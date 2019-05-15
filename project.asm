
include "emu8086.inc"
.stack

.data

num1_req_msg DB 13, 10, "Enter first number: $"
num2_req_msg DB 13, 10, "Enter second number: $"  
op_req_msg DB 13, 10, "Enter operator(+,-,*,/,%): $" 
      
error_msg DB "ERROR$"
quit_msg DB 13, 10, "Press ('Q'/'q') to quit$"
continue_msg DB 13, 10, "Press other keys to continue", 13, 10,"$"

num1_int        DD      0H 
num1_int_abs    DD      0H
num1_dot        DW      0H
num1_dot_       DW      0H
num1_fill       DB      0H 
num1_sign       DD      1H
num1_pow        DW      1H

num2_int        DD      0H
num2_int_abs    DD      0H
num2_dot        DW      0H 
num2_dot_       DW      0H
num2_fill       DB      0H
num2_sign       DD      1H
num2_pow        DW      1H

res_int         DD      0H  
res_int_abs     DD      0H
res_dot         DW      0H 
res_pow         DW      1H 

better_dot DB 0H

op DB 0H

.code

start:
    MOV AX, @data
    MOV DS, AX     
    
    CALL reset_num1
    
    CALL reset_num2
    
    MOV res_int, 0H 
    MOV res_int_abs, 0H
    MOV res_dot, 0H  
    MOV res_pow, 1H
    
    MOV op, 0H   
    
    JMP main
    
reset_num1:
    MOV num1_fill, 0H
    MOV num1_int, 0H 
    MOV num1_int_abs, 0H
    MOV num1_dot, 0H
    MOV num1_dot_, 0H 
    MOV num1_sign, 1H
    MOV num1_pow, 1H
    
    RET    
            
reset_num2:
    MOV num2_fill, 0H
    MOV num2_int, 0H
    MOV num2_int_abs, 0H
    MOV num2_dot, 0H
    MOV num2_dot_, 0H
    MOV num2_sign, 1H
    MOV num2_pow, 1H
    
    RET

    
main: 
    CALL clear_screen
    
    CMP num1_fill, 0H
    JE req_num1
    
    CMP num2_fill, 0H
    JE req_num2 
    
    CMP op, 0H
    JE req_op 
    
    CALL change_sign1
    CALL change_sign2
     
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
                
    MOV AH, 0H            
    CMP AL, 2DH
    
    MOV BL, AL
    XOR BL, num1_fill
 
    CMP BL, 2CH
    JE save_sign1            
 
    MOV BL, AL
    CMP BL, 30H
    JL invalid_num1
    
    CMP BL, 39H
    JG invalid_num1  
    
    INC DI
    JMP add_int1

invalid_num1:
    CALL reset_num1
    
    JMP main
    
save_sign1:
    MOV num1_sign, 0FFFFH
    
    JMP get_num1
    
change_sign1:
    MOV AX, num1_int
    MOV num1_int_abs, AX
    
    IMUL num1_sign
    MOV num1_int, AX 
    
    RET        

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
    CMP num1_dot, 0H
    JNE invalid_num1
    
    MOV num1_dot, DI
    
    JMP get_num1 
    
save_dot1:
    CMP num1_dot, 0H
    JE main

    SUB DI, num1_dot
    MOV num1_dot, DI

    JMP main   
    
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
    SUB BL, 2DH
    
    MOV BH, num2_fill
    DEC BH
    
    XOR BH, BL 
    CMP BH, 0H
    JE save_sign2 
    
    MOV BL, AL
    CMP BL, 30H
    JL invalid_num2
    
    CMP BL, 39H
    JG invalid_num2
 
    INC DI
    JMP add_int2
    
invalid_num2:
    CALL reset_num2
    
    JMP main     
    
save_sign2:
    MOV num2_sign, 0FFFFH
    
    JMP get_num2 
    
