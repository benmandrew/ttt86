section .data
    prompt db "Enter a number (1-9): ", 0
    prompt_len equ $ - prompt
    invalid db "Invalid input.", 10, 0
    invalid_len equ $ - invalid
    newline db 10

section .bss
    input_char resb 1
    return_buf resb 1
    board resb 9

section .text
    global _start

extern set_raw_mode
extern draw_board

_start:
    call set_raw_mode
    call draw_board

    ; call get_input
    ; call print_input
    jmp exit

exit:
    ; exit(number)
    mov rdi, 0              ; exit code
    mov rax, 60             ; syscall: exit
    syscall

; get_input:
;     ; Prompt user
;     mov rax, 1              ; syscall: write
;     mov rdi, 1              ; fd = stdout
;     mov rsi, prompt
;     mov rdx, prompt_len
;     syscall
;     ; Get user input
;     mov rax, 0              ; syscall: read
;     mov rdi, 0              ; fd = stdin
;     mov rsi, input_char
;     mov rdx, 1
;     syscall
;     ; Convert ASCII to integer
;     movzx rax, byte [input_char]
;     sub    rax, '0'
;     ; Check lower bound
;     cmp    rax, 1
;     jl     invalid_input
;     ; Check upper bound
;     cmp    rax, 9
;     jg     invalid_input
;     ret

; invalid_input:
;     ; write(1, invalid, invalid_len)
;     mov rax, 1
;     mov rdi, 1
;     mov rsi, invalid
;     mov rdx, invalid_len
;     syscall
;     jmp get_input

; print_input:
;     ; Convert integer to ASCII
;     add rax, '0'
;     mov [return_buf], al
;     ; write(1, newline, newline_len)
;     mov rax, 1              ; syscall: write
;     mov rdi, 1              ; fd = stdout
;     mov rsi, newline
;     mov rdx, 1
;     syscall
;     ; write(1, return_buf, 1)
;     mov rax, 1              ; syscall: write
;     mov rdi, 1              ; fd = stdout
;     mov rsi, return_buf
;     mov rdx, 1
;     syscall
;     ; write(1, newline, newline_len)
;     mov rax, 1              ; syscall: write
;     mov rdi, 1              ; fd = stdout
;     mov rsi, newline
;     mov rdx, 1
;     syscall
