#!/bin/bash
source ./sourceme.sh
riscv32-unknown-elf-gcc -o step_04.elf step_04.s -nostartfiles -Wl,-Tstep_04.ld
riscv32-unknown-elf-objdump -d -s -j .text step_04.elf
echo ""
riscv32-unknown-elf-size step_04.elf
qemu-system-riscv32 -M virt -nographic -kernel step_04.elf -bios none -semihosting
# Should directly exit.
