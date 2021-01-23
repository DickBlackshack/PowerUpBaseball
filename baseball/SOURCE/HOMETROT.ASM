;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************


	.export	HomeTrotScreen

	.import	InitPlayer,CameraX,HitDistance
	.import	NewBatterUp,Pletter,PlayerColor

	.import	Pitcher,Batter,FirstBase,SecondBase,ShortStop,FirstRunner,Baseball
	.import	ThirdBase,Catcher,LeftField,CenterField,RightField

 	.import	Player,AddOut,AtBatPlayer,Inning,Random
 	.import	BlitObject,Anim
 	.import	SwitchReason,AwayPlayer,HomePlayer
 	.import	CycleGame,HomeRun
 	.import	PlayHomeDone
 	.import	DspBody,WinTestRun
 	.import	InitTrackball
 	.import	BackArt,BigWinPtr
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
 	.import	MoveBall,FielderNum
 	.import	BallXAccel,BallZAccel

	.import draftteam,GroundY
	.import vstime
	.import temp
	.import done
	.import TogglePage
	.import button_sound
	.import PlayerL
	.import PlayerR

	.import	LosingPlayer
	.import	WinningPlayer
	.import	DScore,SetExtra
	.import	F2CharTrans
	.import	F3CharTrans
	.import	ScorePtr,spinner
	.import	fnt2Spacing
	.import	fnt3Spacing

	.import	card_pal,InitPitcher
	.import	BatRoster
	.import	NOTDIM,InitPlayers
	.import	blit_card2

	.import	NeoCharTrans
	.import	neo3Spacing
	.import	neo2Spacing
	.import	neo1Spacing

	.import	TeamNames

	.global	BallFountain

	.global	CharTrans
	.global	BIGCharTrans
	.global	AllocObject
	.global	FontAdjust
	.global	FontSpacing
	.global	fnt5Spacing
	.global	DeallocObject

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
JumpOnHome	ds.w	1
HomerNum	ds.l	1
HomeRunTot	ds.w	1
	.region	"RomCode"

;***************************************************************************


HomeTrotScreen
	add.w	#1,([AtBatPlayer],HOMERUNSCNT)

	SOUND	#Crowd2,#0

	jsr	InitProcs	; Initialize Object System


	move.l	HitDistance,d0
	lsr.l	#8,d0
	divu	#12,d0	;inches to feet

	cmp.w	#400,d0
	blt	InPark

;homer art 1-5

	clr.b	d1	; Set As Non Collidable
	jsr	AllocObject	; Allocate An Object
	beq	.noObj
;	move.w	#180,XPOSITION(a0)	; Store Starting X Position
;	move.w	#20,YPOSITION(a0)	; Store Starting Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
;	move.b	#homer1,PICTURE(a0)	; Set Bank Number
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#0xfff0,ZPOSITION(a0) ;was 100
	move.l	#BlitHomer,DISPLAYPROC(a0)    ; Store Address Of Display Procedure

	move.l	HitDistance,d0
	lsr.l	#8,d0
	divu	#12,d0	;inches to feet

	move.w	#homer1,PICTURE(a0)	;bkg art
	move.w	#16,XPOSITION(a0)	; Store Starting X Position
	move.w	#103,YPOSITION(a0)	; Store Starting Y Position
	cmp.w	#425,d0
	blt.s	.noObj

	move.w	#homer2,PICTURE(a0)	;bkg art
	move.w	#18,XPOSITION(a0)	; Store Starting X Position
	move.w	#65,YPOSITION(a0)	; Store Starting Y Position
	cmp.w	#450,d0
	blt.s	.noObj

	move.w	#homer3,PICTURE(a0)	;bkg art
	move.w	#8,XPOSITION(a0)	; Store Starting X Position
	move.w	#85,YPOSITION(a0)	; Store Starting Y Position
	cmp.w	#475,d0
	blt.s	.noObj

	move.w	#homer4,PICTURE(a0)	;bkg art
	move.w	#20,XPOSITION(a0)	; Store Starting X Position
	move.w	#19,YPOSITION(a0)	; Store Starting Y Position
	cmp.w	#500,d0
	blt.s	.noObj

	move.w	#homer5,PICTURE(a0)	;bkg art
	move.w	#261,XPOSITION(a0)	; Store Starting X Position
	move.w	#189,YPOSITION(a0)	; Store Starting Y Position

.noObj
	jsr	AllocObject	; Allocate An Object
	beq.s	.noebut	; Branch If None
	move.l	#end_but1,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#20,COUNTER(a0)	;delay buttons
.noebut

	clr.b	PlayHomeDone
.EndLoop

	jsr	CycleGame	; Perform One Game Cycle

	tst.b	PlayHomeDone
	beq	.EndLoop

	jmp	RunToPlate


BlitHomer
	IMAGES	#Misc
	APALETTE	#P_HOMER1
	BLIT	PICTURE(a5),#0,#0

	APALETTE	#P_NEWSCORE
	BLIT	#splash2,XPOSITION(a5),YPOSITION(a5)

;How Far
	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans ; character translation table

	APALETTE	#P_NEWSCORE

	PLOT	XPOSITION(a5),YPOSITION(a5)
	add.w	#10,prx_coor	;offset from splash
	add.w	#5,pry_coor
	move.l	HitDistance,d0
	lsr.l	#8,d0
	divu	#12,d0	;inches to feet

	PRINTDEC d0,#3,JRGT
	add.w	#9,pry_coor
	PRINT	"FEET"

	rts


