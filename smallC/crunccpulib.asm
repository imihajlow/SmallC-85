;       runtime library for small C compiler

    .export __cc_r_pri
    .export __cc_r_sec
    .export __cc_r_sp
    .export __cc_r_ret
    .export __cc_push_pri
    .export __cc_push_sec
    .export __cc_push_ret
    .export __cc_ret
    .export __cc_pop_sec
    .export __cc_swap_stack_pri
    .export __cc_bool_not
    .export __cc_bool
    .export __cc_eq
    .export __cc_ne
    .export __cc_lt
    .export __cc_le
    .export __cc_gt
    .export __cc_ge
    .export __cc_ult
    .export __cc_ule
    .export __cc_ugt
    .export __cc_uge
    .export __cc_case
    .export __cc_asr
    .export __cc_lsr
    .export __cc_asl
    .export __cc_mul
    .export __cc_div
    .export __cc_udiv
    .export __cc_div_zero_trap

    ; stack grows down
    ; SP should be aligned by 2

    .global __seg_stack_end ; provided by the linker
    .global main

    ; start-up code
    .section init
    ; point SP to the end of stack segment
    ldi pl, lo(__cc_r_sp)
    ldi ph, hi(__cc_r_sp)
    ldi a, lo(__seg_stack_end)
    st a
    inc pl
    ldi a, hi(__seg_stack_end)
    st a

    ; call main
    ldi pl, lo(main)
    ldi ph, hi(main)
    jmp
main_exit:
    ldi pl, lo(main_exit)
    ldi ph, hi(main_exit)
    jmp

    .section text
    ; push pri onto stack
__cc_push_pri:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ; SP -= 2
    ldi pl, lo(__cc_r_sp)
    ; ldi ph, hi(__cc_r_sp)
    ld b
    inc pl
    ld a
    dec b
    sbb a, 0
    dec b
    st a
    dec pl
    st b

    ; a:b = SP
    ; SP[0] := lo(pri)
    ldi pl, lo(__cc_r_pri)
    ld pl
    mov ph, a
    mov a, b
    xor pl, a
    xor a, pl
    xor pl, a
    st a

    ; a:b := ph:pl
    mov a, ph
    ; SP[1] := hi(pri)
    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri + 1)
    ld pl
    mov ph, a
    mov a, b
    xor pl, a
    xor a, pl
    xor pl, a
    inc pl
    st a

    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    ld a
    inc pl
    ld ph
    mov pl, a
    jmp

    ; push sec onto stack
__cc_push_sec:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ; SP -= 2
    ldi pl, lo(__cc_r_sp)
    ; ldi ph, hi(__cc_r_sp)
    ld b
    inc pl
    ld a
    dec b
    sbb a, 0
    dec b
    st a
    dec pl
    st b

    ; a:b = SP
    ; SP[0] := lo(sec)
    ldi pl, lo(__cc_r_sec)
    ld pl
    mov ph, a
    mov a, b
    xor pl, a
    xor a, pl
    xor pl, a
    st a

    ; a:b := ph:pl
    mov a, ph
    ; SP[1] := hi(sec)
    ldi ph, hi(__cc_r_sec)
    ldi pl, lo(__cc_r_sec + 1)
    ld pl
    mov ph, a
    mov a, b
    xor pl, a
    xor a, pl
    xor pl, a
    inc pl
    st a

    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    ld a
    inc pl
    ld ph
    mov pl, a
    jmp

    ; push ret onto stack
__cc_push_ret:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ; SP -= 2
    ldi pl, lo(__cc_r_sp)
    ; ldi ph, hi(__cc_r_sp)
    ld b
    inc pl
    ld a
    dec b
    sbb a, 0
    dec b
    st a
    dec pl
    st b

    ; a:b = SP
    ; SP[0] := lo(ret)
    ldi pl, lo(__cc_r_ret)
    ld pl
    mov ph, a
    mov a, b
    xor pl, a
    xor a, pl
    xor pl, a
    st a

    ; a:b := ph:pl
    mov a, ph
    ; SP[1] := hi(ret)
    ldi ph, hi(__cc_r_ret)
    ldi pl, lo(__cc_r_ret + 1)
    ld pl
    mov ph, a
    mov a, b
    xor pl, a
    xor a, pl
    xor pl, a
    inc pl
    st a

    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    ld a
    inc pl
    ld ph
    mov pl, a
    jmp

    ; pop sec from the stack
