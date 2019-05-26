
%include "lib/asm_io.inc"
%include "src/binary_search_tree.asm"
%include "src/read_write_file.asm"
%include "src/functions.asm"

segment .data
   debug_msg1 db "===== DEBUG ====", 0
    debug_msg2 db "AQUI",10, 0
    debug_msg3 db "Memory: ", 0

    


segment .bss
    tree resd 1
	
	bb resb 1

segment .text  

        global  asm_main
asm_main:

	mov eax,16511
	or byte [bb],eax
	mov eax,byte [bb]
	call print_int
	call print_nl

    leave                     
    ret