;.............................................................................
InPark
	jsr	AllocObject	; Allocate An Object
	beq.s	.nobkg	; Branch If None
	move.l	#HRbkg,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.w	#5,ZPOSITION(a0)	; Initialize Z Position
.nobkg

	jsr	AllocObject	; Allocate An Object
	beq.s	.noshow	; Branch If None
	move.l	#HowFar,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.w	#15,ZPOSITION(a0)	; Initialize Z Position
	move.w	#0,COUNTER(a0)	;flasher
.noshow

	jsr	AllocObject	; Allocate An Object
	beq.s	.noebut	; Branch If None
	move.l	#end_but1,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#50,COUNTER(a0)	;delay buttons
.noebut

	jsr	AllocObject	; Allocate An Object
	beq.s	.nospin	; Branch If None
	move.l	#Anim,UPDATEPROC(a0)	; Store Address Of Update Procedure
	move.l	#BlitObject,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
	move.l	#spinball,PARSEPOINTER(a0) ; Save Starting Animation Address
	move.w	#10,ZPOSITION(a0)	; Initialize Z Position
	move.w	#190-56,XPOSITION(a0)	; Initialize Z Position
	move.w	#155,YPOSITION(a0)	; Initialize Z Position
	move.b	#Title,BANK(a0)	; Set Bank Number
	move.b	#P_DALL,PALETTE(a0)	; Set Palette Number
.nospin

	clr.b	PlayHomeDone
.EndLoop

	jsr	CycleGame	; Perform One Game Cycle

	tst.b	PlayHomeDone
	beq	.EndLoop

RunToPlate

	jsr	InitProcs	; Initialize Object System



;***************************************************************************

	move.l	#CatchRight,PARSEPOINTER+Catcher ;Starting Animation Address

;	jmp	BallLeft
;;init ball center
;	move.l	#Baseball,a0	; Load Address Of Ball
;	move.l	#ShowBall,DISPLAYPROC(a0)	; Store Address Of Display Procedure
;	move.l	#AnimBall,UPDATEPROC(a0)        ; Set Animation Routine
;	clr.l	PARSEPOINTER(a0)  ; Set Animation String
;	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
;	move.b	#Misc,BANK(a0)	; Set Bank Number
;	move.b	#1,STATIONARY(a0)	; Don't Let Anim Move The Ball
;	move.l	#PITCHERY,WORLDY(a0)	; Set Initial Y Position
;	move.l	#PITCHERX,WORLDX(a0)	; Set Initial X Position
;	move.l	#150*256,WORLDZ(a0)	; Set Initial Z Position was 72
;	move.w	#10,ZPOSITION(a0)	; Display Ball On Top
;
;	move.w	#ball0020,PICTURE(a0)	; Set Ball Picture
;
;	move.l	#0,WORLDXVEL(a0)	; Save World Y Velocity
;	move.l	#-800,WORLDYVEL(a0)	; Save World Y Velocity
;	move.l	#-700,WORLDZVEL(a0)	; Save World Y Velocity
;	move.w	#0,BallXAccel	; Load Ball X Acceleration
;	move.w	#0,BallZAccel	; Load Ball X Acceleration
;
;	move.l	#CatchCenter,PARSEPOINTER+Catcher ;Starting Animation Address
;	jmp	balldone
;
;;init ball left
;BallLeft
;	move.l	#Baseball,a0	; Load Address Of Ball
;	move.l	#Dball,DISPLAYPROC(a0)	; Store Address Of Display Procedure
;	move.l	#Mball,UPDATEPROC(a0)        ; Set Animation Routine
;	clr.l	PARSEPOINTER(a0)  ; Set Animation String
;	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
;	move.b	#Misc,BANK(a0)	; Set Bank Number
;	move.b	#1,STATIONARY(a0)	; Don't Let Anim Move The Ball
;	move.l	#-75*65535,WORLDY(a0)	; Set Initial Y Position
;	move.l	#-60*65535,WORLDX(a0)	; Set Initial X Position
;	move.l	#150*256,WORLDZ(a0)	; Set Initial Z Position was 72
;	move.w	#10,ZPOSITION(a0)	; Display Ball On Top
;
;	move.w	#ball0020,PICTURE(a0)	; Set Ball Picture
;
;	move.l	#1000*256,WORLDXVEL(a0)	; Save World Y Velocity
;	move.l	#1000*256,WORLDYVEL(a0)	; Save World Y Velocity
;	move.l	#-700,WORLDZVEL(a0)	; Save World Z Velocity
;	move.w	#0,BallXAccel	; Load Ball X Acceleration
;	move.w	#0,BallZAccel	; Load Ball X Acceleration
;
;	move.l	#CatchLeft,PARSEPOINTER+Catcher ;Starting Animation Address
;;-
;balldone

	jsr	InitJoys	; Initialize Joy Stick Data
	jsr	InitControls	; Initialize Controls
;	jsr	InitPlayers	; Initialize All Fielders

	jsr	InitPitcher
	move.l	#PitcherAnim,PARSEPOINTER+Pitcher ;New Starting Animation Address

; Second Base
;	move.w    #290,d2	; Set X Position
;	move.l	#SecondBase,a0	; Set Up Short Stop
;	move.l	#480*256,WORLDX(a0)	; Set World Coordinates
;	move.l	#1543*256,WORLDY(a0)
; 	jsr	InitPlayer	; Initialize Object
;	move.b	#SECONDBASEMAN,FielderNum	; Set Fielder Number
;	jsr	PlayerColor
;	move.l	#SecondBaseAnim,PARSEPOINTER(a0) ;New Starting Animation Address