__cc_pop_sec:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_sp)
    ; ldi ph, hi(__cc_r_sp)
    ld b
    inc pl
    ld a
    ; a:b = SP

    mov ph, a
    mov a, b
    mov pl, a
    ld b
    inc pl
    ld a

    ldi pl, lo(__cc_r_sec)
    ldi ph, hi(__cc_r_sec)
    st b
    inc pl
    st a

    ; SP += 2
    ldi pl, lo(__cc_r_sp)
    ; ldi ph, hi(__cc_r_sp)
    ld b
    inc pl
    ld a
    ; stack is aligned => overflow may happen only on second increment
    inc b
    inc b
    adc a, 0
    st a
    dec plc
    st b

    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    ld a
    inc pl
    ld ph
    mov pl, a
    jmp

    ; swap pri and top of the stack
__cc_swap_stack_pri:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_sp)
    ld a
    inc pl
    ld ph
    mov pl, a
    ld a

    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri)
    ld b
    st a

    ldi ph, hi(__cc_r_sp)
    ldi pl, lo(__cc_r_sp)
    ld a
    inc pl
    ld ph
    mov pl, a
    st b
    inc pl
    ld a

    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri + 1)
    ld b
    st a

    ldi ph, hi(__cc_r_sp)
    ldi pl, lo(__cc_r_sp)
    ld a
    inc pl
    ld ph
    mov pl, a
    inc pl
    st b

    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    ld a
    inc pl
    ld ph
    mov pl, a
    jmp

    ; pop the address from the stack and jump there
__cc_ret:
    ; SP += 2
    ldi pl, lo(__cc_r_sp)
    ldi ph, hi(__cc_r_sp)
    ld b
    inc pl
    ld a

    ; stack is aligned => overflow may happen only on second increment
    inc b
    inc b
    adc a, 0
    st a
    dec pl
    st b

    ; a:b = SP
    ; [SP-2] = addr
    dec b
    sbb a, 0
    mov ph, a
    mov a, b
    mov pl, a
    ld a
    dec pl
    ld pl
    mov ph, a
    jmp

    ; PRI = !PRI
__cc_bool_not:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri)
    ld a
    inc pl
    ld b
    or a, b

    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jnz

    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jz

    ; PRI = PRI ? 1 : 0
__cc_bool:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri)
    ld a
    inc pl
    ld b
    or a, b

    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jz

    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jnz

    ; PRI = PRI == SEC
__cc_eq:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri + 1)
    ld b
    ldi pl, lo(__cc_r_sec + 1)
    ld a
    sub b, a
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jnz

    ldi pl, lo(__cc_r_pri)
    ldi ph, hi(__cc_r_pri)
    ld b
    ldi pl, lo(__cc_r_sec)
    ld a
    sub b, a
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jnz
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jmp

    ; PRI = PRI != SEC
__cc_ne:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri + 1)
    ld b
    ldi pl, lo(__cc_r_sec + 1)
    ld a
    sub b, a
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jnz

    ldi pl, lo(__cc_r_pri)
    ldi ph, hi(__cc_r_pri)
    ld b
    ldi pl, lo(__cc_r_sec)
    ld a
    sub b, a
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jz
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jmp

    ; PRI = SEC < PRI (signed)
__cc_lt:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri + 1)
    ld b
    ldi pl, lo(__cc_r_sec + 1)
    ld a
    sub a, b ; hi(SEC) - hi(PRI)
    ldi pl, lo(return_ns)
    ldi ph, hi(return_ns)
    jo
    ldi pl, lo(return_s)
    ldi ph, hi(return_s)
    jnz

    ldi pl, lo(__cc_r_pri)
    ldi ph, hi(__cc_r_pri)
    ld b
    ldi pl, lo(__cc_r_sec)
    ld a
    sub a, b ; lo(SEC) - lo(PRI)
    ldi pl, lo(return_ns)
    ldi ph, hi(return_ns)
    jo
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jz ; SEC == PRI
return_s:
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jns
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jmp
return_ns:
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    js
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jmp

; PRI = SEC <= PRI (signed)
__cc_le:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri + 1)
    ld b
    ldi pl, lo(__cc_r_sec + 1)
    ld a
    sub a, b ; hi(SEC) - hi(PRI)
    ldi pl, lo(return_ns)
    ldi ph, hi(return_ns)
    jo
    ldi pl, lo(return_s)
    ldi ph, hi(return_s)
    jnz

    ldi pl, lo(__cc_r_pri)
    ldi ph, hi(__cc_r_pri)
    ld b
    ldi pl, lo(__cc_r_sec)
    ld a
    sub a, b ; lo(SEC) - lo(PRI)
    ldi pl, lo(return_ns)
    ldi ph, hi(return_ns)
    jo
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jz ; SEC == PRI
    ldi pl, lo(return_s)
    ldi ph, hi(return_s)
    jmp

    ; PRI = SEC > PRI (signed)
