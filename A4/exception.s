# 52-56 just saves registers. The reentrant means it keeps jumping back to the .ktext, which is what we don't want.
# By default, it isn't reentrant, so it's all good there. Implementation in a reentrant way is that at the end of the exception handler, it set up registers on line 37:
# mfco $k0 $12
# ori $k0 0x1
# mtc0 $k0 $12
# It read everything into k0, or operation on the last bit. If we were to move this to the top, then it will make it reentrant because we are enabling the interrupt right after it's triggered from the main program.
# The code is extracted using a mask. It'll read from the CAUSE register. The exception code is from bit 2 to bit 6. What it does is that it applies a logical shift to k0. Then the exception code is aligned to the right part. Because there are 5 bits, you apply a mask to the 32 bits so the 0x1f just allows us to keep the exception code we need.
# On line 79, we handle bad PC exception. 0x18 is 24 in decimal, and the exception 6 is that's it. We have 24 and not 6 because it did some shifting already. We assume that we take the number from the CAUSE register without shifting it. We assume the last 2 bits are both 0. If the exception code is 6 and we srl by 2, then 6*4 = 24, which is why we have that number. This command checks against that exception, then it jumps if it isn't the exception..
# The exception on line 97 is the interrupt code exception, which is normally 0. It checks to see if the code is interrupted - if it is, then it keeps going. Then you have the interrupt specific code. If it isn't interrupt, then the exception is handled normally. Most of the code is for exception - interrupt is the odd one out.
# Trap exception is triggered by running the code.
# On line 111-114. EPC by default will store the address of the command that had an error or the one that triggered the exception. If it has an exception, then skip that instruction.
# On line 128-130, the code allows interrupts by raising the status register and sets the last bit to 1. No, it isn't enabled when SPIM is reinitialized. You can enable interrupt by doing it in the user text and not in the kernel.
# On line 111-133, it is definitely safer than doing it the other way. 
# On line 139-154, it isn't part of exception handling. It sets up the symbol so that SPIM will know where to find the main program. 

# To write out a character for part 2, look at A-39. It shows you how to use a memory mapped thing like the keyboard and print out the right one. Find the control register the important bits and what you need to set to enable the device. Then you take the ASCII code and write that to the data register. you already have the address, so you just need it to the data section and give it a name so you can call it in the program. 


 # SPIM S20 MIPS simulator.
 # The default exception handler for spim.
 #
 # Copyright (c) 1990-2010, James R. Larus.
 # ....
  
# This defines the kernal data, and you use it the same way. This will print out stuff about exceptions and interrupt.   
         .kdata
 __m1_:  .asciiz "  Exception "
 __m2_:  .asciiz " occurred and ignored\n"
 __e0_:  .asciiz "  [Interrupt] "
 __e1_:  .asciiz "  [TLB]"
 __e2_:  .asciiz "  [TLB]"
 __e3_:  .asciiz "  [TLB]"
 __e4_:  .asciiz "  [Address error in inst/data fetch] "
 __e5_:  .asciiz "  [Address error in store] "
 __e6_:  .asciiz "  [Bad instruction address] "
 __e7_:  .asciiz "  [Bad data address] "
 __e8_:  .asciiz "  [Error in syscall] "
 __e9_:  .asciiz "  [Breakpoint] "
 __e10_: .asciiz "  [Reserved instruction] "
 __e11_: .asciiz ""
 __e12_: .asciiz "  [Arithmetic overflow] "
 __e13_: .asciiz "  [Trap] "
 __e14_: .asciiz ""
 __e15_: .asciiz "  [Floating point] "
 __e16_: .asciiz ""
 __e17_: .asciiz ""
 __e18_: .asciiz "  [Coproc 2]"
 __e19_: .asciiz ""
 __e20_: .asciiz ""
 __e21_: .asciiz ""
 __e22_: .asciiz "  [MDMX]"
 __e23_: .asciiz "  [Watch]"
 __e24_: .asciiz "  [Machine check]"
 __e25_: .asciiz ""
 __e26_: .asciiz ""
 __e27_: .asciiz ""
 __e28_: .asciiz ""
 __e29_: .asciiz ""
 __e30_: .asciiz "  [Cache]"
 __e31_: .asciiz ""
 __excp: .word __e0_, __e1_, __e2_, __e3_, __e4_, __e5_, __e6_, __e7_, __e8_, __e9_
     .word __e10_, __e11_, __e12_, __e13_, __e14_, __e15_, __e16_, __e17_, __e18_,
     .word __e19_, __e20_, __e21_, __e22_, __e23_, __e24_, __e25_, __e26_, __e27_,
     .word __e28_, __e29_, __e30_, __e31_
 s1: .word 0
 s2: .word 0
 

