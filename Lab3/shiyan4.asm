.MODEL SMALL
PUBLIC _FUNC3_4
PUBLIC _FUNC3_5
PUBLIC _FUNC3_6
PUBLIC _DISPLAY
PUBLIC _modify_info
PUBLIC _search_good


.386
;---------------------------
STACK1 SEGMENT USE16 STACK
DB 200 DUP(0)
STACK1 ENDS
;---------------------------
_DATA SEGMENT USE16 PUBLIC 
BNAME DB "XUYONGXIN",0;老板名称徐永�?
COUNT1 EQU $-BNAME-1; 姓名长度
BPSW  DB "TEST123",0;密码
COUNT2 EQU $-BPSW-1;  密码长度
INNAME DB 30 DUP('$')
INPSW  DB 30 DUP('$')
INGOOD DB 30 DUP('$')
SIGN DB 0
TIPN  DB "Please enter your name:$";姓名输入提示
TIPP  DB "Please enter your password:$";密码输入提示
TIPG  DB "Please enter the goods you want to search:$";提示输入要找的商�?
STIPC  DB "Please choose one function from above!$";提示输入选择
TIPCOST DB "cost: $"
TIPPRICE DB "price: $"
TIPTOTAL DB "total num: $"
FAILED DB "Log in failed! Try again!$";登录失败提示
FAILED2 DB "Search failed! Try again!$";查找失败提示
FAILED3 DB "INVALID!Not number!$"
INPUTERROR1 DB "Please input a number between 1 and 2!$";输入的数字不合理
INPUTERROR2 DB "Please input a number between 1 and 6!$"
OUTSHOP1 DB "SHOP1 $"
OUTSHOP2 DB "SHOP2 $"
INCOST DB "Please input the modified cost: $"
INPRICE DB "Please input the modified price: $"
INTOTAL DB "Please input the modified total number: $"
PROF DB "profit margin:$";利润�?APROF DB "average profit margin:$";平均利润�?CRLF  DB 0DH,0AH,"$";
ISNUM DB 0
CRLF  DB 0DH,0AH,"$";
SUCCESS DB "Search success!$"
RANKA DB "profit rank: A$";利润等级
RANKB DB "profit rank: B$"
RANKC DB "profit rank: C$"
RANKD DB "profit rank: D$"
RANKF DB "profit rank: F$"
WELCOME DB "Welcome back!$"
OUT_BUF DB 30 DUP(0)
IN_BUF_cost DB 30 DUP('$')
IN_BUF_price DB 30 DUP('$')
IN_BUF_total DB 30 DUP('$')
Choice DB '$$$$$';记录选择
subChoice DB '$$$$$';
strmatch DB 0
N EQU 8
S1 DB 'SHOP1', '$'

GA1 DB 'BAG',6 DUP(' '),'$'
dw 12,30,25,5,?
GA2 DB 'BOOK',5 DUP(' '),'$'
DW 35,56,70,25,?;
GA3 DB 'PEN',6 DUP(' '),'$'
dw 50,80,32,16,?
GA4 DB 'COOKER',3 DUP(' '),'$'
dw 55,70,52,26,?
GA5 DB 'BREAD',4 DUP(' '),'$'
dw 55,70,52,27,?
;dw 60,100,45,15,?
GA6 DB 'APPLE',4 DUP(' '),'$'
dw 55,70,52,25,?
;dw 75,80,89,67,?
GA7 DB 'BALL',5 DUP(' '),'$'
dw 80,120,20,2,?
GA8 DB 'SHOE',5 DUP(' '),'$'
dw 5,10,200,120,?

S2 DB 'SHOP2', '$'

