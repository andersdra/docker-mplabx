#!/bin/bash
# hack to kill firefox when downloads are finished
# causes exception:
# selenium.common.exceptions.WebDriverException: Message: Failed to decode response from marionette

sleep 45

while :
do
  if ! find /toolchains -name "*.part" | read
  then
    echo "finished download(s)"
    pgrep firefox-esr | xargs kill
    exit 0
  fi
  sleep 5
done
