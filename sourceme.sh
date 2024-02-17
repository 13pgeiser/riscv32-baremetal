#!/bin/sh
CURL="curl -L -O"

if [ "$OSTYPE" == "msys" ]; then
    # Download gcc for riscv32 and put it in the PATH
    GCC="x86_64-w64-mingw32_riscv32-unknown-elf-13.2.0"
    if [ ! -d "$(pwd)/$GCC/bin/" ]; then
        $CURL "https://github.com/13pgeiser/gcc-riscv32/releases/download/gcc_13.2.0_binutils_2.42/$GCC.7z"
        $CURL https://www.7-zip.org/a/7zr.exe
        ./7zr.exe x "$GCC.7z"
        rm -f ./7zr.exe
        rm -f "$GCC.7z"
    fi
    PATH="$(pwd)/$GCC/bin:$PATH"
    # Download the device tree compiler and put it in GCC bin folder
    if [ ! -e "$(pwd)/$GCC/bin/dtc" ]; then
        ZSTD="zstd-v1.5.5-win64.zip"
        $CURL "https://github.com/facebook/zstd/releases/download/v1.5.5/$ZSTD"
        unzip "$ZSTD"
        ARCHIVE="mingw-w64-x86_64-dtc-1.7.0-1-any.pkg.tar.zst"
        $CURL "https://mirror.msys2.org/mingw/mingw64/$ARCHIVE"
        ./zstd-v1.5.5-win64/zstd -d "$ARCHIVE" -o "mingw-w64-x86_64-dtc.tar"
        tar xvf "mingw-w64-x86_64-dtc.tar"
        cp "$(pwd)/mingw64/bin/dtc" "$(pwd)/$GCC/bin"
        rm -f "$ARCHIVE"
        rm -rf mingw64
        rm -f "mingw-w64-x86_64-dtc.tar"
        rm -rf zstd-v1.5.5-win64
        rm -f "$ZSTD"
        rm -f .BUILDINFO
        rm -f .MTREE
        rm -f .PKGINFO
    fi
    # Expect qemu in the default location on windows.
    PATH="C:\Program Files\qemu":$PATH
elif [ "$OSTYPE" == "linux-gnu" ]; then
    # Download gcc for riscv32 and put it in the PATH
    GCC="x86_64-linux-gnu_riscv32-unknown-elf-13.2.0"
    if [ ! -d "$(pwd)/$GCC/bin/" ]; then
	    # should check specifically for apt
	    sudo apt install qemu-system-misc qemu-system-data device-tree-compiler p7zip
	    $CURL "https://github.com/13pgeiser/gcc-riscv32/releases/download/gcc_13.2.0_binutils_2.42/$GCC.7z"
	    7zr x "$GCC.7z"
	    rm -f "$GCC.7z"
    fi
    PATH="$(pwd)/$GCC/bin:$PATH"
else
    echo "Unsupported OS: OSTYPE=$OSTYPE"
fi
