;------------------------------------------
include '../include/library.inc'

;------------------------------------------
library EVENTLIB, 1

export ev_Setup
export ev_RegisterEvent
export ev_UnregisterEvent
export ev_UpdateCallbacks
export ev_PurgeEvent
export ev_Watch
export ev_Unwatch
export ev_Trigger
export ev_HandleEvents
export ev_Cleanup


_indcallhl:
; Calls HL
; Inputs:
;  HL : Address to call
	jp	(hl)
	
_indcall:
; Calls IY
    jp  (iy)

ev_Setup:
	call	ti._frameset0
	ld	bc, (ix + 6)
	ld	de, (ix + 9)
	push	bc
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB0_3
	push	de
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB0_3
	ld	(_ev_malloc), bc
	ld	(_ev_free), de
BB0_3:
	push	bc
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	c, -1
	ld	b, 0
	ld	a, c
	jr	nz, BB0_5
	ld	a, b
BB0_5:
	ex	de, hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, BB0_7
	ld	c, b
BB0_7:
	and	a, c
	pop	ix
	ret


ev_RegisterEvent:
	ld	hl, -6
	call	ti._frameset
	ld	hl, (ix + 12)
	ld	bc, -1
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB1_3
	ld	de, (ix + 18)
	ld	hl, (_ev_malloc)
	push	de
	call	_indcallhl
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, BB1_4
BB1_2:
	ld	bc, -1
BB1_3:
	push	bc
	pop	hl
	ld	sp, ix
	pop	ix
	ret
BB1_4:
	ld	de, (ix + 15)
	ld	bc, _ev_queue
	ld	(ix - 3), bc
	ld	bc, (ix + 18)
	push	bc
	push	de
	ld	(ix - 6), hl
	push	hl
	call	ti._memcpy
	pop	hl
	pop	hl
	pop	hl
	ld	de, 256
	ld	bc, 0
BB1_5:
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	z, BB1_2
	ld	iy, (ix - 3)
	bit	0, (iy)
	jr	z, BB1_8
	inc	bc
	lea	iy, iy + 16
	ld	(ix - 3), iy
	jr	BB1_5
BB1_8:
	or	a, a
	sbc	hl, hl
	ld	l, (ix + 6)
	ld	(iy + 1), hl
	ld	hl, (ix + 12)
	ld	(iy + 6), hl
	ld	hl, (ix + 18)
	ld	(iy + 9), hl
	ld	hl, (ix - 6)
	ld	(iy + 12), hl
	ld	a, (ix + 9)
	ld	(iy + 15), a
	ld	(iy), 1
	and	a, 1
	bit	0, a
	jr	z, BB1_3
	ld	(iy + 4), 1
	jr	BB1_3


ev_UnregisterEvent:
	ld	hl, -3
	call	ti._frameset
	ld	de, (ix + 6)
	ld	bc, 256
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, ti._setflag
	jp	p, BB2_2
	ld	iy, _ev_queue
	ld	c, 4
	ex	de, hl
	call	ti._ishl
	push	hl
	pop	de
	add	iy, de
	ld	(ix - 3), iy
	ld	hl, (_ev_free)
	ld	de, (iy + 12)
	push	de
	call	_indcallhl
	pop	hl
	ld	hl, (ix - 3)
	ld	(hl), 0
	push	hl
	pop	iy
	inc	iy
	ld	bc, 15
	lea	de, iy
	ldir
	ld	bc, 256
	ld	de, (ix + 6)
BB2_2:
	ex	de, hl
	or	a, a
	sbc	hl, bc
	call	pe, ti._setflag
	jp	m, BB2_4
	ld	a, 0
	jr	BB2_5
BB2_4:
	ld	a, -1
BB2_5:
	pop	hl
	pop	ix
	ret
	
	
ev_UpdateCallbacks:
	ld	hl, -3
	call	ti._frameset
	ld	de, (ix + 6)
	xor	a, a
	ld	bc, 256
	push	de
	pop	hl
	sbc	hl, bc
	call	pe, ti._setflag
	jp	p, BB3_10
	ld	iy, _ev_queue
	ld	c, 4
	push	de
	pop	hl
	call	ti._ishl
	push	hl
	pop	bc
	lea	hl, iy
	add	hl, bc
	bit	0, (hl)
	jp	z, BB3_10
	ld	hl, (ix + 9)
	ld	bc, (ix + 12)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB3_4
	ld	c, 4
	push	de
	pop	hl
	call	ti._ishl
	push	hl
	pop	bc
	ld	iy, _ev_queue
	add	iy, bc
	ld	bc, (ix + 12)
	ld	hl, (ix + 9)
	ld	(iy + 6), hl
	ld	iy, _ev_queue
