;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************
	.region	"RAM"
	ds	0
	#include	"player.h"
	#include	"ramblock.h"
	#include	"pals.h"
	#include	"groms.h"
	#include	"rosters.h"
	#include	"sys.mac"
	#include	"bsblsnds.equ"

;***************************************************************************
;   Routines Exported From PLAYER.ASM		*
;***************************************************************************
	.export	AnimPlayer,AnimPlayer2
	.export	DspBody,Split
	.export	DisplayShadows
	.export	GetPosition
	.export	InitPlayers
	.export	InitPlayer
	.export	PlayerColor
	.export	FielderNum

;***************************************************************************
;  Variable Imports			*
;***************************************************************************
	.import.s	BlitX,BlitY,BlitWidth,BlitFlip,BlitFlop
	.import.s	GroundY2,GroundY
	.import.s	FreezeMask,FreezeTick
	.import.s	SwitchReason;,batternum
	.import.s	HomeTeamNum,AwayTeamNum,HomePlayer,AwayPlayer
	.import.s	SinglePlayer,BallInFlight
	.import.s	BatTablePos
	.import.s Inning,ControlPtr
	.import.s	SecondRunX,SecondRunY
	.import.s	ThirdRunX,ThirdRunY
	.import	PHEADNUM,BatBlit
	.import	PickOffTest
	.import	AtBatPlayer
	.import	Light

;***************************************************************************
;  Subroutine Imports		*
;***************************************************************************
	.import	AllocObject	
	.import	Anim,Move
	.import	BlitObject,BlitAObject,BlitSAObject
	.import	CalcFieldCoord
	.import	CreateJoy,InputControl
	.import	DeallocObject
	.import	InitAI
	.import	LoadPtrs
	.import	Switches
	.import	PitcherIntro,PlayerIntro
	.import	Pitcher_5
	.import	ROSTERS,GetRoster,AtPitPlayer
	.import	Fight
	.import	FielderRun,RunnerRun,CatcherRun
	.import	BatRoster

;***************************************************************************
;  Fighter Table Imports		*
;***************************************************************************
	.import	BaseTable
	.import	Player,FielderIntro,PitcherIntro,CatcherIntro
	.import	RunnerIntroT,RunnerIntroF,RunnerIntroS
	.import	attrib_size,teamattrib_size

;***************************************************************************
;  RAM Variables Defined In This Section		*
;***************************************************************************
	.export	Objects,FreeObjects,ObjectList
	.export	Pitcher,Batter,FirstBase,SecondBase,ShortStop,Baseball
	.export	ThirdBase,Catcher,LeftField,CenterField,RightField,FirstRunner
	.export	FlopShadows,DimShadows,DownShadows,NoShadows,ClipShadows
	.export	FlickerShadows,FlickerCnt,ThirdRunner,FirstRunStart,FirstRunPtr
	.export	SecondRunStart,SecondRunPtr,SecondRunner,HomeRunner
	.export	ThirdRunStart
	.export	PlayerR,PlayerL
	.export	testin,XScale,YScale
	.export	FieldTeam,InitPitcher
	.export	SaberOn
	.export	RosterNumber1
	.export	RosterNumber2
	.export	SwitchHit

	.export BlitHead 
            .export BlitBat  
            .export BlitLegs 
            .export BlitTorso
	.export	BatE
;***************************************************************************
;  Sub Routine Exports Defined In This Section		*
;***************************************************************************
	.export	ChangeControl

;Equates for the Ethnicity from AT_ethnicity
W    equ  0       ;White
H    equ  1       ;Hispanic
B    equ  2       ;Black

