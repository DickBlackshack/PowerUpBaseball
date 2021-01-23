;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************

	.export	HalfInnScreen,EndGameFlag
	.export	LosingPlayer,FreeBee
	.export	WinningPlayer
	.export	ThreeUp3Down

	.import	incinns1,incinns2,hurryup,GameMode
	.import	InitPlayer,CameraX,AtBatPlayer,PlayerL,PlayerR
	.import	NewBatterUp,ScoreObj,CoinageScreen,CoinageScreen2

	.import	Pitcher,Batter,FirstBase,SecondBase,ShortStop,FirstRunner
	.import	ThirdBase,Catcher,LeftField,CenterField,RightField

 	.import	Player,GetBatterRoster,AllocObject,Anim,blit_card2
 	.import	SwitchReason,Inning,save_stats
 	.import	CycleGame,LoadPtrs
 	.import	PlayHomeDone,GameStart1,GameStart2
 	.import	DspBody,NoY,PowerBar_1,PowerBar_2,PowerFrame
 	.import	InitTrackball,teamattrib_size,attrib_size
 	.import	BackArt,ROSTERS,DraftAttr,ROSTERsize
 	.import	InitObjects,InitProcs
 	.import	InitJoys,draftteam
 	.import	HomeRunner,plpos
 	.import	ThirdRunner
 	.import	SecondRunner
 	.import	AnimPlayer2
 	.import	InitJoyWatch
 	.import	InitBackgnd,SinglePlayer
 	.import	InitControls

	.import	CharTrans,setAIpitcher
	.import	F5CharTrans
	.import	F1CharTrans
	.import	F2CharTrans
	.import	SetHomePal
	.import	CLRSWING
	.import	FontAdjust,ClearScores
	.import	FontSpacing,NEWvs
	.import	fnt1Spacing,BatRoster,AtPitPlayer,GetRoster

	.import	DScore,SetExtra
	.import	BIGCharTrans,HelpHalf
	.import	ScorePtr,HomePlayer,AwayPlayer,BigWinObj
	.import	fnt5Spacing,BallOnGround
	.import	fnt2Spacing,extrainnings,ProcessTime
	.import	NewVSBlit,CalcAudits,total_complete

	.import	NeoCharTrans
	.import	neo1Spacing
	.import	neo2Spacing
	.import	neo3Spacing
	.import	neo4Spacing

	.import	FieldTeam
	.import	InitTeam
	.import	AlphaOrder
	.import	FreeAward


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
	#include	"rosters.h"

;***************************************************************************
***************************************************************************
;		   PRINT "xxx" centered	*
***************************************************************************
PRINTCT:	macro	string
	#ifndef	PrintCentered
	.global	PrintCentered
	#endif
	#ifndef	Print
	.global	Print
	#endif
	move.l	#striii\@,a0
	clr.w	d6	
	move.w	#$7FFF,d7
	jsr	PrintCentered	;entry point for plot print
	bra	dprrr\@
striii\@:
	dc.b	string,0
dprrr\@:	ds	0	;align prg counter
	endm


;***************************************************************************

	.region.s	"RAM"
HTimerPtr	ds.l	1
NewSeries	ds.b	1
AnySeries	ds.b	1
BATX	ds.w	1
PITX	ds.w	1
savedbatter	ds.w	1
tbx1	ds.w	1
tby1	ds.w	1
pnamey	ds.w	1
pcursor	ds.w	1
PIndex	ds.w	1	;for alpha order
curs	ds.w	1
FreeBee	ds.w	1
pitcnt	ds.w	1
incomplete	ds.w	1
savepitcher	ds.l	1
pitmenu	ds.b	8
TempPower	ds.b	1
pitmenuptr	ds.l	1
WinningPlayer	ds.l	1
LosingPlayer	ds.l	1
EndGameFlag	ds.b	1
ThreeUp3Down	ds.w	1

sensitive	equ	15
	.region	"RomCode"

;***************************************************************************


HalfInnScreen
	tst.b	GameMode
	bne.s	.NotAttMode
	rts		;no halfinn screen in attract
.NotAttMode
	SOUND	#HalfInningMusic,#0

	move.b	([AtBatPlayer],HITS),ThreeUp3Down ;for 3 up 3 down sound call

	jsr	InitProcs	; Initialize Object System

	clr.b	TempPower

	jsr	InitJoys	; Initialize Joy Stick Data
	jsr	InitControls	; Initialize Controls
;	jsr	InitPlayers	; Initialize All Fielders

	jsr	InitJoyWatch	; Watch The Inputs

	jsr	InitTrackball 	; Initialize Trackball
;	jsr	StrikeOuts

;set roster addresses for outfield
	move.l	AtPitPlayer,a0
	move.l	(ROSTERPTR+4,a0),Catcher+B_ROSTERADR
	move.l	(ROSTERPTR+8,a0),FirstBase+B_ROSTERADR
	move.l	(ROSTERPTR+12,a0),SecondBase+B_ROSTERADR
	move.l	(ROSTERPTR+16,a0),ShortStop+B_ROSTERADR
	move.l	(ROSTERPTR+20,a0),ThirdBase+B_ROSTERADR
	move.l	(ROSTERPTR+24,a0),LeftField+B_ROSTERADR
	move.l	(ROSTERPTR+28,a0),CenterField+B_ROSTERADR
	move.l	(ROSTERPTR+32,a0),RightField+B_ROSTERADR
;pitcher gets set in initpitcher
;now here
	clr.w	d0
	move.b	([AtPitPlayer],FIRSTPITCHER),d0 ;first pitcher
	move.l	([AtPitPlayer],d0.w*4,ROSTERPTR),Pitcher+B_ROSTERADR ;point at current pitchers roster adr



	tst.l	WinningPlayer
	bne	endgame

	btst	#0,Inning	;top of inning?
	bne	.bottom	;no need to buyin
;	cmp.b	#18,Inning	;top of tenth inning
;	blt.s	.notextra	;
;	move.b	PlayerL+RUNS,d0
;	cmp.b	PlayerR+RUNS,d0
;	bne	.endgame	;game over
.notextra	move.b	Inning,d0
	lsr.b	#1,d0
	tst.b	PlayerL+START	;human?
	beq.s	.nothuman
	cmp.b	PlayerL+INNINGSBOUGHT,d0
;	beq.s	.buyin
	bge.s	.buyin
.nothuman
	tst.b	PlayerR+START	;human?
	beq	.bottom	;no need to buyin
	cmp.b	PlayerR+INNINGSBOUGHT,d0
;	bne	.bottom	;no need to buyin
	blt	.bottom	;no need to buyin
.buyin			;a player has run out of innings

	jsr	CoinageScreen2
	clr.b	PlayerL+START	;handle a player dropping out
	SWITCH	#START1,#81H,#GameStart1
	move.b	Inning,d0
	lsr.b	#1,d0	;convert inning halves to whole
	cmp.b	PlayerL+INNINGSBOUGHT,d0
	bge.s	.nopl1	;branch if more innings than tickets
	move.b	#1,PlayerL+START
	SWITCH	#START1,#81H,#0
.nopl1
	clr.b	PlayerR+START	;handle a player dropping out
	SWITCH	#START2,#81H,#GameStart2
	move.b	Inning,d0
	lsr.b	#1,d0	;convert inning halves to whole
	cmp.b	PlayerR+INNINGSBOUGHT,d0
	bge.s	.nopl2	;branch if more innings than tickets
	move.b	#1,PlayerR+START
	SWITCH	#START2,#81H,#0
.nopl2

.bottom

	move.w	#3,BackArt	;half inn screen
	jsr	InitBackgnd	; Initialize Background

	clr.b	PlayHomeDone
	clr.w	SwitchReason	; Clear Ball Hit Flag

;	move.l	#200,GroundY

	move.b	#P_BALL,card_pal

	move.w	#0,BATX
	move.w	#384/2,PITX
	move.w	#arrowb4,curs
