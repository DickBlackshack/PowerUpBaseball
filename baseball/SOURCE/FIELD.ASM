;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1996, IT, INC.	*
;***************************************************************************
	.region.s	"RAM"
	ds	0

	.import.s	Temp1,Temp2,Temp3,Temp4

FIRST		equ   1
SECOND		equ   2
THIRD		equ   3
HOME		equ   4
PITCH		equ   5

BALLCLOSE   	equ   4*12*256	; Check If Closer Than 48 Inches

ControlPtr	  	ds.l  1	; Address Of Controlling Object
MarkerPtr	  	ds.l  1 	; Address Of Fancy Ball Marker
Destination  	ds.w  1	; Ball Destination For Throw
Thrower	  	ds.l  1	; Address Of Ball Thrower
		      
ThrowTime	  	ds.w  1	; Counter Used In Throw
HitDirection 	ds.w  1	; Direction Of Hit (0-127)   64-Up THe Middle
SwitchReason 	ds.w  1	; Switch To Field Reason

FliedOut     	ds.b  1	; Set If Ball Was Caught On Fly
HomeRun	  	ds.b  1	; Set If Home Run Hit
Flyball		ds.b  1

FielderColor 	ds.w  1
RunnerColor  	ds.w  1
TrackRange		ds.w  1
OutCount	  	ds.b  1	; Number Of Out In This At Bat

PickOffTest  	ds.b  1
BallInFlight 	ds.b  1	; Set If Ball In Flight
BallActive		ds.b  1
BackupCount	ds.b  1	; Number Of Times Runner Backs Up

RunDirection 	ds.b  1	; Set to Direction 0 = formward, 1 = back
BallOffWall  	ds.b  1	; Set If Ball Bounced Off Wall
WallHeight   	ds.l  1	; Height Of Stadium Wall
HitDistance  	ds.l  1
MarkerDistance	ds.l  1
Outfielder	  	ds.b  1	; Set If Outfielder Is Active
Infielder	  	ds.b  1	; Set If Infielder Is Active
PlayNumber	  	ds.w  1
PlayType	  	ds.w  1
CatchYVel	  	ds.l  1	; Ball Y Velocity At Catch
PowerBallPal	ds.b  1   	; Palette for PowerBall

RunnerInst		ds.b  1   	; Runner Inst. Counter
FielderInst	ds.b  1   	; Fielder Inst. Counter
BatE		ds.b  1   	; Fielder Inst. Counter
DidGetHit		ds.b  1   	; Did Batter Register a hit? 0/1


;*********** The Next Four Locations Must Remain Together **************************
FirstCover   	ds.l  1	; Address Of Player Covering First
SecondCover  	ds.l  1	; Address Of Player Covering Second
ThirdCover   	ds.l  1	; Address Of Player Covering Third
;***********************************************************************************

saveda0		ds.l  1
saveda1		ds.l  1
saveda2		ds.l  1

SpeedCheck		ds.w  1
Speed		ds.l  1
Seeker1	 	ds.l  1	; Address Of Player Seeking Ball
Seeker2		ds.l  1	; Outfielder Seeking Ball
BallXVel		ds.l  1	; Ball X Velocity
BallYVel		ds.l  1	; Ball Y Velocity
BallZVel		ds.l  1	; Ball Z Velocity
BallX		ds.l  1	; Ball X Position
BallY		ds.l  1	; Ball Y Position
BallZ		ds.l  1	; Ball Z Position
BackupPlayer	ds.l  1

DistanceInc	ds.l  1	; Distance Increment
TotalDistance	ds.l  1	; Total Distance

WallFlag	  	ds.b  1

Closest		ds.w  1	; Closest Distance To Ball

RunTime		ds.w  1	; Time It Will Take Runner To Complete Run

BaseOCount		ds.b  1	; Counter Used To Flash Active Player

NoControl		ds.b  1	; Set If Controls Removed From Player
NoCatch		ds.b  1

BallRolling 	ds.b  1	; Set If Balling Rolling

RunnerAtSecond	ds.b  1	; Set If Runner Held At Second
RunnerAtThird	ds.b  1	; Set If Runner Held At Second
ForcedOut		ds.b  1	; Set If Runner Was Forced Out
WasGrand		ds.w  1	; was a grand slam

;***************************************************************************
;  Start Of Program Code		*
;***************************************************************************
	.region	"RomCode"

	ds	0

	#include	"itvideo2.h"
	#include	"sys.h"
	#include	"sys.mac"
	#include	"graphlib.mac"
	#include	"graphlib.h"
	#include	"graphglb.h"
	#include	"macros.h"
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
	#include	"ai.h"

	.export	CalcDirection
	.export	CalcDistance	; Calculate Distance
	.export	ClearUpField
	.export	ClearUp_1
	.export	HitDirection
	.export	InitField
	.export	MakeDust
	.export	PowerBallPal
	.export	RunDirection
	.export	TrackPlayer

	.import	AIBias
	.import	AIHomeRun	; Flag Home Run To AI
	.import	AllocObject
	.import	Anim
	.import	AnimPlayer
	.import	AreRunning
	.import.s	AtBatPlayer	; Pointer To Batting Control Block
	.import.s	AtPitPlayer	; Pointer To Pitcher Control Block
	.export	BackupCount
	.export	BallActive	; Set If Ball Not Picked Up
	.export	BallInFlight	; Ball Not Picked Up Yet
	.import.s	BallOnGround
	.import	BareHand	; Bare Hand Catch Animation
	.import.s	Baseball	; Baseball Object
        	.export 	BaseOMeter
	.import	BaseCount
	.import.s	Batter
	.import	BigSafeObj
	.import	BigOutObj
	.import	BigMesh
	.import	BlitAObject	; Display Anchored Object
	.import	BlitObject	; Standard Display Object
	.import	CalcBallPos	; Calculate Ball Position
	.import	CalcFieldCoord
	.import.s	Catcher	; Catcher Object
	.export	CatcherRun	; Catcher Running Animation
	.import	CATCHER_CONTROLS
	.import.s	CatchIBall,CatchCBall
	.export.s	CatchYVel	; Y Velocity At Catch
	.import.s	CenterField	; Center Fielder Object
	.import	CheckBases
	.export	CheckPowerUp
	.export	CheckPowerUp2
	.import	CheckRunning
	.import	ClearButtons
	.export	ControlPtr
	.export	CopyPlayer	; Copy Player Data
	.export	Destination	; Check If Ball Thrown To Base
	.export	DidGetHit	; batter got a hit
	.import	DisplayBall
	.import	DisplayField
	.import	DoDive
	.import	DoublePlayObj
	.import	DspBody	; Display Player
	.export	EndRun
	.import	FastCatch	; Fielder Catch Animation
	.import	FIELDER_CONTROLS
	.export	FielderRun	; Fielder Running Animation
	.import	FieldTeam
	.export	FielderInst   	; Fielder Inst. Counter
	.import	FielderIntro,CatcherIntro
	.export	FindNewFielder
	.import.s	FirstBase	; First Baseman Object
	.export	FirstCover	; Player Covering First
	.import.s	FirstRunner	; Runner To First Object
	.export	FliedOut	; Set If Ball Caught On Fly
	.export	Flyball	; Set If High Fly Ball
	.export	ForcedOut	; Forced Out Flag
	.import.s	FrameRate
	.import	GameMode
	.import	HelpSwitch
	.export	HitDistance	; Distance Ball Was Hit
	.export	HomeRun
	.import.s	HomeRunner	; Runner To Home Object
	.import	HomeRunX,HomeRunY
	.import	InitJoyWatch
	.import	InitObjects
	.import	Inning
	.import.s	LaserHit	; Set If Ball Hit By Light Sabre
	.import.s	AntiL	; Set If Anti Laser Powerup
	.import.s	LeftField	; Left Fielder Object
	.export	MarkerDistance
	.export	MarkerPtr
	.import.s	MoveGlove
	.import	NameNum
	.import	NoBatterControls
	.import	NoY
	.import	outs,NewOut,AddOut
	.export	Outfielder
	.export	PickOffTest
	.import.s	Pitcher	; Pitcher Object
	.import	PlayerR,PlayerL
	.export	PlayNumber,PlayType
	.import	PowerBar_1,PowerFrame
          	.import	PowerPtr,PowerPtr2
	.import	PowerBar_2
	.import.s	ProcessTime
	.import	Random	; Get A Random Number
	.import.s	RightField	; Right Fielder Object
	.export	RunnerInst   	; Runner Inst. Counter
	.export	RunnerRun	; Base Runner Running Animation
	.export	RunToDugout
	.export	RunToF,RunToS,RunToT,RunToH	; RAD 5/5/96
	.export	RunToFirst
	.export	RunToSecond
	.export	RunToThird
	.import	SaberOn
	.import	ScrewHim
	.import.s	SecondBase	; Second Baseman Object
	.import.s	SecondRunner	; Runner To Second Object
	.export	SecondCover	; Runner To Second Object
	.import	SecondRunX,SecondRunY
	.export	SetBaseFlags
	.import.s	ShortStop	; Short Stop Object
	.import	SndBit1,SndBit2
	.import	StadiumY	; Y Positions Of Stadium
	.export	SwitchReason	; Reason Field Was Switched To
	.import.s	ThirdBase	; Third Baseman Object
	.import.s	ThirdRunner	; Runner To Third Object
	.import	ThirdRunX,ThirdRunY
	.export	ThrowTime	; Time Ball Is In Flight
	.export	ThrowToFirst	; Throw Ball To First Base
	.export	ThrowToHome	; Throw Ball To Home Plate
	.export	ThrowToPitcher	; Throw Ball To Pitcher
	.export	ThrowToSecond	; Throw Ball To Second Base	
	.export	ThrowToThird	; Throw Ball To Third Base
	.import	WallLaser
	.export	WallImpact	; Fielder Run In With Wall
	.import	WinTestRun	; Check For Win After Run
	.import	FieldHelp	; Help Screen for Fielder
	.import	RunnerHelp	; Help Screen for Runners
	.import	SinglePlayer	; Single Player Flag
	.import.s	VintageHit	; Set If Vintage Player Hit Ball

	.export	RunnerInst   	; Runner Inst. Counter
	.export	FielderInst   	; Fielder Inst. Counter
	.export	WasGrand


;***************************************************************************
;   InitField - Set Up For Perspected Field		*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
InitField:
;	SOUND	#FieldViewMusic,#FieldViewMusic ; Init Sounds System

	clr.b	WasGrand
	SOUND	#LightSaberOff,#0	; Set Volume
	clr.b	SaberOn
	clr.b	OutCount	; Clear Number Of Outs
	clr.b	BallInFlight	; Ball Not In Flight
	clr.b	BallRolling	; Set If Ball Is Rolling
	clr.b	NoCatch 	; Catching Is Allowed
	move.b	#1,BallActive
	clr.b	FliedOut	; Clear Out Flag
	clr.b	HomeRun	; Clear Home Run Flag
	clr.w	Destination	; Clear Ball Destination
	clr.b	BallOffWall	; Clear Ball Off Wall Flag
	clr.b	BackupCount	; Clear Backup Count
	clr.w	SpeedCheck	; Check Speed Soon
	move.l	#18*12*256,WallHeight	; Set Height Of Stadium Wall

	move.l	AtBatPlayer,a1	; Load Address Of Batter
	move.w	#AI_RUNNING,AISTATUS(a1)	; Set AI Status
	move.l	AtPitPlayer,a1	; Load Address Of Pitcher
	move.w	#AI_FIELDING,AISTATUS(a1)	; Set AI Status

	jsr	InitJoyWatch	; Reinit Buttons
	jsr	InitObjects	; Remove All Objects

	move.l	#PlayerR,a6	; Load Right Player Controls
	jsr	ClearButtons	; Clear Out Buttons
	move.l	#PlayerL,a6	; Load Left Player Controls
	jsr	ClearButtons	; Clear Out Buttons

	clr.l	Batter+UPDATEPROC	; Turn Off Batter Updating
	clr.l	Batter+DISPLAYPROC	; Turn Off Batter Display

	jsr	AllocField	; Allocate Field Object
	jsr	InitBall	; Initialize Ball
	jsr	BaseOMeter	; Allocate Base-O-Meter
	jsr	PowerFrame	; Draw the Power Bar Frame
	jsr	PowerBar_1	; Draw the Power Bar Left
	jsr	PowerBar_2	; Draw the Power Bar Right
	jsr	InitCatcher	; Initialize Catcher
	jsr	GiveAssignments	; Give Assignments To All Players

	jsr	NoBatterControls	; no controls for the runner!
	move.w	SwitchReason,d0	; Load Switch Reason
	move.l	#PickOffs,a0	; Load Address Of Pickoff Plays
	move.l	#Pitcher,a5	; Load Address Of Thrower
	jsr	([a0,d0.w*4])	; Jump To Routine
	rts

PickOffs:
	dc.l	0	; 0 - No Switch Reason
	dc.l	BallHit	; 1 - Ball Was Hit
	dc.l	PickOffFirst	; 2 - First Base Pickoff
	dc.l	PickOffSecond	; 3 - Second Base Pickoff
	dc.l	PickOffThird	; 4 - Third Base Pickoff
	dc.l	ThrowToHome	; 5 - Home Pickoff
	dc.l	CatcherHas	; 6 - catcher has ball

BallHit:
	clr.l	Thrower	; Clear Throwing Object (Ball Was Hit)
	clr.w	ThrowTime	; Ball Was Not Thrown
	SOUND	#Crowd1,#0	; Set Volume
	move.b	#1,BallInFlight	; Flag Ball In Flight
	jsr	DoInstructions
	jsr	StartRunToFirst	; Start Up Runners
;	jsr	AssignControl	; Give Control To A Player
	rts

;***************************************************************************
;   DoInstructions - Print Instructions for players if they havent played	*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
DoInstructions:
	tst.b	GameMode
	beq       PrintAllInst
	bra	NotInFirst
	cmp.b	#1,Inning	;Are we in the first inning
	bgt	NotInFirst	;if not branch

	move.l	SinglePlayer,a4	;Move single player to a4
	tst.l	a4	;check if single player game
	beq	NotSingle	;branch if not
	cmp.b	#2,SinglePlayer+YND	;check for enter initials
	beq	NoInitials	;no initials, give instructions 
	cmp.w	#1,([SinglePlayer],stat_win);does player have 2 wins
	bgt	NotInFirst	;if yes skip
NoInitials:		;Below does help screens
	tst.b	GameMode
	beq       PrintAllInst
	move.l	SinglePlayer,d0	;move single player address to d0
	cmp.l	AtBatPlayer,d0	;is player batting 
	bne.s	FielderHelp	;branch if fielding
	cmp.b	#1,RunnerInst	;have inst. been printed?
	beq	NotInFirst	;if yes skip
;	jsr	BigMesh
	jsr	RunnerHelp	;call runner help
	move.b	#1,RunnerInst	;set inst. have been printed
	bra	NotInFirst	;skip everything
FielderHelp:
	cmp.b	#1,FielderInst	;have inst. been printed?
	beq	NotInFirst	;if yes skip
;	jsr	BigMesh
	jsr	FieldHelp	;call fielder help
	move.b	#1,FielderInst
	bra	NotInFirst
	
NotSingle:
;	bra.s	PrintAllInst	;for now... PlayerL+YND dosent work!

;	move.l	PlayerL,d0	;Move single player to d0
;	clr.l	d0
	cmp.b	#NoY,PlayerL+YND	;check for enter initials
	beq.s	PrintAllInst	;no initials then print
	move.l	PlayerR,a4	;Move single player to a4
	cmp.b	#2,PlayerR+YND	;check for enter initials
	beq.s	PrintAllInst	;no initials then print
	cmp.w	#1,PlayerL+stat_win	;does player have 2 wins
	blt.s	PrintAllInst	;not enough wins. Print
	cmp.w	#1,PlayerR+stat_win	;does player have 2 wins
	blt.s	PrintAllInst	;not enough wins. Print
	bra.s	NotInFirst

PrintAllInst:
;	jsr	Random	; Get A Random Number
;	and.w	#1,d0	; Extract 0-1
;	move.w	d0,HelpSwitch

	eor.w	#1,HelpSwitch
	cmp.b	#0,Inning	;Are we in the first inning
	bne.s 	NotBottom
	cmp.b	#2,RunnerInst	;have inst. been printed
	beq.s	NotInFirst	;yes branch don't print
;	jsr	BigMesh	;print mesh
	jsr	RunnerHelp	;call runner help
	move.b	#2,RunnerInst	;set inst. have been printed
	jsr	FieldHelp	;call fielder help
	move.b	#2,FielderInst	;set inst. have been printed
NotBottom:
	cmp.b	#1,RunnerInst	;have inst. been printed
	bge.s	NotInFirst	;yes branch don't print
	jsr	RunnerHelp	;call runner help
	move.b	#1,RunnerInst	;set inst. have been printed
	jsr	FieldHelp	;call fielder help
	move.b	#1,FielderInst	;set inst. have been printed
NotInFirst:
	rts

;***************************************************************************
;   PickOffFirst - Pickoff Throw To First		*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
PickOffFirst:
	jsr	StartStealers	; Start Up Stealing Runners
;	jsr	ForceReturn	; Force Runners Back To Base
	move.b	#1,BallOnGround

	move.l	#FirstBase,a1	; Load Address Of First Base

	move.l	#Pitcher,a0	; Load Address Of Controlled Player
	move.l	CONTROLBLOCK(a0),a2	; Load Address Of Control Block
	clr.l	CONTROLBLOCK(a0)	; Clear Control Block
	move.l	#AnimPlayer,UPDATEPROC(a0)	; Set For Standard Updating

	move.l	a1,ControlPtr	; Store Address Of Controlled Player
	move.l	#TrackPlayer,UPDATEPROC(a1)	; Set For Updating
	move.l	a2,CONTROLBLOCK(a1)	; Save Controls Address
	move.l	a1,CONTROLOBJECT(a2)	; Point Controls To Player
	clr.b	B_MOVABLE(a1)	; Don't Let Player Move

	move.l	FirstCover,a0	; Load Address Of First Base
	move.l	#70*MPH,d3	; Set For 70 MPH Throw
	move.l	#FIRSTBASEX,d4	; Set First Base X Position
	move.l	#FIRSTBASEY,d5	; Set First Base Y Position

	jsr	SetCatch	; Set Up For Ball Catch

	jsr	ThrowToXY	; Set For Throw
	move.w	#FIRST,Destination	; Save Destination Flag

	rts

;***************************************************************************
;   PickOffSecond - Pickoff Throw To Second		*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
PickOffSecond:
	jsr	StartStealers	; Start Up Stealing Runners
;	jsr	ForceReturn	; Force Runners Back To Base
    	move.b	#1,BallOnGround

	move.l	#SecondBase,a1	; Load Address Of Second Base

	move.l	#Pitcher,a0	; Load Address Of Controlled Player
	move.l	CONTROLBLOCK(a0),a2	; Load Address Of Control Block
	clr.l	CONTROLBLOCK(a0)	; Clear Control Block
	move.l	#AnimPlayer,UPDATEPROC(a0)	; Set For Standard Updating

	move.l	a1,ControlPtr	; Store Address Of Controlled Player
	move.l	#TrackPlayer,UPDATEPROC(a1)	; Set For Updating
	move.l	a2,CONTROLBLOCK(a1)	; Save Controls Address
	move.l	a1,CONTROLOBJECT(a2)	; Point Controls To Player
	clr.b	B_MOVABLE(a1)	; Don't Let Player Move

	move.l	#SecondBase,a0	; Load Address Of Second Base
	move.l	#70*MPH,d3	; Set For 70 MPH Throw
	move.l	#SECONDBASEX,d4	; Set First Base X Position
	move.l	#SECONDBASEY,d5	; Set First Base Y Position

	jsr	SetCatch	; Set Up For Ball Catch

	jsr	ThrowToXY	; Set For Throw
	move.w	#SECOND,Destination	; Save Destination Flag

	rts

;***************************************************************************
;   PickOffThird - Pickoff Throw To Third		*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
PickOffThird:
	jsr	StartStealers	; Start Up Stealing Runners
;	jsr	ForceReturn	; Force Runners Back To Base
    	move.b	#1,BallOnGround

	move.l	#ThirdBase,a1	; Load Address Of Third Base

	move.l	#Pitcher,a0	; Load Address Of Controlled Player
	move.l	CONTROLBLOCK(a0),a2	; Load Address Of Control Block
	clr.l	CONTROLBLOCK(a0)	; Clear Control Block
	move.l	#AnimPlayer,UPDATEPROC(a0)	; Set For Standard Updating

	move.l	a1,ControlPtr	; Store Address Of Controlled Player
	move.l	#TrackPlayer,UPDATEPROC(a1)	; Set For Updating
	move.l	a2,CONTROLBLOCK(a1)	; Save Controls Address
	move.l	a1,CONTROLOBJECT(a2)	; Point Controls To Player
	clr.b	B_MOVABLE(a1)	; Don't Let Player Move

	move.l	#ThirdBase,a0	; Load Address Of Third Base
	move.l	#70*MPH,d3	; Set For 65 MPH Throw
	move.l	#THIRDBASEX,d4	; Set First Base X Position
	move.l	#THIRDBASEY,d5	; Set First Base Y Position

	jsr	SetCatch	; Set Up For Ball Catch

	jsr	ThrowToXY	; Set For Throw
	move.w	#THIRD,Destination	; Save Destination Flag

	rts

	.export	CatcherHas
CatcherHas:
	move.l	#Baseball,a1	; Load Address Of The Baseball
	clr.l	WORLDXVEL(a1)	; Clear World X Velocity
	clr.l	WORLDYVEL(a1)	; Clear World Y Velocity
	clr.l	WORLDZVEL(a1)	; Clear World Z Velocity
	clr.l	WORLDX(a1)	; Place Ball At Home Plate X
	clr.l	WORLDY(a1)	; Place Ball At Home Plate Y
	clr.l	WORLDZ(a1)	; Place Ball At Home Plate Z
	clr.l	DISPLAYPROC(a1)	; Turn Off Ball
	clr.w	ThrowTime	; Ball Was Not Thrown
	move.l	#Catcher,a1	; Load Address Of Catcher
	move.b	#1,B_HASBALL(a1)	; Give Player The Ball
	move.b	#1,B_MOVABLE(a1)	; Make Catcher Movable
	move.b	#-1,STATIONARY(a1)	; Set As Stationary
	jsr	NewControl	; Give Control To Catcher
	move.b	#1,B_HASBALL(a1)	; Give Player The Ball
	move.l	#CATCHER_CONTROLS,INPUTROUTINE(a2) ; Set Input Controls
	rts

;***************************************************************************
;   StartStealers - Startup Runners When Pickoff Play Happens	*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
StartStealers:
	clr.b	FirstRunner+B_ONBASE	; First Runner Not In Use
	clr.b	FirstRunner+B_INUSE	; First Runner Not In Use

	move.l	#HomeRunner,a0	; Load Address Of Runner To Home
StartSteal_1:
	tst.b	B_INUSE(a0)	; Check If In Use
	bne.s	StartSteal_2	; Branch If It Is
	sub.l	#`sizeof(player_struct),a0	; Move To Previous Runner
	bra.s	StartSteal_1	; Loop Until Farthest Runner Found
StartSteal_2:
	move.l	AtBatPlayer,a1	; Load Control Block For Batter
	move.l	a1,CONTROLBLOCK(a0)	; Store Control Block Address Into Runner
	move.l	a0,CONTROLOBJECT(a1)	; Store Controlling Object
	move.l	#RunnerUpdate,ALWAYSROUTINE(a0) ; Start Checking

	move.l	#SecondRunner,a0	; Load Address Of Second Runner
	clr.b	B_FORCEBACK(a0)	; Not Forced Back Yet
	clr.b	B_FORCED(a0)	; Not Forced
	tst.b	B_INUSE(a0)	; Check If Running
	beq.s	StartSteal_3	; Branch If Not
	tst.b	B_ONBASE(a0)	; Check If On Base
	bpl.s	StartSteal_3	; Branch If He Is
	jsr	RunToSecond	; Set Runner To Second
	move.b	#-2,B_ONBASE(a0)	; Flag Running To Second From First
	clr.b	B_SLIDING(a0)	; Not Sliding Yet
StartSteal_3:
	move.l	#ThirdRunner,a0	; Load Address Of Batter
	clr.b	B_FORCEBACK(a0)	; Not Forced Back Yet
	clr.b	B_FORCED(a0)	; Not Forced
	tst.b	B_INUSE(a0)	; Check If Running
	beq.s	StartSteal_4	; Branch If Not
	tst.b	B_ONBASE(a0)	; Check If On Base
	bpl.s	StartSteal_4	; Branch If He Is
	jsr	RunToThird	; Set Runner To Third
	move.b	#-4,B_ONBASE(a0)	; Flag Running To Third From Second
	clr.b	B_SLIDING(a0)	; Not Sliding Yet
StartSteal_4:
	move.l	#HomeRunner,a0	; Load Address Of Batter
	clr.b	B_FORCEBACK(a0)	; Not Forced Back Yet
	clr.b	B_FORCED(a0)	; Not Forced
	tst.b	B_INUSE(a0)	; Check If Running
	beq.s	StartSteal_5	; Branch If Not
	tst.b	B_ONBASE(a0)	; Check If On Base
	bpl.s	StartSteal_5	; Branch If He Is
	jsr	RunToHome	; Set Runner To Home
	move.b	#-6,B_ONBASE(a0)	; Flag Running To Home From Third
	clr.b	B_SLIDING(a0)	; Not Sliding Yet
StartSteal_5:
	rts

;***************************************************************************
;   ForceReturn - Force Leadoffers Back To Base		*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
;ForceReturn:
;	move.l	#HomeRunner,a0	; Load Address Of Home Runner
;ForceR_1:
;	tst.b	B_INUSE(a0)	; Check If Runner In Use
;	beq.s	ForceR_4	; Branch If Not
;	move.b	B_ONBASE(a0),d1	; Check If On Base
;	bpl.s	ForceR_4	; Branch If On Base
;	move.l	#ForceBackTable,a1	; Load Address Of Back Table
;	ext.w	d1	; Extend To A Word
;	move.l	(a1,d1.w*4),d0	; Load Address Of Return Run
;	beq.s	ForceR_4	; Branch If Not Valid
;	clr.b	B_FORCED(a0)	; Clear Forced Flag
;	move.l	d0,a1	; Move To An Address Register
;	jsr	(a1)	; Return Runner
;ForceR_4:
;	sub.l	#`sizeof(player_struct),a0	; Move To Previous Runner
;	cmp.l	#FirstRunner,a0	; Check If Done
;	bne.s	ForceR_1	; Loop If Not
;	rts
	
;***************************************************************************
;   StartRunners - Startup Runners When Ball Is Hit	*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
StartRunToFirst:
	move.l	Batter+B_ROSTERADR,FirstRunner+B_ROSTERADR ; Transfer Roster Data
	clr.b	B_FORCED+SecondRunner	; Second Runner Not Forced
	clr.b	B_FORCED+ThirdRunner	; Third Runner Not Forced
	clr.b	B_FORCED+HomeRunner	; Home Runner Not Forced

	move.l	#FirstRunner,a0	; Load Address Of First Runner
	jsr	GetRunnerColor
	move.b	#1,B_INUSE(a0)	; Start Up Runner
	move.b	#1,B_FORCED(a0)	; Set Forced Run Flag
	clr.b	B_FORCEBACK(a0)	; Not Forced Back Yet
	clr.b	B_OUT(a0)	; Player Not Out
	jsr	RunToFirst	; Run To First
	move.b	#-1,B_ONBASE(a0)	; Flag Running To First From Home
	clr.b	B_SLIDING(a0)	; Not Sliding Yet
	move.w	#rt1d01,PICTURE(a0)	; Initialize Picture
	move.w	#rt1d01,CURRENTFRAME(a0)	; Initialize Current Frame

StartRunners:
	move.l	#HomeRunner,a0	; Load Address Of Runner To Home
StartRun_1:
	tst.b	B_INUSE(a0)	; Check If In Use
	bne.s	StartRun_2	; Branch If It Is
	sub.l	#`sizeof(player_struct),a0	; Move To Previous Runner
	bra.s	StartRun_1	; Loop Until Farthest Runner Found
StartRun_2:
	move.l	AtBatPlayer,a1	; Load Control Block For Batter
	move.l	a1,CONTROLBLOCK(a0)	; Store Control Block Address Into Runner
	move.l	a0,CONTROLOBJECT(a1)	; Store Controlling Object
	move.l	#RunnerUpdate,ALWAYSROUTINE(a0) ; Start Checking

	move.l	#SecondRunner,a0	; Load Address Of Second Runner
	jsr	GetRunnerColor
	clr.l	UPDATEPROC(a0)	; Set For No Updating
	clr.l	DISPLAYPROC(a0)	; Set For No Display
	clr.b	B_FORCEBACK(a0)	; Not Forced Back Yet
	tst.b	B_INUSE(a0)	; Check If Running
	beq.s	StartRun_4	; Branch If Not
	move.b	#1,B_FORCED(a0)	; Set Forced Run Flag
	jsr	RunToSecond	; Set Runner To Second
	move.b	#-2,B_ONBASE(a0)	; Flag Running To Second From First
	clr.b	B_SLIDING(a0)	; Not Sliding Yet

	move.l	#ThirdRunner,a0	; Load Address Of Third Runner
	jsr	GetRunnerColor
	clr.l	UPDATEPROC(a0)	; Set For No Updating
	clr.l	DISPLAYPROC(a0)	; Set For No Display
	clr.b	B_FORCEBACK(a0)	; Not Forced Back Yet
	tst.b	B_INUSE(a0)	; Check If Running
	beq.s	StartRun_4	; Branch If Not
	move.b	#1,B_FORCED(a0)	; Set Forced Run Flag
	jsr	RunToThird	; Set Runner To Third
	move.b	#-4,B_ONBASE(a0)	; Flag Running To Third From Second
	clr.b	B_SLIDING(a0)	; Not Sliding Yet

