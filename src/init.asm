InitData:
	lda #NOT_BOMBING
	sta player1_bombing
	sta player2_bombing
	lda #YPOS_1
	sta player1_y
	lda #YPOS_2
	sta player2_y
	sta16 player1_x,#0,#X_MIN
	sta16 player2_x,#1,#X_MAX
	lda #0
	sta player1_direction
	lda #FALL_NOT_FALLING
	sta sfx1_fall
	sta sfx2_fall
	lda #1
	sta player2_direction
	lda #2
	sta player1_speed
	sta player2_speed
	sta16 player1_score,#0,#0
	sta16 player2_score,#0,#0

	lda #$ff
	sta sfx1_age
	sta sfx2_age

	ldx #$0f
	lda #$ff
.loop:
	sta player1_block_hits,x
	dex
	bpl .loop
	
	; Sprite #0: located at $2000 / $40 = $80
	lda #$80
	sta SPRITE_PTR
	; Sprite #1: located at $2040 / $40 = $81
	lda #$81
	sta SPRITE_PTR+1

	lda #$80
	sta SPRITE_PTR+2
	lda #$81
	sta SPRITE_PTR+3

	; multicolor mode on
	;lda SCREEN_CTL_2
	;ora #%00010000
	;sta SCREEN_CTL_2
	
	; init sid voice 3 for randomization
	lda #$FF
	sta SID_V3_FREQ_1
	sta SID_V3_FREQ_2
	lda #$80 ; noise, gate off
	sta SID_V3_CTL

	rts