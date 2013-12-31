nasm -f elf 8qns.asm
ld -m elf_i386 -o 8qns 8qns.o
rm 8qns.o