;	tst.b	Flyball	; Check For A Fly Ball
;	bne	StartRun_4	; Exit If It Is

	move.l	#HomeRunner,a0	; Load Address Of Home Runner
	jsr	GetRunnerColor
	clr.l	UPDATEPROC(a0)	; Set For No Updating
	clr.l	DISPLAYPROC(a0)	; Set For No Display
	clr.b	B_FORCEBACK(a0)	; Not Forced Back Yet
	tst.b	B_INUSE(a0)	; Check If Running
	beq.s	StartRun_4	; Branch If Not
	move.b	#1,B_FORCED(a0)	; Set Forced Run Flag
	jsr	RunToHome	; Set Runner To Home
	move.b	#-6,B_ONBASE(a0)	; Flag Running To Home From Third
	clr.b	B_SLIDING(a0)	; Not Sliding Yet
StartRun_4:
	rts

;***************************************************************************
;   GetRunnerColor - Change color of runners		*
;				*
;   Parameters :  a0			*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************

GetRunnerColor:
	move.l	B_ROSTERADR(a0),a1 ; Transfer Roster Data
	move.b	AT_ethnicity(a1),BatE	;Batter Race 0,1,2
	move.b	#P_HOMETPAL00,PALETTE(a0)	; Load Palette Number
	cmp.b	#2,BatE
	bne.s	NotB
	move.b	#P_HOMETPAL02,PALETTE(a0)	; Load Palette Number
NotB:
	move.b	#P_HOMEBPAL,B_BOTPALETTE(a0) ; Load Palette Number
	move.l	#RunnerRun,B_RUNNINGANIM(a0) ; Set For Running
     	tst.b	FieldTeam	; Which Team is up to Bat?
     	bne.s	HomePal2	; HomeTeam, then branch
	move.b	#P_VISTPAL00,PALETTE(a0)	; Load Palette Number
	cmp.b	#2,BatE
	bne.s	NotB2
	move.b	#P_VISTPAL02,PALETTE(a0)	; Load Palette Number
NotB2:	
	move.b	#P_VISBPAL,B_BOTPALETTE(a0)	; Load Palette Number
HomePal2:
	rts

;***************************************************************************
;   ForceBackRunners - Force Runners Back To Original Bases	*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
ForceBackRunners:
	PUSHL	a1,a3
	move.l	#HomeRunner,a0	; Load Address Of Home Runner
	move.w	#3,d7	; Load Base Runner Started From
ForceBackR_1:
	jsr	ForceBackRunner	; Force Back Runner
	sub.w	#1,d7	; Previous Base
	sub.l	#`sizeof(player_struct),a0	; Move To Previous Runner
	cmp.l	#FirstRunner,a0	; Check If Done
	bne.s	ForceBackR_1	; Loop If Not
	
	POPL	a1,a3
	rts

ForceBackRunner:
	tst.b	B_INUSE(a0)	; Check If Runner Is In Use
	beq.s	ForceBack_2	; Branch If Not 
	clr.b	B_FORCEBACK(a0)	; Clear Forced Back Flag
	clr.b	B_FORCED(a0)	; Clear Forced Back Flag
	move.b	B_ONBASE(a0),d1	; Load On Base Flag
	cmp.b	d7,d1	; Check If On Correct Base
	beq.s	ForceBack_2	; Branch If Fine

	clr.l	ALWAYSROUTINE(a0)	; Clear Always Routine
	move.b	#1,B_FORCED(a0)	; Set Forced Flag
	move.b	d7,B_FORCEBACK(a0)	; Store Base Being Forced To
	ext.w	d1	; Extend To A Word
	move.l	#ForceBackBases,a1	; Load Address Of Back Table
	move.b	(a1,d1.w),d0	; Load On Base Flag
	beq.s	ForceBack_2	; Branch If Not Valid
	move.b	d0,B_ONBASE(a0)	; Set On Base Flag
	move.l	#ForceBackTable,a1	; Load Address Of Back Table
	move.l	(a1,d1.w*4),d0	; Load Address Of Return Run
	beq.s	ForceBack_2	; Branch If Not Valid
	move.l	d0,a1	; Move To An Address Register
	PUSHL	d7	; Save D7
	jsr	(a1)	; Return Runner
	POPL	d7	; Retrieve D7
ForceBack_2:
	rts

	dc.l	RunToThird	; -7 - From Home To Third
	dc.l	RunToThird	; -6 - From Third To Home
	dc.l	RunToSecond	; -5 - From Third To Second
	dc.l	RunToSecond	; -4 - From Second To Third
	dc.l	RunToFirst	; -3 - From Second To First
	dc.l	RunToFirst	; -2 - From First To Second
	dc.l	0	; -1 - From Home To First
ForceBackTable:
	dc.l	0	;  0 - Inactive
	dc.l	0	;  1 - On First Base
	dc.l	RunToFirst	;  2 - On Second Base
	dc.l	RunToSecond	;  3 - On Third Base
	dc.l	RunToThird	;  4 - On Home Plate
	dc.l	0	;  5 - In Dug Out

	dc.b	-7	; -7 - From Home To Third
	dc.b	-7	; -6 - From Third To Home
	dc.b	-5	; -5 - From Third To Second
	dc.b	-5	; -4 - From Second To Third
	dc.b	-3	; -3 - From Second To First
	dc.b	-3	; -2 - From First To Second
	dc.b	0	; -1 - From Home To First
ForceBackBases:
	dc.b	0	;  0 - Inactive
	dc.b	0	;  1 - On First Base
	dc.b	-3	;  2 - On Second Base
	dc.b	-5	;  3 - On Third Base
	dc.b	-7	;  4 - On Home Plate
	dc.b	0	;  5 - In Dug Out

	.align	2
;***************************************************************************
;   RunToFirst - Run To First		*
;				*
;   Parameters :  A0 - Address Of Runner Object		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
	.export	RunToFirst
RunToFirst:
	move.b	#RunnerTopBank,BANK(a0)	; Load Runner Bank Number
	move.l	#RunnerRun,B_RUNNINGANIM(a0) ; Set For Running
	move.w	#FIRST,B_RUNNERGOAL(a0)	; Set Runner's Goal
	move.l	#28*MPH,d3	; Set For 28 MPH Run
	move.l	#FIRSTBASEX,d4	; Load First Base X Position
	move.l	#FIRSTBASEY-0x80,d5	; Load First Base Y Position
	move.l	#EndRunToFirst,a2	; Ending For First Base Run
	move.w	#AT_SPEED,d1	; Use Speed Attribute
	jsr	RunToXY	; Run To Base
	rts

;***************************************************************************
;   RunToSecond - Run To Second		*
;				*
;   Parameters :  A0 - Address Of Runner Object		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
FRunToSecond:
	move.l	#30*MPH,d3	; Set For 30 MPH Run
	bra.s	RunToSecond_1
SRunToSecond:
;	tst.b	RunnerAtSecond	; Check If Runner Held At Third
;	bne.s	RunToSecond_2	; Hold Runner If There Is

;	move.l	Baseball+WORLDX,d6	; Load World Position
;	sub.l	WORLDX(a0),d6	; Subtract Runner's X
;	move.l	Baseball+WORLDY,d7	; Load World Position
;	sub.l	WORLDY(a0),d7	; Subtract Runner's Y
;	jsr	CalcDistance	; Calculate Distance
;	cmp.l	#30*12*256,d1	; Check For Thirty Feet
;	ble.s	RunToSecond_2	; Exit If Less
	
	move.l	AtBatPlayer,a1	; Load Address Of Runner Controls
	btst.b	#0,RAWBUTTONS(a1)	; Check If Button Held
	beq.s	RunToSecond_2	; Branch If It Isn't

;	move.l	FirstCover,a1	; Load Address Of Coverer
;	tst.b	B_HASBALL(a1)	; Check If He Has The Ball
;	bne.s	RunToSecond_2	; Exit If He Does

	SOUND	#HeRoundsFirst,#0	; Running To Second
RunToSecond:
	move.l	#15*MPH,d3	; Set For 15 MPH Run
RunToSecond_1:
	move.b	#RunnerTopBank,BANK(a0)	; Load Runner Bank Number
	move.l	#RunnerRun,B_RUNNINGANIM(a0) ; Set For Running
	move.w	#SECOND,B_RUNNERGOAL(a0)	; Set Runner's Goal
	move.l	#SECONDBASEX,d4	; Load Second Base X Position
	move.l	#SECONDBASEY-0x80,d5	; Load Second Base Y Position
	move.l	#EndRunToSecond,a2	; Ending For Second Base Run
	move.w	#AT_SPEED,d1	; Use Speed Attribute
	jsr	RunToXY	; Run To Base
	clr.b	d0	; Flag Fineness
	rts
RunToSecond_2:
	move.b	#1,B_ONBASE(a0)	; Still On First
	rts

;***************************************************************************
;   RunToThird - Run To Third		*
;				*
;   Parameters :  A0 - Address Of Runner Object		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
FRunToThird:
	move.l	#30*MPH,d3	; Set For 30 MPH Run
	bra.s	RunToThird_1
SRunToThird:
	move.b	#1,RunnerAtSecond	; Runner Held Flag
;	tst.b	RunnerAtThird	; Check If Runner Held At third
;	bne.s	RunToThird_2	; Branch If There Is

;	move.l	Baseball+WORLDX,d6	; Load World Position
;	sub.l	WORLDX(a0),d6	; Subtract Runner's X
;	move.l	Baseball+WORLDY,d7	; Load World Position
;	sub.l	WORLDY(a0),d7	; Subtract Runner's Y
;	jsr	CalcDistance	; Calculate Distance
;	cmp.l	#30*12*256,d1	; Check For Thirty Feet
;	ble.s	RunToThird_2	; Exit If Less
	
	btst.b	#1,([AtBatPlayer],RAWBUTTONS) ; Check If Button Held
	beq.s	RunToThird_2	; Branch If It Isn't

;	move.l	SecondCover,a1	; Load Address Of Coverer
;	tst.b	B_HASBALL(a1)	; Check If He Has The Ball
;	bne.s	RunToThird_2	; Exit If He Does
RunToThird:
	move.l	#15*MPH,d3	; Set For 15 MPH Run
	clr.b	RunnerAtSecond	; Clear Runner Held Flag
RunToThird_1:
	move.b	#RunnerTopBank,BANK(a0)	; Load Runner Bank Number
	move.l	#RunnerRun,B_RUNNINGANIM(a0) ; Set For Running
	move.w	#THIRD,B_RUNNERGOAL(a0)	; Set Runner's Goal
	move.l	#THIRDBASEX,d4	; Load Third Base X Position
	move.l	#THIRDBASEY-0x80,d5	; Load Third Base Y Position
	move.l	#EndRunToThird,a2	; Ending For Third Base Run
	move.w	#AT_SPEED,d1	; Use Speed Attribute
	jsr	RunToXY	; Run To Base
	clr.b	d0	; Flag Fineness
	rts
RunToThird_2:
	move.b	#2,B_ONBASE(a0)	; Still On Second
	rts

;***************************************************************************
;   RunToHome - Run To Home		*
;				*
;   Parameters :  A0 - Address Of Runner Object		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
	.export	RunToHome
FRunToHome:
	move.l	#30*MPH,d3	; Set For 30 MPH Run
	bra.s	RunToHome_1
SRunToHome:
	move.b	#1,RunnerAtThird	; Set Runner Held At Third Flag

;	move.l	Baseball+WORLDX,d6	; Load World Position
;	sub.l	WORLDX(a0),d6	; Subtract Runner's X
;	move.l	Baseball+WORLDY,d7	; Load World Position
;	sub.l	WORLDY(a0),d7	; Subtract Runner's Y
;	jsr	CalcDistance	; Calculate Distance
;	cmp.l	#20*12*256,d1	; Check For Thirty Feet
;	ble.s	RunToHome_2	; Exit If Less

	btst.b	#2,([AtBatPlayer],RAWBUTTONS) ; Check If Button Held
	beq.s	RunToHome_2	; Branch If It Isn't

;	move.l	ThirdCover,a1	; Load Address Of Coverer
;	tst.b	B_HASBALL(a1)	; Check If He Has The Ball
;	bne.s	RunToHome_2	; Exit If He Does
	SOUND	#HesHeadedForHome,#0
RunToHome:
	move.l	#15*MPH,d3	; Set For 15 MPH Run
RunToHome_1:
	clr.b	RunnerAtThird	; Clear Runner Held At Third Flag
	move.b	#RunnerTopBank,BANK(a0)	; Load Runner Bank Number
	move.l	#RunnerRun,B_RUNNINGANIM(a0) ; Set For Running
	move.w	#HOME,B_RUNNERGOAL(a0)	; Set Runner's Goal
	move.l	#HOMEPLATEX,d4	; Load Home Plate X Position
	move.l	#HOMEPLATEY,d5	; Load Home Plate Y Position
	move.l	#EndRunToHome,a2	; Ending For Home Plate Run
	move.w	#AT_SPEED,d1	; Use Speed Attribute
	jsr	RunToXY	; Run To Home
	clr.b	d0	; Flag Fineness
	rts
RunToHome_2:
	move.b	#3,B_ONBASE(a0)	; Still On Third
	rts

;***************************************************************************
;   RunToDugout - Run To Dug Out		*
;				*
;   Parameters :  A0 - Address Of Runner Object		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
RunToDugout:
	tst.b	B_INUSE(a0)	; Check If Player In Use
	beq.s	RunToDug_9	; Branch If Not
	move.l	a0,a2	; Move Outted Player Address To A2
RunToDug_1:
	tst.b	B_FORCEBACK(a2)	; Check If Forced Back By Catch
	bne.s	RunToDug_2	; Skip If It Was
	clr.b	B_FORCED(a2)	; Clear Forced Flag
RunToDug_2
	add.l	#`sizeof(player_struct),a2	; Index To Next Runner
	cmp.l	#HomeRunner,a2	; Check If Done
	ble.s	RunToDug_1	; Continue Until All Done

	move.b	#5,B_ONBASE(a0)	; Set For Dug Out
	move.l	#25*MPH,d3	; Set For 25 MPH Run
	move.l	#481*256,d4	; Load Dug Out X Position
	move.l	#156*256,d5	; Load Dug Out Y Position
	move.l	#EndDugOut,a2	; Ending For Dug Out Run
	move.w	#AT_SPEED,d1	; Use Speed Attribute
	jsr	RunToXY	; Run To Dug Out
RunToDug_9:
	rts

;***************************************************************************
;   BaseOMeter - Display Base-O-Meter		*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
	.export	BaseOMeter
BaseOMeter:
	jsr	AllocObject	; Allocate An Object
	beq.s	BaseO_2	; Branch If None
	move.l	#OutfieldMeter,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	tst.w	SwitchReason	; Check If In Field View
	bne.s	BaseO_1	; Branch If It Is
	move.l	#InfieldMeter,DISPLAYPROC(a0) ; Store Address Of Display Procedure
BaseO_1:
	clr.l	UPDATEPROC(a0)	; Clear Animation Routine
	move.w	#126,ZPOSITION(a0)	; Initialize Z Position
	clr.w	PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	#10,XPOSITION(a0)	; Set X Position
	move.w	#10,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary

	move.w	#blipred,FielderColor	; Set For Red Fielders
	move.w	#blipblu,RunnerColor	; Set For Blue Runners
	cmp.l	#PlayerL,AtPitPlayer	; Check If Left Player Fielder
	beq.s	BaseO_2	; Branch If They Are
	move.w	#blipred,RunnerColor	; Set For Red Runners
	move.w	#blipblu,FielderColor	; Set For Blue Fielders
BaseO_2:
	rts

InfieldMeter:
	IMAGES	#Misc	; Load Image Bank
	move.w	#130,d4	; 2 byte x value
	move.w	#1,d5	; Load Y Position
	APALETTE	#P_NEWSCORE	; Palette Number
	move.w	#namea,d3	; load Frame Number
	cmp.l	#PlayerL,AtPitPlayer	; Check If Left Player Fielder
	beq.s	IsPlayerL
	move.w	#nameb,d3	; load Frame Number
IsPlayerL:
	jsr	Blit	; Blit The Object

	IMAGES	#Cards	; Load Image Bank
	move.w	#140,d4	; 2 byte x value
	move.w	#3,d5	; Load Y Position
	APALETTE	#P_NEWSCORE	; Palette Number
;	move.l	ControlPtr,a0	; Load Address Of Controlled Player
	move.b	([AtPitPlayer],FIRSTPITCHER),d0
	move.l	([AtPitPlayer],d0.w*4,ROSTERPTR),a1
	move.w	AT_nameart(a1),d3
;	move.l	AtPitPlayer,a0	; Load Address Of Controlled Player
;	move.w	([B_ROSTERADR,a0],AT_nameart),d3 ; Fielder Name from Roster
	jsr	Blit	; Blit The Object

	IMAGES	#Misc	; Load Image Bank

;	move.w	#10+11,d4	; 2 byte x value
;	move.w	#10+12,d5	; Load Y Position
	move.w	#10,d4	; 2 byte x value
	move.w	#10,d5	; Load Y Position
	APALETTE	#P_BALL	; Palette Number
	move.w	#meter06,d3	; Reload Frame Number
	jsr	Blit	; Blit The Object

	APALETTE	#P_BALL	; Palette Number

	move.l	#Pitcher,a6	; Load Address Of Pitcher
InMeter_2:
	cmp.l	ControlPtr,a6	; Check If This Controlled
	bne.s	InMeter_3	; Branch If Not
	btst.b	#0,BaseOCount	; Check If Display Time
	beq.s	InMeter_4	; Branch If Not Time
InMeter_3:
	move.l	WORLDX(a6),d4	; Load Fielder X Position
	asr.l	#8,d4	; Extract Inches
	asr.l	#5,d4	; Extract 32 Inch Increments
	add.w	#43+10,d4	; Add In Screen X Position
	move.l	WORLDY(a6),d5	; Load Fielder Y Position
	asr.l	#8,d5	; Extract Inches
	asr.l	#5,d5	; Extract 64 Inch Increments
	neg.l	d5	; Negate The Result
	add.w	#68+10,d5	; Add In Screen Y Position
	move.w	FielderColor,d3	; Reload Frame Number
	jsr	Blit	; Blit The Object
InMeter_4:
	add.l	#`sizeof(player_struct),a6	; Index To Next Fielder
	cmp.l	#Catcher,a6	; Check If Done
	ble.s	InMeter_2	; Branch If Not

	move.l	#FirstRunner,a6	; Load Address Of Pitcher
InMeter_5:
	tst.b	B_INUSE(a6)	; Check If In Use
	beq.s	InMeter_6	; Branch If Not
	move.l	WORLDX(a6),d4	; Load Fielder X Position
	asr.l	#8,d4	; Extract Inches
	asr.l	#5,d4	; Extract 64 Inch Increments
	add.w	#43+10,d4	; Add In Screen X Position
	move.l	WORLDY(a6),d5	; Load Fielder Y Position
	asr.l	#8,d5	; Extract Inches
	asr.l	#5,d5	; Extract 64 Inch Increments
	neg.l	d5	; Negate The Result
	add.w	#68+10,d5	; Add In Screen Y Position
	move.w	RunnerColor,d3	; Reload Frame Number
	jsr	Blit	; Blit The Object
InMeter_6:
	add.l	#`sizeof(player_struct),a6	; Index To Next Fielder
	cmp.l	#HomeRunner,a6	; Check If Done
	ble.s	InMeter_5	; Branch If Not

	move.l	#Baseball,a6	; Load Address Of Ball
	move.l	WORLDX(a6),d4	; Load Ball X Position
	asr.l	#8,d4	; Extract Inches
	asr.l	#5,d4	; Extract 64 Inch Increments
	add.w	#43+10,d4	; Add In Screen X Position
	move.l	WORLDY(a6),d5	; Load Ball Y Position
	asr.l	#8,d5	; Extract Inches
	asr.l	#5,d5	; Extract 64 Inch Increments
	neg.l	d5	; Negate The Result
	add.w	#68+10,d5	; Add In Screen Y Position
	move.w	#blipwhi,d3	; Reload Frame Number
	jsr	Blit	; Blit The Object

	move.l	MarkerPtr,d0	; Load Address Of Marker
	beq.s	InMeter_9	; Branch If None
	move.l	d0,a6	; Move To A6
	move.l	WORLDX(a6),d4	; Load Marker X Position
	asr.l	#8,d4	; Extract Inches
	asr.l	#6,d4	; Extract 64 Inch Increments
	add.w	#43+10,d4	; Add In Screen X Position
	move.l	WORLDY(a6),d5	; Load Marker Y Position
	asr.l	#8,d5	; Extract Inches
	asr.l	#6,d5	; Extract 64 Inch Increments
	neg.l	d5	; Negate The Result
	add.w	#68+10,d5	; Add In Screen Y Position
	move.w	#blipx,d3	; Reload Frame Number
	jsr	Blit	; Blit The Object
InMeter_9:
	rts

OutfieldMeter:
;
;	Display Fielder Name
;
	IMAGES	#Misc	; Load Image Bank
	move.w	#130,d4	; 2 byte x value
	move.w	#1,d5	; Load Y Position
	APALETTE	#P_NEWSCORE	; Palette Number
	move.w	#namea,d3	; load Frame Number
	cmp.l	#PlayerL,AtPitPlayer	; Check If Left Player Fielder
	beq.s	IsPlayerL_2
	move.w	#nameb,d3	; load Frame Number
IsPlayerL_2:
	jsr	Blit	; Blit The Object

	IMAGES	#Cards	; Load Image Bank
	move.w	#140,d4	; 2 byte x value
	move.w	#3,d5	; Load Y Position
	APALETTE	#P_NEWSCORE	; Palette Number
	move.l	ControlPtr,a0	; Load Address Of Controlled Player
	move.w	([B_ROSTERADR,a0],AT_nameart),d3 ; Fielder Name from Roster
	jsr	Blit	; Blit The Object

OutMeter_1:
	addq.b	#1,BaseOCount	; Increment Counter
	IMAGES	#Misc	; Load Image Bank

	move.w	#10,d4	; 2 byte x value
	move.w	#10,d5	; Load Y Position
;	APALETTE	#P_BASEOMETER	; Palette Number
	APALETTE	#P_BALL	; Palette Number
	move.w	#meter05,d3	; Reload Frame Number
	jsr	Blit	; Blit The Object

	APALETTE	#P_BALL	; Palette Number

	move.l	#Pitcher,a6	; Load Address Of Pitcher
OutMeter_2:
	cmp.l	ControlPtr,a6	; Check If This Controlled
	bne.s	OutMeter_3	; Branch If Not
	btst.b	#0,BaseOCount	; Check If Display Time
	beq.s	OutMeter_4	; Branch If Not Time
OutMeter_3:
	move.l	WORLDX(a6),d4	; Load Fielder X Position
	asr.l	#8,d4	; Extract Inches
	asr.l	#6,d4	; Extract 64 Inch Increments
	add.w	#43+10,d4	; Add In Screen X Position
	move.l	WORLDY(a6),d5	; Load Fielder Y Position
	asr.l	#8,d5	; Extract Inches
	asr.l	#6,d5	; Extract 64 Inch Increments
	neg.l	d5	; Negate The Result
	add.w	#68+10,d5	; Add In Screen Y Position
	move.w	FielderColor,d3	; Reload Frame Number
	jsr	Blit	; Blit The Object
OutMeter_4:
	add.l	#`sizeof(player_struct),a6	; Index To Next Fielder
	cmp.l	#RightField,a6	; Check If Done
	ble.s	OutMeter_2	; Branch If Not

	move.l	#FirstRunner,a6	; Load Address Of Pitcher
OutMeter_5:
	tst.b	B_INUSE(a6)	; Check If In Use
	beq.s	OutMeter_6	; Branch If Not
	move.l	WORLDX(a6),d4	; Load Fielder X Position
	asr.l	#8,d4	; Extract Inches
	asr.l	#6,d4	; Extract 64 Inch Increments
	add.w	#43+10,d4	; Add In Screen X Position
	move.l	WORLDY(a6),d5	; Load Fielder Y Position
	asr.l	#8,d5	; Extract Inches
	asr.l	#6,d5	; Extract 64 Inch Increments
	neg.l	d5	; Negate The Result
	add.w	#68+10,d5	; Add In Screen Y Position
	move.w	RunnerColor,d3	; Reload Frame Number
	jsr	Blit	; Blit The Object
OutMeter_6:
	add.l	#`sizeof(player_struct),a6	; Index To Next Fielder
	cmp.l	#HomeRunner,a6	; Check If Done
	ble.s	OutMeter_5	; Branch If Not

	move.l	#Baseball,a6	; Load Address Of Ball
	move.l	WORLDX(a6),d4	; Load Ball X Position
	asr.l	#8,d4	; Extract Inches
	asr.l	#6,d4	; Extract 64 Inch Increments
	add.w	#43+10,d4	; Add In Screen X Position
	move.l	WORLDY(a6),d5	; Load Ball Y Position
	asr.l	#8,d5	; Extract Inches
	asr.l	#6,d5	; Extract 64 Inch Increments
	neg.l	d5	; Negate The Result
	add.w	#68+10,d5	; Add In Screen Y Position
	move.w	#blipwhi,d3	; Reload Frame Number
	jsr	Blit	; Blit The Object

	move.l	MarkerPtr,d0	; Load Address Of Marker
	beq.s	OutMeter_9	; Branch If None
	move.l	d0,a6	; Move To A6
	move.l	WORLDX(a6),d4	; Load Marker X Position
	asr.l	#8,d4	; Extract Inches
	asr.l	#6,d4	; Extract 64 Inch Increments
	add.w	#43+10,d4	; Add In Screen X Position
	move.l	WORLDY(a6),d5	; Load Marker Y Position
	asr.l	#8,d5	; Extract Inches
	asr.l	#6,d5	; Extract 64 Inch Increments
	neg.l	d5	; Negate The Result
	add.w	#68+10,d5	; Add In Screen Y Position
	move.w	#blipx,d3	; Reload Frame Number
	jsr	Blit	; Blit The Object
OutMeter_9:
	rts

;***************************************************************************
;   GiveAssignments - Assign Control To Fielders		*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
	.export	GiveAssignments
GiveAssignments:
	clr.l	Seeker1	; Clear Seeking Player
	move.l	#PickOffPlay,a5	; Load Address Of Pickoff Play
	tst.b	PickOffTest	; Check If Pick Off
	bne.s	GiveAss_6A	; Branch If It Is

	jsr	AllocMarker	; Allocate Impact Marker
	jsr	AssignControl	; Assign Control To A Fielder

	clr.w	d7	; Clear D0
	tst.b	HomeRunner+B_INUSE	; Check Man On Third Flag
	beq.s	GiveAss_1	; Branch If Not
	bset	#2,d7	; Set Man On Third Bit
GiveAss_1:
	tst.b	ThirdRunner+B_INUSE	; Check Man On Second Flag
	beq.s	GiveAss_2	; Branch If Not
	bset	#1,d7	; Set Man On Second Bit
GiveAss_2:
	tst.b	SecondRunner+B_INUSE	; Check Man On First Flag
	beq.s	GiveAss_3	; Branch If Not
	bset	#0,d7	; Set Man On First Bit
GiveAss_3:
	lsl.w	#3,d7	; Multiply By 8 Plays Per Base Type
	add.w	PlayType,d7	; Add In Play Type

	move.l	#Plays,a5	; Load Address Of Plays
	move.l	(a5,d7.w*4),a5	; Load Address Of Selected Play

	tst.b	ScrewHim	; Check If Screw Time
	beq.s	GiveAss_6	; Branch If It Is
	move.l	#ScrewPlay,a5	; Load Address Of Screw Play
GiveAss_6:

;	move.l	#B3011,a5	; FORCE PITCHER PLAY

	move.w	d7,PlayNumber	; Save For Display

GiveAss_6A:
	move.l	#Pitcher,a6	; Load Address Of Pitcher
GiveAss_7:
	move.l	a6,a0	; Move Player Address To A0
	clr.b	B_COVERING(a0)	; Flag Not Covering
	move.w	(a5)+,d0	; Load Command
	lea.l	AssignJump,a1	; Load Address Of Jump Table
	jmp	([a1,d0.w*4])	; Jump To Routine

AssignJump:
	dc.l	Assign_Cover	; 0 - COVER     Command
	dc.l	Assign_Seek	; 1 - SEEK      Command
	dc.l	Assign_Seekball	; 2 - SEEKBALL  Command
	dc.l	Assign_Backup	; 3 - BACKUP    Command
	dc.l	Assign_Stop	; 4 - STOP      Command
	dc.l	Assign_FastCover	; 5 - FASTCOVER Command

Assign_FastCover:
	move.l	#60*MPH,d3	; Set For 50 MPH Run
	bra.s	AssCover_1
Assign_Cover:
	move.l	#30*MPH,d3	; Set For 30 MPH Run
AssCover_1:
	move.b	#1,B_COVERING(a0)	; Flag An Infielder Covering A Base
	move.w	(a5)+,d0	; Load Base To Cover
	move.l	#FirstCover,a1	; Load Address Of Cover Storage
	move.l	a0,(a1,d0.w*4)	; Save Address Of Player Covering Base
	move.l	#Bases,a1	; Load Address Of Bases Info
	asl.w	#3,d0	; Multiply By Eight
	move.l	(a1,d0.w),d4	; Load X Position For Seek
	move.l	4(a1,d0.w),d5	; Load Y Position For Seek
	move.l	#EndRunC,a2	; Ending For Run
	move.w	#AT_SPEED,d1	; Use Speed Attribute
	jsr	RunToXY	; Set For Run
	bra	GiveAss_8

Assign_Seek:
	move.l	#30*MPH,d3	; Set For 30 MPH Run
	move.w	(a5)+,d4	; Load X Position For Seek
	ext.l	d4	; Extend To A Long
	asl.l	#8,d4	; Shift Inches Into Next Byte
	move.w	(a5)+,d5	; Load Y Position For Seek
	ext.l	d5	; Extend To A Long
	asl.l	#8,d5	; Shift Inches Into Next Byte
	move.l	WORLDY(a0),d0	; Move Y Position To D0
	sub.l	d5,d0	; Subtract Marker Position
	cmp.l	#150*12*256,d0	; Check If 150 Feet Away
	bge	GiveAss_8	; Skip It If It Is
	move.l	#EndRun,a2	; Ending For Run
	move.w	#AT_RANGE,d1	; Use Range Attribute
	jsr	RunToXY	; Set For Run
	bra	GiveAss_8

Assign_Seekball:
	move.l	a0,Seeker1	; Save Address Of Seeker
	bra.s	GiveAss_8	; Branch If He Will

Assign_Backup:
Assign_Stop:
	move.l	#EndRun,PARSEPOINTER(a0)	; Set Animation
;	bra.s	GiveAss_8

