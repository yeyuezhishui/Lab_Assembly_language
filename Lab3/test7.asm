public CAL
extern returnKey: BYTE, goodsList: BYTE, goodsInfo1: WORD, goodsInfo2: WORD, BUF: BYTE

.386
SHOW macro A
	push ax
	push dx
	lea dx, A
	mov ah, 9
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

data segment common
	N = 3
data ends 

code segment use16
CAL proc FAR
	assume ds: data, cs: code
	pusha
	;for test
	mov cx, N
	lea di, goodsInfo1
	lea si, goodsInfo2
testPrint:
	mov ax, ds: [di+8]
	call F2T10
	SHOWGAP
	mov ax, ds: [si+8]
	call F2T10
	SHOWGAP
	add di, 10
	add si, 10
	loop testPrint
	SHOW returnKey
	;end for test

	lea bx, goodsInfo1
	mov cx, N
loopCal:
	call countProfit
	mov [bx+8], ax
	add bx, 10
	loop loopCal
	
	lea bx, goodsInfo2
	mov cx, N
loopCal2:
	call countProfit
	mov [bx+8], ax
	add  bx, 10
	loop loopCal2

	lea si, goodsInfo1
	lea di, goodsInfo2
	mov cx, N
calAPR:	
	mov ax, ds: [si+8]
	add ax, ds: [di+8]
	cmp ax, 0
	jl case6
	mov dx, 0
	jmp re6
case6:
	mov dx, 0ffffh
re6:
	mov bx, 2
	idiv bx
	mov ds: [si+8], ax
	add si, 10
	add di, 10
	loop calAPR

	;for test
	mov cx, N
	lea di, goodsInfo1
	lea si, goodsInfo2
testPrint2:
	mov ax, ds: [di+8]
	call F2T10
	SHOWGAP	
	add di, 10
	loop testPrint2
	SHOW returnKey
	;end test
	popa 
	ret
CAL ENDP

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

countProfit proc
;需要预设BX,如LEA BX, GA1
;LEA BX, GA1
    push cx

    MOV EAX,0
    MOV AX,6[BX] ;ax = 售出总数
    MOV ECX,0
    MOV CX,2[BX] ;cx = 售价
    IMUL EAX,ECX ;EAX = 售价*售出总数
    MOV ECX,0
    MOV EDX,0
    MOV CX,4[BX] ;cx = 进货总数
    MOV DX,[BX] ;dx = 进货价
    IMUL ECX,EDX ;ecx = 进货总数*进货价
    SUB EAX,ECX ;
    IMUL EAX,100
    CMP EAX,0
    JL CASE2
    MOV EDX,0
    JMP RE2
CASE2: 
	MOV EDX,0FFFFFFFFH
RE2:   
	IDIV ECX ;商在EAX中，余数在EDX中，所以没有pop ax与dx   
    pop cx
    ret
 countProfit endp


code ends
end


