DrawLevel:
	ldx #249
@loopScreen:
	lda Level,x
	beq @skip1
	sta SCREEN_MEM,x
@skip1:
	lda Level+250,x
	beq @skip2
	sta SCREEN_MEM+250,x
@skip2:
	lda Level+500,x
	beq @skip3
	sta SCREEN_MEM+500,x
@skip3:
	lda Level+750,x
	beq @skip4
	sta SCREEN_MEM+750,x
@skip4:
	dex
	cpx #$ff
	bne @loopScreen
	rts

; in: x = player data offset
DrawScore:
	; ones
	lda player1_score,x
	and #$0f
	clc
	adc #PETSCII_NUMBER_OFFSET
	
	ldy #91 ; magic index to correct place for score
	; adjust position further if player is not 1
	cpx #0
	beq @noOffset
	sta temp
	stx temp2
	tya
	clc
	adc #26
	tay
	lda temp
@noOffset:
	sta SCREEN_MEM,y

	; tens
	lda player1_score,x
	and #$f0
	lsr
	lsr
	lsr
	lsr
	clc
	adc #PETSCII_NUMBER_OFFSET

	dey
	sta SCREEN_MEM,y
	
	; hundreds
	lda player1_score+1,x
	and #$0f
	clc
	adc #PETSCII_NUMBER_OFFSET
	
	dey
	sta SCREEN_MEM,y
	
	; thousands
	lda player1_score+1,x
	and #$f0
	lsr
	lsr
	lsr
	lsr
	clc
	adc #PETSCII_NUMBER_OFFSET
	
	dey
	sta SCREEN_MEM,y

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
	ldx #%00000101
	lda player1_bombing
	cmp #NOT_BOMBING
	beq @dontDrawBomb1
	txa
	eor #%00000010
	tax
@dontDrawBomb1:
	lda player2_bombing
	cmp #NOT_BOMBING
	beq @dontDrawBomb2
	txa
	eor #%00001000
	tax
@dontDrawBomb2:
	stx SPRITE_ENABLE
	rts

; in: x = player data offset
DrawPlayer:
	ldy #0
	cpx #0
	beq @noOffset
	ldy #4
@noOffset:
	lda player1_y,x
	sta SPRITE_0_Y,y
	lda player1_x+1,x
	and #%00000001
	cpx #0
	beq @noMsbOffset
	asl
	asl
@noMsbOffset:
	ora spr_x_msb
	sta spr_x_msb
	lda player1_x,x
	sta SPRITE_0_X,y
	rts

; in: x = player data offset
DrawBomb:
	ldy #0
	cpx #0
	beq @noOffset
	ldy #4
@noOffset:
	lda player1_bomb_y,x
	sta SPRITE_1_Y,y
	; check for x msb
	lda player1_bomb_x+1,x
	and #%00000001
	asl
	cpx #0
	beq @noMsbOffset
	asl
	asl
@noMsbOffset:
	ora spr_x_msb
	sta spr_x_msb
	lda player1_bomb_x,x
	sta SPRITE_1_X,y
	rts