change_sign2:
    MOV AX, num2_int
    MOV num2_int_abs, AX
    
    IMUL num2_sign
    MOV num2_int, AX    

    RET

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
    CMP num2_dot, 0H 
    JNE invalid_num2

    MOV num2_dot, DI
    
    JMP get_num2  
    
save_dot2:
    CMP num2_dot, 0H
    JE main
    
    SUB DI, num2_dot
    MOV num2_dot, DI

    JMP main     
    
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
    JNE main 
 
            
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
    JMP main
        

clear_screen:
    PUSHA
    MOV AH, 0x00
    MOV AL, 0x03
    INT 0x10
    POPA 
    
    RET 
    
prepare:
    CMP CL, 0H
    JE prepare_num1_pow 
    
    CMP CL, 01H
    JE prepare_op
    
    CMP CL, 02H
    JE prepare_num2_pow
    
    MOV AH, 02H
    MOV DL, 20H
    INT 21H
    
    MOV DL, 3DH
    INT 21H
    
    MOV AH, 02H
    MOV DL, 20H
    INT 21H
    
    JMP calculate

    
prepare_num1_pow: 
    MOV AH, 02H
    MOV DL, 0AH
    INT 21H
 
    CALL change_sign1
    
    CALL check_num1_sign
    MOV CL, 01H
    
    MOV AX, 1H
    MOV CH, 0AH
    MOV DI, 0H
    
    JMP calc_pow1
                 
                 
calc_pow1:
    CMP AX, num1_int_abs
    JG prepare_num1
    
    MUL CH
    INC DI
    JMP calc_pow1
            
check_num1_sign:
    CMP num1_sign, 1H
    JNE print_num1_sign
    
    RET
    
print_num1_sign:
    MOV AH, 02H
    MOV DL, 2DH
    INT 21H
    
    RET     
    
prepare_num1:
    MOV num1_pow, DI   
    
    CMP DI, 0H
    JE print_num1
    
    MOV DI, num1_dot
    
    CMP DI, num1_pow
    JL print_num1_
    
    MOV AH, 02H
    MOV DL, 30H
    INT 21H
    
    MOV DL, 2EH
    INT 21H
    
    SUB DI, num1_pow
    
    JMP put_zero1 
    
print_num1_:
    MOV AX, 01H
    MOV DI, num1_dot
    MOV BL, 0AH
    
    JMP calc_pow1_
    
calc_pow1_:
    CMP DI, 0H
    JE prepare_num1_
    
    MUL BL
    DEC DI
    
    JMP calc_pow1_
        
prepare_num1_:
    MOV BH, AL
    MOV AX, num1_int_abs
    
    DIV BH
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
        
put_zero1:
    CMP DI, 0H
    JE print_num1
    
    DEC DI     
    
    MOV AH, 02H  
    MOV DL, 30H
    INT 21H
    
    JMP put_zero1
    
print_num1:
    MOV AX, num1_int_abs
    CALL print_num
    
    JMP prepare 
    
check_num2_sign:
    CMP num2_sign, 1H
    JNE print_num2_sign
    
    RET
    
print_num2_sign:
    MOV AH, 02H
    MOV DL, 2DH
    INT 21H
    
    RET    
    
prepare_num2_pow:
    CALL change_sign2
    
    CALL check_num2_sign

    MOV CL, 03H
    
    MOV AX, 1H
    MOV CH, 0AH
    MOV DI, 0H
    
    JMP calc_pow2
                 
                 
calc_pow2:
    CMP AX, num2_int_abs
    JG prepare_num2
    
    MUL CH
    INC DI
    JMP calc_pow2     

    
prepare_num2:
    MOV num2_pow, DI
    
    CMP DI, 0H
    JE print_num2
    
    MOV DI, num2_dot 
    
    CMP DI, num2_pow
    JL print_num2_
    
    MOV AH, 02H
    MOV DL, 30H
    INT 21H
    
    MOV DL, 2EH
    INT 21H
    
    SUB DI, num2_pow
    
    JMP put_zero2 
    
