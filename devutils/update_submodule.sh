#!/bin/bash

UNGOOGLED_REPO=$(dirname $(dirname $(readlink -f ${BASH_SOURCE[0]})))/ungoogled-chromium

CHROMIUM_VERSION=$(curl -sL https://raw.githubusercontent.com/Eloston/ungoogled-chromium/master/chromium_version.txt)
UNGOOGLED_REVISION=$(curl -sL https://raw.githubusercontent.com/Eloston/ungoogled-chromium/master/revision.txt)

if [ UNGOOGLED_REVISION != "0" ]
then
    UPDATED_TAG="${CHROMIUM_VERSION}-${UNGOOGLED_REVISION}"
else
    UPDATED_TAG="${CHROMIUM_VERSION}"
fi
    
# Ensure the submodule is initialized.
git submodule init
git submodule update

# Update the submodule.
cd $UNGOOGLED_REPO
CURRENT_TAG=$(git describe)
if [ CURRENT_TAG == UPDATED_TAG ]
then
    echo "Submodule already on latest version."
else
    git checkout $TAG
    echo "Submodule updated. Commit the change when you can."
fi
