;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************
	
	.global	Inning
	.global	CharTrans
	.global	F5CharTrans
	.global	FontAdjust
	.global	FontSpacing
	.global	fnt1Spacing

	.global	SendSound

	.global	WasAVint
	.global	SFONTX
	.global	SetSysFont
	.global	BallCordX
	.global	SFONTY
	.global	BallCordY
	.global	BallCordZ
	.global	ZoneObjPtr
	.global	Third2ObjPtr
	.global	Third1ObjPtr
	.global	FirstObjPtr
	.global	OutObjPtr
	.global	StrikeObjPtr
	.global	BallObjPtr
	.global	BallTempX
	.global	BallTempY
	.global	PitchHeight
	.global	Random
	.global	Batter
	.global	ROCKX
	.import.s	SwitchReason
	.import.s	Baseball	; Baseball Object
	.import.s	ControlPtr
	.global	didswing
	.global	WatchBall
	.global	ZonePtr
	.global	Bat_Team
	.global	BlitObject,BlitAObject
	.global	AllocObject
	.global	Anim
	.global	SFONTY2
	.global	BallPassed
	.global	CardPtr
	.export	MoveBall
	.export	ShowBall
	.global	RockPtr
	.global	DirtPtr
	.global	ScorePtr
	.import.s	HitDirection
	.global	AddStrike
	.global	PlayerL
	.global	PlayerR
	.global	firstteam
	.global	Pitcher
	.global	BALLX
	.global	BALLY
	.global	PitchType
	.global	CardAnimPinch
	.import	BallOnGround
	.export	BallXBias,BallZBias
	.global	DirtObj
	.global	DisplayBall
	.global	ZoneObj
	.global	TestClipObj
	.global	RockObj
	.global	Zone3Obj
;	.global	OutFnt
	.global	BallObj
	.global	SwingFlag

	.export	Dust
	.import	PowerBallPal	;Palette for PowerBall
	.export	CheckHit
	.import	ZoneHeight
	.import	CaveManSwing,ThrowAndHit

	.global	HomePlayer
	.global	AwayPlayer

	.export	HelpHalf
	.global	GetBatterRoster
	.global	blit_card2
	.global	strike
	.global	outs,ForcedOut
	.global	BatRoster
	.global 	bricount2
	.import	BlitClipObj,AtBatPlayer,DoHeadPalette
	.import	CheckPowerUp,draftteam
	.import	CheckPowerUp2
	.global	didwiff
	.import.s	GameTime

	.export	WallLaser,ScrewHim,HelpHim
	.import	AtPitPlayer,ProcessTime
	.import	AtBatPlayer,ThrowUp
	.import	CanSwing
	.export	ThrowUpBall
	.export	BallXVel,BallYVel

	.export	HomeRunObj	;These are the Big Font
	.export	DoublePlayObj	;calls!
	.export	StrikemObj
	.export	RetiredObj
	.export	ExtraObj
	.export	TakeObj
	.export	BigOutObj,BigWinObj
	.export	BigSafeObj
	.export	ForceOutObj
	.export	Help1Obj
	.export	Help1Ptr
	.export	LaserHit
	.export	NotEnough
	.export	NotEnoughP
	.export	ProTipObj
	.export	ProTipPtr
	.export	BatterHelp
	.export	PitcherHelp
	.export	VintageHit
	.export	CavemanHit
	.export	BigMesh
	.import	SinglePlayer

	.export	NameNum
	.export	HelpSwitch
	.export	ClearObjPtrs

	.export	PitcherTag,PitchTime
	.export	BatterTag

	.export	RunnerHelp
	.export	FieldHelp

	.export	UnderHandPitch

	.import	NeoCharTrans
	.import	neo1Spacing
	.import	AlphaOrder

	#include	"itvideo2.h"
	#include	"sys.h"
	#include	"sys.mac"
	#include	"graphlib.mac"
	#include	"graphlib.h"
	#include	"graphglb.h"
	#include	"macros.h"
;	#include	"r:\baseball\art\tables\player.h"
;	#include	"c:\bb\player.h"
;	#include	"r:\baseball\sounds\bsblsnds.equ"
	#include	"bsblsnds.equ"
	#include	"player.h"
	#include	"ramblock.h"
	#include	"anim.mac"
	#include	"groms.h"
	#include	"stats.h"
	#include	"audits.h"
	#include	"pals.h"
	#include	"controls.h"
	#include	"rosters.h"

NOGHOST	equ	0
FIREBALL	equ	1
GHOSTBALL	equ	2

	.region	"RAM"

BiasTable	    ds.l	1
	.export	BallHeight
BallHeight	    ds.l	1
BallZone	    ds.w	1	; 0 - High, 1 - Middle, 2 - Low
BatSpeed	    ds.w	1
Power	    ds.w	1 	; Batter's Power Attribute
Accuracy	    ds.w	1	; Closeness Of Bat To Ball
BatAvgBoost    ds.w	1	; Batting Average Boost
Ghosting	    ds.b	1
GhostCount	    ds.b	1
FirstMove	    ds.b	1
BallMove	    ds.b	1
BallPassed	    ds.b	1
PitchType	    ds.b	1
LaserHit	    ds.b	1
VintageHit	    ds.b	1
UnderHandPitch ds.b	1
KnuckleBall    ds.b	1
SuckyHit	    ds.b	1
HelpSwitch	    ds.w	1
ScrewHim	    ds.b	1
HelpHim	    ds.b	1

AfterPlate	    ds.l	1
ZonePtr	    ds.l	1
HelpHPtr	    ds.l	1
CardPtr        ds.l  1
RockPtr        ds.l  1
DirtPtr        ds.l  1
WinFPtr	    ds.l	1
FirstObjPtr    ds.l	1
Third1ObjPtr   ds.l	1
Third2ObjPtr   ds.l	1
BallObjPtr	    ds.l	1
StrikeObjPtr   ds.l	1
OutObjPtr	    ds.l	1
ScorePtr	    ds.l	1
ROCKX	    ds.w	1
ROCKY	    ds.b	1
BigOutPtr	    ds.l	1
BigWinPtr	    ds.l	1
BigSafePtr	    ds.l	1
DoublePlayPtr  ds.l	1
RetiredPtr	    ds.l	1
Help1Ptr	    ds.l	1
Help2Ptr       ds.l	1
Help3Ptr       ds.l	1
Help4Ptr       ds.l	1
ProTipPtr       ds.l	1
ForceOutPtr    ds.l	1

BallCordX      ds.l  1
BallCordY      ds.l  1
BallCordZ      ds.l  1
	.export	BallDestZ
BallDestZ	    ds.l	1
BALLX	    ds.w	1
BALLY	    ds.w	1 
SFONTX	    ds.w	1
SFONTY	    ds.w	1          
SFONTY2	    ds.w	1
NewBallX	    ds.w	1
HelpX	    ds.w	1
HelpCounter    ds.w	1
PitchTime	    ds.w  1
scorex	    ds.w	1
temp	    ds.w	1
whichteam      ds.l  1
BallY	    ds.w	1

	 .export	BallXOffset,BallXOVel,BallXOAccel
	 .export	BallYOffset,BallYOVel,BallYOAccel
            .export	BigWinPtr,HelpCounter

BallXOffset    ds.l	1
BallXOVel	    ds.l  1
BallXOAccel    ds.l	1	; Pitched Ball X Acceleration

BallYOffset    ds.l	1
BallYOVel	    ds.l  1
BallYOAccel    ds.l	1	; Pitched Ball X Acceleration

BallXVel       ds.w	1
BallYVel	    ds.w	1
BallTempY	    ds.l	1
BallTempX	    ds.l	1

BallZBias	    ds.l	1	; Bias Used For Twister\Knuckle Ball
BallXBias	    ds.l	1

cardscaleX	ds.w	1
cardscaleY	ds.w	1
bricount2	ds.b	1
PitchHeight    ds.b	1
PowerPtr	ds.l	1 	;Pointer to Power Bars
PowerPtr2	ds.l	1	;Pointer to Power Bars
NameNum	ds.w	1	;Pointer to Power Bars

extrainnings	ds.l	1 ;TEMP shifts score on scoreboard

PinchIndex	ds.w	1
HomeID	ds.w	1
AwayID	ds.w	1

	.region	"RomCode"

;***************************************************************************
;   DisplayBall - Display Ball		*
;                                                                          *
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
DisplayBall:
	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_BLACK	; Palette Number
	move.w	XPOSITION(a5),d4	; 2 byte x value
	move.w	YPOSITION(a5),d5	; Load Y Position
	move.w	PICTURE(a5),d3	; Reload Frame Number
	jsr	Blit	; Blit The Object

	APALETTE	#P_BALL	; Palette Number
;       	cmp.b	#1,([AtBatPlayer],POWERNUM) ;power used?
	tst.b	LaserHit
	beq.s	NoLightPower
	APALETTE	#P_PURP	; Palette Number
NoLightPower:
	cmp.b	#0,PowerBallPal
	beq.s	NoPowerT
	APALETTE	#P_FIRE	; Palette Number
NoPowerT:
	tst.b	VintageHit
	beq.s	NoVintPower
	APALETTE	#P_FIRE	; Palette Number
NoVintPower:
	move.w	XPOSITION(a5),d4	; 2 byte x value
	move.w	YPOSITION(a5),d5	; Load Y Position
	move.l	WORLDZ(a5),d0	; Load World Z Position
	asr.l	#8,d0	; Shift In Integer Part
	asr.w	#1,d0	; Divide By One More
	sub.w	d0,d5	; Add To Y Position
	move.w	PICTURE(a5),d3	; Reload Frame Number
	move.w	d5,BallY	; Ball position for sparks
	jsr	Blit	; Blit The Object


	rts

	
BallObj:   ;This is the Baseball used for Strikes and Outs
	jsr	AllocObject	; Allocate An Object
	beq.s	BALL_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
;	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#10,ZPOSITION(a0)	; Initialize Z Position
	move.w	#ball0084,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	BALLX,XPOSITION(a0)	; Set X Position
	move.w	BALLY,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
           move.l    a0,BallObjPtr
	add.w	#20,BALLX
BALL_1:
	rts

	.align	2

BigOutObj:   ;This is the Big Out
	tst.b	ForcedOut	; Check For Forced Out
	bne.s	ForceOutObj	; Branch If It Is
	jsr	AllocObject	; Allocate An Object
	beq.s    	BigOut_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#10,ZPOSITION(a0)	; Initialize Z Position
	move.w	#bigout,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#BigOutAnim,PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#130,XPOSITION(a0)	; Set X Position
	move.w	#40,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
           move.l    a0,BigOutPtr
BigOut_1:
	rts
	.align	2
BigOutAnim:
           LASTFRAME 40
	DEALLOC
	.align	2
	

ForceOutObj:   ;This is the Force Out art
	move.l	BigOutPtr,a1	; Load Address Of Out
	cmp.l	#0,BigOutPtr	;Check if there is one
	beq.s	NoOutF	;Branch if 0
	move.b	#1,DELETED(a1)	; Remove The Out
NoOutF:
	jsr	AllocObject	; Allocate An Object
	beq.s    	ForceOut_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#10,ZPOSITION(a0)	; Initialize Z Position
	move.w	#forceout,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#ForceOutAnim,PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#130,XPOSITION(a0)	; Set X Position
	move.w	#40,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
           move.l    a0,ForceOutPtr
ForceOut_1:
	clr.b	ForcedOut	; Clear Forced Out Flag
	rts
	.align	2
ForceOutAnim:
           LASTFRAME 40
	DEALLOC
	.align	2




BigSafeObj:   ;This is the Baseball used for Strikes and Outs
	jsr	AllocObject	; Allocate An Object
	beq.s    	BigSafe_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#10,ZPOSITION(a0)	; Initialize Z Position
	move.w	#safe,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#BigSafeAnim,PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#130,XPOSITION(a0)	; Set X Position
	move.w	#40,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
           move.l    a0,BigSafePtr
BigSafe_1:
	rts
	.align	2
BigSafeAnim:
           LASTFRAME 40
	DEALLOC
	.align	2

HomeRunObj:   ;This is the home run obj
	jsr	AllocObject	; Allocate An Object
	beq.s    	HomeRun_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#250,ZPOSITION(a0)	; Initialize Z Position
	move.w	#homerun,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#HomeRunAnim,PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#130,XPOSITION(a0)	; Set X Position
	move.w	#40,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
HomeRun_1:
	rts
	.align	2
HomeRunAnim:
           LASTFRAME 40
	DEALLOC
	.align	2


DoublePlayObj:   ;This is the Baseball used for Strikes and Outs
	move.l	BigOutPtr,a1	; Load Address Of Out
	cmp.l	#0,BigOutPtr	;Check if there is one
	beq.s	NoOut	;Branch if 0
	move.b	#1,DELETED(a1)	; Remove The Out
NoOut:
	move.l	ForceOutPtr,a1	; Load Address Of Out
	cmp.l	#0,ForceOutPtr	;Check if there is one
	beq.s	NoOut_2	;Branch if 0
	move.b	#1,DELETED(a1)	; Remove The Force Out
NoOut_2:
	cmp.l	#0,RetiredPtr	;Check if there is one
	beq.s	WasRetired	;Branch if 0

	jsr	AllocObject	; Allocate An Object
	beq.s    	DoublePlay_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#250,ZPOSITION(a0)	; Initialize Z Position
	move.w	#doublep,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#DoublePlayAnim,PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#100,XPOSITION(a0)	; Set X Position
	move.w	#30,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
           move.l    a0,DoublePlayPtr
WasRetired:
DoublePlay_1:
	rts
	.align	2
DoublePlayAnim:
           LASTFRAME 40
	DEALLOC
	.align	2


StrikemObj:   ;This is the Baseball used for Strikes and Outs
	jsr	AllocObject	; Allocate An Object
	beq.s    	Strikem_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#250,ZPOSITION(a0)	; Initialize Z Position
;	move.w	#strikem,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#StrikemAnim,PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_FONTY1,PALETTE(a0)	; Set Palette Number
	move.w	#130,XPOSITION(a0)	; Set X Position
	move.w	#40,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
Strikem_1:
	rts
	.align	2
StrikemAnim:
           LASTFRAME 40
	DEALLOC

	.align	2
ClearObjPtrs:
	clr.l	BigOutPtr
	clr.l	ForceOutPtr
	clr.l	DoublePlayPtr
	rts



RetiredObj:   ;This is the retired object
	move.b	#1,BallOnGround	; Activate Ball

	cmp.l	#0,BigOutPtr	;Check if there is one
	beq.s	R_NoOut1	;Branch if 0
	move.l	BigOutPtr,a1	; Load Address Of Out
	cmp.b	#0,DELETED(a1)
	bne.s	R_NoOut1
	move.b	#1,DELETED(a1)	; Remove The Out
R_NoOut1:
	cmp.l	#0,DoublePlayPtr	;Check if there is one
	beq.s	R_NoOut2	;Branch if 0
	move.l	DoublePlayPtr,a1	; Load Address Of Out
	cmp.b	#0,DELETED(a1)
	bne.s	R_NoOut2
	move.b	#1,DELETED(a1)	; Remove The Double Obj
R_NoOut2:
	cmp.l	#0,ForceOutPtr	;Check if there is one
	beq.s	R_NoOut3	;Branch if 0
	move.l	ForceOutPtr,a1	; Load Address Of Out
	cmp.b	#0,DELETED(a1)
	bne.s	R_NoOut3
	move.b	#1,DELETED(a1)	; Remove The Force Out
R_NoOut3:
	jsr	AllocObject	; Allocate An Object
	beq.s    	Retired_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#250,ZPOSITION(a0)	; Initialize Z Position
	move.w	#retired,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#RetiredAnim,PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#70,XPOSITION(a0)	; Set X Position
	move.w	#40,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
           move.l    a0,RetiredPtr


Retired_1:
	rts
	.align	2
RetiredAnim:
           LASTFRAME 40
	DEALLOC
	.align	2

	.global Instructions
Help1Obj:   ;This is the Big Out
	jsr	AllocObject	; Allocate An Object
	beq.s    	Help_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#0XFFFF,ZPOSITION(a0)	; Initialize Z Position
	move.w	#help01,PICTURE(a0)	; Set Base-O-Meter Picture
	move.l	#Instructions,PARSEPOINTER(a0) ; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	#125,XPOSITION(a0)	; Set X Position
	move.w	#60,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
           move.l    a0,Help1Ptr
Help_1:
	rts

ExtraObj:   ;This is the Baseball used for Strikes and Outs
	jsr	AllocObject	; Allocate An Object
	beq.s    	Extra_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#250,ZPOSITION(a0)	; Initialize Z Position
	move.w	#extra,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#ExtraAnim,PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#70,XPOSITION(a0)	; Set X Position
	move.w	#40,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
;           move.l    a0,RetiredPtr

Extra_1:
	rts
	.align	2
ExtraAnim:
           LASTFRAME 40
	DEALLOC
	.align	2



TakeObj:   ;This is the Baseball used for Strikes and Outs
	jsr	AllocObject	; Allocate An Object
	beq.s    	Take_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#250,ZPOSITION(a0)	; Initialize Z Position
	move.w	#take,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#TakeAnim,PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#50,XPOSITION(a0)	; Set X Position
	move.w	#40,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
;           move.l    a0,RetiredPtr

Take_1:
	rts
	.align	2
TakeAnim:
           LASTFRAME 80
	DEALLOC


	.align	2
ProTipObj:   ;This is the Baseball used for Strikes and Outs
	jsr	AllocObject	; Allocate An Object
	beq.s    	ProTip_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#0xFFFF,ZPOSITION(a0)	; Initialize Z Position
	move.w	#protip,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#ProTipAnim,PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#115,XPOSITION(a0)	; Set X Position
	move.w	#20,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
           move.l    a0,ProTipPtr

ProTip_1:
	rts
	.align	2
ProTipAnim:
           LASTFRAME 200
           LASTFRAME 200
           LASTFRAME 200
           LASTFRAME 200
           LASTFRAME 200
           LASTFRAME 200
           LASTFRAME 200
	DEALLOC
	.align	2