GB1 DB 'BAG',6 DUP(' '),'$'
dw 12,28,20,15,?
GB2 DB 'BOOK',5 DUP(' '),'$'
DW 35,50,30,24,?;
GB3 DB 'PEN',6 DUP(' '),'$'
dw 55,75,100,20,?
GB4 DB 'COOKER',3 DUP(' '),'$'
dw 58,72,62,30,?
GB5 DB 'BREAD',4 DUP(' '),'$'
dw 58,72,62,30,?
;dw 65,102,50,23,?
GB6 DB 'APPLE',4 DUP(' '),'$'
dw 58,72,62,30,?
;dw 73,82,50,2,?
GB7 DB 'BALL',5 DUP(' '),'$'
dw 85,125,25,3,?
GB8 DB 'SHOE',5 DUP(' '),'$'
dw 6,11,250,140,?
TABLE1 DW 8 DUP(0)
NUMBER DW 1,2,3,4,5,6,7,8
AUTH DB 0
temp1 DW 0
length1 DW 0
time DB 0
submenu   DB "***********************************SUB MENU************************************$"
submenu1  DB "***************************1. Shop1        2. Shop2****************************$"
menutable DB "*************************************MENU**************************************$"
menu1     DB "*************************1.Query Info    2.Modify Info*************************$"
menu2     DB "*************************3.Print APR     4.Rank by APR*************************$"
menu3     DB "*************************5.Print Info    6.Exit by now*************************$"
menubar   DB "*******************************************************************************$"
menu4     DB "*************************1.Query Info    2.Exit by now*************************$"
_DATA ENDS
;---------------------------
_TEXT SEGMENT USE16 PUBLIC 
ASSUME CS:_TEXT,DS:_DATA,ES:_DATA,SS:STACK1
LINE MACRO
MOV DL,0AH
MOV AH,2
INT 21H
ENDM
PRINT MACRO A
LEA DX,A
MOV AH,9
INT 21H
ENDM
SCANF MACRO B
LEA DX,B
MOV AH,10
INT 21H
ENDM
;**********************
;不带换行的输出
outputline macro string0
push dx
push ax
mov dx, offset string0
mov ah, 09h;输出提示
int 21h
pop ax
pop dx
endm
;**********************
;**********************
;输出宏
output macro string1
push dx
push ax
mov dx, offset string1
mov ah, 09h;输出提示
int 21h
lea dx, CRLF
mov ah, 09h;输出换行
int 21h
pop ax
pop dx
endm
;**********************
;**********************
;输出字符宏
outc macro char
push dx
push ax
mov dl, char
mov ah, 02h;输出提示
int 21h
pop ax
pop dx
endm
;**********************
;**********************
;输入宏
input macro string2
push dx
push ax
mov ah, 0ah;
lea dx, string2
int 21h;
lea dx, CRLF;输出换行
mov ah, 09h
int 21h
pop ax
pop dx
endm
;**********************
f10to2 proc
    push ebx
    mov eax, 0
f10:
next11:
    mov  BL, [si]
next22:
    sub bl, 30h
    movzx ebx, bl
    imul eax, 10
    add eax, ebx
    inc si
    dec cx
    jnz next11
    pop ebx
ret
f10to2 endp

;**********************
;输入是否纯数字判断,入口时di指向INBUF+2
allnum macro string3
    local NUMLOOP
    local NOT_NUM
    local escape00
    push di
    push cx
    push bx
    push ax
    lea di, string3
    mov cl, string3+1
    mov ISNUM, 1
    mov bx, 0
    add di, 2
NUMLOOP:
    mov al, [di+bx]
    cmp al, '0';比零小
    jl NOT_NUM
    cmp al, '9';比9大
    jg NOT_NUM
    inc bx
    dec cl
    cmp cl, 0
    jnz NUMLOOP
    jmp escape00
NOT_NUM:
    mov ISNUM, 0
escape00:
    pop ax
    pop bx
    pop cx
    pop di
endm
;**********************
;**********************
;显示十进制
radixx proc
    push cx
    push edx
    mov cx, 0
LOP1:mov edx, 0
    div ebx
    push dx
    inc cx
    cmp eax, 0
    jne LOP1
LOP2:pop ax
    cmp al, 10
    jb L1
    add al, 7
L1: add al, 30h
    mov [si], al
    inc si
    loop LOP2
    pop edx
    pop cx
    ret
