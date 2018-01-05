#--------------------------------------------------------------------------------------------------------------------------
# Assignment:           4
# Due Date:             Apr 1, 2016
# Name:                 Canopus Tong
# Unix ID:              canopus
# Lecture Section:      B1
# Lab Section:          H01 (Monday 2:00pm-4:50pm)
# Teaching Assistant(s):   Parisa Mohebbi
#---------------------------------------------------------------------------------------------------------------------------

	  .globl pyramid

	  .data
s_v0:     .word 0
s_a0:     .word 0
#--------------------------------------------------------------------------------------------
N:	    .word  1	# width of the pyramid
K:	    .word  0	# left margin of the pyramid's base

char_fill:  .byte  '*'
char_space: .byte  ' '

str1:	    .asciiz "pyramid: "	
str2:	    .asciiz "N= "
str3:	    .asciiz ", K= "
str4:	    .asciiz "\n"
#--------------------------------------------------------------------------------------------
# The main function enable keyboard interrupts, global interrupts and timer. 
# Register used:
# 		s6= flag (0 or 1)
#		s3= 20
#		s4= 40
#		s5= turth value (0 or 1) for comparsion functions
#		t5= i
#		t6= d
#		t7= r
#		t8= l
#		t9= q
#		$a0= N
#		$t1= copy of N
#		$a1= K
#		$t2= copy of K
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
#--------------------------------------------------------------------------------------------
	 li    $s6, 0		# flag = 0; (used for one input at a time)
	 li    $s3, 20		# max N = 20	
	 li    $s4, 40		# max K = 40
	 li    $s5, 1		# $s5 truth value = 1
	 li    $t5, 105		# $t5 = i
	 li    $t6, 100		# $t6 = d
	 li    $t7, 114		# $t7 = r
	 li    $t8, 108		# $t8 = l
	 li    $t9, 113		# $t9 = q
#--------------------------------------------------------------------------------------------
	 addi  $sp, $sp, -8		# allocate frame: $a0, $a1
	 lw    $a0, N	  		# $a0= N
	 lw    $t1, N	  		# $t1= N
	 lw    $a1, K			# $a1= K
	 lw    $t2, K			# $t2= K
#--------------------------------------------------------------------------------------------

loop:	 
	 beq  $t0,$t0, loop	       # infinite loop

# ------------------------------------------------------------
# lab4_handler - example interrupt handler
#   Entry Conditions:
#       - CPU is still in the Exception Mode (EXL= 1)
#       - EPC has a restart address
# ------------------------------------------------------------
# lab4_handler is a function for keyboard intrrupts.	
#-------------------------------------------------------------
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


#---------------------------------------------------------------------
# do_keyboard reads keyboard input and call check key if flag is zero.
#	input: 0xffff0004 (key register)
#	
#	register used: 
#			$t3= 0xffff004
#			$t4= current key
#			$s6= flag (0 or 1)
#---------------------------------------------------------------------
do_keyboard:

	li $t3, 0xffff0004		
	lw $t4, 0($t3)			# $t4 = keyboard input

	beq $s6, $s0, check_key		# if flag = 0

	addi $t4, $0, 0			# clear $t4
	b      lab4_handler_ret

#---------------------------------------------------------------------
# check_key checks if input = i, d, r, l, q, then call the corresponding functions.
#	input:	$t4= current key
#
#	register used:
#		$t5= i
#		$t6= d
#		$t7= r
#		$t8= l
#		$t9= q
#---------------------------------------------------------------------
check_key:
	
	beq $t4, $t5, inwidth		# if input = i
	beq $t4, $t6, dewidth		# if input = d
	beq $t4, $t7, right		# if input = r
	beq $t4, $t8, left		# if input = l
	beq $t4, $t9, quit		# if input = q

	b      lab4_handler_ret	
#---------------------------------------------------------------------
# inwidth is a function for input = i. It adds N and 1 and then check if N > 20.
#---------------------------------------------------------------------
inwidth:
	addi $t1, $t1, 1		# N + 1
	slt  $s2, $s3, $t1		# check if $t1 > 20
	beq  $s2, $s5, maxN		
	addi $t4, $0, 0			# clear $t4
	li   $s6, 1			# flag = 1
	
	b      lab4_handler_ret	
#---------------------------------------------------------------------
# maxN limits N up to 20.
#---------------------------------------------------------------------
maxN:
	li $t1, 20			# set N = 20
	addi $t4, $0, 0			# clear $t4
	li   $s6, 1			# flag = 1
	
	b      lab4_handler_ret
#---------------------------------------------------------------------
# dewidth is a function for input = d. It subtracts N by 1 and then check if N < 1.
#---------------------------------------------------------------------
dewidth:
	addi $t1, $t1, -1		# N - 1
	blez $t1, minN			# check if $t1 < 1
	addi $t4, $0, 0			# clear $t4
	li   $s6, 1			# flag = 1
	
	b      lab4_handler_ret
