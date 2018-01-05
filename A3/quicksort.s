#--------------------------------------------------------------------------------------------------------------------------
# Assignment:           3
# Due Date:             Mar 11, 2016
# Name:                 Canopus Tong
# Unix ID:              canopus
# Lecture Section:      B1
# Lab Section:          H01 (Monday 2:00pm-4:50pm)
# Teaching Assistant(s):   Parisa Mohebbi
#---------------------------------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------------------------------------------
# The main program first finds N,  length of List. Set first = 0 and last = N-1 which are $a1 and $a2.
# It also make a copy of $a2 to $s1 for future uses.
# Then push first and last into $sp.
# After that, it calls procedure qsort. 
#---------------------------------------------------------------------------------------------------------------------------

# -------------------- Data Segment ----------------------------------------------------------------------------------------
	.data
# L is a 0-terminated list (at most 20 numbers, excluding the last 0)

L:			.half 10, 30, 20, 15, 8, 7, 5, 0
			.align 1 								# align on a halfword boundary
space:		.asciiz " "
# -------------------- Text Segment ----------------------------------------------------------------------------------------
	.text
main:		
		la $a0, L								# Load Addr of List into $a0
		move $a1, $zero								# $a1 = 0
		
		li $a2, 0								# $a2 = index 0
		add $t1, $a2, $a0							# $t1 = current address
		lh $t4, 0($t1)								# $t4 = L[0]
		
		while:
			beq $t4, $zero, exit				
			addi $a2, $a2, 1
			add $t1, $t1, 2							# $t1 = next index address	
			lh $t4, 0($t1)							# $t4 = L[n+1]
						
			
			j while
		exit:

		addi $t5, $sp, 0							# t5 is base sp addr

		addi $s1, $a2, 0							# $s1 = n-1
		sub $a2, $a2, 1								# $a2 = n-1

		addi $sp, $sp, -8							# push
		sw $a1, 0($sp)
		sw $a2, 4($sp)
		
		jal qsort								# call qsort





#----------------------------------------------------------------------
# Subroutine qsort pop the top stack and assign it as first and last.
#
# Inputs: $t5 = base address of S 
#   
# Register Usage
#
#       t5: $sp default address
#       sp: access values from the stack
#       t6: first index of List
#       t7: last index of List
#----------------------------------------------------------------------
# ----------------------
# procedure 'qsort'
# $a1 is first, $a2 is last

qsort: 	
		while1:
			beq $t5, $sp, exit1						# stack is  empty
			lw $t6, 0($sp)
			lw $t7, 4($sp)
			addi $sp, $sp, 8						# pop()

			jal split							# call split
			j while1
		exit1:
        		jal print_list

#----------------------------------------------------------------------
# Subroutine split select L[first] as pivot
#                  
# Inputs: $t6 = first, and $t7 = last
#
# Register Usage
#
#       t6: first index of List
#       t7: last index of List; t7-- (new last index)
#	a1: a copy of original t6 (first)
#	a2: a copy of original t7 (last); to be pushed into stack
#	a3: the pivot
#	t4: index increment for address of the pivot
#	a0: address of L
#	s6: splitpoint + 1; to be pused into stack
#----------------------------------------------------------------------
# ---------------------
# procedure 'split'

split:   	
		while2:
			bge $t6, $t7, exit2						# exit if first>=last
			
			addi $a1, $t6, 0						# $a1 = $t6 original
			addi $a2, $t7, 0						# $a2 = $t7 original			
			
			add $t4, $t6, $t6						# $t4 = first*2
			add $t1, $a0, $t4
			lh $a3, 0($t1)							# $a3 = L[first]...x=pivot
			
			jal sort							# List is sorted by pivot
			
			addi $s6, $t0, 1	
			addi $sp, $sp, -8						# push
			sw $s6, 0($sp)
			sw $a2, 4($sp)
			
			addi $t7, $t0, -1
			
			addi $t6, $a1, 0
			#-----------------------------------------------
			
			j while2
		exit2:
        		j while1