radixx endp
;**********************
;**********************
;在某个shop中搜索商品，进入时，si=GA1或GB1，出口时，si为商品的首地址
match_good_from_shop proc
entergood:
    output TIPG;提示输入想查找的商品名称
    input INGOOD;输入商品
    mov strmatch, 2;输入的为换行
    mov cl, INGOOD+2;看看是否是回车
    cmp cl, 0dh;
    jz escape0
    mov si, offset GA1-20
    sub si, 20
    mov bx, offset GA1
    mov ax, offset GB1
    sub ax, bx
    mov length1, ax
begin_search:
    add si, 20
    mov di, length1
    add di, si
    cmp si, di
    jg unmatch;超过最后一个商品 匹配失败
    mov di, offset INGOOD+2
    mov bx, 0
    mov ch, INGOOD+1;循环次数为当前输入商品的词长
    LOOPC:
    mov al,[si+bx]
    mov dl,[di]
    cmp al, dl
    jnz nextgood;   一个商品不匹配，直接对比下一个商品
    inc bx
    inc di
    dec ch
    cmp ch, 0
    jnz LOOPC
    mov strmatch, 1; 匹配成功 退出
    jmp escape0
nextgood:
    cmp si, word ptr GA8;shop1中是否搜索完了
    jg unmatch;不匹配
    ;否则,指向下一个商品,继续搜索
    add ax, 20
    jmp begin_search
unmatch:;不匹配
    mov strmatch, 0
    output FAILED2;输出查找失败
    jmp entergood;重新输入
escape0:
ret
match_good_from_shop endp
;**********************
;**********************
;在Shop1中查询商品，系统存的商品首地址在SI中,用户输入的字符串首地址在DI中
;注:如果用户输入了字符串str，DI的地址应该为str
_search_good proc
    push edx
    push ebx
    push ecx
    push si
    push di
    push eax
call match_good_from_shop
    cmp strmatch, 2
    jz escape2
matchsucc:
    output INGOOD+2
    mov ah, 09h
    lea dx, OUTSHOP1
    int 21h
    mov di, si
    add di, 10
    mov cx, 4
    mov temp1, si;暂时存放si
outpara:
    mov ebx, 10
    movsx eax, word ptr [di]
    lea si, OUT_BUF
    call radixx
    mov byte ptr [si], 20h;补空格
    inc si
    mov byte ptr [si], '$';补结束
    lea dx, OUT_BUF
    mov ah, 09h
    int 21h
    add di, 2
    LOOP outpara
    lea dx, CRLF
    mov ah, 09h;输出换行
    int 21h
    mov ah, 09h
    lea dx, OUTSHOP2
    int 21h
    mov di, temp1
        mov ax, offset GA1
    mov bx, offset GB1
    sub bx, ax
    add di, bx
    add di, 10
    mov cx, 4
outpara2:
    mov ebx, 10
    movsx eax, word ptr [di]
    lea si, OUT_BUF
    call radixx
    mov byte ptr [si], 20h;补空格
    inc si
    mov byte ptr [si], '$';补结束
    lea dx, OUT_BUF
    mov ah, 09h
    int 21h
    add di, 2
    LOOP outpara2
    lea dx, CRLF
    mov ah, 09h;输出换行
    int 21h
escape2:
    mov si, temp1
    pop eax
    pop di
    pop si
    pop ecx
    pop ebx
    pop edx
ret
_search_good endp
;**********************
;**********************
;修改商品信息，入口参数si是GA1或GB1，进来了以后再输入商品的名称
_modify_info proc
output submenu
output submenu1
inch:    input subChoice
    mov al, subChoice+2;输入的数字
    cmp al, '1';小于1，大于2都不合理
    jl error3
    cmp al, '2'
    jg error3
    jmp matching
error3: output INPUTERROR1
    jmp inch
matching:
    call match_good_from_shop
    select_shop:
    mov al, subChoice+2
    cmp al, '2'
    jz select2
    jmp nextabc
    select2:
    push ax
    push bx
    mov ax, offset GA1
    mov bx, offset GB1
    sub bx, ax
    add si, bx
    pop bx
    pop ax
nextabc:    mov temp1, si
    cmp strmatch, 2;只输入了回车
    jz escape3
;否则 匹配成功了
    mov di, si
    add di, 10
    mov cx, 3
    mov temp1, si;暂时存放si