__cc_gt:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri + 1)
    ld b
    ldi pl, lo(__cc_r_sec + 1)
    ld a
    sub a, b ; hi(SEC) - hi(PRI)
    ldi pl, lo(return_s)
    ldi ph, hi(return_s)
    jo
    ldi pl, lo(return_ns)
    ldi ph, hi(return_ns)
    jnz

    ldi pl, lo(__cc_r_pri)
    ldi ph, hi(__cc_r_pri)
    ld b
    ldi pl, lo(__cc_r_sec)
    ld a
    sub a, b ; lo(SEC) - lo(PRI)
    ldi pl, lo(return_s)
    ldi ph, hi(return_s)
    jo
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jz ; SEC == PRI
    ldi pl, lo(return_ns)
    ldi ph, hi(return_ns)
    jmp

; PRI = SEC >= PRI (signed)
__cc_ge:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri + 1)
    ld b
    ldi pl, lo(__cc_r_sec + 1)
    ld a
    sub a, b ; hi(SEC) - hi(PRI)
    ldi pl, lo(return_s)
    ldi ph, hi(return_s)
    jo
    ldi pl, lo(return_ns)
    ldi ph, hi(return_ns)
    jnz

    ldi pl, lo(__cc_r_pri)
    ldi ph, hi(__cc_r_pri)
    ld b
    ldi pl, lo(__cc_r_sec)
    ld a
    sub a, b ; lo(SEC) - lo(PRI)
    ldi pl, lo(return_s)
    ldi ph, hi(return_s)
    jo
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jz ; SEC == PRI
    ldi pl, lo(return_ns)
    ldi ph, hi(return_ns)
    jmp

    ; PRI = SEC < PRI (unsigned)
__cc_ult:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri + 1)
    ld b
    ldi pl, lo(__cc_r_sec + 1)
    ld a
    sub a, b ; hi(SEC) - hi(PRI)
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jc ; SEC < PRI
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jnz ; SEC > PRI

    ldi pl, lo(__cc_r_pri)
    ldi ph, hi(__cc_r_pri)
    ld b
    ldi pl, lo(__cc_r_sec)
    ld a
    sub a, b ; lo(SEC) - lo(PRI)
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jc ; SEC < PRI
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jmp

    ; PRI = SEC <= PRI (unsigned)
__cc_ule:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri + 1)
    ld b
    ldi pl, lo(__cc_r_sec + 1)
    ld a
    sub a, b ; hi(SEC) - hi(PRI)
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jc ; SEC < PRI
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jnz ; SEC > PRI

    ldi pl, lo(__cc_r_pri)
    ldi ph, hi(__cc_r_pri)
    ld b
    ldi pl, lo(__cc_r_sec)
    ld a
    sub a, b ; lo(SEC) - lo(PRI)
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jc ; SEC < PRI
    jz ; SEC == PRI
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jmp

    ; PRI = SEC > PRI (unsigned)
__cc_ugt:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri + 1)
    ld b
    ldi pl, lo(__cc_r_sec + 1)
    ld a
    sub a, b ; hi(SEC) - hi(PRI)
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jc ; SEC < PRI
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jnz ; SEC > PRI

    ldi pl, lo(__cc_r_pri)
    ldi ph, hi(__cc_r_pri)
    ld b
    ldi pl, lo(__cc_r_sec)
    ld a
    sub a, b ; lo(SEC) - lo(PRI)
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jc ; SEC < PRI
    jz ; SEC == PRI
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jmp

    ; PRI = SEC >= PRI (unsigned)
__cc_uge:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri + 1)
    ld b
    ldi pl, lo(__cc_r_sec + 1)
    ld a
    sub a, b ; hi(SEC) - hi(PRI)
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jc ; SEC < PRI
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jnz ; SEC > PRI

    ldi pl, lo(__cc_r_pri)
    ldi ph, hi(__cc_r_pri)
    ld b
    ldi pl, lo(__cc_r_sec)
    ld a
    sub a, b ; lo(SEC) - lo(PRI)
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    jc ; SEC < PRI
    ldi pl, lo(return_1)
    ldi ph, hi(return_1)
    jmp

return_1:
    ldi pl, lo(__cc_r_pri + 1)
    ldi ph, hi(__cc_r_pri)
    mov a, 0
    st a
    dec pl
    inc a
    st a
    ldi pl, lo(exit)
    ldi ph, hi(exit)
    jmp

return_0:
    ldi pl, lo(__cc_r_pri)
    ldi ph, hi(__cc_r_pri)
    mov a, 0
    st a
    inc pl
    st a