print_num2_:
    MOV AX, 01H
    MOV DI, num2_dot
    MOV BL, 0AH
    
    JMP calc_pow2_
    
calc_pow2_:
    CMP DI, 0H
    JE prepare_num2_
    
    MUL BL
    DEC DI
    
    JMP calc_pow2_
        
prepare_num2_:
    MOV BH, AL
    MOV AX, num2_int_abs
    
    DIV BH
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
        
put_zero2:
    CMP DI, 0H
    JE print_num2
    
    DEC DI     
    
    MOV AH, 02H  
    MOV DL, 30H
    INT 21H
    
    JMP put_zero2
    
print_num2:
    MOV AX, num2_int_abs
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
    
    MOV DI, num1_dot
    MOV num1_dot_, DI
    MOV DI, num2_dot
    MOV num2_dot_, DI
    
    ADD num2_dot, AX
    
    MOV better_dot, 1H
    
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
    
    MOV DI, num1_dot
    MOV num1_dot_, DI
    MOV DI, num2_dot
    MOV num2_dot_, DI
    
    ADD num1_dot, AX  
    
    MOV better_dot, 0H
    
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
    
    MOV AX, num1_dot
    ADD AX, num2_dot
    MOV res_dot, AX        

    JMP print_res
    
divide:
    CMP num2_int, 0H
    JE print_error

    MOV AX, num1_int
    MOV BL, b.num2_int   
    
    IDIV BL
    MOV b.res_int, AL

    CMP better_dot, 1H
    JE divide_
    
    JMP divide_1   
    
divide_:
    MOV AX, num1_dot_
    SUB AX, num2_dot_
    MOV res_dot, AX
                   
    JMP print_res

divide_1:
    MOV AX, num2_dot_
    SUB AX, num2_dot_
    MOV res_dot, AX

    JMP print_res

mode:
    CMP num2_int, 0H
    JE print_error

    MOV AX, num1_int
    MOV BL, b.num2_int   
    
    IDIV BL
    MOV b.res_int, AH
    
    JMP print_res 
    
check_res_sign:
    MOV AX, res_int
    
    TEST AX, AX
    JNS change_res_sign
    
    RET    

change_res_sign:
    MOV BX, 0FFFFH
    IMUL BX
    MOV res_int_abs, AX

    RET    

print_res:
    CALL check_res_sign
    
    MOV CL, 01H
    
    MOV AX, 1H
    MOV CH, 0AH
    MOV DI, 0H
    
    JMP calc_res_pow
                 
                 
calc_res_pow:
    CMP AX, res_int
    JG prepare_res
    
    MUL CH
    INC DI
    JMP calc_res_pow
            
    
prepare_res:
    MOV res_pow, DI
    
    CMP DI, 0H
    JE print_res_num
 
    MOV DI, res_dot
    
    CMP DI, res_pow
    JL print_res_
    
    MOV AH, 02H
    MOV DL, 30H
    INT 21H
    
    MOV DL, 2EH
    INT 21H
    
    MOV DI, res_dot
    SUB DI, res_pow
    
    JMP put_zero_res
        
put_zero_res:
    CMP DI, 0H
    JE print_res_num
    
    DEC DI     
    
    MOV AH, 02H  
    MOV DL, 30H
    INT 21H
    
    JMP put_zero_res
    
print_res_:
    MOV AX, 01H
    MOV DI, res_dot
    MOV BL, 0AH
    
    JMP calc_res_
    
calc_res_:
    CMP DI, 0H
    JE prepare_res_
    
    MUL BL
    DEC DI
    
    JMP calc_res_
        
prepare_res_:
    MOV BH, AL
    MOV AX, res_int
    
    DIV BH
    MOV BL, AH
    MOV AH, 0H
    
    CALL print_num
    
    MOV AH, 02H
    MOV DL, 2EH
    INT 21H
    
    MOV AX, 0H
    MOV AL, BL
    
    CALL print_num
    
    JMP restart    
    
print_res_num:
    MOV AX, res_int
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
    
