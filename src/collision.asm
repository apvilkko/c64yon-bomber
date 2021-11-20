; in: x = player data offset
CheckCollision:
	; screen coords 320x200 to char coords 40x25
	; x: 320/40 = 8
	; y: 200/25 = 8

	lda player1_bombing,x
	cmp #NOT_BOMBING
	bne .continue
	rts
.continue:

	lda player1_bomb_y,x
	sec
	sbc #SPR_Y_OFFSET
	to_char_coord
	sta temp2

	sta16_x2 temp16_2,player1_bomb_x+1,player1_bomb_x
	dec16 temp16_2,#SPR_X_OFFSET
	to_char_coord_16 temp16_2
	lda temp16_2
	; the resulting char coord is less than 255 => store to one byte
	sta temp

	; temp & temp2 are now char coords x & y

	; check bomb exiting screen in x direction
	gte_branch temp,#40,.outside
	lda temp
	and #%10000000
	bne .outside

	pushx
	jsr GetScreenRamPos
	pullx

	; get the char at temp,temp2 from screen memory
	ldy temp
	lda (temp16),y
	
	cmp #EMPTY_BLOCK
	beq .noCollision
	cmp #GROUND
	beq .groundCollision

	; bomb collided with scored block
	
	; check that bomb can't go through any more blocks -> dismiss bomb
	dec player1_bomb_thr,x
	beq .outside

	; increase score (block at first row (=12) equal one point and +1 onwards)
	; a holds the current character which is the same as score
	sed
	inc16_x player1_score
	cld

	; erase current block
	lda #EMPTY_BLOCK
	sta (temp16),y
	jsr StoreDestroyedBlock

	jmp .exit
.groundCollision:
	lda #NOT_BOMBING
	sta player1_bombing,x
	jsr CheckBlockDrops
	jmp .exit
.outside:
	lda #NOT_BOMBING
	sta player1_bombing,x
	jsr CheckBlockDrops
	jmp .exit
.noCollision:
.exit:
	rts

; in: temp2 = y char coord
; nukes x
GetScreenRamPos:
	lda #0
	sta temp16
	sta temp16+1
	ldx temp2
.loopY:
	lda #40
	inc16 temp16
	dex
	bne .loopY

	; temp16 now holds screen ram y offset from 0, add $0400 to get the absolute screen address
	; only need to add high byte ($04)
	lda #>SCREEN_MEM
	clc
	adc temp16+1
	sta temp16+1
	rts

; in: x = player data offset, temp = x char coord
StoreDestroyedBlock:
	pushx
	; offset is half (=8) in block hits data
	txa
	lsr
	tax
	ldy #7
.loop:
	lda player1_block_hits,x
	cmp #$ff
	beq .okToStore
	sta temp3
	inx
	dey
	bmi .exit
	jmp .loop
.okToStore:
	; if same value already stored, no need to store again
	lda temp3
	cmp temp
	beq .exit
	lda temp
	sta player1_block_hits,x
.exit:
	pullx
	rts

CheckBlockDrops:
	ldx #$0f
.more:
	lda player1_block_hits,x
	cmp #$ff
	beq .next
	jsr ProcessColumn
	; this one processed, reset
	lda #$ff
	sta player1_block_hits,x
.next:
	dex
	bmi .done
	jmp .more
.done:
	rts

; in: A = x column
ProcessColumn:
	pushall
	; start checking at y=12 (first block line)
	tay ; Y holds the x coord
	lda #12
	sta temp2
	jsr GetScreenRamPos

pcCheckBlock:
	; current block
	lda (temp16),y
	cmp #GROUND
	beq pcExit
	cmp #EMPTY_BLOCK
	beq pcNext
	
	; current block is not empty, check below it

	sta temp3 ; remember block in case we need to move it

	lda #40
	inc16 temp16
	lda (temp16),y
	cmp #EMPTY_BLOCK
	beq pcCanMoveHere
	
	; block below is not empty, continue loop from next block
	; pointer has already been increased
	jmp pcCheckBlock

pcCanMoveHere:
	; set the block to the empty space
	lda temp3
	sta (temp16),y
	
	; erase the original block
	dec16 temp16,#40
	lda #EMPTY_BLOCK
	sta (temp16),y

	; we can continue loop

pcNext:
	lda #40
	inc16 temp16
	jmp pcCheckBlock

pcExit:
	pullall
	rts