GiveAss_8:
	add.l	#`sizeof(player_struct),a6	; Index To Next Fielder
	cmp.l	#ThirdBase,a6	; Check If Done
	ble	GiveAss_7	; Branch If Not

	jsr	CalcBallTraj	; Calculate Ball Trajectory
	
;	move.l	BackupPlayer,d0	; Load Backup Player Address
;	beq.s	GiveAss_9	; Branch If Not
;	move.l	d0,a0	; Move To A0
;	move.l	#30*MPH,d3	; Set For 30 MPH Run
;	move.l	BallStopX,d4	; Load Ball X Position
;	move.l	BallStopY,d5	; Load Ball Y Position
;	move.l	#EndBackupRun,a2	; Ending For Run
;	move.w	#AT_RANGE,d1	; Use Range Attribute
;	jsr	RunToXY	; Set For Run

GiveAss_9:
	move.l	ControlPtr,a1	; Load Address Of Controlled Player
	move.l	AtPitPlayer,a0	; Load Address Of Fielding Team

	move.b	#1,B_MOVABLE(a1)	; Allow Player To Move
	move.l	#TrackPlayer,UPDATEPROC(a1)	; Give Control To A Player
	move.l	a1,CONTROLOBJECT(a0)	; Save Address Of Controlling Object
	move.l	a0,CONTROLBLOCK(a1)	; Set Controls
	move.l	#FIELDER_CONTROLS,INPUTROUTINE(a0) ; Set Input Controls to Fielder

	rts

Bases:
	dc.l	FIRSTBASEX,FIRSTBASEY	; First Base
	dc.l	SECONDBASEX,SECONDBASEY	; Second Base
	dc.l	THIRDBASEX,THIRDBASEY	; Third Base
	dc.l	HOMEPLATEX,HOMEPLATEY	; Home Plate

;***************************************************************************
;   AssignControl - Assign Control To Closest Fielder	*
;				*
;   Parameters :  A0 - Address Of Control Block		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
	.export	AssignControl
AssignControl:
	move.l	Pitcher+CONTROLBLOCK,a0	; Load Address Of Pitcher
	move.b	BOZOFACTOR(a0),NoControl	; Give Player Control Sometime
	clr.w	TRACKX(a0)	; Clear Track Ball X
	clr.w	TRACKY(a0)	; Clear Track Ball Y

	move.l	#Pitcher,a1	; Load Address Of Pitcher
	clr.l	CONTROLBLOCK(a1)	; Take Control Away From Pitcher

	move.b	#FielderTopBank,BANK(a1)	; SetBank Number
	move.w	#f21x01,PICTURE(a1)	; Set Picture
	move.w	#f21x01,CURRENTFRAME(a1)	; Set Picture
	move.w	#1,DURATION(a1)

	clr.b	Outfielder	; Outfielder Not Active
	clr.b	Infielder	; Infielder Not Active

	tst.b	HomeRun	; Check For Possible Home Run
	beq.s	AssCont_1	; Branch If Not

	move.l	#Outfielders,a1	; Load Address Of Outfielders
	move.w	HitDirection,d0	; Load Hit Direction
	lsr.w	#3,d0	; Divide By Eight (0-15)
	move.w	(a1,d0.w*2),d1	; Load Play Type
	move.b	#1,Outfielder	; Flag Outfielder Active
	move.b	BOZOFACTOR(a0),d0	; Load Bozo Factor
	asl.b	#1,d0	; Multiply By Two
	move.b	d0,NoControl	; Double The Bozo Factor
	bra.s	AssCont_4
AssCont_1:
	move.w	HitDirection,d0	; Load Hit Direction
	clr.w	d1	; Set For Bunt
	move.l	#Pitcher,a1	; Load Address Of Pitcher
	tst.b	B_COVERING(a1)	; Check If Pitcher Covering A Base
	bne.s	AssCont_3	; Branch If He Is

;	tst.b	Flyball	; Check If Fly Ball
;	bne.s	AssCont_3	; Not Pitcher If It Is

	cmp.l	#100*12*256,MarkerDistance	; Check If Far Hit
	bgt.s	AssCont_3	; Branch If More

	move.l	Baseball+WORLDXVEL,d7	; Load World X Velocity
	bpl.s	AssCont_2	; Branch If Positive
	neg.l	d7	; Make It Positive
AssCont_2:
	add.l	Baseball+WORLDYVEL,d7	; Add In World Y Velocity
;	tst.l	Baseball+WORLDZVEL	; Check If Going Up
;	bmi.s	AssCont_2A	; Branch If Not
;	asl.l	#1,d7	; Multiply By Two
;AssCont_2A:
	cmp.l	#0x1800,d7	; Check If Ball Fast
	ble.s	AssCont_4	; No Pitcher If Fast

AssCont_3:
	move.b	#1,Infielder	; Flag Infielder Active
	move.l	#Infielders,a1	; Load Address Of Infielders
	lsr.w	#3,d0	; Divide By Eight (0-15)
	move.w	(a1,d0.w*2),d1	; Load Play Type
AssCont_4:
	move.w	d1,PlayType	; Save The Play Type

	move.l	#Fielders,a2	; Load Address Of Fielders
	move.l	(a2,d1*4),a1	; Load Address Of Fielder

	move.l	a0,CONTROLBLOCK(a1)	; Give Buttons To Player

	move.l	a1,ControlPtr	; Give Control To A Player

	rts

;***************************************************************************
;  0 - bunt			*
;  1 - ball hit to right field		*
;  2 - ball hit to center field		*
;  3 - ball hit to left field		*
;  4 - ball hit to first base		*
;  5 - ball hit to second base		*
;  6 - ball hit to shortstop		*
;  7 - ball hit to third base		*
;***************************************************************************
Fielders:
	dc.l	Pitcher	; Bunt
	dc.l	RightField	; Right Field Hit
	dc.l	CenterField	; Center Field Hit
	dc.l	LeftField	; Left Field Hit
	dc.l	FirstBase	; First Base Hit
	dc.l	SecondBase	; Second Base Hit
	dc.l	ShortStop	; Short Stop Hit
	dc.l	ThirdBase	; Third Base Hit

Outfielders:  
	dc.w	1	; 00 : 00.000 - 05.624
	dc.w	1	; 01 : 05.625 - 11.249
	dc.w	1	; 02 : 11.250 - 16.874
	dc.w	1	; 03 : 16.875 - 22.499
	dc.w	1	; 04 : 22.500 - 28.124
	dc.w	2	; 05 : 28.125 - 33.749
	dc.w	2	; 06 : 33.750 - 39.374
	dc.w	2	; 07 : 39.375 - 44.999
	dc.w	2	; 08 : 45.000 - 50.624
	dc.w	2	; 09 : 50.625 - 56.249
	dc.w	2	; 10 : 56.250 - 61.874
	dc.w	3	; 11 : 61.875 - 67.499
	dc.w	3	; 12 : 67.500 - 73.124
	dc.w	3	; 13 : 73.125 - 78.749
	dc.w	3	; 14 : 78.750 - 84.374
	dc.w	3	; 15 : 84.375 - 89.999
	dc.w	3	; 16 : 90.000 - 95.624
			  
Infielders:  		  
	dc.w	4	; 00 : 00.000 - 05.624
	dc.w	4	; 01 : 05.625 - 11.249
	dc.w	5	; 02 : 11.250 - 16.874
	dc.w	5	; 03 : 16.875 - 22.499
	dc.w	5	; 04 : 22.500 - 28.124
	dc.w	5	; 05 : 28.125 - 33.749
	dc.w	5	; 06 : 33.750 - 39.374
	dc.w	5	; 07 : 39.375 - 44.999
	dc.w	6	; 08 : 45.000 - 50.624
	dc.w	6	; 09 : 50.625 - 56.249
	dc.w	6	; 10 : 56.250 - 61.874
	dc.w	6	; 11 : 61.875 - 67.499
	dc.w	6	; 12 : 67.500 - 73.124
	dc.w	6	; 13 : 73.125 - 78.749
	dc.w	7	; 14 : 78.750 - 84.374
	dc.w	7	; 15 : 84.375 - 89.999
	dc.w	7	; 16 : 90.000 - 95.624

	.align	2

;***************************************************************************
;   AllocField - Allocate Field Object		*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
AllocField:
	jsr	AllocObject	; Allocate An Object
	move.l	#DisplayField,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	clr.w	ZPOSITION(a0)	; Initialize Z Position
	move.l	#2820*256,WORLDY(a0)	; Save Y Position Of Foul Pole
	move.l	#2820*256,WORLDX(a0)	; Save X Position Of Foul Pole
	rts
							
;***************************************************************************
;   InitBall - Initialize Ball Object		*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
InitBall:
	clr.b	BallOnGround	; Activate Ball
	move.l	#Baseball,a0	; Load Address Of Ball
	move.w	#METERZ,ZPOSITION(a0)	; Initialize Z Position
	move.w	#ballt,PICTURE(a0)	; Set Ball Picture
	move.l	#DisplayBall,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#AnimBall,UPDATEPROC(a0)	; Animate The Ball
	move.b	#1,STATIONARY(a0)	; Let Anim Routine Move Ball
	clr.b	COUNTER(a0)	; Start Catch Checking
	rts

;***************************************************************************
;   AllocMarker - Allocate Marker Object		*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
AllocMarker:
	jsr	AllocObject	; Allocate An Object
	beq	AllocMark_9	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#UpdateMark,UPDATEPROC(a0)	; Set Animation Routine
	move.l	#Marker,PARSEPOINTER(a0)	; Set Parse Pointer
	move.w	#10,ZPOSITION(a0)	; Initialize Z Position
	move.w	#land0005,PICTURE(a0)	; Set Marker Picture
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
           move.l    #Baseball,a1	; Load Address Of Ball
	jsr	CalcImpact	; Calculate Impact Point
	move.l	d4,WORLDX(a0)	; Set World X Position
	move.l	d5,WORLDY(a0)	; Set World Y Position

	clr.l	WORLDZ(a0)	; Place On Ground
	move.l	a0,MarkerPtr	; Save Address Of Marker

	move.l	d4,d6	; Move X Position To d6
	move.l	d5,d7	; Move Y Position To d7
	jsr	CalcDistance	; Calculate Hit Distance
	move.l	d1,MarkerDistance	; Store Marker Distance

;
;	Check For Easy Catch
;	

	move.l	WORLDX(a0),d4	; Load World X Position
	move.l	WORLDY(a0),d5	; Load World Y Position

	move.l	#Pitcher,a0	; Load Address Of Pitcher
AllocMark_2:
	cmp.l	#Catcher,a0	; Check If Catcher
	beq.s	AllocMark_5	; Branch If It Is

	move.l	WORLDX(a0),d0	; Load World X Position	
	sub.l	d4,d0	; Subtract Marker Position
	bpl.s	AllocMark_3	; Branch If Positive
	neg.l	d0	; Make It Positive
AllocMark_3:
	cmp.l	#10*12*256,d0	; Check If Within 20 Feet
	bgt.s	AllocMark_5	; Branch If Too Far

	move.l	WORLDY(a0),d0	; Load World Y Position	
	sub.l	d5,d0	; Subtract Marker Position
	bpl.s	AllocMark_4	; Branch If Positive
	neg.l	d0	; Make It Positive
AllocMark_4:
	cmp.l	#10*12*256,d0	; Check If Within 20 Feet
	bgt.s	AllocMark_5	; Branch If Too Far

;	trap	#1

	SOUND 	#EasyCatch,#0	; Easy Catch 
	bra.s	AllocMark_9
AllocMark_5:
	add.l	#`sizeof(player_struct),a0	; Index To Next Fielder
	cmp.l	#RightField,a0	; Check If Done
	ble.s	AllocMark_2	; Branch If Not

AllocMark_9:
	rts

UpdateMark:
	jsr	Anim	; Animate Marker
	jsr	CalcFieldCoord	; Set Field Coordinates
	sub.w	#17,XPOSITION(a5)	; Center The Marker
	sub.w	#6,YPOSITION(a5)
	rts

;SetMarker:
;	move.l	#Baseball,a1	; Load Address Of Ball
;	move.l	WORLDZ(a1),d0	; Load Height Of Ball
;	asr.l	#8,d0	; Extract Inches
;	asr.l	#7,d0	; Extract 10.67 Feet
;	neg.w	d0	; Negate The Result
;;bri	add.w	#7,d0	; Offset To Marker Index
;;	bpl.s	SetMark_1	; Branch If Positive
;	clr.w	d0	; Use Biggest If Not
;SetMark_1:
;	move.w	d0,d1	; Save In D1
;	lsl.w	#3,d0	; Multiply By Eight
;	add.w	d1,d0	; Multiply By Nine
;	add.w	d1,d0	; Multiply By Ten
;	add.w	#ball0001-1,d0	; Set Marker Picture
;	move.w	d0,PICTURE(a5)	; Save Picture Number
;	rts

Marker:
	LASTFRAME  10
	JUMP	Marker
	
	.align	2
;***************************************************************************
;   RunToXY - Force Player To Run To X,Y Position	*
;				*
;   Parameters :  a0 - Address Of Player		*
;	       a2 - Address To Jump To At End Of Run	*
;	       d1 - Attribute To Use For Speed	*
;	       d3 - Speed		*	
;	       d4 - X Destination		*
;	       d5 - Y Destination		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
	.export	RunToXY
RunToXY:
;
;	Set Runner Speed Based On Attributes
;
	clr.w	RunTime	; Set For No Time
	PUSHL	a1	; Save A1
	clr.w	d0	; Clear D0
	move.l	B_ROSTERADR(a0),a1	; Load Roster Address
	move.b	(a1,d1.w),d0	; Load Speed Of Runner
	mulu	d0,d3	; Multiply Speed By Attribute
	asr.l	#7,d3	; Shift Out Modified Speed
	POPL	a1	; Retrieve A1

	move.l	d4,B_GOALX(a0)	; Set The Goal
	move.l	d5,B_GOALY(a0)	; Set The Goal
	sub.l	WORLDX(a0),d4	; Subtract Current From Destination
	sub.l	WORLDY(a0),d5	; Subtract Current From Destination

	move.l	d4,d0	; Load X Distance To D0
	or.l	d5,d0	; Or With Y Distance
	beq	RunToXY_B	; Branch If No Movement Needed

	move.l	d4,d6
	move.l	d5,d7
	jsr	CalcDistance	; Determine Distance

	divu	d3,d1	; Divide Distance By Speed

	move.w	d1,RunTime	; Store Running Time

	tst.w	d1	; Check If Already There
	beq	RunToXY_C	; Branch If He Is

	clr.l	d0	; Clear D0
	move.w	d1,d0	; Move Time To d0
	asl.l	#8,d0	; Shift Into Upper Bytes
	subq.l	#1,d0	; Make A Little Slammer
	move.l	d0,B_SEEKING(a0)	; Set Seeking Time

	divs	d1,d4	; Divide X Distance By Time
	ext.l	d4	; Extend To A Long

	divs	d1,d5	; Divide Y Distance By Time
	ext.l	d5	; Extend To A Long

	move.l	d4,WORLDXVEL(a0)	; Save X Velocity
	move.l	d5,WORLDYVEL(a0)	; Save Y Velocity

	jsr	CalcDirection	; Determine Player Direction
	move.b	d0,B_DIRECTION(a0)	; Store The Direction

	clr.l	WORLDZVEL(a0)	; Set Z Velocity
	clr.b	B_SLIDING(a0)	; Clear Sliding Flag 
	move.l	B_RUNNINGANIM(a0),PARSEPOINTER(a0) ; Set For Running
	move.l	#AnimPlayer,UPDATEPROC(a0)	; Store Address Of Update Procedure

RunToXY_2:
	move.l	a2,B_GOALPP(a0)	; Set For Running End
	move.l	#DspBody,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
	move.w	#6,DURATION(a0)	; Set Animation Speed
	clr.w	COUNTER(a0)
RunToXY_9:
	rts

RunToXY_A:
	move.l	a2,PARSEPOINTER(a0)	; Set To Ending Animation
	clr.w	DURATION(a0)	; Set Animation Speed
	move.l	#DspBody,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
	move.l	#AnimPlayer,UPDATEPROC(a0)	; Store Address Of Update Procedure

RunToXY_B:
	clr.l	WORLDXVEL(a0)	; Clear X Velocity
	clr.l	WORLDYVEL(a0)	; Clear Y Velocity
	clr.l	WORLDZVEL(a0)	; Clear Z Velocity
	rts

RunToXY_C:
	move.l	B_GOALX(a0),WORLDX(a0)	; Set The Goal
	move.l	B_GOALY(a0),WORLDY(a0)	; Set The Goal
	rts


RunToF:
	SYSTEM	FielderToFirst
	JUMP	EndRunCover

RunToS:
	SYSTEM	FielderToSecond
	JUMP	EndRunCover

RunToT:
	SYSTEM	FielderToThird
	JUMP	EndRunCover
	
RunToH:
	SYSTEM	FielderToHome

EndRunCover:	
	SYSTEM	ClearTracks	; Clear Track Ball Counters
	SETRAM	B_MOVABLE,1
	UPDATE	TrackPlayer
	INPUTSUB	FIELDER_CONTROLS
	JUMP	StopRun
	

	.align	2

ClearTracks:
	move.l	CONTROLBLOCK(a5),a0	; Loaad AAddress Of Control Block
	tst.l	a0	; Check If Active
	beq.s	ClearTrack_1	; Exit If Not
	clr.w	TRACKX(a0)	; Clear Track Ball X
	clr.w	TRACKY(a0)	; Clear Track Ball Y
ClearTrack_1:
	rts

FielderToFirst:
	move.l	#FIRSTBASEX,d4	; Load X Position For Seek
	move.l	#FIRSTBASEY,d5	; Load Y Position For Seek
	bra.s	FldToBase

FielderToSecond:
	move.l	#SECONDBASEX,d4	; Load X Position For Seek
	move.l	#SECONDBASEY,d5	; Load Y Position For Seek
	bra.s	FldToBase

FielderToThird:
	move.l	#THIRDBASEX,d4	; Load X Position For Seek
	move.l	#THIRDBASEY,d5	; Load Y Position For Seek
	bra.s	FldToBase

FielderToHome:
	move.l	#HOMEPLATEX,d4	; Load X Position For Seek
	move.l	#HOMEPLATEY,d5	; Load Y Position For Seek

FldToBase:
	clr.b	B_MOVABLE(a5)
	move.l	a5,a0
	move.l	#35*MPH,d3	; Set For 35 MPH Run
	move.l	#EndRunCover,a2	; Ending For Run
	move.w	#AT_RANGE,d1	; Use Range Attribute
	jsr	RunToXY	; Set For Run
	rts

;***************************************************************************
;   ThrowToXY - Throw Ball To X,Y Position		*
;				*
;   Parameters :  a1 - Destination Object		*
;	       a5 - Throwing Object		*
;	       d3 - Speed		*	
;	       d4 - X Destination		*
;	       d5 - Y Destination		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
	.export	ThrowToXY
ThrowToXY:
	move.l	a5,Thrower	; Save Address Of Thrower

	clr.w	d0	; Clear D0
	move.l	B_ROSTERADR(a5),a1	; Load Roster Address
	move.b	AT_ARM(a1),d0	; Load Strength Of Arm
	mulu	d0,d3	; Multiply Speed By Attribute
	asr.l	#7,d3	; Shift Out Modified Arm Strength

;	move.w	([ROSTERPTR,a5],AT_namesnd),d1   ; Fielder Name from Roster
;	move.b	d1,SndBit2
;	lsr.w	#8,d1
;	move.b	d1,SndBit1
;	SOUND3	#SetCurrentPlayer,SndBit1,SndBit2
;	SOUND	#S_ThrowToBase,#0

	move.l	#Baseball,a0	; Load Address Of Ball
	move.l	WORLDX(a5),WORLDX(a0)	; Force Ball's Position To Player
	move.l	WORLDY(a5),WORLDY(a0)

	sub.l	WORLDX(a0),d4	; Subtract Current From Destination
	sub.l	WORLDY(a0),d5	; Subtract Current From Destination
	move.l	d4,d6
	move.l	d5,d7
	jsr	CalcDistance	; Determine Distance

	tst.l	d1	; Check If No Distance
	beq.s	ThrowTo_9	; Branch If None

	divu	d3,d1	; Divide Distance By Speed
	tst.w	d1	; Check If No Time
	beq.s	ThrowTo_9	; Branch If None

	divs	d1,d4	; Divide X Distance By Time
	ext.l	d4	; Extend To A Long
	divs	d1,d5	; Divide Y Distance By Time
	ext.l	d5	; Extend To A Long
	move.l	d4,WORLDXVEL(a0)	; Save X Velocity
	move.l	d5,WORLDYVEL(a0)	; Save Y Velocity

	move.w	d1,ThrowTime	; Save Throwing Time

	move.l	#8*12*256,WORLDZ(a0)	; Set To Eight Feet 
	lsr.w	#1,d1	; Divide Time By Two
	mulu	#BALLGRAVITY,d1	; Calculate Z Velocity

	clr.l	d0	; Clear D0
	move.l	B_ROSTERADR(a5),a1	; Load Roster Address
	move.b	AT_ARM(a1),d0	; Load Strength Of Arm
	lsl.w	#4,d0	; Multiply By 16
	add.w	#0x400,d0	; Add A Little More

	cmp.l	d0,d1	; Check For Maximum Velocity
	ble.s	ThrowTo_1	; Branch If Fine
	move.l	d0,d1	; Save Maximum Velocity
ThrowTo_1:
	move.l	d1,WORLDZVEL(a0)	; Set Z Velocity

	clr.b	B_HASBALL(a5)	; Remove Ball From Player
	move.l	#DisplayBall,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#AnimBall,UPDATEPROC(a0)	; Animate The Ball
	jsr	CheckRunning
	cmp.b	#-1,AreRunning
	bne.s	ThrowTo_9
	move.b	#1,BallOnGround
ThrowTo_9:
	rts

;***************************************************************************
;   CalcDistance - Calculate Distance		*
;				*
;   Parameters :  d6 - X Vector		*
;	       d7 - Y Vector		*
;   Returns:      d1 - Distance		*
;   Modifies:     d0,d1,d2,d6,d7		*
;***************************************************************************
CalcDistance:
	asr.l	#8,d6	; Extract Inches
	asr.l	#8,d7	; Extract Inches
	muls.l	d6,d6	; Calculate Square Of X
	muls.l	d7,d7	; Calculate Square Of Y
	add.l	d6,d7	; Add Together Results
	bsr	SquareRoot	; Calculate Square Root
	asl.l	#8,d1	; Shift Back For Inches
	rts

;***************************************************************************
;   SquareRoot - Calculate Square Root		*
;				*
;   Parameters :  d7 - Value To Calculate Square Root	*
;   Returns:      d1    - Square Root		*
;   Modifies:     d0,d1,d2		*
;***************************************************************************
SquareRoot:
	PUSHL	d3
	move.l	#0x1000,d1	; Use Value As First Attempt
	tst.l	d7	; Check If Zero
	beq.s	SR_9	; Branch If It Is

	clr.w	d3
SR_1:
	add.w	#1,d3
	cmp.w	#40,d3
	bgt.s	SR_A	;endless loop patch, obe

	move.l	d1,d0	; Save For End Calculation
	move.l	d1,d2
	asl.l	#1,d2	; Multiply By Two (2X)
	mulu.l	d1,d1	; Calculate Square
	add.l	d7,d1	; Add In Original Value
	divu	d2,d1	; Divide By 2X
	ext.l	d1	; Extend To A Long
	cmp.l	d1,d0	; Check If Done
	bne.s	SR_1	; Continue Looping If Not
	POPL	d3
	rts
SR_9:
	clr.l	d1	; Return Zero
	POPL	d3
	rts

SR_A:
	POPL	d3
;	trap	#1
	rts

;***************************************************************************
;   CalcDirection - Determine Direction From X,Y Vector	*
;				*
;   Parameters :  d4 - X Vector		*
;	       d5 - Y Vector		*
;   Returns:      d0 - 0:Down 2:Right 4:Up 6:Left	*
;   Modifies:     NONE		*
;***************************************************************************
CalcDirection:
	move.w	#-1,d0	; Set For No Direction
	move.l	d4,d1	; Load X Vector
	bpl.s	CalcDir_A	; Branch If Positive
	neg.l	d1	; Make It Positive
CalcDir_A:
	move.l	d5,d2	; Load Y Vector
	bpl.s	CalcDir_B	; Branch If Positive
	neg.l	d2	; Make It Positive
CalcDir_B:
	add.l	d2,d1	; Add The Two Vector Components
	cmp.l	#2,d1	; Check If Big Enough
	ble	CalcDir_99	; Exit If No Direction

	tst.l	d4	; Check If Right Or Left
	bmi.s	CalcDir_10	; Branch If Left
	tst.l	d5	; Check If Up Or Down
	bmi.s	CalcDir_2	; Branch If Down
	cmp.l	d4,d5	; Compare Two Vectors
	bge.s	CalcDir_1	; Branch If Y Greater (0,1)
	asr.l	#1,d4	; Divide X By Two
	move.w	#2,d0	; Set For Right
	cmp.l	d5,d4	; Compare With 1/2 X
	bge	CalcDir_99	; Exit If Done
	move.w	#3,d0	; Set For 45 degree Angle
	bra	CalcDir_99
CalcDir_1:
	asr.l	#1,d5	; Divide Y By Two
	move.w	#4,d0	; Set For Up
	cmp.l	d4,d5	; Compare With 1/2 X
	bge.s	CalcDir_99	; Exit If Done
	move.w	#3,d0	; Set For 45 degree Angle
	bra.s	CalcDir_99

CalcDir_2:
	neg.l	d5	; Make D5 Positive
	cmp.l	d4,d5	; Compare Two Vectors
	bge.s	CalcDir_3	; Branch If Y Greater (0,1)
	asr.l	#1,d4	; Divide X By Two
	move.w	#2,d0	; Set For Right
	cmp.l	d5,d4	; Compare With 1/2 X
	bge.s	CalcDir_99	; Exit If Done
	move.w	#1,d0	; Set For 45 degree Angle
	bra.s	CalcDir_99
CalcDir_3:
	asr.l	#1,d5	; Divide Y By Two
	move.w	#0,d0	; Set For Down
	cmp.l	d4,d5	; Compare With 1/2 X
	bge.s	CalcDir_99	; Exit If Done
	move.w	#1,d0	; Set For 45 degree Angle
	bra.s	CalcDir_99

CalcDir_10:
	neg.l	d4	; Make X Positive
	tst.l	d5	; Check If Up Or Down
	bmi.s	CalcDir_12	; Branch If Down
	cmp.l	d4,d5	; Compare Two Vectors
	bge.s	CalcDir_11	; Branch If Y Greater (0,1)
	asr.l	#1,d4	; Divide X By Two
	move.w	#6,d0	; Set For Left
	cmp.l	d5,d4	; Compare With 1/2 X
	bge.s	CalcDir_99	; Exit If Done
	move.w	#5,d0	; Set For 45 degree Angle
	bra.s	CalcDir_99
CalcDir_11:
	asr.l	#1,d5	; Divide Y By Two
	move.w	#4,d0	; Set For Up
	cmp.l	d4,d5	; Compare With 1/2 X
	bge.s	CalcDir_99	; Exit If Done
	move.w	#5,d0	; Set For 45 degree Angle
	bra.s	CalcDir_99

CalcDir_12:
	neg.l	d5	; Make D5 Positive
	cmp.l	d4,d5	; Compare Two Vectors
	bge.s	CalcDir_13	; Branch If Y Greater (0,1)
	asr.l	#1,d4	; Divide X By Two
	move.w	#6,d0	; Set For Left
	cmp.l	d5,d4	; Compare With 1/2 X
	bge.s	CalcDir_99	; Exit If Done
	move.w	#7,d0	; Set For 45 degree Angle
	bra.s	CalcDir_99
CalcDir_13:
	asr.l	#1,d5	; Divide Y By Two
	move.w	#0,d0	; Set For Down
	cmp.l	d4,d5	; Compare With 1/2 X
	bge.s	CalcDir_99	; Exit If Done
	move.w	#7,d0	; Set For 45 degree Angle

CalcDir_99:
	rts

;***************************************************************************
;   AnimBall - Animate Ball		*
;                                                                          *
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
AnimBall:
	move.l	WORLDXVEL(a5),d0	; Load X Velocity
	or.l	WORLDYVEL(a5),d0	; Or With Y Velocity
	beq	AnimBall_8	; Exit If Not Moving

	move.l	WORLDXVEL(a5),d0	; Load X Velocity
	add.l	d0,WORLDX(a5)	; Add To World X
	move.l	WORLDYVEL(a5),d0	; Load Y Velocity
	add.l	d0,WORLDY(a5)	; Add To World Y
	move.l	WORLDZVEL(a5),d0	; Load Z Velocity
	add.l	d0,WORLDZ(a5)	; Add To World Z
	sub.l	#BALLGRAVITY,WORLDZVEL(a5)	; Add In Gravity Effect

	move.l	WORLDY(a5),d0	; Load Y Position
	asr.l	#8,d0	; Extract Inches
	asr.l	#2,d0	; Extract 4" Increments
	add.w	#3*40,d0	; Add Forty Feet
	neg.w	d0	; Negate Result
	add.w	#0x7FFF,d0	; Add Big Number
	move.w	d0,ZPOSITION(a5)	; Store Object's Z Position

	jsr	BallInRange	; Keep Ball In Range
	jsr	CheckCatch	; Check If Ball Caught
	bra.s	AnimBall_9

AnimBall_8:
	jsr	CheckCatch	; Check If Ball Caught
AnimBall_9:
	cmp.b	#0,BallOnGround
	ble.s	AnimBall_A
	add.b	#1,BallOnGround    	; Increment Ground
AnimBall_A:
	jsr	CalcFieldCoord	; Place Ball On Field
	sub.w	#5,XPOSITION(a5)	; Center On Ball
	sub.w	#5,YPOSITION(a5)
	rts

;***************************************************************************
;   BallInRange - Force Ball In Range		*
;				*
;   Parameters :  a5 - Address Of Ball Object		*
;   Returns:      NONE		*
;   Modifies:     ALL		*
;***************************************************************************
BallInRange:
         	cmp.b	#1,BallOffWall	; Check If Off Wall Last Time
	bne.s	BallIn_0	; Branch If Not
	cmp.b	#1,BallOnGround
	bge.s	HitGround
	jsr	WallLaser
