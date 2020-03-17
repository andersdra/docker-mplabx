#!/usr/bin/env python3
# selenium powered downloader for microchip toolchains
# needs a valid microchip user
import os
import sys
import wget
import pickle
import multiprocessing as mp
from time import sleep
from selenium import webdriver

profile = webdriver.FirefoxProfile()
# remove download dialog, set download directory etc
profile.set_preference('browser.preferences.instantApply', True)
profile.set_preference('browser.helperApps.alwaysAsk.force', False)
profile.set_preference('browser.download.manager.showWhenStarting', False)
profile.set_preference('browser.download.dir', os.environ['DOWNLOAD_DIR'])
profile.set_preference('browser.download.folderList', 2)
# add sh and all tar+zip mime types for automatic download
profile.set_preference('browser.helperApps.neverAsk.saveToDisk', \
'application/x-tar, \
application/x-gzip, \
application/x-sh, \
application/x-zip, \
application/x-gtar, \
application/x-7z-compressed')
profile.update_preferences()
driver = webdriver.Firefox(firefox_profile=profile, service_log_path=os.path.devnull)

def save_cookie(web_driver, path):
    with open(path, 'wb') as filehandler:
        pickle.dump(web_driver.get_cookies(), filehandler)

def load_cookie(web_driver, path):
    with open(path, 'rb') as cookiesfile:
        cookies = pickle.load(cookiesfile)
        for cookie in cookies:
            web_driver.add_cookie(cookie)


def mcp_login(mc_user, mc_pass):
    driver.get('https://www.microchip.com/mymicrochip/')
    username = driver.find_element_by_id('_ctl0__ctl0_MainContent_PageContent_Login1_txtAccount')
    username.send_keys(mc_user)
    password = driver.find_element_by_id('_ctl0__ctl0_MainContent_PageContent_Login1_txtPassword')
    password.send_keys(mc_pass)
    login = driver.find_element_by_id('_ctl0__ctl0_MainContent_PageContent_Login1_LinkButton1')
    login.click()
    save_cookie(driver, '/selenium_cookies')


def mcp_get(dl_url):
    dl = webdriver.Firefox(firefox_profile=profile, service_log_path=os.path.devnull)
    dl.get('https://www.microchip.com/mymicrochip/')
    load_cookie(dl, '/selenium_cookies')
    a = mp.Process(target=dl.get, args=(dl_url,))
    a.start()


def check_downloads():
    for filename in os.listdir(os.environ['DOWNLOAD_DIR']):
        if '.part' in filename:
            sleep(1)
            check_downloads()


try:
    mcp_login(os.environ['MCP_USER'], os.environ['MCP_PASS'])
except TypeError:
    print('No Microchip user/pass input')

toolchains = ['AVRGCC', 'ARMGCC', 'MCPXC8', 'MCPXC16', 'MCPXC32', 'MPLAB_HARMONY', 'PIC32_LEGACY', 'OTHERMCU']
for tool in toolchains:
    if tool in os.environ:
        url = os.environ[tool + '_URL']
        if '.microchip.com' in url:
            print('Started download of {}'.format(tool))
            mcp_get(os.environ[tool + '_URL'])
            sleep(5)
        else:
            print('User defined URL of {}, will be downloaded later'.format(tool))

check_downloads()
sys.exit(0)