;	move.b	#P_FONTB1,card_pal
	cmp.l	#PlayerL,AtBatPlayer
	beq.s	.leftbatter
	move.w	#0,PITX
	move.w	#384/2,BATX
;	move.w	#select1a,curs
	move.w	#arrowa4,curs
;	move.b	#P_FONTR1,card_pal
.leftbatter


	move.b	PlayerL+START,d0
	or.b	PlayerR+START,d0
	beq	NobodyPlaying	;nobody playing

NotEnd
	tst.b	Inning
	bne.s	.sayinning
	SOUND	#StartGame,#0
	bra	.said
.sayinning
	move.b	#BottomOfTheInning,d0
	btst	#0,Inning	;18=top of tenth inning
	bne	.botinn
	move.b	#TopOfTheInning,d0
.botinn
	move.b	Inning,d1
;	add.b	#1,d1
.notminus	lsr.b	d1
	SOUND	d0,d1
.said



;	move.w	#1,PlayerL+BATTERNUM	;test
;	move.w	#1,PlayerR+BATTERNUM	;test


	jsr	B_CardObj


;	move.b	#10,PlayerL+FIRSTPITCHER ;test
;	move.b	#10,PlayerR+FIRSTPITCHER ;test


	jsr	P_CardObj

	jsr	PowerFrame
	jsr	PowerBar_1
	jsr	PowerBar_2

	tst.b	([AtPitPlayer],START) ;AI selects
	bne.s	.noAI

	move.l	AtPitPlayer,a0
	jsr	setAIpitcher

	jsr	AllocObject	; Allocate An Object
	beq.s	.noAI	; Branch If None
;	move.l	#BatDISP,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#AIinput,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#50,COUNTER(a0)	;time till AI makes selection
;	move.l	#BatCards,PARSEPOINTER(a0)	; Set Animation String
;	move.b	#1,STATIONARY(a0)	; Set As Non-Stationary
;	move.w	#10,ZPOSITION(a0)	; Load Z Position Of First Object
.noAI

	jsr	AllocObject	; Allocate An Object
	beq.s	.notimer	; Branch If None
	move.l	#HTimer,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#400,COUNTER(a0)	;time for human to make selection, 200?
	move.l	a0,HTimerPtr	;to adjust timer for power up
.notimer
	tst.l	SinglePlayer
	beq.s	NotSingle
	cmp.b	#2,([SinglePlayer],stat_defeat)
	bge.s	NotSingle	;no help if 2 wins
	tst.b	([AtPitPlayer],START) ;Pitcher is human, print
	beq.s	NotSingle

	jsr	HelpHalf
NotSingle:

;............................................................................

HalfLoop
	jsr	CycleGame	; Perform One Game Cycle


;	move.w	PlayerR+TRACKX,CameraX ;test



	tst.b	PlayHomeDone
	beq	HalfLoop
;	DELAY	#20

	jsr	InitProcs	; Initialize Object System

;	SOUND	#BackGroundMusic,#BackGroundMusic	; Init Sounds System
	SOUND	#BatterUpOrgan,#0	; Set Volume


;first batter sound call
;	jsr	GetBatterRoster	;Get player's position
;	move.w	([BatRoster],AT_namesnd),d1	;Batter Race 0,1,2
;	move.b	d1,d3
;	lsr.w	#8,d1
;	move.b	d1,SndBit1
;	SOUND3	#SetCurrentPlayer,SndBit1,SndBit2
;	SOUND3	#SetCurrentPlayer,d1,d3
;	SOUND	#BatterLeadsOff,#0


	rts		;back to game

reset
	move.b	#1,PlayHomeDone	;exit halfinn
	move.b	#1,EndGameFlag	; Flag Game Over
	rts

	jmp	reset
	jmp	NewBatterUp	; Continue If Not

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

           .import	swing,blit_card,batternum
	.import	card_pal,DIM,NOTDIM,draft_stat
B_CardObj:   ;this is the batters side of the screen
	jsr	AllocObject	; Allocate An Object
	beq.s	B_Card	; Branch If None
	move.l	#BatDISP,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.l	#BatCards,PARSEPOINTER(a0)	; Set Animation String
	move.b	#1,STATIONARY(a0)	; Set As Non-Stationary
	move.w	#10,ZPOSITION(a0)	; Load Z Position Of First Object
B_Card:
	rts

BatCards
;	DISPLAY	BlitCard1
	LASTFRAME 60
;	DISPLAY	BlitCard2
	LASTFRAME 60
;	DISPLAY	BlitCard3
	LASTFRAME 60
	JUMP	BatCards
;	DEALLOC

	.align	2

hiX	equ	20
hiY	equ	60

BatDISP
;	SETPRINT	#13,#12,#fnt1,#0
;	clr.l	FontAdjust
;	move.l	#fnt1Spacing,FontSpacing
;	move.l	#F1CharTrans,CharTrans	; character translation table
;	APALETTE	#P_FONTY1

	SETPRINT	#13,#17,#neo4,#0
	clr.l	FontAdjust
	move.l	#neo4Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEOYEL	;temp? waiting for neo color pals

	move.w	#20,d6	;X
	add.w	BATX,d6	;the side of the screen the batter is on
	PPRINT	d6,#5,"NOW BATTING:"
;batters name
;	jsr	SetPalBatx
;	move.w	#30,d6	;X
;	add.w	BATX,d6	;the side of the screen the batter is on
;	PLOT	d6,#35
;	jsr	GetBatterRoster
;	lea.l	AT_name(a0),a6	;get to name
;	PRINTS	a6
;batters card
	jsr	GetBatterRoster
	move.l	a0,a6
	move.w	#20,d6	; Set X Position
	add.w	BATX,d6	;the side of the screen the batter is on
	move.w	#27,d7	; Set Y Position

;plaque
	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_NEWSCORE	; Palette Number
	move.w	d6,d0
	sub.w	#14,d0
	move.w	d7,d1
	sub.w	#13,d1
	move.w	#carda,d2
	tst.w	BATX
	beq.s	.plaque	;use red plaque
	move.w	d6,d0
	sub.w	#21,d0
	move.w	d7,d1
	sub.w	#10,d1
	move.w	#cardb,d2
.plaque
	BLIT	d2,d0,d1	;plaque


	jsr	blit_card2	;card 1
	jsr	draft_stat


;	SETPRINT	#13,#12,#fnt1,#0
;	clr.l	FontAdjust
;	move.l	#fnt1Spacing,FontSpacing
;	move.l	#F1CharTrans,CharTrans	; character translation table
;	APALETTE	#P_FONTY1

	SETPRINT	#13,#17,#neo4,#0
	clr.l	FontAdjust
	move.l	#neo4Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEOYEL	;temp? waiting for neo color pals

	move.w	([AtBatPlayer],BATTERNUM),savedbatter   ;Else set to the beginning
	move.w	#20,d6	;X
	add.w	BATX,d6	;the side of the screen the batter is on
	PPRINT	d6,#122,"DUE UP:"
	jsr	incbatnum
	move.w	#140,d7
	jsr	pbname
	jsr	incbatnum
	move.w	#163,d7
	jsr	pbname
	jsr	incbatnum
	move.w	#186,d7
	jsr	pbname
	jsr	incbatnum
	move.w	#209,d7
	jsr	pbname
	move.w	savedbatter,([AtBatPlayer],BATTERNUM)   ;Else set to the beginning

	rts

pbname			;print batters name
;	APALETTE	#P_BALL
	jsr	SetPalBatx
	move.w	#30,d6	;X
	add.w	BATX,d6	;the side of the screen the batter is on
	PUSHL	d7

	add.w	#4,d7
	PLOT	d6,d7
	jsr	GetBatterRoster
;	clr.l	FontSpacing	; Non-Proportional Spacing
;	move.l	#fnt1Spacing,FontSpacing

	cmp.b	#draftteam,([AtBatPlayer],team)  ;is it a draft team?
	beq.s	.NoBatNums

	nop
