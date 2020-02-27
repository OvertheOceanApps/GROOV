#!/bin/sh
RESOURCES_DIR_PATH="../groov/Resources"
HASH_FILE_PATH="$RESOURCES_DIR_PATH/checksum.md5"

current_resources_hash=`find $RESOURCES_DIR_PATH -type f ! -path "$HASH_FILE_PATH" -print0 | sort -z | xargs -0 md5 | md5`

resources_hash_changed() {
  touch $HASH_FILE_PATH
  old_resources_hash=`cat $HASH_FILE_PATH`
  [ "$old_resources_hash" != "$current_resources_hash" ]
}

swiftgen_not_installed() {
  ! which swiftgen >/dev/null
}

if swiftgen_not_installed
then
  echo "❗️ SwiftGen is not installed."
  echo "ℹ️ 'brew bundle' command will be executed."
  brew bundle --file="../Brewfile"
fi

if resources_hash_changed
then
  echo "🈶 Resources hash had been changed."
  echo "ℹ️ 'swiftgen' command will be executed."
  (cd .. && swiftgen)
  echo $current_resources_hash >| $HASH_FILE_PATH
fi