HitGround:
	clr.b	LaserHit	; No Longer A Laser Hit
	move.b	#-1,BallOffWall	; Ball Bounced Off Wall
	move.b	#1,BallOnGround	; Don't Allow Catch To Be An Out
	move.b	#10,NoCatch	; Set For No Catch
	SOUND	#OffTheWall,#0	; Output Sound Effect
	SOUND	#BallHitsWall,#0	; Output Sound Effect
BallIn_0:
	tst.b	BallOffWall	; Check If Ball Has Bounced Off Wall
	bne	BallIn_3	; Branch If It Has

	move.l	#StadiumY,a0	; Load Address Of Stadium Data
	move.l	WORLDX(a5),d0	; Load X Position
	bpl.s	BallIn_1	; Branch If Positive
	neg.l	d0	; Make It Positive
BallIn_1:
	lsr.l	#8,d0	; Extract Inches
	lsr.l	#3,d0	; Extract 8 Inches
	lsl.w	#1,d0	; Multiply By Two
	move.w	(a0,d0.w),d0	; Load Stadium Y Position
	lsl.l	#8,d0	; Shift Up Inches
	cmp.l	WORLDY(a5),d0	; Load Ball's Y Position
	bge	BallIn_3	; Branch If Fine

	tst.b	HomeRun	; Check If Already A Home Run
	bmi	BallIn_3	; Branch If It Was
	tst.b	FliedOut	; Check If Flied Out
	bne	BallIn_3	; Branch If It Was

	move.l	WallHeight,d0	; Load Wall's Height
	cmp.l	WORLDZ(a5),d0	; Check Ball Height (Over Wall)
	bge	BallIn_2	; Branch If Not Over The Fence
	jsr	AIHomeRun	; Flag Home Run To AI
	move.l	#12*256,WallHeight	; Set Height To Short (For Bounce Off Stands)
	move.b	#-1,HomeRun	; Flag A Home Run
	clr.b	BallInFlight	; Ball Not In Flight
	add.b	#1,([AtBatPlayer],HITS)	; Increment Hits
	move.b	#1,DidGetHit      	; yes he hit
	clr.l	MarkerPtr	; Clear Marker
	clr.b	AreRunning	; Clear Running Flag
	
	move.l	#HomeRunner,a0	; Load Address Of Runner To Home
	move.l	AtBatPlayer,a1	; Load Address Of Batter
	move.b	Inning,d1	; Load Inning Number
	ext.w	d1	; Extend To A Word
	lsr.w	#1,d1	; Extract Inning Number
	clr.w	d2	; Clear from home run counter
BallIn_1B:
	tst.b	B_INUSE(a0)	; Check If In Use
	beq.s	BallIn_1C	; Branch If Not
	add.b	#1,(INNINGSSCORE,a1,d1.w)	; Increment Inning Score by using INNINGSSCORE
	add.b	#1,RUNS(a1)	; Increment Runs
	add.w	#1,d2	; keep adding to homerun counter
	clr.b	B_INUSE(a0)	; Remove Runner
	clr.b	B_ONBASE(a0)	; Remove Runner
BallIn_1C:
	sub.l	#`sizeof(player_struct),a0	; Move To Previous Runner
	cmp.l	#FirstRunner,a0	; Check If Done
	bgt.s	BallIn_1B	; Loop If Not

	cmp.w	#3,d2	; Check if a Grand Slam
	bne.s	NotGrandSlam	; branch if not
	SOUND	#GrandSlam,#0	; Output Sound Effect
	SOUND	#HomerunMusic,#0
	move.w	#1,WasGrand
	bra.s	BallIn_3
NotGrandSlam:
	SOUND	#S_HomeRun,#0	; Output Sound Effect
	bra.s	BallIn_3

BallIn_2:
	move.l	WORLDXVEL(a5),d0	; Load The X Velocity
	neg.l	d0	; Bounce Off The Wall
	asr.l	#3,d0	; Divide By Four
	move.l	d0,WORLDXVEL(a5)	; Save The New Velocity

	move.l	WORLDYVEL(a5),d0	; Load The Y Velocity
	neg.l	d0	; Bounce Off The Wall
	asr.l	#3,d0	; Divide By Four
	cmp.l	#-0x400,d0	; Check If Enough
	ble.s	BallIn_2A	; Branch If Fine
	move.l	#-0x400,d0	; Load Minimum
BallIn_2A:
	move.l	d0,WORLDYVEL(a5)	; Save The New Velocity

	move.b	#1,BallOffWall	; Set For Wall Bounce
BallIn_3:
	tst.l	WORLDZ(a5)	; Check Ball Height
	bpl	BallIn_9	; Branch If Still In Air

	add.b	#1,BallOnGround    	; Flag Ball On Ground

	tst.w	ThrowTime	; Check If Thrown
	bne.s	BallIn_6	; Branch If It Was

	move.l	WORLDXVEL(a5),d0	; Load X Velocity
	asr.l	#2,d0	; Divide By Four
	sub.l	d0,WORLDXVEL(a5)	; Slow Ball Down

	move.l	WORLDYVEL(a5),d0	; Load Y Velocity
	asr.l	#2,d0	; Divide By Four
	sub.l	d0,WORLDYVEL(a5)	; Slow Ball Down

	move.l	WORLDXVEL(a5),d0	; Load X Velocity
	bpl.s	BallIn_4	; Branch If Positive
	neg.l	d0 	; Make It Positive
BallIn_4:
	move.l	WORLDYVEL(a5),d1	; Load Y Velocity
	bpl.s	BallIn_5	; Branch If Positive
	neg.l	d1 	; Make It Positive
BallIn_5:
	add.l	d0,d1	; Add The Two Velocities
	cmp.l	#0x200,d1	; Check If Slow
	bge.s	BallIn_6	; Branch If not
	clr.l	WORLDXVEL(a5)	; Stop X Velocity
	clr.l	WORLDYVEL(a5)	; Stop Y Velocity

	jsr	RunToBall	; Force Fielder To Ball
	move.b	#1,BallOnGround
	
BallIn_6:
	move.l	WORLDZVEL(a5),d0	; Load Z Velocity
	neg.l	d0	; Make Positive Again
	asr.l	#1,d0	; Divide By Two
	move.l	d0,WORLDZVEL(a5)	; Store New Velocity
	move.b	#1,BallRolling	; Flag Rolling Ball
	cmp.l	#0x300,d0	; Check If Hard Hit
	ble.s	BallIn_7	; Branch If Soft
	SOUND	#BallHitsDirt,#0	; Ball Hits Dirt Sound
	clr.b	BallRolling	; Ball Not Rolling
BallIn_7:
	tst.b	VintageHit	; Check If Vintage Player Hit
	beq.s	BallIn_8	; Branch If Not
;	clr.b	VintageHit	; Clear Vintage Hit
	SOUND	#VintageBallBounce,#0	; Make Silly Noise
	move.l	WORLDYVEL(a5),d1	; Load Y Velocity
	neg.l	d1	; Make It Negative
	move.l	WORLDXVEL(a5),d2	; Load X Velocity
	bpl.s	BallIn_7A	; Branch If Positive
	neg.l	d1	; Negate Y Velocity
	neg.l	d2	; Negate X Velocity
BallIn_7A:
	move.l	d2,WORLDYVEL(a5)	; Set New Y Velocity
	move.l	d1,WORLDXVEL(a5)	; Set New X Velocity
BallIn_8:
	clr.l	WORLDZ(a5)
	tst.l	MarkerPtr	; Check If Marker Still Displayed
	beq.s	BallIn_9	; Branch If Not
	move.l	MarkerPtr,a0	; Load Address Of Marker
	move.b	#1,DELETED(a0)	; Remove The Marker
	clr.l	MarkerPtr	; Clear Marker Address
	clr.b	BallInFlight	; Ball Not In Flight
	clr.b	Flyball	; Clear Fly Ball Flag

	jsr	IncBozo	; A Little More Bozo-like

	cmp.l	#110*12*256,WORLDY(a5)	; Check If In The Outfield
	ble.s	BallIn_8A	; Branch If Not
	SOUND	#BaseHit,#0	; Base Hit Sound
BallIn_8A:

	tst.b	ThirdRunner+B_FORCED	; Check If Third Runner Forced
	beq.s	BallIn_9	; Branch If Not

	move.l	#HomeRunner,a0	; Load Address Of Batter
	tst.b	B_INUSE(a0)	; Check If Running
	beq.s	BallIn_9	; Branch If Not
	move.b	#1,B_FORCED(a0)	; Set Forced Run Flag
	jsr	RunToHome	; Set Runner To Home
	move.b	#-6,B_ONBASE(a0)	; Flag Running To Home From Third
	clr.b	B_SLIDING(a0)	; Not Sliding Yet
BallIn_9:
	rts

RunToBall:
	move.l	ControlPtr,a1	; Load Address Of Control Ptr
	move.l	Baseball+WORLDX,d4	; Load World X Of Ball
	move.l	d4,d7	; Move To D7
	sub.l	WORLDX(a1),d7	; Subtract Fielder X
	bpl.s	RunToBall_1	; Branch If Positive
	neg.l	d7	; Make It Positive
RunToBall_1:
	move.l	Baseball+WORLDY,d5	; Load World Y Of Ball
	move.l	d5,d0	; Move To D0
	sub.l	WORLDY(a1),d0	; Subtract Fielder Y
	bpl.s	RunToBall_2	; Branch If Positive
	neg.l	d0	; Make It Positive
RunToBall_2:
	add.l	d0,d7	; Calculate Pseudo Distance
	move.l	a1,a3	; Save Address Of Controlled

	move.l	#LeftField,a1	; Load Address Of Left Fielder
RunToBall_3:
	cmp.l	#Catcher,a1	; Check If Catcher
	beq.s	RunToBall_6	; Branch If It Is
	move.l	d4,d1	; Move Ball X To D1
	sub.l	WORLDX(a1),d1	; Subtract Fielder X
	bpl.s	RunToBall_4	; Branch If Positive
	neg.l	d1	; Make It Positive
RunToBall_4:
	move.l	d5,d0	; Move Ball Y To D0
	sub.l	WORLDY(a1),d0	; Subtract Fielder Y
	bpl.s	RunToBall_5	; Branch If Positive
	neg.l	d0	; Make It Positive
RunToBall_5:
	add.l	d0,d1	; Calculate Pseudo Distance
	cmp.l	d1,d7	; Check If Closer
	ble.s	RunToBall_6	; Branch If Not
	move.l	d1,d7	; Save Closer Distance
	move.l	a1,a3	; Save Address Of Closer Fielder
RunToBall_6:
	add.l	#`sizeof(player_struct),a1	; Index To Next Fielder
	cmp.l	#RightField,a1	; Check If Done
	ble.s	RunToBall_3	; Branch If Not

	move.l	a3,a0	; Move Fielder To A0
	move.b	#-1,B_MOVABLE(a0)	; Stop Trackball Movement
	move.l	#40*MPH,d3	; Set For 40 MPH Run
	jsr	AIBias	; Bias For AI Level
	move.l	WORLDX(a5),d4	; Load X Position For Seek
	move.l	WORLDY(a5),d5	; Load Y Position For Seek
;	move.l	#BareHand,a2	; Ending For Run
	move.l	#0,a2
	move.w	#AT_RANGE,d1	; Use Range Attribute
	jsr	RunToXY	; Set For Run
	rts

;***************************************************************************
;   CheckCatch - Check If Ball Caught		*
;				*
;   Parameters :  a5 - Address Of Ball Object		*
;   Returns:      NONE		*
;   Modifies:     ALL		*
;***************************************************************************
CheckCatch:
	tst.b	HomeRun	; Check If Already Home Run
	bmi.s	CheckCatch_0	; Eixt If It Is
	tst.b	NoCatch	; Check If Catch Allowed
	beq.s	CheckCatch_1	; Branch If It Is
	subq.b	#1,NoCatch	; Decrement Catch Timer
CheckCatch_0:
	rts
CheckCatch_1:
	tst.l	DISPLAYPROC(a5)	; Check If Ball Active
	beq	CheckCatch_B	; Exit If Not
	tst.w	ThrowTime	; Check Ball Was Thrown
	bne	CheckCatch_7	; Branch If It Was

;	tst.b	COUNTER(a5)	; Check If Player Lunging
;	bne.s	CheckCatch_2	; Branch If He Is

;	jsr	CheckForLunge	; Check If Lunge Needed
CheckCatch_2:
	jsr	CheckNewFielder	; Check If New Fielder Needed

	move.l	WORLDX(a5),d4	; Load Ball's X Position
	move.l	WORLDY(a5),d5	; Load Ball's Y Position

	move.l	#Pitcher,a1	; Load Address Of Pitcher Object
;	cmp.l	#0x2000,WORLDYVEL(a5)	; Check If Ball Fast
;	ble.s	CheckCatch_3	; Branch If It Is Slow
;
;	move.l	#FirstBase,a1	; Load Address Of First Base Object
CheckCatch_3:
	tst.b	B_CATCHACTIVE(a1)	; Check If He Can Catch
	beq.s	CheckCatch_6	; Branch If Not

	cmp.l	#Catcher,a1	; Check If Catcher
	beq.s	CheckCatch_6	; Branch If It Is

	move.l	d5,d0	; Move Ball Position To D0
	sub.l	WORLDY(a1),d0	; Subtract Player's Position
	bpl.s	CheckCatch_4	; Branch If Positive
	neg.l	d0	; Make It Positive
CheckCatch_4:
	cmp.l	#BALLCLOSE,d0	; Check If Closer Than 5 Feet
	bge.s	CheckCatch_6	; Branch If Not

	move.l	d4,d0	; Move Ball Position To D0
	sub.l	WORLDX(a1),d0	; Subtract Ball Position
	bpl.s	CheckCatch_5	; Branch If Positive
	neg.l	d0	; Make It Positive
CheckCatch_5:
	cmp.l	#BALLCLOSE,d0	; Check If Closer Than 5 Feet
	bge.s	CheckCatch_6	; Branch If Not

	move.l	WORLDZ(a5),d0	; Load Ball Height
	sub.l	WORLDZ(a1),d0	; Subtract Player Height
	cmp.l	#-4*12*256,d0	; Check If 4 Feet Under
	ble.s	CheckCatch_6	; Branch If Ball Below Player
	
	cmp.l	#9*12*256,d0	; Check For Over Nine Feet
	ble.s	CheckCatch_6A	; Branch If Caught

CheckCatch_6:
	add.l	#`sizeof(player_struct),a1	; Index To Next Fielder
	cmp.l	#RightField,a1	; Check If Done
	ble.s	CheckCatch_3	; Branch If Not (was blt, changed to include catcher)
	bra	CheckCatch_B	; Exit

CheckCatch_6A:
	cmp.l	#Pitcher,a1	; Check If Pitcher Catch
	bne.s	CheckCatch_6B	; Branch If Not

	cmp.l	#0x2000,WORLDYVEL(a5)	; Check If Ball Fast
	ble.s	CheckCatch_6B	; Branch If It Is Slow

	move.l	#KnockDown,PARSEPOINTER(a1)	; Knock Down Pitcher
	clr.w	DURATION(a1)	; Start Animation Soon
	clr.b	B_CATCHACTIVE(a1)	; Don't Check For Catch 
	clr.b	B_MOVABLE(a1)	; Don't Let Move
	bra.s	CheckCatch_6	; Continue Looking

CheckCatch_6B:
	tst.b	LaserHit	; Check If Laser Hit
	beq.s	CheckCatch_8	; Branch If Not

;	bne.s	CheckCatch_6B	; Branch If It Is
;	cmp.l	#0x3000,WORLDYVEL(a5)	; Check If Ball Fast
;	ble.s	CheckCatch_8	; If slow, branch else knockem
;	move.b	#1,AntiL	; Let Player Catch Ball
;CheckCatch_6B:
	move.l	#KnockDown,PARSEPOINTER(a1)	; Knock Down Fielder
	clr.w	DURATION(a1)	; Start Animation Soon
	clr.b	B_CATCHACTIVE(a1)	; Don't Check For Catch 
	clr.b	B_MOVABLE(a1)	; Don't Let Move
	tst.b	AntiL	;If AntiLaser
	bne.s	CheckCatch_8	;then Branch
	move.l	Baseball+WORLDXVEL,d0	; Load Baseball X Velocity
	asr.w	#1,d0	; Divide By Four
	move.l	d0,WORLDXVEL(a1)	; Store X Velcoity
	move.l	Baseball+WORLDYVEL,d0	; Load Baseball Y Velocity
	asr.w	#1,d0	; Divide By Four
	move.l	d0,WORLDYVEL(a1)	; Store Y Velcoity
	bra	CheckCatch_B	; Exit

CheckCatch_7:
	sub.w	#1,ThrowTime	; Decrement Throw Time
	bne	CheckCatch_B	; Branch If Not Done

	move.l	ControlPtr,a1	; Load Address Of Receiver

CheckCatch_8:
	clr.b	AntiL	; No Longer A Laser Hit
	clr.b	LaserHit	; No Longer A Laser Hit
	clr.b	BallActive	; Ball Not Catchable
	clr.b	BallRolling	; Ball Not Rolling
	clr.b	BallInFlight	; Ball Not In Flight
	jsr	StopOutfielders	; Stop Outfielder Pursuit
     	move.l	#Baseball,a0	;Load Address Of Ball
	move.l	WORLDX(a0),WORLDX(a1)	;Set The Goal
    	move.l	WORLDY(a0),WORLDY(a1)	;Set The Goal

	move.b	#-1,STATIONARY(a1)	; Let Player Move

;	clr.l	WORLDXVEL(a1)	; Stop Fielder
;	clr.l	WORLDYVEL(a1)

;	tst.b	PowerBallPal
;	beq.s	NoPowerThrowS
;	SOUND	#CatchPowerThrow,#0	; Set Volume
;	bra.s	NoCatchSound
;NoPowerThrowS
	
;	move.l	WORLDYVEL(a0),d2	;move ball vel. bri
;	cmp.l	#100,d2	;check ball vel. bri
;	bge.s	CatchSound
;	neg.l	d2
;	cmp.l	#-100,d2	;check ball vel. bri
;	ble.s	CatchSound
;
;	move.l	WORLDXVEL(a0),d2	;check ball vel. bri
;	cmp.l	#100,d2
;	bge.s	CatchSound
;	neg.l	d2
;	cmp.l	#-100,d2	;check ball vel. bri
;	ble.s	CatchSound
;	bra.s	NoCatchSound
;CatchSound:
	SOUND	#FielderCatchBall,#0	; Set Volume
;NoCatchSound:
	clr.l	B_SEEKING(a1)	; Stop The Seek
	move.b	#1,B_HASBALL(a1)	; Give Player The Ball
	clr.b	VintageHit	; Clear Vintage Hit
	jsr	NewControl	; Give Control To Catcher
	tst.w	Destination	; Check If Throwing To A Base
	bne.s	CheckCatch_9	; Branch If It Is
	tst.b	BallOnGround	; Check If Ball Touched Ground
	bne.s	CheckCatch_9	; Branch If It Has
;bri	move.b	#0x30,BallOnGround	; Set to low paramater to increment
	move.b	#1,BallOnGround	; Set to low paramater to increment
	jsr	AddOut	; Increment Outs
	add.b	#1,BallOnGround	;Bri Added to stop false outs
	move.b	#1,FliedOut	; Flag An Out
	jsr	DecBozo	; A Little Less Bozo-like
	jsr	ForceBackRunners	; Return Runners To Original Bases
	move.l	#FirstRunner,a0	; Load Address Of Runner To First
	move.b	#1,B_OUT(a0)	; Runner Is Out
	jsr	RunToDugout	; Run To Dug Out
CheckCatch_9:
	clr.l	DISPLAYPROC(a5)	; Turn Off Ball
	clr.l	WORLDXVEL(a5)	; Stop The Ball
	move.l	WORLDYVEL(a5),CatchYVel	; Save The Ball Y Velocity
	clr.l	WORLDYVEL(a5)	; Stop The Ball

	move.l	MarkerPtr,d0	; Load Address Of Ball Marker
	beq.s	CheckCatch_B	; Branch If Not Active
	move.l	d0,a3	; Move To A3
	move.b	#1,DELETED(a3)	; Turn Off Marker
	clr.l	MarkerPtr	; Deactivate Marker
CheckCatch_B:
	rts

;***************************************************************************
;   CheckForLunge - Check If Ball In Range For Lunge	*
;				*
;   Parameters :  a5 - Address Of Ball Object		*
;   Returns:      NONE		*
;   Modifies:     ALL		*
;***************************************************************************
CheckForLunge:
	tst.b	BallOnGround	; Has Ball Hit Ground? (bri)
	bne.s	CheckL_9	; Exit If It Has

	tst.l	WORLDZVEL(a5)	; Check If Ball Coming Down
	bpl.s	CheckL_9	; Exit If Not

	move.w	#12,d0	; Ball In Twelve Ticks
	jsr	CalcBallPos	; Calculate Ball Position

	cmp.l	#8*12*256,d6	; Check If Over Eight Feet
	bgt.s	CheckL_9	; Exit If It Is

	move.l	ControlPtr,a1	; Load Address Of Controlled Player
	move.l	WORLDXVEL(a1),d1	; Load Fielder's X Velcity
	bpl.s	CheckL_1	; Branch If Positive
	neg.l	d1	; Make It Positive
CheckL_1:
	lsl.l	#2,d1	; Multiply By Four
	add.l	#6*12*256,d1	; Add Six Feet

	move.l	WORLDX(a1),d0	; Load Player X Position
	sub.l	d4,d0	; Subtract Baseball Position
	bpl.s	CheckL_2	; Branch If Positive
	neg.l	d0	; Make It Positive
CheckL_2:
	cmp.l	#10*12*256,d0	; Check If Closer Than 10 Feet
	blt.s	CheckL_9	; Branch If Too Close

	cmp.l	d1,d0	; Check If Close
	bgt.s	CheckL_9	; Branch If Not

	move.l	WORLDYVEL(a1),d1	; Load Fielder Y Velocity
	bpl.s	CheckL_3	; Branch If Positive
	neg.l	d1	; Make It Positive
CheckL_3:
	lsl.l	#2,d1	; Multiply By Four
	add.l	#6*12*256,d1	; Add Six Feet

	move.l	WORLDY(a1),d0	; Load Player Y Position
	sub.l	d5,d0	; Subtract Baseball Position
	bpl.s	CheckL_4	; Exit If Behind Fielder
	neg.l	d0	; Make It Positive
CheckL_4:
	cmp.l	d1,d0	; Check If Close
	bgt.s	CheckL_9	; Branch If Not

	move.l	#DoDive,PARSEPOINTER(a1)	; Set For Dive Animation
	clr.w	DURATION(a1)	; Start Real Soon
	move.b	#1,COUNTER(a5)	; Stop Catch Checking
	clr.b	B_MOVABLE(a1)	; Let Player Animate
	move.l	#AnimPlayer,UPDATEPROC(a1)	; Set For Updating
CheckL_9:
	rts

;***************************************************************************
;   CheckNewFielder - Check If Ball Is Far Past Current Fielder	*
;				*
;   Parameters :  a5 - Address Of Ball Object		*
;   Returns:      NONE		*
;   Modifies:     ALL		*
;***************************************************************************
CheckNewFielder:
	tst.b	Outfielder	; Check If Outfielder Already Active
	bne.s	CheckFielder_9	; Branch If He Is
	move.l	ControlPtr,a1	; Load Address Of Tracking Player
	move.l	WORLDY(a5),d0	; Load Y Position Of Ball
	sub.l	WORLDY(a1),d0	; Subtract Position Of Tracking Player
	bmi.s	CheckFielder_9	; Branch If In Front Of Player
	cmp.l	#12*12*256,d0	; Check For 12 Feet Behind Player
	ble.s	CheckFielder_9	; Branch If Not

	move.b	#1,Outfielder	; Flag Outfielder Active
	move.l	#Outfielders,a1	; Load Address Of Outfielders
	tst.b	Infielder	; Check If Infielder In Control
	bne.s	CheckFielder_1	; Branch If Not
	move.l	#Infielders,a1	; Load Address Of Infielders
	move.b	#1,Infielder	; Flag Infielder Active
	clr.b	Outfielder	; Flag Outfielder Inactive
CheckFielder_1:
	move.w	HitDirection,d0	; Load Hit Direction
	lsr.w	#3,d0	; Divide By Eight (0-15)
	move.w	(a1,d0.w*2),d0	; Load Assigned Player
	move.l	#Fielders,a0	; Load Address Of Fielders
	move.l	(a0,d0.w*4),a1	; Load Player To Switch To
	move.b	#1,B_MOVABLE(a1)	; Let Him Move
	jsr	SwitchControl	; Switch Control To New Player
CheckFielder_9:
	rts

;***************************************************************************
;   StopOutfielders - Stop Outfield Activity When Ball Is Caught	*
;                                                                          *
;   Parameters :  a1 - Address Of Ball Object		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
StopOutfielders:
	move.l	#Pitcher,a0	; Load Address Of Pitcher
StopOut_1:
	tst.b	B_COVERING(a0)	; Check If Covering A Base
	bne.s	StopOut_2	; Branch If He Is
	tst.l	B_SEEKING(a0)	; Check If Seeking
	beq.s	StopOut_2	; Branch If Not
	clr.l	B_SEEKING(a0)	; Stop Seeking
	move.l	B_GOALPP(a0),PARSEPOINTER(a0) ; Set To Ending Parse Pointer
	clr.l	WORLDXVEL(a0)	; Stop X Velocity
	clr.l	WORLDYVEL(a0)	; Stop Y Velocity
StopOut_2:
	add.l	#`sizeof(player_struct),a0	; Index To Next Fielder
	cmp.l	#RightField,a0	; Check If Done
	ble.s	StopOut_1	; Branch If Not
	rts

;***************************************************************************
;   CalcImpact - Calculate Ball Impact Point		*
;                                                                          *
;   Parameters :  a1 - Address Of Ball Object		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
CalcImpact:
	clr.b	Flyball	; Clear Fly Ball Flag
	clr.l	HitDistance	; Hit Distance Not Calculated Yet
	move.l	#StadiumY,a2	; Load Address Of Stadium Data

	move.l	WORLDX(a1),d4	; Load X Position
	move.l	WORLDY(a1),d5	; Load Y Position
	move.l	WORLDZ(a1),d6	; Load Z Position

	move.l	WORLDXVEL(a1),d1	; Load X Velocity
	move.l	WORLDYVEL(a1),d2	; Load Y Velocity
	move.l	WORLDZVEL(a1),d3	; Load Z Velocity

	move.l	d1,d0	; Move X Velocity To d0
	or.l	d2,d0	; Or With Y Velocity
	beq	CalcImp_9	; Exit If Not Moving

CalcImp_1:
	add.l	d1,d4	; Add To World X
	add.l	d2,d5	; Add To World Y
	add.l	d3,d6	; Add To World Z

	tst.l	d3	; Check If Coming Down
	bpl.s	CalcImp_1A	; Branch If Not
	cmp.l	#6*12*256,d6	; Check If 6 Feet Off Ground
	ble	CalcImp_9	; Exit If Low

CalcImp_1A:
	cmp.l	#30*12*256,d6	; Check If High Fly
	ble.s	CalcImp_1B	; Branch If Not
	move.b	#1,Flyball	; Flag A Fly Ball
CalcImp_1B:
	move.l	d4,d0	; Load X Position
	bpl.s	CalcImp_2	; Branch If Positive
	neg.l	d0	; Make It Positive
CalcImp_2:
	lsr.l	#8,d0	; Extract Inches
	lsr.l	#3,d0	; Extract 8 Inches
	lsl.w	#1,d0	; Multiply By Two
	move.w	(a2,d0.w),d0	; Load Stadium Y Position
	lsl.l	#8,d0	; Shift Up Inches
	cmp.l	d5,d0	; Load Ball's Y Position
	ble.s	CalcImp_4	; Branch If Over The Wall
CalcImp_3:
	sub.l	#BALLGRAVITY,d3	; Add In Gravity Effect
	bpl.s	CalcImp_1	; Branch If Still Going Up
	tst.l	HitDistance	; Check If Distance Already Stored
	bne.s	CalcImp_1	; Branch If It Has
	PUSHL	d1-d6
	move.l	d4,d6	; Move X Position To d6
	move.l	d5,d7	; Move Y Position To d7
	jsr	CalcDistance	; Calculate Hit Distance
	asl.l	#1,d1	; Multiply By Two
	cmp.l	#420*12*256,d1	; Check If Long Hit
	ble.s	CalcImp_3A	; Branch If Fine
	sub.l	#420*12*256,d1	; Subtract 420 Feet
	asr.l	#1,d1	; Divide By Two
	add.l	#420*12*256,d1	; Add 420 Feet
CalcImp_3A:
	move.l	d1,HitDistance	; Store Hit Distance
	POPL	d1-d6
	bra	CalcImp_1	; Continue Looping
CalcImp_4:
	cmp.l	#10*12*256,d6	; Check For Ten Feet Off Ground
	ble.s	CalcImp_9	; Branch If Not
	SOUND	#PotentialHomeRun,#0	; Output Sound Effect
	move.b	#1,HomeRun	; Flag A Home Run

	tst.l	HitDistance	; Check If Hit Distance Calculated
	bne.s	CalcImp_5	; Branch If It Was
	jsr	Random	; Get Random Number
	and.l	#63,d1	; Extract 0-63
	asl.l	#8,d1	; Multiply By 256
	asl.l	#4,d1	; Multiply By 16
	add.l	#400*12*256,d1	; Add 400 Feet
	move.l	d1,HitDistance	; Save Hit Distance
CalcImp_5:
	sub.l	d1,d4	; Back Up A Little
	sub.l	d2,d5	; Back Up A Little

	rts

CalcImp_9:
	btst.b	#0,ProcessTime+1	; Check Pseudo-Random Number
	beq.s	CalcImp_B	; Branch If Not Time

	tst.b	Flyball	; Check For Flyball
	beq.s	CalcImp_B	; Branch If Not

	move.b	#S_FlyBall,d0	; Load Fly Ball Sound
	cmp.l	#140*12*256,HitDistance	; Check If Within 140 Feet
	bgt.s	CalcImp_A	; Branch If Greater
	move.b	#InfieldPopUp,d0	; Load Duck Snort Sound
	cmp.l	#90*12*256,HitDistance	; Check If Within 90 Feet
	bgt.s	CalcImp_A	; Branch If Greater
	move.b	#PopsUp,d0	; Load Infield Popup Sound
