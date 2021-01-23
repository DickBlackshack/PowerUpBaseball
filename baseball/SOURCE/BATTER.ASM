;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************
;****** Batter Controls the Batter, Pitcher, and Fielders (for now)  *******

 
	.region.s	"RAM"


BALLXTMP	ds.w	1
strike	ds.b	1
swing	ds.b	1
outs	ds.b	1
outtmp	ds.w	1
BatterPal	ds.b	1
strike1ptr ds.l	1
strike2ptr ds.l	1
strike3ptr ds.l	1
out1ptr	ds.l	1
out2ptr	ds.l	1
out3ptr	ds.l	1
NewOut	ds.b	1
NewStrike	ds.b	1
didswing	ds.b	1
P_NOWBAT	ds.b	1
didwiff	ds.b	1
PHEADNUM	ds.b	1
PHAIR	ds.b	1
;batternum	ds.w	1
Bat_Team	ds.b	1	;0 is Away, 1 is Home
HomeBatNum ds.w	1
AwayBatNum ds.w	1
BallTo	ds.b	1
BatTablePos	ds.w 1
BatTableTeam	ds.w 1
BatRoster	ds.l 1	;a6 =BatRoster
Inning	ds.b	1
briancount	ds.b	1
BaseCount	ds.b	1
FirstButton ds.b	1
ThirdButton ds.b	1
SndBit1	ds.b	1
SndBit2	ds.b	1
BatterReady ds.b	1
ZoneHeight	ds.w	1
speed	ds.l	1
BatWalk	ds.b	1	;0 no wdalkin 1 walkin
AreRunning	ds.b	1	;0 no wdalkin 1 walkin
SkinTone	ds.b	1	;0 no wdalkin 1 walkin
CanSwing	ds.b	1	;0 cant swing, 1 can
pitcht	ds.b	1	;0 cant swing, 1 can
	.export	SwingFlag
SwingFlag	ds.b	1
Light	ds.b	1
SaveTopPal	ds.b	1
SaveBotPal	ds.b	1
SaveTopBPal	ds.b	1
SaveBotBPal	ds.b	1

NoTrackBalls	ds.b	1
PrintInst	ds.b	1
AntiL	ds.b	1
TiredPit	ds.b	1
WasAVint	ds.b	1
IsOnGround	ds.b	1
ShouldStand ds.b	1
HasFirst	ds.b	1
PitchSound	ds.b	1

	.region	"RomCode"
	ds	0

	#include	"sys.h"
	#include	"itvideo2.h"
	#include	"anim.mac"
	#include	"controls.h"
	#include	"ramblock.h"
;	#include	"r:\baseball\art\tables\player.h"
;	#include	"c:\bb\player.h"
;	#include	"r:\baseball\sounds\bsblsnds.equ"
	#include	"bsblsnds.equ"
	#include	"player.h"
;	#include	"banks.h"
	#include	"joydefs.h"
	#include	"pals.h"
	#include	"graphlib.mac"
	#include	"sys.mac"
	#include	"rosters.h"
	#include	"groms.h"

	.export	PlayerIntro,PitcherIntro,FielderIntro,CatchIBall,CatchCBall,MoveGlove
	.export	AddStrike,swing,CatcherIntro
	.export	didswing ;,batternum
	.export	WatchBall,P_NOWBAT
	.export	Bat_Team,PHAIR,PHEADNUM
	.export	BatTableTeam,BatTablePos,BatRoster
 	.export	CLRSWING,outs,briancount,NewOut,AddOut,Inning,swing
	.export	CheckOut,strike
	.export	FastCatch
	.export	didwiff
	.export	BATTER_CONTROLS,CONTROLS_COUNT
	.export	BaseCount
	.export	BatWalk
	.export	GiveControlsToBatter,GiveCounterToBatter
	.export	FirstButton
	.export	CheckOut,ClrStr
	.export	CheckBases
	.export	CheckRunning
	.export	DoSkinPalette
	.export	AreRunning
	.export	SkinTone
	.export	Light
	.export	SndBit1,SndBit2,CanSwing
	.export	DoDive
	.export	Instructions
	.export	NoTrackBalls 
	.export	HitByPitch
	.export	PrintInst
	
	.import	AtBatPlayer,AtPitPlayer,SwitchState

	.import	SwitchHit
	.import	InAttractDraft
	.import	FrameRate
	.import	BallFountain
	.import	PowerBallPal
	.import.s BallCordX,BallCordY,BallCordZ
	.import.s	BatHeight
	.import	SetSysFont
	.import	GhostPitch,TwisterPitch,KnucklePitch

	.import	ThreeUp3Down
	.import	Steal2nd
	.import	Steal3rd
	.import	InitAI
	.import	CardAnimPinch

	.import	attrib_size,teamattrib_size
	.import	PitchIt,PitchBall,B_CardObj,MoveCard,ScoreObj
	.import   FirstViewObj,FirstObjPtr,FirstRunStart,FirstRunPtr,FirstMove
	.import	frmove
	.import 	RunnerIntroF,Batter,DeallocObject,DeallocObjecta1,RunToSecond
	.import	Pitcher,AllocObject
	.import	SecondRunPtr,SecondRunner,FirstRunner,ThirdRunner,HomeRunner
	.import	SecondRunStart
	.import	BallObj,BallObjPtr,BallMove,BallPassed,DirtObj,RockObj
	.import.s	Baseball
	.import.s	ForcedOut
     	.import	StrikeS,OutFnt
	.import.s	Zone3Obj,ZonePtr,CardPtr,ScorePtr
	.import	AwayPlayer,HomePlayer
	.import	GetBatterRoster,InitObjects
	.import	SwitchReason
	.import	PickOffTest
	.import	InitTrackball
	.import	InitJoyWatch
	.import	BigOutObj
	.import	SaberOn
	.import	PitcherTag
	.import	BatterTag
	.import	ClearObjPtrs


	.export	WasAVint
	.import	GameMode
	.import	SinglePlayer	; Single Player Flag

	.import.s	BALLX,SFONTX,BALLY,StrikeObjPtr
;	.import	AttractSounds
	.import	ROSTERS
	.import	CheckHit,AwayTeamNum,HomeTeamNum
	.import	AnimPlayer,TrackPlayer
	.import	ThrowToFirst,ThrowToSecond,ThrowToThird,ThrowToHome
	.import	StrikeOuts,ChangeControl
	.import	InitTeam
	.import	LeadTrigger_2nd,BackTrigger_1st
	.import	LeadTrigger_3rd,BackTrigger_2nd
	.import	LeadTrigger_Home,BackTrigger_3rd
	.import 	HalfInnScreen
	.import 	BatterDone
	.import	FieldTeam
	.import	RunDirection
	.import	StartRunners
	.import	RunToFirst
	.import	RunToThird
	.import	HomeRun
	.import	CheckPowerUp
	.import	CheckPowerUp2
	.import	PowerPtr,PowerPtr2
	.import.s	FirstCover
	.import.s	SecondCover
	.import.s	BallOnGround
	.import	RunToDugout

	.import	Help1Obj
	.import	Help1Ptr
	.import	RetiredObj
	.import	ExtraObj
	.import	TakeObj
	.import	StrikemObj
	.import	BigMesh

	.import	BatterHelp
	.import	PitcherHelp
	.import	WinningPlayer,WinTest3Outs

	.import	NotEnough
	.import	NotEnoughP
	.export	ZoneHeight
	.export	Fight
	.import	UnderHandPitch

	.import	ProTipPtr
	.import	ProTipObj
	.export	PrintHelp
	.export	Pitcher_5
	.export	AntiL
	.export	HasFirst

;Equates for the Ethnicity from AT_ethnicity
W    equ  0       ;White
H    equ  1       ;Hispanic
B    equ  2       ;Black

;************************************************************************
	.align	2

PITCHER_CONTROLS    		; Pitcher Can pickoff a runner
	IFPOWERUP	POWERPITCHING
	LOADABS	Steal2nd
	JUMPCMP	0,PITCHER_CONTROLS_2
	JUMPCMP	1,PITCHER_CONTROLS3
PITCHER_CONTROLS_2    		; Pitcher Can pickoff a runner
	LOADABS	Steal3rd
	JUMPCMP	0,PITCHER_NOCONTROLS
	JUMPCMP	1,PITCHER_CONTROLS3

PITCHER_CONTROLS3
	LOAD	BUTTONS
	STANDARDMOVE FIRSTBASE,PickOff_1
	STANDARDMOVE SECONDBASE,PickOff_2
	STANDARDMOVE THIRDBASE,PickOff_3

;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DONE

POWERPITCHING
	LOAD	BUTTONS
	STANDARDMOVE FIRSTBASE,UnderPitch
	STANDARDMOVE SECONDBASE,VintagePitch
	STANDARDMOVE THIRDBASE,TornadoPitch
	STANDARDMOVE HOMEPLATE,BeanBall
	DONE


PITCHER_NOCONTROLS		; Pitcher Can Pick off a Runner
	LOAD	BUTTONS
;	STANDARDMOVE FIRSTBASE,PickOff_1;PitchType1;GoPitch
;	STANDARDMOVE SECONDBASE,PickOff_2;PitchType1;GoPitch
;	STANDARDMOVE THIRDBASE,PickOff_3;PitchType1;GoPitch
	DONE



PITCHER_BALL_CONTROLS           	; Pitcher Controls the Ball
	LOAD	BUTTONS

;	ALLBITS	FIRSTBASE|HOMEPLATE,DownRightBall
;	ALLBITS	FIRSTBASE|SECONDBASE,UpRightBall
;	ALLBITS	THIRDBASE|HOMEPLATE,DownLeftBall
;	ALLBITS	THIRDBASE|SECONDBASE,UpLeftBall
;
;	ANYBITS	FIRSTBASE,RightBall
;	ANYBITS	SECONDBASE,UpBall
;	ANYBITS	THIRDBASE,LeftBall
;	ANYBITS	HOMEPLATE,DownBall
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DONE

	
SpeedUp:
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	NOCLEAR	BUTTONS
	ANYBITS	FIRSTBASE|SECONDBASE|THIRDBASE|HOMEPLATE,SpeedUp1
	DONE
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;

BATTER_CONTROLS
STANDING_CONTROLS	     	; Batter Can move in or out
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	
	IFPOWERUP	PowerButtons

	LOADABS	BaseCount
	JUMPCMP	0,BATTER_CONTROLS0	;No Controls so no stealing
	JUMPCMP	1,BATTER_CONTROLS0
	JUMPCMP	2,BATTER_CONTROLS0
	JUMPCMP	3,BATTER_CONTROLS0
	JUMPCMP	4,BATTER_CONTROLS0


BATTER_CONTROLS0
	LOAD	BUTTONS
;	ANYBITS	FIRSTBASE,BNothing
;	ANYBITS	SECONDBASE,BNothing
;	ANYBITS	FIRSTBASE,SubToFButton
;	ANYBITS	SECONDBASE,AddToFButton
;	ANYBITS	THIRDBASE,BNothing
;	ANYBITS	HOMEPLATE,BNothing
;	ANYBITS	STARTBASE,StartButtonSnd

	DONE

BATTER_CONTROLS1
	LOAD	BUTTONS
	ANYBITS	FIRSTBASE,LeadTrigger_2nd
;	ANYBITS	SECONDBASE,LeadTrigger_2nd
;	ANYBITS	THIRDBASE,BNothing
;	ANYBITS	HOMEPLATE,BNothing
;	ANYBITS	STARTBASE,StartButtonSnd
	DONE

BATTER_CONTROLS2

	LOAD	BUTTONS
;	ANYBITS	FIRSTBASE,BNothing
	ANYBITS	SECONDBASE,LeadTrigger_3rd
;	ANYBITS	THIRDBASE,LeadTrigger_3rd
;	ANYBITS	HOMEPLATE,BNothing
;	ANYBITS	STARTBASE,StartButtonSnd
	DONE

BATTER_CONTROLS3
	LOAD	BUTTONS
;	ANYBITS	FIRSTBASE,BNothing
;	ANYBITS	SECONDBASE,BNothing
	ANYBITS	THIRDBASE,LeadTrigger_Home
;	ANYBITS	HOMEPLATE,LeadTrigger_Home
;	ANYBITS	STARTBASE,StartButtonSnd
	DONE

BATTER_CONTROLS4
	LOAD	BUTTONS
	ANYBITS	FIRSTBASE,LeadTrigger_2nd
;	ANYBITS	SECONDBASE,LeadTrigger_2nd
	ANYBITS	THIRDBASE,LeadTrigger_Home
;	ANYBITS	HOMEPLATE,LeadTrigger_Home
;	ANYBITS	STARTBASE,StartButtonSnd
	DONE

         
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	.export	BATTER_NOCONTROLS
BATTER_NOCONTROLS
	LOAD	BUTTONS
	DONE

PowerButtons:
	LOAD	BUTTONS

	ANYBITS	FIRSTBASE,POneArm
	ANYBITS	SECONDBASE,PPinch
	ANYBITS	THIRDBASE,PLightSabre	
	ANYBITS	HOMEPLATE,PKarate
	DONE


BATTER_SKIP
	LOAD	BUTTONS
	ANYBITS	FIRSTBASE,Fight
	ANYBITS	SECONDBASE,Fight
	ANYBITS	THIRDBASE,Fight
	ANYBITS	HOMEPLATE,Fight
	DONE

BATTER_SWING
	LOAD	BUTTONS
 ;	ANYBITS	FIRSTBASE,SStepTo
 ;	ANYBITS	THIRDBASE,SStepFrom
;	ANYBITS	FIRSTBASE,BNothing
;	ANYBITS	SECONDBASE,ZoneUp
;	ANYBITS	THIRDBASE,BNothing
;	ANYBITS	HOMEPLATE,ZoneDown
;	ANYBITS	STARTBASE,StartButtonSnd
	DONE

BATTER_WALKING
	LOAD	BUTTONS
;	ANYBITS	FIRSTBASE,SStepTo
;	ANYBITS	THIRDBASE,SStepFrom
	DONE

CONTROLS_COUNT    ;These are given to the batter after the ball is Pitched
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	
	LOADABS	BaseCount
	JUMPCMP	0,CONTROLS_COUNT0
	JUMPCMP	1,CONTROLS_COUNT1
	JUMPCMP	2,CONTROLS_COUNT2
	JUMPCMP	3,CONTROLS_COUNT3
	JUMPCMP	4,CONTROLS_COUNT4

CONTROLS_COUNT0:	
	LOAD	BUTTONS
;	ANYBITS	FIRSTBASE,BNothing
;	ANYBITS	SECONDBASE,BNothing
;	ANYBITS	THIRDBASE,BNothing
;	ANYBITS	HOMEPLATE,BNothing
  	DONE

CONTROLS_COUNT1:	
	LOAD	BUTTONS
	ANYBITS	FIRSTBASE,AddToFButton
;	ANYBITS	SECONDBASE,AddToFButton
;	ANYBITS	THIRDBASE,BNothing
;	ANYBITS	HOMEPLATE,BNothing
	DONE

CONTROLS_COUNT2:	
	LOAD	BUTTONS
;	ANYBITS	FIRSTBASE,BNothing
	ANYBITS	SECONDBASE,AddToFButton
;	ANYBITS	THIRDBASE,AddToFButton
;	ANYBITS	HOMEPLATE,BNothing
	DONE

CONTROLS_COUNT3:	
	LOAD	BUTTONS
;	ANYBITS	FIRSTBASE,BNothing
;	ANYBITS	SECONDBASE,BNothing
	ANYBITS	THIRDBASE,AddToFButton
;	ANYBITS	HOMEPLATE,AddToFButton
	DONE

CONTROLS_COUNT4:	
	LOAD	BUTTONS
	ANYBITS	FIRSTBASE,AddToFButton
;	ANYBITS	SECONDBASE,AddToFButton
	ANYBITS	THIRDBASE,AddToTButton
;	ANYBITS	HOMEPLATE,AddToTButton
	DONE
         
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DONE

NO_CONTROLS		; Don't Allow the batter to move
	LOAD	BUTTONS
	DONE	         

	.export	FIELDER_CONTROLS

FIELDER_CONTROLS    ;These are given to the Fielder After the ball is pitched
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;	LOADOBJ	B_ONSCREEN	; Check If Fielder Is On Screen
; 	JUMPEQU	FIELDER_2	; Branch If He Doesn't

	LOADOBJ	B_MOVABLE	; Check If Fielder Movable
 	JUMPEQU	FIELDER_9	; Branch If He Doesn't

	LOADOBJ	B_HASBALL	; Check If Fielder Has The Ball
 	JUMPEQU	FIELDER_2	; Branch If He Doesn't
	LOAD	BUTTONS
	MASKME	FIELDER_0	; RAD 5/5/96
	ANYBITS	FIRSTBASE,ThrowToF
	ANYBITS	SECONDBASE,ThrowToS
	ANYBITS	THIRDBASE,ThrowToT
	ANYBITS	HOMEPLATE,ThrowToH
	DONE

	.import	RunToF,RunToS,RunToT,RunToH	; RAD 5/5/96
FIELDER_0:			; RAD 5/5/96
	ANYBITS	FIRSTBASE,RunToF	; RAD 5/5/96
	ANYBITS	SECONDBASE,RunToS	; RAD 5/5/96
	ANYBITS	THIRDBASE,RunToT	; RAD 5/5/96	
	ANYBITS	HOMEPLATE,RunToH	; RAD 5/5/96
	DONE

FIELDER_1:
	LOAD	BUTTONS
;	SYSTEM	BRITRAP
	ANYBITS	HOMEPLATE,AntiLaser	;DiveTumble
;	ANYBITS	FIRSTBASE,DoDive	;DiveBall         
	ANYBITS	SECONDBASE,PowerJump	;DiveBall         
	ANYBITS	THIRDBASE,PowerJump3	;DiveBall         
;	ANYBITS	STARTBASE,StartButtonSnd
	DONE

FIELDER_2:
	IFPOWERUP	FIELDER_1
	LOAD	BUTTONS
	ANYBITS	HOMEPLATE,SwitchFielder
	ANYBITS	FIRSTBASE,SwitchFielder
	ANYBITS	SECONDBASE,SwitchFielder
	ANYBITS	THIRDBASE,SwitchFielder
FIELDER_9:
	DONE

;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DONE

	
SpeedUp1:
	SETRAMW	DURATIONRESET,1	; Set For 60HZ Anim
	SETRAMW	DURATION,1	; Set For 60HZ Anim
	QED

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PlayerInit:
	SETGRAV	0xF0
	SEMCLR	PitchIt
	QED
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;	SYSTEM	CLRSWING	; Clear some Variables
PlayerIntro: 
	INPUTSUB	BATTER_NOCONTROLS
	EXECUTE	PlayerInit        	;Init Players
	CLRFLIP
	SYSTEM	ClearPower	;Clear Power Ups
	SYSTEM	ClearTracks	;Clear Track Balls
	SYSTEM	CheckBases	;check who's on base
	SYSTEM	ScoreObj	;Call Score Board and B_Card
	SYSTEM	PitcherTag	;Set Tag over pitcher head
  ;      	SOUNDS	AmbCrowdKill	;Kill the crowd
        	SOUNDS	Crowd1	;cheer batter
;	SYSTEM	ChangeApperance1	;Change batter appearance
 ;	SOUNDS	BatterUpOrgan	;Do Batter Organ
	SYSTEM	DoBatterName	;Announce batter
	SEMCLR	BatterReady	;Ready to swing
	SEMCLR	PowerBallPal	;Ready to swing
	SEMCLR	Steal2nd	;Clear Stealing
	SEMCLR	Steal3rd	;Clear Stealing
	SYSTEM	CheckSwing	;Checks for Lefty or Righty
;***********************************************	;From here jumps to NewBatter
			;R or L

NewBatterR:  		;Right Handed batter walk in
	SYSTEM	DoHeadPalette	;Check Palette for Head
	SYSTEM	DoSkinPalette	;Change Skin Palette

	SETRAMW	XPOSITION,92	;Set Starting Location
	SETRAMW	YPOSITION,236
	CLRFLIP

;     	LOADABS	BatWalk
;     	JUMPCMP	0,SkipWalkIn

	JUMP	SkipWalkIn	
	SETRAMW	XPOSITION,-80	;Set Starting Location
	SETRAMW	YPOSITION,236
WalkIn: 			;Walk in From left Side
;	SYSTEM    ClrTrk
     ;	SPRITE	b04a01,5
     ;	SPRITE	b04a02,5
     ;	SPRITE	b04a03,5
     ;	SPRITE	b04a04,5
	MOVE	30,0
	MOVE	23,0
	CLRFLIP
;	SPRITE1	b01a02,8
;         	MOVE	22,-4
   ;art      	SPRITE1	b01a03,8
   ;      	MOVE	10,-1
   ;      	SPRITE1	b01a04,8
   ;      	MOVE	19,2
   ;      	SPRITE1	b01a05,8
   ;      	MOVE	19,1
   ;      	SPRITE1	b01a06,8
   ;      	MOVE	11,0
   ;      	SPRITE1	b01a07,8
   ;	SPRITE1	b01a01,8
   ;      	MOVE	23,2
   ;      	SPRITE1	b01a02,8
   ;      	MOVE	22,-4
   ;      	SPRITE1	b01a03,8
   ;      	MOVE	10,-1
   ;      	SPRITE1	b01a04,8
   ;      	MOVE	19,2
   ;      	SPRITE1	b01a05,8
;  ;       	MOVE	19,1
;  ;       	SPRITE1	b01a06,8
;  ;       	MOVE	11,0
;  ;       	SPRITE1	b01a07,8
;   	SPRITE1	b12a02,8
;         	SPRITE1	b12a03,8
EndOfWalkIn:
   	SYSTEM	CheckWI	;Check to see if Walking in
	QED


NewBatterL:  ;Left Handed BAtter Walkk in
	SYSTEM	DoHeadPalette
	SYSTEM	DoSkinPalette	;Change Skin Palette


	SETRAMW	XPOSITION,280	;Set Starting Location
	SETRAMW	YPOSITION,236
	SETFLIP		;Flip anim for Righty

;     	LOADABS	BatWalk
;     	JUMPCMP	0,SkipWalkOut

	JUMP	SkipWalkOut	
	SETRAMW	XPOSITION,535	;Set to outside screen.
	SETRAMW	YPOSITION,236

WalkOut: ;From Right side
;	SYSTEM    ClrTrk
      ;	SPRITE	b04a01,5
      ;	SPRITE	b04a02,5
      ;	SPRITE	b04a03,5
      ;	SPRITE	b04a04,5
	SETFLIP		;Flip anim for Righty
  ;	SPRITE	b04a05,5
     ;	MOVE	0,2
  ;	SPRITE	b04a06,5
      ;	MOVE	0,2
  ;	SPRITE	b04a07,5
	SETFLIP		;Flip anim for Lefty
       ;	MOVE	-27,-4
	MOVE	-30,0
;art       	SPRITE1	b01a07,6
;art       	MOVE	-10,0
;art   	SPRITE1	b01a01,8
;art        	MOVE	-23,2
;art         	SPRITE1	b01a02,8
;art         	MOVE	-22,-4
;art         	SPRITE1	b01a03,8
;art          	MOVE	-10,-1 
;art         	SPRITE1	b01a04,8
;art         	MOVE	-19,2
;art         	SPRITE1	b01a05,8
;art         	MOVE	-19,1
;art         	SPRITE1	b01a06,8
;art         	MOVE	-11,0
;art         	SPRITE1	b01a07,8
;art         	MOVE	-10,0
;art   	SPRITE1	b01a01,8
;art         	MOVE	-23,2
;art         	SPRITE1	b01a02,8
;art         	MOVE	-22,-4
;art         	SPRITE1	b01a03,8
;art         	MOVE	-10,-1
;art         	SPRITE1	b01a04,8
;art         	MOVE	-19,2
;art         	SPRITE1	b01a05,8
;art         	MOVE	-19,1
;art         	SPRITE1	b01a06,8
;art         	MOVE	-11,2
;art         	SPRITE1	b01a07,8
;art
;art;    	SPRITE1	b01a01,8
;art;         	MOVE	-23,3
;art;         	SPRITE1	b01a02,6
;art;         	MOVE	-22,-4
;art
EndOfWalkOut:
    	SYSTEM	CheckWO	;Check Walk out if Walking in.
	STOPANIM
	QED

LookBefore:
SkipWalkIn:
SkipWalkOut:

	SYSTEM	ClearObjPtrs
	SEMCLR	BatWalk	
	LASTFRAME	25
	INPUTSUB	BATTER_SKIP
;obe	SPRITE1	b35e01,6
;	SPRITE1	b35e02,6
;	SPRITE1	b35e03,8
;	SPRITE1	b35e04,95
;	SPRITE1	b35e03,8
;	SPRITE1	b35e02,6
;	SPRITE1	b35e01,6

Standing:	 	;Randomly do stuff after walk in and inbetween swings
;	JUMP	Fight 	;Skip junk for now...bri
	SYSTEM	BatterTag
	SEMCLR	BatterReady
	INPUTSUB	BATTER_SKIP
;	JUMP	TapBat

	JUMPRND	7
	ADDRESS	PrSwing
	ADDRESS	TapShoe	;waveback
;	ADDRESS	KickDirt
	ADDRESS	TapShoe	;Tap Shoe
	ADDRESS	PrSwing
	ADDRESS	TapBat
	ADDRESS	TapBat
	ADDRESS	TapBat
	ADDRESS	WaveBack
;	ADDRESS	KickDirt
	
;	
;	JUMPRND	14	;in of after a swing.
;	ADDRESS	Fight
;	ADDRESS	Fight
;	ADDRESS	TapBat
;	ADDRESS	PrSwing	;waveback
;	ADDRESS	PrSwing
;	ADDRESS	GrabSpit
;	ADDRESS	KickDirt
;	ADDRESS	KickDirt
;	ADDRESS	TapShoe	;Tap Shoe
;	ADDRESS	TapShoe
;	ADDRESS	PrSwing	;TapBat
;	ADDRESS	Fight
;	ADDRESS	PrSwing
;	ADDRESS	WaveBack
;	ADDRESS	TapShoe
;

TapShoe:			;Tap Shoe's with bat
	SOUNDS	ScratchFootInDirt
	SPRITE1	b08a01,6
	SPRITE1	b08a02,6
	SPRITE1	b08a03,3
	SPRITE1	b08a04,3
	SPRITE1	b08a05,6
	SOUNDS	ScratchFootInDirt
	SPRITE1	b08a01,6
	SPRITE1	b08a02,6
	SPRITE1	b08a03,4
	SPRITE1	b08a04,4
	SPRITE1	b08a05,6
	SPRITE1	b08a06,6
	SPRITE1	b08a07,6
	SPRITE1	b08a08,6
	SPRITE1	b08a09,6
	JUMP	Fight

	
TapBat:			; Tap the Plate with the bat
	SPRITE1	b06a01,6
	SPRITE1	b06a02,6
	SPRITE1	b06a03,6
	SPRITE1	b06a04,6
	SOUNDS	BatTapsPlate
	SPRITE1	b06a05,15
	SPRITE1	b06a06,6
	SOUNDS	BatTapsPlate
	SPRITE1	b06a07,6
	SPRITE1	b06a08,6
	SPRITE1	b06a09,6
	SPRITE1	b06a10,6
	SPRITE1	b06a11,6
   	JUMP	Fight

WaveBack:		                      	;Waves Fielders Back
	SPRITE	b54a01,5
	SPRITE	b54a02,5
	SPRITE	b54a03,6
	SPRITE	b54a04,7
	SPRITE	b54a05,11
	SPRITE	b54a04,6
	SPRITE	b54a03,6
	SPRITE	b54a04,6
	SPRITE	b54a05,11
	SPRITE	b54a04,6
	SPRITE	b54a03,6
	SPRITE	b54a04,6
	SPRITE	b54a05,11
	SPRITE	b54a04,6
	SPRITE	b54a03,6
	SPRITE	b54a02,6
	SPRITE	b54a01,6
	SPRITE	b14a13,6
	SPRITE	b14a14,6
	SPRITE	b14a15,6
	SPRITE	b14a16,6
 	
	JUMP	Fight

KickDirt:			;Begin Dirt Kick
	SOUNDS	ScratchFootInDirt
;	SPRITE1	b12a03,8 ;bri added
;	SPRITE1	b12a02,8 ;bri added
;	SPRITE1	b07a01,6
;	SPRITE1	b07a02,6
;	SPRITE1	b07a03,10;6
;	SOUNDS	ScratchFootInDirt
;	SPRITE1	b07a04,10;8
;	SPRITE1	b07a05,8;6
;	SPRITE1	b07a06,10;6
;	SPRITE1	b07a07,10;6
;	SPRITE1	b07a08,10;6
;	SOUNDS	ScratchFootInDirt
;	SPRITE1	b07a09,10;8
;	SPRITE1	b07a08,8;6
;	SPRITE1	b07a07,8;6
;	SPRITE1	b07a06,8;6
;	SPRITE1	b12a02,8 ;bri added
;	SPRITE1	b12a03,8 ;bri added
	JUMP	Fight

PrSwing:   		;Practice Low Swing
           SPRITE1	b14a01,5
           SPRITE1	b14a02,5
           SPRITE1	b14a03,5
           SPRITE1	b14a04,5
	SOUNDS	SwingBat
           SPRITE1	b14a05,5
           SPRITE1	b14a06,5
           SPRITE1	b14a07,5
           SPRITE1	b14a08,5
           SPRITE1	b14a09,5
           SPRITE1	b14a10,5
           SPRITE1	b14a11,5
           SPRITE1	b14a12,5
           SPRITE1	b14a13,5
           SPRITE1	b14a14,5
           SPRITE1	b14a15,5
           SPRITE1	b14a16,5
           JUMP	Fight