#----------------------------------------------------------------------
# Subroutine sort pivot the List and find the splitpoint.
#               
# Inputs: refer to split
#  
# Register Usage
#
#       t6: first index of List
#       t7: last index of List
#	t1,t4,t8 : tempoary values/addr
#	t2: L[last]
#	t3: L[first]
#	t9: copy of t1
#----------------------------------------------------------------------
# ---------------------
# procedure 'sort'

sort:
		while3:
			beq $t6, $t7, exit3						# exit if first = last
			add $t4, $t7, $t7
			add $t1, $a0, $t4
			lh $t2, 0($t1)							# $t2 = L[last]
			slt $t8, $t2 , $a3
			bne $t8, $zero, else1

			add $t4, $t6, $t6
			add $t1, $a0, $t4
			lh $t3, 0($t1)							# $t3 = L[first]
			slt $t8, $a3, $t3
			bne $t8, $zero, else2
			
			add $t4, $t7, $t7
			add $t1, $a0, $t4
			lh $t2, 0($t1)							# $t2 = L[last]			
			slt $t8, $a3, $t2
			bne $t8, $zero, else3

			add $t4, $t6, $t6
			add $t1, $a0, $t4
			lh $t3, 0($t1)							# $t3 = L[first]
			slt $t8, $t3, $a3
			bne $t8, $zero, else4
			
			j while3
		exit3:
			li $t0, 0							# set $t0 to zero
			addi $t1, $a0, 0						# set $t1 to $a0
			lh $t4, 0($t1)
			while4:
				beq $a3, $t4, exit4					# exit if pivot = splitpoint
				addi $t0, $t0, 1
				add $t1, $t1, 2						# $t1 = next index address
				lh $t4, 0($t1)						# $t4 = L[n+1]

				j while4
		exit4:
			jr $ra
# ---------------------------------------------------------------------------------------------------------
# if L[last] < pivot; swap these two and first++;
# ---------------------------------------------------------------------------------------------------------
# procedure 'else1'

else1: 		
		addi $t9, $t1, 0
		add $t4, $t6, $t6
		add $t1, $a0, $t4
		sh $t2, 0($t1)
		sh $a3, 0($t9)		

		addi $t6, $t6, 1							# first++		

		j while3
# ---------------------------------------------------------------------------------------------------------
# if L[lfirst] > pivot; swap these two and last--;
# ---------------------------------------------------------------------------------------------------------
# procedure 'else2'

else2:    	
		addi $t9, $t1, 0
		add $t4, $t7, $t7
		add $t1, $a0, $t4
		sh $t3, 0($t1)
		sh $a3, 0($t9)

		addi $t7, $t7, -1

        	j while3
# ---------------------------------------------------------------------------------------------------------
# if pivot < L[last]; last--;
# ---------------------------------------------------------------------------------------------------------
# procedure 'else3'

else3:
		addi $t7, $t7, -1

		j while3
# ---------------------------------------------------------------------------------------------------------
# if L[first] < pivot; first++;
# ---------------------------------------------------------------------------------------------------------
# procedure 'else4'

else4:	

		addi $t6, $t6, 1

		j while3

#----------------------------------------------------------------------
# Subroutine print_list print to finalized List in data segment and terminate quicksort.s.
#   
# Inputs: $a0 = base address of L, and $s1 = n
#             
# Register Usage
#
#   a0: halfword in new stack
#	s2: s2++ until it reaches N, like a counter
#	s5: s5=s5+2. address to load the next halfword in new stack.
#	s1: N, the length of List
#----------------------------------------------------------------------
# ---------------------
# procedure 'print_list'

print_list:		
		li $s2, 0
		add $s5, $a0, 0
		lh $a0, 0($s5)

		while5:
			beq $s2, $s1, exit10				
			
			li $v0, 1							# print the halfword
			syscall
			la $a0, space							# print a spacing between each halfword
			li $v0, 4
			syscall
			
			addi $s5, $s5, 2
			addi $s2, $s2, 1


			lh $a0, 0($s5)							# get the next halfword
			
		
			j while5

		exit10:

			li $v0, 10							# exit
			syscall



			








