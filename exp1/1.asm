DATA SEGMENT
    cMsg DB '1.Lowwer to upper', 0DH, 0AH
         DB '2.Upper to lowwer', 0DH, 0AH
         DB '3.Exit', 0DH, 0AH
         DB 'Please input a number: $'
    num DB 2, ?, 2 DUP(?)
    msg DB 'Please input a string: $'
    buffer DB 50, ?, 50 DUP('$')
    res DB 50 DUP('$')
DATA ENDS
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
START:
    ; 设置数据段寄存器
    MOV AX, DATA
    MOV DS, AX
MAIN:
    ; 输出提示信息
    MOV DX, OFFSET cMsg
    MOV AH, 9
    INT 21H
    ; 输入数字
    MOV DX, OFFSET num
    MOV AH, 0AH
    INT 21H
    ; 换行
    CALL NEWLINE
    MOV AL, [num + 2]
    PUSH AX ; 暂存数字
    ; 退出分支判断
    CMP AL, '3'
    JE EXIT
    ; 输出提示信息
    MOV DX, OFFSET msg
    MOV AH, 9
    INT 21H
    ; 输入字符串
    MOV DX, OFFSET buffer
    MOV AH, 0AH
    INT 21H
    CALL NEWLINE
    ; 初始化
    LEA SI, buffer + 2 ; 字符串
    LEA DI, res ; 结果
    MOV CL, [buffer + 1] ; 字符串长度
    POP AX ; 恢复数字
    ; 转换分支判断
    CMP AL, '1'
    JE LOWER_TO_UPPER
    CMP AL, '2'
    JE UPPER_TO_LOWER
; 转换小写为大写
LOWER_TO_UPPER:
    ; 取出字符比较
    MOV AL, [SI]
    CMP AL, 'a'
    JB NEXT
    CMP AL, 'z'
    JA NEXT
    SUB AL, 20H
    MOV [DI], AL
NEXT:
    MOV [DI], AL
    INC SI
    INC DI
    LOOP LOWER_TO_UPPER
    JMP OUTPUT
; 转换大写为小写
UPPER_TO_LOWER:
    ; 取出字符比较
    MOV AL, [SI]
    CMP AL, 'A'
    JB NEXT2
    CMP AL, 'Z'
    JA NEXT2
    ADD AL, 20H
    MOV [DI], AL
NEXT2:
    MOV [DI], AL
    INC SI
    INC DI
    LOOP UPPER_TO_LOWER
    JMP OUTPUT
; 输出结果
OUTPUT:
    MOV AL, '$'
    MOV [DI], AL
    LEA DX, res
    MOV AH, 9
    INT 21H
    CALL NEWLINE
    JMP MAIN
; 换行
NEWLINE PROC
    MOV DL, 0DH
    MOV AH, 2
    INT 21H
    MOV DL, 0AH
    INT 21H
    RET
NEWLINE ENDP
; 退出
EXIT:
    MOV AH, 4CH
    INT 21H
CODE ENDS
    END START