exit:
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    ld a
    inc pl
    ld ph
    mov pl, a
    jmp

    ; case jump
    ; PRI = value
    ; [SP] = table address
    ; table consists on entries (value, address) for switch cases
    ; followed by (address, 0) for the default case
__cc_case:
    ldi pl, lo(__cc_pop_sec)
    ldi ph, hi(__cc_pop_sec)
    jmp

    ; PRI = value
    ; SEC = table address
__cc_case_loop:
    ; tmp := case value
    ldi pl, lo(load_tmp_inc_sec)
    ldi ph, hi(load_tmp_inc_sec)
    jmp

    ; compare tmp and PRI
    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri)
    ld b
    ldi pl, lo(tmp)
    ld a
    sub a, b
    ldi pl, lo(__cc_case_next)
    ldi ph, hi(__cc_case_next)
    jnz ; lo(tmp) != lo(PRI)

    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri + 1)
    ld b
    ldi pl, lo(tmp + 1)
    ld a
    sub a, b
    ldi pl, lo(__cc_case_next)
    ldi ph, hi(__cc_case_next)
    jnz ; hi(tmp) != hi(PRI)

    ; tmp == PRI

    ; tmp := case label
    ldi pl, lo(load_tmp_inc_sec)
    ldi ph, hi(load_tmp_inc_sec)
    jmp

    ; tmp == 0?
    ldi pl, lo(tmp)
    ldi ph, hi(tmp)
    ld b
    inc pl
    ld a
    or b, a
    ldi pl, lo(__cc_case_default)
    ldi ph, hi(__cc_case_default)
    jz ; tmp == 0

    ; case matched, label non-zero, jump
    ldi pl, lo(tmp)
    ldi ph, hi(tmp)
    ld pl
    ; a is still hi(tmp)
    mov ph, a
    jmp

__cc_case_next:
    ; tmp != PRI

    ; tmp := case label
    ldi pl, lo(load_tmp_inc_sec)
    ldi ph, hi(load_tmp_inc_sec)
    jmp

    ; tmp == 0?
    ldi pl, lo(tmp)
    ldi ph, hi(tmp)
    ld b
    inc pl
    ld a
    or b, a
    ldi pl, lo(__cc_case_loop)
    ldi ph, hi(__cc_case_loop)
    jnz ; tmp != 0

__cc_case_default:
    ; jump to *(sec - 4)
    ldi pl, lo(__cc_r_sec + 1)
    ldi ph, hi(__cc_r_sec)
    ld a
    dec pl
    ld pl
    ; a:pl = sec
    dec pl
    sbb a, 0
    dec pl
    dec pl
    sbb a, 0
    mov ph, a
    ; P = sec - 3
    ld a
    dec pl
    ld pl
    mov ph, a
    jmp


    ; tmp := *sec
    ; sec += 2
load_tmp_inc_sec:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ; tmp := *sec
    ldi pl, lo(__cc_r_sec)
    ldi ph, hi(__cc_r_sec)
    ld a
    inc pl
    ld ph
    mov pl, a
    ld a
    inc pl
    ld b
    ldi pl, lo(tmp)
    ldi ph, hi(tmp)
    st a
    inc pl
    st b

    ; sec += 2
    ldi pl, lo(__cc_r_sec)
    ldi ph, hi(__cc_r_sec)
    ld b
    inc pl
    ld a
    inc b
    inc b
    adc a, 0
    st a
    dec pl
    st b

    ldi pl, lo(exit)
    ldi ph, hi(exit)
    jmp

    ; PRI = SEC >> PRI
__cc_asr:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri)
    ld b
    inc pl
    ld a
    ldi pl, lo(return_sec_sign)
    ldi ph, hi(return_sec_sign)
    add a, 0
    jnz ; PRI >= 256
    ldi a, 15
    sub a, b ; 15 - lo(PRI)
    jc ; 15 < lo(PRI)

    ldi a, 8
    sub b, a ; lo(PRI) - 8
    ldi pl, lo(__cc_asr_count_lt_8)
    ldi ph, hi(__cc_asr_count_lt_8)
    jc ; lo(PRI) < 8
    sub b, a
    ; b = count - 16

    ; lo(SEC) := hi(SEC)
    ; hi(SEC) := sign(SEC)
    ldi pl, lo(__cc_r_sec + 1)
    ldi ph, hi(__cc_r_sec)
    ld a
    dec pl
    st a
    inc pl
    shl a ; sign -> carry
    exp a
    st a
