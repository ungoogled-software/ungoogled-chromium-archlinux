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
    echo "Submodule updated. Commit the change when you can."
fi
