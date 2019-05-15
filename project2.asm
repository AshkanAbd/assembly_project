
.stack

.data

num1_req_msg DB 13, 10, "Enter first number: $"
num2_req_msg DB 13, 10, "Enter second number: $"  
op_req_msg DB 13, 10, "Enter operator(+,-,*,/,%): $" 
      
error_msg   DB    "ERROR$" 
dot_msg     DB    "x10^$"
quit_msg DB 13, 10, "Press ('Q'/'q') to quit$"
continue_msg DB 13, 10, "Press other keys to continue", 13, 10,"$"

num1_int        DD      0H 
num1_dot        DW      0H
num1_dot_       DW      0H
num1_fill       DB      0H 
num1_sign       DD      1H
num1_pow        DW      1H

num2_int        DD      0H
num2_dot        DW      0H 
num2_dot_       DW      0H
num2_fill       DB      0H
num2_sign       DD      1H
num2_pow        DW      1H

res_int         DD      0H  
res_dot         DW      0H 
res_pow         DW      1H 

op              DB      0H 

ten             DW      0AH
len             DW      0H
tmp             DD      ? 
tmp1            DD      ?

.code

start:
    ; Load data segment
    MOV AX, @data
    MOV DS, AX     
    
    ; Reset numbers
    CALL reset_num1
    CALL reset_num2
    
    ; Reset result
    MOV res_int, 0H 
    MOV res_dot, 0H  
    MOV res_pow, 1H
    
    ; Reset operator
    MOV op, 0H   
    
    JMP main
    
reset_num1:
    MOV num1_fill, 0H
    MOV num1_int, 0H 
    MOV num1_dot, 0H
    MOV num1_dot_, 0H 
    MOV num1_sign, 1H
    MOV num1_pow, 1H
    
    RET    
            
reset_num2:
    MOV num2_fill, 0H
    MOV num2_int, 0H
    MOV num2_dot, 0H
    MOV num2_dot_, 0H
    MOV num2_sign, 1H
    MOV num2_pow, 1H
    
    RET

    
main: 
    CALL clear_screen
    
    ; Check num1 
    CMP num1_fill, 0H
    JE req_num1
                          
    ; Check num2                       
    CMP num2_fill, 0H
    JE req_num2 
            
    ; Check operator        
    CMP op, 0H
    JE req_op 
    
    ; Set nums sign
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
    ; Get input
    MOV AH, 1H
    INT 21H
    
    ; Exit if enter pressed
    CMP AL, 0DH
    JE save_dot1
    
    ; Check q pressed
    CMP AL, 51H
    JE exit 
   
    ; Check Q presssed
    CMP AL, 71H
    JE exit
    
    INC num1_fill
 
    ; Check "." pressed  
    CMP AL, 2EH
    JE find_dot1 
    
    ; Check valid "-" pressed            
    MOV AH, 0H            
    CMP AL, 2DH
    
    MOV BL, AL
    XOR BL, num1_fill
 
    CMP BL, 2CH
    JE save_sign1            
    
    ; Check other character pressed
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
    ; Save "-" pressed
    MOV num1_sign, 0FFFFH
    
    JMP get_num1
    
change_sign1:
    ; Load num1 to AX, DX
    MOV AX, [num1_int]
    MOV DX, [num1_int+2]
 
    ; Set sign     
    IMUL num1_sign 
    
    ; Load AX, DX to num1
    MOV [num1_int], AX
    MOV [num1_int+2], DX 
    
    RET        

add_int1:
    ; Save input char in CL
    MOV CL, AL                
    SUB CL, 30H
    
    ; Load num1 to AX, DX
    MOV AX, [num1_int] 
    MOV DX, [num1_int+2]
    
    ; Shift to left
    IMUL ten
    
    ; Add input 
    ADD AL, CL
    
    ; Load AX, DX to num1
    MOV [num1_int], AX 
    MOV [num1_int+2], DX
    
    JMP get_num1

find_dot1: 
    ; Check valid "."
    CMP num1_dot, 0H
    JNE invalid_num1
    
    ; Save "." position
    MOV num1_dot, DI
    
    JMP get_num1 
    
