# ungoogled-chromium-archlinux

Arch Linux packaging for [ungoogled-chromium](//github.com/ungoogled-software/ungoogled-chromium).

## A note on reproducibility

While [extra/chromium builds are reproducible](https://reproducible.archlinux.org/api/v0/pkgs/list?name=chromium), this repository currently
doesn't publish reproducible builds:

- Due to [limitations of GitHub Actions](https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration#usage-limits) it's not possible to continuously run the build process on GitHub-hosted runners. This prevents being able to build in a reproducible way.
- OBS [does not](https://github.com/openSUSE/obs-build/issues/753) build Arch Linux packages in a reproducible way.

Container images published by this repository will (since version `92.0.4515.131-1`) always produce the same output, this however is not compatible by tools like [repro](https://github.com/archlinux/archlinux-repro)

## Binary Downloads

You can get pre-built binaries from the following sources:

- [AUR ungoogled-chromium-bin](https://aur.archlinux.org/packages/ungoogled-chromium-bin)
- [Contributor Binaries Source](//ungoogled-software.github.io/ungoogled-chromium-binaries/)
- [OBS Production Project](//build.opensuse.org/package/show/home:ungoogled_chromium/ungoogled-chromium-arch)
- [OBS Development Project](//build.opensuse.org/package/show/home:ungoogled_chromium:testing/ungoogled-chromium-arch)

### Open Build Service Repository

We now defer to here:
[OBS Setup Instructions](https://software.opensuse.org//download.html?project=home%3Aungoogled_chromium&package=ungoogled-chromium)

Also note, if you have added the repository previously, you may eventually
get errors about expired keys. This is due to how OBS generates repository
keys and we have no known way to control it. At present the only known
solution is to redo the steps for adding the repository key as OBS does
regenerate it eventually with a new expiration date.

### Unofficial Repositories

- [chaotic-aur](https://lonewolf.pedrohlc.com/chaotic-aur/) - Maintained by PedroHLC
- [jk-aur](https://github.com/jstkdng/aur) - Maintained by JustKidding
- [cachy-repo](https://wiki.cachyos.org/en/home/Repo) - Maintained by ptr1337

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

# Start the build, this will download all necessary dependencies automatically
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
