#--------------------------------------------------------------------------------------------------------------------------
# Assignment:           4
# Due Date:             Apr 1, 2016
# Name:                 Canopus Tong
# Unix ID:              canopus
# Lecture Section:      B1
# Lab Section:          H01 (Monday 2:00pm-4:50pm)
# Teaching Assistant(s):   Parisa Mohebbi
#---------------------------------------------------------------------------------------------------------------------------
#     - Must Run with Memory-Mapped I/O and the modified Exception response code.
#---------------------------------------------------------------------------------------------------------------------------

	  .data
s_v0:     .word 0
s_a0:     .word 0

str1:	  .asciiz  " input string= "
str2:	  .asciiz  ", x= "
str3:     .asciiz  "\n"

buffer:   .space 240
#--------------------------------------------------------------------------------------------
# The main function enable keyboard interrupts, global interrupts and timer. 
# Register used:
#		$t3= 4   (fixed; used for div to calcuated length of input)
#		$s2= 100 (for moding 100)
#		$t7 = 60
#		$t8 = 1
#		$a1 = current buffer address, will be increased to store and read characters
#		$a2 = default buffer address
#--------------------------------------------------------------------------------------------
	  .text
main:
	 # Enable keyboard interrupts	  
	 li	$a3, 0xffff0000        # base address of I/O
	 li	$s1, 2		       # $s1= 0x 0000 0002
	 sw 	$s1, 0($a3)	       # enable keyboard interrupts

	 # Enable global interrupts
	 li	$s1, 0x0000ff01	       # set IE= 1 (enable interrupts) , EXL= 0
	 mtc0	$s1, $12	       # SR (=R12) = enable bits

	 # Start timer
         mtc0  $0, $9                  # COUNT = 0
         addi  $t0, $0, 50             # $t0 = 50 ticks
         mtc0  $t0, $11                # CP0:R11 (Compare Reg.)= $t0

	 li $t3, 4				# $t3 = 4 (fixed; used for div to calcuated length of input)
	 li $s2, 100			# $s2 = 100 (for moding 100)
	 li $t7, 60				# $t7 = 60
	 li $t8, 1				# $t8 = 1
	 la $a1, buffer			# Store buffer address to $a1
	 la $a2, buffer			# $a2 = default buffer address


loop:	 beq  $t0,$t0, loop	       # infinite loop

# ------------------------------------------------------------
# lab4_handler - example interrupt handler
#   Entry Conditions:
#       - CPU is still in the Exception Mode (EXL= 1)
#       - EPC has a restart address
# ------------------------------------------------------------	

        .globl  lab4_handler   

lab4_handler:

	# Save $at, $v0, and $a0
	#
	.set noat
	move $k1 $at		# Save $at
	.set at
	sw   $v0 s_v0		# Not re-entrant and we can't trust $sp
	sw $a0, s_a0		# But we need to use these registers

	# Identify the interrupt source
	#
	mfc0   $k0, $13		# $k0 = Cause Reg (R13)

	srl    $a0, $k0, 11	# isolate IP3 (interrupt bit 1) (for keyboard)
	andi   $a0, 0x1
	bgtz   $a0, do_keyboard

	srl    $a0, $k0, 15	# isolate IP7 (interrupt bit 5) (for timer)
	andi   $a0, 0x1
	bgtz   $a0, do_timer

	b      lab4_handler_ret # ignore other interrupts

#----------------------------------------------------------------------------------------------------------------
# do_keyboard reads keyboard input and store it in buffer.
#	input: 0xffff0004 (key register),  $a1 (current buffer address)
#
#	register used: 
#			$t2= 0xffff004
#			$t4= current key			
#----------------------------------------------------------------------------------------------------------------
do_keyboard:
#----------------------------------------------------------------------------------------------------------------
	li $t2, 0xffff0004		# $t2 = key address
	lw $t4, 0($t2)			# $t4 = current key

	sw $t4, 0($a1)			# store key $t4 as a word
	addi $a1, $a1, 4		# increase buffer address by 4
	
	b      lab4_handler_ret