Objects	 ds.l	1	; Pointer To Object List
FreeObjects ds.l	1	; Pointer To Free Object List
ObjectList	 ds.b	(NUMBLOCKS*`sizeof(object_struct))

PlayerR	ds.b	`sizeof(control_struct)	; Right Player Control
PlayerL	ds.b	`sizeof(control_struct)	; Left Player Control
HomeTest	ds.b	`sizeof(control_struct)	

Baseball	 ds.b	`sizeof(object_struct)

Batter	 ds.b	`sizeof(player_struct)
Pitcher	 ds.b	`sizeof(player_struct)
FirstBase	 ds.b	`sizeof(player_struct)
SecondBase	 ds.b	`sizeof(player_struct)
ShortStop	 ds.b	`sizeof(player_struct)
ThirdBase	 ds.b	`sizeof(player_struct)
Catcher	 ds.b	`sizeof(player_struct)
LeftField	 ds.b	`sizeof(player_struct)
CenterField ds.b	`sizeof(player_struct)
RightField	 ds.b	`sizeof(player_struct)
FirstRunner ds.b	`sizeof(player_struct)
SecondRunner ds.b	`sizeof(player_struct)
ThirdRunner ds.b	`sizeof(player_struct)
HomeRunner  ds.b	`sizeof(player_struct)

	 ds	0
Shadow_Yanchor ds.w	1
ClipShadows    ds.w	1	; Shadows Flopped
FlopShadows    ds.b	1	; Shadows Flopped
DimShadows	    ds.b	1	; Shadows in Dim Palette
DownShadows    ds.b	1	; Shadows Move Downward
NoShadows      ds.b	1	; Set For No Shadows
FlickerShadows ds.b	1	; Flickers the Shadows
FlickerCnt	    ds.b	1	; Flicker Speed
Temp	    ds.b	1
FirstRunPtr    ds.l	1
SecondRunPtr    ds.l	1
XScale	    ds.w	1
YScale	    ds.w	1
FielderNum	    ds.b	1
FPalNum	    ds.l	1
batternum2	    ds.l	1
FieldTeam	    ds.b	1
AwayArtNum	    ds.w	1
testin	    ds.b	1
SaberOn	    ds.b	1
RosterNumber1  ds.b	1
RosterNumber2  ds.b	1
BatE	    ds.b	1
SwitchHit	    ds.b	1

;***************************************************************************
;  Start Of Program Code		*
;***************************************************************************
	.region	"RomCode"
	ds	0

	#include	"graphlib.mac"
	#include	"graphlib.h"
	#include	"graphglb.h"
	#include	"controls.h" 
	#include	"anim.mac"

;***************************************************************************
;   InitPlayers - Initialize All Players Including Batter And Pitcher	*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
InitPlayers:                ;Took extra Fielders out
;	SOUND	#INITPLAYER2,TEAMNUMBER+PlayerR
	jsr	InitAI	; Initialize AI
	clr.l	SinglePlayer
	tst.b	COMPUTER+PlayerL
	beq.s	nocompL
	move.l	#PlayerR,SinglePlayer ; Flag Single Player Game
nocompL	tst.b	COMPUTER+PlayerR
	beq.s	nocompR
	move.l	#PlayerL,SinglePlayer ; Flag Single Player Game
nocompR
	jsr	InitBatter	; Initialize The Batter
	jsr	InitPitcher	; Initialize The Pitcher

;	move.b	#0,FieldTeam


; Catcher
	move.w	#500,d2	; Set X Position (Off Screen)
	move.l	#Catcher,a0	; Load Address Of Catcher
	move.l	#0*256,WORLDX(a0)	; Set World Coordinates
	move.l	#0*256,WORLDY(a0)
	bsr	InitPlayer	; Initialize Player Object
	move.w	#c02a01,B_STANDINGFRAME(a0)	; Force Standing Frame
	move.l	#CatcherRun,B_RUNNINGANIM(a0) ; Set For Running
	move.b	#CATCHER,FielderNum	; Set Fielder Number
	jsr	PlayerColor	; Setup Player Color

; First Base
	move.w	#500,d2	; Set X Position To Off Screen
	move.l	#FirstBase,a0	; Set Up Third Baseman
	move.l	#757*256,WORLDX(a0)	; Set World Coordinates
	move.l	#1098*256,WORLDY(a0)
	bsr	InitPlayer	; Initialize Object
	move.b	#FIRSTBASEMAN,FielderNum	; Set Fielder Number
	jsr	PlayerColor	; Setup Player Color

; Second Base
	move.w    #290,d2	; Set X Position
	move.l	#SecondBase,a0	; Set Up Short Stop
	move.l	#480*256,WORLDX(a0)	; Set World Coordinates
	move.l	#1543*256,WORLDY(a0)
 	bsr	InitPlayer	; Initialize Object
	move.b	#SECONDBASEMAN,FielderNum	; Set Fielder Number
	jsr	PlayerColor

; Short Stop
	move.w    #60,d2	; Set X Position
           move.l	#ShortStop,a0	; Set Up Short Stop
	move.l	#-480*256,WORLDX(a0)	; Set World Coordinates
	move.l	#1543*256,WORLDY(a0)
 	bsr	InitPlayer	; Initialize Object
	move.b	#SHORTSTOP,FielderNum	; Set Fielder Number
	jsr	PlayerColor	; Setup Player Color

; Third Base
	move.w	#500,d2	; Set X Position To Off Screen
	move.l	#ThirdBase,a0	; Set Up Third Baseman
	move.l	#-757*256,WORLDX(a0)	; Set World Coordinates
	move.l	#1098*256,WORLDY(a0)
	bsr	InitPlayer	; Initialize Object
	move.b	#THIRDBASEMAN,FielderNum	; Set Fielder Number
	jsr	PlayerColor	; Set Up Player Color

; Left Field
	move.w	#500,d2	; Set X Position To Off Screen
	move.l	#LeftField,a0	; Set Up Third Baseman
	move.l	#-1628*256,WORLDX(a0)	; Set World Coordinates
	move.l	#2784*256,WORLDY(a0)
	bsr	InitPlayer	; Initialize Object
	move.b	#LEFTFIELD,FielderNum	; Set Fielder Number
	jsr	PlayerColor	; Setup Player Color

; Center Field
	move.w	#500,d2	; Set X Position To Off Screen
	move.l	#CenterField,a0	; Set Up Third Baseman
	move.l	#0*256,WORLDX(a0)	; Set World Coordinates
	move.l	#3640*256,WORLDY(a0)
	bsr	InitPlayer	; Initialize Object
	move.b	#CENTERFIELD,FielderNum	; Set Fielder Number
	jsr	PlayerColor	; Setup Player Color

; Right Field
	move.w	#500,d2	; Set X Position To Off Screen
	move.l	#RightField,a0	; Set Up Third Baseman
	move.l	#1628*256,WORLDX(a0)	; Set World Coordinates
	move.l	#2784*256,WORLDY(a0)
	bsr	InitPlayer	; Initialize Object
	move.b	#RIGHTFIELD,FielderNum	; Set Fielder Number
	jsr	PlayerColor	; Setup Player Color
	
; First Base Runner
	move.w	#500,d2	; Set X Position To Off Screen
	move.l	#FirstRunner,a0	; Set Up Third Baseman
	bsr	InitPlayer	; Initialize Object
	move.l	#0,WORLDX(a0)	; Set World Coordinates
	move.l	#0,WORLDY(a0)	; Set World Coordinates
	move.l	#RunnerRun,B_RUNNINGANIM(a0) ; Set For Running

;	move.b	#P_HOMETPAL00,PALETTE(a0)	; Load Palette Number
;	move.b	#P_HOMEBPAL,B_BOTPALETTE(a0) ; Load Palette Number
;	tst.b	FieldTeam
;     	bne.s	HomePal1
;	move.b	#P_VISTPAL00,PALETTE(a0)	; Load Palette Number
;	move.b	#P_VISBPAL,B_BOTPALETTE(a0)	; Load Palette Number

HomePal1:

; Second Base Runner
         	move.w	#500,d2	; Set X Position To Off Screen
         	move.l	#SecondRunner,a0	; Set Up Third Baseman
         	bsr	InitPlayer	; Initialize Object
         	move.l	#FIRSTBASEX,WORLDX(a0)	; Set World Coordinates
         	move.l	#FIRSTBASEY,WORLDY(a0)	; Set World Coordinates

;	move.b	#P_HOMETPAL00,PALETTE(a0)	; Load Palette Number
;	move.b	#P_HOMEBPAL,B_BOTPALETTE(a0) ; Load Palette Number
;	move.l	#RunnerRun,B_RUNNINGANIM(a0) ; Set For Running
;     	tst.b	FieldTeam	; Which Team is up to Bat?
;     	bne.s	HomePal2	; HomeTeam, then branch
;	move.b	#P_VISTPAL00,PALETTE(a0)	; Load Palette Number
;	move.b	#P_VISBPAL,B_BOTPALETTE(a0)	; Load Palette Number
HomePal2:
	tst.b	B_INUSE(a0)
	beq.s	nofirst
	jsr	FirstRunStart	;obe
nofirst

; Third Base Runner
         	move.w	#500,d2	; Set X Position To Off Screen
         	move.l	#ThirdRunner,a0	; Set Up Third Baseman
         	bsr	InitPlayer	; Initialize Object
         	move.l	#0,WORLDX(a0)	; Set World Coordinates
         	move.l	#SECONDBASEY,WORLDY(a0)	; Set World Coordinates


;	move.b	#P_HOMETPAL00,PALETTE(a0)	; Load Palette Number
;	move.b	#P_HOMEBPAL,B_BOTPALETTE(a0) ; Load Palette Number
;	move.l	#RunnerRun,B_RUNNINGANIM(a0) ; Set For Running
;     	tst.b	FieldTeam	; Which Team is up to Bat?
;     	bne.s	HomePal3	; HomeTeam, then branch
;	move.b	#P_VISTPAL00,PALETTE(a0)	; Load Palette Number
;	move.b	#P_VISBPAL,B_BOTPALETTE(a0)	; Load Palette Number
HomePal3:
	tst.b	B_INUSE(a0)
	beq.s	nosecond
	jsr	SecondRunStart	;obe
nosecond:
; Home Plate Runner
         	move.w	#500,d2	; Set X Position To Off Screen
         	move.l	#HomeRunner,a0	; Set Up Third Baseman
         	bsr	InitPlayer	; Initialize Object
	move.l	#RunnerRun,B_RUNNINGANIM(a0) ; Set For Running
         	move.l	#0,WORLDX(a0)	; Set World Coordinates
         	move.l	#THIRDBASEY,WORLDY(a0)	;Set World Coordinates
	
;	move.b	#P_HOMETPAL00,PALETTE(a0)	; Load Palette Number
;	move.b	#P_HOMEBPAL,B_BOTPALETTE(a0) ; Load Palette Number
;     	tst.b	FieldTeam	; Which Team is up to Bat?
;     	bne.s	HomePal4	; HomeTeam, then branch
;	move.b	#P_VISTPAL00,PALETTE(a0)	; Load Palette Number
;	move.b	#P_VISBPAL,B_BOTPALETTE(a0)	; Load Palette Number
HomePal4:
	tst.b	B_INUSE(a0)
	beq.s	nothird
	jsr	ThirdRunStart	;obe
nothird:
	move.l	#ThirdRunner,HomeRunner+CHILD ; Create Runner Chain
	move.l	#SecondRunner,ThirdRunner+CHILD
	move.l	#FirstRunner,SecondRunner+CHILD
	clr.l	FirstRunner+CHILD
	rts

;***************************************************************************
;   InitBatter - Initialize Batter Ram Block                  	*
;				*
;   Parameters :  A0 - Ram Block Address		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
InitBatter:
	move.l	#Batter,a0	; Load Address Of Player 1 Data
	clr.l	WORLDX(a0)	; Set Batter World X
	clr.l	WORLDY(a0)	; Set Batter World Y
	move.w	#223,YPOSITION(a0)	; Store Starting Y Position
	move.w	#62,ZPOSITION(a0)	; Set Z Position
	clr.b	FLIPFLAG(a0)	; Set No Flip
	move.l	#AnimPlayer,UPDATEPROC(a0)	; Store Address Of Update Procedure
	move.l	#DspBody,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
	move.w	#-1,CURRENTFRAME(a0)	; Start With First Frame
	move.w	#TORSOZ,ZPOSITION(a0)   	; Initialize Z Position
	move.b	#0xFF,OBJECTTYPE(a0)	; Initialize Object Type	
	move.w	#256,XSCALE(a0)	; Set To Full Size Body
	move.w	#256,YSCALE(a0)	; Set To Full Size Body
	move.w	#256,SCALEFACTOR(a0)	; Set To Half Size
	move.b	#1,B_INUSE(a0)	; Set To In Use

	move.l	#0x40,GRAVITY(a0)	; Store Gravity
	move.w	#-1,PICTURE(a0)	; Start With Standing Picture
	clr.l	ALWAYSROUTINE(a0)	; Clear Always Routine Address
	move.b	#-1,STATIONARY(a0)	; Set As Stationary
	clr.w	DURATION(a0)	; Clear Animation Duration
	clr.b	B_HASBALL(a0)	; Clear Has Ball Flag
	clr.w	XVELOCITY(a0)	; Clear X Velocity
	clr.w	YVELOCITY(a0)	; Clear Y Velocity
	clr.b	DELETED(a0)
	move.b	#8,DAMP(a0)
	move.l	#Player,B_FRAMESDATA(a0)	; Save In Ram Block
;	tst.b	PickOffTest
;	beq.s	WasPickOff
	move.l	#PlayerIntro,PARSEPOINTER(a0) ; Save Starting Animation Address
;	bra	NotPickOff
;WasPickOff:
;	move.l	#Fight,PARSEPOINTER(a0) ; Save Starting Animation Address
;	clr.b	PickOffTest
;NotPickOff:
	move.b	#BatterTopBank,BANK(a0)	; Load Bank Number

	jsr	ChangeControl	; ChangeControl At inning
	rts

;***************************************************************************
;   InitPitcher - Initialize Pitcher Ram Block                  	*
;				*
;   Parameters :  A0 - Ram Block Address		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
InitPitcher:
	move.l	#Pitcher,a0	; Load Address Of Player 2 Data
	clr.l	WORLDX(a0)	; Set Pitcher World X
;   	jsr	PitcherColor

;  	move.b	#P_VISTPAL02,PALETTE(a0)	; Load Palette Number
;  	tst.b	FieldTeam
;  	bne.s	VisitBPal
;  	move.b	#P_HOMETPAL02,PALETTE(a0)	; Load Palette Number
;VisitBPal:
	move.l	#256*726,WORLDY(a0)	; Set Pitcher World Y
	move.w	#138-6,YPOSITION(a0)	; 22 Store Starting Y Position
	move.w	#195,XPOSITION(a0)	; Store Starting X Position
	move.w	#40,ZPOSITION(a0)	; Set Z Position
	clr.b	FLIPFLAG(a0)	; Set No Flip

	clr.l	d0
      	move.b	([AtPitPlayer],FIRSTPITCHER),d0 ;pitchers pos
	move.b	d0,FielderNum	; Set Fielder Number
	jsr	PlayerColor
	clr.l	d0
	move.b	([AtPitPlayer],FIRSTPITCHER),d0 ;pitchers pos
	move.l	([AtPitPlayer],d0.w*4,ROSTERPTR),a1
	move.l	a1,(B_ROSTERADR,a0)	;set pointer for any more accessing
	clr.l	d0
  	move.b	AT_throw(a1),d0	; Move throw byte (1 or 0)
  	move.b	AT_throw(a1),SwitchHit	; Move throw byte (1 or 0)
	cmp.b	#1,d0	; If  then he's a righty
 	beq.s	Righty	; Check for Lefty or Righty (not it yet)
	move.w	#187,XPOSITION(a0)	; Store Starting X Position for Lefty
	move.b	#1,FLIPFLAG(a0)	; Set Flip for Lefty
Righty:

;      	move.b	([AtPitPlayer],FIRSTPITCHER),d0 ;pitchers pos
;	move.b	d0,FielderNum	; Set Fielder Number
;	jsr	PlayerColor

	move.l	#AnimPlayer,UPDATEPROC(a0)	; Store Address Of Update Procedure
	move.l	#DspBody,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
	move.w	#-1,CURRENTFRAME(a0)	; Start With First Frame
	move.w	#TORSOZ,ZPOSITION(a0)   	; Initialize Z Position
	move.b	#0xFF,OBJECTTYPE(a0)	; Initialize Object Type	
	move.w	#256,XSCALE(a0)	; Set To Full Size Body
	move.w	#256,YSCALE(a0)	; Set To Full Size Body
	move.w	#256,SCALEFACTOR(a0)	; Set To Half Size

	move.l	#0x40,GRAVITY(a0)	; Store Gravity
	move.b	#1,B_CATCHACTIVE(a0)	; Let Player Catch
	move.w	#-1,PICTURE(a0)	; Start With Standing Picture
	clr.l	ALWAYSROUTINE(a0)	; Clear Always Routine Address
	move.b	#-1,STATIONARY(a0)	; Set As Stationary
	clr.w	DURATION(a0)	; Clear Animation Duration
	clr.w	XVELOCITY(a0)	; Clear X Velocity
	clr.w	YVELOCITY(a0)	; Clear Y Velocity
	clr.b	DELETED(a0)
	move.b	#8,DAMP(a0)
	move.w	#f61a04,B_STANDINGFRAME(a0)	; Force Standing Frame
	move.l	#FielderRun,B_RUNNINGANIM(a0); Set Running Animation

	move.l	#Player,B_FRAMESDATA(a0)	; Save In Ram Block

;bri	move.l	#Pitcher_5,PARSEPOINTER(a0) ; Save Starting Animation Address
;	cmp.b	#240,PITCHERSTRENGTH(a0)
;	ble.s	Tired
	move.l	#PitcherIntro,PARSEPOINTER(a0) ; Save Starting Animation Address
;Tired:
	move.b	#PitcherTopBank,BANK(a0)	; Load Bank Number
;	tst.w	SwitchReason	; Check If On Outfield
;	beq.s	StillPitcher
;	move.b	#FielderTopBank,BANK(a0)	; Load Bank Number
;	move.l	#FielderIntro,PARSEPOINTER(a0) ; Save Starting Animation Address
;
;StillPitcher:	
	
;	move.l	#PlayerR,CONTROLBLOCK(a0)	; Set Controlling Block
;	move.l	a0,PlayerR+CONTROLOBJECT	; Set Up Controlled Object

	jsr	ChangeControl	;Change control at Inning

;set pitchers size
;	move.l	AtPitPlayer,a0
;	move.b	FIRSTPITCHER(a0),d0	;current pitcher
;	ext.w	d0
;	jsr	GetRoster
;	move.b	AT_weight(a0),d0
	move.b	([Pitcher+B_ROSTERADR],AT_weight),d0

	ext.w	d0
	ext.l	d0
	move.w	(PitcherWidths,d0*2),Pitcher+XSCALE
	move.b	([Pitcher+B_ROSTERADR],AT_height),d0
	ext.w	d0
	ext.l	d0
	move.w	(PitcherHeights,d0*2),Pitcher+YSCALE

	rts

PitcherWidths
	dc.w	202 ;0
	dc.w	208 ;1
	dc.w	214 ;2
	dc.w	220 ;3
	dc.w	226 ;4
	dc.w	232 ;5
	dc.w	238 ;6
	dc.w	244 ;7
	dc.w	250 ;8
	dc.w	256 ;9

PitcherHeights
	dc.w	229 ;0
	dc.w	232 ;1
	dc.w	235 ;2
	dc.w	238 ;3
	dc.w	241 ;4
	dc.w	244 ;5
	dc.w	247 ;6
	dc.w	250 ;7
	dc.w	253 ;8
	dc.w	256 ;9

	rts

 	
;*************************************************************************
;* Change Controls: Changes the controling side for Batter and Pitcher   *
;* based on the inning number.	                        *
;*************************************************************************
ChangeControl:	
	move.l	#Batter,a0	; Load Address Of Player 1 Data
	move.l	AwayPlayer,CONTROLBLOCK(a0) ; Set Controlling Block
	move.l	a0,([AwayPlayer],CONTROLOBJECT)  ; Set Up Controlled Object
	btst.b	#0,Inning 	;Top of Inning?
	beq.s	SwapBat_2
	move.l	HomePlayer,CONTROLBLOCK(a0) ; Set Controlling Block
	move.l	a0,([HomePlayer],CONTROLOBJECT)  ; Set Up Controlled Object
SwapBat_2:
	move.l	#Pitcher,a0	; Load Address Of Player 2 Data
	move.l	HomePlayer,CONTROLBLOCK(a0) ; Set Controlling Block
	move.l	a0,([HomePlayer],CONTROLOBJECT)  ; Set Up Controlled Object
	btst.b	#0,Inning	; Top Of inning?
	beq.s	SwapPitch_2
	move.l	AwayPlayer,CONTROLBLOCK(a0) ; Set Controlling Block
	move.l	a0,([AwayPlayer],CONTROLOBJECT) ; Set Up Controlled Object
		
SwapPitch_2:
	rts


FirstRunStart:
;********************* First And third Runners ***************
	move.l	#SecondRunner,a0
	bsr	InitPlayer
	move.l	#RunnerIntroF,PARSEPOINTER(a0) ; Save In Ram Block
	move.b	#RunnerTopBank,BANK(a0)	; Load Legs Bank Number
	move.w	#500,XPOSITION(a0)
 	move.w	#54,YPOSITION(a0)
	move.l	a0,FirstRunPtr
	rts

SecondRunStart:
;*********************** Second Runners ***************
	move.l	#ThirdRunner,a0
	bsr	InitPlayer
	move.l	#RunnerIntroS,PARSEPOINTER(a0) ; Save In Ram Block
	move.b	#RunnerTopBank,BANK(a0)	; Load Legs Bank Number
	move.w	#178,XPOSITION(a0)
	move.w	#115,YPOSITION(a0)
	move.w	#30,ZPOSITION(a0)	; Initialize Z Position
	move.l	a0,SecondRunPtr
	rts
	
ThirdRunStart:
	move.l	#HomeRunner,a0
	bsr	InitPlayer
	move.l	#RunnerIntroT,PARSEPOINTER(a0) ; Save In Ram Block
	move.b	#RunnerTopBank,BANK(a0)	; Load Legs Bank Number
	move.w	#500,XPOSITION(a0)
	move.w	#54,YPOSITION(a0)

	rts

;***************************************************************************
;   PlayerColor - Gets the color of the player from the roster
;	       and then gets the palette color
;
;***************************************************************************
PlayerColor:
;    	clr.b	FLIPFLAG(a0)
	clr.w	d1
	tst.b	FieldTeam
	beq.s	Home1
	move.w	AwayTeamNum,d1
      	bra	Away1
Home1:	
	move.w	HomeTeamNum,d1
Away1:
	ext.w	d1

	clr.w	d0

	move.b	FielderNum,d0
	ext.w	d0

	mulu	#attrib_size,d0	;pos*attsize
	mulu	#teamattrib_size,d1	;team*NumberOfTeamPlayers

;	move.l	#ROSTERS,a6
;	lea.l	(a6,d1.w),a6	;get to team
;	lea.l	(a6,d0.w),a6	;get to position

	move.l	(B_ROSTERADR,a0),a6	;new roster address source

	clr.w	d1
	move.b	AT_ethnicity(a6),d1
	clr.l	d2
	move.b	AT_throw(a6),d2
	cmp.b	#1,d2
	beq.s	NotLefty
	move.b	#1,FLIPFLAG(a0)	; Set Flip for Lefty
NotLefty:
	move.l	#FieldHColors,a2	; Load Address Of Palettes Table
	tst.b	FieldTeam	;Which Team is in the field
	beq.s	HomeField	;If 0 then Home is in Field
	move.l	#FieldAColors,a2	; Load Address Of Palettes Table
HomeField:
	move.b	(a2,d1.w),PALETTE(a0)	; Load Palette Number
	rts

FieldAColors:
	dc.b	P_VISTPAL00	;White
	dc.b	P_VISTPAL01	;Hispanic
	dc.b	P_VISTPAL02	;Black

FieldHColors:
	dc.b	P_HOMETPAL00	;White
	dc.b	P_HOMETPAL01	;Hispanic
	dc.b	P_HOMETPAL02	;Black






;***************************************************************************
;   InitPlayer - Initialize Player Ram Block                  	*
;				*
;   Parameters :  A0 - Ram Block Address		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
InitPlayer:
	clr.w	DURATION(a0)	; Clear Animation Duration
	clr.w	XVELOCITY(a0)	; Clear X Velocity
	clr.w	YVELOCITY(a0)	; Clear Y Velocity
	clr.l	WORLDXVEL(a0)	; Clear X Velocity
	clr.l	WORLDYVEL(a0)	; Clear Y Velocity
	clr.l	WORLDZVEL(a0)	; Clear Z Velocity
	clr.b	FLIPFLAG(a0)	; Clear The Flip Flag
	clr.b	FLOPFLAG(a0)	; Clear The Flop Flag
	clr.l	ALWAYSROUTINE(a0)	; Clear The Always Procedure
	clr.l	CONTROLBLOCK(a0)	; Clear Controling Block
	clr.w	ANCHORX(a0)	; Clear X Anchor
	clr.w	ANCHORY(a0)	; Clear Y Anchor
	clr.w	BLITWIDTH(a0)	; Clear Blit Width
	clr.w	BLITHEIGHT(a0)	; Clear Blit Height
	clr.l	B_SEEKING(a0)	; Clear Desperatly Seeking Position Flag
	clr.b	B_HASBALL(a0)	; Clear Has Ball Flag
	clr.b	B_FORCED(a0)	; Clear Forced Run Flag
	clr.b	B_OUT(a0)	; Clear Runner Out Flag
	clr.b	DELETED(a0)	; Clear Deleted Flag
	clr.b	BOUNCESOUND(a0)	; Clear The Bounce Sound
	move.b	#1,B_CATCHACTIVE(a0)	; Let Player Catch
	clr.b	B_MOVABLE(a0)	; Let Player Move
	move.b	#-1,STATIONARY(a0)	; Set As Non-Stationary
	move.l	#0x40,GRAVITY(a0)	; Store Gravity
	move.w	#f61a04,B_STANDINGFRAME(a0)	; Force Standing Frame
	move.l	#FielderRun,B_RUNNINGANIM(a0); Set For Running

	move.l	#AnimPlayer,UPDATEPROC(a0) ; Store Address Of Update Procedure
	move.l	#DspBody,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
	move.w	#-1,CURRENTFRAME(a0)        ; Start With First Frame
	move.w	#10,ZPOSITION(a0)   	; Initialize Z Position
	move.b	#0xFF,OBJECTTYPE(a0)	; Initialize Object Type	

	move.w	#256,XSCALE(a0)	; Set To Full Size Body
	move.w	#256,YSCALE(a0)	; Set To Full Size Body
	move.w	#0xC0,SCALEFACTOR(a0)	; Set To Half Size

	move.w	#-1,PICTURE(a0)	; Start With Standing Picture
	move.w	d2,XPOSITION(a0)
	move.w	#116,YPOSITION(a0)	;was 115
	move.l	#FielderIntro,PARSEPOINTER(a0) ; Save In Ram Block
	move.l	#Player,B_FRAMESDATA(a0)	; Save In Ram Block

	clr.b	DELETED(a0)

	move.b	#8,DAMP(a0)

	move.b	#FielderTopBank,BANK(a0)	; Load Legs Bank Number

	move.l	WORLDX(a0),B_GOALX(a0)	; Set To Current Position X
	move.l	WORLDY(a0),B_GOALY(a0)	; Set To Current Position Y

	rts

;***************************************************************************
;   AnimPlayer - Execute The Animation Tables For Each Fighter	*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
AnimPlayer:
AnimPlayer2:
	jsr	InputControl	; Execute Input Control
	jsr	Anim	; Animate The Player
	jsr	ForceInRange	; Keep Player Of Field

	tst.l	DISPLAYPROC(a5)	; Check If Displaying
	beq.s	AnimP_6	; Branch If Not
	jsr	Split	; Split Fighter Into Parts
AnimP_6:
	tst.w	SwitchReason	; Check If Displaying Field
	beq.s	AnimP_7	; Branch If Not Displaying
	jsr	CalcFieldCoord	; Place Player On Field
AnimP_7:
	rts

;****************************************************************************
;   ForceInRange - Keep Player On The Field		*
;				*
;   Parameters :  A5 - Address Of Player Object		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
	.import	AtWallCatch
	.import	StadiumY,WallImpact
	.import.s	HomeRun

ForceInRange:
	move.l	#StadiumY,a0	; Load Address Of Stadium Data
	move.l	WORLDX(a5),d0	; Load X Position
	bpl.s	Force_1	; Branch If Positive
	neg.l	d0	; Make It Positive
Force_1:
	lsr.l	#8,d0	; Extract Inches
	lsr.l	#3,d0	; Extract 8 Inches
	lsl.w	#1,d0	; Multiply By Two
	move.w	(a0,d0.w),d0	; Load Stadium Y Position
	lsl.l	#8,d0	; Shift Up Inches
	cmp.l	WORLDY(a5),d0	; Load Ball's Y Position
	bge.s	Force_3	; Branch If Fine
	move.l	d0,WORLDY(a5)	; Force In Range
	move.l	AtPitPlayer,a0	; Load Address Of Fielders
	tst.l	INPUTROUTINE(a0)	; Check If Under Control
	beq.s	Force_5	; Branch If Not
	cmp.l	#0xC00,WORLDYVEL(a5)	; Check If Fast Enough
	ble.s	Force_5	; Branch If Too Slow
	move.l	#AtWallCatch,d0	; Make Him Jump On Wall
	tst.b	BallInFlight	; Check If Ball In Flight
	bne.s	Force_2	; Branch If It Is
	move.l	#WallImpact,d0	; Make Him Fall Down
	neg.l	WORLDYVEL(a5)	; Force Away From Wall
Force_2:
	move.l	d0,PARSEPOINTER(a5)	; Save Animation
	move.l	#AnimPlayer,UPDATEPROC(a5)	; Remove Player Control
	clr.l	INPUTROUTINE(a0)	; Take Away Control
	clr.w	DURATION(a5)	; Start Up Soon
	bra.s	Force_5
Force_3:
	move.l	#HOMEPLATEY-480*256,d0	; Check If 40 Feet Behind Home
	cmp.l	WORLDY(a5),d0	; Load Ball's Y Position
	ble.s	Force_5	; Branch If Fine
Force_4:
	move.l	d0,WORLDY(a5)	; Force In Range
Force_5:
	rts

;***************************************************************************
;   Split - Extract Torso, Back Arm and Weapon Arm Pictures	*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
Split:
	move.w	CURRENTFRAME(a5),d7	; Load The Frame Number
	bmi.s	Split_9
	move.l	B_FRAMESDATA(a5),a0	; Load Address Of Frames Data
	lsl.w	#2,d7	; Multiply By Four
	move.l	(a0,d7.w),a3	; Load Address Of Frame
	move.l	a3,B_DATAPTR(a5)	; Save Pointer To Dots Data
	move.w	Torso(a3),d3
	move.w	d3,PICTURE(a5)	; Save Body Image Number

	clr.w	ZOFFSET(a5)	; Clear Z Offset
	move.l	WORLDZ(a5),d1	; Load Z Position
	beq.s	Split_9	; Branch If None
	asr.l	#8,d1	; Shift To Integral Part
	mulu	SCALEFACTOR(a5),d1	; Multiply By Scale Factor
	asr.l	#8,d1	; Divide By 256
	asr.l	#1,d1	; --Brian Fix This-- was 3
	move.w	d1,ZOFFSET(a5)	; Store Z Height
Split_9:
	rts

;***************************************************************************
;   DisplayShadows - Display All Player Shadows		*
;                                                                          *
;   Parameters :  NONE                                                     *
;   Returns:      NONE                                                     *
;   Modifies:     ALL                                                      *
;***************************************************************************
DisplayShadows:
	PUSHL	a5	; Save A5
	CLIP	OFF
	move.l	Objects,a5	; Load Address Of Pitcher
DspShad_1:
	move.l	a5,d0	; Check If Pointer Valid
	beq	DspShad_9	; Exit If Not Defined

	cmp.l	#Batter,d0	; Check If Batter
	beq.s	DspShad_8	; No Shadow For Batter

	tst.b	OBJECTTYPE(a5)	; Check If Player Object
	bpl.s	DspShad_8	; Continue If Not
	tst.b	B_INUSE(a5)	; Check If Player In Use
	beq.s	DspShad_8	; Continue If Not

	move.b	#1,B_ONSCREEN(a5)	; Set On Screen

	cmp.w	#360,XPOSITION(a5)	; Check Right Side Of Screen
	blt.s	DspShad_2	; Exit If On Screen
	clr.b	B_ONSCREEN(a5)	; Set Off Screen
	cmp.w	#384+50,XPOSITION(a5)	; Check Right Side Of Screen
	blt.s	DspShad_2	; Branch If Half On Screen

	move.w	#384+60,XPOSITION(a5)	; Position Off Screen
	bra.s	DspShad_8

DspShad_2:
	cmp.w	#-24,XPOSITION(a5)	; Check Left Side Of Screen
	bgt.s	DspShad_3	; Exit If On Screen
	clr.b	B_ONSCREEN(a5)	; Set Off Screen
	cmp.w	#-50,XPOSITION(a5)	; Check Left Side Of Screen
	bgt.s	DspShad_3	; Branch If Half On Screen

	move.w	#384+60,XPOSITION(a5)	; Position Off Screen
	bra.s	DspShad_8

DspShad_3:
	cmp.w	#312,YPOSITION(a5)	; Check Bottom Of Screen
	blt.s	DspShad_4	; Branch If On Screen
	clr.b	B_ONSCREEN(a5)	; Set Off Screen
	cmp.w	#356,YPOSITION(a5)	; Check Bottom Of Screen
	blt.s	DspShad_4	; Branch If Half On Screen
	move.w	#384+60,XPOSITION(a5)	; Position Off Screen
	bra.s	DspShad_8
DspShad_4:
	jsr	BlitShad	; Display Shadow
DspShad_8:
	move.l	NEXTOBJECT(a5),a5 	; Load Pointer To Next Object
	bra	DspShad_1
DspShad_9:
	CLIP	ON
	POPL	a5	; Retrieve A5
	rts

;***************************************************************************
;   DspBody - Display The Body			*
;                                                                          *
;   Parameters :  NONE                                                     *
;   Returns:      NONE                                                     *
;   Modifies:     ALL                                                      *
;***************************************************************************
DspBody:
	tst.w	CURRENTFRAME(a5)	; current frame in char tables
	bmi	DspBody_9	; Branch If None

	tst.b	B_INUSE(a5)	; Check If Player In Use
	beq	DspBody_9	; Exit If Not

	tst.w	SwitchReason	; Test If Screen Changed
	beq.s	DspBody_3	; Branch If Batter Screen

	CLIP	OFF
DspBody_3:	
	move.w	SCALEFACTOR(a5),d0	; Load Scale Factor
	move.w	XSCALE(a5),d6	; Load X Scale
	mulu	d0,d6	; Multiply By Scale Factor
	lsr.l	#8,d6	; Divide By 256
	move.w	d6,XScale	; Save X Scale Value
	move.w	YSCALE(a5),d7	; Load Y Scale
	mulu	d0,d7	; Multiply By Scale Factor
	lsr.l	#8,d7	; Divide By 256
	move.w	d7,YScale	; Save Y Scale Value
	jsr	DoOScale	; Set Output Scaling

	cmp.l	#Batter,a5	; Check If Batter
	bne.s	DspBody_4	; Branch If Not Batter
	jsr	BlitHead	; Display Head
	jsr	BlitBat	; Display Bat

DspBody_4:
	jsr	BlitLegs	; Display Legs
	jsr	BlitTorso	; Display Torso

	cmp.l	#Batter,a5	; Check If Batter
	beq.s	NoBall
	jsr	BlitBallHand
NoBall:
;	cmp.l	#Batter,a5	; Check If Batter
;	bne.s	DspBody_11	; Branch If Not Batter
;	jsr	BlitBNum	; Display Batter number
;DspBody_11:
	CLIP	ON
	OSCALE	#$100,#$100	; Set No Scaling
	ROT_OFF
DspBody_9:
	rts

;***************************************************************************
;   BlitTorso -  Blit Player's Torso		*
;                                                                          *
;   Parameters :  a5 - Address Of Object		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
BlitTorso:
	move.l	B_DATAPTR(a5),a3	; Load Pointer To Frames Data
	clr.w	d2	; Load Start Index Into Frame
	jsr	GetPosition	; Get Blit Coordinates
	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq	BlitTorso_9	; Branch if not Valid
	cmp.w	#256,YScale	; Check If Full Scale
	beq.s	BlitTorso_1	; Branch If It Is
	add.w	#1,d5	; Move Down One
BlitTorso_1:
	cmp.l	#Batter,a5	; Check If Batter
	bne.s	NotBatter_1	; Branch If Not Batter

   	APALETTE	#P_VINTAGE	; Set Palette 
 	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
 	move.l	d0,a1	; Move Address Of Control Block To A1
 	cmp.b	#14,POWERNUM(a1)	; Check If Powered Up
 	beq.s	Vintage_B
	APALETTE	B_TOPPALETTE(a5)
Vintage_B:
	bra	WasBatter

NotBatter_1:
;;	cmp.l	#FirstRunner,a5	; Check If Batter
;	bne.s	NotBatter_2	; Branch If Not Batter
;	APALETTE	PALETTE(a5)
;	bra	WasBatter
;NotBatter_2:
#comment
	cmp.l	#FirstRunner,a5
	bne.s	NotBatter_2
   	APALETTE	#P_HOMETPAL00	; Set Palette 
   	tst.b	FieldTeam
   	bne.s	NotBatter_2
	APALETTE	#P_VISTPAL00
	bra	WasBatter
NotBatter_2:
	cmp.l	#SecondRunner,a5
	bne.s	NotBatter_3
   	APALETTE	#P_HOMETPAL00	; Set Palette 
   	tst.b	FieldTeam
   	bne.s	NotBatter_3
	APALETTE	#P_VISTPAL00
	bra	WasBatter
NotBatter_3:
   	APALETTE	#P_VISTPAL00	; Set Palette 
   	tst.b	FieldTeam
   	bne.s	WasBatter
   	APALETTE	#P_HOMETPAL00	; Set Palette 
;  	APALETTE	PALETTE(a5)	; Set Palette 
#endcomment
   	APALETTE	#P_VINTAGE	; Set Palette 
 	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
 	move.l	d0,a1	; Move Address Of Control Block To A1
 	cmp.b	#11,POWERNUM(a1)	; Check If Powered Up
 	beq.s	Vintage
	APALETTE	PALETTE(a5)	; Set Palette 
Vintage:

WasBatter:
;	APALETTE	PALETTE(a5)	; Set Palette 
	IMAGES	BANK(a5)	; Set Image Bank
	sub.w	ZOFFSET(a5),d5	; Offset For Distance Off Ground
	jsr	Blit	; Display The Torso
BlitTorso_9:
	rts

;***************************************************************************
;   BlitLegs -  Blit Player's Legs		*
;                                                                          *
;   Parameters :  a5 - Address Of Object		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
BlitLegs:
	move.l	B_DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#Legs,d2	; Load Start Index Into Frame
	jsr	GetPosition	; Get Blit Coordinates
	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq	BlitLegs_9	; Branch if not Valid
;	APALETTE	d0	; Set Palette 
	cmp.l	#Batter,a5	; Check If Batter
	bne.s	NotBatter_L	; Branch If Not Batter

	APALETTE	#P_VINTAGE	; Set Palette 
 	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
 	move.l	d0,a1	; Move Address Of Control Block To A1
 	cmp.b	#14,POWERNUM(a1)	; Check If Powered Up
 	beq.s	Vintage_B1
	APALETTE	B_BOTPALETTE(a5)
Vintage_B1:
	bra	WasBatterL	

NotBatter_L:
	cmp.l	#FirstRunner,a5	; Check If Batter
	bne.s	NotBatter_1L	; Branch If Not Batter
	APALETTE	B_BOTPALETTE(a5)
	bra	WasBatterL	
NotBatter_1L:
	cmp.l	#SecondRunner,a5	; Check If Batter
	bne.s	NotBatter_2L	; Branch If Not Batter
	APALETTE	B_BOTPALETTE(a5)
	bra	WasBatterL	
NotBatter_2L:
	cmp.l	#ThirdRunner,a5	; Check If Batter
	bne.s	NotBatter_3L	; Branch If Not Batter
	APALETTE	B_BOTPALETTE(a5)
	bra	WasBatterL	
NotBatter_3L:
	cmp.l	#HomeRunner,a5	; Check If Batter
	bne.s	NotBatter_4L	; Branch If Not Batter
	APALETTE	B_BOTPALETTE(a5)
	bra	WasBatterL	
NotBatter_4L:

	APALETTE	#P_VINTAGE	; Set Palette 
 	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
 	move.l	d0,a1	; Move Address Of Control Block To A1
 	cmp.b	#11,POWERNUM(a1)	; Check If Powered Up
 	beq.s	Vintage2
;	APALETTE	PALETTE(a5)	; Set Palette 

	APALETTE	#P_VISBPAL	; Set Palette 
     	tst.b	FieldTeam
     	bne.s	WasBatterL
     	APALETTE	#P_HOMEBPAL	; Set Palette 
Vintage2:
WasBatterL:
	move.b	BANK(a5),d0	; Load Bank Number
	addq.b	#1,d0	; Increment Bank
	IMAGES	d0	; Set Image Bank
	sub.w	ZOFFSET(a5),d5	; Offset For Distance Off Ground
	jsr	Blit	; Display The Legs
BlitLegs_9:
	rts

;***************************************************************************
;   BlitHead -  Blit Batter's Head		*
;                                                                          *
;   Parameters :  a5 - Address Of Object		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
	.import	BatTableTeam
BlitHead:
	move.l	B_DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#Head,d2	; Load Start Index Into Frame
	jsr	GetPosition	; Get Blit Coordinates

	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq	BlitHead_9	; Branch if not Valid
	APALETTE	B_HEADPALETTE(a5)	; Set Palette 

	
	move.b	BANK(a5),d0	; Load Bank Number
	IMAGES	#BatterHead	; Set Image Bank
	cmpi.w	#16,d3	;was 19
	ble.s	regular
	APALETTE	B_HEADPALETTE(a5)	; Set Palette 
	move.w	([BatRoster],AT_headart),d0	;Batter Race 0,1,2
     	add.w	d0,d3
	sub.w	#h0000v1a,d3
	bra.s	NotRegular	; Generic
regular:	
;Put generic palette here when it comes

	APALETTE	#P_HHATPAL01

	move.b	([BatRoster],AT_hair),d0	;Batter hair 0,1
	cmp.b	#1,d0
	bne.s	NotBlond_1
	APALETTE	#P_HHATPAL02
NotBlond_1:
	btst.b	#0,Inning
	bne.s	HomeGHead
	APALETTE	#P_VHATPAL01
	cmp.b	#1,d0
	bne.s	NotBlond_2
	APALETTE	#P_VHATPAL02
NotBlond_2:




HomeGHead:
	add.w	#24,d3
	move.l	BatRoster,a6
	clr.l	d0
	move.b	AT_ethnicity(a6),d0
	beq.s	NotRegular
	cmp.w	#2,d0
	bne.s	NotRegular
;	add.w	#8,d3
	sub.w	#16,d3	;no hair for black guy
		
NotRegular:


	sub.w	ZOFFSET(a5),d5	; Offset For Distance Off Ground
	jsr	Blit	; Display The Head

BlitHead_9:
	rts
AwayArt:
	dc.l	0	;0 Braves
	dc.l	72	;1 Orioles
	dc.l	144	;2 RedSox
	dc.l	216	;3 Angels
	dc.l	288	;4 Cubs
	dc.l	360	;5 White Sox
	dc.l	432	;6 Reds
	dc.l	504	;7 Indians
	dc.l	576	;8 Rockies
	dc.l	648	;9 Tigers
	dc.l	720	;10 Marlins
	dc.l	792	;11 Astros
	dc.l	864	;12 Royals
	dc.l	0	;13 Dodgers
	dc.l	0	;14 Brewers
	dc.l	0	;15 Twins
	dc.l	315	;16 Expos
	dc.l	0	;17 Mets
	dc.l	0	;18 Yankees
	dc.l	0	;19 Athletics
	dc.l	0	;20 Phillies
	dc.l	0	;21 Pirates
	dc.l	0	;22 Cardnials
	dc.l	0	;23 Padres
	dc.l	0	;24 Giants
	dc.l	0	;25 Mariners
	dc.l	0	;26 Rangers
	dc.l	0	;27 Blue Jays
	dc.l	0	;28 Draft
	
	rts



;***************************************************************************
;   BlitBNum -  Blit Batter's Number		*
;                                                                          *
;   Parameters :  a5 - Address Of Object		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
BlitBNum:

	move.l	B_DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#Tens,d2	; Load Start Index Into Frame
	jsr	GetPosition	; Get Blit Coordinates

	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq.s	BlitBNum_9	; Branch if not Valid
	APALETTE	B_HEADPALETTE(a5)	; Set Palette 


	move.b	BANK(a5),d0	; Load Bank Number
	IMAGES	#Misc	; Set Image Bank
	sub.w	#888,d3

	move.b	([BatRoster],AT_number1),d1 ; His Jersy number (1)
	ext.w	d1
	mulu.w	#111,d1
     	add.w	d1,d3

	sub.w	ZOFFSET(a5),d5	; Offset For Distance Off Ground

	FLIP	OFF	; Turn Off Flipping
	move.l	#Batter,a1
	tst.b	FLIPFLAG(a1)	; Check If Flipped
	beq.s	DontFlipT	; Branch If Not
	neg.w	d0	; Negate The X Offset
;	FLIP	ON	; Turn On Flipping
DontFlipT


	jsr	Blit	; Display The Head

BlitBNum_9:
	
	move.l	B_DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#Units,d2	; Load Start Index Into Frame
	jsr	GetPosition	; Get Blit Coordinates
	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq.s	BlitBNum_11	; Branch if not Valid
	APALETTE	B_HEADPALETTE(a5)	; Set Palette 
	move.b	BANK(a5),d0	; Load Bank Number
	IMAGES	#Misc	; Set Image Bank
	sub.w	#888,d3

	move.b	([BatRoster],AT_number2),d1 ; His Jersy number (1)
	ext.w	d1
	mulu.w	#111,d1
     	add.w	d1,d3
	
	sub.w	ZOFFSET(a5),d5	; Offset For Distance Off Ground
	FLIP	OFF	; Turn Off Flipping
	move.l	#Batter,a1
	tst.b	FLIPFLAG(a1)	; Check If Flipped
	beq.s	DontFlipU	; Branch If Not
	neg.w	d0	; Negate The X Offset
;	FLIP	ON	; Turn On Flipping
DontFlipU

	jsr	Blit	; Display The Head
	
BlitBNum_11:
	rts


;***************************************************************************
;   BlitBat -  Blit Bat		*
;                                                                          *
;   Parameters :  a5 - Address Of Object		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
BlitBat:
	move.l	B_DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#Bat,d2	; Load Start Index Into Frame
	jsr	GetPosition	; Get unscaled Blit Coordinates

	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq	BlitBat_9	; Branch if not Valid

	btst.b	#0,BatFF(a3)	; Check For Flop
	beq.s	BlitBat_1	; Branch If Not
	FLOP	ON	; Turn On Flopping
	move.b	#1,BlitFlop	; Flop The Bat
BlitBat_1:
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	bne.s	BlitBat_2	; Branch If He Is

	btst.b	#1,BatFF(a3)	; Check For Flip
	beq.s	BlitBat_3	; Branch If Not
	FLIP	ON	; Turn On Flipping
	move.b	#1,BlitFlip	; Flip The Bat
	bra.s	BlitBat_3
BlitBat_2:
	btst.b	#1,BatFF(a3)	; Check For Flip
	beq.s	BlitBat_3	; Branch If Not
	FLIP	OFF	; Turn Off Flipping
	move.b	#-1,BlitFlip	; Set Fr Inverted Flip

BlitBat_3:
	APALETTE	#P_BAT	; Set Palette 

	cmp.l	#PlayerL,AtBatPlayer
	bne.s	NotLeftPl
	move.l	#PlayerL,d0	; Load Control Block
	bra.s	WasLeft
NotLeftPl:
	move.l	#PlayerR,d0	; Load Control Block
WasLeft:
 ;	move.l	d0,a1	; Move Address Of Control Block To A1
 ;	bra.s	NotSabr
 ;	tst.b	Light	; Check If Powered Up

	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	move.l	d0,a1	; Move Address Of Control Block To A1
 	cmp.b	#1,POWERNUM(a1)
	bne.s	NotSabr

	jsr	sabrsound
	APALETTE	#P_SABR	; Set Palette 
	add.w	#sabr0001,d3

; 	APALETTE	#P_CLUB	; Set Palette 
;	add.w	#club0001,d3
	
NotSabr:

	move.b	BANK(a5),d0	; Load Bank Number
	IMAGES	#BattersBat	; Set Image Bank
	jsr	BatBlit	; Display The Bat (custom for scaled flip flops)

	FLIP	OFF	; Turn Off Flipping
	FLOP	OFF	; Turn Off Flopping
BlitBat_9:
	rts

sabrsound:
	tst.b	SaberOn
	bne.s	wason
  	SOUND	#LightSaberOn,#0	; Set Volume
	move.b	#1,SaberOn
wason:
	rts
;***************************************************************************
;   BlitShad -  Blit Shadow		*
;                                                                          *
;   Parameters :  a5 - Address Of Object		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
BlitShad:
	move.w	XPOSITION(a5),d4	; Load Object's X Position
	move.w	YPOSITION(a5),d5	; Load Object's Y Position

	IMAGES	#Misc	; Set Image Bank
	APALETTE	#P_BALL	; Set Palette 

	tst.b	B_HASBALL(a5)	; Check If Player Has Ball
	bne.s	BlitShad_3	; Branch If He Does
	
	move.w	SCALEFACTOR(a5),d3	; Load Scale Factor
	asr.w	#5,d3	; Calculate Scaling Index
	neg.w	d3	; Negate Result
	add.w	#8,d3	; Calcluate Shadow Index

	move.l	#ShadSizes,a0	; Load Address Of Sizing Array
	sub.w	(a0,d3.w*4),d4	; Subtract From X Position
	sub.w	2(a0,d3.w*4),d5	; Subtract From Y Position

	move.w	#shad01,d0	; Load Regular Shadow Picture
	cmp.l	ControlPtr,a5	; Check If Controlled Object
	bne.s	BlitShad_1	; Branch If Not

	APALETTE	#P_MARKCL	; Set Palette 
	move.w	#mark0001+1,d0	; Load Left Player Marker
	cmp.l	#PlayerL,CONTROLBLOCK(a5)	; Check If Left Player
	beq.s	BlitShad_1	; Branch If It Isn't
	move.w	#mark0008+1,d0	; Load Right Player Marker
BlitShad_1:
	add.w	d0,d3	; Calculate Picture Number
	jsr	Blit	; Display The Shadow
	rts	

BlitShad_3:
	move.w	#ballmark,d3	; Load Regular Shadow Picture
	sub.w	#50/2,d4	; Center The Width
	sub.w	#20/2,d5	; Center The Height
	jsr	Blit	; Display The Shadow
NoBlitShad:
	rts	


ShadSizes:
	dc.w	47/2-3,14/2	; shad01
	dc.w	39/2-3,13/2	; shad02
	dc.w	33/2-2,11/2	; shad03
	dc.w	27/2-2,8/2 	; shad04
	dc.w	23/2-1,7/2 	; shad05
	dc.w	17/2-1,5/2 	; shad06
	dc.w	12/2,4/2 	; shad07
	dc.w	7/2,3/2 	; shad08
	
;***************************************************************************
;   BlitBallHand -  Blit The Ball in the hand of Fielder/Pitcher		*
;                                                                          *
;   Parameters :  a5 - Address Of Object		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
BlitBallHand:
	move.l	B_DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#HBall,d2	; Load Start Index Into Frame
	jsr	GetPosition	; Get Blit Coordinates
	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq.s	NoBlitBall	; Branch if not Valid
	APALETTE	#P_BALL	; Set Palette 
	move.b	BANK(a5),d0	; Load Bank Number
	IMAGES	#Misc	; Set Image Bank
	sub.w	ZOFFSET(a5),d5	; Offset For Distance Off Ground
	jsr	Blit	; Display The Shadow

NoBlitBall:
	rts	

;***************************************************************************
;   GetPosition - Calculate Image, X Position and Y Position for an	*
;	       image in a frame.                                        *
;				*
;   Parameters :  a5 - Address Of Object                                   *
;	       d2 - Offset In Frame Data		*
;				*
;   Returns:      d3 - Image Number		*
;	       d4 - X Position		*
;	       d5 - Y Position		*
;				*
;   Modifies:     ALL                                                      *
;***************************************************************************
GetPosition:
	move.w	XPOSITION(a5),d4	; Load X Position 
	move.w	YPOSITION(a5),d5	; Load Y Position
	move.l	B_DATAPTR(a5),a3	; Load Address Of Frame Data
	move.w	(a3,d2.w),d3	; Load Image Number
	move.b	2(a3,d2.w),d0	; Load X Offset
	ext.w	d0	; Extend To A Word
	move.b	3(a3,d2.w),d1	; Load Y Offset
	ext.w	d1	; Extend To A Word
	add.w	#YBIAS,d1	; Unbias Y Offset
	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	GetPos_1	; Branch If Not
	neg.w	d0	; Negate The X Offset
	FLIP	ON	; Turn On Flipping
GetPos_1:
	move.w	XScale,d2	; Load X Scale
	muls	d2,d0	; Multiply By Scale
	add.l	#255,d0	; Round Up
	asr.l	#8,d0	; Divide By 256
	add.w	d0,d4	; Add To X Position

	move.w	YScale,d2	; Load Y Scale
	muls	d2,d1	; Multiply By Scale
	add.w	#255,d1	; Round Up
	asr.l	#8,d1	; Divide By 256
	add.w	d1,d5	; Add To Y Position
	rts


;***************************************************************************
;   GetPositionL -  For the shadow anchoring		*
;                                                                          *
;   Parameters :  NONE                                                     *
;   Returns:      Non Zero if Valid		*
;   Modifies:     ALL                                                      *
;***************************************************************************
GetPositionL:
 	move.w	XPOSITION(a5),d4	; Load X Position
	move.w	YPOSITION(a5),d5	; Load X Position

	ext.w	d2	; Make D2 Into A Word
	move.l	B_DATAPTR(a5),a3	; Load Address Of Dots Data
	move.w	(a3,d2.w),d3	; Load Image Number

	move.b	TorsoX(a3,d2.w),d0	; Load X Offset
	ext.w	d0

	move.b	TorsoY(a3,d2.w),d1	; Load Y Offset
	ext.w	d1

	move.w	d1,d2	; Save For Validity Check
	add.w	#YBIAS,d1	; Unbias Y Offset
	lsr.w	#2,d1	; divide by 4 for shadow

	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	GetPosL_1	; Branch If Not
	neg.w	d0	; Negate The X Offset
	FLIP	ON	; Turn On Flipping
GetPosL_1:
	add.w	d0,d4	; Add To X Position
	add.w	d1,d5	; Add To Y Position

	cmp.l	#Batter,a5	; see if batter
	bne.s	GetPos_2	; else not
	sub.w	#10,d5	; sub a fudge #?

	cmp.w	#Bat,d2	; see if batter
	bne.s	GetPos_2	; else not
	sub.w	#10,d5	; sub a fudge #?
	
GetPos_2:
	rts

	end





