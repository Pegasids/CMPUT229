#---------------------------------------------------------------
# Assignment:           1
# Due Date:             January 29, 2016
# Name:                 Canopus Tong
# Unix ID:              canopus
# Lecture Section:      B1
# Lab Section:          H01 (Monday 2:00pm-4:50pm)
# Teaching Assistant(s):   Parisa Mohebbi
#---------------------------------------------------------------
# ------------------------------
# Purpose - convert an ASCII hexadecimal character to its numerical value
# Entry conditions: a single ASCII character loaded by the first instruction
# in register $t0
# Exit conditions: if the character denotes a valid hexadecimal digit
# (i.e., ’0’ to ’9’ or ’A’ to ’F’) then register
# $t1 should contain its equivalent numerical value
# (i.e., 0 to F), or an error code of 0xFF if the ASCII
# character does not correspond to a hexadecimal digit
# Example: If the first instruction is: li $t0, ’A’
# then $t1 should contain decimal 10 upon termination

	.text
main: 	li 	$t0, 'E'			# load an ASCII character in $t0

	blt 	$t0, 0x30, error 		# if (character < ’0’) goto error
	bgt 	$t0, 0x39, atof 		# if (character > ’9’) goto atof
	sub 	$t2, $t0, 0x30 			# else, map it to the required value
	b 	done 				# no, goto done

atof: 	blt 	$t0, 0x41, error 		# if (character < ’A’) goto error
	bgt 	$t0, 0x46, error 		# if (character > ’F’) goto error
	sub 	$t2, $t0, 0x37 			# else, map it to the required value
	b 	done 				# no, goto done

done: 	andi 	$t1, $t2, 0xFF 			# keep only the lowest byte in $t1	
	b 	exit

error: 	li 	$t1, 0xff 			# load the error code

exit: 	li 	$v0, 10 			# exit
	syscall
# ------------------------------
