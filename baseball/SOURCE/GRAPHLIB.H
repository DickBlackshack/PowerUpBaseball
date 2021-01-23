
;#define	BPP4		; set for 4 bits per pix
;#define	VERT		;set vert monitor

;equ: Blitter macro parameter definitions.
OPAQUE	equ	0x00
SEETHRU	equ	0x10

DECOMP	equ	0x08
RAW	equ	0x00

XFLIPON	equ	0x02
YFLIPON	equ	0x04

YES	equ	0x80
NO	equ	0x00

;ON	equ	0x01
;OFF	equ	0x00
;RELATIVE	 equ	 0x81	 ;window relative clipping on

PAGEA	equ	0	;draw page a
PAGEB	equ	512	;draw page b

;	interupt masks
;EIRQ	 equ	 $2100	 ; Enable interrupts value for SR
DIRQ	equ	$2700	; Disable interrupts value for SR

TST_TRANS	equ	0	;mode1+1
TST_FLIP	equ	1	;mode1+1
TST_FLOP	equ	2	;mode1+1
TST_ROT	equ	3	;mode1+1

TST_LOOK	equ	0	;mode1
TST_CLIP	equ	2	;mode1
TST_WP	equ	7	;mode1

Q_TRANSOFF equ	$fffe
Q_TRANSON	equ	$0001
Q_LOOKOFF	equ	$feff
Q_LOOKON	equ	$0100
Q_CLIPOFF	equ	$fbff
Q_CLIPON	equ	$0400
Q_WPOFF	equ	$7fff
Q_WPON	equ	$8000
Q_FLIPOFF	equ	$fffd
Q_FLIPON	equ	$0002
Q_FLOPOFF	equ	$fffb
Q_FLOPON	equ	$0004

;***************************************************************************
; Print Types				*
;***************************************************************************
HEX	 equ	0
DECIMALBYTE equ	1
DECIMALWORD equ 	2
DECIMALLONG equ	3

NOPAD	equ	0x40
NOPADS	equ	0x60
JLEFT	equ	0x80
JLEFTS	equ	0xA0
JRGTS	equ	0x20


;***************************************************************************
; BANK SWITCHING ADDRESSING
;***************************************************************************
B_SET0	equ 0x0
B_SET1	equ 0x4000
B_SET2	equ 0x8000

