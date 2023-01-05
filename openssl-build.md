# Pre-requisites:
1. Git for Windows. You can download it at https://git-scm.com/download/win. This guide uses version 2.11.0.3.
2. Strawberry perl or ActivePerl. You can download it at http://strawberryperl.com/
3. NASM assembler, which is available from http://www.nasm.us/. This guide uses version 2.12.03rc1.

*You are expected to install all those tools system-wide and add them to your %PATH% environmental variable.*

# Building OpenSSL Static LIB

Note: The openssl static library requires zlib to built as a static library too. the steps below illustrate the build process for both openssl and zlib

1. Open `x64 Native Tools Command Prompt` from your Start Menu. You will see command prompt.
1. Create C:\build directory and issue the following command in the command prompt:
	```
	cd c:\build
	```
1. Download latest zlib & OpenSSL source codes to your build dir by using the following commands:

	_Zlib:_
	```
	git clone https://github.com/madler/zlib
	```
	_OpenSSL:_
	
	* download the source code zip file from the [openssl release page](https://github.com/openssl/openssl)
	  We are currently using [v3.0.7](https://github.com/openssl/openssl/archive/refs/tags/openssl-3.0.7.zip)
	* unzip to `C:\build\openssl`

1. First we have to build static zlib. To do that first we will need to edit some configuration files:
	* Navigate to the zlib source folder: cd C:\build\zlib
	* open the sln file in `contrib\vstudio\vc14` directory - ensure you choose the correct Windows SDK version 10.0.18362.0 and Platform toolset v142 when opening the SLN file the first time
	* build the SLN (note: the zlibstat project builds the static library)
	* the artifacts are in `contrib\vstudio\vc14\x64\ZlibStatRelease\zlibstat.lib`; this should be renamed to `zlib.lib`
	* copy the following:
	```
	xcopy zlib.h C:\build\openssl\
	xcopy zconf.h C:\build\openssl\
	xcopy zlib.lib C:\build\openssl\
	xcopy zlib.pdb C:\build\openssl\
	```
1. Prepare the openSSL config generator to do a build that does not require VCRedist
   1. edit `C:\build\openssl\Configurations\10-main.conf` and make the following changes
      ```
	  line num 1358: ($disabled{shared} ? "" : "/MDd") ==> ($disabled{shared} ? "" : "/MTd
	  line num 1362: ($disabled{shared} ? "" : "/MD")  ==> ($disabled{shared} ? "" : "/MT")
	  ```
	  NOTE: openSSL supports `/MT` only when generating static libraries
1. OpenSSL build: Navigate to OpenSSL source: cd C:\build\openssl\ and configure it to use static zlib & read configuration files (openssl.cnf) from C:\Windows\ directory.
	```
	perl Configure VC-WIN64A shared no-zlib threads --prefix=c:\Windows\ --release
	```
1. Build OpenSSL by running `nmake` (will take around 15 minutes) - static and dynamically linkable artifacts (`libssl.lib,dll/libssl_static.lib` and `libcrypto.lib,dll/libcrypto_static.lib`) will be generated in `c:\build\openssl` folder
1. copy the linkable artifacts and `include\openssl` directory to the appropriate folders inside thirparty folder under `openssl`