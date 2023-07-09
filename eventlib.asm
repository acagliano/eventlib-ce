;------------------------------------------
include '../include/library.inc'

;------------------------------------------
library EVENTLIB, 1

export ev_Setup
export ev_RegisterEvent
export ev_UnregisterEvent
export ev_UpdateCallbackFunction
export ev_UpdateCallbackData
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
	ld	hl, -3
	call	ti._frameset
	ld	hl, (ix + 12)
	ld	de, -1
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, BB1_5
	ld	hl, (_ev_queued)
	ld	bc, (_ev_max_events)
	or	a, a
	sbc	hl, bc
	call	pe, ti._setflag
	jp	p, BB1_5
	ld	de, (ix + 18)
	ld	hl, (_ev_malloc)
	push	de
	call	_indcallhl
	ld	de, -1
	pop	bc
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB1_5
	ld	bc, (ix + 15)
	ld	de, (ix + 18)
	push	de
	push	bc
	push	hl
	ld	(ix - 3), hl
	call	ti._memcpy
	pop	hl
	pop	hl
	pop	hl
	ld	de, (_ev_queued)
	push	de
	pop	hl
	inc	hl
	ld	(_ev_queued), hl
	ld	bc, 15
	push	de
	pop	hl
	call	ti._imulu
	push	hl
	pop	bc
	ld	iy, _ev_queue
	add	iy, bc
	or	a, a
	sbc	hl, hl
	ld	l, (ix + 6)
	ld	(iy), hl
	ld	hl, (ix + 12)
	ld	(iy + 5), hl
	ld	hl, (ix + 18)
	ld	(iy + 8), hl
	ld	hl, (ix - 3)
	ld	(iy + 11), hl
	ld	a, (ix + 9)
	ld	(iy + 14), a
	and	a, 1
	bit	0, a
	jr	z, BB1_5
	ld	bc, 15
	push	de
	pop	hl
	call	ti._imulu
	push	hl
	pop	bc
	ld	hl, _ev_queue
	push	hl
	pop	iy
	add	iy, bc
	ld	(iy + 3), 1
BB1_5:
	ex	de, hl
	ld	sp, ix
	pop	ix
	ret

ev_UnregisterEvent:
	ld	hl, -12
	call	ti._frameset
	ld	de, (ix + 6)
	ld	bc, (_ev_queued)
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, ti._setflag
	jp	p, BB2_7
	ld	(ix - 6), bc
	ld	iy, _ev_queue
	ld	hl, (_ev_free)
	ld	(ix - 3), hl
	ld	bc, 15
	ex	de, hl
	call	ti._imulu
	push	hl
	pop	de
	add	iy, de
	ld	hl, (iy + 11)
	push	hl
	ld	hl, (ix - 3)
	call	_indcallhl
	ld	de, (ix + 6)
	pop	hl
	ld	iy, (_ev_queued)
	dec	iy
	lea	hl, iy
	or	a, a
	sbc	hl, de
	call	pe, ti._setflag
	push	de
	pop	hl
	jp	m, BB2_3
	lea	hl, iy
BB2_3:
	or	a, a
	sbc	hl, de
	ld	(ix - 3), hl
	ex	de, hl
	ld	bc, 15
	call	ti._imulu
	push	hl
	pop	de
	ld	hl, _ev_queue
	add	hl, de
BB2_4:
	ld	(ix - 9), hl
	ld	hl, (ix - 3)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	de, (ix + 6)
	ld	bc, (ix - 6)
	jr	z, BB2_6
	lea	bc, iy
	ld	iy, (ix - 9)
	lea	hl, iy + 15
	ld	(ix - 12), hl
	lea	de, iy
	push	bc
	pop	iy
	ld	bc, 15
	ldir
	ld	hl, (ix - 3)
	dec	hl
	ld	(ix - 3), hl
	ld	hl, (ix - 12)
	jr	BB2_4
BB2_6:
	ld	(_ev_queued), iy
BB2_7:
	ex	de, hl
	or	a, a
	sbc	hl, bc
	call	pe, ti._setflag
	jp	m, BB2_9
	ld	a, 0
	jr	BB2_10
BB2_9:
	ld	a, -1
BB2_10:
	ld	sp, ix
	pop	ix
	ret
	
	