;	PRINTDECB AT_order(a0),#1,JRGT ; PRINT "123456789" DISABLED
.NoBatNums

;	PRINT	" "

	move.w	#30+16,d6	;X
	add.w	BATX,d6	;the side of the screen the batter is on
	POPL	d7
	PLOT	d6,d7

;	lea	([BatRoster],AT_name),a0
;	move.l	#fnt1Spacing,FontSpacing
;	PRINTS	a0

	lea	([BatRoster],AT_nameart),a0
	IMAGES	#Cards	; Load Image Bank
	APALETTE	#P_NEWSCORE
	BLIT	(a0),d6,d7

	rts

incbatnum
	add.w	#1,([AtBatPlayer],BATTERNUM)
	cmp.w	#10,([AtBatPlayer],BATTERNUM)  ;Is the Last Batter Up?
	bne.s	.nowrap	   ;No.. then Branch
	move.w	#1,([AtBatPlayer],BATTERNUM)   ;Else set to the beginning
.nowrap
	rts

;............................................................................

P_CardObj:   ;this is the pitchers side of the screen
	jsr	AllocObject	; Allocate An Object
	beq	P_Card	; Branch If None
	move.b	#1,STATIONARY(a0)	; Set As Non-Stationary
	move.w	#130,ZPOSITION(a0)	; Load Z Position Of First Object
	move.l	#PitDISP,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.l	#PitCards,PARSEPOINTER(a0)	; Set Animation String
	move.w	#100,COUNTER(a0)	;delay buttons

	move.w	([AtPitPlayer],TRACKY),tby1 ;init trackball
	move.w	([AtPitPlayer],TRACKX),tbx1 ;init trackball
	clr.w	pcursor
	clr.w	PIndex

;create list of available pitchers
	move.b	([AtPitPlayer],FIRSTPITCHER),d0 ;first pitcher
	move.l	([AtPitPlayer],PITAVAIL),d1
	move.w	#-1,pitcnt
	move.l	#pitmenu,a0
.listlp	btst.l	d0,d1
	beq.s	.used
	move.b	d0,(a0)+
	add.w	#1,pitcnt
.used
	add.b	#1,d0
.wrap	cmp.b	([AtPitPlayer],FIRSTPITCHER),d0
	beq.s	.done
	cmp.b	#14,d0	;last pitcher
	bne.s	.listlp
	move.b	#9,d0	;firstpitcher on team
	bra.s	.wrap
.done
	clr.b	(a0)	;end of list


P_Card:
	rts


;	move.b	([AtPitPlayer],FIRSTPITCHER),d0 ;pitchers pos
;	lea	([AtPitPlayer],d0.w*4,ROSTERPTR),a0
;	move.b	AT_ethnicity(a0),d0


PitCards
;	DISPLAY	BlitCard1
	LASTFRAME 60
;	DISPLAY	BlitCard2
	LASTFRAME 60
;	DISPLAY	BlitCard3
	LASTFRAME 60
	JUMP	PitCards
;	DEALLOC

	.align	2

PitDISP
;	tst.b	([AtPitPlayer],SECONDBUTTON)
;	beq.s	.nopower
;	tst.b	([AtPitPlayer],SECONDBUTTON)
;	move.b	#1,TempPower
;.nopower

;	SETPRINT	#13,#12,#fnt1,#0
;	clr.l	FontAdjust
;	move.l	#fnt1Spacing,FontSpacing
;	move.l	#F1CharTrans,CharTrans	; character translation table
;	APALETTE	#P_FONTY1

	SETPRINT	#13,#17,#neo4,#0
	clr.l	FontAdjust
	move.l	#neo4Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEOYEL	;temp? waiting for neo color pals

	move.w	#20,d6	;X
	add.w	PITX,d6	;the side of the screen the batter is on
	PPRINT	d6,#5,"NOW PITCHING:"
;pitchers name
;	APALETTE	#P_BALL
	jsr	SetPalPitx
	move.w	#30,d6	;X
	add.w	PITX,d6	;the side of the screen the batter is on
	PLOT	d6,#35
	move.l	AtPitPlayer,a0
	move.w	pcursor,d1
	move.b	(pitmenu,d1),d0
;	move.b	FIRSTPITCHER(a0),d0
	ext.w	d0

;	jsr	GetRoster
	move.l	([AtPitPlayer],d0.w*4,ROSTERPTR),a0


	move.l	a0,savepitcher
	lea.l	AT_name(a0),a6	;get to name
;	PRINTS	a6
;pitchers card
;	jsr	GetBatterRoster
	move.l	savepitcher,a6
	move.w	#20,d6	; Set X Position
	add.w	PITX,d6	;the side of the screen the batter is on
	move.w	#27,d7	; Set Y Position

;plaque
	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_NEWSCORE	; Palette Number
	move.w	d6,d0
	sub.w	#14,d0
	move.w	d7,d1
	sub.w	#13,d1
	move.w	#carda,d2
	tst.w	PITX
	beq.s	.plaque	;use red plaque
	move.w	d6,d0
	sub.w	#21,d0
	move.w	d7,d1
	sub.w	#10,d1
	move.w	#cardb,d2
.plaque
	BLIT	d2,d0,d1	;plaque

	jsr	blit_card2	;card 1
	move.w	#9,plpos
	jsr	draft_stat

;pitchers menu
;	SETPRINT	#13,#12,#fnt1,#0
;	clr.l	FontAdjust
;	move.l	#fnt1Spacing,FontSpacing
;	move.l	#F1CharTrans,CharTrans	; character translation table
;	APALETTE	#P_FONTY1

	SETPRINT	#13,#17,#neo4,#0
	clr.l	FontAdjust
	move.l	#neo4Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEOYEL	;temp? waiting for neo color pals

	move.w	#20,d6	;X
	add.w	PITX,d6	;the side of the screen the batter is on
	PPRINT	d6,#122,"PITCHERS:"
	move.w	#140,pnamey
	move.l	#pitmenu,pitmenuptr
.nextname	jsr	ppname
	add.l	#1,pitmenuptr
	tst.b	([pitmenuptr])
	bne.s	.nextname
;cursor
;	jsr	BallService
	move.w	PITX,d4
	add.w	#15,d4	;X
	move.w	pcursor,d5
	mulu	#yspace,d5	;pitcher menu y spacing
	add.w	#136,d5	;Y
	move.w	curs,d3

;	IMAGES	#Initial	; Load Image Bank
;	APALETTE	card_pal

	IMAGES	#Misc	; Load Image Bank
	APALETTE	#P_NEWSCORE

	BLIT	d3,d4,d5
;input
	sub.w	#1,COUNTER(a5)
	bpl	.nobut	;ignore buts for a little bit

	jsr	BallService
	tst.b	([AtPitPlayer],BUTTONS)
	beq	.nobut

	tst.b	([AtPitPlayer],SECONDBUTTON)
	beq.s	.nopow

	tst.b	([AtPitPlayer],POWERUP)
	beq.s	.nopow

	tst.b	TempPower
	bne	.nobut	;already powered

	cmp.w	#56*256,([AtPitPlayer],TOTALPOWER)
	ble	.nobut	;not enough
	sub.w	#55*256,([AtPitPlayer],TOTALPOWER)	; subtract from total power

	move.b	#1,TempPower	;pick other pitchers
	clr.w	pcursor	;pinch only current pitcher
	move.w	#1000,([HTimerPtr],COUNTER) ;extra time
	clr.b	([AtPitPlayer],BUTTONS)
	clr.b	([AtPitPlayer],SECONDBUTTON)
	clr.b	([AtPitPlayer],POWERUP)
	bra.s	.nobut

.nopow
;	move.b	([AtPitPlayer],SECONDBUTTON),d0
;	move.b	([AtPitPlayer],POWERUP),d1
;	move.b	([AtPitPlayer],BUTTONS),d2
;	trap	#1

	move.b	#1,PlayHomeDone

	move.w	pcursor,d1

	tst.b	TempPower	;pick other pitchers
	bne.s	.pinched

	tst.w	pcursor
	beq.s	.same	;didn't change the pitcher
