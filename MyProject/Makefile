all: src/main.asm
	nasm -f elf32 lib/asm_io.asm
	nasm -f elf32 src/main.asm
	gcc -m32 -o huffman src/main.o lib/driver.c lib/asm_io.o

clean:
	rm huffman
