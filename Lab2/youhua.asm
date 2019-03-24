.386
DATA SEGMENT USE16
pname   DB   'Please input your name:$'
CESHI  DB 'HELLO' 
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
BBOOK  DB  'BOOK',0
BNAME  DB  'yexiangyu',0 
BPASS  DB  '1234',0,0,0
N      EQU   15
S1     DB  'SHOP1',0 
GA1    DB    'PEN', 7 DUP(0) 
       DW   35,56,1,0,?      ;进货价/销售价/进货数/已售数/利率
GA2    DB    'BOOK', 6 DUP(0)
       DW   12,30,25,5,?  
GAN    DB   N-2 DUP( 'Temp-Value',15,0,20,0,30H,75H,0,0,?,?) 
S2     DB  'SHOP2',0          
GB1    DB    'BOOK', 6 DUP(0) 
       DW   12,28,20,15,?   
GB2    DB    'PEN', 7 DUP(0)  
       DW   35,50,30,24,?  
GBN    DB   N-2 DUP( 'Temp-Value',15,0,20,0,30H,75H,0,0,?,?) 
DATA   ENDS
STACK  SEGMENT USE16 STACK
       DB 200 DUP(0)
STACK  ENDS
CODE   SEGMENT USE16
       ASSUME CS:CODE,DS:DATA,SS:STACK
	   
	   
	   PRINT MACRO A
 		    LEA DX,A
		    MOV AH,9
		    INT 21H
		 ENDM
		 
		 
		SINGLE PROC NEAR 
			MOV EAX,0
            MOV AX,16[SI]
            MOV EBX,0
            MOV BX,12[SI]
            IMUL EAX,EBX
            MOV EBX,0
            MOV EDX,0
            MOV BX,14[SI]
            MOV DX,10[SI]
            IMUL EBX,EDX
            SUB EAX,EBX
            IMUL EAX,100
		    RET
	     SINGLE ENDP
		 
BEGIN: MOV AX,DATA
       MOV DS,AX
       MOV ES,AX
LOG:   MOV AX,1
       CALL TIMER
       LEA DX,pname        ;提示输入姓名
       MOV AH,09H
       INT 21H
       LEA DX,in_name      ;输入姓名
       MOV AH,10
       INT 21H
       LEA DX,0AH          ;输出换行
       MOV AH,02H
       INT 21H
       CMP in_name+2,0DH   ;最低字节回车进入normal模式
       JZ  NORMAL
       CMP in_name+2,'q'   ;输入q退出
       JZ  EXIT
       MOV BL,in_name+1    ;判断姓名是否正确
       CMP BL,9 
       JNZ FAIL_LOG              ;姓名长度错误跳到（3）
       PUSH SI
       PUSH DI
       PUSH CX
       LEA SI,in_name+2
       LEA DI,BNAME
       MOV CX,9
       REPZ CMPSB
       POP CX
       POP DI
       POP SI
       JNE FAIL_LOG              ;姓名内容错误跳到（3）
       LEA DX,pass         ;密码
       MOV AH,9
       INT 21H
       LEA DX,in_pass      ;输入密码
       MOV AH,10
       INT 21H
       LEA DX,0AH          ;换行
       MOV AH,2
       INT 21H
       MOV BL,in_pass+1    ;判断密码是否正确
       CMP BL,4
       JNZ FAIL_LOG
       PUSH SI              ;保护现场--入栈
       PUSH DI
       PUSH CX
       LEA SI,in_pass+2     ;设置DS偏移地址
       LEA DI,BPASS         ;设置ES偏移地址
       MOV CX,4
       REPZ CMPSB
       POP CX               ;保护现场--退栈
       POP DI
       POP SI
       JNZ FAIL_LOG              ;密码错误跳到（3)
       JMP BOSS              ;密码正确进到功能三
NORMAL:MOV AUTH,0H          ;客户
       JMP BOSS2
FAIL_LOG:    LEA DX,failure      ;（3)登陆失败提示
       MOV AH,09H
       INT 21H
       LEA DX,0AH          ;换行
       MOV AH,02H
       INT 21H
       JMP LOG              ;回到（1)
BOSS:  MOV AUTH,1          ;BOSS模式
       JMP BOSS2
BOSS2: LEA DX,goods        ;显示提示输入商品名
       MOV AH,09H
       INT 21H
       LEA DX,in_goods     ;输入商品名
       MOV AH,10
       INT 21H
       LEA DX,0AH          ;显示换行
       MOV AH,02H
       INT 21H
       CMP in_goods+2,0DH  ;判断回车
       JZ  LOG              ;回到（1)
       MOV BL,in_goods+1   ;判断是不是笔
       CMP BL,3
       JNZ JUDGE_BOOK
       PUSH SI
       PUSH DI
       PUSH CX
       LEA SI,in_goods+2
       LEA DI,GA1
       MOV CX,3
       REPZ CMPSB
       POP CX
       POP DI
       POP SI
       JZ JUDGE_MOD
JUDGE_BOOK:   
	   MOV BL,in_goods+1   ;判断是不是书
       CMP BL,4
       JNZ BOSS2
       PUSH SI
       PUSH DI
       PUSH CX
       LEA SI,in_goods+2
       LEA DI,GA2
       MOV CX,4
       REPZ CMPSB
       POP CX
       POP DI
       POP SI
       JNZ BOSS2              ;未找到商品，重新提示
       MOV KIND,1          ;书1笔0
