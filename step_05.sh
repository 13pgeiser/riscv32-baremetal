#!/bin/bash
source ./sourceme.sh
riscv32-unknown-elf-gcc -o step_05.elf step_05.s step_05.c -nostartfiles -Wl,-Tstep_05.ld
riscv32-unknown-elf-objdump -d -s -j .text step_05.elf
echo ""
riscv32-unknown-elf-size step_05.elf
qemu-system-riscv32 -M virt -nographic -kernel step_05.elf -bios none -semihosting
# Should directly exit.
