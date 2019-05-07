.model calculator

.stack  

.data          
num1_req_msg DB "Enter first number: $"
num2_req_msg DB "Enter second number: $"  
op_req_msg DB "Enter operator: $"  

num1 DB 6 dup("0")
num2 DB 6 dup("0")
result DB 6 dup(0)
op DB 0H, 0H   

num1_len DW 1 dup(0H)
num2_len DW 1 dup(0H)

num1_x DW 5H
num2_x DW 5H
res_x DW 6H
 
dot1_x DW 5H 
dot2_x Dw 5H
res_dot_x DW 6H  

dot_offset DW 0H 

tmp DW 0H

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
    
    JMP find_num1_dot
    
   
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
    CMP DI, num1_x
    JE fill_num1
    
    MOV BL, num1[DI+1] 
    MOV num1[DI], BL
    INC DI
    
    JMP shift1 

fill_num1:
    MOV num1[4], AL

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
    CMP DI, num2_x
    JE fill_num2
    
    MOV BL, num2[DI+1]
    MOV num2[DI], BL
    INC DI
    
    JMP shift2 
    
fill_num2:
    MOV num2[4], AL
    
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
    MOV op[1], 24H
    
    JMP scan_op

clear_screen:
    PUSHA
    MOV AH, 0x00
    MOV AL, 0x03
    INT 0x10
    POPA  
    JMP get_nums


find_num1_dot:
    CMP DI, num1_x
    MOV BX, 0H
    JE find_num2_dot
    
    MOV AL, num1[DI]
    CMP AL, 2EH
    JE save_dot1
    
    INC DI 
    JMP find_num1_dot
    
find_num2_dot:
    CMP BX, num2_x
    JE reformat
    
    MOV AL, num2[BX]
    CMP AL, 2EH
    JE save_dot2
    
    INC BX
    JMP find_num2_dot
    
save_dot1:
    MOV dot1_x, DI
    
    MOV BX, 0H
    JMP find_num2_dot
    
save_dot2:
    MOV dot2_x, BX
    
    JMP reformat
    
reformat:
    MOV DI, dot1_x 
    
    CMP DI, dot2_x 
    
    MOV DI, dot2_x
    SUB DI, dot1_x
    MOV dot_offset, DI
                   
    MOV AX, dot_offset
    
    MOV DI, dot1_x
    MOV res_dot_x, DI
                          
    JNB reformat_num2
                      
    MOV DI, dot1_x
    SUB DI, dot2_x
    MOV dot_offset, DI 
    
    MOV AX, dot_offset
       
    MOV DI, dot2_x  
    MOV res_dot_x, DI
                                            
    JMP reformat_num1
    
reformat_num1:
    MOV DI, 0H
 
    CMP AX, 0H
    
    JNE shift_num1
    
    JMP fill_num1_offset
                     
reformat_num1_:
    DEC AX
    JMP reformat_num1
                         
shift_num1:    
    CMP DI, num1_x
    JE reformat_num1_
    
    MOV CL, num1[DI+1] 
    MOV num1[DI], CL
    INC DI
    
    JMP shift_num1
                     
fill_num1_offset: 
    MOV DI, res_dot_x
    MOV num1[DI], 2EH

    JMP remove_dots                  
        
reformat_num2:
    MOV DI, 0H
    
    CMP AX, 0H
    
    JNE shift_num2
    
    JMP fill_num2_offset
    
reformat_num2_:
    DEC AX
    JMP reformat_num2    

shift_num2:
    CMP DI, num2_x
    JE reformat_num2_
    
    MOV CL, num2[DI+1] 
    MOV num2[DI], CL
    INC DI
    
    JMP shift_num2

fill_num2_offset:
    MOV DI, res_dot_x
    MOV num2[DI], 2EH

    JMP remove_dots

remove_dots:
    MOV DI, res_dot_x
    JMP dot_shift1

remove_dots_:
    MOV DI, res_dot_x
    JMP dot_shift2
    
dot_shift1: 
    CMP DI, num1_x
    JE reformat_num2_
    
    MOV CL, num1[DI+1] 
    MOV num1[DI], CL
    INC DI
    
    JMP dot_shift1

dot_shift2:
    CMP DI, num2_x
    JE calculate
    
    MOV CL, num2[DI+1] 
    MOV num2[DI], CL
    INC DI
    
    JMP dot_shift2    
           
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
    MOV DI, 0H 
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
    MOV num1[5], 24H        
    LEA DX, num1 
    MOV AH, 09H
    INT 21H 
    
    LEA DX, op
    MOV AH, 09H
    INT 21H
    
    MOV num2[5], 24H
    LEA DX, num2 
    MOV AH, 09H
    INT 21H

    MOV AH, 02H
    MOV DL, ":"
    INT 21H
    
    MOV DI, 0H  
    INC res_dot_x
    JMP print_result
    
print_result: 
    CMP DI, 6H
    JE exit
    
    CMP DI, res_dot_x
    JE print_dot
    
    MOV AH, 02H
    MOV DL, result[DI] 
    ADD DL, 48
    INT 21H
    
    INC DI
    JMP print_result

print_dot:
    MOV AH, 02H
    MOV DL, 2EH
    INT 21H
    
    INC DI
    JMP print_result
     
exit:
    END     
        
     
