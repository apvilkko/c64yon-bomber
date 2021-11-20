PlaySounds:
    ldx #1
.loop:
    lda sfx1_age,x
    cmp #$fe
    beq .notPlayingBombFx
    cmp #0
    beq .doStart
    cmp #5
    beq .doOff
    jmp .skip
.doStart:
    jsr StartBombFx
    jmp .skip
.doOff:
    jsr GateOff
.notPlayingBombFx:
    jsr MaybePlayBombDrop
.skip:
    dex
    bpl .loop
.done:
    rts

SetSidOffset:
    ldy #0 ; set y as SID regs offset
    cpx #1
    bne .noAdjust
    ldy #7
.noAdjust:
    rts

AdvanceSounds:
    ldx #0
    jsr SetSidOffset
    lda player1_bombing
    cmp #NOT_BOMBING
    beq .skip1
    lda player1_bomb_y
    lsr
    sta temp
    lda #$8c
    sec
    sbc temp
    
    sta SID_V1_FREQ_2,y
.skip1:
    ldx #1
    jsr SetSidOffset
    lda player2_bombing
    cmp #NOT_BOMBING
    beq .exit
    lda player2_bomb_y
    lsr
    sta temp
    lda #$8c
    sec
    sbc temp
    
    sta SID_V1_FREQ_2,y
.exit:
    rts

MaybePlayBombDrop:
    cpx #1
    beq .check2
    lda player1_bombing
    cmp #NOT_BOMBING
    beq .no1

    lda #$ff
    sta sfx1_age,x
    
    jsr SetSidOffset
    
    lda #$44
    sta SID_V1_FREQ_1,y
    
    lda #$7a
    sta SID_V1_SR,y

    lda #%00010001
    sta SID_V1_CTL,y

    jmp .exit
.check2:
    lda player2_bombing
    cmp #NOT_BOMBING
    beq .no2

    lda #$ff
    sta sfx1_age,x

    jsr SetSidOffset
    lda #$44
    sta SID_V1_FREQ_1,y

    lda #$7a
    sta SID_V1_SR,y
    
    lda #%00010001
    sta SID_V1_CTL,y
.no1:
.no2:
.exit:
    rts

; in: x = 0 player 1, x = 1 player 2
StartBombFx:
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
    lda #%10000001
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