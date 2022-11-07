# bwanclient-3p

this repo contains the thirdparty (3p) dependencies i.e libs, dlls, include files required for building the bwanclient services

# Organization

the repo is organized as follows
```
  -> module
		   |--> <ARCH>-windows
							  |--> lib -> release/debug
							  |--> bin -> release/debug
							  |--> include
```
`ARCH` can be `x64` for 64-bit artifacts or `x86` for 32-bit artifacts