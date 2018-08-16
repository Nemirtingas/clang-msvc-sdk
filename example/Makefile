.PHONY: all clean

all: hello-world.exe

hello-world.exe: hello-world.cpp build/build.ninja
	cmake --build build

build/build.ninja:
	mkdir -p build
	cd build && cmake .. -G Ninja \
		-DCMAKE_TOOLCHAIN_FILE=$(abspath ../clang-cl-msvc.cmake) \
		-DMSVC_BASE=$(abspath ../msvc/14.14.26428) \
		-DWINSDK_BASE=$(abspath ../winsdk) \
		-DWINSDK_VER=10.0.17134.0

clean:
	rm -rf build
