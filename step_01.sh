#!/bin/bash
source ./sourceme.sh
qemu-system-riscv32 -machine virt -bios none -machine dumpdtb=riscv32-virt.dtb
dtc -I dtb -O dts -o riscv32-virt.dts riscv32-virt.dtb
riscv32-unknown-elf-ld --verbose > qemu-riscv32-vrit.ld
