# Maintainer: Ungoogled Software Contributors
# Maintainer: Jakob-Niklas See <git@nwex.de>

# Based on aur/chromium-vaapi, with ungoogled-chromium patches
# Based on extra/chromium

# Maintainer: Evangelos Foutras <evangelos@foutrelis.com>
# Contributor: Pierre Schmitz <pierre@archlinux.de>
# Contributor: Jan "heftig" Steffens <jan.steffens@gmail.com>
# Contributor: Daniel J Griffiths <ghost1227@archlinux.us>

pkgname=ungoogled-chromium
pkgver=92.0.4515.131
pkgrel=1
_launcher_ver=8
_gcc_patchset=7
_pkgname=$(echo $pkgname | cut -d\- -f1-2)
_pkgver=$(echo $pkgver | cut -d\. -f1-4)
# ungoogled chromium variables
_uc_ver=$pkgver-1
_uc_usr=Eloston
pkgdesc="A lightweight approach to removing Google web service dependency"
arch=('x86_64')
url="https://github.com/Eloston/ungoogled-chromium"
license=('BSD')
depends=('gtk3' 'nss' 'alsa-lib' 'xdg-utils' 'libxss' 'libcups' 'libgcrypt'
         'ttf-liberation' 'systemd' 'dbus' 'libpulse' 'pciutils' 'libva'
         'desktop-file-utils' 'hicolor-icon-theme')
makedepends=('python' 'gn' 'ninja' 'clang' 'lld' 'gperf' 'nodejs' 'pipewire'
             'java-runtime-headless' 'python2')
optdepends=('pipewire: WebRTC desktop sharing under Wayland'
            'kdialog: support for native dialogs in Plasma'
            'org.freedesktop.secrets: password storage backend on GNOME / Xfce'
            'kwallet: support for storing passwords in KWallet on Plasma')
provides=('chromium')
conflicts=('chromium')
source=(https://commondatastorage.googleapis.com/chromium-browser-official/chromium-$_pkgver.tar.xz
        $_pkgname-$_uc_ver.tar.gz::https://github.com/$_uc_usr/ungoogled-chromium/archive/$_uc_ver.tar.gz
        https://github.com/foutrelis/chromium-launcher/archive/v$_launcher_ver/chromium-launcher-$_launcher_ver.tar.gz
        https://github.com/stha09/chromium-patches/releases/download/chromium-${pkgver%%.*}-patchset-$_gcc_patchset/chromium-${pkgver%%.*}-patchset-$_gcc_patchset.tar.xz
        chromium-drirc-disable-10bpc-color-configs.conf
        sql-VirtualCursor-standard-layout.patch
        wayland-egl.patch
        use-oauth2-client-switches-as-default.patch
        extend-enable-accelerated-video-decode-flag.patch
        linux-sandbox-syscall-broker-use-struct-kernel_stat.patch
        linux-sandbox-fix-fstatat-crash.patch
        chromium-freetype-2.11.patch)
sha256sums=('b6ac840ed5390de69f962e922649bf1df895ff0f5db8e5f656b5191e0cf4ce3a'
            '417ed82d81895d3cd2773e9a44406dc676810e1faf09947be3084c53afcdaee4'
            '213e50f48b67feb4441078d50b0fd431df34323be15be97c55302d3fdac4483a'
            '53a2cbb1b58d652d5424ff9040b6a51b9dc6348ce3edc68344cd0d25f1f4beb2'
            'babda4f5c1179825797496898d77334ac067149cac03d797ab27ac69671a7feb'
            '23d6b14530acb66762c5d8b895c100203a824549e0d9aa815958dfd2513e6a7a'
            '34d08ea93cb4762cb33c7cffe931358008af32265fc720f2762f0179c3973574'
            'e393174d7695d0bafed69e868c5fbfecf07aa6969f3b64596d0bae8b067e1711'
            '66db9132d6f5e06aa26e5de0924f814224a76a9bdf4b61afce161fb1d7643b22'
            '268e18ad56e5970157b51ec9fc8eb58ba93e313ea1e49c842a1ed0820d9c1fa3'
            '253348550d54b8ae317fd250f772f506d2bae49fb5dc75fe15d872ea3d0e04a5'
            '7ef689cd6b2f85f2b76b2a10ecede003cfa0c2da15acc998ecbc445f2c95ced6')

