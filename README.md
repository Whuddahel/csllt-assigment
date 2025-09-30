# Author
All files and code present in this folder is the sole work of **Edward Fong Yu Xian**, APU Student ID TP072974.

# Purpose
This folder is the intended submission of the assignment for APU's CSLLT module for the intake APD2F2502CS 

# Compilation
All code, with the exception of *runasm.sh*, is in the x86 Assembly Language, designed with a 32-bit architecture, NASM, and Linux in mind.

To assemble and run for Linux, ensure that the .asm files are present in the working directory, then enter the following commands into the terminal:

*nasm -f elf main.asm*
*ld -m elf_i386 main.o -o main*
*./main*

Alternatively, the included shell script *runasm.sh* simplifies this. To use it, ensure it is in the working directory and enter the command:

*./runasm.sh main*

OR

*./runasm.sh main.asm*

