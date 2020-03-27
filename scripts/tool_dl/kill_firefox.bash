#!/bin/bash
# hack to kill firefox when downloads are finished
# causes exception:
# selenium.common.exceptions.WebDriverException: Message: Failed to decode response from marionette

# wait for downloads to start
while ! find /toolchains -name "*.part" | read -r;do
    if find /toolchains -name "*.part" | read -r;then
        break
    fi
    sleep 5
done

while :;do
  if ! find /toolchains -name "*.part" | read -r;then
    echo "Finished download(s)"
    pgrep firefox-esr | xargs kill
    exit 0
  fi
  sleep 5
done
