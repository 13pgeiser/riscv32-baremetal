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
