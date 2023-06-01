# Building Google Protobuf Static and Dynamic LIB for MacOS

Note: Libraries need to be built for both Intel and Arm processors.

To build protobuf using below commands: 
    
    ./build-protobuf.sh -i  -> for interaction mode with user to take permission to go to next step 
    ./build-protobuf.sh     -> Run without user interaction


build-protobuf.sh does below things:
- Download the google protobuf from the git achieve for the given tag
- Configure the protobuf for paltform specific parameters
- Build protobuf for Arm64:
    - make clean
    - make
    - make install (to a local folder)
- Build protobuf for x86_64
    - make clean
    - make
    - make install (to a local folder)
- Create Universal libraries for protobuf (libprotobuf-lite.a and libprotobuf.a)

Results can be found in the current folder:
- protobuf/platform/universal


Note: Dont use '-g' compile time flag when configuring the build, otherwise the
library size will huge (100MB+).
