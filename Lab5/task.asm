.386
.model   flat,stdcall
option   casemap:none

WinMain  proto :DWORD,:DWORD,:DWORD,:DWORD
WndProc  proto :DWORD,:DWORD,:DWORD,:DWORD
Display  proto :DWORD
Average  proto :DWORD

include      menuID.INC

include      windows.inc
include      user32.inc
include      kernel32.inc
include      gdi32.inc
include      shell32.inc

includelib   user32.lib
includelib   kernel32.lib
includelib   gdi32.lib
includelib   shell32.lib

good	struct
		good_name   db  10 dup(0)
		bought_price  dw  0
		sell_price    dw  0
		bought_num  dw  0
		sell_num  dw  0
		profit    dw  0
good    ends

N equ 5

.data
ClassName    db       'TryWinClass',0
AppName      db       'Our First Window',0
MenuName     db       'MyMenu',0
DlgName	     db       'MyDialog',0
AboutMsg     db       'Ye Xiangyu',0
hInstance    dd       0
CommandLine  dd       0
buf	    good <'PEN       ',35,56,70,25, ' '>
		good <'BOOK      ',12,30,25,20, ' '>
		good <'BOTTLE    ',30,45,64,44, ' '>
		good <'SCISSORS  ',12,20,80,59, ' '>
		good <'DRINKS    ',2,3,100,58, ' '>
shop2	good <'PEN       ',35,50,70,60, ' '>
		good <'BOOK      ',12,20,25,22, ' '>
		good <'BOTTLE    ',30,40,64,54, ' '>
		good <'SCISSORS  ',12,24,80,50, ' '>
		good <'DRINKS    ',2,3,200,120, ' '>

numberbuf	db		100 dup(0)
msg_name	db		'name',0
msg_bought_price  db       'bought_price',0
msg_sell_price    db       'sell_price',0
msg_bought_num    db       'bought_num',0
msg_sell_num      db       'sell_num',0
msg_profit   	  db       'profit',0

bought_price	db 	'35','12','30','12','2'
sell_price	    db  '56','30','45','20','3'
bought_num	    db  '70','25','64','80','100'
sell_num	    db  '25','20','44','59','58'
profit 			db	' 00%',' 00%',' 00%',' 00%',' 00%'	

.code
Start:	     invoke GetModuleHandle,NULL
	     mov    hInstance,eax
	     invoke GetCommandLine
	     mov    CommandLine,eax
	     invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	     invoke ExitProcess,eax
	     ;;
WinMain      proc   hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
			LOCAL  wc:WNDCLASSEX
			LOCAL  msg:MSG
			LOCAL  hWnd:HWND
			invoke RtlZeroMemory,addr wc,sizeof wc
			mov    wc.cbSize,SIZEOF WNDCLASSEX
			mov    wc.style, CS_HREDRAW or CS_VREDRAW
			mov    wc.lpfnWndProc, offset WndProc
			mov    wc.cbClsExtra,NULL
			mov    wc.cbWndExtra,NULL
			push   hInst
			pop    wc.hInstance
			mov    wc.hbrBackground,COLOR_WINDOW+1
			mov    wc.lpszMenuName, offset MenuName
			mov    wc.lpszClassName,offset ClassName
			invoke LoadIcon,NULL,IDI_APPLICATION
			mov    wc.hIcon,eax
			mov    wc.hIconSm,0
			invoke LoadCursor,NULL,IDC_ARROW
			mov    wc.hCursor,eax
			invoke RegisterClassEx, addr wc
			INVOKE CreateWindowEx,NULL,addr ClassName,addr AppName,\
			        WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
			        CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
			        hInst,NULL
			mov    hWnd,eax
			INVOKE ShowWindow,hWnd,SW_SHOWNORMAL
			INVOKE UpdateWindow,hWnd
			;;
			MsgLoop: 
			    INVOKE GetMessage,addr msg,NULL,0,0
				cmp    EAX,0
				je     ExitLoop
				INVOKE TranslateMessage,addr msg
				INVOKE DispatchMessage,addr msg
				jmp    MsgLoop 
			ExitLoop:
			    mov    eax,msg.wParam
	     ret
WinMain      endp