.pinched	move.w	#0x100,([AtPitPlayer],PITCHERSTRENGTH) ; Set Pitcher not tired

	clr.w	d0

	move.b	(pitmenu,d1),d0	;new pitcher
	move.b	([AtPitPlayer],FIRSTPITCHER),d2 ;save old pitcher
	move.b	d0,([AtPitPlayer],FIRSTPITCHER) ;first pitcher
	move.l	([AtPitPlayer],PITAVAIL),d1 ;can only do long bits in registers
	tst.b	TempPower	;pick other pitchers
	bne.s	.DontRetire	;dont retire if pinching
	bclr.l	d2,d1	;old pitcher retired
	move.l	d1,([AtPitPlayer],PITAVAIL)
.DontRetire
	move.l	([AtPitPlayer],d0.w*4,ROSTERPTR),Pitcher+B_ROSTERADR ;point at current pitchers roster adr

.same
	clr.b	([AtPitPlayer],BUTTONS)
.nobut

	tst.w	COUNTER(a5)
	bne.s	.noinit
	move.w	([AtPitPlayer],TRACKY),tby1 ;init trackball
	move.w	([AtPitPlayer],TRACKX),tbx1 ;init trackball
.noinit

	rts



yspace	equ	18

ppname			;print batters name
;	APALETTE	#P_BALL
	jsr	SetPalPitx
	move.w	#30,d6	;X
	add.w	PITX,d6	;the side of the screen the batter is on
	PLOT	d6,pnamey
	move.l	AtPitPlayer,a0
	move.b	([pitmenuptr]),d0
	ext.w	d0

;	jsr	GetRoster
	move.l	([AtPitPlayer],d0.w*4,ROSTERPTR),a0

	move.l	a0,savepitcher
	lea.l	AT_nameart(a0),a6	;get to name
;	PRINTS	a6


	IMAGES	#Cards	; Load Image Bank
	APALETTE	#P_NEWSCORE
	BLIT	(a6),d6,pnamey


	add.w	#yspace,pnamey	;Y space by 18
	rts


SetPalBatx
;	APALETTE	#P_FONTR1
;	cmp.w	#100,BATX
;	blt.s	.p1color
;	APALETTE	#P_FONTB1
.p1color	rts


SetPalPitx
;	APALETTE	#P_FONTR1
;	cmp.w	#100,PITX
;	blt.s	.p1color
;	APALETTE	#P_FONTB1
.p1color	rts




BallService	;ball service for the halfinn screen

	tst.w	([AtPitPlayer],START)
	beq	nobcontrol	;no player=no control


;switch to x movement if power-up 2 is on
	tst.b	TempPower ;power used?
	bne	Ballx	;select across teams


	move.w	tby1,d0
	sub.w	([AtPitPlayer],TRACKY),d0

	cmp.w	#sensitive,d0
	blt.s	.noinc
	move.w	([AtPitPlayer],TRACKY),tby1
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove	; Init Sounds System
	add.w	#1,pcursor
	jmp	.nodec
.noinc
	cmp.w	#-sensitive,d0
	bgt.s	.nodec
	move.w	([AtPitPlayer],TRACKY),tby1
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove	; Init Sounds System
	sub.w	#1,pcursor
.nodec
	cmp.w	#-1,pcursor
	bne	.notneg
	move.w	pitcnt,pcursor	;max cursor value
.notneg
	move.w	pcursor,d0
	cmp.w	pitcnt,d0	;max cursor value
	ble	.notmax
	move.w	#0,pcursor	;wrap to first pitcher card
.notmax
	rts
Ballx
	move.w	tbx1,d0
	sub.w	([AtPitPlayer],TRACKX),d0

	cmp.w	#sensitive,d0
	blt.s	.noinc
	move.w	([AtPitPlayer],TRACKX),tbx1
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove	; Init Sounds System

	move.w	pcursor,d1
	move.b	(pitmenu,d1.w),d0
	ext.w	d0
	lea.l	([AtPitPlayer],d0.w*4,ROSTERPTR),a0 ;point at current pitchers roster adr
;	add.l	#teamattrib_size,(a0) ;next team
	add.w	#1,PIndex	;next team
	cmp.w	#27,PIndex
	ble.s	.nomax
	clr.w	PIndex	;wrap
.nomax
	jmp	.nodec
.noinc
	cmp.w	#-sensitive,d0
	bgt.s	.nodec
	move.w	([AtPitPlayer],TRACKX),tbx1
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove	; Init Sounds System

	move.w	pcursor,d1
	move.b	(pitmenu,d1.w),d0
	ext.w	d0
	lea.l	([AtPitPlayer],d0.w*4,ROSTERPTR),a0 ;point at current pitchers roster adr
;	sub.l	#teamattrib_size,(a0) ;next team
	sub.w	#1,PIndex	;next team
	bpl.s	.nomin
	move.w	#27,PIndex	;wrap
.nomin
.nodec

;	move.w	plpos,d0	;batters position on team
	move.w	pcursor,d1
	move.b	(pitmenu,d1.w),d0
	ext.w	d0
	mulu	#28,d0	;number of teams
	add.w	PIndex,d0	;selector
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

nobcontrol
	rts



AIinput
	sub.w	#1,COUNTER(a5)
	bpl.s	.notyet
	move.b	#1,([AtPitPlayer],BUTTONS) ;AI selects

	tst.b	([AtBatPlayer],BUTTONS)
	beq.s	.notyet
	move.b	#1,PlayHomeDone	;human aborts early

.notyet	rts

;............................................................................

DEBUG
	.import	SetSysFont
	jsr	SetSysFont	; Set Up For Font 0
	APALETTE	#P_BALL	; Use Font Palette
	APALETTE	#P_ZONE	; Use Font Palette

	PLOT	#310,#5
	PRINTHEX	#PlayerL+BATTINGORDER,#2
;	PRINTHEX	#PlayerR+FIRSTPITCHER,#2

	PLOT	#10,#170
	move.l	AtBatPlayer,a0
	lea	BATTERNUM(a0),a0
	PRINTHEX	a0,#2

	rts


;............................................................................

ScoreAnimHalf
           SETVEL    0,-0x220,-1
           LASTFRAME 40	;how far down it comes
           SETVEL    0,0,-1
.hold	LASTFRAME 45
	JUMP	.hold
;	DEALLOC

	.align	2


;HomeRunnerPARSE
;	SETVEL	380,-50,8
;	SPRITE	b04a01,5
;	SPRITE	b04a02,5
;	SPRITE	b04a03,5
;	SPRITE	b04a04,5
;	JUMP	CatcherPARSE

	.align	2


;***************************************************************************

season_completed
	clr.b	(winCNT,d6)
	clr.b	(seriesCNT,d6)


;***************************************************************************

HTimer
	sub.w	#1,COUNTER(a5)
	bne.s	.notyet
	move.b	#1,PlayHomeDone
.notyet	rts

;***************************************************************************

end_but
	sub.w	#1,COUNTER(a5)
	bpl.s	.nobutsballs	;ignore buts for a little bit
	tst.b	([AtBatPlayer],BUTTONS)
	bne.s	.cont
	tst.b	([AtPitPlayer],BUTTONS)
	bne.s	.cont
	cmp.w	#-1000,COUNTER(a5)
	bne.s	.nobuts
.cont
	move.b	#1,PlayHomeDone	;exit
.nobuts	rts

.nobutsballs
	move.w	([AtPitPlayer],TRACKX),tbx1 ;init trackball
	rts
;***************************************************************************
;***************************************************************************
;		   PRINT 'STRING'        		*
;***************************************************************************
PRINC:	macro	string
	#ifndef	PrintCentered
	.global	PrintCentered
	#endif
	move.l	#striii\@,a0
	clr.w	d6	
	move.w	#$7FFF,d7
	jsr	PrintCentered	;entry point for plot print
	bra	dprrr\@
