#!/bin/bash
set -e

for i in git curl
do
    if test -z "$(which "$i" || true)"
    then
        echo "The $i binary could not be found. Aborting."
        exit 1
    fi
done

BASE="$(git rev-parse --show-toplevel 2> /dev/null)"
PKGBUILD="${BASE}/PKGBUILD"

if test -z "${BASE}"
then
    echo "BASE directory could not be determined. Aborting."
    exit 1
fi

if test ! -f "${PKGBUILD}"
then
    echo "${PKGBUILD} must exist and be a regular file. Aborting."
    exit 1
fi

for i in OBS_API_USERNAME OBS_API_PASSWORD
do
    if test -z "$(eval echo \$${i})"
    then
        echo "$i is not in the environment. Aborting."
        exit 1
    fi
done

PROJECT="${OBS_API_PROJECT:-home:${OBS_API_USERNAME}}"

get_type()
{
    local TAG
    local TYPE

    TAG="$(git describe --tags --exact-match 2> /dev/null || true)"

    if test -z "${TAG}"
    then
        TYPE='development'
    else
        TYPE='production'
    fi

    echo "${TYPE}"
}

generate_obs()
{
    local ROOT="${1}"
    local CHROMIUM_VERSION="${2}"
    local LAUNCHER_VERSION="${3}"
    local UNGOOGLED_CHROMIUM_ARCHLINUX_VERSION="${4}"
    local UNGOOGLED_CHROMIUM_VERSION="${5}"
    local DEPENDS="${6}"
    local MAKEDEPENDS="${7}"

    cat > "${ROOT}/_service" << EOF
<services>
    <service name="download_url">
        <param name="protocol">https</param>
        <param name="host">commondatastorage.googleapis.com</param>
        <param name="path">chromium-browser-official/chromium-${CHROMIUM_VERSION}.tar.xz</param>
    </service>
    <service name="download_url">
        <param name="protocol">https</param>
        <param name="host">github.com</param>
        <param name="path">foutrelis/chromium-launcher/archive/v${LAUNCHER_VERSION}.tar.gz</param>
        <param name="filename">chromium-launcher-${LAUNCHER_VERSION}.tar.gz</param>
    </service>
    <service name="tar_scm">
        <param name="scm">git</param>
        <param name="url">https://github.com/ungoogled-software/ungoogled-chromium-archlinux.git</param>
        <param name="submodules">disable</param>
        <param name="version">_none_</param>
        <param name="revision">${UNGOOGLED_CHROMIUM_ARCHLINUX_VERSION}</param>
    </service>
    <service name="tar_scm">
        <param name="scm">git</param>
        <param name="url">https://github.com/Eloston/ungoogled-chromium.git</param>
        <param name="submodules">disable</param>
        <param name="version">_none_</param>
        <param name="revision">${UNGOOGLED_CHROMIUM_VERSION}</param>
    </service>
    <service name="recompress">
        <param name="compression">xz</param>
        <param name="file">*.tar</param>
    </service>
</services>
EOF

    cat > "${ROOT}/_constraints" << 'EOF'
<constraints>
    <hardware>
        <disk>
            <size unit="G">16</size>
        </disk>
        <memory>
            <size unit="G">8</size>
        </memory>
    </hardware>
    <overwrite>
        <conditions>
            <arch>x86_64</arch>
        </conditions>
        <hardware>
            <memory>
                <size unit="G">24</size>
            </memory>
        </hardware>
    </overwrite>
</constraints>
EOF

    cp "${PKGBUILD}" "${ROOT}/PKGBUILD"
    sed -r -i \
        -e '/^depends=/,/[)]$/cdepends=('"${DEPENDS}"')' \
        -e '/^depends[+]=/d' \
        -e '/^makedepends=/,/[)]$/cmakedepends=('"${MAKEDEPENDS}"')' \
        -e '/^source=/,/[)]$/csource=(chromium-${_chromium_version}.tar.xz chromium-launcher-$_launcher_ver.tar.gz ungoogled-chromium-archlinux.tar.xz ungoogled-chromium.tar.xz)'\
        "${ROOT}/PKGBUILD"
}

upload_obs()
{
    local USERNAME="${1}"
    local PASSWORD="${2}"
    local ROOT="${3}"
    local TYPE="${4}"
    local REPOSITORY
    local PACKAGE="ungoogled-chromium"
    local FILE
    local FILENAME

    case "${TYPE}" in
    
        production)
            REPOSITORY="${PROJECT}"
            ;;

        development)
            REPOSITORY="${PROJECT}:testing"
            ;;

    esac

    curl -s -K - "https://api.opensuse.org/source/${REPOSITORY}/${PACKAGE}" -F 'cmd=deleteuploadrev' << EOF
user="${USERNAME}:${PASSWORD}"
EOF

    for FILE in "${ROOT}"/*
    do
        FILENAME="${FILE##*/}"
        curl -s -K - "https://api.opensuse.org/source/${REPOSITORY}/${PACKAGE}/${FILENAME}?rev=upload" -T "${FILE}" << EOF
user="${USERNAME}:${PASSWORD}"
EOF
    done

    curl -s -K - "https://api.opensuse.org/source/${REPOSITORY}/${PACKAGE}" -F 'cmd=commit' << EOF
user="${USERNAME}:${PASSWORD}"
EOF
}

. "${PKGBUILD}"

TMP="$(mktemp -d)"
CHROMIUM_VERSION="${_chromium_version}"
LAUNCHER_VERSION="${_launcher_ver}"
UNGOOGLED_CHROMIUM_ARCHLINUX_VERSION="${_ungoogled_archlinux_version}"
UNGOOGLED_CHROMIUM_VERSION="${_ungoogled_version}"
DEPENDS="${depends[*]}"
MAKEDEPENDS="${makedepends[*]} jack"
TYPE="$(get_type)"

generate_obs "${TMP}" "${CHROMIUM_VERSION}" "${LAUNCHER_VERSION}" "${UNGOOGLED_CHROMIUM_ARCHLINUX_VERSION}" "${UNGOOGLED_CHROMIUM_VERSION}" "${DEPENDS}" "${MAKEDEPENDS}"
upload_obs "${OBS_API_USERNAME}" "${OBS_API_PASSWORD}" "${TMP}" "${TYPE}"

rm -rf "${TMP}"
