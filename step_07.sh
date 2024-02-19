#!/bin/bash
source ./sourceme.sh
riscv32-unknown-elf-gcc -Os -o step_07.elf step_07.s step_07.c -nostartfiles -Wl,-Tstep_07.ld -nostdlib -lc
echo ""
riscv32-unknown-elf-size step_07.elf
qemu-system-riscv32 -M virt -nographic -kernel step_07.elf -bios none -semihosting
riscv32-unknown-elf-gcc -Os -o step_07.elf step_07.s step_07.c -nostartfiles -Wl,-Tstep_07.ld -nostdlib -specs=nano.specs -lc_nano
echo ""
riscv32-unknown-elf-size step_07.elf
qemu-system-riscv32 -M virt -nographic -kernel step_07.elf -bios none -semihosting
