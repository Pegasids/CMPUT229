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
msg_prompt:	.asciiz "\n? "
msg_length:	.asciiz "length= "
length:		.word	0
buff:		.space 81

# -------------------- Text Segment ------------------------
		.text
main:		jal 	getstr		# get input string

		jal	getlen		# get string length
		sw	$v0, length	# store length

		la	$a0, msg_length # print length
		li	$v0, 4
		syscall

		lw	$a0, length
		li	$v0, 1
		syscall

		lw	$t1, length	# $t1 = length
loop:		addi	$t1, -1		# $t1 = $t1 -1
		bltz 	$t1, next	# if (t1 < 0) goto next
#
#		... loop body ...
#
		b loop
next:	
		jal 	print_NL	# print newline

		li	$v0, 10		# exit
		syscall
# ---------------------
# procedure 'getstr'
getstr:
prompt:		la	$a0, msg_prompt	# display prompt
		li	$v0, 4		# print string
		syscall

		la	$a0, buff	# load buff into $a0
		li	$a1, 81		# read 80 max spaces
		li	$v0, 8		# read string
		syscall

		jr	$ra		# return to main
# procedure 'getlen'
getlen:
 		li	$t1, 0		# count $t1 = 0
loop2:		lb	$t0, 0($a0)	# load $a0 into index($t0)
		beqz	$t0, exit	# exit if ......something
		beq	$t0, 0xD, exit	
		beq	$t0, 0xA, exit
		addi	$a0, $a0, 1	# $a0++ (index)
		addi	$t1, $t1, 1	# $t1++ (counter)
		j	loop2		# loop
exit:
		addi	$v0, $t1, 0	# move
		jr	$ra		# return from procedure
# ---------------------
# procedure 'print_NL'
print_NL:
		li	$a0, 0xA	# load new line character
		li	$v0, 11		
		syscall

		jr	$ra		# return to main
# ----------------------------------------------------------
	
