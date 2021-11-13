InitData:
	lda #NOT_BOMBING
	sta player1_bombing
	lda #$60
	sta player1_y
	sta16 player1_x,#0,#X_MIN
	lda #2
	sta player1_speed
	sta16 player1_score,#0,#0
	
	; Sprite #0: located at $2000 / $40 = $80
	lda #$80
	sta SPRITE_PTR
	; Sprite #1: located at $2040 / $40 = $81
	lda #$81
	sta SPRITE_PTR+1

	; multicolor mode on
	;lda SCREEN_CTL_2
	;ora #%00010000
	;sta SCREEN_CTL_2
	
	rts