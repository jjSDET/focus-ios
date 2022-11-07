#!/bin/sh

set -e

if [ ! -d Blockzilla.xcodeproj ]; then
  echo "[E] Run this script from the project root as tools/export-strings.sh"
  exit 1
fi

if [ -d "focusios-l10n" ]; then
echo "Focus iOS L10 directory found. Removing to re-clone for fresh start."
rm -Rf focusios-l10n;
fi

echo "[*] Cloning mozilla-l10n/focusios-l10n"
git clone https://github.com/mozilla-l10n/focusios-l10n.git

echo "[*] Cloning mozilla-mobile/LocalizationTools"
[ -d tools/Localizations ] && rm -rf tools/Localizations
git clone https://github.com/mozilla-mobile/LocalizationTools.git tools/Localizations

echo "\n\n[*] Building tools/Localizations"
(cd tools/Localizations && swift build)

echo "[*] Replacing firefox with focus in swift task files"
sed -i '' 's/firefox-ios.xliff/focus-ios.xliff/g' tools/Localizations/Sources/LocalizationTools/tasks/*.swift

echo "\n\n[*] Exporting Strings (output in export-strings.log)"
(cd tools/Localizations && swift run LocalizationTools \
  --export \
  --project-path "$PWD/../../Blockzilla.xcodeproj" \
  --l10n-project-path "$PWD/../../focusios-l10n") > export-strings.log 2>&1

echo "\n\n[!] Hooray strings have been succesfully exported."
echo "[!] You can create a PR in the focusios-l10n checkout"
