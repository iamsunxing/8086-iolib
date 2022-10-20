;=================================
;注：
;库的用法请参考下的格式：
; 定义输入输出缓冲区，不能修改
; 包含进来相应的文件共两个地方
; 函数用法请参考其他两个源文件中的说明
;==============================
;		汇编输入输出练习
;PMG 		;打印从地址ARG开始的一串字符直到$
;PRINTWS 	;打印若干个字数据
;PRINTBS	;打印若干个字节数据
;SCANWS		;输入若干个字数据(最后带有回车)
;SCANBS		;输入若干个字节数据(最后带有回车)
;PRGB		;涂色
;SORT	 	;冒泡排序
;作者：孙兴
;时间：2015-10-12
;修改时间：2015-10-14
;修改时间：2015-10-22
;================================
DATA SEGMENT
	BUFSIZE DB 200
	CNT DB 0
	CHARS DB 200 DUP(0) ;输入输出共用此缓冲区，大小200字节
	CLRF DB 0DH, 0AH ,'$' ;换行回车
	EVEN
	INCLUDE MACRO.ASM  ;注意这里包含进来相关的宏函数
;====================================
;以上内容是输入输出缓冲区，请勿修改！！！
;====================================
;			自定义数据段开始
;=====================================
	MEG1 DB 'PLEASE TYPE:',0DH, 0AH,'$'
	MEG2 DB 'BEFOR SORT:' ,0DH, 0AH,'$'
	MEG3 DB 'AFTER SORT:' ,0DH, 0AH,'$'
	MEG4 DB 'TOTAL: ','$'
	CHA DW 100 DUP(0)
;=====================================
;			自定义数据段结束
;=====================================
DATA ENDS
STACK SEGMENT PARA STACK 'STACK'
	DW 100 DUP(0)
STACK ENDS
CODE SEGMENT
    ASSUME  CS:CODE,DS:DATA,SS:STACK
START:
	MOV AX,DATA
    MOV DS,AX
;=====================================
;			MAIN主程序开始
;=====================================
;测试用例：
;功能描述：输入若干个无符号字数据，以1个或多个空格隔开
;排序后输出，并打印输入的字数据个数
;=====================================
	CLS				;清屏
	PRGB 1,1,80*25, 01101111B  ;涂颜色
	PMG MEG1  		;打印输入提示信息

	SCANWS CHA		;输入若干字数据于CHA中，
					;并返回字数据个数存放于DI寄存器中
					;输入的字符个数存放于CNT中
	PMG MEG2
	PRINTWS CHA,DI  ;打印输入的字数据

	PUSH SI
	PUSH CX
	LEA SI,CHA
	MOV CX,DI
	CALL SORT  		;冒泡排序
	POP CX
	POP SI

	PMG MEG3
	PRINTWS CHA,DI 	;打印排序结果

	PMG MEG4
	;-----------------------
	;   打印寄存器DI的值
	;----------------------
	PUSH CHA 	;压栈保护
	MOV CHA,DI
	PRINTBS CHA,1
	POP CHA		;恢复数据

	MOV AL,CNT
	MOV AH,0
	PRGB 6,1,AX,    00001110B   ;涂颜色
	PRGB 7,8,2,     10001110B   ;涂颜色
;=====================================
;			MAIN主程序结束
;=====================================
    MOV AH,4CH		; 返回DOS
    INT 21H
	INCLUDE IOLIB.ASM          ;注意这里要包含进来iolib.asm
CODE ENDS
	END START ;指明代码段首行程序
