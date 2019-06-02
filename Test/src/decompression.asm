decompression:
	mov ebx,0
	read_inputd:
		call read_char
		mov byte [input + ebx],al
		inc ebx
		cmp al,'.'
		jne read_inputd

	call read_char
	call read_char
	call read_char

	
	mov byte [input + ebx],'h'
	mov byte [input + ebx + 1],'u'
	mov byte [input + ebx + 2],'f'
	push ebx

	push input
	push buffer2
	push buflen2
	call read_file
	add esp,12
	push eax
	call close_file
	add esp,4

	pop ebx
	mov byte [input + ebx],'t'
	mov byte [input + ebx + 1],'x'
	mov byte [input + ebx + 2],'t'





	movzx eax,byte [buffer2]
	shl eax,8
	or al,byte [buffer2 + 1]
	mov [qntlet],eax
    

	movzx edx,byte [buffer2 + 2]
	shl edx,8
	or dl,byte [buffer2 + 3]
	
	
	mov [n],edx
	; n = tamanho do texto
	;[buffer2 + edx + 2] = inicio das letras utilizadas
	movzx eax,byte [buffer2 + edx + 4]
	mov [N],eax
	; N = quantidade de letras diferentes 
	


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
	
	pushad
		xor edx,edx
		movzx ecx, byte [buffer2 + ebp + ebx + 1]
		
		or dl,byte [buffer2 + ebp + ebx + 2]
		
		shl edx,8
		
		or dl,byte [buffer2 + ebp + ebx + 3]

		; edx = codificacao
		mov eax,edx
		
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

	mov edx,-1
	inc edi
	kk:
	inc edx
	dec ecx
	dec ebp
	cmp ecx,0
	jne build_buffer_decomp
    

    push input
    push buffer
    push dword [qntlet]
    call write_file
    add esp,12

ret
