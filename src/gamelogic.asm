AdvancePlayer1:
	lda player1_direction
	beq .increaseX
	dec16 player1_x,player1_speed
	jmp .checkExitScreen
.increaseX:
	lda player1_speed
	inc16 player1_x
.checkExitScreen:
	sta16 temp16,#1,#X_MAX
	gte_branch16 player1_x,temp16,ExitedScreen
	sta16 temp16,#0,#X_MIN
	gte_branch16 temp16,player1_x,ExitedScreen
	jmp ExitAdvancePlayer
ExitedScreen:
	; change direction
	lda player1_direction
	bne .leftToRight
.rightToLeft:
	sta16 player1_x,#1,#X_MAX
	lda #1
	sta player1_direction
	jmp ExitAdvancePlayer
.leftToRight:
	sta16 player1_x,#0,#X_MIN
	lda #0
	sta player1_direction
ExitAdvancePlayer:
	rts

AdvanceBomb1:
	lda player1_bombing
	cmp #NOT_BOMBING
	beq .exit
	lda player1_bomb_dir
	beq .leftToRight
	dec16 player1_bomb_x,player1_bomb_spd_x
	jmp .handleY
.leftToRight:
	lda player1_bomb_spd_x
	inc16 player1_bomb_x
.handleY:
	lda player1_bomb_spd_y
	clc
	adc player1_bomb_y
	sta player1_bomb_y
.exit:
	rts