__cc_asr_count_lt_8:
    ; b = count - 8
    ; PRI := SEC
    ldi ph, hi(__cc_r_sec)
    ldi pl, lo(__cc_r_sec)
    ld a
    ldi pl, lo(__cc_r_pri)
    st a
    ldi pl, lo(__cc_r_sec + 1)
    ld a
    ldi pl, lo(__cc_r_pri + 1)
    st a

    ldi a, 8
    add b, a
    ldi pl, lo(exit)
    ldi ph, hi(exit)
    jz ; count == 0

    ; b = count
__cc_asr_loop:
    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri)
    ld a
    shr a
    st a
    inc pl
    ld a
    sar a
    st a
    ldi pl, lo(__cc_asr_loop_end)
    ldi ph, hi(__cc_asr_loop_end)
    jnc
    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri)
    ld a
    ldi pl, 0x80
    or a, pl
    ldi pl, lo(__cc_r_pri)
    st a
__cc_asr_loop_end:
    ldi pl, lo(__cc_asr_loop)
    ldi ph, hi(__cc_asr_loop)
    dec b
    jnz ; count != 0

    ldi pl, lo(exit)
    ldi ph, hi(exit)
    jmp

return_sec_sign:
    ldi pl, lo(__cc_r_sec + 1)
    ldi ph, hi(__cc_r_sec)
    ld a
    shl a ; sign -> carry
    exp a
    ldi pl, lo(__cc_r_pri)
    st a
    inc pl
    st a
    ldi pl, lo(exit)
    ldi ph, hi(exit)
    jmp

    ; PRI = SEC >> PRI
__cc_lsr:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri)
    ld b
    inc pl
    ld a
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    add a, 0
    jnz ; PRI >= 256
    ldi a, 15
    sub a, b ; 15 - lo(PRI)
    jc ; 15 < lo(PRI)

    ldi a, 8
    sub b, a ; lo(PRI) - 8
    ldi pl, lo(__cc_lsr_count_lt_8)
    ldi ph, hi(__cc_lsr_count_lt_8)
    jc ; lo(PRI) < 8
    sub b, a
    ; b = count - 16

    ; lo(SEC) := hi(SEC)
    ; hi(SEC) := 0
    ldi pl, lo(__cc_r_sec + 1)
    ldi ph, hi(__cc_r_sec)
    ld a
    dec pl
    st a
    inc pl
    mov a, 0
    st a
__cc_lsr_count_lt_8:
    ; b = count - 8
    ; PRI := SEC
    ldi ph, hi(__cc_r_sec)
    ldi pl, lo(__cc_r_sec)
    ld a
    ldi pl, lo(__cc_r_pri)
    st a
    ldi pl, lo(__cc_r_sec + 1)
    ld a
    ldi pl, lo(__cc_r_pri + 1)
    st a

    ldi a, 8
    add b, a
    ldi pl, lo(exit)
    ldi ph, hi(exit)
    jz ; count == 0

    ; b = count
__cc_lsr_loop:
    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri)
    ld a
    shr a
    st a
    inc pl
    ld a
    shr a
    st a
    ldi pl, lo(__cc_lsr_loop_end)
    ldi ph, hi(__cc_lsr_loop_end)
    jnc
    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri)
    ld a
    ldi pl, 0x80
    or a, pl
    ldi pl, lo(__cc_r_pri)
    st a
__cc_lsr_loop_end:
    ldi pl, lo(__cc_asr_loop)
    ldi ph, hi(__cc_asr_loop)
    dec b
    jnz ; count != 0

    ldi pl, lo(exit)
    ldi ph, hi(exit)
    jmp


    ; PRI = SEC << PRI
__cc_asl:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ldi pl, lo(__cc_r_pri)
    ld b
    inc pl
    ld a
    ldi pl, lo(return_0)
    ldi ph, hi(return_0)
    add a, 0
    jnz ; PRI >= 256
    ldi a, 15
    sub a, b ; 15 - lo(PRI)
    jc ; 15 < lo(PRI)

    ldi a, 8
    sub b, a ; lo(PRI) - 8
    ldi pl, lo(__cc_asl_count_lt_8)
    ldi ph, hi(__cc_asl_count_lt_8)
    jc ; lo(PRI) < 8
    sub b, a
    ; b = count - 16

    ; hi(SEC) := lo(SEC)
    ; lo(SEC) := 0
    ldi pl, lo(__cc_r_sec)
    ldi ph, hi(__cc_r_sec)
    ld a
    inc pl
    st a
    dec pl
    mov a, 0
    st a
