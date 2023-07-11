# Building nDPI Static and Dynamic LIB for MacOS

Note: Libraries need to be built for both Intel and Arm processors.

Use repo: https://github.com/infiotinc/nDPI
Branch Use: infiot-ndpi-3.0

How to Build:
- cd nDPI
- ./bootstrap.sh
- ./configure
- make

Use above steps to build libraies on Intel anf Arm based macbooks to generate libraries for
both platforms.

- Libraies can be found in below path:
    nDPI/src/lib/libndpi.so
    nDPI/src/lib/libndpi.a

Use below commands to build universal (x85_64 + arm64) libraries:
    lipo x86_64-osx/libndpi.a arm64-osx/libndpi.a -create -output universal/libndpi.a
    lipo x86_64-osx/libndpi.so arm64-osx/libndpi.so -create -output universal/libndpi.so 

Use below command to check the architecture type of the libraries:
    lipo -info universal/libndpi.*


3rd June 2023:
- osx nDPI libraries are built from below repo and branch:
    - repo: https://github.com/infiotinc/nDPI
    - branch: story/bwan-1573_infiot-ndpi-3.0