GrabSpit:			;Grab and Spit
;	SOUNDS	PitcherSpits
;obe	SPRITE1	b35e01,6
;	SPRITE1	b35e02,6
;	SPRITE1	b35e03,6
;	SPRITE1	b35e04,6
;	SPRITE1	b35e05,6
;	SPRITE1	b35e06,6
;	SPRITE1	b35e07,6
;	SPRITE1	b35e08,6
;	SOUNDS	GrabCrotch
;	SPRITE1	b35e09,6
;	SPRITE1	b35e10,6
;	SPRITE1	b35e11,6
;	SPRITE1	b35e12,6
;	SPRITE1	b35e11,6 ;bri added frame
;	SPRITE1	b35e13,6
;	SPRITE1	b35e14,6
;	SPRITE1	b35e15,6
;	SPRITE1	b35e16,6
;	SPRITE1	b35e17,6
   	JUMP	Fight

WatchBall:			; If he didn't swing
	SPRITE	bx6a01,4
	SPRITE	bx6a02,4
	SPRITE	bx6a03,4
	SPRITE	bx6a04,4
	SPRITE	bx6a05,30
	SPRITE	bx6a04,6
	SPRITE	bx6a03,6
	SPRITE	bx6a02,6
	SPRITE	bx6a01,6
	
      ;	SPRITE	bx6a06,6
      ;	SPRITE	bx6a07,6
      ;	SPRITE	bx6a08,6
      ;	SPRITE	bx6a09,6
	JUMP	Fight

StartButtonSnd:
	SOUNDS	CrowdBoo1
	QED



Disapoint:			; Random Disapointment
BackFromOut:		; After Strike out
	SEMCLR	BatterReady
	SEMSET	BatWalk
;	JUMP	SlamBat_2
	JUMPRND	3
	ADDRESS	Angry_1
	ADDRESS	Angry_2
	ADDRESS	Angry_2
;art	ADDRESS	SlamBat_2
	ADDRESS	ENDDIS


DISAP1:	SPRITE2	b33e05,6          	;Hit Head on bat
  	SYSTEM	No_Moving
	SPRITE2	b33e06,6
	SPRITE2	b33e08,6
	SPRITE2	b33e09,6
	SOUNDS	BatTapsPlate
	SPRITE2	b33e10,9
	SPRITE2	b33e09,9
	SPRITE2	b33e08,6
	SPRITE2	b33e09,6
	SOUNDS	BatTapsPlate
	SPRITE2	b33e10,9
	SPRITE2	b33e09,6
	SPRITE2	b33e08,6
	SPRITE2	b33e07,6
	SPRITE2	b33e06,6
	SPRITE2	b33e05,6
;	SPRITE2	b33e04,6
;	SPRITE2	b33e03,6
;	SPRITE2	b33e02,6
;	SPRITE2	b33e01,6
	JUMP	ENDDIS

;DISAP2:			;Break Bat  over knee
;  art	SPRITE	b55e01,5
;	SPRITE	b55e02,5
;	SPRITE	b55e03,6
;	SPRITE	b55e04,6
;	SPRITE	b55e05,6
;	SPRITE	b55e06,6
;	SOUNDS	BreakBat
;	SPRITE	b55e07,5
 ;	JUMP	ENDDIS

DISAP3:			;Slam Bat
;	JUMP	SlamBat_2
;art	SPRITE	b56e01,5
;	SPRITE	b56e02,5
;	SPRITE	b56e03,5
;	SPRITE	b56e04,4
;	SPRITE	b56e05,3
;	SPRITE	b56e06,3
;	SOUNDS	BatTapsPlate
;	SPRITE	b56e07,5
;	SPRITE	b56e06,5
;	SPRITE	b56e05,5
;	SPRITE	b56e04,6
;	SPRITE	b56e03,5
;	SPRITE	b56e04,4
;	SPRITE	b56e05,3
;	SPRITE	b56e06,3
;	SPRITE	b56e07,10
;	SPRITE	b56e06,5
;	SPRITE	b56e05,5
;	SPRITE	b56e04,5
;	SPRITE	b56e03,5
;	SPRITE	b56e02,5
;	SPRITE	b56e01,10
;	JUMP	ENDDIS

	
;SlamBat_2:			;Slams bat onto ground
;art	SPRITE	bn8a01,5
;	SPRITE	bn8a02,5
;	SPRITE	bn8a03,5
;	SPRITE	bn8a04,5
;	SPRITE	bn8a05,3
;	SPRITE	bn8a06,3
;	SPRITE	bn8a07,3
;;	SOUNDS	BatTapsPlate
;	SOUNDS	BatSmacksPlate
;	SPRITE	bn8a08,6
;	SPRITE	bn8a09,4
;	SPRITE	bn8a10,5
;	SPRITE	bn8a11,5
;	SPRITE	bn8a12,5
;	SPRITE	bn8a13,5
;	SPRITE	bn8a14,5
;	SPRITE	bn8a15,5
;	JUMP	ENDDIS


Angry_1:			;Slap Bat
	SPRITE	bnoa01,5
	SPRITE	bnoa02,5
	SPRITE	bnoa03,6
	SPRITE	bnoa04,7
	SPRITE	bnoa03,6
	SPRITE	bnoa02,5
	SPRITE	bnoa01,5

;	SPRITE	bnoa05,3
;	SPRITE	bnoa06,3
;	SPRITE	bnoa07,3
;	SPRITE	bnoa08,5
;	SPRITE	bnoa09,4
;	SPRITE	bnoa10,5
;;	SPRITE	bnoa11,5
;	SPRITE	bnoa12,5
;	SPRITE	bnoa13,5
;	SPRITE	bnoa14,5
;	SPRITE	bnoa15,5
;	SPRITE	bnoa16,5
;	SPRITE	bnoa17,5
	JUMP	ENDDIS

Angry_2:			;Shoot Bat
	SPRITE	bnqa01,5
	SPRITE	bnqa02,5
	SPRITE	bnqa03,5
	SPRITE	bnqa04,5
	SPRITE	bnqa05,5
	SPRITE	bnqa06,5
	SPRITE	bnqa07,5
	SPRITE	bnqa08,5
	SPRITE	bnqa09,4
	SPRITE	bnqa10,5
	SPRITE	bnqa11,5
	SPRITE	bnqa06,5
	SPRITE	bnqa05,5
	SPRITE	bnqa04,5
	SPRITE	bnqa03,5
	SPRITE	bnqa02,5
	SPRITE	bnqa01,5

;	SPRITE	bnqa12,5
;	SPRITE	bnqa13,5
;	SPRITE	bnqa14,5
;	SPRITE	bnqa15,5
	JUMP	ENDDIS

Angry_3:			;Kick dirt at Ump
;	SPRITE	bnwa01,5
;	SPRITE	bnwa02,5
;	SPRITE	bnwa03,5
;	SPRITE	bnwa04,5
;	SPRITE	bnwa05,3
;	SPRITE	bnwa06,3
;	SPRITE	bnwa07,3
;	SPRITE	bnwa08,5	      
;	SPRITE	bnwa09,4
	JUMP	ENDDIS

	
Angry_4:			;Too much time
;art	SPRITE	bxba01,5
;art	SPRITE	bxba02,5
;art	SPRITE	bxba03,5
;art	SPRITE	bxba04,5
;art	SPRITE	bxba05,3
;art	SPRITE	bxba06,3
;art	SPRITE	bxba07,3
;art	SPRITE	bxba08,5
;art	SPRITE	bxba09,4
;art	SPRITE	bxba10,5
;art	SPRITE	bxba11,5
;art	SPRITE	bxba12,5
;art	SPRITE	bxba13,5
;art	SPRITE	bxba14,5
;art	SPRITE	bxba15,5
;art	JUMP	ENDDIS


Angry_5:			;Kick Dirt Down
	SPRITE	bxca01,5
	SPRITE	bxca02,5
	SPRITE	bxca03,5
	SPRITE	bxca04,7
	SOUNDS	ScratchFootInDirt
	SPRITE	bxca05,15
	SPRITE	bxca04,9
	SPRITE	bxca05,15
	SPRITE	bxca06,5
	SPRITE	bxca07,5
	SPRITE	bxca08,5
	SPRITE	bxca09,4
	JUMP	ENDDIS

ENDDIS:			; End of Disapointment
	SYSTEM	CheckWalk	;Check which way to walk
;bri to speed up
    ;	SPRITE	bn6a01,6
    ;	SPRITE	bn6a02,6
    ;	SPRITE	bn6a03,6
    ;	SPRITE	bn6a04,6
    ;	SPRITE	bn6a05,6
    ;	SPRITE	bn6a06,6
    ;	SPRITE	bn6a07,6
   ;	SPRITE	bn6a08,6
   ;	SPRITE	bn6a09,6
   ;	SPRITE	bn6a10,6
	SYSTEM	CheckWalk	;Check which way to walk
	JUMP	WalkOut	;Walkout


	
	.export	BeanBatter
BeanBatter:		; Bean Ball Batter
	SOUNDS	CrowdBoo2
	SOUNDS	S_BeanBall
	SOUNDS	BeanBallSpeech
	SPRITE	ben101,3
	SPRITE	ben102,4
	SPRITE	ben103,5
	SPRITE	ben104,5
	SPRITE	ben105,4
	SPRITE	ben106,4
	SPRITE	ben107,4
	SYSTEM	TakeObj
	SPRITE	ben108,80
	SYSTEM	GiveHimFirst
	SYSTEM	CheckWalk	;Check which way to walk
	STOPANIM

BNothing:			;Called when doing nothing
Fight: 			;Just Standing
	SEMCLR	ForcedOut	; Clear Forced Out Condition
	LOADABS	didwiff
	JUMPCMP	1,DoNewBat
	SEMSET	BatterReady
	SYSTEM	GiveControlsToBatter
Fight2:	SYSTEM	ClrTrk	;This is the basic batter
;	SYSTEM	ChangeApperance2
;	SYSTEM	CheckBases
;	SYSTEM	GiveControlsToBatter
	SYSTEM	NoSwing
	ALWAYS	CheckTrackBall	;stand. Keep calling.
  	SPRITE	bn2a07,7
  	SPRITE	bn2a08,7
  	SPRITE	bn2a09,7
  	SPRITE	bn2a10,7
  	SPRITE	bn2a11,7
  	SPRITE	bn2a12,7
  	SPRITE	bn2a11,7
  	SPRITE	bn2a10,7
  	SPRITE	bn2a09,7
  	SPRITE	bn2a08,7
	
;	SPRITE	b12a12,7
;	SPRITE	b12a11,7
;	SPRITE	b12a10,7
;	SPRITE	b12a09,7
;	SPRITE	b12a08,7
;	SPRITE	b12a07,7
;	SPRITE	b12a06,7
;	SPRITE	b12a05,7
	JUMP	Fight2
DoNewBat:
	SYSTEM	NewBatter1
	QED


VintageLoop:
	SYSTEM	NoSwing
	ALWAYS	CheckTrackBall	;stand. Keep calling.
	SPRITE1	v14e01,6
	SPRITE1	v14e01,6
	JUMP	VintageLoop


StepFrom:			;Step Away from the plate
;	SPRITE1	b12a05,1
;	MOVE	-5,0

	SPRITE	bx9a08,2
	SPRITE	bx9a07,2
	MOVE	-3,0
	SPRITE	bx9a06,2
	MOVE	-3,0
	SPRITE	bx9a05,2
	MOVE	-3,0
	SPRITE	bx9a04,2
	MOVE	-3,0
	SPRITE	bx9a03,2
	MOVE	-3,0
	SPRITE	bx9a02,2
	MOVE	-3,0
	SPRITE	bx9a01,2
	MOVE	-3,0
	
	
	
	
;	SPRITE1	b09c08,1
;	MOVE	-2,-1
;	SPRITE1	b09c07,1
;	MOVE	-2,0
;	SPRITE1	b09c06,1
;	MOVE	-4,0
;	SPRITE1	b09c05,1
;	MOVE	-4,0
;	SPRITE1	b09c04,1
;	MOVE	-4,1
;	SPRITE1	b09c03,1
;	MOVE	-2,-2
;	SPRITE1	b09c02,1
;	MOVE	-6,2
;art	SPRITE1	b12a05,1

	JUMP	Fight


StepF2:			;Step away from the plate
;	SPRITE1	b12a05,1	;From left side
;	MOVE	5,0
	SPRITE	bx9a08,2
	SPRITE	bx9a07,2
	MOVE	3,0
	SPRITE	bx9a06,2
	MOVE	3,0
	SPRITE	bx9a05,2
	MOVE	3,0
	SPRITE	bx9a04,2
	MOVE	3,0
	SPRITE	bx9a03,2
	MOVE	3,0
	SPRITE	bx9a02,2
	MOVE	3,0
	SPRITE	bx9a01,2
	MOVE	3,0
	
	
;	SPRITE1	b09c08,1
;	MOVE	2,-1
;	SPRITE1	b09c07,1
;	MOVE	2,0
;	SPRITE1	b09c06,1
;	MOVE	4,0
;	SPRITE1	b09c05,1
;	MOVE	4,0
;	SPRITE1	b09c04,1
;	MOVE	4,1
;	SPRITE1	b09c03,1
;	MOVE	2,-2
;	SPRITE1	b09c02,1
;	MOVE	6,2
;art	SPRITE1	b12a05,1

	JUMP	Fight

StepTo:			;Step to the plate

	SPRITE	bx9a01,2
	SPRITE	bx9a02,2
	MOVE	3,0
	SPRITE	bx9a03,2
	MOVE	3,0
	SPRITE	bx9a04,2
	MOVE	3,0
	SPRITE	bx9a05,2
	MOVE	3,0
	SPRITE	bx9a06,2
	MOVE	3,0
	SPRITE	bx9a07,2
	MOVE	3,0
  	SPRITE	bx9a08,2
	MOVE	3,0


;	SPRITE1	b12a05,1
;	MOVE	6,-2
;	SPRITE1	b09c02,1
;	MOVE	2,2
;	SPRITE1	b09c03,1
;	SPRITE1	b09c04,1
;	MOVE	4,0
;	SPRITE1	b09c05,1
;	MOVE  	4,0
;	SPRITE1	b09c06,1
;	MOVE	2,0
;	SPRITE1	b09c07,1
;	MOVE	2,1
;	SPRITE1	b09c08,1
;	MOVE	5,0
;art	SPRITE1	b12a05,1
	JUMP	Fight

StepT2:			;Step to the plate from left

	SPRITE	bx9a01,2
	SPRITE	bx9a02,2
   	MOVE	-3,0
	SPRITE	bx9a03,2
   	MOVE	-3,0
	SPRITE	bx9a04,2
   	MOVE	-3,0
	SPRITE	bx9a05,2
   	MOVE	-3,0
	SPRITE	bx9a06,2
   	MOVE	-3,0
	SPRITE	bx9a07,2
   	MOVE	-3,0
	SPRITE	bx9a08,2
   	MOVE	-3,0


;	SPRITE1	b12a05,1
;	MOVE	-6,-2
;	SPRITE1	b09c02,1
;	MOVE	-2,2
;	SPRITE1	b09c03,1
;	MOVE	-4,-1
;	SPRITE1	b09c05,3
;	SPRITE1	b09c04,1
;	MOVE	-4,0
;	SPRITE1	b09c05,1
;	MOVE  	-4,0
;	SPRITE1	b09c06,1
;	MOVE	-2,0
;	SPRITE1	b09c07,1
;	MOVE	-2,1
;	SPRITE1	b09c08,1
;	MOVE	-5,0
;art	SPRITE1	b12a05,1
	JUMP	Fight
SStepTo:
	SYSTEM	XStepTo
	SYSTEM	GiveWalkToBatter
	QED
SStepFrom:
	SYSTEM	XStepFrom
	SYSTEM	GiveWalkToBatter

	QED




AddToFButton:
	SYSTEM	AddToFirst
;	SYSTEM	GiveControlsToBatter
         ;	SYSTEM	GiveCounterToBatter
	QED
SubToFButton:
	SYSTEM	SubToFirst
;	SYSTEM	GiveCounterToBatter
         ;	SYSTEM	GiveControlsToBatter
	QED
      
AddToTButton:
	SYSTEM	AddToThird
         ;	SYSTEM	GiveControlsToBatter
	QED
SubToTButton:
	SYSTEM	SubToThird
         ;	SYSTEM	GiveControlsToBatter
	QED

	
PLightSabre:
	SYSTEM	PLight
	SYSTEM	GiveControlsToBatter
	QED
PKarate:
	SYSTEM	PKarateS
	SYSTEM	GiveControlsToBatter
	QED

GiveFullPower:
	SYSTEM	PGive
	SYSTEM	GiveControlsToBatter
	QED


POneArm:
	SYSTEM	POneArmS
	SYSTEM	GiveControlsToBatter
	QED

PGrabNHit:
	SYSTEM	PGrabNHitIt
	SYSTEM	GiveControlsToBatter
	QED

	

PPinch:
	SYSTEM	PPinchHit
	SYSTEM	GiveControlsToBatter
	QED

AntiLaser:
	SYSTEM	PAntiLaser
	SYSTEM	GiveControlsToFielder
	QED

	
UnderPitch:
	SYSTEM	PUnderPitch
	INPUTSUB	PITCHER_CONTROLS
	QED
VintagePitch:
	SYSTEM	PVintagePitch
	INPUTSUB	PITCHER_CONTROLS
	QED
TornadoPitch:
	SYSTEM	PTornadoPitch
	INPUTSUB	PITCHER_CONTROLS
	QED
BeanBall:
	SYSTEM	PBeanBall
	INPUTSUB	PITCHER_CONTROLS
	QED

;ZoneUp:		
;	SYSTEM	MoveZoneUp            
;	INPUTSUB	BATTER_SWING
;	ALWAYS	CheckTrackBall	;stand. Keep calling.
;        	QED

;ZoneDown:
;	SYSTEM	MoveZoneDown	
;	INPUTSUB	BATTER_SWING
;	ALWAYS	CheckTrackBall	;stand. Keep calling.
;        	QED

LowSwing:
	SETMEM	BatHeight,0	; Set For Low Swing
	SYSTEM	YesSwing
	SPRITE1	blsa01,1
	TRACKBALL	Fight 
	SPRITE1	blsa02,1
	TRACKBALL	-1
	SPRITE1	blsa03,1
	TRACKBALL	-1
	SPRITE1	blsa04,1
	TRACKBALL	-1
	SPRITE1	blsa05,1
	TRACKBALL	-1
	SPRITE1	blsa06,1
	TRACKBALL	-1
	SPRITE1	blsa07,1
	TRACKBALL	-1
	SPRITE1	blsa08,1
	TRACKBALL	-1
	SPRITE1	blsa09,1
	TRACKBALL	-1
	SPRITE1	blsa10,1
	TRACKBALL	-1
LowSwing1:
	SPRITE1	blsa11,1
	TRACKBALL	-1
	LOADABS	CanSwing
     	JUMPCMP	0,LowSwing1
	SYSTEM	SaveTrack
	SYSTEM	YesSwing
	SPRITE1	blsa12,1
	TRACKBALL	LowSwing1
	SPRITE1	blsa13,1
;	TRACKBALL	-1
	SPRITE1	blsa14,1
	SOUNDS	SwingBat
	VSPRITE	blsa15,10
	VSPRITE	blsa16,10
	VSPRITE	blsa17,10
	VSPRITE	blsa18,10
	VSPRITE	blsa19,10
	VSPRITE	blsa20,10
	VSPRITE	blsa21,10
	VSPRITE	blsa22,10
	VSPRITE	blsa23,10
	SPRITE	blsa24,5
	SPRITE	blsa25,5
	SPRITE	blsa26,5
	SPRITE blsa25,2
	SPRITE blsa24,2
	SPRITE blsa29,2
	SPRITE blsa30,2
	SPRITE blsa31,2
	SPRITE blsa32,2
	SPRITE bmsa33,2
	SPRITE bmsa34,2
	SPRITE bmsa35,2
	SPRITE bmsa36,2
	SPRITE bmsa37,2
	SPRITE bmsa38,2
	SPRITE bmsa39,2



;	JUMP	Standing
	JUMP	Fight



LowMidSwing:
	SETMEM	BatHeight,0	; Set For Low Swing
;;	SPRITE1	b27e01,1
;;	TRACKBALL	Fight
;;	SPRITE1	b27e02,1
;;	TRACKBALL	-1
;	SPRITE1	b27e03,1
	TRACKBALL	Fight
;	SPRITE1	b27e04,1
	TRACKBALL	-1
;	SPRITE1	b27e05,1
	TRACKBALL	-1
;	SPRITE1	b27e06,1
	TRACKBALL	-1
;	SPRITE1	b27e07,1
	TRACKBALL	-1
;	SPRITE1	b27e08,1
	TRACKBALL	-1     
LowMid1:
;	SPRITE1	b27e09,1
	TRACKBALL	-1
	SYSTEM	SaveTrack
	SYSTEM	YesSwing
;           SPRITE1	b27e10,1
	TRACKBALL	LowMid1
;	SPRITE1	b27e11,1
;	TRACKBALL	-1
;	SPRITE1	b27e12,1
;	TRACKBALL	-1
;	SPRITE1	b27e13,1
;	SYSTEM	NoPitcherControls

	SOUNDS	SwingBat
;	JUMP	WIFF
;	VSPRITE	b27e14,15
;	VSPRITE	b27e15,15
;	VSPRITE	b27e16,15
;	VSPRITE	b27e17,15
;	VSPRITE	b27e18,15
;	VSPRITE	b27e19,15
;	VSPRITE	b27e20,15
;	VSPRITE	b27e21,15
;	VSPRITE	b27e22,15
;	VSPRITE	b27e23,15
;	SPRITE1	b27e24,30
           JUMP	BatterReturn

WIFF:
;art	SYSTEM	DirtObj
;	SYSTEM	BATTERCLIP
;art	SYSTEM	YesWiff
;art	SOUNDS	BatterSpins
;art	SPRITE	b71e01,0
;art	SPRITE	b71e02,0
;art	SPRITE	b71e03,0
;art	SPRITE	b71e04,0
;art	SPRITE	b71e05,0
;art	SPRITE	b71e06,0
;art	SPRITE	b71e07,0
;art	SPRITE	b71e08,0
;art	SPRITE	b71e01,0
;art	SPRITE	b71e02,0
;art	SPRITE	b71e03,0
;art	SPRITE	b71e04,0
;art	SPRITE	b71e05,0
;art	SYSTEM	RockObj
;art	SPRITE	b71e06,0
;art	MOVE	0,2
;art	SPRITE	b71e07,0
;art	MOVE	0,2
;art	SPRITE	b71e08,0
;art	MOVE	0,2
;art	SPRITE	b71e01,0
;art	MOVE	0,2
;art	SPRITE	b71e02,0
;art	MOVE	0,2
;art	SPRITE	b71e03,0
;art	MOVE	0,2
;art	SPRITE	b71e04,0
;art	MOVE	0,2
;art	SPRITE	b71e05,0
;art	MOVE	0,2
;art	SYSTEM	RockObj
;art	SPRITE	b71e06,0
;art	MOVE	0,2
;art	SPRITE	b71e07,0
;art	MOVE	0,2
;art	SPRITE	b71e08,0
;art	MOVE	0,2
;art	SPRITE	b71e01,0
;art	MOVE	0,2
;art	SPRITE	b71e02,0
;art	MOVE	0,2
;art	SPRITE	b71e03,0
;art	MOVE	0,2
;art	SPRITE	b71e04,0
;art	MOVE	0,2
;art	SPRITE	b71e05,0
;art	MOVE	0,2
;art	SPRITE	b71e06,0
;art	MOVE	0,2
;art	SPRITE	b71e07,0
;art	MOVE	0,2
;art	SPRITE	b71e08,0
;art	MOVE	0,2
;art	SYSTEM	RockObj
;art           SPRITE	b71e01,0
;art	MOVE	0,2
;art	SPRITE	b71e02,0
;art	MOVE	0,2
;art	SPRITE	b71e03,0
;art	MOVE	0,2
;art	SYSTEM	RockObj
;art	SPRITE	b71e04,0
;art	MOVE	0,2
;art	SPRITE	b71e05,0
;art	MOVE	0,2
;art	SPRITE	b71e06,0
;art	MOVE	0,2
;art	SPRITE	b71e07,0
;art	MOVE	0,2
;art	SPRITE	b71e08,0
;art	MOVE	0,2
;art           SPRITE	b71e01,0
;art	MOVE	0,2
;art	SPRITE	b71e02,0
;art	MOVE	0,2
;art	SYSTEM	RockObj
;art	SPRITE	b71e03,0
;art	MOVE	0,2
;art	SPRITE	b71e04,0
;art	MOVE	0,2
;art	SPRITE	b71e05,0
;art	MOVE	0,2
;art	SPRITE	b71e06,0
;art	MOVE	0,2
;art	SPRITE	b71e07,0
;art	MOVE	0,2
;art	SPRITE	b71e08,0
;art	MOVE	0,2
;art           SPRITE	b71e01,0
;art	MOVE	0,2
;art	SPRITE	b71e02,0
;art	MOVE	0,2
;art	SPRITE	b71e03,0
;art	MOVE	0,2
;art	SPRITE	b71e04,0
;art	SYSTEM	RockObj
;art	MOVE	0,2
;art	SPRITE	b71e05,0
;art	MOVE	0,2
;art	SPRITE	b71e06,0
;art	MOVE	0,2
;art	SPRITE	b71e07,0
;art	MOVE	0,2
;art	SPRITE	b71e08,0
;art	MOVE	0,2
;art           SPRITE	b71e01,0
;art	MOVE	0,2
;art	SPRITE	b71e02,0
;art	MOVE	0,2
;art	SPRITE	b71e03,0
;art	MOVE	0,2
;art	SYSTEM	RockObj
;art	SPRITE	b71e04,0
;art	MOVE	0,2
;art	SPRITE	b71e05,0
;art	MOVE	0,2
;art	SPRITE	b71e06,0
;art	MOVE	0,2
;art	SPRITE	b71e07,0
;art	MOVE	0,2
;art	SPRITE	b71e08,0
;art	MOVE	0,2
;art           SPRITE	b71e01,0
;art	MOVE	0,2
;art	SPRITE	b71e02,0
;art	MOVE	0,2
;art	SPRITE	b71e03,0
;art	MOVE	0,2
;art	SPRITE	b71e04,0
;art	MOVE	0,2
;art	SPRITE	b71e05,0
;art	MOVE	0,2
;art	SPRITE	b71e06,0
;art	SYSTEM	RockObj
;art	MOVE	0,2
;art	SPRITE	b71e07,0
;art	MOVE	0,2
;art	SPRITE	b71e08,0
;art	MOVE	0,2
;art	SYSTEM	RockObj
;art	SPRITE	b71e01,0
;art	MOVE	0,2
;art	SPRITE	b71e02,0
;art	MOVE	0,2
;art	SPRITE	b71e03,0
;art	MOVE	0,2
;art	SPRITE	b71e04,0
;art	SYSTEM	RockObj
;art	MOVE	0,2
;art	SPRITE	b71e05,0
;art	MOVE	0,2
;art	SYSTEM	RockObj
;art	SPRITE	b71e06,0
;art	MOVE	0,2
;art	SPRITE	b71e07,0
;art	SYSTEM	RockObj
;art	MOVE	0,2
;art	SPRITE	b71e08,0
;art	MOVE	0,2
;art	SPRITE	b71e01,0
;art	MOVE	0,2
;art	SPRITE	b71e02,0
;art	MOVE	0,2
;art	SPRITE	b71e03,0
;art	MOVE	0,2
;art	SPRITE	b71e04,0
;art	MOVE	0,2
;art	SPRITE	b71e05,0
;art	MOVE	0,2
;art	SYSTEM	RockObj
;art	SPRITE	b71e06,0
;art	MOVE	0,2
;art	SPRITE	b71e07,0
;art	SYSTEM	RockObj
;art	MOVE	0,2
;art	SPRITE	b71e08,0
;art	MOVE	0,2
;art	SPRITE	b71e01,0
;art	MOVE	0,2
;art	SPRITE	b71e02,0
;art	MOVE	0,2
;art	SPRITE	b71e03,0
;art	MOVE	0,2
;art	SYSTEM	RockObj
;art	SPRITE	b71e04,0
;art	MOVE	0,2
;art	SPRITE	b71e05,0
;art	MOVE	0,2
;art	SYSTEM	RockObj
;art	SPRITE	b71e06,0
;art	MOVE	0,2
;art	SPRITE	b71e07,0
;art	SYSTEM	RockObj
;art	MOVE	0,2
;art	SPRITE	b71e08,0
;art	MOVE	0,2
;art	
;art;	SYSTEM	AddStrike
;art;	SYSTEM	AddStrike
;art;	JUMP	BatterReturn
;art	JUMP	PlayerIntro	

MidSwing:
	JUMP	NewMidSwing
	SETMEM	BatHeight,2	; Set Bat Not In Hitting Position
; art	SPRITE1	b28e01,1
;	TRACKBALL	Fight
;        	SPRITE1	b28e02,1
;	TRACKBALL	-1
;	SPRITE1	b28e03,1
;	TRACKBALL	Fight 
;	SPRITE1	b28e04,1
;	TRACKBALL	-1
;	SPRITE1	b28e05,1
;	TRACKBALL	-1
;	SPRITE1	b28e06,1
;	TRACKBALL	-1
;	SPRITE1	b28e07,1
;	TRACKBALL	-1
;	SPRITE1	b28e08,1
;	TRACKBALL	-1
;MidSwing1:
;	SPRITE1	b28e09,1
;	TRACKBALL	-1
;	SYSTEM	SaveTrack
;	SYSTEM	YesSwing
;	SPRITE1	b28e10,1
;	TRACKBALL	MidSwing1
;	SPRITE1	b28e11,1
;	TRACKBALL	-1
;	SPRITE1	b28e12,1
;	TRACKBALL	-1
;	SPRITE1	b28e13,1
;	SYSTEM	NoPitcherControls

	SOUNDS	SwingBat
;	VSPRITE	b28e14,10
;	VSPRITE	b28e15,10
;	VSPRITE	b28e16,10
;	VSPRITE	b28e17,10
;	VSPRITE	b28e18,10
;	VSPRITE	b28e19,10
;	SPRITE1	b28e20,30
           JUMP	BatterReturn



