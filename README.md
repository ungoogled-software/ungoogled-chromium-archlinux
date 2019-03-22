# ungoogled-chromium-archlinux

Arch Linux packaging for [ungoogled-chromium](//github.com/Eloston/ungoogled-chromium).

## Downloads

Available in the AUR as `ungoogled-chromium`
	* NOTE: `ungoogled-chromium-bin` is *not* officially part of ungoogled-chromium. Please submit all issues to the maintainer of the PKGBUILD.

Alternatively, [get builds from the Contributor Binaries website](//ungoogled-software.github.io/ungoogled-chromium-binaries/).

**Source Code**: Use the tags. The branches are for development and may not be stable.

## Building

TODO

## Developer info

TODO

Patches are in GNU Quilt format.

GN flags in `flags.archlinux.gn` are appended to `flags.gn` from the ungoogled-chromium repo before GN is run.

Useful script `devutils/update_platform_patches.py` in ungoogled-chromium repo to update patches.

## License

See [LICENSE](LICENSE)
