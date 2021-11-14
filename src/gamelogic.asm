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

	; randomize ship/speed
	jsr Rand
	lsr ; clamp random number to 0-127
	cmp #84
	bcs .option1
	cmp #42
	bcs .option2
	jmp .option3
.option1:
	lda #1
	db $2c
.option2:
	lda #2
	db $2c
.option3:
	lda #3
	sta player1_speed

ExitAdvancePlayer:
	rts

AdvanceBomb1:
	lda player1_bombing
	cmp #NOT_BOMBING
	beq .exit

	; get the current velocity from speed table
	; player1_bomb_ptr is the table base address
	; player1_bomb_age is the current index or time
	; subtick denotes the subdivision index
	; index calculation:
	; (x ? 0 : 4) + age * 8 + subtick

	; x velocity
	lda player1_bomb_age
	; max out age at last index of our table data (=9)
	cmp #10
	bcc .ageOk
	lda #9
.ageOk:
	asl
	asl
	asl
	clc
	adc subtick
	tay
	lda (player1_bomb_ptr),y
	sta temp

	; y velocity is read from position of x velocity + 4
	tya
	clc
	adc #4
	tay
	lda (player1_bomb_ptr),y
	sta temp2
	
	lda player1_bomb_dir
	beq .leftToRight
	dec16 player1_bomb_x,temp
	jmp .handleY
.leftToRight:
	lda temp
	inc16 player1_bomb_x
.handleY:
	lda temp2
	clc
	adc player1_bomb_y
	sta player1_bomb_y
.exit:
	rts

PerFrame:
	lda tick
	and #%00000111
	bne .exit
	inc player1_bomb_age
.exit:
	rts