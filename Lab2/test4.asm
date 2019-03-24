.386
DATA SEGMENT USE16

;version1 factor import 2000, loop 3000 takes 440ms

pname   DB   'Please input your name:$'
pass   DB   'Please input the password:$'
failure DB  'login failed$'
goods   DB  'the name of the goods:$'
in_name DB   50
        DB   0
        DB   50 DUP(0)
in_pass DB   50
        DB   0
        DB   50 DUP(0)
in_goods DB   50
         DB   0
         DB   50 DUP(0)
APR    DW  0
KIND   DB  0
AUTH   DB  0
BPEN   DB  'PEN',0
BBOOK  DB  'Bag',0
BNAME  DB  'Cai Bowen',0 
BPASS  DB  'test',0,0
N      EQU   3000
S1     DB  'SHOP1',0 
GA1    DB    'PEN', 7 DUP(0) 
       DW   35,56,70,25,?
GA2    DB    'Bag', 7 DUP(0)
       DW   12,30,2000,0,?  ;进货价，售价，进货总数，售出总数
GAN    DB   N-2 DUP( 'Temp-Value',15,0,20,0,30,0,2,0,?,?) 
S2     DB  'SHOP2',0          
GB1    DB    'Bag', 7 DUP(0) 
       DW   12,28,2000,0,?   
GB2    DB    'PEN', 7 DUP(0)  
       DW   35,50,30,24,?  
message db 'Input mistake', '$'

DATA   ENDS

STACK  SEGMENT USE16 STACK
       DB 200 DUP(0)
STACK  ENDS

CODE   SEGMENT USE16
       ASSUME CS:CODE,DS:DATA,SS:STACK
BEGIN: MOV AX,DATA
       MOV DS,AX
       MOV ES,AX

L5:    LEA DX,goods        ;商品名
       MOV AH,9
       INT 21H
       LEA DX,in_goods     ;输入商品名
       MOV AH,10
       INT 21H
       LEA DX,0AH          ;换行
       MOV AH,2
       INT 21H 

       ;计时开始
       MOV AX, 0
       call TIMER

       MOV BP, 3000

L7:    PUSH BX
       LEA BX,GA1          ;计算A店笔的利润率
       MOV EAX,0
       MOV AX,16[BX]
       MOV ECX,0
       MOV CX,12[BX]
       IMUL EAX,ECX
       MOV ECX,0
       MOV EDX,0
       MOV CX,14[BX]
       MOV DX,10[BX]
       IMUL ECX,EDX
       SUB EAX,ECX
       IMUL EAX,100
       CMP EAX,0
       JL CASE4
       MOV EDX,0
       JMP RE4
CASE4: MOV EDX,0FFFFFFFFH
RE4:   IDIV ECX
       MOV 18[BX],AX
       PUSH BX
       LEA BX,GB2          ;计算B店笔的利润率
       MOV EAX,0
       MOV AX,16[BX]
       MOV ECX,0
       MOV CX,12[BX]
       IMUL EAX,ECX
       MOV ECX,0
       MOV EDX,0
       MOV CX,14[BX]
       MOV DX,10[BX]
       IMUL ECX,EDX
       SUB EAX,ECX
       IMUL EAX,100
       CMP EAX,0
       JL CASE3
       MOV EDX,0
       JMP RE3
CASE3: MOV EDX,0FFFFFFFFH
RE3:   IDIV ECX
       MOV 18[BX],AX
       POP DI             ;计算平均利润率
       MOV AX,18[DI]
       ADD AX,18[BX]
       CMP AX,0
       JL  CASE5
       MOV DX,0
       JMP RE5
CASE5: MOV DX,0FFFFH
RE5:   MOV BX,2
       IDIV BX
       MOV APR,AX
       POP BX 
       ;JMP L9

       PUSH BX
L12:   LEA BX,GA2          ;计算A店包的利润率
       MOV EAX,0
       MOV AX,16[BX]
       MOV ECX,0
       MOV CX,12[BX]
       IMUL EAX,ECX
       MOV ECX,0
       MOV EDX,0
       MOV CX,14[BX]
       MOV DX,10[BX]
       IMUL ECX,EDX
       SUB EAX,ECX
       IMUL EAX,100
       CMP EAX,0
       JL CASE2
       MOV EDX,0
       JMP RE2