__cc_asl_count_lt_8:
    ; b = count - 8
    ; PRI := SEC
    ldi ph, hi(__cc_r_sec)
    ldi pl, lo(__cc_r_sec)
    ld a
    ldi pl, lo(__cc_r_pri)
    st a
    ldi pl, lo(__cc_r_sec + 1)
    ld a
    ldi pl, lo(__cc_r_pri + 1)
    st a

    ldi a, 8
    add b, a
    ldi pl, lo(exit)
    ldi ph, hi(exit)
    jz ; count == 0

    ; b = count
__cc_asl_loop:
    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri + 1)
    ld a
    shl a
    st a
    dec pl
    ld a
    shl a
    st a
    ldi pl, lo(__cc_asl_loop_end)
    ldi ph, hi(__cc_asl_loop_end)
    jnc
    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri + 1)
    ld a
    ldi pl, 0x01
    or a, pl
    ldi pl, lo(__cc_r_pri + 1)
    st a
__cc_asl_loop_end:
    ldi pl, lo(__cc_asl_loop)
    ldi ph, hi(__cc_asl_loop)
    dec b
    jnz ; count != 0

    ldi pl, lo(exit)
    ldi ph, hi(exit)
    jmp


    ; multiply PRI and SEC, result into PRI
__cc_mul:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ; tmp := 0
    ldi pl, lo(tmp)
    ldi ph, hi(tmp)
    mov a, 0
    st a
    inc pl
    st a

__cc_mul_loop:
    ; lo(SEC) >>= 1
    ldi pl, lo(__cc_r_sec)
    ldi ph, hi(__cc_r_sec)
    ld a
    shr a
    st a
    ldi pl, lo(__cc_mul_added)
    ldi ph, hi(__cc_mul_added)
    jnc ; no need to add
    ; tmp += PRI
    ldi pl, lo(__cc_r_pri)
    ldi ph, hi(__cc_r_pri)
    ld a
    ldi pl, lo(tmp)
    ld b
    add b, a
    st b
    ldi pl, lo(__cc_r_pri + 1)
    ld a
    ldi pl, lo(tmp + 1)
    ld b
    adc b, a
    st b
__cc_mul_added:
    ; hi(SEC) >>= 1
    ldi pl, lo(__cc_r_sec + 1)
    ldi ph, hi(__cc_r_sec)
    ld b
    shr b
    st b
    exp b
    ldi a, 0x80
    and a, b
    ; lo(SEC) |= c ? 0x80 : 0
    dec pl
    ld b
    or a, b
    st a
    ; PRI <<= 1
    ldi pl, lo(__cc_r_pri)
    ld a
    shl a
    st a
    exp b
    ldi a, 0x01
    and b, a
    inc pl
    ld a
    shl a
    or a, b
    st a

    ; PRI | SEC == 0?
    ; a = hi(PRI)
    dec pl
    ld b
    or a, b
    ldi pl, lo(__cc_r_sec)
    ld b
    or a, b
    inc pl
    ld b
    or a, b
    ldi pl, lo(__cc_mul_loop)
    ldi ph, hi(__cc_mul_loop)
    jnz ; PRI | SEC != 0

    ; PRI := tmp
    ldi pl, lo(tmp)
    ldi ph, hi(tmp)
    ld a
    inc pl
    ld b
    ldi pl, lo(__cc_r_pri)
    st a
    inc pl
    st b

    ldi pl, lo(exit)
    ldi ph, hi(exit)
    jmp


    ; SEC / PRI
__cc_div:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ; tmp & 1 = nominator was negative
    ; tmp & 2 = denominator was negative
    ; tmp := 0
    ldi pl, lo(tmp)
    ldi ph, hi(tmp)
    mov a, 0
    st a

    ; test PRI
    ldi pl, lo(__cc_r_pri + 1)
    ld a
    add a, 0
    ldi pl, lo(__cc_div_neg_denom)
    ldi ph, hi(__cc_div_neg_denom)
    jc ; PRI < 0

__cc_div_test_sec:
    ; PRI >= 0
    ; test SEC
    ldi pl, lo(__cc_r_sec + 1)
    ldi ph, hi(__cc_r_sec)
    ld a
    add a, 0
    ldi pl, lo(__cc_div_neg_nom)
    ldi ph, hi(__cc_div_neg_nom)
    jc ; SEC < 0

