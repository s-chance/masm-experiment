DATA SEGMENT
    counter DW 0  ; 计数器
    printCounter DB 0 ; 行计数器
    newline DB 13, 10, '$' ; 换行符
    comma DB ', ', '$' ; 逗号
    buffer DB 4 DUP(?), '$' ; 用于存储数字的字符串
DATA ENDS
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
    MOV AX, DATA ; 初始化DS寄存器
    MOV DS, AX

    MOV counter, 0

PRINT_LOOP:
    ; 输出数字0-100
    MOV AX, counter
    MOV DI, OFFSET buffer + 4
    MOV BX, 10

CONVERT_LOOP:
    XOR DX, DX
    DIV BX
    ADD DL, '0'
    DEC DI
    MOV [DI], DL
    TEST AX, AX
    JNZ CONVERT_LOOP

PRINT_NUMBER:
    MOV AH, 2
    MOV DL, [DI]
    INT 21H
    INC DI
    CMP DI, OFFSET buffer + 4
    JNE PRINT_NUMBER

    INC counter
    INC printCounter
    CMP counter, 101
    JE EXIT
    MOV DX, OFFSET comma
    MOV AH, 9
    INT 21H

    CMP printCounter, 10
    JZ PRINT_NEWLINE

    JMP PRINT_LOOP

PRINT_NEWLINE:
    MOV printCounter, 0
    MOV DX, OFFSET newline
    MOV AH, 9
    INT 21H
    JMP PRINT_LOOP
EXIT:
    MOV AH, 4CH
    INT 21H

CODE ENDS
    END START