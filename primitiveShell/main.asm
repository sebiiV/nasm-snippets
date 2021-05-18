BITS 64
SECTION .text
global main

main:
    sub RSP,0x28			; 40 bytes of shadow space
    and RSP,0FFFFFFFFFFFFFFF0h		; align the stack to a multiple of 16.
    call find_kernel32			; base addr of dll is returned in RBX
    call find_getProcAddress		; function addr is returned in RDI
    ; pushing "LoadLibraryA" onto the stck but taking care of alignment
    mov rcx, 0x41797261         	; RCX = "aryA"
    push rcx                    	; Push on the stack
    mov rcx, 0x7262694c64616f4c 	; RCX = "LoadLibr"
    push rcx                    	; Push on stack
    mov rdx,rsp				; RDX = "LoadLibraryA"
    mov rcx, rbx                	; RCX = kernel32 base address
    sub rsp,0x30                	; Allocating stack space
    ;Call GetProcAddress(Kernel32addr,"LoadLibraryA")
    call rdi                    	; result is stored in RAX
    add rsp,0x30                	; clean up allocated stack space
    add rsp,0x10                	; Clean up "LoadLibraryA" off stack
    mov rsi,rax                 	; RSI = Address of LoadLibraryA


; Finding Kernel32.dll
;--------------------------------------------------------------------
; Takes no arguments, returns base address in RBX
;	- Find the TEB. Located at gs:[0x00]
;	- The TEB at 0x60 has a pointer to the PEB
;	- Contains Loader at 0x18
;	- which contains InMemoryOrder list of modules at 0x20
;	- The third entry in the list will be kernel32
;	- 0x20 off this will be the base adress
;--------------------------------------------------------------------
find_kernel32:
    xor rcx,rcx				; RCX = 0
    mov rax, [gs:rcx+0x60]		; RAX = PEB
    mov rax, [rax+0x18]			; RAX = PEB->ldr
    mov rsi, [rax+0x020]		; RSI = PEB->ldr.inMemoryOrder
    ; https://www.felixcloutier.com/x86/lods:lodsb:lodsw:lodsd:lodsq
    lodsq				; RAX = second module (ntdll.dll)
    xchg rax,rsi			; RAX = RSI, RSI=RAX
    lodsq				; RAX = third module (kernel32.dll)
    mov rbx, [rax+0x020]		; RBX = kernel32.dll base address

; Finding GetProcAddress
;--------------------------------------------------------------------
; Takes base address in RBX, returns value in RDI
;	- Go to the PE header from RCX+0x3c
;	- Export table at offset 0x88
;	- Names table at offset 0x20
;	- Get the function name and string check
;   - Go to the ordinals table at offset 0x24
;	- Get function number
;	- Address table at offset 0x1c
;	- Return the function address
; we liberally use 32 bit registers  to ensure we only take the offset
;--------------------------------------------------------------------
find_getProcAddress:
    xor r8 ,r8				; r8 = 0
    mov r8d,[rbx+0x3c]			; r8d = DOS->e_lfanew offset
    mov rdx,r8				; RDX = DOS->e_lfanew
    add rdx,rbx				; RDX = PE header
    mov r8d,[rdx+0x88]			; r8d = export table offset
    add r8 ,rbx				; r8 = export table
    xor rsi,rsi				; RSI = 0
    mov esi, [r8 + 0x20]			; RSI = name table offset
    add rsi,rbx				; RSI = names table
    xor rcx,rcx				; RCX = 0. This will be the ordinal counter
    mov r9, 0x41636f7250746547		; r9 = "GetProcA"
    ; At this point:
    ;	RBX = kernel32 base addr
    ;	RDX = PE header
    ;	RSI = names table
    ;	r8 = export table addr
    ;	r9 = "GetProcA"
    get_function:
        inc rcx				; increment the ordinal counter
        xor rax, rax			; RAX = 0
        mov eax, [rsi + rcx * 4]	; get name offset
        add rax, rbx			; get function name
        cmp QWORD [rax],r9		; Have we found GetProcAddress ?
        jnz get_function		; we did not find it.
        xor rsi, rsi			; RSI = 0
        mov esi, [r8 + 0x24]		; ESI = ordinals offset
        add rsi, rbx			; RSI = ordinals table
        mov cx, [rsi + rcx * 2]		; number of function.
        xor rsi, rsi			; RSI = 0
        mov esi, [r8 + 0x1c]		; ESI = address table offset
        add rsi, rbx			; ESI = address table
        xor rdx, rdx			; RDX=0
        mov edx, [rsi + rcx * 4]	; EDX = Pointer offset
        add rdx, rbx			; RDX = GetProcAddress
        mov rdi, rdx			; Save GetProcAddress in RDI
