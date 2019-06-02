
%include "lib/asm_io.inc"
%include "src/binary_search_tree.asm"
%include "src/read_write_file.asm"
%include "src/functions.asm"

segment .data
  

    debug_msg1 db "===== DEBUG ====", 0
    debug_msg2 db "AQUI",10, 0
    debug_msg3 db "Memory: ", 0
	msg db "frequencia --- left --- right --- char",0
	sep db "-------------",0
	filename db "bigtest.txt", 0
	flname db "compressed.txt", 0
	flname2 db "decompression.txt",0
  	buflen dw 2048
	buflen2 dd 16384

	freq_table times 256 dd 0	
	n dd 0
	fldscp dd 0
	N dd 0
	qntlet dd 0
	


segment .bss

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

        global  asm_main
asm_main:
call read_char
cmp al,'c'
je compressao

	push flname
	push buffer2
	push buflen2
	call read_file
	add esp,12
	push eax
	call close_file
	add esp,4

	movzx eax,byte [buffer2]
	shl eax,8
	or al,byte [buffer2 + 1]
	mov [qntlet],eax
    call print_int
    call print_nl

	movzx edx,byte [buffer2 + 2]
	shl edx,8
	or dl,byte [buffer2 + 3]
	mov eax,edx
	call print_int
	call print_nl
	mov [n],edx
	; n = tamanho do texto
	;[buffer2 + edx + 2] = inicio das letras utilizadas
	movzx eax,byte [buffer2 + edx + 4]
	mov [N],eax
	; N = quantidade de letras diferentes 
	call print_int
	call print_nl


	mov eax, 45     ; sys_brk
    xor ebx, ebx
    int 80h

	mov ebx, 20
	imul ebx,[N]

    add eax, ebx ; reserve 20*N bytes, 1 para o char 20 para codificacao
    mov ebx, eax
    mov eax, 45     ; sys_brk
    int 80h
	
	mov ebx,20
	imul ebx,[N]
	sub ebx,4
	sub eax,ebx	

	mov [huffman_table],eax ; eax aponta para o inicio do vetor criado

	mov ecx,[N]
	mov ebx,5
	mov eax,0
	mov ebp,[n]
	mov edi,0 ; pointeiro para construir vetor
	mov esi,[huffman_table]

build_encoding_table:

	mov al,byte [buffer2 + ebp + ebx]
	mov byte [esi + edi], al
	call print_char
	call print_nl
	pushad
		xor edx,edx
		movzx ecx, byte [buffer2 + ebp + ebx + 1]
		
		or dl,byte [buffer2 + ebp + ebx + 2]
		
		shl edx,8
		
		or dl,byte [buffer2 + ebp + ebx + 3]

		; edx = codificacao
		mov eax,edx
		call print_int
		call print_nl
		mov eax,1
		shl eax,cl
		shr eax,1
		mov ebx,1
		get_code:

			push eax
			and eax,edx
			cmp eax,0
			je continue_code
			xor eax,eax
			mov eax,1
			continue_code:
			add eax,48
			add edi,ebx
			mov byte [esi + edi],al
			sub edi,ebx
			pop eax
			shr eax,1
			inc ebx
		loop get_code

	popad
	add edi,20
	add ebx,4
	
loop build_encoding_table

mov ecx,[N]
mov edi,0
mov esi,[huffman_table]

print_encoding_table:
	movzx eax, byte [esi + edi]
	call print_char
	mov al,' '
	call print_char
	mov ebx,1
	print_encoding_table_char:
		xor eax,eax
		add edi,ebx
		mov al,byte [esi + edi]
		sub edi,ebx
		cmp al,0
		je fim_print_encoding_table_char
		call print_char 
		inc ebx
	jmp print_encoding_table_char
	fim_print_encoding_table_char:
	call print_nl
	add edi,20
loop print_encoding_table

mov eax,0
mov ebx,3
mov ecx,[n]
imul ecx,8
mov edx,0
mov edi,0
mov ebp,0
print_binary_rep:
	cmp ebp,0
	jne prox_bit1
	
	mov ebp,8
	inc ebx
	mov eax,ebx
	;call print_int
	;call print_nl
	prox_bit1:
	movzx eax,byte [buffer2 + ebx]
	push ebp
	push ecx
		mov ecx,ebp
		dec ecx
		mov ebp,1
		shl ebp,cl
		and eax,ebp
		cmp eax,0
		je letrazero1
		mov eax,1
		letrazero1:
		add eax,48
		call print_char
	pop ecx
	pop ebp
	dec ebp
loop print_binary_rep	
mov eax,0
mov ebx,3
mov ecx,[n]

