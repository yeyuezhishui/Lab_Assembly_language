.386
stack segment use16 stack
	db 200 dup(0)
stack ends
code segment use16
assume cs:code, ss:stack

old_int dw ?, ?

new16h:
	cmp ah, 00h
	je process
	cmp ah, 10h
	je process
	jmp dword ptr old_int

process:
	pushf
	call dword ptr cs:old_int
	cmp al, 97
	jae next1
	jmp back
	
next1:
	cmp al, 122
	jbe toupper
	jmp back

toupper:
	sub al, 32

back:
	iret

start:
	xor ax, ax;ax=0
	mov ds, ax;0指向DS
	mov ax, ds:[16h*4]
	mov old_int, ax;保存偏移
	mov ax, ds:[16h*4+2]
	mov old_int+2, ax;保存段
	
	cli ;置0
	mov word ptr ds:[16h*4], offset new16h;将新的偏移值送中断矢量表
	mov ds:[16h*4+2], cs
	sti

	mov dx, offset start+15;计算字节数,+15便于计算节数时向上取整

	shr dx, 4;计算节数
	add dx, 100h;驻留的长度还需包括程序段前缀的内容

	mov al, 0;退出码为0
	mov ah, 31h;
	int 21h
code ends
end start