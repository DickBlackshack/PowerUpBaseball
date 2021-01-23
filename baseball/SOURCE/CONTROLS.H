;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************
	.region "RomCode"
	ds	0

;;JOYSTICK_BITS
;RIGHT	equ	0x01
;LEFT	equ	0x02
;DOWN	equ	0x04
;UP	equ	0x08
;FACING	equ	0x10
;AWAY	equ	0x20
;TOWARD	equ	0x40
;CENTER	equ	0x80

;B_RIGHT	equ	0x0
;B_LEFT	equ	0x1
;B_DOWN	equ	0x2
;B_UP	equ	0x3
;B_FACING	equ	0x4
;B_AWAY	equ	0x5
;B_TOWARD	equ	0x6
;B_CENTER	equ	0x7

STARTBASE	equ	0x40
FIRSTBASE	equ	0x20
SECONDBASE	equ	0x10
THIRDBASE	equ	0x08
HOMEPLATE	equ	0x04

C_FIRSTBASE  equ	0x1
C_SECONDBASE equ	0x2
C_THIRDBASE  equ	0x4
C_HOMEPLATE  equ	0x8