outpara1:
    mov ebx, 10
    movsx eax, word ptr [di]
    lea si, OUT_BUF
    call radixx
    mov byte ptr [si], 20h;补空格
    inc si
    mov byte ptr [si], '$';补结束
    cmp cx, 3
    je  outcost
    cmp cx, 2
    je  outprice
outtotal:
    outputline TIPTOTAL
    outputline OUT_BUF
    outputline INTOTAL
    input IN_BUF_total
    outputline OUT_BUF
    outc '>'
    outc '>'
    outpuT IN_BUF_total+2
    push cx
    mov cl, IN_BUF_total+2
    cmp cl, 0dh
    pop cx
    jz conti
    allnum IN_BUF_total
    cmp ISNUM, 1
    jnz outtotal
push si
push ax
push dx
push cx
movsx cx, IN_BUF_total+1
LEA SI, IN_BUF_total+2
mov dx, 16
call f10to2
mov si, temp1
add si, 14
mov [si],ax
pop cx
pop dx
pop ax
pop si
    jmp conti
outcost:
    outputline TIPCOST
    outputline OUT_BUF
    outputline INCOST
    input IN_BUF_cost
    outputline OUT_BUF
    outc '>'
    outc '>'
    outpuT IN_BUF_cost+2
    push cx
    mov cl, IN_BUF_cost+2
    cmp cl, 0dh
    pop cx
    jz conti
    allnum IN_BUF_cost
    cmp ISNUM, 1
    jnz outcost
    push si
    push ax
    push dx
    push cx
    movsx cx, IN_BUF_cost+1
    LEA SI, IN_BUF_cost+2
    mov dx, 16
    call f10to2
    mov si, temp1
    add si, 10
    mov [si],ax
    pop cx
    pop dx
    pop ax
    pop si
    jmp conti
outprice:
    outputline TIPPRICE
    outputline OUT_BUF
    outputline INPRICE
    input IN_BUF_price
    outputline OUT_BUF
    outc '>'
    outc '>'
    outpuT IN_BUF_price+2
    push cx
    mov cl, IN_BUF_price+2
    cmp cl, 0dh
    pop cx
    jz conti
    allnum IN_BUF_price
    cmp ISNUM, 1
    jnz outprice
push si
push ax
push dx
push cx
movsx cx, IN_BUF_price+1
LEA SI, IN_BUF_price+2
mov dx, 16
call f10to2
mov si, temp1
add si, 12
mov [si],ax
pop cx
pop dx
pop ax
pop si
    jmp conti
conti:
    add di, 2
    dec cx
    cmp cx, 0
    jnz outpara1
    lea dx, CRLF
    mov ah, 09h;输出换行
    int 21h
;请按顺序输入进货价、销售价、进货总数顺序输入修改的数
escape3:
ret
_modify_info endp

_DISPLAY PROC 
PUSH EDX
PUSH EBX
PUSH ECX
PUSH EDI
MOV DI,AX		
CMP AX,0
JGE SHOWNUM
MOV DL,'-'
MOV AH,2
INT 21H
MOV AX,DI
NEG AX
SHOWNUM:MOV BX,10
MOV CX,0
PUSHNUM:MOV DX,0
DIV BX
PUSH DX
INC CX
CMP AX,0
JZ POPNUM
JMP PUSHNUM
POPNUM:		POP DX
ADD DL,30H
MOV AH,2
INT 21H
LOOP POPNUM
MOV DL,' '
MOV AH,2
INT 21H
POP EDI
POP ECX
POP EBX
POP EDX
RET
_DISPLAY ENDP


_FUNC3_4 PROC 
PUSH EAX
PUSH EBX
PUSH ECX
PUSH EDX
PUSH ESI
PUSH EDI
PUSH EBP	;保护现场

LEA SI,GA1
LEA DI,GB1
ADD SI,10
ADD DI,10
MOV BP,N

