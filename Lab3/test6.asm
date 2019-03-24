EXTERN CAL:FAR
public returnKey, goodsList, goodsInfo1, goodsInfo2, BUF

.386
assume cs: code, ds: data, ss: stack

stack segment use16 stack
	db 100 dup(0)
stack ends

SHOW macro A
	push ax
	push dx
	lea dx, A
	mov ah, 9
	int 21h
	pop dx
	pop ax
	endm

SHOW2 macro
	push ax
	mov ah, 9
	int 21h
	pop ax
	endm

WRITE macro A
	push ax
	push dx
	lea dx, A
	mov ah, 0ah
	int 21h
	pop dx
	pop ax
	endm

SHOWGAP macro
	push ax
	push dx
	mov dl, ' '
	mov ah, 2
	int 21h
	pop dx
	pop ax
	endm

TRANSIN macro IN, OUT
	push ax
	push bx
	mov al, IN+2
	sub al, '0'
	
	mov ah, IN+3
	cmp ah, 0dh
	je finish
	mov bl, 10
	mul bl
	mov ah, IN+3
	sub ah, '0'
	add al, ah
finish:
	mov ah, 0
	cbw
	mov OUT, ax
	pop bx
	pop ax
	endm
	
data segment common
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
start: 
	mov ax, data
	mov ds, ax
	mov es, ax

validateStart: 
	mov ah, 9
	mov dx, offset message1
    int 21h       

    mov ah, 0ah
    mov dx, offset in_name
    int 21h

    mov ah, 9
	mov dx, offset returnKey
    int 21h  

    call preValidate

    mov ah, 9
    mov dx, offset message2
    int 21h

    mov ah, 0ah
    mov dx, offset in_pwd
   	int 21h

    mov ah, 9
	mov dx, offset returnKey
    int 21h

    call validate

menu:
	SHOW menu0
	SHOW menu1
	cmp auth, 1
	jne notLogin
	;jne validateStart
	SHOW menu2
	SHOW menu3
	SHOW menu4
	SHOW menu5
notLogin:
	SHOW menu6
	WRITE choice


	mov bl, choice+2
	cmp bl, '1'
	je PRINT

	mov bl, choice+2
	cmp bl, '2'
	je REVISE

	mov bl, choice+2
	cmp bl, '3'
	jne continuem
	call far ptr CAL
	jmp menu

continuem:
	mov bl, choice+2
	cmp bl, '4'
	je RANK

	mov bl, choice+2
	cmp bl, '5'
	je ALLINFO

	mov bl, choice+2
	cmp bl, '6'
	je endMark

	jmp menu

endMark:
	mov ax, 4c00h
	int 21h

ALLINFO:
	pusha
	SHOW shop1
	SHOW returnKey
	lea dx, goodsList
	push dx
	SHOW2
	SHOWGAP
PRINTALL:
	lea di, goodsInfo1
	mov bx, 0
	mov si, di
	mov cx, 4
INFO111:	
	mov ax, ds: [si]
	call F2T10
	SHOWGAP
	add si, 2
	loop INFO111
	inc bx
	cmp bx, N
	je INFO112
	SHOW returnKey
	mov cx, 4
	add si, 2
	pop dx
	add dx, 10
	push dx
	SHOW2
	SHOWGAP
	jmp INFO111

INFO112:
	SHOW returnKey
	SHOW returnKey
	SHOW shop2
	SHOW returnKey
	lea dx, goodsList
	push dx
	SHOW2 ;直接打出dx中的语句
	SHOWGAP
	lea di, goodsInfo2
	mov bx, 0
	mov si, di
	mov cx, 4
INFO122:	
	mov ax, ds: [si]
	call F2T10
	SHOWGAP
	add si, 2
	loop INFO122
	inc bx
	cmp bx, N
	je AVERATE
	SHOW returnKey
	mov cx, 4
	add si, 2
	pop dx
	add dx, 10
	push dx
	SHOW2
	SHOWGAP
	jmp INFO122

AVERATE:
	SHOW returnKey
	SHOW returnKey
	SHOW averageRate
	mov cx, N
	lea si, goodsInfo1
AVERLOOP:
	mov ax, ds: [si+8]
	call F2T10
	SHOWGAP
	add si, 10
	loop AVERLOOP

PRINTRANK:
	SHOW returnKey
	SHOW ranking
	mov cx, N
	lea si, goodsInfo2
PRIRLOOP:	
	mov ax, ds: [si+8]
	call F2T10
	SHOWGAP
	add si, 10
	loop PRIRLOOP
	SHOW returnKey
	popa
	jmp menu

RANK:
	;ax, dx, cx的值由小到大
	pusha
	lea si, goodsInfo1+8
	mov ax, [si]
	add si, 10
	mov dx, [si]
	add si, 10
	mov cx, [si]

	mov bx, 0
	mov di, 1
	mov bp, 2

	cmp ax, dx
	jg swap1
continue1:
	cmp dx, cx
	jg swap2
continue2:
	cmp ax, dx
	jg swap3
continue3:
	imul bx, 10
	imul di, 10
	imul bp, 10
	lea si, goodsInfo2+8
	add bx, si
	add di, si
	add bp, si
	mov word ptr [bx], 3
	mov word ptr [di], 2
	; bp无法作为寻址寄存器，使用后无法成功更改对应数据段的值
	;mov word ptr [bp], 1
	mov di, bp
	mov word ptr [di], 1
	popa

	;for test
	mov cx, N
	lea si, goodsInfo2+8
testPrint3:
	mov ax, [si]
	call F2T10
	SHOWGAP
	add si, 10
	loop testPrint3
	SHOW returnKey
	;end test
	jmp menu

swap1: 
	xchg ax, dx
	xchg bx, di
	;bx is rank of the first goods, di is the second, bp is the third
	jmp continue1
