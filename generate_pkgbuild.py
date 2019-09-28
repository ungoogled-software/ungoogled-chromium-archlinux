#!/usr/bin/python3 -B
# -*- coding: UTF-8 -*-

# Copyright (c) 2019 The ungoogled-chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
"""
Generates PKGBUILD and print to stdout
"""

from pathlib import Path
import argparse
import re
import string
import subprocess

_PRODUCTION_URL = 'git+https://github.com/ungoogled-software/ungoogled-chromium-archlinux.git'
_ENCODING = 'UTF-8'

# Classes

class _BuildFileStringTemplate(string.Template):
    """
    Custom string substitution class

    Inspired by
    http://stackoverflow.com/questions/12768107/string-substitutions-using-templates-in-python
    """

    pattern = r"""
    {delim}(?:
      (?P<escaped>{delim}) |
      _(?P<named>{id})      |
      {{(?P<braced>{id})}}   |
      (?P<invalid>{delim}((?!_)|(?!{{)))
    )
    """.format(
        delim=re.escape("$$PKGBUILD_TEMPLATE"), id=string.Template.idpattern)


# Methods

def _get_current_commit():
    return subprocess.run(
        ('git', 'rev-parse', '--verify', 'HEAD'),
        check=True,
        capture_output=True,
        encoding=_ENCODING,
    ).stdout.strip()

def _unstaged_changes():
    """Returns True if there are unstaged changes; False otherwise"""
    return subprocess.run(
        ('git', 'diff', '--exit-code'),
        stdout=subprocess.DEVNULL,
    ).returncode != 0

def main():
    """CLI Entrypoint"""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prod', action='store_true',
                        help=(
                            'Add this flag to use the production '
                            'ungoogled-chromium-archlinux repo for building'))
    parser.add_argument('--force', '-f', action='store_true',
                        help=(
                            'Force PKGBUILD generation even if there '
                            'are unstaged changes.'))
    args = parser.parse_args()

    root_dir = Path(__file__).resolve().parent
    ungoogled_repo = root_dir / 'ungoogled-chromium'

    if args.prod:
        archlinux_git_source = _PRODUCTION_URL
    else:
        if not args.force and _unstaged_changes():
            parser.error('There are unstaged changes in git; please commit them or add --force')
        archlinux_git_source = '$pkgname-archlinux::git+file://{}'.format(
            Path(root_dir, '.git').resolve().as_posix()
        )
    archlinux_git_source += '#commit={commit}'.format(
        commit=_get_current_commit()
    )

    chromium_version = (ungoogled_repo / 'chromium_version.txt').read_text(encoding=_ENCODING).strip()
    ungoogled_revision = (ungoogled_repo / 'revision.txt').read_text(encoding=_ENCODING).strip()

    # Print PKGBUILD to stdout
    print(
        _BuildFileStringTemplate(
            Path(root_dir, 'PKGBUILD.in').read_text(encoding=_ENCODING)
        ).substitute(
            archlinux_git_source=archlinux_git_source,
            chromium_version=chromium_version,
            ungoogled_revision=ungoogled_revision,
        )
    )


if __name__ == '__main__':
    main()
