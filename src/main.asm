;================================
; LOADER
;================================

	org $07ff
	db $01,$08 ; prg header (BASIC program memory start $0801)

; BASIC loader
	db $0c,$08 ; pointer to next BASIC line
	db $0a,$00 ; line number (10)
	db $9e ; SYS token
	text "11904" ; program start in decimal
	db $00 ; end of basic line
	db $00,$00 ; end of program

;================================
; DEFINITIONS
;================================

	include "defs.asm"
	include "macros.asm"


	dsect
	org $02

scanresult:			blk 8
tick:				byt
spr_x_msb:			byt
player1_x:			blk 2
player1_y:			byt
player1_direction:	byt
player1_speed:		byt
player1_bombing:	byt
player1_bomb_x:		blk 2
player1_bomb_y:		byt
player1_bomb_dir:	byt
player1_bomb_spd_x:	byt
player1_bomb_spd_y:	byt
temp_16:			blk 2

	dend

X_MIN = 20
X_MAX = 320-256
Y_MAX = 229

; methods
clearScreen = $e544
stdIntRestore = $ea81

;================================
; SPRITE
;================================

	org $2000

	; player

	db $00,$78,$00,$00,$fc,$00,$01,$84
	db $00,$01,$06,$00,$01,$12,$00,$01
	db $02,$00,$01,$86,$00,$00,$7c,$00
	db $00,$46,$f8,$1f,$c3,$80,$00,$82
	db $00,$00,$81,$00,$00,$81,$00,$00
	db $82,$00,$00,$82,$00,$00,$fe,$00
	db $00,$ce,$00,$00,$82,$00,$00,$f3
	db $e0,$01,$92,$20,$01,$f3,$e0,$03

	; bomb
	db $07,$ff,$e0,$03,$ff,$c0,$03,$ff
	db $00,$00,$3c,$00,$00,$ff,$00,$00
	db $81,$00,$00,$81,$00,$00,$81,$00
	db $00,$b9,$00,$01,$a5,$00,$01,$39
	db $00,$01,$25,$00,$01,$25,$00,$01
	db $39,$00,$01,$01,$00,$01,$83,$00
	db $00,$86,$00,$00,$4c,$00,$00,$68
	db $00,$00,$30,$00,$00,$00,$00,$0a

;================================
; PROGRAM START
;================================

	org $2e80

Start:
	jsr Init
	jmp Loop

Init:
	sei
	cld

	jsr clearScreen

	lda #%01111111
	sta INT_CTL_STA		; switch off interrupt signals from CIA-1

	and SCREEN_CTL_1	; clear most significant bit of VIC's raster register
	sta SCREEN_CTL_1

	lda INT_CTL_STA		; acknowledge pending interrupts
	lda INT_CTL_STA2

	lda #$fa
	sta RASTER_LINE

	lda #<Isr		; set ISR vector
	sta ISR_LO
	lda #>Isr
	sta ISR_HI

	lda #$01
	sta INT_CTL		; enable raster interrupt

	lda #COLOR_GREY_3
	sta SCR_COLOR_BORDER
	lda #COLOR_BLACK
	sta SCR_COLOR_BACKGROUND

ClearSid:
	ldx #$1d
	lda #$00
.clearloop:
	sta SID_REGS
	dex
	bne .clearloop

	lda #%00001111	; volume to max
	sta SID_FLT_VM

	lda #$ff
	sta player1_bombing
	lda #$60
	sta player1_y
	sta16 player1_x,#$00,#X_MIN
	lda #2
	sta player1_speed
	
	; Sprite #0: located at $2000 / $40 = $80
	lda #$80
	sta SPRITE_PTR
	; Sprite #1: located at $2040 / $40 = $81
	lda #$81
	sta SPRITE_PTR+1

	; multicolor mode on
	lda SCREEN_CTL_2
	ora #%00010000
	sta SCREEN_CTL_2

	jsr DrawLevel

	cli 			; clear interrupt flag, allowing the CPU to respond to interrupt requests

	rts

Loop:
	jmp Loop

;================================
; INTERRUPT
;================================

Isr:
	asl INT_STATUS	; acknowledge the interrupt by clearing the VIC's interrupt flag
	inc tick
	jsr ReadKeyboard
	jsr CheckKeys
	jsr AdvancePlayer1
	jsr AdvanceBomb1
	jsr HandleSpriteVisibility
	jsr StartSpriteDraw
	jsr DrawPlayer1
	jsr DrawBomb1
	jsr EndSpriteDraw

	jmp stdIntRestore

;================================
; SUBROUTINES
;================================

DrawLevel:
	ldx #249
.loopScreen:
	lda Level,x
	beq .skip1
	sta SCREEN_MEM,x
.skip1:
	lda Level+250,x
	beq .skip2
	sta SCREEN_MEM+250,x
.skip2:
	lda Level+500,x
	beq .skip3
	sta SCREEN_MEM+500,x
.skip3:
	lda Level+750,x
	beq .skip4
	sta SCREEN_MEM+750,x
.skip4:
	dex
	cpx #$ff
	bne .loopScreen
	rts

StartSpriteDraw:
	lda #0
	sta spr_x_msb
	rts

EndSpriteDraw:
	lda spr_x_msb
	sta SPRITE_X_MSB
	rts

HandleSpriteVisibility:
	ldx #01
	lda player1_bombing
	cmp #$ff
	beq .dontDrawBomb1
	txa
	eor #02
	tax
.dontDrawBomb1:
	stx SPRITE_ENABLE
	rts

CheckKeys:
	lda #%00010000 ; test space key
	and scanresult
	bne .dontStartBomb
	lda player1_bombing
	cmp #$ff
	bne .dontStartBomb
.startBombing:
	lda #0
	sta player1_bombing
	sta16 player1_bomb_x,player1_x,player1_x+1
	lda player1_y
	sta player1_bomb_y
	lda player1_speed
	sta player1_bomb_spd_x
	lda player1_direction
	sta player1_bomb_dir
	lda #2
	sta player1_bomb_spd_y
.dontStartBomb
	rts

AdvancePlayer1:
	lda player1_direction
	beq .increaseX
	dec16 player1_x,player1_speed
	jmp .checkExitScreen
.increaseX:
	lda player1_speed
	inc16 player1_x
.checkExitScreen:
	sta16 temp_16,#1,#X_MAX
	gte_branch16 player1_x,temp_16,ExitedScreen
	sta16 temp_16,#0,#X_MIN
	gte_branch16 temp_16,player1_x,ExitedScreen
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
	cmp #$ff
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
.checkGroundCollision:
	cmp #Y_MAX
	bcs .explode
	jmp .exit
.explode:
	lda #$ff
	sta player1_bombing
.exit:
	rts

DrawBomb1:
	lda player1_bomb_y
	sta SPRITE_1_Y
	lda player1_bomb_x
	and #%00000001
	asl
	ora spr_x_msb
	sta spr_x_msb
	lda player1_bomb_x+1
	sta SPRITE_1_X
	rts

DrawPlayer1:
	lda player1_y
	sta SPRITE_0_Y
	lda player1_x
	and #%00000001
	ora spr_x_msb
	sta spr_x_msb
	lda player1_x+1
	sta SPRITE_0_X
	rts

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

;================================
; DATA
;================================

Level:
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