ev_UpdateCallbackFunction:
	ld	hl, -3
	call	ti._frameset
	ld	de, (ix + 6)
	ld	hl, (ix + 9)
	ld	bc, (_ev_queued)
	ld	(ix - 3), bc
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB3_3
	push	de
	pop	hl
	ld	bc, (ix - 3)
	or	a, a
	sbc	hl, bc
	ld	hl, (ix + 9)
	call	pe, ti._setflag
	jp	p, BB3_3
	ld	bc, 15
	push	de
	pop	hl
	call	ti._imulu
	push	hl
	pop	bc
	ld	iy, _ev_queue
	add	iy, bc
	ld	hl, (ix + 9)
	ld	(iy + 5), hl
BB3_3:
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	c, -1
	ld	b, 0
	ld	a, c
	jr	nz, BB3_5
	ld	a, b
BB3_5:
	ex	de, hl
	ld	de, (ix - 3)
	or	a, a
	sbc	hl, de
	call	pe, ti._setflag
	jp	m, BB3_7
	ld	c, b
BB3_7:
	and	a, c
	pop	hl
	pop	ix
	ret


ev_UpdateCallbackData:
	ld	hl, -3
	call	ti._frameset
	ld	de, (ix + 6)
	xor	a, a
	ld	bc, (_ev_queued)
	push	de
	pop	hl
	sbc	hl, bc
	call	pe, ti._setflag
	jp	p, BB4_6
	ld	iy, _ev_queue
	ld	bc, 15
	ex	de, hl
	call	ti._imulu
	ld	bc, (ix + 12)
	push	hl
	pop	de
	add	iy, de
	ld	hl, (iy + 8)
	ld	de, (iy + 11)
	or	a, a
	sbc	hl, bc
	jr	z, BB4_5
	ld	(ix - 3), iy
	ld	hl, (ix + 15)
	push	bc
	push	de
	call	_indcallhl
	ld	bc, (ix + 12)
	xor	a, a
	push	hl
	pop	de
	pop	hl
	pop	hl
	push	bc
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB4_4
	push	de
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB4_6
BB4_4:
	ld	iy, (ix - 3)
	ld	(iy + 11), de
	ld	(iy + 8), bc
BB4_5:
	ld	hl, (ix + 9)
	push	bc
	push	hl
	push	de
	call	ti._memcpy
	ld	a, 1
	pop	hl
	pop	hl
	pop	hl
BB4_6:
	pop	hl
	pop	ix
	ret
	
	
ev_PurgeEvent:
	ld	hl, -18
	call	ti._frameset
	ld	bc, 15
	ld	iy, 0
	or	a, a
	sbc	hl, hl
	push	hl
	pop	de
	ld	e, (ix + 6)
	ld	(ix - 15), de
	ld	l, (ix + 9)
	ld	(ix - 12), hl
	ld	de, (_ev_queued)
	ld	(ix - 6), iy
BB5_1:
	lea	hl, iy
	or	a, a
	sbc	hl, de
	call	pe, ti._setflag
	jp	p, BB5_11
	ld	(ix - 9), de
	lea	hl, iy
	call	ti._imulu
	ld	(ix - 3), iy
	push	hl
	pop	de
	ld	iy, _ev_queue
	lea	hl, iy
	add	hl, de
	ld	hl, (hl)
	ld	de, (ix - 15)
	or	a, a
	sbc	hl, de
	jp	nz, BB5_9
	ld	hl, (_ev_free)
	ld	(ix - 9), hl
	ld	hl, (ix - 3)
	call	ti._imulu
	push	hl
	pop	de
	add	iy, de
	ld	hl, (iy + 11)
	push	hl
	ld	hl, (ix - 9)
	call	_indcallhl
	pop	hl
	ld	de, (_ev_queued)
	dec	de
	push	de
	pop	hl
	ld	bc, (ix - 3)
	or	a, a
	sbc	hl, bc
	call	pe, ti._setflag
	ld	bc, (ix - 3)
	push	bc
	pop	hl
	jp	m, BB5_5
	push	de
	pop	hl
BB5_5:
	or	a, a
	sbc	hl, bc
	ld	(ix - 18), hl
	push	bc
	pop	hl
	ld	bc, 15
	call	ti._imulu
	push	hl
	pop	bc
	ld	iy, _ev_queue
	add	iy, bc
	ld	bc, (ix - 18)
	ld	(ix - 9), de
BB5_6:
	push	bc
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB5_8
	lea	hl, iy + 15
	lea	de, iy
	push	hl
	pop	iy
	ld	(ix - 18), bc
	ld	bc, 15
	ldir
	ld	bc, (ix - 18)
	ld	de, (ix - 9)
	dec	bc
	jr	BB5_6