# Possible replacements are listed in build/linux/unbundle/replace_gn_files.py
# Keys are the names in the above script; values are the dependencies in Arch
declare -gA _system_libs=(
  [ffmpeg]=ffmpeg
  [flac]=flac
  [fontconfig]=fontconfig
  [freetype]=freetype2
  [harfbuzz-ng]=harfbuzz
  [icu]=icu
  [libdrm]=
  [libjpeg]=libjpeg
  [libpng]=libpng
  #[libvpx]=libvpx
  [libwebp]=libwebp
  [libxml]=libxml2
  [libxslt]=libxslt
  [opus]=opus
  [re2]=re2
  [snappy]=snappy
  [zlib]=minizip
)
_unwanted_bundled_libs=(
  $(printf "%s\n" ${!_system_libs[@]} | sed 's/^libjpeg$/&_turbo/')
)
depends+=(${_system_libs[@]})

prepare() {
  cd "$srcdir/chromium-$_pkgver"

  # Allow building against system libraries in official builds
  sed -i 's/OFFICIAL_BUILD/GOOGLE_CHROME_BUILD/' \
    tools/generate_shim_headers/generate_shim_headers.py

  # https://crbug.com/893950
  sed -i -e 's/\<xmlMalloc\>/malloc/' -e 's/\<xmlFree\>/free/' \
    third_party/blink/renderer/core/xml/*.cc \
    third_party/blink/renderer/core/xml/parser/xml_document_parser.cc \
    third_party/libxml/chromium/*.cc

  # Use the --oauth2-client-id= and --oauth2-client-secret= switches for
  # setting GOOGLE_DEFAULT_CLIENT_ID and GOOGLE_DEFAULT_CLIENT_SECRET at
  # runtime -- this allows signing into Chromium without baked-in values
  patch -Np1 -i ../use-oauth2-client-switches-as-default.patch

  # Fix build with FreeType 2.11 (patch from Gentoo)
  patch -Np1 -i ../chromium-freetype-2.11.patch

  # Upstream fixes
  patch -Np1 -i ../extend-enable-accelerated-video-decode-flag.patch
  patch -Np1 -i ../linux-sandbox-syscall-broker-use-struct-kernel_stat.patch
  patch -Np1 -i ../linux-sandbox-fix-fstatat-crash.patch

  # Fixes building with GCC 11  https://crbug.com/1189788
  patch -Np1 -i ../sql-VirtualCursor-standard-layout.patch

  # Fixes for building with libstdc++ instead of libc++
  patch -Np1 -i ../patches/chromium-90-ruy-include.patch

  # Wayland/EGL regression (crbug #1071528 #1071550)
  patch -Np1 -i ../wayland-egl.patch

  # Ungoogled Chromium changes
  _ungoogled_repo="$srcdir/$_pkgname-$_uc_ver"
  _utils="${_ungoogled_repo}/utils"
  msg2 'Pruning binaries'
  python "$_utils/prune_binaries.py" ./ "$_ungoogled_repo/pruning.list"
  msg2 'Applying patches'
  python "$_utils/patches.py" apply ./ "$_ungoogled_repo/patches"
  msg2 'Applying domain substitution'
  python "$_utils/domain_substitution.py" apply -r "$_ungoogled_repo/domain_regex.list" \
    -f "$_ungoogled_repo/domain_substitution.list" -c domainsubcache.tar.gz ./

  # Link to system tools required by the build
  mkdir -p third_party/node/linux/node-linux-x64/bin
  ln -s /usr/bin/node third_party/node/linux/node-linux-x64/bin/
  ln -s /usr/bin/java third_party/jdk/current/bin/

  # Remove bundled libraries for which we will use the system copies; this
  # *should* do what the remove_bundled_libraries.py script does, with the
  # added benefit of not having to list all the remaining libraries
  local _lib
  for _lib in ${_unwanted_bundled_libs[@]}; do
    find "third_party/$_lib" -type f \
      \! -path "third_party/$_lib/chromium/*" \
      \! -path "third_party/$_lib/google/*" \
      \! -path "third_party/harfbuzz-ng/utils/hb_scoped.h" \
      \! -regex '.*\.\(gn\|gni\|isolate\)' \
      -delete
  done

  ./build/linux/unbundle/replace_gn_files.py \
    --system-libraries "${!_system_libs[@]}"
}

build() {
  make -C chromium-launcher-$_launcher_ver

  cd "$srcdir/chromium-$_pkgver"

  if check_buildoption ccache y; then
    # Avoid falling back to preprocessor mode when sources contain time macros
    export CCACHE_SLOPPINESS=time_macros
  fi

  export CC=clang
  export CXX=clang++
  export AR=ar
  export NM=nm

  local _flags=(
    'custom_toolchain="//build/toolchain/linux/unbundle:default"'
    'host_toolchain="//build/toolchain/linux/unbundle:default"'
    'is_official_build=true' # implies is_cfi=true on x86_64
    'ffmpeg_branding="Chrome"'
    'proprietary_codecs=true'
    'rtc_use_pipewire=true'
    'link_pulseaudio=true'
    'use_gnome_keyring=false'
    'use_sysroot=false'
    'use_custom_libcxx=false'
    'enable_widevine=true'
    'use_vaapi=true'
  )

  if [[ -n ${_system_libs[icu]+set} ]]; then
    _flags+=('icu_use_data_file=false')
  fi

  if check_option strip y; then
    _flags+=('symbol_level=0')
  fi

  # Append ungoogled chromium flags to _flags array
  _ungoogled_repo="$srcdir/$_pkgname-$_uc_ver"
  readarray -t -O ${#_flags[@]} _flags < "${_ungoogled_repo}/flags.gn"

  # See https://github.com/ungoogled-software/ungoogled-chromium-archlinux/issues/123
  CFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -fno-plt"
  CXXFLAGS="$CFLAGS"

  # Facilitate deterministic builds (taken from build/config/compiler/BUILD.gn)
  CFLAGS+='   -Wno-builtin-macro-redefined'
  CXXFLAGS+=' -Wno-builtin-macro-redefined'
  CPPFLAGS+=' -D__DATE__=  -D__TIME__=  -D__TIMESTAMP__='

  # Do not warn about unknown warning options
  CFLAGS+='   -Wno-unknown-warning-option'
  CXXFLAGS+=' -Wno-unknown-warning-option'

  msg2 'Configuring Chromium'
  gn gen out/Release --args="${_flags[*]}"
  msg2 'Building Chromium'
  ninja -C out/Release chrome chrome_sandbox chromedriver
}

package() {
  cd chromium-launcher-$_launcher_ver
  make PREFIX=/usr DESTDIR="$pkgdir" install
  install -Dm644 LICENSE \
    "$pkgdir/usr/share/licenses/chromium/LICENSE.launcher"

  cd "$srcdir/chromium-$_pkgver"

  install -D out/Release/chrome "$pkgdir/usr/lib/chromium/chromium"
  install -Dm4755 out/Release/chrome_sandbox "$pkgdir/usr/lib/chromium/chrome-sandbox"
  ln -s /usr/lib/chromium/chromedriver "$pkgdir/usr/bin/chromedriver"

  install -Dm644 ../chromium-drirc-disable-10bpc-color-configs.conf \
    "$pkgdir/usr/share/drirc.d/10-$pkgname.conf"

  install -Dm644 chrome/installer/linux/common/desktop.template \
    "$pkgdir/usr/share/applications/chromium.desktop"
  install -Dm644 chrome/app/resources/manpage.1.in \
    "$pkgdir/usr/share/man/man1/chromium.1"
  sed -i \
    -e 's/@@MENUNAME@@/Chromium/g' \
    -e 's/@@PACKAGE@@/chromium/g' \
    -e 's/@@USR_BIN_SYMLINK_NAME@@/chromium/g' \
    "$pkgdir/usr/share/applications/chromium.desktop" \
    "$pkgdir/usr/share/man/man1/chromium.1"

  install -Dm644 chrome/installer/linux/common/chromium-browser/chromium-browser.appdata.xml \
    "$pkgdir/usr/share/metainfo/chromium.appdata.xml"
  sed -ni \
    -e 's/chromium-browser\.desktop/chromium.desktop/' \
    -e '/<update_contact>/d' \
    -e '/<p>/N;/<p>\n.*\(We invite\|Chromium supports Vorbis\)/,/<\/p>/d' \
    -e '/^<?xml/,$p' \
    "$pkgdir/usr/share/metainfo/chromium.appdata.xml"

  local toplevel_files=(
    chrome_100_percent.pak
    chrome_200_percent.pak
    resources.pak
    v8_context_snapshot.bin

    # ANGLE
    libEGL.so
    libGLESv2.so

    chromedriver
    crashpad_handler
  )

  if [[ -z ${_system_libs[icu]+set} ]]; then
    toplevel_files+=(icudtl.dat)
  fi

  cp "${toplevel_files[@]/#/out/Release/}" "$pkgdir/usr/lib/chromium/"
  install -Dm644 -t "$pkgdir/usr/lib/chromium/locales" out/Release/locales/*.pak
  install -Dm755 -t "$pkgdir/usr/lib/chromium/swiftshader" out/Release/swiftshader/*.so

  for size in 24 48 64 128 256; do
    install -Dm644 "chrome/app/theme/chromium/product_logo_$size.png" \
      "$pkgdir/usr/share/icons/hicolor/${size}x${size}/apps/chromium.png"
  done

  for size in 16 32; do
    install -Dm644 "chrome/app/theme/default_100_percent/chromium/product_logo_$size.png" \
      "$pkgdir/usr/share/icons/hicolor/${size}x${size}/apps/chromium.png"
  done

  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/chromium/LICENSE"
}

# vim:set ts=2 sw=2 et ft=sh:
