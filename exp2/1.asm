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
    MOV AL, [BX]
    CMP AL, '$'
    JZ PRINT
    CMP AL, ' '
    JZ SPACE
    CMP AL, 'A'
    JB DIGIT
    CMP AL, 'Z'
    JA NEXT
    INC upperNum
    INC BX
    JMP AGAIN

DIGIT:
    CMP AL, '0'
    JB OTHER
    CMP AL, '9'
    JA OTHER
    INC digitNum
    INC BX
    JMP AGAIN

SPACE:
    INC spaceNum
    INC BX
    JMP AGAIN

OTHER:
    INC otherNum
    INC BX
    JMP AGAIN
    
NEXT:
    CMP AL, 'a'
    JB OTHER
    CMP AL, 'z'
    JA  OTHER
    INC lowerNum
    INC BX
    JMP AGAIN

PRINT:
    MOV DX, OFFSET upper
    MOV AH, 9
    INT 21H
    MOV AX, upperNum
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE
    
    MOV DX, OFFSET lower
    MOV AH, 9
    INT 21H
    MOV AX, lowerNum
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE

    MOV DX, OFFSET digits
    MOV AH, 9
    INT 21H
    MOV AX, digitNum
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE
    
    MOV DX, OFFSET spaces
    MOV AH, 9
    INT 21H
    MOV AX, spaceNum
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE

    MOV DX, OFFSET others
    MOV AH, 9
    INT 21H
    MOV AX, otherNum
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE

DONE:
    MOV AH, 4CH
    INT 21H

PRINT_NUMBER PROC
    MOV DI, OFFSET buffer + 3
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