CASE2: MOV EDX,0FFFFFFFFH
RE2:   IDIV ECX
       MOV 18[BX],AX
       PUSH BX
       LEA BX,GB1          ;计算B店包的利润率
       MOV EAX,0
       MOV AX,16[BX]
       MOV ECX,0
       MOV CX,12[BX]
       IMUL EAX,ECX
       MOV ECX,0
       MOV EDX,0
       MOV CX,14[BX]
       MOV DX,10[BX]
       IMUL ECX,EDX
       SUB EAX,ECX
       IMUL EAX,100
       CMP EAX,0
       JL CASE1
       MOV EDX,0
       JMP RE1

CASE1: MOV EDX,0FFFFFFFFH
RE1:   IDIV ECX
       MOV 18[BX],AX
       POP DI             ;计算平均利润率
       MOV AX,18[DI]
       ADD AX,18[BX]
       CMP AX,0
       JL  CASE6
       MOV DX,0
       JMP RE6
CASE6: MOV DX,0FFFFH
RE6:   MOV BX,2
       IDIV BX
       MOV APR,AX
       POP BX     
       ;JMP L9

       ;LOOP L7

L8:    ;MOV BL,in_goods+1   ;3.4 输出商品名 
       ;MOV BH,0
       ;MOV BYTE PTR in_goods+2[BX],'$'
       ;LEA DX,in_goods+2      
       ;MOV AH,9
       ;INT 21H
       ;LEA DX,0AH         ;换行
       ;MOV AH,2
       ;INT 21H  

       ;push dx
       ;mov dl, '!'
       ;mov ah, 2
       ;int 21h
       ;pop dx

       ;判断已售数量是否大于库存数量
       ;此行之后6行为此次新增代码
       MOV AX, WORD PTR GA2+14 
       MOV BX, WORD PTR GA2+16
       CMP AX, BX
       JNG TEMP
       INC BX; 售出数量加1
       MOV WORD PTR DS:[GA2+16], BX

       ;此行之后6行为此次新增代码
       MOV AX, WORD PTR GB1+14 
       MOV BX, WORD PTR GB1+16
       CMP AX, BX
       JNG TEMP
       INC BX; 售出数量加1
       MOV WORD PTR DS:[GB1+16], BX

       JMP FAR PTR L7
       
TEMP:  SUB BP, 1
       CMP BP, 0
       JNE RESET

       ;计时结束
       MOV AX, 1
       CALL TIMER

       JMP L5

       MOV AX, 4C00H
       INT 21H

RESET: MOV WORD PTR DS:[GA2+16], 0 
       MOV WORD PTR DS:[GB1+16], 0
       JMP FAR PTR L7

TIMER  PROC
       PUSH  DX
       PUSH  CX
       PUSH  BX
       MOV   BX, AX
       MOV   AH, 2CH
       INT   21H          ;CH=hour(0-23),CL=minute(0-59),DH=second(0-59),DL=centisecond(0-100)
       MOV   AL, DH
       MOV   AH, 0
       IMUL  AX,AX,1000
       MOV   DH, 0
       IMUL  DX,DX,10
       ADD   AX, DX
       CMP   BX, 0
       JNZ   _T1
       MOV   CS:_TS, AX
_T0:   POP   BX
       POP   CX
       POP   DX
       RET
_T1:   SUB   AX, CS:_TS
       JNC   _T2
       ADD   AX, 60000
_T2:   MOV   CX, 0
       MOV   BX, 10
_T3:   MOV   DX, 0
       DIV   BX
       PUSH  DX
       INC   CX
       CMP   AX, 0
       JNZ   _T3
       MOV   BX, 0
_T4:   POP   AX
       ADD   AL, '0'
       MOV   CS:_TMSG[BX], AL
       INC   BX
       LOOP  _T4
       PUSH  DS
       MOV   CS:_TMSG[BX+0], 0AH
       MOV   CS:_TMSG[BX+1], 0DH
       MOV   CS:_TMSG[BX+2], '$'
       LEA   DX, _TS+2
       PUSH  CS
       POP   DS
       MOV   AH, 9
       INT   21H
       POP   DS
       JMP   _T0
_TS    DW    ?
       DB    'Time elapsed in ms is '
_TMSG  DB    12 DUP(0)
TIMER   ENDP

       CODE ENDS
       END BEGIN



