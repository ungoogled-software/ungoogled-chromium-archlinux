# ungoogled-chromium-archlinux

Arch Linux packaging for [ungoogled-chromium](//github.com/Eloston/ungoogled-chromium).

## A note on reproducibility

[Just as](https://reproducible.archlinux.org/api/v0/pkgs/list?name=chromium) the official archlinux package, binaries compiled
from this repository are reproducible. Still different build systems will in most cases produce different binaries. This is due to the
[SOURCE_DATE_EPOCH](https://reproducible-builds.org/docs/source-date-epoch/) variable not being the same.

To check the reproducibility of a binary, [repro](https://github.com/archlinux/archlinux-repro) can be used. It will use a timestamp stored in the package.

Docker images built by GitHub Actions since version 92.0.4515.131-1 will use a predefined timestamp for building, meaning that a given image will always produce
the same binary.

## Binary Downloads

You can get pre-built binaries from the following sources:

- [Contributor Binaries Source](//ungoogled-software.github.io/ungoogled-chromium-binaries/)
- [OBS Production Project](//build.opensuse.org/package/show/home:ungoogled_chromium/ungoogled-chromium-arch)
- [OBS Development Project](//build.opensuse.org/package/show/home:ungoogled_chromium:testing/ungoogled-chromium-arch)

### Open Build Service Repository

Use these commands to add the OBS repository:

```sh
curl -s 'https://download.opensuse.org/repositories/home:/ungoogled_chromium/Arch/x86_64/home_ungoogled_chromium_Arch.key' | sudo pacman-key -a -
echo '
[home_ungoogled_chromium_Arch]
SigLevel = Required TrustAll
Server = https://download.opensuse.org/repositories/home:/ungoogled_chromium/Arch/$arch' | sudo tee --append /etc/pacman.conf
sudo pacman -Sy
```

Use this command to install ungoogled-chromium:

```sh
sudo pacman -Sy ungoogled-chromium
```

### Unofficial Repositories

- [chaotic-aur](https://lonewolf.pedrohlc.com/chaotic-aur/) - Maintained by PedroHLC
- [jk-aur](https://github.com/jstkdng/aur) - Maintained by JustKidding

All issues should go to their respective maintainers.

## Building

### On your host (aur)

In the AUR there are multiple ungoogled-chromium flavors:

1. `ungoogled-chromium`: regular ungoogled-chromium
2. `ungoogled-chromium-git`: ungoogled-chromium but using the master branch of upstream UC patches.

### On your host (manually)

For the latest full version, run the following commands:

```sh
# Install required dependencies. Make sure your user has access to sudo
sudo pacman -S base-devel

# Clone this repository
git clone https://github.com/ungoogled-software/ungoogled-chromium-archlinux

# Navigate into the repository
cd ungoogled-chromium-archlinux

# Check out the latest tag
git checkout $(git describe --abbrev=0 --tags)

# Start the build, this will download all nessesarry dependencies automatically
makepkg -s
```

For the latest testing version, run these commands instead:

```sh
# Install required dependencies. Make sure your user has access to sudo
sudo pacman -S base-devel

# Clone this repository
git clone https://github.com/ungoogled-software/ungoogled-chromium-archlinux

# Navigate into the repository
cd ungoogled-chromium-archlinux

# Start the build, this will download all necessary dependencies automatically
makepkg -s
```

If the build succeeds, you can run `makepkg --install` or `pacman -U ungoogled-chromium-*.pkg.*`. Running the latter requires root permission.

### In a container

For the latest testing version, run these commands instead:

```sh
# Create a directory for the package output
mkdir output

# Start the build, the image already contains all nessesarry dependencies 
docker run --rm --mount type=bind,source=$(pwd)/output,target=/mnt/output ghcr.io/ungoogled-software/ungoogled-chromium-archlinux-testing:latest
```

Now you can install the package using `pacman -U output/ungoogled-chromium-*.pkg.*`, this requires root permission.

### Hardware Requirements

A 64-bit system is required, as Arch has dropped 32-bit support.
8 GB of RAM is highly recommended (per the document in the Chromium source tree under `docs/linux_build_instructions.md`).

## License

See [LICENSE](LICENSE)
