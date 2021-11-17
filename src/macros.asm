; branches to \3 when \1 >= \2
gte_branch	macro
	lda \1
	cmp \2
	bcs \3
	endmacro

; stores 16-bit number (\2=hi \3=lo) to \1
sta16	macro
	lda \2
	sta \1+1
	lda \3
	sta \1
	endmacro

; same as above but \1 is x indexed
sta16_x	macro
	lda \2
	sta \1+1,x
	lda \3
	sta \1,x
	endmacro

; same as sta16 but \2 and \3 are x indexed
sta16_x2	macro
	lda \2,x
	sta \1+1
	lda \3,x
	sta \1
	endmacro

; same as above but everything is x indexed
sta16_x_x	macro
	lda \2,x
	sta \1+1,x
	lda \3,x
	sta \1,x
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

; same as above but \1 is x indexed
inc16_x	macro
	clc
	adc \1,x
	sta \1,x
	lda \1+1,x
	adc #$00
	sta \1+1,x
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

; same as above but \1 is x indexed
dec16_x	macro
	sec
	lda \1,x
	sbc \2
	sta \1,x
	lda \1+1,x
	sbc #0
	sta \1+1,x
	endmacro

; same as above, both \1 and \2 are x indexed
dec16_x_x	macro
	sec
	lda \1,x
	sbc \2,x
	sta \1,x
	lda \1+1,x
	sbc #0
	sta \1+1,x
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

; three-way random choice: jumps to \1,\2 or \3
rand3	macro
	jsr Rand
	lsr ; clamp random number to 0-127
	cmp #84
	bcs \1
	cmp #42
	bcs \2
	jmp \3
	endmacro