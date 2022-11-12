Prerequisites
* CMake (https://cmake.org/install/)

*Note: ensure Cmake is there in the system wide %PATH% variable*

Building protobuf static libraries
1. dowload the required version of protobuf from [here](https://github.com/protocolbuffers/protobuf/releases)
	* this document used `protobuf-cpp-3.21.9.zip`
1. open `x64 Native Tools Command Prompt` and browse to the folder
1. use the Visual Studio solution/project files generator to generate the SLN/VCXPROJ files using the following command
	```
	cmake -G "Visual Studio 17 2022" -T v142 ^
	-DCMAKE_INSTALL_PREFIX=C:\Users\sunil\source\repos\protobuf\install ^
	-DCMAKE_SYSTEM_VERSION=10.0.18362.0
	```
	* note: this is a multiline command*
	* adjust `CMAKE_SYSTEM_VERSION` to the Windows SDK version to be used
	* adjust `-T` option to use the right toolset
	* adjust `CMAKE_INSTALL_PREFIX` to adjust the install directory
1. open `protobuf.sln` and build the solution/project
1. run `cmake install` to copy all the artifacts to the `CMAKE_INSTALL_PREFIX` folder
1. copy `CMAKE_INSTALL_PREFIX\lib`, `CMAKE_INSTALL_PREFIX\bin`, `CMAKE_INSTALL_PREFIX\include` directories to the appropriate folders inside thirparty folder under `protobuf`
