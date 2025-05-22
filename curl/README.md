# Building libcurl Static and Dynamic LIB for MacOS

Note: Libraries need to be built for both Intel and Arm processors. It will use
lipo tool to create universal library

To build openssl using below commands: 
    
    ./build-curl.sh


build-curl.sh does below things:
- Download the libcurl from the git achieve for the given tag
- Copy openssl library and include folders in local directory
- Configure the libcurl for paltform (arm64 and x64_64) specific parameters
- Build libcurl for Arm64:
    - make
    - make install (to a local folder)
- Build libcurl for x86_64
    - make
    - make install (to a local folder)
- Create Universal libraries for libcurl (libcurl.a)

Results can be found in the current folder:
- curl/osx-universal
