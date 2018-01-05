#---------------------------------------------------------------
# Assignment:           2
# Due Date:             Feb 12, 2016
# Name:                 Canopus Tong
# Unix ID:              canopus
# Lecture Section:      B1
# Lab Section:          H01 (Monday 2:00pm-4:50pm)
# Teaching Assistant(s):   Parisa Mohebbi
#---------------------------------------------------------------
# -------------------- Data Segment ------------------------
		.data
msg_1:	.asciiz "strMain? "
msg_2:	.asciiz "strOld? "
msg_3:	.asciiz "strNew? "

buff:		.space 81

# -------------------- Text Segment ------------------------
		.text
main:		jal 	strmain		# get input string strmain
		
									
		jal	strold
		

		jal 	strnew
		

		#jal	compare
		
		
		li	$v0, 10		# exit
		syscall

	

# ------------------------------------------------------------

		



# procedure 'strmain'
strmain:
prompt1:	la	$a0, msg_1	# display prompt
		li	$v0, 4		# print string
		syscall

		la	$a0, buff	# load buff into $a0
		li	$a1, 81		# read 80 max spaces
		li	$v0, 8		# read string
		syscall

		jr	$ra		# return from procedure

# ----------------------------------------------------------
# precedure 'strold'
strold:
prompt2:	la	$a0, msg_2	# display prompt
		li	$v0, 4		# print string
		syscall

		la	$t5, buff	# load buff into $a0
		li	$a1, 81		# read 80 max spaces
		li	$v0, 8		# read string
		syscall

		jr	$ra		# return from procedure
#---------------------------------------------------------------------
# precedure 'strnew'
strnew:
prompt3:	la	$a0, msg_3	# display prompt
		li	$v0, 4		# print string
		syscall

		la	$t6, buff	# load buff into $a0
		li	$a1, 81		# read 80 max spaces
		li	$v0, 8		# read string
		syscall

		jr	$ra		# return from procedure
#---------------------------------------------------------------------
# procedure 'getlen'
getlen:
 		li	$t1, 0		# count $t1 is 0
loop2:		lb	$t0, 0($a0)	# load $a0 into index($t0)
		beqz	$t0, exit	# exit if .....something
		beq	$t0, 0xD, exit
		beq	$t0, 0xA, exit
		addi	$a0, $a0, 1	# $a0 ++ (index)
		addi	$t1, $t1, 1	# $t1 ++ (counter)
		j	loop2		# loop
exit:
		addi	$v0, $t1, 0
		jr	$ra
# ---------------------