imul ecx,8
mov edx,0
mov edi,0
mov ebp,0
build_buffer_decomp:
	cmp ebp,0
	jne prox_bit
	prox_letra:
	mov ebp,8
	inc ebx
	mov eax,ebx
	;call print_int
	;call print_nl
	prox_bit:
	movzx eax,byte [buffer2 + ebx]
	
	push ebp
	push ecx

		mov ecx,ebp
		dec ecx
		mov ebp,1
		shl ebp,cl
		and eax,ebp
		cmp eax,0
		je letrazero
		mov eax,1
		letrazero:
		add eax,48
		call print_char
		

	pop ecx
	pop ebp
	
	mov  [buf + edx],eax
	
	
	;go through all characters:
	pushad
		mov ecx,[N]
		mov edi,0
		mov esi,[huffman_table]

		go_through:			
			mov ebx,1

			push ecx
			mov ecx,20
			clear_let2:
				mov byte [let + ecx - 1],0
			loop clear_let2

			pop ecx
			go_through_char:
				xor eax,eax
				add edi,ebx
				movzx edx,byte [esi + edi]
				sub edi,ebx
				mov byte [let + ebx - 1],dl
				
				cmp byte [let + ebx - 1],0
				je fim_go_through_char
				inc ebx
			jmp go_through_char
			fim_go_through_char:
			push let
			push buf
			call cmp_strings
			add esp,8
			push ecx
			mov ecx,20
			clear_let:
				mov byte [let + ecx - 1],0
			loop clear_let

			pop ecx
			;call print_nl
			cmp eax,1 ; resultado vem em eax 1 = true, 0 = false
			je fim_go_through_true
			add edi,20
		loop go_through
		jmp fim_go_through_false
		fim_go_through_true:
			mov al,byte [esi + edi]
			call print_char
			call print_nl
			call print_nl
			mov byte [let],al
			mov ecx,20
			clear_buf:
				mov byte [buf + ecx - 1],0
			loop clear_buf
			
			jmp nkk
		fim_go_through_false:
	popad
	jmp kk
	nkk:
	popad
	movzx eax,byte [let]
	mov byte [buffer + edi],al
	mov eax,edi
	;call print_int
	;call print_nl
	mov edx,-1
	inc edi
	kk:
	inc edx
	dec ecx
	dec ebp
	cmp ecx,0
	jne build_buffer_decomp

;aehoo printa o buffer
    mov esi, buffer
    mov ebx,0
    cld 
    print:
        lodsb ;al = [esi] e esi+=1
        cmp al, 0
        je exit
        inc ebx
        call print_char
    jmp print
    exit:
    call print_nl 

    

    push flname2
    push buffer
    push dword [qntlet]
    call write_file
    add esp,12

leave
ret

; compressão teoricamente completa : 28/05/2019
	;build frequency table
compressao:
	push filename
	push buffer
	push buflen
	call read_file
	add esp,12
	push eax
	call close_file
	add esp,4

	mov esi,buffer
	cld
build_table:
	lodsb
		cmp al,0
		je finish_table
		inc dword [qntlet]
		movzx eax,al
		imul eax,4
		inc dword [freq_table + eax]
	jmp build_table
finish_table:



; print freq_table
mov ecx,256
mov ebx,0
mov edx,0

print_table:
	mov eax,ebx
	cmp dword [freq_table + edx],0
	je next_step
	; elementos que aparecem no minimo 1 vez 
	inc dword [n]; aumenta o tamanho do vetor
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
mov eax,[n]
mov [N],eax

; reserva 16 * n bytes para a huffman table
    mov eax, 45     ; sys_brk
    xor ebx, ebx
    int 80h

	mov ebx, 16
	imul ebx,[n]

    add eax, ebx ; reserve 16*n bytes
    mov ebx, eax
    mov eax, 45     ; sys_brk
    int 80h
	
	mov ebx,16
	imul ebx,[n]
	sub ebx,4
	sub eax,ebx	

	mov dword [huffman_table], 0
	mov [huffman_table] , eax ; huffman_table aponta para inicio do vetor de node
		

	mov ecx,256	
	mov ebx,0 ; position on huffman_table
	mov eax,0 ; position on ascii table
	mov edx,0 ; position on frequency_table

initialize_vector:

	cmp dword [freq_table + edx],0
	je next_iteration
	push ecx
	push edx
	mov ecx, [freq_table + edx]
	mov edx, [huffman_table]
	mov [edx + ebx], ecx ; node = {freq,*left,*right,char}
	mov dword [edx + ebx + 4], 0
	mov dword [edx + ebx + 8], 0
	mov [edx + ebx + 12], eax
	pop edx
	pop ecx
	add ebx,16	

