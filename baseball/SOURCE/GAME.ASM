;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************
	.region.s	"RAM"
	ds	0

;***************************************************************************
;   Routines Exported From GAME.ASM		*
;***************************************************************************
	.export	GameStart,Game
	.export	LoadPtrs
	.import	CalcFieldCoord,EndGameFlag
	.export	ClearSwitches
	.export	InitDisplay
	.export	InitTeam
	.export	CycleGame
	.export	GameStart1,GameStart2
	.export	ReadTrackball
	.export	InitTrackball
	.export	NewBatterUp,PlayHomeDone,InitControls
	.export	BatterDone
	.export	InAttractDraft

	.import	SetScoreFont,Selections,SwitchState
	.import	TicketSlider,TicketSlideL,TicketSlideR
	.import	AddStrike,SetHomePal,DraftY
	.import	ClearUpField,PlayAtHomeScreen,HalfInnScreen,HomeTrotScreen
;***************************************************************************
;  Variable Imports			*
;***************************************************************************
	.import	AttractSem,InitAI,AttractSelect
	.import.s	ProcessTime,max_chars
	.import.s	BlitAObject	
	.import.s	ControlPtr	; Address Of Controlling Object
	.import.s	StartFlag1,StartFlag2,GameMode
	.import.s	AITest,AIMode
	.import.s	GroundY2,GroundY,GameTime
	.import	S_PLN1XTP,S_PLN1YTP
	.import	skill_level
	.import	ClearPage
	.import.s	ScreenInvert,ScreenInvert2
	.import	pictest,InitProcs
	.import	didswing,P_NOWBAT,outs,testin,Inning,swing,BaseCount
	.import	FirstButton,SndBit1,BatWalk
	.import	CheckBases
	.import	NoTrackBalls
	.import	HelpCounter
	.import	SndBit2
	.import	Top10,WinsScreen
	.import	HasFirst

	.import	Bat_Team,PHAIR,FIELDER_CONTROLS,BatTableTeam,PHEADNUM;,batternum
	.import	briancount,FieldTeam
	.import	AtBatPlayer,AtPitPlayer
	.import	AreRunning
	.import	ZoneHeight
	.import	SkinTone,WinningPlayer

	.import	incinns1,AwayPlayer
	.import	incinns2,HomePlayer
	.import	hurryup,LogoScreen,LegalScreen
	.import	PrintInst
	.import	SetSkillLevel,InitSkillLevel
	.import	CoinageScreen,CoinageScreen2

;***************************************************************************
;  Subroutine Imports			*
;***************************************************************************
	.import	AttractLogoTest
	.import	BallFountain
	.import	DemoTextObj
	.import	CreditsMsg
	.import	InitBackgnd

	.import	InitPlayers

	.import	LoadAttractPal
	.import	LoadSelectPal
	.import	LoadGamePal

	.import	SetFont2,SetSysFont,SetWinFont
	.import	StartBackgnd
	.import	TextObject,ScaledObject
	.import	OScaledObject
	.import	oper_adj1

	.import	InitIntials
	.import	DisplayField
	.import	RunnerIntroF
	.import	WatchBall,SetBaseFlags
	.import	CLRSWING,CheckOut,StrikeOuts
	.import	ChangeControl,GiveControlsToBatter

	.import	PowerBar_1,PowerFrame
	.import	PowerBar_2
	.import	CheckPowerUp
	.import	CheckPowerUp2
	.import	BaseOMeter
	.import	CheckRunning
	.import	CoinFlag

	.import	T10list
	.import	T10data
	.import	T10art 

	.import	WinList
	.import	REC_stat_win
	.import	REC_stat_hits
	.import	REC_stat_homeruns
	.import	REC_stat_strikeouts
	.import	HitList
	.import	HomeList
	.import	StrikeList

;***************************************************************************
;  Team Table Imports			*
;***************************************************************************
	.import	Player

	.import	PlayerR,PlayerL

;***************************************************************************
;  RAM Variables Defined In This Section		*
;***************************************************************************
	.export.s	GameNum
	.export.s	AILevel
	.export	BackArt,TimerStatus,GameStatus,Timer,NewBack
	.export	CTimer
	.export	TimerTick,BuyIn
	.export	GameActive,AIActive
	.export	SinglePlayer

	.import	RunnerInst   	; Runner Inst. Counter
	.import	FielderInst   	; Fielder Inst. Counter

	.export.s	picout
	.import.s	objdis_cnt
	.export	PitchIt,MoveCard,MoveFField

	.import	ZonePtr,Zone3Obj,Baseball,CardPtr,WinFPtr,ScorePtr
	.import	FirstObjPtr,FirstMove,Third1ObjPtr,Third2ObjPtr
	.import	ThirdView1Obj,ThirdView2Obj
	.import	OutFnt,StrikeObjPtr,OutObjPtr
	.import.s	BALLX,SFONTX,BALLY
	.import.s	SwitchReason
	.import	bricount2
	.import	PickOffTest

	.import	PowerBallPal

	.global	SFONTY
	.global	TestClipObj
	.global	ZoneObj
	.global	SFONTY2
	.global	DisplayBall
	.import	StartText
 	.import	AttractDraft
	.import	StartThanks
	.import	DoITStuff
	.import	DraftInputTime
	.import	WeWishThanks
	.import	StartCards
;	.import	DCardNum	

	.global	ZoneObjPtr

	.import	InAttract
	.export.s	BatHeight

CTimer	    ds.w	1
Timer	    ds.b	1
Timer2	    ds.b	1
TimerTick	    ds.b	1
TimerStatus    ds.b	1
GameStatus	    ds.b	1
PitchIt	    ds.b	1
MoveCard       ds.b  1
MoveFField	    ds.b	1

BackArt	    ds.w	1
NewBack	    ds.w	1
GameActive	    ds.b	1
BuyIn	    ds.b	1

Distance	    ds.w	1
AILevel	    ds.w	1
GameNum	    ds.b	1
AIActive	    ds.b	1
SinglePlayer   ds.l	1	;was a byte

AbortTime      ds.w	1	; Trackball Time Out

AttractCnt	    ds.b	1

picout	    ds.b  1 	

	.export	BallOnGround

BallOnGround   ds.b	1	; Incremented When Ball Touches Ground

PlayHomeDone   ds.b 1	;play at home done flag
BatHeight      ds.b	1
BatterDone	    ds.b	1	; Set If Time For New Batter

ZoneObjPtr	    ds.l	1

WinWait	    ds.w	1

ListCycle	    ds.w	1
AttractCounter ds.b	1
InAttractDraft ds.b	1

	.export	Temp1,Temp2,Temp3,Temp4
Temp1	    ds.l	1
Temp2	    ds.l	1
Temp3	    ds.l	1
Temp4	    ds.l	1

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
	#include	"ai.h"
;	#include	"r:\baseball\sounds\bsblsnds.equ"
;	#include	"c:\bb\player.h"
;	#include	"r:\baseball\art\tables\player.h"
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

;***************************************************************************
;  System Subroutine Imports		*
;***************************************************************************
	.import	DeallocObject

	.import	TogglePage
	.import	Random,Mode1
	.import	Sort,ClrStr
	.import	TakeContCredits,TakeStartCredits
	.import	TestStartCredits,TestContCredits
	.import	DspBody
	.import	PageLine
	.import	InitField

	.import.s	GameMode
	.import	CalcZ
 
	.import	AnimPlayer,AnimPlayer2
	.import	Pitcher,Batter,FirstBase,SecondBase,ShortStop,FirstRunner
	.import	ThirdBase,Catcher,LeftField,CenterField,RightField
	.import	SecondRunner,ThirdRunner,HomeRunner,HomeRun
	.import	InitJoys,InitCycle

;***************************************************************************
;               Ramblock imports (from ramblock.inc)	*
;***************************************************************************
	.import	InitObjects,Update,Display
	.import	AllocObject
	.import	Anim
	.import	BlitObject,BlitClipObj,BlitCentered

;***************************************************************************
;               anim.asm imports		*
;***************************************************************************
	.import	InitJoyWatch,JoyWatch
	.import	ButtonSelect1,ButtonSelect2
	.import.s	ShakeYDist