JUDGE_MOD:   CMP AUTH,1          ;判断登陆状态
       JZ  BOSS3              ;老板
       JMP NORMAL2              ;客户
BOSS3: CMP KIND,1           ;判断是书是笔
       JZ  IS_BOOK
	   MOV AX,0
	   CALL TIMER   
	   ;新代码
NEW:   
       PUSH SI
	   PUSH AX
	   MOV SI,OFFSET GAN
	   MOV AX,14[SI]  ;进货数
	   CMP AX,16[SI]  ;进货数\已售数
	   JLE LOG 
	   MOV AX,16[SI]
	   INC AX
	   MOV 16[SI],AX
	   POP AX
	   POP SI
	   ;新代码
	   
	   
       PUSH SI
	   PUSH DI
       LEA SI,GAN          ;计算A店所有商品的利润率
	   LEA DI,GBN
	   
	   PUSH CX
	   MOV CX,N-2
APRA:  CALL SINGLE 
       CMP EAX,0
       JL CASE4
       MOV EDX,0
       JMP RE4
CASE4: MOV EDX,0FFFFFFFFH
RE4:   IDIV EBX
       MOV 18[SI],AX       
	   PUSH SI
       MOV SI,DI	   
       CALL SINGLE
	   POP SI
       CMP EAX,0
       JL CASE3
       MOV EDX,0
       JMP RE3
CASE3: MOV EDX,0FFFFFFFFH
RE3:   IDIV EBX
       MOV 18[DI],AX      ;保存B店笔利率
                    ;计算平均利润率
       MOV AX,18[DI]
       ADD AX,18[SI]
       CMP AX,0
       JL  CASE5
       MOV DX,0
       JMP RE5
CASE5: MOV DX,0FFFFH
RE5:   MOV BX,2
       IDIV BX
       MOV APR,AX
       ADD SI,20
	   ADD DI,20
	   DEC CX
	   CMP CX,0
	   JNE APRA
	   POP CX
	   POP DI
	   POP SI
	   
	   JMP NEW        ;新代码
	   
	   
       JMP L9    
IS_BOOK:   
	   PUSH BX
       LEA BX,GA2          ;计算A店书的利润率
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
CASE2: MOV EDX,0FFFFFFFFH   ;拓展为32位有符号数
RE2:   IDIV ECX
       MOV 18[BX],AX      
       PUSH BX
       LEA BX,GB1          ;计算B店书的利润率
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
       JMP L9
NORMAL2:    MOV BL,in_goods+1   ;3.4 输出商品名 
       MOV BH,0
       MOV BYTE PTR in_goods+2[BX],'$'
       LEA DX,in_goods+2      
       MOV AH,9
       INT 21H
       LEA DX,0AH         ;换行
       MOV AH,2
       INT 21H  
       JMP LOG              ;回到（1）
L9:                        ;4,进行等级判断
       MOV AX,APR
       CMP AX,90
       JL  L13
       MOV DL,41H
       MOV AH,2
       INT 21H
       LEA DX,0AH         ;换行
       MOV AH,2
       INT 21H 
       JMP LOG
L13:   CMP AX,50
       JL  L14
       MOV DL,42H
       MOV AH,2
       INT 21H
       LEA DX,0AH         ;换行
       MOV AH,2
       INT 21H 
       JMP LOG
L14:   CMP AX,20
       JL  L15
       MOV DL,43H
       MOV AH,2
       INT 21H
       LEA DX,0AH         ;换行
       MOV AH,2
       INT 21H 
       JMP LOG 
L15:   CMP AX,0
       JL  L16
       MOV DL,44H
       MOV AH,2
       INT 21H
       LEA DX,0AH         ;换行
       MOV AH,2
       INT 21H 
       JMP LOG 
L16:   MOV DL,46H
       MOV AH,2
       INT 21H
       LEA DX,0AH         ;换行
       MOV AH,2
       INT 21H 
       JMP LOG     
EXIT:    MOV AH,4CH
       INT 21H
	   
;时间计数器(ms),在屏幕上显示程序的执行时间(ms)
;使用方法:
;	   MOV  AX, 0	;表示开始计时
;	   CALL TIMER
;	   ... ...	;需要计时的程序
;	   MOV  AX, 1	
;	   CALL TIMER	;终止计时并显示计时结果(ms)
;输出: 改变了AX和状态寄存器
TIMER	PROC
	PUSH  DX
	PUSH  CX
	PUSH  BX
	MOV   BX, AX
	MOV   AH, 2CH
	INT   21H	     ;CH=hour(0-23),CL=minute(0-59),DH=second(0-59),DL=centisecond(0-100)
	MOV   AL, DH
	MOV   AH, 0
	IMUL  AX,AX,1000
	MOV   DH, 0
	IMUL  DX,DX,10
	ADD   AX, DX
	CMP   BX, 0
	JNZ   _T1
	MOV   CS:_TS, AX
_T0:	POP   BX
	POP   CX
	POP   DX
	RET
_T1:	SUB   AX, CS:_TS
	JNC   _T2
	ADD   AX, 60000
_T2:	MOV   CX, 0
	MOV   BX, 10
_T3:	MOV   DX, 0
	DIV   BX
	PUSH  DX
	INC   CX
	CMP   AX, 0
	JNZ   _T3
	MOV   BX, 0
_T4:	POP   AX
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
_TS	DW    ?
 	DB    'Time elapsed in ms is '
_TMSG	DB    12 DUP(0)
TIMER   ENDP

       CODE ENDS
       END BEGIN