BB5_8:
	ld	(_ev_queued), de
	ld	hl, (ix - 3)
	dec	hl
	ld	(ix - 3), hl
	ld	bc, 15
BB5_9:
	ld	hl, (ix - 6)
	ld	de, (ix - 12)
	or	a, a
	sbc	hl, de
	ld	de, (ix - 9)
	ld	iy, (ix - 3)
	jr	z, BB5_11
	ld	hl, (ix - 6)
	inc	hl
	ld	(ix - 6), hl
	inc	iy
	jp	BB5_1
BB5_11:
	ld	sp, ix
	pop	ix
	ret

ev_Watch:
	call	ti._frameset0
	ld	a, (ix + 6)
	ld	de, (_ev_queued)
	ld	bc, 1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, ti._setflag
	jp	p, BB6_2
	ld	de, 0
BB6_2:
	ld	iy, _ev_queue
	ld	bc, 0
	ld	c, a
BB6_3:
	push	de
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB6_7
	ld	hl, (iy)
	or	a, a
	sbc	hl, bc
	jr	nz, BB6_6
	ld	(iy + 3), 1
BB6_6:
	dec	de
	lea	iy, iy + 15
	jr	BB6_3
BB6_7:
	pop	ix
	ret
	

ev_Unwatch:
	call	ti._frameset0
	ld	a, (ix + 6)
	ld	de, (_ev_queued)
	ld	bc, 1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, ti._setflag
	jp	p, BB7_2
	ld	de, 0
BB7_2:
	ld	iy, _ev_queue
	ld	bc, 0
	ld	c, a
BB7_3:
	push	de
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB7_7
	ld	hl, (iy)
	or	a, a
	sbc	hl, bc
	jr	nz, BB7_6
	ld	(iy + 3), 0
BB7_6:
	dec	de
	lea	iy, iy + 15
	jr	BB7_3
BB7_7:
	pop	ix
	ret


ev_Trigger:
	call	ti._frameset0
	ld	a, (ix + 6)
	ld	de, (_ev_queued)
	ld	bc, 1
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, ti._setflag
	jp	p, BB8_2
	ld	de, 0
BB8_2:
	ld	iy, _ev_queue+4
	ld	bc, 0
	ld	c, a
BB8_3:
	push	de
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB8_7
	ld	hl, (iy - 4)
	or	a, a
	sbc	hl, bc
	jr	nz, BB8_6
	ld	(iy), 1
BB8_6:
	dec	de
	lea	iy, iy + 15
	jr	BB8_3
BB8_7:
	pop	ix
	ret


ev_HandleEvents:
	ld	hl, -6
	call	ti._frameset
	ld	iy, _ev_queue+8
	ld	bc, 0
	ld	de, (_ev_queued)
BB9_1:
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, ti._setflag
	jp	p, BB9_7
	bit	0, (iy - 5)
	jr	z, BB9_6
	bit	0, (iy - 4)
	jr	z, BB9_6
	ld	hl, (iy - 3)
	ld	de, (iy + 3)
	ld	(ix - 6), bc
	ld	bc, (iy)
	push	bc
	push	de
	ld	(ix - 3), iy
	call	_indcallhl
	ld	bc, (ix - 6)
	ld	iy, (ix - 3)
	pop	hl
	pop	hl
	ld	de, (_ev_queued)
	bit	1, (iy + 6)
	jr	z, BB9_6
	ld	(iy - 5), 0
BB9_6:
	inc	bc
	lea	iy, iy + 15
	jr	BB9_1
BB9_7:
	ld	sp, ix
	pop	ix
	ret
	

ev_Cleanup:
	ld	hl, -6
	call	ti._frameset
	ld	hl, 11
	ld	(ix - 3), hl
	ld	bc, 0
BB10_1:
	ld	de, (_ev_queued)
	ld	iy, (_ev_free)
	ld	(ix - 6), bc
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	call	pe, ti._setflag
	jp	p, BB10_3
	ld	de, (ix - 3)
	ld	hl, _ev_queue
	add	hl, de
	ld	hl, (hl)
	push	hl
	call	_indcall
	pop	hl
	ld	bc, (ix - 6)
	inc	bc
	ld	de, 15
	ld	hl, (ix - 3)
	add	hl, de
	ld	(ix - 3), hl
	jr	BB10_1
BB10_3:
	ld	hl, _ev_queue
	push	hl
	call	_indcall
	ld	sp, ix
	pop	ix
	ret
	
	
_ev_malloc: rb	3

_ev_max_events: dl 256

_ev_free: rb	3

_ev_queued: rb	3

_ev_queue: rb 3840
