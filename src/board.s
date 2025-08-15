global draw_board

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
    row_len equ 9 

section .bss
    row resb 9

section .text

; Copy three-byte Unicode character from source to destination
; Parameters:
;   rdi - pointer to the destination
;   rsi - pointer to the source
; Returns:
;   None
copy_three_byte_unicode_char:
    mov al, [rsi]         ; load first byte
    mov [rdi], al         ; store first byte
    mov al, [rsi + 1]     ; load second byte
    mov [rdi + 1], al     ; store second byte
    mov al, [rsi + 2]     ; load third byte
    mov [rdi + 2], al     ; store third byte
    ret

; Draw a single row of the game board
; Parameters:
;   rdi - pointer to the three-element row of the board
; Returns:
;   None
draw_board_row:
    mov byte [row], '|'
    mov byte [row + 1], 0x20
    mov byte [row + 2], '|'
    mov byte [row + 3], 0x20
    mov byte [row + 4], '|'
    mov byte [row + 5], 0x20
    mov byte [row + 6], '|'
    mov byte [row + 7], 0x0A
    mov byte [row + 8], 0x00
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

    ; Draw the top row of board
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, board_top
    mov rdx, board_top_len
    syscall

    mov rdi, r8
    call draw_board_row

    ; Draw the top-middle row of board
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, board_middle
    mov rdx, board_middle_len
    syscall

    add rdi, r8
    add rdi, 3
    call draw_board_row

    ; Draw the bottom-middle row of board
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, board_middle
    mov rdx, board_middle_len
    syscall

    mov rdi, r8
    add rdi, 6
    call draw_board_row

    ; Draw the bottom row of board
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; fd = stdout
    mov rsi, board_bottom
    mov rdx, board_bottom_len
    syscall

    ret
