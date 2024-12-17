	.zeropage
	.org $02
temp3:				.res 1
	

	.zeropage
	.org $20
sfx1_age:			.res 1
sfx1_fall:			.res 1
unused:				.res 14

sfx2_age:			.res 1
sfx2_fall:			.res 1
	

	.zeropage
	.org $40
player1_block_hits:	.res 8
player2_block_hits:	.res 8
	

	; player data 2*16 bytes
	.zeropage
	.org $60
player1_x:			.res 2
player1_y:			.res 1
player1_direction:	.res 1
player1_speed:		.res 1
player1_bombing:	.res 1
player1_bomb_x:		.res 2
player1_bomb_ptr:	.res 2
player1_bomb_y:		.res 1
player1_bomb_dir:	.res 1
; counter for how many boulders the current bomb can go through
player1_bomb_thr:	.res 1
player1_bomb_age:	.res 1
; score in 4-digit decimal
player1_score:		.res 2

player2_x:			.res 2
player2_y:			.res 1
player2_direction:	.res 1
player2_speed:		.res 1
player2_bombing:	.res 1
player2_bomb_x:		.res 2
player2_bomb_ptr:	.res 2
player2_bomb_y:		.res 1
player2_bomb_dir:	.res 1
player2_bomb_thr:	.res 1
player2_bomb_age:	.res 1
player2_score:		.res 2
	

	.zeropage
	.org $57
scanresult:			.res 8
spr_x_msb:			.res 1
	

	.zeropage
	.org $f8
temp:				.res 1
temp2:				.res 1
temp16:				.res 2
temp16_2:			.res 2
tick:				.res 1
subtick:			.res 1
	

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

FALL_NOT_FALLING = 0
FALL_FALLING = 1
FALL_START = 2
FALL_STOP = 3

; how much coords need to be decreased for character coord matching
SPR_X_OFFSET = 24
SPR_Y_OFFSET = 50
