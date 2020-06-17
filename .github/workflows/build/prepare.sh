#!/bin/bash
shopt -s dotglob

cd $HOME

echo "==> Prepairing sources..."
makepkg --nobuild --nodeps

echo "==> Size of src/ directory"
du -shc src/

echo "==> Compressing src/ directory..."
tar caf src.tar.zst src/ --remove-file -H posix --atime-preserve

echo "==> Size of src/ archive"
du -shc src.tar.zst

echo "==> Resulting sha256sum of src/ archive"
sha256sum src.tar.zst
