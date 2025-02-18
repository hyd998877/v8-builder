set VERSION=9.2.230.22

git config --global user.name "V8 Windows Builder"
git config --global user.email "v8.windows.builder@localhost"
git config --global core.autocrlf false
git config --global core.filemode false
git config --global color.ui true

cd %HOMEPATH%
echo =====[ Getting Depot Tools ]=====
powershell -command "Invoke-WebRequest https://storage.googleapis.com/chrome-infra/depot_tools.zip -O depot_tools.zip"
7z x depot_tools.zip -o*
set PATH=%CD%\depot_tools;%PATH%
set DEPOT_TOOLS_WIN_TOOLCHAIN=0
call gclient


mkdir v8
cd v8

echo =====[ Fetching V8 ]=====
call fetch v8
echo target_os = ['win'] >> .gclient
cd v8
call git checkout %VERSION%
call gclient sync
call git apply --ignore-whitespace --verbose %GITHUB_WORKSPACE%\builders\BUILD.gn.patch


echo =====[ Building V8 ]=====
#call python .\tools\dev\v8gen.py ia32.release -vv -- target_os="""win""" is_component_build=true use_custom_libcxx=false is_clang=true use_lld=false v8_enable_verify_heap=false v8_enable_i18n_support=true v8_use_external_startup_data=false symbol_level=0 target_cpu="""x86""" v8_target_cpu="""x86"""
python .\tools\dev\v8gen.py ia32.release -- v8_monolithic=true v8_enable_i18n_support=false v8_use_external_startup_data=false use_custom_libcxx=false is_component_build=false treat_warnings_as_errors=false v8_symbol_level=0
call ninja -C out.gn\ia32.release -t clean
call ninja -C out.gn\ia32.release v8_monolith
