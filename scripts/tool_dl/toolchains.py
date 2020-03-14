#!/usr/bin/env python3
# selenium powered downloader for microchip toolchains
# needs a valid microchip user

import os

mcp_download=False
try:
    os.environ['MCP_USER'] # check if downloading from microchip
    mcp_download=True
except TypeError: # no user, alternative downloader
    print('ALTERNATIVE DOWNLOAD')

if mcp_download:
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
    profile.set_preference('browser.helperApps.neverAsk.saveToDisk', 'application/x-tar, application/x-gzip, application/x-sh, application/x-zip, application/x-gtar, application/x-7z-compressed')
    profile.update_preferences()
    driver = webdriver.Firefox(firefox_profile=profile, service_log_path=os.path.devnull)

    def save_cookie(driver, path):
        with open(path, 'wb') as filehandler:
            pickle.dump(driver.get_cookies(), filehandler)

    def load_cookie(driver, path):
        with open(path, 'rb') as cookiesfile:
            cookies = pickle.load(cookiesfile)
            for cookie in cookies:
                driver.add_cookie(cookie)

    def login(mc_user, mc_pass):
        driver.get('https://www.microchip.com/mymicrochip/')
        driver.find_element_by_id('_ctl0__ctl0_MainContent_PageContent_Login1_txtAccount').send_keys(mc_user)
        driver.find_element_by_id ('_ctl0__ctl0_MainContent_PageContent_Login1_txtPassword').send_keys(mc_pass)
        driver.find_element_by_id('_ctl0__ctl0_MainContent_PageContent_Login1_LinkButton1').click()
        save_cookie(driver, '/selenium_cookies')

    def toolchain_dl(dl_url):
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

    login(os.environ['MCP_USER'], os.environ['MCP_PASS'])

    toolchains = ['AVRGCC', 'ARMGCC', 'MCPXC8', 'MCPXC16', 'MCPXC32', 'MPLAB_HARMONY', 'PIC32_LEGACY', 'OTHERMCU']
    for tool in toolchains:
        if tool in os.environ:
            print('Started download of {}'.format(tool))
            toolchain_dl(os.environ[tool + '_URL'])
            sleep(5)
    check_downloads()
    exit(0)
else:
    print('Alternative Download')
    exit(0)