TickReset	equ	36
ABORTTIME	equ	60*60*1	; One Minute

;***************************************************************************
;***************************************************************************

GameStart:
	clr.b	InAttractDraft
	clr.b	HasFirst	; Let Track Balls Roll
	clr.b	NoTrackBalls	; Let Track Balls Roll
	clr.b	EndGameFlag	; game is not over
	move.w	#ABORTTIME,AbortTime	; 
	move.w	#60,WinWait	;win message wait for halfinn

	move.w	#25,BALLX	; X Cordinate For The Strike/Out Ball
	move.w	#135,BALLY	; Y Cordinate For The Strike/Out Ball
	move.w	#7,SFONTX	; X Cordinate For The Strike Font
	move.w	#135,SFONTY	; Y Cordinate For The Strike Font  Top
	move.w	#155,SFONTY2	; Y Cordinate For The Strike Bottom

	jsr	InitSkillLevel	; Set Up Skill Level

	clr.w	PlayerL+AISTATUS	; Clear AI Status
	clr.w	PlayerR+AISTATUS	; Clear AI Status

;	SWITCH	#START1,#81H,#GameStart1	; Set Up Start Switches
;	SWITCH	#START2,#81H,#GameStart2

	jsr	InitGame	; Initialize Game

;	SOUND	#SOUNDSON,#SOUNDSON	; Turn On Sounds
;	SOUND	#SetVolume,#0	; Set Sound Volume

;o	jsr	ClearPage	; Clear The Screen
;o	jsr	TogglePage	; Display The Cleared Screen
;o	DELAY	#10	; Delay 1/3 Second
;o	jsr	TogglePage	; Display The Cleared Screen

	jsr	InitCycle	; Initialize Color Cycling
	jsr	InitObjects	; Initialize Object System
	jsr	InitDisplay	; Initialize The Display

	clr.b	PrintInst
	move.w	ScreenInvert,ScreenInvert2	; Set Screen Invert

;	SOUND	#SetVolume,#0	; Set Volume
	jsr	LoadSelectPal	; Select Screen palettes

	tst.b	GameMode
	beq.s	.AttMode
	SOUND	#SOUNDSON,#SOUNDSON	; Turn On Sounds
	jsr	Selections	; Select Teams
	bra.s	.SelDone
.AttMode
	jsr	AttractSelect	; sets Selections variables
.SelDone

	jsr	SetHomePal
	jsr	CLRSWING
	move.b	#0,FieldTeam

;	SPAWN	#CycleP_BALL,#25
;	CYCLE	#P_BALL,#231,#24,#1

;	move.b	#1,PlayerL+START	; Force Player Start
;	move.b	#1,PlayerR+START	;

;	clr.w	HelpCounter
	move.w	#-1,HelpCounter
	jsr	CLRSWING

 .if debugmode=="obe"
	move.b	#16,Inning	;16=top of 9th for end game test
 .endif

	move.w	#84*256,PlayerL+TOTALPOWER	; Set Total Power for Left Player
	move.w	#84*256,PlayerR+TOTALPOWER	; Set Total Power for Left Player
	clr.b	RunnerInst   	; Runner Inst. Counter
	clr.b	FielderInst   	; Fielder Inst. Counter

	clr.b	bricount2
	clr.w	SwitchReason	; Clear Ball Hit Flag
	jsr	HalfInnScreen	;select starting pitcher
NextTeamUp:
;	move.w	#84*256,PlayerL+TOTALPOWER	; Set Total Power for Left Player
;	move.w	#84*256,PlayerR+TOTALPOWER	; Set Total Power for Left Player
	jsr	InitTeam	; Inialize New Team Up
NewBatterUp:
	jsr	SetSkillLevel	; Set Skill Level
	tst.l	WinningPlayer
	bne.s	SuddenDeath

	cmp.b	#3,outs	; Is there 3 outs?
	bne.s	Not3Outs	; No, then branch
	jsr	ChangeControl
	jsr	SwapAtBatPit
	
;	jsr	InitJoys	; Initialize Joy Stick Data
;	jsr	InitControls	; Initialize Controls
;	jsr	InitBackgnd	; Initialize Background
;	jsr	InitJoyWatch	; Watch The Inputs
;	jsr	InitTrackball 	; Initialize Trackball
;	jsr	InitPlayers	; Initialize All Fielders
SuddenDeath
	clr.b	PrintInst
;	move.w	#84*256,PlayerL+TOTALPOWER	; Set Total Power for Left Player
     ;	move.w	#84*256,PlayerR+TOTALPOWER	; Set Total Power for Left Player
	jsr	CheckOut	; Do 3 out stuff in batter
	jsr	HalfInnScreen	;
	tst.b	EndGameFlag
	bne	Game_B	;halfinn says game is over
	bra	NextTeamUp	; Cycle up to Next Team
Not3Outs:			; If there wasent 3 outs
;	tst.b	PickOffTest
;	beq.s	WasPickOff
	clr.b	BatterDone	; Clear Batter Done Flag
	jsr	InitObjects	; Initialize Object System
	jsr	InitJoys	; Initialize Joy Stick Data
	jsr	ResetBatter	; Reset Batter Information

	jsr	InitControls	; Initialize Controls
	jsr	InitPlayers	; Initialize All Fielders


	clr.w	BackArt	; Set For Play Field
	jsr	InitBackgnd	; Initialize Background
	jsr	InitJoyWatch	; Watch The Inputs
	jsr	ZoneObj	; Set Up Strike Zone Object
	clr.w	SwitchReason	; Clear Switch Reason
	jsr	BaseOMeter	; Display Base-O-Meter
	jsr	PowerFrame
    	jsr	PowerBar_1
    	jsr	PowerBar_2

	jsr	InitTrackball 	; Initialize Trackball
	jsr	StrikeOuts

;***************************************************************************
; Main Game Loop			*
;***************************************************************************
	move.b	#1,GameActive	; Activate The Game
Game:
	move.l	#PlayerR,a0	; Load Address Of Right Player
	move.b	START(a0),d0	; Load Player Start Condition
	eor.b	#1,d0	; Invert It
	move.b	d0,COMPUTER(a0)	; Save Computer Status

	move.l	#PlayerL,a0	; Load Address Of Left Player
	move.b	START(a0),d0	; Load Player Start Condition
	eor.b	#1,d0	; Invert It
	move.b	d0,COMPUTER(a0)	; Save Computer Status

	move.b	#15,PlayerL+BOZOFACTOR	; Set Bozo Factor
	move.b	#15,PlayerR+BOZOFACTOR	; Set Bozo Factor

	clr.w	SwitchReason	; Clear Ball Hit Flag
Game_1:
	jsr	CoinExit
	bsr	CycleGame	; Perform One Game Cycle
	tst.b	BatterDone	; Test If Batter Struck Out
	bne	nextbatter	; Branch If Batter Done
	tst.w	SwitchReason	; Check For Ball Hit
	beq.s	Game_1	; Continue If Not


;	move.b	#1,HomeRunner+INUSE	;test


home2field
	jsr	InitField	; Initialize Field Objects
Game_2:
	jsr	CoinExit
	bsr	CycleGame	; Perform One Game Cycle

;outfield view, exit condition: home runner at home plate
	tst.b	HomeRun	;Home Run?
	bpl.s	.nohomer
	move.b	#1,NoTrackBalls
	jsr	HomeTrotScreen
	clr.b	NoTrackBalls
	bra	QuickExit
.nohomer
;outfield view, exit condition: close play at home plate

	bra	.nohp	;bri no play at home

	cmp.l	#PITCHERY-(24*256),Baseball+WORLDY ;ball close enough to catcher?
     	bge.s	.nohp
	tst.l	Baseball+WORLDYVEL	;ball going toward catcher?
     	bpl.s	.nohp

	move.l	#HomeRunner,a0
	jsr	CloseTest
	bne	.PlayHome

	move.l	#FirstRunner,a0
	jsr	CloseTest
	bne	.PlayHome

	move.l	#SecondRunner,a0
	jsr	CloseTest
	bne	.PlayHome

	move.l	#ThirdRunner,a0
	jsr	CloseTest
	beq	.nohp

