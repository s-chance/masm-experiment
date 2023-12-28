DATA SEGMENT
    initA DB 'Please input the StrA: $'
    StrA DB 50, ?, 50 DUP('$')
    initB DB 'Please input the StrB: $'
    StrB DB 50, ?, 50 DUP('$')
    Menu DB '=======================', 13, 10
         DB '1: Search StrB in StrA.', 13, 10
         DB '2: Insert StrB in StrA.', 13, 10
         DB '3: Delete StrB from StrA.', 13, 10
         DB '4: Quit.', 13, 10
         DB '=======================', 13, 10
         DB 'Please input your choice: $'
    choice DB 2, ?, 2 DUP('$')
    err DB 'Invalid input$'
    newline DB 13, 10, '$'
    location DB 3 DUP('$')
    insertMsg DB 'Please input the location to insert: $'
    insertlocation DB 2, ?, 2 DUP('$')
    res DB 50 DUP('$')
    split DB ' '
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA

START:
    MOV AX, DATA
    MOV DS, AX

    LEA DX, initA ; 获取StrA
    MOV AH, 9
    INT 21H
    MOV DX, OFFSET StrA
    MOV AH, 0AH
    INT 21H

    CALL PRINT_NEWLINE

    LEA DX, initB ; 获取StrB
    MOV AH, 9
    INT 21H
    MOV DX, OFFSET StrB
    MOV AH, 0AH
    INT 21H

    CALL PRINT_NEWLINE
MAIN:
    LEA DX, Menu ; 打印菜单
    MOV AH, 9
    INT 21H

    MOV DX, OFFSET choice ; 获取用户输入
    MOV AH, 0AH
    INT 21H

    CALL PRINT_NEWLINE

    MOV AH, [choice + 2] ; 获取用户选择
    CMP AH, '1'
    JZ SEARCH
    CMP AH, '2'
    JZ INSERT
    CMP AH, '3'
    JZ DELETE
    CMP AH, '4'
    JZ DONE
    JMP ERROR

SEARCH:
    CALL SEARCH_PROC
    CALL PRINT_NEWLINE
    JMP MAIN
INSERT:
    CALL INSERT_PROC
    CALL PRINT_NEWLINE
    JMP MAIN
DELETE:
    CALL DELETE_PROC
    CALL PRINT_NEWLINE
    JMP MAIN
ERROR:
    LEA DX, err
    MOV AH, 9
    INT 21H
DONE:
    MOV AX, 4C00H
    INT 21H

PRINT_NEWLINE PROC
    LEA DX, newline
    MOV AH, 9
    INT 21H
    RET
PRINT_NEWLINE ENDP

SPLIT_PROC PROC
    MOV DL, split
    MOV AH, 2
    INT 21H
    RET
SPLIT_PROC ENDP

SEARCH_PROC PROC
    XOR CX, CX ; 初始化源索引
    MOV SI, OFFSET StrA + 2
    MOV DI, OFFSET StrB + 2
    MOV BX, OFFSET location

LOOP_CMP:
    MOV AL, [SI] ; 加载StrA的当前字符
    CMP AL, [DI] ; 比较StrA和StrB的当前字符
    JNE NEXT_CHAR ; 如果不匹配，跳转到下一个字符

    INC DI ; 如果匹配，增加目标索引
NEXT_CHAR:
    INC SI ; 增加源索引
    INC CX ; 更新计数器
    CMP BYTE PTR [DI], 0DH ; 检查是否已经到达StrB的末尾
    JZ FOUND ; 如果是，那么找到了一个匹配项
CONTINUE:
    CMP BYTE PTR [SI], 0DH ; 检查是否已经到达StrA的末尾
    JNZ LOOP_CMP ; 如果不是，继续查找

    JMP END_P ; 如果是，结束程序