save_dot1:
    CMP num1_dot, 0H
    JE main
    
    ; Find true "." position in num1_dot
    SUB DI, num1_dot
    
    ; x in -1
    ;MOV AX, DI
    ;MOV BH, 0FFH
    
    ;IMUL BH
    
    ; Save "." position
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
    
    MOV AH, 0H            
    CMP AL, 2DH
    
    MOV BL, AL
    XOR BL, num2_fill
 
    CMP BL, 2CH
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
    MOV AX, [num2_int]
    MOV DX, [num2_int+2]
    
    IMUL num2_sign    
    
    MOV [num2_int], AX    
    MOV [num2_int+2], DX
    
    RET

add_int2:
    MOV CL, AL                
    SUB CL, 30H
    
    MOV AX, [num2_int]   
    MOV DX, [num2_int+2]
    
    IMUL ten
    
    ADD AL, CL
    
    MOV [num2_int], AX 
    MOV [num2_int+2], DX
    
    JMP get_num2

find_dot2:
    CMP num2_dot, 0H 
    JNE invalid_num2

    MOV num2_dot, DI
    
    JMP get_num2  
    
save_dot2:
    CMP num2_dot, 0H
    JE main
    
    ; Find true "." position in num1_dot
    SUB DI, num2_dot
    
    ; x in -1
    ;MOV AX, DI
    ;MOV BH, 0FFH
    
    ;IMUL BH
    
    ; Save "." position
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
    ; Get input
    MOV AH, 01H
    INT 21H
    
    ; Exit if operator enter
    CMP op, 0H
    JNE main 
 
    ; Save operator        
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
    
    ; Check for "q", "Q"
    CMP AL, 51H
    JE exit 
    
    CMP AL, 71H
    JE exit
    
    ; Request operator if other chars enter                
    MOV op, 0H                
    JMP main
        

clear_screen:
    ; Clearing dot screen
    PUSHA
    MOV AH, 0x00
    MOV AL, 0x03
    INT 0x10
    POPA 
    
    RET
    
print_dot:
    ; Move powers to BX
    MOV [tmp], AX
    MOV [tmp+2], DX
    
    ; Print dot_msg
    LEA DX, dot_msg
    MOV AH, 09H
    INT 21H               
    
    ; Load and print power
    MOV AX, [tmp]   
    
    MOV DI, 10H
    
    CALL print_num
    
    RET
    
prepare:
    CMP CL, 0H
    JE prepare_num1 
    
    CMP CL, 01H
    JE prepare_op
    
    CMP CL, 02H
    JE prepare_num2
    
    ; Print " = " 
    MOV AH, 02H
    MOV DL, 20H
    INT 21H
    
    MOV DL, 3DH
    INT 21H
    
    MOV AH, 02H
    MOV DL, 20H
    INT 21H
    
    JMP calculate

    
prepare_num1:
    ; Change flag 
    MOV CL, 01H
    
    MOV AH, 02H
    MOV DL, 0AH
    INT 21H
    
    ; Load and print num1
    MOV AX, [num1_int]
    MOV DX, [num1_int+2]
    
    MOV DI, num1_dot
    
    CALL print_num
    
    ;MOV AX, [num1_dot]
    ;MOV DX, [num1_dot+2]
    ;CALL print_dot
    
    JMP prepare
               
prepare_num2:
    MOV CL, 03H
    
    MOV AX, [num2_int]
    MOV DX, [num2_int+2]
    
    MOV DI, num2_dot                 
                     
    CALL print_num
                   
    ;MOV AX, [num2_dot]
    ;MOV DX, [num2_dot+2]
    ;CALL print_dot
    
    JMP prepare
   
prepare_op:
    ; Print operator
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
    ; Load num1_dot to AX
    MOV AX, num1_dot 
                    
    ; Find larger "." index                    
    CMP AX, num2_dot
    JG res_dot_1 
    
    JMP res_dot_2  
    
res_dot_1:
    ; Set num1_dot as result_dot index
    MOV AX, num1_dot
    MOV res_dot, AX 
    
    ; Get 2 dots difference
    SUB AX, num2_dot       
    
    ; Save original dot index
    MOV DI, num1_dot
    MOV num1_dot_, DI
    MOV DI, num2_dot
    MOV num2_dot_, DI
    
    ; Set num2 dot index
    ADD num2_dot, AX
    
    ; Save dif in DI
    MOV DI, AX
    
    ; Load num2_int in DX, AX
    MOV AX, [num2_int]
    MOV DX, [num2_int+2]
    
    MOV BL, 0AH
    ; Start shifting num2                   
    JMP shift1
    