.PlayHome	jsr	PlayAtHomeScreen
	move.w	#BACKFROMHOME,SwitchReason
;	bra	home2field
	bra	QuickExit
.nohp

;test for game end during inning
;	btst	#0,Inning	;top of inning?
;	beq.s	.noend	;branch if Top O Inning
;	cmp.b	#18,Inning	;bottom of ninth inning
;	blt.s	.noend	;bri 17
;	move.b	([AwayPlayer],RUNS),d0
;	cmp.b	([HomePlayer],RUNS),d0
;	blt	SuddenDeath	;game over
;.noend
;	tst.l	WinningPlayer
;	beq.s	NoSuddenDeath
;	sub.w	#1,WinWait
;	bmi	SuddenDeath	;game over
;NoSuddenDeath

;start button exits fieldview
;       	move.b	#START1,d0
;       	jsr	SwitchState
;       	cmp.b	#SWITCH_OPEN,d0
;    ;   	beq.s	TimedOut  5
;      	beq	Game_2
;       	move.b	#START2,d0
;       	jsr	SwitchState
;       	cmp.b	#SWITCH_OPEN,d0
;    ;   	beq.s	TimedOut
;      	beq	Game_2
;       	bra.s	QuickExit

; .if debugmode=="obe"
;;	jsr	HomeTrotScreen
; .endif
;
;
;	bra.s	QuickExit

TimedOut:
	cmp.b	#3,outs
	bls.s	NotQuick
	cmp.b	#0x40,BallOnGround
	bge.s	NotQuick
	move.b	#0x40,BallOnGround
	clr.b	AreRunning

NotQuick:
	jsr	CheckBases	; Count number of BaseRunners
	tst.b	BaseCount	; test to see if 0
	beq.s	NoRunners	; if not 0

	jsr	CheckRunning
	cmp.b	#-1,AreRunning
	beq	Game_2

NoRunners:
	clr.w	d0
	move.b	BallOnGround,d0	; Load Something
	cmp.b	#0x31,d0	; Check If ball in field time.
	bls.s	LessThen60	;was 62, and 55 bri
	move.b	#0x25,BallOnGround
LessThen60:

	cmp.b	#0x30,BallOnGround	; Check If ball in field time.
	bne	Game_2	;was bne


QuickExit:
	move.l	#HomeRunner,a0	; Load Address Of Home Runner
QuickExit_1:
	cmp.b	#1,B_ONBASE(a0)	; Check If Valid
	blt.s	QuickExit_2	; Branch If Not
	cmp.b	#3,B_ONBASE(a0)	; Check If Valid
	ble.s	QuickExit_3	; Branch If Fine
QuickExit_2:
	clr.b	B_INUSE(a0)	; Make Not In Use
QuickExit_3:
	move.l	CHILD(a0),a0	; Load Next Runner Address
	tst.l	a0	; Check If Done
	bne.s	QuickExit_1	; Continue If Not


;	SOUND	#BackGroundMusic,#BackGroundMusic	; Init Sounds System
	clr.b	BatWalk
.exitfield
;	tst.b	PickOffTest
;	bne.s	nextbatter
	jsr	ClearUpField	; Clear Up Fielder Screen
nextbatter
	tst.b	PickOffTest
	bne.s	WasPickOff
	jsr	ClrStr	;inc batternum
WasPickOff:
	clr.b	PickOffTest

 .if debugmode=="obe"
;	move.b	#3,outs	;for testing innings
 .endif

	tst.b	GameMode
	bne	NewBatterUp	; Continue If Not
	rts		;return to attract mode

Game_3:
	jsr	EndGame	; End Of Game Stats
Game_4:
	jsr	ClearPage
	jsr	TogglePage
	DELAY	#10

	neg.b	PlayerL+START	; Invert Start Flags
	neg.b	PlayerR+START	; Invert Start Flags

Game_B:
	DELAY	#10
	jsr	EndGame	; End Of Game Stats
	move.b	#2,GameMode	; Flag Game Over
	rts


;***************************************************************************
CoinExit		;allow exit in attract mode if coin comes in
	tst.b	GameMode
	bne.s	NoAtt	; Continue If Not
	tst.b	CoinFlag
	beq.s	NoAtt	;no coin
	POPL	d0	;dont return to game
	rts		;return to attract
NoAtt	rts		;return to game

;***************************************************************************
; InitTeam() - Initialize Next Team At Bat		*
;				*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: NONE			*
;***************************************************************************
InitTeam:
	clr.b	FirstRunner+B_INUSE	; First Base Runner Not In Use
	clr.b	SecondRunner+B_INUSE	; Second Base Runner Not In Use
	clr.b	ThirdRunner+B_INUSE	; Third Base Runner Not In Use
	clr.b	HomeRunner+B_INUSE	; Home Plate Runner Not In Use
	rts

;***************************************************************************
; CycleGame() - Perform One Game Cycle		*
;				*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: d1				*
;***************************************************************************
CycleGame:
	sub.w	#1,AbortTime	; Decrement Time Out
	bne.s	CycleGame_1	; Branch If Not
	move.b	#2,GameMode	; End The Game
CycleGame_1:
	jsr	JoyWatch	; Watch The Joystick
	jsr	SetBaseFlags	; Set Fielders On Base
	jsr	Update	; Update All Objects
	jsr	Sort	; Sort The Objects
	jsr	Display	; Display All Objects

	jsr	SetSysFont	; Set Up For Font 0
	APALETTE	#P_SYSFONT	; Use Font Palette

	.import.s	BackupCount

;	PLOT	#10,#110
;	PRINTHEX	#BackupCount,#2

	jsr	TogglePage	; Swap Pages

	rts

;***************************************************************************
; CheckStart() - Check For Start Button Pressed During Game	*
;				*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: d1				*
;***************************************************************************
	.export	CheckStart
CheckStart:
	jsr	LoadPtrs	; Load Pointers To Players
	move.b	COMPUTER(a5),d0	; Load Player 1 Computer
	and.b	START(a5),d0	; And With Player Started
	beq.s	ChkStrt_1	; Branch If Game Continues
	clr.b	COMPUTER(a5)
	bra.s	ChkStrt_2
ChkStrt_1:
	move.b	COMPUTER(a6),d0	; Load Player 1 Computer
	and.b	START(a6),d0	; And With Player Started
	beq	ChkStrt_9	; Branch If Game Continues
	clr.b	COMPUTER(a6)
	exg	a5,a6	; Make A5 Starting
ChkStrt_2:
InteruptPlay:		; someone buying in
	jsr	CycleGame	; Cycle The Game

	DELAY	#80
	jsr	LoadPtrs	; Load Player Pointers
ChkStrt_9:	
	move.b	#1,d0	; Flag Start Of Match
	rts

;***************************************************************************
; LoadPtrs - Initialize Game Values		*
;				*
; Parameters: NONE			*
; Returns: a5 - Address Of Left Player		*
;	a6 - Address Of Right Player		*
; Uses: None 			*
;***************************************************************************
LoadPtrs:
	move.l	#PlayerL,a5	; Load Address Of Player 1 Data
	move.l	#PlayerR,a6	; Load Address Of Player 2 Data
	rts

;***************************************************************************
; InitGame() - Initialize Game Values		*
;				*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: a5,a6,d1 			*
;***************************************************************************
InitGame:
	FLOP	OFF	; No Flopping Here, Maybe Next Game
	EXTERM	#0	; Clear The Multi-Tasking System
	clr.b	BuyIn	; Not Buying In
	clr.b	ShakeYDist	; Clear Screen Shake
	jsr	ClearScores	; Clear The Scores
	jsr	InitTrackball	; Initialize Track Ball

	clr.b	outs
	clr.b	BuyIn	; Not Buying In

	EXTERM	#0	; Clear The Multi-Tasking System
	clr.b	GameNum	; Clear Number Of Games
	jsr	LoadPtrs	; Load Pointers To Players

	move.b	#30,TimerTick	; Set Up Timer Tick
	clr.w	FrameRate	; Run At Sizty Hertz

	jsr	SetSkillLevel	; Set Up Skill Level

	rts

	.align	2
