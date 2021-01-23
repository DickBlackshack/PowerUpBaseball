;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************


	.export	PlayAtHomeScreen

	.import	InitPlayer,CameraX
	.import	NewBatterUp

	.import	Pitcher,Batter,FirstBase,SecondBase,ShortStop,FirstRunner,Baseball
	.import	ThirdBase,Catcher,LeftField,CenterField,RightField

 	.import	Player,AddOut,AtBatPlayer,Inning,Random
 	.import	BlitObject,Anim
 	.import	SwitchReason
 	.import	CycleGame
 	.import	PlayHomeDone
 	.import	DspBody
 	.import	InitTrackball
 	.import	BackArt
 	.import	InitObjects,InitProcs
 	.import	InitJoys
 	.import	HomeRunner
 	.import	ThirdRunner
 	.import	SecondRunner
 	.import	AnimPlayer2
 	.import	InitJoyWatch
 	.import	InitBackgnd
 	.import	InitControls
 	.import	ShowBall
 	.import	PitchBall
 	.import	MoveBall
; 	.import	BallXAccel,BallZAccel

	.global	CharTrans
	.global	BIGCharTrans
	.global	AllocObject
	.global	FontAdjust
	.global	FontSpacing
	.global	fnt5Spacing
	.global	DeallocObject
	.global	ClearUpField

;***************************************************************************

	#include	"itvideo2.h"
	#include	"sys.h"
	#include	"sys.mac"
	#include	"graphlib.mac"
	#include	"graphlib.h"
	#include	"graphglb.h"
	#include	"macros.h"
;	#include	"r:\baseball\sounds\bsblsnds.equ"
;	#include	"r:\baseball\art\tables\player.h"
	#include	"player.h"
	#include	"bsblsnds.equ"
	#include	"ramblock.h"
	#include	"anim.mac"
	#include	"groms.h"
	#include	"stats.h"
	#include	"audits.h"
	#include	"pals.h"
	#include	"controls.h"

;***************************************************************************

	.region.s	"RAM"
SafeOutTextPointer	ds.l	1
;ScreenX	ds.l	1
	.region	"RomCode"

;***************************************************************************


PlayAtHomeScreen
	jsr	InitProcs	; Initialize Object System


	tst.l	WORLDX+Baseball
	bmi	BallRight
	cmp.l	#20*65535,WORLDX+Baseball
	bgt	BallLeft
	jmp	BallCenter

;init ball right ( off screen )
BallRight
	move.l	#Baseball,a0	; Load Address Of Ball
	move.l	#Dball,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Mball,UPDATEPROC(a0)        ; Set Animation Routine
	clr.l	PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Don't Let Anim Move The Ball
	move.l	#-75*65535,WORLDY(a0)	; Set Initial Y Position
	move.l	#420*65535,WORLDX(a0)	; Set Initial X Position
	move.l	#150*256,WORLDZ(a0)	; Set Initial Z Position was 72
	move.w	#10,ZPOSITION(a0)	; Display Ball On Top

	move.w	#ball0020,PICTURE(a0)	; Set Ball Picture

	move.l	#-1000*256,WORLDXVEL(a0)	; Save World Y Velocity
	move.l	#1000*256,WORLDYVEL(a0)	; Save World Y Velocity
	move.l	#-700,WORLDZVEL(a0)	; Save World Z Velocity
	move.l	#CatchRight,PARSEPOINTER+Catcher ;Starting Animation Address
	jmp	balldone

;init ball center
BallCenter
	move.l	#Baseball,a0	; Load Address Of Ball
	move.l	#ShowBall,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#AnimBall,UPDATEPROC(a0)        ; Set Animation Routine
	clr.l	PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Don't Let Anim Move The Ball
	move.l	#PITCHERY,WORLDY(a0)	; Set Initial Y Position
	move.l	#PITCHERX,WORLDX(a0)	; Set Initial X Position
	move.l	#150*256,WORLDZ(a0)	; Set Initial Z Position was 72
	move.w	#10,ZPOSITION(a0)	; Display Ball On Top

	move.w	#ball0020,PICTURE(a0)	; Set Ball Picture

	move.l	#0,WORLDXVEL(a0)	; Save World Y Velocity
	move.l	#-800,WORLDYVEL(a0)	; Save World Y Velocity
	move.l	#-700,WORLDZVEL(a0)	; Save World Y Velocity

	move.l	#CatchCenter,PARSEPOINTER+Catcher ;Starting Animation Address
	jmp	balldone

