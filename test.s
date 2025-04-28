.equ SYS_write, 1
.equ SYS_exit, 60
.equ STDOUT_FILENO, 1

.globl _start
.type _start, @function
_start:
	movq (%rsp), %r12
	cmp $1, %r12
	jle done

	movq $1, %r13

main_loop:

	movq 8(%rsp, %r13, 8), %rsi
	addq $1, %r13

	testq %rsi, %rsi
	je done

	xorq %rdx, %rdx
get_str_len:

	cmpb $0, (%rsi, %rdx)
	je get_str_len_done

	addq $1, %rdx
	jmp get_str_len
get_str_len_done:

mov $STDOUT_FILENO, %rdi

test %r13, %r12
je write_loop

movb $' ', (%rsi, %rdx)
addq $1, %rdx

write_loop:
	mov $SYS_write, %rax
	syscall
	test %rax, %rax
	jl error
	leaq (%rsi, %rax), %rsi
	sub %rax, %rdx
	jne write_loop

jmp main_loop

done:

	mov $SYS_write, %rax
	leaq newline, %rsi
	movq $1, %rdx
	syscall
	test %rax, %rax
	jl error

	movq $SYS_exit, %rax
	xor %rdi, %rdi
	syscall

error:
	movq $SYS_exit, %rax
	movq $1, %rdi
	syscall

newline:
	.byte '\n'