NewMidSwing:
	SETMEM	BatHeight,2	; Set Bat Not In Hitting Position
	SYSTEM	YesSwing
;	SPRITE1	bmsa01,1
;	SPRITE1	bmsa02,1
;	TRACKBALL	-1
;	SPRITE1	bmsa03,1
;	TRACKBALL	-1
;	SPRITE1	bmsa04,1
;	TRACKBALL	-1
;	SPRITE1	bmsa05,1
;	TRACKBALL	-1
	SPRITE1	bmsa01,1
	TRACKBALL	Fight 
;	TRACKBALL	-1
;	SPRITE1	bmsa07,1
;	TRACKBALL	-1
	SPRITE1	bmsa08,1
	TRACKBALL	-1
	SPRITE1	bmsa09,1
	TRACKBALL	-1
	SPRITE1	bmsa10,1
	TRACKBALL	-1
	SPRITE1	bmsa11,1
	TRACKBALL	-1
	SPRITE1	bmsa12,1
	TRACKBALL	-1

	SPRITE1	bmsa13,1
	TRACKBALL	-1
	SPRITE1	bmsa14,1
	TRACKBALL	-1
NewMidSwing1:
	SPRITE1	bmsa15,1
	TRACKBALL	-1
	LOADABS	CanSwing
     	JUMPCMP	0,NewMidSwing1
	SYSTEM	SaveTrack
	SYSTEM	YesSwing
	SPRITE1	bmsa16,1
	TRACKBALL	NewMidSwing1
	SPRITE1	bmsa17,1
;	TRACKBALL	-1
 	SPRITE1	bmsa18,1

	SOUNDS	SwingBat
	VSPRITE	bmsa19,10
	LOADABS	strike
	JUMPCMP	0,FinishSwing
	JUMPCMP	1,FinishSwing
	JUMPCMP	2,FinishSwing
;	LOADABS	BaseCount
;	JUMPCMP	4,WiffSwing2
	JUMP	WiffSwing
FinishSwing:
	VSPRITE	bmsa20,10
	VSPRITE	bmsa21,10
	VSPRITE	bmsa22,10
	VSPRITE	bmsa23,10
	VSPRITE	bmsa24,10
	VSPRITE	bmsa25,10
	SPRITE	bmsa26,5
	SPRITE	bmsa27,5
	SPRITE	bmsa28,5
	SPRITE	bmsa29,5
	SPRITE	bmsa30,5
	SPRITE	bmsa31,5
	SPRITE	bmsa32,5
	SPRITE	bmsa33,5
	SPRITE	bmsa34,5
	SPRITE	bmsa35,5
	SPRITE	bmsa36,5
	SPRITE	bmsa37,5
	SPRITE	bmsa38,5

;	JUMP	Standing
	JUMP	Fight


HighMidSwing:
	SETMEM	BatHeight,3	; Set Bat Height
;obe	SPRITE1	b29e02,1
;;	TRACKBALL	Fight      	
;;	SPRITE1	b29e03,1
;;	TRACKBALL	-1
;;	SPRITE1	b29e04,1
;;	TRACKBALL	-1
;	SPRITE1	b29e05,1
           TRACKBALL	Fight
;           SPRITE1	b29e06,1
           TRACKBALL	-1
;	SPRITE1	b29e07,1
           TRACKBALL	-1
;	SPRITE1	b29e08,1
           TRACKBALL	-1
HighMid1:
;           SPRITE1	b29e09,1
           TRACKBALL	-1
           SYSTEM	SaveTrack
	SYSTEM	YesSwing
;           SPRITE1	b29e10,1
           TRACKBALL	HighMid1
;           SPRITE1	b29e11,1
;;          TRACKBALL	-1
;	SPRITE1	b29e12,1
;;	SYSTEM	NoPitcherControls

	SOUNDS	SwingBat
;	VSPRITE	b29e13,14
;	VSPRITE	b29e14,14
;	VSPRITE	b29e15,14
;	VSPRITE	b29e16,14
;	VSPRITE	b29e17,14
;	SPRITE1	b29e18,30
           JUMP	BatterReturn

HighSwing:
	SETMEM	BatHeight,4	; Set Bat Height
	SYSTEM	YesSwing
	SPRITE1	bhs101,1
	TRACKBALL	Fight 
	SPRITE1	bhs102,1
	TRACKBALL	-1
	SPRITE1	bhs103,1
	TRACKBALL	-1
	SPRITE1	bhs104,1
	TRACKBALL	-1
	SPRITE1	bhs105,1
	TRACKBALL	-1
	SPRITE1	bhs106,1
	TRACKBALL	-1
	SPRITE1	bhs107,1
	TRACKBALL	-1
	SPRITE1	bhs108,1
	TRACKBALL	-1
	SPRITE1	bhs109,1
	TRACKBALL	-1
	SPRITE1	bhs110,1
	TRACKBALL	-1
	SPRITE1	bhs111,1
	TRACKBALL	-1
	SPRITE1	bhs112,1
	TRACKBALL	-1
HighSwing1:
	SPRITE1	bhs113,1
	TRACKBALL	-1
	LOADABS	CanSwing
     	JUMPCMP	0,HighSwing1
	SYSTEM	SaveTrack
	SYSTEM	YesSwing
	SPRITE1	bhs114,1
	TRACKBALL	HighSwing1
	SPRITE1	bhs115,1
;	TRACKBALL	-1
	SPRITE1	bhs116,1

	SOUNDS	SwingBat
	VSPRITE	bhs117,10
	VSPRITE	bhs118,10
	VSPRITE	bhs119,10
	VSPRITE	bhs120,10
;	JUMP	Standing
	VSPRITE	bhs121,10
	VSPRITE	bhs122,10
	VSPRITE	bhs123,10
	SPRITE	bhs124,5
	SPRITE	bhs125,5
	SPRITE	bhs126,5

;	SPRITE	bhs127,5
;	SPRITE	bhs128,5
;	SPRITE	bhs129,5
;	SPRITE	bhs130,5
;	SPRITE	bhs131,5
;	SPRITE	bhs132,5
	SPRITE	bmsa30,5
	SPRITE	bmsa31,5
	SPRITE	bmsa32,5
	SPRITE	bmsa33,5
	SPRITE	bmsa34,5
	SPRITE	bmsa35,5
	SPRITE	bmsa36,5
	SPRITE	bmsa37,5
	SPRITE	bmsa38,5
	SPRITE	bmsa39,5

;	JUMP	Standing
	JUMP      Fight

PKarateHit:
	SETMEM	BatHeight,4	; Set Bat Height
	SYSTEM	YesSwing
        	SOUNDS	KarateHit
	SPRITE1	bnla01,2
	TRACKBALL	Fight 
	SPRITE1	bnla01,2
	TRACKBALL	-1
	SPRITE1	bnla02,2
	TRACKBALL	-1
	SPRITE1	bnla03,2
	TRACKBALL	-1
	SPRITE1	bnla04,2
	TRACKBALL	-1
	SPRITE1	bnla05,2
	TRACKBALL	-1

KarateSwing1:
	SPRITE1	bnla06,2
	TRACKBALL	-1
	LOADABS	CanSwing
     	JUMPCMP	0,KarateSwing1
	SYSTEM	SaveTrack
	SYSTEM	YesSwing
	SPRITE1	bnla07,2
	TRACKBALL	KarateSwing1
	SPRITE	bnla08,8
	SPRITE	bnla09,8
	SPRITE	bnla10,8
	JUMP      Fight




POneArmSwing:
	SETMEM	BatHeight,4	; Set Bat Height
	SYSTEM	YesSwing
	SPRITE1	bnja01,2
	TRACKBALL	Fight 
;	SPRITE1	bnja01,2	;bri
;	TRACKBALL	-1
;	SPRITE1	bnja02,2
;	TRACKBALL	-1
;	SPRITE1	bnja03,2
;	TRACKBALL	-1
	SPRITE1	bnja04,2
	TRACKBALL	-1
	SPRITE1	bnja05,2
	TRACKBALL	-1
	SPRITE1	bnja06,2
	TRACKBALL	-1
	SPRITE1	bnja07,2
	TRACKBALL	-1
	SPRITE1	bnja08,2
	TRACKBALL	-1
	SPRITE1	bnja09,2
	TRACKBALL	-1

OneArmSwing1:
	SPRITE1	bnja10,2
	TRACKBALL	-1
	LOADABS	CanSwing
     	JUMPCMP	0,OneArmSwing1
	SYSTEM	SaveTrack
	SYSTEM	YesSwing
	SPRITE1	bnja11,2
	TRACKBALL	OneArmSwing1
	SPRITE	bnja12,5
	SPRITE	bnja13,5
	SPRITE	bnja14,5
	SPRITE	bnja15,5
	SPRITE	bnja16,5
	SPRITE	bnja17,5
	SPRITE	bnja18,5
;	SPRITE	bnja19,5
;	SPRITE	bnja20,5
	SPRITE	bmsa32,5
	SPRITE	bmsa33,5
	SPRITE	bmsa34,5
	SPRITE	bmsa35,5
	SPRITE	bmsa36,5
	SPRITE	bmsa37,5
	SPRITE	bmsa38,5
	SPRITE	bmsa39,5

	JUMP      Fight



VintageSwing:
	SETMEM	BatHeight,2	; Set Bat Height
;	SETRAM	POWERNUM,14
;	SYSTEM	YesSwing
	SYSTEM	SetVintageSPal
	SPRITE1	v14e01,1
	SPRITE1	v14e01,1
;TRACKBALL	Fight 
	TRACKBALL	-1
	SPRITE1	v14e02,1
	TRACKBALL	-1
	SPRITE1	v14e02,1
	TRACKBALL	-1
	SPRITE1	v14e03,1
	TRACKBALL	-1
	SPRITE1	v14e03,1
	TRACKBALL	-1
	SPRITE1	v14e04,1
	TRACKBALL	-1
	SPRITE1	v14e04,1
	TRACKBALL	-1
	SPRITE1	v14e05,1
	TRACKBALL	-1
	SPRITE1	v14e05,1
	TRACKBALL	-1
	SPRITE1	v14e06,1
	TRACKBALL	-1
	SPRITE1	v14e06,1
	TRACKBALL	-1
	SPRITE1	v14e07,1
	TRACKBALL	-1
	SPRITE1	v14e07,1
	TRACKBALL	-1
	SPRITE1	v14e08,1
	TRACKBALL	-1
	SPRITE1	v14e08,1
	TRACKBALL	-1

	
VintSwing1:
	SPRITE1	v14e09,1
	TRACKBALL	-1
	LOADABS	CanSwing
     	JUMPCMP	0,VintSwing1
	SYSTEM	SaveTrack
	SYSTEM	YesSwing
	SPRITE	v14e10,1
	TRACKBALL	VintSwing1
	SPRITE	v14e11,1
;	TRACKBALL	-1
	SPRITE	v14e12,1
	TRACKBALL	-1
	SYSTEM	SetNormalSPal
	SPRITE	bmsa20,5
	SPRITE	bmsa21,5
	SPRITE	bmsa22,5
	SPRITE	bmsa23,5
	SPRITE	bmsa24,5
	SPRITE	bmsa25,5
	SPRITE	bmsa26,5
	SPRITE	bmsa27,5
	SPRITE	bmsa28,5
	SPRITE	bmsa29,5
	SPRITE	bmsa30,5
	SPRITE	bmsa31,5
	SPRITE	bmsa32,5
	SPRITE	bmsa33,5
	SPRITE	bmsa34,5
	SPRITE	bmsa35,5
	SPRITE	bmsa36,5
	SPRITE	bmsa37,5
	SPRITE	bmsa38,5
	SPRITE	bmsa39,5

	JUMP      Fight


	.export	CaveManSwing
	.import	CavemanHit
CaveManSwing:
	SOUNDS S_CaveManHit
	SPRITE bxha01,3
	SPRITE bxha02,3
	SPRITE bxha03,3
	SPRITE bxha04,3
	SPRITE bxha05,2
	SPRITE bxha06,2
	SPRITE bxha07,2
	SPRITE bxha08,2

	SYSTEM	CavemanHit
	JUMP	Fight

	.export	ThrowAndHit,ThrowUp
	.import	ThrowUpBall
ThrowAndHit:
	SPRITE bxga01,5
	SPRITE bxga02,5
ThrowHit_1:
	SPRITE bxga03,6
	JUMP	ThrowHit_1

ThrowUp:
	SYSTEM	SetBall0
	SPRITE	bxga04,6
	SYSTEM	SetBall1
	SPRITE	bxga05,6
	SYSTEM	SetBall2
	SPRITE	bxga06,6
	SYSTEM	SetBall3
	SPRITE	bxga07,6
	SYSTEM	SetBall4
	SPRITE	bxga08,6
	SYSTEM	SetBall5
	SPRITE	bxga09,5
	SYSTEM	SetBall6
	SPRITE	bxga10,5
	SOUNDS	CatchesPitch
	SEMSET	CanSwing
	SYSTEM	ThrowUpBall
	JUMP	Fight2

	.align	2
	 .import	BallXOffset,BallXOVel,BallXOAccel
	 .import	BallYOffset,BallYOVel,BallYOAccel
SetBall0:
	move.l	#Baseball,a0	; Load Address Of Ball
	clr.l	WORLDXVEL(a0)	; Stop X Movement
	clr.l	WORLDYVEL(a0)	; Stop Y Movement
	clr.l	WORLDZVEL(a0)	; Stop Z Movement
	clr.l	BallXOffset	; Clear Ball Offsets
	clr.l	BallXOVel
	clr.l	BallXOAccel
	clr.l	BallYOffset
	clr.l	BallYOVel
	clr.l	BallYOAccel
	move.l	#10*12*256,WORLDY(a0)	; Move a Little In Front Of Plate
	rts
SetBall1:
	move.l	#28*256,Baseball+WORLDZ
	move.l	#-30*256,d0
	tst.b	Batter+FLIPFLAG	; Check If Flipped	*
	beq	SetBall1_9	; Branch If Not	*
	neg.l	d0	; Set For Left Hander	*
SetBall1_9:
	add.l	d0,Baseball+WORLDX

	rts
SetBall2:
	move.l	#33*256,Baseball+WORLDZ
	move.l	#10*256,d0
	tst.b	Batter+FLIPFLAG	; Check If Flipped	*
	beq	SetBall2_9	; Branch If Not	*
	neg.l	d0	; Set For Left Hander	*
SetBall2_9:
	add.l	d0,Baseball+WORLDX
	rts
SetBall3:
	move.l	#37*256,Baseball+WORLDZ
	move.l	#7*256,d0
	tst.b	Batter+FLIPFLAG	; Check If Flipped	*
	beq	SetBall3_9	; Branch If Not	*
	neg.l	d0	; Set For Left Hander	*
SetBall3_9:
	add.l	d0,Baseball+WORLDX
	rts
SetBall4:
	move.l	#28*256,Baseball+WORLDZ
	rts
SetBall5:
	move.l	#46*256,Baseball+WORLDZ
	move.l	#12*256,d0
	tst.b	Batter+FLIPFLAG	; Check If Flipped	*
	beq	SetBall5_9	; Branch If Not	*
	neg.l	d0	; Set For Left Hander	*
SetBall5_9:
	add.l	d0,Baseball+WORLDX
	rts
SetBall6:
	move.l	#64*256,Baseball+WORLDZ
	rts

WiffSwing:
;	SOUNDS	SwingBat
	SPRITE	b48e05,5
	SPRITE	b48e06,5
	SPRITE	b48e07,5
	SPRITE	b48e08,5
	SPRITE	b48e09,35
	SPRITE	b48e10,5
	SPRITE	b48e11,5
	SPRITE	b48e12,5
	SPRITE	b48e13,5
	SPRITE	b48e14,5
	SPRITE 	bmsa32,5
	SPRITE 	bmsa33,5
	SPRITE 	bmsa34,5
	SPRITE 	bmsa35,5
	SPRITE 	bmsa36,5	SPRITE 	bmsa37,1
	SPRITE 	bmsa38,5
	SPRITE 	bmsa39,5

;	SPRITE	b48e15,5
  ;	SPRITE	bf2a16,5
  ;	SPRITE	bf2a17,5
  ;	SPRITE	bf2a18,5
  ;	SPRITE	bf2a19,5
  ;	SPRITE	bf2a20,5
  ;	SPRITE	bf2a21,5
  ;	SPRITE	bf2a22,5
  ;	SPRITE	bf2a23,5
  ;	SPRITE	bf2a24,5
	JUMP	Fight

;WiffSwing2:
;	SPRITE	bf2a03,5
;	SPRITE	bf2a04,5
;	SPRITE	bf2a05,5
;	SPRITE	bf2a06,5
;	SPRITE	bf2a07,5
;	SPRITE	bf2a08,5
;;	SOUNDS	PlayerHitsDirt
;;	SPRITE	bf2a09,25
;	SPRITE	bf2a11,8
;	SPRITE	bf2a12,8
;	SPRITE	bf2a13,8
;	SPRITE	bf2a14,8
;	SPRITE	bf2a15,7
;	SPRITE	bf2a16,7
;	SPRITE	bf2a17,6
;	SPRITE	bf2a18,6
;	SPRITE	bf2a19,6
;	SPRITE	bf2a21,6
;	SPRITE	bf2a22,6
;	SPRITE	bf2a23,6
;	SPRITE	bf2a24,6
;	SPRITE	bf2a25,6
;	JUMP	Fight


HitByPitch:
	SPRITE1	b22a01,5
	SPRITE1	b22a02,5
	SPRITE1	b22a03,5
	SPRITE1	b22a04,5
	SPRITE1	b22a05,5
	SPRITE1	b22a06,5
	SPRITE1	b22a07,5
	SPRITE1	b22a08,5
	SPRITE1	b22a09,5
	SPRITE1	b22a10,5
	SPRITE1	b22a11,5
	SPRITE1	b22a12,5
	SPRITE1	b22a13,5
	SPRITE1	b22a14,5
	SPRITE1	b22a15,5
	SPRITE1	b22a14,5
	SPRITE1	b22a13,5
	SPRITE1	b22a12,5
	JUMP	Fight


BatterReturn:		;Return from the Swing
;	SPRITE1	ba2a01,4
;	SPRITE1	ba2a02,4
	SPRITE1	ba2a03,1
	SPRITE1	ba2a04,1
	SPRITE1	ba2a05,1
	SPRITE1	ba2a06,1
	SPRITE1	ba2a07,1
	SPRITE1	b14a13,1
	SPRITE1	b14a14,1
	SPRITE1	b14a15,1
	SPRITE1	b14a16,1
BackFromSec:
	JUMP	Standing

PitcherIntro:
	SEMCLR	CanSwing
	SYSTEM	DoPitcherName

	SYSTEM	CheckForTired
	LOADABS	TiredPit
	JUMPCMP	1,Pitcher_5
	
	JUMP	PitcherIntro2
	JUMPRND	7	;Random Pitch
	ADDRESS	PitcherIntro2
	ADDRESS	Pitcher_5
	ADDRESS	PitcherIntro2
	ADDRESS	Pitcher_2
	ADDRESS	PitcherIntro2
	ADDRESS	Pitcher_3
	ADDRESS	PitcherIntro2
	ADDRESS	PitcherIntro2

PitcherIntro2:
	SPRITE1	pa1a02,3
	SPRITE1	pa1a03,5;3
	SPRITE1	pa1a04,5;3
	SPRITE1	pa1a05,5;3
	SPRITE1	pa1a06,5;3
	SPRITE1	pa1a07,5;3
	SPRITE1	p02a01,4
	SPRITE1	p02a02,5;4
	SPRITE1	p02a03,5;4
	SPRITE1	p02a04,5;4
	SPRITE1	p02a05,5;4
 ;	SPRITE1	p02a06,5;4
	SPRITE1	p02a07,5;4
	SPRITE1	p02a08,5;4

PNothing:
Pitcher_1:			;Just stand there
	SYSTEM	ClearPowerF
	SYSTEM	InitTrackball
	SETRAM	COUNTER,240	; Set Time-Out Counter
Pitcher_1A:
	ALWAYS	CheckPitch
	SYSTEM	InitJoyWatch
	SYSTEM	CheckForCards
;	INPUTSUB	PITCHER_CONTROLS
	SPRITE1	p02a09,6
	JUMP	Pitcher_1A

Pitcher_2:     		;dirt kick
	MOVE	0,-2
	SOUNDS	ScratchFootInDirt
	SPRITE1	p07a01,4
        	SPRITE1	p01a01,4
        	SPRITE1	p01a02,4
        	SPRITE1	p01a03,4
        	SPRITE1	p01a04,4
        	SPRITE1	p01a05,4
        	SPRITE1	p01a06,4
        	SPRITE1	p01a07,3
        	SPRITE1	p01a08,3
        	SPRITE1	p01a09,3
	SOUNDS	ScratchFootInDirt
        	SPRITE1	p01a08,3        
        	SPRITE1	p01a07,3
        	SPRITE1	p01a06,4
        	SPRITE1	p01a05,4
        	SPRITE1	p01a04,4
        	SPRITE1	p01a03,4
        	SPRITE1	p01a04,4
        	SPRITE1	p01a05,4
        	SPRITE1	p01a06,4
        	SPRITE1	p01a07,3
        	SPRITE1	p01a08,3
        	SPRITE1	p01a09,3
	SOUNDS	ScratchFootInDirt
        	SPRITE1	p01a08,3        
        	SPRITE1	p01a07,3
        	SPRITE1	p01a06,4
        	SPRITE1	p01a05,4
        	SPRITE1	p01a04,4
        	SPRITE1	p01a03,4
        	SPRITE1	p01a02,4
        	SPRITE1	p01a01,4
	FMOVE	0,2
        	SPRITE1	p07a01,4

	JUMP	PitcherIntro2
	
Pitcher_3: 		;Head nod
;        	SPRITE1	p05a02,4
;        	SPRITE1	p05a03,4
;        	SPRITE1	p05a04,4
;        	SPRITE1	p05a05,15
;        	SPRITE1	p05a06,5;4
;        	SPRITE1	p05a07,5;4
;        	SPRITE1	p05a08,5;4
;        	SPRITE1	p05a09,5;4
;        	SPRITE1	p05a08,5;4
;        	SPRITE1	p05a07,5;4
;        	SPRITE1	p05a06,5;4
;        	SPRITE1	p05a05,5;4
;        	SPRITE1	p05a04,5;4
;        	SPRITE1	p05a03,5;4
;        	SPRITE1	p05a02,4
        	JUMP	PitcherIntro2

Pitcher_4: 		;Head Turn
	SPRITE	p02a09,10
	SPRITE	p02a10,4
	SPRITE	p02a11,4
	SPRITE	p02a12,4
	SPRITE	p02a13,4
	SPRITE	p02a14,4
	SPRITE	p02a15,4
	SPRITE	p02a16,20
	SPRITE	p02a15,4
	SPRITE	p02a14,4
	SPRITE	p02a13,4
	SPRITE	p02a12,4
	SPRITE	p02a11,4
	SPRITE	p02a10,4
	SPRITE	p02a09,10
        	JUMP	PNothing

Pitcher_5: 		;Tired Arm
	SPRITE1	p34a01,8
	SPRITE1	p34a02,8
	SPRITE1	p34a03,8
	SPRITE1	p34a04,7
	SPRITE1	p34a05,7
	SPRITE1	p34a06,8
	SPRITE1	p34a07,8
	SPRITE1	p34a08,8
	SPRITE1	p34a01,8
	SPRITE1	p34a02,8
	SPRITE1	p34a03,8
	SPRITE1	p34a04,7
	SPRITE1	p34a05,7
	SPRITE1	p34a06,8
	SPRITE1	p34a07,8
	SPRITE1	p34a08,8
	
	JUMP	PitcherIntro2
	

	
;Pitcher_6:		;Wave In
;	SPRITE	p23a01,6
;	SPRITE	p23a02,6
;	SPRITE	p23a03,6
;	SPRITE	p23a04,6
;	SPRITE	p23a05,6
;	SPRITE	p23a06,5
;	SPRITE	p23a07,4
;	SPRITE	p23a08,6
;	SPRITE	p23a07,6
;	SPRITE	p23a06,6
;	SPRITE	p23a05,6
 ;	SPRITE	p23a06,5
 ;	SPRITE	p23a07,4
;	SPRITE	p23a08,6
 ;	SPRITE	p23a07,6
;	SPRITE	p23a06,6
;	SPRITE	p23a05,6
;	SPRITE	p23a04,6
;	SPRITE	p23a03,6
;	SPRITE	p23a02,6
;	SPRITE	p23a01,6
;	SPRITE	pa1a01,6
;        	JUMP	PitcherIntro2
;	
	
GoPitch:
;	SYSTEM	NoPitcherControls
;	INPUTSUB	PITCHER_NOCONTROLS
	
	SEMCLR	UnderHandPitch
	LOADABS	Inning
	JUMPCMP	0,WasFirstP
;	SOUNDS	HeresThePitch
	JUMP	NotFirstP
WasFirstP:
	LOADABS	HasFirst
	JUMPCMP	1,NotFirstP
	SEMSET	HasFirst
	SOUNDS	FirstPitch
	JUMP	WasFirst2

NotFirstP
	SOUNDS	HeresThePitch

WasFirst2
	SEMCLR	PitchSound
	SYSTEM	GiveControlsToBatter
	SYSTEM	GiveWalkToBatter
	SEMSET	CanSwing
	SYSTEM	NoSwing

;	JUMP	PitchType10
	IFHASPOWER 8,P1PitchType	;did he get the Power?
	IFHASPOWER 9,PitchType9	;did he get the Power?
	IFHASPOWER 10,PitchType10	;did he get the Power?
	
	
NoPowerPitch:
	SYSTEM	GetPitchType
	LOADABS	pitcht
	JUMPCMP	0,PitchType0
	JUMPCMP	1,PitchType1
	JUMPCMP	2,PitchType2
	JUMPCMP	3,PitchType3
	JUMPCMP	4,PitchType4
	
;;	JUMP	PitchType4
;	JUMPRND	7
;	ADDRESS	PitchType1   	;Regular
;	ADDRESS	PitchType1
;	ADDRESS	PitchType1
;	ADDRESS	PitchType1
;	ADDRESS	PitchType2	;Sub
;	ADDRESS	PitchType2
;	ADDRESS	PitchType3	;HighKick
;	ADDRESS	PitchType3

GoMove:
	JUMP	StepTo

P1PitchType:		;These are the p1's
	SEMSET	PitchSound
	JUMPRND	3
	ADDRESS	PitchType6
	ADDRESS	PitchType8
	ADDRESS	PitchType3	;was 6
	ADDRESS	PitchType8
	

PitchType0:   		; Regular Pitch
	SYSTEM	SetPitch0
	SPRITE1	p07a08,5
	SPRITE1	p07a09,5
	SPRITE1	p07a10,5
	SPRITE1	p07a11,5
	SPRITE1	p07a12,5
	SPRITE	p07a13,5
	SOUNDS	PitchBalls
	SPRITE	p07a14,5
	SPRITE	p07a15,5
	SEMSET	PitchIt
	SYSTEM	PitchBall
	INPUTSUB	PITCHER_BALL_CONTROLS
;	SYSTEM	SetZone
	SYSTEM	GiveSwingToBatter
;	SEMSET	ZonePtr
;	SYSTEM	Zone3Obj

	VSPRITE	p07a16,5
	VSPRITE	p07a17,5
   	VSPRITE	p07a18,5
	VSPRITE	p07a19,5
	VSPRITE	p07a20,5
	VSPRITE	p07a21,5
	VSPRITE	p07a22,5
	VSPRITE	p07a23,5
	VSPRITE	p07a24,5
	SPRITE1	p07a25,50
	JUMP	PitchReturn

PitchType1: 		; High Kick Pitch
        	SYSTEM	SetPitch1
	SPRITE1	p02a09,5
	SPRITE1	p11a06,5
	SPRITE1	p11a07,5
   	SPRITE1	p11a08,5
	SPRITE1	p11a09,3
	SPRITE	p11a10,3
	SPRITE	p11a11,3
	SPRITE	p11a12,4
	SPRITE	p11a13,4
	SPRITE	p11a14,4
	VSPRITE	p11a15,14
	VSPRITE	p11a16,14
	SOUNDS	PitchBalls
	VSPRITE	p11a17,14
	VSPRITE	p11a18,14
	VSPRITE	p11a19,14
	VSPRITE	p11a20,14
	SEMSET	PitchIt
	SYSTEM	PitchBall
	INPUTSUB	PITCHER_BALL_CONTROLS
;	SYSTEM	SetZone
	SYSTEM	GiveSwingToBatter
;	SYSTEM	GiveControlsToBatter
;	SEMSET	ZonePtr
;	SYSTEM	Zone3Obj

	VSPRITE	p11a21,14
	VSPRITE	p11a22,14
	VSPRITE	p11a23,14
	VSPRITE	p11a24,14
	VSPRITE	p11a25,14
	SEMCLR	BatterReady
	VSPRITE	p11a26,14
	VSPRITE	p11a27,14
	VSPRITE	p11a28,14
	VSPRITE	p11a29,14
	SPRITE1	p11a30,50
	JUMP	PitchReturn


PitchType2:   		;SUB Pitch
	SYSTEM	SetPitch2
           SPRITE1	p02a09,5
	SPRITE1	p09a01,5
	SPRITE1	p09a02,5
	SPRITE1	p09a03,5
	SPRITE1	p09a04,3
	SPRITE1	p09a05,3
	SPRITE1	p09a06,3
 	SPRITE1	p09a07,3
	SPRITE1	p09a08,3
	SPRITE1	p09a09,3
	SPRITE	p09a10,3
	VSPRITE	p09a11,3
	VSPRITE	p09a12,3
	SOUNDS	PitchBalls
	VSPRITE	p09a13,4
	VSPRITE	p09a14,4
	VSPRITE	p09a15,4
	VSPRITE	p09a16,4
	SEMSET	PitchIt
	SYSTEM	PitchBall
	INPUTSUB	PITCHER_BALL_CONTROLS
	SYSTEM	GiveSwingToBatter
    	VSPRITE	p09a17,4
	VSPRITE	p09a18,4
	VSPRITE	p09a19,5
	VSPRITE	p09a20,5
	VSPRITE	p09a21,5
	VSPRITE	p09a22,5
	VSPRITE	p09a24,5
	SPRITE1	p09a25,50
	FMOVE	-7,-4
	SEMCLR	BatterReady
	SPRITE1	p07a26,7
	SPRITE1	p07a27,7
	SPRITE1	p07a28,7
	SPRITE1	p07a29,7
	FMOVE	1,0
	SPRITE1	p07a30,7
	SPRITE1	p07a31,7
	FMOVE	2,0
	SPRITE1	p07a32,7
	FMOVE	0,2
	SPRITE1	p07a33,7
	SPRITE1	p07a34,7
	SPRITE1	p07a35,7
	FMOVE	3,2
	SPRITE1	p07a36,7
	SPRITE1	p07a37,7
	SPRITE1	p07a01,7
	FMOVE	1,0
