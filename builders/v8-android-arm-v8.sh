VERSION=$1

sudo apt-get install -y \
    pkg-config \
    git \
    subversion \
    curl \
    wget \
    build-essential \
    python \
    xz-utils \
    zip

git config --global user.name "V8 Android Builder"
git config --global user.email "v8.android.builder@localhost"
git config --global core.autocrlf false
git config --global core.filemode false
git config --global color.ui true


cd ~
echo "=====[ Getting Depot Tools ]====="	
git clone -q https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=$(pwd)/depot_tools:$PATH
gclient


mkdir v8
cd v8

echo "=====[ Fetching V8 ]====="
fetch v8
echo "target_os = ['android']" >> .gclient
cd ~/v8/v8
./build/install-build-deps-android.sh
git checkout $VERSION
gclient sync


echo "=====[ Building V8 ]====="
python ./tools/dev/v8gen.py arm64.release -vv -- '
target_os = "android"
target_cpu = "arm64"
v8_target_cpu = "arm64"
is_debug = false
v8_static_library = true
is_component_build = false
v8_monolithic = true
v8_enable_i18n_support = false
v8_use_external_startup_data = false
symbol_level = 0
strip_debug_info = true
v8_enable_webassembly = false
v8_enable_wasm_gdb_remote_debugging = false
use_custom_libcxx = false
v8_use_snapshot = false
v8_enable_disassembler = false
v8_enable_gdbjit = false
v8_enable_handle_zapping = false
v8_no_inline = true
v8_experimental_extra_library_files = []
v8_extra_library_files = []
v8_enable_concurrent_marking = true
v8_enable_embedded_builtins = false
is_desktop_linux = false
icu_use_data_file = false
enable_iterator_debugging = false
enable_precompiled_headers = false
clang_use_chrome_plugins = false
asan_globals = false
libcpp_is_static = true
use_aura = false
use_dbus = false
use_gio = false
use_glib = false
use_icf = false
use_udev = false
'
ninja -C out.gn/arm64.release -t clean
ninja -C out.gn/arm64.release v8_libplatform
ninja -C out.gn/arm64.release v8_monolith
cp ./third_party/android_ndk/sources/cxx-stl/llvm-libc++/libs/arm64-v8a/libc++_shared.so ./out.gn/arm64.release/obj