CalcImp_A:
	clr.b	d1	; Clear Second Byte
	jsr	SendSound	; Output Sound

CalcImp_B:
	cmp.b	#2,outs	; Check For Two Outs
	bne.s	CalcImp_C	; Branch If Not
	clr.b	Flyball	; Let All Runners Run
CalcImp_C:
	rts

;***************************************************************************
;   CalcBallTraj - Calculate Ball's Trajectory		*
;                                                                          *
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
CalcBallTraj:
	tst.l	Seeker1	; Check If Any Player Seeking
	beq	CalcTraj_9	; Exit If Not

	move.l	#32*MPH,d3	; Set For 32 MPH Run
	jsr	AIBias	; Bias For AI Level
	move.l	d3,DistanceInc	; Distance Increment
	clr.l	TotalDistance	; Clear Total Distance Covered

	move.l	#CalcTrajTable,a0	; Load Address Of Outfielder Table
	move.w	HitDirection,d0	; Load Hit Direction
	and.w	#0xFFF8,d0	; Extract Upper Bits
	move.l	(a0,d0.w),Seeker2	; Save Seeking Outfielder
	move.l	4(a0,d0.w),BackupPlayer	; Load Address Of Backup Fielder	

	clr.b	WallFlag	; Clear Bounce Off Wall Flag

	move.l	#Baseball,a1	; Load Address Of Baseball
	move.l	WORLDX(a1),BallX	; Load X Position
	move.l	WORLDY(a1),BallY	; Load Y Position
	move.l	WORLDZ(a1),BallZ	; Load Z Position
	move.l	WORLDXVEL(a1),BallXVel	; Load X Velocity
	move.l	WORLDYVEL(a1),BallYVel	; Load Y Velocity
	move.l	WORLDZVEL(a1),BallZVel	; Load Z Velocity

	move.l	BallXVel,d0	; Move X Velocity To d0
	or.l	BallYVel,d0	; Or With Y Velocity
	beq	CalcStop_9	; Exit If Not Moving
CalcStop_1:
	move.l	DistanceInc,d0	; Load Distance Increment
	add.l	d0,TotalDistance	; Add To Total Distance

	move.l	BallXVel,d0	; Load X Velocity
	add.l	d0,BallX	; Add To World X

	move.l	BallYVel,d0	; Load Y Velocity
	add.l	d0,BallY	; Add To World Y

	move.l	BallZVel,d0	; Load Z Velocity
	add.l	d0,BallZ	; Add To World Z

	sub.l	#BALLGRAVITY,BallZVel	; Add In Gravity Effect

	tst.b	WallFlag	; Check If Ball Has Bounced Off Wall
	bne.s	CalcStop_4	; Branch If It Has

	move.l	BallX,d0	; Load X Position
	bpl.s	CalcStop_2	; Branch If Positive
	neg.l	d0	; Make It Positive
CalcStop_2:
	lsr.l	#8,d0	; Extract Inches
	lsr.l	#3,d0	; Extract 8 Inches
	lsl.w	#1,d0	; Multiply By Two
	move.l	#StadiumY,a2	; Load Address Of Stadium Data
	move.w	(a2,d0.w),d0	; Load Stadium Y Position
	lsl.l	#8,d0	; Shift Up Inches
	cmp.l	BallY,d0	; Load Ball's Y Position
	bge.s	CalcStop_4	; Branch If Fine

	move.l	WallHeight,d0	; Load Wall's Height
	cmp.l	BallZ,d0	; Check Ball Height (Over Wall)
	blt.s	CalcStop_4	; Branch If Not Over The Fence

	move.l	BallXVel,d0	; Load The X Velocity
	neg.l	d0	; Bounce Off The Wall
	asr.l	#2,d0	; Divide By Four
	move.l	d0,BallXVel	; Save The New Velocity

	move.l	BallYVel,d0	; Load The Y Velocity
	neg.l	d0	; Bounce Off The Wall
	asr.l	#2,d0	; Divide By Four
	move.l	d0,BallYVel	; Save The New Velocity

	move.b	#1,WallFlag	; Set For Wall Bounce

CalcStop_4:
	move.l	#Seeker1,a1	; Load Address Of Seeker 1
	jsr	CheckSeek	; Check Seeker
	move.l	#Seeker2,a1	; Load Address Of Seeker 2
	jsr	CheckSeek	; Check Seeker

	tst.l	BallZ	; Check Z Position
	bpl	CalcStop_1	; Branch If Not Underground Yet

	move.l	BallXVel,d0	; Load X Velocity
	asr.l	#2,d0	; Divide By Four
	sub.l	d0,BallXVel	; Slow Ball Down

	move.l	BallYVel,d0	; Load Y Velocity
	asr.l	#2,d0	; Divide By Four
	sub.l	d0,BallYVel	; Slow Ball Down

	move.l	BallXVel,d0	; Load X Velocity
	bpl.s	CalcStop_5	; Branch If Positive
	neg.l	d0 	; Make It Positive
CalcStop_5:
	move.l	BallYVel,d1	; Load Y Velocity
	bpl.s	CalcStop_6	; Branch If Positive
	neg.l	d1 	; Make It Positive
CalcStop_6:
	add.l	d1,d0	; Add The Two Velocities
	cmp.l	#0x200,d0	; Check If Slow
	blt.s	CalcStop_9	; Branch If not

	move.l	BallZVel,d0	; Load Z Velocity
	neg.l	d0	; Make Positive Again
	asr.l	#1,d0	; Divide By Two
	move.l	d0,BallZVel	; Store New Velocity
	clr.l	BallZ	; Clear Z Position
	bra	CalcStop_1
CalcStop_9:
CalcTraj_9:
	tst.l	Seeker1	; Check If Assignment Given
	beq.s	CalcTraj_A	; Branch If It Has

	move.l	DistanceInc,d0	; Load Distance Increment
	add.l	d0,TotalDistance	; Add To Total Distance
	move.l	BallXVel,d0	; Load X Velocity
	add.l	d0,BallX	; Add To World X
	move.l	BallYVel,d1	; Load Y Velocity
	add.l	d1,BallY	; Add To World Y
	or.l	d0,d1	; Or Together The Velocities
	beq.s	CalcTraj_A	; Branch If None

	move.l	#Seeker1,a1	; Load Address Of Seeker 1
	jsr	CheckSeek	; Check Seeker
	bra.s	CalcTraj_9

CalcTraj_A:
	move.l	BackupPlayer,a0	; Load Backup Player Address
	move.l	#32*MPH,d3	; Set For 32 MPH Run
	move.l	BallX,d4	; Load Ball X Position
	move.l	BallY,d5	; Load Ball Y Position
	move.l	#EndBackupRun,a2	; Ending For Run
	move.w	#AT_RANGE,d1	; Use Range Attribute
	jsr	RunToXY	; Set For Run

	rts

CheckSeek:
	tst.l	(a1)	; Check If Defined Yet
	beq.s	CheckSeek_9	; Branch If It Is
	cmp.l	#10*12*256,BallZ	; Check If Ball Low Enough To Catch
	bgt.s	CheckSeek_9	; Branch If Not
	move.l	(a1),a0	; Load Seeker Address
	move.l	WORLDX(a0),d6	; Load World Position
	sub.l	BallX,d6	; Subtract Ball X Position
	move.l	WORLDY(a0),d7	; Load World Position
	sub.l	BallY,d7	; Subtract Ball Y Position
	jsr	CalcDistance	; Calculate Distance
	cmp.l	TotalDistance,d1	; Compare With Last Distance
	bgt.s	CheckSeek_9	; Branch If Less
	clr.l	(a1)	; Clear Seeker Address
	move.l	DistanceInc,d3	; Set For 30 MPH Run
	move.l	BallX,d4	; Load Ball X Position
	move.l	BallY,d5	; Load Ball Y Position

	move.l	#EndSeekRun,a2	; Ending For Run
	move.w	#AT_RANGE,d1	; Use Range Attribute
	jsr	RunToXY	; Set For Run

	tst.w	RunTime	; Check If Already There
	bne.s	CheckSeek_9	; Branch If Not
	move.l	a2,PARSEPOINTER(a0)	; Force To End Seek
	clr.w	DURATION(a0)
CheckSeek_9:
	rts

CalcTrajTable:
	dc.l	RightField,CenterField	;  0 - 7
	dc.l	RightField,CenterField	;  8 - 15
	dc.l	RightField,CenterField	; 16 - 23
	dc.l	RightField,CenterField	; 24 - 31
	dc.l	RightField,CenterField	; 32 - 39
	dc.l	CenterField,RightField	; 40 - 47
	dc.l	CenterField,RightField	; 48 - 55
	dc.l	CenterField,RightField	; 56 - 63

	dc.l	CenterField,LeftField	; 64 - 71
	dc.l	CenterField,LeftField	; 72 - 79
	dc.l	CenterField,LeftField	; 80 - 87
	dc.l	LeftField,CenterField	; 88 - 95
	dc.l	LeftField,CenterField	; 96 - 103
	dc.l	LeftField,CenterField	;104 - 111
	dc.l	LeftField,CenterField	;112 - 119
	dc.l	LeftField,CenterField	;120 - 127
	dc.l	LeftField,CenterField	;128 - inf


;***************************************************************************
;   CheckIfOut - Check If Runner Out After Slide		*
;                                                                          *
;   Parameters :  a5 - Address Of Runner		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
CheckIfOut:
	clr.b	B_SLIDING(a5)	; No Longer Sliding
	tst.b	B_OUT(a5)	; Check If Tagged Out
	beq.s	CheckIf_1	; Branch If Not
	SOUND	#UmpCallsOut,d0	; Normal Out Sound
	jsr	AddOut	; Add An Out
	move.l	a5,a0	; Move Address To A0
	jsr	RunToDugout	; Run To Dug Out
	move.b	#-1,B_INUSE(a0)	; in use but not playing
CheckIf_1:
	rts

;***************************************************************************
;   SlideTagOut - Check If Runner Out After Slide	*
;                                                                          *
;   Parameters :  a5 - Address Of Runner		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
SlideTagOut:
	move.l	PARENT(a5),a0	; Load Address Of Sliding	Runner
	tst.b	B_ONBASE(a0)	; Check If On Base
	bpl.s	SlideTag_1	; Branch If He Is
	move.b	#1,B_OUT(a0)	; Flag Runner Out
	jsr	ChangeRunner	; Give Controls To Different Runner
SlideTag_1:
	rts


RegularTag:
	SYSTEM	FaceRunner
	CLEAR	B_MOVABLE
	DSPRITES	f08a01,f08b01,f08c01,f08d01,f08e01,f08f01,f08g01,f08f01
	DSPRITE	1
	NEXTSPRITE 1
	NEXTSPRITE 1
	NEXTSPRITE 4
	NEXTSPRITE 1
	NEXTSPRITE 1
	SETRAM	B_MOVABLE,1
	JUMP	EndRunCover

	.export 	TagAnim
TagAnim:
	CLEAR	 B_MOVABLE
	LASTFRAME	 1
	NEXTSPRITE 1
	NEXTSPRITE 1
	NEXTSPRITE 2
	SYSTEM	 SlideTagOut
	LASTFRAME	 5
	SYSTEM	 SlideTagOut
	LASTFRAME	 5
	SYSTEM	 SlideTagOut
	LASTFRAME	 5
	SYSTEM	 SlideTagOut
	LASTFRAME	 3
	NEXTSPRITE 2
	NEXTSPRITE 2
	NEXTSPRITE 2
	NEXTSPRITE 2
	UPDATE	 TrackPlayer
	SETRAM	 B_MOVABLE,1
	JUMP	 EndRunCover

CatcherTag:
	CLEAR	B_MOVABLE
	SPRITE	ctgs01,1
	SPRITE	ctgs03,1
	SPRITE	ctgs05,1
	SPRITE	ctgs06,2
	SYSTEM	SlideTagOut
	SPRITE	ctgs06,5
	SYSTEM	SlideTagOut
	SPRITE	ctgs06,5
	SYSTEM	SlideTagOut
	SPRITE	ctgs06,5
	SYSTEM	SlideTagOut
	SPRITE	ctgs09,3
	SPRITE	ctgs10,2
	SPRITE	ctgs11,2
	SPRITE	ctgs12,2
	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
CatcherTag_1:
	LASTFRAME	10
	JUMP	CatcherTag_1

RunnerRun:
	ALWAYS	RunnerUpdate	; Process Runner
	SETRAMW	DURATIONRESET,4	; Set For 20HZ Anim
	DSPRITES	rt1a01,rt1b01,rt1c01,rt1d01,rt1e01,rt1f01,rt1g01,rt1h01
RunRun_1:
	DSPRITE	-1	; Running Picture Number
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	JUMP	RunRun_1

SlideGetUp:
	CMPBI	B_SLIDING,1	; Check If Sliding
	JUMPNE	SlideGet_1	; Branch If Not
	CLEAR	B_SLIDING	; Not Sliding No More
;	LASTFRAME	6
;	SETRAMW	DURATIONRESET,3	; Set For 20HZ Anim
;	SETRAM	BANK,FielderTopBank
	CLEAR	FLIPFLAG
;	DSPRITES	fgua01,fgub01,fguc01,fgud01,fgue01,fguf01,fgug01,fguh01
;	DSPRITE	-1
;	NEXTSPRITE -1
;	NEXTSPRITE -1
;	NEXTSPRITE -1
;	NEXTSPRITE -1
;	NEXTSPRITE -1
;	NEXTSPRITE -1
;	NEXTSPRITE -1
;	SETRAM	BANK,RunnerTopBank
	SYSTEM	CheckIfOut
SlideGet_1:
	QED

Slide4:
	SETFLIP
Slide1:
	SPRITE	r76f01,3
	SPRITE	r76f02,3
	SPRITE	r76f03,3
	SPRITE	r76f04,3
	SPRITE	r76f05,3
	SPRITE	r76f06,3
	SPRITE	r76f07,3
	SPRITE	r76f08,3
Slide1_1:
	SPRITE	r76f08,3
	JUMP	Slide1_1

Slide6:
	SETFLIP
Slide2:
	SPRITE	rxca02,3
	SPRITE	rxca03,3
	SPRITE	rxca04,3
	SPRITE	rxca05,3
	SPRITE	rxca06,3
	SPRITE	rxca07,3
Slide2_1:
	SPRITE	rxca07,3
	JUMP	Slide2_1

Slide3:
	SETFLIP
Slide5:
	SPRITE	rxaa03,3
	SPRITE	rxaa04,3
	SPRITE	rxaa05,3
	SPRITE	rxaa06,3
	SPRITE	rxaa07,3
	SPRITE	rxaa08,3
Slide3_1:
	SPRITE	rxaa08,3
	JUMP	Slide3_1

Slide9:
Slide7:
	SETFLIP
Slide13:
Slide11:
	SPRITE	rx9a03,3
	SPRITE	rx9a04,3
	SPRITE	rx9a05,3
	SPRITE	rx9a06,3
	SPRITE	rx9a07,3
	SPRITE	rx9a08,3
Slide11_1:
	SPRITE	rx9a08,3
	JUMP	Slide11_1

Slide8:
	SETFLIP
Slide12:
	SPRITE	r45b01,3
	SPRITE	r45b02,3
	SPRITE	r45b03,3
	SPRITE	r45b04,3
	SPRITE	r45b05,3
	SPRITE	r45b06,3
	SPRITE	r45b07,3
	SPRITE	r45b08,3
Slide12_1:
	SPRITE	r45b08,3
	JUMP	Slide12_1

Slide10:
	SETFLIP
Slide14:
	SPRITE	r48b01,3
	SPRITE	r48b02,3
	SPRITE	r48b03,3
	SPRITE	r48b04,3
	SPRITE	r48b05,3
	SPRITE	r48b06,3
	SPRITE	r48b07,3
	SPRITE	r48b08,3
Slide14_1:
	SPRITE	r48b08,3
	JUMP	Slide14_1

Dust:
	ALWAYS	FollowSlider
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
	SPRITE	dust0012,1
	SPRITE	dust0013,1
	SPRITE	dust0014,1
	SPRITE	dust0015,1
	SPRITE	dust0016,1
	SPRITE	dust0017,1
	SPRITE	dust0018,1
	SPRITE	dust0019,1
	JUMP	Dust

	.align	2
FaceRunner:
	move.l	PARENT(a5),a0	; Load Address Of Runner
	move.l	WORLDX(a0),d4	; Load Runner X
	sub.l	WORLDX(a5),d4	; Subtract Fielder Position
	move.l	WORLDY(a0),d5	; Load Runner Y
	sub.l	WORLDY(a5),d5	; Subtract Fielder Position
	jsr	CalcDirection	; Determine Player Direction
	move.b	d0,B_DIRECTION(a5)	; Store The Direction
	rts

FollowSlider:
	move.l	PARENT(a5),a0	; Load Address Of Slider
	tst.b	B_SLIDING(a0)	; Check If Still Sliding
	beq.s	Follow_1	; Branch If Not

	move.w	XPOSITION(a0),XPOSITION(a5)	; Copy X Position
	move.w	YPOSITION(a0),YPOSITION(a5)	; Copy Y Position
	move.w	ZPOSITION(a0),d0	; Load Z Position
	add.w	#10,d0	; Place Infront Of Player
	move.w	d0,ZPOSITION(a5)	; Store Dust Z Position
	rts
Follow_1:
	move.b	#1,DELETED(a5)	; Remove Dust
	rts


StickOnFirst:
;	SPRITE	rx3a01,2
;	SPRITE	rx3a02,2
;	SPRITE	rx3a03,2
;	SPRITE	rx3a04,2
;	SPRITE	rx3a05,2
;	SPRITE	rx3a06,2
;	SPRITE	rx3a07,2
;	SPRITE	rx3a08,2
;	SPRITE	rx3a09,2
Stick1st_1:
	SPRITE	rx3a10,10
	JUMP	Stick1st_1

StickOnSecond:
;	SPRITE	rx5a01,2
;	SPRITE	rx5a02,2
;	SPRITE	rx5a03,2
;	SPRITE	rx5a04,2
;	SPRITE	rx5a05,2
;	SPRITE	rx5a06,2
;	SPRITE	rx5a07,2
;	SPRITE	rx5a08,2
;	SPRITE	rx5a09,2
Stick2nd_1:
	SPRITE	rx5a10,10
	JUMP	Stick2nd_1

StickOnThird:
;	SPRITE	rx7a01,2
;	SPRITE	rx7a02,2
;	SPRITE	rx7a03,2
;	SPRITE	rx7a04,2
;	SPRITE	rx7a05,2
;	SPRITE	rx7a06,2
;	SPRITE	rx7a07,2
;	SPRITE	rx7a08,2
;	SPRITE	rx7a09,2
Stick3rd_1:
	SPRITE	rx7a10,10
	JUMP	Stick3rd_1

CatcherRun:
	SETRAMW	DURATIONRESET,3	; Set For 20HZ Anim
	DSPRITES	c02a01,c02b01,c02c01,c02d01,c02e01,c02f01,c02g01,c02h01
CatchRun_1:
	DSPRITE	-1	; Running Picture Number
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	JUMP	CatchRun_1

FielderRun:
	SETRAMW	DURATIONRESET,3	; Set For 20HZ Anim
	DSPRITES	f03a01,f03b01,f03c01,f03d01,f03e01,f03f01,f03g01,f03h01
FieldRun_1:
	DSPRITE	-1	; Running Picture Number
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	JUMP	FieldRun_1

	.export	StopRun,EndRun,EndSeekRun,EndBackupRun
StopRun:
	SYSTEM	ClearVels	; Clear All Velocities
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
;	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	10
	JUMP	StopRun

EndRunC:
	GOALPOS
EndRun:
	SYSTEM	ClearVels	; Clear All Velocities
	FACEBALL	1
	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x01
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	2
	JUMP	EndRun

EndSeekRun:
	SYSTEM	ClearVels	; Clear All Velocities
	SYSTEM	ContinueSeek	; Continue Seeking Ball
	FACEBALL	1
	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x01
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	2
	JUMP	EndSeekRun

EndMarkerRun:
	SYSTEM	ClearVels	; Clear All Velocities
	SYSTEM	CheckForWall	; Check If Off Wall
	FACEBALL	1
	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x01
	DSPRITE	2
	JUMP	EndMarkerRun

EndBackupRun:
	SYSTEM	ClearVels	; Clear All Velocities
	FACEBALL	1
	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x01
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	2
	SYSTEM	BackupToBall
	JUMP	EndBackupRun

EndDugOut:
EndDug_1:
	SETRAM	B_ONBASE,5	; Flag On Base
	CLEAR	B_INUSE
	SPRITE	rx3a10,10
	JUMP	EndDug_1

EndRunPastFirst:
	SYSTEM	BackToFirst

EndRunToFirst:
	CLEAR	B_FORCED
	SETRAM	B_ONBASE,1	; Flag On Base
	EXECUTE	SlideGetUp
	SYSTEM	CheckFirst	; Check Player At First
StayAtFirst:
	SPRITE	rx3a10,10
	JUMP	StayAtFirst

EndRunToSecond:
	CLEAR	B_FORCED
	SETRAM	B_ONBASE,2	; Flag On Base
	EXECUTE	SlideGetUp
	SYSTEM	CheckSecond	; Check Player At Second
EndRun2_1:
	SPRITE	rx3a10,10
	JUMP	EndRun2_1

EndRunToThird:
	CLEAR	B_FORCED
	SETRAM	B_ONBASE,3	; Flag On Base
	EXECUTE	SlideGetUp
	SYSTEM	CheckThird	; Check Player At Third
EndRun3_1:
	SPRITE	r06b06,10
	JUMP	EndRun3_1

EndRunToHome:
	CLEAR	B_FORCED
	SETRAM	B_ONBASE,4	; Flag On Base
	EXECUTE	SlideGetUp
	SYSTEM	CheckHome	; Check Player At Home
EndRunH_1:
	SPRITE	rx3a10,10
	JUMP	EndRunH_1

KnockDown:
	SOUNDS	FielderHitsGrass
	SPRITE	ff6a01,2
	SPRITE	ff6a02,2
	SPRITE	ff6a03,2
	SPRITE	ff6a04,2
	SPRITE	ff6a05,2
	SPRITE	ff6a06,2
	SPRITE	ff6a07,2
	SYSTEM	ClearVels
	SPRITE	ff6a08,10
	SPRITE	fgue01,2
	SPRITE	fgue02,2
	SPRITE	fgue03,2
	SPRITE	fgue04,2
	SPRITE	fgue05,2
	SPRITE	fgue06,2
	SPRITE	fgue07,2
	SPRITE	fgue08,2
	SETRAM	B_MOVABLE,1
	SETRAM	B_CATCHACTIVE,1
	JUMP	EndRun
	
WallImpact:
	CLEAR	B_MOVABLE
	SOUNDS	FielderHitsWall
	SPRITE	ff1a04,2
	SPRITE	ff1a05,2
	SPRITE	ff1a06,2
	SPRITE	ff1a07,2
	SPRITE	ff1a08,2
	SPRITE	ff1a09,2
	SYSTEM	ClearVels	; Clear Velocities
	SPRITE	fgua01,12
	SPRITE	fgua02,2
	SPRITE	fgua03,2
	SPRITE	fgua04,2
	SPRITE	fgua05,2
	SPRITE	fgua06,2
	SPRITE	fgua07,2
	SPRITE	fgua08,2
	CLEAR	B_DIRECTION
	JUMP	EndRunCover

	.align	2
CheckForWall:
	tst.b	BallOnGround	; Check If Ball Touched Something
	beq.s	CheckWall_9	; Branch If not
	move.l	#EndSeekRun,PARSEPOINTER(a5) ; Ending For Run
CheckWall_9:
	rts

ContinueSeek:
	move.l	#EndMarkerRun,a2	; Ending For Run
	move.l	MarkerPtr,a1	; Load Address Of Marker
	move.l	WORLDX(a1),d4	; Load Marker X Position
	move.l	WORLDY(a1),d5	; Load Marker Y Position
	cmp.l	WORLDX(a5),d4	; Check If There
	bne.s	ContSeek_1	; Branch If Not
	cmp.l	WORLDY(a5),d5	; Check If There
	beq.s	ContSeek_9	; Branch If He Is
ContSeek_1:
	tst.l	a1	; Check If Ball Touched Ground Yet
	bne.s	ContSeek_2	; Branch If Not
	tst.b	BallActive	; Check If Ball Active
	beq.s	ContSeek_3	; Branch If Not
	move.l	#EndSeekRun,a2	; Ending For Run
	clr.l	d4	; Set For Home Plate
	clr.l	d5	; Set For Home Plate
	move.l	Baseball+WORLDY,d0	; Load Y Position Of Ball
	cmp.l	WORLDY(a5),d0	; Compare With Player Position
	blt.s	ContSeek_2	; Branch If Toward Home

;	move.w	#20,d0	; Calculate Ball Position In 30 Ticks	
;	jsr	CalcBallPos	; Calculate Ball Position

	move.l	Baseball+WORLDX,d4	; Load X Position Of Ball
	move.l	Baseball+WORLDY,d5	; Load Y Position Of Ball

	move.l	#EndSeekRun,a2	; Ending For Run
ContSeek_2:
	move.l	d5,d0	; Load Destination Y
	sub.l	WORLDY(a5),d0	; Subtract Player's Position
	cmp.l	#120*12*256,d0	; Check If More Than 120 Feet
	bge.s	ContSeek_3	; Exit If Too Far

	move.l	a5,a0	; Move Address To A0
	move.l	#45*MPH,d3	; Set For 35 MPH Run
	jsr	AIBias	; Bias For AI Level
	move.w	#AT_RANGE,d1	; Use Range Attribute
	jsr	RunToXY	; Set For Run
	bra.s	ContSeek_9
ContSeek_3:
	move.l	#EndRun,PARSEPOINTER(a5)	; Go To End Run
ContSeek_9:
	rts

ClearVels:
	clr.l	WORLDXVEL(a5)	; Clear X Velocity
	clr.l	WORLDYVEL(a5)	; Clear Y Velocity
	clr.l	WORLDZVEL(a5)	; Clear Z Velocity
	rts

	.export	BallRolling
BackupToBall:
	cmp.l	ControlPtr,a5	; Check If Controlled Player
	beq.s	BackToBall_9	; Branch If He Is
	tst.b	BallRolling	; Check If Ball Is Rolling
	beq.s	BackToBall_9	; Exit If Not
	move.l	#Baseball,a1	; Load Address Of Baseball
	move.l	a5,a0	; Move Address Of a0
	move.l	#EndRun,a2	; Set Run End
	move.l	#30*MPH,d3	; Set Speed Of Run
	jsr	AIBias	; Bias For AI Level
	move.l	WORLDX(a1),d4	; Load X Position Of Baseball
	move.l	WORLDY(a1),d5	; Load Y Position Of Baseball
	move.w	#AT_RANGE,d1	; Use Range Attribute
	jsr	RunToXY	; Run To Ball
BackToBall_9:
	rts

;***************************************************************************
;   RunnerUpdate - Process Runner		*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
	.export	RunnerUpdate
RunnerUpdate:
	jsr	CheckSlide	; Check For Sliding
RunnerUpdate2:
	jsr	SpeedUpRun	; Speed Up Running With Trackball
	jsr	CheckRunner	; Check Base Running
	rts

;***************************************************************************
;   SpeedUpRun - Increase Runner Speed Based On Trackball	*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
SpeedUpRun:
	cmp.l	#FirstRunner,a5	; Check If First Runner
	bne.s	SpeedUp_1	; First Runner Can Not Be Sped Up

	cmp.b	#-1,B_ONBASE(a5)	; Check If Running To First
	beq.s	SpeedUp_9	; Exit If He Is
;
;	tst.b	Flyball	; Check For Fly Ball
;	bne.s	SpeedUp_9	; Exit If It Is
SpeedUp_1:
	move.l	AtBatPlayer,a0	; Load Address Of At Bat Player
	clr.l	d0	; Clear D0
	move.w	TRACKYVEL(a0),d0	; Load Trackball Velocity

	move.l	#RunForwardTable,a1	; Load Address Of Forward Table
	move.b	B_ONBASE(a5),d1	; Load On Base Flag
	ext.w	d1	; Extend To A Word

	tst.b	(a1,d1.w)	; Check If Forward
	beq.s	SpeedUp_2	; Branch If Backward

	tst.w	d0	; Check If Forward Trackball
	bpl.s	SpeedUp_9	; Exit If Forward
	neg.w	d0	; Make It Positive
	bra.s	SpeedUp_3
SpeedUp_2:
	tst.w	d0	; Check If Forward Trackball
	bmi.s	SpeedUp_9	; Exit If Back
SpeedUp_3:
	tst.b	([AtBatPlayer],COMPUTER)	; Check If Computer Player
	beq.s	SpeedUp_4	; Branch If Not
	move.w	#0x20,d0	; Set For Computer Speed Up
SpeedUp_4:
	move.w	d0,d1	; Save Velocity In D1
	muls	WORLDXVEL+2(a5),d1	; Multiply By Runner Velocity
	asr.l	#5,d1	; Divide By 32
	add.l	d1,WORLDX(a5)	; Add Into X Position

	move.w	d0,d1	; Save Velcoity In D1
	muls	WORLDYVEL+2(a5),d1	; Multiply By Runner Velocity
	asr.l	#5,d1	; Divide By 32
	add.l	d1,WORLDY(a5)	; Add Into Y Position

	cmp.w	#0x14,d0	; Check If Velocity Fast 
	blt.s	SpeedUp_5	; Branch If Not
	subq.w	#1,DURATION(a5)	; Decrement Duration
SpeedUp_5:
	lsl.l	#3,d0	; Multiply By Eight
	sub.l	d0,B_SEEKING(a5)	; Decrement Seeking
	bne.s	SpeedUp_9	; Branch If Still Seeking
	move.l	#0x100,B_SEEKING(a5)	; Stop Seeking Soon
SpeedUp_9:
	rts