;RunnerHelp:   ;This is the Baseball used for Strikes and Outs
;	jsr	AllocObject	; Allocate An Object
;	beq.s    	RunHelp_1	; Branch If None
;	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
;	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
;	move.w	#0xFFFF,ZPOSITION(a0)	; Initialize Z Position
;	move.w	#help02,PICTURE(a0)	; Set Base-O-Meter Picture
;	clr.l	PARSEPOINTER(a0)	; Set Animation String
;	move.l	#RunHelpAnim,PARSEPOINTER(a0)  ; Set Animation String
;	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
;	move.w	#200,XPOSITION(a0)	; Set X Position
;	move.w	#190,YPOSITION(a0)	; Set Y Position
;	move.b	#Misc,BANK(a0)	; Set Bank Number
;	move.b	#1,STATIONARY(a0)	; Set As Stationary
;;           move.l    a0,ProTipPtr
;
;RunHelp_1:
;	rts
;	.align	2
;RunHelpAnim:
;	LASTFRAME 1
;	FRAMERATE 60	; 5 second delay
;           LASTFRAME 3
;	FRAMERATE 0
;	DEALLOC
;	.align	2


;FieldHelp:   ;This is the Baseball used for Strikes and Outs
;	jsr	AllocObject	; Allocate An Object
;	beq.s    	FieldHelp_1	; Branch If None
;	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
;	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
;	move.w	#0xFFFF,ZPOSITION(a0)	; Initialize Z Position
;	move.w	#help01,PICTURE(a0)	; Set Base-O-Meter Picture
;	clr.l	PARSEPOINTER(a0)	; Set Animation String
;	move.l	#FieldHelpAnim,PARSEPOINTER(a0)  ; Set Animation String
;	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
;	move.w	#115,XPOSITION(a0)	; Set X Position
;	move.w	#20,YPOSITION(a0)	; Set Y Position
;	move.b	#Misc,BANK(a0)	; Set Bank Number
;	move.b	#1,STATIONARY(a0)	; Set As Stationary
;
;FieldHelp_1:
;	rts
;	.align	2
;FieldHelpAnim:
;	LASTFRAME 1
;	FRAMERATE 60	; 5 second delay
;          LASTFRAME 3
;	FRAMERATE 0
;	DEALLOC
;	.align	2
;
	.global BaseMeterObj
BaseMeterObj:
	jsr	AllocObject	; Allocate An Object
	beq.s	BaseM_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
;	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#10,ZPOSITION(a0)	; Initialize Z Position
	move.w	#meter2a,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_METER,PALETTE(a0)	; Set Palette Number
;	move.w	#370-85,XPOSITION(a0)	; Set X Position
;	move.w	#240-87,YPOSITION(a0)	; Set Y Position
;	move.w	#370-85-40,XPOSITION(a0)	; Set X Position40
;	move.w	#370-85-45,XPOSITION(a0)	; Set X Position  ;60
	move.w	#370-70,XPOSITION(a0)	; Set X Position  ;60
	move.w	#170,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
BaseM_1:
	rts

	.align	2

	.import	WinningPlayer
	.import	F2CharTrans
	.import	fnt2Spacing

BigWinObj:   ;This is the Winner message
	jsr	AllocObject	; Allocate An Object
	beq.s	.NoObj	; Branch If None
	move.l	#BlitWin,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#0xffff,ZPOSITION(a0)	; Initialize Z Position
;	move.w	#bigout,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#BigWinAnim,PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_FONTY1,PALETTE(a0)	; Set Palette Number
	move.w	#130,XPOSITION(a0)	; Set X Position
	move.w	#40,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
;           move.l    a0,BigOutPtr
.NoObj
	rts


	.align	2
Dust:   ;This is the Baseball used for Strikes and Outs
	jsr	AllocObject	; Allocate An Object
	beq.s    	Dust_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#12,ZPOSITION(a0)	; Initialize Z Position
	move.w	#dust0001,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#DustAnim,PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_DUST,PALETTE(a0)	; Set Palette Number
	move.w	#180,XPOSITION(a0)	; Set X Position
	move.w	#85,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
           move.l    a0,ProTipPtr

Dust_1:
	rts
	.align	2
DustAnim:
	SPRITE	dust0001,1
	SPRITE	dust0002,1
	SPRITE	dust0003,1
	SPRITE	dust0004,1
	SPRITE	dust0005,1
	SPRITE	dust0006,1
	SPRITE	dust0007,1
	SPRITE	dust0008,1
	SPRITE	dust0009,1
	SPRITE	dust0010,1
	SPRITE	dust0011,1
	SPRITE	dust0012,2
	SPRITE	dust0013,2
	SPRITE	dust0014,2
	SPRITE	dust0015,2
	SPRITE	dust0016,2
	SPRITE	dust0017,2
	SPRITE	dust0018,2
	SPRITE	dust0019,2

	DEALLOC
	.align	2


	.align	2
BigWinAnim:
 ;	SPRITE	bigout,10
           LASTFRAME 60


;           LASTFRAME 250
;           LASTFRAME 250
;           LASTFRAME 250
;           LASTFRAME 250
;           LASTFRAME 250


	DEALLOC

	.align	2

	.import	TeamNames,PrintCentered
	.import	BIGCharTrans
	.import	fnt5Spacing
	.import	PrintHelp

BlitWin
;	SETPRINT	#16,#24,#fnt2,#0
;	clr.l	FontAdjust
;	move.l	#fnt2Spacing,FontSpacing
;	move.l	#F2CharTrans,CharTrans ; character translation table
;
;	APALETTE	#P_FONTY1
;
;	move.w	ProcessTime,d0
;	and.w	#8,d0
;	beq.s	playerdone	;blink it
;
;	move.l	WinningPlayer,d0
;	cmp.l	#PlayerL,d0
;	bne.s	player2side
;
;	PLOT	#10,#10
;	PRINT	"PLAYER 1"
;	bra	playerdone
;player2side
;	PLOT	#210,#10
;	PRINT	"PLAYER 2"
;
;playerdone


	SETPRINT	#31,#46,#neo1,#0
	clr.l	FontAdjust
	move.l	#neo1Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEOYEL	;temp? waiting for neo color pals



	PLOT	#192,#70

	move.w	([WinningPlayer],TEAMNUMBER),d0
;	move.w	([AtBatPlayer],TEAMNUMBER),d0


	cmp.w	#draftteam,d0
	bne.s	nodraft1	;branch if not a draft team
	lea.l	([WinningPlayer],letters),a0
	PLOT	#180,#70
	clr.w	d6
	move.w	#3,d7	;print 3 letters
	jsr	PrintCentered
	bra	Wnamedone
nodraft1

	asl.w	#2,d0	;times 4 
	move.l	(WinNameTBL,d0.w),a0
;	PRINTS	a0
	clr.w	d6	
	move.w	#$7FFF,d7
	jsr	PrintCentered	;entry point for plot print

Wnamedone
	PLOT	#192,#135
	move.l	#WinText,a0
;	PRINTS	a0
	clr.w	d6	
	move.w	#$7FFF,d7
	jsr	PrintCentered	;entry point for plot print

	rts

WinText	dc.b	"WIN",0

	.align	2
WinNameTBL
	dc.l	wn1
	dc.l	wn2
	dc.l	wn3
	dc.l	wn4
	dc.l	wn5
	dc.l	wn6
	dc.l	wn7
	dc.l	wn8
	dc.l	wn9
	dc.l	wna
	dc.l	wnb
	dc.l	wnc
	dc.l	wnd
	dc.l	wne
	dc.l	wnf
	dc.l	wng
	dc.l	wnh
	dc.l	wni
	dc.l	wnj
	dc.l	wnk
	dc.l	wnl
	dc.l	wnm
	dc.l	wnn
	dc.l	wno
	dc.l	wnp
	dc.l	wnq
	dc.l	wnr
	dc.l	wns

	dc.l	wnt
	dc.l	wnu
	dc.l	wnv
	dc.l	wnw

	.align	2
WinNames:
wn1	dc.b	"BRAVES",0
wn2	dc.b	"ORIOLES",0
wn3	dc.b	"RED SOX",0
wn4	dc.b	"ANGELS",0
wn5	dc.b	"CUBS",0
wn6	dc.b	"WHITE SOX",0
wn7	dc.b	"REDS",0
wn8	dc.b	"INDIANS",0
wn9	dc.b	"ROCKIES",0
wna	dc.b	"TIGERS",0
wnb	dc.b	"MARLINS",0
wnc	dc.b	"ASTROS",0
wnd	dc.b	"ROYALS",0
wne	dc.b	"DODGERS",0
wnf	dc.b	"BREWERS",0
wng	dc.b	"TWINS",0
wnh	dc.b	"EXPOS",0
wni	dc.b	"METS",0
wnj	dc.b	"YANKEES",0
wnk	dc.b	"ATHLETICS",0
wnl	dc.b	"PHILLIES",0
wnm	dc.b	"PIRATES",0
wnn	dc.b	"CARDINALS",0
wno	dc.b	"PADRES",0
wnp	dc.b	"GIANTS",0
wnq	dc.b	"MARINERS",0
wnr	dc.b	"RANGERS",0
wns	dc.b	"BLUE JAYS",0

wnt	dc.b	"DRAFTTEAM",0
wnu	dc.b	"AMERICAN",0
wnv	dc.b	"NATIONAL",0
wnw	dc.b	"DESIGN",0

	.align	2

           .export B_CardObj
           .import	swing,blit_card,p1info,p2info,batternum
	.import	card_pal,DIM,NOTDIM,draft_stat
B_CardObj:   ;this is the BaseBall Card.
	jsr	AllocObject	; Allocate An Object
	beq.s	B_Card	; Branch If None
	move.l	#BlitCard,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#217,ZPOSITION(a0)	; Initialize Z Position
	move.w	#card0501,PICTURE(a0)	; Set Base-O-Meter Picture
;	move.b	#P_CARD,PALETTE(a0)	; Set Palette Number
	move.b	#Cards,BANK(a0)	; Set Bank Number
	move.l    a0,CardPtr
	move.w	#0,cardscaleX
	move.w	#0,cardscaleY
	move.l	#CardAnim,PARSEPOINTER(a0)	; Set Animation String
	move.w	#145,YPOSITION(a0)	; Set Y Position
	move.w	#0,PinchIndex	;for alpha order pinch selection

	cmp.b	#0,swing
	bne.s	CardRightSide

	move.w	#15,XPOSITION(a0)
	move.w	([AtBatPlayer],TRACKX),tbx1 ;init trackball
B_Card:
	rts
CardRightSide
	move.w	#216,XPOSITION(a0)
	rts

CardAnim:  
	LASTFRAME 120
;	LASTFRAME 190

 .if debugmode=="obe"
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
 .endif

OldSetRam:
	SETABSW	CardPtr,0
	SETABSW	CardPtr+2,0
	SYSTEM	PrintHelp
	DEALLOC

CardAnimPinch:
	LASTFRAME	250
	LASTFRAME	250
	LASTFRAME	250
	JUMP	OldSetRam

	.align	2

BlitCard
	cmp.b	#2,([AtBatPlayer],POWERNUM) ;power used?
	bne.s	.nopower
;pinch-hitter selection
	jsr	PinchHitter
;	clr.l	d0
;	move.w	([AtBatPlayer],TRACKX),d0
;	lsr.w	#4,d0	;sensetivity
;	divu	#9,d0	;9 possible players to chose from
;	swap	d0	;get mod
;	asl.w	#2,d0	;adr index
;	move.l	([AtBatPlayer],d0.w,ROSTERPTR),BatRoster

;	PUSHL	a5
;	move.l	#Batter,a5
;	jsr	DoHeadPalette
;	POPL	a5
.nopower


	cmp.w	#256,cardscaleX
	bge.s	.fullscale
	add.w	#9,cardscaleX	;was 7
	add.w	#9,cardscaleY
;	bra.s	.scaling
;.fullscale	move.w	#256,cardscaleX
;	move.w	#256,cardscaleY
;.scaling
	OSCALE	cardscaleX,cardscaleY
	CLIP	OFF
.fullscale
	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_NEWSCORE	; Palette Number
	move.w	XPOSITION(a5),d0
	sub.w	#14,d0
	move.w	YPOSITION(a5),d1
	sub.w	#13,d1
	move.w	#carda,d2
	cmp.l	#PlayerL,AtBatPlayer
	beq.s	.plaque	;use red plaque
	move.w	XPOSITION(a5),d0
	sub.w	#21,d0
	move.w	YPOSITION(a5),d1
	sub.w	#10,d1
	move.w	#cardb,d2

.plaque
	BLIT	d2,d0,d1	;plaque

	move.w	XPOSITION(a5),d6	; Set X Position62
	move.w	YPOSITION(a5),d7	; Set Y Position
;	jsr	GetBatterRoster
	move.l	BatRoster,a6
	move.b	#NOTDIM,card_pal

	jsr	blit_card2
	jsr	draft_stat

	OSCALE	#$100,#$100	;reset OSCALE
	ROT_OFF		;reset OSCALE
	CLIP	ON

	rts

	.import	teamattrib_size
	.import	attrib_size
	.import	tbx1
	.import	ROSTERsize
	.import	DraftAttr
	.import	plpos,DoSkinPalette
	.import	ROSTERS


sensitive	equ	30	;trackball sensitivity

PinchHitter
	tst.b	([AtBatPlayer],BUTTONS)
	beq.s	.PowerOn
	clr.b	([AtBatPlayer],BUTTONS)
	move.l	#OldSetRam,PARSEPOINTER(a5)	; Set Animation String
	clr.b	([AtBatPlayer],POWERNUM) ;turn off power
	move.b	#1,DELETED(a5)	; Remove The Card Object
	clr.l	CardPtr
	rts
.PowerOn
	move.w	plpos,d0	;batters position on team
	lea.l	([AtBatPlayer],d0.w*4,ROSTERPTR),a0 ;point at current pitchers roster adr


	move.w	tbx1,d0
	sub.w	([AtBatPlayer],TRACKX),d0

	cmp.w	#sensitive,d0
	blt.s	.noinc
	move.w	([AtBatPlayer],TRACKX),tbx1
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove	; Init Sounds System

;	add.l	#teamattrib_size,(a0) ;next team
	add.w	#1,PinchIndex	;next team
	cmp.w	#27,PinchIndex
	ble.s	.nomax
	clr.w	PinchIndex	;wrap
.nomax
	jmp	.nodec

.noinc	cmp.w	#-sensitive,d0
	bgt.s	.nodec
	move.w	([AtBatPlayer],TRACKX),tbx1
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove	; Init Sounds System

;	sub.l	#teamattrib_size,(a0) ;next team
	sub.w	#1,PinchIndex	;next team
	bpl.s	.nomin
	move.w	#27,PinchIndex	;wrap
.nomin
.nodec

	move.w	plpos,d0	;batters position on team
	mulu	#28,d0	;number of teams
	add.w	PinchIndex,d0	;selector
	clr.w	d1
	move.b	(AlphaOrder,d0.w),d1	;get team number
;convert to rosteradr
	move.w	plpos,d0	;batters position on team
	mulu	#attrib_size,d0	;pos*attsize
	mulu	#teamattrib_size,d1	;team*NumberOfTeamPlayers
	move.l	#ROSTERS,a1
	lea.l	(a1,d1.w),a1	;get to team
	lea.l	(a1,d0.w),a1	;get to position

	move.l	a1,(a0)

;	move.l	(a0),BatRoster
	move.l	a1,BatRoster

	PUSHL	a5
	move.l	#Batter,a5
	jsr	DoSkinPalette
	POPL	a5

	rts


	.align	2

	.export	StrikeOuts
;***************************************************************************
;   StrikeOuts - Display Strikes and Outs		*
;				*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
StrikeOuts:
	jsr	AllocObject	; Allocate An Object
	beq.s	Strike_1	; Branch If None
	move.l	#DspStrikeOut,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	clr.l	UPDATEPROC(a0)	; Clear Animation Routine
	move.w	#127,ZPOSITION(a0)	; Initialize Z Position
	clr.w	PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.w	#370-85,XPOSITION(a0)	; Set X Position
	move.w	#240-87,YPOSITION(a0)	; Set Y Position
	move.b	#1,STATIONARY(a0)	; Set As Stationary
Strike_1:
	rts

DspStrikeOut:		;What side to Blit?
	move.w	#284,NewBallX	;Strikes On Right
	tst.b	swing  	;Left or Right Hitter
	bne.s	StrikesRight	;Put strikes on right for righty
	move.w	#3,NewBallX	;Strikes On Left
StrikesRight:
	IMAGES	#Misc	; Load Image Bank
	move.w	NewBallX,d4	; 2 byte x value
	move.w	#144,d5	; Load Y Position
	APALETTE	#P_NEWSCORE	; Palette Number
	move.w	#strkeout,d3	; load Frame Number
	jsr	Blit	; Blit The Object

	cmp.b	#0,strike
	ble.s	NoStrikes	;This Blits the StrikeCount
	IMAGES	#Misc	; Load Image Bank
	move.w	NewBallX,d4	; 2 byte x value
	add.w	#45,d4	; Move Picture over
	move.w	#156,d5	; Load Y Position
	move.b	strike,d2	; move to d2
	ext.w	d2	; make it a word
	sub.w	d2,d5	; subtract from Y
	cmp.b	#2,strike
	bls.s	NoMoreSub
          	sub.w	#1,d5
NoMoreSub:
	APALETTE	#P_NEWSCORE	; Palette Number
	move.w	#newone-1,d3	; Frame Number
	add.b	strike,d3	; Add number of Strikes
	jsr	Blit	; Blit The Object

NoStrikes:			;This Blits the Out Count
	cmp.b	#0,outs
	ble.s	NoOuts	;This Blits the StrikeCount
	IMAGES	#Misc	; Load Image Bank
	move.w	NewBallX,d4	; 2 byte x value
	add.w	#45,d4	; Move Ball over
	move.w	#180,d5	; Load Y Position
	move.b	outs,d2	; move to d2 
	ext.w	d2	; make it a word
	sub.w	d2,d5	; subtract from Y
	APALETTE	#P_NEWSCORE	; Palette Number
	move.w	#newone-1,d3	; Reload Frame Number
	add.b	outs,d3	; Add Number Of Outs
	jsr	Blit	; Blit The Object
NoOuts:	
			;This Blits the StrikeCount
	rts

	.align	2

;***************************************************************************
;   PitcherTag - Diaplay Which player is pitching		*
;				*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
PitcherTag:
	jsr	AllocObject	; Allocate An Object
	beq.s	PTag_1	; Branch If None
	move.l	#DspPTag,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#127,ZPOSITION(a0)	; Initialize Z Position
	clr.w	PICTURE(a0)	; Set Base-O-Meter Picture
	move.l	#PitchTagAnim,PARSEPOINTER(a0)  ; Set Animation String
