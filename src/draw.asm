DrawLevel:
	ldx #249
.loopScreen:
	lda Level,x
	beq .skip1
	sta SCREEN_MEM,x
.skip1:
	lda Level+250,x
	beq .skip2
	sta SCREEN_MEM+250,x
.skip2:
	lda Level+500,x
	beq .skip3
	sta SCREEN_MEM+500,x
.skip3:
	lda Level+750,x
	beq .skip4
	sta SCREEN_MEM+750,x
.skip4:
	dex
	cpx #$ff
	bne .loopScreen
	rts

DrawScore:
	; ones
	lda player1_score
	and #$0f
	clc
	adc #PETSCII_NUMBER_OFFSET
	
	ldx #91 ; magic index to correct place for score
	sta SCREEN_MEM,x

	; tens
	lda player1_score
	and #$f0
	lsr
	lsr
	lsr
	lsr
	clc
	adc #PETSCII_NUMBER_OFFSET

	dex
	sta SCREEN_MEM,x
	
	; hundreds
	lda player1_score+1
	and #$0f
	clc
	adc #PETSCII_NUMBER_OFFSET
	
	dex
	sta SCREEN_MEM,x
	
	; thousands
	lda player1_score+1
	and #$f0
	lsr
	lsr
	lsr
	lsr
	clc
	adc #PETSCII_NUMBER_OFFSET
	
	dex
	sta SCREEN_MEM,x

	rts

StartSpriteDraw:
	lda #0
	sta spr_x_msb
	rts

EndSpriteDraw:
	lda spr_x_msb
	sta SPRITE_X_MSB
	rts

HandleSpriteVisibility:
	ldx #01
	lda player1_bombing
	cmp #NOT_BOMBING
	beq .dontDrawBomb1
	txa
	eor #02
	tax
.dontDrawBomb1:
	stx SPRITE_ENABLE
	rts

DrawBomb1:
	lda player1_bomb_y
	sta SPRITE_1_Y
	lda player1_bomb_x+1
	and #%00000001
	asl
	ora spr_x_msb
	sta spr_x_msb
	lda player1_bomb_x
	sta SPRITE_1_X
	rts

DrawPlayer1:
	lda player1_y
	sta SPRITE_0_Y
	lda player1_x+1
	and #%00000001
	ora spr_x_msb
	sta spr_x_msb
	lda player1_x
	sta SPRITE_0_X
	rts
