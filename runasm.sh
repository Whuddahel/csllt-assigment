# Indicates that Bash is the terminal being used
#!/bin/bash

# Strip .asm extension if provided. User can enter with or without the .asm
file="${1%.asm}"

# Assemble
nasm -f elf "$file.asm" -o "$file.o"

# Link
ld -m elf_i386 "$file.o" -o "$file"

# Run
./"$file"