__cc_div_positive:
    ; PRI >= 0
    ; SEC >= 0
    ; actually divide
    ldi pl, lo(divide)
    ldi ph, hi(divide)
    jmp

    ldi pl, lo(tmp)
    ldi ph, hi(tmp)
    ld a
    shr a
    st a
    ldi pl, lo(__cc_div_result_nom_positive)
    ldi ph, hi(__cc_div_result_nom_positive)
    jnc

    ; nominator was negative

    ; Q = ~Q
    ldi pl, lo(quotient)
    ldi ph, hi(quotient)
    ld a
    not a
    st a
    inc pl
    ld a
    not a
    st a

    ; R == 0?
    ldi pl, lo(remainder)
    ld a
    inc pl
    ld b
    or a, b
    ldi pl, lo(__cc_div_d_minus_r)
    ldi ph, hi(__cc_div_d_minus_r)
    jnz

    ; "return -Q, 0"
    ; R == 0
    ; Q += 1 - finish the negation
    ldi pl, lo(quotient)
    ldi ph, hi(quotient)
    ld b
    inc b
    st b
    ldi pl, lo(quotient + 1)
    ld a
    adc a, 0
    st a

    ldi pl, lo(__cc_div_result_nom_positive)
    ldi ph, hi(__cc_div_result_nom_positive)
    jmp

__cc_div_d_minus_r:
    ; "return -Q - 1, D - R"
    ; Q is already that
    ; R := PRI - R
    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri)
    ld b
    ldi pl, lo(remainder)
    ld a
    sub b, a
    st b
    ldi pl, lo(__cc_r_pri + 1)
    ld b
    ldi pl, lo(remainder + 1)
    ld a
    sbb b, a
    st b

__cc_div_result_nom_positive:
    ldi pl, lo(tmp)
    ldi ph, hi(tmp)
    ld a
    shr a
    ldi pl, lo(__cc_div_exit)
    ldi ph, hi(__cc_div_exit)
    jnc
    ; denominator was negative
    ; "return -Q, R"
    ; Q := -Q
    ldi pl, lo(quotient)
    ldi ph, hi(quotient)
    ld b
    inc pl
    ld a
    not b
    not a
    inc b
    adc a, 0
    st a
    dec pl
    st b

__cc_div_exit:
    ; PRI := Q
    ldi ph, hi(quotient)
    ldi pl, lo(quotient)
    ld a
    inc pl
    ld b
    ldi pl, lo(__cc_r_pri)
    st a
    inc pl
    st b
    ; SEC := R
    ldi pl, lo(remainder)
    ld a
    inc pl
    ld b
    ldi pl, lo(__cc_r_sec)
    st a
    inc pl
    st b

    ldi pl, lo(exit)
    ldi ph, hi(exit)
    jmp

__cc_div_neg_denom:
    ; PRI = -PRI
    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri)
    ld b
    inc pl
    ld a
    not a
    not b
    inc b
    adc a, 0
    st a
    dec pl
    st b

    ldi pl, lo(tmp)
    ldi a, 0x02 ; negative denominator
    st a

    ldi pl, lo(__cc_div_test_sec)
    ldi ph, hi(__cc_div_test_sec)
    jmp

__cc_div_neg_nom:
    ; SEC = - SEC
    ldi ph, hi(__cc_r_sec)
    ldi pl, lo(__cc_r_sec)
    ld b
    inc pl
    ld a
    not a
    not b
    inc b
    adc a, 0
    st a
    dec pl
    st b

    ldi pl, lo(tmp)
    ld a
    ldi b, 0x01 ; negative nominator
    or a, b
    st a

    ldi pl, lo(__cc_div_positive)
    ldi ph, hi(__cc_div_positive)
    jmp

__cc_udiv:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(int_ret)
    ldi ph, hi(int_ret)
    st b
    inc pl
    st a

    ; actually divide
    ldi pl, lo(divide)
    ldi ph, hi(divide)
    jmp

    ldi pl, lo(__cc_div_exit)
    ldi ph, hi(__cc_div_exit)
    jmp

    ; SEC / PRI
    ; preserve PRI
divide:
    mov a, pl
    mov b, a
    mov a, ph
    ldi pl, lo(div_ret)
    ldi ph, hi(div_ret)
    st b
    inc pl
    st a

    ; D == 0?
    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri)
    ld a
    inc pl
    ld b
    or a, b
    ldi pl, lo(__cc_div_zero_trap)
    ldi ph, hi(__cc_div_zero_trap)
    jz ; D == 0

    ; Q := 0
    ldi ph, hi(quotient)
    ldi pl, lo(quotient)
    mov a, 0
    st a
    inc pl
    st a
    ; R := 0
    ldi pl, lo(remainder)
    st a
    inc pl
    st a

    ; first half:

    ; qbit := 0x80
    ldi pl, lo(qbit)
    ldi a, 0x80
    st a

