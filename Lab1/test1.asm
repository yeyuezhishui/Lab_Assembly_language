.386
stack segment use16 stack
	DB 200 dup(0)
stack ends

data segment use16
	buf1 db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	buf2 db 10 dup(0)
	buf3 db 10 dup(0)
	buf4 db 10 dup(0)
	hello db 'Press any key to begin! $'
	receive db 10
data ends

code segment use16
	assume cs: code, ds: data, ss: stack

start: mov ax, data
	mov ds, ax
	mov esi, offset buf1
	mov ecx, 10
	
LOPA: 
	mov eax, [esi]
	mov [esi+10], eax
	inc eax
	mov [esi+20], eax
	add eax, 3
	mov [esi+30], eax
	inc esi
	dec ecx
	jnz LOPA
	
	mov ah, 4ch
	int 21h

	code ends

end start
