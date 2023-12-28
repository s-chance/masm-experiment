DATA SEGMENT 
    msg DB 'Enter a number: $'
    num DB ?
    ; 缓冲区与DOS 0AH功能号配合使用
    ; 用户输入的字符数等于缓冲区大小减1，这个减去的1是回车符0DH
    ; 关于初始化缓冲区使用 '$'，'$' 主要是考虑方便与其它DOS功能函数交互
    ; buffer DB 2, ?, ' $'
    buffer DB 2, ?, ' '
    result_even DB 0Dh, 0Ah, 'The number is even.$'
    result_odd DB 0Dh, 0Ah, 'The number is odd.$'
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
START:
    ; 设置数据段寄存器
    MOV AX, DATA
    MOV DS, AX

    ; 输出提示信息
    MOV AH, 09H
    ; MOV DX, OFFSET msg
    LEA DX, msg
    INT 21H

    ; 读取用户输入
    CALL GET_NUM
    MOV [num], AL

    ; 奇偶性判断
    AND AL, 01H
    JZ EVEN_P
    JMP ODD

EVEN_P PROC
    ; 输出结果：偶数
    MOV AH, 09H
    LEA DX, result_even
    INT 21H
    JMP END_PROC
EVEN_P ENDP

ODD PROC
    ; 输出结果：奇数
    MOV AH, 09H
    LEA DX, result_odd
    INT 21H
    JMP END_PROC
ODD ENDP

END_PROC:
    ; 程序结束
    MOV AH, 4CH
    INT 21H

; 函数：获取用户输入的数字
GET_NUM PROC
    ; 读取用户输入

    ; ; 写法一：读取1个字符
    ; ; 01H 输入1个字符之后就会结束，不会等待回车
    ; MOV AH, 01H 
    ; INT 21H

    ; ; 将用户输入的字符转换为数字
    ; SUB AL, 30H

    ; 写法二：读取字符串
    ; 0AH 读取字符串，以回车结束
    MOV AH, 0AH
    MOV DX, OFFSET buffer
    INT 21H

    ; 将用户输入的字符转换为数字
    ; + 2 是因为buffer的第一个字节是缓冲区大小，第二个字节是实际读取的字符数
    ; 第三个字节才是用户输入的字符内容
    MOV AL, [buffer + 2]
    SUB AL, 30H

    ; 返回
    RET
GET_NUM ENDP

CODE ENDS
    END START