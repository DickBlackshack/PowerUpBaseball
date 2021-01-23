;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************
;зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
; This file contains the special joystick animation 
; initializaton routines and joystick definition 
; information
;юддддддддддддддддддддддддддддддддддддддддддддддддддддддды

;зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
; SPECIALJOY word bit-map
;юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
;high byte
HADOKEN         equ 0x0100 ;down,down/toward,toward
HURRICANE       equ 0x0200 ;down,down/away,away
DRAGONPUNCH     equ 0x0400 ;toward,down,down/toward
DRAGONKICK      equ 0x0800 ;away,down,down/away
DOWNDOWN        equ 0x1000 ;down/away,down,down/toward,toward,toward/up
PILEDRIVER      equ 0x2000 ;down,down/away,away,toward
YOGA            equ 0x4000 ;away,down/away,down,down/toward,toward
TOWARDTOWARD    equ 0x8000 ;toward,down/toward,down,down/away,away

;low byte
HADOKENSUPER    equ 0x0001 ;down,down/toward,toward,down,down/toward,toward
AWAYCHARGESUPER equ 0x0002 ;away,toward,away,toward
GUILESUPER      equ 0x0004 ;down/away,down/toward,down/away,down/toward,up
FLASH           equ 0x0008 ;down charge,up
SONIC           equ 0x0010 ;away charge,toward
HURRICANESUPER  equ 0x0020 ;two hurricanes
ANYTOWARD       equ 0x0040 ;any toward
FULLHADOKEN     equ 0x0080 ;full hadoken including toward alone

	.import	Tweety
	.import	Stars
	.import	body_got_hit
	.import	head_got_hit
	.import	CheckForCombo
	.import	Ready
	.import	WatchForAttack
	.import	WatchForDefend
	.import	TakeYourPosition
	.import	TakeYourPositionAir
	.import	ThrownForward
	.import	StorePosition
	.import	RestorePosition
	.import	RecoveryMessage

	.import	RECHARGE
	.import	DEADBODY
	.import	TagTeamFindStartPosition
	.import	LET_ME_GO
	.import	RELEASE_ME
	.import	DIE_FROM_GRAB

	.import	AttractSem   
	.import	FightDoneSem 

