	; player data 2*16 bytes
	dsect
	org $60
player1_x:			blk 2
player1_y:			byt
player1_direction:	byt
player1_speed:		byt
player1_bombing:	byt
player1_bomb_x:		blk 2
player1_bomb_ptr:	blk 2
player1_bomb_y:		byt
player1_bomb_dir:	byt
; counter for how many boulders the current bomb can go through
player1_bomb_thr:	byt
player1_bomb_age:	byt
; score in 4-digit decimal
player1_score:		blk 2

player2_x:			blk 2
player2_y:			byt
player2_direction:	byt
player2_speed:		byt
player2_bombing:	byt
player2_bomb_x:		blk 2
player2_bomb_ptr:	blk 2
player2_bomb_y:		byt
player2_bomb_dir:	byt
player2_bomb_thr:	byt
player2_bomb_age:	byt
player2_score:		blk 2
	dend

	dsect
	org $57
scanresult:			blk 8
spr_x_msb:			byt
	dend

	dsect
	org $f8
temp:				byt
temp2:				byt
temp16:				blk 2
temp16_2:			blk 2
tick:				byt
subtick:			byt
	dend

X_MIN = 20
X_MAX = 320-256
Y_MAX = 229
NOT_BOMBING = $ff
GROUND = 102
EMPTY_BLOCK = PETSCII_SPACE

PLAYER_DATA_SIZE = 16

YPOS_1 = 96
YPOS_2 = 108
YPOS_3 = 120

; how much coords need to be decreased for character coord matching
SPR_X_OFFSET = 24
SPR_Y_OFFSET = 50
