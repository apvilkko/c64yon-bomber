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
	include "gamedefs.asm"

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
	db $e0,$00,$00,$40,$00,$00,$e0,$00
	db $00,$e0,$00,$00,$40,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$03

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

	lda #0
	sta tick
	sta subtick

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

	lda #%10001111	; volume to max, mute voice 3
	sta SID_FLT_VM

	jsr InitData
	jsr DrawLevel

	cli 			; clear interrupt flag, allowing the CPU to respond to interrupt requests

	rts

Loop:
	lda tick
	and #$0f
	beq .maybeProcessBlocks
	jmp Loop
.maybeProcessBlocks:
	lda player1_bombing
	cmp #NOT_BOMBING
	bne Loop
	lda player2_bombing
	cmp #NOT_BOMBING
	bne Loop
	jsr CheckBlockDrops	
	jmp Loop

;================================
; INTERRUPT
;================================

Isr:
	asl INT_STATUS	; acknowledge the interrupt by clearing the VIC's interrupt flag
	inc tick
	inc subtick
	lda #%00000011
	and subtick
	sta subtick
	jsr ReadKeyboard
	ldx #0
	jsr CheckKeys
	ldx #PLAYER_DATA_SIZE
	jsr CheckKeys
	jsr PerFrame
	
	ldx #0
	jsr AdvancePlayer
	jsr AdvanceBomb
	jsr CheckCollision
	ldx #PLAYER_DATA_SIZE
	jsr AdvancePlayer
	jsr AdvanceBomb
	jsr CheckCollision
	
	jsr HandleSpriteVisibility
	jsr StartSpriteDraw
	
	ldx #0
	jsr DrawPlayer
	jsr DrawBomb
	jsr DrawScore
	ldx #PLAYER_DATA_SIZE
	jsr DrawPlayer
	jsr DrawBomb
	jsr DrawScore
	
	jsr EndSpriteDraw

	jsr PlaySounds

	jmp stdIntRestore

;================================
; SUBROUTINES
;================================

	include "util.asm"
	include "init.asm"
	include "collision.asm"
	include "input.asm"
	include "draw.asm"
	include "gamelogic.asm"
	include "sound.asm"

;================================
; DATA
;================================

	include "generated.asm"