;***************************************************************************
;   CheckSlide - Check For Sliding Distance And Condition	*
;                                                                          *
;   Parameters :  a5 - Address Of Player		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
CheckSlide:
	cmp.b	#-1,B_ONBASE(a5)	; Check If Running To First
	beq.s	CheckSlid_8	; Branch If He Is
	tst.b	B_ONBASE(a5)	; Check If Already On Base
	bpl.s	CheckSlid_8	; Branch If He Is
	tst.b	B_FORCEBACK(a5)	; Check If Forced Back
	bne.s	CheckSlid_8	; Branch If He Is

	move.l	B_GOALX(a5),d0	; Load Goal X Position
	sub.l	WORLDX(a5),d0	; Subtract X Position
	bpl.s	CheckSlid_7	; Branch If Positive
	neg.l	d0	; Make Result Positive
CheckSlid_7:
	cmp.l	#10*12*256,d0	; Check If Within 10 Feet
	bge.s	CheckSlid_9	; Branch If Not
	move.w	B_RUNNERGOAL(a5),d0	; Load Runner's Goal
	cmp.w	Destination,d0	; Check If Ball Is Heading There
	bne.s	CheckSlid_8	; Exit If It Isn't

	move.b	B_ONBASE(a5),d2	; Load On Base Flags
	bpl.s	CheckSlid_8	; Exit If On Base
	ext.w	d2	; Extend To A Word
	neg.w	d2	; Make It Positive
	lsl.w	#4,d2	; Multiply By Sixteen
	move.l	#Slides,a0	; Load Address Of Slides
	lea	(a0,d2.w),a0	; Index To Correct Slides
	jsr	Random	; Get A Random Number
	and.w	#3,d0	; Extract 0-3
	move.l	(a0,d0.w*4),d0	; Get Slide Address
	move.l	d0,PARSEPOINTER(a5)	; Start The Slide
	move.b	#1,B_SLIDING(a5)	; Flag As Sliding
	clr.w	DURATION(a5)	; Start Up Soon
	SOUND	#PlayerSlides,#0

	jsr	MakeDust	; Start Up Dust

CheckSlid_8:
	move.l	#RunnerUpdate2,ALWAYSROUTINE(a5) ; Stop Checking
CheckSlid_9:
	rts

Slides:
	dc.l	0	; 0 - Inactive Slide
	dc.l	0	; 0 - Inactive Slide
	dc.l	0	; 0 - Inactive Slide
	dc.l	0	; 0 - Inactive Slide

	dc.l	0 	; 1 - Slide To First
	dc.l	0 	; 1 - Slide To First
	dc.l	0 	; 1 - Slide To First
	dc.l	0 	; 1 - Slide To First

	dc.l	Slide1 	; 2 - Slide To Second
	dc.l	Slide2 	; 2 - Slide To Second
	dc.l	Slide3 	; 2 - Slide To Second
	dc.l	Slide1 	; 2 - Slide To Second
	
	dc.l	Slide11 	; 3 - Slide Back To First
	dc.l	Slide12 	; 3 - Slide Back To First
	dc.l	Slide13 	; 3 - Slide Back To First
	dc.l	Slide14 	; 3 - Slide Back To First

	dc.l	Slide7	; 4 - Slide To Third
	dc.l	Slide8	; 4 - Slide To Third
	dc.l	Slide9	; 4 - Slide To Third
	dc.l	Slide10	; 4 - Slide To Third

	dc.l	Slide4	; 5 - Slide Back To Second
	dc.l	Slide5	; 5 - Slide Back To Second
	dc.l	Slide6	; 5 - Slide Back To Second
	dc.l	Slide4	; 5 - Slide Back To Second

	dc.l	Slide11	; 6 - Slide To Home
	dc.l	Slide12	; 6 - Slide To Home
	dc.l	Slide13	; 6 - Slide To Home
	dc.l	Slide14	; 6 - Slide To Home

	dc.l	Slide1	; 7 - Slide Back To Third
	dc.l	Slide2	; 7 - Slide Back To Third
	dc.l	Slide3	; 7 - Slide Back To Third
	dc.l	Slide1	; 7 - Slide Back To Third

;***************************************************************************
;   MakeDust - Make Dust Around Slider		*
;				*
;   Parameters :  a5 - Address Of Slider		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
MakeDust:
	jsr	AllocObject	; Allocate An Object
	beq.s	MakeDust_1	; Branch If None
	move.l	#BlitAObject,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	clr.w	PICTURE(a0)	; Clear Picture
	move.l	#Dust,PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_DUST,PALETTE(a0)	; Set Palette Number
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
	move.l	a5,PARENT(a0)	; Store Parent's Address
MakeDust_1:
	rts


;***************************************************************************
;   CheckRunner - Check Running Direction Based On Trackball	*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
CheckRunner:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block Address
	beq.s	CheckRun_9	; Branch If Not Controlled
	move.l	d0,a0	; Move Address To A0

	move.b	B_ONBASE(a5),d0	; Load On Base Flag
;	tst.b	B_FORCED(a5)	; Check If Forced To Next Base
;	beq.s	CheckRun_1	; Branch If Not
;	clr.b	d0	; Only Check Bases
CheckRun_1:
	cmp.b	#6,BackupCount	; Check If Too Many Backups
	bge.s	CheckRun_5	; Branch If Enough

	cmp.w	#3,TRACKYVEL(a0)	; Check If Fast Enough
	blt.s	CheckRun_5	; Branch If Not Running
	move.l	#RunForwardTable,a1	; Load Address Of Forward Table
	ext.w	d0	; Extend To A Word
	move.b	(a1,d0.w),d0	; Load Action Required
	jsr	ForceForward	; Force Runners Forward
	bra.s	CheckRun_9

CheckRun_5:
	cmp.w	#-3,TRACKYVEL(a0)	; Check If Back Enough
	bgt.s	CheckRun_9	; Branch If Running Back
	move.l	#RunBackTable,a1	; Load Address Of Back Table
	ext.w	d0	; Extend To A Word
	move.b	(a1,d0.w),d0	; Load Action Required
	beq.s	CheckRun_9	; Branch If None
	bmi.s	CheckRun_6	; Branch If On Base
	add.b	#1,BackupCount	; Increment Counter
CheckRun_6:
	jsr	ForceBack	; Force Runners Back
CheckRun_9:
	rts

	dc.b	1	; -7 - From Home To Third
	dc.b	0	; -6 - From Third To Home
	dc.b	1	; -5 - From Third To Second
	dc.b	0	; -4 - From Second To Third
	dc.b	1	; -3 - From Second To First
	dc.b	0	; -2 - From First To Second
	dc.b	0	; -1 - From Home To First
RunForwardTable:
	dc.b	0	;  0 - Inactive
	dc.b	1	;  1 - On First Base
	dc.b	1	;  2 - On Second Base
	dc.b	1	;  3 - On Third Base
	dc.b	0	;  4 - On Home Plate
	dc.b	0	;  5 - In Dug Out
	
	dc.b	0	; -7 - From Home To Third
	dc.b	1	; -6 - From Third To Home
	dc.b	0	; -5 - From Third To Second
	dc.b	1	; -4 - From Second To Third
	dc.b	0	; -3 - From Second To First
	dc.b	1	; -2 - From First To Second
	dc.b	0	; -1 - From Home To First
RunBackTable:
	dc.b	0	;  0 - Inactive
	dc.b	-1	;  1 - On First Base
	dc.b	-1	;  2 - On Second Base
	dc.b	-1	;  3 - On Third Base
	dc.b	0	;  4 - On Home Plate
	dc.b	0	;  5 - In Dug Out


	.align	2

;***************************************************************************
;   CheckHome - Check Runner At Home Plate		*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
CheckHome:
	clr.b	BackupCount	; Clear Backup Count
	move.l	a5,a0	; Move Address To A0
	tst.b	HomeRun	; Check For Home Run
	bne.s	CheckH_3	; Branch If It Is
	tst.b	B_OUT(a5)	; Check If Player Was Out
	beq.s	CheckH_2	; Branch If Not
	jsr	RunToDugout	; Run To Dug Out
	jsr	AddOut	; Add An Out
	bra	CheckH_9
CheckH_2:	
CheckH_3:
	tst.b	BallInFlight	; Check Ball Still In Air
	bne.s	CheckH_4	; Branch If It Is

	jsr	WaitNoForced	; Make Sure No Runner Forced
	bne.s	CheckH_4	; Branch If Any Forced

	SOUND	#HeScores,#0	; Output Announcer Sound
	clr.b	B_FORCED(a5)	; No Longer Forced
	move.b	#4,B_ONBASE(a5)	; Set On Home Plate

	move.b	Inning,d0	; Load Inning Number
	ext.w	d0	; Extend To A Word
	lsr.w	#1,d0	; Extract Inning Number
	move.l	AtBatPlayer,a1	; Load Address Of Batter
	add.b	#1,(INNINGSSCORE,a1,d0.w)	; Increment Inning Score by using INNINGSSCORE
	add.b	#1,RUNS(a1)	; Increment Runs
	jsr	WinTestRun	; Check For A Win

	move.l	a5,a0	; Move Address To A0
	jsr	ChangeRunner	; Change Runner Controls
	move.l	a5,a0	; Move Address To A0
	jsr	RunToDugout	; Run To Dug Out

	cmp.l	#FirstRunner,a5	; Check For In Park Home Run
	bne.s	CheckH_9	; Branch If Not
	SOUND	#InsideParkHomerun,#0	; Output Announcer Sound
	add.b	#1,([AtBatPlayer],HITS)	; Increment Hits
	move.b	#1,DidGetHit      	; yes he hit
	bra.s	CheckH_9
CheckH_4:
	move.l	#WaitForBallDown,ALWAYSROUTINE(a5) ; Wait For Ball
	move.l	#StickOnSecond,PARSEPOINTER(a5)
CheckH_9:
	rts

WaitForBallDown:
	jsr	CheckRunner	; Let Trackball Work
	tst.b	BallInFlight	; Check If Ball Down Yet
	bne.s	WaitForBall_9	; Exit If Not
	tst.b	FliedOut	; Check If Flied Out
	bne.s	WaitForBall_9	; Branch If It Was

	jsr	WaitNoForced	; Make Sure No Runner Forced
	bne.s	WaitForBall_9	; Exit If Any Forced

	SOUND	#HeScores,#0	; Output Announcer Sound
	clr.l	ALWAYSROUTINE(a5)	; Clear Always Routine
	move.b	Inning,d0	; Load Inning Number
	ext.w	d0	; Extend To A Word
	lsr.w	#1,d0	; Extract Inning Number
	move.l	AtBatPlayer,a0	; Load Address Of Batter
	add.b	#1,(INNINGSSCORE,a0,d0.w)	; Increment Inning Score by using INNINGSSCORE
	add.b	#1,RUNS(a0)	; Increment Runs
	jsr	WinTestRun	; Check For A Win
	move.l	a5,a0	; Move Address To A0
	jsr	ChangeRunner	; Change Runner Controls
	move.l	a5,a0	; Move Address To A0
	jsr	RunToDugout	; Run To Dug Out
WaitForBall_9:
	rts

WaitNoForced:
	move.l	#ThirdRunner,a0	; Load Address Of Third Runner
WaitNoF_1:
	tst.b	B_INUSE(a0)	; Check If In Use
	beq.s	WaitNoF_2	; Branch If Not
	tst.b	B_OUT(a0)	; Check If Still Active
	bne.s	WaitNoF_2	; Branch If Out
	tst.b	B_FORCED(a0)	; Check If Noced
	bne.s	WaitNoF_9	; Exit If Any Runner Forced
WaitNoF_2:
	move.l	CHILD(a0),a0	; Index To Previous Runner
	tst.l	a0	; Check If Done
	bne.s	WaitNoF_1	; Continue If Not
	clr.b	d0
	rts
WaitNoF_9:
	move.b	#1,d0	; Forced Runner Found
	rts



;***************************************************************************
;   CheckThird - Check Runner At Third Base		*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
CheckThird:
	clr.b	BackupCount	; Clear Backup Count
	move.l	a5,a0	; Move Address To A0
	tst.b	HomeRun	; Check For Home Run
	bmi.s	CheckT_1	; Branch If It is
	tst.b	B_OUT(a5)	; Check If Player Was Out
	beq.s	CheckT_2	; Branch If Not
	jsr	RunToDugout	; Run To Dug Out
	jsr	AddOut	; Add An Out
	bra.s	CheckT_9
CheckT_1:
	jsr	RunToHome	; Run To Home
CheckT_2:
	clr.b	B_FORCED(a5)	; No Longer Forced
	move.b	#3,B_ONBASE(a5)	; Flag On Base
	move.l	#StickOnThird,PARSEPOINTER(a5) ; Store Stand On First Anim
	move.b	B_FORCEBACK(a5),d7	; Load Bases Returning To
	beq.s	CheckT_9	; Branch If None
	jsr	ForceBackRunner	; Check If Runner Needs To Be Forced Back
CheckT_9:
	jsr	CheckAllRunners	; Check If Two Runners On Same Base
	rts

;***************************************************************************
;   CheckSecond - Check Runner At Second Base		*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
CheckSecond:
	clr.b	BackupCount	; Clear Backup Count
	move.l	a5,a0	; Move Address To A0
	tst.b	HomeRun	; Check For Home Run
	bmi.s	CheckS_1	; Branch If It is
	tst.b	B_OUT(a5)	; Check If Player Was Out
	beq.s	CheckS_2	; Branch If Not
	jsr	RunToDugout	; Run To Dug Out
	jsr	AddOut	; Add An Out
	bra.s	CheckS_9
CheckS_1:
	jsr	RunToThird	; Run To Third
CheckS_2:
	clr.b	B_FORCED(a5)	; No Longer Forced
	move.b	#2,B_ONBASE(a5)	; Flag On Base
	move.l	#StickOnSecond,PARSEPOINTER(a5) ; Store Stand On Second Anim
	move.b	B_FORCEBACK(a5),d7	; Load Bases Returning To
	beq.s	CheckS_9	; Branch If None
	jsr	ForceBackRunner	; Check If Runner Needs To Be Forced Back
CheckS_9:
	jsr	CheckAllRunners	; Check If Two Runners On Same Base
	rts

;***************************************************************************
;   CheckFirst - Check Runner At First Base		*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
CheckFirst:
	tst.b	HomeRun	; Check For A Home Run
	bmi.s	CheckF_1	; Branch If It Is
	tst.b	B_OUT(a5)	; Check If Player Was Out
	beq.s	CheckF_2	; Branch If Not
	move.l	a5,a0	; Move Address To A0
	jsr	RunToDugout	; Run To Dug Out
	jsr	AddOut	; Add An Out
	bra.s	CheckF_9
CheckF_1:
	move.l	a5,a0	; Move Address To A0
	jsr	RunToSecond	; Run To Second
CheckF_2:
	clr.b	B_FORCED(a5)	; No Longer Forced
	move.l	#StickOnFirst,PARSEPOINTER(a5) ; Store Stand On First Anim
	clr.b	B_FORCEBACK(a5)	; Clear Forced Back Flag
	move.b	B_ONBASE(a5),d0	; Load On Base Status
	move.b	#1,B_ONBASE(a5)	; Set On First Base

	cmp.b	#-1,d0	; Check If Running From Home To First
	bne.s	CheckF_4	; Branch If Some Other Running

	cmp.w	#FIRST,Destination	; Check If Ball Thrown To First
	bne.s	CheckF_4	; Branch If It Isn't

	move.l	a5,a0	; Set For Run
	move.l	#20*MPH,d3	; Set For 20 MPH Run
	move.l	#FIRSTBASEX+20*12*256,d4	; Set 20 feet Past First
	move.l	#FIRSTBASEY+20*12*256,d5	; Load Second Base Y Position
	move.l	#EndRunPastFirst,a2	; Ending For Running Back To First
	move.w	#AT_SPEED,d1	; Use Speed Attribute
	jsr	RunToXY	; Set For Run
	jsr	BigSafeObj	; Big Safe Sign
	SOUND	#UmpCallsSafe,#0
CheckF_4:
CheckF_9:
	jsr	CheckAllRunners	; Check If Two Runners On Same Base
	rts

BackToFirst:
	move.l	a5,a0	; Set For Run
	move.l	#12*MPH,d3	; Set For 120 MPH Run
	move.l	#StayAtFirst,a2	; Ending For Running Back To First
	move.l	#FIRSTBASEX,d4	; Load First Base X Position
	move.l	#FIRSTBASEY-10,d5	; Load First Base Y Position
	move.w	#AT_SPEED,d1	; Use Speed Attribute
	jsr	RunToXY	; Run To Base
	rts

CheckAllRunners:
	move.l	#FirstRunner,a4	; Load Address Of First Runner
CheckAll_1:
	tst.b	B_INUSE(a4)	; Check If In Use
	beq.s	CheckAll_5	; Branch If Not
	tst.b	B_OUT(a4)	; Check If Out
	bne.s	CheckAll_5	; Branch If He Is
	clr.w	d0
	move.b	B_ONBASE(a4),d0	; Load First Runner's On Base
	bmi.s	CheckAll_5	; Branch If Off Base

	move.l	a4,a0	; Move Runner Address To A1
	add.l	#`sizeof(player_struct),a0	; Index To Next Runner
CheckAll_2:
	tst.b	B_INUSE(a0)	; Check If In Use
	beq.s	CheckAll_4	; Branch If Not
	tst.b	B_OUT(a0)	; Check If Out Already
	bne.s	CheckAll_4	; Branch If He Is

	cmp.b	B_ONBASE(a0),d0	; Check If On Same Base
	bne.s	CheckAll_4	; Branch If Different
	move.l	#CheckAllTable,a1	; Load Address Of Run Table
	move.l	(a1,d0.w*4),d1	; Load Routinue To Run
	beq.s	CheckAll_5	; Branch If Nothing To Do
	move.l	#CheckAllStatus,a1	; Load Address Of Run Status
	move.b	(a1,d0.w),B_ONBASE(a0)	; Store On Base Status
	move.l	d1,a1	; Move To Address Register
	jsr	(a1)	; Run To Next Base
;	move.b	#1,B_FORCED(a0)	; Set To Forced
	bra.s	CheckAll_5
CheckAll_4:
	add.l	#`sizeof(player_struct),a0	; Index To Next Runner
	cmp.l	#HomeRunner,a0	; Check If Done
	ble.s	CheckAll_2	; Continue Until All Done

CheckAll_5:
	add.l	#`sizeof(player_struct),a4	; Index To Next Runner
	cmp.l	#HomeRunner,a4	; Check If Done
	blt.s	CheckAll_1	; Continue Until All Done
	rts

CheckAllTable:
	dc.l	0	; 0 - Filler
	dc.l	FRunToSecond	; 1 - Run To Second Base
	dc.l	FRunToThird	; 2 - Run To Third Base
	dc.l	FRunToHome	; 3 - Run To Home
	dc.l	0	; 4 - Home Plate
	dc.l	0	; 5 - In Dugout

CheckAllStatus:
	dc.b	0	; 0 - Filler
	dc.b	-2	; 1 - Run To Second Base
	dc.b	-4	; 2 - Run To Third Base
	dc.b	-6	; 3 - Run To Home
	dc.b	0	; 4 - Home Plate
	dc.b	0	; 5 - In Dugout

	.align	2
	
;***************************************************************************
;   ForceForward - Force Runners To Next Base By Controlling Runner	*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;                 d0 - 0 if Base Checking All Runners	*
;	            1 if Forcing Runners Forward	*
;   Returns:      NONE		*
;   Modifies:     a0			*
;***************************************************************************
ForceForward:
	tst.b	d0	; Check If Just Base Checking
	bne.s	ForceFwd_5	; Branch If Forcing All

	move.l	a5,a0	; Move Controlled To d0
ForceFwd_1:
	move.l	CHILD(a0),d0	; Load Previous Runner
	beq	ForceFwd_9	; Exit If Done
	move.l	d0,a0	; Move Address To A0 Register
	tst.b	B_INUSE(a0)	; Check If In Use
	beq.s	ForceFwd_1	; Continue If Not
	tst.b	B_OUT(a0)	; Check If Out
	bne.s	ForceFwd_1	; Continue If Not
	tst.b	B_FORCEBACK(a0)	; Check If Forced Back To A Base
	bne.s	ForceFwd_1	; Branch If Not
	move.b	B_ONBASE(a0),d0	; Load Base Condition
	bmi.s	ForceFwd_1	; Branch If Off Base
	ext.w	d0	; Extend To A Word
	move.l	#ForwardCondition,a1	; Load Address Of Conditions Table
	move.b	(a1,d0.w),B_ONBASE(a0)	; Load New On Base Condition
	move.l	#ForwardTable,a1	; Load Address Of JSR Table
	move.l	(a1,d0.w*4),d0	; Load Routine Address
	beq.s	ForceFwd_1	; Branch If No Action
	move.l	d0,a1	; Move Rotuine Address To A1
	jsr 	(a1)	; Force Runner Forward
	beq.s	ForceFwd_1	; Branch If Not Done
	rts

ForceFwd_5:
	move.l	a5,d0	; Move Controlled To d0

ForceFwd_6:
	move.l	d0,a0	; Move Address To A0
	tst.b	B_INUSE(a0)	; Check If In Use
	beq.s	ForceFwd_8	; Continue If Not
	tst.b	B_OUT(a0)	; Check If Out
	bne.s	ForceFwd_8	; Continue If Not
	tst.b	B_SLIDING(a0)	; Check If Sliding
	bne.s	ForceFwd_8	; Continue If He Is
	tst.b	B_FORCEBACK(a0)   ; NEW	; Check If Forced Back To A Base
	bne.s	ForceFwd_8        ; NEW	; Branch If Not

	move.b	B_ONBASE(a0),d0	; Load Base Condition
	ext.w	d0	; Extend To A Word
	move.l	#ForwardCondition,a1	; Load Address Of Conditions Table
	move.b	(a1,d0.w),B_ONBASE(a0)	; Save New On Base Condition
	move.l	#ForwardTable,a1	; Load Address Of JSR Table
	move.l	(a1,d0.w*4),d0	; Load Routine Address
	beq.s	ForceFwd_8	; Branch If No Action
	move.l	d0,a1	; Move Rotuine Address To A1
	jsr 	(a1)	; Force Runner Forward
;	bne.s	ForceFwd_9	; Exit If No Run
ForceFwd_8:
	move.l	CHILD(a0),d0	; Load Previous Runner
	bne.s	ForceFwd_6	; Branch If Not Done
ForceFwd_9:
	rts

	dc.l	RunToHome	; -7 - From Home To Third
	dc.l	0	; -6 - From Third To Home
	dc.l	RunToThird	; -5 - From Third To Second
	dc.l	0	; -4 - From Second To Third
	dc.l	RunToSecond	; -3 - From Second To First
	dc.l	0	; -2 - From First To Second
	dc.l	0	; -1 - From Home To First
ForwardTable:
	dc.l	0	;  0 - Inactive
	dc.l	SRunToSecond	;  1 - On First Base
	dc.l	SRunToThird	;  2 - On Second Base
	dc.l	SRunToHome	;  3 - On Third Base
	dc.l	0	;  4 - On Home Plate
	dc.l	0	;  5 - In Dug Out

	dc.b	-6	; -7 - From Home To Third
	dc.b	-6	; -6 - From Third To Home
	dc.b	-4	; -5 - From Third To Second
	dc.b	-4	; -4 - From Second To Third
	dc.b	-2	; -3 - From Second To First
	dc.b	-2	; -2 - From First To Second
	dc.b	-1	; -1 - From Home To First
ForwardCondition:
	dc.b	0	;  0 - Inactive
	dc.b	-2	;  1 - On First Base
	dc.b	-4	;  2 - On Second Base
	dc.b	-6	;  3 - On Third Base
	dc.b	0	;  4 - On Home Plate
	dc.b	0	;  5 - In Dug Out

	.align	2
;***************************************************************************
;   ForceBack - Force Runners To Previous Base By Controlling Runner	*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;                 d0 - 0 if Base Checking All Runners	*
;	            1 if Forcing Runners Forward	*
;   Returns:      NONE		*
;   Modifies:     a0			*
;***************************************************************************
ForceBack:
;	tst.b	d0	; Check If Just Base Checking
;	bpl.s	ForceBack_5	; Branch If Forcing All
;
;	move.l	a5,a0	; Move Controlled To d0
;ForceBack_1:
;	move.l	CHILD(a0),d0	; Load Previous Runner
;	beq.s	ForceBack_9	; Exit If Done
;	move.l	d0,a0	; Move Address To A0
;	jsr	CheckForceBack	; Check If Force Bacl Allowed
;	beq.s	ForceBack_1	; Continue If Not
;
;	move.b	B_ONBASE(a0),d0	; Load Base Condition
;	bpl.s	ForceBack_1	; Branch If On Base
;	ext.w	d0	; Extend To A Word
;	move.l	#BackCondition,a1	; Load Address Of Conditions Table
;	move.b	(a1,d0.w),B_ONBASE(a0)	; Save New On Base Condition
;	move.l	#BackTable,a1	; Load Address Of JSR Table
;	move.l	(a1,d0.w*4),d0	; Load Routine Address
;	beq.s	ForceBack_1	; Branch If No Action
;	move.l	d0,a1	; Move Rotuine Address To A1
;	jsr 	(a1)	; Force Runner Back
;	bra.s	ForceBack_1
;
;ForceBack_5:
	move.l	a5,d0	; Move Controlled T0 A0
ForceBack_6:
	move.l	d0,a0	; Move Address To A0
	jsr	CheckForceBack	; Check If Force Back Allowed
	beq.s	ForceBack_8	; Continue If Not

	move.b	B_ONBASE(a0),d0	; Load Base Condition
	ext.w	d0	; Extend To A Word
	move.l	#BackCondition,a1	; Load Address Of Conditions Table
	move.b	(a1,d0.w),B_ONBASE(a0)	; Save New On Base Condition
	move.l	#BackTable,a1	; Load Address Of JSR Table
	move.l	(a1,d0.w*4),d0	; Load Routine Address
	beq.s	ForceBack_8	; Branch If No Action
	move.l	d0,a1	; Move Rotuine Address To A1
	jsr 	(a1)	; Force Runner Back
ForceBack_8:
	move.l	CHILD(a0),d0	; Load Previous Runner
	bne.s	ForceBack_6	; Branch If Done
ForceBack_9:
	rts

CheckForceBack:
	tst.b	B_INUSE(a0)	; Check If In Use
	beq.s	CheckForce_8	; Continue If Not
	tst.b	B_OUT(a0)	; Check If Out
	bne.s	CheckForce_8	; Continue If Not
	tst.b	B_SLIDING(a0)	; Check If Sliding
	bne.s	CheckForce_8	; Branch If He Is

	move.b	B_ONBASE(a0),d0	; Load On Base Flag
	ext.w	d0	; Extend To A Long
	bpl.s	CheckForce_8	; Branch If On A Base

	move.l	#CheckForceTable,a1	; Load Address Of Force Table
	move.b	(a1,d0.w*4),d1	; Load First Test Status
	beq.s	CheckForce_8	; Branch If Not Allowed

	move.l	CHILD(a0),a2	; Load Previous Runner
	tst.l	a2	; Check If Done
	beq.s	CheckForce_7	; Branch If Done

	tst.b	B_INUSE(a2)	; Check If Runner In Use
	beq.s	CheckForce_7	; Branch If Not

	move.b	B_ONBASE(a2),d2	; Load On Base Condition
	cmp.b	d1,d2	; Check If Allowed Condition
	beq.s	CheckForce_8	; Branch If Not
	cmp.b	1(a1,d0.w*4),d2	; Check If Allowed Condition
	beq.s	CheckForce_8	; Branch If Not
	cmp.b	2(a1,d0.w*4),d2	; Check If Allowed Condition
	beq.s	CheckForce_8	; Branch If Not

CheckForce_7:
	move.b	#1,d0	; Flag Allowed
	rts
CheckForce_8:
	clr.b	d0	; Flag Not Allowed
	rts

	dc.b	0,0,0,0	; -7 - From Home To Third
	dc.b	-6,3,-7,0	; -6 - From Third To Home
	dc.b	0,0,0,0	; -5 - From Third To Second
	dc.b	-4,2,-5,0	; -4 - From Second To Third
	dc.b	0,0,0,0	; -3 - From Second To First
	dc.b	-2,1,-3,0	; -2 - From First To Second
	dc.b	0,0,0,0	; -1 - From Home To First
CheckForceTable:

	dc.l	0	; -7 - From Home To Third
	dc.l	RunToThird	; -6 - From Third To Home
	dc.l	0	; -5 - From Third To Second
	dc.l	RunToSecond	; -4 - From Second To Third
	dc.l	0	; -3 - From Second To First
	dc.l	RunToFirst	; -2 - From First To Second
	dc.l	0	; -1 - From Home To First
BackTable:
	dc.l	0	;  0 - Inactive
	dc.l	0	;  1 - On First Base
	dc.l	0	;  2 - On Second Base
	dc.l	0	;  3 - On Third Base
	dc.l	0	;  4 - On Third Base
	dc.l	0	;  5 - In Dug Out

	dc.b	-7	; -7 - From Home To Third
	dc.b	-7	; -6 - From Third To Home
	dc.b	-5	; -5 - From Third To Second
	dc.b	-5	; -4 - From Second To Third
	dc.b	-3	; -3 - From Second To First
	dc.b	-3	; -2 - From First To Second
	dc.b	-1	; -1 - From Home To First
BackCondition:
	dc.b	0	;  0 - Inactive
	dc.b	1	;  1 - On First Base
	dc.b	2	;  2 - On Second Base
	dc.b	3	;  3 - On Third Base
	dc.b	0	;  4 - On Home Plate
	dc.b	0	;  5 - In Dug Out

	.align	2
;***************************************************************************
;* Always Check the POWERUP button, and increase or decrease meter         *
;*                                                                         *
;***************************************************************************
CheckPowerUp:		;WasPitcher
	move.l	#PlayerL,d0	; Load Control Block
	beq.s	Anim_bar_1	; Branch If Not In Control
	move.l	d0,a1	; Move Address Of Control Block To A1
	tst.b	POWERUP(a1)	; Check If Powered Up
	beq.s	CheckP_1	; Branch If He isn't
	move.l	PowerPtr,a0
Anim_bar_1:
	cmp.w	#1*256,PlayerL+TOTALPOWER	; Is player out of power?129
	bls.s	SkipAdd	; If yes, branch
;   	sub.w	#1*256,PlayerL+TOTALPOWER	; subtract from total power
	move.w	PlayerL+TOTALPOWER,d0
	lsr.w	#8,d0
	move.w	d0,XCLIP2(a0)
	add.w	#60,XCLIP2(a0)
	bra.s	SkipAdd	; Jump the add