;init ball left
BallLeft
	move.l	#Baseball,a0	; Load Address Of Ball
	move.l	#Dball,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Mball,UPDATEPROC(a0)        ; Set Animation Routine
	clr.l	PARSEPOINTER(a0)  ; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Don't Let Anim Move The Ball
	move.l	#-75*65535,WORLDY(a0)	; Set Initial Y Position
	move.l	#-60*65535,WORLDX(a0)	; Set Initial X Position
	move.l	#150*256,WORLDZ(a0)	; Set Initial Z Position was 72
	move.w	#10,ZPOSITION(a0)	; Display Ball On Top

	move.w	#ball0020,PICTURE(a0)	; Set Ball Picture

	move.l	#1000*256,WORLDXVEL(a0)	; Save World Y Velocity
	move.l	#1000*256,WORLDYVEL(a0)	; Save World Y Velocity
	move.l	#-700,WORLDZVEL(a0)	; Save World Z Velocity

	move.l	#CatchLeft,PARSEPOINTER+Catcher ;Starting Animation Address
;-
balldone

	jsr	InitJoys	; Initialize Joy Stick Data
	jsr	InitControls	; Initialize Controls
;	jsr	InitPlayers	; Initialize All Fielders

	move.w	#2,BackArt	;play at home

	jsr	InitBackgnd	; Initialize Background
	jsr	InitJoyWatch	; Watch The Inputs

	jsr	InitTrackball 	; Initialize Trackball
;	jsr	StrikeOuts

	clr.b	PlayHomeDone
	clr.w	SwitchReason	; Clear Ball Hit Flag

;	move.l	#200,GroundY

;init catcher
	move.l	#Catcher,a0
	move.b	#1,B_INUSE(a0)	; Set To In Use
	move.b	#1,ONGROUND(a0)	; Set On Ground
	clr.l	WORLDX(a0)	; Set Batter World X
	clr.l	WORLDY(a0)	; Set Batter World Y
	move.w	#192,XPOSITION(a0)	; Store Starting X Position
	move.w	#228,YPOSITION(a0)	; Store Starting Y Position
	clr.b	FLIPFLAG(a0)	; Set No Flip
	move.l	#AnimPlayer2,UPDATEPROC(a0)	; Store Address Of Update Procedure
	move.l	#DspBody,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
	move.w	#-1,CURRENTFRAME(a0)	; Start With First Frame
	move.w	#TORSOZ,ZPOSITION(a0)   	; Initialize Z Position
	move.b	#0xFF,OBJECTTYPE(a0)	; Initialize Object Type	
	move.w	#256,XSCALE(a0)	; Set To Full Size Body
	move.w	#256,YSCALE(a0)	; Set To Full Size Body
	move.w	#256,SCALEFACTOR(a0)	; Set To Half Size

	move.l	#0,GRAVITY(a0)	; Store Gravity
	move.w	#-1,PICTURE(a0)	; Start With Standing Picture
	clr.l	ALWAYSROUTINE(a0)	; Clear Always Routine Address
	move.b	#1,STATIONARY(a0)	; Set As Stationary
	clr.w	DURATION(a0)	; Clear Animation Duration
	clr.b	B_HASBALL(a0)	; Clear Has Ball Flag
	clr.w	XVELOCITY(a0)	; Clear X Velocity
	move.w	#0,YVELOCITY(a0)	; Clear Y Velocity
	clr.b	DELETED(a0)
	move.b	#8,DAMP(a0)
	move.l	#Player,B_FRAMESDATA(a0)	; Save In Ram Block
;	move.l	#CatchCenter,PARSEPOINTER(a0) ; Save Starting Animation Address
;	move.l	#CatchLeft,PARSEPOINTER(a0) ; Save Starting Animation Address
;	move.l	#CatchRight,PARSEPOINTER(a0) ; Save Starting Animation Address
	move.b	#CatcherTopBank,BANK(a0)	; Load Bank Number
	move.b	#P_VISTPAL00,PALETTE(a0)	; Load Palette Number

