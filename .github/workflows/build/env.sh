#/bin/bash
set -e
shopt -s dotglob

echo "==> Installing required packages"
pacman -Syu --noconfirm jq coreutils

echo "==> Copying build files..."
cp -r * /home/build
chown -R build /home/build

echo "==> Copying makepkg.conf..."
rm /etc/makepkg.conf
cp .github/workflows/build/makepkg.conf /etc/makepkg.conf
