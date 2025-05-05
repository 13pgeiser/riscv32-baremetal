#!/bin/bash
if [ ! -d ./openocd-code ]; then
    git clone https://git.code.sf.net/p/openocd/code openocd-code
fi
if [ ! -e ./openocd-code/jimtcl/AUTHORS ]; then
    (
        cd ./openocd-code
        git submodule update --init --recursive
    )
fi
if [ ! -e ./openocd-code/src/openocd ]; then
    sudo apt install autoconf automake pkg-config build-essential libtool libhidapi-dev libusb-1.0-0-dev
    (
        cd ./openocd-code
        ./bootstrap
        ./configure  --enable-internal-jimtcl --enable-cmsis-dap --enable-stlink
        make -j$(nproc)
    )
fi
(
    cd ./openocd-code
    ./src/openocd -f interface/cmsis-dap.cfg -f target/rp2350.cfg -c "adapter speed 5000" -s tcl/
)