WndProc      proc   hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
		LOCAL  hdc:HDC
		.IF     uMsg == WM_DESTROY
			invoke PostQuitMessage,NULL
		.ELSEIF uMsg == WM_KEYDOWN
		.IF     wParam == VK_F1
			invoke MessageBox,hWnd,addr AboutMsg,addr AppName,0
	    .ENDIF
		.ELSEIF uMsg == WM_COMMAND
	    .IF     wParam == IDM_FILE_EXIT
		    invoke SendMessage,hWnd,WM_CLOSE,0,0
	    .ELSEIF wParam == IDM_ACT_LIST	;here remains to be fixed as menu.rc
		    invoke Display, hWnd
		.ELSEIF wParam == IDM_ACT_AVERAGE
        	invoke Average, hWnd
	    .ELSEIF wParam == IDM_HELP_ABOUT	
		    invoke MessageBox,hWnd,addr AboutMsg,addr AppName,0
	    .ENDIF
		;the fellow line of code was edited to stop windows from repainting
		;.ELSEIF uMsg == WM_PAINT
		;;redraw window again
     	.ELSE
			invoke DefWindowProc,hWnd,uMsg,wParam,lParam
			ret
     	.ENDIF
		xor    eax,eax
		ret
WndProc      endp

Display     proc   hWnd:DWORD
		XX     equ  10
		YY     equ  10
		XX_GAP equ  150
		YY_GAP equ  30

		LOCAL  hdc:HDC
		invoke GetDC,hWnd
		mov    hdc,eax

		invoke TextOut,hdc,XX+0*XX_GAP,YY+0*YY_GAP,offset msg_name,4
		invoke TextOut,hdc,XX+1*XX_GAP,YY+0*YY_GAP,offset msg_bought_price,12
		invoke TextOut,hdc,XX+2*XX_GAP,YY+0*YY_GAP,offset msg_sell_price,10
		invoke TextOut,hdc,XX+3*XX_GAP,YY+0*YY_GAP,offset msg_bought_num,10
		invoke TextOut,hdc,XX+4*XX_GAP,YY+0*YY_GAP,offset msg_sell_num,8
		invoke TextOut,hdc,XX+5*XX_GAP,YY+0*YY_GAP,offset msg_profit,6
				
		mov ebx,offset buf

		invoke TextOut,hdc,XX+0*XX_GAP,YY+1*YY_GAP,offset buf.good_name,10	
		invoke TextOut,hdc,XX+1*XX_GAP,YY+1*YY_GAP,offset bought_price,2
		invoke TextOut,hdc,XX+2*XX_GAP,YY+1*YY_GAP,offset sell_price,2
		invoke TextOut,hdc,XX+3*XX_GAP,YY+1*YY_GAP,offset bought_num,2
		invoke TextOut,hdc,XX+4*XX_GAP,YY+1*YY_GAP,offset sell_num,2
		invoke TextOut,hdc,XX+5*XX_GAP,YY+1*YY_GAP,offset profit,4

		invoke TextOut,hdc,XX+0*XX_GAP,YY+2*YY_GAP,offset buf[1*20].good_name,10	
		invoke TextOut,hdc,XX+1*XX_GAP,YY+2*YY_GAP,offset bought_price+2,2
		invoke TextOut,hdc,XX+2*XX_GAP,YY+2*YY_GAP,offset sell_price+2,2
		invoke TextOut,hdc,XX+3*XX_GAP,YY+2*YY_GAP,offset bought_num+2,2
		invoke TextOut,hdc,XX+4*XX_GAP,YY+2*YY_GAP,offset sell_num+2,2
		invoke TextOut,hdc,XX+5*XX_GAP,YY+2*YY_GAP,offset profit+4,4

		invoke TextOut,hdc,XX+0*XX_GAP,YY+3*YY_GAP,offset buf[2*20].good_name,10	
		invoke TextOut,hdc,XX+1*XX_GAP,YY+3*YY_GAP,offset bought_price+4,2
		invoke TextOut,hdc,XX+2*XX_GAP,YY+3*YY_GAP,offset sell_price+4,2
		invoke TextOut,hdc,XX+3*XX_GAP,YY+3*YY_GAP,offset bought_num+4,2
		invoke TextOut,hdc,XX+4*XX_GAP,YY+3*YY_GAP,offset sell_num+4,2
		invoke TextOut,hdc,XX+5*XX_GAP,YY+3*YY_GAP,offset profit+8,4

		invoke TextOut,hdc,XX+0*XX_GAP,YY+4*YY_GAP,offset buf[3*20].good_name,10	
		invoke TextOut,hdc,XX+1*XX_GAP,YY+4*YY_GAP,offset bought_price+6,2
		invoke TextOut,hdc,XX+2*XX_GAP,YY+4*YY_GAP,offset sell_price+6,2
		invoke TextOut,hdc,XX+3*XX_GAP,YY+4*YY_GAP,offset bought_num+6,2
		invoke TextOut,hdc,XX+4*XX_GAP,YY+4*YY_GAP,offset sell_num+6,2
		invoke TextOut,hdc,XX+5*XX_GAP,YY+4*YY_GAP,offset profit+12,4

		invoke TextOut,hdc,XX+0*XX_GAP,YY+5*YY_GAP,offset buf[4*20].good_name,10	
		invoke TextOut,hdc,XX+1*XX_GAP,YY+5*YY_GAP,offset bought_price+8,1
		invoke TextOut,hdc,XX+2*XX_GAP,YY+5*YY_GAP,offset sell_price+8,1
		invoke TextOut,hdc,XX+3*XX_GAP,YY+5*YY_GAP,offset bought_num+8,3
		invoke TextOut,hdc,XX+4*XX_GAP,YY+5*YY_GAP,offset sell_num+8,2
		invoke TextOut,hdc,XX+5*XX_GAP,YY+5*YY_GAP,offset profit+16,4

		ret
