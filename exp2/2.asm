DATA SEGMENT
    msg DB 'Please input a num(0<n<10): $'
    err DB 'Error: Please input a number between 1 and 10! $'
    tip DB 'input the array(use a space to spilt different number): $'
    res DB 'The sum is: $'
    newline DB 13, 10, '$'
    buf DB 3, ?, 3 DUP('$')  ; 用户输入的数字，支持2位数
    n DB 0
    bbuf DB 50, ?, 50 DUP('$') ; 用户输入的数组,支持4位数
    array DB 10 DUP(0)
    sum DW 0
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
START:
    MOV AX, DATA ; 初始化数据段寄存器
    MOV DS, AX

    MOV AH, 09H ; 输出提示信息
    LEA DX, msg
    INT 21H
    
    MOV DX, OFFSET buf ; 输入数组个数
    MOV AH, 0AH
    INT 21H
    MOV SI, OFFSET buf + 2
    XOR CX, CX
    MOV CL, [buf + 1]
    CALL READ_NUMBER
    MOV n, AL
    CMP n, 10 ; 检查n是否超出边界
    JA ERROR
    CMP n, 0
    JBE ERROR

    CALL PRINT_NEWLINE

    MOV AH, 09H ; 输出提示信息
    LEA DX, tip
    INT 21H

    MOV DX, OFFSET bbuf ; 输入具体数组
    MOV AH, 0AH
    INT 21H
    MOV SI, OFFSET bbuf + 2
    MOV CL, [bbuf + 1]
    MOV DI, OFFSET array

    CALL READ_NUMBER
    MOV CL, n ; 数组个数

    CALL PRINT_NEWLINE

    MOV AH, 0
    MOV sum, 0

    LEA SI, array
CALCULATE_SUM:
    MOV AL, [SI]
    ADD sum, AX
    INC SI
    LOOP CALCULATE_SUM

    MOV AX, sum
    MOV DI, OFFSET buf + 5
    MOV BX, 10
OUTPUT_LOOP:
    XOR DX, DX
    DIV BX
    ADD DL, '0'
    DEC DI
    MOV [DI], DL
    TEST AX, AX
    JNZ OUTPUT_LOOP

    MOV AH, 09H
    LEA DX, res
    INT 21H

OUTPUT_DIGIT:
    MOV DL, [DI]
    MOV AH, 02H
    INT 21H
    INC DI
    CMP DI, OFFSET buf + 6
    JNZ OUTPUT_DIGIT

    CALL PRINT_NEWLINE
DONE:
    MOV AX, 4C00H
    INT 21H
ERROR:
    CALL PRINT_NEWLINE
    MOV AH, 09H
    LEA DX, err
    INT 21H
    JMP DONE
READ_NUMBER PROC ; 读取多位数字输入
    XOR AX, AX
    XOR BX, BX
READ_LOOP:
    MOV BL, [SI]
    CMP CL, 0 ; CL 表示的是输入字符串的实际长度
    JZ OK
    INC SI
    DEC CL
    CMP BL, ' ' ; 遇到空格保存数字到数组，如果没有空格则表示是单个数字输入
    JZ SKIP
    SUB BL, 30H ; 字符转数字
    PUSH BX ; 暂存BX, BX为关键的数字部分
    MOV BL, 10
    MUL BL ; 乘10法存入AX
    POP BX
    ADD AL, BL ; 最终结果保存在AL中
    JMP READ_LOOP
SKIP: ; 遇到空格时说明需要处理array
    MOV [DI], AL ; 存入DL指向的array
    INC DI
    XOR AX, AX ; 清空AX
    JMP READ_LOOP
OK:
    MOV [DI], AL ; 存储最后一个没有空格结尾的数字
    RET
READ_NUMBER ENDP
PRINT_NEWLINE PROC
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    RET
PRINT_NEWLINE ENDP
CODE ENDS
    END START