; Short Stop
	move.w    #60,d2	; Set X Position
           move.l	#ShortStop,a0	; Set Up Short Stop
	move.l	#-480*256,WORLDX(a0)	; Set World Coordinates
	move.l	#1543*256,WORLDY(a0)
 	jsr	InitPlayer	; Initialize Object
	move.b	#SHORTSTOP,FielderNum	; Set Fielder Number
	jsr	PlayerColor	; Setup Player Color
	move.l	#ShortStopAnim,PARSEPOINTER(a0) ;New Starting Animation Address






	move.w	#2,BackArt	;play at home

	jsr	InitBackgnd	; Initialize Background
	jsr	InitJoyWatch	; Watch The Inputs

	jsr	InitTrackball 	; Initialize Trackball
;	jsr	StrikeOuts

	clr.b	PlayHomeDone
	clr.w	SwitchReason	; Clear Ball Hit Flag

;	move.l	#200,GroundY

;init catcher
;	move.l	#Catcher,a0
;	move.b	#1,B_INUSE(a0)	; Set To In Use
;	move.b	#1,ONGROUND(a0)	; Set On Ground
;	clr.l	WORLDX(a0)	; Set Batter World X
;	clr.l	WORLDY(a0)	; Set Batter World Y
;	move.w	#192,XPOSITION(a0)	; Store Starting X Position
;	move.w	#200,YPOSITION(a0)	; Store Starting Y Position
;	clr.b	FLIPFLAG(a0)	; Set No Flip
;	move.l	#AnimPlayer2,UPDATEPROC(a0)	; Store Address Of Update Procedure
;	move.l	#DspBody,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
;	move.w	#-1,CURRENTFRAME(a0)	; Start With First Frame
;	move.w	#TORSOZ,ZPOSITION(a0)   	; Initialize Z Position
;	move.b	#0xFF,OBJECTTYPE(a0)	; Initialize Object Type	
;	move.w	#256,XSCALE(a0)	; Set To Full Size Body
;	move.w	#256,YSCALE(a0)	; Set To Full Size Body
;	move.w	#256,SCALEFACTOR(a0)	; Set To Half Size
;
;	move.l	#0,GRAVITY(a0)	; Store Gravity
;	move.w	#-1,PICTURE(a0)	; Start With Standing Picture
;	clr.l	ALWAYSROUTINE(a0)	; Clear Always Routine Address
;	move.b	#1,STATIONARY(a0)	; Set As Stationary
;	clr.w	DURATION(a0)	; Clear Animation Duration
;	clr.b	B_HASBALL(a0)	; Clear Has Ball Flag
;	clr.w	XVELOCITY(a0)	; Clear X Velocity
;	move.w	#0,YVELOCITY(a0)	; Clear Y Velocity
;	clr.b	DELETED(a0)
;	move.b	#8,DAMP(a0)
;	move.l	#Player,B_FRAMESDATA(a0)	; Save In Ram Block
;	move.l	#CatchCenter,PARSEPOINTER(a0) ; Save Starting Animation Address
;	move.b	#CatcherTopBank,BANK(a0)	; Load Bank Number
;	move.b	#P_VISTPAL00,PALETTE(a0)	; Load Palette Number

;init base runner
	move.l	#Batter,a0
;	move.l	#HomeRunner,a0
	move.b	#1,B_INUSE(a0)	; Set To In Use
	jsr	InitPlayer
	move.b	#1,ONGROUND(a0)	; Set On Ground
	clr.l	WORLDX(a0)	; Set Batter World X
	clr.l	WORLDY(a0)	; Set Batter World Y
	move.w	#-350,XPOSITION(a0)	; Store Starting X Position -200
	move.w	#150,YPOSITION(a0)	; Store Starting Y Position 170
	clr.b	FLIPFLAG(a0)	; Set No Flip
	move.l	#AnimPlayer2,UPDATEPROC(a0)	; Store Address Of Update Procedure
	move.l	#DspBody,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
	move.w	#-1,CURRENTFRAME(a0)	; Start With First Frame
;	move.w	#TORSOZ+1,ZPOSITION(a0)   	; Initialize Z Position
	move.w	#0xffff,ZPOSITION(a0)   	; Initialize Z Position
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
	move.b	#1,DAMP(a0)
	move.l	#Player,B_FRAMESDATA(a0)	; Save In Ram Block
	move.l	#HomeRunnerPARSE,PARSEPOINTER(a0) ; Save Starting Animation Address
	jsr	Random
	btst.b	#0,d0
	beq.s	.rndtrot
	move.l	#HomeRunnerPARSErhd1,PARSEPOINTER(a0) ; Save Starting Animation Address
.rndtrot	move.b	#RunnerTopBank,BANK(a0)	; Load Bank Number
	move.b	#P_VISTPAL00,PALETTE(a0)	; Load Palette Number


;safe/out text
;	clr.b	d1	; Set As Non Collidable
;	jsr	AllocObject	; Allocate An Object
;	beq.s	.cant_alloc
;
;	move.l	#SafeOut1,DISPLAYPROC(a0) ; Store Address Of Display Procedure
;	move.w	#100,COUNTER(a0)	;delay
;	move.w	#10,ZPOSITION(a0)	; Initialize Z Position
;.cant_alloc


;camera pan
	clr.b	d1	; Set As Non Collidable
	jsr	AllocObject	; Allocate An Object
	beq.s	.cant_alloc2
	move.l	#CameraProc,UPDATEPROC(a0)	; Store Address Of Update Procedure
	move.w	#175,CameraX	;was 195
.cant_alloc2

