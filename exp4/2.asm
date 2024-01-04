DATA SEGMENT
    inputA DB 'Please input array A: $'
    inputB DB 'Please input array B: $'
    andMsg DB 'A and B = $'
    orMsg DB 'A or B = $'
    diffMsg DB 'A - B = $'
    newline DB 13,10,'$'
    ; arrayA DB 1,2,3,4,5,6,7,8,9,10
    ; arrayB DB 1,2,4,7,11
    ; arrayA DB 1 2 3 4 6 7 8 9
    ; arrayB DB 6 7 8 11 12
    arrayA DB 10 DUP('$')
    arrayB DB 10 DUP('$')
    strA DB 50, ?, 50 DUP('$')
    strB DB 50, ?, 50 DUP('$')
    andRes DB 50 DUP('$')
    orRes DB 50 DUP('$')
    diffRes DB 50 DUP('$')
    lenA DB 0
    lenB DB 0
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
START:
    MOV AX, DATA
    MOV DS, AX

    LEA DX, inputA
    MOV AH, 9
    INT 21H
    LEA DX, strA
    MOV AH, 0AH
    INT 21H
    CALL PRINT_NEWLINE

    LEA SI, strA + 2
    XOR CX, CX
    MOV CL, [strA + 1]
    LEA DI, arrayA
    CALL CONVERT_TO_DIGIT
    MOV [lenA], CH

    LEA DX, inputB
    MOV AH, 9
    INT 21H
    LEA DX, strB
    MOV AH, 0AH
    INT 21H
    CALL PRINT_NEWLINE

    LEA SI, strB + 2
    XOR CX, CX
    MOV CL, [strB + 1]
    LEA DI, arrayB
    CALL CONVERT_TO_DIGIT
    MOV [lenB], CH
    XOR CH, CH

    ; 交集
    LEA SI, arrayA
    LEA DI, andRes    
AND_LOOP:
    XOR AX, AX
    MOV AL, [SI]
    LEA BX, arrayB
    MOV CL, [lenB] ; arrayB的长度
AND_CHECK:
    CMP AL, [BX]
    JZ NEXT1 ; 相等
    INC BX
    LOOP AND_CHECK
    JMP NEXT_DIGIT
NEXT1:
    CALL CONVERT_TO_STRING
NEXT_DIGIT:
    INC SI
    PUSH BX
    XOR BX, BX
    MOV BX, OFFSET arrayA
    ADD BL, [lenA]
    CMP SI, BX ; 判断arrayA是否到达末尾
    POP BX
    JL AND_LOOP
    CALL AND_OUTPUT
    ; 并集
    LEA SI, arrayA
    LEA DI, orRes
OR_SUM_A:
    XOR AX, AX
    MOV AL, [SI]
    CALL CONVERT_TO_STRING
    INC SI
    PUSH BX
    XOR BX, BX
    MOV BX, OFFSET arrayA
    ADD BL, [lenA]
    CMP SI, BX ; 判断arrayA是否到达末尾
    POP BX
    JL OR_SUM_A
    LEA BX, arrayB
OR_CHECK_B: ; 去重
    XOR AX, AX
    MOV AL, [BX]
    LEA SI, arrayA
OR_CHECK_A:
    CMP AL, [SI]
    JZ NEXT2
    INC SI
    PUSH BX
    XOR BX, BX
    MOV BX, OFFSET arrayA
    ADD BL, [lenA]
    CMP SI, BX ; 判断arrayA是否到达末尾
    POP BX
    JL OR_CHECK_A
    CALL CONVERT_TO_STRING
NEXT2:
    INC BX
    PUSH SI
    PUSH AX
    MOV SI, OFFSET arrayB
    XOR AX, AX
    MOV AL, [lenB]
    ADD SI, AX
    CMP BX, SI ; 判断arrayB是否到达末尾
    POP AX
    POP SI
    JL OR_CHECK_B
    CALL OR_OUTPUT

    ; 差集
    LEA SI, arrayA
    LEA DI, diffRes
DIFF_LOOP:
    XOR AX, AX
    MOV AL, [SI]
    LEA BX, arrayB
    MOV CL, [lenB] ; arrayB的长度
DIFF_CHECK:
    CMP AL, [BX]
    JZ NEXT3
    INC BX
    LOOP DIFF_CHECK
    CALL CONVERT_TO_STRING
NEXT3:
    INC SI
    PUSH BX
    XOR BX, BX
    MOV BX, OFFSET arrayA
    ADD BL, [lenA]
    CMP SI, BX ; 判断arrayA是否到达末尾
    POP BX
    JL DIFF_LOOP
    CALL DIFF_OUTPUT

    MOV AH, 4CH
    INT 21H

CONVERT_TO_STRING PROC
    PUSH CX
    MOV CX, 10
    DIV CL ; AH存储余数，AL存储商
    CMP AL, 0 ; 判断位数
    JZ SINGLE_DIGIT
    ADD AL, '0'
    MOV [DI], AL
    INC DI
SINGLE_DIGIT:
    ADD AH, '0'
    MOV [DI], AH
    INC DI
    MOV BYTE PTR [DI], ' '
    INC DI
    POP CX
    RET
CONVERT_TO_STRING ENDP

CONVERT_TO_DIGIT PROC
    XOR AX, AX ; 清空AX寄存器，用于存储当前的数字
    XOR BX, BX 
NEXT_DIGIT2:
    MOV BL, [SI]
    CMP CL, 0
    JZ LAST_DIGIT ; 如果已经处理完所有的字符，就存储当前的数字
    INC SI
    DEC CL
    CMP BL, ' ' ; 检查当前字符是否为空格
    JZ STORE_DIGIT ; 如果是空格，就存储当前的数字
    SUB BL, '0' ; 将字符转换为数字
    PUSH BX ; 将数字压入栈中
    MOV BL, 10
    MUL BL ; 将当前的数字乘以10
    POP BX ; 将数字弹出栈中
    ADD AL, BL
    JMP NEXT_DIGIT2 ; 继续处理下一个字符
STORE_DIGIT:
    MOV [DI], AL ; 将当前的数字存储到arrayA中
    INC CH ; 统计数字的个数
    INC DI ; 处理下一个数字
    XOR AX, AX ; 清空AX寄存器，用于存储当前的数字
    JMP NEXT_DIGIT2 ; 继续处理下一个字符
LAST_DIGIT:
    MOV [DI], AL ; 将最后一个数字存储到数组中
    INC CH ; 统计数字的个数
    RET ; 结束这个过程
CONVERT_TO_DIGIT ENDP

AND_OUTPUT PROC
    LEA DX, andMsg
    MOV AH, 9
    INT 21H
    LEA DX, andRes
    MOV AH, 9
    INT 21H 
    CALL PRINT_NEWLINE
    RET
AND_OUTPUT ENDP

OR_OUTPUT PROC
    LEA DX, orMsg
    MOV AH, 9
    INT 21H
    LEA DX, orRes
    MOV AH, 9
    INT 21H
    CALL PRINT_NEWLINE
    RET
OR_OUTPUT ENDP

DIFF_OUTPUT PROC
    LEA DX, diffMsg
    MOV AH, 9
    INT 21H
    LEA DX, diffRes
    MOV AH, 9
    INT 21H
    CALL PRINT_NEWLINE
    RET
DIFF_OUTPUT ENDP

PRINT_NEWLINE PROC
    LEA DX, newline
    MOV AH, 9
    INT 21H
    RET
PRINT_NEWLINE ENDP

CODE ENDS
    END START