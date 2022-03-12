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

curl()
{
    for i in `seq 1 5`
    do
        {
        command curl -sS -K - "${@}" << EOF
user="${OBS_API_USERNAME}:${OBS_API_PASSWORD}"
EOF
        } && return 0 || sleep 30s
    done
    return 1
}

get_type()
{
    if [ "$OBS_REPOSITORY_TYPE" = "" ]; then
        echo "production"
    else
        echo "${OBS_REPOSITORY_TYPE}"
    fi
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

    echo '<services>' > "${ROOT}/_service"
    for i in "${source[@]}"
    do
        if echo "${i}" | grep -q -E 'https?://'
        then
            if echo "${i}" | grep -q '::'
            then
                filename="$(echo "${i}" | awk -v FS='::' '{print $1}')"
                url="$(echo "${i}" | awk -v FS='::' '{print $2}')"
            else
                filename=''
                url="${i}"
            fi
            printf '%s<service name="download_url">\n' '    ' >> "${ROOT}/_service"
            printf '%s<param name="url">%s</param>\n' '        ' "${url}" >> "${ROOT}/_service"
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

    cp "${PKGBUILD}" "${ROOT}/PKGBUILD"
    sed -r -i \
        -e '/^depends=/,/[)]$/cdepends=('"${DEPENDS}"')' \
        -e '/^depends[+]=/d' \
        -e '/^makedepends=/,/[)]$/cmakedepends=('"${MAKEDEPENDS}"')' \
        "${ROOT}/PKGBUILD"
}

upload_obs()
{
    local ROOT="${1}"
    local TYPE="${2}"
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

    curl "https://api.opensuse.org/source/${REPOSITORY}/${PACKAGE}" -F 'cmd=deleteuploadrev'

    curl "https://api.opensuse.org/source/${REPOSITORY}/${PACKAGE}" > "${ROOT}/directory.xml"

    xmlstarlet sel -t -v '//entry/@name' < "${ROOT}/directory.xml" | while read FILENAME
    do
        curl "https://api.opensuse.org/source/${REPOSITORY}/${PACKAGE}/${FILENAME}?rev=upload" -X DELETE
    done

    rm -f "${ROOT}/directory.xml"

    for FILE in "${ROOT}"/*
    do
        FILENAME="${FILE##*/}"
        curl "https://api.opensuse.org/source/${REPOSITORY}/${PACKAGE}/${FILENAME}?rev=upload" -T "${FILE}"
    done

    curl "https://api.opensuse.org/source/${REPOSITORY}/${PACKAGE}" -F 'cmd=commit'
}

. "${PKGBUILD}"

TMP="$(mktemp -d)"
CHROMIUM_VERSION="${_chromium_version}"
LAUNCHER_VERSION="${_launcher_ver}"
UNGOOGLED_CHROMIUM_ARCHLINUX_VERSION="${_ungoogled_archlinux_version}"
UNGOOGLED_CHROMIUM_VERSION="${_ungoogled_version}"
DEPENDS="${depends[*]}"
MAKEDEPENDS="${makedepends[*]} jack2 jre-openjdk-headless curl"
TYPE="$(get_type)"

trap 'rm -rf "${TMP}"' EXIT INT
generate_obs "${TMP}" "${CHROMIUM_VERSION}" "${LAUNCHER_VERSION}" "${UNGOOGLED_CHROMIUM_ARCHLINUX_VERSION}" "${UNGOOGLED_CHROMIUM_VERSION}" "${DEPENDS}" "${MAKEDEPENDS}"
upload_obs "${TMP}" "${TYPE}"
