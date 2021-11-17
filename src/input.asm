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

; in: x = player data offset
CheckKeys:
	cpx #0
	beq .checkInput

	; player 2: just fire always if possible for now
	jmp .checkCanBomb

.checkInput:
	lda #%00010000 ; test space key
	and scanresult
	bne .dontStartBomb
.checkCanBomb:
	lda player1_bombing,x
	cmp #NOT_BOMBING
	bne .dontStartBomb
.startBombing:
	lda #0
	sta player1_bombing,x
	sta player1_bomb_age,x

	; randomize bomb effectiveness
	rand3 .option1,.option2,.option3
.option1:
	lda #4
	db $2c
.option2:
	lda #5
	db $2c
.option3:
	lda #6
	sta player1_bomb_thr,x

	sta16_x_x player1_bomb_x,player1_x+1,player1_x
	lda player1_y,x
	sta player1_bomb_y,x

	; initialize bomb velocity pointer
	lda #<Speed1
	sta player1_bomb_ptr,x
	lda #>Speed1
	sta player1_bomb_ptr+1,x

	lda player1_speed,x
	cmp #1
	beq .noAdjust
	cmp #2
	beq .adjustSpeed2
	cmp #3
	beq .adjustSpeed3
	jmp .noAdjust
.adjustSpeed2:
	lda #80
	db $2c
.adjustSpeed3:
	lda #160
	inc16_x player1_bomb_ptr
.noAdjust:
	lda player1_direction,x
	sta player1_bomb_dir,x

.dontStartBomb:
	rts