;power taunts
	clr.b	d1	; Set As Non Collidable
	jsr	AllocObject	; Allocate An Object
	beq.s	.cant_PT
	move.l	#PowerTaunts,UPDATEPROC(a0)	; Store Address Of Update Procedure
	move.w	#0,JumpOnHome	;jump on home flag
.cant_PT


;firework
	SOUND	#FireWork,#0
	clr.b	d1	; Set As Non Collidable
	jsr	AllocObject	; Allocate An Object
	beq.s	.cant_f1
	move.l	#FireDown,PARSEPOINTER(a0) ; Save Starting Animation Address
	move.l	#Anim,UPDATEPROC(a0)	; Store Address Of Update Procedure
	move.l	#BlitObject,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
;	move.w	#200,XPOSITION(a0)	; Store Starting X Position
;	move.w	#100,YPOSITION(a0)	; Store Starting Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#P_FIREWORKS1,PALETTE(a0)	; Set Palette Number
	move.w	#0xffff,ZPOSITION(a0)   	; Initialize Z Position
	move.l	a0,a5
	jsr	SetRandomXY
.cant_f1

;firework
	clr.b	d1	; Set As Non Collidable
	jsr	AllocObject	; Allocate An Object
	beq.s	.cant_f2
	move.l	#FireDownF,PARSEPOINTER(a0) ; Save Starting Animation Address
	move.l	#Anim,UPDATEPROC(a0)	; Store Address Of Update Procedure
	move.l	#BlitObject,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
;	move.w	#200,XPOSITION(a0)	; Store Starting X Position
;	move.w	#100,YPOSITION(a0)	; Store Starting Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#P_FIREWORKS2,PALETTE(a0)	; Set Palette Number
	move.w	#0xffff,ZPOSITION(a0)   	; Initialize Z Position
	move.l	a0,a5
	jsr	SetRandomXY
.cant_f2



;homer art 1-5
;
;	clr.b	d1	; Set As Non Collidable
;	jsr	AllocObject	; Allocate An Object
;	beq	.noObj
;	move.w	#180,XPOSITION(a0)	; Store Starting X Position
;	move.w	#20,YPOSITION(a0)	; Store Starting Y Position
;	move.b	#Misc,BANK(a0)	; Set Bank Number
;	move.b	#P_HOMER1,PALETTE(a0)	; Set Palette Number
;	move.w	#0xfff0,ZPOSITION(a0) ;was 100
;	move.l	a0,HomerNum
;
;	move.l	HitDistance,d0
;	lsr.l	#8,d0
;	divu	#12,d0	;inches to feet
;
;	cmp.w	#400,d0
;	blt.s	.noObj
;	move.l	#Anim,UPDATEPROC(a0)	; Store Address Of Update Procedure
;	move.l	#BlitObject,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
;
;	move.l	#Homer1,PARSEPOINTER(a0) ; Save Starting Animation Address
;	cmp.w	#425,d0
;	blt.s	.noObj
;
;	move.l	#Homer2,PARSEPOINTER(a0) ; Save Starting Animation Address
;	cmp.w	#450,d0
;	blt.s	.noObj
;
;	move.l	#Homer3,PARSEPOINTER(a0) ; Save Starting Animation Address
;	cmp.w	#475,d0
;	blt.s	.noObj
;
;	move.l	#Homer4,PARSEPOINTER(a0) ; Save Starting Animation Address
;	cmp.w	#500,d0
;	blt.s	.noObj
;
;	move.l	#Homer5,PARSEPOINTER(a0) ; Save Starting Animation Address
;
;.noObj

	clr.b	d1	; Set As Non Collidable
	jsr	AllocObject	; Allocate An Object
	beq	.nocard
	move.w	#275,XPOSITION(a0)	; Store Starting X Position
	move.w	#55,YPOSITION(a0)	; Store Starting Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#P_HOMER1,PALETTE(a0)	; Set Palette Number
	move.w	#0xfff0,ZPOSITION(a0) ;was 100
	move.l	#BlitCard,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
.nocard







;dust
;	clr.b	d1	; Set As Non Collidable
;	jsr	AllocObject	; Allocate An Object
;	beq	.cant_alloc3

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

;	move.l	#0,GRAVITY(a0)	; Store Gravity

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


;	move.b	#1,B_INUSE(a0)	; Set To In Use
;;	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
;	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
;	move.w	#66,ZPOSITION(a0)   	; Initialize Z Position
;	move.w	#dust0001,PICTURE(a0)	; Set Base-O-Meter Picture
;	move.l	#DustPARSE,PARSEPOINTER(a0)	; Set Animation String
;	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
;	move.w	#-200,XPOSITION(a0)	; Set X Position62
;	move.w	#160,YPOSITION(a0)	; Set Y Position
;	move.b	#Misc,BANK(a0)	; Set Bank Number
;	clr.w	XVELOCITY(a0)	; Clear X Velocity
;	clr.w	YVELOCITY(a0)	; Clear Y Velocity
;	clr.w	B_SEEKING(a0)
;;	move.b	#8,DAMP(a0)
;;	move.b	#1,STATIONARY(a0)	; Set As Stationary
;.cant_alloc3

;score a run
	move.b	Inning,d0	; Load Inning Number
	ext.w	d0	; Extend To A Word
	lsr.w	#1,d0	; Extract Inning Number
	move.l	AtBatPlayer,a0	; Load Address Of Batter
	add.b	#1,(INNINGSSCORE,a0,d0.w)	;Increment Inning Score by using INNINGSSCORE
	add.b	#1,RUNS(a0)	; Increment Runs

	jsr	WinTestRun
	tst.l	WinningPlayer
	beq.s	.nowin
	move.w	#100,([BigWinPtr],XPOSITION) ;better x pos for this screen
