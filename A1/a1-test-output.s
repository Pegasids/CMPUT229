# ------------------------------
	.text
main: 	la $a0, message
	li $v0, 4
	syscall

	lb $a0, solution
	li $v0, 1
	syscall

	li $v0, 10
	syscall

	.data
message: .asciiz "optimal solution="
solution:.byte 0xfe
extra: .asciiz "this is not part of the solution"
# ------------------------------