#---------------------------------------------------------------------
# minN limits N down to 1.
#---------------------------------------------------------------------
minN:
	li $t1, 1			# set N = 1
	addi $t4, $0, 0			# clear $t4
	li   $s6, 1			# flag = 1
	
	b      lab4_handler_ret
#---------------------------------------------------------------------
# right is a function for input = r. It adds K and 1 and then check if N > 40.
#---------------------------------------------------------------------
right:
	addi $t2, $t2, 1		# K + 1
	slt  $s2, $s4, $t2		# check if $t2 > 40
	beq  $s2, $s5, maxK
	addi $t4, $0, 0			# clear $t4
	li   $s6, 1			# flag = 1
	
	b      lab4_handler_ret
#---------------------------------------------------------------------
# maxK limits K up to 40.
#---------------------------------------------------------------------

maxK:
	li $t2, 40			# set K = 40
	addi $t4, $0, 0			# clear $t4
	li   $s6, 1			# flag = 1
	
	b      lab4_handler_ret
#---------------------------------------------------------------------
# left is a function for input = l. It subtracts K by 1 and then check if N < 0.
#---------------------------------------------------------------------
left:
	addi $t2, $t2, -1		# K - 1
	bltz $t2, minK			# check if $t2 <0
	addi $t4, $0, 0			# clear $t4
	li   $s6, 1			# flag = 1
	
	b      lab4_handler_ret	
#---------------------------------------------------------------------
# minK limits K down to 0.
#---------------------------------------------------------------------
minK:
	li $t2, 0			# set K = 0
	addi $t4, $0, 0			# clear $t4
	li   $s6, 1			# flag = 1
	
	b      lab4_handler_ret	
#---------------------------------------------------------------------
# Quit is for exiting program.
#---------------------------------------------------------------------
quit:
	li    $v0, 10; syscall		# exit
	
#---------------------------------------------------------------------
# do_timer is a function for calling pyramid and print_info everytime timer ticks.
#---------------------------------------------------------------------
do_timer:
#-------Print pyramid and infos for N and K----------------------------------------------------------------------------------------------------------------------------------------------
	move    $a0, $t1	  		# $a0= N
	move    $a1, $t2	  		# $t1= N
	li      $s6, 1				# flag = 1
	jal   pyramid				# call pyramid(N,K)
	jal   print_info
	li      $s6, 0				# flag = 0
#-----------------------------------------------------------------------------------------------------------------------------------------------------
	# Restart timer
	mtc0  $0, $9                          # COUNT = 0
        addi  $t0, $0, 50                     # $t0 = 50 ticks
        mtc0  $t0, $11                        # CP0:R11 (Compare Reg.)= $t0
	
	b   lab4_handler_ret

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
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# pyramid is a function for printing the pyramid given N and K.
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

          nop; nop
pyramid:  
	  addi $sp, $sp, -12		# allocate frame: $a0, $a1, $ra
	  sw   $a0, 12($sp)		# store $a0= N in caller's frame
	  sw   $a1, 16($sp)		# store $a1= K in caller's frame
	  sw   $ra,  8($sp)		# store $ra in pyramid's frame	

	  li   $t0, 2			# $t0= 2
	  ble  $a0, $t0, pyramid_line	# n <= 2: goto write line
	  addi $a0, $a0, -2		# n= n-2
	  addi $a1, $a1, 1              # k= k+1
	  jal  pyramid

pyramid_line:
	  lb   $a0, char_space		# $a0 = ' '
	  lw   $a1, 16($sp)		# $a1= K
	  jal  write_char

	  lb   $a0, char_fill		# $a0 = '*'
	  lw   $a1, 12($sp)		# $a1= N
	  jal  write_char
	  jal  print_NL			# print NL

pyramid_end:
	  lw   $ra, 8($sp)		# restore $ra
	  addi $sp, $sp, 12		# release stack frame
	  jr   $ra  			# return

# ------------------------------
# function write_char ($a0= char, $a1= count)
#
          nop; nop
write_char:
	  beqz  $a1, write_char_end	# $a1 == 0: return
	  li    $v0, 11			# print character
	  syscall
	  addi  $a1, $a1, -1		# $a1 = $a1 -1
	  b     write_char

write_char_end:
	  jr    $ra		        # return
# ------------------------------
# function print_NL()
#
	  nop; nop
print_NL:
          li   $a0, 0xA   # newline character
          li   $v0, 11
          syscall
          jr    $ra
#---------------------------------------------------------------------
# print_info is a function for printing pyramid's N and K.
#---------------------------------------------------------------------
print_info:
	la	 $a0, str1;  li $v0,4; syscall		# print "pyramid: "
	la	 $a0, str2;  li $v0,4; syscall		# print "N= "
	move	 $a0, $t1;  li $v0 1; syscall		# print N
	la	 $a0, str3;  li $v0,4; syscall		# print ", K= "
	move	 $a0, $t2;  li $v0 1; syscall		# print K
	la	 $a0, str4;  li $v0,4; syscall		# print newline

	jr	 $ra 
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

