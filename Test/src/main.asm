
%include "lib/asm_io.inc"
%include "src/binary_search_tree.asm"
%include "src/read_write_file.asm"
%include "src/functions.asm"

segment .data
  

    debug_msg1 db "===== DEBUG ====", 0
    debug_msg2 db "AQUI",10, 0
    debug_msg3 db "Memory: ", 0
	
	
	successd db "File successfully decompressed."
	successc db "File successfully compressed."
  	buflen dw 2048
	buflen2 dd 16384

	freq_table times 256 dd 0	
	n dd 0
	fldscp dd 0
	N dd 0
	qntlet dd 0
	


segment .bss

	input resb 2048

    tree resd 1
    num_nodes resd 1
	buffer resb 2048
	buffer2 resb 16384
	huffman_table resd 1
	treebuffer resb 16
	encoding resd 256
	;variaveis para descompressao
	buf resb 20
	let resb 20

segment .text  
		%include "src/compression.asm"
		%include "src/decompression.asm"
        global  asm_main
asm_main:

call read_char
cmp al,'c'
je compressao

	call decompression

	mov eax,successd
	call print_string
	call print_nl

leave
ret
compressao:
	
	call compression
	mov eax,successc
	call print_string
	call print_nl

leave
ret








