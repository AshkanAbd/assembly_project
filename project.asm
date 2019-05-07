.model calculator

.stack  

.data          
num1_req_msg DB "Enter first number: $"
num2_req_msg DB "Enter second number: $"  
op_req_msg DB "Enter operator: $"  

num1 DB 7 dup("0")
num2 DB 7 dup("0")
result DB 7 dup(0)
op DB 0H, 0H   

num1_len DW 1 dup(0H)
num2_len DW 1 dup(0H)
res_len DW 1 dup(0H)

num1_x DW 6H
num2_x DW 6H
res_x DW 7H 
dot1_x DW 6H 
dot2_x Dw 6H


.code 

MOV AX, @data
MOV DS, AX

MOV DL, 10
MOV BL, 0 

        
get_nums:                 
    CMP num1_len, 0H
    JE req_num1
    
    CMP num2_len, 0H
    JE req_num2
    
    CMP op , 0H
    JE req_op 
    
    JMP calculate
    
   
req_num1:        
    LEA DX, num1_req_msg
    MOV AH, 09H   
    
    INT 21H
    JMP scan_num1
        
scan_num1:
    MOV AH, 1H
    INT 21h
    
    CMP AL, 13 
    JE clear_screen
    
    INC num1_len
    MOV DI, 0H
    
    JMP shift1 
 
shift1:
    CMP DI, 6H
    JE fill_num1
    
    MOV BL, num1[DI+1] 
    MOV num1[DI], BL
    INC DI
    
    JMP shift1 

fill_num1:
    MOV num1[5], AL

    JMP scan_num1                

req_num2:        
    LEA DX, num2_req_msg
    MOV AH, 09H   
    INT 21H
    
    JMP scan_num2
    
scan_num2:
    MOV AH, 1H
    INT 21h
    
    CMP AL, 13     
    JE clear_screen  
 
    INC num2_len
    MOV DI, 0H
    
    JMP shift2 
    
shift2:
    CMP DI, 6H
    JE fill_num2
    
    MOV BL, num2[DI+1]
    MOV num2[DI], BL
    INC DI
    
    JMP shift2 
    
fill_num2:
    MOV num2[5], AL
    
    JMP scan_num2           

req_op:    
    LEA DX, op_req_msg
    MOV AH, 09H   
    INT 21H
    
    JMP scan_op
    
scan_op:
    MOV DI,0H
    MOV AH, 1H
    INT 21h 
    
    CMP op, 0H           
    JNE clear_screen 
                                        
    MOV op[0], AL        
    MOV op[1], "$"
    
    JMP scan_op

clear_screen:
    PUSHA
    MOV AH, 0x00
    MOV AL, 0x03
    INT 0x10
    POPA  
    JMP get_nums
           
calculate:
    CMP op, "+"
    JE plus
    
    CMP op, "-"
    JE minus
    
    CMP op, "*"
    JE multiply
    
    CMP op, "/"
    JE divide
    JMP exit          

plus:
    MOV DI, 0H 
    JMP find_num1

find_num1:
    CMP DI, 6H
    JE find_num2
    
    MOV AL, num1[DI]
    CMP AL, 2EH
    JE save_dot1
    
    INC DI 
    JMP find_num1
    
find_num2:
    CMP DI, 6H
    JE plus_num1
    
    MOV AL, num2[DI]
    CMP AL, 2EH
    JE save_dot2
    
    INC DI
    JMP find_num2
    
save_dot1:
    MOV dot1_x, DI
    
    JMP find_num2
    
save_dot2:
    MOV dot2_x, DI
    
    JMP plus_num1    
    
plus_num1:
    CMP num1_x, 0H
    JE print   
    
    MOV DI, num1_x
    MOV AL, num1[DI-1]
    
    DEC num1_x
    DEC res_x
    
    CMP AL, 0H
    JE plus_num2
    
    SUB AL, 48
    MOV DI, res_x
    ADD AL, result[DI]
    
    CMP AL, 0AH
    JNB carry_sum1
   
    MOV result[DI], AL
    JMP plus_num2
     
     
plus_num2:
    MOV DI, num2_x
    MOV AL, num2[DI-1]
    
    DEC num2_x
    
    CMP AL, 0H
    JE plus_num1
    
    SUB AL, 48
    MOV DI, res_x
    ADD AL, result[DI]
    
    CMP AL, 0AH
    JNB carry_sum2
    
    MOV result[DI], AL
    JMP plus_num1      
    

carry_sum1:
    MOV BL, AL
    SUB BL, 0AH
    MOV DI, res_x  
    
    INC result[DI-1]
    MOV result[DI], BL
    
    JMP plus_num2

carry_sum2:
    MOV BL, AL
    SUB BL, 0AH
    MOV DI, res_x  
    
    INC result[DI-1]
    MOV result[DI], BL
    
    JMP plus_num1
          
minus:
    JMP print
    
multiply:
    JMP print
    
divide:
    JMP print
    

print:
    MOV num1[6], "$"        
    LEA DX, num1 
    MOV AH, 09H
    INT 21H 
    
    LEA DX, op
    MOV AH, 09H
    INT 21H
    
    MOV num2[6], "$"
    LEA DX, num2 
    MOV AH, 09H
    INT 21H

    MOV AH, 02H
    MOV DL, ":"
    INT 21H
    
    MOV DI, 0H
    JMP print_result
    
print_result: 
    CMP DI, 7H
    JE exit
    
    MOV AH, 02H
    MOV DL, result[DI] 
    ADD DL, 48
    INT 21H
    
    INC DI
    JMP print_result
     
exit:
    END     
        
     
