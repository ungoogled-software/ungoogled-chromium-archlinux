#!/bin/bash
set -e
shopt -s dotglob

cd /home/build

echo "==> Downloading aur..."

git clone https://aur.archlinux.org/ungoogled-chromium.git aur
git --git-dir=aur/.git checkout $(cat aur-version.git)

cp aur/* . -nr
rm -rf aur

echo "==> Prepairing sources..."
makepkg --nobuild --nodeps

echo "==> Size of src/ directory"
du -shc src/

echo "==> Creating source archive... "
tar caf src.tar.zst src/ --remove-file -H posix --atime-preserve

echo "==> Checksum of source archive"
sha256sum src.tar.zst | tee sum.txt

mkdir build
mv src.tar.zst sum.txt build/