;	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.w	#198,XPOSITION(a0)	; Set X Position
	move.w	#130,YPOSITION(a0)	; Set Y Position
	move.b	#1,STATIONARY(a0)	; Set As Stationary
PTag_1
	rts
	.align	2

PitchTagAnim:
	LASTFRAME 190
	LASTFRAME 50
	LASTFRAME 190
	DEALLOC
	.align	2

DspPTag:			;What side to Blit?
	cmp.l	#PlayerL,AtPitPlayer	; Check If Left Player Fielder
	bne.s	Player2

	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_NEWSCORE	; Palette Number
	move.w	#176,d4	; 2 byte x value
	move.w	#40,d5	; Load Y Position
	move.w	#cpua0,d3	; load Frame Number
	tst.b	PlayerL+START
	beq.s	CPUA
	move.w	#arrowa0,d3	; load Frame Number
CPUA:
	jsr	Blit	; Blit The Object

	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_BATPT	; Palette Number
	move.w	#5,d4	; 2 byte x value
	move.w	#200,d5	; Load Y Position
;	move.w	#0x216,ZPOSITION(a0)	; Initialize Z Position
	move.w	#ptchicon,d3	; load Frame Number
	jsr	Blit	; Blit The Object
	rts

Player2:
	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_NEWSCORE	; Palette Number
	move.w	#176,d4	; 2 byte x value
	move.w	#40,d5	; Load Y Position
	move.w	#cpub0,d3	; load Frame Number
	tst.b	PlayerR+START
	beq.s	CPUB
	move.w	#arrowb0,d3	; load Frame Number
CPUB:
	jsr	Blit	; Blit The Object

	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_BATPT	; Palette Number
	move.w	#310,d4	; 2 byte x value
	move.w	#200,d5	; Load Y Position
;	move.w	#0x216,ZPOSITION(a0)	; Initialize Z Position
	move.w	#ptchicon,d3	; load Frame Number
	jsr	Blit	; Blit The Object


	rts




;***************************************************************************
;   BatterTag - Diaplay Which player is Batting		*
;				*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
BatterTag:
	jsr	AllocObject	; Allocate An Object
	beq.s	BTag_1	; Branch If None
	move.l	#DspBTag,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
;	clr.l	UPDATEPROC(a0)	; Clear Animation Routine
;	move.w	#256,ZPOSITION(a0)	; Initialize Z Position
	move.w	#0xFFFF,ZPOSITION(a0)	; Initialize Z Position
	clr.w	PICTURE(a0)	; Set Base-O-Meter Picture
	move.l	#BatTagAnim,PARSEPOINTER(a0)  ; Set Animation String
;	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.w	#198,XPOSITION(a0)	; Set X Position
;	move.w	XPOSITION(a5),XPOSITION(a0)	; Set X Position62
	move.w	XPOSITION(a5),d4	; Set X Position62
	move.w	#130,YPOSITION(a0)	; Set Y Position
	move.b	#1,STATIONARY(a0)	; Set As Stationary
BTag_1
	rts
	.align	2

BatTagAnim:
	LASTFRAME 190
	LASTFRAME 50
	LASTFRAME 190
	DEALLOC
	.align	2

DspBTag:			;What side to Blit?
	move.w	#83,d4	;Strikes On Right
	tst.b	swing  	;Left or Right Hitter
	bne.s	BatterRight	;Put strikes on right for righty
	move.w	#263,d4	;Strikes On Left
BatterRight:
	cmp.l	#PlayerL,AtBatPlayer	; Check If Left Player Fielder
	bne.s	Player2_2

	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_NEWSCORE	; Palette Number
;	move.w	#140,d4	; 2 byte x value
	move.w	#55,d5	; Load Y Position
	move.w	#cpua0,d3	; load Frame Number
	tst.b	PlayerL+START
	beq.s	CPUA_1
	move.w	#arrowa0,d3	; load Frame Number
CPUA_1:
	jsr	Blit	; Blit The Object

;	IMAGES	#Misc	; Load Image Bank
;	APALETTE	#P_BATPT	; Palette Number
;	move.w	#5,d4	; 2 byte x value
;	move.w	#210,d5	; Load Y Position
;	move.w	#216,ZPOSITION(a0)	; Initialize Z Position
;	move.w	#baticon,d3	; load Frame Number
;	jsr	Blit	; Blit The Object
	
	
	rts
Player2_2:
	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_NEWSCORE	; Palette Number
;	move.w	#140,d4	; 2 byte x value
	move.w	#55,d5	; Load Y Position
	move.w	#cpub0,d3	; load Frame Number
	tst.b	PlayerR+START
	beq.s	CPUB_2
	move.w	#arrowb0,d3	; load Frame Number
CPUB_2
	jsr	Blit	; Blit The Object

;	IMAGES	#Misc	; Load Image Bank
;	APALETTE	#P_BATPT	; Palette Number
;	move.w	#300,d4	; 2 byte x value
;	move.w	#210,d5	; Load Y Position
;	move.w	#216,ZPOSITION(a0)	; Initialize Z Position
;	move.w	#baticon,d3	; load Frame Number
;	jsr	Blit	; Blit The Object
       	rts

;***************************************************************************
;   HelpScreens - Display Help Screens		*
;				*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
FieldHelp:
	jsr	AllocObject	; Allocate An Object
	beq.s	FieldHelp_1	; Branch If None
	move.l	#DspHelp,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
;	clr.l	UPDATEPROC(a0)	; Clear Animation Routine
	move.w	#0xFFFF,ZPOSITION(a0)	; Initialize Z Position
	clr.w	PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#FieldHelpAnim,PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	#120,XPOSITION(a0)	; Set X Position
	move.w	#20,YPOSITION(a0)	; Set Y Position
	move.b	#1,STATIONARY(a0)	; Set As Stationary
FieldHelp_1:
	rts

	.align	2

FieldHelpAnim:
	LASTFRAME 1
	FRAMERATE 90	; 5 second delay
           LASTFRAME 4
	FRAMERATE 0
	DEALLOC
	.align	2


DspHelp:
;	IMAGES	#Initial	; Load Image Bank
;	move.w	#1,d4	; 2 byte x value
;	move.w	#1,d5	; Load Y Position
;	APALETTE	#P_BALL	; Palette Number
;	move.w	#fullmesh,d3	; load Frame Number
;	jsr	Blit	; Blit The Object

	IMAGES	#Misc	; Load Image Bank
	move.w	#105,d4	; 2 byte x value
	move.w	#2,d5	; Load Y Position
	APALETTE	#P_GREEN	; Palette Number
	move.w	#carda,d3	; load Frame Number
	jsr	Blit	; Blit The Object

	IMAGES	#Misc	; Load Image Bank
	move.w	#125,d4	; 2 byte x value
	move.w	#22,d5	; Load Y Position
	APALETTE	#P_BALL	; Palette Number
	move.w	#help01,d3	; load Frame Number
	tst.w	HelpSwitch
	beq.s	BlitFieldH
	move.w	#help05,d3	; load Frame Number
BlitFieldH:
	jsr	Blit	; Blit The Object

	rts

	.align	2



RunnerHelp:
	jsr	AllocObject	; Allocate An Object
	beq.s	RunnerHelp_1	; Branch If None
	move.l	#DspHelpR,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#0xFFFF,ZPOSITION(a0)	; Initialize Z Position
	clr.w	PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#RunnerHelpAnim,PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	#120,XPOSITION(a0)	; Set X Position
	move.w	#20,YPOSITION(a0)	; Set Y Position
	move.b	#1,STATIONARY(a0)	; Set As Stationary
RunnerHelp_1:
	rts

	.align	2

RunnerHelpAnim:
	LASTFRAME 1
	FRAMERATE 90	; 5 second delay
           LASTFRAME 4
	FRAMERATE 0
	DEALLOC
	.align	2


DspHelpR:
;	IMAGES	#Initial	; Load Image Bank
;	move.w	#1,d4	; 2 byte x value
;	move.w	#1,d5	; Load Y Position
;	APALETTE	#P_BALL	; Palette Number
;	move.w	#fullmesh,d3	; load Frame Number
;	jsr	Blit	; Blit The Object

	IMAGES	#Misc	; Load Image Bank
	move.w	#185,d4	; 2 byte x value
	move.w	#115,d5	; Load Y Position
	APALETTE	#P_GREEN	; Palette Number
	move.w	#carda,d3	; load Frame Number
	jsr	Blit	; Blit The Object

	IMAGES	#Misc	; Load Image Bank
	move.w	#205,d4	; 2 byte x value
	move.w	#125,d5	; Load Y Position
	APALETTE	#P_BALL	; Palette Number
	move.w	#help02,d3	; load Frame Number
	tst.w	HelpSwitch
	beq.s	BlitRunH
	move.w	#help06,d3	; load Frame Number
BlitRunH:
	jsr	Blit	; Blit The Object

	rts

	.align	2


BatterHelp:
	jsr	AllocObject	; Allocate An Object
	beq.s	BatterHelp_1	; Branch If None
	move.l	#DspBatHelp,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#0xFFFF,ZPOSITION(a0)	; Initialize Z Position
	clr.w	PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#BatterHelpAnim,PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	#100,XPOSITION(a0)	; Set X Position
	move.w	#125,YPOSITION(a0)	; Set Y Position
	move.b	#1,STATIONARY(a0)	; Set As Stationary
BatterHelp_1:
	rts

	.align	2

BatterHelpAnim:
	LASTFRAME 1
	FRAMERATE 90	; 5 second delay
           LASTFRAME 4
	FRAMERATE 0
	DEALLOC
	.align	2


DspBatHelp:

;	IMAGES	#Initial	; Load Image Bank
;	move.w	#1,d4	; 2 byte x value
;	move.w	#1,d5	; Load Y Position
;	APALETTE	#P_BALL	; Palette Number
;	move.w	#fullmesh,d3	; load Frame Number
;	jsr	Blit	; Blit The Object


	IMAGES	#Misc	; Load Image Bank
	move.w	#105,d4	; 2 byte x value
	move.w	#125,d5	; Load Y Position
	APALETTE	#P_GREEN	; Palette Number
	move.w	#carda,d3	; load Frame Number
	jsr	Blit	; Blit The Object

	IMAGES	#Misc	; Load Image Bank
	move.w	#125,d4	; 2 byte x value
	move.w	#125,d5	; Load Y Position
	APALETTE	#P_BALL	; Palette Number
	move.w	#help03,d3	; load Frame Number
	jsr	Blit	; Blit The Object

	rts

	.align	2


PitcherHelp:
	jsr	AllocObject	; Allocate An Object
	beq.s	PitcherHelp_1	; Branch If None
	move.l	#DspPitHelp,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#0xFFFF,ZPOSITION(a0)	; Initialize Z Position
	clr.w	PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#PitcherHelpAnim,PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	#100,XPOSITION(a0)	; Set X Position
	move.w	#125,YPOSITION(a0)	; Set Y Position
	move.b	#1,STATIONARY(a0)	; Set As Stationary
PitcherHelp_1:
	rts

	.align	2

PitcherHelpAnim:
	LASTFRAME 1
	FRAMERATE 90	; 5 second delay
           LASTFRAME 4
	FRAMERATE 0
	DEALLOC
	.align	2


DspPitHelp:

;	IMAGES	#Initial	; Load Image Bank
;	move.w	#1,d4	; 2 byte x value
;	move.w	#1,d5	; Load Y Position
;	APALETTE	#P_BALL	; Palette Number
;	move.w	#fullmesh,d3	; load Frame Number
;	jsr	Blit	; Blit The Object

	IMAGES	#Misc	; Load Image Bank
	move.w	#105,d4	; 2 byte x value
	move.w	#2,d5	; Load Y Position
	APALETTE	#P_GREEN	; Palette Number
	move.w	#carda,d3	; load Frame Number
	jsr	Blit	; Blit The Object

	IMAGES	#Misc	; Load Image Bank
	move.w	#125,d4	; 2 byte x value
	move.w	#2,d5	; Load Y Position
	APALETTE	#P_BALL	; Palette Number
	move.w	#help04,d3	; load Frame Number
	jsr	Blit	; Blit The Object

	rts

BigMesh:
	jsr	AllocObject	; Allocate An Object
	beq.s	Mesh_1	; Branch If None
	move.l	#BigMesh1,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#0xFFFE,ZPOSITION(a0)	; Initialize Z Position
	clr.w	PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#MeshAnim,PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	#120,XPOSITION(a0)	; Set X Position
	move.w	#20,YPOSITION(a0)	; Set Y Position
	move.b	#1,STATIONARY(a0)	; Set As Stationary
Mesh_1:
	rts

	.align	2

MeshAnim:
	LASTFRAME 1
	FRAMERATE 90	; 5 second delay
           LASTFRAME 4
	FRAMERATE 0
	DEALLOC
	.align	2


BigMesh1:
	IMAGES	#Initial	; Load Image Bank
	move.w	#1,d4	; 2 byte x value
	move.w	#1,d5	; Load Y Position
	APALETTE	#P_BALL	; Palette Number
 ;	move.w	#fullmesh,d3	; load Frame Number
	move.w	#help04,d3	; load Frame Number
	jsr	Blit	; Blit The Object
	rts

	.align	2



;***************************************************************************
;   HelpHalf - Display Help mesages on Half Inning		*
;				*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
HelpHalf:
	jsr	AllocObject	; Allocate An Object
	beq.s	HelpH_1	; Branch If None
	move.l	#HelpDisplay,DISPLAYPROC(a0) ; Store Address Of Display Procedure
;	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	clr.l	UPDATEPROC(a0)	; Set Animation Routine
	move.w	#0xFFFF,ZPOSITION(a0)	; Initialize Z Position
	clr.w	PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
;	move.l	#HalfHelpAnim,PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	#120,XPOSITION(a0)	; Set X Position
	move.w	#20,YPOSITION(a0)	; Set Y Position
	move.b	#1,STATIONARY(a0)	; Set As Stationary
	add.w	#1,HelpCounter

HelpH_1:
	rts

	.align	2
HalfHelpAnim:
           LASTFRAME 90
           LASTFRAME 90
           LASTFRAME 90
           LASTFRAME 90
           LASTFRAME 90
	DEALLOC
	.align	2


HelpDisplay:		;What side to Blit?

	move.w	#195,HelpX	;Strikes On Right
	move.l	SinglePlayer,d0	;move single player address to d0
	cmp.l	#PlayerL,d0	;is player batting 
	beq.s	OnRight
	move.w	#3,HelpX	;Strikes On Left
OnRight:

	IMAGES	#Misc	; Load Image Bank
	move.w	HelpX,d4	; 2 byte x value
	sub.w	#5,d4
	move.w	#133,d5	; Load Y Position
	APALETTE	#P_GREEN	; Palette Number
	move.w	#carda,d3	; load Frame Number
	jsr	Blit	; Blit The Object

	IMAGES	#Misc	; Load Image Bank
	move.w	HelpX,d4	; 2 byte x value
	move.w	#138,d5	; Load Y Position
	APALETTE	#P_BALL	; Palette Number
	move.w	#help04,d3	; load Frame Number
	add.w	HelpCounter,d3
	cmp.w	#5,HelpCounter
	ble.s	NotYet
       	clr.w	HelpCounter
NotYet:
	jsr	Blit	; Blit The Object

	rts

;***************************************************************************
;   NotEnough - Tells player not enough power		*
;				*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
NotEnough:
	jsr	AllocObject	; Allocate An Object
	beq.s	Not_1	; Branch If None
	move.l	#NotE,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
;	clr.l	UPDATEPROC(a0)	; Clear Animation Routine
	move.w	#0xFFFF,ZPOSITION(a0)	; Initialize Z Position
	clr.w	PICTURE(a0)	; Set Base-O-Meter Picture
	move.l	#NotAnim,PARSEPOINTER(a0)  ; Set Animation String
;	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.w	#198,XPOSITION(a0)	; Set X Position
	move.w	#130,YPOSITION(a0)	; Set Y Position
	move.b	#1,STATIONARY(a0)	; Set As Stationary
	SOUND	#S_NotEnoughPower,#0	; Set Volume
Not_1
	rts
	.align	2

NotAnim:
	LASTFRAME 60
	DEALLOC
	.align	2

NotE:			;What side to Blit?
	cmp.l	#PlayerL,AtBatPlayer	; Check If Left Player Fielder
	bne.s	NotLeftP

	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_NEWSCORE	; Palette Number
	move.w	#30,d4	; 2 byte x value
	move.w	#225,d5	; Load Y Position
	move.w	#notenuff,d3	; load Frame Number
	jsr	Blit	; Blit The Object
	rts
NotLeftP:
	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_NEWSCORE	; Palette Number
	move.w	#230,d4	; 2 byte x value
	move.w	#225,d5	; Load Y Position
	move.w	#notenuff,d3	; load Frame Number
	jsr	Blit	; Blit The Object
	rts




;***************************************************************************
;   NotEnoughP - Tells player not enough power		*
;				*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
NotEnoughP:
	jsr	AllocObject	; Allocate An Object
	beq.s	NotP_1	; Branch If None
	move.l	#NotEP,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
;	clr.l	UPDATEPROC(a0)	; Clear Animation Routine
	move.w	#0xFFFF,ZPOSITION(a0)	; Initialize Z Position
	clr.w	PICTURE(a0)	; Set Base-O-Meter Picture
	move.l	#NotPAnim,PARSEPOINTER(a0)  ; Set Animation String
;	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.w	#198,XPOSITION(a0)	; Set X Position
	move.w	#130,YPOSITION(a0)	; Set Y Position
	move.b	#1,STATIONARY(a0)	; Set As Stationary
	SOUND	#S_NotEnoughPower,#0	; Set Volume
NotP_1
	rts
	.align	2

NotPAnim:
	LASTFRAME 60
	DEALLOC
	.align	2

NotEP:			;What side to Blit?
	cmp.l	#PlayerL,AtPitPlayer	; Check If Left Player Fielder
	bne.s	NotLeftPP

	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_NEWSCORE	; Palette Number
	move.w	#30,d4	; 2 byte x value
	move.w	#225,d5	; Load Y Position
	move.w	#notenuff,d3	; load Frame Number
	jsr	Blit	; Blit The Object
	rts