;	SYSTEM	CheckBallP
	JUMP	PitcherIntro




PitchType3:   		; Knuckle Pitch

	SYSTEM	SetPitch3
	SPRITE1	px7a01,5
	SPRITE1	px7a02,5
	SPRITE1	px7a03,5
	SPRITE1	px7a04,5
	LOADABS	PitchSound
	JUMPCMP	0,RegularSound
	SOUNDS	S_KnucklePitch
	JUMP	PassSound
RegularSound:
	SOUNDS	PitchBalls
PassSound:
	VSPRITE	px7a05,5
	SEMCLR	PitchSound
	VSPRITE	px7a06,5
	SEMSET	PitchIt
	SYSTEM	PitchBall
	SYSTEM	KnucklePitch
	INPUTSUB	PITCHER_BALL_CONTROLS
;	SYSTEM	SetZone
	SYSTEM	GiveSwingToBatter
;	SEMSET	ZonePtr
;	SYSTEM	Zone3Obj
	SPRITE	px7a07,35
	SPRITE	px7a08,5
	SEMCLR	BatterReady
	JUMP	PitchReturn1



PitchType4: 		; Nomo Pitch
        	SYSTEM	SetPitch4
;	SPRITE	p07a01,4
	SPRITE	p09a01,4 
;	SPRITE	p09a02,3
	SPRITE	p12a02,5
	SPRITE	p12a03,4
	SPRITE	p12a04,4
	SPRITE	p12a05,20
	SPRITE	p12a06,6
	SPRITE	p12a07,6
	SPRITE	p12a02,6
	VSPRITE	p07a12,6
	VSPRITE	p07a13,6

	SOUNDS	PitchBalls
	VSPRITE	p07a14,5
	VSPRITE	p07a15,5
	SEMSET	PitchIt
	SYSTEM	PitchBall
	INPUTSUB	PITCHER_BALL_CONTROLS
;	SYSTEM	SetZone
	SYSTEM	GiveSwingToBatter
;	SYSTEM	GiveControlsToBatter
;	SEMSET	ZonePtr
;	SYSTEM	Zone3Obj

	VSPRITE	p07a16,5
	VSPRITE	p07a17,5
	VSPRITE	p07a18,5
	VSPRITE	p07a19,5
	VSPRITE	p07a20,5
	VSPRITE	p07a21,5
	SEMCLR	BatterReady
	VSPRITE	p07a22,5
	VSPRITE	p07a23,5
	VSPRITE	p07a24,5
	SPRITE	p07a25,50
	JUMP	PitchReturn



PitchType5: 		; Behind the Back 1
        	SYSTEM	SetPitch5	; Dont Use
	SPRITE	px2a02,5
	SPRITE	px2a03,5
	SPRITE	px2a04,6
   	VSPRITE	px2a05,6
	VSPRITE	px2a06,6
	VSPRITE	px2a07,9
	SOUNDS	PitchBalls
	VSPRITE	px2a08,15
	SEMSET	PitchIt
	SYSTEM	PitchBall
	SYSTEM	GhostPitch
	INPUTSUB	PITCHER_BALL_CONTROLS
	SYSTEM	GiveSwingToBatter
	VSPRITE	px2a09,10
	SPRITE	px2a11,8
	SPRITE	px2a12,6
	SPRITE	px2a13,6
	SPRITE1	p02a01,4
	SPRITE1	p02a02,5
	SPRITE1	p02a03,5
	SPRITE1	p02a04,5
	SPRITE1	p02a05,5
	SPRITE1	p02a06,5
	SPRITE1	p02a07,5
	SEMCLR	BatterReady
	JUMP	PNothing

	
PitchType6: 		; Behind the Back 2
        	SYSTEM	SetPitch6
	SPRITE	px3a02,5
	SPRITE	px3a03,5
	SPRITE	px3a04,6
   	SPRITE	px3a05,4
	SOUNDS	PitchBalls
	SEMSET	PitchIt
	SYSTEM	PitchBall
	INPUTSUB	PITCHER_BALL_CONTROLS
	SYSTEM	GiveSwingToBatter
	SPRITE	px3a06,4
	SPRITE	px3a07,3
	SPRITE	px3a08,15
	SOUNDS	PowerPitch
	SPRITE	px3a06,6
	SPRITE	px3a05,6
	SPRITE	px3a04,6
	SPRITE	px3a03,6
	SPRITE	px3a02,6
	SEMCLR	BatterReady
	
	JUMP	PNothing


PitchType7: 		; Wuss Pitch
        	SYSTEM	SetPitch5
	SPRITE	px4a01,5
	SPRITE	px4a02,5
	SPRITE	px4a03,5
	SOUNDS	PitchBalls
	VSPRITE	px4a04,0
	SEMSET	PitchIt
	SYSTEM	PitchBall
	INPUTSUB	PITCHER_BALL_CONTROLS
	SYSTEM	GiveSwingToBatter
	VSPRITE	px4a05,6
   	VSPRITE	px4a06,6
	VSPRITE	px4a07,6
	SOUNDS	PowerPitch
	VSPRITE	px4a08,6
	VSPRITE	px4a09,6
	SEMCLR	BatterReady
	JUMP	PitcherIntro


PitchType8: 		;Underhand Pitch
	SEMSET	UnderHandPitch
        	SYSTEM	SetPitch8
	SPRITE	px5a01,5
	SPRITE	px5a02,5
	SPRITE	px5a03,5
	SPRITE	px5a04,5
	SPRITE	px5a05,5
	SPRITE	px5a06,5
	SOUNDS	PitchBalls
	VSPRITE	px5a07,1
	SEMSET	PitchIt
	SYSTEM	PitchBall
	INPUTSUB	PITCHER_BALL_CONTROLS
	SYSTEM	GiveSwingToBatter
	SPRITE	px5a08,15
   	SPRITE	px5a09,9
	SPRITE	px5a10,8
	SOUNDS	PowerPitch
	SPRITE	px5a11,6
	SPRITE	px5a12,6
	SEMCLR	BatterReady
	JUMP	PNothing


PitchType9: 		;Tornado Pitch
        	SYSTEM	SetPitch9
	SPRITE	pu1a01,1
	SOUNDS	BatterSpins
	SPRITE	pu1a02,1
	SPRITE	pu1a03,1
	SPRITE	pu1a04,1
	SPRITE	pu1a05,1
	SPRITE	pu1a06,1
	SPRITE	pu1a07,1
	SPRITE	pu1a08,1
	SPRITE	pu1a09,1
	SPRITE	pu1a10,1
	SPRITE	pu1a01,1
	SPRITE	pu1a02,1
	SPRITE	pu1a03,1
	SPRITE	pu1a04,1
	SPRITE	pu1a05,1
	SPRITE	pu1a06,1
	SPRITE	pu1a07,1
	SPRITE	pu1a08,1
	SPRITE	pu1a09,1
	SPRITE	pu1a10,1
	SPRITE	pu1a01,1
	SPRITE	pu1a02,1
	SPRITE	pu1a03,1
	SPRITE	pu1a04,1
	SPRITE	pu1a05,1
	SPRITE	pu1a06,1
	SPRITE	pu1a07,1
	SPRITE	pu1a08,1
	SPRITE	pu1a09,1
	SPRITE	pu1a10,1
	SOUNDS	PitchBalls
	SPRITE	pu1a01,1
	SEMSET	PitchIt
	SYSTEM	PitchBall
	SYSTEM	TwisterPitch
	INPUTSUB	PITCHER_BALL_CONTROLS
	SYSTEM	GiveSwingToBatter
	SPRITE	pu1a02,1
	SPRITE	pu1a03,1
	SPRITE	pu1a04,1
	SPRITE	pu1a05,1
	SPRITE	pu1a06,1
	SPRITE	pu1a07,1
	SPRITE	pu1a08,1
	SPRITE	pu1a09,1
	SOUNDS	PowerPitch
	SPRITE	pu1a10,1
	SPRITE	pu1a02,1
	SPRITE	pu1a03,1
	SPRITE	pu1a04,1
	SPRITE	pu1a05,1
	SPRITE	pu1a06,1
	SPRITE	pu1a07,1
	SPRITE	pu1a08,1
	SPRITE	pu1a09,1
	SPRITE	pu1a10,1

;	SEMCLR	BatterReady
	SPRITE	p07a25,50
	SEMCLR	BatterReady
	JUMP	PitchReturn
;	JUMP	PNothing




PitchType10:   		;Vintage Pitch
	SYSTEM	SetPitch10
;	SETPALETTE P_VINTAGE
	SYSTEM	SetVintagePal
	SPRITE1	v17e01,5
	SPRITE1	v17e02,5
	SPRITE1	v17e03,5
	SPRITE1	v17e04,3
	SPRITE1	v17e05,3
	SPRITE1	v17e06,3
 	SPRITE1	v17e07,3
	SPRITE1	v17e08,3
	SPRITE1	v17e09,3
	SPRITE	v17e10,3
	SPRITE	v17e11,3
	SPRITE	v17e12,3
	SPRITE	v17e13,4
	SPRITE	v17e14,4
	SPRITE	v17e15,4
	SPRITE	v17e16,4
    	SPRITE	v17e17,4
	SPRITE	v17e18,4
	SPRITE	v17e19,4
	SPRITE	v17e20,4
	SPRITE	v17e21,4
	SPRITE	v17e22,4
	SPRITE	v17e24,4
	SPRITE	v17e25,4
	SPRITE	v17e26,4
	SPRITE	v17e27,4
	SOUNDS	PitchBalls
	SPRITE	v17e28,4
	SPRITE	v17e29,4
	SEMSET	PitchIt
	SYSTEM	PitchBall
	INPUTSUB	PITCHER_BALL_CONTROLS
	SYSTEM	GiveSwingToBatter
	SPRITE	v17e30,4
	SOUNDS	S_VintagePitch
	SPRITE	v17e31,4
	SPRITE	v17e32,4
	SPRITE	v17e33,4
	SYSTEM	SetNormalPal
	SPRITE1	p07a25,7
	SPRITE1	p07a26,7
	SPRITE1	p07a27,7
	SEMCLR	BatterReady
	SPRITE1	p07a28,7
	SPRITE1	p07a29,7
	SPRITE1	p07a30,7
	SPRITE1	p07a31,7
	SPRITE1	p07a32,7
	SPRITE1	p07a33,7
	SPRITE1	p07a34,7
	SPRITE1	p07a35,7
	SPRITE1	p07a36,7
	SPRITE1	p07a37,7
	SPRITE1	p07a01,7
	JUMP	PitcherIntro




PitchReturn:
	SPRITE1	p07a26,5
	SPRITE1	p07a27,5
	SPRITE1	p07a28,6
	SPRITE1	p07a29,6
	SPRITE1	p07a30,6
PitchReturn1:
	SPRITE1	p07a31,6
	SYSTEM	CheckBallP
	SPRITE1	p07a32,4;7
	SPRITE1	p07a33,4;7
	SPRITE1	p07a34,4;7
	SPRITE1	p07a35,4;7
	SPRITE1	p07a36,4;7
	SPRITE1	p07a37,4;7
	SPRITE1	pa1a01,4;7
	JUMP	PitcherIntro

PitchReturn2:
	SPRITE	p36a01,7
	SPRITE	p36a02,7
	SPRITE	p36a03,6
	SPRITE	p36a04,6
	SPRITE	p36a05,5
	SPRITE	p36a06,5
	SPRITE	p36a07,25
	SYSTEM	CheckBallP
	SPRITE	p36a08,5;7
	SPRITE	p36a09,5;7
	SPRITE	p36a10,5;7
	SPRITE	p07a31,5;7
	SPRITE	p07a32,5;8
	SPRITE	p07a33,5;8
	SPRITE	p07a34,5;7
	SPRITE	p07a35,5;7
	SPRITE	p07a36,5;7
	SPRITE	p07a37,5;7
	SPRITE	pa1a01,5;7
	JUMP	PitcherIntro

PickOff_1:			;Pick off at First Base
	CMPBI	FLIPFLAG,0
	JUMPNE	PickOff_4
	SPRITE	p14a01,3
	SPRITE	p14a02,3
	SPRITE	p14a03,3
	SPRITE	p14a04,3
 	SPRITE	p14a05,3
 	SPRITE	p14a06,2
 	SPRITE	p14a07,2
 	SPRITE	p14a08,2
	SEMSET	PickOffTest
	SETABSW	SwitchReason,PICKOFFFIRST	; Switch To Field - Pickoff Play
;	SETABSW	SwitchReason,BALLHIT	; Switch To Field - Pickoff Play
; 	SPRITE	p14a09,2
; 	SPRITE	p14a10,2
	SPRITE	p14a11,2
 	SPRITE	p14a12,3
 	SPRITE	p14a13,3
 	SPRITE	p14a14,30
 	SPRITE	p14a15,5
 	SPRITE	p14a16,5
 	SPRITE	p14a17,6
 	SPRITE	p14a18,6
 	SPRITE	p14a19,6
 	SPRITE	p14a20,6
	JUMP	PitcherIntro

	
PickOff_2:			;Pick off at Second Base
	SPRITE	p15a01,3
	SPRITE	p15a02,3
	SPRITE	p15a03,3
	SPRITE	p15a04,3
 	SPRITE	p15a05,3
 	SPRITE	p15a06,3
 	SPRITE	p15a07,2
;	SPRITE	p15a08,3
 	SPRITE	p15a09,2
	SEMSET	PickOffTest
	SETABSW	SwitchReason,PICKOFFSECOND	; Switch To Field - Pickoff Play
 	SPRITE	p15a10,2
	SPRITE	p15a11,2
 	SPRITE	p15a12,3
 	SPRITE	p15a13,3
 	SPRITE	p15a14,30
 	SPRITE	p15a15,5
 	SPRITE	p15a16,5
 	SPRITE	p15a17,5
 	SPRITE	p15a18,6
 	SPRITE	p15a19,6
 	SPRITE	p15a20,6
	JUMP	PitcherIntro

PickOff_3:			;PickOff to Third Base
	CMPBI	FLIPFLAG,0
	JUMPNE	PickOff_5
	SPRITE	p16a01,3
	SPRITE	p16a02,3
	SPRITE	p16a03,3
	SPRITE	p16a04,3
 	SPRITE	p16a05,3
;	SPRITE	p16a06,3
 	SPRITE	p16a07,3
	SEMSET	PickOffTest
	SETABSW	SwitchReason,PICKOFFTHIRD	; Switch To Field - Pickoff Play
; 	SPRITE	p16a08,3
 	SPRITE	p16a09,3
 	SPRITE	p16a10,3
	SPRITE	p16a11,3
 	SPRITE	p16a12,3
 	SPRITE	p16a13,30
 	SPRITE	p16a14,6
 	SPRITE	p16a15,6
 	SPRITE	p16a16,6
 	SPRITE	p16a17,6
 	SPRITE	p16a18,6
 	SPRITE	p16a19,6
 	SPRITE	p16a20,6
	JUMP	PitcherIntro



PickOff_4:		                      ;PickOff to First Base for Lefty
	SPRITE	p16a01,3
	SPRITE	p16a02,3
	SPRITE	p16a03,3
	SPRITE	p16a04,3
 	SPRITE	p16a05,3
;	SPRITE	p16a06,3
 	SPRITE	p16a07,3
	SEMSET	PickOffTest
	SETABSW	SwitchReason,PICKOFFFIRST	; Switch To Field - Pickoff Play
; 	SPRITE	p16a08,3
 	SPRITE	p16a09,3
 	SPRITE	p16a10,3
	SPRITE	p16a11,3
 	SPRITE	p16a12,3
 	SPRITE	p16a13,30
 	SPRITE	p16a14,6
 	SPRITE	p16a15,6
 	SPRITE	p16a16,6
 	SPRITE	p16a17,6
 	SPRITE	p16a18,6
 	SPRITE	p16a19,6
 	SPRITE	p16a20,6
	JUMP	PitcherIntro


PickOff_5:			;Pick off at third Base  Lefty
	SPRITE	p14a01,3
	SPRITE	p14a02,3
	SPRITE	p14a03,3
	SPRITE	p14a04,3
 	SPRITE	p14a05,3
 	SPRITE	p14a06,2
 	SPRITE	p14a07,2
 	SPRITE	p14a08,2
	SEMSET	PickOffTest
	SETABSW	SwitchReason,PICKOFFTHIRD	; Switch To Field - Pickoff Play
; 	SPRITE	p14a09,2
; 	SPRITE	p14a10,2
	SPRITE	p14a11,2
 	SPRITE	p14a12,3
 	SPRITE	p14a13,3
 	SPRITE	p14a14,30
 	SPRITE	p14a15,5
 	SPRITE	p14a16,5
 	SPRITE	p14a17,6
 	SPRITE	p14a18,6
 	SPRITE	p14a19,6
 	SPRITE	p14a20,6
	JUMP	PitcherIntro



DownRightBall:
	INPUTSUB	PITCHER_BALL_CONTROLS
	SYSTEM	DoDownBall
	SYSTEM	DoRightBall
	QED

UpRightBall:
	INPUTSUB	PITCHER_BALL_CONTROLS
	SYSTEM	DoUpBall
	SYSTEM	DoRightBall
	QED

DownLeftBall:
	INPUTSUB	PITCHER_BALL_CONTROLS
	SYSTEM	DoDownBall
	SYSTEM	DoLeftBall
	QED

UpLeftBall:
	INPUTSUB	PITCHER_BALL_CONTROLS
	SYSTEM	DoUpBall
	SYSTEM	DoLeftBall
	QED

UpBall:
	SYSTEM	DoUpBall
	INPUTSUB	PITCHER_BALL_CONTROLS
	QED

DownBall:
	SYSTEM	DoDownBall
	INPUTSUB	PITCHER_BALL_CONTROLS
	QED

LeftBall:
	INPUTSUB	PITCHER_BALL_CONTROLS
	SYSTEM	DoLeftBall
	QED

RightBall:
	INPUTSUB	PITCHER_BALL_CONTROLS
	SYSTEM	DoRightBall
	QED

SpeedUpI:
	LOAD	BUTTONS
	ANYBITS	FIRSTBASE|SECONDBASE|THIRDBASE|HOMEPLATE,SpeedUpI1
	DONE

SpeedUpI1:
	SYSTEM	SpeedUpInstruct	; Speed Up The Instructions
	QED

Instructions:
	SEMSET	NoTrackBalls	;Shut down trackball input
	SYSTEM	BatterHelp
;	SYSTEM	ProTipObj
;	SYSTEM	GiveSpeedToPitcher
;	SYSTEM	GiveSpeedToBatter
;	SPRITE	help01,240
;	SYSTEM	GiveSpeedToPitcher
;	SYSTEM	GiveSpeedToBatter
;	SPRITE	help02,240
;	SYSTEM	GiveSpeedToPitcher
;	SYSTEM	GiveSpeedToBatter
;	SPRITE	help03,240
;	SYSTEM	GiveSpeedToPitcher
;	SYSTEM	GiveSpeedToBatter
;	SPRITE	help04,240
;	SYSTEM	DeallocProTip
	SEMCLR	NoTrackBalls
;	DEALLOC

FielderIntro:
;	JUMP	Fielder0
	JUMPRND	3
	ADDRESS	Fielder0
	ADDRESS	Fielder3
	ADDRESS	Fielder0
	ADDRESS	Fielder3
;	ADDRESS	Fielderf10a
;	ADDRESS	Fielderf04a
;	ADDRESS	Fielderf07a
;	ADDRESS	Fielderf10a


Fielder0:	;crouch (good)

 ;	SPRITE	fx3a01,15
 ;	JUMP	FielderIntro

	SPRITE	fxba01,9
	SPRITE	fxba02,9
	SPRITE	fxba03,9
	SPRITE	fxba04,9
	SPRITE	fxba05,9
	SPRITE	fxba06,9

	JUMP	FielderIntro

Fielder1:	;Kick Dirt Slow

        	SPRITE1	f69a01,10
        	SPRITE1	f69a02,6
        	SPRITE1	f69a03,6
        	SPRITE1	f69a04,8
        	SPRITE1	f69a05,10
        	SPRITE1	f69a06,15
        	SPRITE1	f69a05,10
        	SPRITE1	f69a04,8
        	SPRITE1	f69a03,8
        	SPRITE1	f69a02,6
        	SPRITE1	f69a01,6
        	JUMP	FielderIntro

Fielder2:  ;Kick Dirt Faster (good)
;	SPRITE1	f69a08,6
;        	SPRITE1	f69a07,6
	SPRITE1	f69a01,255
        	SPRITE1	f69a02,5;2
        	SPRITE1	f69a03,5;2
        	SPRITE1	f69a04,5;2
       	SPRITE1	f69a05,7;4
       	SPRITE1	f69a06,7;4
       	SPRITE1	f69a05,7;4
	SPRITE1	f69a04,6;3
        	SPRITE1	f69a03,6;3
        	SPRITE1	f69a02,6;3
        	SPRITE1	f69a06,7
;        	SPRITE1	f69a07,5
;        	SPRITE1	f69a08,5
;        	JUMP	Fielderf02a

Fielder3:	
	SPRITE	fxba01,9
	SPRITE	fxba02,9
	SPRITE	fxba03,9
	SPRITE	fxba02,9
	SPRITE	fxba01,9
	SPRITE	fxba02,9
	SPRITE	fxba03,9
	SPRITE	fxba02,9
	JUMP	FielderIntro

FastCatch:		;Face ball with Ready to Catch
	SEMCLR	IsOnGround
	BALLHIGHER 4*12*256,RegularCatch
			;Grounder Catch
;       	SETRAM	B_DIRECTION,0	; Face Home Plate
	SETRAM	B_HASBALL,1
;GroundBallCatch!!
	BALLFASTER 1*6*256,NoBareHand
	JUMP	BareHand
NoBareHand:

	FASTER	1000,RunGBall	;running or standing.
;Standing
	SYSTEM	SetCount30
	SETRAMW	DURATIONRESET,4	; Set For 10HZ Anim
	SYSTEM	ClearXYVel
	DSPRITES	f44b01,f45a01,f45a01,f45a01,f46a01,f46a01,f46a01,f46a01
	DSPRITE	 1
	NEXTSPRITE 1
	NEXTSPRITE 1
;	SOUNDS	 FielderCatchBall
	SOUNDS	StopsGrounder

	NEXTSPRITE 1
	INPUTSUB	SpeedUp	;Set Input sub to check for break out
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	 -1
	SYSTEM	SetCount10
    	SETRAM	B_MOVABLE,1
	SYSTEM	ClearXYVel
	INPUTSUB	FIELDER_CONTROLS
	STOPANIM

	.export	BareHand	
BareHand:
;	FRAMERATE	30
	SETRAM	B_HASBALL,1
	SYSTEM	SetCount30
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SYSTEM	ClearXYVel
	DSPRITES	f35a01,f35b01,f35c01,f35d01,f35e01,f35f01,f35g01,f35h01
	DSPRITE	 2
	NEXTSPRITE 2
         	SOUNDS	SayPlayerName
	NEXTSPRITE 2
;    	INPUTSUB	FIELDER_CONTROLS
	NEXTSPRITE 2
;	SYSTEM	ClearXYVel
	INPUTSUB	SpeedUp	;Set Input sub to check for break out
	NEXTSPRITE -1
	FRICTION
	NEXTSPRITE -1
	NEXTSPRITE -1
	FRICTION
	NEXTSPRITE -1
;	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
;	DSPRITE	 5
	SYSTEM	SetCount10
    	SETRAM	B_MOVABLE,1
	SYSTEM	ClearXYVel
    	INPUTSUB	FIELDER_CONTROLS
	STOPANIM



RunGBall:
	FASTER	5100,DiveGBall	;running Fast (dive) 7000
	SYSTEM	SetCount30
	SETRAMW	DURATIONRESET,4	; Set For 10HZ Anim
	DSPRITES	ft1a01,ft2b01,ft3c01,ft4d01,ft6f01,ft6f01,ft7g01,ft8h01
	FRICTION
	DSPRITE	 1
	FRICTION
	NEXTSPRITE 1
	FRICTION
	NEXTSPRITE 1
	FRICTION
;	SOUNDS	FielderCatchBall
	SOUNDS	StopsGrounder
;    	INPUTSUB	FIELDER_CONTROLS
	FRICTION
	INPUTSUB	SpeedUp	;Set Input sub to check for break out
	NEXTSPRITE -1
	FRICTION
	NEXTSPRITE -1
	FRICTION
;	FRICTION
;	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
;	FRICTION
;	DSPRITE	 -1
	SYSTEM	ClearXYVel
	SYSTEM	SetCount10
    	SETRAM	B_MOVABLE,1
	INPUTSUB	FIELDER_CONTROLS
	STOPANIM


RegularCatch:
	BALLHIGHER 8*12*256,FlyBall
	FASTER	1100,RunRegularCatch	;running or standing.
	IFPOWERUP	HotDog1
	SYSTEM	SetCount30
	SETRAMW	DURATIONRESET,2	; Set For 10HZ Anim
	LOADABS	outs
	JUMPCMP	3,HotDog1
	SETRAM	B_HASBALL,1
	SOUNDS	CatchesBallNormal
	SYSTEM	ClearXYVel
;	DSPRITES	f70a01,f51h01,f51a01,f51b01,f51b01,f52f01,f52a01,f52b01
	DSPRITES	f50a01,f51h01,fxka01,fxka01,f51b01,fxkb01,fxkb01,f52b01
	DSPRITE	 1
	NEXTSPRITE 1
	INPUTSUB	SpeedUp	;Set Input sub to check for break out
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1	;was 4
	NEXTSPRITE -1	;was 4
;	SOUNDS	 FielderCatchBall
BackUpTop:
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	 5
	SYSTEM	SetCount10
	SETRAM	B_MOVABLE,1
	SYSTEM	ClearXYVel
	INPUTSUB	FIELDER_CONTROLS
	JUMP	BackUpTop
	STOPANIM


HotDog1:
	SYSTEM	ClearXYVel
	JUMPRND	7       
	



	ADDRESS	HotDogA     	;Behind the back
	ADDRESS	HotDogB	;Turn around behind back
	ADDRESS	HotDogC	;bare hand catch
	ADDRESS	HotDogD	;behind back reach
	ADDRESS	HotDogE	;between legs
	ADDRESS	HotDogA	;Behind the back
	ADDRESS	HotDogB	;Turn around behind back
	ADDRESS	HotDogE	;bare hand catch

HotDogA:			;High behind the back
	SETRAM	B_HASBALL,1
	SPRITE	fxna01,1
	SPRITE	fxna02,1
	SPRITE	fxna03,1
	SPRITE	fxna04,1
;	SOUNDS	 FielderCatchBall
	SPRITE	fxna05,5
	SPRITE	fxna06,4
	SPRITE	fxna07,4
	SPRITE	fxna08,4
	SPRITE	fxna09,4
	SPRITE	fxna10,10
	JUMP	FinishHot

HotDogB:			;Turn around behind back catch
	SETRAM	B_HASBALL,1
	SPRITE	fxta01,1
	SPRITE	fxta02,1
	SPRITE	fxta03,1
	SPRITE	fxta04,1
;	SOUNDS	 FielderCatchBall
	SPRITE	fxta05,5
	SPRITE	fxta06,4
	SPRITE	fxta07,4
	SPRITE	fxta08,4
	SPRITE	fxta09,4
	SPRITE	fxta10,10
	JUMP	FinishHot

HotDogC:			;Bare Hand med catch
	SETRAM	B_HASBALL,1
	SPRITE	fxsa01,1
	SPRITE	fxsa02,1
	SPRITE	fxsa03,1
	SPRITE	fxsa04,1
;	SOUNDS	 FielderCatchBall
	SPRITE	fxsa05,2
	SPRITE	fxsa06,2
	SPRITE	fxsa07,2
	SPRITE	fxsa08,2
	SPRITE	fxsa09,2
	SPRITE	fxsa10,5
	JUMP	FinishHot

HotDogD:			;Behind back reach catch
	SETRAM	B_HASBALL,1
	SPRITE	fxoa01,1
	SPRITE	fxoa02,1
	SPRITE	fxoa03,1
	SPRITE	fxoa04,1
;	SOUNDS	 FielderCatchBall
	SPRITE	fxoa05,5
	SPRITE	fxoa06,4
	SPRITE	fxoa07,4
	SPRITE	fxoa08,4
	SPRITE	fxoa09,4
	SPRITE	fxoa10,10
	JUMP	FinishHot


HotDogE:			;between legs
	SETRAM	B_HASBALL,1
	SPRITE	fxpa01,1
	SPRITE	fxpa02,1
	SPRITE	fxpa03,1
	SPRITE	fxpa04,1
;	SOUNDS	 FielderCatchBall
	SPRITE	fxpa05,5
	SPRITE	fxpa06,4
	SPRITE	fxpa07,4
	SPRITE	fxpa08,4
	SPRITE	fxpa09,4
	SPRITE	fxpa10,10
	JUMP	FinishHot


