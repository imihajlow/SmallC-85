/*      File code8080.c: 2.2 (84/08/31,10:05:09) */
/*% cc -O -c %
 *
 */

#include <stdio.h>
#include "defs.h"
#include "data.h"

/*      Define ASNM and LDNM to the names of the assembler and linker
        respectively */

/*
 *      Some predefinitions:
 *
 *      INTSIZE is the size of an integer in the target machine
 *      BYTEOFF is the offset of an byte within an integer on the
 *              target machine. (ie: 8080,pdp11 = 0, 6809 = 1,
 *              360 = 3)
 *      This compiler assumes that an integer is the SAME length as
 *      a pointer - in fact, the compiler uses INTSIZE for both.
 */

/**
 * print all assembler info before any code is generated
 */
void header () {
    output_string ("; Small C CCPU\n;");
    frontend_version();
    newline ();
    output_string ("\t.global __cc_r_pri\n");
    output_string ("\t.global __cc_r_sec\n");
    output_string ("\t.global __cc_r_sp\n");
    output_string ("\t.global __cc_r_ret\n");

    output_string ("\t.global __cc_push_pri\n");
    output_string ("\t.global __cc_push_sec\n");
    output_string ("\t.global __cc_push_ret\n");
    output_string ("\t.global __cc_pop_sec\n");
    output_string ("\t.global __cc_ret\n");
    output_string ("\t.global __cc_bool\n");
    output_string ("\t.global __cc_bool_not\n");
    output_string ("\t.global __cc_eq\n");
    output_string ("\t.global __cc_ne\n");
    output_string ("\t.global __cc_lt\n");
    output_string ("\t.global __cc_le\n");
    output_string ("\t.global __cc_ge\n");
    output_string ("\t.global __cc_gt\n");
    output_string ("\t.global __cc_ult\n");
    output_string ("\t.global __cc_ule\n");
    output_string ("\t.global __cc_uge\n");
    output_string ("\t.global __cc_ugt\n");
    output_string ("\t.global __cc_case\n");
    output_string ("\t.global __cc_asr\n");
    output_string ("\t.global __cc_lsr\n");
    output_string ("\t.global __cc_asl\n");
}

/**
 * prints new line
 * @return
 */
newline () {
#if __CYGWIN__ == 1
    output_byte (CR);
#endif
    output_byte (LF);
}

void initmac() {
    defmac("CCPU\t1");
    defmac("smallc\t1");
}

/**
 * Output internal generated label prefix
 */
void output_label_prefix() {
    output_string("_gen_");
}

/**
 * Output a label definition terminator
 */
void output_label_terminator () {
    output_byte (':');
}

/**
 * begin a comment line for the assembler
 */
void gen_comment() {
    output_byte (';');
}

/**
 * print any assembler stuff needed after all code
 */
void trailer() {
}

/**
 * text (code) segment
 */
void code_segment_gtext() {
    output_line (".section text");
}

/**
 * data segment
 */
void data_segment_gdata() {
    output_line (".section data");
    output_line (".align 2");
}

/**
 * Output the variable symbol at scptr as an extrn or a public
 * @param scptr
 */
void ppubext(SYMBOL *scptr)  {
    if (symbol_table[current_symbol_table_idx].storage == STATIC) return;
    output_with_tab (scptr->storage == EXTERN ? ".global\t" : ".export\t");
    output_string (scptr->name);
    newline();
}

/**
 * Output the function symbol at scptr as an extrn or a public
 * @param scptr
 */
void fpubext(SYMBOL *scptr) {
    if (scptr->storage == STATIC) return;
    output_with_tab (scptr->offset == FUNCTION ? ".export\t" : ".global\t");
    output_string (scptr->name);
    newline ();
}

/**
 * Output a decimal number to the assembler file
 * @param num
 */
void output_number(num) int num; {
    output_decimal(num);
}

/**
 * Store a:b into PRI
 */