shift1:
    ; Check end condition
    CMP DI, 0H
    
    ; Load AX, DX to num2_int
    MOV [num2_int], AX
    MOV [num2_int+2], DX   
    
    
    MOV CL, 0H
    JE prepare
    
    CALL change_dot_dif
    
    ; Shift AX, DX
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
    
    MOV DI, AX
    
    MOV AX, [num1_int]
    MOV DX, [num1_int+2]
    
    MOV BL, 0AH    
       
    JMP shift2

shift2:
    CMP DI, 0H
    MOV [num1_int], AX
    MOV [num1_int+2], DX
    
    MOV CL, 0H    
    JE prepare
    
    CALL change_dot_dif
    
    IMUL BL
    
    JMP shift2 
    
change_dot_dif:
    CMP DI, 0H 
    ; DEC if DI > 0
    JG dec_dot
    ; INC if DI < 0
    INC DI
    
    RET
    
dec_dot:
    DEC DI
    
    RET    
        
    
calculate:
    ; Check operator
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
    ; Load num1_int to AX, DX
    MOV AX, [num1_int]
    MOV DX, [num1_int+2]
    
    ; Perform operator
    ADD AX, num2_int
    
    ; Load AX, DX to res_int
    MOV [res_int], AX
    MOV [res_int+2], DX
    
    JMP print_res           

minus:
    MOV AX, [num1_int]
    MOV DX, [num1_int+2]
    
    SUB AX, num2_int
    
    MOV [res_int], AX
    MOV [res_int+2], DX
    
    JMP print_res
    
multiply:
    MOV AX, [num1_int]
    MOV DX, [num1_int+2]
    
    IMUL num2_int
    
    MOV [res_int], AX
    MOV [res_int+2], DX
    
    ; Set result dot index
    MOV AX, num1_dot
    ADD AX, num2_dot
    MOV res_dot, AX        

    JMP print_res
    
__divide:  
    ; Check for divide on zero
    CMP num2_int, 0H
    JE print_error  
    
    MOV AX, [num1_int]
    MOV DX, [num1_int+2]
    
    IDIV num2_int
    
    MOV [res_int], AX
    
    ; Set result dot index 
    MOV AX, num1_dot
    SUB AX, num2_dot
    MOV res_dot, AX
                   
    JMP print_res  

divide:
    CALL check_divide
    JZ print_error
    
    MOV AX, [num1_int]
    MOV DX, [num1_int+2]
    CALL division  
    
    MOV [res_int], AX
    MOV [res_int+2], DX
    
    ; Set result dot index 
    MOV AX, num1_dot
    SUB AX, num2_dot
    MOV res_dot, AX
                   
    JMP print_res  

mode:
    CALL check_divide
    JZ print_error
              
    MOV AX, [num1_int]
    MOV DX, [num1_int+2]
    
    CALL division
    
    MOV res_int, BX
    
    JMP print_res 
    
division:
    ;;;;
    MOV [tmp], AX
    MOV [tmp+2], DX
    
    MOV [tmp1], 0H
    MOV [tmp1+2], 0H     
    
    ;;;;      
    MOV AL, b.[tmp+3]
    MOV AX, 0H
    XOR DX, DX
    DIV [num2_int]
    MOV b.[tmp1+3], AL
    ;;;;      
    MOV AL, b.[tmp+2]
    MOV AH, DL
    XOR DX, DX
    DIV ten
    MOV b.[tmp1+2], AL
    ;;;;      
    MOV AL, b.[tmp+1]
    MOV AH, DL
    XOR DX, DX
    DIV [num2_int]
    MOV b.[tmp1+1], AL
    ;;;;      
    MOV AL, b.[tmp]
    MOV AH, DL
    XOR DX, DX
    DIV [num2_int]
    MOV b.[tmp1], AL
    ;;;;
    
    ; Remainder to BX
    MOV BX, DX
    
    MOV AX, [tmp1]
    MOV DX, [tmp1+2]
    
    RET
    