striii\@:
	dc.b	string,0
dprrr\@:	ds	0	;align prg counter
	endm

;***************************************************************************
Series1
	IMAGES	#Title
	APALETTE	#P_TITLERB
	BLIT	#pinrb,#0,#0

;	SETPRINT	#16,#30,#fnt2,#0
;	clr.l	FontAdjust
;	move.l	#fnt2Spacing,FontSpacing
;	move.l	#F2CharTrans,CharTrans ; character translation table
;	APALETTE	#P_FONTW1

	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals


	PLOT	#192,#10
	PRINC	"CONGRATULATIONS"
	CARRET
	PRINC	"YOU HAVE ADVANCED"
	CARRET
	PRINC	"TO THE PLAYOFFS"
	CARRET

	tst.w	FreeAward
	beq	rts1

	PRINC	"AND EARNED A FREE"
	CARRET
	PRINC	"GAME AGAINST THE"
	CARRET
	APALETTE	#P_NEOYEL
	PRINC	"AMERICAN LEAGUE"
	CARRET
	PRINC	"ALL STARS"

	move.w	#29,FreeBee

rts1	rts

;***************************************************************************
Series2
	IMAGES	#Title
	APALETTE	#P_TITLERB
	BLIT	#pinrb,#0,#0

;	SETPRINT	#16,#30,#fnt2,#0
;	clr.l	FontAdjust
;	move.l	#fnt2Spacing,FontSpacing
;	move.l	#F2CharTrans,CharTrans ; character translation table
;	APALETTE	#P_FONTW1

	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals

	PLOT	#192,#80
	PRINC	"CONGRATULATIONS"
	CARRET
	PRINC	"YOU HAVE DEFEATED"
	CARRET
	PRINC	"THE MARINERS"


	rts

;***************************************************************************
Series3
	IMAGES	#Title
	APALETTE	#P_TITLERB
	BLIT	#pinrb,#0,#0

;	SETPRINT	#16,#30,#fnt2,#0
;	clr.l	FontAdjust
;	move.l	#fnt2Spacing,FontSpacing
;	move.l	#F2CharTrans,CharTrans ; character translation table
;	APALETTE	#P_FONTW1

	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals

	PLOT	#192,#80
	PRINC	"CONGRATULATIONS"
	CARRET
	PRINC	"YOU HAVE DEFEATED"
	CARRET
	PRINC	"THE REDS"


	rts

;***************************************************************************
Series4
	IMAGES	#Title
	APALETTE	#P_TITLERB
	BLIT	#pinrb,#0,#0

;	SETPRINT	#16,#30,#fnt2,#0
;	clr.l	FontAdjust
;	move.l	#fnt2Spacing,FontSpacing
;	move.l	#F2CharTrans,CharTrans ; character translation table
;	APALETTE	#P_FONTW1

	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals

	PLOT	#192,#10
	PRINC	"CONGRATULATIONS"
	CARRET
	PRINC	"YOU HAVE DEFEATED"
	CARRET
	PRINC	"THE INDIANS"
	CARRET

	tst.w	FreeAward
	beq	rts4

	PRINC	"AND EARNED A FREE"
	CARRET
	PRINC	"GAME AGAINST THE"
	CARRET
	APALETTE	#P_NEOYEL
	PRINC	"NATIONAL LEAGUE"
	CARRET
	PRINC	"ALL STARS"

	move.w	#30,FreeBee

rts4	rts

;***************************************************************************
Series5
	IMAGES	#Title
	APALETTE	#P_TITLERB
	BLIT	#pinrb,#0,#0

;	SETPRINT	#16,#30,#fnt2,#0
;	clr.l	FontAdjust
;	move.l	#fnt2Spacing,FontSpacing
;	move.l	#F2CharTrans,CharTrans ; character translation table
;	APALETTE	#P_FONTW1

	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals

	PLOT	#192,#10
	PRINC	"CONGRATULATIONS"
	CARRET
	PRINC	"YOU HAVE WON"
	CARRET
	PRINC	"THE WORLD SERIES"
	CARRET

	tst.w	FreeAward
	beq	rts5

	PRINC	"AND EARNED A FREE"
	CARRET
	PRINC	"GAME AGAINST THE"
	CARRET
	APALETTE	#P_NEOYEL
	PRINC	"DESIGN TEAM"

	move.w	#31,FreeBee

rts5	rts


;***************************************************************************

ShowScore
	IMAGES	#Title
	APALETTE	#P_TITLERB
	BLIT	#pinrb,#0,#0

;	SETPRINT	#16,#24,#fnt1,#0
;	clr.l	FontAdjust
;	move.l	#fnt1Spacing,FontSpacing
;	move.l	#F1CharTrans,CharTrans ; character translation table
;	APALETTE	#P_FONTR1

	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals


	cmp.l	#PlayerL,WinningPlayer
	bne.s	.noBlinkL
	move.w	ProcessTime,d0
	and.w	#8,d0
	beq	.BlinkL	;blink it
.noBlinkL

	PLOT	#18,#109
	move.w	PlayerL+TEAMNUMBER,d0

	cmp.w	#draftteam,d0
	bne.s	.nodraft1	;branch if not a draft team
	lea.l	PlayerL+letters,a0
	clr.w	d6
	move.w	#3,d7	;print 3 letters
	jsr	Print
	bra	.Wnamedone
.nodraft1

	asl.w	#4,d0	;times 16
	lea.l	(TeamNames,d0.w),a0
	PRINTS	a0
.Wnamedone

;	SETPRINT	#16,#24,#fnt2,#0
;	clr.l	FontAdjust
;	move.l	#fnt2Spacing,FontSpacing
;	move.l	#F2CharTrans,CharTrans ; character translation table
;	APALETTE	#P_FONTR1

	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEOYEL	;temp? waiting for neo color pals

	PLOT	#145,#108
	PRINTDECB PlayerL+RUNS,#2,JRGT
.BlinkL


;	SETPRINT	#16,#24,#fnt1,#0
;	clr.l	FontAdjust
;	move.l	#fnt1Spacing,FontSpacing
;	move.l	#F1CharTrans,CharTrans ; character translation table
;	APALETTE	#P_FONTB1

	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals


	cmp.l	#PlayerR,WinningPlayer
	bne.s	.noBlinkR
	move.w	ProcessTime,d0
	and.w	#8,d0
	beq	.BlinkR	;blink it
.noBlinkR

	PLOT	#210,#109
	move.w	PlayerR+TEAMNUMBER,d0

	cmp.w	#draftteam,d0
	bne.s	.nodraft2	;branch if not a draft team
	lea.l	PlayerR+letters,a0
	clr.w	d6
	move.w	#3,d7	;print 3 letters
	jsr	Print
	bra	.Lnamedone
.nodraft2

	asl.w	#4,d0	;times 16
	lea.l	(TeamNames,d0.w),a0
	PRINTS	a0
.Lnamedone

;	SETPRINT	#16,#24,#fnt2,#0
;	clr.l	FontAdjust
;	move.l	#fnt2Spacing,FontSpacing
;	move.l	#F2CharTrans,CharTrans ; character translation table
;	APALETTE	#P_FONTB1

	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEOYEL	;temp? waiting for neo color pals

	PLOT	#336,#108
	PRINTDECB PlayerR+RUNS,#2,JRGT
.BlinkR

	tst.w	incomplete
	beq.s	.givestats
	rts
.givestats

;game stats
;	SETPRINT	#16,#24,#fnt1,#0
;	clr.l	FontAdjust
;	move.l	#fnt1Spacing,FontSpacing
;	move.l	#F1CharTrans,CharTrans ; character translation table

;	APALETTE	#P_FONTR1
;	PLOT	#61,#146
;	PRINT	"PLAYER 1"

	IMAGES	#Misc
	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals
	BLIT	#scrn11a,#15,#145


