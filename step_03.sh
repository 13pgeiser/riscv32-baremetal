#!/bin/bash
source ./step_02.sh
qemu-system-riscv32 -M virt -s -S -nographic -kernel step_02.elf -bios none&
QEMU_PID=$!
sleep 1
riscv32-unknown-elf-gdb virt --eval-command="target remote :1234" --eval-command="x/8xw 0x80000000" --eval-command="set confirm off" --eval-command="q"
kill $QEMU_PID