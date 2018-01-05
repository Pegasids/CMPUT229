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
end_msg:	.asciiz "end of program"
length:		.word	0
buff:		.space  81
# -------------------- Text Segment ------------------------
		.text
main:		jal 	getstr		# get input 

		jal	getlen		# get string length
		sw	$v0, length	# store length

		jal	swap		# call swap

		la	$a0, msg_length # print length
		li	$v0, 4
		syscall

		lw	$a0, length	
		li	$v0, 1
		syscall

		jal	print_NL	# print
	
		la	$a0, buff	# load buff
		li	$v0, 4		
		syscall

		la	$a0, end_msg	# print end msg
		li	$v0, 4		
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
# procedure 'swap'
swap:
		lb	$t2, length	
		li	$t3, 0		
		la 	$a1, buff
loop3:	
		lb	$t4, 0($a1)	# load char index 1
		lb	$t5, 1($a1)	# load char index 1
		sb	$t4, 1($a1)	# now swap
		sb	$t5, 0($a1)	# now swap
		addi	$a1, $a1, 2	# counter add 2
		addi	$t3, $t3, 2	# counter add 2
		blt	$t3, $t2, loop3	#check if it's end of string

		jr	$ra	# return....
	
# procedure 'getstr'
getstr:
prompt:		la	$a0, msg_prompt	# display prompt
		li	$v0, 4
		syscall

		la	$a0, buff	# read string
		li	$a1, 81
		li	$v0, 8
		syscall

		jr	$ra		# return to main
# procedure 'getlen'
getlen:
 		li	$t1, 0		# count $t1 = 0
loop2:		lb	$t0, 0($a0)	# load $a0 into index($t0)
		beqz	$t0, exit	# exit.... when newline...etc
		beq	$t0, 0xD, exit	
		beq	$t0, 0xA, exit
		addi	$a0, $a0, 1	# index++
		addi	$t1, $t1, 1	# counter++
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

		jr	$ra		# return back to main
# ----------------------------------------------------------
	