void gen_store_pri() {
    output_with_tab ("ldi pl, lo(__cc_r_pri)"); newline ();
    output_with_tab ("ldi ph, hi(__cc_r_pri)"); newline ();
    output_with_tab ("st b"); newline ();
    output_with_tab ("inc pl"); newline();
    output_with_tab ("st a"); newline ();
}

/**
 * fetch a static memory cell into __cc_r_pri
 * @param sym
 */
void gen_get_memory(SYMBOL *sym) {
    output_line("; gen_get_memory");
    output_with_tab ("ldi pl, lo("); output_string (sym->name); output_byte(')'); newline ();
    output_with_tab ("ldi ph, hi("); output_string (sym->name); output_byte(')'); newline ();
    if ((sym->identity != POINTER) && (sym->type == CCHAR)) {
        // fetch byte, sign extend to int
        output_with_tab ("ld b"); newline ();
        output_with_tab ("mov a, b"); newline();
        output_with_tab ("shl a"); newline(); // sign -> carry
        output_with_tab ("exp a"); newline();
    } else if ((sym->identity != POINTER) && (sym->type == UCHAR)) {
        // fetch byte, zero extend to int
        output_with_tab ("ld b"); newline ();
        output_with_tab ("mov a, 0"); newline();
    } else {
        // fetch two bytes, unaligned
        output_line ("ld b");
        output_line ("inc pl");
        output_line ("mov a, 0");
        output_line ("adc ph, a");
        output_line ("ld a");
    }
    gen_store_pri();
}

/**
 * asm - fetch the address of the specified symbol into the primary register
 * @param sym the symbol name
 * @return which register pair contains result
 */
int gen_get_locale(SYMBOL *sym) {
    int sp_offset;
    output_line("; gen_get_locale");
    if (sym->storage == LSTATIC) {
        // load from a local label
        gen_immediate_label(sym->offset, 0);
        return PRI_REG;
    } else {
        sp_offset = sym->offset - stkp;
        // x = sym->offset - stkp
        // pri = sp + X
        output_with_tab ("ldi pl, lo(__cc_r_sp)"); newline ();
        output_with_tab ("ldi ph, hi(__cc_r_sp)"); newline ();
        output_with_tab ("ldi b, lo("); output_decimal (sp_offset); output_byte (')'); newline ();
        output_with_tab ("ld a"); newline ();
        output_with_tab ("add b, a"); newline ();
        output_with_tab ("inc pl"); newline ();
        output_with_tab ("ldi a, hi("); output_decimal (sp_offset); output_byte (')'); newline ();
        output_with_tab ("ld pl"); newline ();
        output_with_tab ("adc a, pl"); newline ();
        // a:b = result
        gen_store_pri();

        return PRI_REG;
    }
}

/**
 * asm - store the primary register into the specified static memory cell
 * @param sym
 */
void gen_put_memory(SYMBOL *sym) {
    int one_byte;
    output_line("; gen_put_memory");
    one_byte = (sym->identity != POINTER) && (sym->type & CCHAR);
    output_line ("ldi pl, lo(__cc_r_pri)");
    output_line ("ldi ph, hi(__cc_r_pri)");
    output_line ("ld a");
    if (!one_byte) {
        output_line ("inc pl");
        output_line ("ld b");
    }
    output_with_tab ("ldi pl, lo("); output_string (sym->name); output_byte(')'); newline ();
    output_with_tab ("ldi ph, hi("); output_string (sym->name); output_byte(')'); newline ();
    output_line ("st a");
    if (!one_byte) {
        output_line ("inc pl");
        output_line ("mov a, 0");
        output_line ("adc ph, a");
        output_line ("st b");
    }
}

/**
 * store the specified object type in the primary register
 * at the address in secondary register (on the top of the stack)
 * @param typeobj
 */