CheckP_1:
	cmp.w	#84*256,PlayerL+TOTALPOWER	; Is Player Power Maxxed?
	bge.s	SkipAdd	; If so branch
	move.l	PowerPtr,a0	; move pointer to a0
	add.w	#1*4,PlayerL+TOTALPOWER	; Add 1 to Player Powerwas 8
	move.w	PlayerL+TOTALPOWER,d0
	lsr.w	#8,d0
	move.w	d0,XCLIP2(a0)
	add.w	#60,XCLIP2(a0)
SkipAdd:		
	rts


CheckPowerUp2:	                    	;was batter
	move.l	#PlayerR,d0	; Load Control Block
	beq.s	Anim_Bri_2	; Branch If Not In Control
	move.l	d0,a1	; Move Address Of Control Block To A1
	tst.b	POWERUP(a1)	; Check If Powered Up
	beq.s	CheckP_2	; Branch If He isn't
	move.l	PowerPtr2,a0	; Move Bar pointer to a0
Anim_Bri_2
	cmp.w	#1*256,PlayerR+TOTALPOWER	; Is player out of power?
	bls.s	SkipAdd	; If yes, branch
;	sub.w	#1*256,PlayerR+TOTALPOWER	; subtract from total power
	move.w	PlayerR+TOTALPOWER,d0
	lsr.w	#8,d0
	move.w	d0,XCLIP2(a0)
	add.w	#291,XCLIP2(a0)
	bra.s	SkipAdd2	; Jump the add
CheckP_2:
	cmp.w	#84*256,PlayerR+TOTALPOWER	; Is Player Power Maxxed?
	bge.s	SkipAdd	; If so branch
	move.l	PowerPtr2,a0	; move pointer to a0
	add.w	#1*4,PlayerR+TOTALPOWER	; Add 1 to Player Power was 8
	move.w	PlayerR+TOTALPOWER,d0
	lsr.w	#8,d0
       	move.w	d0,XCLIP2(a0)
  	add.w	#291,XCLIP2(a0)

SkipAdd2:
	rts

;***************************************************************************
;   TrackPlayer - Move Player With The Trackball		*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
TrackPlayer:
	clr.b	B_ONWALL(a5)	; Not On The Wall
	jsr	CheckTouch	; Check For Base Touch
	move.l	CONTROLBLOCK(a5),a2	; Load Address Of Control Block

	jsr	CheckTagOut	; Check For A Tag Out

	tst.b	COMPUTER(a2)	; Check If Computer Controlled
	bne	TrackP_3	; Skip User Control If He Is
;	bne	TrackP_4	; Skip User Control If He Is

	tst.b	B_MOVABLE(a5)	; Check If Player Is Locked In Place
	beq	TrackP_3	; Branch If Not
	bmi	TrackP_3	; Branch If Not

	tst.b	NoControl	; Check If Player Controlled
	beq.s	TrackP_0	; Branch If He Is
	subq.b	#1,NoControl	; Decrement Counter
	bne	TrackP_4	; Exit If Count Not Done
	clr.l	B_SEEKING(a5)	; Not Seeking Nothing
	move.w	B_STANDINGFRAME(a5),CURRENTFRAME(a5) ; Force Standing Frame
	clr.l	PARSEPOINTER(a5)	; Clear Animation Pointer for Selected Guy
TrackP_0:
	clr.w	d1	; Clear D1
	move.l	B_ROSTERADR(a5),a2	; Load Roster Address
	move.b	AT_range(a2),d1	; Load Speed Of Fielder
	move.w	d1,d0	; Move To D0
	asr.w	#2,d0	; Divide By Four
	add.w	d0,d1	; Calculate 1.25*Range
	add.w	#48,d1	; Add In Minimum Value

	move.l	CONTROLBLOCK(a5),a2	; Load Address Of Control Block

	move.w	TRACKX(a2),d0	; Load Trackball Control
	muls	d1,d0	; Multiply By 96/256 Inch Factor
	move.l	d0,WORLDXVEL(a5)	; Save As X Velocity

	move.w	TRACKY(a2),d0	; Load Trackball Control
	muls	d1,d0	; Multiply By 96/256 Inch Factor
	move.l	d0,WORLDYVEL(a5)	; Save As X Velocity

	move.w	TRACKX(a2),d0	; Load Trackball Control
	bpl.s	TrackP_1	; Branch If Positive
	neg.w	d0	; Make It Positive
TrackP_1:
	add.w	d0,ANIMSTEP(a5)	; Move The Player

	move.w	TRACKY(a2),d0	; Load Trackball Control
	bpl.s	TrackP_2	; Branch If Positive
	neg.w	d0	; Make It Positiove
TrackP_2:
	add.w	d0,ANIMSTEP(a5)	; Move The Player

	move.w	TRACKX(a2),d4	; Load X Direction Count
	ext.l	d4	; Extend To A Long
	move.w	TRACKY(a2),d5	; Load Y Direction Count
	ext.l	d5	; Extend To A Long

	jsr	CalcDirection	; Calculate Direction

	tst.w	d0	; Check Direction
	bmi.s	TrackP_3	; Branch If No Speed

	move.b	d0,B_DIRECTION(a5)	; Store The Direction

	jsr	FielderRunPic	; Set Fielder Running Picture
	move.w	#10,DURATION(a5)	; Set Short Duration
	bra.s	TrackP_4

TrackP_3:
	tst.l	PARSEPOINTER(a5)	; Check If Animation Set
	bne.s	TrackP_4	; Branch If There Is
	move.l	#StopRun,PARSEPOINTER(a5)	; Set Parse Pointer
TrackP_4:
	jsr	AnimPlayer	; Animate The Player
	jsr	KeepInRange	; Keep Controlled Player On Screen

TrackP_9:
	move.l	CONTROLBLOCK(a5),a2	; Load Address Of Control Block
	clr.w	TRACKX(a2)	; Clear Trackball Count
	clr.w	TRACKY(a2)	; Clear Trackball Count
	rts

;***************************************************************************
;   KeepInRange - Keep Fielder On The Field		*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
KeepInRange:
	move.l	WORLDY(a5),d0	; Load Y Position Of Fielder
	cmp.l	#-10*12*256,d0	; Check If Too Low
	bge.s	KeepIn_1	; Branch If Fine
	move.l	#-10*12*256,d0	; Force In range
	move.l	d0,WORLDY(a5)	; Save New Value
KeepIn_1:
	add.l	#10*12*256,d0	; Add In Ten Foot
	move.l	WORLDX(a5),d1	; Load X Position
	bmi.s	KeepIn_2	; Branch If Negative
	cmp.l	d0,d1	; Compare With Biased Y
	ble.s	KeepIn_9	; Exit If Fine
	move.l	d0,WORLDX(a5)	; Force On Field
	bra.s	KeepIn_9
KeepIn_2:
	neg.l	d0	; Make Y Negative
	cmp.l	d0,d1	; Compare With Biased Y
	bge.s	KeepIn_9	; Exit If Fine
	move.l	d0,WORLDX(a5)	; Force On Field
KeepIn_9:
	rts

;***************************************************************************
;   FielderRunPic - Set Fielder Running Picture		*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;	       d0 - Direction		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
FielderRunPic:
	move.w	#8,d6	; Load Eight Frame Animation
	move.w	#c02a01,d2	; Load Catcher Picture
	cmp.l	#Catcher,a5	; Check If Catcher
	beq.s	FielderRun_5	; Branch If It Is

	move.l	Speed,d0	; Load Previous Speed
	tst.w	SpeedCheck	; Check If Time For Check
	bne.s	FielderRun_3	; Branch If Not

	move.l	WORLDXVEL(a5),d0	; Load Player X Velocity
	bpl.s	FielderRun_1	; Branch If Positive
	neg.l	d0	; Make It Positive
FielderRun_1:
	move.l	WORLDYVEL(a5),d1	; Load Player Y Velocity
	bpl.s	FielderRun_2	; Branch If Positive
	neg.l	d1	; Make It Positive
FielderRun_2:
	add.l	d1,d0	; Add In Player Y Velocity
	move.l	d0,Speed	; Store Speed Value
	move.w	#10,SpeedCheck	; Set Delay Time

FielderRun_3:
	subq.w	#1,SpeedCheck	; Decrement Speed Check Time

;	move.w	#fc1a01,d2	; Load Slow Speed Animation
;	cmp.l	#0x600,d0	; Check If Slow
;	ble.s	FielderRun_3	; Branch If It Is

	move.w	#f03a01,d2	; Load Medium Speed Animation
	cmp.l	#0x1000,d0	; Check If Slow
	ble.s	FielderRun_5	; Branch If It Is

	move.w	#fn1a01,d2	; Load Fast Speed Animation
	move.w	#10,d6	; Ten Step Animation

FielderRun_5:
	clr.w	d1	; Clear D1
	move.b	B_DIRECTION(a5),d1	; Load Direction
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	FielderRun_6	; Branch If Not
	neg.w	d1	; Negate DIrection
	add.w	#8,d1	; Calculate Flipped Picture
	and.w	#0x7,d1	; Force In Range
FielderRun_6:
	mulu.w	d6,d1	; Multiply Direction By Animation Count
	add.w	d2,d1	; Calculate Running Picture Number

	move.w	ANIMSTEP(a5),d0	; Load Animation Count
	lsr.w	#5,d0	; Divide By 32
	ext.l	d0	; Extend To A Long
	divu	d6,d0	; Extract Frame Number
	swap	d0	; Remove Remainder To Lower
	add.w	d0,d1	; Calculate Frame

	move.w	d1,PICTURE(a5)	; Store For Display
	move.w	d1,CURRENTFRAME(a5)	; Store For Display
	rts

;***************************************************************************
;   CheckTouch - Check If Ball Holder Touches A Base	*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
BaseRange	equ	24*256	; 24 Inch Range

CheckTouch:
	tst.b	B_HASBALL(a5)	; Check If Player Has Ball
	beq.s	ChkTouch_9	; Branch If Not
	move.l	#CheckBase,a1	; Load Address Of Control Table
	tst.b	FliedOut	; Check If Flied Out
	beq.s	ChkTouch_1	; Branch If Not
	move.l	#CheckBaseBack,a1	; Check Forced Back To Base
ChkTouch_1:
	clr.w	d0	; Clear D0
	move.b	B_ONBASE(a5),d0	; Load On Base Status
	beq.s	ChkTouch_9	; Branch If Not On One

	move.l	(a1,d0.w*4),d1	; Load Player To Check
	beq.s	ChkTouch_9	; Branch If None
	move.l	d1,a0	; Move Player Address To a0

 	tst.b	B_INUSE(a0)	; Check If Runner In Use
 	beq.s	ChkTouch_9	; Branch If He Wasn't
 	tst.b	B_FORCED(a0)	; Check If Runner Forced
 	beq.s	ChkTouch_9	; Branch If He Wasn't
 	tst.b	B_OUT(a0)	; Check If Runner Already Out
 	bne.s	ChkTouch_9	; Branch If He Is
	move.b	#1,ForcedOut	; Set For Forced Out
	PUSHL	a0	; Save Runner Address
	jsr	RunToDugout	; Force Player To The Dug Out
	jsr	AddToOuts	; Increment Outs
	POPL	a0	; Retrieve Runner Address
	jsr	ChangeRunner	; Switch To Next Runner
ChkTouch_9:
	rts

IncBozo:
	PUSHL	a0	; Save A0
	move.l	AtPitPlayer,a0	; Load Address Of Fielding Team
	cmp.b	#60,BOZOFACTOR(a0)	; Check For Maximum Bozo
	bge.s	IncBozo_9	; Exit Is Maxed
	add.b	#5,BOZOFACTOR(a0)	; Increment Bozo Factor
IncBozo_9:
	POPL	a0	; Retrieve A0
	rts

DecBozo:
	PUSHL	a0	; Save A0
	move.l	AtPitPlayer,a0	; Load Address Of Fielding Team
	sub.b	#3,BOZOFACTOR(a0)	; Decrement Bozo Factor
	bpl.s	DecBozo_9	; Exit If Fine
	clr.b	BOZOFACTOR(a0)	; Set To Minimum Bozo
DecBozo_9:
	POPL	a0	; Retrieve A0
	rts

AddToOuts:
	move.b	#1,B_OUT(a0)	; Flag Runner Out
	cmp.b	#3,outs	;is there 3 outs
	beq.s	AddToOut_1	;branch if yes
	jsr	AddOut	; Increment Outs
	move.b	#UmpCallsOut,d0	; Load Normal Out Sound
	move.b	OutCount,d0	; Load Outs Count
	beq.s	AddToOut_1	; Branch If One
 	move.b	#S_DoublePlay,d0	; Double Play Sound
 	SOUND	d0,#0	; Sound
	cmp.b	#3,outs	;is there 3 outs
	beq.s	AddToOut_1	;branch if yes
	jsr	DoublePlayObj	;print Double play sign
AddToOut_1:
	add.b	#1,OutCount	; Increment Outs
	rts

CheckBase:
	dc.l	0	; 0 - No Base
	dc.l	FirstRunner	; 1 - First Base
	dc.l	SecondRunner	; 2 - Second Base
	dc.l	ThirdRunner	; 3 - Third Base
	dc.l	HomeRunner	; 4 - Home Plate

CheckBaseBack:
	dc.l	0	; 0 - No Base
	dc.l	SecondRunner	; 1 - First Base
	dc.l	ThirdRunner	; 2 - Second Base
	dc.l	HomeRunner	; 3 - Third Base
	dc.l	0	; 4 - Home Plate

;***************************************************************************
;   CheckTagOut - Check For Runners Being Tagged Out	*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
CheckTagOut:
;	tst.b	B_MOVABLE(a5)	; Check If Movable
;	beq.s	CheckTagS_9	; Branch If Not
	tst.b	B_HASBALL(a5)	; Check If Player Has The Ball
	beq.s	CheckTagS_9	; Exit If He Doesn't

	move.l	#FirstRunner,a0	; Load First Runner
	bsr	CheckTag	; Check Runner
	move.l	#SecondRunner,a0	; Load Second Runner
	bsr	CheckTag	; Check Runner
	move.l	#ThirdRunner,a0	; Load Third Runner
	bsr	CheckTag	; Check Runner
	move.l	#HomeRunner,a0	; Load Home Runner
	bsr	CheckTag	; Check Runner
CheckTagS_9:
	rts

;***************************************************************************
;   CheckTag - Check For Runners Being Tagged Out	*
;                                                                          *
;   Parameters :  a5 - Address Of Controlled Player	*
;	       a0 - Address Of Runner		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
CheckTag:
	tst.b	B_INUSE(a0)	; Check If Runner In Use
	beq	CheckTag_9	; Exit If Not
	tst.b	B_ONBASE(a0)	; Check If Runner On Base
	bpl	CheckTag_9	; Branch If He Is
	tst.b	B_OUT(a0)	; Check If Runner Is Out
	bne	CheckTag_9	; Exit If He Is

	clr.b	d7	; Set For No Sliding Runner
	tst.b	B_SLIDING(a0)	; Check If Runner Sliding
	beq.s	CheckTag_1	; Branch If Not
	tst.b	B_ONBASE(a5)	; Check If Fielder On Base
	beq.s	CheckTag_1	; Branch If Not
	move.b	#1,d7	; Flag A Slider
CheckTag_1:
	move.l	#8*12*256,d1	; Load 8 Feet
	tst.b	d7	; Check If Runner Sliding
	bne.s	CheckTag_3	; Branch If He Is
	move.l	#4*12*256,d1	; Load 4 Feet
CheckTag_3:
	move.l	WORLDX(a5),d0	; Load X Position Of Player
	sub.l	WORLDX(a0),d0	; Subtract X Position On Runner
	bpl.s	CheckTag_4	; Branch If Positive
	neg.l	d0	; Make Result Positive
CheckTag_4:
	cmp.l	d1,d0	; Check If Within 4 Feet
	bge	CheckTag_9	; Exit If Not

	move.l	WORLDY(a5),d0	; Load Y Position Of Player
	sub.l	WORLDY(a0),d0	; Subtract Y Position On Runner
	bpl.s	CheckTag_5	; Branch If Positive
	neg.l	d0	; Make Result Positive
CheckTag_5:
	cmp.l	d1,d0	; Check If Within 4 Feet
	bge	CheckTag_9	; Exit If Not

	move.l	#TagTable,a1	; Load Address Of Tag Table
	move.b	B_ONBASE(a0),d0	; Load Runner's On Base Flag
	ext.w	d0	; Extend To A Word

	move.w	(a1,d0.w*2),d1	; Load Starting Tag Frame
	beq.s	CheckTag_7	; Branch If Zero

	clr.w	d0	; Clear D0
	move.b	B_DIRECTION(a5),d0	; Load Player's Direction
	asl.w	#3,d0	; Multiply By Eight

	add.w	d0,d1	; Index To Proper Tag Frame
	move.w	d1,CURRENTFRAME(a5)	; Store New Frame Number
	move.w	d1,PICTURE(a5)	; Store For Display
	clr.w	DURATION(a5)	; Start Animation Soon

	clr.l	WORLDXVEL(a5)	; Stop The Player
	clr.l	WORLDYVEL(a5)
	clr.b	B_MOVABLE(a5)	; Make Player Not Movable
	move.l	#AnimPlayer,UPDATEPROC(a5)	; No More Tracking For A While
	move.l	a0,PARENT(a5)	; Save Sliding Player Address
	move.l	#TagAnim,PARSEPOINTER(a5)	; Execute Tag Animation
	cmp.l	#Catcher,a5	; Check If Catcher
	bne.s	CheckTag_6	; Branch If not
	move.l	#CatcherTag,PARSEPOINTER(a5) ; Execute Tag Animation
	bra.s	CheckTag_7
CheckTag_6:
	tst.b	B_ONBASE(a5)	; Check If On A Base
	bne.s	CheckTag_7	; Branch If He Is
	move.l	#RegularTag,PARSEPOINTER(a5) ; Execute Tag Animation
	bra.s	CheckTag_7A
CheckTag_7:
	tst.b	d7	; Check If Runner Is Sliding
	bne.s	CheckTag_8	; Branch If He Is
CheckTag_7A:
	move.b	#1,B_OUT(a0)	; Flag Runner Out
	jsr	RunToDugout	; Run To Dugout Otherwize
	move.l	#AnimPlayer,UPDATEPROC(a0)	; no longer a base runner, new process needed, will use fielder? process for now, obe
	move.b	#-1,B_INUSE(a0)	; in use but not playing
	jsr	ChangeRunner	; Give Controls To Different Runner
	jsr	AddOut	; Increment Outs
	SOUND	#UmpCallsOut,d0	; Normal Out Sound
CheckTag_8:

CheckTag_9:
	rts

	dc.w	fg1b01	; -7 - From Home To Third
	dc.w	fg1f01	; -6 - From Third To Home
	dc.w	fg1h01	; -5 - From Third To Second
	dc.w	fg1d01	; -4 - From Second To Third
	dc.w	fg1f01	; -3 - From Second To First
	dc.w	fg1b01	; -2 - From First To Second
	dc.w	0	; -1 - From Home To First
TagTable:
	dc.w	0	;  0 - Inactive
	dc.w	0	;  1 - On First Base
	dc.w	0	;  2 - On Second Base
	dc.w	0	;  3 - On Third Base
	dc.w	0	;  4 - On Home Plate
	dc.w	0	;  5 - In Dug Out

;***************************************************************************
;   ChangeRunner - Give Controls To Next Active		*
;                                                                          *
;   Parameters :  a0 - Address Of Controlled Player	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
ChangeRunner:
	move.l	CONTROLBLOCK(a0),d1	; Load Address Of Control Block
	beq.s	ChangeRun_9	; Exit If Not In Control
	clr.l	CONTROLBLOCK(a0)	; Clear Out Control
ChangeRun_1:
	move.l	CHILD(a0),d0	; Load Previous Runner
	beq.s	ChangeRun_9	; Exit If No More
	move.l	d0,a0	; Move Address To A0
	tst.b	B_INUSE(a0)	; Check If In Use
	beq.s	ChangeRun_1	; Branch If Not
	tst.b	B_OUT(a0)	; Check If Out
	bne.s	ChangeRun_1	; Branch If He Is
	move.l	d1,a1	; Load Control Block Address
;	move.l	d0,INPUTROUTINE(a1)	; Save Input Routine
	move.l	a1,CONTROLBLOCK(a0)	; Save Control Block Pointer
	move.l	a0,CONTROLOBJECT(a1)	; Save Controling Object Pointer
	move.l	#RunnerUpdate,ALWAYSROUTINE(a0) ; Start Checking
ChangeRun_9:
	rts

;***************************************************************************
;   ThrowToFirst - Throw Ball To First Base		*
;                                                                          *
;   Parameters :  A5 - Address Of Controlling Object	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
ThrowToFirst:
	SOUND	#S_ThrowToBase,#2	; Throw To Base Sound
	move.l	#100*MPH,d3	; Set For 70 MPH Throw
	move.l	CONTROLBLOCK(a5),a1	; Load Control Block
          	tst.b	POWERTHROW(a1)	; Check For Power Throw
	beq.s	ThrowTo1_1	; Branch If Not
	move.l	#130*MPH,d3	; Set For 130 MPH Throw
	SOUND	#FireBall,#0	; Set Volume
	move.b	#1,PowerBallPal
          	clr.b	POWERTHROW(a1)	; Check For Power Throw
ThrowTo1_1:
	move.l	FirstCover,a1	; Load Address Of New Controller
	cmp.l	ControlPtr,a1	; Check If Already Controlled
	beq.s	ThrowTo1_9	; Branch If The Same

	jsr	NewControl	; Set New Controller
	move.l	FirstCover,a0	; Load Address Of First Base
	clr.l	WORLDXVEL(a0)	; Stop The Player
	clr.l	WORLDYVEL(a0)	; Stop The Player
	clr.l	B_SEEKING(a0)	; Stop Seeking
	move.l	WORLDX(a0),d4	; Load X Position
	move.l	WORLDY(a0),d5	; Load Y Position

	jsr	SetCatch	; Set Up For Ball Catch

	jsr	ThrowToXY	; Set For Throw
	move.w	#FIRST,Destination	; Save Destination Flag
ThrowTo1_9:
	rts

;***************************************************************************
;   ThrowToSecond - Throw Ball To Second Base		*
;                                                                          *
;   Parameters :  A5 - Address Of Controlling Object	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
ThrowToSecond:
	SOUND	#S_ThrowToBase,#3	; Throw To Base Sound
	move.l	#90*MPH,d3	; Set For 70 MPH Throw
	move.l	CONTROLBLOCK(a5),a1	; Load Control Block
          	tst.b	POWERTHROW(a1)	; Check For Power Throw
	beq.s	ThrowTo2_1	; Branch If Not
	move.l	#120*MPH,d3	; Set For 130 MPH Throw
	SOUND	#FireBall,#0	; Set Volume
	move.b	#1,PowerBallPal
          	clr.b	POWERTHROW(a1)	; Check For Power Throw
ThrowTo2_1:
	move.l	SecondCover,a1	; Load Address Of New Controller
	cmp.l	ControlPtr,a1	; Check If Already Controlled
	beq.s	ThrowTo2_9	; Branch If The Same
	jsr	NewControl	; Set New Controller
	move.l	SecondCover,a0	; Load Address Of Second Base
	clr.l	WORLDXVEL(a0)	; Stop The Player
	clr.l	WORLDYVEL(a0)	; Stop The Player
	clr.l	B_SEEKING(a0)	; Stop Seeking
	move.l	WORLDX(a0),d4	; Load X Position
	move.l	WORLDY(a0),d5	; Load Y Position
	jsr	SetCatch	; Set Up For Ball Catch
	jsr	ThrowToXY	; Set For Throw
	move.w	#SECOND,Destination	; Save Destination Flag
ThrowTo2_9:
	rts

;***************************************************************************
;   ThrowToThird - Throw Ball To Third Base		*
;                                                                          *
;   Parameters :  A5 - Address Of Controlling Object	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
ThrowToThird:
	SOUND	#S_ThrowToBase,#4	; Throw To Base Sound
	move.l	#90*MPH,d3	; Set For 70 MPH Throw
	move.l	CONTROLBLOCK(a5),a1	; Load Control Block
          	tst.b	POWERTHROW(a1)	; Check For Power Throw
	beq.s	ThrowTo3_1	; Branch If Not
	move.l	#120*MPH,d3	; Set For 130 MPH Throw
	SOUND	#FireBall,#0	; Set Volume
	move.b	#1,PowerBallPal
          	clr.b	POWERTHROW(a1)	; Check For Power Throw
ThrowTo3_1:
	move.l	ThirdCover,a1	; Load Address Of New Controller
	cmp.l	ControlPtr,a1	; Check If Already Controlled
	beq.s	ThrowTo3_9	; Branch If The Same
	jsr	NewControl	; Set New Controller
	move.l	ThirdCover,a0	; Load Address Of Third Base
	clr.l	WORLDXVEL(a0)	; Stop The Player
	clr.l	WORLDYVEL(a0)	; Stop The Player
	clr.l	B_SEEKING(a0)	; Stop Seeking
	move.l	WORLDX(a0),d4	; Load X Position
	move.l	WORLDY(a0),d5	; Load Y Position

	jsr	SetCatch	; Set Up For Ball Catch

	jsr	ThrowToXY	; Set For Throw
	move.w	#THIRD,Destination	; Save Destination Flag
ThrowTo3_9:
	rts

;***************************************************************************
;   ThrowToHome - Throw Ball To Home Plate		*
;                                                                          *
;   Parameters :  A5 - Address Of Controlling Object	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
ThrowToHome:
	SOUND	#S_ThrowToBase,#0	; Throw To Base Sound
	move.l	#80*MPH,d3	; Set For 70 MPH Throw
	move.l	CONTROLBLOCK(a5),a1	; Load Control Block
          	tst.b	POWERTHROW(a1)	; Check For Power Throw
	beq.s	ThrowToH_1	; Branch If Not
	move.l	#120*MPH,d3	; Set For 130 MPH Throw
	SOUND	#FireBall,#0	; Set Volume
	move.b	#1,PowerBallPal
          	clr.b	POWERTHROW(a1)	; Check For Power Throw
ThrowToH_1:
	move.l	#Catcher,a1	; Load Address Of New Controller
	cmp.l	ControlPtr,a1	; Check If Already Controlled
	beq.s	ThrowToH_9	; Branch If The Same
	jsr	NewControl	; Set New Controller
	move.l	#Catcher,a0	; Load Address Of Home Plate
	clr.l	WORLDXVEL(a0)	; Stop The Player
	clr.l	WORLDYVEL(a0)	; Stop The Player
	clr.l	B_SEEKING(a0)	; Stop Seeking
	move.l	WORLDX(a0),d4	; Load X Position
	move.l	WORLDY(a0),d5	; Load Y Position

	jsr	SetCatch	; Set Up For Ball Catch

	jsr	ThrowToXY	; Set For Throw
	move.w	#HOME,Destination	; Save Destination Flag
ThrowToH_9:
	rts

;***************************************************************************
;   ThrowToPitcher - Throw Ball To Pitchere		*
;                                                                          *
;   Parameters :  A5 - Address Of Controlling Object	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
ThrowToPitcher:
	SOUND	#S_ThrowToBase,#3	; Throw To Base Sound
	move.l	#100*MPH,d3	; Set For 70 MPH Throw
	move.l	CONTROLBLOCK(a5),a1	; Load Control Block
	move.l	#Pitcher,a1	; Load Address Of New Controller
	cmp.l	ControlPtr,a1	; Check If Already Controlled
	beq.s	ThrowToP_9	; Branch If The Same
	jsr	NewControl	; Set New Controller
	move.l	#Pitcher,a0	; Load Address Of Pitcher
	clr.l	WORLDXVEL(a0)	; Stop The Player
	clr.l	WORLDYVEL(a0)	; Stop The Player
	clr.l	B_SEEKING(a0)	; Stop Seeking
	move.l	WORLDX(a0),d4	; Load X Position
	move.l	WORLDY(a0),d5	; Load Y Position
	jsr	SetCatch	; Set Up For Ball Catch
	jsr	ThrowToXY	; Set For Throw
	move.w	#PITCH,Destination	; Save Destination Flag
ThrowToP_9:
	rts

;***************************************************************************
;   SetCatch - Set For Catch Of Ball Thrown To Base	*
;                                                                          *
;   Parameters :  a0 - Address Of Player Catching	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
SetCatch:
	move.l	#CatchIBall,d0	; Set For Fielder
	cmp.l	#Catcher,a0	; Check If Catcher
	bne.s	SetCatch_1	; Branch If It Isn't
	move.l	#CatchCBall,d0	; Set For Catcher
SetCatch_1:
	tst.l	B_SEEKING(a0)	; Check If Seeking A Position
	bne.s	SetCatch_2	; Branch If He Is
	move.l	d0,PARSEPOINTER(a0)	; Set For Catch
	rts
SetCatch_2:
	move.l	d0,B_GOALPP(a0)	; Set For Running End
	rts

;***************************************************************************
;   ClearUpField - Perform All Updates On Switch From Field To Batter	*
;                                                                          *
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
ClearUpField:
	move.l	#HomeRunner,a5	; Load Address Of Home Runner
ClearUp_1:
	tst.b	B_INUSE(a5)	; Check If Runner In Use
	beq.s	ClearUp_5	; Continue If Not
	tst.b	B_ONBASE(a5)	; Check If On Base
	beq.s	ClearUp_3	; Branch If Not
	tst.b	B_OUT(a5)	; Check If Player Was Out
	bne.s	ClearUp_3	; Branch If He Was
	clr.w	d1	; Clear D1
	move.b	B_ONBASE(a5),d1	; Load Base Player Is On
	bmi.s	ClearUp_5	; Branch If Not On A Base
	move.l	#ClearBases,a0	; Load Address Of Bases Info
	move.l	(a0,d1.w*4),d0	; Load Address Of New Runner
	beq.s	ClearUp_5	; Branch If Not Active
	cmp.l	a5,d0	; Check If Same Base
	beq.s	ClearUp_5	; Branch If They Are
	cmp.l	#FirstRunner,a5	; Check If Batter Object
	bne.s	ClearUp_2	; Branch If Not
	add.b	#1,([AtBatPlayer],HITS)	; Increment Hits
	move.b	#1,DidGetHit      	; yes he hit