# This is for the kernel text. The kernel text can also be found in XSPIM. 
# The address is a default address where MIPS will jump to whenever there's an exception or interrupt.
# This is set up in the hardware.

     .ktext 0x80000180

 # Select the appropriate one for the mode in which SPIM is compiled.

# The at register and the k register can be found at the top of XSPIM.
# k just means kernal. The file doesn't use t or s register. 
# It's recommended to only use the k registers when programming in the kernel.
# at is the register that is used by the assembler.

     .set noat
     move $k1 $at        # Save $at
     .set at
     sw $v0 s1       # Not re-entrant and we can't trust $sp
     sw $a0 s2       # But we need to use these registers
 
# The notation uses $13 to represent the CAUSE register. 
# The ExcCode is extracted using a mask?

     mfc0 $k0 $13        # Cause register
     srl $a0 $k0 2       # Extract ExcCode Field
     andi $a0 $a0 0x1f
 
     # Print information about exception.
     # This is dependent on what the STATUS register says.
     
     beq  $a0, 0, lab4_interrupt

     li $v0 4        # syscall 4 (print_str)
     la $a0 __m1_
     syscall
 
     li $v0 1        # syscall 1 (print_int)
     srl $a0 $k0 2       # Extract ExcCode Field
     andi $a0 $a0 0x1f
     syscall
 
     li $v0 4        # syscall 4 (print_str)
     andi $a0 $k0 0x3c
     lw $a0 __excp($a0)
     nop
     syscall

# Reentrant is an adjective that describes a computer program or routine that is written so that the same copy in memory can be shared by multiple users. Not re-entrant means that it isn't written so that we can share the same copy in memory by multiple users.
# Implementing it in a re-entrant way
# If you are reentrant, once you are in the kernel, there won't register any other interrupts. This is because it will just jump back to the kernel (itself), so then yeah.
# If you aren't reentrant, that means if you press a keyboard key, it'll register and it'll work. But yeah.
# How to implement in a reentrant way... Who knows? (Not the TA lols)
# By default, the system disables interrupts. That's why we have to reenable it at the end of the code. 
# Check predefined exception code and then print message.

     bne $k0 0x18 ok_pc  # Bad PC exception requires special checks
     nop
 
     mfc0 $a0 $14        # EPC
     andi $a0 $a0 0x3    # Is EPC word-aligned?
     beq $a0 0 ok_pc
     nop
 
     li $v0 10       # Exit on really bad PC
     syscall
 
 ok_pc:
     li $v0 4        # syscall 4 (print_str)
     la $a0 __m2_
     syscall
 
     srl $a0 $k0 2       # Extract ExcCode Field
     andi $a0 $a0 0x1f

# Interrupt generally a good thing. Exception means you screwed up stuff.
     bne $a0 0 ret       # 0 means exception was an interrupt
     nop
 
 # ------------------------------------------------------------
 # Interrupt-specific code goes here!
 # Don't skip instruction at EPC since it has not executed.

  lab4_interrupt:
        lw  $v0 s1              # Restore other registers
        lw  $a0 s2

        .set noat
        move $at $k1            # Restore $at
        .set at

        la  $k0, lab4_handler   #lab4_handler should be global
        jr  $k0
 # ...
 # ------------------------------------------------------------
 
 ret:
 # Return from (non-interrupt) exception. Skip offending instruction
 # at EPC to avoid infinite loop.
 
     mfc0 $k0 $14        # Bump EPC register
     addiu $k0 $k0 4     # Skip faulting instruction
                 # (Need to handle delayed branch case here)
     mtc0 $k0 $14
 
 
 # Restore registers and reset processor state
 
     lw $v0 s1       # Restore other registers
     lw $a0 s2
 
     .set noat
     move $at $k1        # Restore $at
     .set at
 
     mtc0 $0 $13     # Clear Cause register
 
     mfc0 $k0 $12        # Set Status register
     ori  $k0 0x1        # Interrupts enabled
     mtc0 $k0 $12
 
 # Return from exception on MIPS32:

# eret just returns from the exception. Use eret instead of jr $ra.
     eret
 
 # ------------------------------------------------------------
 # Standard startup code.  Invoke the routine "main" with arguments:
 #   main(argc, argv, envp)
 #
     .text

# This is a global starting point. SPIM will look for the symbol and then call the main program.

     .globl __start
 __start:
     lw $a0 0($sp)       # argc
     addiu $a1 $sp 4     # argv
     addiu $a2 $a1 4     # envp
     sll $v0 $a0 2
     addu $a2 $a2 $v0
     jal main
     nop
 
     li $v0 10
     syscall         # syscall 10 (exit)
 
     .globl __eoth
 __eoth:
 # ------------------------------------------------------------
