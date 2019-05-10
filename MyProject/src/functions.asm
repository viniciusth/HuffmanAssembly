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

;sort(*arr,size) Array of Nodes (16 bytes each node)
sort:
	push ebp
	mov ebp,esp
	pushad
	
	mov eax, [ebp + 12]; eax = inicio do arr
	
	mov esi, [eax]
	mov ecx, [ebp + 8] ; ecx = n
	dec ecx ; ecx = n-1

not_done:
	mov edx,1
	push ecx
	mov ebx, 0
	sort_nodes:
		push edx
		push ecx
		mov eax,[esi + ebx]
		mov edx,[esi + ebx + 16]
		
		cmp eax,edx
		
		jle dont_swap

		push esi
		push ebx
		call swap_nodes
		add esp,8
		pop ecx
		pop edx
		mov edx,0
		jmp finished

		dont_swap:
		pop ecx
		pop edx

		finished:
		add ebx,16
		
		loop sort_nodes
	pop ecx
	cmp edx,0
	je not_done
	popad
	pop ebp
ret
