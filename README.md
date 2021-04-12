# ungoogled-chromium-archlinux

Arch Linux packaging for [ungoogled-chromium](//github.com/Eloston/ungoogled-chromium).

## Downloads

In the AUR there are multiple ungoogled-chromium flavors:

1. `ungoogled-chromium` : regular ungoogled-chromium
2. `ungoogled-chromium-git` : ungoogled-chromium but using the master branch of upstream UC patches.

### Binary Downloads

You can get pre-built binaries from the following sources, just follow the instructions on each site:

[Contributor Binaries website](//ungoogled-software.github.io/ungoogled-chromium-binaries/) - Binaries contributed by ungoogled chromium users.

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