void gen_put_indirect(char typeobj) {
    output_line("; gen_put_indirect");
    gen_pop ();

    // assuming hi(__cc_r_pri) == hi(__cc_r_sec)
    output_line ("ldi pl, lo(__cc_r_pri)");
    output_line ("ldi ph, hi(__cc_r_pri)");
    output_line ("ld b");

    output_line ("ldi pl, lo(__cc_r_sec)");
    output_line ("ld a");
    output_line ("inc pl");
    output_line ("ld ph");
    output_line ("mov pl, a");
    output_line ("st b");

    if (!(typeobj & CCHAR)) {
        output_line ("ldi pl, lo(__cc_r_pri + 1)");
        output_line ("ldi ph, hi(__cc_r_pri)");
        output_line ("ld b");

        output_line ("ldi pl, lo(__cc_r_sec + 1)");
        output_line ("ld ph");
        output_line ("mov pl, a");
        output_line ("inc pl");
        output_line ("mov a, 0");
        output_line ("adc ph, a");
        output_line ("st b");
    }
}

/**
 * fetch the specified object type indirect through the specified
 * register into the primary register
 * @param typeobj object type
 */
void gen_get_indirect(char typeobj, int reg) {
    const char *reg_name;
    output_line("; gen_get_indirect");
    if (reg & SEC_REG)
    {
        reg_name = "__cc_r_sec";
    }
    else
    {
        reg_name = "__cc_r_pri";
    }
    output_with_tab ("ldi pl, lo("); output_string(reg_name); output_byte(')'); newline ();
    output_with_tab ("ldi ph, hi("); output_string(reg_name); output_byte(')'); newline ();
    output_line ("ld a");
    output_line ("inc pl");
    output_line ("ld ph");
    output_line ("mov pl, a");
    output_line ("ld b");
    if (typeobj == CCHAR) {
        output_line ("mov a, b");
        output_line ("shl a");
        output_line ("exp a");
    } else if (typeobj == UCHAR) {
        output_line ("mov a, 0");
    } else { /*int*/
        output_line ("inc pl");
        output_line ("mov a, 0");
        output_line ("adc ph, a");
        output_line ("ld a");
    }
    gen_store_pri();
}

/**
 * swap the primary and secondary registers
 */
gen_swap() {
    output_line("; gen_swap");
    // assuming hi(__cc_r_pri) == hi(__cc_r_sec)
    output_with_tab ("ldi ph, hi(__cc_r_pri)"); newline ();
    output_with_tab ("ldi pl, lo(__cc_r_pri)"); newline ();
    output_with_tab ("ld a"); newline ();
    output_with_tab ("ldi pl, lo(__cc_r_sec)"); newline ();
    output_with_tab ("ld b"); newline ();
    output_with_tab ("st a"); newline ();
    output_with_tab ("ldi pl, lo(__cc_r_pri)"); newline ();
    output_with_tab ("st b"); newline ();
    output_with_tab ("inc pl"); newline ();
    output_with_tab ("ld a"); newline ();
    output_with_tab ("ldi pl, lo(__cc_r_sec + 1)"); newline ();
    output_with_tab ("ld b"); newline ();
    output_with_tab ("st a"); newline ();
    output_with_tab ("ldi pl, lo(__cc_r_pri + 1)"); newline ();
    output_with_tab ("st b"); newline ();
 }

/**
 * get an immediate value into the primary register
 */
gen_immediate_number(int x) {
    output_line("; gen_immediate_number");
    output_with_tab ("ldi pl, lo(__cc_r_pri)"); newline ();
    output_with_tab ("ldi ph, hi(__cc_r_pri)"); newline ();
    output_with_tab ("ldi a, lo("); output_number(x); output_byte(')'); newline ();
    output_with_tab ("st a"); newline ();
    output_with_tab ("inc pl"); newline ();
    output_with_tab ("ldi a, hi("); output_number(x); output_byte(')'); newline ();
    output_with_tab ("st a"); newline ();
}

