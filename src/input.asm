ReadKeyboard:
	lda #%11111110
	sta CIA_PORT_A
	ldy CIA_PORT_B
	sty scanresult+7
	sec
	rol
	sta CIA_PORT_A
	ldy CIA_PORT_B
	sty scanresult+6
	rol
	sta CIA_PORT_A
	ldy CIA_PORT_B
	sty scanresult+5
	rol
	sta CIA_PORT_A
	ldy CIA_PORT_B
	sty scanresult+4
	rol
	sta CIA_PORT_A
	ldy CIA_PORT_B
	sty scanresult+3
	rol
	sta CIA_PORT_A
	ldy CIA_PORT_B
	sty scanresult+2
	rol
	sta CIA_PORT_A
	ldy CIA_PORT_B
	sty scanresult+1
	rol
	sta CIA_PORT_A
	ldy CIA_PORT_B
	sty scanresult
	
	rts


CheckKeys:
	lda #%00010000 ; test space key
	and scanresult
	bne .dontStartBomb
	lda player1_bombing
	cmp #NOT_BOMBING
	bne .dontStartBomb
.startBombing:
	lda #0
	sta player1_bombing
	sta16 player1_bomb_x,player1_x+1,player1_x
	lda player1_y
	sta player1_bomb_y
	lda player1_speed
	sta player1_bomb_spd_x
	lda player1_direction
	sta player1_bomb_dir
	lda #2
	sta player1_bomb_spd_y
.dontStartBomb:
	rts