Display     endp

Average 	proc   hWnd:DWORD
		PUSH EAX
		PUSH EBX
		PUSH ECX
		PUSH EDX
		PUSH EDI
		PUSH ESI

		;LOCAL  hdc:HDC
		;invoke GetDC,hWnd
		;mov    hdc,eax
		;invoke TextOut,hdc,10,10,offset msg_name,4

		mov ecx, N
		mov ebx, offset buf
		mov esi, offset profit

		loop_calculate:
			push ecx
					push esi
							;实现功能 将利润率保存到数据段中
							MOVSX EAX, (good PTR [EBX]).sell_price
							MOVSX ESI, (good PTR [EBX]).sell_num
							IMUL EAX, ESI
							
							MOVSX ECX, (good PTR [EBX]).bought_price
							MOVSX EDX, (good PTR [EBX]).bought_num
							IMUL ECX, EDX
							
							SUB EAX, ECX	;销售价*已售数量-进货价*进货总数
							IMUL EAX, 100
							CDQ
							IDIV ECX
							MOV (good PTR [EBX]).profit, AX	;获得shop1的利润率
							
							add ebx, N*20

							MOVSX EAX, (good PTR [EBX]).sell_price
							MOVSX ESI, (good PTR [EBX]).sell_num
							IMUL EAX, ESI
							
							MOVSX ECX, (good PTR [EBX]).bought_price
							MOVSX EDX, (good PTR [EBX]).bought_num
							IMUL ECX, EDX
							
							SUB EAX, ECX	;销售价*已售数量-进货价*进货总数
							IMUL EAX, 100
							CDQ
							IDIV ECX
							MOV (good PTR [EBX]).profit, AX	;获得shop2的利润率

					pop esi
					sub ebx, N*20
					movsx edi, (good PTR [EBX]).profit
					add eax, edi
					sar eax, 1
					jns  greater_than_0
				low_than_0:
					mov byte ptr [esi], '-'
					not eax
					inc eax
				greater_than_0:			
					cdq
					mov edi, 10d
					idiv edi
					ADD AL,30H
					ADD DL,30H
					MOV BYTE PTR 2[esi],AL
					MOV BYTE PTR 1[esi],DL

					add ebx, 20
					add esi, 4
			pop ecx
			dec ecx
			cmp ecx, 0
			jne loop_calculate

		POP ESI
		POP EDI
		POP EDX
		POP ECX
		POP EBX
		POP EAX
		ret
Average 	endp
end  Start