;init base runner
	move.l	#Batter,a0
;	move.l	#HomeRunner,a0
	move.b	#1,B_INUSE(a0)	; Set To In Use
	jsr	InitPlayer
	move.b	#1,ONGROUND(a0)	; Set On Ground
	clr.l	WORLDX(a0)	; Set Batter World X
	clr.l	WORLDY(a0)	; Set Batter World Y
	move.w	#-200,XPOSITION(a0)	; Store Starting X Position
	move.w	#170,YPOSITION(a0)	; Store Starting Y Position
	clr.b	FLIPFLAG(a0)	; Set No Flip
	move.l	#AnimPlayer2,UPDATEPROC(a0)	; Store Address Of Update Procedure
	move.l	#DspBody,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
	move.w	#-1,CURRENTFRAME(a0)	; Start With First Frame
	move.w	#TORSOZ-1,ZPOSITION(a0)   	; Initialize Z Position
	move.b	#0xFF,OBJECTTYPE(a0)	; Initialize Object Type	
	move.w	#256,XSCALE(a0)	; Set To Full Size Body
	move.w	#256,YSCALE(a0)	; Set To Full Size Body
	move.w	#256,SCALEFACTOR(a0)	; Set To Half Size

	move.l	#0,GRAVITY(a0)	; Store Gravity
	move.w	#-1,PICTURE(a0)	; Start With Standing Picture
	clr.l	ALWAYSROUTINE(a0)	; Clear Always Routine Address
	move.b	#0,STATIONARY(a0)	; Set Stationary
	clr.w	DURATION(a0)	; Clear Animation Duration
	clr.b	B_HASBALL(a0)	; Clear Has Ball Flag
	clr.w	XVELOCITY(a0)	; Clear X Velocity
	move.w	#1,YVELOCITY(a0)	; Clear Y Velocity
	clr.b	DELETED(a0)
	move.b	#8,DAMP(a0)
	move.l	#Player,B_FRAMESDATA(a0)	; Save In Ram Block
	move.l	#HomeRunnerPARSE,PARSEPOINTER(a0) ; Save Starting Animation Address
	move.b	#RunnerTopBank,BANK(a0)	; Load Bank Number
	move.b	#P_VISTPAL00,PALETTE(a0)	; Load Palette Number


;safe/out text
	clr.b	d1	; Set As Non Collidable
	jsr	AllocObject	; Allocate An Object
	beq.s	.cant_alloc

	move.l	#SafeOut1,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.w	#100,COUNTER(a0)	;delay
	move.w	#10,ZPOSITION(a0)	; Initialize Z Position
.cant_alloc


;camera pan
	clr.b	d1	; Set As Non Collidable
	jsr	AllocObject	; Allocate An Object
	beq.s	.cant_alloc2
	move.l	#CameraProc,UPDATEPROC(a0)	; Store Address Of Update Procedure
	move.w	#195,CameraX
.cant_alloc2

;dust
	clr.b	d1	; Set As Non Collidable
	jsr	AllocObject	; Allocate An Object
	beq	.cant_alloc3

;	move.b	#1,ONGROUND(a0)	; Set On Ground
;	clr.l	WORLDX(a0)	; Set Batter World X
;	clr.l	WORLDY(a0)	; Set Batter World Y
;	move.w	#-200,XPOSITION(a0)	; Store Starting X Position
;	move.w	#140,YPOSITION(a0)	; Store Starting Y Position
;	clr.b	FLIPFLAG(a0)	; Set No Flip
;;	move.l	#AnimPlayer2,UPDATEPROC(a0)	; Store Address Of Update Procedure
;	move.l	#Anim,UPDATEPROC(a0)	; Store Address Of Update Procedure
;	move.l	#BlitObject,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
;;	move.w	#-1,CURRENTFRAME(a0)	; Start With First Frame
;	move.w	#TORSOZ-2,ZPOSITION(a0)   	; Initialize Z Position
;;	move.b	#0xFF,OBJECTTYPE(a0)	; Initialize Object Type	
;	move.w	#256,XSCALE(a0)	; Set To Full Size Body
;	move.w	#256,YSCALE(a0)	; Set To Full Size Body
;;	move.w	#256,SCALEFACTOR(a0)	; Set To Half Size
;
	move.l	#0,GRAVITY(a0)	; Store Gravity
