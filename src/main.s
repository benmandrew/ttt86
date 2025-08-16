BITS 64

section .data
    prompt db "Enter a number (1-9): ", 0
    prompt_len equ $ - prompt
    invalid db "Invalid input.", 0x0D, 0
    invalid_len equ $ - invalid
    newline db 10
    reset_cursor_ansi db `\033[7A\033[22D`
    reset_cursor_ansi_len equ $ - reset_cursor_ansi


section .bss
    input_char resb 1
    return_buf resb 1
    board resb 9

section .text
    global _start

extern set_raw_mode
extern draw_board
extern init_board
extern check_horizontal_win

_start:
    call set_raw_mode
    mov rdi, board
    call init_board
game_loop:
    mov rdi, board
    call draw_board
    call get_input
    dec rax ; Decrement user input to get index
    mov byte [board+rax], 'X'
    mov rdi, board
    call check_horizontal_win
    cmp rax, 0x20 ; Check if there is a win
    call reset_cursor
    jmp game_loop

exit:
    ; exit(number)
    mov rdi, 0              ; exit code
    mov rax, 60             ; syscall: exit
    syscall

get_input:
    ; Prompt user
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, prompt
    mov rdx, prompt_len
    syscall
    ; Get user input
    mov rax, 0              ; syscall: read
    mov rdi, 0              ; fd = stdin
    mov rsi, input_char
    mov rdx, 1
    syscall
    ; Convert ASCII to integer
    movzx rax, byte [input_char]
    sub    rax, '0'
    ; Check lower bound
    cmp    rax, 1
    jl     invalid_input
    ; Check upper bound
    cmp    rax, 9
    jg     invalid_input
    ret

invalid_input:
    mov rax, 1 ; syscall: write
    mov rdi, 1 ; fd = stdout
    mov rsi, invalid
    mov rdx, invalid_len
    syscall
    jmp get_input

reset_cursor:
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, reset_cursor_ansi
    mov rdx, reset_cursor_ansi_len
    syscall
    ret
