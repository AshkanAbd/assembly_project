
include "emu8086.inc"
.stack

.data

num1_req_msg DB 13, 10, "Enter first number: $"
num2_req_msg DB 13, 10, "Enter second number: $"  
op_req_msg DB 13, 10, "Enter operator(+,-,*,/,%): $" 

dot_msg DB "x10^-$"      
error_msg DB "ERROR$"
quit_msg DB 13, 10, "Press ('Q'/'q') to quit$"
continue_msg DB 13, 10, "Press other keys to continue", 13, 10,"$"

num1_int DD 0H
num1_dot DW 0H
num1_fill DB 0H 
num1_sign DB 1H
num1_pow DW 1H

num2_int DD 0H
num2_dot DW 0H 
num2_fill DB 0H
num2_sign DB 1H
num2_pow DW 1H

res_int DD 0H
res_dot DW 0H 
res_pow DW 1H

op DB 0H

.code

start:
    MOV AX, @data
    MOV DS, AX     
                
    MOV num1_fill, 0H
    MOV num1_int, 0H
    MOV num1_dot, 0H 
    MOV num1_sign, 1H
    MOV num1_pow, 1H
    
    MOV num2_fill, 0H
    MOV num2_int, 0H
    MOV num2_dot, 0H
    MOV num2_sign, 1H
    MOV num2_pow, 1H
    
    MOV res_int, 0H
    MOV res_dot, 0H  
    MOV res_pow, 1H
    
    MOV op, 0H
            
    JMP clear_screen
    
main:
    CMP num1_fill, 0H
    JE req_num1
    
    CMP num2_fill, 0H
    JE req_num2 
    
    CMP op, 0H
    JE req_op
    
    MOV AX, num1_int
    IMUL num1_sign
    MOV num1_int, AX
    
    MOV AX, num2_int
    IMUL num2_sign
    MOV num2_int, AX  
    
    JMP find_res_dot

req_num1: 
    LEA DX, quit_msg
    MOV AH, 09H
    INT 21H    

    LEA DX, num1_req_msg
    INT 21H
    
    MOV DI , 0H
    JMP get_num1      

get_num1:
    MOV AH, 1H
    INT 21H
    
    CMP AL, 0DH
    JE save_dot1
    
    CMP AL, 51H
    JE exit 
    
    CMP AL, 71H
    JE exit
    
    INC num1_fill

    CMP AL, 2EH
    JE find_dot1
    
    MOV BL, AL
    SUB BL, 2CH
    CMP BL, num1_fill
    JE change_sign1            
    
    INC DI
    JMP add_int1
    
change_sign1:
    MOV num1_sign, 0FFH
    
    JMP get_num1

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
    LEA DX, quit_msg
    MOV AH, 09H
    INT 21H
    
    LEA DX, num2_req_msg
    INT 21H
    
    MOV DI, 0H
    JMP get_num2

get_num2:
    MOV AH, 1H
    INT 21H
    
    CMP AL, 0DH
    JE save_dot2 
    
    CMP AL, 51H
    JE exit 
    
    CMP AL, 71H
    JE exit
    
    INC num2_fill
    
    CMP AL, 2EH
    JE find_dot2 
    
    MOV BL, AL
    SUB BL, 2CH
    CMP BL, num2_fill
    JE change_sign2
 
    INC DI
    JMP add_int2 
    
change_sign2:
    MOV num2_sign, 0FFH
    
    JMP get_num2

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
    LEA DX, quit_msg
    MOV AH, 09H
    INT 21H
    
    LEA DX, op_req_msg
    INT 21H
    
    JMP get_op
    
get_op:
    MOV AH, 01H
    INT 21H
    
    CMP op, 0H
    JNE clear_screen 
 
            
    MOV op, AL
    
    CMP op, 2BH
    JE get_op
    
    CMP op, 2AH
    JE get_op
    
    CMP op, 2DH
    JE get_op
    
    CMP op, 2FH
    JE get_op
    
    CMP op, 25H
    JE get_op
    
    CMP AL, 51H
    JE exit 
    
    CMP AL, 71H
    JE exit
                    
    MOV op, 0H                
    JMP clear_screen
        

clear_screen:
    PUSHA
    MOV AH, 0x00
    MOV AL, 0x03
    INT 0x10
    POPA  
    JMP main
    