;***************************************************************************
; ClearScores() - Clear Innings Scores 		*
;				*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: d0,d0,a0,a1			*
;***************************************************************************
	.export	ClearScores
ClearScores:
	move.l	#PlayerL+INNINGSSCORE,a0	; Load Address Of Left Player
	move.l	#PlayerR+INNINGSSCORE,a1	; Load Address Of Right Player
	move.b	#-1,d0	; Load Value Of Inning Not Scored
;	move.w	#12-1,d1	; 12 Bytes To Clear
	move.w	#IMAX-1,d1	; 12 Bytes To Clear
ClearScr_1:
	move.b	d0,(a0)+	; Clear Four Bytes
	move.b	d0,(a1)+	; Clear Four Bytes
	dbf	d1,ClearScr_1	; Continue Until Done

	clr.b	PlayerL+RUNS	; Clear Runs
	clr.b	PlayerR+RUNS	; Clear Runs
	clr.b	PlayerL+HITS	; Clear Hits
	clr.b	PlayerR+HITS	; Clear Hits
	clr.b	PlayerL+ERRORS	; Clear Errors
	clr.b	PlayerR+ERRORS	; Clear Errors

 .if debugmode=="obe"
;end game test left player should be on top of scoreboard (right starts first)
	clr.l	PlayerL+INNINGSSCORE
	clr.l	PlayerL+INNINGSSCORE+4
	move.b	#0,PlayerL+INNINGSSCORE+8
	move.b	#0,PlayerL+RUNS
;	move.b	#10,PlayerL+INNINGSSCORE
;	move.b	#10,PlayerL+INNINGSSCORE+1
;	move.b	#10,PlayerL+INNINGSSCORE+2
;	move.b	#10,PlayerL+INNINGSSCORE+3
;	move.b	#10,PlayerL+INNINGSSCORE+4
	clr.l	PlayerR+INNINGSSCORE
	clr.l	PlayerR+INNINGSSCORE+4
	move.b	#1,PlayerR+INNINGSSCORE+7
	move.b	#1,PlayerR+RUNS
 .endif

	rts

;***************************************************************************
; ResetBatter() - Reset Batter Values 		*
;				*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: d1				*
;***************************************************************************
ResetBatter:
	clr.l	PlayerR+CONTROLOBJECT	; Clear Controlled Object
	clr.l	PlayerL+CONTROLOBJECT	; Clear Controlled Object
	move.l	#Pitcher,ControlPtr	; Pitcher Is In Control

	clr.b	BatHeight
	EXTERM	#0	; Clear The Multi-Tasking System
	clr.w	FrameRate	; Run At Sizty Hertz

	clr.b	Timer   	; 
	move.b	#TickReset,TimerTick
	move.b	#T_PREGAME,TimerStatus

	move.l	#Baseball,a0	; Load Address Of Ball Object
	move.l	#PITCHERY,WORLDY(a0)	; Save Pitcher X Position
	move.l	#PITCHERX,WORLDX(a0)	; Save Pitcher Y Position
	move.l	#72*256,WORLDZ(a0)	; Save Pitcher Z Position
	clr.l	DISPLAYPROC(a0)	; Clear Displaying Routine
	clr.l	UPDATEPROC(a0)	; Clear Updating Routine
	rts

;***************************************************************************
; InitDisplay() - Initialize Display Before a Start Of Round	*
;				*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: d1				*
;***************************************************************************
InitDisplay:
	clr.w	FrameRate	; Run At Sizty Hertz
	PLANES	#PLANEA&PLANEB
	DELAY	#1

	clr.w	Mode1
	clr.w	QMode1
	LOOKAHEAD	ON	; Turn On GROM Look Ahead
	WIDTHPIX	OFF	
	FLIP	OFF	; Turn Off Flipping
	FLOP	OFF	; Turn Off Flopping
	CLIP	ON	; Turn On Clipping
	TRANS	ON	; Turn On Transparency
	rts

;***************************************************************************
; EndGame - Perform End Of Game Stats/Cleanup		*
;				*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: ALL			*
;***************************************************************************
EndGame:
	clr.w	FrameRate	; Run At Sizty Hertz
	clr.b	Inning	;for ticket buying on start button
	SWITCH	#START1,#81H,#GameStart1
	SWITCH	#START2,#81H,#GameStart2

	move.b	#2,GameMode	; Kill Off Game win no one playing
	rts

;********************************************************************************
;********************************************************************************
ClearSwitches:
	SWITCH	#FIRSTBASE1,#2H,#0
	SWITCH	#SECONDBASE1,#2H,#0
	SWITCH	#THIRDBASE1,#2H,#0
	SWITCH	#HOMEPLATE1,#2H,#0

	SWITCH	#FIRSTBASE2,#2H,#0
	SWITCH	#SECONDBASE2,#2H,#0
	SWITCH	#THIRDBASE2,#2H,#0
	SWITCH	#HOMEPLATE2,#2H,#0
	rts

InitControls:
	move.l	#PlayerL,a0	; Load Address Of Left Player
	bsr	InitControl	; Initialize Controls
	move.l	#PlayerR,a0	; Load Address Of Right Player
	bsr	InitControl	; Initialize Controls
	rts

InitControl:
	clr.b	SPECIALJOY(a0)
	clr.b	BUTTONS(a0)
	clr.l	INPUTROUTINE(a0)
	clr.b	JOYSTICK(a0)
	move.b	#10,BUTTONCOUNT(a0)
	rts

****************************************************************************
* Attract() - Perform Attract Sequence		*
*				*
* Parameters: NONE			*
* Returns: NONE			*
* Uses: d1				*
****************************************************************************
	.export	AttractMode
	.import.s	AttractSem	; if in special attract no FA
	.import	CheckSounds

AttractMode:
	jsr	LoadAttractPal

	clr.b	CoinFlag
	clr.b	AttractCounter

AttractModeLP
	jsr	CheckSounds

	jsr	LoadPtrs	; Load Pointer To Characters
	clr.b	INNINGSBOUGHT(a5)
	clr.b	INNINGSBOUGHT(a6)

	move.w	ScreenInvert,ScreenInvert2	; Restore Screen Invert
	clr.b	BuyIn	; Not Buying In

	clr.b	AttractCnt
	clr.b	Timer
	move.b	#1,Timer2

	jsr	InitCycle	; Initialize Color Cycling
	jsr	InitProcs	; Remove Fielders
	jsr	InitObjects	; Initialize Object System
	jsr	InitDisplay	; Initialize The Display

	SOUND	#BuyInMusic,#BuyInMusic	; Turn On Sounds
	move.w	#1,BackArt	; Set For Title Page
	move.w	BackArt,d0	; Set For Attract
	jsr	InitBackgnd	; Initialize Background

Attract_1:
	clr.w	PlayerR+TEAMNUMBER
	clr.w	PlayerL+TEAMNUMBER

Attract_1A:
	clr.l	Batter+DISPLAYPROC
	clr.l	Pitcher+DISPLAYPROC
	clr.l	Batter+UPDATEPROC
	clr.l	Pitcher+UPDATEPROC
	clr.w	Batter+YPOSITION
	clr.w	Pitcher+YPOSITION
	move.w	#5*60,NewBack
Attract_2:
	jsr	CycleAttract	; Perform One Game Cycle
	sub.w	#1,NewBack	; Check If Time For New Background
	bmi.s	Attract_3	; Branch If Time For Game Play
;	beq.s	Attract_2	; Continue If Not
	bra.s	Attract_2

Attract_2A:
;	move.w	NewBack,d1	; Load New Background Number
;	jsr	StartBackgnd	; Start Up New Background
;	beq	Attract_2
;	rts

Attract_3:
;	SOUND	#JerseyOpen,#JerseyOpen

	jsr	Top10	;generate 4 top 10 lists
	add.w	#1,ListCycle
	move.w	ListCycle,d0
	and.w	#11b,d0	;one of 4 top 10 lists
	move.w	d0,ListCycle


	cmp.w	#0,ListCycle
	bne.s	Hit10

	move.w	#700,NewBack	;duration

	jsr	InitObjects	; Initialize Object System

	move.l	#WinList,T10list
	move.w	#REC_stat_win,T10data
	move.w	#mostwins,T10art
	jsr	WinsScreen
