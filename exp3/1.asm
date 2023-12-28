DATA SEGMENT
    msg DB 'Please input a character: $'
    decimal DB "The decimal number is: $"
    hex DB "The hexadecimal number is: $"
    newline DB 13, 10, '$'
    char DB ?
    res DB 3 DUP('$')
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA

START:
    MOV AX, DATA
    MOV DS, AX

    LEA DX, msg
    MOV AH, 9
    INT 21H

    MOV AH, 1
    INT 21H
    MOV char, AL
    CALL CRLF
    CALL CHAR_TO_D
    CALL CRLF
    CALL CHAR_TO_H
    
    MOV AX, 4C00H
    INT 21H
    
CHAR_TO_D PROC ; 转十进制后输出
    MOV DI, OFFSET res
    XOR AX, AX
    MOV AL, char
    MOV BL, 100
    DIV BL
    CMP AL, 0
    JZ SKIP_HUNDRED
    ADD AL, '0'
    MOV [DI], AL ; 百位数
    INC DI
SKIP_HUNDRED:
    MOV AL, AH
    XOR AH, AH
    MOV BL, 10
    DIV BL
    CMP AL, 0
    JZ SKIP_TEN
    ADD AL, '0'
    MOV [DI], AL ; 十位数
    INC DI
SKIP_TEN:
    ADD AH, '0'
    MOV [DI], AH ; 个位数
    INC DI
    MOV BYTE PTR [DI], '$'
    LEA DX, decimal
    MOV AH, 9
    INT 21H
    MOV DX, OFFSET res
    MOV AH, 9
    INT 21H
    RET
CHAR_TO_D ENDP

CHAR_TO_H PROC ; 转十六进制后输出
    MOV DI, OFFSET res
    XOR AX, AX
    MOV AL, char
    MOV BL, 16
    DIV BL
    CMP AL, 10
    JB IS_DIGIT1
    SUB AL, 10
    ADD AL, 'A'
    JMP CONTINUE1
IS_DIGIT1:
    ADD AL, '0'
CONTINUE1:
    MOV [DI], AL ; 十位数
    INC DI
    CMP AH, 10
    JB IS_DIGIT2
    SUB AH, 10
    ADD AH, 'A'
    JMP CONTINUE2
IS_DIGIT2:
    ADD AH, '0'
CONTINUE2:
    MOV [DI], AH ; 个位数
    INC DI
    MOV BYTE PTR [DI], '$'
    LEA DX, hex
    MOV AH, 9
    INT 21H
    MOV DX, OFFSET res
    MOV AH, 9
    INT 21H
    RET
CHAR_TO_H ENDP

CRLF PROC
    LEA DX, newline
    MOV AH, 9
    INT 21H
    RET
CRLF ENDP

CODE ENDS
    END START
