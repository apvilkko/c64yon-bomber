; in: x = player data offset
CheckCollision:
	; screen coords 320x200 to char coords 40x25
	; x: 320/40 = 8
	; y: 200/25 = 8

	lda player1_bombing,x
	cmp #NOT_BOMBING
	bne .continue
	rts
.continue:

	lda player1_bomb_y,x
	sec
	sbc #SPR_Y_OFFSET
	to_char_coord
	sta temp2

	sta16_x2 temp16_2,player1_bomb_x+1,player1_bomb_x
	dec16 temp16_2,#SPR_X_OFFSET
	to_char_coord_16 temp16_2
	lda temp16_2
	; the resulting char coord is less than 255 => store to one byte
	sta temp

	; temp & temp2 are now char coords x & y

	; check bomb exiting screen in x direction
	gte_branch temp,#40,.outside
	lda temp
	and #%10000000
	bne .outside

	txa
	tay
	
	lda #0
	sta temp16
	sta temp16+1
	ldx temp2
.loopY
	lda #40
	inc16 temp16
	dex
	bpl .loopY

	tya
	tax

	; temp16 now holds screen ram y offset from 0, add $0400 to get the absolute screen address
	; only need to add high byte ($04)
	lda #>SCREEN_MEM
	clc
	adc temp16+1
	sta temp16+1

	; get the char at temp,temp2 from screen memory
	ldy temp
	lda (temp16),y
	
	cmp #EMPTY_BLOCK
	beq .noCollision
	cmp #GROUND
	beq .groundCollision

	; bomb collided with scored block
	
	; check that bomb can't go through any more blocks -> dismiss bomb
	dec player1_bomb_thr,x
	beq .outside

	; increase score (block at first row (=12) equal one point and +1 onwards)
	lda temp2
	sec
	sbc #11
	sed
	inc16_x player1_score
	cld

	; erase current block
	lda #EMPTY_BLOCK
	sta (temp16),y

	jmp .exit
.groundCollision:
	lda #NOT_BOMBING
	sta player1_bombing,x
	jmp .exit
.outside:
	lda #NOT_BOMBING
	sta player1_bombing,x
	jmp .exit
.noCollision:
.exit:
	rts
