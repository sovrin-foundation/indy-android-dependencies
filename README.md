# indy-android-dependencies
Dependencies required to build indy-sdk for Android

## Prebuilts

prebuilt folder contains libraries built for `arm`, `arm64` and `x86`.

## Building from source

`src` folder contains scripts for building dependencies 
- openssl (1.1.0f)
- sodium (1.0.14)
- zmq (4.2.5)

execute build.sh in each folder to build the respective dependency

e.g
- openssl `./build.sh`
	- this will generate openssl for all architecures at once.
- sodium 
	- `./build.sh x86 16 i686-linux-android` to build for x86 with api-16
	- `./build.sh arm 16 arm-linux-androideabi` to build for arm
	- `./build.sh arm64 21 aarch64-linux-android` to build for arm 64
- zmq 
	- Zmq requires libsoidum to build. After building libsodium for the compatible architecture copy the libsodium folder to zmq folder and provide the path as argument to the script
	- `./build.sh x86 21 i686-linux-android libsodium_x86/lib` to build for x86 with api-21. _Note the libsodium path provided as args_
	- `./build.sh arm 21 arm-linux-androideabi libsodium_arm/lib` to build for arm with api-21
	- `./build.sh arm64 21 aarch64-linux-android libsodium_arm64/lib` to build for arm64 with api-21
