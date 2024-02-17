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