gen_immediate_symbol(char *s, int offset) {
    output_line("; gen_immediate_symbol");
    output_with_tab ("ldi pl, lo(__cc_r_pri)"); newline ();
    output_with_tab ("ldi ph, hi(__cc_r_pri)"); newline ();
    output_with_tab ("ldi a, lo("); output_string(s);
    if (offset)
    {
        output_string(" + ");
        output_decimal(offset);
    }
    output_byte(')'); newline ();
    output_with_tab ("st a"); newline ();
    output_with_tab ("inc pl"); newline ();
    output_with_tab ("ldi a, hi("); output_string(s);
    if (offset)
    {
        output_string(" + ");
        output_decimal(offset);
    }
    output_byte(')'); newline ();
    output_with_tab ("st a"); newline ();
}

gen_immediate_label(int label, int offset) {
    output_line("; gen_immediate_label");
    output_line ("ldi pl, lo(__cc_r_pri)");
    output_line ("ldi ph, hi(__cc_r_pri)");
    output_with_tab ("ldi a, lo("); print_label(label);
    if (offset)
    {
        output_string(" + ");
        output_decimal(offset);
    }
    output_byte(')'); newline();
    output_line ("st a");
    output_line ("inc pl");
    output_with_tab ("ldi a, hi("); print_label(label);
    if (offset)
    {
        output_string(" + ");
        output_decimal(offset);
    }
    output_byte(')'); newline();
    output_line ("st a");
}

/**
 * push a register onto the stack
 */
gen_push(int reg) {
    output_line("; gen_push");
    if (reg & SEC_REG)
    {
        gen_call("__cc_push_sec");
    }
    else
    {
        gen_call("__cc_push_pri");
    }
    stkp = stkp - INTSIZE;
}

/**
 * pop the top of the stack into the secondary register
 */
gen_pop() {
    output_line("; gen_pop");
    gen_call("__cc_pop_sec");
    stkp = stkp + INTSIZE;
}

/**
 * swap the primary register and the top of the stack
 */
gen_swap_stack() {
    output_line("; gen_swap_stack");
    gen_call("__cc_swap_stack_pri");
}

/**
 * call the specified subroutine name
 * @param sname subroutine name
 */
gen_call(char *sname) {
    output_line("; gen_call");
    output_with_tab ("ldi ph, hi("); output_string (sname); output_byte (')'); newline ();
    output_with_tab ("ldi pl, lo("); output_string (sname); output_byte (')'); newline ();
    output_line("jmp");
}

/**
 * declare entry point
 */
declare_entry_point(char *symbol_name) {
    output_string (symbol_name); output_label_terminator (); newline ();
    output_line ("mov a, pl");
    output_line ("mov b, a");
    output_line ("mov a, ph");
    output_line ("ldi ph, hi(__cc_r_ret)");
    output_line ("ldi pl, lo(__cc_r_ret)");
    output_line ("st b");
    output_line ("inc pl");
    output_line ("st a");
    gen_call ("__cc_push_ret");
}

/**
 * return from subroutine
 */
gen_ret() {
    gen_call ("__cc_ret");
}

/**
 * perform subroutine call to value on top of stack
 */
callstk() {
    output_line ("; callstk");
    output_line ("ldi pl, lo(__cc_r_sp)");
    output_line ("ldi ph, hi(__cc_r_sp)");
    output_line ("ld a");
    output_line ("inc pl");
    output_line ("ld ph");
    output_line ("mov pl, a");
    output_line ("jmp");
    // SP += 2 ?
    // stkp = stkp + INTSIZE; ?
}

/**
 * jump to specified internal label number
 * @param label the label
 */
gen_jump(label)
int     label;
{
    output_line("; gen_jump");
    output_with_tab ("ldi ph, hi("); print_label (label); output_byte (')'); newline ();
    output_with_tab ("ldi pl, lo("); print_label (label); output_byte (')'); newline ();
    output_line("jmp");
}

/**
 * test the primary register and jump if false to label
 * @param label the label
 * @param ft if true jnz is generated, jz otherwise
 */
