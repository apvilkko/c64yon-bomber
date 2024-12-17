; in: x = player data offset
AdvancePlayer:
	lda player1_direction,x
	beq @increaseX
	dec16_x_x player1_x,player1_speed
	jmp @checkExitScreen
@increaseX:
	lda player1_speed,x
	inc16_x player1_x
@checkExitScreen:
	sta16 temp16,#1,#X_MAX
	sta16_x2 temp16_2,player1_x+1,player1_x
	gte_branch16 temp16_2,temp16,ExitedScreen
	sta16 temp16,#0,#X_MIN
	gte_branch16 temp16,temp16_2,ExitedScreen
	jmp ExitAdvancePlayer
ExitedScreen:
	; change direction
	lda player1_direction,x
	bne @leftToRight
@rightToLeft:
	sta16_x player1_x,#1,#X_MAX
	lda #1
	sta player1_direction,x
	jmp ExitAdvancePlayer
@leftToRight:
	sta16_x player1_x,#0,#X_MIN
	lda #0
	sta player1_direction,x

	; randomize ship/speed
	rand3 @option1,@option2,@option3
@option1:
	lda #1
	.byte $2c
@option2:
	lda #2
	.byte $2c
@option3:
	lda #3
	sta player1_speed,x

	; randomize y pos
	rand3 @yoption1,@yoption2,@yoption3
@yoption1:
	lda #YPOS_1
	.byte $2c
@yoption2:
	lda #YPOS_2
	.byte $2c
@yoption3:
	lda #YPOS_3
	sta player1_y,x

ExitAdvancePlayer:
	rts

; in: x = player data offset
AdvanceBomb:
	lda player1_bombing,x
	cmp #NOT_BOMBING
	beq @exit

	; get the current velocity from speed table
	; player1_bomb_ptr => temp16 is the table base address, offset with x
	; player1_bomb_age is the current index or time
	; subtick denotes the subdivision index
	; index calculation:
	; (x ? 0 : 4) + age * 8 + subtick

	cpx #0
	beq @noOffset
	sta16 temp16, player2_bomb_ptr+1, player2_bomb_ptr
	jmp @getX
@noOffset:
	sta16 temp16, player1_bomb_ptr+1, player1_bomb_ptr
@getX:
	; x velocity
	lda player1_bomb_age,x
	; max out age at last index of our table data (=9)
	cmp #10
	bcc @ageOk
	lda #9
@ageOk:
	asl
	asl
	asl
	clc
	adc subtick

	tay
	lda (temp16),y
	sta temp

	; y velocity is read from position of x velocity + 4
	tya
	clc
	adc #4
	tay
	lda (temp16),y
	sta temp2
	
	lda player1_bomb_dir,x
	beq @leftToRight
	dec16_x player1_bomb_x,temp
	jmp @handleY
@leftToRight:
	lda temp
	inc16_x player1_bomb_x
@handleY:
	lda temp2
	clc
	adc player1_bomb_y,x
	sta player1_bomb_y,x
@exit:
	rts

PerFrame:
	lda tick
	and #%00000111
	bne @exit
	inc player1_bomb_age
	inc player2_bomb_age
@exit:
	rts