NotLeftPP:
	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_NEWSCORE	; Palette Number
	move.w	#230,d4	; 2 byte x value
	move.w	#225,d5	; Load Y Position
	move.w	#notenuff,d3	; load Frame Number
	jsr	Blit	; Blit The Object
	rts

	.align	2

;FieldHelpAnim:
;	LASTFRAME 1
;	FRAMERATE 90	; 5 second delay
;           LASTFRAME 4
;	FRAMERATE 0
;	DEALLOC

	.export	PowerFrame,PowerBar_1,PowerBar_2

;***************************************************************************
;   PowerFrame - Display Power Frame With Black Background	*
;				*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
PowerFrame:
	jsr	AllocObject	; Allocate An Object
	beq.s	Power_1	; Branch If None
	move.l	#PowerMeter1,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	clr.l	UPDATEPROC(a0)	; Clear Animation Routine
	move.w	#125,ZPOSITION(a0)	; Initialize Z Position
	clr.w	PICTURE(a0)	; Clear Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.w	#370-85,XPOSITION(a0)	; Set X Position
	move.w	#240-87,YPOSITION(a0)	; Set Y Position
	move.b	#1,STATIONARY(a0)	; Set As Stationary
Power_1:
	jsr	PowerFrameB	;Call On Top Frame (3 part)
	rts

	.export	PowerPtr,PowerPtr2	

	;Left player Frame			
PowerMeter1:		; Actual Frame Images to display 
	IMAGES	#Misc	; Load Image Bank
	move.w	#0,d4	; Load X Position
	move.w	#233,d5	; Load Y Position
	APALETTE	#P_NEWSCORE	; Meter Palette
	move.w	#powerupa,d3	; Reload Frame Number

;	tst.b	PlayerL+START
;	bne.s	NOOPP_1
;	move.w	ProcessTime,d0
;	and.w	#32,d0
;	beq.s	NOOPP_1	;blink it
;	move.w	#oppa,d3	; load Frame Number
;NOOPP_1:
	jsr	Blit	; Blit The Object


	;Right player Frame			
	IMAGES	#Misc	; Load Image Bank
	move.w	#231,d4	; Load X Position
	move.w	#238,d5	; Load Y Position
	APALETTE	#P_NEWSCORE	; Meter Palette
	move.w	#powerupb,d3	; Reload Frame Number
;	tst.b	PlayerR+START
;	bne.s	NOOPP_2
;	move.w	ProcessTime,d0
;	and.w	#32,d0
;	beq.s	NOOPP_2	;blink it
;	move.w	#oppb,d3	; load Frame Number
;NOOPP_2:
	jsr	Blit	; Blit The Object

	rts
	.align	2

;***************************************************************************
;   PowerFrameB - Display Power Frame With 3 Sections on top of bar and 	*
;	       the meterfrm.		*	
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
PowerFrameB:
	jsr	AllocObject	; Allocate An Object
	beq.s	Power_B	; Branch If None
	move.l	#PowerMeterB,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	clr.l	UPDATEPROC(a0)	; Clear Animation Routine
	move.w	#128,ZPOSITION(a0)	; Initialize Z Position
	clr.w	PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
;	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	#370-85,XPOSITION(a0)	; Set X Position
	move.w	#240-87,YPOSITION(a0)	; Set Y Position
	move.b	#1,STATIONARY(a0)	; Set As Stationary
Power_B:
	rts
PowerMeterB:
	;Left Player Part
	tst.b	PlayerL+START
	bne.s	NOOPP_1

	IMAGES	#Misc	; Load Image Bank
	move.w	#0,d4	; Load X Position
	move.w	#233,d5	; Load Y Position
	APALETTE	#P_NEWSCORE
;	move.w	#powerupa,d3	; Reload Frame Number

	move.w	ProcessTime,d0
	and.w	#64,d0
	beq.s	NOOPP_1	;blink it
	move.w	#oppa,d3	; load Frame Number
	jsr	Blit	; Blit The Object
	
NOOPP_1:


;Right Player Part
	tst.b	PlayerR+START
	bne.s	NOOPP_2

	IMAGES	#Misc	; Load Image Bank
	move.w	#231,d4	; Load X Position
	move.w	#238,d5	; Load Y Position
	APALETTE	#P_NEWSCORE
;	move.w	#powerupb,d3	; Reload Frame Number

	move.w	ProcessTime,d0
	and.w	#64,d0
	beq.s	NOOPP_2	;blink it
	move.w	#oppb,d3	; load Frame Number
	jsr	Blit	; Blit The Object

NOOPP_2:
	rts

;***************************************************************************
;   PowerBar_1 - This displays the actual Left PowerBar sandwiched beteween*
;	      the above two frame pictures (meterfrm,metertrb)	*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************

PowerBar_1:
	jsr	AllocObject	; Allocate An Object
	beq.s	Power_2	; Branch If None
     	move.w	#60,XCLIP1(a0)       	;Clip Coordinates
	move.w	PlayerL+TOTALPOWER,d0    ;Clip Coordinates
	lsr.w	#8,d0
	move.w	d0,XCLIP2(a0)
	add.w	#60,XCLIP2(a0)
	move.w	#244,YCLIP1(a0)	;Clip Coordinates
	move.w	#264,YCLIP2(a0)	;Clip Coordinates
	move.l	#BlitClipObj,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#CheckPowerUp,UPDATEPROC(a0) ; Clear Animation Routine
	move.w	#127,ZPOSITION(a0)	; Initialize Z Position
	move.w	#metergrn,PICTURE(a0)	; Set Field Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	#60,XPOSITION(a0)	; Set X Position
	move.w	#246,YPOSITION(a0)	; Set Y Position
	move.b	#Initial,BANK(a0)	; Set Bank Number
           move.l    a0,PowerPtr
Power_2:
	rts
	.align	2


	.align	2
;***************************************************************************
;   PowerBar_2 - This displays the actual Right PowerBar sandwiched beteween*
;	      the above two frame pictures (meterfrm,metertrb)	*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************

PowerBar_2:
	jsr	AllocObject	; Allocate An Object
	beq.s	Power_3	; Branch If None
	move.w	#291,XCLIP1(a0)	;Clip Coordinates
	move.w	PlayerR+TOTALPOWER,d0
	lsr.w	#8,d0
	move.w	d0,XCLIP2(a0)
    	add.w	#291,XCLIP2(a0)
	move.w	#244,YCLIP1(a0)	;Clip Coordinates
	move.w	#264,YCLIP2(a0)	;Clip Coordinates
	move.l	#BlitClipObj,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#CheckPowerUp2,UPDATEPROC(a0) ; Clear Animation Routine
	move.w	#127,ZPOSITION(a0)	; Initialize Z Position
	move.w	#metergrn,PICTURE(a0)	; Set Field Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	#291,XPOSITION(a0)	; Set X Position
	move.w	#246,YPOSITION(a0)	; Set Y Position
	move.b	#Initial,BANK(a0)	; Set Bank Number
           move.l    a0,PowerPtr2
Power_3:
	rts
	.align	2


ZoneObj:   ;This is the NEW StrikeZone
	jsr	AllocObject	; Allocate An Object
	beq	Zone_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
;	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#METERZ,ZPOSITION(a0)	; Initialize Z Position
	move.w	#zone1a,PICTURE(a0)	; Set Zone1 Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	#192-35,XPOSITION(a0)	; Set X Position62
	move.w	#105,YPOSITION(a0)	; Set Y Position 90
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
	move.l	a0,ZoneObjPtr
Zone_1:
	rts
	
Zone3Obj:
	jsr	AllocObject	; Allocate An Object
	beq.s	Zone_3	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
;	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#METERZ,ZPOSITION(a0)	; Initialize Z Position
	move.w	#zone3a,PICTURE(a0)	; Set Zone3 Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	#192-32,XPOSITION(a0)	; Set X Position62
	move.w	#119,YPOSITION(a0)	; Set Y Position 119-14
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
	move.l	a0,ZonePtr	; Store Zone Pointer

Zone_3:
	rts

DirtObj:   ;this is the flying dirt .
	jsr	AllocObject	; Allocate An Object
	beq.s	NoDirt	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
           move.w	#66,ZPOSITION(a0)	; Initialize Z Position
	move.w	#dirt0001,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#DirtAnim,PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_TESTF,PALETTE(a0)	; Set Palette Number
;	move.w	#48,XPOSITION(a0)	; Set X Position62
	move.w	XPOSITION(a5),XPOSITION(a0)	; Set X Position62
 	sub.w	#47,XPOSITION(a0)
	move.w	#223,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
;	move.b	#1,STATIONARY(a0)	; Set As Stationary
           move.l    a0,DirtPtr
NoDirt:
	rts
	.align	2
DirtAnim:
	SPRITE	dirt0001,20
	SPRITE	dirt0002,20
	SPRITE	dirt0003,70
	LASTFRAME 200
	DEALLOC
	rts
	.align	2

RockObj:   ;this is the rocks.
;	jsr	ROCKVEL
;	move.w	#0,XCLIP1(a5)
;	move.w	#300,XCLIP2(a5)
;	move.w	#247,YCLIP2(a5)
;	move.w	#200,YCLIP1(a5)
	jsr	AllocObject	; Allocate An Object
	beq.s	NoRock	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
           move.w	#65,ZPOSITION(a0)	; Initialize Z Position
;	move.w	#rock0005,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#RockAnim,PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_TESTF,PALETTE(a0)	; Set Palette Number
;	move.w	#95,XPOSITION(a0)	; Set X Position62
	move.w	XPOSITION(a5),XPOSITION(a0)	; Set X Position62
	move.w	#216,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
;	move.b	#1,STATIONARY(a0)	; Set As Stationary
           move.l    a0,RockPtr
NoRock:
	rts
	.align	2
RockAnim:
    	SETRANVEL    0x0,0x620,1
	LASTFRAME 100
  ;   	SPRITE	rock0001,20
  ;	SPRITE	rock0002,20
  ;	SPRITE	rock0003,70
  ;	SPRITE	rock0004,70
  ;	SPRITE	rock0005,70
;     	SPRITE	rock0006,20
;	SPRITE	rock0007,20
;	SPRITE	rock0008,70
;	SPRITE	rock0009,70
;	SPRITE	rock0010,70
           LASTFRAME 130
     	DEALLOC

	.align	2
WallLaser:   ;this is the flying dirt .
	tst.b	LaserHit
	bne.s	YesLaser
         	tst.b	PowerBallPal
	bne.s	YesLaser
         	tst.b	VintageHit
	beq.s	NoWallLaser
YesLaser:
	jsr	AllocObject	; Allocate An Object
	beq.s	NoWallLaser	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
           move.w	#0xFFFF,ZPOSITION(a0)	; Initialize Z Position
	move.w	#spka0001,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#WallLAnim,PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_FIREWORKS2,PALETTE(a0)	; Set Palette Number
;NotLaserHit:
	move.l	#Baseball,a6	; Load Address Of Ball
	move.w	XPOSITION(a6),XPOSITION(a0)	; Set X Position
	move.w	BallY,YPOSITION(a0)	; Set Y Position
 	sub.w	#5,XPOSITION(a0)
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
NoWallLaser:
	rts

WallLAnim:
	SOUNDS WallSpark
	SPRITE spke0001,1
	SPRITE spke0002,1
	SPRITE spke0003,1
	SPRITE spke0004,1
	SPRITE spke0005,1
	SPRITE spke0006,1
	SPRITE spke0007,1
	SPRITE spke0008,1
	SPRITE spke0009,1
	SPRITE spke0010,1
	SPRITE spke0011,1
	DEALLOC
	rts

TestClipObj:   ;this is the word 'third' under on the third base view.
	jsr	AllocObject	; Allocate An Object
	beq.s	No_Test	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
;	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#65,ZPOSITION(a0)	; Initialize Z Position
	move.w	#testclip,PICTURE(a0)	; Set Base-O-Meter Picture  third
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_TESTF,PALETTE(a0)	; Set Palette Number   P_FIRST
;	move.w	#370-85,XPOSITION(a0)	; Set X Position
;	move.w	#240-87,YPOSITION(a0)	; Set Y Position
	move.w	#0,XPOSITION(a0)	; Set X Position
	move.w	#238,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
No_Test:
	rts


	.global ScoreObj,SetFontm
ScoreObj:   ;this is the scoreboard.
	jsr	AllocObject	; Allocate An Object
	beq	NoScore	; Branch If None
	move.l	#DScore,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#0xffff,ZPOSITION(a0)	; Initialize Z Position
	move.w	#newscore,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.l	#ScoreAnim,PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
;	move.w	#30,XPOSITION(a0)	; Set X Position62
	move.w	#65,XPOSITION(a0)	; Set X Position62
	move.w	#-87,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
;	move.b	#1,STATIONARY(a0)	; Set As Stationary
           move.l    a0,ScorePtr
	jsr	SetExtra
NoScore:
	rts

SetExtra
;calc offset into scores if more than 9
	move.l	#-1,d1
	lea	([AwayPlayer],INNINGSSCORE),a1
.MoreScores			;count innings with score
	add.l	#1,d1
	tst.b	(a1)+
	bpl.s	.MoreScores
	clr.l	extrainnings
	sub.l	#9,d1
	bmi.s	.noextra
	beq.s	.noextra
	move.l	d1,extrainnings
.noextra
	rts

ScoreAnim
           SETVEL    0,-0x220,-1
;           LASTFRAME 45
.down
            LASTFRAME 1
	CMPWI	YPOSITION,-6
	JUMPLT	.down
           SETVEL    0,0,-1

           LASTFRAME 38	;down duration


 .if debugmode=="obe"
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
;	LASTFRAME	255
 .endif


           SETVEL	0,0x220,-1      ;0x40,-0x180,-1
           LASTFRAME 100 	;45

;	JUMP	ScoreAnim

	DEALLOC


	.align	2
	.export	DScore,SetExtra
DScore
;blit score board
	jsr	BlitObject

;	IMAGES	#Misc	; Load Image Bank
;	APALETTE	#P_BALL
;	move.w	XPOSITION(a5),d0
;	add.w	#59,d0
;	move.w	YPOSITION(a5),d1
;	add.w	#37,d1
;	BLIT	#scoreb,d0,d1	;mesh

;blit team names
	IMAGES	#Initial
	APALETTE	#P_BALL
	move.w	([AwayPlayer],TEAMNUMBER),d0 	;team number


	cmp.w	#draftteam,d0
;	bne.s	.nodraft1	;branch if not a draft team
	blt.s	.nodraft1	;branch if not a draft team
;print draft team initials
	move.w	XPOSITION(A5),d1
	move.w	YPOSITION(A5),d2
	add.w	#14+15,d1	;x offset from board
	add.w	#44+2,d2	;y offset
	PLOT	d1,d2
	jsr	SetFontm
;	clr.l	FontSpacing	; Non-Proportional Spacing
	lea.l	([AwayPlayer],letters),a0
	clr.w	d6
	move.w	#3,d7	;print 3 letters
	jsr	Print
	bra	.Anamedone
.nodraft1


	add.w	#citybra,d0	;first city name
	move.w	XPOSITION(A5),d1
	move.w	YPOSITION(A5),d2
	add.w	#14,d1	;x offset from board
	add.w	#44,d2	;y offset
	BLIT	d0,d1,d2
.Anamedone
	move.w	([HomePlayer],TEAMNUMBER),d0 	;team number

	cmp.w	#draftteam,d0
;	bne.s	.nodraft2	;branch if not a draft team
	blt.s	.nodraft2	;branch if not a draft team
;print draft team initials
	move.w	XPOSITION(A5),d1
	move.w	YPOSITION(A5),d2
	add.w	#14+15,d1	;x offset from board
	add.w	#77+2,d2	;y offset
	PLOT	d1,d2
	jsr	SetFontm
;	clr.l	FontSpacing	; Non-Proportional Spacing
	lea.l	([HomePlayer],letters),a0
	clr.w	d6
	move.w	#3,d7	;print 3 letters
	jsr	Print
	bra	.Hnamedone
.nodraft2

	add.w	#citybra,d0	;first city name
	move.w	XPOSITION(A5),d1
	move.w	YPOSITION(A5),d2
	add.w	#14,d1	;x offset from board  was 11
	add.w	#77,d2	;y offset
	BLIT	d0,d1,d2
.Hnamedone
;blit innings label
	jsr	SetFontm
	clr.l	FontSpacing	; Non-Proportional Spacing

	APALETTE	#P_BALL	; Use Font Palette
	move.w	XPOSITION(A5),d0
	move.w	YPOSITION(A5),d1
	add.w	#89,d0	;x offset from board
	move.w	d0,scorex
	add.w	#18,d1	;y offset
	PLOT	d0,d1

;	clr.l	extrainnings
	move.w	#1,d1	;first inning number
;
;	clr.l	d0
;
;	move.b	Inning,d0
;	lsr.b	#1,d0	;convert inning halves to whole
;	add.b	#1,d0	;make 1 based
;
;	sub.b	#9,d0
;	bmi.s	noextra
;	move.l	d0,extrainnings	;to access scores later
	add.l	extrainnings,d1
;noextra
	move.b	d1,temp+1	;first inning number
	move.b	#9,temp	;number of innings to print
innlab
	move.w	scorex,prx_coor

	APALETTE	#P_BALL	;white
;color coding?
	move.b	Inning,d0
	lsr.b	#1,d0
	add.b	#1,d0	;1 based
	cmp.b	temp+1,d0
	bne.s	.notyellow
	APALETTE	#P_NEWSCORE	;yellow
.notyellow

	PRINTDECB temp+1,#2,JLEFT
	add.w	#19,scorex	;x spacing
	add.b	#1,temp+1
	sub.b	#1,temp
	bne.s	innlab

	move.w	XPOSITION(A5),d1
	add.w	#RHEx+3,d1
	move.w	d1,prx_coor
	PRINT	"R"
	move.w	XPOSITION(A5),d1
	add.w	#RHEx+19+3,d1
	move.w	d1,prx_coor
	PRINT	"H"
	move.w	XPOSITION(A5),d1
	add.w	#RHEx+19+19+3,d1
	move.w	d1,prx_coor
	PRINT	"E"

;blit scores
	jsr	SetFontm
;	SETPRINT	#13,#12,#fnt1,#0
;	clr.l	FontAdjust
	clr.l	FontSpacing	; Non-Proportional Spacing
