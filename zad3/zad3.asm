.eqv STACK_SIZE 2048
.data
	# obszar na zapamietanie adresu stosu systemowego
	sys_stack_addr: .word 0
	# deklaracja wlasnego obszaru stosu
	stack: .space STACK_SIZE
	
	global_array: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
.text
#czynnosci inicjalizacyjne
	sw $sp, sys_stack_addr   # zachowanie adresu stosu systemowego
	la $sp, stack+STACK_SIZE # zainicjowanie obszaru stosu

main:
	subi $sp, $sp, 8

	# 1 argument - długość tablicy
	li $t0, 10
	sw $t0, ($sp)
	
	# 2 argument - adres tablicy
	la $t0, global_array
	sw $t0, 4($sp)
	
	# woła procedurę sum
	jal sum
	
	# wypisuje wartość zwróconą przez sum
	li $v0, 1
	lw $a0, ($sp)
	syscall

	# zakańcza program
	lw $sp, sys_stack_addr
	li $v0, 10
	syscall
	
# zwraca sumę tablicy
sum:
	subi $sp,  $sp,  16
	# przesunięcia zmiennych na stosie w stosunku do $sp:
		# argumenty: 16 - rozmiar tablicy, 20 - adres tablicy
		# 12 - wartość zwracana
		# 8 - adres powrotu
		# zmienne lok.: 0 - s, 4 - i
	sw   $ra,  8($sp) 

	li   $t0,  0
	sw   $t0, ($sp)
	
	lw   $t0, 16($sp)
	subi $t0, $t0,   1
	
	sw   $t0, 4($sp)
	
	loop:
	    # ładuje i do t0
		lw   $t0,   4($sp)
		bltz $t0,   endloop
		
		# ładuje i-ty element tablicy do t1
		lw   $t0,   20($sp)
		lw   $t1,   ($t0)
		
		# przesuwa adres tablicy do następnego elementu i zapisuje nowy adres
		addi $t0,   $t0, 4
		sw   $t0,   20($sp)
		
		# dodaje i-ty element tablicy do s i ją zapisuje
		lw   $t0,   ($sp)
		add  $t0,   $t0,   $t1
		sw   $t0,   ($sp)
		
		# odejmuje 1 od i, zapisuje i
		lw   $t0,   4($sp)
		subi $t0,   $t0, 1 
		sw   $t0,   4($sp)
		j loop
	endloop:
	
	# zapisuje s do return
	lw $t0, ($sp)
	sw $t0, 12($sp)
	
	# zapisuje adres powrotu do ra
	lw $ra, 8($sp)
	
	# przesuwa wskaźnik na zmienną zwracaną, wykonuje powrót
	addi $sp, $sp, 12
	jr   $ra
