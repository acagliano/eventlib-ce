;------------------------------------------
include '../include/library.inc'

;------------------------------------------
library EVENTLIB, 1

export ev_setup
export ev_register
export ev_unregister
export ev_watch
export ev_unwatch
export ev_trigger
export ev_handle
export ev_cleanup


_indcallhl:
; Calls HL
; Inputs:
;  HL : Address to call
	jp	(hl)
	

ev_setup:
	call	ti._frameset0
	ld	iy, (ix + 6)
	ld	de, 1
	lea	hl, iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB0_6
	ld	hl, (ix + 9)
	push	hl
	pop	bc
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB0_6
	ld	hl, (ix + 12)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB0_6
	ld	de, 22
	ld	(_ev_max_events), iy
	ld	(_ev_malloc), bc
	ld	(_ev_free), hl
	lea	hl, iy
	push	de
	pop	bc
	call	ti._imulu
	push	hl
	ld	hl, (ix + 9)
	call	_indcallhl
	pop	de
	ld	(_ev_queue), hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB0_5
	ld	de, 0
	jr	BB0_6
BB0_5:
	ld	de, 3
BB0_6:
	ex	de, hl
	pop	ix
	ret


ev_register:
	ld	hl, -9
	call	ti._frameset
	ld	hl, (ix + 12)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, BB1_2
	ld	de, 1
	jp	BB1_8
BB1_2:
	ld	hl, (_ev_queued)
	ld	de, (_ev_max_events)
	or	a, a
	sbc	hl, de
	jr	nc, BB1_5
	ld	de, (ix + 18)
	ld	hl, (_ev_malloc)
	push	de
	call	_indcallhl
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, BB1_6
	ld	de, 3
	jr	BB1_8
BB1_5:
	ld	de, 2
	jr	BB1_8
BB1_6:
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
	ld	iy, (_ev_queue)
	ld	hl, (_ev_queued)
	push	hl
	pop	de
	inc	de
	ld	(_ev_queued), de
	ld	bc, 15
	ld	(ix - 9), hl
	call	ti._imulu
	push	hl
	pop	bc
	ld	(ix - 6), iy
	add	iy, bc
	ld	hl, (ix + 6)
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
	ld	de, 0
	jr	z, BB1_8
	ld	bc, 15
	ld	hl, (ix - 9)
	call	ti._imulu
	push	hl
	pop	bc
	ld	iy, (ix - 6)
	add	iy, bc
	ld	(iy + 3), 1
BB1_8:
	ex	de, hl
	ld	sp, ix
	pop	ix
	ret


ev_unregister:
	ld	hl, -12
	call	ti._frameset
	ld	iy, 0
	ld	bc, (_ev_queued)
	lea	de, iy
	ld	(ix - 9), iy
BB7_1:
	push	de
	pop	hl
	ld	(ix - 3), bc
	or	a, a
	sbc	hl, bc
	jp	nc, BB7_11
	ld	iy, (_ev_queue)
	push	de
	pop	hl
	ld	bc, 15
	call	ti._imulu
	ld	(ix - 6), de
	push	hl
	pop	de
	lea	hl, iy
	add	hl, de
	ld	hl, (hl)
	ld	de, (ix + 6)
	or	a, a
	sbc	hl, de
	jp	nz, BB7_9
	ld	hl, (_ev_free)
	ld	(ix - 3), hl
	ld	hl, (ix - 6)
	call	ti._imulu
	push	hl
	pop	de
	add	iy, de
	ld	hl, (iy + 11)
	push	hl
	ld	hl, (ix - 3)
	call	_indcallhl
	pop	hl
	ld	bc, (_ev_queued)
	dec	bc
	push	bc
	pop	hl
	ld	de, (ix - 6)
	or	a, a
	sbc	hl, de
	push	de
	pop	hl
	jr	c, BB7_5
	push	bc
	pop	hl
BB7_5:
	ld	iy, (_ev_queue)
	or	a, a
	sbc	hl, de
	ld	(ix - 12), hl
	ex	de, hl
	ld	(ix - 3), bc
	ld	bc, 15
	call	ti._imulu
	ld	bc, (ix - 3)
	push	hl
	pop	de
	add	iy, de
	ld	hl, (ix - 12)
BB7_6:
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB7_8
	lea	bc, iy + 15
	ld	(ix - 12), hl
	lea	de, iy
	push	bc
	pop	hl
	push	bc
	pop	iy
	ld	bc, 15
	ldir
	ld	hl, (ix - 12)
	ld	bc, (ix - 3)
	dec	hl
	jr	BB7_6
BB7_8:
	ld	(_ev_queued), bc
	ld	hl, (ix - 6)
	dec	hl
	ld	(ix - 6), hl