;;	move.l	#fnt1Spacing,FontSpacing
;	move.l	#F5CharTrans,CharTrans	; character translation table

	APALETTE	#P_BALL	; Use Font Palette
	move.w	XPOSITION(A5),d0
	move.w	YPOSITION(A5),d1
	add.w	#84,d0	;x offset from board
	PUSHW	d0
	move.w	d0,scorex
	add.w	#48,d1	;y offset
	PLOT	d0,d1
	move.l	AwayPlayer,d0
	move.l	d0,whichteam	;for score_across color coding
	add.l	extrainnings,d0	;slide scores over
	move.l	d0,a6
	jsr	score_across
	add.w	#33,pry_coor	;y score spacing
	POPW	d0
	move.w	d0,scorex
	move.l	HomePlayer,d0
	move.l	d0,whichteam	;for score_across color coding
	add.l	extrainnings,d0	;slide scores over
	move.l	d0,a6
	jsr	score_across

;blit runs hits errors
RHEx	equ	264
	move.w	XPOSITION(A5),d0
	move.w	YPOSITION(A5),d1
	add.w	#RHEx,d0	;x offset from board
	add.w	#48,d1	;y offset
	PLOT	d0,d1
	move.l	AwayPlayer,a0	; Load Address Of Away Player
	APALETTE	#P_NEWSCORE	;yellow
	PRINTDECB RUNS(a0),#2,JRGT	; Display Runs
	APALETTE	#P_BALL	;white

	move.w	XPOSITION(A5),d0
	add.w	#RHEx+19,d0	;x offset from board
	move.w	d0,prx_coor
	move.l	AwayPlayer,a0	; Load Address Of Away Player
	PRINTDECB HITS(a0),#2,JRGT	; Display Hits

	move.w	XPOSITION(A5),d0
	add.w	#RHEx+19+19,d0	;x offset from board
	move.w	d0,prx_coor
	move.l	AwayPlayer,a0	; Load Address Of Away Player
	PRINTDECB ERRORS(a0),#2,JRGT	; Display Errors


	move.w	XPOSITION(A5),d0
	move.w	YPOSITION(A5),d1
	add.w	#RHEx,d0	;x offset from board
	add.w	#81,d1	;y offset
	PLOT	d0,d1
	move.l	HomePlayer,a0	; Load Address Of Home Player
	APALETTE	#P_NEWSCORE	;yellow
	PRINTDECB RUNS(a0),#2,JRGT
	APALETTE	#P_BALL	;white

	move.w	XPOSITION(A5),d0
	add.w	#RHEx+19,d0	;x offset from board
	move.w	d0,prx_coor
	move.l	HomePlayer,a0	; Load Address Of Home Player
	PRINTDECB HITS(a0),#2,JRGT	; Display Hits

	move.w	XPOSITION(A5),d0
	add.w	#RHEx+19+19,d0	;x offset from board
	move.w	d0,prx_coor
	move.l	HomePlayer,a0	; Load Address Of Home Player
	PRINTDECB ERRORS(a0),#2,JRGT	; Display Errors

;player ID's
	IMAGES	#Misc
	move.w	XPOSITION(A5),d1
	move.w	YPOSITION(A5),d2
	sub.w	#5,d1	;x offset from board
	add.w	#38,d2	;y offset
	APALETTE	#P_NEWSCORE

	cmp.l	#PlayerL,AwayPlayer
	beq.s	.LeftA
	move.w	#arrowb4,AwayID
	tst.b	PlayerR+COMPUTER
	beq.s	.AID
	move.w	#cpub4,AwayID
	bra.s	.AID
.LeftA
	move.w	#arrowa4,AwayID
	tst.b	PlayerL+COMPUTER
	beq.s	.AID
	move.w	#cpua4,AwayID

.AID	BLIT	AwayID,d1,d2

	move.w	XPOSITION(A5),d1
	move.w	YPOSITION(A5),d2
	sub.w	#5,d1	;x offset from board
	add.w	#71,d2	;y offset

	cmp.l	#PlayerL,HomePlayer
	beq.s	.LeftAh
	move.w	#arrowb4,HomeID
	tst.b	PlayerR+COMPUTER
	beq.s	.AIDh
	move.w	#cpub4,HomeID
	bra.s	.AIDh
.LeftAh
	move.w	#arrowa4,HomeID
	tst.b	PlayerL+COMPUTER
	beq.s	.AIDh
	move.w	#cpua4,HomeID

.AIDh	BLIT	HomeID,d1,d2


	rts

score_across
.tstlp	tst.b	INNINGSSCORE(a6)
	bpl.s	.xlp	;branch if inning played
	rts
.xlp
	move.w	scorex,prx_coor
	move.l	whichteam,d0
	cmp.l	AtBatPlayer,d0	;if at bat
	bne.s	.notyellow
	tst.b	INNINGSSCORE+1(a6)	;and last score
	bpl.s	.notyellow
	APALETTE	#P_NEWSCORE	;yellow
.notyellow	PRINTDECB INNINGSSCORE(a6),#2,JRGT
	lea	1(a6),a6	;next inning
	add.w	#19,scorex	;x spacing
	APALETTE	#P_BALL	;back to white
	bra.s	.tstlp

;.............................................................................
	.export	PitchBall
PitchBall:
;	move.b	#22,([AtBatPlayer],POWERNUM) ; FORCE Grab And Throw

	clr.b	GhostCount	; Clear Ghost Counter
	clr.b	Ghosting	; Clear Ghosting Flag
	clr.b	SwingFlag	; Cleaar Swing Flag
	clr.l	BiasTable	; Clear X,Z Bias Table
	clr.b	KnuckleBall	; Not A Knuckle Ball yet
	move.l	#Baseball,a0	; Load Address Of Ball
   	move.l	#ShowBall,DISPLAYPROC(a0)	; Store Address Of Display Procedure
   	move.l	#Anim,UPDATEPROC(a0)        ; Set Animation Routine
   	move.l	#BallAnim,PARSEPOINTER(a0)  ; Set Animation String
	clr.b	OBJECTTYPE(a0)	; Not A Player Object
   	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Don't Let Anim Move The Ball

	move.l	BallCordX,WORLDX(a0)	; Set Initial Y Position
	move.l	BallCordY,WORLDY(a0)	; Set Initial X Position
	move.l	BallCordZ,WORLDZ(a0)	; Set Initial Z Position
;bri	move.w	#0x7FFF,ZPOSITION(a0)	; Display Ball On Top
	move.w	#0x7F00,ZPOSITION(a0)	; Display Ball On Top

	move.l	#-AFTERPLATE,AfterPlate	; Set Distance Behind Plate To Check

;	move.l	CONTROLBLOCK(a5),d0	; Load Address Of Control Block
;	cmp.l	#PlayerL,d0	; Check If Left Player
;	beq.s	PitchBall_1	; Branch If Left
;	clr.l	PlayerR+INPUTROUTINE
;	SWITCH	#FIRSTBASE2,#0x81,#BallRight
;	SWITCH	#THIRDBASE2,#0x81,#BallLeft
;	SWITCH	#SECONDBASE2,#0x81,#BallUp
;	SWITCH	#HOMEPLATE2,#0x81,#BallDown
;	bra.s	PitchBall_9
;PitchBall_1:
;	clr.l	PlayerL+INPUTROUTINE
;	SWITCH	#FIRSTBASE1,#0x81,#BallRight
;	SWITCH	#THIRDBASE1,#0x81,#BallLeft
;	SWITCH	#SECONDBASE1,#0x81,#BallUp
;	SWITCH	#HOMEPLATE1,#0x81,#BallDown
PitchBall_9:
	rts


;BallRight:
;	move.l	#Baseball,a0	; Load Address Of Ball
;	add.l	#3*256,WORLDX(a0)	; Move Ball Over
;	rts
;
;BallLeft:
;	move.l	#Baseball,a0	; Load Address Of Ball
;	sub.l	#3*256,WORLDX(a0)	; Move Ball Over
;	rts
;
;BallUp:
;	move.l	#Baseball,a0	; Load Address Of Ball
;	add.l	#3*256,WORLDZ(a0)	; Move Ball Over
;	rts
;
;BallDown:
;	move.l	#Baseball,a0	; Load Address Of Ball
;	sub.l	#3*256,WORLDZ(a0)	; Move Ball Over
;	rts

	.export	GhostPitch,TwisterPitch,KnucklePitch

KnucklePitch:
	move.b	#1,KnuckleBall	; Set For A Knuckle Ball

TwisterPitch:
	move.l	#TwisterTable,BiasTable
	rts

GhostPitch:
	move.b	#GHOSTBALL,Ghosting	; Set For Ghost Trail
	rts

;***************************************************************************
;   ShowBall - Display Ball During Pitch		*
;				*
;   Parameters :  a5 - Address Of Baseball Object	*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
ShowBall:
	IMAGES	#Misc	; Set For Ball Bank
	APALETTE	#P_BALL	; Set Palette Number

;	Y = (209-(95*WY/726))-(WZ/72)(121-71*WY/726)

;	Y = ((209*726-95*WY)-(WZ/72)(121*726-71*WY))/726

	move.l	#121*726,d0	; 121*726
	move.l	WORLDY(a5),d1	; WY
	asr.l	#8,d1	; Shift Out Integer
	muls.l	#71,d1	; 71*WY
	sub.l	d1,d0	; (121*726-71*WY)
	move.l	WORLDZ(a5),d1	; WZ
	add.l	BallZBias,d1	; Add In Twister\Knuckle Bias
	asr.l	#8,d1	; Shift Out Integer
	muls.l	d1,d0	; WZ(121*726-71*WY)
	divs.l	#72,d0	; (WZ*(121*726-71*WY))/72

	move.l	WORLDY(a5),d1	; WY
	asr.l	#8,d1	; Shift Out Integer
	muls.l	#95,d1	; 95*WY
	neg.l	d1	; -95*WY
	add.l	#209*726,d1	; (209*726-95*WY)
	move.l	d1,BallTempY	; Save For Shadow
	sub.l	d0,d1	; (209*726-95*WY)-(WZ*(121*726-71*WY))/72
	divs.l	#726,d1	; Divide By 726
	move.w	d1,d5	; Load Y Position
	move.l	BallYOffset,d0	; Load X Offset
	asr.l	#8,d0	; Shift Out Integer Part
	add.w	d0,d5	; Add In X Offset

	move.l	WORLDY(a5),d0	; Load Ball X Position
	divs	#-7744,d0	; Divide By Virtually Random Number
	add.w	#32,d0	; Add In Another Number
	move.l	WORLDX(a5),d4	; Load Ball X Position
	add.l	BallXBias,d4	; Add In Twister\Knuckle Bias
	divs	#36,d4	; Divide By Three Feet
	muls	d0,d4	; Multiply By Diatnce From Plate Factor
	asr.w	#8,d4	; Shift Out Result
	add.w	#192,d4	; Positon In Middle Of Screen
	move.l	BallXOffset,d0	; Load X Offset
	asr.l	#8,d0	; Shift Out Integer Part
	add.w	d0,d4	; Add In X Offset
	move.w	d4,BallTempX	; Save For Shadow

	move.w	#ball0081,d3	; Load Maximum Ball Number
	move.l	WORLDY(a5),d0	; Load World Y Position
	bmi.s	ShowBall_1	; Branch If Max
	divs	#2350,d0	; 
	sub.w	d0,d3	; Calculate Picture Number
ShowBall_1:
	move.w	d3,PICTURE(a5)	; Save Picture Number
	move.w	d3,d1	; Save For Ball Size
	sub.w	#ball0001,d1	; Calculate Ball Offset
	clr.w	d0
	move.l	#BallSize,a0	; Load Address Of Ball Size Array
	move.b	(a0,d1.w),d0	; Load Ball Size
	sub.w	d0,d4	; Move Over X
	sub.w	d0,d5	; Move Over Y
	move.w	d4,XPOSITION(a5)	; Store Screen X Position
	move.w	d5,YPOSITION(a5)	; Store Screen Y Position

	jsr	Blit	; Blit The Object

	tst.l	WORLDYVEL(a5)	; Check If Moving
	beq.s	ShowBall_9	; Exit If Not

	APALETTE	#P_BLACK	; Set Palette Number

	move.l	BallTempY,d1	; Load Shadow Temp
	divs.l	#726,d1	; Divide By 726
	move.w	d1,d5	; Load Y Position

	move.w	BallTempX,d4	; Load Shadow X Position

	move.w	#ball0081,d3	; Load Maximum Ball Number
	move.l	WORLDY(a5),d0	; Load World Y Position
	bmi.s	ShowBall_2	; Branch If Max
	divs	#2350,d0	; 
	sub.w	d0,d3	; Calculate Picture Number
ShowBall_2:
	move.w	d3,d1	; Save For Ball Size
	sub.w	#ball0001,d1	; Calculate Ball Offset
	clr.w	d0
	move.l	#BallSize,a0	; Load Address Of Ball Size Array
	move.b	(a0,d1.w),d0	; Load Ball Size
	sub.w	d0,d4	; Move Over X
	sub.w	d0,d5	; Move Over Y

	jsr	Blit	; Blit The Object

ShowBall_9:
	rts

;***************************************************************************
;   MoveBall - Move Ball During Pitch		*
;				*
;   Parameters :  a5 - Address Of Baseball Object	*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
SUCKYAFTER	 equ	4*12*256
SUCKYBEFORE equ	20*12*256
AFTERPLATE	 equ	9*12*256	; Distance Ball Can Be Hit Behind Plate
BEFOREPLATE equ	25*12*256	; Distance Ball Can Be Hit Before Plate

	.import	BeanBatter

MoveBall:
	tst.l	DISPLAYPROC(a5)	; Check If Displaying
	beq	MoveBall_9	; Branch If Not

	tst.b	Ghosting	; Check If Ghosting
	beq	MoveBall_1	; Branch If Not
	
	addq.b	#1,GhostCount	; Increment Counter
	move.b	GhostCount,d0	; Load Ghost Count
	and.b	#3,d0	; Extract Lower Two Bits
	bne.s	MoveBall_1	; Branch If Not Time

	jsr	AllocObject	; Allocate An Object
	beq.s	MoveBall_1	; Branch If None Available
	move.l	#BlitAObject,DISPLAYPROC(a0) ; Blit Anchored Object
	move.b	#Misc,BANK(a0)	; Misc Bank
	move.w	ZPOSITION(a5),ZPOSITION(a0)	; Copy Z Position
	move.w	XPOSITION(a5),XPOSITION(a0)	; Copy X Position
	move.w	YPOSITION(a5),YPOSITION(a0)	; Copy Y Position
	move.l	#Anim,UPDATEPROC(a0)	; Use Standard Animate Routine
	move.b	#1,STATIONARY(a0)	; Set As Stationary

	move.w	PICTURE(a5),PICTURE(a0)	; Copy Picture Number
	move.b	PALETTE(a5),PALETTE(a0)	; Copy Palette
	move.l	#GhostBall,PARSEPOINTER(a0)	; Set Animation

	cmp.b	#FIREBALL,Ghosting	; Check If Fireballing
	bne.s	MoveBall_1	; Branch If Not
	add.w	#5,XPOSITION(a0)	; Move Right A Little
	add.w	#3,YPOSITION(a0)	; Move Down A Little
	move.w	#fire0001,PICTURE(a0)	; Set Fire Ball Picture
	move.b	#P_FIREWORKS1,PALETTE(a0)	; Use Fireworks Palette
	move.l	#FireBallAnim,PARSEPOINTER(a0) ; Set Animation
MoveBall_1:

	move.l	WORLDX(a5),d0	; Load Ball X Position
	add.l	WORLDXVEL(a5),d0	; Add In Ball X Velocity
	move.l	d0,WORLDX(a5)	; Store New World Position

	move.l	BallXOffset,d0	; Load Ball Offset
	add.l	BallXOVel,d0	; Add In Velocity
	move.l	d0,BallXOffset	; Store New Offset

	move.l	BallXOVel,d0	; Load Ball X Offset Velocity
	sub.l	BallXOAccel,d0	; Subtract Acceleration
	move.l	d0,BallXOVel	; Store New Velocity

	move.l	BallYOffset,d0	; Load Ball Offset
	add.l	BallYOVel,d0	; Add In Velocity
	move.l	d0,BallYOffset	; Store New Offset

	move.l	BallYOVel,d0	; Load Ball X Offset Velocity
	sub.l	BallYOAccel,d0	; Subtract Acceleration
	move.l	d0,BallYOVel	; Store New Velocity
;
;	Bias Table Is Used For Twister And Knuckle Ball Pitches
;
	tst.l	BiasTable	; Check If Bias Table Active
	beq.s	MoveBall_2	; Branch If Not
	clr.l	BallXOffset	; Store New Offset
	clr.l	BallYOffset	; Store New Offset

	tst.b	KnuckleBall	; Check If Knuckle Ball
	beq.s	MoveBall_1B	; Branch If Not
	jsr	KnuckleMove	; Set For Knuckle Movement
	bra.s	MoveBall_2
MoveBall_1B:
	move.l	BiasTable,a0	; Load Address Of Bias Table
	move.w	(a0)+,d0	; Load X Bias
	cmp.w	#0x8000,d0	; Check If End Of Table
	bne.s	MoveBall_1C	; Branch If Not
	move.l	(a0)+,a0	; Start At Top Of Table Again
	move.w	(a0)+,d0	; Load X Bias
MoveBall_1C:
	ext.l	d0	; Extend To A Long
	move.l	d0,BallXBias	; Store X Bias
	move.w	(a0)+,d0	; Load Z Bias
	ext.l	d0	; Extend To A Long
	move.l	d0,BallZBias	; Store Z Bias
	add.l	WORLDZ(a5),d0	; Add To World Position
	move.l	d0,BallDestZ	; Set For Hit Calculation
	move.l	a0,BiasTable	; Store New Index
MoveBall_2:

	move.l	WORLDZ(a5),d0	; Load Ball Z Position
	add.l	WORLDZVEL(a5),d0	; Add In Ball Z Velocity
	move.l	d0,WORLDZ(a5)	; Store New World Position

	move.l	WORLDY(a5),d0
	add.l	WORLDYVEL(a5),d0
	move.l	d0,WORLDY(a5)

	cmp.l	#BEFOREPLATE,d0	; Check If 10 Feet In Front Of Plate
	bge.s	MoveBall_3	; Branch If Not
	move.l	ZoneObjPtr,a0
	move.b	#P_STADIUM,PALETTE(a0)	; Set Palette Number
