#!/bin/bash
# hack to kill firefox when downloads are finished
# causes exception:
# selenium.common.exceptions.WebDriverException: Message: Failed to decode response from marionette

part_file_exists() {
  find /toolchains -name "*.part" | read -r
}

# wait for downloads to start
while ! part_file_exists;do
    if part_file_exists;then
        break
    fi
    sleep 5
done

while :;do
  if ! part_file_exists;then
    echo "Finished download(s)"
    pgrep firefox-esr | xargs kill
    exit 0
  fi
  sleep 5
done