ClearUp_2:
	move.l	d0,a2	; Move Destination Address To A2
	move.l	a5,a1	; Move Source Address To A1
	jsr	CopyPlayer	; Copy Player
ClearUp_3:
	clr.b	B_INUSE(a5)	; Make Not In Use
ClearUp_5:
	sub.l	#`sizeof(player_struct),a5	; Move To Previous Runner
	cmp.l	#FirstRunner,a5	; Check If Done
	bge.s	ClearUp_1	; Loop If Not

	move.l	#ThirdRunner,HomeRunner+CHILD ; Create Runner Chain
	move.l	#SecondRunner,ThirdRunner+CHILD
	move.l	#FirstRunner,SecondRunner+CHILD
	clr.l	FirstRunner+CHILD

	rts

ClearBases:
	dc.l	0	; 0 - Not On Base
	dc.l	SecondRunner	; 1 - Man On First
	dc.l	ThirdRunner	; 2 - Man On Second
	dc.l	HomeRunner	; 3 - Man On Third
	dc.l	0	; 4 - Man On Home
	dc.l	0	; 5 - Man In Dugout

CopyPlayer:
	move.l	#`sizeof(player_struct)-4,d0 ; Load Size To Move
	lea	4(a1),a1	; Skip Past Link
	lea	4(a2),a2	; Skip Past Link
CopyP_1:
	move.b	(a1)+,(a2)+	; Move Data
	subq.b	#1,d0	; Decrement Counter
	bne.s	CopyP_1	; Continue Until Done
	rts

;***************************************************************************
;   NewControl - Give Controls To A Different Player	*
;                                                                          *
;   Parameters :  a1 - Address Of New Controlling Object	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
NewControl:

	move.l	ControlPtr,a0	; Load Address Of Controlled Player
	move.l	CONTROLBLOCK(a0),a2	; Load Address Of Control Block
	cmp.l	a1,a0	; Check If Already There
	beq.s	NewControl_3	; Branch If It Is

	clr.l	WORLDXVEL(a0)	; Stop Previously Controlled Player
	clr.l	WORLDYVEL(a0)	;
	clr.l	CONTROLBLOCK(a0)	; Clear Control Block
	move.b	#-1,STATIONARY(a0)	; Set As Non-Stationary
	move.l	#AnimPlayer,UPDATEPROC(a0)	; Set For Updating
	jsr	BackToGoalD	;Run Player Back To Goal DELAYED

	move.l	a1,ControlPtr	; Store Address Of Controlled Player
	move.l	#TrackPlayer,UPDATEPROC(a1)	; Set For Updating
	move.l	a2,CONTROLBLOCK(a1)	; Save Controls Address
	move.l	a1,CONTROLOBJECT(a2)	; Point Controls To Player

	jsr	StartCatch	; Start Catch Animation

	move.b	#1,d0	; Flag A Change Of Control
	bra.s	NewControl_9
NewControl_3:
	move.l	#BareHand,d0	; Load Address Of Bare Hand Catch
	tst.b	B_MOVABLE(a1)	; Check If Player Has Pressed Button
	bmi.s	NewControl_4	; Branch If Bare Hand Catch
	beq.s	NewControl_5	; Branch If He Has

	move.l	#AtWallCaught,d0	; Set For Wall Catch
	tst.b	B_ONWALL(a1)	; Check If On the Wall
	bne.s	NewControl_4	; Branch If He Is
	move.l	#FastCatch,d0	; Start Moving Glove
	cmp.l	#Catcher,a1	; Check If Catcher
	bne.s	NewControl_4	; Branch If Not
	move.l	#CatchCBall,d0	; Load Address Of Ball Catch
NewControl_4:
	move.l	d0,PARSEPOINTER(a1)	; Load Address Of Ball Catch
	clr.l	INPUTROUTINE(a2)	; Clear Input Routine
	clr.b	B_MOVABLE(a1)	; Let Player Animate
	clr.w	DURATION(a1)	; Start Immediatly
	clr.b	B_HASBALL(a1)	; Take Away The Ball
NewControl_5:
	move.l	#TrackPlayer,UPDATEPROC(a0)	; Set For Updating
	move.l	CONTROLBLOCK(a0),a0	; Load Address Of Control Block
	clr.b	d0	; Flag No Change Of Control
NewControl_9:
     	move.w	([B_ROSTERADR,a1],AT_namesnd),d1   ; Fielder Name from Roster
     	move.b	d1,SndBit2
     	lsr.w	#8,d1
     	move.b	d1,SndBit1
     	SOUND3	#SetCurrentPlayer,SndBit1,SndBit2
;    ;	SOUND	#SayPlayerName,#0	

	rts

;***************************************************************************
;   StartCatch - Start Catching Animation		*
;                                                                          *
;   Parameters :  a1 - Address Of New Controlling Object	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
StartCatch:
;	tst.b	PickOffTest	; Check If Pick Off Play
;	bne.s	StartCatch_9	; Exit If It Is
	move.l	#CatchCBall,d0	; Load Address Of Catcher Ball Catch
	cmp.l	#Catcher,a1	; Check If This Is The Catcher
	beq.s	StartCatch_1	; Branch If It Is

	move.l	#FastCatch,d0	; Load Address Of Fast Catch
	tst.b	B_HASBALL(a1)	; Check If Player Has The Ball
	bne.s	StartCatch_1	; Branch If He Does
	move.l	#CatchIBall,d0	; Load Address Of Fielder Ball Catch
StartCatch_1:
	move.l	d0,PARSEPOINTER(a1)	; Start Moving Glove
	clr.w	DURATION(a1)	; Start Up Soon
	clr.b	B_MOVABLE(a1)	; Don't Move Player
	clr.l	B_GOALPP(a1)	; Clear Player's Goal Parsepointer
StartCatch_9:
	rts

;***************************************************************************
;   FindNewFielder - Switch Control To Fielder Near Center Screen	*
;                                                                          *
;   Parameters :  a5 - Address Of Controlling Object	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
FindNewFielder:
	move.w	#0x7FFF,Closest	; Set Far Away Closest
	move.l	#Pitcher,a2	; Load Address Of Pitcher
FindNew_1:
	cmp.l	#Catcher,a2	; Check If Catcher
	beq.s	FindNew_4	; Branch If It Is
	move.w	XPOSITION(a2),d0	; Load X Position
	sub.w	#192,d0	; Subtract Middle Of Screen
	bpl.s	FindNew_2	; Branch If Positive
	neg.w	d0	; Make It Positive
FindNew_2:
	move.w	YPOSITION(a2),d1	; Load Y Position
	sub.w	#192,d1	; Subtract Middle Of Screen
	bpl.s	FindNew_3	; Branch If Positive
	neg.w	d1	; Make It Positive
FindNew_3:
	add.w	d1,d0	; Add The Vectors
	cmp.w	Closest,d0	; Compare With Closest
	bge.s	FindNew_4	; Branch If Farther Away
	move.w	d0,Closest	; Save Value
	move.l	a2,a1	; Save Address Of Fielder
FindNew_4:
	add.l	#`sizeof(player_struct),a2	; Index To Next Fielder
	cmp.l	#RightField,a2	; Check If Done
	ble.s	FindNew_1	; Continue Until All Done
;	rts

;***************************************************************************
;   SwitchControl - Give Controls To A Different Fielder	*
;                                                                          *
;   Parameters :  a1 - Address Of New Controlling Object	*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
SwitchControl:
	move.l	ControlPtr,a0	; Load Address Of Controlled Player
	move.l	CONTROLBLOCK(a0),a2	; Load Address Of Control Block

	clr.l	WORLDXVEL(a0)	; Stop Previously Controlled Player
	clr.l	WORLDYVEL(a0)	;

	clr.l	CONTROLBLOCK(a0)	; Clear Control Block
	move.l	#AnimPlayer,UPDATEPROC(a0)	; Set For Standard Updating
	move.l	#EndRun,PARSEPOINTER(a0)	; Set For Standing Anim

;	jsr	BackToGoal	; Run Player Back To Goal

	move.l	a1,ControlPtr	; Store Address Of Controlled Player
	move.l	#TrackPlayer,UPDATEPROC(a1)	; Set For Updating
	move.l	a2,CONTROLBLOCK(a1)	; Save Controls Address
	move.l	a1,CONTROLOBJECT(a2)	; Point Controls To Player
	move.l	#FIELDER_CONTROLS,INPUTROUTINE(a2) ; Set Input Controls to Fielder

	tst.b	COMPUTER(a2)	; Check If Computer Player
	bne.s	SwitchC_9	; Branch If It Is
	move.b	#1,B_MOVABLE(a1)	; Let Player Move
;	move.l	#EndRun,PARSEPOINTER(a1)	; Set For Standing Anim
	clr.l	B_GOALPP(a1)	; Clear Player's Goal Parsepointer
	clr.w	DURATION(a1)	; Start Immediatly
	clr.l	B_SEEKING(a1)	; Not Seeking Nothing
;	move.l	a1,a0	; Move Address To A0
;	move.w	#24,d0	; Check Ball In 24 Ticks
;	jsr	CalcBallPos	; Calculate Ball Position
;	move.l	#30*MPH,d3	; Set For 30 MPH Run
;	move.l	#EndBackupRun,a2	; Ending For First Base Run
;	move.w	#AT_SPEED,d1	; Use Speed Attribute
;	jsr	RunToXY	; Run To Base
SwitchC_9:
	rts

;***************************************************************************
;   BackToGoal - Return To Assigned Position		*
;                                                                          *
;   Parameters :  a0 - Address Of Object		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
BackToGoal:
	cmp.l	#Pitcher,a0	; Check If Pitcher
	beq.s	BackTo_9	; Exit If It Is
	move.l	#25*MPH,d3	; Set For 25 MPH Run
	move.l	B_GOALX(a0),d4	; Load First Base X Position
	move.l	B_GOALY(a0),d5	; Load First Base Y Position
	cmp.l	WORLDX(a0),d4	; Check If Already There X
	bne.s	BackTo_1	; Branch If Not
	cmp.l	WORLDY(a0),d5	; Check If Already There Y
	beq.s	BackTo_9	; Branch If There
BackTo_1:
	PUSHL	a1-a2
	move.l	#EndRun,a2	; Ending For Run
	move.w	#AT_RANGE,d1	; Use Range Attribute
	jsr	RunToXY	; Set For Run
	POPL	a1-a2
BackTo_9:
	rts


BackToGoalD:	;delay the back to goal function, so the throwing animation can finish
	tst.b	B_COVERING(a0)	; Check If Covering A Base
	beq.s	BackToGoal_9	; Exit If Not
	PUSHL	a1-a2
	move.l	a0,saveda0
	move.l	a1,saveda1
	move.l	a2,saveda2
	SPAWN	#BTGD,#35
	POPL	a1-a2
BackToGoal_9:
	rts
BTGD
	DELAY	#30
	move.l	saveda0,a0
	move.l	saveda1,a1
	move.l	saveda2,a2

	cmp.l	#Pitcher,a0	; Check If Pitcher
	beq.s	.BackTo_9	; Exit If It Is
	move.l	#25*MPH,d3	; Set For 25 MPH Run
	move.l	B_GOALX(a0),d4	; Load First Base X Position
	move.l	B_GOALY(a0),d5	; Load First Base Y Position
	cmp.l	WORLDX(a0),d4	; Check If Already There X
	bne.s	.BackTo_1	; Branch If Not
	cmp.l	WORLDY(a0),d5	; Check If Already There Y
	beq.s	.BackTo_9	; Branch If There
.BackTo_1:
	PUSHL	a1-a2
	move.l	#EndRun,a2	; Ending For Run
	move.w	#AT_RANGE,d1	; Use Range Attribute
	jsr	RunToXY	; Set For Run
	POPL	a1-a2
.BackTo_9:
	EXTERM	#35
	rts

;***************************************************************************
;   StopPlayer - Stop Player's Movement		*
;                                                                          *
;   Parameters :  a0 - Address Of Object		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
StopPlayer:
	clr.l	WORLDXVEL(a0)	; Stop X Movement
	clr.l	WORLDYVEL(a0)	; Stop Y Movement
	clr.l	B_SEEKING(a0)	; Stop Any Seeking
	rts


;***************************************************************************
;   InitCatcher - Initialize Catcher In Field Mode	*
;                                                                          *
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE                                                     *
;***************************************************************************
InitCatcher:
	move.l	#Catcher,a0	; Load Address Of Catcher
	move.b	#CatcherTopBank,BANK(a0)	; Load Bank Number
	move.w	#1,DURATION(a0)	; Start Up Animation
	move.l	#CatcherIntro,PARSEPOINTER(a0) ; Save Starting Animation Address
	rts

;***************************************************************************
;   SetBaseFlags - Set Fielder On Base Flags (called from CycleGame)	*
;                                                                          *
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
SetBaseFlags:
	move.l	ControlPtr,a0	; Load Address Of Controlled Player
	clr.b	B_ONBASE(a0)	; Clear Base Status
	move.l	#Bases,a1	; Load Address Of Bases
	move.w	#1,d7	; First Base First
SetBase_2:
	move.l	(a1)+,d0	; Load Base X Position
	move.l	(a1)+,d1	; Load Base Y Position

	sub.l	WORLDX(a0),d0	; Load Player's X Position
	bpl.s	SetBase_3	; Branch If Positive
	neg.l	d0	; Make result Positive
SetBase_3:
	cmp.l	#BaseRange,d0	; Check If Close
	bgt.s	SetBase_5	; Branch If Not Close

	sub.l	WORLDY(a0),d1	; Load Player's Y Position
	bpl.s	SetBase_4	; Branch If Positive
	neg.l	d1	; Make result Positive
SetBase_4:
	cmp.l	#BaseRange,d1	; Check If Close
	bge.s	SetBase_5	; Branch If Not Close

	move.b	d7,B_ONBASE(a0)	; Save Base Status
	bra.s	SetBase_6

SetBase_5:
	addq.w	#1,d7	; Increment Base Number
	cmp.w	#5,d7	; Check If Done
	blt.s	SetBase_2	; Continue Til Done

SetBase_6:
	rts

Plays:
	dc.l	B2000	; 00 - Bases empty bunt
	dc.l	B9000	; 01 - Bases empty ball hit to right field
	dc.l	B8000	; 02 - Bases empty ball hit to center field
	dc.l	B7000	; 03 - Bases empty ball hit to left field
	dc.l	B3000	; 04 - Bases empty ball hit to first base
	dc.l	B4000	; 05 - Bases empty ball hit to second base
	dc.l	B5000	; 06 - Bases empty ball hit to shortstop
	dc.l	B6000	; 07 - Bases empty ball hit to third base

	dc.l	B2100	; 08 - Runner on first bunt
	dc.l	B9100	; 09 - Runner on first ball hit to right field
	dc.l	B8100	; 0A - Runner on first ball hit to center field
	dc.l	B7100	; 0B - Runner on first ball hit to left field
	dc.l	B3100	; 0C - Runner on first ball hit to first base
	dc.l	B4100	; 0D - Runner on first ball hit to second base
	dc.l	B5100	; 0E - Runner on first ball hit to shortstop
	dc.l	B6100	; 0F - Runner on first ball hit to third base

	dc.l	B2110	; 10 - Runner on second bunt
	dc.l	B9010	; 11 - Runner on second ball hit to right field
	dc.l	B8010	; 12 - Runner on second ball hit to center field
	dc.l	B7010	; 13 - Runner on second ball hit to left field
	dc.l	B3110	; 14 - Runner on second ball hit to first base
	dc.l	B4110	; 15 - Runner on second ball hit to second base
	dc.l	B5110	; 16 - Runner on second ball hit to shortstop
	dc.l	B6110	; 17 - Runner on second ball hit to third base
			   
	dc.l	B2110	; 18 - Runners on first and second bunt
	dc.l	B9110	; 19 - Runners on first and second ball hit to right field
	dc.l	B8110	; 1A - Runners on first and second ball hit to center field
	dc.l	B7110	; 1B - Runners on first and second ball hit to left field
	dc.l	B3110	; 1C - Runners on first and second ball hit to first base
	dc.l	B4110	; 1D - Runners on first and second ball hit to second base
	dc.l	B5110	; 1E - Runners on first and second ball hit to shortstop
	dc.l	B6110	; 1F - Runners on first and second ball hit to third base

	dc.l	B2111	; 20 - Runner on third bunt
	dc.l	B9001	; 21 - Runner on third ball hit to right field
	dc.l	B8001	; 22 - Runner on third ball hit to center field
	dc.l	B7001	; 23 - Runner on third ball hit to left field
	dc.l	B3111	; 24 - Runner on third ball hit to first base
	dc.l	B4111	; 25 - Runner on third ball hit to second base
	dc.l	B5111	; 26 - Runner on third ball hit to shortstop
	dc.l	B6111	; 27 - Runner on third ball hit to third base
			    
	dc.l	B2101	; 28 - Runners on first and third bunt
	dc.l	B9101	; 29 - Runners on first and third ball hit to right field
	dc.l	B8101	; 2A - Runners on first and third ball hit to center field
	dc.l	B7101	; 2B - Runners on first and third ball hit to left field
	dc.l	B3101	; 2C - Runners on first and third ball hit to first base
	dc.l	B4101	; 2D - Runners on first and third ball hit to second base
	dc.l	B5101	; 2E - Runners on first and third ball hit to shortstop
	dc.l	B6101	; 2F - Runners on first and third ball hit to third base
			  
	dc.l	B2011	; 30 - Runners on second and third bunt
	dc.l	B9011	; 31 - Runners on second and third ball hit to right field
	dc.l	B8011	; 32 - Runners on second and third ball hit to center field
	dc.l	B7011	; 33 - Runners on second and third ball hit to left field
	dc.l	B3011	; 34 - Runners on second and third ball hit to first base
	dc.l	B4011	; 35 - Runners on second and third ball hit to second base
	dc.l	B5011	; 36 - Runners on second and third ball hit to shortstop
	dc.l	B6011	; 37 - Runners on second and third ball hit to third base
			    
	dc.l	B2111	; 38 - Bases loaded bunt
	dc.l	B9111	; 39 - Bases loaded ball hit to right field
	dc.l	B8111	; 3A - Bases loaded ball hit to center field
	dc.l	B7111	; 3B - Bases loaded ball hit to left field
	dc.l	B3111	; 3C - Bases loaded ball hit to first base
	dc.l	B4111	; 3D - Bases loaded ball hit to second base
	dc.l	B5111	; 3E - Bases loaded ball hit to shortstop
	dc.l	B6111	; 3F - Bases loaded ball hit to third base
	
COVER	equ	0
SEEK	equ	1
SEEKBALL	equ	2
BACKUP	equ	3
STOP	equ	4
FASTCOVER	equ	5

First	equ	0
Second	equ	1
Third	equ	2
Home	equ	3
	
;  	Bases empty ball hit to left field
B7000:
	dc.w	STOP    	; 0 - Pitcher
	dc.w	COVER,First	; 1 - 1st baseman
	dc.w	COVER,Second	; 2 - 2nd baseman
	dc.w	SEEKBALL    	; 3 - Shortstop
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Bases empty ball hit to center field
B8000:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL       	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Bases empty ball hit to right field
B9000:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	SEEKBALL         	; 2 - 2nd baseman   
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runner on first ball hit to left field
B7100:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL           	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runner on first ball hit to center field
B8100:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL          	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runner on first ball hit to right field
B9100:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	SEEKBALL    	; 2 - 2nd baseman   
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runner on second ball hit to left field
B7010:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL          	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runner on second ball hit to center field
B8010:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL          	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runner on second ball hit to right field
B9010:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First 	; 1 - 1st baseman 
	dc.w	SEEKBALL       	; 2 - 2nd baseman   
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runner on third ball hit to left field
B7001:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL          	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runner on third ball hit to center field
B8001:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL          	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runner on third ball hit to right field
B9001:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First 	; 1 - 1st baseman 
	dc.w	SEEKBALL       	; 2 - 2nd baseman   
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and second ball hit to left field
B7110:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL          	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and second ball hit to center field
B8110:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL          	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and second ball hit to right field
B9110:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	SEEKBALL        	; 2 - 2nd baseman   
	dc.w	COVER,Second  	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and second ball hit to right field
B7101:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL           	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and second ball hit to right field
B8101:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	SEEKBALL        	; 2 - 2nd baseman   
	dc.w	COVER,Second  	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and third ball hit to right field
B9101:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	SEEKBALL        	; 2 - 2nd baseman   
	dc.w	COVER,Second  	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and third ball hit to right field
B7011:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First  	; 1 - 1st baseman 
	dc.w	SEEKBALL       	; 2 - 2nd baseman   
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and third ball hit to right field
B8011:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First  	; 1 - 1st baseman 
	dc.w	SEEKBALL       	; 2 - 2nd baseman   
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and third ball hit to right field
B9011:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First 	; 1 - 1st baseman 
	dc.w	SEEKBALL       	; 2 - 2nd baseman   
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and third ball hit to right field
B7111:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	SEEKBALL        	; 2 - 2nd baseman   
	dc.w	COVER,Second  	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Bases loaded ball hit to center field
B8111:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	SEEKBALL        	; 2 - 2nd baseman   
	dc.w	COVER,Second  	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Bases loaded ball hit to right field
B9111:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	SEEKBALL        	; 2 - 2nd baseman   
	dc.w	COVER,Second  	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Bases empty ball hit to third base
B6000:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	COVER,Third	; 3 - Shortstop  
	dc.w	SEEKBALL	; 4 - 3rd baseman

;	Bases empty ball hit to shortstop
B5000:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Bases empty ball hit to second base
B4000:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	SEEKBALL	; 2 - 2nd baseman   
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Bases empty ball hit to first base
B3000:
	dc.w	FASTCOVER,First	; 0 - Pitcher    
	dc.w	SEEKBALL	; 1 - 1st baseman 
	dc.w	SEEK,820,2041   	; 2 - 2nd baseman  
	dc.w	COVER,Second    	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Bases empty bunt
B2000:
	dc.w	SEEKBALL	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	BACKUP	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runner on first ball hit to third base
B6100:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	COVER,Third	; 3 - Shortstop  
	dc.w	SEEKBALL	; 4 - 3rd baseman

;	Runner on first ball hit to shortstop
B5100:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runner on first ball hit to second base
B4100:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	SEEKBALL	; 2 - 2nd baseman   
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runner on first ball hit to first base
B3100:
	dc.w	FASTCOVER,First	; 0 - Pitcher    
	dc.w	SEEKBALL	; 1 - 1st baseman 
	dc.w	SEEK,820,2041   	; 2 - 2nd baseman  
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runner on first bunt
B2100:
	dc.w	SEEKBALL	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	BACKUP	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and second ball hit to third base
B6110:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	COVER,Third	; 3 - Shortstop  
	dc.w	SEEKBALL	; 4 - 3rd baseman

;	Runners on first and second ball hit to shortstop
B5110:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and second ball hit to second base
B4110:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	SEEKBALL	; 2 - 2nd baseman   
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and second ball hit to first base
B3110:
	dc.w	FASTCOVER,First	; 0 - Pitcher    
	dc.w	SEEKBALL	; 1 - 1st baseman 
	dc.w	SEEK,820,2041   	; 2 - 2nd baseman  
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and second bunt
B2110:
	dc.w	SEEKBALL	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	BACKUP	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and third ball hit to third base
B6101:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	COVER,Third	; 3 - Shortstop  
	dc.w	SEEKBALL	; 4 - 3rd baseman

;	Runners on first and third ball hit to shortstop
B5101:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and third ball hit to second base
B4101:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	SEEKBALL	; 2 - 2nd baseman   
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and third ball hit to first base
B3101:
	dc.w	FASTCOVER,First	; 0 - Pitcher    
	dc.w	SEEKBALL	; 1 - 1st baseman 
	dc.w	SEEK,820,2041   	; 2 - 2nd baseman  
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on first and third bunt
B2101:
	dc.w	SEEKBALL    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	BACKUP	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman
                   
;	Runners on second and third ball hit to third base
B6011:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	COVER,Third	; 3 - Shortstop  
	dc.w	SEEKBALL	; 4 - 3rd baseman

;	Runners on second and third ball hit to shortstop
B5011:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on second and third ball hit to second base
B4011:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	SEEKBALL	; 2 - 2nd baseman   
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on second and third ball hit to first base
B3011:
	dc.w	COVER,First	; 0 - Pitcher    
	dc.w	SEEKBALL	; 1 - 1st baseman 
	dc.w	SEEK,820,2041   	; 2 - 2nd baseman  
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Runners on second and third bunt
B2011:
	dc.w	SEEKBALL	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	BACKUP	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Bases loaded ball hit to third base
B6111:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	COVER,Third	; 3 - Shortstop  
	dc.w	SEEKBALL	; 4 - 3rd baseman

;	Bases loaded ball hit to shortstop
B5111:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	SEEKBALL	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Bases loaded ball hit to second base
B4111:
	dc.w	STOP    	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	SEEKBALL	; 2 - 2nd baseman   
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Bases loaded ball hit to first base
B3111:
	dc.w	COVER,First	; 0 - Pitcher    
	dc.w	SEEKBALL	; 1 - 1st baseman 
	dc.w	SEEK,820,2041   	; 2 - 2nd baseman  
	dc.w	COVER,Second	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Bases loaded bunt
B2111:
	dc.w	SEEKBALL	; 0 - Pitcher    
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	BACKUP	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

;	Pick Off Play
PickOffPlay:
	dc.w	STOP	; 0 - Pitcher
	dc.w	FASTCOVER,First	; 1 - 1st baseman 
	dc.w	FASTCOVER,Second	; 2 - 2nd baseman   
	dc.w	STOP	; 3 - Shortstop  
	dc.w	FASTCOVER,Third	; 4 - 3rd baseman

ScrewPlay:
	dc.w	SEEKBALL	; 0 - Pitcher
	dc.w	COVER,First	; 1 - 1st baseman 
	dc.w	COVER,Second	; 2 - 2nd baseman   
	dc.w	STOP	; 3 - Shortstop  
	dc.w	COVER,Third	; 4 - 3rd baseman

	.export	AtWallCatch
AtWallCatch:
	SETRAML	WORLDZVEL,0x2000
	SETRAML	WORLDXVEL,0
	SETRAML	WORLDYVEL,0

	SETRAM	B_ONWALL,1

	JUMPRND	3
	ADDRESS	AtWall1
	ADDRESS	AtWall2
	ADDRESS	AtWall3
	ADDRESS	AtWall1


AtWall1:
	SPRITE	f95c01,3
	SPRITE	f95c02,3
	SPRITE	f95c03,1
AtWall1_1:
	LASTFRAME	1
	CMPWI	WORLDZVEL+2,0	; Check If Comping Down
	JUMPGT	AtWall1_1

	SETRAM	STATIONARY,1

	SETLOOP	30
AtWall1_2:	
	SPRITE	f95c04,1
	SYSTEM	CheckOffWall
	LOOP	AtWall1_2

	SETRAM	STATIONARY,-1

	SPRITE	f95c05,2
	SPRITE	f95c06,2
	SPRITE	f95c07,2
	SPRITE	f95c08,2
	SPRITE	f95c09,2
	SPRITE	f95c10,2
	SETRAML	WORLDYVEL,-0x100
	SPRITE	fgua06,2
	JUMP	EndRunCover

AtWall2:
	SPRITE	f95f01,2
	SPRITE	f95f02,2
	SPRITE	f95f03,2
	SPRITE	f95f04,1
AtWall2_1:
	LASTFRAME	1
	CMPWI	WORLDZVEL+2,0	; Check If Comping Down
	JUMPGT	AtWall2_1

	SETRAM	STATIONARY,1
	SETLOOP	30
AtWall2_2:	
	SPRITE	f95f05,1
	SYSTEM	CheckOffWall
	LOOP	AtWall2_2

	SETRAM	STATIONARY,-1

	SPRITE	f95f06,2
	SPRITE	f95f07,2
	SPRITE	f95f08,2
	SPRITE	f95f09,2
	SPRITE	f95f10,2
	SETRAML	WORLDYVEL,-0x100
	SPRITE	fgua06,2
	JUMP	EndRunCover

AtWall3:
	SPRITE	f93d01,3
	SPRITE	f93d02,3
	SPRITE	f93d03,1
AtWall3_1:
	LASTFRAME	1
	CMPWI	WORLDZVEL+2,0	; Check If Comping Down
	JUMPGT	AtWall3_1

	SETRAM	STATIONARY,1

	SETLOOP	30
AtWall3_2:	
	SPRITE	f93d04,1
	SYSTEM	CheckOffWall
	LOOP	AtWall3_2

	SETRAM	STATIONARY,-1

	SPRITE	f93d05,2
	SPRITE	f93d06,2
	SPRITE	f93d07,2
	SPRITE	f93d08,2
	SPRITE	f93d09,2
	SPRITE	f93d10,2
	SETRAML	WORLDYVEL,-0x100
	SPRITE	fgua06,2
	JUMP	EndRunCover

AtWallCaught:
	SETRAM	STATIONARY,-1
	SETRAM	B_HASBALL,1
	SPRITE	f95f06,2
	SPRITE	f95f07,2
	SPRITE	f95f08,2
	SPRITE	f95f09,2
	SPRITE	f95f10,2
	SETRAML	WORLDYVEL,-0x100
	SPRITE	fgua06,2
	JUMP	EndRunCover
	
	.align	2
         	.export	KnockHim

CheckOffWall:
	move.l	CONTROLBLOCK(a5),d0	; Load Address Of Control Block
	beq.s	CheckOff_9	; Branch If None
	move.l	d0,a0	; Move To Address Register
	cmp.w	#-2,TRACKY(a0)	; Check If Downward
	bge.s	CheckOff_8	; Branch If More
	move.w	#1,LOOPCOUNTER(a5)	; Set Last Loop
CheckOff_8:
	clr.w	TRACKY(a0)	; Clear Track Y
CheckOff_9:
	rts

KnockHim:
;	PUSHL	a0
;	move.l	ControlPtr,a0	; Load Address Of Controlled Player
;	move.l	#KnockDown,PARSEPOINTER(a0)	; Knock Down Pitcher
;	clr.w	DURATION(a0)	; Start Animation Soon
;	clr.b	B_CATCHACTIVE(a0)	; Don't Check For Catch 
;	clr.b	B_MOVABLE(a0)	; Don't Let Move
;	POPL	a0
	rts
	
	end

;	btst.b	#1,RAWBUTTONS+PlayerL
;	beq.s	RadTrap
;	trap	#1
;RadTrap:

