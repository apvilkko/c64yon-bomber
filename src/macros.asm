; branches to \3 when \1 >= \2
gte_branch	macro
	lda \1
	cmp \2
	bcs \3
	endmacro

; branches to \2 with probability \1
if_rand	macro
	ldx \1
	jsr Rand
	cmp #1
	beq \2
	endmacro

; stores 16-bit number (\2=hi \3=lo) to \1
sta16	macro
	lda \2
	sta \1+1
	lda \3
	sta \1
	endmacro

; inc 16-bit number \1 by 8-bit number (A)
; nukes A
inc16	macro
	clc
	adc \1
	sta \1
	lda \1+1
	adc #$00
	sta \1+1
	endmacro

; dec 16-bit number \1 by 8-bit number \2
; nukes A
dec16	macro
	sec
	lda \1
	sbc \2
	sta \1
	lda \1+1
	sbc #0
	sta \1+1
	endmacro

; branches to \3 when \1 >= \2
gte_branch16	macro
	lda \1+1
	cmp \2+1
	bcc .\@ ; \1 < \2
	bne \3 ; \1 > \2
	lda \1
	cmp \2
	bcc .\@ ; \1 < \2
	beq \3 ; \1 = \2
	bne \3 ; \1 > \2
.\@:
	endmacro

; converts pixel coordinate (A) to character coordinate (=divide by 8)
to_char_coord	macro
	lsr
	lsr
	lsr
	endmacro

; converts pixel coordinate (\1, 16-bit) to character coordinate (=divide by 8)
to_char_coord_16	macro
	lsr \1+1
	ror \1
	lsr \1+1
	ror \1
	lsr \1+1
	ror \1
	endmacro