HotDogF:			;flip catch
	SETRAM	B_HASBALL,1
	SPRITE ff9a01,1
	SPRITE ff9a02,1
	SOUNDS	FielderHitsGrass
	SPRITE ff9a03,1
	SPRITE ff9a04,1
	SETRAM BallOnGround,1
	SPRITE ff9a05,1
	SPRITE ff9a06,1
	SPRITE ff9a07,3
	SPRITE ff9a08,4
	SETRAM BallOnGround,1
	SPRITE fgua01,5
	SPRITE fgua02,5
	SPRITE fgua03,5
	SETRAM BallOnGround,1
	SPRITE fgua04,5
	SPRITE fgua05,5
	SPRITE fgua06,5
	SETRAM BallOnGround,1
	SPRITE fgua07,5
	SPRITE fgua08,5
	SETRAM BallOnGround,1
	SPRITE f61a01,4
	SPRITE f61a02,4
	SPRITE f61a03,4
	SETRAM BallOnGround,1
	SPRITE f61a04,4
	SPRITE f61a05,4
	SPRITE f61a06,4
	SPRITE f61a05,4
	SETRAM BallOnGround,1
	SPRITE f61a04,4
	SPRITE f61a03,4
	SPRITE f61a02,4
	SPRITE f61a01,4
	
;	JUMP	FinishHot



FinishHot:
	SOUNDS	CatchesBallExciting
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
	INPUTSUB	FIELDER_CONTROLS
	SYSTEM	ClearXYVel
	STOPANIM



RunRegularCatch:
	SETRAM	B_HASBALL,1
	IFPOWERUP	NoPower_2
	SYSTEM	SetCount30
	SETRAMW	DURATIONRESET,4	; Set For 10HZ Anim
;bri	DSPRITES	f53a01,f53b01,f53c01,f53d01,f53e01,f53f01,f53g01,f53h01
	DSPRITES	f53a01,f53b01,f53c01,f53d01,f53e01,f53f01,f53g01,f53h01
	FRICTION
	DSPRITE	 1
;	SOUNDS	 FielderCatchBall
	FRICTION
	NEXTSPRITE 1
	FRICTION
;	SOUNDS	CatchesBallExciting
  	SOUNDS	CatchesBallNormal

	NEXTSPRITE 1
	FRICTION
	NEXTSPRITE 1
	FRICTION
	NEXTSPRITE 2
	FRICTION
	INPUTSUB	SpeedUp	;Set Input sub to check for break out
	NEXTSPRITE -1
	FRICTION
	NEXTSPRITE -1
	FRICTION
	NEXTSPRITE -1
	FRICTION
;	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
;	DSPRITE	 5
	FRICTION
	SYSTEM	ClearXYVel
	SYSTEM	SetCount10
	SETRAM	B_MOVABLE,1
	INPUTSUB	FIELDER_CONTROLS
	STOPANIM


DoDive:
	JUMP	NoPower_2
	BALLHIGHER  3*12*256,MedDive
	JUMP	LowDive	;bri
	FASTER	100,MedDive	;running or standing.

MedTumble:		;Diving Rolling Catch
	UPDATE	AnimPlayer
;	SYSTEM	FixHasBall	; Fixup When Player Has Already Caught
;	SETRAM	B_MOVABLE,0
	SYSTEM	SetCount30
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
MedTumble_1:
	DSPRITES	f87h01,f87b01,f87c01,f87d01,f87d01,f87f02,f87f01,f87h01
	DSPRITE	 3	; 8 Frames
	NEXTSPRITE 3
	NEXTSPRITE 3
	NEXTSPRITE 3
	NEXTSPRITE 3
	INPUTSUB	SpeedUp	;Set Input sub to check for break out
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	SYSTEM	ClearXYVel
			 ; Do Getups After Dives
	SETRAM	B_HASBALL,1
			 ; Do Getups After Dives
	DSPRITES	fgua01,fgub01,fguc01,fgud01,fgud01,fguf01,fguf01,fguh01
	DSPRITE	 -1	  ; 8 Frames
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	NEXTSPRITE -1
	SYSTEM	SetCount10
	SYSTEM	ClearXYVel
	SYSTEM	ClearTracks
	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
	INPUTSUB	FIELDER_CONTROLS

MedTum_2:	  		
			; Ready to Throw Ball frame
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	MedTum_2


MedDive:		;Diving  Catch
;	IFPOWERUP	PowerMedDive	;If powered jump
	JUMP	NoPower_2	;jump if not
PowerMedDive:
;	SYSTEM	StrikemObj
       	BALLFARTHER 7,10*12*256,NoPower_2	;Is he close enough?

;	SYSTEM	S3Power	;Check for p3 power
;	IFHASPOWER 7,YesPower	;did he get it?
;	JUMP	NoPower_2	;if not jump
YesPower
;	SYSTEM	ClearPowerF	;clear powernum
;	SYSTEM	DoubleXYVel	;Double Velocity
	FACEBALL	1
	LUNGE	7
	JUMP	MedDive_1	

NoPower_2:
;	BALLFARTHER 15,15*12*256,MedDiv_2	;Is he close enough?
;	FACEBALL	1
;	LUNGE	15
MedDive_1:
	UPDATE	AnimPlayer
	SYSTEM	FixHasBall	; Fixup When Player Has Already Caught
	SYSTEM	SetCount30
	SETRAMW	DURATIONRESET,2	; Set For 10HZ Anim
	DSPRITES	ff9a01,f87b01,ffba01,f87d01,ffaa01,f87f01,ffca01,f87h01
;	DSPRITES	f84a01,f84b01,f84c01,f84d01,f84e01,f84f01,f84g01,f84h01
;	DSPRITES	f79a01,f89b01,f89c01,f89d01,f89e01,f89f01,f89g01,f89h01
	DSPRITE	 2	; 8 Frames
	NEXTSPRITE 2
	NEXTSPRITE 2
	NEXTSPRITE 2
	NEXTSPRITE 2
	NEXTSPRITE 2
	FRICTION
	NEXTSPRITE 2
	FRICTION
	NEXTSPRITE 2
	FRICTION
	SOUNDS	CatchesBallExciting
	SYSTEM	ClearXYVel
			 ; Do Getups After Dives
	SETRAM	B_HASBALL,1

	DSPRITES	fgua01,fgub01,fguc01,fgud01,fgud01,fguf01,fguf01,fguh01
	DSPRITE	 2	  ; 8 Frames
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	FRICTION
;	SETRAM	B_MOVABLE,1	; Let Player Move
	SYSTEM	ClearTracks
	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
;	SYSTEM	FixHasBall	; Fixup When Player Has Already Caught
;	SYSTEM	GiveControlsToFielder
	INPUTSUB	FIELDER_CONTROLS

MedDiv_2:	  		
			; Ready to Throw Ball frame
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	MedDiv_2


PowerDive:		;Diving  POWER Catch With Lunge

;	BALLFARTHER 15,40*12*256,MedDive_1
;	FACEBALL	1
;	LUNGE	15

	UPDATE	AnimPlayer
	SYSTEM	FixHasBall	; Fixup When Player Has Already Caught
;	SETRAM	B_MOVABLE,0
	SYSTEM	DoubleXYVel
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
;	DSPRITES	f84a01,f84b01,f84c01,f84d01,f84e01,f84f01,f84g01,f84h01
	DSPRITES	f79a01,f89b01,f89c01,f89d01,f89e01,f89f01,f89g01,f89h01
	DSPRITE	 3	; 8 Frames
	NEXTSPRITE	3
	NEXTSPRITE	3
	NEXTSPRITE	4
	NEXTSPRITE	4
	NEXTSPRITE	3
	FRICTION
	NEXTSPRITE	3
	FRICTION
	NEXTSPRITE	3
	SYSTEM	ClearXYVel
			 ; Do Getups After Dives
	DSPRITES	fgua01,fgub01,fguc01,fgud01,fgud01,fguf01,fguf01,fguh01
	DSPRITE	 -1	  ; 8 Frames
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	SYSTEM	ClearXYVel
;	SETRAM	B_MOVABLE,1	; Let Player Move
	SYSTEM	ClearTracks
	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
;	SYSTEM	FixHasBall	; Fixup When Player Has Already Caught
;	SYSTEM	GiveControlsToFielder
	INPUTSUB	FIELDER_CONTROLS

PowDiv_2:	  		
			; Ready to Throw Ball frame
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	PowDiv_2


LowDive:
;	IFPOWERUP	KneeSlide
;	BALLFARTHER 12,20*12*256,MedDive_1
;	FACEBALL	1
;	LUNGE	12
	UPDATE	AnimPlayer
;	SETRAM	B_MOVABLE,0
	SYSTEM	FixHasBall	; Fixup When Player Has Already Caught
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	DSPRITES	f89b01,f89b01,f89c01,f89d01,f89e01,f89f01,f89g01,f89h01
	DSPRITE	 -1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	SYSTEM	ClearXYVel
		   	;Do Getups After Dives
	DSPRITES	fgub01,fgub01,fguc01,fgud01,fgue01,fguf01,fgug01,fguh01
	DSPRITE	 2
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	
	SYSTEM	ClearTracks
;	SETRAM	B_MOVABLE,1	; Let Player Move

	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
;	SYSTEM	GiveControlsToFielder
	INPUTSUB	FIELDER_CONTROLS
	STOPANIM
;	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
;	DSPRITE	-1
LowDive_2:
			; Ready to Throw Ball frame
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	LowDive_2	; Jump back to ready frame


KneeSlide:
	UPDATE	AnimPlayer
	SYSTEM	FixHasBall	; Fixup When Player Has Already Caught
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	DSPRITES	f79a01,f79a01,f79a01,f79a01,f79h01,f79h01,f79h01,f79h01
	DSPRITE	 -1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1

	SYSTEM	ClearXYVel
	
	SYSTEM	ClearTracks

	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
	INPUTSUB	FIELDER_CONTROLS
	STOPANIM
;	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
;	DSPRITE	-1
KneeSlide_2:
			; Ready to Throw Ball frame
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	KneeSlide_2





JumpBall:
;	FASTER	100,HighDive	;running or standing.
	IFPOWERUP	PowerJump
;	UPDATE	AnimPlayer
NoPowerJump:
	SYSTEM	FixHasBall	; Fixup When Player Has Already Caught
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	DSPRITES	f33a01,f33b01,f33c01,f33d01,f33e01,f33f01,f33g01,f33h01
	DSPRITE	 2
	SYSTEM	ClearXYVel
	SYSTEM	SetJumpZ
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	5
	NEXTSPRITE	7
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
;	NEXTSPRITE	2


	SYSTEM	ClearXYVel
	
	SYSTEM	ClearTracks
;	SETRAM	B_MOVABLE,1	; Let Player Move

	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
;	SYSTEM	GiveControlsToFielder
	INPUTSUB	FIELDER_CONTROLS
	STOPANIM
;	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
;	DSPRITE	-1
JumpJ:
			; Ready to Throw Ball frame
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	JumpJ


PowerJump:
;	BALLFARTHER 12,10*12*256,MedDive_1	;Is he close enough?
;	FACEBALL	1
;	LUNGE	12
;	UPDATE	AnimPlayer
	SYSTEM	PSuperJump
	IFHASPOWER 2,YesPowerJ	;did he get it?
	JUMP	NoPowerJump	;if not jump
YesPowerJ:
;	BALLFARTHER 12,25*12*256,NoPowerJump	;Is he close enough?
;	FACEBALL	1
;	LUNGE	12
        	SOUNDS	FireBall	;Fire Sound
	SYSTEM	ClearPowerF	;clear powernum
;	FACEBALL	1
	SYSTEM	FixHasBall	; Fixup When Player Has Already Caught
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	DSPRITES	f33a01,f33b01,f33c01,f33d01,f33e01,f33f01,f33g01,f33h01
;	DSPRITES	f34a01,f34b01,f34c01,f34d01,f34e01,f34f01,f34g01,f34h01
	DSPRITE	 3
	SYSTEM	SetSJumpZ
	NEXTSPRITE	2
	NEXTSPRITE	3
	NEXTSPRITE	3
	NEXTSPRITE	4
	NEXTSPRITE	4
	NEXTSPRITE	4
	NEXTSPRITE	3
	NEXTSPRITE	2
	SOUNDS	PowerPitch
	NEXTSPRITE	2
	NEXTSPRITE	2
;	NEXTSPRITE	2

	SYSTEM	ClearXYVel
	
	SYSTEM	ClearTracks
;	SETRAM	B_MOVABLE,1	; Let Player Move

	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
;	SYSTEM	GiveControlsToFielder
	INPUTSUB	FIELDER_CONTROLS
	STOPANIM
;	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
;	DSPRITE	-1
PJump:
			; Ready to Throw Ball frame
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	PJump



HighDive:
	IFPOWERUP	PowerHighDive
	JUMP	NoPower_1
PowerHighDive:
    ;	SYSTEM	DoubleXYVel
NoPower_1:
	BALLFARTHER 12,20*12*256,MedDive_1	;Is he close enough?
	FACEBALL	1
	LUNGE	12
	SYSTEM	SetJumpZ
	UPDATE	AnimPlayer
;	SETRAM	B_MOVABLE,0
	SYSTEM	FixHasBall	; Fixup When Player Has Already Caught
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	DSPRITES	f83a01,f83b01,f83c01,f83d01,f83e01,f83f01,f83g01,f83h01
	DSPRITE	 3
	FRICTION
	NEXTSPRITE	3
	FRICTION
	NEXTSPRITE	3
	FRICTION
	NEXTSPRITE	3
	FRICTION
	NEXTSPRITE	7
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE                           	2
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ClearXYVel
		   	;Do Getups After Dives
	DSPRITES	fgua01,fgub01,fguc01,fgud01,fgue01,fguf01,fgug01,fguh01
	DSPRITE	 -1
	NEXTSPRITE	-1
	NEXTSPRITE	-1
	NEXTSPRITE	-1
	NEXTSPRITE	-1
	NEXTSPRITE	-1
	NEXTSPRITE	-1
	NEXTSPRITE	-1
	
	SYSTEM	ClearTracks
;	SETRAM	B_MOVABLE,1	; Let Player Move

	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
;	SYSTEM	GiveControlsToFielder
	INPUTSUB	FIELDER_CONTROLS
	STOPANIM
;	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
;	DSPRITE	-1
tmp1:
			; Ready to Throw Ball frame
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	tmp1



PowerJump3:
	UPDATE	AnimPlayer
;	SYSTEM	PSuperJump3
;	IFHASPOWER 2,YesPowerJ3	;did he get it?
;	JUMP	NoPowerJump	;if not jump
YesPowerJ3:
	BALLFARTHER 12,25*12*256,NoPowerJump	;Is he close enough?
	SYSTEM	PSuperJump3
	IFHASPOWER 2,YesPowerJ4	;did he get it?
	JUMP	NoPowerJump	;if not jump
YesPowerJ4
	FACEBALL	1
	LUNGE	12
	SYSTEM	ClearPowerF	;clear powernum
;	FACEBALL	1
        	SOUNDS	FireBall	;Fire Sound
	SYSTEM	FixHasBall	; Fixup When Player Has Already Caught
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	DSPRITES	f83a01,f83b01,f83c01,f83d01,f83e01,f83f01,f83g01,f83h01
;	DSPRITES	f34a01,f34b01,f34c01,f34d01,f34e01,f34f01,f34g01,f34h01
	DSPRITE	 3
;	SYSTEM	SetSJumpZ
	NEXTSPRITE	2
	NEXTSPRITE	3
	NEXTSPRITE	3
	NEXTSPRITE	4
	NEXTSPRITE	4
	NEXTSPRITE	4
	NEXTSPRITE	3
	NEXTSPRITE	2
	NEXTSPRITE	2
	SOUNDS	PowerPitch
	NEXTSPRITE	2
;	NEXTSPRITE	2
	SYSTEM	ClearXYVel
	DSPRITES	fgua01,fgub01,fguc01,fgud01,fgue01,fguf01,fgug01,fguh01
	DSPRITE	 -1
	NEXTSPRITE	-1
	NEXTSPRITE	-1
	NEXTSPRITE	-1
	NEXTSPRITE	-1
	NEXTSPRITE	-1
	NEXTSPRITE	-1
	NEXTSPRITE	-1
	
	SYSTEM	ClearTracks
;	SETRAM	B_MOVABLE,1	; Let Player Move

	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
;	SYSTEM	GiveControlsToFielder
	INPUTSUB	FIELDER_CONTROLS
	STOPANIM
;	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
;	DSPRITE	-1
PJump3:
			; Ready to Throw Ball frame
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	PJump3





;***************************************************************************

ThrowToF:
	SYSTEM	ToFirst           
	INPUTSUB	0
	CLOSER	FIRSTBASEX,FIRSTBASEY,50*12*256,TossToFirst ;Close? Toss
	FASTER	2000,FirstRunT     	;Do Running Throw?
	IFIAM	SecondCover,IAmSecond	;If Im covering first, Jump	
          	JUMP	NotSecondCover
IAmSecond:
	SYSTEM	DoublePlay
NotSecondCover:
	DIRJUMP	FIRSTBASEX,FIRSTBASEY,Throw1out,Throw2out,Throw3out,Throw4out,Throw5out,Throw6out,Throw7out,Throw8out
FirstRunT:			;Running Throw to First
	DIRJUMP	FIRSTBASEX,FIRSTBASEY,Throw1,Throw2,Throw3,Throw4,Throw5,Throw6,Throw7,Throw8

TossToFirst:
	FASTER	2100,RunTossFirst     	;Do Running Throw?
	DIRJUMP	FIRSTBASEX,FIRSTBASEY,SThrowT1,SThrowT2,SThrowT3,SThrowT4,SThrowT5,SThrowT6,SThrowT7,SThrowT8
RunTossFirst:
	DIRJUMP	FIRSTBASEX,FIRSTBASEY,ThrowT1,ThrowT2,ThrowT3,ThrowT4,ThrowT5,ThrowT6,ThrowT7,ThrowT8



ThrowToS:
	SYSTEM	ToSecond
	INPUTSUB	0
	CLOSER	SECONDBASEX,SECONDBASEY,30*12*256,TossToSecond
	FASTER	2500,SecondRunT	;Do Running Throw?
	DIRJUMP	SECONDBASEX,SECONDBASEY,Throw1out,Throw2out,Throw3out,Throw4out,Throw5out,Throw6out,Throw7out,Throw8out
SecondRunT:
	DIRJUMP	SECONDBASEX,SECONDBASEY,Throw1,Throw2,Throw3,Throw4,Throw5,Throw6,Throw7,Throw8
TossToSecond:	
	FASTER	2150,RunTossSecond     	;Do Running Throw?
	DIRJUMP	SECONDBASEX,SECONDBASEY,SThrowT1,SThrowT2,SThrowT3,SThrowT4,SThrowT5,SThrowT6,SThrowT7,SThrowT8
RunTossSecond:
	DIRJUMP	SECONDBASEX,SECONDBASEY,ThrowT1,ThrowT2,ThrowT3,ThrowT4,ThrowT5,ThrowT6,ThrowT7,ThrowT8

ThrowToT:
	SYSTEM	ToThird
	INPUTSUB	0
	CLOSER	THIRDBASEX,THIRDBASEY,30*12*256,TossToThird
	FASTER	2500,ThirdRunT	;Do Running Throw?
	DIRJUMP	THIRDBASEX,THIRDBASEY,Throw1out,Throw2out,Throw3out,Throw4out,Throw5out,Throw6out,Throw7out,Throw8out
ThirdRunT:
	DIRJUMP	THIRDBASEX,THIRDBASEY,Throw1,Throw2,Throw3,Throw4,Throw5,Throw6,Throw7,Throw8
TossToThird:
	FASTER	2150,RunTossThird     	;Do Running Throw?
	DIRJUMP	THIRDBASEX,THIRDBASEY,SThrowT1,SThrowT2,SThrowT3,SThrowT4,SThrowT5,SThrowT6,SThrowT7,SThrowT8
RunTossThird:
	DIRJUMP	THIRDBASEX,THIRDBASEY,ThrowT1,ThrowT2,ThrowT3,ThrowT4,ThrowT5,ThrowT6,ThrowT7,ThrowT8

	
ThrowToH:
	SYSTEM	ToHome	;Do Running Throw?
	DIRJUMP	HOMEPLATEX,HOMEPLATEY,Throw1out,Throw2out,Throw3out,Throw4out,Throw5out,Throw6out,Throw7out,Throw8out
;	DIRJUMP	THIRDEX,THIRDBASEY,Throw1,Throw2,Throw3,Throw4,Throw5,Throw6,Throw7,Throw8





DoubleThrow: 	    	;Throw Straight Down
	IFPOWERUP	PowerDouble
	JUMP	DoubleRThrow	;No Power then Regular
PowerDouble:
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fspb01,fspb01,fspc01,fspd01,fspe01,fspf01,fspg01,fsph01
	DSPRITE	 1
	NEXTSPRITE	1
	NEXTSPRITE	1
	SYSTEM	ThrowBall
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	DSPRITES	fgua01,fgub01,fguc01,fgud01,fgue01,fguf01,fgug01,fguh01
	DSPRITE	 5
	NEXTSPRITE	3
	NEXTSPRITE	3
	NEXTSPRITE	3
	NEXTSPRITE	3
	NEXTSPRITE	3
	NEXTSPRITE	3
	NEXTSPRITE	3
	
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
DP1:
	LASTFRAME	30
	JUMP	DP1


DoubleRThrow: 	    	;Throw Straight Down
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fdpa01,fdpb01,fdpc01,fdpd01,fdpe01,fdpf01,fdpg01,fdph01
;	DSPRITES	fspb01,fspb01,fspc01,fspd01,fspe01,fspf01,fspg01,fsph01
	DSPRITE	 2
	NEXTSPRITE	1
	NEXTSPRITE	1
	SYSTEM	ThrowBall
	NEXTSPRITE	-1
	NEXTSPRITE	-1
	NEXTSPRITE	-1
;	NEXTSPRITE	-1
	
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
DP2:
	LASTFRAME	30
	JUMP	DP2





;*************************************************************************
;* All throws Below are Running Type Throws. There Will be the same      *
;* For Standing throws. Currently there is no difference between         *
;* infielder and an outfielder.	                        *
;*************************************************************************
Throw1:		    	;Throw Straight Down
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	ft1a09,ft2a09,ft3a09,ft4a09,ft5a09,ft6a09,ft7a09,ft8a09

	DSPRITE	 1
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	1
	SYSTEM	ThrowBall
;	FRICTION
	NEXTSPRITE	1
;	FRICTION
	FRICTION
	NEXTSPRITE	8
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
To1:
	LASTFRAME	30
	JUMP	To1


Throw2:			;Throw Down Right
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	ft1b09,ft2b09,ft3b09,ft4b09,ft5b09,ft6b09,ft7b09,ft8b09
	DSPRITE	 1
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	1
;	FRICTION
	NEXTSPRITE	1
	SYSTEM	ThrowBall
	FRICTION
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
To2:
	LASTFRAME	30
	JUMP	To2

Throw3:			; Throw To the Right
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	ft1c09,ft2c09,ft3c09,ft4c09,ft5c09,ft6c09,ft7c09,ft8c09
	DSPRITE	 1
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	1
;	FRICTION
	NEXTSPRITE	1
;	FRICTION
	SYSTEM	ThrowBall
	FRICTION
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	SETRAM	B_MOVABLE,1
	DSPRITE	 5
;	INPUTSUB	FIELDER_CONTROLS
To3:
	LASTFRAME	30
	JUMP	To3

Throw4:			; Throw Up Right
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	ft1d09,ft2d09,ft3d09,ft4d09,ft5d09,ft6d09,ft7d09,ft8d09
	DSPRITE	 2
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	1
;	FRICTION
	NEXTSPRITE	1
	SYSTEM	ThrowBall
	FRICTION
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

To4:
	LASTFRAME	30
	JUMP	To4

Throw5:			; Throw Straight Up
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	ft1e09,ft2e09,ft3e09,ft4e09,ft5e09,ft6e09,ft7e09,ft8e09
	DSPRITE	 2
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	1
;	FRICTION
	NEXTSPRITE	1
	SYSTEM	ThrowBall
	FRICTION
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
To5:
	LASTFRAME	30
	JUMP	To5

Throw6:			; throw Up left
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	ft1f09,ft2f09,ft3f09,ft3f09,ft5f09,ft6f09,ft7f09,ft8f09
	DSPRITE	 2
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	1
;	FRICTION
	NEXTSPRITE	1
	SYSTEM	ThrowBall
	FRICTION
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
To6:
	LASTFRAME	30
	JUMP	To6

Throw7:			;Throw Straight Left
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	ft1g09,ft2g09,ft3g09,ft3g09,ft5g09,ft6g09,ft7g09,ft8g09
	DSPRITE	 2
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	1
;	FRICTION
	NEXTSPRITE	1
	SYSTEM	ThrowBall
	FRICTION
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

To7:
	LASTFRAME	30
	JUMP	To7

Throw8:			; Throw Down left
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	ft1h09,ft2h09,ft3h09,ft4h09,ft5h09,ft6h09,ft7h09,ft8h09
	DSPRITE	 2
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	2
;	FRICTION
	NEXTSPRITE	1
;	FRICTION
	NEXTSPRITE	1
	SYSTEM	ThrowBall
	FRICTION		
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

To8:
	LASTFRAME	30
	JUMP	To8

;*************************************************************************
;* All throws Below are Standing Type Throws. There are be the same      *
;* For Running Throws. Currently there is no difference between a        *
;* infielder and an outfielder.	                        *
;*************************************************************************

Throw1out:		    	;Throw Straight Down
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	LOADABS	IsOnGround
	JUMPCMP	1,KneeThrow1
	DSPRITES	fs1a01,fs2a01,fs3a01,fs4a01,fs5a01,fs6a01,fs7a01,fs8a01
	SEMCLR	IsOnGround
	JUMP	NoKnee1
KneeThrow1:
	SEMSET	ShouldStand
	DSPRITES	fgta01,fgta01,fgta01,fgta01,fgta01,fgta01,fgta01,fgta01
NoKnee1:
	SEMCLR	IsOnGround
	SYSTEM	ClearXYVel
	DSPRITE	 3
	NEXTSPRITE 3
	NEXTSPRITE 2
	NEXTSPRITE 3
	SYSTEM	 ThrowBall
	NEXTSPRITE 3
;	SYSTEM	 ThrowBall
	NEXTSPRITE 3
	
	NEXTSPRITE 3
	NEXTSPRITE 6;15
	FACEBALL	 1

	LOADABS	ShouldStand
	JUMPCMP	1,GetUpAnim
	SEMCLR	IsOnGround

	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
	DSPRITE	5

	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
To1out:
	LASTFRAME	30
	JUMP	To1out

Throw2out:		    	;Throw Straight Down
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fs1b01,fs2b01,fs3b01,fs4b01,fs5b01,fs6b01,fs7b01,fs8b01
	LOADABS	IsOnGround
	JUMPCMP	1,KneeThrow2
	DSPRITES	fs1b01,fs2b01,fs3b01,fs4b01,fs5b01,fs6b01,fs7b01,fs8b01
	SEMCLR	IsOnGround
	JUMP	NoKnee2
KneeThrow2:
	SEMSET	ShouldStand
	DSPRITES	fgtb01,fgtb01,fgtb01,fgtb01,fgtb01,fgtb01,fgtb01,fgtb01
NoKnee2:
	SEMCLR	IsOnGround
	SYSTEM	ClearXYVel
	DSPRITE	 3
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	1
	SYSTEM	ThrowBall
	NEXTSPRITE	1
;	SYSTEM	ThrowBall
	NEXTSPRITE	1
	NEXTSPRITE	1
	NEXTSPRITE	6;15
	SYSTEM	ClearXYVel
	FACEBALL	1
	LOADABS	ShouldStand
	JUMPCMP	1,GetUpAnim
	SEMCLR	IsOnGround

	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
	DSPRITE	5
	
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

To2out:
	LASTFRAME	30
	JUMP	To2out

Throw3out:		    	;Throw Straight Down
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	LOADABS	IsOnGround
	JUMPCMP	1,KneeThrow3
	DSPRITES	fs1c01,fs2c01,fs3c01,fs4c01,fs5c01,fs6c01,fs7c01,fs8c01
	SEMCLR	IsOnGround
	JUMP	NoKnee3
KneeThrow3:
	SEMSET	ShouldStand
	DSPRITES	fgtc01,fgtc01,fgtc01,fgtc01,fgtc01,fgtc01,fgtc01,fgtc01
NoKnee3:
	SEMCLR	IsOnGround

	SYSTEM	ClearXYVel
	DSPRITE	 3
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	1
	SYSTEM	ThrowBall
	NEXTSPRITE	1
;	SYSTEM	ThrowBall
	NEXTSPRITE	1
	NEXTSPRITE	1
	NEXTSPRITE	6;15
	SYSTEM	ClearXYVel
	FACEBALL	1
	LOADABS	ShouldStand
	JUMPCMP	1,GetUpAnim
	SEMCLR	IsOnGround

	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
	DSPRITE	5

	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

To3out:
	LASTFRAME	30
	JUMP	To3out

Throw4out:		    	;Throw Straight Down
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	LOADABS	IsOnGround
	JUMPCMP	1,KneeThrow4
	DSPRITES	fs1d01,fs2d01,fs3d01,fs4d01,fs5d01,fs6d01,fs7d01,fs8d01
	SEMCLR	IsOnGround
	JUMP	NoKnee4
KneeThrow4:
	SEMSET	ShouldStand
	DSPRITES	fgtd01,fgtd01,fgtd01,fgtd01,fgtd01,fgtd01,fgtd01,fgtd01
NoKnee4:
	SEMCLR	IsOnGround
	SYSTEM	ClearXYVel
	DSPRITE	 3
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	1
	SYSTEM	ThrowBall
	NEXTSPRITE	1
;	SYSTEM	ThrowBall
	NEXTSPRITE	1
	NEXTSPRITE	1
	NEXTSPRITE                            6
	SYSTEM	ClearXYVel
	FACEBALL	1
	LOADABS	ShouldStand
	JUMPCMP	1,GetUpAnim
	SEMCLR	IsOnGround

	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
	DSPRITE	5
	
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

To4out:
	LASTFRAME	30
	JUMP	To4out