;;	move.w	#-1,PICTURE(a0)	; Start With Standing Picture
;	clr.l	ALWAYSROUTINE(a0)	; Clear Always Routine Address
;;	move.b	#0,STATIONARY(a0)	; Set Stationary
;	clr.w	DURATION(a0)	; Clear Animation Duration
;	clr.b	B_HASBALL(a0)	; Clear Has Ball Flag
;	clr.w	XVELOCITY(a0)	; Clear X Velocity
;	move.w	#1,YVELOCITY(a0)	; Clear Y Velocity
;	clr.b	DELETED(a0)
;	move.b	#8,DAMP(a0)
;;	move.l	#Player,B_FRAMESDATA(a0)	; Save In Ram Block
;	move.l	#DustPARSE,PARSEPOINTER(a0) ; Save Starting Animation Address
;	move.b	#Misc,BANK(a0)	; Load Bank Number
;	move.b	#P_BALL,PALETTE(a0)	; Load Palette Number


	move.b	#1,B_INUSE(a0)	; Set To In Use
;	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#66,ZPOSITION(a0)   	; Initialize Z Position
	move.w	#dust0001,PICTURE(a0)	; Set Base-O-Meter Picture
	move.l	#DustPARSE,PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_DUST,PALETTE(a0)	; Set Palette Number
	move.w	#-200,XPOSITION(a0)	; Set X Position62
	move.w	#160,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	clr.w	XVELOCITY(a0)	; Clear X Velocity
	clr.w	YVELOCITY(a0)	; Clear Y Velocity
	clr.w	B_SEEKING(a0)
;	move.b	#8,DAMP(a0)
;	move.b	#1,STATIONARY(a0)	; Set As Stationary
.cant_alloc3


;***************************************************************************


HomePlayLoop
	jsr	CycleGame	; Perform One Game Cycle
	tst.b	PlayHomeDone
	beq	HomePlayLoop

;	jmp	PlayAtHomeScreen	;test

	clr.b	HomeRunner+B_INUSE	; Make Not In Use
	clr.l	HomeRunner+UPDATEPROC
	clr.l	HomeRunner+DISPLAYPROC
	jsr	ClearUpField
	rts


;***************************************************************************
CameraProc
	sub.l	#120*1092,CameraX	;pan speed, 1092 = 1 pixel per sec
	bpl.s	.nomin
	clr.w	CameraX
	jsr	DeallocObject
.nomin	rts

;***************************************************************************
SafeOut1
	sub.w	#1,COUNTER(a5)	;delay
	bne.s	.notyet
;bri	move.w	#180,COUNTER(a5)	;delay
	move.w	#80,COUNTER(a5)	;delay
	move.l	#SafeOutText,DISPLAYPROC(a5) ; Store Address Of Display Procedure

	jsr	Random
	btst.b	#1,d0
	beq	.safe
.out
;undo run scoring
;bri	move.b	Inning,d0	; Load Inning Number
;bri	ext.w	d0	; Extend To A Word
;bri	lsr.w	#1,d0	; Extract Inning Number
;bri	move.l	AtBatPlayer,a0	; Load Address Of Batter
;bri	add.b	#1,(INNINGSSCORE,a0,d0.w)	;Increment Inning Score by using INNINGSSCORE
;bri	add.b	#1,RUNS(a0)	; Increment Runs

	jsr	AddOut
	SOUND	#RunnerThrownOut,#0
	move.l	#notext,SafeOutTextPointer
;	move.l	#outtext,SafeOutTextPointer
	rts
