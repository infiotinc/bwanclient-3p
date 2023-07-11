# Building nDPI Static and Dynamic LIB for MacOS

Note: Libraries need to be built for both Intel and Arm processors.

Use repo: https://github.com/madler/zlib
zlib/tags: https://github.com/madler/zlib/tags 

How to Build:
- wget https://github.com/madler/zlib/archive/refs/tags/vx.y.z.tar.gz
- tar xvf vx.y.z.tar.gz
- cd zlib-x.y.z
- ./configure
- make

Use above steps to build libraies on Intel anf Arm based macbooks to generate libraries for
both platforms.

- Libraies can be found in below path:
    ./zlib-x.y.z/libz.dylib
    ./zlib-x.y.z/libz.1.2.13.dylib
    ./zlib-x.y.z/libz.1.dylib

Use below commands to build universal (x86_64 + arm64) libraries:
    lipo x86_64/libz.1.2.13.dylib arm64/libz.1.2.13.dylib -create -output universal/libz.1.2.13.dylib
    lipo x86_64/libz.1.dylib arm64/libz.1.dylib -create -output universal/libz.1.dylib
    lipo x86_64/libz.dylib arm64/libz.dylib -create -output universal/libz.dylib
    lipo x86_64/libz.a arm64/libz.a -create -output universal/libz.a


Use below command to check the architecture type of the libraries:
    lipo -info universal/libz.*


9th June 2023:
- osx zlib libraries are built from below repo and branch:
     tag used to build zlib: https://github.com/madler/zlib/archive/refs/tags/v1.2.13.tar.gz
