/**
 * Dead test for ZX Spectrum 16k/48k (see const.S)
 * Public domain
 */
.include "const.S"

.org 0

reset:
    di
    jr memtest
    
.org 0x38, 0xff

vsync:
    di

    /* black border background */
    xor a
    out (PBORD), a
    
    /* sleep (vertical offset) */
    ld bc, VOFFSET
0:
    dec bc
    ld a, b
    or c
    jr nz, 0b

    /* C = check byte */
    ex af, af'
    ld c, a
    ex af, af'
    
    /* for d in 8..1 */
    ld d, 0x08
1:  /* start line */

    /* check lower bit */
    bit 0, c
    jr z, 2f

    /* bad bit */
    ld a, FAILCOLOR
    ld b, BHEIGHT * 2
    jr 3f
2:
    /* good bit */
    ld a, GOODCOLOR
    ld b, BHEIGHT
3:
    out (PBORD), a
0:
    djnz 0b

    /* draw spacer */
    xor a
    out (PBORD), a
    ld b, SHEIGHT
0:
    djnz 0b

    /* shift result byte */
    sra c

    dec d
    jr nz, 1b

    /* wait for int */
    ei
    halt

/****************************************************/

.macro TEST_RAM_PATTERN pattern

    ld hl, RAMSTART
    ld de, RAMSTART+1
    ld bc, RAMSIZE
    ld a, \pattern
    ld (hl), a
    ldir
    
    /* scan RAM for bad bits */
    ld hl, RAMSTART
    ld bc, RAMSIZE
    ld d, 0
    
0:
    /* test byte */
    ld a, \pattern
    xor (hl)
    or d
    ld d, a
    inc hl
    dec bc
    /* while (BC) */
    ld a, b  
    or c
    jr nz, 0b

    /* put result into A' */
    ex af, af'
    or d
    ex af, af'

.endm

memtest:
    /* do not touch RAM */
    ld sp, 0

    /* init check byte (A') */
    xor a
    ex af, af'

    TEST_RAM_PATTERN 0x00
    TEST_RAM_PATTERN 0xff
    TEST_RAM_PATTERN 0x55
    TEST_RAM_PATTERN 0xaa

    /* run frame refresh */
    ei
    halt
    rst 0x38
