.386
.model flat, c
public PRINT
assume cs: code, ds: data, ss: stack

stack segment use16 stack
	db 100 dup(0)
stack ends
	
data segment use16
	message1 db 'Please input your name', 0dh, 0ah, '$'
	message2 db 'please input your password', 0dh, 0ah, '$'
	returnKey db 0dh, 0ah, '$'
	averageRate db 'Average', 0dh, 0ah, '$'
	ranking db 'Rank', 0dh, 0ah, '$'


	bossName db 'Cai Bowen',0
	bossPass db 'test',0,0

	in_name db 15, 10, 15 dup(0)
	in_pwd db 8, 6, 8 dup(0)

	stringEqual db 0
	auth db 0

	message3 db 'Please input the name of goods', 0dh, 0ah, '$'
	message4 db 'Goods is not found', 0dh, 0ah, '$'
	message5 db 'Goods found', 0dh, 0ah, '$'
	
	menu0 db 'please input the function number', 0dh, 0ah, '$'
	menu1 db '(1)Show goods info', 0dh, 0ah, '$'
	menu2 db '(2)Revise goods info', 0dh, 0ah, '$'
	menu3 db '(3)Average profit rate', 0dh, 0ah, '$'
	menu4 db '(4)Rank profit rate', 0dh, 0ah, '$'
	menu5 db '(5)Output all goods info', 0dh, 0ah, '$'
	menu6 db '(6)Quit', 0dh, 0ah, '$'
	choice db 5, 3, 5 dup(0)

	notice db 'Please input new value', 0dh, 0ah, '$'
	newValue db 5, 3, 5 dup(0)

	nameOfGoods db 15, 10, 15 dup(0); 10bytes

	shopName db 'Revise in (1)shop1 or (2)shop2', 0dh, 0ah, '$'

	N = 3

	goodsList db 'banana','$',0,0,0
		   db 'apple','$',0,0,0,0
	       db 'pear','$',0,0,0,0,0

	;buyPrice, salePrice, buyAmount, soldAmount,profitRate
	shop1 db 'SHOP1, ', '$'
	goodsInfo1 dw 5, 8, 20, 15, 0
			  dw 4, 5, 25, 10, 0
			  dw 2, 6, 50, 15, 0
	
	shop2 db 'SHOP2, ', '$'
	goodsInfo2 dw 5, 8, 20, 15, 0
			  dw 4, 5, 25, 10, 0
			  dw 2, 6, 50, 15, 0 

	notValidated db 'Name and password are not validated', 0ah, 0dh, '$'
	BUF db 100 dup(0)
data ends

code segment use16
PRINT proc FAR 
	call searchGoods

	push dx
	push si
	push cx
	push ax

	;SHOW shop1
	lea dx, goodsList
	add dx, bx
	mov ah, 9
	int 21h

	; (1, 2, 3)  * 2
	lea dx, goodsInfo1
	add dx, bx

	mov si, dx
	mov cx, 3
INFO:	
	add si, 2
	mov ax, ds: [si]

	;call F2T10
	;SHOWGAP
	loop INFO

	;SHOW returnKey

	;SHOW shop2
	lea dx, goodsList
	add dx, bx
	mov ah, 9
	int 21h

	lea dx, goodsInfo2
	add dx, bx
	mov si, dx
	mov cx, 3
INFO2:	
	add si, 2
	mov ax, ds: [si]
	mov dx, 16

	;call F2T10
	;SHOWGAP
	loop INFO2

	;SHOW returnKey
	pop ax
	pop cx
	pop si 
	pop dx
	ret
	;jmp far ptr menu

searchGoods:
	mov ah, 9
	mov dx, offset message3
	int 21h

	mov ah, 0ah
	mov dx, offset nameOfGoods
	int 21h

	mov al, [nameOfGoods+2]
	cmp al, 0dh
	;je alert3

	mov dx, 0
	lea si, goodsList
	mov al, [nameOfGoods+1]
	cbw

	mov bx, 0
LOOPLIST:
	lea di, nameOfGoods+2
	mov cx, ax
	repz cmpsb
	je VALIDG
	inc dx
	cmp dx, N
	je notFound
	
	mov bx, 10
	imul bx, dx
	lea si, goodsList
	add si, bx
	jmp LOOPLIST
VALIDG:
	;SHOW returnKey 
	;SHOW message5
	ret

notFound:
	;SHOW returnKey
	;SHOW message4
	jmp searchGoods

PRINT endp
code ends
end