BB3_4:
	ld	a, 1
	push	bc
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB3_10
	ld	hl, (ix + 15)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB3_10
	ld	c, 4
	ex	de, hl
	call	ti._ishl
	ld	bc, (ix + 15)
	push	hl
	pop	de
	add	iy, de
	ld	hl, (iy + 9)
	ld	de, (iy + 12)
	or	a, a
	sbc	hl, bc
	jr	z, BB3_9
	ld	(ix - 3), iy
	ld	hl, (ix + 18)
	push	bc
	push	de
	call	_indcallhl
	xor	a, a
	push	hl
	pop	de
	pop	hl
	pop	hl
	push	de
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB3_10
	ld	iy, (ix - 3)
	ld	(iy + 12), de
	ld	hl, (ix + 15)
	ld	(iy + 9), hl
	push	hl
	pop	bc
BB3_9:
	push	bc
	ld	hl, (ix + 12)
	push	hl
	push	de
	call	ti._memcpy
	pop	hl
	pop	hl
	pop	hl
	ld	a, 1
BB3_10:
	pop	hl
	pop	ix
	ret
	
	
ev_PurgeEvent:
	ld	hl, -18
	call	ti._frameset
	ld	bc, _ev_queue
	ld	iy, 0
	or	a, a
	sbc	hl, hl
	push	hl
	pop	de
	ld	e, (ix + 6)
	ld	(ix - 3), de
	ld	l, (ix + 9)
	ld	(ix - 9), hl
	ld	de, 4096
	ld	(ix - 6), iy
BB4_1:
	lea	hl, iy
	or	a, a
	sbc	hl, de
	jp	z, BB4_9
	lea	de, iy
	push	bc
	pop	hl
	add	hl, de
	bit	0, (hl)
	jr	z, BB4_7
	ld	(ix - 12), hl
	lea	de, iy
	push	bc
	pop	hl
	lea	bc, iy
	push	hl
	pop	iy
	add	iy, de
	ld	hl, (iy + 1)
	ld	de, (ix - 3)
	or	a, a
	sbc	hl, de
	jr	nz, BB4_6
	ld	hl, (_ev_free)
	ld	(ix - 18), hl
	push	bc
	pop	de
	ld	hl, _ev_queue
	push	hl
	pop	iy
	add	iy, de
	ld	de, (iy + 12)
	push	de
	ld	(ix - 15), bc
	ld	hl, (ix - 18)
	call	_indcallhl
	pop	hl
	ld	hl, (ix - 12)
	ld	(hl), 0
	push	hl
	pop	iy
	inc	iy
	lea	de, iy
	ld	bc, 15
	ldir
	ld	hl, (ix - 6)
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, de
	ld	bc, _ev_queue
	ld	de, 16
	ld	iy, (ix - 15)
	jr	z, BB4_9
	ld	hl, (ix - 6)
	inc	hl
	ld	(ix - 6), hl
	jr	BB4_8
BB4_6:
	push	bc
	pop	iy
	ld	bc, _ev_queue
BB4_7:
	ld	de, 16
BB4_8:
	add	iy, de
	ld	de, 4096
	jp	BB4_1
BB4_9:
	ld	sp, ix
	pop	ix
	ret
	

ev_Watch:
	ld	hl, -6
	call	ti._frameset
	ld	bc, _ev_queue
	ld	iy, 0
	or	a, a
	sbc	hl, hl
	ld	l, (ix + 6)
	ld	(ix - 3), hl
BB5_1:
	ld	de, 4096
	lea	hl, iy
	or	a, a
	sbc	hl, de
	jr	z, BB5_6
	lea	de, iy
	push	bc
	pop	hl
	add	hl, de
	bit	0, (hl)
	jr	z, BB5_5
	lea	de, iy
	ld	(ix - 6), iy
	ld	iy, _ev_queue
	add	iy, de
	ld	hl, (iy + 1)
	ld	iy, (ix - 6)
	ld	bc, _ev_queue
	ld	de, (ix - 3)
	or	a, a
	sbc	hl, de
	jr	nz, BB5_5
	lea	bc, iy
	ld	iy, _ev_queue
	add	iy, bc
	ld	(iy + 4), 1
	ld	iy, (ix - 6)
	ld	bc, _ev_queue
BB5_5:
	ld	de, 16
	add	iy, de
	jr	BB5_1
BB5_6:
	ld	sp, ix
	pop	ix
	ret
	

ev_Unwatch:
	ld	hl, -6
	call	ti._frameset
	ld	bc, _ev_queue
	ld	iy, 0
	or	a, a
	sbc	hl, hl
	ld	l, (ix + 6)
	ld	(ix - 3), hl