Throw5out:		    	;Throw Straight Down
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0

	LOADABS	IsOnGround
	JUMPCMP	1,KneeThrow5
	DSPRITES	fs1d01,fs2e01,fs3e01,fs4e01,fs5e01,fs6e01,fs7e01,fs8e01
	SEMCLR	IsOnGround
	JUMP	NoKnee5
KneeThrow5:
	SEMSET	ShouldStand
	DSPRITES	fgte01,fgte01,fgte01,fgte01,fgte01,fgte01,fgte01,fgte01
NoKnee5:
	SEMCLR	IsOnGround
	
	SYSTEM	ClearXYVel
	DSPRITE	 3
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	1
;	SYSTEM	ThrowBall
	NEXTSPRITE	1
	NEXTSPRITE	1
	NEXTSPRITE                           6;15
	SYSTEM	ClearXYVel
	FACEBALL	1
	LOADABS	ShouldStand
	JUMPCMP	1,GetUpAnim
	SEMCLR	IsOnGround

	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
	DSPRITE	5
	
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

To5out:
	LASTFRAME	30
	JUMP	To5out

Throw6out:		    	;Throw Straight Down
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	LOADABS	IsOnGround
	JUMPCMP	1,KneeThrow6
	DSPRITES	fs1f01,fs2f01,fs3f01,fs4f01,fs5f01,fs6f01,fs7f01,fs8f01
	SEMCLR	IsOnGround
	JUMP	NoKnee6
KneeThrow6:
	SEMSET	ShouldStand
	DSPRITES	fgtf01,fgtf01,fgtf01,fgtf01,fgtf01,fgtf01,fgtf01,fgtf01
NoKnee6:
	SEMCLR	IsOnGround

	SYSTEM	ClearXYVel
	DSPRITE	 3
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	1
;	SYSTEM	ThrowBall
	NEXTSPRITE	1
	NEXTSPRITE	1
	NEXTSPRITE	6;15
	SYSTEM	ClearXYVel
	FACEBALL	1
	LOADABS	ShouldStand
	JUMPCMP	1,GetUpAnim
	SEMCLR	IsOnGround

	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
	DSPRITE	5
	
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

To6out:
	LASTFRAME	30
	JUMP	To6out

Throw7out:		    	;Throw Straight Down
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	LOADABS	IsOnGround
	JUMPCMP	1,KneeThrow7
	DSPRITES	fs1g01,fs2g01,fs3g01,fs4g01,fs5g01,fs6g01,fs7g01,fs8g01
	SEMCLR	IsOnGround
	JUMP	NoKnee7
KneeThrow7:
	SEMSET	ShouldStand
	DSPRITES	fgtg01,fgtg01,fgtg01,fgtg01,fgtg01,fgtg01,fgtg01,fgtg01
NoKnee7:
	SEMCLR	IsOnGround
	
	SYSTEM	ClearXYVel
	DSPRITE	 3
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	1
;	SYSTEM	ThrowBall
	NEXTSPRITE	1
	NEXTSPRITE	1
	NEXTSPRITE	6;15
	SYSTEM	ClearXYVel
	FACEBALL	1
	LOADABS	ShouldStand
	JUMPCMP	1,GetUpAnim
	SEMCLR	IsOnGround

	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
	DSPRITE	5
	
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

To7out:
	LASTFRAME	30
	JUMP	To7out


Throw8out:		    	;Throw Straight Down
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	LOADABS	IsOnGround
	JUMPCMP	1,KneeThrow8
	DSPRITES	fs1h01,fs2h01,fs3h01,fs4h01,fs5h01,fs6h01,fs7h01,fs8h01
	SEMCLR	IsOnGround
	JUMP	NoKnee8
KneeThrow8:
	SEMSET	ShouldStand
	DSPRITES	fgth01,fgth01,fgth01,fgth01,fgth01,fgth01,fgth01,fgth01
NoKnee8:
	
	SEMCLR	IsOnGround
	
	SYSTEM	ClearXYVel
	DSPRITE	 3
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	1
;	SYSTEM	ThrowBall
	NEXTSPRITE	1
	NEXTSPRITE	1
	NEXTSPRITE	6;15
	SYSTEM	ClearXYVel
	FACEBALL	1
	LOADABS	ShouldStand
	JUMPCMP	1,GetUpAnim
	SEMCLR	IsOnGround

	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
	DSPRITE	5
	
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

To8out:
	LASTFRAME	30
	JUMP	To8out


;************************************************************************
;* All throws Below are Running Toss Throws. There Will be the same     *
;* For Standing Toss throws. Currently these happen when you are        *
;* throwing the ball closer than 50 feet.	                       *
;************************************************************************

ThrowT1:		    	;Throw Straight Down
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fu1a09,fu2a09,fu3a09,fu4a09,fu5a09,fu6a09,fu7a09,fu8a09
	DSPRITE	 3
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	FRICTION
	NEXTSPRITE	8
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
TosTo1:
	LASTFRAME	30
	JUMP	TosTo1


ThrowT2:			;Throw Down Right
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fu1b09,fu2b09,fu3b09,fu4b09,fu5b09,fu6b09,fu7b09,fu8b09
	DSPRITE	 3
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
TosTo2:
	LASTFRAME	30
	JUMP	TosTo2

ThrowT3:			; Throw To the Right
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fu1b09,fu2b09,fu3c09,fu4c09,fu5c09,fu6c09,fu7c09,fu8c09
	DSPRITE	 3
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	FRICTION
	SYSTEM	ThrowBall
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	SETRAM	B_MOVABLE,1
	DSPRITE	 5
;	INPUTSUB	FIELDER_CONTROLS
TosTo3:
	LASTFRAME	30
	JUMP	TosTo3

ThrowT4:			; Throw Up Right
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fu1d09,fu2d09,fu3d09,fu4d09,fu5d09,fu6d09,fu7d09,fu8d09
	DSPRITE	 3
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

TosTo4:
	LASTFRAME	30
	JUMP	TosTo4

ThrowT5:			; Throw Straight Up
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fu1e09,fu2e09,fu3e09,fu4e09,fu5e09,fu6e09,fu7e09,fu8e09
	DSPRITE	 3
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
TosTo5:
	LASTFRAME	30
	JUMP	TosTo5

ThrowT6:			; throw Up left
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fu1f09,fu2f09,fu3f09,fu3f09,fu5f09,fu6f09,fu7f09,fu8f09
	DSPRITE	 3
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
TosTo6:
	LASTFRAME	30
	JUMP	TosTo6

ThrowT7:			;Throw Straight Left
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fu1g09,fu2g09,fu3g09,fu3g09,fu5g09,fu6g09,fu7g09,fu8g09
	DSPRITE	 3
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

TosTo7:
	LASTFRAME	30
	JUMP	TosTo7

ThrowT8:			; Throw Down left
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fu1h09,fu2h09,fu3h09,fu4h09,fu5h09,fu6h09,fu7h09,fu8h09
	DSPRITE	 3
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

TosTo8:
	LASTFRAME	30
	JUMP	TosTo8


;************************************************************************
;* All throws Below are Standing Toss Throws. There Will be the same    *
;* For Running Toss throws. Currently these happen when you are         *
;* throwing the ball closer than 50 feet.	                       *
;************************************************************************

SThrowT1:		    	;Throw Straight Down
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fv1a01,fv2a01,fv3a01,fv4a01,fv5a01,fv6a01,fv7a01,fv8a01
	DSPRITE	 3
	SYSTEM	ClearXYVel
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION		 
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	FRICTION
	NEXTSPRITE	8
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
STosTo1:
	LASTFRAME	30
	JUMP	STosTo1


SThrowT2:			;Throw Down Right
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fv1b01,fv2b01,fv3b01,fv4b01,fv5b01,fv6b01,fv7b01,fv8b01
	DSPRITE	 3
	SYSTEM	ClearXYVel
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
STosTo2:
	LASTFRAME	30
	JUMP	STosTo2

SThrowT3:			; Throw To the Right
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fv1b01,fv2b01,fv3c01,fv4c01,fv5c01,fv6c01,fv7c01,fv8c01
	DSPRITE	 3
	SYSTEM	ClearXYVel
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	FRICTION
	SYSTEM	ThrowBall
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	SETRAM	B_MOVABLE,1
	DSPRITE	 5
;	INPUTSUB	FIELDER_CONTROLS
STosTo3:
	LASTFRAME	30
	JUMP	STosTo3

SThrowT4:			; Throw Up Right
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fv1d01,fv2d01,fv3d01,fv4d01,fv5d01,fv6d01,fv7d01,fv8d01
	DSPRITE	 3
	SYSTEM	ClearXYVel
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

STosTo4:
	LASTFRAME	30
	JUMP	STosTo4

SThrowT5:			; Throw Straight Up
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fv1e01,fv2e01,fv3e01,fv4e01,fv5e01,fv6e01,fv7e01,fv8e01
	DSPRITE	 3
	FRICTION
	SYSTEM	ClearXYVel
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
STosTo5:
	LASTFRAME	30
	JUMP	STosTo5

SThrowT6:			; throw Up left
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fv1f01,fv2f01,fv3f01,fv3f01,fv5f01,fv6f01,fv7f01,fv8f01
	DSPRITE	 3
	SYSTEM	ClearXYVel
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
STosTo6:
	LASTFRAME	30
	JUMP	STosTo6

SThrowT7:			;Throw Straight Left
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fv1g01,fv2g01,fv3g01,fv3g01,fv5g01,fv6g01,fv7g01,fv8g01
	DSPRITE	 3
	SYSTEM	ClearXYVel
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION		 
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
;	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

STosTo7:
	LASTFRAME	30
	JUMP	STosTo7

SThrowT8:			; Throw Down left
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	fv1h01,fv2h01,fv3h01,fv4h01,fv5h01,fv6h01,fv7h01,fv8h01
	DSPRITE	 3
	SYSTEM	ClearXYVel
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	1
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ThrowBall
	NEXTSPRITE	9
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	f21s01,f21s02,f21s03,f21s04,f21s05,f21s06,f21s07,f21s08
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

STosTo8:
	LASTFRAME	30
	JUMP	STosTo8




;**************************************************************************
;*Catch Infield Ball:  Loop's till ball is within 35 feet, then jumps     *
;*to a catch depending on the hight of the ball and speed of player       *
;**************************************************************************
CatchIBall:		;Face ball with Ready to
;	SETRAM	B_MOVABLE,0
	SEMCLR	IsOnGround
	FACEBALL	0	;Catch frame
	DSPRITES	f21x01,f21x02,f21x03,f21x04,f21x05,f21x06,f21x07,f21x08
	DSPRITE	 5
NearLoop:			;Loop till ball is within 35 feet
	NEARBALL	25*12*256,MoveGlove	;35
	LASTFRAME	10
	JUMP	NearLoop


;catcher version of above
CatchCBall:		;Face ball with Ready to
	FACEBALL	1	;Catch frame
	DSPRITES	c70d01,c70d01,c70d01,c70d01,c70e01,c70f01,c70f01,c70f01
	DSPRITE	 5
.NearLoop:			;Loop till ball is within 35 feet
	NEARBALL	25*12*256,CatCatch
	LASTFRAME	10
	JUMP	.NearLoop

CatCatch
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
;	SETRAM	B_MOVABLE,0
	DSPRITES	c70d01,c70d01,c70d01,c70d01,c70e01,c70f01,c70f01,c70f01
;	DSPRITES	f70a02,f70b02,f70c02,f70d02,f70e02,f1bf01,f1bg01,f1bh01
	DSPRITE	 2
	NEXTSPRITE	2
	NEXTSPRITE	2
;	SOUNDS	FielderCatchBall
	NEXTSPRITE	2
	NEXTSPRITE	2
	SYSTEM	ClearTracks
	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
	INPUTSUB	CATCHER_CONTROLS
CCLP			;Ready to Throw After Catch
	DSPRITES	c70d01,c70d01,c70d01,c70d01,c70e01,c70f01,c70f01,c70f01
;	DSPRITES	f21c08,f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07
	DSPRITE	-1
	LASTFRAME	30
	JUMP	CCLP

	.export	CATCHER_CONTROLS
CATCHER_CONTROLS    ;These are given to the catcher After he catches the ball  
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	
	LOADOBJ	B_HASBALL	; Check If Fielder Has The Ball
 	JUMPEQU	.catcon1	; Branch If He Doesn't
	LOAD	BUTTONS
	ANYBITS	FIRSTBASE,CThrowToF
	ANYBITS	SECONDBASE,CThrowToS
	ANYBITS	THIRDBASE,CThrowToT
;	ANYBITS	HOMEPLATE,CThrowToH
	ANYBITS	STARTBASE,StartButtonSnd
.catcon1
;	LOAD	BUTTONS
;	ANYBITS	HOMEPLATE,RGndBall;DiveTumble
;	ANYBITS	FIRSTBASE,DoDive;DiveBall         
;	ANYBITS	SECONDBASE,JumpBall;DiveBall         
;	ANYBITS	THIRDBASE,DoDive;DiveBall         
;	ANYBITS	STARTBASE,StartButtonSnd

;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DONE

CThrowToF
	SETABSB	BallTo,1
	SETRAM	B_DIRECTION,3	; Face Home Plate
	JUMP	CThrow

CThrowToS
	SETABSB	BallTo,2
	SETRAM	B_DIRECTION,4	; Face Home Plate
	JUMP	CThrow

CThrowToT
	SETABSB	BallTo,3
	SETRAM	B_DIRECTION,5	; Face Home Plate
	JUMP	CThrow

CThrowToH
	SETABSB	BallTo,4
	SETRAM	B_DIRECTION,7	; Face Home Plate
	JUMP	CThrow


CThrow
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	c41a01,c41b01,c41b01,c41d01,c41e01,c41f01,c41g01,c41h01
	DSPRITE	 2
	FRICTION
	NEXTSPRITE	2
	FRICTION
	NEXTSPRITE	2
	FRICTION
	SYSTEM	ThrowBall
	NEXTSPRITE	3
;	SYSTEM	ThrowBall
	FRICTION
	NEXTSPRITE	3
	FRICTION
	NEXTSPRITE	2
	SYSTEM	ClearXYVel
	LASTFRAME	15
	FACEBALL	1
	DSPRITES	c70d01,c70d01,c70d01,c70d01,c70e01,c70f01,c70f01,c70f01
	DSPRITE	 5
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS
.ctdone
	FACEBALL	1
	LASTFRAME	30
	JUMP	.ctdone

          
;**************************************************************************
;*Move Glove just calls the infielder catch. It will decide which catch   *
;*to call based on the height/velocity of the ball and momentum of player *
;**************************************************************************
MoveGlove:		      	;Just goto InfielderCatch
	SYSTEM	CheckPickOff
	QED	
SInfBall:			;Standing Infielder Catch
	LOADABS	PowerBallPal	;was is a power throw?
	JUMPCMP	0,NoPowerBallT	;branch if not
	SOUNDS	CatchPowerThrow	;else power catch sound
NoPowerBallT:
	SEMCLR	PowerBallPal	;clear power ball pal flag
	UPDATE	AnimPlayer
	SYSTEM	SetCount30
	SETRAMW	DURATIONRESET,2	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
;	SETRAM	B_HASBALL,1

	IFIAM	FirstCover,IAmFirst	;If Im covering first, Jump	
	DSPRITES	f70a02,f70b02,f70c02,f70d02,f70e02,f70f02,f70g02,f70h02
	DSPRITE	 -1
;	SYSTEM	Testing
	NEXTSPRITE     -1	
	NEXTSPRITE     -1
	UPDATE	TrackPlayer
	INPUTSUB	SpeedUp	;Set Input sub to check for break out
	NEXTSPRITE     -1
	NEXTSPRITE     -1
	SYSTEM	SetCount10
	SYSTEM	ClearTracks
;	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
	INPUTSUB	FIELDER_CONTROLS
Sinf_1:			;Ready to Throw After Catch
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	Sinf_1


IAmFirst:
;	CLRFLIP
	SYSTEM	SetCount30
	SETRAMW	DURATIONRESET,4	; Set For 10HZ Anim
	DSPRITES	f70a01,f1bb01,f1bc01,f1bd01,f70e01,f1bf01,f1bg01,f1bh01
	DSPRITE	 1
	NEXTSPRITE 1
	NEXTSPRITE 1
	INPUTSUB	 SpeedUp
	NEXTSPRITE 6  ;2
;	SOUNDS	 FielderCatchBall
	NEXTSPRITE 2
	UPDATE	 TrackPlayer
	LASTFRAME	 4  ;25
	NEXTSPRITE -1  ;3
	NEXTSPRITE -1
	NEXTSPRITE -1
	SYSTEM	  SetCount10
	SYSTEM	  ClearTracks
;	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
	INPUTSUB	FIELDER_CONTROLS
IFirst_1:			;Ready to Throw After Catch
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
;	DSPRITES	f21c08,f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07
	DSPRITE	5
	LASTFRAME	30
	JUMP	IFirst_1

PickOffCatchC:
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
PickLoop:			;Loop till ball is within 35 feet
;	SEMCLR	PickOffTest
	NEARBALL	2*12*256,FinishPick
	LASTFRAME	10
	JUMP	PickLoop
FinishPick:
	DSPRITES	f40c01,f40c01,f40h01,f40b01,f40b01,f40b01,f40c01,f40h01
	DSPRITE	 2
;	SOUNDS	FielderCatchBall
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	4

	SYSTEM	ClearTracks
	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
	INPUTSUB	FIELDER_CONTROLS
Pick_1:			;Ready to Throw After Catch
;	DSPRITES	f40c01,f40c01,f40h01,f40b01,f40b01,f40b01,f40c01,f40h01
;	DSPRITES	f21c08,f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	Pick_1



FlyBall:			;Catch Fly ball : Call 
	FASTER	1100,RFlyBall	;running or standing.
	BALLHIGHER 9*12*256,FallBackCatch
	IFPOWERUP	HotDog1
SFlyBall:			;Standing Fly Ball Catch
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SYSTEM	FixHasBall	; Fixup When Player Has Already Caught
	SETRAM	B_HASBALL,1	;test
;	SETRAM	B_MOVABLE,0
;	DSPRITES	fpua01,fpub01,fpuc01,fpud01,fpue01,fpuf01,fpug01,fpuh01
	DSPRITES	fhca02,fhcb01,fhcc01,fhcd01,fhce01,fhcf01,fhcg01,fhch01
	DSPRITE	 2
	SYSTEM	ClearXYVel
;	TRAP	1
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	2
;	NEXTSPRITE	4
;	NEXTSPRITE	4
	SYSTEM	ClearTracks
	UPDATE	TrackPlayer
	INPUTSUB	FIELDER_CONTROLS
;	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
;	DSPRITE	-1
	SETRAM	B_MOVABLE,1

SFly_2:			;Ready to Throw After Catch
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	2
	LASTFRAME	30
	JUMP	SFly_2

RFlyBall:			;Running Fly Ball Catch
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SYSTEM	FixHasBall	; Fixup When Player Has Already Caught
;	SETRAM	B_MOVABLE,0
	SETRAM	B_HASBALL,1	;test
	DSPRITES	f04a01,f04b01,f04c01,f04d01,f04e01,f04f01,f04g01,f04h01
	DSPRITE	 1
	NEXTSPRITE	1
	NEXTSPRITE	1
	NEXTSPRITE	1
	NEXTSPRITE	1
	NEXTSPRITE	4
;	NEXTSPRITE	4
;	NEXTSPRITE	4
	SYSTEM	ClearTracks
	UPDATE	TrackPlayer
	SYSTEM	ClearXYVel
	INPUTSUB	FIELDER_CONTROLS
;	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
;	DSPRITE	-1
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

RFly_2:			;Ready to Throw After Catch

	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	RFly_2

FallBackCatch:		;Standing Fly Ball Catch
	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,3	; Set For 10HZ Anim
	SYSTEM	FixHasBall	; Fixup When Player Has Already Caught
	SETRAM	B_HASBALL,1	;test
;	SETRAM	B_MOVABLE,0
	DSPRITES	fxea01,fxfa01,fxea01,fxfa01,fxea01,fxfa01,fxea01,fxia01
	DSPRITE	 1
	SYSTEM	ClearXYVel
	NEXTSPRITE	1
	NEXTSPRITE	1
	NEXTSPRITE	1
	NEXTSPRITE	2
	NEXTSPRITE	2
	NEXTSPRITE	5
	NEXTSPRITE	5
	NEXTSPRITE	5
	JUMP	SkipFall

	DSPRITES	f82a01,f82a01,f82c01,f82a01,f82a01,f82c01,f82c01,f82c01
	DSPRITE	 2
	SYSTEM	ClearXYVel
	NEXTSPRITE	2
	NEXTSPRITE	3
	NEXTSPRITE	5
	NEXTSPRITE	5
	NEXTSPRITE	5

	DSPRITES	fgua01,fgub01,fguc01,fgud01,fgue01,fguf01,fgug01,fguh01
	DSPRITE	 5
	NEXTSPRITE	5
	NEXTSPRITE	5
	NEXTSPRITE	5
	NEXTSPRITE	5
	NEXTSPRITE	5
	NEXTSPRITE	5
	NEXTSPRITE	5
	
SkipFall:
	SYSTEM	ClearTracks
	UPDATE	TrackPlayer
	INPUTSUB	FIELDER_CONTROLS
;	DSPRITES	f21b01,f21b02,f21b03,f21b04,f21b05,f21b06,f21b07,f21b08
;	DSPRITE	-1
	SETRAM	B_MOVABLE,1
;	INPUTSUB	FIELDER_CONTROLS

FallBack_2: 		;Ready to Throw After Catch
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	FallBack_2


DiveGBall:

	UPDATE	AnimPlayer
	SETRAMW	DURATIONRESET,2	; Set For 10HZ Anim
	SETRAM	B_MOVABLE,0
	DSPRITES	flc101,flc201,flc301,flc401,flc501,flc601,flc701,flc801
	DSPRITE	 -1
	FRICTION
	SEMSET	IsOnGround
	NEXTSPRITE	-1
	SOUNDS	StopsGrounder
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	SOUNDS	FielderHitsGrass
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	FRICTION
	NEXTSPRITE	-1
	SETRAM	B_MOVABLE,1
	INPUTSUB	FIELDER_CONTROLS
 	SYSTEM	ClearXYVel
	LASTFRAME 20
	SEMCLR	IsOnGround
;	LASTFRAME 5
;	DSPRITES	flc108,flc208,flc308,flc408,flc508,flc608,flc708,flc808
;	DSPRITE	 3
	SEMCLR	IsOnGround
	SETRAM	B_MOVABLE,0
			 ; Do Getups After Dives
	DSPRITES	fgua01,fgub01,fguc01,fgud01,fgud01,fguf01,fguf01,fguh01
	DSPRITE	 1	  ; 8 Frames
	NEXTSPRITE 1
	NEXTSPRITE 1
	NEXTSPRITE 1
	NEXTSPRITE 1
	NEXTSPRITE 1
	NEXTSPRITE 1
	NEXTSPRITE 1
	SYSTEM	ClearXYVel
	SYSTEM	ClearTracks
	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
	INPUTSUB	FIELDER_CONTROLS

RGDive_2:			;Ready to Throw After Catch
;	DSPRITES	fgua02,fgub02,fguc02,fgud02,fgud02,fguf02,fguf02,fguh02
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	RGDive_2


GetUpAnim:
	SEMCLR	ShouldStand
	DSPRITES	fgua01,fgub01,fguc01,fgud01,fgud01,fguf01,fguf01,fguh01
	DSPRITE	 15  ; 8 Frames
	NEXTSPRITE 3
	NEXTSPRITE 3
	NEXTSPRITE 3
	NEXTSPRITE 3
	NEXTSPRITE 3
	NEXTSPRITE 3
	NEXTSPRITE 3
	SEMCLR	IsOnGround
	SYSTEM	ClearXYVel
	SYSTEM	ClearTracks
	UPDATE	TrackPlayer
	SETRAM	B_MOVABLE,1
	INPUTSUB	FIELDER_CONTROLS

GetUp_1:			;Ready to Throw After Catch
;	DSPRITES	fgua02,fgub02,fguc02,fgud02,fgud02,fguf02,fguf02,fguh02
	DSPRITES	f21c01,f21c02,f21c03,f21c04,f21c05,f21c06,f21c07,f21c08
	DSPRITE	-1
	LASTFRAME	30
	JUMP	GetUp_1



FielderTest:
	SPRITE1	f03a01,16
	SPRITE1	f03b01,16
	SPRITE1	f03c01,16
	SPRITE1	f03d01,16
	SPRITE1	f03e01,16
	SPRITE1	f03f01,16
	SPRITE1	f03g01,16
	SPRITE1	f03h01,16
  	JUMP	FielderIntro

	
	.align	2
;**************************************************************************
;*The Following set the Starting Ball Coordinates for the Pitching.       *
;**************************************************************************

SetCount10:
	move.l	AtPitPlayer,a1	; Load Fielder Countrol
	move.b	#10,BUTTONCOUNT(a1)	; Set To 10 Count
	rts

SetCount30:
	move.l	AtPitPlayer,a1	; Load Fielder Countrol
	move.b	#30,BUTTONCOUNT(a1)	; Set To 30 Count
	rts

ClearTracks:
	move.l	CONTROLBLOCK(a5),a1	; Load AAddress Of Control Block
	clr.w	TRACKX(a1)	; Clear X Trackball
	clr.w	TRACKY(a1)	; Clear X Trackball
	rts
	.align	2

GetPitchType:
	clr.w	d0
	move.b	([AtPitPlayer],FIRSTPITCHER),d0
	move.l	([AtPitPlayer],d0.w*4,ROSTERPTR),a1
	move.b	AT_pitchtype(a1),pitcht
	rts

	.align	2

DoPitcherName:
	clr.w	d0
	move.b	([AtPitPlayer],FIRSTPITCHER),d0
	move.l	([AtPitPlayer],d0.w*4,ROSTERPTR),a1
	move.b	AT_pitchtype(a1),pitcht
	rts

	.align	2

			;These are the BALL Coords.
SetPitch0:			;Regular  Coords
	move.l	#-1*12*256,BallCordX
	tst.b	FLIPFLAG(a5)	; Test Flipping
	beq.s	S0Right
	move.l	#1*12*256,BallCordX
S0Right:
	move.l	#726*256,BallCordY
	move.l	#72*256,BallCordZ
	rts

SetPitch1:			;HighKick  Coords
	move.l	#-4*12*256,BallCordX
	tst.b	FLIPFLAG(a5)	; TEST Flipping
	beq.s	S1Right
	move.l	#4*12*256,BallCordX
S1Right:
	move.l	#726*256,BallCordY
	move.l	#72*256,BallCordZ
	rts


SetPitch2:			;Sidearm  Coords
	move.l	#-10*12*256,BallCordX
	tst.b	FLIPFLAG(a5)	; Test Flipping
	beq.s	S2Right
	move.l	#10*12*256,BallCordX
S2Right:
	move.l	#726*256,BallCordY
	move.l	#5*256,BallCordZ
		rts

SetPitch3:			;Regular  Coords
	move.l	#-2*12*256,BallCordX
	tst.b	FLIPFLAG(a5)	; Test Flipping
	beq.s	S3Right
	move.l	#2*12*256,BallCordX
S3Right:
	move.l	#726*256,BallCordY
	move.l	#40*256,BallCordZ
	rts


SetPitch4:			;Nomo 
	move.l	#-4*12*256,BallCordX
	tst.b	FLIPFLAG(a5)	; Test Flipping
	beq.s	S4Right
	move.l	#4*12*256,BallCordX
S4Right:
	move.l	#726*256,BallCordY
	move.l	#72*256,BallCordZ
	rts
	rts

SetPitch5:			;Behind Back 1 Coords
	move.l	#5*12*256,BallCordX
	move.l	#726*256,BallCordY
	move.l	#50*256,BallCordZ
		rts

SetPitch6:			;BehindBack  Coords
	move.l	#7*12*256,BallCordX
	tst.b	FLIPFLAG(a5)	; Test Flipping
	beq.s	S6Right
	move.l	#-7*12*256,BallCordX
S6Right:
	move.l	#726*256,BallCordY
	move.l	#40*256,BallCordZ
		rts


SetPitch8:			;UnderHand  Coords
	move.l	#-3*12*256,BallCordX
	tst.b	FLIPFLAG(a5)	; Test Flipping
	beq.s	S8Right
	move.l	#3*12*256,BallCordX
S8Right:
	move.l	#726*256,BallCordY
	move.l	#5*256,BallCordZ
		rts


SetPitch9:			;Tornado  Coords
	move.l	#-4*12*256,BallCordX
	tst.b	FLIPFLAG(a5)	; Test Flipping
	beq.s	S9Right
	move.l	#4*12*256,BallCordX
S9Right:
	move.l	#726*256,BallCordY
	move.l	#50*256,BallCordZ
		rts

SetPitch10:			;Regular  Coords
	move.l	#-2*12*256,BallCordX
	tst.b	FLIPFLAG(a5)	; Test Flipping
	beq.s	S10Right
	move.l	#2*12*256,BallCordX
S10Right:
	move.l	#726*256,BallCordY
	move.l	#40*256,BallCordZ
	rts

CheckBallP:
;	cmp.b	#1,BallPassed
;	beq	AddStrike
	rts
	.align	2

SetJumpZ:			;Regular Jump
	move.l	#1*12*256,WORLDZVEL(a5)
	rts
	.align	2
SetSJumpZ:			;Super Jump
	move.l	#3*12*256,WORLDZVEL(a5)
	rts
	.align	2


SubPower:			;Super Jump
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
   	sub.w	#40*256,TOTALPOWER(a1)	; subtract from total power
	rts
	.align	2

ClearXYVel:
	clr.l	WORLDXVEL(a5)	; Stop X Velocity
	clr.l	WORLDYVEL(a5)	; Stop Y Velocity
	rts
	.align	2
DoubleXYVel:
	move.l	WORLDXVEL(a5),d4
 	asl.l	#1,d4
	move.l	d4,WORLDXVEL(a5)

	move.l	WORLDYVEL(a5),d4
 	asl.l	#1,d4
	move.l	d4,WORLDYVEL(a5)



	rts
	.align	2

