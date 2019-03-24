.386
stack segment use16 stack
	db 200 dup(0)
stack ends
code segment use16
assume cs:code, ss:stack


start:
	
	mov ax,0000H
	MOV DS,ax
	mov word ptr ds:[16h*4],11E0H;将新的偏移值送中断矢量表
	mov word ptr ds:[16h*4+2],0F000h
    mov ah,4Ch
	int 21h

code ends
end start