;	APALETTE	#P_FONTB1
;	PLOT	#253,#146
;	PRINT	"PLAYER 2"

	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals
	BLIT	#scrn11b,#206,#142


	SETPRINT	#10,#22,#neo3,#0
	clr.l	FontAdjust
;	move.l	#neo3Spacing,FontSpacing ; Non-Proportional Spacing
	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table

	APALETTE	#P_NEORED
	PLOT	#123,#178+4
	PRINTDECB PlayerL+HITS,#3,JRGTS
	APALETTE	#P_NEOBLU
	PLOT	#315,#175+4+3
	PRINTDECB PlayerR+HITS,#3,JRGTS

	APALETTE	#P_NEORED
	PLOT	#123,#201+5
	PRINTDEC PlayerL+HOMERUNSCNT,#3,JRGTS
	APALETTE	#P_NEOBLU
	PLOT	#315,#198+4+3
	PRINTDEC PlayerR+HOMERUNSCNT,#3,JRGTS

	APALETTE	#P_NEORED
	PLOT	#123,#223+7
	PRINTDEC PlayerL+STRIKEOUTSCNT,#3,JRGTS
	APALETTE	#P_NEOBLU
	PLOT	#315,#220+4+3
	PRINTDEC PlayerR+STRIKEOUTSCNT,#3,JRGTS

;	APALETTE	#P_FONTR1
;	PLOT	#32,#234
;	PRINT	"STRIKE OUTS "
;	PLOT	#161,#234
;	clr.l	FontSpacing
;	PRINTDEC PlayerL+STRIKEOUTSCNT,#2,JRGT
;	move.l	#fnt1Spacing,FontSpacing
;	APALETTE	#P_FONTB1
;	PLOT	#224,#234
;	PRINT	"STRIKE OUTS "
;	PLOT	#353,#234
;	clr.l	FontSpacing
;	PRINTDEC PlayerR+STRIKEOUTSCNT,#2,JRGT
;	move.l	#fnt1Spacing,FontSpacing


	rts

	.export	TeamNames
TeamNames:	;each entry 16 bytes please!
	dc.b	"BRAVES",0,0,0,0,0,0,0,0,0,0
	dc.b	"ORIOLES",0,0,0,0,0,0,0,0,0
	dc.b	"RED SOX",0,0,0,0,0,0,0,0,0
	dc.b	"ANGELS",0,0,0,0,0,0,0,0,0,0
	dc.b	"CUBS",0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	"WHITE SOX",0,0,0,0,0,0,0
	dc.b	"REDS",0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	"INDIANS",0,0,0,0,0,0,0,0,0
	dc.b	"ROCKIES",0,0,0,0,0,0,0,0,0
	dc.b	"TIGERS",0,0,0,0,0,0,0,0,0,0
	dc.b	"MARLINS",0,0,0,0,0,0,0,0,0
	dc.b	"ASTROS",0,0,0,0,0,0,0,0,0,0
	dc.b	"ROYALS",0,0,0,0,0,0,0,0,0,0
	dc.b	"DODGERS",0,0,0,0,0,0,0,0,0
	dc.b	"BREWERS",0,0,0,0,0,0,0,0,0
	dc.b	"TWINS",0,0,0,0,0,0,0,0,0,0,0
	dc.b	"EXPOS",0,0,0,0,0,0,0,0,0,0,0
	dc.b	"METS",0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	"YANKEES",0,0,0,0,0,0,0,0,0
	dc.b	"ATHLETICS",0,0,0,0,0,0,0
	dc.b	"PHILLIES",0,0,0,0,0,0,0,0
	dc.b	"PIRATES",0,0,0,0,0,0,0,0,0
	dc.b	"CARDINALS",0,0,0,0,0,0,0
	dc.b	"PADRES",0,0,0,0,0,0,0,0,0,0
	dc.b	"GIANTS",0,0,0,0,0,0,0,0,0,0
	dc.b	"MARINERS",0,0,0,0,0,0,0,0
	dc.b	"RANGERS",0,0,0,0,0,0,0,0,0
	dc.b	"BLUE JAYS",0,0,0,0,0,0,0

	dc.b	"DRAFTTEAM",0,0,0,0,0,0,0
	dc.b	"AMERICAN",0,0,0,0,0,0,0,0
	dc.b	"NATIONAL",0,0,0,0,0,0,0,0
	dc.b	"DESIGN",0,0,0,0,0,0,0,0,0,0

	.align	2


	.export	WinTestRun
	.export	WinTest3Outs

WinTestRun
	btst	#0,Inning	;top of inning?
	beq.s	.top
	cmp.b	#17,Inning	;17=bot of ninth inning
	blt.s	.notB9	;
	move.b	([HomePlayer],RUNS),d0
	cmp.b	([AwayPlayer],RUNS),d0
	bgt.s	Winner
.top
.notB9
	rts

WinTest3Outs
	btst	#0,Inning	;top of inning?
	beq.s	.top
	cmp.b	#17,Inning	;17=bot of ninth inning
	blt.s	.notB9	;
	move.b	([HomePlayer],RUNS),d0
	cmp.b	([AwayPlayer],RUNS),d0
	bne.s	Winner
.notB9	rts

.top
	cmp.b	#16,Inning	;16=top of ninth inning
	beq.s	.special9	;
	rts
.special9
	move.b	([HomePlayer],RUNS),d0
	cmp.b	([AwayPlayer],RUNS),d0
	bgt.s	Winner	;no need to play bottom of 9th
	rts

;end of game
Winner
	SWITCH	#START1,#81H,#0	;dont allow buyin
	SWITCH	#START2,#81H,#0
;find winner
	move.l	#PlayerL,WinningPlayer
	move.l	#PlayerR,LosingPlayer
	move.b	PlayerL+RUNS,d0
	cmp.b	PlayerR+RUNS,d0
	bgt.s	.leftwins
	move.l	#PlayerR,WinningPlayer
	move.l	#PlayerL,LosingPlayer
.leftwins
	clr.l	FirstRunner+UPDATEPROC
	clr.l	SecondRunner+UPDATEPROC
	clr.l	ThirdRunner+UPDATEPROC
	clr.l	HomeRunner+UPDATEPROC

	clr.l	FirstRunner+B_ONBASE
	clr.l	SecondRunner+B_ONBASE
	clr.l	ThirdRunner+B_ONBASE
	clr.l	HomeRunner+B_ONBASE

	clr.l	FirstRunner+B_INUSE
	clr.l	SecondRunner+B_INUSE
	clr.l	ThirdRunner+B_INUSE
	clr.l	HomeRunner+B_INUSE

	move.b	#1,BallOnGround

	jsr	BigWinObj
	rts

;***************************************************************************


;	cmp.b	#17,Inning	;17=bot of ninth inning
;	bne.s	.not9	;bri
;	move.b	([AtBatPlayer],RUNS),d0
;	cmp.b	([AtPitPlayer],RUNS),d0
;	bgt.s	.endgame	;no need to play bottom of 9th
;.not9
;	cmp.b	#18,Inning	;18=top of tenth inning
;	bne	NotEnd	;bri
;	move.b	PlayerL+RUNS,d0
;	cmp.b	PlayerR+RUNS,d0
;	beq	NotEnd	;no end if tie


endgame

	add.w	#1,total_complete
	jsr	CalcAudits	; Update Audits


;find winner
;	move.l	#PlayerL,WinningPlayer
;	move.l	#PlayerR,LosingPlayer
;	move.b	PlayerL+RUNS,d0
;	cmp.b	PlayerR+RUNS,d0
;	bgt.s	.leftwins
;	move.l	#PlayerR,WinningPlayer
;	move.l	#PlayerL,LosingPlayer
;.leftwins

;	cmp.b	#17,Inning	;17=bot of ninth inning
;	blt	notfullgame	;bri