;*************************************************************************
;*Move Zones take care of moving the BATTING zone Up and Down.           *
;*************************************************************************
;MoveZoneUp:
;	move.l	ZonePtr,a0	;Move the pointer to a0
;	clr.w	ZoneHeight ;30	;Check the position
;	ble.s	MZU_1	;Branch if it's lowest
;	sub.w	#1,ZoneHeight   	;Subtract 14 from Y Position
;MZU_1:
;	rts		;Return

;MoveZoneDown:
;	move.l	ZonePtr,a0	;Move the pointer to a0
;	move.w	#2,ZoneHeight   ;	;Check the position
;	bge.s	MZD_1       	;Branch if it's Highest
;	add.w	#1,ZoneHeight ;15	;Add 14 to the Y Position
;MZD_1:
;	rts

;SetZone:
;	move.w	#1,ZoneHeight
;	rts

;ClrZone:			;Remove the Zone
;	move.l	ZonePtr,a5
;	jsr	DeallocObject
;	rts

ClrTrk:			;Clear's the track ball
	clr.w	([AtBatPlayer],TRACKX)	;for in X for Step to/from
	rts

CheckTrackBall:
;	jsr	CheckPowerUp
;	jsr	CheckPowerUp2
	cmp.l	#0,CardPtr
	bne.s	CheckTB_9

	move.l	CONTROLBLOCK(a5),d0	; Check If Active
	beq.s	CheckTB_9	; Exit If Not
	move.l	d0,a1	; Move To Address Register
;	tst.b	didwiff
;	bne.s	CheckTB_1

	move.w	TRACKYVEL(a1),d0	; Load Track Y Delta
	bpl.s	CheckTrack_1	; Branch If Positive
	cmp.w	#-500,d0
	cmp.b	#22,POWERNUM(a1)
	beq.s	NoPowerUp
	tst.b	POWERUP(a1)	; Check If Powered Up
	beq.s	NoPowerUp
	jsr	PGrabNHitIt	
NoPowerUp:
	bra	CheckTB_9	;Branch because negative
;	neg.w	d0	; Make It Positive
CheckTrack_1:
	move.w	TRACKXVEL(a1),d1	; Load Track X Delta
	bpl.s	CheckTrack_2	; Branch If Negative
	neg.w	d1	; Make It Positive
CheckTrack_2:
	cmp.w	#4,d1	; Check If Enough Delta
	ble.s	CheckTrack_4	; Branch If Not
	tst.w	d0	; Check For Zero Divide
	beq.s	CheckTrack_3	; Take The Step If Zero
	divu	d0,d1	; Divide X By Y
	cmp.w	#2,d1	; Check If X Enough
	ble.s	CheckTrack_4	; Branch If Not Enough X
CheckTrack_3:
	tst.w	TRACKXVEL(a1)	; Check Which Way To Step
	bpl.s	XStepTo	; Walk Right
	bra.s	XStepFrom	; Walk Left

CheckTrack_4:
	cmp.w	#3,d0	; Check If Track Ball Moving
	bge	CalcSwing	; Swing If Fast Enough
CheckTB_9:
	rts

AddToFirst:
	addi.b	#1,FirstButton
	rts
SubToFirst:
         	subi.b	#1,FirstButton
	rts
AddToThird:
	addi.b	#1,ThirdButton
	rts
SubToThird:
	subi.b	#1,ThirdButton
	rts

;***************************************************************************
;* Step to and from the plate. the swing determins which anim it should    *
;* use depending on which way the batter is facing.                        *
;***************************************************************************
XStepTo:			;Step Toward on Right
	move.l	CONTROLBLOCK(a5),a1	; Load Control Block
	clr.l	ALWAYSROUTINE(a5)	; Clear Always Routine
	clr.l	INPUTROUTINE(a1)	; Shut Down Inputs
	clr.w	TRACKX(a1)
	move.l	#Fight,d0	; Set For Ready Position
	cmp.b	#1,swing
	bne.s	XStepF2
	cmp.w	#120,XPOSITION(a5) ;30	; Check the position
	bge.s	XStepF	; If no room to step, branch
	move.l	#StepTo,d0	; Start Up Walk
	bra.s	XStepF
XStepF2:			;Step Back on Left
	cmp.w	#300,XPOSITION(a5) 	;Check the position
	bge.s	XStepF	;If no room to step, branch
	move.l	#StepF2,d0	; Start Back Up Left
XStepF:
	move.l	d0,PARSEPOINTER(a5)	; Jump to fight
	rts

XStepFrom:			;Step Back on Right
	move.l	CONTROLBLOCK(a5),a1	; Load Control Block
	clr.l	ALWAYSROUTINE(a5)
	clr.l	INPUTROUTINE(a1)	; Shut Down Inputs
	clr.w	TRACKX(a1)
	move.l	#Fight,d0	; Set For Ready Position
	cmp.b	#1,swing
	bne.s	XStepT2	
	cmp.w	#70,XPOSITION(a5) 	;Check the position
	bls.s	StepT3	;If no room to step, branch
	move.l	#StepFrom,d0	; Start Up Walk
	bra	StepT3
XStepT2:			;Step toward on Left
	cmp.w	#260,XPOSITION(a5) 	;Check the position
	bls.s	StepT3	;If no room to step, branch
	move.l	#StepT2,d0	; Start Up Walk Left
StepT3:
	move.l	d0,PARSEPOINTER(a5)	; Jump to fight
	rts

SaveTrack:
	move.l	CONTROLBLOCK(a5),a1	; Load Address Of Control Block
	cmp.w	#0,TRACKYVEL(a1)	; Check If Fast Enough
	bne.s	TracktoV	; Branch If Fine
	move.w	#1,TRACKYVEL(a1)	; Set To Minimum
TracktoV:
         	move.w	TRACKYVEL(a1),VELOCITYDECREMENT(a5)
	jsr	CheckHit	; Check For Ball Hit
	move.b	#1,SwingFlag	; Flag A Swing
         	rts

CalcSwing:
	move.l	AtBatPlayer,a0	; Load Address Of At Bat Player
	move.l	#MidSwing,d0	; Set For Middle Swing

	move.w	#1,ZoneHeight	; Set For Mid Zone
	btst.b	#1,RAWBUTTONS(a0)	; Check If Second Pressed
	beq.s	CalcSwing_1	; Branch If Not Pressed
	move.l	#HighSwing,d0	; Set For High Swing
	clr.w	ZoneHeight	; Set For High Zone
CalcSwing_1:
	btst.b	#4,RAWBUTTONS(a0)	; Check If Home Pressed
	beq.s	CalcSwing_2	; Branch If Not Pressed
	move.l	#LowSwing,d0	; Set For Low Swing
	move.w	#2,ZoneHeight	; Set For Low Zone
CalcSwing_2:
	cmp.b	#3,POWERNUM(a0)	; Check For Power Up 3
	bne.s	CalcSwing_3	; Branch If It Is
	move.l	#PKarateHit,d0	; Load Address Of Karate Hit
CalcSwing_3:
	cmp.b	#13,POWERNUM(a0)	; Check For Power Up 3
	bne.s	CalcSwing_4	; Branch If It Is
	move.l	#VintageSwing,d0	; Load Address Of Karate Hit
CalcSwing_4:
	cmp.b	#25,POWERNUM(a0)	; Check For Power Up 3
	bne.s	CalcSwing_5	; Branch If It Is
	move.l	#POneArmSwing,d0	; Load Address Of Karate Hit
CalcSwing_5:
	move.l	d0,PARSEPOINTER(a5)	; Start Up Swing
	clr.w	TRACKX(a1)	; Clear Track Count
	clr.l	ALWAYSROUTINE(a5)	; Clear Always Routine
	clr.l	INPUTROUTINE(a1)	; Shut Down Inputs
	rts

DoUpBall:
	move.l	#Baseball,a0	; Load Address Of Ball
	sub.w	#0x50,YVELOCITY(a0)	; Slow Ball Down
	rts

DoDownBall:
	move.l	#Baseball,a0	; Load Address Of Ball
	add.w	#0x50,YVELOCITY(a0)	; Slow Ball Down
	rts

DoRightBall:
	move.l	#Baseball,a0	; Load Address Of Ball
	add.w	#0x60,XVELOCITY(a0)	; Slow Ball Down
	rts

DoLeftBall:
	move.l	#Baseball,a0	; Load Address Of Ball
	sub.w	#0x60,XVELOCITY(a0)	; Slow Ball Down
	rts

RunDirectionS:		;Forward
	move.w	#1,DURATION(a5)	
	move.l	a5,a0
	jsr	RunToSecond
	move.l	#AnimPlayer,UPDATEPROC(a5)
	rts
RunDirectionF:		;Backward
	move.w	#1,DURATION(a5)	
	move.l	a5,a0
	jsr	RunToFirst
	move.l	#AnimPlayer,UPDATEPROC(a5)
	rts
RunDirectionT:		;Backward
	move.w	#1,DURATION(a5)	
	move.l	a5,a0
	jsr	RunToThird
	move.l	#AnimPlayer,UPDATEPROC(a5)
	rts


CheckPickOff:
;	tst.b	PickOffTest
;	beq.s	NotPickCatch
;	move.l	#PickOffCatchC,PARSEPOINTER(a5)	; Start Up Swing
;	bra	endcheck
;NotPickCatch:
	move.l	#SInfBall,PARSEPOINTER(a5)	; Start Up Swing
endcheck:
	clr.w	DURATION(a5)
	clr.l	ALWAYSROUTINE(a5)
	rts
	
CheckPitch:
	tst.w	SwitchReason	; Check If On Outfield
	bne.s	CheckP_6	; Branc If It Is
	tst.l	CONTROLBLOCK(a5)	; Check If Active
	beq.s	CheckP_6	; Exit If Not

	tst.b	BatterReady	; Check If If Batter Is Reaady
	beq.s	CheckP_6	; Branch If Not

	cmp.l	#0,CardPtr
	bne.s	CheckP_6
	
	
	move.l	CONTROLBLOCK(a5),a1	; Load Address Of Control Block
	subq.b	#1,COUNTER(a5)	; Decrement Time Out
	bne.s	CheckP_1	; Branch If Not Time Out
	move.b	#1,COMPUTER(a1)	; Make Him Pitch
CheckP_1:
	move.w	TRACKYVEL(a1),d0	; Load Current Velocity
	bpl.s	CheckP_2	; Branch If Positive
        	neg.w	d0	; Make It Positive
CheckP_2:
	move.w	TRACKXVEL(a1),d1	; Load X Velocity
	bpl.s	CheckP_5	; Branch If Positive
	neg.w	d1	; Make It Positive
CheckP_5:
	add.w	d0,d1	; Add Both Velocities
	cmp.w	#4,d1	; Check If Fast Enough
	ble.s	CheckP_6	; Branch If Not
	jsr	NoPitcherControls
	move.w	d1,VELOCITYDECREMENT(a5)	; Save For Pitcher Animation
	move.l	#GoPitch,PARSEPOINTER(a5)	; Start Up Swing
	clr.b	WasAVint
	tst.b	strike
	bne.s	NotNewBatter	;dont count same batter
	add.w	#1,([AtBatPlayer],ATBATSCNT) ;count at bats for batting average
NotNewBatter

	clr.w	DURATION(a5)
	clr.l	ALWAYSROUTINE(a5)
	clr.l	INPUTROUTINE(a1)	; Shut Down Inputs
CheckP_6:
	rts

No_Moving:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	beq.s	NoMoving_1	; Branch If None
	move.l	d0,a1
	clr.l	INPUTROUTINE(a1)	; Shut Down Inputs
NoMoving_1:
	rts	

No_Pitching:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	beq.s	NoPitch_1	; Branch If None
	move.l	d0,a1
	clr.l	INPUTROUTINE(a1)	; Shut Down Inputs
NoPitch_1:
	rts	

GiveControlsToBatter:	;Allow batter to move zone
	move.l	Batter+CONTROLBLOCK,a1	; Load Address Of Batter Controls
	move.l	#BATTER_CONTROLS,INPUTROUTINE(a1)
	jsr	InitAI	
	rts

GiveWalkToBatter:	;Allow batter to move zone
	move.l	Batter+CONTROLBLOCK,a1	; Load Address Of Batter Controls
	move.l	#BATTER_WALKING,INPUTROUTINE(a1)
	rts

GiveSwingToBatter:	;Allow batter to move zone
	move.l	Batter+CONTROLBLOCK,a1	; Load Address Of Batter Controls
	move.l	#BATTER_SWING,INPUTROUTINE(a1)
	rts


GiveSpeedToBatter:	;Allow batter speed up pages
	move.l	Batter+CONTROLBLOCK,a1	; Load Address Of Batter Controls
	move.l	#SpeedUpI,INPUTROUTINE(a1)
	rts

GiveSpeedToPitcher:	;Allow pitcher to speed up pages
	move.l	Pitcher+CONTROLBLOCK,a1	; Load Address Of Batter Controls
	move.l	#SpeedUpI,INPUTROUTINE(a1)
	rts

SpeedUpInstruct:
	move.l	Help1Ptr,a0	; Load Address Of Instructions
	move.w	#1,DURATIONRESET(a0)	; Set For 60HZ Anim
	move.w	#1,DURATION(a0)	; Set For 60HZ Anim
	rts

GiveCounterToBatter:	;Allow batter to move zone
	move.l	Batter+CONTROLBLOCK,a1	; Load Address Of Batter Controls
	move.l	#CONTROLS_COUNT,INPUTROUTINE(a1)
	rts

	.export	NoBatterControls
NoBatterControls:		;Batter not allowed to move zone
	move.l	Batter+CONTROLBLOCK,a1	; Load Address Of Batter Controls
	move.l	#BATTER_NOCONTROLS,INPUTROUTINE(a1)
	rts


;GiveControlsToPitcher:
;	move.l	Pitcher+CONTROLBLOCK,a1	; Load Address Of Batter Controls
;	move.l	#PITCHER_CONTROLS,INPUTROUTINE(a1)
;	rts

GiveControlsToFielder:
	move.l	Pitcher+CONTROLBLOCK,a1	; Load Address Of Batter Controls
	move.l	#FIELDER_CONTROLS,INPUTROUTINE(a1)
	rts

NoPitcherControls:
	move.l	Pitcher+CONTROLBLOCK,a1	; Load Address Of Batter Controls
	move.l	#PITCHER_NOCONTROLS,INPUTROUTINE(a1)
	rts


	.align	2

;FirstLead:
;	SYSTEM	FirstRunStart
;	INPUTSUB	BATTER_CONTROLS
;	QED
;
;	.align	2
;
;SecondLead:
;;	SEMSET	SecondRunner
;;	SYSTEM	SecondRunStart
;;	SYSTEM	ClearBall
;	INPUTSUB	BATTER_CONTROLS
;	QED
;
	.align	2

;ChangeA:	
;	move.l	SecondRunPtr,a5
;	rts
ClearViews:
;	SEMSET	FirstObjPtr
;	SYSTEM	ClearViews2
;	INPUTSUB	BATTER_CONTROLS
      	QED

	.align	2

DoublePlay:
	tst.b	BallOnGround	;has ball hit the ground?
	beq.s	EndDouble	;if not.. branch
;	cmp.b	#-2,SecondRunner+B_ONBASE	;Check for Second runner
	cmp.b	#1,SecondRunner+B_INUSE	;Check for Second runner
	bne.s	EndDouble	;if none branch
;	cmp.b	#-1,FirstRunner+B_ONBASE	;Check for First Runner
	cmp.b	#1,FirstRunner+B_INUSE	;Check for First Runner
	bne.s	EndDouble	;if none branch
	move.l	#DoubleThrow,PARSEPOINTER(a5) ;Do Doubleplay Throw
	
EndDouble:
	rts
	
	.align	2

ClrStrike:			
	clr.b	 strike	;Clear Strike Counter
	clr.b	NewOut	;Clear NewOut Byte
	clr.b	didwiff
	rts

	.import	PitchType
AddStrike:		            
	move.l	AtBatPlayer,a1
	cmp.b	#13,POWERNUM(a1)
	bne.s	NotVintage
	move.b	#1,WasAVint
	jsr	SetNormalSPal
	move.l	#Batter,a1
	clr.l	PARSEPOINTER(a1) ;Do Walk out Anim
	move.l	#Fight,PARSEPOINTER(a1)	; Start Up Swing
	
	move.w	TRACKYVEL(a1),d0	; Load Track Y Delta
	bpl.s	DidSwingP	; Branch If Positive
	bra.s	NotVintage
DidSwingP:
	move.b	#1,SwingFlag	;if started to swing,swing flag =1
NotVintage:


	jsr	ClearPower
	addi.b	#1,strike	;Add Strike to Counter
	move.b	#1,NewStrike	;Declare new strike
	cmp.b	#3,strike	;Is there 3 strikes
	beq.s	AddStrike_1	;branch On Strike Out
 	SOUND	PitchType,SwingFlag	;Sound
	bra.s	AddStrike_9
AddStrike_1
	add.w	#1,([AtPitPlayer],STRIKEOUTSCNT)
	move.b	#1,didwiff	; Flag A Strike Out
	cmp.b	#CurveBallStrike,PitchType	; Check If Curve Ball Out
	beq.s	AddStrike_2	; Branch If It Is
 	SOUND	#StrikeOut,SwingFlag	;Sound
	bra.s	AddStrike_9
AddStrike_2:
	SOUND	#CurveBallStrikeOut,#0	; Send Sound
AddStrike_9:
	rts


	.align	2

;***************************************************************************
;*NewBatter:  	 	          	*
;*This area add's to the outs, call's out move, and then Calls for the    	*
;*batter to walk out.	          	*
;***************************************************************************
NewBatter1:
	clr.b	strike	;clear the strike counter
 	jsr	AddOut
	move.l	#Batter,a5
;	cmp.b	#1,didwiff
;	beq	wiffed
;	move.l	UPDATEPROC(a5)
	clr.l	PARSEPOINTER(a5) ;Do Walk out Anim
	move.l	#BackFromOut,PARSEPOINTER(a5) ;Do Walk out Anim
;	move.l	#ENDDIS,PARSEPOINTER(a5) ;Do Walk out Anim
	bra	donenew
wiffed:	
	move.l	#PlayerIntro,PARSEPOINTER(a5) ;skip walkout
donenew:	
;	jsr	ClrTrk
	clr.l	ALWAYSROUTINE(a5)
;	SOUND     #Strike,#0
;	SOUND     #StrikeOut,#1
	SOUND	#CrowdAwe1,#0
;	move.b	#1,BatterDone
	rts		;Return
	
;***************************************************************************
;*DoBatterName:  	 	          	*
;*This area takes care of the batter number for the sound call.    	*
;***************************************************************************
DoBatterName:
	jsr	GetBatterRoster	;Get player's position
	move.w	([BatRoster],AT_namesnd),d1	;Batter Race 0,1,2
;	sub.w	#1,d1
NotBig:
	move.b	d1,SndBit2
	lsr.w	#8,d1
	move.b	d1,SndBit1
	SOUND3	#SetCurrentPlayer,SndBit1,SndBit2

;	cmp.b	#0,AtBatPlayer+BATTERNUM
;	bne.s	NotFirst
;	SOUND	#BatterLeadsOff,#0
;	bra	Done_1
;NotFirst:
	SOUND	#SayBatterName,#0
Done_1:
	clr.w	d0
;	trap 	#1
	
	
	rts
	
	.export SndBit1,SndBit2
;***************************************************************************
;*DoHeadPalette:  	 	          	*
;*This area takes car of the Head Palettes with hair, helmet ect.    	*
;***************************************************************************
	.align	2
	.export	DoHeadPalette
DoHeadPalette:
;          tst.b	Bat_Team	;Check Who's Batting
;	beq	AwayTeam
;	cmp.w	#10,([AtBatPlayer],BATTERNUM)  ;Is the Last Batter Up?
;	bne.s	HNotNine	   ;No.. then Branch
;	move.w	#1,([AtBatPlayer],BATTERNUM)   ;Else set to the beginning
;	cmp.w	#10,HomeBatNum
;	bne.s	HNotNine
;	move.w	#1,HomeBatNum
;HNotNine:

	jsr	GetBatterRoster	;Get player's position
	move.w	BatTablePos,d0	;Get to place in table
	move.w	BatTableTeam,d1	;Get to place in table

;	addi	#1,([AtBatPlayer],BATTERNUM)

;	move.w	HomeBatNum,batternum
;	addi	#1,HomeBatNum
;	move.w	batternum,d0	;for draft_stat label
;	move.w	HomeTeamNum,d1	;4 is cubget team number
;	bra	ContPals
 
AwayTeam:	
;          	cmp.w	#9,AwayBatNum
;	bne.s	ANotNine
;	clr.w	AwayBatNum
ANotNine:
;	move.w	AwayBatNum,batternum
;;	move.w	#0,batternum
;	addi	#1,AwayBatNum
;	move.w	batternum,d0	;for draft_stat label
;	move.w	AwayTeamNum,d1	;4 is cubget team number
;	bra	ContPals

ContPals:	
;	ext.w	d1
;	mulu	#attrib_size,d0	;pos*attsize
;	mulu	#teamattrib_size,d1	;team*NumberOfTeamPlayers
;	move.l	#ROSTERS,a6
;	lea.l	(a6,d1.w),a6	;get to team
;	lea.l	(a6,d0.w),a6	;get to position
;	move.b	AT_head(a6),PHEADNUM	;Batter Race 0,1,2


	move.l	BatRoster,a6
	move.b	AT_ethnicity(a6),PHEADNUM	;Batter Race 0,1,2

	move.b	AT_hair(a6),PHAIR	;Batter Hair 0,1
;	move.b	AT_bat(a6),swing	;Batter Race 0,1,2

	cmp.b	#0,PHEADNUM
	bne.s	phead01
;	tst.b	Bat_Team

	btst.b	#0,Inning
	beq.s	VisitPal1
;   	tst.b	FieldTeam
;	bne.s	VisitPal1
   	

;	trap	#1
;	move.b	#1,FieldTeam	;Visit Team in Field
	cmp.b	#1,PHAIR
	beq.s	BlondHair

	move.b	#P_HHATPAL00,B_HEADPALETTE(a5)   	;White/brown
	bra	ContHead

BlondHair:
	move.b	#P_HHATPAL00,B_HEADPALETTE(a5) ;white/Blond was 03
ContHead:
	move.b	#P_HOMETPAL00,B_TOPPALETTE(a5)
	move.b	#P_HOMEBPAL,B_BOTPALETTE(a5)
	bra	EndDoHead

VisitPal1:	
;	trap 	#1
;	clr.b	FieldTeam	;Home Team in Field
	cmp.b	#1,PHAIR
	beq.s	BlondHairV
	move.b	#P_VHATPAL00,B_HEADPALETTE(a5) ;White/brown
	bra	ContHeadV

BlondHairV:
	move.b	#P_VHATPAL00,B_HEADPALETTE(a5) ;white/Blond was 03
ContHeadV:
	move.b	#P_VISTPAL00,B_TOPPALETTE(a5)
	move.b	#P_VISBPAL,B_BOTPALETTE(a5)
	bra	EndDoHead
phead01:	
	cmp.b	#1,PHEADNUM
	bne.s	phead02
	btst.b	#0,Inning
;	tst.b	Bat_Team
	beq.s	VisitPal2
	move.b	#P_HHATPAL00,B_HEADPALETTE(a5) ;was 01
	move.b	#P_HOMETPAL01,B_TOPPALETTE(a5)
	move.b	#P_HOMEBPAL,B_BOTPALETTE(a5)
	bra	EndDoHead
VisitPal2:
	move.b	#P_VHATPAL00,B_HEADPALETTE(a5) ;was 01
	move.b	#P_VISTPAL01,B_TOPPALETTE(a5)
	move.b	#P_VISBPAL,B_BOTPALETTE(a5)
	bra	EndDoHead
phead02:	
	btst.b	#0,Inning
;	tst.b	Bat_Team
	beq.s	VisitPal3
;	move.b	#P_HHATPAL01,B_HEADPALETTE(a5);was 02
	move.b	#P_HHATPAL00,B_HEADPALETTE(a5);was 02
	move.b	#P_HOMETPAL02,B_TOPPALETTE(a5)
	move.b	#P_HOMEBPAL,B_BOTPALETTE(a5)
	bra	EndDoHead
VisitPal3:
;	move.b	#P_VHATPAL02,B_HEADPALETTE(a5)
	move.b	#P_VHATPAL00,B_HEADPALETTE(a5)
	move.b	#P_VISTPAL02,B_TOPPALETTE(a5)
	move.b	#P_VISBPAL,B_BOTPALETTE(a5)
	bra	EndDoHead
	
EndDoHead:
;	addi	#1,batternum
	rts
	.align	2

DoSkinPalette:

	move.l	BatRoster,a6
	move.b	AT_ethnicity(a6),SkinTone
	tst.b	InAttractDraft
	bne.s	AttractPal
	btst.b	#0,Inning
	beq.s	VisitorTeam

AttractPal:
	move.b	#P_HOMETPAL00,B_TOPPALETTE(a5)
	move.b	#P_HOMEBPAL,B_BOTPALETTE(a5)
	tst.b	SkinTone
	beq.s	EndSkinPal
	cmp.b	#1,SkinTone
	bne.s	Skin_2
	move.b	#P_HOMETPAL01,B_TOPPALETTE(a5)
	bra.s	EndSkinPal       	
Skin_2:
	move.b	#P_HOMETPAL02,B_TOPPALETTE(a5)
EndSkinPal:
	rts
	
VisitorTeam:
	move.b	#P_VISTPAL00,B_TOPPALETTE(a5)
	move.b	#P_VISBPAL,B_BOTPALETTE(a5)
	tst.b	SkinTone
	beq.s	EndSkinPal2
	cmp.b	#1,SkinTone
	bne.s	Skin_3
	move.b	#P_VISTPAL01,B_TOPPALETTE(a5)
	bra.s	EndSkinPal       	
Skin_3:
	move.b	#P_VISTPAL02,B_TOPPALETTE(a5)

EndSkinPal2:
	rts

	.align	2

SetVintagePal
	move.b	B_TOPPALETTE(a5),SaveTopPal
	move.b	B_BOTPALETTE(a5),SaveBotPal

	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	move.b	#11,POWERNUM(a1)
 	rts

	.align	2

SetNormalPal:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	move.b	#0,POWERNUM(a1)
	move.b	SaveTopPal,B_TOPPALETTE(a5)
	move.b	SaveBotPal,B_BOTPALETTE(a5)
 	rts

	.align	2


SetVintageSPal
	move.b	B_TOPPALETTE(a5),SaveTopBPal
	move.b	B_BOTPALETTE(a5),SaveBotBPal

	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	move.b	#14,POWERNUM(a1)
 	rts

	.align	2

SetNormalSPal:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	move.b	#0,POWERNUM(a1)
	move.b	SaveTopBPal,B_TOPPALETTE(a5)
	move.b	SaveBotBPal,B_BOTPALETTE(a5)
 	rts

	.align	2


;*************************************************************************
;*ClrStr Clears the strikes. This gets called from Sprite Land           *
;*************************************************************************
ClrStr:			;Clear Strikes
	clr.b	didwiff
	clr.b	strike	;clear strike byte
	addi	#1,([AtBatPlayer],BATTERNUM)   ;Add 1 to batternum
	cmp.w	#10,([AtBatPlayer],BATTERNUM)  ;Is the Last Batter Up?
	bne.s	HNotNine_2	   ;No.. then Branch
	move.w	#1,([AtBatPlayer],BATTERNUM)   ;Else set to the beginning
HNotNine_2:
	rts

;*************************************************************************
;*Checkout Check to see if there are 3 outs, to swap palettes.           *
;*This is changing to Change At 3 Outs.... It will be called from game   *
;*when there are 3 outs.	                        *
;*************************************************************************
CheckOut:			
;	trap	#1
;:	cmp.b	#3,outs	;Check for 3 outs
;:	bne.s    	Not3Outs	;If not 3 outs dont change
	clr.b	outs	;clear Outs
;:	jsr	InitTeam
;	trap	#1
;	jsr 	ClearOutBall	;This deallocs all the 
;	eor.b	#1,Bat_Team	;Changes Batting Team	

;	move.l	AwayPlayer,AtBatPlayer
;	btst.b	#0,Inning
;	beq.s	VisitInning
;	move.l	HomePlayer,AtBatPlayer
;VisitInning:

	addi.b	#1,Inning

	tst.l	WinningPlayer
	bne.s	NoScoreboardChange	;obe
	
	move.b	Inning,d0
	lsr.b	#1,d0
	ext.w	d0
	move.l	AtBatPlayer,a0
	clr.b     (INNINGSSCORE,a0,d0.w)

NoScoreboardChange

Not3Outs:
	rts

;*************************************************************************
;*TeamPalSwap will swap the team palettes for the team changes           *
;*This should eventuall be Home and Visitor Palettes                     *
;*************************************************************************
;TeamPalSwap:		;3 Outs? Swap Color's
;	jsr	HalfInnScreen
;	clr.b	outs	;clear Outs
;	cmp.b	#0,BatterPal	;Compare palettes
;	beq	MakeCub	;Change to cub palette
;	move.b	#P_VISTPAL00,P_NOWBAT
;	move.b	P_NOWBAT,PALETTE(a5)	; Load Palette Number
;	move.l	FirstRunPtr,a5
;	move.b	#P_VOAKT,PALETTE(a5)	; Load Palette Number
;	move.b	#0,BatterPal	;Set to old palette
;	jsr 	ClearOutBall
;	bra 	SwapReturn	;Branch to return
;MakeCub:
;	clr.b	BatterPal
;	trap	#1
;	move.b	#1,BatterPal
;	move.b	#P_VISTPAL00,P_NOWBAT
;	move.b	P_NOWBAT,PALETTE(a5)	; Load Palette Number
;;	move.l	FirstRunPtr,a5
;;	move.b	#P_VCUBT,PALETTE(a5)	; Load Palette Number
;;	move.l	BatterHead,a5	; Load Pointer To Frames Data
;;	move.b	#P_HB1BLU,PALETTE(a5)	; Load Palette Number
;
;
;SwapReturn:
;;	jsr 	ClearOutBall	;This deallocs all the 
;	rts

