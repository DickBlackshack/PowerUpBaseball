STARTCOMPUTER  equ	0
STARTHUMAN	    equ   1
CONTINUEGAME   equ	2
COMPLETEGAME   equ	3
STARTGAME	    equ	4
TOTGTIME	    equ   5		;long
CDOOR1	    equ	7
CDOOR2	    equ	8

TOTALTAG	equ	9

TC_RYU	equ	10
TC_VEGA	equ	11
TC_GUILE	equ	12
TC_SAGAT	equ	13
TC_KEN	equ	14
TC_HONDA	equ	15
TC_CHUNLI	equ	16
TC_CAMMY	equ	17
TC_SAWADA	equ	18
TC_BALROG	equ	19
TC_TROOPER1	equ	20
TC_BISON	equ	21
TC_AKUMA	equ	22
TC_ZANGIEF	equ	23
TC_ARKANE	equ	24
TC_F7	equ	25
TC_KHYBER	equ	26
TC_SBISON	equ	27

SECRET1	equ	28	;Arkane select 
SECRET2	equ	29 	;F7 select 
SECRET3	equ	30	;Khyber select 
SECRET4	equ	31	;prog backgnd  
SECRET5	equ	32	;blanka screen 
SECRET6	equ	33	;Khyber in backgnd 
SECRET7	equ	34	;Arkane in backgnd 
SECRET8	equ	35	;snake found cloud fall
SECRET9	equ	36	; crowd guys
SECRET10	equ	37	; crates
SECRET11	equ	38	; tino anhead
SECRET12	equ	39	; chopper kill
SECRET13	equ	40	; anhead daytime
SECRET14	equ	41	; fire off
SECRET15	equ	42	;BLANKA FIGHTS 
SECRET16	equ	43	;FEI LONG

COMPLETETAG equ	44	; complete tag team games

AUDIT	macro	AuditNum
	.global	IncAudit
	movem.l	d0,-(sp)
	move.w	AuditNum,d0
	jsr	IncAudit
	movem.l	(sp)+,d0
	endm                        