swap2:
	xchg dx, cx
	xchg di, bp
	jmp continue2
swap3:
	xchg ax, dx
	xchg bx, di
	jmp continue3



;bx为EA
REVISE:
	call searchGoods
	call PRINT2

	SHOW shopName
	WRITE choice

	mov al, choice+2
	cmp al, '1'
	je inshop1

	cmp al, '2'
	je inshop2

	cmp al, 0dh
	je menu

	jmp REVISE

inshop1:
	lea dx, goodsInfo1
	add dx, bx
	jmp inputValue
	;SHOW notice
	;WRITE newValue


	;jmp far ptr menu
inshop2:
	lea dx, goodsInfo2
	add dx, bx
	jmp inputValue
	;SHOW notice
	;WRITE newValue


	;jmp far ptr menu
	
inputValue:
	mov si, dx
	mov dx, 16
	mov cx, 3
loopValue:
	mov ax, ds: [si]
	call F2T10
	SHOWGAP
	WRITE newValue
	call VALUECHECK
	TRANSIN newValue, ds:[si]
skip:
	add si, 2
	SHOW returnKey
	loop loopValue
	jmp menu

PRINT2:
	push dx
	push si
	push cx
	push ax

	SHOW shop1
	lea dx, goodsInfo1
	add dx, bx
	mov si, dx
	mov cx, 3
INFO11:	
	mov ax, ds: [si]
	call F2T10
	SHOWGAP
	add si, 2
	loop INFO11

	SHOW returnKey

	SHOW shop2
	lea dx, goodsInfo2
	add dx, bx
	mov si, dx
	mov cx, 3
INFO12:	
	mov ax, ds: [si]
	call F2T10
	SHOWGAP
	add si, 2
	loop INFO12

	SHOW returnKey
	pop ax
	pop cx
	pop si 
	pop dx
	ret

;bx为EA
searchGoods:
	mov ah, 9
	mov dx, offset message3
	int 21h

	mov ah, 0ah
	mov dx, offset nameOfGoods
	int 21h

	mov al, [nameOfGoods+2]
	cmp al, 0dh
	je alert3

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
	SHOW returnKey 
	SHOW message5
	ret

notFound:
	SHOW returnKey
	SHOW message4
	jmp searchGoods

;bx为EA
PRINT:
	call searchGoods

	push dx
	push si
	push cx
	push ax

	SHOW shop1
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

	call F2T10
	SHOWGAP
	loop INFO

	SHOW returnKey

	SHOW shop2
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

	call F2T10
	SHOWGAP
	loop INFO2

	SHOW returnKey
	pop ax
	pop cx
	pop si 
	pop dx
	jmp far ptr menu


preValidate:
	mov al, 0dh
	mov ah, ds: [in_name+2]

	cmp al, ah
	je menu

	mov al, 71h ; input = q
	cmp al, ah
	je endMark

	ret

validate: 
CERTINAME:
	lea di, bossName
	lea si, in_name+2
	
	mov al, [in_name+1]
	cbw
	mov cx, ax

	repz cmpsb
	je CERTIPASS ;name valid

	jmp alert2

CERTIPASS:
	lea di, bossPass
	lea si, in_pwd+2

	mov al, in_pwd+1
	cbw
	mov cx, ax

	repz cmpsb
	je VALID
	jmp alert2

VALID:
	mov auth, 1
	ret

alert2: mov dx, offset notValidated
	mov ah, 9
	int 21h
	jmp far ptr validateStart

alert3: jmp far ptr validateStart



F2T10 PROC FAR
	PUSH EBX
	PUSH SI

	LEA SI, BUF
	CMP DX, 32 ;判断是对EAX还是对AX中的数进行操作
	JE B
	MOVSX EAX, AX
B:  OR EAX, EAX   ;不改变EAX的值，为了使用JNS检查EAX是否为0
	JNS PLUS
	NEG EAX
	MOV BYTE PTR [SI], '-'
	INC SI
PLUS:
	MOV EBX, 10     ;设置基数为10
	CALL RADIX

	MOV BYTE PTR [SI], '$'
	LEA DX, BUF
	MOV AH, 9
	INT 21H
	POP SI
	POP EBX
	RET
F2T10 ENDP


;入口参数 AX/EAX---存放待转换的有符号二进制数
;DX---存放16位或32位有符号二进制数的标志，DX=32为32位
;所用寄存器 EBX---存放基数(3-16)
;SI---十进制数ASCII码存储区的指针
;出口参数 转换后带符号的十进制数在显示器上输出
RADIX PROC
	PUSH CX
	PUSH EDX
	XOR CX, CX
LOP1:
	XOR EDX ,EDX
	DIV EBX
	PUSH DX
	INC CX
	OR EAX, EAX
	JNZ LOP1
LOP2:
	POP AX
	CMP AL, 10
	JB L1
	ADD AL, 7
L1:
	ADD AL, 30H
	MOV [SI], AL
	INC SI
	LOOP LOP2
	POP EDX
	POP CX
	RET
RADIX ENDP

VALUECHECK PROC
	push ax
    push si
    push cx
    mov si, 2
    mov al, [newValue+1]
    cbw
    mov cx, ax
    cmp cx, 0
    je next
compareString:
	cmp [newValue+si], 0dh
	je next
    cmp [newValue+si], '0'
    jl return
    cmp [newValue+si], '9'
    jg return
    inc si
   	loop compareString

    pop cx
    pop si
    pop ax
    ret   ;validated
return:
	pop cx
    pop si
    pop ax
    SHOW returnKey
    jmp far ptr loopValue ;not validated
next:
	pop cx
    pop si
    pop ax
    jmp skip
VALUECHECK ENDP


code ends

end start