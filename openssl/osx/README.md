# Building OpenSSL Static and Dynamic LIB for MacOS

Note: Libraries need to be built for both Intel and Arm processors.

To build openssl using below commands: 
    ./build-openssl.sh -i  -> for interaction mode with user to take permission to go to next step 
    ./build-openssl.sh     -> Run without user interaction


build-openssl.sh does below things:
- Download the openssl from the git achieve for the given tag
- Configure the openssl for paltform specific parameters
- Build Openssl for Arm64:
    - make clean
    - make
    - make install (to a local folder)
- Build Openssl for x86_64
    - make clean
    - make
    - make install (to a local folder)
- Create Universal libraries for openssl (libcrpto.a, libcrpto.dylib, libssl.a and libssl.dylib)

Results can be found in the current folder:
- openssl/platform/universal