.nowin

;***************************************************************************

	SOUND	#Crowd2,#0

	clr.b	PlayHomeDone
HomeRunLoop
	jsr	CycleGame	; Perform One Game Cycle

	jsr	BallFountain	; brian
	tst.b	PlayHomeDone
	beq	HomeRunLoop

	tst.l	WinningPlayer
	beq.s	.nowin
	rts		;back to game for win screens
.nowin

;***************************************************************************

;	jmp	HomeTrotScreen	;test


	clr.b	Catcher+B_INUSE	; Make Not In Use
	move.b	#1,Catcher+DELETED	; Make Not In Use
	clr.l	Catcher+UPDATEPROC
	clr.l	Catcher+DISPLAYPROC

	clr.b	Batter+B_INUSE	; Make Not In Use
	move.b	#1,Batter+DELETED	; Make Not In Use
	clr.l	Batter+UPDATEPROC
	clr.l	Batter+DISPLAYPROC


	jsr	InitProcs	; Initialize Object System


;show new scores

	jsr	AllocObject	; Allocate An Object
	beq.s	.noobj	; Branch If None
	move.l	#DScore,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	jsr	SetExtra
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#11,ZPOSITION(a0)	; Initialize Z Position
	move.w	#newscore,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#40,XPOSITION(a0)	; Set X Position62
	move.w	#10,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
	move.l	a0,ScorePtr
.noobj

	jsr	AllocObject	; Allocate An Object
	beq.s	.noshow	; Branch If None
	move.l	#ShowScore,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.w	#11,ZPOSITION(a0)	; Initialize Z Position
.noshow

	jsr	AllocObject	; Allocate An Object
	beq.s	.noebut	; Branch If None
	move.l	#end_but,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#0,COUNTER(a0)	;delay buttons
.noebut

	SOUND	#Crowd2,#0
	clr.b	PlayHomeDone
EndLoop1

	jsr	CycleGame	; Perform One Game Cycle

	tst.b	PlayHomeDone
	beq	EndLoop1


	SOUND	#BatterUpOrgan,#0	; Set Volume

	jsr	InitProcs	; Initialize Object System

	rts		;back to game



;***************************************************************************

end_but
	sub.w	#1,COUNTER(a5)
	bpl.s	.nobuts	;ignore buts for a little bit
	tst.b	([AtBatPlayer],BUTTONS)
	bne.s	.cont
	cmp.w	#-200,COUNTER(a5)	;auto timeout
	bne.s	.nobuts
.cont
	move.b	#1,PlayHomeDone	;exit
.nobuts	rts

;***************************************************************************

end_but1
	sub.w	#1,COUNTER(a5)
	bpl.s	.nobuts	;ignore buts for a little bit
;	tst.b	([AtBatPlayer],BUTTONS)
;	bne.s	.cont
	cmp.w	#-200,COUNTER(a5)	;auto timeout
	bne.s	.nobuts
.cont
	move.b	#1,PlayHomeDone	;exit
.nobuts	rts


;***************************************************************************
HRbkg
	IMAGES	#Title
	APALETTE	#P_CELEB01
	BLIT	#celeb01,#0,#0
	rts

HowFar
;	IMAGES	#Title
;	APALETTE	#P_CELEB01
;	BLIT	#celeb01,#0,#0

	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans ; character translation table


	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	add.w	#1,COUNTER(a5)
	btst	#3,COUNTER+1(a5)
	beq.s	.flash
	BLIT	#homerun,#100,#15
.flash

	APALETTE	#P_NEWSCORE

	PLOT	#217-56,#175
	move.l	HitDistance,d0
	lsr.l	#8,d0
	divu	#12,d0	;inches to feet



;	tst.w	d0
;	bne	.notrap
;	move.l	HitDistance,d1
;	trap	#1
;.notrap



	PRINTDEC d0,#3,JRGT

	PLOT	#214-56,#205
	PRINT	"FEET"

	rts

;***************************************************************************

ShowScore
	IMAGES	#Title
	APALETTE	#P_TITLERB
	BLIT	#pinrb,#0,#0

	SETPRINT	#31,#46,#neo1,#0
	clr.l	FontAdjust
	move.l	#neo1Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans ; character translation table

	APALETTE	#P_NEWSCORE
	PLOT	#80,#130
	move.w	([AwayPlayer],TEAMNUMBER),d0

	cmp.w	#draftteam,d0
	bne.s	.nodraft1	;branch if not a draft team
	lea.l	([AwayPlayer],letters),a0
	clr.w	d6
	move.w	#3,d7	;print 3 letters
	jsr	Print
	bra	.Anamedone
.nodraft1

	asl.w	#4,d0	;times 16
	lea.l	(TeamNames,d0.w),a0
	PRINTS	a0
.Anamedone

	APALETTE	#P_NEOYEL
	PLOT	#290,#130
	SETPRINT	#31,#46,#neo1,#0
	clr.l	FontSpacing	;don't proportional space score
	PRINTDECB <([AwayPlayer],RUNS)>,#2,JRGTS
	move.l	#neo1Spacing,FontSpacing


	APALETTE	#P_NEWSCORE
	PLOT	#80,#130+50
	move.w	([HomePlayer],TEAMNUMBER),d0

	cmp.w	#draftteam,d0
	bne.s	.nodraft2	;branch if not a draft team
	lea.l	([HomePlayer],letters),a0
	clr.w	d6
	move.w	#3,d7	;print 3 letters
	jsr	Print
	bra	.Wnamedone
