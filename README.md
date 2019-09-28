# ungoogled-chromium-archlinux

Arch Linux packaging for [ungoogled-chromium](//github.com/Eloston/ungoogled-chromium).

## Downloads

Available in the AUR as `ungoogled-chromium`

* NOTE: `ungoogled-chromium-bin` is *not* officially part of ungoogled-chromium. Please submit all issues to the maintainer of the PKGBUILD.

Alternatively, [get builds from the Contributor Binaries website](//ungoogled-software.github.io/ungoogled-chromium-binaries/).

**Source Code**: It is recommended to use a tag. You may also use `master`, but it is for development and may not be stable.

## Building

Download the PKGBUILD file from the `pkgbuild` branch. After that, run this command:

```
makepkg
```

If the build succeeds, you can run `makepkg --install` or `pacman -U ungoogled-chromium-*pkgver*.tar.xz`. Running the latter requires you to be in sudo or root.

### Hardware Requirements

* A 64-bit system is required, as Arch has dropped 32-bit support. 8 GB of RAM is highly recommended (per the document in the Chromium source tree under `docs/linux_build_instructions.md`).

## Developer info

### Update submodule

The submodule is primarily needed for `devutils`. Use `devutils/update_submodule.sh` to update the submodule.

### Update patches

You need to clone the entire repository, along with the submodules, with this command:

`git clone --recurse-submodules https://github.com/ungoogled-software/ungoogled-chromium-archlinux`

You should update the submodule first. After that, do this entire section below:

```sh
./devutils/update_patches.sh merge
source devutils/set_quilt_vars.sh

# Setup Chromium source
mkdir -p build/{src,download_cache}
./ungoogled-chromium/utils/downloads.py retrieve -i ungoogled-chromium/downloads.ini -c build/download_cache
./ungoogled-chromium/utils/downloads.py unpack -i ungoogled-chromium/downloads.ini -c build/download_cache build/src

cd build/src
# Use quilt to refresh patches. See ungoogled-chromium's docs/developing.md section "Updating patches" for more details
quilt pop -a

cd ../../
# Remove all patches introduced by ungoogled-chromium
./devutils/update_patches.sh unmerge
# Ensure patches/series is formatted correctly, e.g. blank lines

# Sanity checking for consistency in series file
./devutils/check_patch_files.sh

# Use git to add changes and commit
```

## License

See [LICENSE](LICENSE)
