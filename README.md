# Cross toolchain configuration for using clang-cl on non-Windows hosts to target MSVC.

Based on the CMake toolchain file of the LLVM project

https://github.com/llvm-mirror/llvm/blob/master/cmake/platforms/WinMsvc.cmake

## Usage 

```
cmake -G Ninja
   -DCMAKE_TOOLCHAIN_FILE=/path/to/clang-cl-msvc.cmake
   -DHOST_ARCH=[aarch64|arm64|armv7|arm|i686|x86|x86_64|x64]
   -DMSVC_BASE=/path/to/msvc
   -DWINSDK_BASE=/path/to/winsdk
   -DWINSDK_VER=windows sdk version folder name
   -DLLVM_VER=6
   -DCLANG_VER=6.0
```

##### HOST_ARCH:
   The architecture to build for.

##### MSVC_BASE:
  *Absolute path* to the folder containing MSVC headers and system libraries.
  The layout of the folder matches that which is intalled by MSVC 2017 on
  Windows, and should look like this:

```
${MSVC_BASE}
  include
    vector
    stdint.h
    etc...
  lib
    x64
      libcmt.lib
      msvcrt.lib
      etc...
    x86
      libcmt.lib
      msvcrt.lib
      etc...
```

For versions of MSVC < 2017, or where you have a hermetic toolchain in a
custom format, you must use symlinks or restructure it to look like the above.

##### WINSDK_BASE:
  Together with WINSDK_VER, determines the location of Windows SDK headers
  and libraries.

##### WINSDK_VER:
  Together with WINSDK_BASE, determines the locations of Windows SDK headers
  and libraries.

WINSDK_BASE and WINSDK_VER work together to define a folder layout that matches
that of the Windows SDK installation on a standard Windows machine.  It should
match the layout described below.

Note that if you install Windows SDK to a windows machine and simply copy the
files, it will already be in the correct layout.

```
${WINSDK_BASE}
  Include
    ${WINSDK_VER}
      shared
      ucrt
      um
        windows.h
        etc...
  Lib
    ${WINSDK_VER}
      ucrt
        x64
        x86
          ucrt.lib
          etc...
      um
        x64
        x86
          kernel32.lib
          etc
```

IMPORTANT: In order for this to work, you will need a valid copy of the Windows
SDK and C++ STL headers and libraries on your host.  Additionally, since the
Windows libraries and headers are not case-correct, this toolchain file sets
up a VFS overlay for the SDK headers and case-correcting symlinks for the
libraries when running on a case-sensitive filesystem.

##### LLVM_VER (optional):
  Version of the LLVM/LLD installation on the machine, it assumes 6.0 in case it is
  not set.

##### CLANG_VER (optional):
  Version of the clang(-cl) installation on the machine, it assumes 6.0 in case it is
  not set.


## Windows SDK

The window SDK can downloaded directly from Microsoft at:

https://developer.microsoft.com/en-us/windows/downloads/windows-10-sdk

## Examples

### Using a makefile for building a project on debian9 for win32

```
 .PHONY: all clean clang-msvc-sdk
 
 MSVC_SDK_URL={Git URL to a copy of this repository which includes the MSVC SDK}
 
 HOSTS=win32-clang
 BUILD_TYPES=debug release
 
 TARGETS=$(foreach h,$(HOSTS),$(addprefix $(h)-,$(BUILD_TYPES)))
 PKG_TARGETS=$(addprefix package-,$(TARGETS))
 
 .SECONDEXPANSION:
 $(TARGETS): build/$$@/build.ninja
     @cmake --build build/$@ --parallel
 
 .clang-msvc-sdk:
     git clone $(MSVC_SDK_URL) .clang-msvc-sdk
 
 clang-msvc-sdk: .clang-msvc-sdk
     @cd .clang-msvc-sdk && git pull
 
 build/win32-clang-%/build.ninja: Makefile .clang-msvc-sdk
     @mkdir -p $(dir $@)
     @cd $(dir $@) && cmake ../.. -G Ninja \
         -DCMAKE_BUILD_TYPE=$(lastword $(subst -, ,$(notdir $(dir $@)))) \
         -DCMAKE_TOOLCHAIN_FILE=$(abspath .clang-msvc-sdk)/clang-cl-msvc.cmake \
         -DMSVC_BASE=$(abspath .clang-msvc-sdk)/msvc/14.14.26428 \
         -DWINSDK_BASE=$(abspath .clang-msvc-sdk)/winsdk \
         -DWINSDK_VER=10.0.17134.0 \
         -DHOST_ARCH=x86
```

The above make file provides the following targets:

```
$ make
all                          win32-clang-debug
clang-msvc-sdk               win32-clang-release
clean
```