BB7_9:
	ld	iy, 0
	ld	hl, (ix - 9)
	ld	de, (ix + 9)
	or	a, a
	sbc	hl, de
	ld	de, (ix - 6)
	jr	z, BB7_11
	ld	hl, (ix - 9)
	inc	hl
	ld	(ix - 9), hl
	inc	de
	ld	bc, (ix - 3)
	jp	BB7_1
BB7_11:
	lea	hl, iy
	ld	sp, ix
	pop	ix
	ret


ev_watch:
	call	ti._frameset0
	ld	bc, (_ev_queued)
	ld	iy, (_ev_queue)
BB2_1:
	push	bc
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB2_5
	ld	hl, (iy)
	ld	de, (ix + 6)
	or	a, a
	sbc	hl, de
	jr	nz, BB2_4
	ld	(iy + 3), 1
BB2_4:
	dec	bc
	lea	iy, iy + 14
	jr	BB2_1
BB2_5:
	or	a, a
	sbc	hl, hl
	pop	ix
	ret


ev_unwatch:
	call	ti._frameset0
	ld	bc, (_ev_queued)
	ld	iy, (_ev_queue)
BB3_1:
	push	bc
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB3_5
	ld	hl, (iy)
	ld	de, (ix + 6)
	or	a, a
	sbc	hl, de
	jr	nz, BB3_4
	ld	(iy + 3), 0
BB3_4:
	dec	bc
	lea	iy, iy + 14
	jr	BB3_1
BB3_5:
	or	a, a
	sbc	hl, hl
	pop	ix
	ret


ev_trigger:
	call	ti._frameset0
	ld	bc, (_ev_queued)
	ld	iy, (_ev_queue)
	lea	iy, iy + 4
BB4_1:
	push	bc
	pop	hl
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB4_5
	ld	hl, (iy - 4)
	ld	de, (ix + 6)
	or	a, a
	sbc	hl, de
	jr	nz, BB4_4
	ld	(iy), 1
BB4_4:
	dec	bc
	lea	iy, iy + 14
	jr	BB4_1
BB4_5:
	or	a, a
	sbc	hl, hl
	pop	ix
	ret


ev_handle:
	ld	hl, -15
	call	ti._frameset
	or	a, a
	sbc	hl, hl
	ld	de, (_ev_queued)
	ld	(ix - 6), hl
	ld	(ix - 3), hl
BB5_1:
	ld	hl, (ix - 3)
	or	a, a
	sbc	hl, de
	jr	nc, BB5_7
	ld	(ix - 9), de
	ld	iy, (_ev_queue)
	ld	bc, (ix - 6)
	lea	hl, iy
	add	iy, bc
	bit	0, (iy + 3)
	jr	z, BB5_6
	ld	(ix - 12), iy
	ld	bc, (ix - 6)
	push	hl
	pop	iy
	add	iy, bc
	bit	0, (iy + 4)
	jr	z, BB5_6
	ld	de, (ix - 6)
	push	hl
	pop	iy
	add	iy, de
	ld	(ix - 15), iy
	ld	hl, (iy + 5)
	ld	de, (iy + 11)
	ld	bc, (iy + 8)
	push	bc
	push	de
	call	_indcallhl
	pop	hl
	pop	hl
	ld	de, (_ev_queued)
	ld	(ix - 9), de
	ld	iy, (ix - 15)
	bit	1, (iy + 14)
	jr	z, BB5_6
	ld	iy, (ix - 12)
	ld	(iy + 3), 0
BB5_6:
	ld	hl, (ix - 3)
	inc	hl
	ld	(ix - 3), hl
	ld	bc, 15
	ld	hl, (ix - 6)
	add	hl, bc
	ld	(ix - 6), hl
	ld	de, (ix - 9)
	jr	BB5_1
BB5_7:
	or	a, a
	sbc	hl, hl
	ld	sp, ix
	pop	ix
	ret

ev_cleanup:
	ld	hl, -6
	call	ti._frameset
	ld	iy, 11
	ld	bc, 0
BB6_1:
	ld	de, (_ev_queued)
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	nc, BB6_3
	ld	hl, (_ev_queue)
	ld	(ix - 3), bc
	ld	bc, (_ev_free)
	ld	(ix - 6), iy
	lea	de, iy
	add	hl, de
	ld	hl, (hl)
	push	hl
	push	bc
	pop	hl
	call	_indcallhl
	ld	bc, (ix - 3)
	pop	hl
	inc	bc
	ld	de, 22
	ld	iy, (ix - 6)
	add	iy, de
	jr	BB6_1
BB6_3:
	ld	hl, (_ev_free)
	ld	de, (_ev_queue)
	push	de
	call	_indcallhl
	ld	sp, ix
	pop	ix
	ret

_ev_malloc: rb	3

_ev_max_events: rb	3

_ev_free: rb	3

_ev_queued: rb	3

_ev_queue: rb	3