next_iteration:
	inc eax
	add edx,4
	loop initialize_vector

	push huffman_table
	push dword [n]
	push dword 0
	call sort
	add esp,12

mov ebx,0
mov ecx,[n]
print_vec:
	mov edx,[huffman_table]
	mov eax,[edx + ebx]
	call print_int
	mov al,'-'
	call print_char
	mov eax,[edx + ebx + 12]
	call print_char
	call print_nl
	add ebx,16
	loop print_vec

mov eax,msg
call print_string
call print_nl
mov ebx,0

build_huffman_tree:
	mov eax,[n]
	call print_int
	call print_nl
	;cria no
	call create_node
	sub eax,12
	mov ecx,[huffman_table]
	add ecx,ebx
	
;;;;;;;
;cmp ebx,16
;	jne sem_debug2
;	mov eax,[ecx]
;	call print_int
;	call print_nl
;leave
;ret	
;sem_debug2:
	mov edx,[ecx + 16]

	mov [eax],edx
	
	mov edx,[ecx + 20]
	mov [eax + 4],edx
	mov edx,[ecx + 24]
	mov [eax + 8],edx
	mov edx,[ecx + 28]
	mov [eax + 12], edx ; new node == b
;cmp ebx,16
;jne sem_debug
;quita:
;leave
;ret
;sem_debug:
;;;;;;;


	mov edx, [ecx]
	add [ecx + 16],edx

	mov edx, ecx
	
	mov [ecx + 20],edx
	mov [ecx + 24],eax
	mov edx,300
	mov [ecx + 28], edx
	; printar os 3 nós utilizados nesse processo

; nó criado
	mov edx,eax
	mov eax, [edx]
	call print_int

	mov al, ' '
	call print_char

	mov eax,[edx + 4]
	call print_int
	
	mov al,' '
	call print_char

	mov eax,[edx + 8]
	call print_int
	
	mov al,' '
	call print_char
	
	mov eax,[edx + 12]
	call print_int
	call print_nl
	

; [huffman_table + ebx]
		
	mov eax, [ecx]
	call print_int

	mov al, ' '
	call print_char

	mov eax,[ecx + 4]
	call print_int
	
	mov al,' '
	call print_char

	mov eax,[ecx + 8]
	call print_int
	
	mov al,' '
	call print_char
	
	mov eax,[ecx + 12]
	call print_int
	call print_nl

; [huffman_table + ebx + 16]

	mov eax, [ecx + 16]
	call print_int

	mov al, ' '
	call print_char

	mov eax,[ecx + 20]
	call print_int
	
	mov al,' '
	call print_char

	mov eax,[ecx + 24]
	call print_int
	
	mov al,' '
	call print_char
	
	mov eax,[ecx + 28]

	call print_int
	call print_nl

	mov eax,sep
	call print_string
	call print_nl

	dec dword [n] 
	add ebx,16

	push huffman_table
	push dword [n]
	push ebx

	call sort
	add esp,12
	
	cmp dword [n],1
	jne build_huffman_tree
	mov ecx,[huffman_table]
	add ecx,ebx
	mov [tree],ecx ; ree = raiz da arvore

mov ecx,256
mov ebx,0
clear_encoding:
mov dword [encoding+ebx],0
add ebx,4
loop clear_encoding
    ;mov eax,[tree]
   	;add eax,8
   	;mov eax,[eax]
   	;mov eax,[eax + 12]
   	;call print_int
   	;call print_nl
   	;call print_nl

	push tree
	push treebuffer
	push encoding
	push dword 0
   	call process_huffman_tree
   	add esp, 16
   	
   	mov ecx,256
   	mov ebx,0
   	mov esi,0
   	print_encoding:
   		cmp dword [encoding + ebx],0
   		je cont_print_encoding
   		mov eax,esi
   		call print_char
   		mov al,' '
   		call print_char 
   		;cmp esi,'e'
   		;je xx
   		mov edx,[encoding + ebx]
   		mov edi,edx
   		mov edx,0
   		print_char_encoding:
   			cmp byte [edi + edx],0
   			je end_print_char_encoding
   			mov eax,[edi + edx]

   			call print_char
   			inc edx
   			jmp print_char_encoding
   			end_print_char_encoding:
   			call print_nl

   		cont_print_encoding:
   		add ebx,4
   		inc esi
   	loop print_encoding

