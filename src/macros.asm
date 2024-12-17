; branches to \3 when \1 >= \2
.macro gte_branch first, second, target
	lda first
	cmp second
	bcs target
.endmacro

; stores 16-bit number (\2=hi \3=lo) to \1
.macro sta16 target, hi, lo
	lda hi
	sta target+1
	lda lo
	sta target
.endmacro

; same as above but \1 is x indexed
.macro sta16_x target, hi, lo
	lda hi
	sta target+1,x
	lda lo
	sta target,x
.endmacro

; same as sta16 but \2 and \3 are x indexed
.macro sta16_x2 target, hi, lo
	lda hi,x
	sta target+1
	lda lo,x
	sta target
.endmacro

; same as above but everything is x indexed
.macro sta16_x_x target, hi, lo
	lda hi,x
	sta target+1,x
	lda lo,x
	sta target,x
.endmacro

; inc 16-bit number \1 by 8-bit number (A)
; nukes A
.macro inc16 num16
	clc
	adc num16
	sta num16
	lda num16+1
	adc #$00
	sta num16+1
.endmacro

; same as above but \1 is x indexed
.macro inc16_x num16
	clc
	adc num16,x
	sta num16,x
	lda num16+1,x
	adc #$00
	sta num16+1,x
.endmacro

; dec 16-bit number \1 by 8-bit number \2
; nukes A
.macro dec16 num16, num8
	sec
	lda num16
	sbc num8
	sta num16
	lda num16+1
	sbc #0
	sta num16+1
.endmacro

; same as above but \1 is x indexed
.macro dec16_x num16, num8
	sec
	lda num16,x
	sbc num8
	sta num16,x
	lda num16+1,x
	sbc #0
	sta num16+1,x
.endmacro

; same as above, both \1 and \2 are x indexed
.macro dec16_x_x num16, num8
	sec
	lda num16,x
	sbc num8,x
	sta num16,x
	lda num16+1,x
	sbc #0
	sta num16+1,x
.endmacro

; branches to \3 when \1 >= \2
.macro gte_branch16 first, second, target
	.local @end_gte
	lda first+1
	cmp second+1
	bcc @end_gte ; \1 < \2
	bne target ; \1 > \2
	lda first
	cmp second
	bcc @end_gte ; \1 < \2
	beq target ; \1 = \2
	bne target ; \1 > \2
@end_gte:
.endmacro

; converts pixel coordinate (A) to character coordinate (=divide by 8)
.macro to_char_coord
	lsr
	lsr
	lsr
.endmacro

; converts pixel coordinate (\1, 16-bit) to character coordinate (=divide by 8)
.macro to_char_coord_16 param
	lsr param+1
	ror param
	lsr param+1
	ror param
	lsr param+1
	ror param
.endmacro

; three-way random choice: jumps to \1,\2 or \3
.macro rand3 t1, t2, t3
	jsr Rand
	lsr ; clamp random number to 0-127
	cmp #84
	bcs t1
	cmp #42
	bcs t2
	jmp t3
.endmacro

.macro pushx
	txa
	pha
.endmacro

.macro pullx
	pla
	tax
.endmacro

.macro pushall
	pha
	tya
	pha
	txa
	pha
.endmacro

.macro pullall
	pla
	tax
	pla
	tay
	pla
.endmacro