MoveBall_3:
	cmp.l	AfterPlate,d0	; Check If 4 Feet Behind Plate
	bge	MoveBall_9	; Branch If Not
	move.l	ZoneObjPtr,a0
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
; *******	Bean Ball Pitch *************************************************
	cmp.b	#20,([AtPitPlayer],POWERNUM) ; Check For Bean Ball	*
	bne.s	MoveBall_4	; Branch If Not	*
	move.l	#BeanBatter,Batter+PARSEPOINTER ; Knock Down Batter	*
	SOUND	#CatchBall,#2	; Ball Hits Dirt Sound	*
	clr.w	Batter+DURATION	; Start Up Soon	*
	bra.s	MoveBall_8	;	*
MoveBall_4:		;	*
; *******	Grab And Throw Hit ***********************************************
	cmp.b	#22,([AtBatPlayer],POWERNUM) ; Check For Grab And Throw*
	bne.s	MoveBall_5	 ; Branch If Not	 *
	SOUND	#BareHandedCatch,#0	 ; Sound	 *
	move.l	#ThrowUp,Batter+PARSEPOINTER ; Throw Up Ball	 *
	clr.w	Batter+DURATION	 ; Start Up Soon	 *
	bra.s	MoveBall_9	 ;	 *
MoveBall_5:		 ;	 *
; ***************************************************************************
	jsr	SwingCheck	; Check If Batter Swung
	jsr	AddStrike	; Strike Him Up
	SOUND	#CatchBall,#2	; Ball Hits Dirt Sound
;	move.b	#1,didwiff
MoveBall_8:
	clr.l	DISPLAYPROC(a5)	; Turn Off Ball
	clr.l	UPDATEPROC(a5)	; Turn Off Ball
MoveBall_9:
	rts

KnuckleMove:
	jsr	Random	; Get A Random Number
	ext.w	d0	; Extend To A Word
	ext.l	d0	; Extend To A Long
	asl.w	#3,d0	; Multiply By Eight
	add.l	BallXBias,d0	; Add To X Bias
	cmp.l	#24*256,d0	; Compare WIth Two Feet
	ble.s	Knuckle_1	; Branch If Not
	move.l	#24*256,d0	; Load Two Feet
Knuckle_1:
	cmp.l	#-24*256,d0	; Compare WIth Two Feet
	bge.s	Knuckle_2	; Branch If Not
	move.l	#-24*256,d0	; Load Two Feet
Knuckle_2:
	move.l	d0,BallXBias	; Store New Bias

	jsr	Random	; Get A Random Number
	ext.w	d0	; Extend To A Word
	ext.l	d0	; Extend To A Long
	asl.w	#3,d0	; Multiply By Eight
	add.l	BallZBias,d0	; Add To Z Bias
	cmp.l	#24*256,d0	; Compare WIth Two Feet
	ble.s	Knuckle_3	; Branch If Not
	move.l	#24*256,d0	; Load Two Feet
Knuckle_3:
	cmp.l	#-24*256,d0	; Compare WIth Two Feet
	bge.s	Knuckle_4	; Branch If Not
	move.l	#-24*256,d0	; Load Two Feet
Knuckle_4:
	move.l	d0,BallZBias	; Store New Bias

	add.l	WORLDZ(a5),d0	; Add To World Position
	move.l	d0,BallDestZ	; Set For Hit Calculation
	rts

GhostBall:
	LASTFRAME	10
	DEALLOC

FireBallAnim:
	LASTFRAME	1
	SPRITE	fire0002,1
	SPRITE	fire0003,1
	SPRITE	fire0004,1
	SPRITE	fire0005,1
	SPRITE	fire0006,1
	SPRITE	fire0007,1
	SPRITE	fire0008,1
	SPRITE	fire0009,1
	DEALLOC

	.align	2

;***************************************************************************
;   CalcBallVel - Calculate Ball Velocities Based On Pitch	*
;				*
;   Parameters :  a5 - Address Of Baseball Object	*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
CalcBallVel:
	clr.b	LaserHit	; Clear Laser Hit
	clr.b	VintageHit	; Clear Vintage Hit
	move.l	Pitcher+CONTROLBLOCK,a2	; Load Address Of Control Block

; *******	Bean Ball Pitch *************************************************
	cmp.b	#20,POWERNUM(a2)	; Check For Bean Ball	*
	bne.s	CalcBall_1A	; Branch If Not	*
			;	*
	move.l	Batter+CONTROLBLOCK,a0	; Load Address Of CB	*
	cmp.b	#3,POWERNUM(a0)	; Check If Caveman Bat	*
	bne.s	CalcBall_1	; Branch If Not	*
	move.l	#CaveManSwing,PARSEPOINTER+Batter ; Set Animation	*
	clr.w	DURATION+Batter	; Start Real Soon	*
CalcBall_1:		;	*
	move.b	#GHOSTBALL,Ghosting	; Set For Ghost Trail	*
	move.b	#FastBallStrike,PitchType	; Save For Sounds	*
	clr.w	LASTTRACKXVEL(a2)	; Clear Last X Velocity	*
	move.l	#-80*MPH,WORLDYVEL(a5)	; Real Fast	*
	move.l	#80*MPH,d3	; Real Fast	*
	move.l	#-7*12*256,d4	; Seven Feet Off Base	*
	move.l	#6*12*256,d5	; Set For Bean Ball	*
	tst.b	Batter+FLIPFLAG	; Check If Flipped	*
	beq	CalcBall_5	; Branch If Not	*
	neg.l	d4	; Set For Left Hander	*
	bra	CalcBall_5	;	*
; **************************************************************************

CalcBall_1A:
; *******	Underhand Pitch *************************************************
	tst.b	UnderHandPitch	; Check If UnderHand Pitch*
	beq.s	CalcBall_1B	; Branch If Not	*
	move.w	#0x10,LASTTRACKYVEL(a2)	; Force Slow Trackball	*
	move.w	#0x10,MAXTRACKYVEL(a2)	; Force Slow Trackball	*
	clr.w	MAXTRACKXVEL(a2)	; Clear X Direction	*
	clr.w	LASTTRACKXVEL(a2)	; Clear X Direction	*
CalcBall_1B:		;	*
; *******	Vintage Pitcher *************************************************
	cmp.b	#11,POWERNUM(a2)	; Check If Vintage Pitcher*
	bne.s	CalcBall_1C	; Branch If Not	*
	move.w	#0x24,LASTTRACKYVEL(a2)	; Force Fast Trackball	*
	move.w	#0x24,MAXTRACKYVEL(a2)	; Force Fast Trackball	*
	move.b	#FIREBALL,Ghosting	; Set For Fire Ball Trail	*
CalcBall_1C:		;	*
; *******	Catch And Hit ***************************************************
	cmp.b	#22,([AtBatPlayer],POWERNUM); Check For Grab And Throw*
	bne.s	CalcBall_1D	; Branch If Not	*
	clr.l	AfterPlate	; Stop Ball At Plate	*
	move.l	#ThrowAndHit,PARSEPOINTER+Batter ; Set Animation	*
	clr.l	ALWAYSROUTINE+Batter	; Don't Check Trackball	*
	clr.w	DURATION+Batter	; Start Real Soon	*
	move.l	#-60*MPH,WORLDYVEL(a5)	; Moderate Speed	*
	move.l	#60*MPH,d3	; Real Fast	*
	move.l	#-40*256,d4	; Seven Feet Off Base	*
	move.l	#32*256,d5	; Set For Grab	*
	tst.b	Batter+FLIPFLAG	; Check If Flipped	*
	beq	CalcBall_5	; Branch If Not	*
	neg.l	d4	; Set For Left Hander	*
	bra	CalcBall_5	;	*
; **************************************************************************
CalcBall_1D:
	jsr	PitcherBias	; Bias Trackball Values By Pitcher Strength

	move.l	#PitchTable,a0	; Load Address Of Speed Table
	move.b	#SinkerStrike,PitchType	; Save For Sounds

	move.w	MAXTRACKXVEL(a2),d0	; Load X Direction
	asr.w	#2,d0	; Divide X By Four
	move.w	MAXTRACKYVEL(a2),d0	; Add Two Velocities

	tst.w	LASTTRACKYVEL(a2)	; Check For Sinker
	bmi.s	CalcBall_2	; Branch If It Is
	move.b	#CurveBallStrike,PitchType	; Save For Sounds
	move.w	MAXTRACKYVEL(a2),d1	; Load Y Velocity
	cmp.w	MAXTRACKXVEL(a2),d1	; Compare With X Direction
	blt.s	CalcBall_2	; Branch If X Less Than Y
	move.b	#Strike,PitchType	; Save Pitch Type For Sounds
	add.w	#8,d0	; Add Some For FastBall
CalcBall_2:
	cmp.w	#0x2C,d0	; Check If Too Big
	ble.s	CalcBall_3	; Branch If Not
	move.w	#0x2C,d0	; Load Maximum Velocity
CalcBall_3:
	and.w	#0xFFFE,d0	; Extract Even Number
	clr.l	d3	; Clear D1
	move.w	(a0,d0.w),d3	; Load Ball Speed

	tst.b	POWERUP(a2)	; Check If Powerup Button Down
	beq.s	CalcBall_3A	; Branch If It Isn;t
	asr.l	#1,d3	; Divide By Two
	asr.w	LASTTRACKXVEL(a2)	; Divide X By Two
CalcBall_3A:
	neg.l	d3	; Make Result Negative
	move.l	d3,WORLDYVEL(a5)	; Save World Y Velocity
	neg.l	d3	; Make It Positive Again

	move.w	MAXTRACKXVEL(a2),d4	; Load Maximum Velocity
	tst.w	LASTTRACKXVEL(a2)	; Check Current Trackball X Velocity
	bpl.s	CalcBall_3B	; Branch If Positive
	neg.w	d4	; Make It Negative
CalcBall_3B:
	move.w	MAXTRACKYVEL(a2),d5	; Load Maximum Velocity
	tst.w	LASTTRACKYVEL(a2)	; Check Current Trackball X Velocity
	bpl.s	CalcBall_3C	; Branch If Positive
	neg.w	d5	; Make It Negative
CalcBall_3C:
	tst.w	d5	; Check Y Velocity
	bmi.s	CalcBall_4	; Branch If Sinker
;	move.b	#Strike,PitchType	; Save Pitch Type For Sounds
	move.w	d4,d0	; Move X Vel To D0
	bpl.s	CalcBall_3E	; Branch If Positive
	neg.w	d0	; Make It Positive
CalcBall_3E:
	cmp.w	d0,d5	; Compare With Y Vel
	ble.s	CalcBall_4	; Branch If In Range
	move.w	d0,d5	; Force Y Down
CalcBall_4:
	muls	#(16*256)/0x18,d5	; Multiply By Up/Down Factor
	add.l	#42*256,d5	; Add In 3.5 Feet Off Ground
	muls	#(18*256)/0x18,d4	; Multiply By Sideways Factor
CalcBall_5:
	jsr	PitchToXZ	; Set For Pitch

	rts

;***************************************************************************
;   ThrowUp - Throw Up Ball		*
;				*
;   Parameters :  a5 - Address Of Baseball Object	*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
CalcThrowUp:
	move.b	#1,CanSwing	; Allow Swing

	move.l	WORLDX(a5),d0	; Load Ball X Position
	add.l	WORLDXVEL(a5),d0	; Add In Ball X Velocity
	move.l	d0,WORLDX(a5)	; Store New World Position

	sub.l	#0x18,WORLDZVEL(a5)	; Add In Gravity
	move.l	WORLDZ(a5),d0	; Load Ball Z Position
	add.l	WORLDZVEL(a5),d0	; Add In Ball Z Velocity
	move.l	d0,WORLDZ(a5)	; Store New World Position

	bpl.s	CalcThrowUp_9	; Branch If Off Ground

	clr.l	DISPLAYPROC(a5)	; Turn Off Ball
	clr.l	UPDATEPROC(a5)	; Turn Off Ball
	jsr	SwingCheck	; Check If Batter Swung
	jsr	AddStrike	; Strike Him Up
	SOUND	#CatchBall,#2	; Ball Hits Dirt Sound
;	move.b	#1,didwiff
CalcThrowUp_9:
	rts

;***************************************************************************
;   ThrowUpBall - Throw Ball Up In The Air		*
;				*
;   Parameters :  a5 - Address Of Batter		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
ThrowUpBall:
	move.l	#Baseball,a0	; Load Address Of Ball
   	move.l	#BallAnim_2,PARSEPOINTER(a0) ; Set Animation String
	move.l	#0x300,WORLDZVEL(a0)	; Set Upward World Z Velocity
	move.l	#0x80,WORLDXVEL(a0)	; Move Over A Little
	tst.b	Batter+FLIPFLAG	; Check If Flipped
	beq.s	ThrowUpB_1	; Branch If Not
	neg.l	WORLDXVEL(a0)	; Make It Negative
ThrowUpB_1:
	rts

;***************************************************************************
;   PitcherBias - Bias Trackball Values By Pitcher Strength	*
;				*
;   Parameters :  a2 - Control Block Of Pitcher		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
PitcherBias:
	tst.b	COMPUTER(a2)	; Check If Computer Player
	bne.s	BiasP_9	; Branch If It Is

	move.w	PITCHERSTRENGTH(a2),d1	; Load Pitcher Strength

	move.w	MAXTRACKXVEL(a2),d0	; Load X Max Track
	muls	d1,d0	; Multiply By Pitcher Strength
	asr.l	#8,d0	; Divide By 256
	move.w	d0,MAXTRACKXVEL(a2)	; Save X Max Track

	move.w	MAXTRACKYVEL(a2),d0	; Load Y Max Track
	muls	d1,d0	; Multiply By Pitcher Strength
	asr.l	#8,d0	; Divide By 256
	move.w	d0,MAXTRACKYVEL(a2)	; Save Y Max Track

	move.w	LASTTRACKXVEL(a2),d0	; Load X Last Track
	muls	d1,d0	; Multiply By Pitcher Strength
	asr.l	#8,d0	; Divide By 256
	move.w	d0,LASTTRACKXVEL(a2)	; Save X Last Track

	move.w	LASTTRACKYVEL(a2),d0	; Load Last Y Track
	muls	d1,d0	; Multiply By Pitcher Strength
	asr.l	#8,d0	; Divide By 256
	btst.b	#4,RAWBUTTONS(a2)	; Check If Home Base Pressed
	beq.s	BiasP_1	; Branch If Not
	neg.w	d0	; Negative The X Direction
BiasP_1:
	move.w	d0,LASTTRACKYVEL(a2)	; Save Last Y Track

	cmp.w	#64,d1	; Check If Minimum Arm Strength
	ble.s	BiasP_9	; Exit If A Minimum
;	subq.w	#5,d1	; Decrement Pitcher Strength
	move.w	d1,PITCHERSTRENGTH(a2)	; Give Pitcher Less Arm
BiasP_9:
	rts


;***************************************************************************
;   PitchToXZ - Pitch To An XZ Position, Y Is Zero	*
;   Parameters :  d4 - X Destination		*
;	       d5 - Z Destination		*
;	       d3 - Speed Of Pitch		*
;	       a5 - Address Of Baseball Object	*
;   Returns:      NONE		*
;   Modifies:     d0,d1,d2,d6,d7		*
;***************************************************************************
PitchToXZ:
	move.l	d5,BallDestZ	; Save Destination Z
	jsr	Random	; Get Random Number
	and.w	#0x7,d0	; Extract 0-7
	add.w	#12,d0	; Add Twelve More
	move.w	d0,PitchTime	; Set Initial Pitch Time

	clr.b	PitchHeight	; Set For Regular Pitch

	cmp.l	#50*256,d5	; Check If Higher Than 50 inches
	ble.s	PitchXZ_1	; Branch If Lower
	move.b	#0x02,PitchHeight	; Set For Sinker
PitchXZ_1:

	cmp.l	#32*256,d5	; Check If Lower Than 32 inches
	bge.s	PitchXZ_2	; Branch If Higher
	move.b	#0x10,PitchHeight	; Set For Sinker
PitchXZ_2:

	sub.l	BallCordX,d4	; Subtract Current From Destination
	sub.l	BallCordZ,d5	; Subtract Current From Destination

	move.l	BallCordY,d1	; Load Distance To Plate
;	sub.l	#BEFOREPLATE+AFTERPLATE/2,d1 ; Subtract Mid Point Of Swing Check

	divu	d3,d1	; Divide Distance By Speed

	divs	d1,d4	; Divide X Distance By Time
	ext.l	d4	; Extend To A Long
	divs	d1,d5	; Divide Y Distance By Time
	ext.l	d5	; Extend To A Long
	move.l	d4,WORLDXVEL(a5)	; Save X Velocity
	move.l	d5,WORLDZVEL(a5)	; Save Z Velocity

	add.w	d1,PitchTime	; Save Time From Pitcher To Batter

	move.w	LASTTRACKXVEL(a2),d0	; Load Last X Velocity
	ext.l	d0	; Extend To A Long
	asl.l	#1,d0	; Multiply By Two
	neg.l	d0	; Jim Wants It The Other Way
	move.l	d0,BallXOAccel	; Store As Arc Value

	lsr.w	#1,d1	; Divide Time By Two
	muls	d1,d0	; Calculate X Offset Velocity
	move.l	d0,BallXOVel	; Set X Velocity

	clr.l	BallXOffset	; Clear Ball Offset
	clr.l	BallYOffset	; Clear Y Offset
	clr.l	BallYOAccel
	clr.l	BallYOVel
	clr.l	BallZBias	; Clear Z Bias
	clr.l	BallXBias	; Clear X Bias

	tst.b	UnderHandPitch	; Check If UnderHand Pitch
	beq.s	PitchXZ_9

	move.l	#-0xE0,d0	; Load Y Accel
	move.l	d0,BallYOAccel	; Store Y Acceleration
		      
	muls	d1,d0	; Calculate Initial Velocity
	move.l	d0,BallYOVel	; Set Y Velocity

PitchXZ_9:

	rts

