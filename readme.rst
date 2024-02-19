############################################
Playing with Bare Metal RISC-V, QEMU and GCC
############################################

:date: 2024-02-17 10:00
:modified: 2024-02-17 10:00
:tags: risc-v, qemu, gcc
:authors: Pascal Geiser
:summary: Minimal examples with GCC for RISC-V

.. contents::

************
Installation
************

Windows
=======

QEMU
----

See https://www.qemu.org/download/#windows.

The binaries are provided since a long time by Stefan Weil here: https://qemu.weilnetz.de/w64/

Download the installer and install it in the default location ("C:\\Program Files\\qemu")

GIT
---

Download and install git for windows, standalone version, available here: https://git-scm.com/download/win

Debian Linux
============

Install the following packages: qemu-system-misc device-tree-compiler p7zip git.


Assuming you've configured *sudo*:

.. code-block:: bash

    sudo apt install qemu-system-misc device-tree-compiler p7zip git

GCC
===

In order to simplify the installation slightly, the next steps have been automated in the file *sourceme.sh*

It will download a usable gcc compiler for RISC-V architecture in the following repo:
 * https://github.com/13pgeiser/gcc-riscv32

And on windows, it will download and install the device-tree-compiler.

************************************************
First Step: getting information about the target
************************************************

QEMU provides a generic virtual platform `virt <https://www.qemu.org/docs/master/system/riscv/virt.html>`__
In order to know more about the available peripherals and memories, the tool can be queried:

.. code-block:: bash

    qemu-system-riscv32 -machine virt -machine dumpdtb=riscv32-virt.dtb

This will provide the binary representation of the machine's data structure describing the HW components.

To have it in a more human readable form, *dtc* can convert it in dts format:

.. code-block:: bash

    dtc -I dtb -O dts -o riscv32-virt.dts riscv32-virt.dtb

Currently, the interesting section is:

.. code-block::

	memory@80000000 {
		device_type = "memory";
		reg = <0x00 0x80000000 0x00 0x8000000>;
	};

Finally, the linker can provide us a default (but too complex) version of the linker script:

.. code-block:: bash

    riscv32-unknown-elf-ld --verbose > qemu-riscv32-vrit.ld

***********************************************
Second Step: compiling the smallest risc-v code
***********************************************

The smallest executable code is an infinite loop place at the first location in memory (see *step_02.s*)

.. code-block:: asm

            .text
            .global _start
    _start:
            j _start

To compile it, we need a small linker script that will explain to the linker where to put the compiled code.
Note that the ram section matches the memory discovered in the first step.

.. code-block::

    OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
    OUTPUT_ARCH(riscv)
    ENTRY(_start)

    MEMORY
    {
        ram   (wxa!ri) : ORIGIN = 0x80000000, LENGTH = 128M
    }

    PHDRS
    {
        text PT_LOAD;
    }

    SECTIONS
    {
        .text : {
            *(.text.init) *(.text .text.*)
        } >ram AT>ram :text
    }

To create an application:

.. code-block:: bash

    riscv32-unknown-elf-gcc -o step_02.elf step_02.s -nostartfiles -Wl,-Tstep_02.ld

And to verify the result:

.. code-block:: bash

    riscv32-unknown-elf-objdump.exe -d -s -j .text step_02.elf
    riscv32-unknown-elf-size step_02.elf

Which prints the following output:

.. code-block:: bash

    $ ./step_02.sh

    step_02.elf:     file format elf32-littleriscv

    Contents of section .text:
    80000000 01a0                                 ..

    Disassembly of section .text:

    80000000 <_start>:
    80000000:       a001                    j       80000000 <_start>

   text    data     bss     dec     hex filename
      2       0       0       2       2 step_02.elf

Nice! 2 bytes only! ;-) But totally useless.


***********************************************
Third Step: Try to run our (useless) executable
***********************************************

.. code-block:: bash

    source sourceme.sh
    qemu-system-riscv32 -M virt -s -S -nographic -kernel step_02.elf -bios none

This tell qemu to: (see https://www.qemu.org/docs/master/system/invocation.html for more information):
 * '-s': Shorthand for -gdb tcp::1234
 * '-S': Do not start CPU at startup
 * '-nographic': disable windowing system
 * '-kernel' step_02.elf : loads our binary
 * '-bios none': get rid of the default bios

And in a second terminal:

.. code-block:: bash

    source sourceme.sh
    riscv32-unknown-elf-gdb virt --eval-command="target remote :1234" --eval-command="x/8xw 0x80000000"

Which will connect with gdb to the stopped binary and dump the memory at 0x80000000 (RAM)

.. code-block::

    GNU gdb (GDB) 14.1
    ...
    0x80000000 in ?? ()
    0x80000000:     0x0000a001      0x00000000      0x00000000      0x00000000
    0x80000010:     0x00000000      0x00000000      0x00000000      0x00000000

Then in the same gdb run:
 * 'c': to continue execution
 * 'ctrl-c': to break
 * 'info register pc' (or 'i r pc'): to show the current program counter

.. code-block::

    (gdb) c
    Continuing.

    Program received signal SIGINT, Interrupt.
    0x80000000 in ?? ()
    (gdb) info register pc
    pc             0x80000000       0x80000000
    (gdb)

So far, so good.

************************************************************
Fourth Step: The smallest program that exists QEMU "cleanly"
************************************************************

To do that, we will use `Semihosting <https://www.qemu.org/docs/master/about/emulation.html#semihosting>`__.

The RISC-V semihosting `trap <https://github.com/riscv-non-isa/riscv-semihosting/blob/main/binary-interface.adoc#trap>`__ sequence:

.. code-block:: asm

    slli x0, x0, 0x1f   # 0x01f01013   Entry NOP
    ebreak              # 0x00100073   Break to debugger
    srai x0, x0, 7      # 0x40705013   NOP encoding the semihosting call number 7

These instructions must be encoded using 32 bits opcodes thus the ".option norvc" in the assembly code:

.. code-block:: asm

            .text
            .global _start
    _start:
            li a0, 0x18 # SYS_EXIT
            li a1, 0
            jal sys_semihost

            .balign 16
            .option norvc
            .text
            .global sys_semihost
    sys_semihost:
            slli zero, zero, 0x1f
            ebreak
            srai zero, zero, 0x7
            ret

The registers a0, a1 are encoding the operation and the parameter respectively.

**********************************
Fifth Step: Jump to main in C Code
**********************************

The fifth step adds some complexity in the linker script. It handles the main sections that are expected in a c program:
 * .text : the program code
 * .rodata: the read-only initialized constants
 * .data: the writable initialized constants
 * .bss: the variables not initialized.

Jump to C means setting up the stack (even if we do not use it yet in this example).
To do so, some memory space is reserved at the end of the bss section.

The assembly code has very changes:

.. code-block:: asm

    ...
    _start:
            la sp, stack_top
            jal main
    ...

Returning from main will call the semihost hosting code SYS_EXIT and stop QEMU.