divide_loop_1:
    ; R := (R << 1) | msb(N)
    ; N <<= 1
    ldi ph, hi(remainder)
    ldi pl, lo(remainder)
    ld a
    shl a
    ldi pl, lo(__cc_r_sec + 1)
    ld b
    shl b
    st b
    adc a, 0
    ldi pl, lo(remainder)
    st a

    ; R >= D?
    ; hi(R) is still 0
    ldi pl, lo(__cc_r_pri + 1)
    ld a
    add a, 0
    ldi pl, lo(divide_loop_1_r_lt_d)
    ldi ph, hi(divide_loop_1_r_lt_d)
    jnz ; hi(D) != 0

    ldi ph, hi(remainder)
    ldi pl, lo(remainder)
    ld a
    ldi pl, lo(__cc_r_pri)
    ld b
    sub a, b ; lo(R) - lo(D)
    ldi pl, lo(divide_loop_1_r_lt_d)
    ldi ph, hi(divide_loop_1_r_lt_d)
    jc ; lo(R) < lo(D)

    ; R >= D
    ; R -= D
    ; hi(R) == 0, hi(D) == 0, overflow isn't possible
    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri)
    ld a
    ldi pl, lo(remainder)
    ld b
    sub b, a
    st b
    ; Q |= qbit
    ldi pl, lo(qbit)
    ld a
    ldi pl, lo(quotient + 1)
    ld b
    or b, a
    st b

divide_loop_1_r_lt_d:
    ; qbit >>= 1
    ldi ph, hi(qbit)
    ldi pl, lo(qbit)
    ld a
    shr a
    st a
    ldi ph, hi(divide_loop_1)
    ldi pl, lo(divide_loop_1)
    jnc

    ; second half:

    ; qbit := 0x80
    ldi ph, hi(qbit)
    ldi pl, lo(qbit)
    ldi a, 0x80
    st a

divide_loop_2:
    ; R := (R << 1) | msb(N)
    ; N <<= 1
    ldi ph, hi(remainder)
    ldi pl, lo(remainder)
    ld b
    inc pl
    ld a
    shl a
    shl b
    adc a, 0
    st a
    mov a, b
    ldi pl, lo(__cc_r_sec)
    ld b
    shl b
    st b
    adc a, 0
    ldi pl, lo(remainder)
    st a

    ; R >= D?
    ldi pl, lo(__cc_r_pri + 1)
    ld a
    ldi pl, lo(remainder + 1)
    ld b
    sub b, a
    ldi pl, lo(divide_loop_2_r_lt_d)
    ldi ph, hi(divide_loop_2_r_lt_d)
    jc ; hi(R) < hi(D)
    ldi pl, lo(divide_loop_2_r_gt_d)
    ldi ph, hi(divide_loop_2_r_gt_d)
    jnz

    ; hi(R) == hi(D)
    ldi ph, hi(remainder)
    ldi pl, lo(remainder)
    ld a
    ldi pl, lo(__cc_r_pri)
    ld b
    sub a, b ; lo(R) - lo(D)
    ldi pl, lo(divide_loop_2_r_lt_d)
    ldi ph, hi(divide_loop_2_r_lt_d)
    jc ; lo(R) < lo(D)

divide_loop_2_r_gt_d:
    ; R >= D
    ; R -= D
    ldi ph, hi(__cc_r_pri)
    ldi pl, lo(__cc_r_pri)
    ld a
    ldi pl, lo(remainder)
    ld b
    sub b, a
    st b
    ldi pl, lo(__cc_r_pri + 1)
    ld a
    ldi pl, lo(remainder + 1)
    ld b
    sbb b, a
    st b
    ; Q |= qbit
    ldi pl, lo(qbit)
    ld a
    ldi pl, lo(quotient)
    ld b
    or b, a
    st b

divide_loop_2_r_lt_d:
    ; qbit >>= 1
    ldi ph, hi(qbit)
    ldi pl, lo(qbit)
    ld a
    shr a
    st a
    ldi ph, hi(divide_loop_2)
    ldi pl, lo(divide_loop_2)
    jnc

    ldi pl, lo(div_ret)
    ldi ph, hi(div_ret)
    ld a
    inc pl
    ld ph
    mov pl, a
    jmp


__cc_div_zero_trap:
    ldi pl, lo(__cc_div_zero_trap)
    ldi ph, hi(__cc_div_zero_trap)
    jmp

    .section bss
    .align 32 ; all internal data have same hi byte
__cc_r_pri: res 2
__cc_r_sec: res 2
__cc_r_sp: res 2
__cc_r_ret: res 2

int_ret: res 2
tmp: res 2
div_ret: res 2

quotient: res 2
remainder: res 2
qbit: res 2
