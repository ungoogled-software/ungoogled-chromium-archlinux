#/bin/bash
set -e
shopt -s dotglob

echo "==> Installing required packages"
pacman -Syu --noconfirm jq coreutils

# Work-around the issue with glibc 2.33 on old Docker engines
# Extract files directly as pacman is also affected by the issue
# See https://github.com/lxqt/lxqt-panel/pull/1562
patched_glibc=glibc-linux4-2.33-4-x86_64.pkg.tar.zst
curl -LO https://repo.archlinuxcn.org/x86_64/$patched_glibc
bsdtar -C / -xvf $patched_glibc
rm $patched_glibc

echo "==> Copying build files..."
cp -r * /home/build
chown -R build /home/build

echo "==> Copying makepkg.conf..."
rm /etc/makepkg.conf
cp .github/workflows/build/makepkg.conf /etc/makepkg.conf