gen_test_jump(label, ft)
int     label,
        ft;
{
    output_line("; gen_test_jump");
    output_line ("ldi ph, hi(__cc_r_pri)");
    output_line ("ldi pl, lo(__cc_r_pri)");
    output_line ("ld a");
    output_line ("inc pl");
    output_line ("ld b");
    output_line ("or a, b");
    output_with_tab ("ldi ph, hi("); print_label (label); output_byte (')'); newline ();
    output_with_tab ("ldi pl, lo("); print_label (label); output_byte (')'); newline ();
    if (ft)
        output_line ("jnz");
    else
        output_line ("jz");
}

/**
 * print pseudo-op  to define a byte
 */
gen_def_byte() {
    output_with_tab ("db ");
}

/**
 * print pseudo-op to define storage
 */
gen_def_storage() {
    output_with_tab ("res ");
}

/**
 * print pseudo-op to define a word
 */
gen_def_word() {
    output_with_tab ("dw ");
}

/**
 * modify the stack pointer to the new value indicated
 * @param newstkp new value
 */
gen_modify_stack(int newstkp) {
    int k;

    output_line("; gen_modify_stack");

    k = newstkp - stkp;
    if (k == 0)
        return (newstkp);
    output_line ("ldi ph, hi(__cc_r_sp)");
    output_line ("ldi pl, lo(__cc_r_sp)");
    output_line ("ld a");
    output_with_tab ("ldi b, lo("); output_number (k); output_byte (')'); newline ();
    output_line ("add a, b");
    output_line ("st a");
    output_line ("ldi pl, lo(__cc_r_sp + 1)");
    output_line ("ld a");
    output_with_tab ("ldi b, hi("); output_number (k); output_byte (')'); newline ();
    output_line ("adc a, b");
    output_line ("st a");
    return (newstkp);
}

static gen_multiply_by_two_common() {
    output_line ("ld b");
    output_line ("inc pl");
    output_line ("ld a");
    output_line ("shl a");
    output_line ("shl b");
    output_line ("adc a, 0");
    output_line ("st a");
    output_line ("dec pl");
    output_line ("st b");
}

/**
 * multiply the primary register by 2
 */
gen_multiply_by_two() {
    output_line("; gen_multiply_by_two");
    output_line ("ldi pl, lo(__cc_r_pri)");
    output_line ("ldi ph, hi(__cc_r_pri)");
    gen_multiply_by_two_common();
}

/**
 * multiply the secondary register by 2
 */
gen_multiply_by_two_sec() {
    output_line("; gen_multiply_by_two_sec");
    output_line ("ldi pl, lo(__cc_r_sec)");
    output_line ("ldi ph, hi(__cc_r_sec)");
    gen_multiply_by_two_common();
}

/**
 * divide the primary register by 2
 */
gen_divide_by_two() {
    output_line("; gen_divide_by_two");
    output_line ("ldi pl, lo(__cc_r_pri + 1)");
    output_line ("ldi ph, hi(__cc_r_pri)");
    output_line ("ld b");
    output_line ("shr b");
    output_line ("st b");
    output_line ("exp b");
    output_line ("ldi a, 0x80");
    output_line ("and b, a");
    output_line ("dec pl");
    output_line ("ld a");
    output_line ("shr a");
    output_line ("or a, b");
    output_line ("st a");
}

/**
 * Case jump instruction
 */
gen_jump_case() {
    output_line ("; gen_jump_case");
    output_line ("ldi pl, lo(__cc_case)");
    output_line ("ldi ph, hi(__cc_case)");
    output_line ("jmp");
}

/**
 * add the primary and secondary registers
 * if lval2 is int pointer and lval is not, scale lval
 * @param lval
 * @param lval2
 */