.nodraft2

	asl.w	#4,d0	;times 16
	lea.l	(TeamNames,d0.w),a0
	PRINTS	a0
.Wnamedone

	APALETTE	#P_NEOYEL
	PLOT	#290,#130+50
	SETPRINT	#31,#46,#neo1,#0
	clr.l	FontSpacing	;don't proportional space score
	PRINTDECB <([HomePlayer],RUNS)>,#2,JRGTS
	move.l	#neo1Spacing,FontSpacing

	rts

;***************************************************************************

BlitCard
;	SETPRINT	#8,#8,#fnt3,#0
;	clr.l	FontAdjust
;	clr.l	FontSpacing	; Non-Proportional Spacing
;	move.l	#F3CharTrans,CharTrans	; character translation table
;	APALETTE	#P_FONTW2


	move.w	XPOSITION(a5),d6	; Set X Position
	move.w	YPOSITION(a5),d7	; Set Y Position
;	jsr	GetBatterRoster
	move.l	BatRoster,a6
	move.b	#NOTDIM,card_pal

	jsr	blit_card2

;homeruncnt
	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEOYEL

	move.w	([AtBatPlayer],HOMERUNSCNT),d0
	add.w	([AtBatPlayer],stat_homeruns),d0
	move.w	d0,HomeRunTot
	clr.l	d1
	move.w	d0,d1
	divu.w	#20,d1
	swap	d1
	tst.w	d1	;no remainder?
	bne	no20mod
	PLOT	#55,#10
	PRINT	"YOUR "
	PRINTDEC	HomeRunTot,#3,JRGT
;	PRINTDEC	#50,#3,JRGT
	PRINT	"TH HOME RUN!"
no20mod

	rts



;	SETPRINT	#17,#22,#neo3,#0
;	clr.l	FontAdjust
;	move.l	#neo3Spacing,FontSpacing ; Non-Proportional Spacing
;;	clr.l	FontSpacing ; Non-Proportional Spacing
;	move.l	#NeoCharTrans,CharTrans ; character translation table
;	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals
;
;
;	PLOT	XPOSITION(a5),YPOSITION(a5)
;
;	move.w	([HomerNum],PICTURE),d0
;
;	move.l	#outpT,a1	;Text location
;	cmp.w	#homer1,d0
;	beq.s	.printthis
;
;	move.l	#itsT,a1	;Text location
;	cmp.w	#homer2,d0
;	beq.s	.printthis
;
;	move.l	#ptplT,a1	;Text location
;	cmp.w	#homer3,d0
;	beq.s	.printthis
;
;	move.l	#ootcT,a1	;Text location
;	cmp.w	#homer4,d0
;	beq.s	.printthis
;
;	move.l	#ioT,a1	;Text location
;	cmp.w	#homer5,d0
;	beq.s	.printthis
;
;	rts
;
;.printthis
;
;
;;	move.l	#ptplT,a1	;test
;
;
;	move.l	a1,a0
;	PRINTS	a0
;	rts
;
;outpT	dc.b	"OUT OF THE PARK",0
;itsT	dc.b	"INTO THE STREET",0
;ptplT	dc.b	"PAST THE PARKING LOT",0
;ootcT	dc.b	"OUT OF THE CITY",0
;ioT	dc.b	"INTO ORBIT",0

	.align	2


;***************************************************************************

PowerTaunts
	cmp.w	#150,Batter+XPOSITION
	blt.s	.nojmp
	tst.w	JumpOnHome	;jump on home
	beq.s	.nojmp
	clr.w	JumpOnHome	;jump on home
	move.l	#HomeRunnerPARSEjmp,PARSEPOINTER+Batter ; Save Starting Animation Address
.nojmp

	move.w	([AtBatPlayer],TOTALPOWER),d2

	tst.b	([AtBatPlayer],POWERUP)
	beq	.nopow

	move.w	#28*256,d1
	move.l	#HomeRunnerPARSErhd2,d3
	jsr	Random
	btst.b	#0,d0
;	beq.s	.rndtrot
;	move.l	#HomeRunnerPARSErhd3,d3
.rndtrot
	tst.b	([AtBatPlayer],FIRSTBUTTON)
	bne.s	.power

	move.w	#28*256,d1
	tst.b	([AtBatPlayer],HOMEBUTTON)
	beq.s	.nopow
	move.l	#HomeRunnerPARSE,d3	;normal run
	move.w	#1,JumpOnHome	;jump on home
;	move.l	d3,PARSEPOINTER+ShortStop ;fall down
;	move.l	d3,PARSEPOINTER+Pitcher ;fall down
;	move.l	d3,PARSEPOINTER+SecondBase ;fall down

.power
;	cmp.w	d1,d2
;	blt	.nopow	;not enough
;	sub.w	d1,([AtBatPlayer],TOTALPOWER)	; subtract from total power

	move.l	d3,PARSEPOINTER+Batter ; Save Starting Animation Address

	clr.b	([AtBatPlayer],BUTTONS)
	clr.b	([AtBatPlayer],HOMEBUTTON)
	clr.b	([AtBatPlayer],FIRSTBUTTON)
	clr.b	([AtBatPlayer],SECONDBUTTON)
	clr.b	([AtBatPlayer],THIRDBUTTON)
	clr.b	([AtBatPlayer],POWERUP)
.nopow

	cmp.w	#550,Batter+XPOSITION ;duration of screen


;	cmp.w	#4000,Batter+XPOSITION ;test


	blt.s	.notoff
	move.b	#1,PlayHomeDone	;exit flag
.notoff
	rts

