debug:
    pusha
    pushf
    
    push eax
    mov eax, debug_msg1
    call print_string
    call print_nl
    call print_nl
    pop eax
    
    dump_regs 1               ; dump out register values
;    dump_mem 2, num_nodes, 1    ; dump out memory
    mov eax, debug_msg3
    call print_string
    mov eax, [tree]
    call print_int
    call print_nl
    
    push eax
    mov eax, debug_msg1
    call print_string
    call print_nl
    call print_nl
    pop eax

    popf
    popa

ret 

;init(*tree, *num_nodes)
init:
    push ebp
    mov ebp, esp
    
   ; push edi
    ;push esi
    ;push eax
    mov edi, [ebp + 8]  ;num_nodes
    mov esi, [ebp + 12] ;tree
    mov eax, 0
    mov [edi], eax
    mov [esi], eax
    
    ;pop eax
    ;pop esi
    ;pop edi
    
    pop ebp
ret

;
create_node:
    push ebp
    mov ebp, esp
    
    push ebx    
    mov eax, 45     ; sys_brk
    xor ebx, ebx
    int 80h

    add eax, 16 ; reserve 16 bytes
    mov ebx, eax
    mov eax, 45     ; sys_brk
    int 80h
    pop ebx
    
    pop ebp 
ret

;insert(int x,*tree, *num_nodes, int y)
insert:
    push ebp
    mov ebp, esp
    
    mov ebx, [ebp + 20] ;x
    mov edi, [ebp + 16] ;tree
    mov esi, [ebp + 12]  ;num_nodes
    mov edx, [ebp + 8]  ;y

    
    cmp dword [edi], 0  ;verify if tree is null
    je empty  
    mov edx, [edi] 
    cmp ebx, [edx]       ; compare x with tree->value
    jl insert_sub_tree_left
;sub_tree right    
    push ebx
    mov ecx, [edi]
    sub ecx, 4 ;get left child
    push dword ecx
    push esi
	mov edx,[ebp+8]
	push edx
    call insert
    add esp, 16
    jmp end
    
    
    insert_sub_tree_left:
    push ebx
    mov ecx, [edi]
    sub ecx, 8 ;get left child
    push dword ecx
    push dword esi
	mov edx,[ebp+8]
	push edx
    call insert
    add esp, 16
    jmp end
    
    empty:
    call create_node
    
    mov [eax], ebx    ;value node
    mov ecx, 0
    mov [eax - 4], ecx ;right pointer
    mov [eax - 8], ecx ;left pointer
    mov [eax - 12], edx ; character
    mov [edi], eax    ;connect node in the tree
    inc dword [esi]   ;increments num_nodes
    end:
    pop ebp
ret

;search(*tree, int x)
search_value:
    push ebp
    mov ebp, esp
    push ebx
    push edx
    
        mov edi, [ebp + 12] ;tree
        mov ebx, [ebp + 8]  ;x
        cmp dword [edi], 0
        je didnt_find
            mov edx, [edi]
            cmp ebx, [edx]
            jl search_sub_tree_left
            jg search_sub_tree_right
            
            ;found
            mov eax, 1
            jmp search_end
            
            search_sub_tree_left:
            sub edx, 8
            push edx
            push ebx
            call search_value
            add esp, 8
            jmp search_end
            
            search_sub_tree_right:
            sub edx, 4
            push edx
            push ebx
            call search_value
            add esp, 8
            jmp search_end
            
             
        didnt_find:
            mov eax, 0
        search_end:
    pop edx
    pop ebx
    pop ebp
ret
    
;add_to_encoding(char,*buffer,*encoding,size)
add_to_encoding:
;push ebp
;mov ebp,esp
;mov al,[ebp + 20]
;call print_char
;mov al, ' '
;call print_char
;mov eax,[ebp+8]
;call print_int
;call print_nl
;pop ebp
;ret
    push ebp
    mov ebp,esp
    pushad
        mov ecx,[ebp + 8] ; size
        mov edx,[ebp + 12] ; encoding

        mov eax,ecx
        call print_int
        mov al,' '
        call print_char
        mov al,[ebp+20]
        call print_char
        call print_int
        call print_nl

        mov eax,45
        xor ebx,ebx
        int 80h

        mov ebx,eax
        add ebx,ecx
        add ebx,4
        mov eax,45
        int 80h
        
        
        sub eax,ecx
        movzx ebx,byte [ebp + 20] ; char

        imul ebx, dword 4
        add edx,ebx

        mov [edx],eax ; conecta memoria criada ao vetor de encoding
       

        mov esi,[edx]        
        mov ebx,0
        
        run_buffer:
            mov edi,[ebp + 16]
            movzx edx, byte [edi + ebx]
            mov eax,edx
            call print_char

            mov [esi + ebx],edx

            inc ebx
        loop run_buffer
        mov byte [esi + ebx],0
        call print_nl

        mov edx,[ebp + 12]
        movzx ebx,byte [ebp + 20] ; char
        imul ebx, dword 4
        add edx,ebx
        mov esi,[edx]
        mov ebx,0
        print_buffer:
            mov al,[esi + ebx]
            
            cmp al,0
            je fimfunc
            inc ebx
            call print_char
            jmp print_buffer
        fimfunc:
        call print_nl
        call print_nl
    popad
    pop ebp
ret

;process_huffman_tree(*tree,*buffer,*encoding,size)
process_huffman_tree:
    push ebp
    mov ebp, esp
    pushad

        mov edi, [ebp+20] ;tree_address, node = {freq,left,right,char}

        ;[ebp+16]  buffer
        ;[ebp+12]  encoding
        ;[ebp+8]   size

        cmp edi,dword 0
        je dont_print

            mov edx, [edi]
            ;mov eax, [edx]
            ;call print_int
            ;mov al,' '
            ;call print_char
            ;mov eax, [edx + 12]
            ;call print_int
            ;call print_nl
            mov eax, [edx + 12]

            cmp eax,dword 300
            je continue_process
            ; (char,*buffer,*encoding,size)
            push eax
            push dword [ebp+16]
            push dword [ebp+12]
            push dword [ebp+8]
            call add_to_encoding
            add esp,16
            jmp dont_print
            continue_process:
            mov ecx,[ebp+16];buffer            
            add edx, 4

            push edx
            push ecx

            push dword [ebp+12]

            mov eax,[ebp+8];size
            

            mov [ecx + eax],byte '0'


            inc eax
            push eax
            call process_huffman_tree
            add  esp, 16

            add edx, 4
            
            push edx
            mov ecx,[ebp + 16]
            push ecx
            push dword [ebp+12]
            mov eax,[ebp + 8]


            ; n sei pq tava rolando um bug que o primeiro nó pra direita da raiz tava com o 
            ; caractere dele se transformando 808464428
            ; n consegui descobrir por que e mudei na força bruta aq e ta funcionando
            ; por enquanto
            cmp eax,0
            jne cont
                mov eax,[edx]
                mov dword [eax+12],300
                mov eax,0
            ;;
            cont:
            mov [ecx + eax],byte '1'
            inc eax
            push eax
            
            call process_huffman_tree
            add  esp, 16
            
        dont_print:
    popad
    pop ebp
ret