Attract_win:
	jsr	CycleAttract	; Perform One Game Cycle
	sub.w	#1,NewBack	; Check If Time For New Background
	bpl.s	Attract_win	; Branch If Time For Game Play
;	trap	#1

;next screen
Hit10
	cmp.w	#1,ListCycle
	bne.s	Home10

	move.w	#700,NewBack	;duration

	jsr	InitObjects	; Initialize Object System

	move.l	#HitList,T10list
	move.w	#REC_stat_hits,T10data
	move.w	#tophitte,T10art
	jsr	WinsScreen
Attract_hit:
	jsr	CycleAttract	; Perform One Game Cycle
	sub.w	#1,NewBack	; Check If Time For New Background
	bpl.s	Attract_hit
;	trap	#1

;next screen
Home10
	cmp.w	#2,ListCycle
	bne.s	Strike10

	move.w	#700,NewBack	;duration

	jsr	InitObjects	; Initialize Object System

	move.l	#HomeList,T10list
	move.w	#REC_stat_homeruns,T10data
	move.w	#homeslug,T10art
	jsr	WinsScreen
Attract_hom:
	jsr	CycleAttract	; Perform One Game Cycle
	sub.w	#1,NewBack	; Check If Time For New Background
	bpl.s	Attract_hom
;	trap	#1

;next screen
Strike10
	cmp.w	#3,ListCycle
	bne.s	GameAtt

	move.w	#700,NewBack	;duration

	jsr	InitObjects	; Initialize Object System

	move.l	#StrikeList,T10list
	move.w	#REC_stat_strikeouts,T10data
	move.w	#outaces,T10art
	jsr	WinsScreen
Attract_str:
	jsr	CycleAttract	; Perform One Game Cycle
	sub.w	#1,NewBack	; Check If Time For New Background
	bpl.s	Attract_str
;	trap	#1

;next screen
GameAtt
;	bra	ITSkip
	move.w	#850,NewBack

	jsr	InitObjects	; Initialize Object System
	jsr	LogoScreen
Attract_MLB:
	jsr	CycleAttract	; Perform One Game Cycle
	sub.w	#1,NewBack	; Check If Time For New Background
	bpl.s	Attract_MLB



	cmp.b	#6,AttractCounter	; has attract cycled 5 times
	bne	SkipCredits	; branch if not

;next screen
	clr.b	AttractCounter	; clear attract counter
	move.w	#1370,NewBack

	jsr	InitObjects	; Initialize Object System
   	jsr	StartText
   	jsr	StartCards
Attract_DCRED:
	jsr	CycleAttract	; Perform One Game Cycle
	jsr	BallFountain
	sub.w	#1,NewBack	; Check If Time For New Background
	bpl.s	Attract_DCRED	; Branch If Time For Game Play




;next screen
	move.w	#800,NewBack

	jsr	InitObjects	; Initialize Object System
   	jsr	StartThanks
Attract_Thanks:
	jsr	CycleAttract	; Perform One Game Cycle
	jsr	BallFountain
	sub.w	#1,NewBack	; Check If Time For New Background
	bpl.s	Attract_Thanks	; Branch If Time For Game Play

;next screen
WeWish:

	move.w	#1200,NewBack

	jsr	InitObjects	; Initialize Object System
   	jsr	WeWishThanks
;	jsr	DraftInputTime
Wish_Thanks:
	jsr	CycleAttract	; Perform One Game Cycle
	sub.w	#1,NewBack	; Check If Time For New Background
	bpl.s	Wish_Thanks	; Branch If Time For Game Play



;next screen
ITSkip
	move.w	#700,NewBack

	jsr	InitObjects	; Initialize Object System
   	jsr	DoITStuff
ITStuff:
	jsr	CycleAttract	; Perform One Game Cycle
	sub.w	#1,NewBack	; Check If Time For New Background
	bpl.s	ITStuff	; Branch If Time For Game Play


;next screen


	move.w	#200,NewBack

	jsr	InitObjects	; Initialize Object System

	jsr	LegalScreen

Attract_legal:
	jsr	CycleAttract	; Perform One Game Cycle
	sub.w	#1,NewBack	; Check If Time For New Background
	bpl.s	Attract_legal	; Branch If Time For Game Play

SkipCredits:

;next screen
Draftthing
	add.b	#1,AttractCounter
	move.w	#800,NewBack

	move.b	#1,InAttractDraft
	jsr	InitObjects	; Initialize Object System
   	jsr	AttractDraft
Attract_draft:
	jsr	CycleAttract	; Perform One Game Cycle
	sub.w	#1,NewBack	; Check If Time For New Background
	bpl.s	Attract_draft	; Branch If Time For Game Play
	clr.b	InAttract
	clr.b	InAttractDraft

	SOUND	#BatterUpOrgan,#BatterUpOrgan; Turn On Sounds

	jsr	ClearPage
	jsr	TogglePage
	DELAY	#10

	jsr	InitObjects	; Initialize Object System


	add.b	#1,AttractCounter
	clr.l	SinglePlayer	; Set As A Two Player Game
	jsr	GameStart

	jmp	AttractModeLP


	jsr	LoadPtrs	; Load Address Of Teams
	move.b	#1,COMPUTER(a5)	; Force Both To Computer
	move.b	#1,COMPUTER(a6)	; Force Both To Computer
;	move.b	#0,COMPUTER(a5)	; Force Both To Computer
;	move.b	#0,COMPUTER(a6)	; Force Both To Computer

	move.w	#1,TEAMNUMBER(a5)	; Set Team Number
	move.w	#2,TEAMNUMBER(a6)	; Set Team Number

	jsr	InitDisplay	; Initialize The Display

;	tst.b	AttractSem
;	bne.s	Attract_3_1	  
;	SOUND	#FADE,#FADE	; backgnd snd stop
Attract_3_1:

	jsr	InitGame	; Initialize Game

	jsr	ResetBatter	; Initialize Round
	jsr	InitJoys	; Initialize Joy Stick Data

	jsr	InitBackgnd	; Initialize Background

	move.w	GroundY2,Batter+YPOSITION	; Store Starting Y Position
	move.w	GroundY2,Pitcher+YPOSITION	; Store Starting Y Position

	move.w	#TORSOZ,Batter+ZPOSITION	; Store Starting z Position
	move.w	#TORSOZ,Pitcher+ZPOSITION	; Store Starting z Position

	jsr	InitJoyWatch	; Watch The Joystick


	
	
;	tst.b	AttractSem	; if in special attract no FA
;	bne.s	Attract_3a
Attract_3a:
	move.b	#1,AIActive	; Activate AI
	move.b	#1,GameActive	; Activate The Game
Attract_4:
	bsr	CycleGame	; Perform One Game Cycle
	bra.s	Attract_4	; Continue Until Player Dead
Attract_5:
	EXTERM	#1	; Exterminate Joystick Task
	bra	Attract_1A	; Bring Up Next Screen

****************************************************************************
* CycleAttract() - Perform One Attract Cycle		*
*				*
* Parameters: NONE			*
* Returns: NONE			*
* Uses: d1				*
****************************************************************************
CycleAttract:
	tst.b	CoinFlag
	beq.s	.NoCoin	;no coin
	clr.b	Inning	;for ticket buying on start button
	jmp	CoinageScreen	;test, doesnt return
.NoCoin
	jsr	Update	; Update All Objects
	jsr	Sort	; Sort The Objects
	jsr	Display	; Display All Objects
	jsr	CreditsMsg	; Display Credits
	FRAMERT	#0	;/60 Hz quicker rtn
	PLANES	#PLANEA	; Select The Foreground Plane
	jsr	TogglePage	; Swap Pages
	rts

****************************************************************************
* GameStart1 - Player 1 Game Start		*
*				*
* Parameters: NONE			*
* Returns: NONE			*
* Uses: d1				*
****************************************************************************
	.align 2
