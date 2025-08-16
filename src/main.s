BITS 64

section .data
    prompt db "Enter a number (1-9): ", 0
    prompt_len equ $ - prompt
    invalid db "Invalid input.", 0x0D, 0
    invalid_len equ $ - invalid
    newline db 10
    reset_cursor_ansi db `\033[7A\033[22D`
    reset_cursor_ansi_len equ $ - reset_cursor_ansi
    winner db "The winner is: ", 0
    winner_len equ $ - winner

section .bss
    input_char resb 1
    winner_char resb 1
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
    mov rdi, board
    call draw_board
game_loop:
    call get_input
    dec rax ; Decrement user input to get index
    mov byte [board+rax], 'X'
    call reset_cursor
    mov rdi, board
    call draw_board
    mov rdi, board
    call check_horizontal_win
    mov rdi, rax
    cmp rax, 0x00 ; Check if there is a win
    jne win
    jmp game_loop
win:
    call print_win

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

; Reset cursor to where we started in the terminal
; Parameters:
;   None
; Returns:
;   None
reset_cursor:
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, reset_cursor_ansi
    mov rdx, reset_cursor_ansi_len
    syscall
    ret

; Print whoever won
; Parameters:
;   rdi - character for the winner
; Returns:
;   None
print_win:
    mov [winner_char], dil  ; lowest 8 bits of rdi
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, winner
    mov rdx, winner_len
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, winner_char
    mov rdx, 1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ret
