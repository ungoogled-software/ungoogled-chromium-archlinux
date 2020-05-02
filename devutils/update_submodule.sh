#!/bin/bash

UNGOOGLED_REPO=$(dirname $(dirname $(readlink -f ${BASH_SOURCE[0]})))/ungoogled-chromium

# Ensure the submodule is initialized.
git submodule init
git submodule update

# Pull latest commits and get the submodule's current tag.
cd $UNGOOGLED_REPO
CURRENT_TAG=$(git describe)
git checkout master -q
git pull
git checkout $CURRENT_TAG -q
cd ..

CHROMIUM_VERSION=$(git --git-dir=ungoogled-chromium/.git show origin/master:chromium_version.txt)
UNGOOGLED_REVISION=$(git --git-dir=ungoogled-chromium/.git show origin/master:revision.txt)
SHA256=$(curl -sL https://commondatastorage.googleapis.com/chromium-browser-official/chromium-$CHROMIUM_VERSION.tar.xz.hashes | grep sha256 | cut -d ' ' -f3)

UPDATED_TAG="${CHROMIUM_VERSION}-${UNGOOGLED_REVISION}"

# Update the submodule.
cd $UNGOOGLED_REPO
if [ $CURRENT_TAG == $UPDATED_TAG ]
then
    echo "Submodule already on latest version."
else
    git checkout $UPDATED_TAG -q
    cd ..
    git add ungoogled-chromium
    sed -r -i -e "/^_ungoogled_version=/c_ungoogled_version='$UPDATED_TAG'" -e "0,/[0-9A-Fa-f]{64}/{s//$SHA256/}" PKGBUILD
    echo "Submodule updated. Commit the change when you can."
fi