check_divide:
    MOV AX, [num2_int]
    MOV DX, [num2_int+2]
    
    CMP DX, 0H
    JNE check_divide_
    
    CMP AX, 0H
    RET    
    
check_divide_:
    RET  
    
check_res_sign:
    
    MOV AX, [res_int]
    MOV DX, [res_int+2]
    
    TEST AX, AX
    ;JS change_res_sign
    
    RET    

change_res_sign:
    MOV BX, 0FFFFH
    IMUL BX

    RET    

print_res:
    ;CALL check_res_sign
    
    ; Load and print res_int in AX, DX
    MOV AX, [res_int]
    MOV DX, [res_int+2] 
    
    MOV DI, res_dot
    
    CALL print_num
    
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
    
print_num: 
    CALL detect_sign
    
    JMP print_nums               
           
print_nums:
    ; Check digits remains
    CMP AX, 0H
    JE check_len
    ;;;;
    MOV [tmp], AX
    MOV [tmp+2], DX
    
    MOV [tmp1], 0H
    MOV [tmp1+2], 0H     
    
    ;;;;      
    MOV AL, b.[tmp+3]
    MOV AX, 0H
    XOR DX, DX
    DIV ten
    MOV b.[tmp1+3], AL
    ;;;;      
    MOV AL, b.[tmp+2]
    MOV AH, DL
    XOR DX, DX
    DIV ten
    MOV b.[tmp1+2], AL
    ;;;;      
    MOV AL, b.[tmp+1]
    MOV AH, DL
    XOR DX, DX
    DIV ten
    MOV b.[tmp1+1], AL
    ;;;;      
    MOV AL, b.[tmp]
    MOV AH, DL
    XOR DX, DX
    DIV ten
    MOV b.[tmp1], AL
    ;;;;
    
    PUSH DX
    
    MOV AX, [tmp1]
    MOV DX, [tmp1+2]
    
    
    ; Increase digits length
    INC len
    
    JMP print_nums  
    
check_len:
    ; Check digits length
    CMP len, 0H
    
    INC len
    INC DI
    
    ; Print digits if len not 0
    JNE print_leading_zero
    
    ; If len = 0, push stack 0 and increase len
    PUSH 0H
    INC len
    
    JMP print_leading_zero
    
print_leading_zero:
    ; Compare length and dot position
    CMP len, DI
    
    ; Jump if Length > dot pose +1
    JA print_nums__       
    
    ; Push 0H (0) to stack and increase length
    PUSH 0H
    INC len
    
    JMP print_leading_zero

print_nums__:
    DEC DI
    
    JMP print_nums_

print_nums_:
    DEC len

    ; Check digits length
    CMP len, 0H
    JE end_print  
 
    CMP len, DI
    JE print_nums_dot 
    
    ; Load from stack and print
    MOV AH, 02H
    POP DX
    ADD DX, 30H
    INT 21H
    
    JMP print_nums_
    
print_nums_dot:
    MOV AH, 02H
    MOV DL, 2EH
    INT 21H
    
    ; Load from stack and print
    MOV AH, 02H
    POP DX
    ADD DX, 30H
    INT 21H
    
    JMP print_nums_    

detect_sign:
    ; Check DH fisrt bit for sign 
    CMP DH, 80H
    
    JB change_sign_pos
    
    JMP change_sign_neg    
    
change_sign_pos:
    ; If positive return
    RET
    
change_sign_neg:
    ; Load AX, DX to tmp
    MOV [tmp], AX
    MOV [tmp+2], DX

    ; Print "-" char 
    MOV AH, 02H
    MOV DL, 2DH
    INT 21H           
    
    ; Negative tmp1 
    ; Set tmp1 to 0xFFFFFFFF (-1)
    MOV [tmp1], 0FFFFH
    MOV [tmp1+2], 0FFFFH
    
    ; Load tmp to AX, DX
    MOV AX, [tmp]
    MOV DX, [tmp+2]
  
    ; tmp1 - tmp  
    SUB [tmp1], AX
    SUB [tmp1+2], DX
    
    ; tmp++
    INC tmp1
    
    ; Load tmp1 to AX, DX
    MOV AX, [tmp1]
    MOV DX, [tmp1+2] 
    
    RET        
    
end_print:
    RET  
    
exit:    
    END
    
