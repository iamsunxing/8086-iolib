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
;========================
;函数名：SORT 冒泡排序
;功能描述：冒泡排序,排序后覆盖原有数据
;相关宏定义
;_TMP为AX时是字排序，是AL时是字节排序
;JSE为JBE时从小到大排序，为JAE时从大到小排序
;输入参数： SI 排序数据的首地址
;			CX 排序数据的个数
;输出参数： 无
;例如:
;	LEA SI,CHA
;	MOV CX,5
;	CALL SORT
;========================
SORT PROC NEAR
	_TMP EQU AX
	MOV BX,2 ;AX与2配合使用字排序，AL与1配合使用字节排序
	_JSE EQU JBE ; 为JBE 从小到大排序 JAE从大到小排序
	PUSH AX
	DEC CX
_OUTLOOP:
	PUSH CX			;保护数据
	PUSH SI

_LABEL1:				;内层循环
	MOV _TMP,[SI]
	CMP _TMP,[SI+BX]
	_JSE _LABEL2
	XCHG _TMP,[SI+BX]
	MOV [SI],_TMP
_LABEL2:
	ADD SI,BX
	LOOP _LABEL1		;内层循环结束

	POP SI			;恢复数据
	POP CX
	LOOP _OUTLOOP
	POP AX
	RET
SORT ENDP


;======================
;函数名字： RGB
;用例：
;	MOV CH,ARR
;	MOV CL,COLORFMT
;	MOV BX,BEGINCHAR
;	MOV AX,NUM
;	CALl RGB
;从第ARR行的第BEGINCHAR个字符开始涂NUM个字符
;其颜色格式为COLORFMT
;COLORFMT 设置如下:
;   7 	6  5  4	 3	2  1  0
;   BL  R  G  B  I  R  G  B
; 闪烁   背景   高亮  前景
;=======================
RGB PROC
	PUSH SI
	PUSH ES
	PUSH AX
	MOV AL,CL
	PUSH AX
	DEC CH
	DEC BX
	MOV AL,0A0H
	MUL CH
	MOV SI,AX
	SHL BX,1
	MOV CX,BX
	ADD SI,CX
	INC SI
	MOV CX,0B800H
    MOV ES,CX
	POP AX
    POP CX
_SF:MOV BYTE PTR ES:[SI],AL
    INC SI
	INC SI
    LOOP _SF
	POP ES
	POP SI
	RET
RGB ENDP
;========================
;函数名：PRINTB
;功能描述： 从一个地址SI开始打印CX个BYTE
;输入参数： SI 开始打印的首地址
;			CX 打印的字节个数
;输出参数： 无
;例如：
;	LEA SI,ARG
;	MOV CX,COUNT
;	CALL PRINTB
;=========================
PRINTB PROC
_LOOP4:
	PUSH DS:[SI]
	MOV AL,0
	MOV [SI+1],AL
	CALL PRINTW
	POP [SI]
	INC SI
	LOOP _LOOP4
	LEA DX,CLRF
	MOV AH,9
	INT 21H
	RET
PRINTB ENDP

;========================
;函数名：  PRINTMW
;功能描述：调用函数PRINTW打印多个字数据
;输入参数：SI 见函数PRINTW
;		   _NUM 见函数PRINTW
;		   CX 打印字数据的个数
;例如：
;	LEA SI,CHA
;	MOV CX,5
;	CALL PRINTMW
;=======================
PRINTMW PROC
PUSH SI
_LOOP3:
	CALL PRINTW
	INC SI
	INC SI
	LOOP _LOOP3
	POP SI
	LEA DX,CLRF		;打印回车换行
	MOV AH,9
	INT 21H
	RET
PRINTMW ENDP
;========================
;函数名：	PRINTW
;功能描述： 打印一个字数据到屏幕上
;输入参数： SI 数据的首地址
;			_NUM 不少于7个字节大小的缓冲区的首地址
;输出参数： 无
;例如：
;	LEA SI,CHA
;	CALL PRINTW
;=======================
PRINTW PROC
	_NUM EQU CHARS 	;CHARS 是缓冲区

	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH SI
	MOV AX,DS:[SI]  ;除数
	SUB CX,CX		;用来计数有几位，弹栈时用到
	MOV BX,10   	;被除数

_AG:MOV DX,0
	DIV BX
	MOV DH,DL
	PUSH DX
	INC CX
	CMP AX,0
	JE _NEXT   		;等于0的话跳出来
	JMP _AG
_NEXT:
	MOV SI,0
_LOOP1:
	POP BX			;转化为字符
	ADD BH,'0'
	MOV _NUM[SI],BH
	INC SI
	LOOP _LOOP1

	ADD SI,OFFSET _NUM		;打印整数
	MOV BYTE PTR [SI],' '
	MOV BYTE PTR [SI+1],'$'
	LEA DX,_NUM	;打印输出
	MOV AH,9
	INT 21H

	POP SI
	POP DX
	POP CX
	POP BX
	POP AX
	RET
PRINTW ENDP
;=======================
;函数名：	SCANMW
;功能描述：从起始地址_WORD开始存放键盘输入的字数据
;还需要输入缓冲区，三段式定义，
;BUFSIZE DB 100
;CNT DB 0
;CHARS DB 128 DUP(0)
;该函数影响所有标志位
;
;输入参数：SI  数据存放首地址
;		   CX   1为字节数据，2为字数据
;返回参数: DI  字数据个数
;		   CNT 输入的字符个数
;例如：
;	LEA SI,ARG
;	MOV CX,2
;	CALL SCANMW
;=======================
SCANMW PROC
	PUSH AX
	PUSH BX
	PUSH DX

	PUSH CX
	PUSH SI
	MOV DX,OFFSET BUFSIZE   ;输入字符串
	MOV AH,0AH
	INT 21H

	MOV CL,CNT
	MOV CH,0
	SUB DI,DI
	MOV SI,0
	MOV BP,0
_AG2:LEA BX,CHARS
	MOV AL,DS:[BX+SI]
	INC SI		;指向下一个字符

	CMP AL,' '
	JNZ _AG0
	CMP BP,0
	JNZ _POPH
	JMP _AG2
_AG0:
	INC BP 		;计算数字位数
	MOV AH,0
	PUSH AX
	MOV AX,SI
	CMP AL,CNT
	JZ _POPH		;到达字符串结尾跳出

	JMP _AG2
_POPH:  ;下面开始弹栈
	MOV DX,0
	MOV CX,BP	;数字位数就是弹栈的次数
	MOV BP,SI   ;保护SI的值
	MOV SI,0
_AG3:
	POP AX
	SUB AL,'0'

	PUSH CX
	CMP SI,0
	JZ _AG5
	MOV BX,10 	;底数10
	MOV CX,SI 	;幂
	PUSH DX		;保护DX
_AG1:
	MUL BX
	LOOP _AG1
	POP DX     	;恢复DX
_AG5:ADD DX, AX
	POP CX

	INC SI
	LOOP _AG3

	MOV SI,BP 	;恢复SI的值
	MOV BP,0	; BP清零
	POP BX
	POP AX
	CMP AL,1
	JZ _FAL1
	MOV [BX],DX ;存放结果
	JMP _FAL2
_FAL1:
	MOV [BX],DL ;存放结果
_FAL2:
	INC DI
	ADD BX,AX
	PUSH AX
	PUSH BX
	MOV AX,SI
	CMP AL,CNT
	JNZ _AG2
	POP SI
	POP CX
	POP DX
	POP BX
	POP AX
	RET
SCANMW ENDP