.safe
	move.b	Inning,d0	;bri Load Inning Number
	ext.w	d0	;bri  Extend To A Word
	lsr.w	#1,d0	;bri  Extract Inning Number
	move.l	AtBatPlayer,a0	;bri  Load Address Of Batter
	add.b	#1,(INNINGSSCORE,a0,d0.w)	;bri Increment Inning Score by using INNINGSSCORE
	add.b	#1,RUNS(a0)	;bri  Increment Runs

	SOUND	#BaseRunnerSafe,#0
	move.l	#safetext,SafeOutTextPointer
.notyet	rts

SafeOutText
;	SETPRINT	#42,#30,#fnt5,#0
;	clr.l	FontAdjust
;	move.l	#fnt5Spacing,FontSpacing ; Non-Proportional Spacing
;	move.l	#BIGCharTrans,CharTrans ; character translation table
	APALETTE	#P_FONTY1
	PLOT	#130,#40
	move.l	SafeOutTextPointer,a0
	PRINTS	a0

;	BLIT	#130,#40,#safe

	sub.w	#1,COUNTER(a5)	;delay
	bne.s	.notyet
	move.b	#1,PlayHomeDone	;exit flag
.notyet	rts


safetext	dc.b	"SAFE",0
outtext	dc.b	"OUT",0
notext	dc.b	"",0

;***************************************************************************
AnimBall:
;	jsr	MoveBall

	move.l	WORLDX(a5),d0	; Load Ball X Position
	add.l	WORLDXVEL(a5),d0	; Add In Ball X Velocity
	move.l	d0,WORLDX(a5)	; Store New World Position

;	cmp.l	#726*256/2,WORLDY(a5)	; Check If Half Way
;	bge.s	MoveBall_2A	; Branch If Farther Away
;	move.w	BallXAccel,d0	; Load Ball X Acceleration
;	ext.l	d0	; Extend To A Long
;	add.l	d0,WORLDXVEL(a5)	; Add In To X Velocity
;	move.w	BallZAccel,d0	; Load Ball Z Acceleration
;	ext.l	d0	; Extend To A Long
;	add.l	d0,WORLDZVEL(a5)	; Add In To Z Velocity
MoveBall_2A:

	move.l	WORLDZ(a5),d0	; Load Ball Z Position
	add.l	WORLDZVEL(a5),d0	; Add In Ball Z Velocity
	move.l	d0,WORLDZ(a5)	; Store New World Position

	move.l	WORLDY(a5),d0
	add.l	WORLDYVEL(a5),d0
	move.l	d0,WORLDY(a5)
	
;	cmp.l	#120*256,d0	; Check If 5 Feet In Front Of Plate
;	bge.s	MoveBall_3	; Branch If Not
;	move.l	ZoneObjPtr,a0
;	move.b	#P_STADIUM,PALETTE(a0)	; Set Palette Number
MoveBall_3:
	cmp.l	#580*256,d0	; Check If in catchers mitt
	bge.s	MoveBall_9	; Branch If Not
	clr.l	DISPLAYPROC(a5)	; Turn Off Ball
	clr.l	UPDATEPROC(a5)	; Turn Off Ball
;	move.l	ZoneObjPtr,a0
;	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
;	jsr	AddStrike	; Strike Him Up
MoveBall_9:

;	sub.w	#5,XPOSITION(a5)	; Center On Ball
;	add.w	#2,YPOSITION(a5)
	rts

Mball
	move.l	WORLDXVEL(a5),d0
	add.l	d0,WORLDX(a5)
	move.l	WORLDYVEL(a5),d0
	add.l	d0,WORLDY(a5)
	cmp.w	#130,WORLDY(a5)	;catchers glove y
	blt.s	.nocatch
	clr.l	DISPLAYPROC(a5)	;ball caught
	clr.l	UPDATEPROC(a5)	;ball caught
	SOUND	#CatchBall,#1
.nocatch	rts

Dball
	IMAGES	#Misc	; Set For Ball Bank
	APALETTE	#P_BALL	; Set Palette Number
	BLIT	PICTURE(a5),WORLDX(a5),WORLDY(a5)
	rts

;***************************************************************************