GameStart1:
	clr.b	InAttract
	jsr	LoadPtrs	; Load Pointer To Characters
	cmp.b	#1,START(a5)	; Check If Already Started
	beq	GameSt1_5	; Branch If It Is	

	cmp.b	#DraftY,PlayerR+YND	;is other player drafting?
	beq	GameSt1_6	; Branch If yes

	move.w	#1,d0	; Check For Player 1
	jsr	TestCredits	; Check If Enough Credits Available
	beq	GameSt1_6	; Branch If Not
	jsr	TakeCredits	; Decrement Credit Count
	move.b	#1,START(a5)
	move.b	Inning,d0
	lsr.b	#1,d0	;convert inning halves to whole
	add.b	#2,d0
	move.b	d0,INNINGSBOUGHT(a5)

	clr.b	COMPUTER(a5)	; Not A Computer

	move.l	#TicketSlideL,a4	;players ticket slider
	move.l	#PlayerL,a6
	jsr	TicketSlider

	move.w	#$0301,Timer	; Set Initial Timer
	move.b	#TickReset,TimerTick	; Reset Timer Tick

	SWITCH	#START1,#1H,#incinns1
	SWITCH	#BUTTON1_1,#1H,#hurryup
	SWITCH	#BUTTON1_2,#1H,#hurryup
	SWITCH	#BUTTON1_3,#1H,#hurryup
	SWITCH	#BUTTON1_4,#1H,#hurryup
;	SWITCH	#START1,#81H,#ButtonSelect1 ;activate diffrent selects

	jsr	LoadPtrs	; Load Pointer To Characters
	move.l	#PlayerL,SinglePlayer ; Set As Single Player Game
	tst.b	START(a6)	; Check If Other Player Active
	beq.s	GameSt1_3	; Branch If One Player Game
	clr.l	SinglePlayer	; Set As A Two Player Game
	AUDIT	#STARTHUMAN	; Increment Audit
	bra.s	GameSt1_4
GameSt1_3:
	AUDIT	#STARTCOMPUTER	; Increment Audit
GameSt1_4:
;	jsr	SelectPlyr
	rts
GameSt1_5:
	SWITCH	#START1,#81H,#ButtonSelect1 ;activate diffrent selects
GameSt1_6:
	jsr	LoadPtrs	; Load Pointer To Characters
	move.b	#1,NEWBUTTON(a5)	; Flag New Button
	rts

****************************************************************************
* GameStart2 - Player 2 Game Start		*
*				*
* Parameters: NONE			*
* Returns: NONE			*
* Uses: d1				*
****************************************************************************
GameStart2:
	clr.b	InAttract
	jsr	LoadPtrs	; Load Pointer To Characters
	cmp.b	#1,START(a6)	; Check If Already Started
	beq	GameSt2_5	; Branch If It Is

	cmp.b	#DraftY,PlayerL+YND	;is other player drafting?
	beq	GameSt2_6	; Branch If yes

	move.w	#2,d0	; Check For Player 2
	jsr	TestCredits	; Check If Enough Credits Available
	beq	GameSt2_6	; Branch If Not
	jsr	TakeCredits	; Decrement Credit Count
	move.b	#1,START(a6)
	move.b	Inning,d0
	lsr.b	#1,d0	;convert inning halves to whole
	add.b	#2,d0
	move.b	d0,INNINGSBOUGHT(a6)

	clr.b	COMPUTER(a6)	; Not A Computer

	move.l	#TicketSlideR,a4	;players ticket slider
	move.l	#PlayerR,a6
	jsr	TicketSlider

	move.w	#$0301,Timer	; Set Initial Timer
	move.b	#TickReset,TimerTick	; Reset Timer Tick

	SWITCH	#START2,#1H,#incinns2
	SWITCH	#BUTTON2_1,#1H,#hurryup
	SWITCH	#BUTTON2_2,#1H,#hurryup
	SWITCH	#BUTTON2_3,#1H,#hurryup
	SWITCH	#BUTTON2_4,#1H,#hurryup
;	SWITCH	#START2,#81H,#ButtonSelect2 ;activate different selects

	jsr	LoadPtrs	; Load Pointer To Characters
	move.l	#PlayerR,SinglePlayer ; Set As Single Player Game
	tst.b	START(a5)	; Check If Other Player Active
	beq.s	GameSt2_3	; Branch If One Player Game
	clr.l	SinglePlayer	; Set As A Two Player Game
	AUDIT	#STARTHUMAN	; Increment Audit
	bra.s	GameSt2_4
GameSt2_3:
	AUDIT	#STARTCOMPUTER	; Increment Audit
GameSt2_4:
	exg	a5,a6
;	jsr	SelectPlyr
	rts
GameSt2_5:
	SWITCH	#START2,#81H,#ButtonSelect2 ;activate different selects
GameSt2_6:
	jsr	LoadPtrs	; Load Pointer To Characters
	move.b	#1,NEWBUTTON(a6)	; Flag New Button
	rts

****************************************************************************
* TestCredits - Check If Enough Credits Available For Start Or Continue    *
*				*
* Parameters: NONE			*
*				*
* Returns: NONE			*
*				*
* Uses: ALL			*
****************************************************************************
	.export	TestCredits
TestCredits:
	cmp.b	BuyIn,d0	; Check For Buy In
	beq.s	TestCred_1	; Branch If Buying In
	jsr	TestStartCredits	; Check For Starting Credits
	rts
TestCred_1:
	jsr	TestContCredits	; Check For Continuing Credits
	rts

****************************************************************************
* TakeCredits - Check If Enough Credits Available For Start Or Continue    *
*				*
* Parameters: NONE			*
*				*
* Returns: NONE			*
*				*
* Uses: ALL			*
****************************************************************************
	.export	TakeCredits
TakeCredits:
	tst.b	BuyIn	; Check For Buy In
	bne.s	TakeCred_1	; Branch If Buying In
	jsr	TakeStartCredits	; Take Starting Credits
	clr.b	BuyIn
	rts
TakeCred_1:
	jsr	TakeContCredits	; Take Continuing Credits
	clr.b	BuyIn
	rts

****************************************************************************
* InitTrackball - Set Up Track Ball Variables		*
*				*
* Parameters: NONE			*
* Returns:    NONE			*
* Uses:       NONE			*
****************************************************************************
InitTrackball:
	move.l	#PlayerL,a1	: Load Address Of Left Player

	move.b	TRACKPORT1,d0	; Load Track Ball X
	and.b	#0x0F,d0	; Extract Lower Four Bits
	lsl.b	#4,d0	; Move To Upper Nibble
	move.b	d0,LASTTRACKX(a1)	; Save Trackball Values
	move.b	d0,NEWTRACKX(a1)	; Save Initial Value

	move.b	TRACKPORT1,d0	; Load Track Ball X
	and.b	#0xF0,d0	; Extract Upper Four Bits
	move.b	d0,LASTTRACKY(a1)	; Save Trackball Values
	move.b	d0,NEWTRACKY(a1)	; Save Initial Value

	clr.w	TRACKXVEL(a1)
	clr.w	TRACKYVEL(a1)
	clr.w	LASTTRACKXVEL(a1)
	clr.w	LASTTRACKYVEL(a1)
	clr.l	TRACKXDELTA(a1)
	clr.l	TRACKXDELTA+4(a1)
	clr.l	TRACKXDELTA+8(a1)
	clr.l	TRACKXDELTA+12(a1)
	clr.l	TRACKYDELTA(a1)
	clr.l	TRACKYDELTA+4(a1)
	clr.l	TRACKYDELTA+8(a1)
	clr.l	TRACKYDELTA+12(a1)
	clr.w	TRACKXCNT(a1)
	clr.w	TRACKYCNT(a1)
	clr.w	TRACKY(a1)
	clr.w	TRACKX(a1)
	clr.w	MAXTRACKXVEL(a1)
	clr.w	MAXTRACKYVEL(a1)

	move.l	#PlayerR,a1	: Load Address Of Right Player

	move.b	TRACKPORT2,d0	; Load Track Ball X
	and.b	#0x0F,d0	; Extract Lower Four Bits
	lsl.b	#4,d0	; Move To Upper Nibble
	move.b	d0,LASTTRACKX(a1)	; Save Trackball Values
	move.b	d0,NEWTRACKX(a1)	; Save Initial Value

	move.b	TRACKPORT2,d0	; Load Track Ball X
	and.b	#0xF0,d0	; Extract Upper Four Bits
	move.b	d0,LASTTRACKY(a1)	; Save Trackball Values
	move.b	d0,NEWTRACKY(a1)	; Save Initial Value

	clr.w	TRACKXVEL(a1)
	clr.w	TRACKYVEL(a1)
	clr.w	LASTTRACKXVEL(a1)
	clr.w	LASTTRACKYVEL(a1)
	clr.l	TRACKXDELTA(a1)
	clr.l	TRACKXDELTA+4(a1)
	clr.l	TRACKXDELTA+8(a1)
	clr.l	TRACKXDELTA+12(a1)
	clr.l	TRACKYDELTA(a1)
	clr.l	TRACKYDELTA+4(a1)
	clr.l	TRACKYDELTA+8(a1)
	clr.l	TRACKYDELTA+12(a1)
	clr.w	TRACKXCNT(a1)
	clr.w	TRACKYCNT(a1)
	clr.w	TRACKY(a1)
	clr.w	TRACKX(a1)
	clr.w	MAXTRACKXVEL(a1)
	clr.w	MAXTRACKYVEL(a1)

	rts

