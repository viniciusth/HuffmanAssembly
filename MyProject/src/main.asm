
%include "lib/asm_io.inc"
%include "src/binary_search_tree.asm"
%include "src/read_write_file.asm"

segment .data
  

    debug_msg1 db "===== DEBUG ====", 0
    debug_msg2 db "AQUI",10, 0
    debug_msg3 db "Memory: ", 0
	filename db "test.txt", 0
  	buflen dw 2048
	
	freq_table times 256 dd 0	

segment .bss

    tree resd 1
    num_nodes resd 1
	buffer resb 2048

segment .text  

        global  asm_main
asm_main:
    

	; build frequency table
	push filename
	push buffer
	push buflen
	call read_file
	add esp,12
	

	mov esi,buffer
	cld
build_table:
	lodsb
		cmp al,0
		je finish_table
		movzx eax,al
		imul eax,4
		inc dword [freq_table + eax]
	jmp build_table
finish_table:



mov ecx,256
mov ebx,0
mov edx,0
print_table:
	mov eax,ebx
	cmp dword [freq_table + edx],0
	je next_step
	call print_char
	mov al, '-'
	call print_char
	mov eax,ebx
	call print_int
	mov al,':'
	call print_char
	mov al,' '
	call print_char
	mov eax,[freq_table + edx]
	call print_int
	call print_nl
next_step:
	inc ebx
	add edx,4
loop print_table

leave
ret












  ; exemplo de funcionamento da arvore
    push tree
    push num_nodes
    call init
    add esp, 8
    
    call debug
    
    push dword 15
    push tree
    push num_nodes
	push dword 'a'
    call insert
    add esp, 16
    
    call debug
    
    push dword 10
    push tree
    push num_nodes
	push dword 'b'
    call insert
    add esp, 16
    
    call debug
    
    push dword 20
    push tree
    push num_nodes
	push 'c'
    call insert
    add esp, 16
    
    call debug
    
    push dword 5
    push tree
    push num_nodes
	push 'd'
    call insert
    add esp, 16
    
    call debug
    
    
    ;mov eax, [num_nodes]
    ;call print_int

   push tree
   call print_pre_order
   add esp, 4
   call print_nl
   
   push tree
   push dword 18
   call search_value
   add esp, 8
   call print_int
   call print_nl
   

    leave                     
    ret