FOUND:
    PUSH CX
    SUB CL, [StrB + 1] ; 获取StrB的长度
    MOV AX, CX
    MOV CL, 10
    DIV CL ; 转换为十进制
    ADD AL, '0' ; 转换为ASCII码
    MOV [BX], AL ; 将十位数存入location
    PUSH BX
    INC BX
    ADD AH, '0' ; 转换为ASCII码
    MOV [BX], AH ; 将位置存入location
    POP BX
    POP CX
    LEA DX, location ; 打印位置
    MOV AH, 9
    INT 21H
    CALL SPLIT_PROC
    MOV DI, OFFSET StrB + 2; 重置目标索引
    JMP CONTINUE ; 继续查找

END_P:
    RET
SEARCH_PROC ENDP
ERROR2:
    LEA DX, err
    MOV AH, 9
    INT 21H
    JMP MAIN

INSERT_PROC PROC
    LEA DX, insertMsg
    MOV AH, 9
    INT 21H
    LEA DX, insertlocation
    MOV AH, 0AH
    INT 21H
    MOV AL, [insertlocation + 2]
    SUB AL, 30H
    CMP AL, 0
    JB ERROR2
    CMP AL, [StrA + 1]
    JA ERROR2
    CALL PRINT_NEWLINE
    MOV SI, OFFSET StrA + 2
    MOV DI, OFFSET StrB + 2
    MOV BX, OFFSET res
    XOR CX, CX
    SUB [insertlocation + 2], 30H

LOOP_LOC:
    CMP CL, [insertlocation + 2]
    JZ INSERT_STRB
    MOV AL, [SI]
    MOV [BX], AL
    INC SI
    INC CL
    INC BX
    CMP BYTE PTR [SI], 0DH
    JNZ LOOP_LOC
    LEA DX, res
    MOV AH, 9
    INT 21H
    RET
INSERT_STRB:
    MOV AL, [DI]
    MOV [BX], AL
    INC DI
    INC BX
    CMP BYTE PTR [DI], 0DH
    JNZ INSERT_STRB
    INC CL
    JMP LOOP_LOC
INSERT_PROC ENDP

DELETE_PROC PROC
    XOR CX, CX ; 相同字符计数器
    MOV SI, OFFSET StrA + 2
    MOV DI, OFFSET StrB + 2
    MOV BX, OFFSET res

LOOP_CHECK:
    MOV AL, [SI] ; 加载StrA的当前字符
    MOV [BX], AL ; 将当前字符存入res
    INC BX ; 更新res的索引
    CMP AL, [DI] ; 比较StrA和StrB的当前字符
    JZ SAME ; 如果匹配，跳转到下一个字符
    XOR CX, CX ; 如果不匹配，重置计数器
    MOV DI, OFFSET StrB + 2 ; 重置目标索引
    CMP AL, [DI] ; 重新比较
    JZ SAME ; 如果匹配，跳转到下一个字符
    INC SI
    CMP BYTE PTR [SI], 0DH ; 检查是否已经到达StrA的末尾
    JZ LOOP_END ; 如果是，结束程序
    JMP RESET ; 不匹配的情况，重置目标索引

SAME:
    INC CX ; 更新计数器
    INC SI ; 增加源索引
    INC DI ; 增加目标索引
    CMP BYTE PTR [SI], 0DH ; 检查是否已经到达StrA的末尾
    JZ LOOP_END ; 如果不是，继续查找
    CMP BYTE PTR [DI], 0DH ; 检查是否已经到达StrB的末尾
    JZ ALL_CMP ; 完全匹配，删除StrB
    JMP LOOP_CHECK

ALL_CMP:
    SUB BX, CX
    XOR CX, CX
RESET:
    MOV DI, OFFSET StrB + 2 ; 重置目标索引
    JMP LOOP_CHECK ; 继续查找

LOOP_END:
    MOV BYTE PTR [BX], '$' ; 结束res
    LEA DX, res ; 打印结果
    MOV AH, 9
    INT 21H
    RET
DELETE_PROC ENDP

CODE ENDS
    END START