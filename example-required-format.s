again:	
		addi $a0, $0, 1
		ll	$t0, 0($s0)
		sc	$a0, 0($s0)
		beq	$a0, $0, again		# branch if store fails
		slt	$t1, $a1, $a2		# shvar = max(shvar,x)
		beq	$t1, $0, shvar		# if shvar > x, go to shvar
		add	$a1, $a2, $0
		j	ul

shvar:	add	$a1, $a1, $0

ul:		add $a0, $0, $0		# unlock(lk)
		sw	$a0, 0($s0)