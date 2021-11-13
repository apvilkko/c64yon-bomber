; Returns random number in A.
; Expected that SID voice 3 has been setup to produce noise.
Rand:
	lda SID_V3_OSC
	rts