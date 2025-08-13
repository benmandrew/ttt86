section .data
    prompt db "Enter a number (1-9): ", 0
    prompt_len equ $ - prompt
    invalid db "Invalid input.", 10, 0
    invalid_len equ $ - invalid
    newline db 10

section .bss
    input_char resb 1
    termios_raw resb 32   ; struct termios is 32 bytes on x86-64

section .text
    global _start

; Terminal raw mode for immediate user input without waiting for enter
set_raw_mode:
    ; TCGETS = 0x5401, TCSETS = 0x5402
    mov rax, 16           ; syscall: ioctl
    mov rdi, 0            ; fd = stdin
    mov rsi, 0x5401       ; TCGETS
    mov rdx, termios_raw
    syscall

    ; Modify termios_raw: unset ICANON (0x0002) and ECHO (0x0008) in c_lflag
    ; c_lflag is at offset 12 in termios struct
    mov rbx, termios_raw
    add rbx, 12
    mov eax, [rbx]
    and eax, 0xFFFFFFFFFFFFFFF5  ; clear ICANON (bit 1) and ECHO (bit 3)
    mov [rbx], eax

    mov rax, 16           ; syscall: ioctl
    mov rdi, 0            ; fd = stdin
    mov rsi, 0x5402       ; TCSETS
    mov rdx, termios_raw
    syscall
    ret

_start:
    call set_raw_mode

get_input:
    ; write(1, prompt, prompt_len)
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; read(0, input_char, 1)
    mov rax, 0              ; syscall: read
    mov rdi, 0              ; fd = stdin
    mov rsi, input_char
    mov rdx, 1
    syscall

    ; Convert ASCII -> integer
    movzx rax, byte [input_char]
    sub    rax, '0'         ; now rax = 1..9 (if valid input)

    ; Check lower bound
    cmp    rax, 1
    jl     invalid_input

    ; Check upper bound
    cmp    rax, 9
    jg     invalid_input
    jmp    exit

invalid_input:
    ; write(1, invalid, invalid_len)
    mov rax, 1
    mov rdi, 1
    mov rsi, invalid
    mov rdx, invalid_len
    syscall
    jmp get_input

exit:
    ; write(1, newline, newline_len)
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, newline
    mov rdx, 1
    syscall

    ; exit(number)
    mov rdi, rax            ; exit code
    mov rax, 60             ; syscall: exit
    syscall
