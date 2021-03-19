#!/bin/bash

cd /home/build

echo "==> Downloading aur..."

git clone https://aur.archlinux.org/ungoogled-chromium.git aur
git --git-dir=aur/.git checkout $(cat aur-version.git)

cp aur/* . -nr

echo "==> Resuming build..."
timeout -k 10m -s SIGTERM 310m makepkg --noextract --nodeps

if compgen -G "*.pkg.tar.zst" > /dev/null; then
    echo "==> Checksum of built package:"
    sha256sum *.pkg.tar.zst | tee sum.txt

    mkdir res
    mv *.pkg.tar.zst sum.txt res/
else
    echo "==> Size of src/ directory"
    du -shc src/

    echo "==> Creating source archive... "
    tar caf src.tar.zst src/ --remove-file -H posix --atime-preserve

    echo "==> Checksum of source archive"
    sha256sum src.tar.zst | tee sum.txt

    mkdir build
    mv src.tar.zst sum.txt build/
fi