gen_add(lval,lval2) int *lval,*lval2; {
    output_line("; gen_add");
    gen_pop (); // SEC := pop()
    if (dbltest (lval2, lval)) {
        // SEC *= 2
        gen_multiply_by_two_sec();
    }
    // PRI += SEC
    output_line ("ldi ph, hi(__cc_r_sec)");
    output_line ("ldi pl, lo(__cc_r_sec)");
    output_line ("ld b");
    output_line ("ldi pl, lo(__cc_r_pri)");
    output_line ("ld a");
    output_line ("add a, b");
    output_line ("st a");
    output_line ("ldi pl, lo(__cc_r_sec + 1)");
    output_line ("ld b");
    output_line ("ldi pl, lo(__cc_r_pri + 1)");
    output_line ("ld a");
    output_line ("add a, b");
    output_line ("st a");
}

/**
 * subtract the primary register from the secondary
 * PRI -= SEC
 */
gen_sub() {
    output_line("; gen_sub");
    gen_pop ();
    output_line ("ldi ph, hi(__cc_r_sec)");
    output_line ("ldi pl, lo(__cc_r_sec)");
    output_line ("ld b");
    output_line ("ldi pl, lo(__cc_r_pri)");
    output_line ("ld a");
    output_line ("sub a, b");
    output_line ("st a");
    output_line ("ldi pl, lo(__cc_r_sec + 1)");
    output_line ("ld b");
    output_line ("ldi pl, lo(__cc_r_pri + 1)");
    output_line ("ld a");
    output_line ("sbb a, b");
    output_line ("st a");
}

/**
 * multiply the primary and secondary registers (result in primary)
 * PRI *= SEC
 */
gen_mult() {
    output_line("; gen_mult");
    gen_pop();
    gen_call ("TODO MUL");
}

/**
 * divide the secondary register by the primary
 * (quotient in primary, remainder in secondary)
 */
gen_div() {
    output_line("; gen_div");
    gen_pop();
    gen_call ("TODO DIV");
}

/**
 * unsigned divide the secondary register by the primary
 * (quotient in primary, remainder in secondary)
 */
gen_udiv() {
    output_line("; gen_udiv");
    gen_pop();
    gen_call ("TODO UDIV");
}

/**
 * compute the remainder (mod) of the secondary register
 * divided by the primary register
 * (remainder in primary, quotient in secondary)
 */
gen_mod() {
    output_line("; gen_mod");
    gen_div ();
    gen_swap ();
}

/**
 * compute the remainder (mod) of the secondary register
 * divided by the primary register
 * (remainder in primary, quotient in secondary)
 */
gen_umod() {
    output_line("; gen_umod");
    gen_udiv ();
    gen_swap ();
}

/**
 * inclusive 'or' the primary and secondary registers
 */
gen_or() {
    output_line("; gen_or");
    gen_pop();
    output_line ("ldi ph, hi(__cc_r_sec)");
    output_line ("ldi pl, lo(__cc_r_sec)");
    output_line ("ld b");
    output_line ("ldi pl, lo(__cc_r_pri)");
    output_line ("ld a");
    output_line ("or a, b");
    output_line ("st a");
    output_line ("ldi pl, lo(__cc_r_sec + 1)");
    output_line ("ld b");
    output_line ("ldi pl, lo(__cc_r_pri + 1)");
    output_line ("ld a");
    output_line ("or a, b");
    output_line ("st a");
}

/**
 * exclusive 'or' the primary and secondary registers
 */
gen_xor() {
    output_line("; gen_xor");
    gen_pop();
    output_line ("ldi ph, hi(__cc_r_sec)");
    output_line ("ldi pl, lo(__cc_r_sec)");
    output_line ("ld b");
    output_line ("ldi pl, lo(__cc_r_pri)");
    output_line ("ld a");
    output_line ("xor a, b");
    output_line ("st a");
    output_line ("ldi pl, lo(__cc_r_sec + 1)");
    output_line ("ld b");
    output_line ("ldi pl, lo(__cc_r_pri + 1)");
    output_line ("ld a");
    output_line ("xor a, b");
    output_line ("st a");
}

/**
 * 'and' the primary and secondary registers
 */