;full game stats
;stat_win		ds.w  1
;stat_lost		ds.w  1
;stat_hits		ds.w  1	;for batting average
;stat_atbats		ds.w  1	;for batting average
;stat_homeruns 	ds.w  1
;stat_steals 	ds.w  1
;stat_strikeouts 	ds.w  1

	add.w	#1,([WinningPlayer],stat_win)
	move.b	([WinningPlayer],stat_lastgame),d0
	move.b	d0,([WinningPlayer],stat_lastgame+1)
	move.b	#1,([WinningPlayer],stat_lastgame)

	add.w	#1,([LosingPlayer],stat_lost)
	move.b	([LosingPlayer],stat_lastgame),d0
	move.b	d0,([LosingPlayer],stat_lastgame+1)
	move.b	#2,([LosingPlayer],stat_lastgame)


	move.b	([WinningPlayer],HITS),d0
	ext.w	d0
	add.w	d0,([WinningPlayer],stat_hits)

	move.b	([LosingPlayer],HITS),d0
	ext.w	d0
	add.w	d0,([LosingPlayer],stat_hits)


	move.w	([WinningPlayer],ATBATSCNT),d0
	sub.w	([WinningPlayer],BEANCNT),d0
	add.w	d0,([WinningPlayer],stat_atbats)

	move.w	([LosingPlayer],ATBATSCNT),d0
	sub.w	([LosingPlayer],BEANCNT),d0
	add.w	d0,([LosingPlayer],stat_atbats)


	move.w	([WinningPlayer],HOMERUNSCNT),d0
	add.w	d0,([WinningPlayer],stat_homeruns)

	move.w	([LosingPlayer],HOMERUNSCNT),d0
	add.w	d0,([LosingPlayer],stat_homeruns)


	move.w	([WinningPlayer],STEALSCNT),d0
	add.w	d0,([WinningPlayer],stat_steals)

	move.w	([LosingPlayer],STEALSCNT),d0
	add.w	d0,([LosingPlayer],stat_steals)


	move.w	([WinningPlayer],STRIKEOUTSCNT),d0
	add.w	d0,([WinningPlayer],stat_strikeouts)

	move.w	([LosingPlayer],STRIKEOUTSCNT),d0
	add.w	d0,([LosingPlayer],stat_strikeouts)


	clr.b	NewSeries
	clr.b	AnySeries

	tst.w	FreeBee	;was it a free game?
	bne	.final_screen	;branch yes
;update season
	move.l	SinglePlayer,a4
	tst.l	a4
	beq	.notsingle	;not season if 2 players

	cmp.b	#NoY,YND(a4)
	beq	.nosave	;don't save if no initials input

	add.b	#1,(seriesCNT,a4)	;an official season/series game
	cmpa.l	WinningPlayer,a4	;did player win?
	bne	.human_lost
	add.b	#1,(winCNT,a4)	;human_won
.human_lost			;possible series lost?
	move.b	(stat_defeat,a4),d4
;	move.l	#0,d1	;lose penalty
	move.w	#4,d2	;4 out of
	move.w	#7,d3	;7 series
	move.b	#1,AnySeries	;flag a series game
;	cmp.b	#31,d4	;world
;	beq	.seasonseries
;	move.l	#29,d1	;lose penalty
;	cmp.b	#28,d4	;championship
;	bge	.seasonseries
;	move.w	#3,d2	;3 out of
;	move.w	#5,d3	;5 series
	cmp.b	#28,d4	;series?
	bge	.seasonseries	;branch if yes
	move.w	#1,d2
	move.w	#$8000,d3	;regular season has no series
	clr.b	AnySeries	;not a series game
.seasonseries
	cmp.b	(winCNT,a4),d2
	bne.s	.noadvance
	add.b	#1,(stat_defeat,a4)	;next team in season/series
	move.b	(stat_defeat,a4),NewSeries ;flag an advance

	cmp.b	#32,(stat_defeat,a4)
	blt.s	.nowrap
	clr.b	(stat_defeat,a4)	;reset series
	add.w	#1,(BeatGame,a4)	;beat counter
.nowrap
	move.b	#0,(seriesCNT,a4)	;reset counter
	move.b	#0,(winCNT,a4)	;reset counter
	bra	.win_def_done
.noadvance
	sub.b	(seriesCNT,a4),d3	;games left to play
	add.b	(winCNT,a4),d3	;total possible wins
	cmp.b	d3,d2	;can player still win?
	ble.s	.canwin
	move.b	#0,(seriesCNT,a4)	;reset counter
	move.b	#0,(winCNT,a4)	;reset counter
;	move.b	d1,(stat_defeat,a4)	;lose penalty
.canwin
.win_def_done

;	cmp.b	#28,(stat_defeat,a4)
;	beq	season_completed


.nosave
.notsingle

	jsr	save_stats

.final_screen

	cmp.b	#32,NewSeries
	bne.s	.notWorld

	SOUND	#WinWorldSeries,<([WinningPlayer],TEAMNUMBER+1)>
	bra.s	.sDone
.notWorld
	SOUND	#TheTeamWinIt,<([WinningPlayer],TEAMNUMBER+1)>
.sDone


	SOUND	#Crowd2,#0

;	move.b	Inning,d0
;	lsr.b	#1,d0
;	ext.w	d0
;	move.b	#-1,([AtBatPlayer],d0.w,INNINGSSCORE) ;so scoreboard doesnt show inning

	jsr	AllocObject	; Allocate An Object
	beq.s	.noobj	; Branch If None
	move.l	#DScore,DISPLAYPROC(a0)	; Store Address Of Display Procedure

	jsr	SetExtra

	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#11,ZPOSITION(a0)	; Initialize Z Position
	move.w	#newscore,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#31,XPOSITION(a0)	; Set X Position62
	move.w	#0,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
	move.l	a0,ScorePtr
.noobj

	jsr	AllocObject	; Allocate An Object
	beq.s	.noshow	; Branch If None
	clr.w	incomplete
	move.l	#ShowScore,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.w	#11,ZPOSITION(a0)	; Initialize Z Position
.noshow

	jsr	AllocObject	; Allocate An Object
	beq.s	.noebut	; Branch If None
	move.l	#end_but,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#200,COUNTER(a0)	;delay buttons was 200 test
.noebut

	clr.b	PlayHomeDone
EndLoop1
	jsr	CycleGame	; Perform One Game Cycle
	tst.b	PlayHomeDone
	beq	EndLoop1




;	tst.w	FreeBee	;was it a free game?
;	beq	.notrap
;	trap	#1
;.notrap



	jsr	InitProcs	; Initialize Object System

;new series?
;a congrat screen or series score screen

	clr.w	FreeBee

	tst.b	NewSeries
	beq	.NoNewSeries

	jsr	AllocObject	; Allocate An Object
	beq.s	.noshow	; Branch If None
	move.b	NewSeries,d0
	move.l	#Series1,a1	; Store Address Of Display Procedure
	cmp.b	#28,d0
	beq.s	.ThisSeries
	move.l	#Series2,a1	; Store Address Of Display Procedure
	cmp.b	#29,d0
	beq.s	.ThisSeries
	move.l	#Series3,a1	; Store Address Of Display Procedure
	cmp.b	#30,d0
	beq.s	.ThisSeries
	move.l	#Series4,a1	; Store Address Of Display Procedure
	cmp.b	#31,d0
	beq.s	.ThisSeries
	move.l	#Series5,a1	; Store Address Of Display Procedure
	cmp.b	#32,d0
	bne	.NoNewSeries

.ThisSeries	move.l	a1,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.w	#11,ZPOSITION(a0)	; Initialize Z Position
.noshow


	jsr	AllocObject	; Allocate An Object
	beq.s	.noebut2	; Branch If None
	move.l	#end_but,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#200,COUNTER(a0)	;delay buttons
.noebut2

	clr.b	PlayHomeDone
