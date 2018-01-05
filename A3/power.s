#---------------------------------------------------------------
# Assignment:           3
# Due Date:             Mar 11, 2016
# Name:                 Canopus Tong
# Unix ID:              canopus
# Lecture Section:      B1
# Lab Section:          H01 (Monday 2:00pm-4:50pm)
# Teaching Assistant(s):   Parisa Mohebbi
#---------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------
# The main program gets inputs from users for X and N. $a1 = N and $a0 = X.
# It creates a stack and $a0 will be the base address for stack pointer.
# Then it pushes $a1 and $a0 into the stack.
# After that it calls powXN.
#---------------------------------------------------------------------------------------------------------------------------
# -------------------- Data Segment ------------------------
		.data
result: 	.word 0 				# stores ’result’
str: .asciiz " Enter X: "
str1: .asciiz " Enter N: "
result1: .asciiz " Result: "
startdash: .asciiz "\n\n                    =============================="
enddash: .asciiz "\n                    ==============================\n"
dash: .asciiz "\n                    ------------------------------"
address: .asciiz "\n address "
equal_sign: .asciiz " |        $sp = " 
# -------------------- Text Segment ------------------------
		.text
main:	
		#------------------------ Implement a stack ---------------------
		addi $a0 ,$sp, 0 			# $a0 = base $sp saddress
		addi $s0, $a0, -4
		addi $sp, $sp, -4			# allocate stack frame
		
		#---------------------------------- User Input --------------------------------------------------------
		la $a0,str				#---------------------------
		li $v0,4
		syscall
		li $v0,5
		syscall
		move $t0,$v0				#	get X and N
		la $a0,str1
		li $v0,4
		syscall
		li $v0,5
		syscall					#---------------------------
		move $a1,$v0    			# $a1=N    
		move $a0, $t0    			# $a0=X
		# ------------------------------------------------------------------------------------------------------

		sw $a1, 0($sp)				# push N
		addi $sp, $sp, -4	
		sw $a0, 0($sp)				# push X
		
		jal powXN					# call powXN
	
		#------------------------------------- Exit Procedure --------------------------------------------------
		exit:						
			li $v0, 10				# exit
			syscall
		#-------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------
# Subroutine powXN calculate X^N. Store the result of each recursion to stack.
# Base Case 1: if N == 0; result = 1
# Base Case 2: if N == 1: result = X
#				else: Do the recursion
# Call procedure clear_reg after recursion is done.
#
# Inputs: $a0 = X, $a1 = N, $a2 = address of result
#		
# Register Usage
#
#       t9: temp. variable to transfer values
#       sp: store and retrieve values
#----------------------------------------------------------------------
powXN:  
		#------------------------- Base Case 1 ---------------------------------
		bne $a1, $zero, else			# goto else if N != zero

		addi $t9, $zero, 1				# $t9 = 1 if N = zero
		#---
		addi $sp, $sp, -4
		sw $t9, 0($sp)					# push result	
		#---
		jal clear_reg
		#------------------------- Base Case 2 -------------------------------------------
else:		
		bne $a1, 1, else1				# goto else1 if N != 1
		jal clear_reg						
		#---------------------------------------------------------------------
else1:
		addi $a1, $a1, -1
		lw $t9, 0($sp)				
		mul $t9, $t9, $a0
		addi $sp, $sp, -4
		sw $t9, 0($sp)					# push result	
		jal powXN						# recursion


#----------------------------------------------------------------------
# Subroutine clear_reg clears Register $a0 to $a3.
# Call print_frame at the end.
#		
# Inputs: $a0, $a1, $a2, $a3
#----------------------------------------------------------------------
clear_reg:
		addi $a0, $zero, 0
		addi $a1, $zero, 0
		addi $a2, $zero, 0
		addi $a3, $zero, 0

		jal print_frame		
#----------------------------------------------------------------------
# Subroutine print_frame prints a powXN stack frame pointed to by register $sp. 
#
# Inputs: $sp
#
# Other Registers used are for syscall (printing) and transfer values.
#----------------------------------------------------------------------
print_frame:
		la $a0, result1
		li $v0, 4
		syscall
		lw $t9, 0($sp) 
		move $a0, $t9			
		li $v0, 1				# print result
		syscall
		
		
		la $a0, startdash		# print =====
		li $v0,4
		syscall

		#-------- loop to print all stacks ---------
		while:
				beq $s0, $sp, exit1

				la $a0, address
				li $v0, 4
				syscall

				move $a0, $sp			# $a0 is the value
				li $v0, 1				# print result
				syscall

				la $a0, equal_sign
				li $v0, 4
				syscall

				lw $a0, 0($sp)			# $a0 is the value
				li $v0, 1				# print result
				syscall

				la $a0, dash
				li $v0, 4
				syscall

				addi $sp, $sp, 4	
				

				j while
		#-------------------------------------------

		exit1:
				
				la $a0, address
				li $v0, 4
				syscall

				move $a0, $sp			# $a0 is the value
				li $v0, 1				# print result
				syscall

				la $a0, equal_sign
				li $v0, 4
				syscall

				lw $a0, 0($sp)			# $a0 is the value
				li $v0, 1				# print result
				syscall



				la $a0, enddash			# print =====
				li $v0,4
				syscall

				j exit