gen_and() {
    output_line("; gen_and");
    gen_pop();
    output_line ("ldi ph, hi(__cc_r_sec)");
    output_line ("ldi pl, lo(__cc_r_sec)");
    output_line ("ld b");
    output_line ("ldi pl, lo(__cc_r_pri)");
    output_line ("ld a");
    output_line ("and a, b");
    output_line ("st a");
    output_line ("ldi pl, lo(__cc_r_sec + 1)");
    output_line ("ld b");
    output_line ("ldi pl, lo(__cc_r_pri + 1)");
    output_line ("ld a");
    output_line ("and a, b");
    output_line ("st a");
}

/**
 * arithmetic shift right the secondary register the number of
 * times in the primary register (results in primary register)
 */
gen_arithm_shift_right() {
    output_line("; gen_arithm_shift_right");
    gen_pop();
    gen_call ("__cc_asr");
}

/**
 * logically shift right the secondary register the number of
 * times in the primary register (results in primary register)
 */
gen_logical_shift_right() {
    output_line("; gen_logical_shift_right");
    gen_pop();
    gen_call ("__cc_lsr");
}

/**
 * arithmetic shift left the secondary register the number of
 * times in the primary register (results in primary register)
 */
gen_arithm_shift_left() {
    output_line("; gen_arithm_shift_left");
    gen_pop ();
    gen_call ("__cc_asl");
}

/**
 * two's complement of primary register
 * PRI = -PRI
 */
gen_twos_complement() {
    output_line("; gen_twos_complement");
    output_line ("ldi ph, hi(__cc_r_pri)");
    output_line ("ldi pl, lo(__cc_r_pri)");
    output_line ("ld b");
    output_line ("inc pl");
    output_line ("ld a");
    output_line ("not a");
    output_line ("not b");
    output_line ("inc b");
    output_line ("adc a, 0");
    output_line ("st a");
    output_line ("dec pl");
    output_line ("st b");
}

/**
 * logical complement of primary register
 * PRI = !PRI
 */
gen_logical_negation() {
    output_line("; gen_logical_negation");
    gen_call("__cc_bool_not");
}

/**
 * one's complement of primary register
 * PRI = ~PRI
 */
gen_complement() {
    output_line("; gen_complement");
    output_line ("ldi ph, hi(__cc_r_pri)");
    output_line ("ldi pl, lo(__cc_r_pri)");
    output_line ("ld a");
    output_line ("not a");
    output_line ("st a");
    output_line ("inc pl");
    output_line ("ld a");
    output_line ("not a");
    output_line ("st a");
}

/**
 * Convert primary value into logical value (0 if 0, 1 otherwise)
 * PRI = PRI != 0 ? 1 : 0
 */
gen_convert_primary_reg_value_to_bool() {
    output_line("; gen_convert_primary_reg_value_to_bool");
    gen_call ("__cc_bool");
}

/**
 * increment the primary register by 1 if char, INTSIZE if int
 */
gen_increment_primary_reg(LVALUE *lval) {
    output_line("; gen_increment_primary_reg");
    if (lval->ptr_type == STRUCT) {
        add_offset(lval->tagsym->size);
    } else {
        output_line ("ldi ph, hi(__cc_r_pri)");
        output_line ("ldi pl, lo(__cc_r_pri)");
        output_line ("ld b");
        output_line ("inc pl");
        output_line ("ld a");
        output_line ("inc b");
        output_line ("adc a, 0");
        if (lval->ptr_type & CINT)
        {
            output_line ("inc b");
            output_line ("adc a, 0");
        }
        output_line ("st a");
        output_line ("dec pl");
        output_line ("st b");
    }
}

/**
 * decrement the primary register by one if char, INTSIZE if int
 */