.EndLoop2
	jsr	CycleGame	; Perform One Game Cycle
	tst.b	PlayHomeDone
	beq	.EndLoop2

	jsr	InitProcs	; Initialize Object System

	tst.w	FreeBee
	beq	.SeriesScreensDone

;free game given
	move.b	#1,EndGameFlag	; Flag Game Over
	rts		;back to game

;old give free game
	clr.b	Inning
	clr.l	WinningPlayer
	jsr	ClearScores


	move.w	FreeBee,d0	;team number
	move.l	LosingPlayer,a0
	move.w	d0,TEAMNUMBER(a0)

	move.b	d0,team(a0)	;for logo on vs screen

	move.b	d0,PLAYERSTEAM(a0)
	move.b	d0,PLAYERSTEAM+1(a0)
	move.b	d0,PLAYERSTEAM+2(a0)
	move.b	d0,PLAYERSTEAM+3(a0)
	move.b	d0,PLAYERSTEAM+4(a0)
	move.b	d0,PLAYERSTEAM+5(a0)
	move.b	d0,PLAYERSTEAM+6(a0)
	move.b	d0,PLAYERSTEAM+7(a0)
	move.b	d0,PLAYERSTEAM+8(a0)
	move.b	d0,PLAYERSTEAM+9(a0)
	move.b	d0,PLAYERSTEAM+10(a0)
	move.b	d0,PLAYERSTEAM+11(a0)
	move.b	d0,PLAYERSTEAM+12(a0)
	move.b	d0,PLAYERSTEAM+13(a0)

	move.w	#1,PlayerL+BATTERNUM
	move.w	#1,PlayerR+BATTERNUM

;set roster addresses for all players
	move.w	#0,d2
.rosterPL	move.w	d2,d0
	move.l	LosingPlayer,a0
	jsr	GetRoster

;	move.l	#PlayerL+ROSTERPTR,a1
;	move.l	a0,(a1,d2.w*4)

	move.l	LosingPlayer,a1
	move.l	a0,(ROSTERPTR,a1,d2.w*4)

	add.w	#1,d2
	cmp.w	#14,d2
	bne.s	.rosterPL


;set roster addresses for outfield
	move.l	LosingPlayer,a0
	move.l	(ROSTERPTR+4,a0),Catcher+B_ROSTERADR
	move.l	(ROSTERPTR+8,a0),FirstBase+B_ROSTERADR
	move.l	(ROSTERPTR+12,a0),SecondBase+B_ROSTERADR
	move.l	(ROSTERPTR+16,a0),ShortStop+B_ROSTERADR
	move.l	(ROSTERPTR+20,a0),ThirdBase+B_ROSTERADR
	move.l	(ROSTERPTR+24,a0),LeftField+B_ROSTERADR
	move.l	(ROSTERPTR+28,a0),CenterField+B_ROSTERADR
	move.l	(ROSTERPTR+32,a0),RightField+B_ROSTERADR

	clr.w	d0
	move.b	([LosingPlayer],FIRSTPITCHER),d0 ;first pitcher
	move.l	([LosingPlayer],d0.w*4,ROSTERPTR),Pitcher+B_ROSTERADR ;point at current pitchers roster adr

;set batting order
	move.w	#9,d1
	move.b	([LosingPlayer],team),d0
	ext.w	d0
	mulu	#teamattrib_size,d0	;team*NumberOfTeamPlayers
	move.l	#ROSTERS,a6
	lea.l	(a6,d0.w),a6	;get to team
	lea.l	([LosingPlayer],bat_order+1),a0
.sp2b	move.b	AT_order(a6),(a0)+
	lea.l	attrib_size(a6),a6	;next bbplayer
	dbf	d1,.sp2b
.dt2



	jsr	NEWvs

	jsr	HalfInnScreen	;THIS IS ME

	jsr	SetHomePal

	jsr	CLRSWING
	move.b	#0,FieldTeam
	move.w	#84*256,PlayerL+TOTALPOWER	; Set Total Power for Left Player
	move.w	#84*256,PlayerR+TOTALPOWER	; Set Total Power for Left Player
	clr.w	SwitchReason	; Clear Ball Hit Flag
	jsr	InitTeam	; Inialize New Team Up

;	clr.w	FreeBee
	rts		;back for free game


;series score screen
.NoNewSeries
	tst.b	AnySeries
	beq.s	.SeriesScreensDone

	jsr	AllocObject	; Allocate An Object
	beq.s	.noOBJ	; Branch If None
	move.l	#NewVSBlit,DISPLAYPROC(a0)	; Store Address Of Display Procedure
.noOBJ

	jsr	AllocObject	; Allocate An Object
	beq.s	.noebut3	; Branch If None
	move.l	#end_but,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#200,COUNTER(a0)	;delay buttons
.noebut3

	clr.b	PlayHomeDone
.EndLoop3
	jsr	CycleGame	; Perform One Game Cycle
	tst.b	PlayHomeDone
	beq	.EndLoop3

	jsr	InitProcs	; Initialize Object System


.SeriesScreensDone
	move.b	#1,EndGameFlag	; Flag Game Over
	rts		;back to game


;............................................................................

NobodyPlaying
;game over screen
	SWITCH	#START1,#81H,#0	;dont allow buyin
	SWITCH	#START2,#81H,#0

	jsr	InitProcs	; Initialize Object System

	SOUND	#Crowd2,#0


	jsr	AllocObject	; Allocate An Object
	beq.s	.noobj	; Branch If None
	move.l	#DScore,DISPLAYPROC(a0)	; Store Address Of Display Procedure

	jsr	SetExtra

	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#11,ZPOSITION(a0)	; Initialize Z Position
	move.w	#newscore,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#31,XPOSITION(a0)	; Set X Position62
	move.w	#0,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
	move.l	a0,ScorePtr
.noobj

	jsr	AllocObject	; Allocate An Object
	beq.s	.noshow	; Branch If None
	move.w	#1,incomplete
	move.l	#ShowScore,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.w	#11,ZPOSITION(a0)	; Initialize Z Position
.noshow

	jsr	AllocObject	; Allocate An Object
	beq.s	.nogover	; Branch If None
	move.l	#GOver,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.w	#15,ZPOSITION(a0)	; Initialize Z Position
	move.w	#0,COUNTER(a0)	;flasher
.nogover

	jsr	AllocObject	; Allocate An Object
	beq.s	.noebut	; Branch If None
	move.l	#Gend_but,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#30,COUNTER(a0)	;delay buttons
.noebut

	clr.b	PlayHomeDone
.EndLoop

	jsr	CycleGame	; Perform One Game Cycle

	tst.b	PlayHomeDone
	beq	.EndLoop

	move.b	#1,EndGameFlag	; Flag Game Over
 	rts		;back to game


GOver
;	IMAGES	#Title
;	APALETTE	#P_TITLERB
;	BLIT	#pinrb,#0,#0

;	SETPRINT	#49,#30,#fnt5,#0
;	clr.l	FontAdjust
;	move.l	#fnt5Spacing,FontSpacing ; Non-Proportional Spacing
;	move.l	#BIGCharTrans,CharTrans ; character translation table
;
;	APALETTE	#P_FONTY1

	SETPRINT	#31,#46,#neo1,#0
	clr.l	FontAdjust
	move.l	#neo1Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals


	PLOT	#192,#148
	PRINTCT	"GAME OVER"

	SETPRINT	#13,#17,#neo4,#0
	clr.l	FontAdjust
	move.l	#neo4Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEOYEL	;temp? waiting for neo color pals

	PLOT	#192,#148+60
	PRINTCT	"INCOMPLETE GAME"

	rts


Gend_but
	sub.w	#1,COUNTER(a5)
	bpl.s	.nobuts	;ignore buts for a little bit
	tst.b	([AtBatPlayer],BUTTONS)
	bne.s	.cont
	cmp.w	#-150,COUNTER(a5)	;auto timeout
	bne.s	.nobuts
.cont
	move.b	#1,PlayHomeDone	;exit
.nobuts	rts


;............................................................................



