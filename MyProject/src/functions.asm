;swap(*arr, int k) da swap de k e k+1
swap_nodes:
	push ebp
	mov ebp,esp
	pushad
		mov ebx,[ebp + 8]
		mov esi,[ebp + 12]	; esi = arr

		mov eax, [esi + ebx] ; eax = arr[k].x
		mov edx, [esi + ebx + 16] ; eax = arr[k+1].x
		mov [esi + ebx],edx
		mov [esi + ebx + 16], eax

		add ebx,4

		mov eax, [esi + ebx] ; eax = arr[k].x
		mov edx, [esi + ebx + 16] ; eax = arr[k+1].x
		mov [esi + ebx],edx
		mov [esi + ebx + 16], eax

		add ebx,4

		mov eax, [esi + ebx] ; eax = arr[k].x
		mov edx, [esi + ebx + 16] ; eax = arr[k+1].x
		mov [esi + ebx],edx
		mov [esi + ebx + 16], eax

		add ebx,4

		mov eax, [esi + ebx] ; eax = arr[k].x
		mov edx, [esi + ebx + 16] ; eax = arr[k+1].x
		mov [esi + ebx],edx
		mov [esi + ebx + 16], eax
		
		
	popad
	pop ebp
ret

;sort(*arr,size,headstart) Array of Nodes (16 bytes each node)
sort:
	push ebp
	mov ebp,esp
	pushad
	
	mov eax, [ebp + 16]; eax = inicio do arr
	mov esi, [eax]
	mov ecx, [ebp + 12] ; ecx = n
	cmp ecx,1
	je dont_sort
	dec ecx ; ecx = n-1
not_done:
	mov edx,1
	push ecx
	mov ebx, [ebp + 8]
	sort_nodes:
		push edx
		
		mov eax,[esi + ebx]
		mov edx,[esi + ebx + 16]
		
		cmp eax,edx
		
		jle dont_swap

		push esi
		push ebx
		call swap_nodes
		add esp,12
		
		mov edx,0
		jmp finished

		dont_swap:
		
		pop edx

		finished:
		add ebx,16
		
		loop sort_nodes
	pop ecx
	cmp edx,0
	je not_done
dont_sort:
	popad
	pop ebp
ret


;(*str1,*str2)
cmp_strings:
	push ebp
	mov ebp,esp
	push ebx
	push ecx
	push edx
		mov eax,[ebp + 8]
		mov ebx,[ebp + 12]
		;call print_string
		;call print_nl
		;mov eax,[ebp + 12]
		;call print_string
		;call print_nl
		;mov eax,[ebp + 8]
		mov edx,0
		mov ecx,0
		check_strings:
			mov edx,[eax + ecx]
			push eax
			mov eax,edx
			;call print_char
			pop eax
			cmp dl,byte [ebx + ecx]
			jne fim_false 
			cmp dl,0
			je fim_true
			inc ecx
			jmp check_strings
	fim_false:
	mov eax,0
	jmp fim_fim
	fim_true:
	mov eax,1
	fim_fim:
	pop edx
	pop ecx
	pop ebx
	pop ebp
ret

mov eax,0
mov ebx,1
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