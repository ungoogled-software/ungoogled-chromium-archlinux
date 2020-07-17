# ungoogled-chromium-archlinux

Arch Linux packaging for [ungoogled-chromium](//github.com/Eloston/ungoogled-chromium).

## Downloads

Available in the AUR as `ungoogled-chromium`, wayland users could benefit from using `ungoogled-chromium-ozone` and `ungoogled-chromium-git` is for the bleeding edge experience.

### Binary Downloads

You can get pre-built binaries from the following sources, just follow the instructions on each site:

[Contributor Binaries website](//ungoogled-software.github.io/ungoogled-chromium-binaries/) - Binaries
contributed by ungoogled chromium users.

** Unofficial Repositories **

[chaotic-aur](https://lonewolf.pedrohlc.com/chaotic-aur/) - Maintained by PedroHLC

[jk-aur](https://github.com/jstkdng/aur) - Maintained by JustKidding

All issues should go to their respective maintainers.

## Building

You only need to download the PKGBUILD from this repository. After that, run this command:

```
makepkg
```

If the build succeeds, you can run `makepkg --install` or `pacman -U ungoogled-chromium-*.pkg.*`. Running the latter requires you to be in sudo or root.

### Hardware Requirements

* A 64-bit system is required, as Arch has dropped 32-bit support. 8 GB of RAM is highly recommended (per the document in the Chromium source tree under `docs/linux_build_instructions.md`).

## Developer info

### Updating docker image

You can forcefully update the docker image used for CI by committing any
change to the `.cirrus_Dockerfile` file. This is particularly important to
try when `validate_makepkg_task` is failing for unknown reasons.

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

Afterwards, update `_ungoogled_version` in PKGBUILD to the same tag the submodule is using (`cd` into the submodule, then use `git describe` to get the needed tag).

## License

See [LICENSE](LICENSE)
