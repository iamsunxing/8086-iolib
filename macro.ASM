;==============================
;		汇编输入输出练习
;PMG 		;打印从地址ARG开始的一串字符直到$
;PRINTWS 	;打印若干个字数据
;PRINTBS	;打印若干个字节数据
;SCANWS		;输入若干个字数据(最后带有回车)
;SCANBS		;输入若干个字节数据(最后带有回车)
;PRGB		;涂色
;作者：孙兴
;时间：2015-10-12
;修改时间：2015-10-14
;修改时间：2015-10-22
;================================
;----------------
;	宏函数
;----------------
PMG MACRO ARG			;打印从地址ARG开始的一串字符直到$
	PUSH DX
	LEA DX,ARG
	MOV AH,9
	INT 21H
	POP DX
ENDM
PRINTWS MACRO ARG,COUNT		;从arg开始打印count个字数据
	PUSH SI
	PUSH CX
	LEA SI,ARG
	MOV CX,COUNT
	CALL PRINTMW
	POP CX
	POP	SI
ENDM
PRINTBS MACRO ARG,COUNT 	;ARG是首地址,输出COUNT个BYTE
    PUSH SI
	PUSH CX
	LEA SI,ARG
	MOV CX,COUNT
	CALL PRINTB
	POP CX
	POP	SI
ENDM
SCANWS MACRO ARG     ;从arg地址开始存放键盘输入的字数据
	PUSH SI
	PUSH CX
	LEA SI,ARG
	MOV CX,2
	CALL SCANMW
	PMG CLRF
	POP CX
	POP	SI
ENDM
SCANBS MACRO ARG     ;从arg地址开始存放键盘输入的字节数据
	PUSH SI
	PUSH CX
	LEA SI,ARG
	MOV CX,1
	CALL SCANMW
	PMG CLRF
	POP CX
	POP	SI
ENDM
CLS MACRO			;清屏
	PUSH AX
	MOV AX,3
	INT 10H
	POP AX
ENDM
PRGB MACRO 	ARR,BEGINCHAR,NUM,COLORFMT	;从第ARR行的第BEGINCHAR个字符开始对NUM个字符涂色
;COLORFMT对颜色进行配置
	PUSH AX
	PUSH BX
	PUSH CX
	MOV CH,ARR
	MOV CL,COLORFMT
	MOV BX,BEGINCHAR
	MOV AX,NUM
	CALl RGB
	POP CX
	POP BX
	POP AX
ENDM