prepare:
    CMP CL, 0H
    JE prepare_num1_pow 
    
    CMP CL, 01H
    JE prepare_op
    
    CMP CL, 02H
    JE prepare_num2_pow
    
    MOV AH, 02H
    MOV DL, 3DH
    INT 21H
    
    MOV AH, 02H
    MOV DL, 20H
    INT 21H
    
    JMP calculate

    
prepare_num1_pow:
    MOV AX, 1H
    MOV CH, 0AH
    MOV DI, num1_dot 
    
    JMP calc_pow1
                 
                 
calc_pow1:
    CMP DI, 0H   
    JE prepare_num1
    
    MUL CH
    DEC DI
    JMP calc_pow1
            
    
prepare_num1:
    MOV CL, 01H
    MOV num1_pow, AX
    
    MOV AH, 02H
    MOV DL, 0AH
    INT 21H   
    
    MOV AX, num1_int
    MOV BL, b.num1_pow
    IDIV BL
    
    MOV BL, AH
    MOV AH, 0H
    CALL print_num
    
    MOV AH, 02H
    MOV DL, 2EH
    INT 21H
    
    MOV AX, 0H
    MOV AL, BL
    CALL print_num
    
    JMP prepare

prepare_num2_pow:
    MOV AX, 1H
    MOV CH, 0AH
    MOV DI, num2_dot 
    
    JMP calc_pow2
                 
                 
calc_pow2:
    CMP DI, 0H   
    JE prepare_num2
    
    MUL CH
    DEC DI
    JMP calc_pow2    

prepare_num2:
    MOV CL, 03H
    MOV num2_pow, AX   
    
    MOV AX, num2_int
    MOV BL, b.num2_pow
    IDIV BL
    
    MOV BL, AH
    MOV AH, 0H
    CALL print_num
    
    MOV AH, 02H
    MOV DL, 2EH
    INT 21H
    
    MOV AX, 0H
    MOV AL, BL
    CALL print_num
    
    JMP prepare

prepare_op:
    MOV CL, 02H

    MOV AH, 02H
    MOV DL, 20H
    INT 21H
    
    MOV AH, 02H
    MOV DL, op
    INT 21H
    
    MOV AH, 02H
    MOV DL, 20H
    INT 21H
    
    JMP prepare

    
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
    
    MOV CL, 0H
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
    
    MOV CL, 0H    
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
    
    CMP op, 25H
    JE mode
    
    JMP exit
    
plus:
    MOV AX, num1_int
    ADD AX, num2_int
    MOV res_int, AX
    
    JMP print_res           

minus:
    MOV AX, num1_int
    SUB AX, num2_int
    MOV res_int, AX
    
    JMP print_res
    
multiply:
    MOV AX, num1_int
    IMUL num2_int
    MOV res_int, AX        

    JMP print_res
    
divide:
    CMP num2_int, 0H
    JE print_error

    MOV AX, num1_int
    MOV BL, b.num2_int   
    
    IDIV BL
    MOV b.res_int, AL
    
    JMP print_res

mode:
    CMP num2_int, 0H
    JE print_error

    MOV AX, num1_int
    MOV BL, b.num2_int   
    
    IDIV BL
    MOV b.res_int, AH
    
    JMP print_res

print_res:
    MOV AX, 1H
    MOV CH, 0AH
    MOV DI, res_dot 
    
    JMP calc_res_pow
                 
                 
calc_res_pow:
    CMP DI, 0H   
    JE print
    
    MUL CH
    DEC DI
    JMP calc_res_pow
    
print:
    MOV CL, 03H
    MOV res_pow, AX   
    
    MOV AX, res_int
    MOV BL, b.res_pow
    IDIV BL
    
    MOV BL, AH
    MOV AH, 0H
    CALL print_num
    
    MOV AH, 02H
    MOV DL, 2EH
    INT 21H
    
    MOV AX, 0H
    MOV AL, BL
    CALL print_num
       
    MOV AH, 02H
    MOV DL, 0AH
    INT 21H  
    
    JMP restart
    
print_error: 
    LEA DX, error_msg
    MOV AH, 09H
    INT 21H
    
    MOV AH, 02H
    MOV DL, 0AH
    INT 21H 
    
    JMP restart
    
restart:
    LEA DX, quit_msg
    MOV AH, 09H
    INT 21H
    
    LEA DX, continue_msg
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    
    CMP AL, 51H
    JE exit 
    
    CMP AL, 71H
    JE exit
    
    JMP start
            
    
exit:
    DEFINE_PRINT_NUM
    DEFINE_PRINT_NUM_UNS    
    END
    
