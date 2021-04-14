#!/bin/bash
set -e

for i in git curl xmlstarlet
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
    local i
    local filename
    local url
    local protocol
    local host
    local path

    echo '<services>' > "${ROOT}/_service"
    for i in "${source[@]}"
    do
        if echo "${i}" | grep -q 'https://'
        then
            if echo "${i}" | grep -q '::'
            then
                filename="$(echo "${i}" | awk -v FS='::' '{print $1}')"
                url="$(echo "${i}" | awk -v FS='::' '{print $2}')"
            else
                filename=''
                url="${i}"
            fi
            protocol="$(echo "${url}" | cut -d / -f 1 | cut -d : -f 1)"
            host="$(echo "${url}" | cut -d / -f 3)"
            path="$(echo "${url}" | cut -d / -f 4-)"
            printf '%s<service name="download_url">\n' '    ' >> "${ROOT}/_service"
            printf '%s<param name="protocol">%s</param>\n' '        ' "${protocol}" >> "${ROOT}/_service"
            printf '%s<param name="host">%s</param>\n' '        ' "${host}" >> "${ROOT}/_service"
            printf '%s<param name="path">%s</param>\n' '        ' "${path}" >> "${ROOT}/_service"
            if test -n "${filename}"
            then
                printf '%s<param name="filename">%s</param>\n' '        ' "${filename}" >> "${ROOT}/_service"
            fi
            printf '%s</service>\n' '    ' >> "${ROOT}/_service"
        else
            cp "${BASE}/${i}" "${ROOT}"
        fi
    done
    echo '</services>' >> "${ROOT}/_service"

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
        "${ROOT}/PKGBUILD"
}

upload_obs()
{
    local USERNAME="${1}"
    local PASSWORD="${2}"
    local ROOT="${3}"
    local TYPE="${4}"
    local REPOSITORY
    local PACKAGE="ungoogled-chromium-arch"
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

    curl -sS -K - "https://api.opensuse.org/source/${REPOSITORY}/${PACKAGE}" -F 'cmd=deleteuploadrev' << EOF
user="${USERNAME}:${PASSWORD}"
EOF

    curl -sS -K - "https://api.opensuse.org/source/${REPOSITORY}/${PACKAGE}" > directory.xml << EOF
user="${USERNAME}:${PASSWORD}"
EOF

    xmlstarlet sel -t -v '//entry/@name' < directory.xml | while read FILENAME
    do
        curl -sS -K - "https://api.opensuse.org/source/${REPOSITORY}/${PACKAGE}/${FILENAME}?rev=upload" -X DELETE << EOF
user="${USERNAME}:${PASSWORD}"
EOF
    done

    rm -f directory.xml

    for FILE in "${ROOT}"/*
    do
        FILENAME="${FILE##*/}"
        curl -sS -K - "https://api.opensuse.org/source/${REPOSITORY}/${PACKAGE}/${FILENAME}?rev=upload" -T "${FILE}" << EOF
user="${USERNAME}:${PASSWORD}"
EOF
    done

    curl -sS -K - "https://api.opensuse.org/source/${REPOSITORY}/${PACKAGE}" -F 'cmd=commit' << EOF
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
MAKEDEPENDS="${makedepends[*]} jack jre-openjdk-headless"
TYPE="$(get_type)"

generate_obs "${TMP}" "${CHROMIUM_VERSION}" "${LAUNCHER_VERSION}" "${UNGOOGLED_CHROMIUM_ARCHLINUX_VERSION}" "${UNGOOGLED_CHROMIUM_VERSION}" "${DEPENDS}" "${MAKEDEPENDS}"
upload_obs "${OBS_API_USERNAME}" "${OBS_API_PASSWORD}" "${TMP}" "${TYPE}"

rm -rf "${TMP}"
