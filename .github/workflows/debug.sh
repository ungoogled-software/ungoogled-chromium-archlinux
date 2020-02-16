#!/usr/bin/env bash
set -eux -o pipefail


# For debugging script
sed -i '/# Assemble GN flags/a \ \ cat "$_ungoogled_archlinux_repo/flags.archlinux.gn"' PKGBUILD

# Remove jumbo
# sed -i '/# Assemble GN flags/a \ \ sed -i -e '\''/use_jumbo_build=/d'\'' -e '\''/jumbo_file_merge_limit=/d'\'' "$_ungoogled_archlinux_repo/flags.archlinux.gn"' PKGBUILD

# Add debug flags
sed -i '/# Assemble GN flags/a \ \ sed -i -e '\''s/is_debug=false/is_debug=true/g'\'' -e '\''s/blink_symbol_level=0/blink_symbol_level=1/g'\'' -e '\''s/symbol_level=0/symbol_level=1/g'\'' "$_ungoogled_archlinux_repo/flags.archlinux.gn"' PKGBUILD