;***********************************************************************
;*CheckSwing checks for a righty or Left (1=right) and then Call's the *
;*walk in animation for that batter.	       *
;***********************************************************************
CheckSwing:		;Check for Lefty/Righty
	clr.b	didwiff
	jsr	GetBatterRoster	;Get to position
	move.w	BatTablePos,d0
	move.w	BatTableTeam,d1
	move.l	BatRoster,a6
	move.b	AT_bat(a6),swing	;Batter Swing 0,1,2
	cmpi.b	#2,swing	;Is he a Switch Hitter?
	bne.s	Not_2	;If not branch
	cmp.b	#1,SwitchHit	;is pitcher Righty?
	bne.s	MakeRighty	;if yes, make batter lefty
	move.b	#0,swing	;else make him Lefty
	bra.s	Not_2
MakeRighty:
	move.b	#1,swing	;else make him Righty
	
Not_2:
	cmpi.b	#1,swing	;If 1 then Right Batter
	beq	RightBat	;Branch to Right Batter
	bra	LeftBat	;Branch to lefty batter
	rts

RightBat:			;Calls Righty
	jsr	B_CardObj
;	jsr	Testing
	move.w	#1,DURATION(a5)	
	move.l	#NewBatterR,PARSEPOINTER(a5)  ;Move Right batter anim
	rts

LeftBat:			;Calls Lefty
	jsr	B_CardObj
;	jsr	Testing
	move.w	#1,DURATION(a5)
	move.l	#NewBatterL,PARSEPOINTER(a5)  ;Move Left batter anim
	rts

ChangeSwing:
	eor.b	#1,swing	;changes swing to opposite
	rts

CheckWalk:
	cmp.b	#1,swing	;Check walk to walk in or out
	beq	Do_WalkOut	;Walk's out depending on 
	bra	Do_WalkIn	;the swing.
	rts

Do_WalkOut:
	jsr	No_Moving
	move.w	#1,DURATION(a5)
	move.l	#EndOfWalkOut,PARSEPOINTER(a5)	
;	move.l	#WalkOut,PARSEPOINTER(a5)	
	rts

Do_WalkIn:
	jsr	No_Moving
	move.w	#1,DURATION(a5)
;	move.l	#WalkIn,PARSEPOINTER(a5)
	move.l	#EndOfWalkIn,PARSEPOINTER(a5)
	rts

CheckWO:			;Check Walk Out
	cmp.b	#0,swing
	beq	Do_Standing
	cmp.b	#0,swing
	beq.s	DoneCheck1
	bra	BatterIsDone
DoneCheck1:
	rts

CheckWI:		            	;Check Walk In
	cmp.b	#0,swing
	beq	BatterIsDone
	cmp.b	#0,swing
	beq.s	Skip_1
	bra	Do_Standing               ;	bra	Do_Standing
Skip_1:
	rts	                          ;	rts

	.align	2
BatterIsDone:
	move.b	#1,BatterDone
	rts
	.align	2

	
Do_Standing:
	move.w	#1,DURATION(a5)
	move.l	#Standing,PARSEPOINTER(a5)
;	move.l	#LookBefore,PARSEPOINTER(a5)
	rts
	
Do_PlayerIntro:
	move.w	#1,DURATION(a5)
	move.l	#PlayerIntro,PARSEPOINTER(a5)
	rts
	
DECSWING:
	move.b	#1,swing
	rts

ClearViews2:
;	move.l	FirstObjPtr,a1
;	jsr	DeallocObjecta1
	rts
	.import	PlayerL,PlayerR
CLRSWING:	
	clr.b	swing
	move.b	#0,BatterPal	; Give Palette Number
;	move.b	#0,batternum

;	move.l	AwayPlayer,AtBatPlayer
;	move.l	AtBatPlayer,a0

;	move.w	#0,PlayerL+BATTERNUM
;	move.w	#0,PlayerR+BATTERNUM

;	move.w	#0,([AtBatPlayer],BATTERNUM)   ;Else set to the beginning


;	clr.w	HomeBatNum
;	clr.w	AwayBatNum
;	clr.b	Bat_Team

	clr.b	Inning
	clr.b	Steal2nd
	clr.b	Steal3rd
	clr.b	strike
	clr.b	outs


; .if debugmode=="obe"
;;	move.b	#14,Inning	;test obe 17
; .endif

;	move.l	AwayPlayer,AtBatPlayer

	clr.b	([AtBatPlayer],INNINGSSCORE)

;	move.w	#1,([HomePlayer],BATTERNUM)
;	trap	#1
;	move.b	#1,Bat_Team
	rts
NoSwing:			;Clear out didswing
	clr.b	didswing
	rts

YesSwing:
	move.b	#1,didswing
	rts

YesWiff:
	move.b	#1,didwiff
	rts

BATTERCLIP:
;	SETCLIP	#0,#0,#247,#300
	move.w	#0,XCLIP1(a5)
	move.w	#300,XCLIP2(a5)
	move.w	#247,YCLIP2(a5)
	move.w	#0,YCLIP1(a5)
	rts

IntroPlayer:
;	SOUND	#GetReadyForBatter,#1
	rts
	
;ChangePal:
;	eor.b	#1,Bat_Team	;Changes Batting Team	
;	rts
	
;************************************************************************
;* AddOut			                       *
;* This add's outs to the 'outs' counter. No more then 3 can be added.  *
;* It also defines New outs from old out's                              *
;************************************************************************
AddOut:
	SOUND	#Crowd1,#0
	cmpi.b	#3,outs	;Check For 3 Outs
	bge	NoAdd	;Don't add if 3
	add.b	#1,outs	;Add 1 out
	move.b	#1,NewOut	;Declare new out
	cmp.b	#1,outs
	bne.s	AddOut_1
	tst.b	didwiff
	bne.s	NoDisplay_1
	jsr	BigOutObj
NoDisplay_1:
	SOUND	#FirstOut,#0
	bra	NoAdd
AddOut_1:
	cmp.b	#2,outs
	bne.s	AddOut_2
	tst.b	didwiff
	bne.s	NoDisplay_2
	jsr	BigOutObj
NoDisplay_2:
	SOUND	#SecondOut,#0
	bra	NoAdd
AddOut_2:
	cmp.b	#3,outs
	bne.s	AddOut_3
	jsr	WinTest3Outs
	tst.l	WinningPlayer
	bne.s	TheyWon
	move.b	([AtBatPlayer],HITS),ThreeUp3Down ;for 3 up 3 down sound call

	cmp.w	#0,ThreeUp3Down
	bne.s	WasAHit
	SOUND	#ThreeUpThreeDown,#0
	bra.s	NotAHit
WasAHit:
	SOUND	#S_ThirdOut,#0
NotAHit:
	cmp.b	#17,Inning
	beq.s	extrainning
	jsr	RetiredObj
	bra.s	TheyWon
extrainning:
	jsr	ExtraObj
TheyWon:
	move.b	#0x40,BallOnGround
	bra	NoAdd
AddOut_3:
	

NoAdd:
	cmp.b	#2,outs	;Check For 3 Outs
	ble.s	EndAdd	;Don't add if 3
;	trap	#1

	move.b	#0x40,BallOnGround
	tst.w	SwitchReason
	beq.s	EndAdd
			;If 3 outs force runners to dugout
	move.l	#FirstRunner,a0	; Load Address Of Runner To First
	jsr	RunToDugout	; Run To Dug Out
	move.l	#SecondRunner,a0	; Load Address Of Runner To First
	jsr	RunToDugout	; Run To Dug Out
	move.l	#ThirdRunner,a0	; Load Address Of Runner To First
	jsr	RunToDugout	; Run To Dug Out
	move.l	#HomeRunner,a0	; Load Address Of Runner To First
	jsr	RunToDugout	; Run To Dug Out
	
EndAdd
	rts		 ;Returrn
	.align	2

Testing:
	addi.b	#1,briancount
	rts
	.align	2

;***********************************************************************
;* Below takes care of which base to throw the ball to                 *
;***********************************************************************
ToFirst:		          	
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	tst.b	POWERUP(a1)	; Check If Powered Up
	beq.s	NoPower1_2	; Branch If He Is
	cmp.w	#42*256,TOTALPOWER(a1)
  	ble.s	NoPower1
;	tst.b	POWERUP(a1)	; Check If Powered Up
;	beq.s	NoPower1	; Branch If He Is
     	move.b	#1,POWERTHROW(a1)
	move.b	#1,PowerBallPal
   	sub.w	#40*256,TOTALPOWER(a1)	; subtract from total power
	bra.s	YesPower1
NoPower1:
	jsr	NotEnoughP
NoPower1_2:
	move.b	#0,POWERTHROW(a1)
	move.b	#0,PowerBallPal
YesPower1:
	move.b	#1,BallTo	;Set to First Base
	rts
	.align	2

ToSecond:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	tst.b	POWERUP(a1)	; Check If Powered Up
	beq.s	NoPower2_2	; Branch If He Is
	cmp.w	#42*256,TOTALPOWER(a1)
	ble.s	NoPower2
;	tst.b	POWERUP(a1)	; Check If Powered Up
;	beq.s	NoPower2	; Branch If He Is
     	move.b	#1,POWERTHROW(a1)
	move.b	#1,PowerBallPal
   	sub.w	#40*256,TOTALPOWER(a1)	; subtract from total power
	bra.s	YesPower2
NoPower2:
	jsr	NotEnoughP
NoPower2_2:
     	move.b	#0,POWERTHROW(a1)
	move.b	#0,PowerBallPal
YesPower2:
	move.b	#2,BallTo	;Set to Second Base
	rts
	.align	2

ToThird:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	tst.b	POWERUP(a1)	; Check If Powered Up
	beq.s	NoPower3_2	; Branch If He Is
	cmp.w	#42*256,TOTALPOWER(a1)
	ble.s	NoPower3
;	tst.b	POWERUP(a1)	; Check If Powered Up
;	beq.s	NoPower3	; Branch If He Is
     	move.b	#1,POWERTHROW(a1)
	move.b	#1,PowerBallPal
   	sub.w	#40*256,TOTALPOWER(a1)	; subtract from total power
	bra.s	YesPower3
NoPower3:
	jsr	NotEnoughP
NoPower3_2:
     	move.b	#0,POWERTHROW(a1)
	move.b	#0,PowerBallPal
YesPower3:
	move.b	#3,BallTo	;Set to Third Base
	rts
	.align	2

ToHome:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	tst.b	POWERUP(a1)	; Check If Powered Up
	beq.s	NoPower4_2	; Branch If He Is
	cmp.w	#42*256,TOTALPOWER(a1)
	ble.s	NoPower4
;	tst.b	POWERUP(a1)	; Check If Powered Up
;	beq.s	NoPower4	; Branch If He Is
     	move.b	#1,POWERTHROW(a1)
	move.b	#1,PowerBallPal
   	sub.w	#40*256,TOTALPOWER(a1)	; subtract from total power
	bra.s	YesPower4
NoPower4:
	jsr	NotEnoughP
NoPower4_2:
     	move.b	#0,POWERTHROW(a1)
	move.b	#0,PowerBallPal
YesPower4:
	move.b	#4,BallTo	;Set to Home Base
	rts
	.align	2


;***********************************************************************
;* ThrowBall: Makes the call to FIELD to throw the ball to that base.  *
;***********************************************************************

ThrowBall:
;	clr.b	d0
;	clr.b	d1

	cmp.b	#1,BallTo	;To First Base?
	bne.s	JToSecond	;If not, branch to second
	jsr	ThrowToFirst	;Yes, Throw to First
	bra	EndThrow	;End throw
JToSecond:
	cmp.b	#2,BallTo	;To Second Base?
	bne.s	JToThird	;If not, branch to third
	jsr	ThrowToSecond	;Yes, Throw to Second
	bra	EndThrow	;End throw
JToThird:
	cmp.b	#3,BallTo	;To Third Base?
	bne.s	JToHome	;If not, branch to Home
	jsr	ThrowToThird	;Yes, Throw to Third
	bra	EndThrow	;End throw
JToHome:
	jsr	ThrowToHome	;Throw To Home
EndThrow:
	rts		;End Throwing

FixHasBall:
	tst.b	B_MOVABLE(a5)	; Check If Player Already Caught
	bne.s	FixHas_1	; Branch If He Is
	move.b	#1,B_HASBALL(a5)	; Give Him The Ball
	clr.w	d1

FixHas_1:
;	move.w	([B_ROSTERADR,a1],AT_namesnd),d1   ; Fielder Name from Roster
;	move.b	d1,SndBit2
;	lsr.w	#8,d1
;	move.b	d1,SndBit1
;;	SOUND3	#SetCurrentPlayer,SndBit1,SndBit2
	;	SOUND3	#SetCurrentPlayer,#0,#0
;	SOUND	#CatchesBallNormal,#0
;;	cmp.b	#97,SndBit2
;;	bne.s	NotGreen
;;         	trap	#1
;NotGreen:
	clr.b	B_MOVABLE(a5)	; Stop The Player
	jsr	GiveControlsToFielder
	rts
CheckBases:
	clr.b	BaseCount

	tst.b	FirstRunner+B_INUSE
	beq.s	SRunner
	move.b	#1,BaseCount
SRunner:
	tst.b	SecondRunner+B_INUSE
	beq.s	TRunner
	move.b	#1,BaseCount
TRunner:
	tst.b	ThirdRunner+B_INUSE
	beq.s	HRunner
	move.b	#2,BaseCount
HRunner:
	tst.b	HomeRunner+B_INUSE
	beq.s	DoneRunner
	cmpi.b	#1,BaseCount
	beq.s	OnFirst
	move.b	#3,BaseCount
DoneRunner:
;        	jsr	GiveControlsToBatter
	rts
OnFirst:
	move.b	#4,BaseCount
;	jsr	GiveControlsToBatter
	rts


CheckRunning:
	move.b	#-1,AreRunning	; Flag Runners Running
	tst.b	HomeRun	; Check If Home Run
	bmi.s	CheckR_9	; Exit If It Was

	move.l	#HomeRunner,a0	; Load Address Of Home Runner
CheckR_1:
	tst.b	B_INUSE(a0)	; Check If Runner Inuse
	beq.s	CheckR_2	; Branch If Not
	tst.b	B_ONBASE(a0)	; Test On Base Condition
	bmi.s	CheckR_9	; Exit If Off Base
CheckR_2:
	move.l	CHILD(a0),a0	; Load Previous Runner
	tst.l	a0	; Check If Done
	bne.s	CheckR_1	; Continue If Not

	move.l	#FirstRunner,a0	; Load Address Of First Runner
	move.l	#SecondRunner,a1	; Load Address Of Second Runner
	move.b	B_INUSE(a0),d0	; Load In Use Flag
	and.b	B_INUSE(a1),d0	; And With Other In Use
	beq.s	CheckR_3	; Branch If Either Not In Use
	move.b	B_ONBASE(a0),d0	; Load On Base Flag
	cmp.b	B_ONBASE(a1),d0	; Compare With Other
	beq.s	CheckR_9	; Exit If Same
CheckR_3:

	move.l	#SecondRunner,a0	; Load Address Of Second Runner
	move.l	#ThirdRunner,a1	; Load Address Of Third Runner
	move.b	B_INUSE(a0),d0	; Load In Use Flag
	and.b	B_INUSE(a1),d0	; And With Other In Use
	beq.s	CheckR_4	; Branch If Either Not In Use
	move.b	B_ONBASE(a0),d0	; Load On Base Flag
	cmp.b	B_ONBASE(a1),d0	; Compare With Other
	beq.s	CheckR_9	; Exit If Same
CheckR_4:

	move.l	#ThirdRunner,a0	; Load Address Of Third Runner
	move.l	#HomeRunner,a1	; Load Address Of Home Runner
	move.b	B_INUSE(a0),d0	; Load In Use Flag
	and.b	B_INUSE(a1),d0	; And With Other In Use
	beq.s	CheckR_5	; Branch If Either Not In Use
	move.b	B_ONBASE(a0),d0	; Load On Base Flag
	cmp.b	B_ONBASE(a1),d0	; Compare With Other
	beq.s	CheckR_9	; Exit If Same
CheckR_5:

	clr.b	AreRunning	; Flag Nobody Running
CheckR_9:
	rts

	.align	2
;CheckWiff:
;	tst.b	didwiff
;	bne.s	NotAWiff
;;         	
;NotAWiff:
; 	rts

	.align	2

BRITRAP:
	trap	#1
	rts
	.align	2

ClearPower:
;	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
;	move.l	d0,a1	; Move Address Of Control Block To A1
	move.l	AtBatPlayer,a1
	clr.b	POWERNUM(a1)
	clr.b	Light
	clr.b	PowerBallPal
	SOUND	#LightSaberOff,#0	; Set Volume
	clr.b	SaberOn
	rts
	.align	2


PLight:	         
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	cmp.w	#83*256,TOTALPOWER(a1)
	ble.s	LNotEnough
;	move.b	#1,Light
	move.b	#1,POWERNUM(a1)
	sub.w	#83*256,TOTALPOWER(a1)	; subtract from total power
	rts
LNotEnough:
	jsr	NotEnough
	rts
	.align	2

PAntiLaser:	         
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	cmp.w	#28*256,TOTALPOWER(a1)
	ble.s	ANotEnough
	move.b	#1,AntiL
	move.b	#30,POWERNUM(a1)
 	sub.w	#27*256,TOTALPOWER(a1)	; subtract from total power
	rts
ANotEnough:
	jsr	NotEnough
	rts
	.align	2


PKarateS:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	cmp.w	#27*256,TOTALPOWER(a1)
	ble.s	KNotEnough
	move.b	#3,POWERNUM(a1)
	move.b	#1,PowerBallPal
	sub.w	#26*256,TOTALPOWER(a1)	; subtract from total power
	rts
KNotEnough:
	jsr	NotEnough
	rts
	.align	2


PGive:
;	trap	#1
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	move.w	#84*256,TOTALPOWER(a1)
	rts
	.align	2

POneArmS:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	cmp.w	#27*256,TOTALPOWER(a1)
	ble.s	OneNotEnough
	move.b	#25,POWERNUM(a1)
	move.b	#1,PowerBallPal
	sub.w	#26*256,TOTALPOWER(a1)	; subtract from total power
	rts
OneNotEnough:
	jsr	NotEnough
	rts
	.align	2

PGrabNHitIt:
;	jsr	BallFountain
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	cmp.w	#83*256,TOTALPOWER(a1)
	ble.s	GNotEnough
	move.b	#22,POWERNUM(a1)
	move.b	#1,PowerBallPal
	sub.w	#83*256,TOTALPOWER(a1)	; subtract from total power
	rts
GNotEnough:
	jsr	NotEnough
	rts
	.align	2


PPinchHit:
	cmp.l	#0,CardPtr
	beq.s	VintageBat
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	cmp.w	#56*256,TOTALPOWER(a1)
	ble.s	PNotEnough
	move.l	#CardAnimPinch,([CardPtr],PARSEPOINTER)	; Set Animation String
	move.b	#2,POWERNUM(a1)
	sub.w	#55*256,TOTALPOWER(a1)	; subtract from total power
	rts
PNotEnough:
	jsr	NotEnough
	rts
	.align	2


VintageBat:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	cmp.w	#56*256,TOTALPOWER(a1)
	ble.s	VNotEnough
	move.b	#13,POWERNUM(a1)
	sub.w	#55*256,TOTALPOWER(a1)	; subtract from total power
	jsr	SetVintageSPal
	move.l	#VintageSwing,d0
	move.l	d0,PARSEPOINTER(a5)	; Start Up Swing
	rts
VNotEnough:
	jsr	NotEnough
	rts
	.align	2


PSuperJump:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	cmp.w	#55*256,TOTALPOWER(a1)
	ble.s	PNSuper
	move.b	#2,POWERNUM(a1)
	sub.w	#54*256,TOTALPOWER(a1)	; subtract from total power
	rts
PNSuper:
	jsr	NotEnoughP
	rts
	.align	2


PSuperJump3:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	cmp.w	#83*256,TOTALPOWER(a1)
	ble.s	PNSuper
	move.b	#2,POWERNUM(a1)
	sub.w	#83*256,TOTALPOWER(a1)	; subtract from total power
	rts
PNSuper3:
	jsr	NotEnoughP
	rts
	.align	2

PUnderPitch:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	cmp.w	#28*256,TOTALPOWER(a1)
	ble.s	PNPitch
	move.b	#8,POWERNUM(a1)
	sub.w	#27*256,TOTALPOWER(a1)	; subtract from total power
	rts
PNPitch:
	jsr	NotEnoughP
	rts
	.align	2

PVintagePitch:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	cmp.w	#56*256,TOTALPOWER(a1)
	ble.s	PVPitch
	move.b	#10,POWERNUM(a1)
	sub.w	#55*256,TOTALPOWER(a1)	; subtract from total power
	rts
PVPitch:
	jsr	NotEnoughP
	rts
	.align	2


PTornadoPitch:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	cmp.w	#83*256,TOTALPOWER(a1)
	ble.s	PTPitch
	move.b	#9,POWERNUM(a1)
	sub.w	#82*256,TOTALPOWER(a1)	; subtract from total power
	rts
PTPitch:
	jsr	NotEnoughP
	rts
	.align	2
PBeanBall:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	cmp.w	#27*256,TOTALPOWER(a1)
	ble.s	PBePitch
	move.b	#20,POWERNUM(a1)
	sub.w	#26*256,TOTALPOWER(a1)	; subtract from total power
	rts
PBePitch:
	jsr	NotEnoughP
	rts
	.align	2


;SPower:			;Standard Power Up Check
;	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
;	move.l	d0,a1	; Move Address Of Control Block To A1
;	cmp.w	#53*256,TOTALPOWER(a1)
;	ble.s	SPEnough
;	move.b	#7,POWERNUM(a1)
;	sub.w	#52*256,TOTALPOWER(a1)	; subtract from total power
;SPEnough:
;	rts
	.align	2

;S3Power:			;Standard Power Up Check
;	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
;	move.l	d0,a1	; Move Address Of Control Block To A1
;	cmp.w	#83*256,TOTALPOWER(a1)
;	bls.s	SP3Enough
;	;	trap	#1
;	move.b	#7,POWERNUM(a1)
;	sub.w	#81*256,TOTALPOWER(a1)	; subtract from total power
;SP3Enough:
;	rts
	.align	2

ClearPowerF:  		;Clear Fielder Power
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
	clr.w	POWERNUM(a1)	;clear power number
	rts

	.align	2

CheckForTired
	clr.b	TiredPit
	move.l	AtBatPlayer,a1	; Load Address Of Batter
	move.b	Inning,d1	; Load Inning Number
	ext.w	d1	; Extend To A Word
	lsr.w	#1,d1	; Extract Inning Number
	cmp.b	#4,(INNINGSSCORE,a1,d1.w)	; Increment Inning Score by using INNINGSSCORE
	ble.s	NotEnoughRuns
	move.b	#1,TiredPit
	rts
NotEnoughRuns:
	clr.b	TiredPit
	rts
	
	.align	2


PrintHelp:
	tst.b	GameMode
	beq       NotSingle
	bra.s	DontPrint

	cmp.b	#1,Inning
	bge.s	DontPrint
	tst.b	PrintInst	;test to print?
	bne.s	DontPrint	;Dont Print

	move.l	SinglePlayer,a4	;Move single player to a4
	tst.l	a4	;check if single player game
	beq	NotSingle	;branch if not
	cmp.b	#2,SinglePlayer+YND	;check for enter initials
	beq	NotSingle	;no initials, give instructions 
	cmp.w	#1,([SinglePlayer],stat_win);does player have 2 wins
	bgt	DontPrint	;if yes skip
	
NotSingle:	
;	jsr	BigMesh
	jsr	BatterHelp
	jsr	PitcherHelp
;	jsr	Help1Obj	;Call Help Object
	move.b	#1,PrintInst
DontPrint:
	rts
	.align	2

DeallocProTip:
	move.l	ProTipPtr,a1
	move.b	#1,DELETED(a1)	; Remove The Out
	clr.l	Help1Ptr
          	move.b	#240,Pitcher+COUNTER
	jsr	InitAI
	rts
	.align	2
CheckForCards:
	cmp.l	#0,Help1Ptr	;Check for help message
	bne.s	DontSet	;branch if present
	cmp.l	#0,CardPtr	;Check for Card	
	bne.s	DontSet	;branch if present
	move.l	Pitcher+CONTROLBLOCK,a1	; Load Address Of Pitcher Controls
	move.l	#PITCHER_CONTROLS,INPUTROUTINE(a1) ;Give Controls to Pitcher
DontSet:
	rts

	.align	2

ChangeApperance1:
;set batter height & width
	move.l	BatRoster,a6
	clr.l	d0
	move.b	AT_weight(a6),d0
	move.w	(BatterWidths,d0*2),Batter+XSCALE
	clr.l	d0
	move.b	AT_height(a6),d0
	move.w	(BatterHeights,d0*2),Batter+YSCALE
	rts

ChangeApperance2:
;set batter height & width
	move.l	BatRoster,a6
	move.b	AT_weight(a6),d0
	clr.l	d0
	move.b	#9,d0
	ext.l	d0
	move.w	(BatterWidths,d0*2),Batter+XSCALE
	move.b	AT_height(a6),d0
	clr.l	d0
	move.b	#9,d0
	ext.l	d0
	move.w	(BatterHeights,d0*2),Batter+YSCALE
	rts

	.export	BatterWidths,BatterHeights

BatterWidths

Ws	equ	9	;was 6

	dc.w	256-Ws-Ws-Ws-Ws-Ws-Ws-Ws-Ws-Ws ;0
	dc.w	256-Ws-Ws-Ws-Ws-Ws-Ws-Ws-Ws ;1
	dc.w	256-Ws-Ws-Ws-Ws-Ws-Ws-Ws ;2
	dc.w	256-Ws-Ws-Ws-Ws-Ws-Ws ;3
	dc.w	256-Ws-Ws-Ws-Ws-Ws ;4
	dc.w	256-Ws-Ws-Ws-Ws ;5
	dc.w	256-Ws-Ws-Ws ;6
	dc.w	256-Ws-Ws ;7
	dc.w	256-Ws ;8
	dc.w	256 ;9

;	dc.w	202 ;0
;	dc.w	208 ;1
;	dc.w	214 ;2
;	dc.w	220 ;3
;	dc.w	226 ;4
;	dc.w	232 ;5
;	dc.w	238 ;6
;	dc.w	244 ;7
;	dc.w	250 ;8
;	dc.w	256 ;9

BatterHeights

Hs	equ	6	;was 3

	dc.w	256-Hs-Hs-Hs-Hs-Hs-Hs-Hs-Hs-Hs ;0
	dc.w	256-Hs-Hs-Hs-Hs-Hs-Hs-Hs-Hs ;1
	dc.w	256-Hs-Hs-Hs-Hs-Hs-Hs-Hs ;2
	dc.w	256-Hs-Hs-Hs-Hs-Hs-Hs ;3
	dc.w	256-Hs-Hs-Hs-Hs-Hs ;4
	dc.w	256-Hs-Hs-Hs-Hs ;5
	dc.w	256-Hs-Hs-Hs ;6
	dc.w	256-Hs-Hs ;7
	dc.w	256-Hs ;8
	dc.w	256 ;9

;	dc.w	229 ;0
;	dc.w	232 ;1
;	dc.w	235 ;2
;	dc.w	238 ;3
;	dc.w	241 ;4
;	dc.w	244 ;5
;	dc.w	247 ;6
;	dc.w	250 ;7
;	dc.w	253 ;8
;	dc.w	256 ;9


CatcherIntro		;standing image
	SPRITE	c41e01,45
	JUMP	CatcherIntro

	.import	FindNewFielder
	.align	2
SwitchFielder:
	SYSTEM	FindNewFielder	; Switch To Fielder In Middle Of Screen

	.import	CopyPlayer
GiveHimFirst:	
	move.l	#SecondRunner,a4	; Load Address Of Runner On First
	tst.b	B_INUSE(a4)	; Check If In Use
	beq.s	GiveHim_4	; Exit If Not
GiveHim_1:
	tst.b	B_INUSE(a4)	; Check If In Use
	beq.s	GiveHim_2	; Exit If Not
	add.l	#`sizeof(player_struct),a4	; Index To Next Runner
	cmp.l	#HomeRunner,a4	; Check If Home Runner
          	blt.s	GiveHim_1

	tst.b	B_INUSE(a4)	; Check If In Use
	beq.s	GiveHim_2	; Exit If Not
	move.l	AtBatPlayer,a1	; Load Address Of Batter
	move.b	Inning,d1	; Load Inning Number
	ext.w	d1	; Extend To A Word
	lsr.w	#1,d1	; Extract Inning Number
	add.b	#1,(INNINGSSCORE,a1,d1.w)	; Increment Inning Score by using INNINGSSCORE
	add.b	#1,RUNS(a1)	; Increment Runs

GiveHim_2:
	move.l	a4,a2	; Move Destination Address To A2
	move.l	CHILD(a4),a1	; Move Source Address To A1
	jsr	CopyPlayer	; Copy Player
	move.l	CHILD(a4),a2	; Back Up One Runner
	cmp.l	#FirstRunner,a2	; Check If Done
	bne.s	GiveHim_2

GiveHim_4:
	move.l	#SecondRunner,a0	; Load Address Of Second Runner
	move.l	B_ROSTERADR(a5),B_ROSTERADR(a0) ; Transfer Roster Data
	move.b	#1,B_INUSE(a0)	; Start Up Runner
	move.b	#1,B_ONBASE(a0)	; Force On First
	clr.b	B_OUT(a0)	; Player Not Out
	clr.b	B_SLIDING(a0)	; Not Sliding Yet
	move.w	#rt1d01,PICTURE(a0)	; Initialize Picture
	move.w	#rt1d01,CURRENTFRAME(a0)	; Initialize Current Frame
	rts

	end


