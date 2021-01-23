;***************************************************************************
;                   STREET FIGHTER   VIDEO GAME                            *
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1994, IT, INC.	*
;***************************************************************************
;***************************************************************************
;       below RAM record format Season Statistics		*
;***************************************************************************
SCORES	equ	0	; 4 - Total Score
INITIALS	equ	4	; 4 - Initials

RECORDSIZE	equ	8  	; vital stats

KEYLENGTH	equ	8
STATBLOCKS	equ	10	; highscore totals

MAXHST	equ	10
;***************************************************************************
;  Joystick Values				*
;***************************************************************************
NULLMOVE	equ	0

SNONE	equ	0
SUP	equ	1
SRT	equ	2
SDN	equ	3
SLT	equ	4
SUPRT	equ	0x12
SDNRT	equ	0x32
SUPLT	equ	0x14
SDNLT	equ	0x34



SBK	equ	0x40
SFA	equ	0x08
SBA	equ	0x10
SFL	equ	0x80
SBL	equ	0x20

WAITTIME	equ	100

;***************************************************************************
;       Switch Task Equates			*
;***************************************************************************
TASKKEYRT		equ	69
TASKKEYLT		equ	70
