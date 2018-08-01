# indy-android-dependencies
Dependencies required to build indy-sdk for Android

## Prebuilts

prebuilt folder contains libraries built for `arm`, `armv7`, `arm64`, `x86`, `x86_64`.

## Building from source

`src` folder contains scripts for building dependencies 
- openssl (1.1.0h)
- sodium (1.0.14)
- zmq (4.2.5)

execute build.sh in each folder to build the respective dependency

e.g
- openssl `./build.sh`
	- this will generate openssl for all architecures at once.
- sodium `./build.sh`
	- this will generate sodium for all architecures at once.
- zmq 
	- Zmq requires libsoidum to build. After building libsodium for the compatible architecture copy the sodium/prebuilt folder to zmq folder and rename the copied folder to sodium_prebuilt
	- `./build.sh` this will generate zmq for all architecures at once.
