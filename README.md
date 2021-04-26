# ungoogled-chromium-archlinux

Arch Linux packaging for [ungoogled-chromium](//github.com/Eloston/ungoogled-chromium).

## Downloads

In the AUR there are multiple ungoogled-chromium flavors:

1. `ungoogled-chromium` : regular ungoogled-chromium
2. `ungoogled-chromium-git` : ungoogled-chromium but using the master branch of upstream UC patches.

### Binary Downloads

You can get pre-built binaries from the following sources:

- [Contributor Binaries Source](//ungoogled-software.github.io/ungoogled-chromium-binaries/)
- [OBS Production Project](https://build.opensuse.org/packages/ungoogled-chromium-arch/job_history/home:ungoogled_chromium/Arch/x86_64)
- [OBS Development Project](https://build.opensuse.org/packages/ungoogled-chromium-arch/job_history/home:ungoogled_chromium:testing/Arch/x86_64)

**OBS Repository:**

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

**Unofficial Repositories:**

- [chaotic-aur](https://lonewolf.pedrohlc.com/chaotic-aur/) - Maintained by PedroHLC

- [jk-aur](https://github.com/jstkdng/aur) - Maintained by JustKidding

All issues should go to their respective maintainers.

## Building

You only need to clone this repository. After that, run this command:

```
makepkg
```

If the build succeeds, you can run `makepkg --install` or `pacman -U ungoogled-chromium-*.pkg.*`. Running the latter requires you to be in sudo or root.

### Hardware Requirements

* A 64-bit system is required, as Arch has dropped 32-bit support. 8 GB of RAM is highly recommended (per the document in the Chromium source tree under `docs/linux_build_instructions.md`).

## License

See [LICENSE](LICENSE)
