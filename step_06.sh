#!/bin/bash
source ./sourceme.sh
riscv32-unknown-elf-gcc -Os -o step_06.elf step_06.s step_06.c -nostartfiles -Wl,-Tstep_06.ld
riscv32-unknown-elf-objdump -d -s -j .text step_06.elf
echo ""
riscv32-unknown-elf-size step_06.elf
qemu-system-riscv32 -M virt -nographic -kernel step_06.elf -bios none -semihosting
# Should directly exit.