;***************************************************************************
CameraProc
	sub.l	#120*1092,CameraX	;pan speed, 1092 = 1 pixel per sec
	bpl.s	.nomin
	clr.w	CameraX
	jsr	DeallocObject


	rts

.nomin	rts

;***************************************************************************
;SafeOut1
;	sub.w	#1,COUNTER(a5)	;delay
;	bne.s	.notyet
;	move.w	#180,COUNTER(a5)	;delay
;	move.l	#SafeOutText,DISPLAYPROC(a5) ; Store Address Of Display Procedure
;
;	jsr	Random
;	btst.b	#1,d0
;	beq	.safe
;.out
;;undo run scoring
;	move.b	Inning,d0	; Load Inning Number
;	ext.w	d0	; Extend To A Word
;	lsr.w	#1,d0	; Extract Inning Number
;	move.l	AtBatPlayer,a0	; Load Address Of Batter
;	add.b	#1,(INNINGSSCORE,a0,d0.w)	;Increment Inning Score by using INNINGSSCORE
;	add.b	#1,RUNS(a0)	; Increment Runs
;
;
;	jsr	AddOut
;	move.l	#notext,SafeOutTextPointer
;;	move.l	#outtext,SafeOutTextPointer
;	rts
;.safe
;	move.l	#safetext,SafeOutTextPointer
;.notyet	rts
;
;SafeOutText
;	SETPRINT	#42,#30,#fnt5,#0
;	clr.l	FontAdjust
;	move.l	#fnt5Spacing,FontSpacing ; Non-Proportional Spacing
;	move.l	#BIGCharTrans,CharTrans ; character translation table
;	APALETTE	#P_FONTY1
;	PLOT	#130,#40
;	move.l	SafeOutTextPointer,a0
;	PRINTS	a0
;
;	sub.w	#1,COUNTER(a5)	;delay
;	bne.s	.notyet
;	move.b	#1,PlayHomeDone	;exit flag
;.notyet	rts
;
;
;safetext	dc.b	"SAFE",0
;outtext	dc.b	"OUT",0
;notext	dc.b	"",0

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
.nocatch	rts

Dball
	IMAGES	#Misc	; Set For Ball Bank
	APALETTE	#P_BALL	; Set Palette Number
	BLIT	PICTURE(a5),WORLDX(a5),WORLDY(a5)
	rts


SetPlayHomeDone
	move.b	#1,PlayHomeDone	;exit flag

	rts

;----------------------------------------------------------------------------

SetRandomXY
	jsr	Random
	and.w	#0000000011111111b,d0
	add.w	#65,d0
;	asl.w	#8,d0
	move.w	d0,XPOSITION(a5)

	jsr	Random
	and.w	#0000000000111111b,d0
	sub.w	#40,d0
;	asl.w	#8,d0
	move.w	d0,YPOSITION(a5)

	rts

;***************************************************************************

CatchCenter
.hold
;noart	SPRITE	c45e01,30
	JUMP	.hold

CatchLeft
;noart	SPRITE	c47f01,30
;noart	SPRITE	c47f02,30
;noart	SPRITE	c45e05,6
;noart	SPRITE	c45e06,6
;noart	SPRITE	c45e07,6
;noart	SPRITE	c45e08,6
;noart	SPRITE	c45e09,6
;noart	SPRITE	c45e10,6
;noart	SPRITE	c45e11,6
;noart	SPRITE	c45e12,6
.hold	LASTFRAME 30
	JUMP	.hold


CatchRight
;noart	SPRITE	c43d01,30
;noart	SPRITE	c43d02,10
;noart	SPRITE	c45e06,5
;noart	SPRITE	c45e07,5
;noart	SPRITE	c45e08,5
;noart	SPRITE	c45e09,5
;noart	SPRITE	c45e10,5
;noart	SPRITE	c45e11,5
;noart	SPRITE	c45e12,5
.hold	LASTFRAME 30
	JUMP	.hold


HomeRunnerPARSE
	SETVEL	1150,-150,10	;-150 to home
.hold
	SPRITE	rb3b01,5
	SPRITE	rb3b02,5
	SPRITE	rb3b03,5
	SPRITE	rb3b04,5
	SPRITE	rb3b05,5
	SPRITE	rb3b06,5
	SPRITE	rb3b07,5
	SPRITE	rb3b08,5

	JUMP	.hold


HomeRunnerPARSErhd1	;arm pump
	SETVEL	1150,-150,10	;-150 to home
.hold
	SPRITE rhd101,5
	SPRITE rhd102,5
	SPRITE rhd103,5
	SPRITE rhd104,5
	SPRITE rhd105,5
	SPRITE rhd106,5
	SPRITE rhd107,5
	SPRITE rhd108,5

	JUMP	.hold


HomeRunnerPARSErhd2	;kiss
	SETVEL	1150,-150,10	;-150 to home
.hold
	SPRITE rhd201,5
	SPRITE rhd202,5
	SPRITE rhd203,5
	SPRITE rhd204,5
	SPRITE rhd205,5
	SPRITE rhd206,5
	SPRITE rhd207,5
	SPRITE rhd208,5

	JUMP	.hold


;HomeRunnerPARSErhd3	;turnaround
;	SETVEL	1150,-150,10	;-150 to home
;.hold
;	SPRITE rhd301,5
;	SPRITE rhd302,5
;	SPRITE rhd303,5
;	SPRITE rhd304,5
;	SPRITE rhd305,5
;	SPRITE rhd306,5
;	SPRITE rhd307,5
;	SPRITE rhd308,5
;
;	JUMP	.hold