PitchTable:
	dc.w	40*MPH	; 00 
	dc.w	40*MPH	; 01 
	dc.w	40*MPH	; 02 
	dc.w	40*MPH	; 03 
	dc.w	40*MPH	; 04 
	dc.w	42*MPH	; 05 
	dc.w	44*MPH	; 06 
	dc.w	46*MPH	; 07 
	dc.w	48*MPH	; 08 
	dc.w	50*MPH	; 09 
	dc.w	52*MPH	; 0A 
	dc.w	54*MPH	; 0B 
	dc.w	56*MPH	; 0C 
	dc.w	58*MPH	; 0D 
	dc.w	60*MPH	; 0E 
	dc.w	62*MPH	; 0F 
	dc.w	64*MPH	; 10 
	dc.w	66*MPH	; 11 
	dc.w	68*MPH	; 12 
	dc.w	70*MPH	; 13 
	dc.w	75*MPH	; 14 
	dc.w	80*MPH	; 15 
	dc.w	85*MPH	; 16 
	dc.w	90*MPH	; 17 
	dc.w	95*MPH	; 18 
	dc.w	100*MPH	; 19 
	dc.w	105*MPH	; 1A 
	dc.w	110*MPH	; 1B 
	dc.w	115*MPH	; 1C
	dc.w	120*MPH	; 1D
	dc.w	125*MPH	; 1E 
	dc.w	130*MPH	; 1F 
	dc.w	130*MPH	; 20 
	
BallSize:		   
	dc.b	1,1,2,2,2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4
	dc.b	4,4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5
	dc.b	5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
	dc.b	6,6,6,6,6,6,6,7,7,7,7,7,7,7,7,8
	dc.b	8,8,8,8,8,8,8

BallAnim:
	SYSTEM	CalcBallVel
BallAnim_1:
	SYSTEM	MoveBall
	LASTFRAME	1
	JUMP	BallAnim_1
BallAnim_2:
	SYSTEM	CalcThrowUp
	LASTFRAME	1
	JUMP	BallAnim_2

	.align	2

;***************************************************************************
;   CavemanHit - Caveman COunter To Bean Ball Hit	*
;				*
;   Parameters :  a5 - Address Of Batter Object		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
CavemanHit:
	move.l	Batter+CONTROLBLOCK,a4	; Load Address Of Control Block
	move.b	#255,POWERNUM(a4)	; Set For Caveman Hit
	move.w	#BALLHIT,SwitchReason	; Switch To Field Display
	move.w	#40,d0	; Load Hit Direction
	move.w	d0,HitDirection	; Set Hit Direction
	bra	CavemanHit_1

;***************************************************************************
;   CheckHit - Check If Ball Was Hit During Swing	*
;				*
;   Parameters :  a5 - Address Of Batter Object		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************

CheckHit:
	jsr	SetHelpFlags	; Set Up Cheats

	move.l	#Baseball,a0	; Load Address Of Ball
	tst.l	DISPLAYPROC(a0)	; Check If Still Displayed
	beq	CheckHit_9	; Exit If It Was
	move.l	WORLDY(a0),d0	; Load World Y Position
	cmp.l	#BEFOREPLATE,d0	; Check For Distance Out
	bge	CheckHit_9	; Branch If Farther Out
	cmp.b	#20,([AtPitPlayer],POWERNUM) ; Check For Bean Ball
	beq	CheckHit_9	; Branch If It Is

	cmp.b	#22,([AtPitPlayer],POWERNUM) ; Check For Catch And Hit
	beq.s	CheckHit_0	; Branch If It Is

	move.b	#1,SuckyHit	; Set Sucky Hit Flag

	cmp.l	#SUCKYBEFORE,d0	; Check If Sucky Range
	bge.s	CheckHit_0	; Branch If It Is
	cmp.l	#-SUCKYAFTER,d0	; Check If Sucky Range
	bgt.s	CheckHit_1	; Branch If It Isn't
CheckHit_0:
	.import.s	Temp1
	move.l	d0,Temp1
	jsr	Random	; Get Random Number
	and.w	#0x7F,d0	; Extract 0-127
	bra.s	CheckHit_2

CheckHit_1:
	clr.b	SuckyHit	; Not A Sucky Hit
	add.l	#SUCKYAFTER,d0	; Add In Distance Behind Plate
	divu	#(SUCKYBEFORE+SUCKYAFTER)/128,d0 ; Calculate Index Into Hit Table

	tst.b	FLIPFLAG(a5)	; Check If Flipped Batter
	beq.s	CheckHit_2	; Branch If Not
	neg.w	BallXVel 	; Change Ball Direction
	sub.w	#128,d0	; Invert Hit Direction
	neg.w	d0	; Make It Positive
CheckHit_2:

;	move.w	#64,d0	; FORCE HIT DIRECTION

	move.w	d0,HitDirection	; Save Hit Direction


CavemanHit_1:
	move.l	AtBatPlayer,a4	; Load Address Of Batter
	move.w	#BALLHIT,SwitchReason	; Switch To Field Display

	asl.w	#2,d0	; Multiply By Four
	move.l	#HitsTable,a1	; Load Address Of Hit Table
	move.w	(a1,d0.w),BallXVel	; Store Hit Ball X Vector
	move.w	2(a1,d0.w),BallYVel	; Store Hit Ball Y Vector

;****************************************************************************
;	Calculate Bat Power Based On Trackball Speed	 *
;****************************************************************************
	move.w	MAXTRACKYVEL(a4),d1	; Load Bat Speed
	jsr	CheckBatPU	; Check For a Batter Power Up

	move.l	#BatVelTable,a1	; Load Address Of Velocity Table
	move.w	(a1,d1.w*2),BatSpeed	; Load Bat Speed

	clr.b	Power	; Clear D2
	move.l	B_ROSTERADR(a5),a2	; Load Address Of Attributes
	move.b	AT_POWER(a2),Power+1	; Store Power Attribute

;****************************************************************************
;	Calculate Ball Z Velocity Based On Bat Height	 *
;****************************************************************************

	clr.w	d0	; Set For High Ball
	move.l	BallDestZ,d1	; Load Height Of Ball
	cmp.l	#0x3000,d1	; Check If High
	bge.s	CheckHit_3	; Branch If It Is
	move.w	#1,d0	; Set For Mid Ball
	cmp.l	#0x2200,d1	; Check If Low
	bge.s	CheckHit_3	; Branch If Not
	move.w	#2,d0	; Set For Low Ball
CheckHit_3:
	move.w	ZoneHeight,d1	; Load Bat Height Zone
	sub.w	d0,d1	; Subtract Ball From Bat Zone
	add.w	#2,d1	; Make Result Positive
			; 0 - Ball Lowest
			; 1 - Ball Low
			; 2 - Optimal Hit
			; 3 - Ball High
			; 4 - Ball Highest



	cmp.w	#0x10,BatSpeed	; Check For A Bunt
	bgt.s	CheckHit_3A	; Branch If It Is
	move.w	#1,d1	; Set For Low Hit
CheckHit_3A:

	tst.b	SuckyHit	; Check If Sucky Hit
	beq.s	CheckHit_3B	; Branch If Not
	move.w	#4,d1	; Set For High Fly
CheckHit_3B:

	jsr	CheckHitPU	; Check For a Hit Power Up

	move.l	#BatZTable,a1	; Load Address Of Z Table
	move.l	(a1,d1.w*4),d0	; Load Z Velcity
	move.w	#0x100,BatAvgBoost	; Set No Batting Average Boost
	cmp.w	#2,d1	; Check If Optimal Hit
	bne.s	CheckHit_4	; Branch If Not
	jsr	UseBatAvg	; Use Batting Average To Lower Hit
CheckHit_4:
	move.l	d0,WORLDZVEL(a0)	; Set Z Velocity

; ***************************************************************************
;	Decrease Ball Velocity Based On Distance Between Bat And Ball    *
; ***************************************************************************

	move.l	#BatVertTable,a1	; Load Address Of Bat Velocity Table
	move.w	(a1,d1.w*2),Accuracy	; Load Distance Multiplier

	move.l	#Baseball,a0	; Load Address Of Ball
	jsr	SetBallSpeed	; Use Attributes To Set Ball Speed

	jsr	HitSounds	; Process Bat Hit Sounds

	clr.l	WORLDX(a0)	; Start Ball At Home Plate
	clr.l	WORLDY(a0)	; Start Ball At Home Plate
CheckHit_9:
	rts

;***************************************************************************
;   SetBallSpeed - Use Attribute To Modify Ball Speed	*
;				*
;   Parameters :  a0 - Baseball Object		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
	.export	Power,Accuracy,BatSpeed,BatAvgBoost
SetBallSpeed:
	move.w	Power,d0	; Load Power Attribute
	mulu	Accuracy,d0	; Multiply By Accuracy Factor
	asr.l	#8,d0	; Shift Out Result
	mulu	BatAvgBoost,d0	; Multiply In Batting Average Boost
	asr.l	#8,d0	; Shift Out Result
	mulu	BatSpeed,d0	; Multiply By Bat Speed
	asr.l	#3,d0	; Shift Out Result

	move.w	BallXVel,d1	; Load Ball X Velocity
	muls	d0,d1	; Multiply By Attributes
	asr.l	#8,d1	; Shift Out Result
	move.l	d1,WORLDXVEL(a0)	; Store Ball Speed

	move.w	BallYVel,d1	; Load Ball Y Velocity
	muls	d0,d1	; Multiply By Height Factor
	asr.l	#8,d1	; Divide By 256
	cmp.l	#0x400,d1	; Check For Minimum
	bge.s	SetBall_1	; Branch If Fine
	move.l	#0x400,d1	; Use Minimum Velocity
SetBall_1:
	move.l	d1,WORLDYVEL(a0)	; Save New Velocity

	tst.b	ScrewHim	; Check For Screw Job
	beq.s	SetBall_2	; Branch If Not
	jsr	Random	; Get A Random Number
	and.w	#0x3,d0	; Calculate Infielder To Hit To

	move.l	#HelpDir,a1	; Load Address Of Help Directions
	move.w	(a1,d0.w*2),HitDirection	; Set Hit Direction
	
	move.l	#ScrewTable,a1	; Load Address Of Screw Table
	asl.w	#3,d0	; Multiplly By Eight
	move.l	(a1,d0.w),WORLDXVEL(a0)	; Store X Velocity
	move.l	4(a1,d0.w),WORLDYVEL(a0)	; Store Y Velocity
	move.w	#0x100,d0	; Set Slighly Up Hit
	move.l	d0,WORLDZVEL(a0)	; Set World Z Velocity
SetBall_2:
	tst.b	HelpHim	; Check If Help Desired
	beq.s	SetBall_3	; Branch If Not
	move.w	ProcessTime,d0	; Get A Random Number
	and.w	#0x3,d0	; Calculate Infielder To Hit To
	move.l	#HelpDir,a1	; Load Address Of Help Directions
	move.w	(a1,d0.w*2),HitDirection	; Set Hit Direction
	move.l	#HelpTable,a1	; Load Address Of Help Table
	asl.w	#3,d0	; Multiplly By Eight
	move.l	(a1,d0.w),WORLDXVEL(a0)	; Store X Velocity
	move.l	4(a1,d0.w),WORLDYVEL(a0)	; Store Y Velocity
	move.w	#0x100,d0	; Set Slighly Up Hit
;	move.w	#0xB00,d0	; Set Slighly Up Hit
	move.l	d0,WORLDZVEL(a0)	; Set World Z Velocity
SetBall_3:

	rts

ScrewTable:
	dc.l	1700*7,2000*7	; First Base
	dc.l	1000*4,3000*7	; Second Base
	dc.l	-950*7,3000*7	; Short Stop
	dc.l	-1700*7,2000*7	; Third Base

HelpTable:
;	dc.l	000*6,3000*6	; Home Run
;	dc.l	000*6,3000*6	; Home Run
;	dc.l	000*6,3000*6	; Home Run
;	dc.l	000*6,3000*6	; Home Run

	dc.l	1990*6,2000*6	; First Base
	dc.l	000*6,3000*6	; Second Base
	dc.l	-2000*6,3000*6	; Short Stop
	dc.l	-1990*6,2000*6	; Third Base

HelpDir:
	dc.w	1	; First Base
	dc.w	56	; Second Base
	dc.w	72	; Short Stop
	dc.w	126	; Third Base


BatVelTable:
	dc.w	2	; 0 - 
	dc.w	2	; 1 - 
	dc.w	2	; 2 - 
	dc.w	3	; 3 - 
	dc.w	3	; 4 - 
	dc.w	3	; 5 - 
	dc.w	4	; 6 - 
	dc.w	4	; 7 - 
	dc.w	4	; 8 - 
	dc.w	5	; 9 - 
	dc.w	5	; A - 
	dc.w	5	; B - 
	dc.w	6	; C - 
	dc.w	6	; D - 
	dc.w	6	; E - 
	dc.w	7	; F - 
	dc.w	7	;10 - 
	dc.w	8	;11 - 
	dc.w	0xA	;12 - 
	dc.w	0xC	;13 - 
	dc.w	0xE	;14 - 
	dc.w	0x10	;15 - 
	dc.w	0x12	;16 - 
	dc.w	0x14	;17 - 
	dc.w	0x16	;18 - 
	dc.w	0x18	;19 - 
	dc.w	0x1A	;1A - 
	dc.w	0x1B	;1B - 
	dc.w	0x1C	;1C - 
	dc.w	0x1D	;1D - 
	dc.w	0x1E	;1E - 
	dc.w	0x1F	;1F - 
	dc.w	0x20	;20 - 
	dc.w	0x21	;21 - 
	dc.w	0x22	;22 - 
	dc.w	0x23	;23 - 
	dc.w	0x24	;24 - 
	dc.w	0x26	;25 - 
	dc.w	0x28	;26 - 
	dc.w	0x2A	;27 - 
	dc.w	0x2C	;28 - 
	dc.w	0x2E	;29 - 
	dc.w	0x30	;2A - 
	dc.w	0x32	;2B - 
	dc.w	0x34	;2C - 
	dc.w	0x36	;2D - 
	dc.w	0x38	;2E - 
	dc.w	0x3A	;2F - 
	dc.w	0x3C	;30 - 
	dc.w	0x3E	;31 - 
	dc.w	0x40	;32 - 
	dc.w	0x48	;33 - 
	dc.w	0x50	;34 - 

BatVertTable:
	dc.w	220	; 0 - Ball Lowest
	dc.w	176	; 1 - Ball Low
	dc.w	256	; 2 - Optimal Hit
	dc.w	128	; 3 - Ball High
	dc.w	96	; 4 - Ball Highest

BatZTable:
	dc.l	-0x1000	; 0 - Ball Lowest
	dc.l	-0x200	; 1 - Ball Low
	dc.l	0xA00	; 2 - Optimal Hit
	dc.l	0xF00	; 3 - Ball High
	dc.l	0x1200	; 4 - Ball Highest

;***************************************************************************
;   CheckHitPU - Check For Special Hitting Power Up	*
;				*
;   Parameters :  a4 - Control Block Of Batter		*
;	       d1 - Baseball Trajectory		*
;   Returns:      d1 - Power Up Modified Baseball Trajectory	*
;   Modifies:     NONE		*
;***************************************************************************
CheckHitPU:
; *******	Karate Hit ******************************************************
	cmp.b	#3,POWERNUM(a4)	; Check If Light Sabre	*
	bne.s	CheckHPU_1	; Branch If Not	*
	move.w	#2,d1	; Give Maximum Velocity   *
CheckHPU_1:		;	*
; *******	Light Sabre *****************************************************
	cmp.b	#1,POWERNUM(a4)	; Check If Light Sabre	*
	bne.s	CheckHPU_2	; Branch If Not	*
	move.w	#2,d1	; Give Maximum Velocity   *
CheckHPU_2:		;	*
; *******	Caveman Hit *****************************************************
	cmp.b	#255,POWERNUM(a4)	; Check If Caveman Hit	*
	bne.s	CheckHPU_3	; Branch If Not	*
	move.w	#2,d1	; Give Maximum Velocity   *
CheckHPU_3:		;	*
; *******	Grab And Hit ****************************************************
	cmp.b	#22,POWERNUM(a4)	; Check For Grab And Throw*
	bne.s	CheckHPU_4	; Branch If Not	*
	move.w	#2,d1	; Give Maximum Velocity   *
CheckHPU_4:		;	*
; **************************************************************************
	rts

;***************************************************************************
;   CheckBatPU - Check For Special Batter Power Up	*
;				*
;   Parameters :  a4 - Control Block Of Batter		*
;	       d1 - User Trackball Y Velocity		*
;   Returns:      d1 - Power Up Modified Track Ball Y Velocity	*
;   Modifies:     NONE		*
;***************************************************************************
CheckBatPU:
; *******	Light Sabre ******************************************************
	cmp.b	#1,POWERNUM(a4)	; Check If Light Sabre	 *
	bne.s	CheckBPU_1	; Branch If Not	 *
	move.w	#0x34,d1	; Add Some Power	 *
	move.b	#1,LaserHit	; Set For A Laser Hit	 *
CheckBPU_1:		;	 *
; *******	Vintage Player ***************************************************
	cmp.b	#14,POWERNUM(a4)	; Check If Vintage Player	 *
	bne.s	CheckBPU_2	; Branch If Not	 *
	move.b	#1,VintageHit	; Flag Vintage Hit	 *
CheckBPU_2:		;	 *
; *******	Karate Hit *******************************************************
;	cmp.b	#3,POWERNUM(a4)	; Check If Karate Hit	 *
;	bne.s	CheckBPU_3	; Branch If Not	 *
;	move.w	#0x30,d1	; Give Hard Hit	 *
;CheckBPU_3:		;	 *
; *******	One Arm Hit ******************************************************
	cmp.b	#25,POWERNUM(a4)	; Check If One Arm Hit	 *
	bne.s	CheckBPU_4	; Branch If Not	 *
	add.w	#3,d1	; Add A Little Harder	 *
CheckBPU_4:		;	 *
; *******	Caveman Hit ******************************************************
	cmp.b	#255,POWERNUM(a4)	; Check If Caveman Hit	 *
	bne.s	CheckBPU_5	; Branch If Not	 *
	move.w	#0x25,d1	; Give Hard Hit	 *
CheckBPU_5:		;	 *
; *******	Grab And Hit ****************************************************
	cmp.b	#22,POWERNUM(a4)	; Check For Grab And Throw*
	bne.s	CheckHPU_6	; Branch If Not	*
	add.w	#4,d1	; Add A Little	*
CheckHPU_6:		;	*
; ***************************************************************************

	cmp.w	#0x34,d1	; Check For Maximum
	ble.s	CheckBPU_9	; Branch If Fine
	move.w	#0x34,d1	; Load Maximum Value
CheckBPU_9:

	rts