CatchCenter
;noart	SPRITE	c45e01,30
;noart	SPRITE	c45e02,30
;noart	SPRITE	c45e03,5
;noart	SPRITE	c45e04,5
;noart	SPRITE	c45e05,5
;noart	SPRITE	c45e06,5
.hold
;noart	SPRITE	c45e07,5
;	SPRITE	c45e08,10
;	SPRITE	c45e09,5
;.hold	SPRITE	c45e10,5
	JUMP	.hold

CatchLeft
;noart	SPRITE	c47f01,30
;noart	SPRITE	c47f02,30
;noart	SPRITE	c45e05,6
;noart	SPRITE	c45e06,6
.hold
;noart	SPRITE	c45e07,6
;	SPRITE	c45e08,6
;	SPRITE	c45e09,6
;	SPRITE	c45e10,6
;	SPRITE	c45e11,6
;	SPRITE	c45e12,6
;.hold	LASTFRAME 30
	JUMP	.hold


CatchRight
;noart	SPRITE	c43d01,30
;noart	SPRITE	c43d02,10
;noart	SPRITE	c45e06,5
.hold
;noart	SPRITE	c45e07,5
;	SPRITE	c45e08,5
;	SPRITE	c45e09,5
;	SPRITE	c45e10,5
;	SPRITE	c45e11,5
;	SPRITE	c45e12,5
;.hold	LASTFRAME 30
	JUMP	.hold


HomeRunnerPARSE
	SETVEL	1150,-150,8
	SPRITE	rb3b01,5
	SPRITE	rb3b02,5
	SOUNDS	PlayerRuns,#0
	SPRITE	rb3b03,5
	SPRITE	rb3b04,5
	SOUNDS	PlayerRuns,#0
	SPRITE	rb3b05,5
	SPRITE	rb3b06,5
	SOUNDS	PlayerRuns,#0
	SPRITE	rb3b07,5
	SPRITE	rb3b08,5
;.hold	LASTFRAME 30
;	JUMP	.hold
HomeSlidePARSE
;	SETVEL	700,-70,8
;noart	SPRITE	rs1b01,5
;noart	SPRITE	rs1b02,5
;noart	SPRITE	rs1b03,5
;noart	SPRITE	rs1b04,13
;noart	SPRITE	rs1b05,10
;noart	SPRITE	rs1b06,5
;noart	SPRITE	rs1b07,5
	SETVEL	0,0,8
;noart	SPRITE	rs1b08,10
;noart	SPRITE	rs1b09,10
;noart	SPRITE	rs1b10,10
;noart	SPRITE	rs1b10,10
.hold	LASTFRAME 30
	JUMP	.hold


DustPARSE
	SETVEL	1150,-50,8	;-50
	LASTFRAME 50
	DISPLAY	BlitObject	;dust appears
	SETVEL	1150/2,-150/2,8	;-150/2

	SOUNDS	PlayerSlides,#0

	SPRITE	dust0001,3
	SPRITE	dust0002,3
	SPRITE	dust0003,3
	SPRITE	dust0004,3
	SPRITE	dust0005,3
	SPRITE	dust0006,3
	SPRITE	dust0007,3
	SPRITE	dust0008,3
	SPRITE	dust0009,3
	SPRITE	dust0010,3
	SPRITE	dust0011,3
	SPRITE	dust0012,3
	SPRITE	dust0013,3
	SPRITE	dust0014,3
	SPRITE	dust0015,3
	SPRITE	dust0001,3
	SPRITE	dust0002,3
	SPRITE	dust0003,3
	SPRITE	dust0004,3
	SPRITE	dust0005,3
	SPRITE	dust0006,3
	SPRITE	dust0007,3
	SPRITE	dust0008,3
;total 70
	SETVEL	1150/3,-150/3,8
	SPRITE	dust0009,3
	SPRITE	dust0010,3
	SPRITE	dust0011,3
	SPRITE	dust0012,3
	SPRITE	dust0013,3
	SPRITE	dust0014,3
	SPRITE	dust0015,3
	SPRITE	dust0001,3
	SPRITE	dust0002,3
	SPRITE	dust0003,3
	SPRITE	dust0004,3
	SPRITE	dust0005,3
	SPRITE	dust0006,3
;total 40
	DISPLAY	0
.hold	LASTFRAME 30
	JUMP	.hold




;***************************************************************************