HomeRunnerPARSEjmp
	SETVEL	1150,-150,10	;-150 to home
.hold
;	SPRITE rhd301,5
;	SPRITE rhd302,5
;	SPRITE rhd303,5
;	SPRITE rhd304,5
;	SPRITE rhd305,5
;	SPRITE rhd306,5
;	SPRITE rhd307,5
;	SPRITE rhd308,5


	SPRITE rn3a01,5
	SPRITE rn3a02,5
	SPRITE rn3a03,5
	SPRITE rn3a04,5
	SPRITE rn3a05,5
	SPRITE rn3a06,5
	SPRITE rn3a07,5
	SPRITE rn3a08,5
	SPRITE rn3a09,5



	JUMP	.hold


PitcherAnim
.hold
	SPRITE p07a01,8
	SPRITE p01a01,4
	SPRITE p01a02,4
	SPRITE p01a03,4
	SPRITE p01a04,4
	SPRITE p01a05,4
	SPRITE p01a06,4
	SPRITE p01a07,3
	SPRITE p01a08,5
	SPRITE p01a07,3
	SPRITE p01a06,4
	SPRITE p01a05,4
	SPRITE p01a04,4
	SPRITE p01a03,4
	SPRITE p01a02,4
	SPRITE p01a01,4
	SPRITE p07a01,4

	JUMP	.hold

SecondBaseAnim
.hold
	SPRITE f69a01,40
	SPRITE f69a02,6
	SPRITE f69a03,6
	SPRITE f69a04,8
	SPRITE f69a05,8
	SPRITE f69a06,10
	SPRITE f69a05,8
	SPRITE f69a04,8
	SPRITE f69a03,8
	SPRITE f69a02,6

	JUMP	.hold


ShortStopAnim
.hold
	SPRITE f69a01,160
	SPRITE f69a02,6
	SPRITE f69a03,6
	SPRITE f69a04,8
	SPRITE f69a05,8
	SPRITE f69a06,10
	SPRITE f69a05,8
	SPRITE f69a04,8
	SPRITE f69a03,8
	SPRITE f69a02,6

	JUMP	.hold

;***************************************************************************

FireDown

.hold
;	SOUNDS	FireWork
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

	SYSTEM	SetRandomXY

	JUMP	.hold

	DEALLOC

FireDownF
	SETFLIP		;Flip anim for Lefty
.hold
;	SOUNDS	FireWorkB
	SPRITE spke0001,2
	SPRITE spke0002,2
	SPRITE spke0003,2
	SPRITE spke0004,2
	SPRITE spke0005,2
	SPRITE spke0006,2
	SPRITE spke0007,2
	SPRITE spke0008,2
	SPRITE spke0009,2
	SPRITE spke0010,2
	SPRITE spke0011,2

	SYSTEM	SetRandomXY

	JUMP	.hold

	DEALLOC

FireLeft
	SPRITE spkf0001,2
	SPRITE spkf0002,2
	SPRITE spkf0003,2
	SPRITE spkf0004,2
	SPRITE spkf0005,2
	SPRITE spkf0006,2
	SPRITE spkf0007,2
	SPRITE spkf0008,2
	SPRITE spkf0009,2
	SPRITE spkf0010,2
	SPRITE spkf0011,2

	DEALLOC


FireLeftF
	SETFLIP		;Flip anim for Lefty
	SPRITE spkf0001,2
	SPRITE spkf0002,2
	SPRITE spkf0003,2
	SPRITE spkf0004,2
	SPRITE spkf0005,2
	SPRITE spkf0006,2
	SPRITE spkf0007,2
	SPRITE spkf0008,2
	SPRITE spkf0009,2
	SPRITE spkf0010,2
	SPRITE spkf0011,2

	DEALLOC


Homer1
.hold
	SPRITE homer1,10
	JUMP	.hold

Homer2
	SPRITE homer1,30
.hold
	SPRITE homer2,10
	JUMP	.hold

Homer3
	SPRITE homer1,30
	SPRITE homer2,30
.hold
	SPRITE homer3,10
	JUMP	.hold

Homer4
	SPRITE homer1,30
	SPRITE homer2,30
	SPRITE homer3,30
.hold
	SPRITE homer4,10
	JUMP	.hold

Homer5
	SPRITE homer1,30
	SPRITE homer2,30
	SPRITE homer3,30
	SPRITE homer4,30
.hold
	SPRITE homer5,10
	JUMP	.hold


bSp	equ	4

spinball
	SPRITE dall0001,bSp
	SPRITE dall0002,bSp
	SPRITE dall0003,bSp
	SPRITE dall0004,bSp
	SPRITE dall0005,bSp
	SPRITE dall0006,bSp
	SPRITE dall0007,bSp
	SPRITE dall0008,bSp
	SPRITE dall0009,bSp
	SPRITE dall0010,bSp
	SPRITE dall0011,bSp
	SPRITE dall0012,bSp
	SPRITE dall0013,bSp
	SPRITE dall0014,bSp
	SPRITE dall0015,bSp
	SPRITE dall0016,bSp
	SPRITE dall0017,bSp
	SPRITE dall0018,bSp
	SPRITE dall0019,bSp
	SPRITE dall0020,bSp
	SPRITE dall0021,bSp
	SPRITE dall0022,bSp
	SPRITE dall0023,bSp
	SPRITE dall0024,bSp
	SPRITE dall0025,bSp
	SPRITE dall0026,bSp
	SPRITE dall0027,bSp
	SPRITE dall0028,bSp
	SPRITE dall0029,bSp
	SPRITE dall0030,bSp

	JUMP	spinball

;***************************************************************************