mov ebx,0
mov esi,buffer
build_buffer:
	lodsb
		cmp al,0
		je finish_buffer

		imul eax,4

		mov edx,[encoding + eax] ; posiçao da letra no encoding
		
		mov eax,0
		put_on_buffer:
			cmp byte [edx + eax],0
			je next_letter
			mov ecx,[edx + eax]

			mov [buffer2 + ebx],ecx

			inc ebx
			inc eax
			jmp put_on_buffer
	next_letter:
	jmp build_buffer
finish_buffer:

mov ecx,0
mov esi,buffer2
mov edx,0
print_buffer2:
	lodsb
		cmp al,0
		je finish_print_buffer2
		inc ecx
		call print_char
		jmp print_buffer2
finish_print_buffer2:
call print_nl

mov eax,ecx
call print_int
call print_nl


; 26/05 ----------
mov [n],eax
mov ecx,[n]
mov ebx,7
mov edx,0
mov edi,0
mov eax,0
build_new_buffer:
	push ecx

	movzx ecx, byte [buffer2 + edx] ; read bit from buffer
	sub ecx,'0'

	or eax,ecx ; put it on first bit

	shl eax,1 ; shift it left once

	pop ecx

	cmp ebx,0
	jne dont_reset

	mov ebx,8
	mov byte [buffer2 + edi + 4],0
	shr eax,1 ; remove the extra space
	mov [buffer2 + edi + 4],al
	mov eax,0
	inc edi

	dont_reset:
	dec ebx
	inc edx
loop build_new_buffer

cmp eax,0
je tamanho_certo
push eax
	mov eax,ebx
	call print_int
	call print_nl
pop eax
call print_int
call print_nl

mov ecx,ebx
shl eax,cl
call print_int
call print_nl
mov [buffer2 + edi + 4],al ; bota os bits finais que faltaram 
inc edi
mov [n],edi
add dword [n],1

tamanho_certo:

mov byte [buffer2 + edi + 4],0; bota um zero no novo final do buffer
mov eax,[n]
mov [buffer2 + 3], al ; primeiros dois bytes usados para representar tamanho
shr eax,8
mov [buffer2 + 2],al

mov eax,[qntlet]
mov [buffer2 + 1],al
shr eax,8
mov [buffer2],al


mov ebx,4
mov ecx,[n]
printa_bits:
	;mov eax,0
	movzx eax,byte [buffer2 + ebx]
	call print_char
	inc ebx
loop printa_bits
call print_nl
; ebx = posicao do buffer final
mov eax,[N]
mov [buffer2 + ebx],eax ; primeiro byte apos o texto que demonstra a quant de letras do texto
inc ebx
inc dword [n]
mov eax,-1 ;               com cada letra tendo 4 bytes cada.

continue_buffer2:
	inc eax
	cmp eax,256
	je finalprog
	cmp dword [freq_table + eax*4],0 ; verifico se apareceu no texto
	je continue_buffer2
	; se tem frequencia, adiciono em 4 o tamanho do buffer2
	add dword [n],4

	mov edi,[encoding + eax*4]
	push eax
	mov edx,0
	mov eax,0
	put_on_buffer2:
			cmp byte [edi + eax],0
			je next_it
			movzx ecx,byte [edi + eax]
			sub ecx,'0'
			or edx,ecx
			shl edx,1
			inc eax
			jmp put_on_buffer2
	next_it:
	shr edx,1
	; edx = codificaçao em bits,
	; eax = quantidade de bits utilizados
	; [buffer2 + ebx] = inicio de uma struct de 4 posiçoes
	; struct = {char,quantidade de bits utilizados, 8 primeiros bits, 8 ultimos bits}

	
	mov edi,eax
	
	call print_int
	call print_nl
	pop eax
	mov [buffer2 + ebx],eax
	mov [buffer2 + ebx + 1], edi
	mov [buffer2 + ebx + 3],dl
	shr edx,8
	mov [buffer2 + ebx + 2],dl

	push eax
;debug:
	mov eax,ebx	
	call print_int
	mov al,' '
	call print_char
	movzx eax,byte [buffer2 + ebx]
	call print_char
	mov al,' '
	call print_char
	movzx eax, byte [buffer2 + ebx + 1]
	call print_int
	mov al,' '
	call print_char
	movzx eax,byte [buffer2 + ebx + 2]
	call print_int
	mov al,' '
	call print_char
	movzx eax,byte [buffer2 + ebx + 3]
	call print_int
	mov al,' '
	call print_char
	call print_nl

	pop eax
	add ebx,4
	jmp continue_buffer2
finalprog:

mov eax,ebx
call print_int
call print_nl
push flname
push buffer2
push ebx
call write_file
add esp,12


leave
ret







