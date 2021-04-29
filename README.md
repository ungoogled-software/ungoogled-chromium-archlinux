# ungoogled-chromium-archlinux

Arch Linux packaging for [ungoogled-chromium](//github.com/Eloston/ungoogled-chromium).

## Binary Downloads

You can get pre-built binaries from the following sources:

- [Contributor Binaries Source](//ungoogled-software.github.io/ungoogled-chromium-binaries/)
- [OBS Production Project](//build.opensuse.org/package/show/home:ungoogled_chromium/ungoogled-chromium-arch)
- [OBS Development Project](//build.opensuse.org/package/show/home:ungoogled_chromium:testing/ungoogled-chromium-arch)

### Open Build Service Repository

Use these commands to add the OBS repository:

```sh
curl -s 'https://download.opensuse.org/repositories/home:/ungoogled_chromium/Arch/x86_64/home_ungoogled_chromium_Arch.key' | sudo pacman-key -a -
sudo cat >> /etc/pacman.conf << 'EOF'

[home_ungoogled_chromium_Arch]
SigLevel = Required TrustAll
Server = https://download.opensuse.org/repositories/home:/ungoogled_chromium/Arch/$arch
EOF
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
# Clone this repository
git clone https://github.com/ungoogled-software/ungoogled-chromium-archlinux

# Navigate into the repository
cd ungoogled-chromium-archlinux

# Check out the latest tag
git checkout $(git describe --abbrev=0 --tags)

# Start the build, this will download all nessesarry dependencies automatically
makepkg
```

For the latest testing version, run these commands instead:

```sh
# Clone this repository
git clone https://github.com/ungoogled-software/ungoogled-chromium-archlinux

# Navigate into the repository
cd ungoogled-chromium-archlinux

# Start the build, this will download all nessesarry dependencies automatically
makepkg
```

If the build succeeds, you can run `makepkg --install` or `pacman -U ungoogled-chromium-*.pkg.*`. Running the latter requires root permission.

### In a container

> Note: Currently github does not support pulling an image anonymously. See [the github roadmap](https://github.com/github/roadmap/issues/121)

For the latest testing version, run these commands instead:

```sh
# Create a directory for the package output
mkdir output

# Start the build, the image already contains all nessesarry dependencies 
docker run --mount type=bind,source=$(pwd)/output,target=/mnt/output docker.pkg.github.com/ungoogled-software/ungoogled-chromium-archlinux/ungoogled-chromium-archlinux-testing:latest
```

Now you can install the package using `pacman -U output/ungoogled-chromium-*.pkg.*`, this requires root permission.

### Hardware Requirements

A 64-bit system is required, as Arch has dropped 32-bit support.
8 GB of RAM is highly recommended (per the document in the Chromium source tree under `docs/linux_build_instructions.md`).

## License

See [LICENSE](LICENSE)