****************************************************************************
* ReadTrackball - 			*
*				*
* Parameters: NONE			*
* Returns:    NONE			*
* Uses:       NONE			*
****************************************************************************
ReadTrackball:
	tst.b	NoTrackBalls	;Test for Shut Down
	bne	ReadTrack_8	;Branch if shut down

	move.l	#PlayerL,a1	; Load Address Of Left Player

; Left Player - Track Ball X
	tst.b	COMPUTER(a1)	; Check If Computer Player
	bne	ReadTrack_4	; Branch If Not A Human

	move.b	TRACKPORT1,d0	; Load Track Ball X
	and.b	#0x0F,d0	; Extract Lower Four Bits
	lsl.b	#4,d0	; Move To Upper Nibble

	move.b	NEWTRACKX(a1),LASTTRACKX(a1) ; Save Last Track X
	move.b	d0,NEWTRACKX(a1)	; Save New Track X

	sub.b	LASTTRACKX(a1),d0	; Subtract Previous Track X
	beq.s	ReadTrack_0	; Branch If No Change
	move.w	#ABORTTIME,AbortTime	; Reset Abort Time
ReadTrack_0:
	ext.w	d0	; Extend To A Word
	neg.w	d0	; Negate Result

	asr.w	#4,d0	; Shift Back Down

	lea.l	TRACKXDELTA(a1),a0	; Load Address Of Deltas
	move.w	TRACKXCNT(a1),d1	; Load Counter
	move.w	d0,(a0,d1.w)	; Save Delta Value
	addq.w	#2,d1	; Increment Counter
	and.w	#0xE,d1	; Force In Range (0,2,4,6,8,10,12,14)
	move.w	d1,TRACKXCNT(a1)	; Store New Counter

	add.w	d0,TRACKX(a1)	; Add To Track Value

	lea.l	TRACKXDELTA(a1),a0	; Load Address Of Deltas
	move.w	(a0)+,d0	; Load First Delta
	add.w	(a0)+,d0	; Add In Delta 2
	add.w	(a0)+,d0	; Add In Delta 4
	add.w	(a0)+,d0	; Add In Delta 6
	add.w	(a0)+,d0	; Add In Delta 8
	add.w	(a0)+,d0	; Add In Delta 10
	add.w	(a0)+,d0	; Add In Delta 12
	add.w	(a0)+,d0	; Add In Delta 14
	move.w	d0,TRACKXVEL(a1)	; Store Velocity
	bpl.s	ReadTrack_1	; Branch iF Positive
	neg.w	d0	; Make It Positive
ReadTrack_1:
	cmp.w	MAXTRACKXVEL(a1),d0	; Check If Maxium
	ble.s	ReadTrack_2	; Branch If Not
	move.w	d0,MAXTRACKXVEL(a1)	; Save Maximum
	move.w	TRACKXVEL(a1),LASTTRACKXVEL(a1) ; Save Previous Velocity
ReadTrack_2:

; Left Player - Track Ball Y

	move.b	TRACKPORT1,d0	; Load Track Ball X
	and.w	#0xF0,d0	; Extract Upper Nibble

	move.b	NEWTRACKY(a1),LASTTRACKY(a1) ; Save Last Track Y
	move.b	d0,NEWTRACKY(a1)	; Save New Track Y

	sub.b	LASTTRACKY(a1),d0	; Subtract Previous Track Y
	beq.s	ReadTrack_1A	; Branch If No Change
	move.w	#ABORTTIME,AbortTime	; Reset Abort Time
ReadTrack_1A:
	ext.w	d0	; Extend To A Word
	neg.w	d0	; Negate Result
	asr.w	#4,d0	; Shift Back Down

	lea.l	TRACKYDELTA(a1),a0	; Load Address Of Deltas
	move.w	TRACKYCNT(a1),d1	; Load Counter
	move.w	d0,(a0,d1.w)	; Save Delta Value
	addq.w	#2,d1	; Increment Counter
	and.w	#0xE,d1	; Force In Range (0,2,4,6,8,10,12,14)
	move.w	d1,TRACKYCNT(a1)	; Store New Counter

	add.w	d0,TRACKY(a1)	; 

	lea.l	TRACKYDELTA(a1),a0	; Load Address Of Deltas
	move.w	(a0)+,d0	; Load First Delta
	add.w	(a0)+,d0	; Add In Delta 2
	add.w	(a0)+,d0	; Add In Delta 4
	add.w	(a0)+,d0	; Add In Delta 6
	add.w	(a0)+,d0	; Add In Delta 8
	add.w	(a0)+,d0	; Add In Delta 10
	add.w	(a0)+,d0	; Add In Delta 12
	add.w	(a0)+,d0	; Add In Delta 14
	move.w	d0,TRACKYVEL(a1)	; Store Velocity
	bpl.s	ReadTrack_3	; Branch iF Positive
	neg.w	d0	; Make It Positive
ReadTrack_3:
	cmp.w	MAXTRACKYVEL(a1),d0	; Check If Maxium
	ble.s	ReadTrack_4	; Branch If Not
	move.w	d0,MAXTRACKYVEL(a1)	; Save Maximum
	move.w	TRACKYVEL(a1),LASTTRACKYVEL(a1) ; Save Previous Velocity
ReadTrack_4:

; Right Player - Track Ball X

	move.l	#PlayerR,a1	; Load Address Of Right Player

	tst.b	COMPUTER(a1)	; Check If Computer Player
	bne	ReadTrack_8	; Branch If Not A Human

	move.b	TRACKPORT2,d0	; Load Track Ball Y
	and.b	#0x0F,d0	; Extract Lower Four Bits
	lsl.b	#4,d0	; Move To Upper Nibble

	move.b	NEWTRACKX(a1),LASTTRACKX(a1) ; Save Last Track X
	move.b	d0,NEWTRACKX(a1)	; Save New Track X

	sub.b	LASTTRACKX(a1),d0	; Subtract Previous Track X
	beq.s	ReadTrack_4A	; Branch If No Change
	move.w	#ABORTTIME,AbortTime	; Reset Abort Time
ReadTrack_4A:
	ext.w	d0	; Extend To A Word
	neg.w	d0	; Negate Result

	asr.w	#4,d0	; Shift Back Down

	lea.l	TRACKXDELTA(a1),a0	; Load Address Of Deltas
	move.w	TRACKXCNT(a1),d1	; Load Counter
	move.w	d0,(a0,d1.w)	; Save Delta Value
	addq.w	#2,d1	; Increment Counter
	and.w	#0xE,d1	; Force In Range (0,2,4,6,8,10,12,14)
	move.w	d1,TRACKXCNT(a1)	; Store New Counter

	add.w	d0,TRACKX(a1)	; 

	lea.l	TRACKXDELTA(a1),a0	; Load Address Of Deltas
	move.w	(a0)+,d0	; Load First Delta
	add.w	(a0)+,d0	; Add In Delta 2
	add.w	(a0)+,d0	; Add In Delta 4
	add.w	(a0)+,d0	; Add In Delta 6
	add.w	(a0)+,d0	; Add In Delta 8
	add.w	(a0)+,d0	; Add In Delta 10
	add.w	(a0)+,d0	; Add In Delta 12
	add.w	(a0)+,d0	; Add In Delta 14
	move.w	d0,TRACKXVEL(a1)	; Store Velocity
	bpl.s	ReadTrack_5	; Branch iF Positive
	neg.w	d0	; Make It Positive
