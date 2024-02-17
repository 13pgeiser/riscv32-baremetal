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