#---------------------------------------------------------------------
# maxlen set length to 60 if length > 60.
#	input: $t1 (length of input)
#
#---------------------------------------------------------------------
maxlen:
	li $t1, 60				# set length of input to 60
	j $ra

#------------------------------------------------------------------------------------------------------------------------------------
# do_timer is a function for printing the output every time the timer ticks. 
# So it will print the string the user typed and X, the random number.
#
#	input:	$a1 (current buffer address), $a2 (default buffer address), $t3 (= 4), $t7 (= 60), $t8 (= 1), $s2 (= 100)
#
#	register used:
#			$t5 = counter
#			$s0 = partialy randomized number (not the final result)
#			$t1 = length of input
#			$t6 = truth value for slt (can be 0 or 1)
#------------------------------------------------------------------------------------------------------------------------------------
do_timer:
#------------------------------------------------------------------------------------------------------------------------------------
	sub  $t1, $a1, $a2						# $t1 = length of input * 4
	div  $t1, $t3							# $t1/4
	mflo $t1								# $t1 = length of input

	slt  $t6, $t7 ,$t1						# if length of input > 60, call maxlen
	beq  $t6, $t8, maxlen


	
	la	 $a0, str1;  li $v0,4; syscall		# print " input string= "
	li 	 $a0, '"';   li $v0, 11; syscall	# print "
	
	li   $t5, 0								# counter $t5 = 0 (for start_print_str)
	addi $a1, $a2, 0						# set $a1 back to buffer address
	li   $a0, 0								# $a0 = 0
	li   $s0, 0								# $s0 = 0

	jal start_print_str						# call start_print_str to print str that is entered

start_print_str:							# Start of loop: a loop to print string and calculate the random number.

	add $s0, $s0, $a0						# randomizer
	add $s0, $s0, $t5						# randomizer
	beq  $t5, $t1, end_print_str			# if $t5 = $t1, goto end_print_str (if counter = length of input)
	lw   $a0, 0($a1)					    # load each key into $a0
	li $v0, 11; syscall						# print each key
	addi $a1, $a1, 4						# increase $a1 by 4
	addi $t5, $t5, 1						# counter + 1

	j start_print_str						# loop back


end_print_str:								# End of loop
	li 	 $a0, '"';   li $v0, 11; syscall	# print "
	la	 $a0, str2;  li $v0,4; syscall		# print ", x= " 
	div  $s0, $s2							# $s0 mod 100  # randomizer
	mfhi $s0								# load remainder into $s0  # randomizer
	mul $s0, $s0, $s0						# $s0 = $s0 ^2  # randomizer
	div  $s0, $s2							# $s0 mod 100  # randomizer
	mfhi $a0								# load remainder into $a0  # randomizer
	li $v0,1; syscall						# print X
	la	 $a0, str3;  li $v0,4; syscall		# print "\n"
	
	addi $a1, $a2, 0						# set $a1 back to buffer address


	# Restart timer
        mtc0  $0, $9                          # COUNT = 0
        addi  $t0, $0, 50                     # $t0 = 50 ticks
        mtc0  $t0, $11                        # CP0:R11 (Compare Reg.)= $t0

	b   lab4_handler_ret
#------------------------------------------------------------------------------------------------------------------------------------
lab4_handler_ret:
	lw  $v0  s_v0		# restore $v0, $a0, and $at
	lw  $a0, s_a0

	.set noat
	move $at $k1		# Restore $at
	.set at

	mtc0 $0 $13		# Clear Cause register

	mfc0  $k0 $12		# Set Status register
	ori   $k0 0x1		# Interrupts enabled
	mtc0  $k0 $12
	
	eret			# exception return
#------------------------------------------------------------------------------------------------------------------------------------