ReadTrack_5:
	cmp.w	MAXTRACKXVEL(a1),d0	; Check If Maxium
	ble.s	ReadTrack_6	; Branch If Not
	move.w	d0,MAXTRACKXVEL(a1)	; Save Maximum
	move.w	TRACKXVEL(a1),LASTTRACKXVEL(a1) ; Save Previous Velocity
ReadTrack_6:

; Right Player - Track Ball Y

	move.b	TRACKPORT2,d0	; Load Track Ball Y
	and.w	#0xF0,d0	; Extract Upper Nibble

	move.b	NEWTRACKY(a1),LASTTRACKY(a1) ; Save Last Track Y
	move.b	d0,NEWTRACKY(a1)	; Save New Track Y

	sub.b	LASTTRACKY(a1),d0	; Subtract Previous Track Y
	beq.s	ReadTrack_6A	; Branch If No Change
	move.w	#ABORTTIME,AbortTime	; Reset Abort Time
ReadTrack_6A:
	ext.w	d0	; Extend To A Word
	neg.w	d0	; Negate Result

	asr.w	#4,d0	; Shift Back Down

	lea.l	TRACKYDELTA(a1),a0	; Load Address Of Deltas
	move.w	TRACKYCNT(a1),d1	; Load Counter
	move.w	d0,(a0,d1.w)	; Save Delta Value
	addq.w	#2,d1	; Increment Counter
	and.w	#0xE,d1	; Force In Range (0,2,4,6,8,10,12,14)
	move.w	d1,TRACKYCNT(a1)	; Store New Counter

	add.w	d0,TRACKY(a1)	; Increment Track Ball Value

	lea.l	TRACKYDELTA(a1),a0	; Load Address Of Deltas
	move.w	(a0)+,d0	; Load First Delta
	add.w	(a0)+,d0	; Add In Delta 2
	add.w	(a0)+,d0	; Add In Delta 4
	add.w	(a0)+,d0	; Add In Delta 6
	add.w	(a0)+,d0	; Add In Delta 8
	add.w	(a0)+,d0	; Add In Delta 10
	add.w	(a0)+,d0	; Add In Delta 12
	add.w	(a0)+,d0	; Add In Delta 14
	move.w	d0,TRACKYVEL(a1)	; Store Velocity
	bpl.s	ReadTrack_7	; Branch iF Positive
	neg.w	d0	; Make It Positive
ReadTrack_7:
	cmp.w	MAXTRACKYVEL(a1),d0	; Check If Maxium
	ble.s	ReadTrack_8	; Branch If Not
	move.w	d0,MAXTRACKYVEL(a1)	; Save Maximum
	move.w	TRACKYVEL(a1),LASTTRACKYVEL(a1) ; Save Previous Velocity
ReadTrack_8:
	rts

;****************************************************************************

SwapAtBatPit:
	move.l	AtBatPlayer,d0
	move.l	AtPitPlayer,AtBatPlayer
	move.l	d0,AtPitPlayer
	eor.b	#1,FieldTeam	;Changes Field Team	
	rts

;****************************************************************************
CycleP_BALL
	CYCLE	#P_BALL,#231,#24,#1
	DELAY	#60	; cycle 1 range (if 24, never starts)

	CYCLE	#P_BALL,#231,#24,#0	;turn off cycling
	DELAY	#30*3	; 30*3=3 seconds?

	jmp	CycleP_BALL

;****************************************************************************
CloseTest
	tst.b	B_INUSE(a0)	;is there a home runner?
	beq.s	.nohp

	tst.b	B_ONBASE(a0)	; Flag Running To Home From Third
	bpl.s	.nohp

	cmp.l	#HOMEPLATEY+((20*12)*256),WORLDY(a0) ;runner close enough to homeplate?
	bgt.s	.nohp
	cmp.l	#HOMEPLATEY+((10*12)*256),WORLDY(a0) ;runner too close to homeplate?
	blt.s	.nohp
	move.b	#1,d0	;set z flag
	rts
.nohp	move.b	#0,d0	;set z flag
	rts


	.global	NEXTOBJECT,PARSEPOINTER,CONTROLBLOCK,XPOSITION,YPOSITION
	.global	XFRACTION,YFRACTION,XVELOCITY,YVELOCITY,ZPOSITION,DAMP
	.global	GRAVITY,ONGROUND,STATIONARY,BOUNCESOUND
	.global	PICTURE,BANK,PALETTE,CURRENTFRAME,DURATION,DURATIONRESET
	.global	UPDATEPROC,DISPLAYPROC,NUMBEROFCHARS,STARTCHARACTER
	.global	ALWAYSROUTINE,PARENT,TEXTPTR,CHILD,FLIPFLAG
	.global	LOOPCOUNTER,EXERETURN,DELETED,DIRECTION,VSPRITETYPE
	.global	SEEKING,HASBALL,COUNTER,DATAPTR,VELOCITYDECREMENT
	.global	ANCHORX,ANCHORY,BLITHEIGHT,BLITWIDTH,FLOPFLAG,OBJECTTYPE
	.global	XSCALE,YSCALE,DAMAGETYPE,INUSE,XCLIP1,XCLIP2,YCLIP1,YCLIP2
	.global	WORLDX,WORLDY,WORLDZ,WORLDXVEL,WORLDYVEL,WORLDZVEL
	.global	GOALX,GOALY,GOALPP,TORSOBANK,HEADBANK,HEADPALETTE
	.global	TOPPALETTE,BOTPALETTE,NUMPALETTE,FRAMESDATA,SCALEFACTOR
	.global	DIRSPRITES

	.global	CONTROLOBJECT,TEAMNUMBER,COMPUTER,DEADFLAG,INPUTROUTINE
	.global	BUTTONS,JOYSTICK,SPECIALJOY,JOYSEQDATA,JOYSEQDECAY
	.global	TRACKY,TRACKX,TRACKCOUNT,LASTTRACKX,LASTTRACKY
	.global	LASTTRACKXVEL,LASTTRACKYVEL,NEWTRACKX,NEWTRACKY
	.global	TRACKXVEL,TRACKYVEL,TRACKXDELTA,TRACKYDELTA,TRACKXCNT,TRACKYCNT
	.global	MAXTRACKXVEL,MAXTRACKYVEL,SAVEJOYSTICK,SAVEBUTTONS
	.global	INNINGSSCORE,RUNS,HITS,ERRORS,START,NEWBUTTON,BUTTONCOUNT
	.global	LASTJOYSTICK,STARTBUTTON,FIRSTBUTTON,SECONDBUTTON
	.global	THIRDBUTTON,HOMEBUTTON,PLAYERSTEAM,FIRSTPITCHER,BATTINGORDER
	.global	B_DIRECTION,B_INUSE,B_SEEKING,B_DATAPTR,B_GOALX
	.global	B_GOALY,B_GOALPP,B_TORSOBANK,B_HEADBANK,B_HEADPALETTE
	.global	B_TOPPALETTE,B_BOTPALETTE,B_NUMPALETTE,B_FRAMESDATA  
	.global	B_DIRSPRITES,B_MOVABLE,B_HASBALL,B_ONBASE,B_OUT
	.global	B_FORCED,B_COVERING
	.global	ROSTERPTR

	.global	letters,month,dayofmonth,stat_win
	.global	stat_lost,stat_ba,stat_homeruns,first_pitcher,players
	.global	present,YND,Bcursor,Lcursor,max_select,max_input
	.global	bat_order,cardX,dnamex,dnamexinc,winCNT,seriesCNT

	end