;***************************************************************************
;   HitSound - Output Appropriate Sound After A Ball Is Hit	*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
HitSounds:
	move.b	#KaratePunch,d0	; Load Karate Sound
	cmp.b	#3,([AtBatPlayer],POWERNUM)	; Check If Karate
	beq.s	HitSnd_1	; Branch If It Is
	move.b	#BatHitBall,d0	; Load Sound Value
	move.w	BatSpeed,d1	; Load Bat Speed
	lsr.w	#4,d1	; Extract Upper Bits
	cmp.w	#4,d1	; Check For Maximum
	ble.s	HitSnd_1	; Branch If In Range
	move.w	#4,d1	; Load Maximum
HitSnd_1:
	jsr	SendSound	; Send Out The Sound

	tst.b	ScrewHim	; Check If Hard Out
	bne	HitSnd_8	; Branch If It Was
	tst.b	HelpHim	; Check If Hard Hit
	bne	HitSnd_8	; Branch If It Was

	cmp.w	#0x10,BatSpeed	; Check For Bunt
	bgt.s	HitSnd_2	; Branch If Greater
	SOUND	#Bunt,#0	; Bunt Sound
	bra	HitSnd_9
HitSnd_2:
	cmp.l	#-0x800,WORLDZVEL(a0)	; Check For Chopper
	bgt.s	HitSnd_3	; Branch If Not
	SOUND	#Chopper,#0	; Chopper Sound
	bra.s	HitSnd_9
HitSnd_3:
	move.w	Baseball+XPOSITION,d1	; Load Baseball X Position
	sub.w	Batter+XPOSITION,d1	; Subtract Batter X Position
	bpl.s	HitSnd_4	; Branch If Positive
	neg.w	d1	; Make It Positive
HitSnd_4:
	cmp.w	#40,d1	; Check For Jam Sandwich
	bge.s	HitSnd_9	; Branch If Greater
	SOUND	#JamSandwich,#0	; Jam Sandwich Sound
	bra.s	HitSnd_9
HitSnd_8:
	move.b	#HardDownLine,d0	; Down The Line Drive Sound
	cmp.w	#5,HitDirection	; Check For Down Line
	ble.s	HitSnd_7	; Branch If It Was
	cmp.w	#123,HitDirection	; Check For Down Line
	bge.s	HitSnd_7	; Branch If It Was
	move.b	#LineDrive,d0	; Load Line Drive Sound
HitSnd_7:
	clr.b	d1	; Clear Second Byte
	jsr	SendSound
HitSnd_9:
	rts

UseBatAvg:
	PUSHL	d1	; Save D1
	cmp.w	#0xD8,Power	; Check If Power Hitter
	bge.s	UseBat_1	; Exit If He Is

	clr.w	d2	; Clear D0
	move.b	AT_batavg(a2),d2	; Load Batting Average
	move.w	d2,d3	; Move BA To D2

	mulu	d0,d2	; Multiply By Z Velocity

	divs	#400,d2	; Divide By 400
	ext.l	d2	; Extend To A Long
	sub.l	d2,d0	; More Of A Line Drive

	add.w	#180,d3	; Add Constant To Batting Average
	move.w	d3,BatAvgBoost	; Set For Batting Average Boost
UseBat_1:
	move.l	d0,d2	; Save In D2
	jsr	Random	; Get A Random Number
	asl.l	#2,d0	; Multiply By Four
	add.l	d2,d0	; Add In Z Velocity
	POPL	d1	; Retrieve D1

	rts

SetHelpFlags:
	clr.b	ScrewHim	; No Screw
	clr.b	HelpHim	; No Help

	move.l	AtBatPlayer,a0	; Load Address Of Batter
	move.l	AtPitPlayer,a1	; Load Address Of Pitcher

	cmp.b	#50,BOZOFACTOR(a1)	; Check For Bozo
	bge.s	SetHelp_4	; Branch If He Is

	tst.b	COMPUTER(a0)	; Check If Computer Batter
	bne.s	SetHelp_9	; Branch If It Is

	cmp.w	#20,MAXTRACKYVEL(a0)	; Check For Decent Bat Speed
	blt.s	SetHelp_9	; Branch If Not

	jsr	Random	; Get Random Number

	cmp.b	#18,Inning	; Check For Extra Innings
	bge.s	SetHelp_6	; Branch If Not
	
	move.w	GameTime,d1	; Get The Game Time
	asr.w	#4,d1	; Divide By Sixteen
	cmp.w	#128,d1	; Check For Maximum
	ble.s	SetHelp_1	; Branch If Not
	move.w	#128,d1	; Load Maximum Value
SetHelp_1:
	cmp.w	d1,d0	; Compare With Random Number
	bgt.s	SetHelp_6	; Exit If Larger

SetHelp_4:
	move.b	#1,ScrewHim	; Set Screw Flag
	bra.s	SetHelp_9

SetHelp_6:
	move.b	HITS(a1),d0	; Load Pitcher Hits
	cmp.b	HITS(a0),d0	; Compare With Batter Hits
	ble.s	SetHelp_9	; Exit If Batter Tied Or Winning

	jsr	Random	; Get Random Number
	cmp.w	#0x40,d0	; Check For 1/4
	bgt.s	SetHelp_9	; Branch If Greater

	move.b	#1,HelpHim	; Get Him Help
SetHelp_9:
;	move.b	#1,HelpHim	; FORCE Get Him Help
	rts


;***************************************************************************
;   SwingHit - Check If Batter Swing At Ball		*
;				*
;   Parameters :  a5 - Address Of Batter Object		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
SwingCheck:
 	move.b	#1,BallPassed	; Set Ball Passed Flag
	cmp.b	#1,WasAVint ;turn off power
 	beq.s	WasAVintage
	cmp.b	#1,didswing	; Check If Batter Swung
	beq.s	SwingCheck_9	; Branch If He Did
WasAVintage:
	clr.l	Batter+PARSEPOINTER
	clr.b	([AtBatPlayer],POWERNUM) ;turn off power
	move.l	#WatchBall,Batter+PARSEPOINTER ; Do Walk out Anim
SwingCheck_9:
	clr.b	didswing	; Clear Swing Flag
	rts


Mult	equ	30
Div	equ	10

HitsTable:
;	dc.w	727*Mult/Div,727*Mult/Div
	dc.w	718*Mult/Div,736*Mult/Div
	dc.w	718*Mult/Div,736*Mult/Div
	dc.w	709*Mult/Div,745*Mult/Div
	dc.w	700*Mult/Div,753*Mult/Div
	dc.w	690*Mult/Div,762*Mult/Div
	dc.w	681*Mult/Div,770*Mult/Div
	dc.w	671*Mult/Div,778*Mult/Div
	dc.w	662*Mult/Div,787*Mult/Div
	dc.w	652*Mult/Div,795*Mult/Div
	dc.w	642*Mult/Div,803*Mult/Div
	dc.w	632*Mult/Div,810*Mult/Div
	dc.w	622*Mult/Div,818*Mult/Div
	dc.w	612*Mult/Div,826*Mult/Div
	dc.w	602*Mult/Div,833*Mult/Div
	dc.w	592*Mult/Div,840*Mult/Div
	dc.w	582*Mult/Div,848*Mult/Div
	dc.w	571*Mult/Div,855*Mult/Div
	dc.w	561*Mult/Div,862*Mult/Div
	dc.w	550*Mult/Div,869*Mult/Div
	dc.w	539*Mult/Div,875*Mult/Div
	dc.w	528*Mult/Div,882*Mult/Div
	dc.w	518*Mult/Div,888*Mult/Div
	dc.w	507*Mult/Div,894*Mult/Div
	dc.w	496*Mult/Div,901*Mult/Div
	dc.w	485*Mult/Div,907*Mult/Div
	dc.w	473*Mult/Div,912*Mult/Div
	dc.w	462*Mult/Div,918*Mult/Div
	dc.w	451*Mult/Div,924*Mult/Div
	dc.w	440*Mult/Div,929*Mult/Div
	dc.w	428*Mult/Div,935*Mult/Div
	dc.w	417*Mult/Div,940*Mult/Div
	dc.w	405*Mult/Div,945*Mult/Div
	dc.w	393*Mult/Div,950*Mult/Div
	dc.w	382*Mult/Div,955*Mult/Div
	dc.w	370*Mult/Div,959*Mult/Div
	dc.w	358*Mult/Div,964*Mult/Div
	dc.w	346*Mult/Div,968*Mult/Div
	dc.w	334*Mult/Div,972*Mult/Div
	dc.w	322*Mult/Div,976*Mult/Div
	dc.w	310*Mult/Div,980*Mult/Div
	dc.w	298*Mult/Div,984*Mult/Div
	dc.w	286*Mult/Div,987*Mult/Div
	dc.w	274*Mult/Div,991*Mult/Div
	dc.w	262*Mult/Div,994*Mult/Div
	dc.w	250*Mult/Div,997*Mult/Div
	dc.w	238*Mult/Div,1000*Mult/Div
	dc.w	225*Mult/Div,1003*Mult/Div
	dc.w	213*Mult/Div,1006*Mult/Div
	dc.w	201*Mult/Div,1008*Mult/Div
	dc.w	188*Mult/Div,1011*Mult/Div
	dc.w	176*Mult/Div,1013*Mult/Div
	dc.w	163*Mult/Div,1015*Mult/Div
	dc.w	151*Mult/Div,1017*Mult/Div
	dc.w	138*Mult/Div,1019*Mult/Div
	dc.w	126*Mult/Div,1020*Mult/Div
	dc.w	113*Mult/Div,1022*Mult/Div
	dc.w	101*Mult/Div,1023*Mult/Div
	dc.w	88*Mult/Div,1024*Mult/Div
	dc.w	76*Mult/Div,1025*Mult/Div
	dc.w	63*Mult/Div,1026*Mult/Div
	dc.w	50*Mult/Div,1027*Mult/Div
	dc.w	38*Mult/Div,1027*Mult/Div
	dc.w	25*Mult/Div,1028*Mult/Div
	dc.w	13*Mult/Div,1028*Mult/Div
	dc.w	0*Mult/Div,1028*Mult/Div
	dc.w	-13*Mult/Div,1028*Mult/Div
	dc.w	-25*Mult/Div,1028*Mult/Div
	dc.w	-38*Mult/Div,1027*Mult/Div
	dc.w	-50*Mult/Div,1027*Mult/Div
	dc.w	-63*Mult/Div,1026*Mult/Div
	dc.w	-76*Mult/Div,1025*Mult/Div
	dc.w	-88*Mult/Div,1024*Mult/Div
	dc.w	-101*Mult/Div,1023*Mult/Div
	dc.w	-113*Mult/Div,1022*Mult/Div
	dc.w	-126*Mult/Div,1020*Mult/Div
	dc.w	-138*Mult/Div,1019*Mult/Div
	dc.w	-151*Mult/Div,1017*Mult/Div
	dc.w	-163*Mult/Div,1015*Mult/Div
	dc.w	-176*Mult/Div,1013*Mult/Div
	dc.w	-188*Mult/Div,1011*Mult/Div
	dc.w	-201*Mult/Div,1008*Mult/Div
	dc.w	-213*Mult/Div,1006*Mult/Div
	dc.w	-225*Mult/Div,1003*Mult/Div
	dc.w	-238*Mult/Div,1000*Mult/Div
	dc.w	-250*Mult/Div,997*Mult/Div
	dc.w	-262*Mult/Div,994*Mult/Div
	dc.w	-274*Mult/Div,991*Mult/Div
	dc.w	-286*Mult/Div,987*Mult/Div
	dc.w	-298*Mult/Div,984*Mult/Div
	dc.w	-310*Mult/Div,980*Mult/Div
	dc.w	-322*Mult/Div,976*Mult/Div
	dc.w	-334*Mult/Div,972*Mult/Div
	dc.w	-346*Mult/Div,968*Mult/Div
	dc.w	-358*Mult/Div,964*Mult/Div
	dc.w	-370*Mult/Div,959*Mult/Div
	dc.w	-382*Mult/Div,955*Mult/Div
	dc.w	-393*Mult/Div,950*Mult/Div
	dc.w	-405*Mult/Div,945*Mult/Div
	dc.w	-417*Mult/Div,940*Mult/Div
	dc.w	-428*Mult/Div,935*Mult/Div
	dc.w	-440*Mult/Div,929*Mult/Div
	dc.w	-451*Mult/Div,924*Mult/Div
	dc.w	-462*Mult/Div,918*Mult/Div
	dc.w	-473*Mult/Div,912*Mult/Div
	dc.w	-485*Mult/Div,907*Mult/Div
	dc.w	-496*Mult/Div,901*Mult/Div
	dc.w	-507*Mult/Div,894*Mult/Div
	dc.w	-518*Mult/Div,888*Mult/Div
	dc.w	-528*Mult/Div,882*Mult/Div
	dc.w	-539*Mult/Div,875*Mult/Div
	dc.w	-550*Mult/Div,869*Mult/Div
	dc.w	-561*Mult/Div,862*Mult/Div
	dc.w	-571*Mult/Div,855*Mult/Div
	dc.w	-582*Mult/Div,848*Mult/Div
	dc.w	-592*Mult/Div,840*Mult/Div
	dc.w	-602*Mult/Div,833*Mult/Div
	dc.w	-612*Mult/Div,826*Mult/Div
	dc.w	-622*Mult/Div,818*Mult/Div
	dc.w	-632*Mult/Div,810*Mult/Div
	dc.w	-642*Mult/Div,803*Mult/Div
	dc.w	-652*Mult/Div,795*Mult/Div
	dc.w	-662*Mult/Div,787*Mult/Div
	dc.w	-671*Mult/Div,778*Mult/Div
	dc.w	-681*Mult/Div,770*Mult/Div
	dc.w	-690*Mult/Div,762*Mult/Div
	dc.w	-700*Mult/Div,753*Mult/Div
	dc.w	-709*Mult/Div,745*Mult/Div
	dc.w	-709*Mult/Div,745*Mult/Div
	dc.w	-709*Mult/Div,745*Mult/Div
	dc.w	-709*Mult/Div,745*Mult/Div
	dc.w	-709*Mult/Div,745*Mult/Div
	dc.w	-709*Mult/Div,745*Mult/Div
		        
TwisterTable:
	dc.w	4608,0
;	dc.w	4602,228
;	dc.w	4585,455
;	dc.w	4557,681
;	dc.w	4518,906
;	dc.w	4468,1128
;	dc.w	4406,1348
;	dc.w	4334,1564
	dc.w	4252,1777
;	dc.w	4159,1985
;	dc.w	4055,2188
;	dc.w	3942,2386
;	dc.w	3819,2578
;	dc.w	3687,2764
;	dc.w	3546,2943
;	dc.w	3396,3114
	dc.w	3238,3278
;	dc.w	3072,3435
;	dc.w	2898,3582
;	dc.w	2718,3721
;	dc.w	2530,3851
;	dc.w	2337,3972
;	dc.w	2138,4082
;	dc.w	1933,4183
	dc.w	1724,4273
;	dc.w	1510,4353
;	dc.w	1293,4423
;	dc.w	1073,4481
;	dc.w	850,4529
;	dc.w	625,4565
;	dc.w	398,4591
;	dc.w	171,4605
	dc.w	-57,4608
;	dc.w	-285,4599
;	dc.w	-512,4579
;	dc.w	-738,4549
;	dc.w	-962,4507
;	dc.w	-1183,4453
;	dc.w	-1402,4389
;	dc.w	-1618,4315
	dc.w	-1829,4229
;	dc.w	-2036,4134
;	dc.w	-2238,4028
;	dc.w	-2434,3912
;	dc.w	-2625,3787
;	dc.w	-2809,3653
;	dc.w	-2986,3509
;	dc.w	-3156,3358
	dc.w	-3318,3197
;	dc.w	-3472,3029
;	dc.w	-3618,2854
;	dc.w	-3755,2671
;	dc.w	-3882,2483
;	dc.w	-4000,2288
;	dc.w	-4108,2087
;	dc.w	-4207,1881
	dc.w	-4294,1671
;	dc.w	-4372,1456
;	dc.w	-4438,1238
;	dc.w	-4494,1017
;	dc.w	-4539,794
;	dc.w	-4573,568
;	dc.w	-4595,342
;	dc.w	-4607,114
	dc.w	-4607,-114
;	dc.w	-4595,-342
;	dc.w	-4573,-568
;	dc.w	-4539,-794
;	dc.w	-4494,-1017
;	dc.w	-4438,-1238
;	dc.w	-4372,-1456
;	dc.w	-4294,-1671
	dc.w	-4207,-1881
;	dc.w	-4108,-2087
;	dc.w	-4000,-2288
;	dc.w	-3882,-2483
;	dc.w	-3755,-2671
;	dc.w	-3618,-2854
;	dc.w	-3472,-3029
;	dc.w	-3318,-3197
	dc.w	-3156,-3358
;	dc.w	-2986,-3509
;	dc.w	-2809,-3653
;	dc.w	-2625,-3787
;	dc.w	-2434,-3912
;	dc.w	-2238,-4028
;	dc.w	-2036,-4134
;	dc.w	-1829,-4229
	dc.w	-1618,-4315
;	dc.w	-1402,-4389
;	dc.w	-1183,-4453
;	dc.w	-962,-4507
;	dc.w	-738,-4549
;	dc.w	-512,-4579
;	dc.w	-285,-4599
;	dc.w	-57,-4608
	dc.w	171,-4605
;	dc.w	398,-4591
;	dc.w	625,-4565
;	dc.w	850,-4529
;	dc.w	1073,-4481
;	dc.w	1293,-4423
;	dc.w	1510,-4353
;	dc.w	1724,-4273
	dc.w	1933,-4183
;	dc.w	2138,-4082
;	dc.w	2337,-3972
;	dc.w	2530,-3851
;	dc.w	2718,-3721
;	dc.w	2898,-3582
;	dc.w	3072,-3435
;	dc.w	3238,-3278
	dc.w	3396,-3114
;	dc.w	3546,-2943
;	dc.w	3687,-2764
;	dc.w	3819,-2578
;	dc.w	3942,-2386
;	dc.w	4055,-2188
;	dc.w	4159,-1985
;	dc.w	4252,-1777
	dc.w	4334,-1564
;	dc.w	4406,-1348
;	dc.w	4468,-1128
;	dc.w	4518,-906
;	dc.w	4557,-681
;	dc.w	4585,-455
;	dc.w	4602,-228
;	dc.w	4608,0

	dc.w	0x8000
	dc.l	TwisterTable

	end	        

