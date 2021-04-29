#!/bin/bash

cd /home/build

BUILD_ARGUMENTS=""

if [[ -d "/mnt/input" && -f "/mnt/input/progress.tar.zst.sum" && -f "/mnt/input/progress.tar.zst" ]]; then
    echo "==> Found input directory, extracting source files from there"
    echo "==> Verifying checksums..."

    cd /mnt/input

    sudo sha256sum -c progress.tar.zst.sum

    cd /home/build

    echo "==> Extracting source archive..."
    sudo tar -xf /mnt/input/progress.tar.zst -C /home/build

    echo "==> Deleting source archive..."
    sudo rm /mnt/input/*

    echo "==> Adjusting ownership of build directory..."
    sudo chown -R build .

    echo "==> Build directory content"
    ls -lah .

    echo "==> Build subdirectory sizes" 
    du -h -d 1

    echo "==> Added --noextract --nodeps to build arguments"
    BUILD_ARGUMENTS="--noextract --nodeps"
fi

echo "==> Building with a timeout of ${TIMEOUT:-"1800 (default)"} minute(s)..."
timeout -k 10m -s SIGTERM "${TIMEOUT:-"1800"}m" makepkg $BUILD_ARGUMENTS

EXIT_CODE=$?

if [[ $EXIT_CODE == 0 ]]; then
    echo "==> Build successful"
elif [[ $EXIT_CODE == 124 ]]; then # https://www.gnu.org/software/coreutils/manual/html_node/timeout-invocation.html#timeout-invocation
    echo "==> Build timed out"
else
    echo "==> Build failed with $EXIT_CODE"

    exit $EXIT_CODE
fi

echo "==> Build directory content"
ls -lah /home/build

echo "==> Build subdirectory sizes"
sudo du -hd 1

if compgen -G "*.pkg.tar.zst" > /dev/null; then
    echo "==> Successfully built package"
    echo "==> Creating checksum of package..."

    sha256sum *.pkg.tar.zst | tee sum.txt

    mkdir output -p

    if [[ -d "/mnt/output" ]]; then
        echo "==> Moving package to output directory..."
        sudo mv *.pkg.tar.zst sum.txt /mnt/output
    else
        echo "==> Output directory does not exist, exiting"
    fi
elif [[ -d "/mnt/progress" ]]; then
    echo "==> No package built yet, compressing current build progress"

    echo "==> Creating archive of progress..."
    tar caf progress.tar.zst src/ --remove-file -H posix --atime-preserve

    echo "==> Creating checksum of progress..."
    sha256sum progress.tar.zst | tee progress.tar.zst.sum

    echo "==> Moving archive to progress directory..."
    sudo mv progress.tar.zst progress.tar.zst.sum /mnt/progress
else
    echo "==> No package built yet and progress directory does not exist, exiting"
fi
