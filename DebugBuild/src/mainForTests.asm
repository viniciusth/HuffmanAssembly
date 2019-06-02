
%include "lib/asm_io.inc"
%include "src/binary_search_tree.asm"
%include "src/read_write_file.asm"
%include "src/functions.asm"

segment .data
   debug_msg1 db "===== DEBUG ====", 0
    debug_msg2 db "AQUI",10, 0
    debug_msg3 db "Memory: ", 0

    filename db "compressed.txt",0
	buflen2 dd 16384
	n dd 0
	 
segment .bss
    tree resd 1
	buffer2 resb 16384
	bb resb 1

segment .text  

        global  asm_main
asm_main:

	;build frequency table
	push filename
	push buffer2
	push buflen2
	call read_file
	add esp,12
	push eax
	call close_file
	add esp,4
	
	movzx eax,byte [buffer2]

	shl eax,8
	or al,[buffer2 + 1]
	
	mov [n],eax
	
	mov ecx,[n]
	mov edx,0
print_buffer2:
	mov al,[buffer2 + edx]
    cmp al,0
	je fifim
	call print_char
	inc edx
loop print_buffer2
fifim:
    leave                     
    ret







