.data
in_i: .word 123
out_f: .float 

.text
main:
lw $t1, in_i
lwc1 $f0 out_f
beqz $t1, EQUAL0
bltz $t1, SMALLER0
bgtz $t1, GREATER0
li $v0, 10
syscall

EQUAL0:
b SETFLOAT

GREATER0:
b MANT_EXPONENT

SMALLER0:
li $s0 -1
sll $s0, $s0, 31 #set sign part
b INVERTINT

#invert and add one
INVERTINT:
li $t2 -1
xor $t1, $t1, $t2
addi $t1, $t1, 1

#calculate  the mantissa and exponent
MANT_EXPONENT:
li $t2 0 #1 checker
li $t3 31 #power
li $t4 127 #exponent
while:
	bltz $t1, end_while
	
	sll $t1, $t1, 1
    addi $t3, $t3, -1
    j while
end_while:
	add $t4, $t4, $t3
	sll $t1, $t1, 1
	srl $s2, $t1, 9 #set mantissa part
	sll $s1, $t4, 23 #set exponent part
	
SETFLOAT:
or $s0, $s0, $s1
or $s0, $s0, $s2
sw $s0, 0($sp)
lwc1 $f0, 0($sp)
li $v0, 2
mov.s $f12, $f0
syscall
