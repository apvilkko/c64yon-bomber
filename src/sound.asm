; called per frame
; in: x = player data offset
PlaySounds:
    ; increase age
    lda sfx1_age,x
	cmp #$ff
	beq .skipInc
	inc sfx1_age,x
.skipInc:

    lda sfx1_fall,x
    cmp #FALL_START
    beq .doStartFall
    cmp #FALL_STOP
    beq .doStopFall
    cmp #FALL_NOT_FALLING
    beq .checkBombAge
    cmp #FALL_FALLING
    beq .falling
.checkBombAge:
    lda sfx1_age,x
    cmp #$ff
    beq .done
    cmp #5
    beq .doOff
    cmp #30
    beq .resetBombAge
    jmp .done

.falling:
    jsr SetSidOffset
    lda player1_bomb_y,x
    lsr
    sta temp
    lda #$7c
    sec
    sbc temp
    
    sta SID_V1_FREQ_2,y

    jmp .done

.doStartFall:
    lda #FALL_FALLING
    sta sfx1_fall,x
    jsr StartDropEffect
    jmp .done
.doStopFall:
    lda #FALL_NOT_FALLING
    sta sfx1_fall,x
    
    ; stop falling sound
    jsr SetSidOffset
    lda #$f0
    sta SID_V1_SR,y
    lda #%00010000
    sta SID_V1_CTL,y

    lda #0
    sta sfx1_age,x
    
    jsr StartBombExplosion
    jmp .done
.resetBombAge:
    lda #$ff
    sta sfx1_age,x
    jmp .done
.doOff:
    jsr GateOff
    jmp .done
.bombFalling:
    ; do nothing
    jmp .done
.done:
    rts

SetSidOffset:
    ldy #0 ; set y as SID regs offset
    cpx #0
    beq .noAdjust
    ldy #7
.noAdjust:
    rts

StartDropEffect:
    jsr SetSidOffset
    
    lda #$44
    sta SID_V1_FREQ_1,y
    
    lda #$04
    sta SID_V1_AD,y

    lda #$99
    sta SID_V1_SR,y

    lda #%00010001
    sta SID_V1_CTL,y

    rts

; in: x = 0 player 1, x = 1 player 2
StartBombExplosion:
    jsr SetSidOffset
    lda #$11
    sta SID_V1_PW_1,y
    sta SID_V1_PW_2,y
    lda #$a7
    sta SID_V1_FREQ_1,y
    lda #$03
    sta SID_V1_FREQ_2,y
    lda #$04
    sta SID_V1_AD,y
    lda #$fa
    sta SID_V1_SR,y
    lda #%01000001
    sta SID_V1_CTL,y
    rts

GateOff:
    jsr SetSidOffset
    lda #$69
    sta SID_V1_FREQ_1,y
    lda #$04
    sta SID_V1_FREQ_2,y
    lda #%10000000
    sta SID_V1_CTL,y
    rts