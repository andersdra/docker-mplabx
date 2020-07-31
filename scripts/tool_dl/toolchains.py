#!/usr/bin/env python3
# selenium powered downloader for microchip toolchains
# needs a valid microchip user
import os
import sys
import pickle
import multiprocessing as mp
from time import sleep
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.firefox.firefox_binary import FirefoxBinary

binary = FirefoxBinary('/tmp/firefox/firefox')

options = Options()
options.headless = True

mcp_url='https://www.microchip.com/wwwregister/default.aspx?ReturnURL=https://www.microchip.com/mymicrochip/%23/?mode=SetPreference&RedirectedFrom=Login&DestURL=Home'

toolchains = ['AVRGCC', 'ARMGCC', 'MCPXC8', 'MCPXC16', 'MCPXC32', 'MPLAB_HARMONY', 'PIC32_LEGACY', 'OTHERMCU']

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
driver = webdriver.Firefox(firefox_profile=profile, service_log_path=os.path.devnull, firefox_binary=binary, options=options)

def save_cookie(web_driver, path):
    with open(path, 'wb') as filehandler:
        pickle.dump(web_driver.get_cookies(), filehandler)

def load_cookie(web_driver, path):
    with open(path, 'rb') as cookiesfile:
        cookies = pickle.load(cookiesfile)
        for cookie in cookies:
            web_driver.add_cookie(cookie)


def mcp_login(mc_user, mc_pass):
    driver.get(mcp_url)
    username = driver.find_element_by_id('_ctl0__ctl0_MainContent_PageContent_Login1_txtAccount')
    username.send_keys(mc_user)
    password = driver.find_element_by_id('_ctl0__ctl0_MainContent_PageContent_Login1_txtPassword')
    password.send_keys(mc_pass)
    login = driver.find_element_by_id('_ctl0__ctl0_MainContent_PageContent_Login1_LinkButton1')
    login.click()
    save_cookie(driver, '/tmp/selenium_cookies')


def mcp_get(dl_url):
    dl = webdriver.Firefox(firefox_profile=profile, service_log_path=os.path.devnull, firefox_binary=binary, options=options)
    dl.get('https://www.microchip.com/mymicrochip/')
    load_cookie(dl, '/tmp/selenium_cookies')
    a = mp.Process(target=dl.get, args=(dl_url,))
    a.start()


def check_downloads():
    downloads = 0
    for filename in os.listdir(os.environ['DOWNLOAD_DIR']):
        if '.part' in filename:
            print("{} size; {}".format(filename, os.path.getsize(os.environ['DOWNLOAD_DIR'] + "/{}".format(filename))))
            downloads += 1
    if downloads:
        sleep(2)
        check_downloads()

try:
    mcp_login(os.environ['MCP_USER'], os.environ['MCP_PASS'])
except:
    print('myMicrochip login error')
    sys.exit(1)

for tool in toolchains:
    if tool in os.environ:
        if os.environ[tool] == '1':
            url = os.environ[tool + '_URL']
            if '.microchip.com' in url:
                print('Starting download of {}'.format(tool))
                mcp_get(os.environ[tool + '_URL'])
                sleep(.5)
            else:
                print('User defined {} URL {}'.format(tool, url))

sleep(1)
check_downloads()
sys.exit(0)

