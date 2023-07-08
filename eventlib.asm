;------------------------------------------
include '../include/library.inc'

;------------------------------------------
library EVENTLIB, 1

export ev_setup
export ev_register
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
	jr	z, BB0_5
	ld	hl, (ix + 9)
	push	hl
	pop	bc
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, BB0_5
	ld	de, 14
	ld	(_ev_max_events), iy
	ld	(_ev_malloc), bc
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
	jr	z, BB0_4
	ld	de, 0
	jr	BB0_5
BB0_4:
	ld	de, 3
BB0_5:
	ex	de, hl
	pop	ix
	ret


ev_register:
	ld	hl, -3
	call	ti._frameset
	ld	hl, (ix + 9)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, BB1_2
	ld	hl, 1
	jr	BB1_7
BB1_2:
	ld	hl, (_ev_queued)
	ld	de, (_ev_max_events)
	or	a, a
	sbc	hl, de
	jr	nc, BB1_5
	ld	de, (ix + 15)
	ld	hl, (_ev_malloc)
	push	de
	call	_indcallhl
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, BB1_6
	ld	hl, 3
	jr	BB1_7
BB1_5:
	ld	hl, 2
	jr	BB1_7
BB1_6:
	ld	bc, (ix + 12)
	ld	de, (ix + 15)
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
	ld	bc, 14
	call	ti._imulu
	push	hl
	pop	de
	add	iy, de
	ld	hl, (ix + 6)
	ld	(iy), hl
	ld	hl, (ix + 9)
	ld	(iy + 5), hl
	ld	hl, (ix + 15)
	ld	(iy + 8), hl
	ld	hl, (ix - 3)
	ld	(iy + 11), hl
	or	a, a
	sbc	hl, hl
BB1_7:
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
	ld	hl, -12
	call	ti._frameset
	or	a, a
	sbc	hl, hl
	ld	de, (_ev_queued)
	push	hl
	pop	iy
BB5_1:
	push	hl
	pop	bc
	or	a, a
	sbc	hl, de
	jr	nc, BB5_7
	ld	(ix - 6), de
	ld	(ix - 3), bc
	ld	de, (_ev_queue)
	lea	hl, iy
	push	hl
	pop	bc
	ld	(ix - 9), de
	push	de
	pop	iy
	add	iy, bc
	bit	0, (iy + 3)
	jr	nz, BB5_4
	push	hl
	pop	iy
	ld	de, (ix - 6)
	jr	BB5_6
BB5_4:
	push	hl
	pop	bc
	ld	iy, (ix - 9)
	add	iy, bc
	bit	0, (iy + 4)
	push	hl
	pop	iy
	ld	de, (ix - 6)
	jr	z, BB5_6
	lea	de, iy
	ld	(ix - 12), de
	ld	hl, (ix - 9)
	add	hl, de
	push	hl
	pop	bc
	push	bc
	pop	iy
	ld	hl, (iy + 5)
	ld	de, (iy + 11)
	ld	bc, (iy + 8)
	push	bc
	push	de
	call	_indcallhl
	ld	iy, (ix - 12)
	pop	hl
	pop	hl
	ld	de, (_ev_queued)
BB5_6:
	ld	hl, (ix - 3)
	inc	hl
	ld	bc, 14
	add	iy, bc
	jr	BB5_1
BB5_7:
	or	a, a
	sbc	hl, hl
	ld	sp, ix
	pop	ix
	ret


ev_cleanup:
	ld	hl, -9
	call	ti._frameset
	ld	hl, (ix + 6)
	ld	(ix - 6), hl
	ld	hl, 11
	ld	(ix - 3), hl
	ld	bc, 0
BB6_1:
	ld	de, (_ev_queued)
	ld	iy, (_ev_queue)
	ld	(ix - 9), bc
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	nc, BB6_3
	ld	de, (ix - 3)
	add	iy, de
	ld	hl, (iy)
	push	hl
	ld	hl, (ix - 6)
	call	_indcallhl
	pop	hl
	ld	bc, (ix - 9)
	inc	bc
	ld	de, 14
	ld	hl, (ix - 3)
	add	hl, de
	ld	(ix - 3), hl
	jr	BB6_1
BB6_3:
	ld	(ix + 6), iy
	ld	hl, (ix - 6)
	ld	sp, ix
	pop	ix
	jp	(hl)

_ev_malloc: rb	3

_ev_max_events: rb	3

_ev_queued: rb	3

_ev_queue: rb	3
