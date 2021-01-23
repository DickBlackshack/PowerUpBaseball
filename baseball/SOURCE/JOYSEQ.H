;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************

HOME	equ	0x10
THIRD	equ	0x04
SECOND	equ	0x02
FIRST	equ	0x01

BUTSEQ1	MACRO
	dc.l	\1
	dc.w	\2
	dc.l	\3
	ENDM

;Special Button Switch definitions

TEST_BUT
	dc.b	HOME,HOME
	dc.b	FIRST,FIRST
	dc.b	HOME,HOME
	dc.b	0xff


	.align	2
TIMEOUT	equ	30
;зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
; InitSpecialJoySequences is called by all fighters
;юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	.import	KnockHim
SpecialJoySeq:
	BUTSEQ1	TEST_BUT,40,KnockHim
	dc.w	0xFFFF