LOPA:
MOVSX EDX,WORD PTR 4[SI]		
MOVSX EAX,WORD PTR 2[SI]
MOVSX ECX,WORD PTR [SI]
MOVSX EBX,WORD PTR 6[SI]
IMUL EAX,EBX		
IMUL ECX,EDX
SUB EAX,ECX
MOV EDX,100
IMUL EDX										;64位除�?2位，�?2位结�?MOV 8[SI],AX
IDIV ECX
MOV 8[SI],AX

MOVSX EDX,WORD PTR 4[DI]
MOVSX ECX,WORD PTR [DI]
MOVSX EAX,WORD PTR 2[DI]
MOVSX EBX,WORD PTR 6[DI]
IMUL EAX,EBX
IMUL ECX,EDX
SUB EAX,ECX
MOV EDX,100
IMUL EDX
IDIV ECX

MOV DX,8[SI]
ADD AX,DX
SAR AX,1
MOV 8[SI],AX	
ADD SI,20
ADD DI,20
DEC BP
JNZ LOPA

POP EBP
POP EDI
POP ESI
POP EDX
POP ECX
POP EBX
POP EAX	;保护现场
RET
_FUNC3_4 ENDP

_FUNC3_5 PROC 
PUSH EAX
PUSH EBX
PUSH ECX
PUSH EDX
PUSH ESI
PUSH EDI
PUSH EBP	;保护现场


MOV CX,8

LEA SI,GA1
LEA DI,TABLE1
ADD SI,10

LOP5:
MOV AX,8[SI]
MOV [DI],AX

ADD SI,20
ADD DI,2
DEC CX
JNZ LOP5	;将各商品的平均利润率存入数组


MOV BX,8

LOP101:
LEA SI,TABLE1
LEA DI,NUMBER
DEC BX
MOV CX,BX
LOP201:
MOVSX AX,BYTE PTR [SI]
MOVSX BP,BYTE PTR 2[SI]

CMP AX,BP
JGE NEXT
MOV  [SI],BP
MOV  2[SI],AX

MOV AX,[DI]
MOV BP,2[DI]
MOV [DI],BP
MOV 2[DI],AX
NEXT:
ADD SI,2
ADD DI,2
LOOP LOP201

CMP BX,2
JNE LOP101	;将table中的数据排序


LEA BP,TABLE1
LEA SI,NUMBER


MOV AX,0
MOV BX,0
LOP3:
LEA DI,GB1
SUB DI,2
MOV CX,[SI]

INC BX
LOP4:
ADD DI,20
LOOP LOP4

CMP AX,[BP]
JE QWE1
MOV [DI],BX
MOV DX,BX
JMP QWE2
QWE1:
MOV [DI],DX
JMP QWE2


QWE2:ADD SI,2
MOVSX EAX,WORD PTR[BP]
ADD BP,2
CMP BX,8
JNE LOP3





POP EBP
POP	EDI
POP ESI
POP EDX
POP ECX
POP EBX
POP EAX	;保护现场
RET
_FUNC3_5 ENDP





_FUNC3_6 PROC
PUSH EAX
PUSH EBX
PUSH ECX
PUSH EDX
PUSH ESI
PUSH EDI
PUSH EBP	;保护现场


PRINT S1
LINE
LEA SI,GA1
MOV CX,8
LOP11:
PRINT [SI]

ADD SI,10
MOV BP,5
LOP10:
MOVSX EAX,WORD PTR[SI]
CALL _DISPLAY
ADD SI,2
DEC BP
JNZ LOP10
LINE
DEC CX
JNZ LOP11

LINE
PRINT S2
LINE
LEA SI,GB1
MOV CX,8
LOP12:
PRINT [SI]

ADD SI,10
MOV BP,5
LOP13:
MOVSX EAX,WORD PTR[SI]
CALL _DISPLAY
ADD SI,2
DEC BP
JNZ LOP13
LINE
DEC CX
JNZ LOP12

LEA SI,NUMBER
MOV CX,8
MOV BX,0
LOP15:
    INC BX
    MOV [SI],BX
    ADD SI,2
    DEC CX
    JNZ LOP15
POP EBP
POP	EDI
POP ESI
POP EDX
POP ECX
POP EBX
POP EAX	;保护现场
RET
_FUNC3_6 ENDP



_TEXT ENDS
END
