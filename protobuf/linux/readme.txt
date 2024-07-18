 wget https://github.com/protocolbuffers/protobuf/releases/download/v21.9/protoc-21.9-linux-x86_64.zip
 wget https://github.com/protocolbuffers/protobuf/archive/refs/tags/v3.21.9.tar.gz
tar -xvf v3.21.9.tar.gz
  cd protobuf-3.21.9/
  ./autogen.sh
  ./configure CXXFLAGS="-O2"
  make
  sudo make install

Protocol Buffers - Google's data interchange format
Copyright 2008 Google Inc.
https://developers.google.com/protocol-buffers/
This package contains a precompiled binary version of the protocol buffer
compiler (protoc). This binary is intended for users who want to use Protocol
Buffers in languages other than C++ but do not want to compile protoc
themselves. To install, simply place this binary somewhere in your PATH.
If you intend to use the included well known types then don't forget to
copy the contents of the 'include' directory somewhere as well, for example
into '/usr/local/include/'.
Please refer to our official github site for more installation instructions:
  https://github.com/protocolbuffers/protobuf