BB6_1:
	ld	de, 4096
	lea	hl, iy
	or	a, a
	sbc	hl, de
	jr	z, BB6_6
	lea	de, iy
	push	bc
	pop	hl
	add	hl, de
	bit	0, (hl)
	jr	z, BB6_5
	lea	de, iy
	ld	(ix - 6), iy
	ld	iy, _ev_queue
	add	iy, de
	ld	hl, (iy + 1)
	ld	iy, (ix - 6)
	ld	bc, _ev_queue
	ld	de, (ix - 3)
	or	a, a
	sbc	hl, de
	jr	nz, BB6_5
	lea	bc, iy
	ld	iy, _ev_queue
	add	iy, bc
	ld	(iy + 4), 1
	ld	iy, (ix - 6)
	ld	bc, _ev_queue
BB6_5:
	ld	de, 16
	add	iy, de
	jr	BB6_1
BB6_6:
	ld	sp, ix
	pop	ix
	ret
	

ev_Trigger:
	ld	hl, -6
	call	ti._frameset
	ld	bc, _ev_queue
	ld	iy, 0
	or	a, a
	sbc	hl, hl
	ld	l, (ix + 6)
	ld	(ix - 3), hl
BB7_1:
	ld	de, 4096
	lea	hl, iy
	or	a, a
	sbc	hl, de
	jr	z, BB7_7
	lea	de, iy
	push	bc
	pop	hl
	add	hl, de
	bit	0, (hl)
	jr	z, BB7_6
	lea	de, iy
	ld	(ix - 6), iy
	ld	iy, _ev_queue
	add	iy, de
	ld	hl, (iy + 1)
	ld	iy, (ix - 6)
	ld	bc, _ev_queue
	ld	de, (ix - 3)
	or	a, a
	sbc	hl, de
	jr	nz, BB7_6
	lea	bc, iy
	ld	iy, _ev_queue
	add	iy, bc
	bit	0, (iy + 4)
	ld	iy, (ix - 6)
	ld	bc, _ev_queue
	jr	z, BB7_6
	lea	bc, iy
	ld	iy, _ev_queue
	add	iy, bc
	ld	(iy + 5), 1
	ld	iy, (ix - 6)
	ld	bc, _ev_queue
BB7_6:
	ld	de, 16
	add	iy, de
	jr	BB7_1
BB7_7:
	ld	sp, ix
	pop	ix
	ret


ev_HandleEvents:
	ld	hl, -9
	call	ti._frameset
	ld	bc, _ev_queue
	or	a, a
	sbc	hl, hl
BB8_1:
	ld	(ix - 3), hl
	ld	de, 4096
	ld	hl, (ix - 3)
	or	a, a
	sbc	hl, de
	jr	z, BB8_8
	ld	de, (ix - 3)
	push	bc
	pop	hl
	add	hl, de
	bit	0, (hl)
	jr	z, BB8_7
	ld	de, (ix - 3)
	push	bc
	pop	iy
	add	iy, de
	ld	(ix - 6), iy
	bit	0, (iy + 4)
	jr	z, BB8_7
	ld	de, (ix - 3)
	ld	iy, _ev_queue
	add	iy, de
	bit	0, (iy + 5)
	ld	bc, _ev_queue
	jr	z, BB8_7
	ld	de, (ix - 3)
	push	bc
	pop	iy
	add	iy, de
	ld	(ix - 9), iy
	ld	hl, (iy + 6)
	ld	de, (iy + 12)
	ld	bc, (iy + 9)
	push	bc
	push	de
	call	_indcallhl
	ld	bc, _ev_queue
	pop	hl
	pop	hl
	ld	iy, (ix - 9)
	bit	1, (iy + 15)
	jr	z, BB8_7
	ld	iy, (ix - 6)
	ld	(iy + 4), 0
BB8_7:
	ld	de, 16
	ld	hl, (ix - 3)
	add	hl, de
	jr	BB8_1
BB8_8:
	ld	sp, ix
	pop	ix
	ret
	

ev_Cleanup:
	ld	hl, -3
	call	ti._frameset
	ld	bc, _ev_queue
	ld	iy, 0
BB9_1:
	ld	de, 4096
	lea	hl, iy
	or	a, a
	sbc	hl, de
	jr	z, BB9_5
	lea	de, iy
	push	bc
	pop	hl
	add	hl, de
	bit	0, (hl)
	jr	z, BB9_4
	ld	hl, (_ev_free)
	lea	de, iy
	ld	(ix - 3), iy
	ld	iy, _ev_queue
	add	iy, de
	ld	de, (iy + 12)
	push	de
	call	_indcallhl
	ld	iy, (ix - 3)
	ld	bc, _ev_queue
	pop	hl
BB9_4:
	ld	de, 16
	add	iy, de
	jr	BB9_1
BB9_5:
	pop	hl
	pop	ix
	ret
	
	
_ev_malloc: rb	3

_ev_free: rb	3

_ev_queue: rb 4096