gen_decrement_primary_reg(LVALUE *lval) {
    output_line("; gen_decrement_primary_reg");
    output_line ("ldi ph, hi(__cc_r_pri)");
    output_line ("ldi pl, lo(__cc_r_pri)");
    if (lval->ptr_type == STRUCT) {
        output_line ("ld a");
        output_line ("inc pl");
        output_line ("ld b");
        output_with_tab ("ldi pl, lo("); output_number (lval->tagsym->size); output_byte (')'); newline();
        output_line ("sub a, pl");
        output_line ("mov pl, a");
        output_with_tab ("ldi a, hi("); output_number (lval->tagsym->size); output_byte (')'); newline();
        output_line ("sbb b, a");
        output_line ("mov a, pl");
        output_line ("ldi pl, lo(__cc_r_pri)");
        output_line ("st a");
        output_line ("inc pl");
        output_line ("st b");
    } else {
        output_line ("ld b");
        output_line ("inc pl");
        output_line ("ld a");
        output_line ("dec b");
        output_line ("sbb a, 0");
        if (lval->ptr_type & CINT)
        {
            output_line ("dec b");
            output_line ("sbb a, 0");
        }
        output_line ("st a");
        output_line ("dec pl");
        output_line ("st b");
    }
}

/**
 * following are the conditional operators.
 * they compare the secondary register against the primary register
 * and put a literal 1 in the primary if the condition is true,
 * otherwise they clear the primary register
 */

/**
 * equal
 */
gen_equal() {
    gen_pop();
    gen_call ("__cc_eq");
}

/**
 * not equal
 */
gen_not_equal() {
    gen_pop();
    gen_call ("__cc_ne");
}

/**
 * less than (signed)
 */
gen_less_than() {
    gen_pop();
    gen_call ("__cc_lt");
}

/**
 * less than or equal (signed)
 */
gen_less_or_equal() {
    gen_pop();
    gen_call ("__cc_le");
}

/**
 * greater than (signed)
 */
gen_greater_than() {
    gen_pop();
    gen_call ("__cc_gt");
}

/**
 * greater than or equal (signed)
 */
gen_greater_or_equal() {
    gen_pop();
    gen_call ("__cc_ge");
}

/**
 * less than (unsigned)
 */
gen_unsigned_less_than() {
    gen_pop();
    gen_call ("__cc_ult");
}

/**
 * less than or equal (unsigned)
 */
gen_unsigned_less_or_equal() {
    gen_pop();
    gen_call ("__cc_ule");
}

/**
 * greater than (unsigned)
 */
gen_usigned_greater_than() {
    gen_pop();
    gen_call ("__cc_ugt");
}

/**
 * greater than or equal (unsigned)
 */
gen_unsigned_greater_or_equal() {
    gen_pop();
    gen_call ("__cc_uge");
}

char *inclib() {
#ifdef  INCDIR
        return(INCDIR);
#else
        return "";
#endif
}

int assemble(s)
char    *s; {
    return(0);
}

int link() {
    return(0);
}

/**
 * add offset to primary register
 * @param val the value
 */
add_offset(int val) {
    output_line("; add_offset");
    output_line ("ldi ph, hi(__cc_r_pri)");
    output_line ("ldi pl, lo(__cc_r_pri)");
    output_line ("ld a");
    output_line ("inc pl");
    output_line ("ld b");
    output_with_tab ("ldi pl, lo("); output_number (val); output_byte (')'); newline();
    output_line ("add pl, a");
    output_with_tab ("ldi a, hi("); output_number (val); output_byte (')'); newline();
    output_line ("adc b, a");
    output_line ("mov a, pl");
    output_line ("ldi pl, lo(__cc_r_pri)");
    output_line ("st a");
    output_line ("inc pl");
    output_line ("st b");
}

/**
 * multiply the primary register by the length of some variable
 * @param type
 * @param size
 */
gen_multiply(int type, int size) {
    output_line("; gen_multiply");
    switch (type) {
        case CINT:
        case UINT:
            gen_multiply_by_two();
            break;
        case STRUCT:
            // gen_immediate2();
            output_number(size);
            newline();
            gen_call("ccmul");
            break ;
        default:
            break;
    }
}

gen_align(int size) {
    output_with_tab(".align "); output_number(size); newline();
}

