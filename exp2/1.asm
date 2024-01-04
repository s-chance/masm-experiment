DATA SEGMENT
    msg DB 'Please input a string: $'
    string DB 50, ?, 50 DUP('$')
    newline DB 0DH, 0AH, '$'
    upper DB 'The number of uppercase letters is: $'
    upperNum DW 0
    lower DB 'The number of lowercase letters is: $'
    lowerNum DW 0
    digits DB 'The number of digits is: $'
    digitNum DW 0
    spaces DB 'The number of spaces is: $' 
    spaceNum DW 0
    others DB 'The number of other characters is: $'
    otherNum DW 0
    buffer DB 4 DUP(?), '$'
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
    MOV AX, DATA ; 初始化数据段寄存器
    MOV DS, AX

    MOV DX, OFFSET msg ; 输出提示信息
    MOV AH, 9
    INT 21H

    MOV DX, OFFSET string ; 初始化字符串
    MOV AH, 0AH
    INT 21H
    CALL PRINT_NEWLINE

    MOV BX, OFFSET string + 2 ; 初始化BX为字符串首地址
AGAIN:
    MOV AL, [BX] ; 取出当前字符
    CMP AL, '$' ; 判断是否到字符串结尾
    JZ PRINT ; 到结尾则输出结果
    CMP AL, ' ' ; 判断是否为空格
    JZ SPACE
    CMP AL, 'A' ; 判断是否为大写字母
    JB DIGIT ; 小于A则判断是否为数字
    CMP AL, 'Z'
    JA NEXT ; 大于Z则判断是否为小写字母
    INC upperNum ; 确认为大写字母，计数器加一
    INC BX ; BX指向下一个字符
    JMP AGAIN

DIGIT:
    CMP AL, '0' ; 判断是否为数字
    JB OTHER ; 小于0则判断是否为其他字符
    CMP AL, '9' ; 大于9则判断是否为其它字符
    JA OTHER
    INC digitNum ; 确认为数字，计数器加一
    INC BX
    JMP AGAIN

SPACE:
    INC spaceNum ; 确认为空格，计数器加一
    INC BX
    JMP AGAIN

OTHER:
    INC otherNum ; 确认为其他字符，计数器加一
    INC BX
    JMP AGAIN
    
NEXT:
    CMP AL, 'a' ; 判断是否为小写字母
    JB OTHER ; 小于a则判断是否为其他字符
    CMP AL, 'z'
    JA  OTHER ; 大于z则判断是否为其他字符
    INC lowerNum ; 确认为小写字母，计数器加一
    INC BX
    JMP AGAIN

PRINT:
    MOV DX, OFFSET upper
    MOV AH, 9
    INT 21H
    MOV AX, upperNum ; 输出大写字母字符个数
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE
    
    MOV DX, OFFSET lower
    MOV AH, 9
    INT 21H
    MOV AX, lowerNum ; 输出小写字母字符个数
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE

    MOV DX, OFFSET digits
    MOV AH, 9
    INT 21H
    MOV AX, digitNum ; 输出数字字符个数
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE
    
    MOV DX, OFFSET spaces
    MOV AH, 9
    INT 21H
    MOV AX, spaceNum ; 输出空格字符个数
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE

    MOV DX, OFFSET others
    MOV AH, 9
    INT 21H
    MOV AX, otherNum ; 输出其他字符个数
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE

DONE:
    MOV AH, 4CH
    INT 21H

PRINT_NUMBER PROC
    MOV DI, OFFSET buffer + 4
    MOV BX, 10

DIVIDE_LOOP:
    XOR DX, DX
    DIV BX
    ADD DL, '0'
    DEC DI
    MOV [DI], DL
    TEST AX, AX
    JNZ DIVIDE_LOOP
PRINT_LOOP:
    MOV AH, 2
    MOV DL, [DI]
    INT 21H
    INC DI
    CMP DI, OFFSET buffer + 4
    JNE PRINT_LOOP
    RET
PRINT_NUMBER ENDP

PRINT_NEWLINE PROC
    MOV DX, OFFSET newline
    MOV AH, 9
    INT 21H
    RET
PRINT_NEWLINE ENDP

CODE ENDS
    END START