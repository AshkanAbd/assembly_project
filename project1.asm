
include "emu8086.inc"
.stack

.data

num1_req_msg DB "Enter first number: $"
num2_req_msg DB "Enter second number: $"  
op_req_msg DB "Enter operator(+ - * / ): $" 

dot_msg DB "*10^-$"      
error_msg DB "ERROR$"

num1_int DD 0H
num1_dot DW 0H
num1_fill DB 0H

num2_int DD 0H
num2_dot DW 0H 
num2_fill DB 0H

res_int DD 0H
res_dot DW 0H

op DB 0H

.code

start:
    MOV AX, @data
    MOV DS, AX     
                
    MOV Bl, 0H            
    JMP main
    
main:
    CMP num1_fill, 0H
    JE req_num1
    
    CMP num2_fill, 0H
    JE req_num2 
    
    CMP op, 0H
    JE req_op  
    
    JMP find_res_dot

req_num1:
    LEA DX, num1_req_msg
    MOV AH, 09H
    INT 21H
    
    MOV DI , 0H
    JMP get_num1      

get_num1:
    MOV AH, 1H
    INT 21H
    
    CMP AL, 0DH
    JE save_dot1
    
    INC num1_fill

    CMP AL, 2EH
    JE find_dot1
    
    INC DI
    JMP add_int1

add_int1:
    MOV CL, AL                
    SUB CL, 30H
    
    MOV AX, num1_int 
    MOV BH, 0AH
    IMUL BH
    ADD AL, CL
    MOV num1_int, AX 
    
    JMP get_num1

find_dot1:
    MOV num1_dot, DI
    
    JMP get_num1 
    
save_dot1:
    CMP num1_dot, 0H
    JE clear_screen

    SUB DI, num1_dot
    MOV num1_dot, DI

    JMP clear_screen    
    
req_num2:
    LEA DX, num2_req_msg
    MOV AH, 09H
    INT 21H
    
    MOV DI, 0H
    JMP get_num2

get_num2:
    MOV AH, 1H
    INT 21H
    
    CMP AL, 0DH
    JE save_dot2 
    
    INC num2_fill

    CMP AL, 2EH
    JE find_dot2
 
    INC DI
    JMP add_int2

add_int2:
    MOV CL, AL                
    SUB CL, 30H
    
    MOV AX, num2_int 
    MOV BH, 0AH
    IMUL BH
    ADD AL, CL
    MOV num2_int, AX 
    
    JMP get_num2

find_dot2:
    MOV num2_dot, DI
    
    JMP get_num2  
    
save_dot2:
    CMP num2_dot, 0H
    JE clear_screen
    
    SUB DI, num2_dot
    MOV num2_dot, DI

    JMP clear_screen     
    
req_op:
    LEA DX, op_req_msg
    MOV AH, 09H
    INT 21H
    
    JMP get_op
    
get_op:
    MOV AH, 01H
    INT 21H
    
    CMP op, 0H
    JNE clear_screen
            
    MOV op, AL
    
    JMP get_op
        

clear_screen:
    PUSHA
    MOV AH, 0x00
    MOV AL, 0x03
    INT 0x10
    POPA  
    JMP main
    
prepare:
    MOV AX, num1_int
    CALL print_num
 
    LEA DX, dot_msg
    MOV AH, 09H
    INT 21H   
    
    MOV AX, num1_dot
    CALL print_num
    
    MOV AH, 02H
    MOV DL, 20H
    INT 21H
    
    MOV AH, 02H
    MOV DL, op
    INT 21H
    
    MOV AH, 02H
    MOV DL, 20H
    INT 21H
    
    MOV AX, num2_int
    CALL print_num
    
    LEA DX, dot_msg
    MOV AH, 09H
    INT 21H
    
    MOV AX, num2_dot
    CALL print_num   
 
    MOV AH, 02H
    MOV DL, 20H
    INT 21H
    
    MOV AH, 02H
    MOV DL, 3DH
    INT 21H
    
    MOV AH, 02H
    MOV DL, 20H
    INT 21H
    
    JMP calculate
    
find_res_dot:
    MOV AX, num1_dot 
    
    CMP AX, num2_dot
    JG res_dot_1 
    
    JMP res_dot_2  
    
res_dot_1:
    MOV AX, num1_dot
    MOV res_dot, AX 
    
    SUB AX, num2_dot
    
    MOV DI, AX
    MOV AX, num2_int
    MOV BL, 0AH
                       
    JMP shift1
    
shift1:
    CMP DI, 0H
    MOV num2_int, AX
    JE prepare
    
    DEC DI
    IMUL BL
    
    JMP shift1    
    
res_dot_2:
    MOV AX, num2_dot
    MOV res_dot, AX
    
    SUB AX, num1_dot
    
    MOV DI, AX
    MOV AX, num1_int
    MOV BL, 0AH    
       
    JMP shift2

shift2:
    CMP DI, 0H
    MOV num1_int, AX
    JE prepare
    
    DEC DI
    IMUL BL
    
    JMP shift2
    
calculate:
    CMP op, 2BH
    JE plus 
    
    CMP op, 2DH
    JE minus
    
    CMP op, 2AH
    JE multiply
    
    CMP op, 2FH
    JE divide
    
    JMP exit
    
plus:
    MOV AX, num1_int
    ADD AX, num2_int
    MOV res_int, AX
    
    JMP print               

minus:
    MOV AX, num1_int
    SUB AX, num2_int
    MOV res_int, AX
    
    JMP print
    
multiply:
    MOV AX, num1_int
    IMUL num2_int
    MOV res_int, AX        

    JMP print
    
divide:
    CMP num2_int, 0H
    JE print_error

    MOV AX, num1_int
    MOV BL, b.num2_int   
    
    IDIV BL
    MOV res_int, AX
    
    JMP print    
    
print:
    MOV AX, res_int
    CALL print_num
    
    LEA DX, dot_msg
    MOV AH, 09H
    INT 21H
    
    MOV AX, res_dot
    CALL print_num   
    
    JMP exit
    
print_error: 
    LEA DX, error_msg
    MOV AH, 09H
    INT 21H 
    
    JMP exit
    
exit:
    DEFINE_PRINT_NUM
    DEFINE_PRINT_NUM_UNS    
    END
    
