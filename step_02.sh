#!/bin/bash
source ./sourceme.sh
riscv32-unknown-elf-gcc -o step_02.elf step_02.s -nostartfiles -Wl,-Tstep_02.ld
riscv32-unknown-elf-objdump -d -s -j .text step_02.elf
echo ""
riscv32-unknown-elf-size step_02.elf