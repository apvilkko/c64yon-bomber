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
	sta player1_bomb_age

	; randomize bomb effectiveness
	jsr Rand
	lsr ; clamp random number to 0-127
	cmp #84
	bcs .option1
	cmp #42
	bcs .option2
	jmp .option3
.option1:
	lda #4
	db $2c
.option2:
	lda #5
	db $2c
.option3:
	lda #6
	sta player1_bomb_thr

	sta16 player1_bomb_x,player1_x+1,player1_x
	lda player1_y
	sta player1_bomb_y

	; initialize bomb velocity pointer
	lda #<Speed1
	sta player1_bomb_ptr
	lda #>Speed1
	sta player1_bomb_ptr+1

	lda player1_speed
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
	inc16 player1_bomb_ptr
.noAdjust:
	lda player1_direction
	sta player1_bomb_dir

.dontStartBomb:
	rts
