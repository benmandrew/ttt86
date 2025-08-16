BITS 64

global draw_board
global init_board

; 0xE2, 0x94, 0x8C = ┌
; 0xE2, 0x94, 0x90 = ┐
; 0xE2, 0x94, 0x94 = └
; 0xE2, 0x94, 0x98 = ┘
; 0xE2, 0x94, 0x80 = ─
; 0xE2, 0x94, 0x82 = │
; 0xE2, 0x94, 0xAC = ┬
; 0xE2, 0x94, 0xB4 = ┴
; 0xE2, 0x94, 0xA4 = ┤
; 0xE2, 0x94, 0x9C = ├
; 0xE2, 0x94, 0xBC = ┼

section .data
    ; ┌─┬─┐
    board_top db 0xE2, 0x94, 0x8C, 0xE2, 0x94, 0x80, 0xE2, 0x94, 0xAC, 0xE2, 0x94, 0x80, 0xE2, 0x94, 0xAC, 0xE2, 0x94, 0x80, 0xE2, 0x94, 0x90, 10
    board_top_len equ $ - board_top
    ; ├─┼─┤
    board_middle db 0xE2, 0x94, 0x9C, 0xE2, 0x94, 0x80, 0xE2, 0x94, 0xBC, 0xE2, 0x94, 0x80, 0xE2, 0x94, 0xBC, 0xE2, 0x94, 0x80, 0xE2, 0x94, 0xA4, 10
    board_middle_len equ $ - board_middle
    ; └─┴─┘
    board_bottom db 0xE2, 0x94, 0x94, 0xE2, 0x94, 0x80, 0xE2, 0x94, 0xB4, 0xE2, 0x94, 0x80, 0xE2, 0x94, 0xB4, 0xE2, 0x94, 0x80, 0xE2, 0x94, 0x98, 10
    board_bottom_len equ $ - board_bottom
    board_vertical db 0xE2, 0x94, 0x82
    board_vertical_len equ $ - board_vertical
    row_len equ 16 

section .bss
    row resb 16

section .text

; Draw a single row of the game board
; Parameters:
;   rdi - pointer to the three-element row of the board
; Returns:
;   None
draw_board_row:
    mov r9, rdi
    xor r8, r8
copy_vertical_lines_loop:
    lea rdi, [row+r8*4]
    mov rsi, board_vertical
    mov rcx, board_vertical_len
    rep movsb
    inc r8
    cmp r8, 4
    jl copy_vertical_lines_loop
    ; Copy board data into row, spaced between the vertical bars
    mov al, [r9]
    mov byte [row + 3], al
    mov al, [r9+1]
    mov byte [row + 7], al
    mov al, [r9+2]
    mov byte [row + 11], al
    mov byte [row + 15], 0x0A ; Newline
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, row
    mov rdx, row_len
    syscall
    ret

; Draw the game board
; Parameters:
;   rdi - pointer to the board state
; Returns:
;   None
draw_board:
    mov r8, rdi
    ; Draw the top row
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, board_top
    mov rdx, board_top_len
    syscall
    ; Draw the top dynamic row
    mov rdi, r8
    push r8
    call draw_board_row
    pop r8
    ; Draw the top-middle static row
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, board_middle
    mov rdx, board_middle_len
    syscall
    ; Draw the middle dynamic row
    mov rdi, r8
    add rdi, 3
    push r8
    call draw_board_row
    pop r8
    ; Draw the bottom-middle static row
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, board_middle
    mov rdx, board_middle_len
    syscall
    ; Draw bottom dynamic row
    mov rdi, r8
    add rdi, 6
    push r8
    call draw_board_row
    pop r8
    ; Draw the bottom static row
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, board_bottom
    mov rdx, board_bottom_len
    syscall
    ret

; Initialise the characters of the 9-element board array
; Parameters:
;   rdi - pointer to the board state
; Returns:
;   None
init_board:
    xor rcx, rcx
loop:
    mov byte [rdi+rcx], 0x20
    inc rcx
    cmp rcx, 9
    jl loop
    ret
