;***************************************************************************
;                                                                          *
;                   INCREDIBLE TECHNOLOGIES, INC.                          *
;                    (C) COPYRIGHT 1995, IT, INC.                          *
;***************************************************************************

	.export	TicketSlider,TicketSlideL,TicketSlideR
	.export	Selections,blit_card,blit_card2,draft_stat
	.export	card_pal,NOTDIM,DIM,fnt5Spacing,BIGCharTrans

	.export	AttractSelect,setAIpitcher,NewVSBlit,NEWvs
	.export	AnimDraft,DrDspBody,MaxPlayers

	.export F2CharTrans,fnt2Spacing,fnt3Spacing
	.export incinns1,F3CharTrans,stat_defeat
	.export incinns2,CoinageScreen,CoinageScreen2
	.export hurryup,buytime,save_stats

	.export	team,firstteam,last_players_stats
	.export	start_state1,NoY,DraftY,Pletter
	.export	start_state2,plpos,tbx1

	.export	draftteam,vstime,done,button_sound


	.export	REC_stat_win
	.export	REC_stat_homeruns
	.export	REC_stat_strikeouts
	.export	REC_stat_hits
;	.export	DestList
;	.export	WinsList
	.export	endrec
	.export	records

	.export	neo0Spacing
	.export	neo1Spacing
	.export	neo2Spacing
	.export	neo3Spacing
	.export	neo4Spacing
	.export	neo5Spacing
	.export	neo6Spacing
	.export	neo7Spacing



	.import	attrib_size,teamattrib_size,CameraX,Inning
	.import	BatTablePos,BatTableTeam,BatRoster,InCreditsMsg
	.import.s	GameMode

	.import	LoadCardPals
	.export	NumberOfTeamPlayers
	.import	NumberOfParms,InitJoyWatch

	.import	TrackY1,TrackY2,LoadSelectPal
	.import	TrackY1Vel,TrackY2Vel,TrackY1Cnt,TrackY1Delta
	.import	TrackX1Vel,TrackX2Vel
	.import	SwitchState,InitIntials,Display,DoHeadPalette,DoSkinPalette
	.import	FontAdjust,FontSpacing,MedCharTrans,CharTrans

	.import	GetInitials,EnterInitials,CheckForInitials,AllocObject
	.import	CreditsMsg,Player,AnimPlayer,Anim,Split
	.import	ROSTERS,AlphaOrder

	.import	TestCredits,TestDraftCredits
	.import	TakeCredits,TakeDraftCredits

	.import	LoadPtrs,SinglePlayer,Batter
	.import	SetFont2,SetSysFont,SetWinFont,SetScoreFont
	.import.s	FontSpacing

	.import	Pitcher,Batter,FirstBase,SecondBase,ShortStop,FirstRunner
	.import	ThirdBase,Catcher,LeftField,CenterField,RightField

	.import	score1,score1_name0
	.import	score2,score2_name0
	.import	score3,score3_name0
	.import	score4,score4_name0
	.import	score5,score5_name0

;	.import	BatterWidths,BatterHeights

            .import BlitHead,SetHomePal
            .import BlitBat,FreeBee
            .import BlitLegs 
            .import BlitTorso
	.import	XScale,YScale
	.import	WinningPlayer
	.import	LosingPlayer


	.import	InitObjects,Update,Display,InitProcs,Split
	.import	AllocObject
	.import	Anim
	.import	SysCharTrans
	.import	BlitObject,BlitClipObj,BlitCentered
	.import	DeallocObject
	.import	AllocObject
	.import	LoadTicketPals,fix_checksum
	.import	min_draft_credit,init_permanent

	.global F5CharTrans
	.global F1CharTrans
	.global	fnt1Spacing

	.global	HomePlayer
	.global	AwayPlayer


	#include	"ramblock.h"

;.............................................................................

	.region	"RAM"
	ds	0

HomePlayer	ds.l	1
AwayPlayer	ds.l	1
AtBatPlayer	ds.l	1
AtPitPlayer	ds.l	1
savea0	ds.l	1
tempd6	ds.w	1
tempd7	ds.w	1
P1y ds.w 1
P2y ds.w 1
;P1yinc	ds.w	1
;P2yinc	ds.w	1
plpos	ds.w	1
;YNy	ds.w	1
clipX	ds.w	1
menuart	ds.l	1
last_players_stats	ds.l	1
behind_curtain	ds.l	1
answer	ds.w	1
tbx1	ds.w	1
tbx2	ds.w	1
menu_width	ds.w	1
menu_height	ds.w	1
art_offset	ds.w	1
Lseries	ds.b	1
Rseries	ds.b	1
temp	ds.b	4
max4sale	ds.b	1
coinON	ds.b	1
ingame	ds.b	1
messcnt	ds.w	1	;# of messages on buyin screen
leftside	ds.w	1
leftcside	ds.w	1
xmspace	ds.w	1
xcmspace	ds.w	1
ymspace	ds.w	1
pinfo	ds.l	1
pinfodata	ds.l	1
SaveIndexAddress	ds.l	1
SaveIndex	ds.b	1
TeamAllSame	ds.b	1
AllSameTeam	ds.b	1
;ALLSAMEADR	ds.l	1
done	ds.w	1
topside	ds.w	1
vscardx	ds.w	1
vscardy	ds.w	1
vsH	ds.w	1
vsW	ds.w	1
VSdur	ds.w	1
cscaledir	ds.w	1
selcx1	ds.w	1
selcy1	ds.w	1
selcx2	ds.w	1
selcy2	ds.w	1
blinker	ds.b	1
card_pal	ds.b	1
button_sound ds.b	1
curtx	ds.w	1
p1start	ds.b	1
p2start	ds.b	1
seldone	ds.b	1
VScnt	ds.b	1
nameram	ds.b	16
cardscaleX	ds.w	1
vstime	ds.w	1
cardscaleY	ds.w	1
dallart	ds.w	1
trapcnt	ds.l	1
TimeOut	ds.w	1
DraftSelTime1	ds.w	1
DraftSelTime2	ds.w	1

firstt	ds.b	1
tb_moved	ds.b	1
firstteam	ds.b	1
stst1	ds.b	1
stst2	ds.b	1
start_state1	ds.b	1
start_state2	ds.b	1
AttTeam	ds.w	1
SoundOnce	ds.w	1
ButtonDelay	ds.w	1

;NumberOfTeamPlayers	equ	14 ;if changed check getrec and selectteam

;menudata	.struct

;letters	ds.b	3 ;THESE MUST BE TOGETHER
;month	ds.b	1 ;THESE MUST BE TOGETHER
;dayofmonth	ds.b	1 ;THESE MUST BE TOGETHER
;team	ds.b	1 ;THESE MUST BE TOGETHER
;
;stat_defeat	ds.b	1	;defeated teams
;stat_win	ds.w	1
;stat_lost	ds.w	1
;stat_ba	ds.w	1	;batting average
;stat_homeruns ds.w	1
;first_pitcher ds.b	1
;players	ds.b	NumberOfTeamPlayers+1 ;number of bbplayers+1
;          
;present	ds.b	1
;YND	ds.b	1
;Bcursor	ds.b	1	;ball cursor
;Lcursor	ds.b	1	;letter cursor
;max_select	ds.w	1
;max_input	ds.w	1
;bat_order	ds.b	10 ;first player (DH) is at bat_order+1
;cardX	ds.w	1
;dnamex	ds.w	1
;dnamexinc	ds.w	1
;	.endstruct

;menudef	ds.l	1

;p1info	ds.b	`sizeof(menudata)
;p2info	ds.b	`sizeof(menudata)

	.export	REC_letters
	.export	REC_month
	.export	REC_dayofmonth
	.export	REC_team
;
	.export	REC_stat_defeat
	.export	REC_stat_win
	.export	REC_stat_lost
	.export	REC_stat_hits
	.export	REC_stat_atbats
	.export	REC_BeatGame
	.export	REC_stat_lastgame
	.export	REC_stat_homeruns
	.export	REC_stat_steals
	.export	REC_stat_strikeouts
	.export	REC_first_pitcher
	.export	REC_players
	.export	REC_bat_order
	.export	REC_winCNT
	.export	REC_seriesCNT

	.export	REC_checksum


	.export	recorddata
recorddata	.struct

REC_letters	ds.b	3 ;THESE MUST BE TOGETHER
REC_month	ds.b	1 ;THESE MUST BE TOGETHER
REC_dayofmonth	ds.b	1 ;THESE MUST BE TOGETHER
REC_team	ds.b	1 ;THESE MUST BE TOGETHER
;
REC_stat_defeat	ds.b 1 ;defeated teams in series
REC_stat_win	ds.w 1 ;games won
REC_stat_lost	ds.w 1 ;games lost
REC_stat_hits	ds.w 1 ;for batting average
REC_stat_atbats	ds.w 1 ;for batting average
REC_BeatGame	ds.w 1 ;1=world series won
REC_stat_lastgame	ds.w 1 ;for ai
REC_stat_homeruns	ds.w 1 ;homers hit
REC_stat_steals	ds.w 1 ;stolen bases
REC_stat_strikeouts	ds.w 1 ;duh!
REC_first_pitcher	ds.b 1 ;he pitches at start of game
REC_players 	ds.b NumberOfTeamPlayers+1 ;number of bbplayers+1
REC_bat_order	ds.b 10 ;first player (DH) is at bat_order+1
REC_winCNT		ds.b 1 ;count of wins in series
REC_seriesCNT	ds.b 1 ;games played in series

REC_checksum    	ds.w	1 ;

	ds	0

	.endstruct

RecordSize	equ	`sizeof(recorddata)
	.export	RecordSize

menudata	equ	menudataEND-menudataBEGIN

	.region	"RECRAM"
	.align	2

MaxPlayers	equ	800
records	ds.b	`sizeof(recorddata)*MaxPlayers ;800?
endrec	ds.w	1	;

dummy	ds.b	`sizeof(recorddata)*2


	.export	PermRecords,Pendrec,PRecCnt
PRecCnt	equ	21	; number of last record ABOVE
PermRecords	ds.b	RecordSize*PRecCnt ;permanent records
Pendrec	ds.w	1	;

	.export	Precords
Precords	equ	PermRecords-RecordSize




;records	equ	$8000	;well after all other ram use
;endrec	equ	records+`sizeof(recorddata)*800


;InitialInput   ds.l	1
;InitialPlyr    ds.l	1
;InitialNum	    ds.w	1
;EnterInitials  ds.b	1
;InitialCnt	    ds.w	1
;InitialPtr	    ds.l	1
;AttSndCnt	    ds.w	1
;Rank	    ds.w	1
;HighScorePtr   ds.l	1
;Afighter	    ds.b	1
;TagBack	    ds.b	1	; Set For Game Play
;Attractcnt	    ds.b	1	; loop counter

;***************************************************************************
;  Start Of Program Code			*
;***************************************************************************
	.region	"RomCode"

	ds	0

	#include	"player.h"
	#include	"itvideo2.h"
	#include	"sys.h"
	#include	"sys.mac"
	#include	"graphlib.mac"
	#include	"graphlib.h"
	#include	"graphglb.h"
	#include	"macros.h"
;	#include	"sndequ.h"
	#include	"bsblsnds.equ"
	#include	"anim.mac"
	#include	"groms.h"
	#include	"stats.h"
	#include	"audits.h"
	#include	"pals.h"

	#include	"rosters.h"

;***************************************************************************
;  System Subroutine Imports		*
;***************************************************************************
	.import	DeallocObject

	.import	TogglePage
	.import	Random,Mode1
	.import	Sort

;***************************************************************************
;               DisplayFighters imports (from display.asm)	*
;***************************************************************************
	.import	AnimFighter
	.import	PlayerR,PlayerL
	.import	InitJoys,InitCycle
	.import	CTimer
	.import	LoadAttractPal,message_flag
	.import	SemoGame1
	.import	NewBack
	.import	RecordList


***************************************************************************
;		   PRINT (a0) centered	*
***************************************************************************
PRINTC:	macro
	#ifndef	PrintCentered
	.global	PrintCentered
	#endif
	#ifndef	Print
	.global	Print
	#endif
;	move.l	#striii\@,a0
	clr.w	d6	
	move.w	#$7FFF,d7
	jsr	PrintCentered	;entry point for plot print
;	bra	dprrr\@
;striii\@:
;	dc.b	string,0
;dprrr\@:	ds	0	;align prg counter
	endm


****************************************************************************
PLOTY:	macro	x,y
	#ifndef	prx_coor
	.global.s prx_coor,prx_init,pry_coor
	#endif
	PUSHW	d0
	move.w	y,d0
	move.w	x,prx_coor	;2 bytes in ram
	move.w	x,prx_init	;2 bytes in ram
	cmp.w	#178,prx_coor
	bgt	.rightside\@
	sub.w	P1y,d0
	bra	.con\@
.rightside\@
	sub.w	P2y,d0
.con\@
	move.w	d0,pry_coor	;2 byte in ram
	POPW	d0
	endm

****************************************************************************
PLAT:	macro	x,y
	#ifndef	prx_coor
	.global.s prx_coor,prx_init,pry_coor
	#endif
	PUSHW	d0
	move.w	curtx,d0
	move.w	x,prx_coor	;2 bytes in ram
	move.w	x,prx_init	;2 bytes in ram
	cmp.w	#178,prx_coor
	bgt	.add\@
	sub.w	d0,prx_coor
	sub.w	d0,prx_init
	bra	.con\@
.add\@
	add.w	d0,prx_coor
	add.w	d0,prx_init
.con\@
	move.w	y,pry_coor	;2 byte in ram
	POPW	d0
	endm


****************************************************************************
;blit,  obe
BLITY	macro	num,xp,yp
	.global	Blit
	move.w	yp,d5
	move.w	xp,d4	;2 byte x value
	cmp.w	#178,d4
	bgt	.add\@
	sub.w	P1y,d5
	bra	.con\@
.add\@
	sub.w	P2y,d5
.con\@
	move.w	num,d3
	jsr	Blit
.bblit\@
	endm


****************************************************************************
;blit,  obe
BLOT	macro	num,xp,yp
	.global	Blit
	move.w	xp,d4	;2 byte x value
	cmp.w	#178,d4
	bgt	.add\@
	sub.w	curtx,d4
	bra	.con\@
.add\@
	add.w	curtx,d4
.con\@
	move.w	num,d3
	move.w	yp,d5	;2 byte x value
	jsr	Blit
.bblit\@
	endm



****************************************************************************
;blink blit,  obe
BBLIT	macro	num,xp,yp
	.global	Blit
	tst.b	blinker
	beq.s	.bblit\@
;	move.w	xp,d4	;2 byte x value
;	move.w	yp,d5	;2 byte x value
;	move.w	num,d3
;	jsr	Blit
	BLOT	num,xp,yp
.bblit\@
	endm

****************************************************************************
;blink blit,  obe
BBLITO	macro	num,xp,yp
	.global	Blit
	tst.b	blinker
	beq.s	.bblit\@
;	move.w	xp,d4	;2 byte x value
;	move.w	yp,d5	;2 byte x value
;	move.w	num,d3
;	jsr	Blit
	BLIT	num,xp,yp
.bblit\@
	endm


****************************************************************************
****************************************************************************
	.align	2

sensitive	equ	15	;trackball sensitivity
YesY	equ	1
NoY	equ	2
DraftY	equ	3
draftteam	equ	NumberOfTeams	;draft team is the last team
DIM	equ	1
NOTDIM	equ	0
buytime	equ	10*60
DeadMan	equ	20*60


Selections

 .if debugmode=="obe"

;	SWITCH	#COIN1,#81H,#TRAPPER

;	move.b	#BUTTON1_1,d0
;	jsr	SwitchState
;	tst.b	d0
;	beq.s	.noclear
;	move.b	#BUTTON1_2,d0
;	jsr	SwitchState
;	tst.b	d0
;	beq.s	.noclear
;	move.b	#BUTTON1_3,d0
;	jsr	SwitchState
;	tst.b	d0
;	beq.s	.noclear
;	move.b	#BUTTON1_4,d0
;	jsr	SwitchState
;	tst.b	d0
;	beq.s	.noclear
;	move.l	#records,a0	;clear all records
;.zrecords	clr.b	(a0)+
;	cmp.l	#endrec,a0
;	bne.s	.zrecords
;.noclear

 .endif


	clr.w	P1y
	clr.w	P2y

	tst.w	FreeBee
	beq	NoFreeGame

;setup a free game
;	clr.w	FreeBee

;	clr.b	Inning
	clr.l	WinningPlayer
;	jsr	ClearScores

;buy 9 innings
	move.b	#9,PlayerL+INNINGSBOUGHT
	move.b	#9,PlayerR+INNINGSBOUGHT


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

	move.b	d0,players(a0)
	move.b	d0,players+1(a0)
	move.b	d0,players+2(a0)
	move.b	d0,players+3(a0)
	move.b	d0,players+4(a0)
	move.b	d0,players+5(a0)
	move.b	d0,players+6(a0)
	move.b	d0,players+7(a0)
	move.b	d0,players+8(a0)
	move.b	d0,players+9(a0)
	move.b	d0,players+10(a0)
	move.b	d0,players+11(a0)
	move.b	d0,players+12(a0)
	move.b	d0,players+13(a0)

;	move.w	#1,PlayerL+BATTERNUM
;	move.w	#1,PlayerR+BATTERNUM

;set roster addresses for all players
	move.w	#0,d2
rosterFG	move.w	d2,d0
	move.l	LosingPlayer,a0
	jsr	GetRoster

	move.l	LosingPlayer,a1
	move.l	a0,(ROSTERPTR,a1,d2.w*4)

	add.w	#1,d2
	cmp.w	#14,d2
	bne.s	rosterFG

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

	jsr	LoadCardPals

	jsr	NEWvs

	bra	ContinueFreeGame

;	jsr	HalfInnScreen	;THIS IS ME
;	jsr	SetHomePal
;	jsr	CLRSWING
;	move.b	#0,FieldTeam
;	move.w	#84*256,PlayerL+TOTALPOWER	; Set Total Power for Left Player
;	move.w	#84*256,PlayerR+TOTALPOWER	; Set Total Power for Left Player
;	clr.w	SwitchReason	; Clear Ball Hit Flag
;	jsr	InitTeam	; Inialize New Team Up
;	clr.w	FreeBee
;	rts		;back for free game



;............................................................................

NoFreeGame
	jsr	CoinageScreen

	SPAWN	#MakeSelection,#22

	clr.b	seldone
	clr.b	Inning
	clr.b	coinON

	jsr	LoadPtrs
	move.b	START(a5),p1start
	move.b	START(a5),PlayerL+present
	move.b	START(a6),p2start
	move.b	START(a6),PlayerR+present

	move.b	#NoY,PlayerL+YND	;not drafting
	move.b	#NoY,PlayerR+YND

.buyinlp
	cmp.b	#DraftY,PlayerL+YND	;is player drafting?
	beq.s	.nobuyin
	cmp.b	#DraftY,PlayerR+YND	;is player drafting?
	beq.s	.nobuyin

	tst.b	coinON
	bne.s	.nobuyin	;dont restart buyin screen

	jsr	LoadPtrs
	move.b	START(a5),d0
	cmp.b	p1start,d0
	bne	newplayer
	move.b	START(a6),d0
	cmp.b	p2start,d0
	bne	newplayer
.nobuyin
	DELAY	#1
	tst.b	seldone
	beq.s	.buyinlp

	EXTERM	#20
	EXTERM	#21
	EXTERM	#22

ContinueFreeGame
;pass info to game
	move.b	PlayerL+team,d0
	ext.w	d0
	move.w	d0,PlayerL+TEAMNUMBER

	clr.w	d0	;bri
	move.b	PlayerR+team,d0
	ext.w	d0
	move.w	d0,PlayerR+TEAMNUMBER

	move.b	PlayerL+first_pitcher,PlayerL+FIRSTPITCHER
	move.b	PlayerR+first_pitcher,PlayerR+FIRSTPITCHER


;	move.b	PlayerL+FIRSTPITCHER,d0
;	move.b	PlayerR+FIRSTPITCHER,d1
;	trap	#1


	move.l	PlayerL+players,PlayerL+PLAYERSTEAM
	move.l	PlayerL+players+4,PlayerL+PLAYERSTEAM+4
	move.l	PlayerL+players+8,PlayerL+PLAYERSTEAM+8
	move.w	PlayerL+players+12,PlayerL+PLAYERSTEAM+12

	move.l	PlayerR+players,PlayerR+PLAYERSTEAM
	move.l	PlayerR+players+4,PlayerR+PLAYERSTEAM+4
	move.l	PlayerR+players+8,PlayerR+PLAYERSTEAM+8
	move.w	PlayerR+players+12,PlayerR+PLAYERSTEAM+12

	move.l	PlayerL+bat_order,PlayerL+BATTINGORDER
	move.l	PlayerL+bat_order+4,PlayerL+BATTINGORDER+4
	move.w	PlayerL+bat_order+8,PlayerL+BATTINGORDER+8

	move.l	PlayerR+bat_order,PlayerR+BATTINGORDER
	move.l	PlayerR+bat_order+4,PlayerR+BATTINGORDER+4
	move.w	PlayerR+bat_order+8,PlayerR+BATTINGORDER+8

	move.l	#$ffffffff,PlayerL+PITAVAIL ;make all pitchers available
	move.l	#$ffffffff,PlayerR+PITAVAIL

	move.l	HomePlayer,AtPitPlayer
	move.l	AwayPlayer,AtBatPlayer

	clr.l	WinningPlayer
	clr.l	LosingPlayer

	move.w	#1,PlayerL+BATTERNUM
	move.w	#1,PlayerR+BATTERNUM

	move.b	PlayerL+START,d0
	eor.b	#1,d0
	move.b	d0,PlayerL+COMPUTER

	move.b	PlayerR+START,d0
	eor.b	#1,d0
	move.b	d0,PlayerR+COMPUTER


	clr.w	PlayerL+HOMERUNSCNT   
	clr.w	PlayerL+STEALSCNT
	clr.w	PlayerL+STRIKEOUTSCNT
	clr.w	PlayerL+ATBATSCNT
	clr.w	PlayerL+BEANCNT

	clr.w	PlayerR+HOMERUNSCNT   
	clr.w	PlayerR+STEALSCNT     
	clr.w	PlayerR+STRIKEOUTSCNT 
	clr.w	PlayerR+ATBATSCNT
	clr.w	PlayerR+BEANCNT

	move.w	#0x100,PlayerL+PITCHERSTRENGTH ; Set Pitcher not tired
	move.w	#0x100,PlayerR+PITCHERSTRENGTH ; Set Pitcher not tired

	clr.l	trapcnt
;test
;	jsr	GetBatterRoster
;	move.b	PlayerL+FIRSTPITCHER,d0
;	move.b	PlayerR+FIRSTPITCHER,d1
;	move.l	HomePlayer,a0
;	move.l	AwayPlayer,a1
;	trap	#1
;	move.b	#4,PlayerL+stat_defeat
;	move.b	#4,PlayerR+stat_defeat


	rts	;back to game


newplayer
	EXTERM	#20
	EXTERM	#21
	EXTERM	#22
	jmp	Selections

;.............................................................................

AttractSelect

	move.b	#1,PlayerR+COMPUTER	; Set For Computer
 	move.b	#1,PlayerL+COMPUTER	; Set For Computer

	clr.b	PlayerR+START
	clr.b	PlayerL+START

;	move.w	#1,PlayerL+TEAMNUMBER
;	move.w	#2,PlayerR+TEAMNUMBER
;
;	move.l	#$01010101,PlayerL+PLAYERSTEAM
;	move.l	#$01010101,PlayerL+PLAYERSTEAM+4
;	move.l	#$01010101,PlayerL+PLAYERSTEAM+8
;	move.w	#$0101,PlayerL+PLAYERSTEAM+12
;
;	move.l	#$02020202,PlayerR+PLAYERSTEAM
;	move.l	#$02020202,PlayerR+PLAYERSTEAM+4
;	move.l	#$02020202,PlayerR+PLAYERSTEAM+8
;	move.w	#$0202,PlayerR+PLAYERSTEAM+12

	add.w	#1,AttTeam
	move.w	AttTeam,d0
	and.w	#1111b,d0

	move.w	d0,PlayerL+TEAMNUMBER
	move.b	d0,PlayerL+PLAYERSTEAM
	move.b	d0,PlayerL+PLAYERSTEAM+1
	move.b	d0,PlayerL+PLAYERSTEAM+2
	move.b	d0,PlayerL+PLAYERSTEAM+3
	move.b	d0,PlayerL+PLAYERSTEAM+4
	move.b	d0,PlayerL+PLAYERSTEAM+5
	move.b	d0,PlayerL+PLAYERSTEAM+6
	move.b	d0,PlayerL+PLAYERSTEAM+7
	move.b	d0,PlayerL+PLAYERSTEAM+8
	move.b	d0,PlayerL+PLAYERSTEAM+9
	move.b	d0,PlayerL+PLAYERSTEAM+10
	move.b	d0,PlayerL+PLAYERSTEAM+11
	move.b	d0,PlayerL+PLAYERSTEAM+12
	move.b	d0,PlayerL+PLAYERSTEAM+13

	add.w	#1,d0
	move.w	d0,PlayerR+TEAMNUMBER
	move.b	d0,PlayerR+PLAYERSTEAM
	move.b	d0,PlayerR+PLAYERSTEAM+1
	move.b	d0,PlayerR+PLAYERSTEAM+2
	move.b	d0,PlayerR+PLAYERSTEAM+3
	move.b	d0,PlayerR+PLAYERSTEAM+4
	move.b	d0,PlayerR+PLAYERSTEAM+5
	move.b	d0,PlayerR+PLAYERSTEAM+6
	move.b	d0,PlayerR+PLAYERSTEAM+7
	move.b	d0,PlayerR+PLAYERSTEAM+8
	move.b	d0,PlayerR+PLAYERSTEAM+9
	move.b	d0,PlayerR+PLAYERSTEAM+10
	move.b	d0,PlayerR+PLAYERSTEAM+11
	move.b	d0,PlayerR+PLAYERSTEAM+12
	move.b	d0,PlayerR+PLAYERSTEAM+13


	move.b	#0,PlayerL+BATTINGORDER
	move.b	#4,PlayerL+BATTINGORDER+1
	move.b	#7,PlayerL+BATTINGORDER+2
	move.b	#3,PlayerL+BATTINGORDER+3
	move.b	#2,PlayerL+BATTINGORDER+4
	move.b	#5,PlayerL+BATTINGORDER+5
	move.b	#6,PlayerL+BATTINGORDER+6
	move.b	#8,PlayerL+BATTINGORDER+7
	move.b	#1,PlayerL+BATTINGORDER+8
	move.b	#9,PlayerL+BATTINGORDER+9

	move.b	#0,PlayerR+BATTINGORDER
	move.b	#4,PlayerR+BATTINGORDER+1
	move.b	#9,PlayerR+BATTINGORDER+2
	move.b	#3,PlayerR+BATTINGORDER+3
	move.b	#6,PlayerR+BATTINGORDER+4
	move.b	#2,PlayerR+BATTINGORDER+5
	move.b	#7,PlayerR+BATTINGORDER+6
	move.b	#5,PlayerR+BATTINGORDER+7
	move.b	#1,PlayerR+BATTINGORDER+8
	move.b	#8,PlayerR+BATTINGORDER+9

	move.l	#$ffffffff,PlayerL+PITAVAIL ;make all pitchers available
	move.l	#$ffffffff,PlayerR+PITAVAIL

	move.l	#PlayerL,HomePlayer
	move.l	#PlayerR,AwayPlayer

	clr.l	WinningPlayer
	clr.l	LosingPlayer

	move.l	HomePlayer,AtPitPlayer
	move.l	AwayPlayer,AtBatPlayer

	move.w	#1,PlayerL+BATTERNUM
	move.w	#1,PlayerR+BATTERNUM

	move.b	#11,PlayerL+FIRSTPITCHER
	move.b	#11,PlayerR+FIRSTPITCHER

	jsr	AtSetRoster
	jsr	LoadCardPals

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

	clr.w	d0
	move.b	([AtPitPlayer],FIRSTPITCHER),d0 ;first pitcher
	move.l	([AtPitPlayer],d0.w*4,ROSTERPTR),Pitcher+B_ROSTERADR ;point at current pitchers roster adr


	rts

;.............................................................................

MakeSelection

	move.w	#0,curtx
	move.l	#title_sep,behind_curtain

	clr.b	blinker
	SPAWN	#Blinker,#21	;BBLIT blinker

;	move.l	#0x41414100,p1info	; Store "AAA" For Initials, 0 for month
;	move.l	#0x5b5b5b0c,PlayerL+letters	; Store "   " For Initials, c=no month
	move.l	#0x2020200c,PlayerL+letters	; Store "   " For Initials, c=no month
	move.b	#0,PlayerL+dayofmonth
;	move.l	#0x41414100,PlayerR+letters	; Store "AAA" For Initials
;	move.l	#0x5b5b5b0c,PlayerR+letters	; Store "   " For Initials
	move.l	#0x2020200c,PlayerR+letters	; Store "   " For Initials
	move.b	#0,PlayerR+dayofmonth

	clr.b	PlayerL+team
	clr.b	PlayerR+team

	clr.b	PlayerL+stat_defeat
	clr.b	PlayerR+stat_defeat

	clr.l	PlayerL+ALLSAMEADR
	clr.l	PlayerR+ALLSAMEADR

	SPAWN	#BallServiceY,#20	;read trackballs
	jsr	YNinitials

	EXTERM	#20	;turn off ball
	SPAWN	#BallService,#20	;read trackballs

	move.w	#0,curtx	;don't curtain in select team screen

	cmp.b	#NoY,PlayerL+YND
	bne	Input
	cmp.b	#NoY,PlayerR+YND
	beq	TeamSelect
Input			;come here if someone wants to input initials
	jsr	Initial_Input
	jsr	Month_Input
	jsr	Day_Input

	EXTERM	#20	;turn off ball
	move.b	#team,PlayerL+Lcursor	;move cursor off-scrren
	move.b	#team,PlayerR+Lcursor

	jsr	get_data

	jsr	showstats

	tst.l	SinglePlayer
	beq.s	two_players	;no defeated screen if 2 players

	jsr	showdefeats
two_players

	move.w	#0,curtx	;don't curtain in select team screen

	SPAWN	#BallService,#20	;read trackballs

TeamSelect
	jsr	SelectTeam

	jsr	TogglePage	;get to blank screen for palette loads
	DELAY	#1
	jsr	LoadCardPals


	jsr	save_team	;stores team selection

	jsr	Draft_Input

	jsr	save_team_players	;stores team selection


	cmp.b	#DraftY,PlayerL+YND	;is player drafting?
	bne.s	.notdraftL
	move.b	#YesY,PlayerL+YND	;done drafting
.notdraftL
	cmp.b	#DraftY,PlayerR+YND	;is player drafting?
	bne.s	.notdraftR
	move.b	#YesY,PlayerR+YND	;done drafting
.notdraftR


	move.w	#0,curtx	;don't curtain in select team screen

	EXTERM	#20	;turn off ball
;	SPAWN	#BallService2,#20	;read trackballs
	jsr	VSscreen

;	jsr	TogglePage	;get to blank screen for palette loads
;	DELAY	#1
;	jsr	LoadSelectPal	; Select Screen palettes

	jsr	NEWvs

;	jsr	TogglePage	;get to blank screen for palette loads
;	DELAY	#1
;	jsr	LoadCardPals

	EXTERM	#20	;turn off ball
	EXTERM	#21	;turn off blinker




	move.b	#1,seldone	;tell buyin monitor we are done
.done	DELAY	#1
     	jmp	.done

;............................................................................

	.export	zrecord
zrecord
	dc.b	[RecordSize]0

	.align	2

TRAPPER
	trap	#1


showstats
	move.w	#DeadMan,TimeOut	;time to finish
	move.b	#SelectTeamButton,button_sound
	jsr	ButtsOnM
	jsr	setdoneYND
	move.w	#256,topside	;offscreen
	move.l	#statmenu,menuart
.IILP

	tst.l	SinglePlayer
	bne.s	.nochg	;don't prep for select screen if single player game
	tst.w	curtx
	bne.s	.nochg
	jsr	set_select
.nochg
	move.w	#256,topside	;cursor offscreen
	jsr	blit_menu	;blit initials

	jsr	Statistics
	jsr	TogglePage

	jsr	finished
	bne	.IILP

	jsr	ButtsOff
	rts


statmenu
	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	cmp.l	#PlayerL,pinfo
	bne.s	.rightplayer

	tst.w	([pinfo],BeatGame)
	beq.s	.NoTrophy
	APALETTE	#P_TROPHY
	BLOT	#trophy,#7,#5
.NoTrophy
	APALETTE	#P_NEWSCORE
	BLOT	#scrn07a,#7,#5
	rts
.rightplayer
	tst.w	([pinfo],BeatGame)
	beq.s	.NoTrophy2
	APALETTE	#P_TROPHY
	BLOT	#trophy,#199,#5
.NoTrophy2
	APALETTE	#P_NEWSCORE
	BLOT	#scrn07b,#201,#2
	rts


showdefeats
	move.w	#DeadMan,TimeOut	;time to finish
	move.b	#SelectTeamButton,button_sound
	jsr	ButtsOnM
	jsr	setdoneYND
	move.l	#DEFmenu,menuart
.IILP
	tst.w	curtx
	bne.s	.nochg
	jsr	set_select
.nochg
	jsr	blit_menu	;blit initials

	jsr	TogglePage

	jsr	finished
	bne	.IILP

	jsr	ButtsOff
	rts




set_select
	move.b	PlayerL+team,PlayerL+Bcursor
	move.b	PlayerR+team,PlayerR+Bcursor
	move.b	#team,PlayerL+Lcursor
	move.b	#team,PlayerR+Lcursor
	move.w	#7,menu_width
	move.w	#4,menu_height
	move.w	#53,xcmspace
	move.w	#18,ymspace
	move.w	#27,PlayerL+max_select
	move.w	#27,PlayerR+max_select
	move.w	#28,PlayerL+max_input
	move.w	#28,PlayerR+max_input
	move.w	#176,topside

	cmp.b	#DraftY,PlayerL+YND	;is player drafting?
	beq.s	.nocurt

	cmp.b	#DraftY,PlayerR+YND	;is player drafting?
	beq.s	.nocurt

	move.l	#blit_select,behind_curtain ;prep select screen
.nocurt
	rts


save_stats		;saves for both players
	cmp.b	#NoY,PlayerR+YND
	beq.s	.p2	;don't save if no initials input
	jsr	LoadPtrs
	tst.b	START(a6)
	beq.s	.p2
	move.l	#records,a0	;player2 on top
	move.l	a6,a5
	jsr	Player2REC
.p2
	cmp.b	#NoY,PlayerL+YND
	beq.s	.nop	;don't save if no initials input
	jsr	LoadPtrs
	tst.b	START(a5)
	beq.s	.nop
	move.l	#records,a0
	tst.b	START(a6)	;other player?
	beq.s	.nop2
	move.l	#records+`sizeof(recorddata),a0 ;player1 in second slot
.nop2
	jsr	Player2REC

.nop
	rts


Player2REC
	move.b	stat_defeat(a5),REC_stat_defeat(a0)
	move.b	winCNT(a5),REC_winCNT(a0)
	move.b	seriesCNT(a5),REC_seriesCNT(a0)

	move.w	stat_win(a5),REC_stat_win(a0)
	move.w	stat_lastgame(a5),REC_stat_lastgame(a0)
	move.w	stat_lost(a5),REC_stat_lost(a0)
	move.w	stat_hits(a5),REC_stat_hits(a0)
	move.w	stat_atbats(a5),REC_stat_atbats(a0)
	move.w	BeatGame(a5),REC_BeatGame(a0)
	move.w	stat_homeruns(a5),REC_stat_homeruns(a0)
	move.w	stat_steals(a5),REC_stat_steals(a0)
	move.w	stat_strikeouts(a5),REC_stat_strikeouts(a0)

	PUSHL	a0-a1	;save em
	lea.l	RecordSize-2(a0),a1	;point at checksum
	jsr	fix_checksum
	POPL	a0-a1	;save em

	rts


save_team
	cmp.b	#NoY,PlayerR+YND
	beq.s	.p2	;don't save if no initials input
	jsr	LoadPtrs
	tst.b	START(a6)
	beq.s	.p2
	move.l	#records+REC_team,a0	;player2 on top
	move.b	PlayerR+team,(a0)

	move.l	#records,a0
	lea.l	RecordSize-2(a0),a1	;point at checksum
	jsr	fix_checksum

.p2
	cmp.b	#NoY,PlayerL+YND
	beq.s	.nop	;don't save if no initials input
	jsr	LoadPtrs
	tst.b	START(a5)
	beq.s	.nop
	move.l	#records,a0
	tst.b	START(a6)
	beq.s	.nop2
	move.l	#records+`sizeof(recorddata),a0 ;player1 in second slot
.nop2	move.b	PlayerL+team,REC_team(a0)

	lea.l	RecordSize-2(a0),a1	;point at checksum
	jsr	fix_checksum

.nop
	rts


save_team_players

	cmp.b	#NoY,PlayerR+YND
	beq.s	.p2	;don't save if no initials input
	jsr	LoadPtrs
	tst.b	START(a6)
	beq.s	.p2
	move.l	#records,a2
	move.l	#PlayerR,a3

	tst.w	SpecialTeam(a3)
	bne.s	.p2	;branch=no save, if a perm

	move.l	players(a3),REC_players(a2) ;4
	move.l	players+4(a3),REC_players+4(a2) ;4
	move.l	players+8(a3),REC_players+8(a2) ;4
	move.w	players+12(a3),REC_players+12(a2) ;2=14 number of players
	move.l	bat_order(a3),REC_bat_order(a2)
	move.l	bat_order+4(a3),REC_bat_order+4(a2)
	move.w	bat_order+8(a3),REC_bat_order+8(a2) ;10 bytes in bat order

	move.l	a2,a0
	lea.l	RecordSize-2(a0),a1	;point at checksum
	jsr	fix_checksum

.p2
	cmp.b	#NoY,PlayerL+YND
	beq.s	.nop	;don't save if no initials input
	jsr	LoadPtrs
	tst.b	START(a5)
	beq.s	.nop
	move.l	#records,a2
	tst.b	START(a6)
	beq.s	.nop2
	move.l	#records+`sizeof(recorddata),a2
.nop2
	move.l	#PlayerL,a3

	tst.w	SpecialTeam(a3)
	bne.s	.nop	;branch=no save, if a perm

	move.l	players(a3),REC_players(a2) ;4
	move.l	players+4(a3),REC_players+4(a2) ;4
	move.l	players+8(a3),REC_players+8(a2) ;4
	move.w	players+12(a3),REC_players+12(a2) ;2=14 number of players
	move.l	bat_order(a3),REC_bat_order(a2)
	move.l	bat_order+4(a3),REC_bat_order+4(a2)
	move.w	bat_order+8(a3),REC_bat_order+8(a2) ;10 bytes in bat order

	move.l	a2,a0
	lea.l	RecordSize-2(a0),a1	;point at checksum
	jsr	fix_checksum

.nop	rts



get_data
	jsr	LoadPtrs
	move.l	#PlayerL,a0
	tst.b	START(a5)
	beq.s	.p2
	jsr	getrec
.p2
	jsr	LoadPtrs
	move.l	#PlayerR,a0
	tst.b	START(a6)
	beq.s	.nop
	jsr	getrec
.nop	rts


;	.export	getrec
getrec			;put player on top of records
	move.l	#records,a1
	move.l	a0,a2	;player L or R
			;a0=where letters are
			;a2=where data will go
.reclp
	KICK_DOG
	move.l	a1,a3	;current record

	move.l	letters(a0),d0	;3 letters+month
	cmp.l	REC_letters(a1),d0
	bne	.next
	move.b	dayofmonth(a0),d0
	cmp.b	REC_dayofmonth(a1),d0
	bne	.next

;test
;	add.b	#1,stat_defeat(a3)
;	add.w	#1,stat_win(a3)
;	add.w	#1,stat_lost(a3)
;	add.w	#1,stat_ba(a3)
;	add.w	#1,stat_homeruns(a3)

;get info
	move.b	REC_team(a3),team(a2)
	move.b	REC_stat_defeat(a3),stat_defeat(a2)
	move.w	REC_stat_win(a3),stat_win(a2)
	move.w	REC_stat_lastgame(a3),stat_lastgame(a2)
	move.w	REC_stat_lost(a3),stat_lost(a2)
;	move.w	REC_stat_ba(a3),stat_ba(a2)
	move.w	REC_stat_hits(a3),stat_hits(a2)
	move.w	REC_stat_atbats(a3),stat_atbats(a2)
	move.w	REC_BeatGame(a3),BeatGame(a2)
	move.w	REC_stat_homeruns(a3),stat_homeruns(a2)
	move.w	REC_stat_steals(a3),stat_steals(a2)
	move.w	REC_stat_strikeouts(a3),stat_strikeouts(a2)
	move.w	REC_first_pitcher(a3),first_pitcher(a2)
	move.l	REC_players(a3),players(a2) ;4
	move.l	REC_players+4(a3),players+4(a2) ;4
	move.l	REC_players+8(a3),players+8(a2) ;4
	move.w	REC_players+12(a3),players+12(a2) ;2=14 number of players
	move.l	REC_bat_order(a3),bat_order(a2)
	move.l	REC_bat_order+4(a3),bat_order+4(a2)
	move.w	REC_bat_order+8(a3),bat_order+8(a2) ;10 bytes in bat order
	move.b	REC_winCNT(a3),winCNT(a2)
	move.b	REC_seriesCNT(a3),seriesCNT(a2)
	move.w	REC_checksum(a3),checkzum(a2)
;move everyone down
	cmp.l	#records,a3
	beq	.already_first
	lea.l	`sizeof(recorddata)(a3),a0
.close_up
	move.b	-(a3),-(a0)
	cmp.l	#records,a3
	bne.s	.close_up
;put on top
	move.b	letters(a2),REC_letters(a3)
	move.b	letters+1(a2),REC_letters+1(a3)
	move.b	letters+2(a2),REC_letters+2(a3)
	move.b	month(a2),REC_month(a3)
	move.b	dayofmonth(a2),REC_dayofmonth(a3)
	move.b	team(a2),REC_team(a3)
	move.b	stat_defeat(a2),REC_stat_defeat(a3)
	move.w	stat_win(a2),REC_stat_win(a3)
	move.w	stat_lastgame(a2),REC_stat_lastgame(a3)
	move.w	stat_lost(a2),REC_stat_lost(a3)
;	move.w	stat_ba(a2),REC_stat_ba(a3)
	move.w	stat_hits(a2),REC_stat_hits(a3)
	move.w	stat_atbats(a2),REC_stat_atbats(a3)
	move.w	BeatGame(a2),REC_BeatGame(a3)
	move.w	stat_homeruns(a2),REC_stat_homeruns(a3)
	move.w	stat_steals(a2),REC_stat_steals(a3)
	move.w	stat_strikeouts(a2),REC_stat_strikeouts(a3)
	move.w	first_pitcher(a2),REC_first_pitcher(a3)
	move.l	players(a2),REC_players(a3) ;4
	move.l	players+4(a2),REC_players+4(a3) ;4
	move.l	players+8(a2),REC_players+8(a3) ;4
	move.w	players+12(a2),REC_players+12(a3) ;2=14 number of players
	move.l	bat_order(a2),REC_bat_order(a3)
	move.l	bat_order+4(a2),REC_bat_order+4(a3)
	move.w	bat_order+8(a2),REC_bat_order+8(a3) ;10 bytes in bat order
	move.b	winCNT(a2),REC_winCNT(a3)
	move.b	seriesCNT(a2),REC_seriesCNT(a3)
	move.w	checkzum(a2),REC_checksum(a3)
.already_first
	bra	getrec_exit

.next			;next record
	move.l	a2,a0	;point a0 back to pxinfo
	move.l	a3,a1	;back to beginning of record
	lea.l	`sizeof(recorddata)(a1),a1 ;next record
	cmp.l	#endrec,a1
	bne	.reclp

;new player
;move everyone down
	move.l	#endrec-`sizeof(recorddata),a0
	move.l	#endrec,a1
.movelp
	KICK_DOG
	move.b	-(a0),-(a1)
	cmp.l	#records,a0
	bne.s	.movelp
;clear new player data
	clr.b	team(a2)
	clr.b	stat_defeat(a2)
	clr.w	stat_win(a2)
	clr.w	stat_lastgame(a2)
	clr.w	stat_lost(a2)
;	clr.w	stat_ba(a2)
	clr.w	stat_hits(a2)
	clr.w	stat_atbats(a2)
	clr.w	BeatGame(a2)
	clr.w	stat_homeruns(a2)
	clr.w	stat_steals(a2)
	clr.w	stat_strikeouts(a2)
	clr.w	first_pitcher(a2)
	clr.l	players(a2) ;4
	clr.l	players+4(a2) ;4
	clr.l	players+8(a2) ;4
	clr.w	players+12(a2) ;2=14 number of players
	clr.l	bat_order(a2)
	clr.l	bat_order+4(a2)
	clr.w	bat_order+8(a2)
	clr.b	winCNT(a2)
	clr.b	seriesCNT(a2)

;see if a permanant player, and get data from table instead

;	PUSHL	a1-a2
;	move.l	a2,a3	;pointer to letters to find
;	jsr	FindPerm
;	beq.s	.NotPerm

;put into normal AND REC_ 


;.NotPerm
;	POPL	a1-a2

;set new player record
	move.l	#records,a1
	move.b	letters(a2),REC_letters(a1)
	move.b	letters+1(a2),REC_letters+1(a1)
	move.b	letters+2(a2),REC_letters+2(a1)
	move.b	month(a2),REC_month(a1)
	move.b	dayofmonth(a2),REC_dayofmonth(a1)

	clr.b	REC_team(a1)
	clr.b	REC_stat_defeat(a1)
	clr.w	REC_stat_win(a1)
	clr.w	REC_stat_lastgame(a1)
	clr.w	REC_stat_lost(a1)
;	clr.w	REC_stat_ba(a1)
	clr.w	REC_stat_hits(a1)
	clr.w	REC_stat_atbats(a1)
	clr.w	REC_BeatGame(a1)
	clr.w	REC_stat_homeruns(a1)
	clr.w	REC_stat_steals(a1)
	clr.w	REC_stat_strikeouts(a1)
	clr.w	REC_first_pitcher(a1)
	clr.l	REC_players(a1) ;4
	clr.l	REC_players+4(a1) ;4
	clr.l	REC_players+8(a1) ;4
	clr.w	REC_players+12(a1) ;2=14 number of players
	clr.l	REC_bat_order(a1)
	clr.l	REC_bat_order+4(a1)
	clr.w	REC_bat_order+8(a1)
	clr.b	REC_winCNT(a1)
	clr.b	REC_seriesCNT(a1)

	move.l	a1,a0
	lea.l	RecordSize-2(a0),a1	;point at checksum
	jsr	fix_checksum

getrec_exit
	cmp.b	#DraftY,YND(a2)	;is player drafting?
	bne.s	.nodraft
	move.b	#draftteam,team(a2)
.nodraft

CheckSpecialTeam
;check for special teams
	jsr	init_permanent	;create data in ram with checksums

	clr.w	SpecialTeam(a2)

	move.l	#PermRecords,a1
	move.l	a2,a0	;player L or R
.reclp
	move.l	a1,a3	;current record
	move.l	letters(a0),d0	;3 letters+month
	cmp.l	REC_letters(a1),d0
	bne	.next
	move.b	dayofmonth(a0),d0
	cmp.b	REC_dayofmonth(a1),d0
	bne	.next

	move.w	#1,SpecialTeam(a2)	;don't save team

;get special for game, a3=perm a2=PlayerLR
	move.b	REC_team(a3),team(a2)
	move.l	REC_players(a3),players(a2) ;4
	move.l	REC_players+4(a3),players+4(a2) ;4
	move.l	REC_players+8(a3),players+8(a2) ;4
	move.w	REC_players+12(a3),players+12(a2) ;2=14 number of players
	move.l	REC_bat_order(a3),bat_order(a2)
	move.l	REC_bat_order+4(a3),bat_order+4(a2)
	move.w	REC_bat_order+8(a3),bat_order+8(a2) ;10 bytes in bat order

;get special for record, a3=perm dest=records
	move.b	REC_team(a3),REC_team+records
	move.l	REC_players(a3),REC_players+records ;4
	move.l	REC_players+4(a3),REC_players+4+records ;4
	move.l	REC_players+8(a3),REC_players+8+records ;4
	move.w	REC_players+12(a3),REC_players+12+records ;2=14 number of players
	move.l	REC_bat_order(a3),REC_bat_order+records
	move.l	REC_bat_order+4(a3),REC_bat_order+4+records
	move.w	REC_bat_order+8(a3),REC_bat_order+8+records ;10 bytes in bat order

	move.l	#records,a0
	lea.l	RecordSize-2(a0),a1	;point at checksum
	jsr	fix_checksum
	rts

.next			;next record
	move.l	a2,a0	;point a0 back to pxinfo
	move.l	a3,a1	;back to beginning of record
	lea.l	`sizeof(recorddata)(a1),a1 ;next record
	cmp.l	#Pendrec,a1
	bne	.reclp

	rts

;............................................................................

FindPerm
;	move.l	#PermRecords,precPtr

	rts

;............................................................................

CoinageScreen2	;during game
	move.b	#1,ingame	;tell this routine, came from game
	move.w	#2,messcnt
	bra.s	CoSc
CoinageScreen
	move.b	#0,ingame
	move.w	#3,messcnt

CoSc
	SOUND	#SOUNDSON,#SOUNDSON	; Turn On Sounds
	SOUND	#BuyInMusic,#0

	move.b	#1,coinON
	jsr	InitProcs

	jsr	LoadTicketPals

	tst.b	PlayerL+START
	beq.s	.noLeft
	SWITCH	#START1,#1H,#incinns1
	SWITCH	#BUTTON1_1,#1H,#hurryup
	SWITCH	#BUTTON1_2,#1H,#hurryup
	SWITCH	#BUTTON1_3,#1H,#hurryup
	SWITCH	#BUTTON1_4,#1H,#hurryup
.noLeft
	tst.b	PlayerR+START
	beq.s	.noRight
	SWITCH	#START2,#1H,#incinns2
	SWITCH	#BUTTON2_1,#1H,#hurryup
	SWITCH	#BUTTON2_2,#1H,#hurryup
	SWITCH	#BUTTON2_3,#1H,#hurryup
	SWITCH	#BUTTON2_4,#1H,#hurryup
.noRight

	jsr	AllocObject	; Allocate background art
	beq.s	nobkg	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	clr.l	UPDATEPROC(a0)	; Clear Animation Routine
	move.w	#100,ZPOSITION(a0)	; Initialize Z Position
	move.w	#gate,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_GATE,PALETTE(a0)	; Set Palette Number
	move.w	#0,XPOSITION(a0)	; Set X Position
	move.w	#0,YPOSITION(a0)	; Set Y Position
	move.b	#Title,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
nobkg


	move.b	Inning,d0
	lsr.b	#1,d0	;convert inning halves to whole
;	add.b	#1,d0	;make 1 based
	cmp.b	INNINGSBOUGHT+PlayerL,d0
	ble.s	.nominL
	move.b	d0,INNINGSBOUGHT+PlayerL ;minimum number of tickets
.nominL	cmp.b	INNINGSBOUGHT+PlayerR,d0
	ble.s	.nominR
	move.b	d0,INNINGSBOUGHT+PlayerR ;minimum number of tickets
.nominR


	jsr	AllocObject	; Allocate red tickets
	beq.s	noticketrd	; Branch If None
	move.l	#TicketBlitL,DISPLAYPROC(a0) ; Store Address Of Display Procedure
;	move.l	#TicketSlideL,UPDATEPROC(a0)	; Clear Animation Routine
	move.w	#110,ZPOSITION(a0)	; Initialize Z Position
	move.w	#ticketrd,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
;	move.b	#P_SO,PALETTE(a0)	; Set Palette Number
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number

	move.w	#86,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary

;init ticketpos
	move.l	#-(9*40)+13,d0	;starting x
	clr.l	d2
	move.b	INNINGSBOUGHT+PlayerL,d2

	clr.l	d1
	move.b	Inning,d1
	lsr.b	#1,d1	;convert inning halves to whole
	divu	#9,d1
	mulu	#9,d1
	sub.w	d1,d2 ;sync with inning labels, first inning number 0,9,18,27...

	mulu	#40,d2	;ticket width
	add.w	d2,d0
	move.w	d0,TICKETXPOS+PlayerL

noticketrd

	jsr	AllocObject	; Allocate blue tickets
	beq.s	noticketbl	; Branch If None
	move.l	#TicketBlitR,DISPLAYPROC(a0) ; Store Address Of Display Procedure
;	move.l	#TicketSlideR,UPDATEPROC(a0)	; Clear Animation Routine
	move.w	#110,ZPOSITION(a0)	; Initialize Z Position
	move.w	#ticketbl,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
;	move.b	#P_BLUESO,PALETTE(a0)	; Set Palette Number
	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number

	move.w	#169,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary

;init ticketpos
	move.l	#-(9*40)+13,d0	;starting x (40 = ticket width)
	clr.l	d2
	move.b	INNINGSBOUGHT+PlayerR,d2

	clr.l	d1
	move.b	Inning,d1
	lsr.b	#1,d1	;convert inning halves to whole
	divu	#9,d1
	mulu	#9,d1
	sub.w	d1,d2 ;sync with inning labels, first inning number 0,9,18,27...

	mulu	#40,d2	;ticket width
	add.w	d2,d0
	move.w	d0,TICKETXPOS+PlayerR
noticketbl

	jsr	AllocObject	; Allocate text
	beq.s	noinfo	; Branch If None
	move.l	#displayinfo,DISPLAYPROC(a0) ; Store Address Of Display Procedure
	clr.l	UPDATEPROC(a0)	; Clear Animation Routine
	move.w	#120,ZPOSITION(a0)	; Initialize Z Position
	move.w	#0,COUNTER(a0)	; Initialize message cycler
	move.w	#0,DURATION(a0)	;message #
	clr.l	PARSEPOINTER(a0)	; Set Animation String
noinfo

	move.w	#buytime,CTimer	;time to buy innings

	move.b	#9,max4sale	;default max tickets can buy
	move.b	Inning,d0
	lsr.b	#1,d0	;convert inning halves to whole
	add.b	#1,d0	;make 1 based
	cmp.b	#9,d0
	ble.s	.max9
	add.b	#1,d0	;allow only 1 extra inning at a time
	move.b	d0,max4sale	;max tickets can buy
.max9

.Cloop

	jsr	Update	; Update All Objects
	jsr	Sort	; Sort The Objects
	jsr	Display	; Display All Objects

	jsr	TogglePage

	jsr	LoadPtrs	; Load Pointer To Characters
	move.b	INNINGSBOUGHT(a5),d0
	or.b	INNINGSBOUGHT(a6),d0
	beq	.Cloop	;dont time until 1 is bought

	sub.w	#1,CTimer	;time passes

	tst.b	ingame
	bne.s	.no9
	cmp.b	#9,PlayerL+INNINGSBOUGHT
	bne.s	.no9
	cmp.b	#9,PlayerR+INNINGSBOUGHT
	bne.s	.no9
	sub.w	#8,CTimer	;fast time if all innings bought
.no9	cmp.w	#60,CTimer
	bgt	.Cloop

	jsr	ButtsOff

	tst.b	START(a5)
	beq.s	.nopl1
	SWITCH	#START1,#81H,#0
.nopl1
	tst.b	START(a6)
	beq.s	.nopl2
	SWITCH	#START2,#81H,#0
.nopl2
	jsr	InitProcs
	jsr	InitJoyWatch

;clear any buyins
	jsr	LoadPtrs
	move.b	START(a5),p1start
	move.b	START(a5),PlayerL+present
	move.b	START(a6),p2start
	move.b	START(a6),PlayerR+present
	move.b	#0,coinON	;turn on buyins
	rts

;............................................................................

TicketSlideL
	move.l	#PlayerL,a6
	bra.s	TicSlide

TicketSlideR
	move.l	#PlayerR,a6
TicSlide
	add.w	#2,TICKETXPOS(a6)
	sub.w	#2,COUNTER(a5)
	bne.s	.notdone
	jsr	DeallocObject
.notdone	rts


TicketBlitL
	move.l	#PlayerL,a6
	move.w	#playedrd,temp+2
	bra.s	TicBlit
;	tst.b	START(a6)
;	bne.s	TicBlit
;	rts
TicketBlitR
	move.l	#PlayerR,a6
	move.w	#playedbl,temp+2
	tst.b	START(a6)
;	bne.s	TicBlit
;	rts

TicBlit
	SETCLIP	#13,#0,#384,#256
	IMAGES	BANK(a5)	; Set Bank Number
	APALETTE	PALETTE(a5)
	move.w	TICKETXPOS(a6),temp

	BLIT	PICTURE(a5),temp,YPOSITION(a5)
	add.w	#40,temp
	BLIT	PICTURE(a5),temp,YPOSITION(a5)
	add.w	#40,temp
	BLIT	PICTURE(a5),temp,YPOSITION(a5)
	add.w	#40,temp
	BLIT	PICTURE(a5),temp,YPOSITION(a5)
	add.w	#40,temp
	BLIT	PICTURE(a5),temp,YPOSITION(a5)
	add.w	#40,temp
	BLIT	PICTURE(a5),temp,YPOSITION(a5)
	add.w	#40,temp
	BLIT	PICTURE(a5),temp,YPOSITION(a5)
	add.w	#40,temp
	BLIT	PICTURE(a5),temp,YPOSITION(a5)
	add.w	#40,temp
	BLIT	PICTURE(a5),temp,YPOSITION(a5)
	add.w	#40,temp

	SETCLIP	#0,#0,#384,#256

	tst.b	ingame
	bne	canceltickets
;full game?
	tst.b	Inning
	bne	noFmess	;only at start of game

	cmp.b	#9,INNINGSBOUGHT(a6)	;a6=player
	bne	noFmess	;

;	SETPRINT	#16,#24,#fnt2,#0
;	clr.l	FontAdjust
;	move.l	#fnt2Spacing,FontSpacing
;	move.l	#F2CharTrans,CharTrans ; character translation table

	APALETTE	#P_NEWSCORE

	BLIT	#fullgame,#75,YPOSITION(a5)
;	PLOT	#0,YPOSITION(a5)
;	PRINT	"FULL GAME PURCHASED"

noFmess	rts
canceltickets

	clr.l	d0
	move.b	Inning,d0
	lsr.b	#1,d0	;convert inning halves to whole
;	add.b	#1,d0	;make 1 based

	divu	#9,d0
	swap	d0	;get mod, if more than 9

	move.b	d0,temp
	tst.b	d0
	beq.s	.nocancels
	move.w	#13,d2	;first x

.playdLP
	move.w	YPOSITION(a5),d3
	sub.w	#15,d3	;align to tickets
	APALETTE	#P_NEWSCORE
;	BLIT	#playedrd,d2,d3
	BLIT	temp+2,d2,d3
	add.w	#40,d2
	sub.b	#1,temp
	bne.s	.playdLP
.nocancels	rts



displayinfo
	add.w	#1,COUNTER(a5)
	cmp.w	#4*30,COUNTER(a5)	;MESSAGE CYCLE SPEED
	blt.s	.noinc
	clr.w	COUNTER(a5)
	add.w	#1,DURATION(a5)	;message #
	move.w	messcnt,d0	;total # of messages
	cmp.w	DURATION(a5),d0	;total # of messages
	bgt.s	.noinc
	clr.w	DURATION(a5)	;message #
.noinc

	SETPRINT	#13,#17,#neo4,#0
	clr.l	FontAdjust
	move.l	#neo4Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table
;	APALETTE	#P_FONTW1
	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals

	cmp.w	#0,DURATION(a5)
	bne.s	NotThis1
	PPRINT	#116+17,#13,"PURCHASE INNINGS"
NotThis1
	cmp.w	#1,DURATION(a5)
	bne.s	NotThis2
	PPRINT	#104+17,#13,"1 CREDIT = 2 INNINGS"
NotThis2
	cmp.w	#2,DURATION(a5)
	bne.s	NotThis3
	PPRINT	#51+17,#13,"BUY 8 INNINGS  GET THE 9TH FREE"
NotThis3

;timers
	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans ; character translation table

;	APALETTE	#P_FONTR1
	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals

	move.w	CTimer,d1
	ext.l	d1
	divu	#60,d1
	move.b	d1,temp
	PLOT	#28,#202
	PRINTDECB temp,#2,JRGT

	PLOT	#318,#202
	PRINTDECB temp,#2,JRGT

;	BLIT	#buyin,#15,#188
;	BLIT	#buyin,#316,#188


;innings labels
	SETPRINT	#20,#21,#neo7,#0
	clr.l	FontAdjust
;	clr.l	FontSpacing
	move.l	#neo7Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table

	clr.l	d0
	move.b	Inning,d0
	lsr.b	#1,d0	;convert inning halves to whole
	divu	#9,d0
	mulu	#9,d0
	add.b	#1,d0	;make 1 based

	move.b	d0,temp+1	;first inning number 1,10,19,28 ???
	move.b	#9,temp	;number of innings to print
	move.w	#31,temp+2	;x pos
innlab1
	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals
	PLOT	temp+2,#71-5
	PRINTDECB temp+1,#2,JLEFT

	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals
	PLOT	temp+2,#154-5
	PRINTDECB temp+1,#2,JLEFT

	add.w	#40,temp+2	;x spacing
	add.b	#1,temp+1
	sub.b	#1,temp
	bne	innlab1

;player labels
;	SETPRINT	#16,#24,#fnt2,#0
;	clr.l	FontAdjust
;	move.l	#fnt2Spacing,FontSpacing
;	move.l	#F2CharTrans,CharTrans ; character translation table

	APALETTE	#P_NEWSCORE
;	PPRINT	#125,#44,"PLAYER 1"
	BLIT	#pone,#125+17,#44-7
;	PPRINT	#125,#126,"PLAYER 2"
	BLIT	#ptwo,#125+17,#126-7


;credits
	SETPRINT	#20,#21,#neo7,#0
	clr.l	FontAdjust
	move.l	#neo7Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table

;	APALETTE	#P_FONTW1
	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals
	PPRINT	#160,#210,"CREDITS"


;	SETPRINT	#16,#24,#fnt2,#0
;	clr.l	FontAdjust
;	move.l	#fnt2Spacing,FontSpacing
;	move.l	#F2CharTrans,CharTrans ; character translation table

	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans ; character translation table

	PLOT	#185,#225
	jsr	InCreditsMsg

	rts



incinns1
	jsr	LoadPtrs	; Load Pointer To Characters
	move.w	#1,d0	; Check For Player 1
	jsr	TestCredits	; Check If Enough Credits Available
	beq	nocredits	; Branch If Not
	move.l	#PlayerL,a6
	move.l	#TicketSlideL,a4	;players ticket slider
	bra.s	incinns

incinns2
	jsr	LoadPtrs	; Load Pointer To Characters
	move.w	#2,d0	; Check For Player 2
	jsr	TestCredits	; Check If Enough Credits Available
	beq	nocredits	; Branch If Not
	move.l	#TicketSlideR,a4	;players ticket slider
incinns
	move.b	max4sale,d0
	cmp.b	INNINGSBOUGHT(a6),d0
	beq	nocredits	; Branch If Not
	jsr	TakeCredits	; Decrement Credit Count
	add.b	#2,INNINGSBOUGHT(a6)	;2 innings per credit
	move.b	#1,START(a6)
	move.w	#buytime,CTimer	; Set Initial Timer
TicketSlider
	SOUND	#TicketDispenser,#0
	jsr	AllocObject	; Allocate red tickets
	beq.s	.noObj	; Branch If None
	move.l	a4,UPDATEPROC(a0)	; Clear Animation Routine
	move.w	#80,COUNTER(a0)	;ticket width
.noObj
;	tst.b	ingame
;	bne.s	nocredits	;branch if in game
	cmp.b	#8,INNINGSBOUGHT(a6)
	bne.s	nocredits
	add.b	#1,INNINGSBOUGHT(a6)	;free 9th inning
	jsr	AllocObject	; Allocate red tickets
	beq.s	.noObjfree	; Branch If None
	move.l	a4,UPDATEPROC(a0)	;ticket slider
	move.w	#40,COUNTER(a0)	;ticket width
.noObjfree

nocredits	rts


hurryup
	move.b	#BUTTON1_1,d0
	jsr	SwitchState
	tst.b	d0
	bne.s	.butdown
	move.b	#BUTTON1_2,d0
	jsr	SwitchState
	tst.b	d0
	bne.s	.butdown
	move.b	#BUTTON1_3,d0
	jsr	SwitchState
	tst.b	d0
	bne.s	.butdown
	move.b	#BUTTON1_4,d0
	jsr	SwitchState
	tst.b	d0
	bne.s	.butdown
	move.b	#BUTTON2_1,d0
	jsr	SwitchState
	tst.b	d0
	bne.s	.butdown
	move.b	#BUTTON2_2,d0
	jsr	SwitchState
	tst.b	d0
	bne.s	.butdown
	move.b	#BUTTON2_3,d0
	jsr	SwitchState
	tst.b	d0
	bne.s	.butdown
	move.b	#BUTTON2_4,d0
	jsr	SwitchState
	tst.b	d0
	bne.s	.butdown
.terminate	rts
.butdown	sub.w	#6,CTimer	;speed up the timer
	cmp.w	#60,CTimer
	blt	.terminate
	DELAY	#1
	bra	hurryup

;.............................................................................

YNinitials
	move.w	#DeadMan,TimeOut	;time to finish
	move.b	#SelectTeamButton,button_sound
	jsr	ButtsOnYND

	move.b	#NoY-1,PlayerL+Bcursor
	move.b	#NoY-1,PlayerR+Bcursor
	move.b	#NoY,PlayerL+YND
	move.b	#NoY,PlayerR+YND
	move.b	#YND,PlayerL+Lcursor
	move.b	#YND,PlayerR+Lcursor
;	move.l	#YNList,menuart
;	move.w	#6,menu_width
	move.w	#1,menu_width
;	move.w	#6,menu_height
	move.w	#3,menu_height
	move.w	#50,xmspace	;was 60
	move.w	#50,xcmspace
	move.w	#26,ymspace
	move.w	#1,art_offset


;	move.w	#1,PlayerL+max_select
;	move.w	#1,PlayerR+max_select
;drafton
	move.w	#2,PlayerL+max_select
	move.w	#2,PlayerR+max_select


	move.w	#3,PlayerL+max_input
	move.w	#3,PlayerR+max_input


	move.w	#145,topside
	jsr	setdone

YNloop
	move.w	#3,leftside
	move.w	#13,leftcside	;cursor leftside

	jsr	blit_YND
	move.b	#2,message_flag
	jsr	CreditsMsg

	jsr	TogglePage
	DELAY	#1

	jsr	finished
	bne	YNloop


	tst.w	TimeOut
	bne.s	NoTimeOut
	move.b	#NoY,PlayerL+YND
	move.b	#NoY,PlayerR+YND
NoTimeOut

	tst.l	SinglePlayer
	beq.s	two_players2
	eor.b	#1,firstt	;force player to Home team if computer playing
two_players2
	move.l	#PlayerL,HomePlayer
	move.l	#PlayerR,AwayPlayer
	move.b	firstt,firstteam	;which player selected first
	beq.s	awayok
	move.l	#PlayerR,HomePlayer
	move.l	#PlayerL,AwayPlayer
awayok
	jsr	ButtsOff

	rts



blit_YND
	move.l	behind_curtain,a0
	tst.l	a0
	beq.s	.nocurt
	jsr	(a0)
.nocurt
	IMAGES	#Initial
	APALETTE	#P_BAK1APAL
	BLOT	#bakdrp3a,#180,#0
	APALETTE	#P_BAK1BPAL
	BLOT	#bakdrp3b,#0,#0

	move.l	#PlayerL,pinfo
	move.l	#LeftData,pinfodata
	jsr	YNDside
	move.l	#PlayerR,pinfo
	move.l	#RightData,pinfodata
YNDside
	tst.b	([pinfo],START)
	beq	beggar

	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	BLOT	<([pinfodata],YNDscrn)>,<([pinfodata],YNDscrnX)>,<([pinfodata],YNDscrnY)>
;highlight selection
	APALETTE	#P_NEOYEL
	cmp.b	#1,([pinfo],Bcursor)
	bne.s	.NoBall
	BLOT	#playball,<([pinfodata],playballX)>,#72
	bra	.HighLightDone
.NoBall	cmp.b	#0,([pinfo],Bcursor)
	bne.s	.NoIni
	BLOT	#enterini,<([pinfodata],enteriniX)>,#114
	bra.s	.HighLightDone
.NoIni
	SETCLIP	#0,#0,#384,#183
	BLOT	#draft,<([pinfodata],draftX)>,#157
	SETCLIP	#0,#0,#384,#256
.HighLightDone
;cursor
	clr.w	d1
	move.b	([pinfo],Bcursor),d1
	clr.w	d0
	move.b	(YNDcursorY,d1.w),d0
	BBLIT	<<([pinfodata],YNDarrow)>>,<<([pinfodata],YNDcursorX)>>,d0
;draft cost
	SETPRINT	#13,#17,#neo4,#0
	clr.l	FontAdjust
	move.l	#neo4Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table
	APALETTE	#P_NEOYEL

	PLAT	<([pinfodata],drcostX)>,#182
	PRINT	"COSTS "
	PRINTDEC	min_draft_credit,#1,JLEFT
	PRINT	" CREDITS"

	rts


beggar
	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	BBLIT	#oppo,<<([pinfodata],oppX)>>,#97 ;double << nested parameter
	rts

YNDcursorY
	dc.b	117,75,157
	.align	2


;YNList			;called by (a0)
;	SETPRINT	#13,#13,#fnt1,#0
;	clr.l	FontAdjust
;	move.l	#fnt1Spacing,FontSpacing
;	move.l	#F5CharTrans,CharTrans	; character translation table
;
;	PLAT	leftside,#80
;	APALETTE	#P_FONTW1
;	PRINT	"ENTER INITIALS?"
;
;	PLAT	leftside,#127
;	move.b	#1,temp
;
;	move.w	leftside,d3
;	move.w	menu_height,d4
;YNylp	move.w	menu_width,d5
;YNxlp
;	PUSHL	d3-d6
;
;	jsr	SetPalToSideDim
;	move.l	pinfo,a0
;	move.b	temp,d0
;	sub.b	#1,d0
;	cmp.b	Bcursor(a0),d0
;	bne	YNnotdim
;	jsr	SetPalToSide
;	sub.w	#3,pry_coor	;shift selected char up
;YNnotdim
;	cmp.b	#1,temp
;	bne.s	YNnot1
;	PRINT	"YES"
;	jmp	YNprinted
;YNnot1
;	cmp.b	#2,temp
;	bne.s	YNnot2
;	PRINT	"NO"
;	jmp	YNprinted
;YNnot2
;	cmp.b	#3,temp
;	bne	YNprinted
;	move.w	prx_coor,prx_init
;	sub.w	#13,pry_coor
;	PRINT	"DRAFT"
;	CARRET
;	PRINT	"NEW"
;	CARRET
;	PRINT	"TEAM"
;	CARRET
;	CARRET
;
;	PRINT	"COSTS"
;	CARRET
;	PRINT	"4"
;	CARRET
;	PRINT	"CREDITS"
;
;	.align	2
;
;YNprinted
;	POPL	d3-d6
;
;	cmp.b	#P_FONTR1,N_PalSel+3
;	beq	YNnotbright
;	cmp.b	#P_FONTB1,N_PalSel+3
;	beq	YNnotbright
;	add.w	#3,pry_coor	;unshift selection
;YNnotbright
;	move.b	temp,d0
;	move.l	pinfo,a0
;	cmp.b	max_input+1(a0),d0
;	beq.s	YNdone
;
;	add.w	xmspace,d3	; Increment Coordinates
;	move.w	d3,prx_coor
;	jsr	curtain
;	add.b	#1,temp
;	cmp.w	#1,d5
;	dbeq	d5,YNxlp
;
;	move.w	leftside,d3
;	move.w	d3,prx_coor
;
;	jsr	curtain
;
;	move.w	ymspace,d0
;	add.w	d0,pry_coor	; Increment Coordinates
;	cmp.w	#1,d4
;	dbeq	d4,YNylp
;YNdone
;	rts



SetPalToSide
;	APALETTE	#P_FONTR2
	APALETTE	#P_NEORED
	cmp.w	#384/2,leftside
	blt.s	.p1color
;	APALETTE	#P_FONTB2
	APALETTE	#P_NEOBLU
.p1color
	rts

SetPalToSideDim	;now white

	APALETTE	#P_NEWSCORE

;	APALETTE	#P_NEORED
;	cmp.w	#384/2,leftside
;	blt.s	.p1color
;	APALETTE	#P_NEOBLU
;.p1color
	rts


ButtsOnYND
	move.l	#Enter1YND,d2
	move.l	#Enter2YND,d3

	SWITCH	#BUTTON1_1,#81H,d2
	SWITCH	#BUTTON1_2,#81H,d2
	SWITCH	#BUTTON1_3,#81H,d2
	SWITCH	#BUTTON1_4,#81H,d2
	
	SWITCH	#BUTTON2_1,#81H,d3
	SWITCH	#BUTTON2_2,#81H,d3
	SWITCH	#BUTTON2_3,#81H,d3
	SWITCH	#BUTTON2_4,#81H,d3

	rts


Enter2YND
	tst.b	done+1
	bne.s	.rts
	cmp.b	#DraftY,PlayerR+YND
	bne.s	.notdr
	jsr	TestDraftCredits	; Check If Enough Credits Available
	beq	.notenough
	jsr	TakeDraftCredits	; Check If Enough Credits Available
.notdr
	SOUND	button_sound,button_sound
	move.b	#1,done+1
	move.b	#0,firstt

	move.b	#START2,d0
	jsr	SwitchState
	move.b	d0,stst2

.notenough
.rts
	rts

Enter1YND
	tst.b	done
	bne.s	.rts
	cmp.b	#DraftY,PlayerL+YND
	bne.s	.notdr
	jsr	TestDraftCredits	; Check If Enough Credits Available
	beq	.notenough
	jsr	TakeDraftCredits	; Check If Enough Credits Available
.notdr
	SOUND	button_sound,button_sound
	move.b	#1,done
	move.b	#1,firstt

	move.b	#START1,d0
	jsr	SwitchState
	move.b	d0,stst1

.notenough
.rts
	rts

;.............................................................................

DraftInputTime	equ	60*100
;DraftInputTime	equ	100

Draft_Input
	move.w	#DraftInputTime,DraftSelTime1
	move.w	#DraftInputTime,DraftSelTime2
;	move.w	#DeadMan,TimeOut	;time to finish
	move.w	#$ffff,TimeOut	;time to finish

	jsr	setdonedraft
	cmp.w	#$ffff,done
	bne.s	do_draft

	rts
do_draft
	SOUND	#BuyInMusic,#0

	SPAWN	#dallspinner,#24	;spin ball

	jsr	ButtsOnD
	jsr	Random
	and.b	#00001111b,d0
	move.b	d0,PlayerL+Bcursor
	tst.b	done
	bne.s	.nodraft1
	move.b	d0,PlayerL+players
	clr.b	PlayerL+bat_order
	clr.l	PlayerL+bat_order+1
	clr.l	PlayerL+bat_order+5
	clr.b	PlayerL+bat_order+9
.nodraft1
	jsr	Random
	and.b	#00001111b,d0
	move.b	d0,PlayerR+Bcursor
	tst.b	done+1
	bne.s	.nodraft2
	move.b	d0,PlayerR+players
	clr.b	PlayerR+bat_order
	clr.l	PlayerR+bat_order+1
	clr.l	PlayerR+bat_order+5
	clr.b	PlayerR+bat_order+9
.nodraft2
	move.w	#NumberOfTeams-1,PlayerL+max_select
	move.w	#NumberOfTeams,PlayerL+max_input
	move.w	#NumberOfTeams-1,PlayerR+max_select
	move.w	#NumberOfTeams,PlayerR+max_input

	move.b	#players,PlayerL+Lcursor
	move.b	#players,PlayerR+Lcursor

	move.w	#0,PlayerL+cardX
	move.w	#193,PlayerR+cardX

	move.w	#0,art_offset



;	move.b	#1,start_state1
;	move.b	#1,start_state2
	move.w	#0,([HomePlayer],TEAMNUMBER) ;draft team (save first?)
	move.w	#0,([AwayPlayer],TEAMNUMBER) ;draft team (save first?)
	jsr	SetHomePal

	move.l	#Batter,a5	; Batter
	jsr	DoHeadPalette



	move.l	#Batter,a0	; Check If Batter
	move.b	#1,B_INUSE(a0)	; Set To In Use
	clr.l	WORLDX(a0)	; Set Batter World X
	clr.l	WORLDY(a0)	; Set Batter World Y

	move.w	#233,YPOSITION(a0)	; Store Starting Y Position

	move.w	#155,XPOSITION(a0)	; Store Starting X Position
	move.w	#62,ZPOSITION(a0)	; Set Z Position
	clr.b	FLIPFLAG(a0)	; Set No Flip
	move.l	#AnimDraft,UPDATEPROC(a0)	; Store Address Of Update Procedure
;	move.l	#Split,UPDATEPROC(a0)	; Store Address Of Update Procedure

	move.l	#DrDspBody,DISPLAYPROC(a0)    ; Store Address Of Display Procedure

	move.w	#b16a01,CURRENTFRAME(a0)	; Start With First Frame
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

	move.b	#P_VISTPAL00,PALETTE(a0)	; Load Palette Number

	move.b	#P_HHATPAL00,B_HEADPALETTE(a0) ;white/Blond was 03
;	move.b	#P_HEAD3D,B_HEADPALETTE(a0) ;white/Blond was 03

	move.b	#P_HOMETPAL00,B_TOPPALETTE(a0)
	move.b	#P_HOMEBPAL,B_BOTPALETTE(a0)

	move.l	#spinner,PARSEPOINTER(a0) ; Save Starting Animation Address

	move.b	#BatterTopBank,BANK(a0)	; Load Bank Number

	move.b	#1,Inning
.noObj
	move.w	#0,ButtonDelay


drLP
;	move.w	#3,leftside
;	move.w	#3,leftcside	;cursor leftside

	jsr	title_sep

	move.l	#PlayerL,a5
;	move.w	#player1,d7	;player label
	tst.b	done
	bne.s	p1done
	jsr	blit_draft

;timeout each selection
	sub.w	#1,DraftSelTime1
	bpl.s	p1done
	move.w	#DraftInputTime,DraftSelTime1
	tst.b	PlayerL+bat_order
	bne.s	p1SelBat
	jsr	Enter1D	;auto select
	bra.s	p1done
p1SelBat
	jsr	Enter1Dbat          	;auto select
p1done

	move.l	#PlayerR,a5
;	move.w	#player2,d7	;player label
	tst.b	done+1
	bne.s	p2done
	jsr	blit_draft

;timeout each selection
	sub.w	#1,DraftSelTime2
	bpl.s	p2done
	move.w	#DraftInputTime,DraftSelTime2
	tst.b	PlayerR+bat_order
	bne.s	p2SelBat
	jsr	Enter2D	;auto select
	bra.s	p2done
p2SelBat
	jsr	Enter2Dbat          	;auto select
p2done


;	move.w	P1yinc,d0	;do slide
;	add.w	d0,P1y
;	move.w	P2yinc,d0
;	add.w	d0,P2y


	jsr	TogglePage

	tst.w	ButtonDelay
	beq.s	.nodelay
	sub.w	#1,ButtonDelay
.nodelay

	jsr	finished

	bne	drLP

	jsr	ButtsOff

	cmp.b	#DraftY,PlayerL+YND	;is player drafting?
	bne.s	.notdraft1
;convert alphaorder player team numbers
	move.l	#AlphaOrder,a1
	move.w	#0,d1
.cteamlp	move.b	(players+PlayerL,d1.w),d0 ;alpha index
	ext.w	d0
	move.b	(a1,d0.w),d2	;real team number
	move.b	d2,(players+PlayerL,d1.w)
	lea	28(a1),a1	;28 teams in alphaorder line
	add.w	#1,d1	;next player position
	cmp.w	#14,d1	;14 on team
	bne.s	.cteamlp
.notdraft1

	cmp.b	#DraftY,PlayerR+YND	;is player drafting?
	bne.s	.notdraft2
;convert alphaorder player team numbers
	move.l	#AlphaOrder,a1
	move.w	#0,d1
.cteamlp2	move.b	(players+PlayerR,d1.w),d0 ;alpha index
	ext.w	d0
	move.b	(a1,d0.w),d2	;real team number
	move.b	d2,(players+PlayerR,d1.w)
	lea	28(a1),a1	;28 teams in alphaorder line
	add.w	#1,d1	;next player position
	cmp.w	#14,d1	;14 on team
	bne.s	.cteamlp2
.notdraft2

	jsr	set_rosterptr

	EXTERM	#24	;turn off spinner

	clr.b	Inning

	rts


dallspinner
	move.w	#dall0001,dallart
.nextdall	DELAY	#4
	add.w	#1,dallart
	cmp.w	#dall0030+1,dallart
	beq.s	dallspinner
	bra.s	.nextdall


AnimDraft
	jsr	Anim
	jsr	Split
	rts


	.export	blit_draft
blit_draft
	move.l	a5,pinfo

	tst.b	present(a5)
	bne.s	plpresent
;	APALETTE	#P_BALL
;	IMAGES	#Initial
;	BBLIT	#opponent,oppX(a5),#112
	rts
plpresent


;	IMAGES	#Initial
;;	APALETTE	#P_FONTY2
;	APALETTE	#P_FONTY1
;	move.w	cardX(a5),d6
;	add.w	#27,d6	;offset from card
;	BLITY	#use,d6,#225

	move.b	Lcursor(a5),d0
	and.w	#$00ff,d0	;ext to word
	sub.w	#players,d0	;get players position


;added for alpha order
	move.b	players(a5,d0.w),d1	;(get team number) now index to alpha order
	ext.w	d1
	move.b	d1,SaveIndex
	lea.l	players(a5,d0.w),a0
	move.l	a0,SaveIndexAddress
	move.w	d0,d2	;player position
	mulu	#28,d2	;28 teams per position
	move.l	d2,a1
	move.b	(AlphaOrder,a1,d1.w),(a0) ;real team number
;added for alpha order


	move.w	cardX(a5),d6
	add.w	#15,d6	;x offset from card
	move.w	#144,d7	;y was 125
	move.b	#NOTDIM,card_pal
	jsr	blit_card	;middle card
	move.b	Lcursor(a5),d5


;added for alpha order
	move.b	SaveIndex,d0
	move.b	d0,([SaveIndexAddress]) ;restore players array alpha index
;added for alpha order


;	jsr	field_pos
;field_pos
;	PUSHW	d6-d7
;	APALETTE	#P_FONTY2
	APALETTE	#P_NEOYEL

	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans ; character translation table

	move.w	cardX(a5),d6	;x offset from card
	add.w	#143,d6	;x offset from card
	PLOTY	d6,#45
	move.b	Lcursor(a5),d5
	sub.b	#players,d5
	and.w	#$00ff,d5	;ext to word
	asl.w	#2,d5	;string length 4
	move.l	#PlayerPostxt,a0	;playing position
	lea	(a0,d5.w),a0
	PRINTS	a0
;	POPW	d6-d7

;gauges
	APALETTE	#P_FONTW2

	move.w	cardX(a5),d6	;x offset from card
	sub.w	#55,d6
	move.w	#57,d7	;y was 42
	jsr	draft_statBO


	cmp.w	#9,plpos
	bge	selectingpitcher

;spining batter
;	move.l	#DrDspBody,Batter+DISPLAYPROC    ; Store Address Of Display Procedure
;	move.b	#BatterTopBank,Batter+BANK	; Load Bank Number
;	move.l	#spinner,Batter+PARSEPOINTER ; Save Starting Animation Address
;	move.w	#233,Batter+YPOSITION	; Store Starting Y Position

	move.w	cardX(a5),d6	;x offset from card
	add.w	#155,d6	;x offset from card
	move.w	d6,Batter+XPOSITION	

	move.b	Lcursor(a5),d5
	sub.b	#players,d5
	and.w	#$00ff,d5	;ext to word
	move.w	d5,BatTablePos	;for blithead

	move.b	([SaveIndexAddress]),d0 ;get team
	ext.w	d0
	move.w	d0,BatTableTeam	;for blithead

;	move.l	BatRoster,a6
	move.l	last_players_stats,a6
	move.l	a6,BatRoster

	PUSHL	a5-a6
	move.l	#Batter,a5
	jsr	DoSkinPalette
;	jsr	DoHeadPalette
	POPL	a5-a6

	clr.l	d0
	move.b	AT_weight(a6),d0
	move.w	(DBatterWidths,d0*2),Batter+XSCALE
	clr.l	d0
	move.b	AT_height(a6),d0
	move.w	(DBatterHeights,d0*2),Batter+YSCALE

	move.l	last_players_stats,a6
	move.l	a6,BatRoster

	PUSHL	a5	;preserve pinfo
	tst.b	GameMode
	beq.s	WasAttract
	jsr	Update
   	jsr	Display
WasAttract:
	POPL	a5

	bra	batballdone
selectingpitcher
;spining ball
;	move.b	#P_DALL,Batter+PALETTE	; Load Palette Number
;	move.l	#dall_spinner,Batter+PARSEPOINTER ; Save Starting Animation Address
;	move.l	#BlitObject,Batter+DISPLAYPROC    ; Store Address Of Display Procedure
;	move.b	#Title,Batter+BANK	; Load Bank Number

;	move.w	#4*(NumberOfTeams-1),(max_select,a5) ;select from all pitchers
;	move.w	#4*NumberOfTeams,(max_input,a5)

	IMAGES	#Title
	APALETTE	#P_DALL

	move.w	cardX(a5),d6
	add.w	#85,d6	;x offset from card
	BLITY	dallart,d6,#115

;pitchers name on ball
;	SETPRINT	#13,#13,#fnt1,#0
;	clr.l	FontAdjust
;	move.l	#fnt1Spacing,FontSpacing
;	move.l	#F1CharTrans,CharTrans	; character translation table
;
;	SETCLIP	#90,#0,#90+100,#256
;	move.w	cardX(a5),d6
;	add.w	dnamex(a5),d6
;	PLOTY	d6,#160
;	move.l	last_players_stats,a6
;	PRINTDECB AT_number1(a6),#1,JRGT ;jersey numbers
;	move.l	last_players_stats,a6
;	PRINTDECB AT_number2(a6),#1,JRGT ;jersey numbers
;	move.w	dnamexinc(a5),d0
;	add.w	d0,dnamex(a5)
;unfinished



	SETCLIP	#0,#0,#384,#256

batballdone


	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans ; character translation table

	tst.w	cardX(a5)
	bne.s	nop1
;	APALETTE	#P_FONTR2
;	PPRINT	#27,#2,"PLAYER 1"
	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	BLOT	#pone,#57,#3
;	BLOT	#ptwo,#248,#3
nop1	tst.w	cardX(a5)
	beq.s	nop2
;	APALETTE	#P_FONTB2
;	PPRINT	#219,#2,"PLAYER 2"
	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
;	BLOT	#pone,#57,#3
	BLOT	#ptwo,#248,#3
nop2
;players name
	cmp.w	#9,plpos
	bge	pitselect
	tst.b	bat_order(a5)
	bne	dnamedone

dnamehigh
	move.w	cardX(a5),d6
	add.w	#25,d6	;x
;	PLOTY	d6,#35	;was 29
	move.w	#35,d7
	jsr	print_dname
	jmp	dnamedone

pitselect	;name on ball
	move.w	cardX(a5),d6
	add.w	#133,d6
	PLOTY	d6,#159	;name on ball
;	jsr	print_dname
	SETPRINT	#13,#17,#neo4,#0
	clr.l	FontAdjust
	move.l	#neo4Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table

	move.l	last_players_stats,a6
	lea.l	AT_name(a6),a0	;get to name
;strip spaces for centering
	move.l	#nameram,a6
.ramit	move.b	(a0)+,d0
	beq.s	.done
	cmp.b	#' ',d0
	beq.s	.done
	move.b	d0,(a6)+
	bra.s	.ramit
.done
	clr.b	(a6)
	move.l	#nameram,a0
	PRINTC		;print centered
	jmp	dnamedone

dnamedone

	rts



print_dname
;	SETPRINT	#13,#17,#neo4,#0
;	clr.l	FontAdjust
;	move.l	#neo4Spacing,FontSpacing
;	move.l	#NeoCharTrans,CharTrans	; character translation table
;
;	move.l	last_players_stats,a6
;	lea.l	AT_name(a6),a6	;get to name
;	PRINTS	a6

	APALETTE	#P_NEWSCORE
	IMAGES	#Cards	; Load Image Bank

	move.l	last_players_stats,a6
	BLIT	AT_nameart(a6),d6,d7
	rts


DBatterWidths

Ws	equ	14	;scale factor, was 9

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

DBatterHeights

Hs	equ	10	;scale factor was 6

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


;............................................................................

	.export	spinner
spinner

spinspeed	equ	8	;was 8

	CLRFLIP

	SPRITE	b16a03,spinspeed
	SPRITE	b16a04,spinspeed	;leave for no spin
	SPRITE	b16a05,spinspeed
	SPRITE	b16a06,spinspeed
	SPRITE	b16a07,spinspeed
	SPRITE	b16a08,spinspeed
	SPRITE	b16a09,spinspeed
	SPRITE	b16a10,spinspeed
	SPRITE	b16a11,spinspeed

	SETFLIP

	SPRITE	b16a12,spinspeed
	SPRITE	b16a13,spinspeed
	SPRITE	b16a14,spinspeed
	SPRITE	b16a15,spinspeed

	SPRITE	b16a01,spinspeed
	SPRITE	b16a02,spinspeed

  	JUMP	spinner


;dallspeed	equ	3
;dall_spinner
;	SPRITE	dall0001,dallspeed
;	SPRITE	dall0002,dallspeed
;	SPRITE	dall0003,dallspeed
;	SPRITE	dall0004,dallspeed
;	SPRITE	dall0005,dallspeed
;	SPRITE	dall0006,dallspeed
;	SPRITE	dall0007,dallspeed
;	SPRITE	dall0008,dallspeed
;	SPRITE	dall0009,dallspeed
;	SPRITE	dall0010,dallspeed
;
;	SPRITE	dall0011,dallspeed
;	SPRITE	dall0012,dallspeed
;	SPRITE	dall0013,dallspeed
;	SPRITE	dall0014,dallspeed
;	SPRITE	dall0015,dallspeed
;	SPRITE	dall0016,dallspeed
;	SPRITE	dall0017,dallspeed
;	SPRITE	dall0018,dallspeed
;	SPRITE	dall0019,dallspeed
;	SPRITE	dall0020,dallspeed
;
;	SPRITE	dall0021,dallspeed
;	SPRITE	dall0022,dallspeed
;	SPRITE	dall0023,dallspeed
;	SPRITE	dall0024,dallspeed
;	SPRITE	dall0025,dallspeed
;	SPRITE	dall0026,dallspeed
;	SPRITE	dall0027,dallspeed
;	SPRITE	dall0028,dallspeed
;	SPRITE	dall0029,dallspeed
;	SPRITE	dall0030,dallspeed
;
;  	JUMP	dall_spinner


	.align	2

;***************************************************************************
;   DrDspBody - Display The Body of the batter, on the draft screen
;***************************************************************************
DrDspBody:
;	tst.b	B_INUSE(a5)	; Check If Player In Use
;	beq	DspBody_9	; Exit If Not
;
	tst.w	CURRENTFRAME(a5)	; current frame in char tables
	bmi	DspBody_9	; Branch If None

;	tst.w	SwitchReason
;	beq.s	NotBatter
;	jsr	BlitShad
;NotBatter:	
;	CLIP	OFF
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
	bne.s	DspBody_1	; Branch If Not Batter
;	jsr	BlitShadow


	cmp.w	#b16a01,CURRENTFRAME(a5)
	beq.s	.batbehind
	cmp.w	#b16a02,CURRENTFRAME(a5)
	beq.s	.batbehind
	cmp.w	#b16a03,CURRENTFRAME(a5)
	beq.s	.batbehind
	cmp.w	#b16a04,CURRENTFRAME(a5)
	beq.s	.batbehind
	cmp.w	#b16a13,CURRENTFRAME(a5)
	beq.s	.batbehind
	cmp.w	#b16a14,CURRENTFRAME(a5)
	beq.s	.batbehind
	cmp.w	#b16a15,CURRENTFRAME(a5)
	beq.s	.batbehind


;	move.b	#P_HHATPAL01,B_HEADPALETTE(a5) ;didnt work
	move.b	#P_HHATPAL00,B_HEADPALETTE(a5) ;white/Blond was 03


	jsr	BlitHead	; Display Head
	jsr	BlitBat	; Display Bat
	bra.s	.batdone
.batbehind
	jsr	BlitBat	; Display Bat


;	move.b	#P_HHATPAL01,B_HEADPALETTE(a5) ;didnt work
	move.b	#P_HHATPAL00,B_HEADPALETTE(a5) ;white/Blond was 03


	jsr	BlitHead	; Display Head
.batdone
DspBody_1:
	jsr	BlitLegs	; Display Legs
	jsr	BlitTorso	; Display Torso

;	cmp.l	#Batter,a5	; Check If Batter
;	beq.s	NoBall
;	jsr	BlitBallHand
;NoBall:
;	cmp.l	#Batter,a5	; Check If Batter
;	bne.s	DspBody_11	; Branch If Not Batter
;	jsr	BlitBNum	; Display Bat
DspBody_11:
;	CLIP	ON
	OSCALE	#$100,#$100	; Set No Scaling
	ROT_OFF
DspBody_9:
	rts

;............................................................................

blit_card		;a5=pinfo pointer  d0=player position  d6=x  d7=y

	move.b	players(a5,d0.w),d1	;get team number
	ext.w	d1

	move.w	d0,plpos	;for draft_stat label

	mulu	#attrib_size,d0	;pos*attsize
	mulu	#teamattrib_size,d1	;team*NumberOfTeamPlayers
	move.l	#ROSTERS,a6
	lea.l	(a6,d1.w),a6	;get to team
	lea.l	(a6,d0.w),a6	;get to position

blit_card2			;a6 already set, entry
	move.w	d6,tempd6
	move.w	d7,tempd7

	move.l	a6,last_players_stats ;roster address


	IMAGES	#Cards


	APALETTE	AT_cardpal+1(a6)
	cmp.b	#NOTDIM,card_pal
	beq.s	.nodim1
	APALETTE	AT_cardpal+1(a6)	;dimmed palet 
.nodim1
;	BLITY	#back0001,d6,d7

;	add.w	#5,d6	;x offset, Alan moved the art!
;	add.w	#6,d7	;y offset
	BLITY	AT_card(a6),d6,d7
;	sub.w	#5,d6	;x offset, Alan moved the art!
;	sub.w	#6,d7	;y offset
;	BLITY	#card0501,d6,d7

;	APALETTE	#P_BORDPAL
;	cmp.b	#NOTDIM,card_pal
;	beq.s	.nodim2
;	APALETTE	#P_DIMCARD
;.nodim2
;	BLITY	#border,d6,d7

;blit cards name
;	APALETTE	#P_FONTY1	;dim font
;	cmp.b	#DIM,card_pal
;	beq.s	.dimmed
;	APALETTE	#P_FONTY2
;.dimmed
;	SETPRINT	#6,#12,#fnt4,#0
;	clr.l	FontAdjust
;	move.l	#fnt4Spacing,FontSpacing
;	move.l	#F5CharTrans,CharTrans	; character translation table
;	add.w	#10,d6	;x offset from card
;	add.w	#70,d7	;y offset from card
;	PLOTY	d6,d7
;
;	move.l	last_players_stats,a6
;	lea.l	AT_name(a6),a6	;get to name
;	PRINTS	a6
;print position
;	move.w	tempd6,d6
;	move.w	tempd7,d7
;	add.w	#44,d6	;x offset from card
;	add.w	#7,d7	;y offset from card
;	PLOTY	d6,d7
;;	lea.l	AT_name(a6),a6	;get to name
;	move.w	plpos,d5
;	asl.w	#2,d5	;string length 4
;	move.l	#PlayerPostxt,a0
;	lea	(a0,d5.w),a0
;	PRINTS	a0

	move.w	tempd6,d6
	move.w	tempd7,d7

	rts

;............................................................................

blit_cardVS		;a5=pinfo pointer  d0=player position  d6=x  d7=y
           		;for versus screen flipping
	move.b	players(a5,d0.w),d1	;get team number
	ext.w	d1

	move.w	d0,plpos	;for draft_stat label

	mulu	#attrib_size,d0	;pos*attsize
	mulu	#teamattrib_size,d1	;team*NumberOfTeamPlayers
	move.l	#ROSTERS,a6
	lea.l	(a6,d1.w),a6	;get to team
	lea.l	(a6,d0.w),a6	;get to position



;all the same player
	cmp.b	#2,TeamAllSame
	bne.s	.nobut
	cmp.w	#9,plpos
	bge.s	.nobut	;not pitchers

	clr.l	d0
	move.w	TRACKX(a5),d0
	lsr.w	#4,d0	;sensetivity

	divu	#9,d0	;9 possible players to chose from
	swap	d0	;get mod

	asl.w	#2,d0	;adr index
	move.l	(ROSTERPTR,a5,d0.w),a6
	move.l	a6,ALLSAMEADR(a5)
.nobut



	move.l	a6,last_players_stats ;roster address


	APALETTE	AT_cardpal+1(a6)
;	cmp.b	#NOTDIM,card_pal
;	beq.s	.nodim1
;	APALETTE	AT_cardpal+1(a6)	;dimmed palet 
;.nodim1
;	BLITY	#back0001,d6,d7

;mod for VS
;	move.w	cardscaleX,d0
;	neg.w	d0
;	lsr.w	#3,d0
;	add.w	d0,d6
;	add.w	#30,d6


	BLITY	AT_card(a6),d6,d7

;	APALETTE	#P_BORDPAL
;;	cmp.b	#NOTDIM,card_pal
;;	beq.s	.nodim2
;;	APALETTE	#P_DIMCARD
;;.nodim2
;	sub.w	#5,d6	;x offset, Alan moved the art!
;	sub.w	#6,d7	;y offset
;	BLITY	#border,d6,d7

;;blit cards name
;;	cmp.w	#250,cardscaleX
;;	ble	.nonames
;	APALETTE	#P_FONTW1	;dim font
;	cmp.b	#DIM,card_pal
;	beq.s	.dimmed
;	APALETTE	#P_FONTW2
;.dimmed
;	SETPRINT	#6,#12,#fnt4,#0
;	clr.l	FontAdjust
;	move.l	#fnt4Spacing,FontSpacing
;	move.l	#F5CharTrans,CharTrans	; character translation table
;	add.w	#10,d6	;x offset from card
;	add.w	#70,d7	;y offset from card
;	PLOTY	d6,d7
;
;	move.l	last_players_stats,a6
;	lea.l	AT_name(a6),a6	;get to name
;	PRINTS	a6
;.nonames
	rts




draft_stat
	move.w	d6,tempd6
	move.w	d7,tempd7

	SETPRINT	#7,#8,#fnt3,#0
	clr.l	FontAdjust
;	clr.l	FontSpacing
	move.l	#fnt3Spacing,FontSpacing
	move.l	#F3CharTrans,CharTrans	; character translation table

	APALETTE	#P_FONTW2

	add.w	#70,d6	;x offset from card
	add.w	#17,d7	;y offset from card
	PLOTY	d6,d7
	cmp.w	#9,plpos
	bge	pitcher

;	PRINT	"BATTING"
	IMAGES	#neo0
	APALETTE	#P_NEWSCORE
	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#64,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0b,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#70,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0a,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#76,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0t,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#81,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0t,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#86,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0i,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#89,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0n,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#96,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0g,d6,d7


	bra	batpit
pitcher
;	PRINT	"PITCHING"
	IMAGES	#neo0
	APALETTE	#P_NEWSCORE
	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#64,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0p,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#70,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0i,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#73,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0t,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#78,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0c,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#83,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0h,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#89,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0i,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#92,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0n,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#99,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0g,d6,d7
batpit

;blit bat meter
;	APALETTE	#P_METER
	IMAGES	#Initial
;	add.w	#8,d7	;y offset from label
;	BLITY	#meterfrm,d6,d7

	move.l	last_players_stats,a0
	move.b	AT_batavg(a0),d1
;range adjust
	sub.b	#80,d1
	bcc.s	notneg
	clr.b	d1
notneg	and.w	#$00ff,d1	;ext to word

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#63,d6               ;x offset from card
	add.w	#12,d7               ;y offset from card
	add.w	d6,d1
	SETCLIP	#0,#0,d1,#256
	APALETTE	#P_BALL
	BLITY	#metergrn,d6,d7
	SETCLIP	#0,#0,#384,#256
	sub.w	#2,d6



	APALETTE	#P_FONTW2

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#2,d6
	add.w	#10,d7	;y offset from card
	PLOTY	d6,d7
	cmp.w	#9,plpos
	bge	pitcher2
;	PRINT	"POWER"
	IMAGES	#neo0
	APALETTE	#P_NEWSCORE
	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#64,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0p,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#70,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0o,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#76,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0w,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#84,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0e,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#89,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0r,d6,d7

	bra	batpit2
pitcher2
;	PRINT	"STRIKE OUTS"
;temp POWER
	IMAGES	#neo0
	APALETTE	#P_NEWSCORE
	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#64,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0p,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#70,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0o,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#76,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0w,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#84,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0e,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#89,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0r,d6,d7

batpit2

;blit power meter
;	APALETTE	#P_METER
	IMAGES	#Initial
;	add.w	#8,d7	;y offset from label
;	BLITY	#meterfrm,d6,d7

	move.l	last_players_stats,a0
	move.b	AT_power(a0),d1
;range adjust
;	sub.b	#15,d1
;	bcc.s	notneg2
;	clr.b	d1
	ext.w	d1
	move.b	(PowerRange,d1.w),d1
notneg2
	and.w	#$00ff,d1	;ext to word

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#63,d6
	add.w	#41,d7
	add.w	d6,d1
	SETCLIP	#0,#0,d1,#256
	APALETTE	#P_BALL
	BLITY	#metergrn,d6,d7
	SETCLIP	#0,#0,#384,#256
	sub.w	#2,d6


	APALETTE	#P_FONTW2

	add.w	#10,d7	;y offset from card
	PLOTY	d6,d7
;	PRINT	"SPEED"
	IMAGES	#neo0
	APALETTE	#P_NEWSCORE
	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#64,d6               ;x offset from card
	add.w	#59,d7               ;y offset from card
	BLIT	#neo0s,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#70,d6               ;x offset from card
	add.w	#59,d7               ;y offset from card
	BLIT	#neo0p,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#76,d6               ;x offset from card
	add.w	#59,d7               ;y offset from card
	BLIT	#neo0e,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#81,d6               ;x offset from card
	add.w	#59,d7               ;y offset from card
	BLIT	#neo0e,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#86,d6               ;x offset from card
	add.w	#59,d7               ;y offset from card
	BLIT	#neo0d,d6,d7


;blit speed meter
;	APALETTE	#P_METER
	IMAGES	#Initial
;	add.w	#8,d7	;y offset from label
;	BLITY	#meterfrm,d6,d7

	move.l	last_players_stats,a0
	move.b	AT_speed(a0),d1
;range adjust
	asl.b	d1
	and.w	#$00ff,d1	;ext to word

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#63,d6
	add.w	#71,d7
	add.w	d6,d1
	SETCLIP	#0,#0,d1,#256
	APALETTE	#P_BALL
	BLITY	#metergrn,d6,d7
	SETCLIP	#0,#0,#384,#256
	sub.w	#2,d6



;	APALETTE	#P_FONTGRN
;	add.w	#70,d6	;x offset from card
;	add.w	#25,d7	;y offset from card
;	PLAT	d6,d7
;	move.l	last_players_stats,a6
;	PRINTDECB AT_batavg(a6),#3,JRGT

	move.w	tempd6,d6
	move.w	tempd7,d7

	rts

PowerRange
	dc.b	01,02,03,04,04,05,06,07,07,08,09,10
	dc.b	11,12,13,14,14,15,16,17,17,18,19,20
	dc.b	21,22,23,24,24,25,26,27,27,28,29,30
	dc.b	31,32,33,34,34,35,36,37,37,38,39,40
	dc.b	41,42,43,44,44,45,46,47,47,48,49,50
	dc.b	51,52,53,54,54,55,56,57,57,58,59,60
	dc.b	61,62,63,64,64,65,66,67,67,68,69,70
	dc.b	71,72,73,74,74,75,76,77,77,78,79,80
	dc.b	81,82,83,83

;	dc.b	84,84,85,86,87,87,88,89,90
;	dc.b	01,02,03,04,04,05,06,07,07,08,09,10


	.align	2


draft_stat_draft
	move.w	d6,tempd6
	move.w	d7,tempd7

	SETPRINT	#7,#8,#fnt3,#0
	clr.l	FontAdjust
;	clr.l	FontSpacing
	move.l	#fnt3Spacing,FontSpacing
	move.l	#F3CharTrans,CharTrans	; character translation table

	APALETTE	#P_FONTW2

	add.w	#70,d6	;x offset from card
	add.w	#17,d7	;y offset from card
	PLOTY	d6,d7
	cmp.w	#9,plpos
	bge	pitcherD

;	PRINT	"BATTING"
	IMAGES	#neo0
	APALETTE	#P_NEWSCORE
	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#64,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0b,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#70,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0a,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#76,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0t,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#81,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0t,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#86,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0i,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#89,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0n,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#96,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0g,d6,d7


	bra	batpitD
pitcherD
;	PRINT	"PITCHING"
	IMAGES	#neo0
	APALETTE	#P_NEWSCORE
	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#64,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0p,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#70,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0i,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#73,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0t,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#78,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0c,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#83,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0h,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#89,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0i,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#92,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0n,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#99,d6               ;x offset from card
;	add.w	#2,d7               ;y offset from card
	BLIT	#neo0g,d6,d7
batpitD

;blit bat meter
	APALETTE	#P_NEWSCORE
	IMAGES	#Initial
	move.w	tempd6,d6
	add.w	#61,d6	;x offset from label
	move.w	tempd7,d7
	add.w	#10,d7	;y offset from label
	BLIT	#meterfrm,d6,d7

	move.l	last_players_stats,a0
	move.b	AT_batavg(a0),d1
;range adjust
	sub.b	#80,d1
	bcc.s	notnegD
	clr.b	d1
notnegD	and.w	#$00ff,d1	;ext to word

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#63,d6               ;x offset from card
	add.w	#12,d7               ;y offset from card
	add.w	d6,d1
	SETCLIP	#0,#0,d1,#256
	APALETTE	#P_BALL
	BLITY	#metergrn,d6,d7
	SETCLIP	#0,#0,#384,#256
	sub.w	#2,d6



	APALETTE	#P_FONTW2

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#2,d6
	add.w	#10,d7	;y offset from card
	PLOTY	d6,d7
	cmp.w	#9,plpos
	bge	pitcher2D
;	PRINT	"POWER"
	IMAGES	#neo0
	APALETTE	#P_NEWSCORE
	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#64,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0p,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#70,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0o,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#76,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0w,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#84,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0e,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#89,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0r,d6,d7

	bra	batpit2D
pitcher2D
;	PRINT	"STRIKE OUTS"
;temp POWER
	IMAGES	#neo0
	APALETTE	#P_NEWSCORE
	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#64,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0p,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#70,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0o,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#76,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0w,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#84,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0e,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#89,d6               ;x offset from card
	add.w	#29,d7               ;y offset from card
	BLIT	#neo0r,d6,d7

batpit2D

;blit power meter
	APALETTE	#P_NEWSCORE
	IMAGES	#Initial
	move.w	tempd6,d6
	add.w	#61,d6	;x offset from label
	move.w	tempd7,d7
	add.w	#39,d7	;y offset from label
	BLIT	#meterfrm,d6,d7

	move.l	last_players_stats,a0
	move.b	AT_power(a0),d1
;range adjust
;	sub.b	#15,d1
;	bcc.s	notneg2
;	clr.b	d1
	ext.w	d1
	move.b	(PowerRange,d1.w),d1
notneg2D
	and.w	#$00ff,d1	;ext to word

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#63,d6
	add.w	#41,d7
	add.w	d6,d1
	SETCLIP	#0,#0,d1,#256
	APALETTE	#P_BALL
	BLITY	#metergrn,d6,d7
	SETCLIP	#0,#0,#384,#256
	sub.w	#2,d6


	APALETTE	#P_FONTW2

	add.w	#10,d7	;y offset from card
	PLOTY	d6,d7
;	PRINT	"SPEED"
	IMAGES	#neo0
	APALETTE	#P_NEWSCORE
	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#64,d6               ;x offset from card
	add.w	#59,d7               ;y offset from card
	BLIT	#neo0s,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#70,d6               ;x offset from card
	add.w	#59,d7               ;y offset from card
	BLIT	#neo0p,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#76,d6               ;x offset from card
	add.w	#59,d7               ;y offset from card
	BLIT	#neo0e,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#81,d6               ;x offset from card
	add.w	#59,d7               ;y offset from card
	BLIT	#neo0e,d6,d7

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#86,d6               ;x offset from card
	add.w	#59,d7               ;y offset from card
	BLIT	#neo0d,d6,d7


;blit speed meter
	APALETTE	#P_NEWSCORE
	IMAGES	#Initial
	move.w	tempd6,d6
	add.w	#61,d6	;x offset from label
	move.w	tempd7,d7
	add.w	#69,d7	;y offset from label
	BLIT	#meterfrm,d6,d7

	move.l	last_players_stats,a0
	move.b	AT_speed(a0),d1
;range adjust
	asl.b	d1
	and.w	#$00ff,d1	;ext to word

	move.w	tempd6,d6
	move.w	tempd7,d7
	add.w	#63,d6
	add.w	#71,d7
	add.w	d6,d1
	SETCLIP	#0,#0,d1,#256
	APALETTE	#P_BALL
	BLITY	#metergrn,d6,d7
	SETCLIP	#0,#0,#384,#256
	sub.w	#2,d6



;	APALETTE	#P_FONTGRN
;	add.w	#70,d6	;x offset from card
;	add.w	#25,d7	;y offset from card
;	PLAT	d6,d7
;	move.l	last_players_stats,a6
;	PRINTDECB AT_batavg(a6),#3,JRGT

	move.w	tempd6,d6
	move.w	tempd7,d7

	rts



draft_statBO
	tst.b	bat_order(a5)
	beq	draft_stat_draft

	PUSHW	d6-d7

	SETPRINT	#7,#8,#fnt3,#0
	clr.l	FontAdjust
;	clr.l	FontSpacing
	move.l	#fnt3Spacing,FontSpacing
	move.l	#F3CharTrans,CharTrans	; character translation table
	APALETTE	#P_FONTY1

	add.w	#70,d6	;x offset from card
	add.w	#24,d7	;y offset from card
	PLOTY	d6,d7
	PUSHW	d6-d7
	PRINT	"BATTING POSITION"
	POPW	d6-d7

	SETPRINT	#12,#12,#fnt1,#0
	clr.l	FontAdjust
	clr.l	FontSpacing
;	move.l	#fnt1Spacing,FontSpacing
	move.l	#F5CharTrans,CharTrans	; character translation table

	add.w	#0,d6	;x offset from card
	add.w	#15,d7	;y offset from card
	PLOTY	d6,d7

	move.w	#-1,d7
	move.b	#1,d1
bomenu	PUSHW	d1-d6
	jsr	find_bat_pos
	beq.s	filled
	PUSHW	d7
	PRINTDECB d1,#1,JRGT	; PRINT "123456789"
	POPW	d7
	add.w	#1,d7
filled	POPW	d1-d6
	add.b	#1,d1
	cmp.b	#10,d1
	bne.s	bomenu


	move.w	d7,max_select(a5)
	add.w	#1,d7
	move.w	d7,max_input(a5)

	IMAGES	#Misc
	move.l	#PlayerL+TRACKX,a0
	move.w	#arrowa3,d1
	cmp.l	#PlayerL,a5
	beq.s	p1con
	move.l	PlayerR+TRACKX,a0
	move.w	#arrowb3,d1
p1con
	move.b	Bcursor(a5),d0
	ext.w	d0
	mulu	#12,d0	;font width
	sub.w	#8,d6	;x offset from BATTING POS. title
	add.w	d6,d0	;which side offset
	APALETTE	#P_NEWSCORE
	BBLIT	d1,d0,#105	;batting order select pointer


	POPW	d6-d7
	rts


find_bat_pos
	move.w	#1,d0
.fbpLP	cmp.b	bat_order(a5,d0.w),d1
	beq.s	.fbp_rts
     	add.w	#1,d0
	cmp.w	#10,d0
	bne.s	.fbpLP
	move.w	#1,d0	;clear z flag
.fbp_rts	rts


sel2pos
	move.b	#1,d1
.bomenu
	jsr	find_bat_pos
	beq.s	.filled
	sub.b	#1,Bcursor(a5)
	bmi.s	.done
.filled
	add.b	#1,d1
	cmp.b	#10,d1
	bne.s	.bomenu



;	trap	#1	;happens sometime with fast buttons and spinning ball
	move.w	#9,d1	;fix???


.done
	clr.b	Bcursor(a5)
	rts



	.global	GetBatterRoster,GetRoster,AtBatPlayer,AtPitPlayer
GetBatterRoster	;
	move.l	AtBatPlayer,a0
;	move.w	([AtBatPlayer],BATTERNUM),d1
	move.w	BATTERNUM(a0),d1

	move.w	#0,d0
.findbatter
	cmp.b	(BATTINGORDER+1,a0,d0.w),d1
	beq.s	.found
	add.w	#1,d0
	cmp.w	#10,d0
	bne.s	.findbatter

;	trap	#2	;batter not found trap
	move.w	#9,d0	;instead of error

.found

	move.w	d0,plpos	;for draft_stat
	move.w	d0,BatTablePos

	move.b	(PLAYERSTEAM,a0,d0.w),d1	;get team number
	ext.w	d1
	move.w	d1,BatTableTeam

	tst.l	ALLSAMEADR(a0)
	beq.s	.not_all_same
	move.l	ALLSAMEADR(a0),a0
	bra	.setadr
.not_all_same

	move.l	(ROSTERPTR,a0,d0.w*4),a0 ;instead of GetRoster for pinch hitting
;	jsr	GetRoster

.setadr
	move.l	a0,BatRoster
	move.l	a0,Batter+B_ROSTERADR	; Save In Batter Object
	rts


GetRoster	;a0=control_struct, d0.w=pos number
	;returns a0=rosterptr

	tst.l	ALLSAMEADR(a0)
	beq.s	.not_all_same
	move.l	ALLSAMEADR(a0),a0
	rts
.not_all_same
	move.w	d0,plpos	;for draft_stat
	move.w	d0,BatTablePos

	move.b	(PLAYERSTEAM,a0,d0.w),d1	;get team number
	ext.w	d1
	move.w	d1,BatTableTeam

	mulu	#attrib_size,d0	;pos*attsize
	mulu	#teamattrib_size,d1	;team*NumberOfTeamPlayers
	move.l	#ROSTERS,a0
	lea.l	(a0,d1.w),a0	;get to team
	lea.l	(a0,d0.w),a0	;get to position

;	trap	#1

	rts



Statistics
	IMAGES	#Misc
	SETPRINT	#11,#24,#neo3,#0
	clr.l	FontAdjust
	clr.l	FontSpacing
;	move.l	#neo3Spacing,FontSpacing
;	move.l	#F5CharTrans,CharTrans	; character translation table
	move.l	#NeoCharTrans,CharTrans	; character translation table

	jsr	LoadPtrs
	tst.b	START(a5)
	bne.s	.p1present
;	jsr	beg1a
	jmp	.p1done
.p1present
	tst.b	done
	bne	.p1done
;left side
	APALETTE	#P_NEWSCORE
;	BLOT	#scrn07a,#7,#5

	tst.w	PlayerL+BeatGame
	beq.s	.NoTrophy2
	APALETTE	#P_NEOYEL
.NoTrophy2


	PLAT	#147,#68
	PRINTDEC	PlayerL+stat_win,#3,JLEFT
	PLAT	#147,#89
	PRINTDEC	PlayerL+stat_lost,#3,JLEFT
	PLAT	#147,#110
;	PRINTDEC	PlayerL+stat_ba,#3,JRGT
	move.l	a5,a4
	jsr	BatAvg
	PRINTDEC	d0,#3,JLEFT
	PLAT	#147,#131
	PRINTDEC	PlayerL+stat_hits,#3,JLEFT
	PLAT	#147,#152
	PRINTDEC	PlayerL+stat_homeruns,#3,JLEFT
	PLAT	#147,#173
	PRINTDEC	PlayerL+stat_strikeouts,#3,JLEFT
.p1done
	jsr	LoadPtrs
	tst.b	START(a6)
;	beq	beg2a
	tst.b	done+1
	bne	.p2done
;right side
	APALETTE	#P_NEWSCORE
;	BLOT	#scrn07b,#201,#2

	tst.w	PlayerR+BeatGame
	beq.s	.NoTrophy3
	APALETTE	#P_NEOYEL
.NoTrophy3

	PLAT	#339,#68
	PRINTDEC	PlayerR+stat_win,#3,JLEFT
	PLAT	#339,#89
	PRINTDEC	PlayerR+stat_lost,#3,JLEFT
	PLAT	#339,#110
;	PRINTDEC	PlayerR+stat_ba,#3,JLEFT
	move.l	a6,a4
	jsr	BatAvg
	PRINTDEC	d0,#3,JLEFT
	PLAT	#339,#131
	PRINTDEC	PlayerR+stat_hits,#3,JLEFT
	PLAT	#339,#152
	PRINTDEC	PlayerR+stat_homeruns,#3,JLEFT
	PLAT	#339,#173
	PRINTDEC	PlayerR+stat_strikeouts,#3,JLEFT
.p2done
	rts

BatAvg
	move.w	stat_hits(a4),d0
;	move.w	#6,d0	;test
	mulu.w	#1000,d0	;scale up
	move.w	stat_atbats(a4),d1
	beq.s	.zero	;68000 has not learned how to divide by zero
;	move.w	#8,d1	;test
	divu.l	d1,d0	;hits divided by atbats
	rts
.zero	clr.l	d0
	rts


DEFmenu
;Defeated
	jsr	LoadPtrs
	tst.b	START(a5)
	bne.s	p1present
	jmp	p1doneDEF
p1present
	tst.b	done
	bne	p1doneDEFrts

	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	move.w	#scrn06c,d6
	cmp.b	#28,([SinglePlayer],stat_defeat)
	bge.s	.p1series
	move.w	#scrn06a,d6
.p1series
	BLOT	d6,#7,#5

	move.b	PlayerL+stat_defeat,d6
	ext.w	d6


;	move.w	PlayerL+TRACKX,d6	;test
;	lsr.w	d6


	APALETTE	#P_BALL
	IMAGES	#Initial
dlp1
	tst.w	d6
	beq.s	p1doneDEFrts
	cmp.w	#28,d6
	beq.s	p1doneDEFrts
	clr.w	d4
	clr.w	d5
	move.b	(defX,d6.w),d4
	move.b	(defY,d6.w),d5
	BLOT	#check,d4,d5
 	sub.w	#1,d6
	bra	dlp1
p1doneDEFrts
	rts
p1doneDEF

	jsr	LoadPtrs
	tst.b	START(a6)
	beq	p2doneDEF
	tst.b	done+1
	bne	p2doneDEF

	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	move.w	#scrn06d,d6
	cmp.b	#28,([SinglePlayer],stat_defeat)
	bge.s	.p2series
	move.w	#scrn06b,d6
.p2series
	BLOT	d6,#201,#2

	move.b	PlayerR+stat_defeat,d6
	ext.w	d6

	APALETTE	#P_BALL
	IMAGES	#Initial
dlp2
	tst.w	d6
	beq.s	p2doneDEF
	cmp.w	#28,d6
	beq.s	p2doneDEF
	clr.w	d4
	clr.w	d5
	move.b	(defX,d6.w),d4
	add.w	#192,d4
	move.b	(defY,d6.w),d5
	BLOT	#check,d4,d5
	sub.w	#1,d6
	bra	dlp2
p2doneDEF
	rts


defX
	dc.b	0 ;now 1 based
	dc.b	103
	dc.b	103
	dc.b	20
	dc.b	103
	dc.b	103
	dc.b	103
	dc.b	103
	dc.b	103
	dc.b	103
	dc.b	20
	dc.b	103
	dc.b	20
	dc.b	103
	dc.b	103
	dc.b	20
	dc.b	20
	dc.b	20
	dc.b	103
	dc.b	103
	dc.b	20
	dc.b	20
	dc.b	20
	dc.b	20
	dc.b	20
	dc.b	20
	dc.b	103
	dc.b	20
	dc.b	20
;series
	dc.b	59
	dc.b	71
	dc.b	60
	dc.b	60



defY
	dc.b	0 ;now 1 based
	dc.b	114
	dc.b	124
	dc.b	134
	dc.b	174
	dc.b	54
	dc.b	64
	dc.b	44
	dc.b	74
	dc.b	144
	dc.b	144
	dc.b	104
	dc.b	164
	dc.b	94
	dc.b	164
	dc.b	94
	dc.b	84
	dc.b	154
	dc.b	134
	dc.b	84
	dc.b	174
	dc.b	64
	dc.b	44
	dc.b	124
	dc.b	54
	dc.b	74
	dc.b	154
	dc.b	104
	dc.b	114
;series
	dc.b	59
	dc.b	91
	dc.b	124
	dc.b	155

	.align	2



DefeatedSeries
;	IMAGES	#Initial

	jsr	LoadPtrs
	tst.b	START(a5)
	bne.s	p1presentSER
;	jsr	beg1a
	jmp	p1doneDEFSER
p1presentSER
	tst.b	done
	bne	p1doneDEFSER

;	IMAGES	#Initial
;	APALETTE	#P_FONTW2
;	BLOT	#teamdef,#28,#18
;	APALETTE	#P_NEWSCORE

	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	BLOT	#scrn06c,#7,#5

	move.b	PlayerL+stat_defeat,d6
	ext.w	d6

;	move.w	PlayerL+TRACKX,d6	;test
;	lsr.w	d6


;	move.w	#0,d7	;loop counter & index
	IMAGES	#Initial
	APALETTE	#P_BALL
dlp1SER
	cmp.w	#28,d6	;series only
	beq	p1doneDEFSER
	clr.w	d4
	clr.w	d5
	move.b	(defX,d6.w),d4
	move.b	(defY,d6.w),d5
	BLOT	#check,d4,d5
 	sub.w	#1,d6
	bra	dlp1SER
p1doneDEFSER

	jsr	LoadPtrs
	tst.b	START(a6)
	beq	beg2a
	tst.b	done+1
	bne	p2doneDEFSER

;	IMAGES	#Initial
;	APALETTE	#P_FONTW2
;	BLOT	#teamdef,#219,#18
;	APALETTE	#P_NEWSCORE

	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	BLOT	#scrn06d,#201,#2


	move.b	PlayerR+stat_defeat,d6
	ext.w	d6

;	move.w	#0,d7	;loop counter & index
	APALETTE	#P_BALL
	IMAGES	#Initial
dlp2SER
	cmp.w	#28,d6	;series only
	beq	p2doneDEFSER
	clr.w	d4
	clr.w	d5
	move.b	(defX,d6.w),d4
	add.w	#192,d4
	move.b	(defY,d6.w),d5
	BLOT	#check,d4,d5
	sub.w	#1,d6
	bra	dlp2SER
p2doneDEFSER
	rts



Initial_Input
	move.w	#DeadMan,TimeOut	;time to finish
;	SOUND	#JerseyOpen,#0
	jsr	ButtsOn
	clr.b	PlayerL+Bcursor
	clr.b	PlayerR+Bcursor
	move.b	#letters,PlayerL+Lcursor
	move.b	#letters,PlayerR+Lcursor
	move.l	#LetterList,menuart
	move.w	#7,menu_width
	move.w	#4,menu_height
	move.w	#26,xmspace
	move.w	#26,xcmspace
	move.w	#33,ymspace
	move.w	#$41,art_offset
	move.w	#27,PlayerL+max_select
	move.w	#27,PlayerR+max_select
	move.w	#27,PlayerL+max_input
	move.w	#27,PlayerR+max_input
	move.w	#76,topside	;was 66
	move.w	#34*cusp,curtx	;should be close to 200
	jsr	setdoneYND

	move.w	#0,ButtonDelay

.IILP
	move.w	#3,leftside
	move.w	#3,leftcside

	jsr	blit_menu
	jsr	TogglePage

	tst.w	ButtonDelay
	beq.s	.nodelay
	sub.w	#1,ButtonDelay
.nodelay

	jsr	finished
	bne	.IILP


;	trap	#1


	jsr	ButtsOff
;	SOUND	#JerseyOpen,#0
	rts

Month_Input
	move.w	#DeadMan,TimeOut	;time to finish
	move.b	#SelectTeamButton,button_sound
	jsr	ButtsOnM
	clr.b	PlayerL+Bcursor
	clr.b	PlayerR+Bcursor
	move.b	#month,PlayerL+Lcursor
	move.b	#month,PlayerR+Lcursor
	move.l	#MonthList,menuart
	move.w	#3,menu_width
	move.w	#4,menu_height
	move.w	#59,xmspace
	move.w	#60,xcmspace
	move.w	#33,ymspace
	move.w	#0,art_offset
	move.w	#11,PlayerL+max_select
	move.w	#11,PlayerR+max_select
	move.w	#12,PlayerL+max_input
	move.w	#12,PlayerR+max_input
	move.w	#76,topside	;was 66
	jsr	setdoneYND
.IILP
	move.w	#8,leftside
	move.w	#18,leftcside	;cursor leftside

	jsr	blit_menu
	jsr	TogglePage

	jsr	finished
	bne	.IILP

	jsr	ButtsOff
	rts

Day_Input
	move.w	#DeadMan,TimeOut	;time to finish
	move.b	#SelectTeamButton,button_sound
	jsr	ButtsOnM
	clr.b	PlayerL+Bcursor
	clr.b	PlayerR+Bcursor
	move.b	#dayofmonth,PlayerL+Lcursor
	move.b	#dayofmonth,PlayerR+Lcursor
	move.l	#DayList,menuart
	move.w	#6,menu_width
	move.w	#6,menu_height

	move.w	#28,xmspace
	move.w	#28,xcmspace
	move.w	#26,ymspace
	move.w	#1,art_offset

	move.b	PlayerL+month,d0
	ext.w	d0
	move.l	#daycnt,a0
	move.b	(a0,d0.w),PlayerL+max_select+1
	move.b	(a0,d0.w),PlayerL+max_input+1
	add.b	#1,PlayerL+max_input+1

	move.b	PlayerR+month,d0
	ext.w	d0
	move.l	#daycnt,a0
	move.b	(a0,d0.w),PlayerR+max_select+1
	move.b	(a0,d0.w),PlayerR+max_input+1
	add.b	#1,PlayerR+max_input+1

	move.w	#59,topside
	jsr	setdoneYND
.IILP
	move.w	#3,leftside
	move.w	#3,leftcside	;cursor leftside

	jsr	blit_menu
	jsr	TogglePage

	jsr	finished
	bne	.IILP

	jsr	ButtsOff
	rts


title_sep
	IMAGES	#Title
	APALETTE	#P_TITLERB
	BLIT	#titlerb,#0,#0
	rts


blit_menu
	move.l	behind_curtain,a0
	tst.l	a0
	beq.s	.nocurt
	jsr	(a0)
.nocurt
	IMAGES	#Initial
	APALETTE	#P_BAK1APAL
	BLOT	#bakdrp3a,#180,#0
	APALETTE	#P_BAK1BPAL
	BLOT	#bakdrp3b,#0,#0

;	IMAGES	#Misc
;	APALETTE	#P_NEWSCORE
;	BLOT	#pone,#57,#3
;	BLOT	#ptwo,#248,#3

	jsr	LoadPtrs
	tst.b	START(a5)
	bne.s	.p1present
	jsr	beg1a
	jmp	player1done
.p1present
	move.l	#PlayerL,pinfo
	move.l	#LeftData,pinfodata
	tst.b	done
	bne	nomenu11
	move.l	menuart,a0
	tst.l	a0
	beq	nomenu11
	jsr	(a0)	;blit menu

	IMAGES	#Initial
	APALETTE	#P_FONTW1
;	BLOT	#use,#38,#21
	APALETTE	#P_BALL

;ball cursor
	clr.l	d0
	move.b	PlayerL+Bcursor,d0
	and.w	#$00ff,d0	;ext to word
	divu	menu_width,d0
	move.l	d0,d1
	swap	d1
	mulu	ymspace,d0
	add.w	topside,d0	;topside???
	mulu	xcmspace,d1
	add.w	leftcside,d1	;leftside???
	sub.w	#2,d1
;	BBLIT	#select1b,d1,d0

;letters
nomenu11
;	APALETTE	#P_FONTYEL
	APALETTE	#P_NEWSCORE
;	APALETTE	#P_BALL
	PLAT	#25+5,#198
	move.l	#PlayerL+letters,a0
	jsr	Pletter
	PLAT	#25+43,#198
	move.l	#PlayerL+letters+1,a0
	jsr	Pletter
	PLAT	#25+43+43-5,#198
	move.l	#PlayerL+letters+2,a0
	jsr	Pletter
;month
;	APALETTE	#P_FONTR1
;	SETPRINT	#14,#12,#fnt1,#0
;	clr.l	FontAdjust
;	move.l	#fnt1Spacing,FontSpacing
;	move.l	#F5CharTrans,CharTrans	; character translation table
	APALETTE	#P_NEWSCORE
	SETPRINT	#13,#17,#neo4,#0
	clr.l	FontAdjust
	move.l	#neo4Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table

	PLAT	#145,#207	;month pos
	move.b	PlayerL+month,d0
	ext.w	d0
	asl.w	#2,d0	;string length 4
	move.l	#Monthstxt,a0
	lea	(a0,d0.w),a0
	PRINTS	a0
;day
	PLAT	#145,#227	;day pos
	tst.b	PlayerL+dayofmonth
	beq.s	noday11
	PRINTDECB PlayerL+dayofmonth,#2,JLEFT
noday11
;cursor
	APALETTE	#P_NEWSCORE
	IMAGES	#Misc
	move.b	PlayerL+Lcursor,d3
	sub.b	#letters,d3
	cmp.b	#team-letters,d3
	bge	nolcurs11
	ext.w	d3
	asl.w	#2,d3
	move.l	#InCursXY1,a0
	move.w	(a0,d3.w),d0
	move.w	2(a0,d3.w),d1
	tst.b	done
	bne	nolcurs11
;	BBLIT	#select1b,d0,d1
	BBLIT	#arrowa3,d0,d1
nolcurs11
player1done

	jsr	LoadPtrs
	tst.b	START(a6)
	beq	beg2a

	add.w	#192+8,leftside	;leftside???
	add.w	#192+8,leftcside	;leftside???

	move.l	#PlayerR,pinfo
	move.l	#RightData,pinfodata
	tst.b	done+1
	bne	nomenu22
	move.l	menuart,a0
	tst.l	a0
	beq	nomenu22
	jsr	(a0)	;blit menu

	IMAGES	#Initial
	APALETTE	#P_FONTW1
;	BLOT	#use,#227,#21
	APALETTE	#P_BALL

;ball cursor
	clr.l	d0
	move.b	PlayerR+Bcursor,d0
	ext.w	d0
	divu	menu_width,d0
	move.l	d0,d1
	swap	d1
	mulu	ymspace,d0
	add.w	topside,d0	;topside???
	mulu	xcmspace,d1
	add.w	leftcside,d1	;leftside???
	sub.w	#2,d1
;	BBLIT	#select2b,d1,d0

nomenu22
;	APALETTE	#P_FONTYEL
	APALETTE	#P_NEWSCORE
;	APALETTE	#P_BALL
	PLAT	#25+5+192,#198
	move.l	#PlayerR+letters,a0
	jsr	Pletter
	PLAT	#25+43+192,#198
	move.l	#PlayerR+letters+1,a0
	jsr	Pletter
	PLAT	#25+43+43-5+192,#198
	move.l	#PlayerR+letters+2,a0
	jsr	Pletter
;month
;	APALETTE	#P_FONTB1
;	SETPRINT	#14,#12,#fnt1,#0
;	clr.l	FontAdjust
;	move.l	#fnt1Spacing,FontSpacing
;	move.l	#F5CharTrans,CharTrans	; character translation table
	APALETTE	#P_NEWSCORE
	SETPRINT	#13,#17,#neo4,#0
	clr.l	FontAdjust
	move.l	#neo4Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table

	PLAT	#145+192,#207	;month pos
	move.b	PlayerR+month,d0
	ext.w	d0
	asl.w	#2,d0	;string length 4
	move.l	#Monthstxt,a0
	lea	(a0,d0.w),a0
	PRINTS	a0
;day
	PLAT	#145+192,#227	;day pos
	tst.b	PlayerR+dayofmonth
	beq.s	noday22
	PRINTDECB PlayerR+dayofmonth,#2,JLEFT
noday22
;cursor
	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	move.b	PlayerR+Lcursor,d3
	sub.b	#letters,d3
	cmp.b	#team-letters,d3
	bge	nolcurs22
	ext.w	d3
	asl.w	#2,d3
	move.l	#InCursXY2,a0
	move.w	(a0,d3.w),d0
	move.w	2(a0,d3.w),d1
	tst.b	done+1
	bne	nolcurs22
	BBLIT	#arrowb3,d0,d1
nolcurs22

	APALETTE	#P_BALL

	rts


beg1a
	cmp.b	#DraftY,PlayerR+YND	;is other player drafting?
	beq.s	nobuyin1a

	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	BBLIT	#oppo,#56,#97
nobuyin1a	rts

beg2a
	cmp.b	#DraftY,PlayerL+YND	;is other player drafting?
	beq.s	nobuyin2a
	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	BBLIT	#oppo,#247,#97
nobuyin2a	rts


setdone		;set done if player is here
	clr.w	done
	jsr	LoadPtrs
	tst.b	START(a5)
	bne	.here
	move.b	#$ff,done
.here
	tst.b	START(a6)
	bne	.here2
	move.b	#$ff,done+1
.here2	rts


setdoneYND		;set done if player is here and inputting initials
	clr.w	done
	jsr	LoadPtrs
	tst.b	START(a5)
	bne	.here
	move.b	#$ff,done
.here
	cmp.b	#NoY,PlayerL+YND
	bne	.hereYND
	move.b	#$ff,done
.hereYND

	tst.b	START(a6)
	bne	.here2
	move.b	#$ff,done+1
.here2
	cmp.b	#NoY,PlayerR+YND
	bne	.hereYND2
	move.b	#$ff,done+1
.hereYND2
	rts



setdonedraft
	move.w	#$ffff,done	;don't select
;	cmp.b	#draftteam,PlayerL+team
;	bne.s	.p2

	cmp.b	#DraftY,PlayerL+YND	;is player drafting?
	bne.s	.p2

	clr.b	done	;select team if drafting
.p2
;	cmp.b	#draftteam,PlayerR+team
;	bne.s	.pdone

	cmp.b	#DraftY,PlayerR+YND	;is player drafting?
	bne.s	.pdone

	clr.b	done+1	;select team if drafting
.pdone
	rts


setdonesel
	clr.w	done
	jsr	LoadPtrs
	move.l	#PlayerL,a0
	tst.b	START(a5)
	bne	.here
	move.b	#$ff,done
	move.l	#PlayerR,a1
	jsr	setAIteam
	jmp	.p2
.here
	cmp.b	#draftteam,team(a0)
	bne.s	.p2
	move.b	#$ff,done	;don't select team if draft team
.p2
	move.l	#PlayerR,a0
	tst.b	START(a6)
	bne	.here2
	move.b	#$ff,done+1
	move.l	#PlayerL,a1
	jsr	setAIteam
	jmp	.p2d
.here2
	cmp.b	#draftteam,team(a0)
	bne.s	.p2d
	move.b	#$ff,done+1

.p2d	rts


;............................................................................
SelectTeam
	move.w	#DeadMan,TimeOut	;time to finish
	move.b	#SelectTeamButton,button_sound
	jsr	ButtsOnM
	move.b	PlayerL+team,PlayerL+Bcursor
	move.b	PlayerR+team,PlayerR+Bcursor
	move.b	#team,PlayerL+Lcursor
	move.b	#team,PlayerR+Lcursor
;	move.l	#DayList,menuart
	move.w	#7,menu_width
	move.w	#4,menu_height
;	move.w	#28,xmspace
	move.w	#53,xcmspace
	move.w	#18,ymspace
;	move.w	#1,art_offset

	move.w	#27,PlayerL+max_select
	move.w	#27,PlayerR+max_select
	move.w	#28,PlayerL+max_input
	move.w	#28,PlayerR+max_input

	move.w	#176,topside

	clr.b	stst1
	clr.b	stst2

	jsr	setdonesel

	cmp.w	#$ffff,done
	beq	.bothdrafting

	SOUND	#SelectMenuStart,#0
	SOUND	#NationalAnthem,#0

.IILP
	clr.l	d0
	move.b	PlayerL+Bcursor,d0
	ext.w	d0
	divu	menu_width,d0
	move.l	d0,d1
	swap	d1
	mulu	ymspace,d0
	add.w	topside,d0	;topside???
	mulu	xcmspace,d1
	add.w	#5,d1	;leftside???
	move.w	d1,selcx1
	move.w	d0,selcy1
;	BLOT	#select1b,d1,d0

	clr.l	d0
	move.b	PlayerR+Bcursor,d0
	ext.w	d0
	divu	menu_width,d0
	move.l	d0,d1
	swap	d1
	mulu	ymspace,d0
	add.w	topside,d0	;topside???
	mulu	xcmspace,d1
	add.w	#48,d1	;leftside???
	move.w	d1,selcx2
	move.w	d0,selcy2
;	BLOT	#select1b,d1,d0


	jsr	blit_select
	jsr	TogglePage

	jsr	finished

;	bne	.IILP
	sub.w	#1,TimeOut
	beq.s	.bothdrafting	;times-up

	tst.w	curtx	;don't curtain out
	beq	.IILP
.bothdrafting


	move.b	stst1,start_state1	;start button down?
	move.b	stst2,start_state2

	move.b	PlayerL+Bcursor,PlayerL+team
	move.b	PlayerR+Bcursor,PlayerR+team
;set players team
	cmp.b	#draftteam,PlayerL+team
	beq.s	.dt1	;don't mess with a drafted team
	move.b	PlayerL+team,d0
	move.l	#PlayerL+players,a0
	move.w	#NumberOfTeamPlayers-1,d1
.sp1	move.b	d0,(a0)+
	dbf	d1,.sp1
;set batting order
	move.w	#9,d1
	move.b	PlayerL+team,d0
	ext.w	d0
	mulu	#teamattrib_size,d0	;team*NumberOfTeamPlayers
	move.l	#ROSTERS,a6
	lea.l	(a6,d0.w),a6	;get to team
	move.l	#PlayerL+bat_order+1,a0
.sp1b	move.b	AT_order(a6),(a0)+
	lea.l	attrib_size(a6),a6	;next bbplayer
	dbf	d1,.sp1b

.dt1

;set players team
	cmp.b	#draftteam,PlayerR+team
	beq.s	.dt2	;don't mess with a drafted team
	move.b	PlayerR+team,d0
	move.l	#PlayerR+players,a0
	move.w	#NumberOfTeamPlayers-1,d1
.sp2	move.b	d0,(a0)+
	dbf	d1,.sp2
;set batting order
	move.w	#9,d1
	move.b	PlayerR+team,d0
	ext.w	d0
	mulu	#teamattrib_size,d0	;team*NumberOfTeamPlayers
	move.l	#ROSTERS,a6
	lea.l	(a6,d0.w),a6	;get to team
	move.l	#PlayerR+bat_order+1,a0
.sp2b	move.b	AT_order(a6),(a0)+
	lea.l	attrib_size(a6),a6	;next bbplayer
	dbf	d1,.sp2b
.dt2


	jsr	set_rosterptr



;	move.l	PlayerL+ROSTERPTR,d0
;	cmp.l	PlayerL+ROSTERPTR+4,d0
;	bne.s	.notrap
;	trap	#1
;.notrap
;	move.l	PlayerR+ROSTERPTR,d0
;	cmp.l	PlayerR+ROSTERPTR+4,d0
;	bne.s	.notrap2
;	trap	#1
;.notrap2



	jsr	ButtsOff

;	SOUND	#killall,#killall
	rts

;............................................................................
blit_select
	jsr	title_sep

;	IMAGES	#Initial
;	APALETTE	#P_FONTY1
;	BLIT	#select,#130,#6

	SETPRINT	#17,#22,#neo3,#0
	clr.l	FontAdjust
	move.l	#neo3Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table
	APALETTE	#P_NEOYEL
	PLOT	#130,#1
	PRINT	"SELECT TEAM"

	IMAGES	#Logos
	cmp.b	#draftteam,PlayerL+team
	beq.s	draftlogo1

	move.w	#P_LOGOBRA,d0	;first city
	add.b	PlayerL+Bcursor,d0
	APALETTE	d0
	clr.w	d0
	add.b	PlayerL+Bcursor,d0
	BLIT	d0,#10,#1
	bra	logo2
draftlogo1
	APALETTE	#P_SCOREB	;will re-use some other palette
	BLIT	#logoini,#10,#1

	APALETTE	#P_NEORED
	PLAT	#10+45,#1+22
	move.l	#PlayerL+letters,a0
	jsr	Pletter
	PLAT	#10+45+35,#1+22+15
	move.l	#PlayerL+letters+1,a0
	jsr	Pletter
	PLAT	#10+45+35+35,#1+22+15+15 ;+lr off + logo off + letter off
	move.l	#PlayerL+letters+2,a0
	jsr	Pletter

logo2
	IMAGES	#Logos
	cmp.b	#draftteam,PlayerR+team
	beq.s	draftlogo2

	move.w	#P_LOGOBRA,d0	;first city
	add.b	PlayerR+Bcursor,d0
	APALETTE	d0
	clr.w	d0
	add.b	PlayerR+Bcursor,d0
	BLIT	d0,#10+190,#1
	bra	logodone
draftlogo2
	APALETTE	#P_SCOREB	;will re-use some other palette
	BLIT	#logoini,#10+195,#1

	APALETTE	#P_NEOBLU
	PLAT	#10+45+195,#1+22
	move.l	#PlayerR+letters,a0
	jsr	Pletter
	PLAT	#10+45+35+195,#1+22+15
	move.l	#PlayerR+letters+1,a0
	jsr	Pletter
	PLAT	#10+45+35+35+195,#1+22+15+15
	move.l	#PlayerR+letters+2,a0
	jsr	Pletter
logodone

	IMAGES	#Initial
;labels
	APALETTE	#P_FONTY1	;was W2
	BLIT	#attribs,#169,#122


	SETPRINT	#7,#8,#fnt3,#0
	clr.l	FontAdjust
	clr.l	FontSpacing
;	move.l	#fnt2Spacing,FontSpacing
	move.l	#F3CharTrans,CharTrans	; character translation table

;blit meters
	move.l	#PlayerL,pinfo
	move.w	#48+2,clipX

	APALETTE	#P_NEWSCORE
	BLIT	#meterfrm,#48,#121
	move.w	#0,d1
	jsr	setclip
	BLIT	#metergrn,#48+2,#121+2
	SETCLIP	#0,#0,#384,#256

	APALETTE	#P_FONTR2
	PLOT	#143,#122
	PRINTDECB temp,#2,JRGT
	jsr	printsuffix


	APALETTE	#P_NEWSCORE
	BLIT	#meterfrm,#48,#131
	move.w	#3,d1
	jsr	setclip
	BLIT	#metergrn,#48+2,#131+2
	SETCLIP	#0,#0,#384,#256

	APALETTE	#P_FONTR2
	PLOT	#143,#132
	PRINTDECB temp,#2,JRGT
	jsr	printsuffix


	APALETTE	#P_NEWSCORE
	BLIT	#meterfrm,#48,#141
	move.w	#2,d1
	jsr	setclip
	BLIT	#metergrn,#48+2,#141+2
	SETCLIP	#0,#0,#384,#256

	APALETTE	#P_FONTR2
	PLOT	#143,#142
	PRINTDECB temp,#2,JRGT
	jsr	printsuffix


	APALETTE	#P_NEWSCORE
	BLIT	#meterfrm,#48,#151
	move.w	#1,d1
	jsr	setclip
	BLIT	#metergrn,#48+2,#151+2
	SETCLIP	#0,#0,#384,#256

	APALETTE	#P_FONTR2
	PLOT	#143,#152
	PRINTDECB temp,#2,JRGT
	jsr	printsuffix


	APALETTE	#P_NEWSCORE
	BLIT	#meterfrm,#48,#161
	move.w	#4,d1
	jsr	setclip
	BLIT	#metergrn,#48+2,#161+2
	SETCLIP	#0,#0,#384,#256

	APALETTE	#P_FONTR2
	PLOT	#143,#162
	PRINTDECB temp,#2,JRGT
	jsr	printsuffix



p2stat	equ	72+10
p2gx	equ	195+10

	move.l	#PlayerR,pinfo
	move.w	#48+p2gx+85,clipX

	APALETTE	#P_NEWSCORE
	BLIT	#meterfrm,#48+p2gx,#121
	move.w	#0,d1
	jsr	setclip2
	BLIT	#metergrn,#48+2+p2gx,#121+2
	SETCLIP	#0,#0,#384,#256

	APALETTE	#P_FONTB2
	PLOT	#144+p2stat,#122
	PRINTDECB temp,#2,JRGT
	jsr	printsuffix


	APALETTE	#P_NEWSCORE
	BLIT	#meterfrm,#48+p2gx,#131
	move.w	#3,d1
	jsr	setclip2
	BLIT	#metergrn,#48+2+p2gx,#131+2
	SETCLIP	#0,#0,#384,#256

	APALETTE	#P_FONTB2
	PLOT	#144+p2stat,#132
	PRINTDECB temp,#2,JRGT
	jsr	printsuffix


	APALETTE	#P_NEWSCORE
	BLIT	#meterfrm,#48+p2gx,#141
	move.w	#2,d1
	jsr	setclip2
	BLIT	#metergrn,#48+2+p2gx,#141+2
	SETCLIP	#0,#0,#384,#256

	APALETTE	#P_FONTB2
	PLOT	#144+p2stat,#142
	PRINTDECB temp,#2,JRGT
	jsr	printsuffix


	APALETTE	#P_NEWSCORE
	BLIT	#meterfrm,#48+p2gx,#151
	move.w	#1,d1
	jsr	setclip2
	BLIT	#metergrn,#48+2+p2gx,#151+2
	SETCLIP	#0,#0,#384,#256

	APALETTE	#P_FONTB2
	PLOT	#144+p2stat,#152
	PRINTDECB temp,#2,JRGT
	jsr	printsuffix


	APALETTE	#P_NEWSCORE
	BLIT	#meterfrm,#48+p2gx,#161
	move.w	#4,d1
	jsr	setclip2
	BLIT	#metergrn,#48+2+p2gx,#161+2
	SETCLIP	#0,#0,#384,#256

	APALETTE	#P_FONTB2
	PLOT	#144+p2stat,#162
	PRINTDECB temp,#2,JRGT
	jsr	printsuffix



;blit city names
	clr.b	temp

	move.w	#180,pry_coor

	move.w	#3,d6	;height-1
.ylp	move.w	#6,d7	;width-1
	move.w	#6,prx_coor	;leftside
.xlp
	move.w	pry_coor,d1
;	APALETTE	#P_FONTDPAL
	APALETTE	#P_BALL
	move.b	temp,d0
	cmp.b	PlayerL+Bcursor,d0
	beq	.highlight
	cmp.b	PlayerR+Bcursor,d0
	bne	.dim
.highlight	APALETTE	#P_BALL
	sub.w	#2,d1	;shift selected char up
.dim
	cmp.b	#15,temp
	bne.s	.noshift
	add.w	#2,prx_coor	;space between Milwaukee & Minn.
.noshift
	ext.w	d0
	add.w	#citybra,d0	;first city name
	BLIT	d0,prx_coor,d1

	add.w	#53,prx_coor
	add.b	#1,temp
	dbf	d7,.xlp

	add.w	#18,pry_coor	; Increment Coordinates
	dbf	d6,.ylp

	APALETTE	#P_NEWSCORE
	IMAGES	#Misc
;	BLOT	#cities,#8,#182

	cmp.b	#draftteam,PlayerL+team
	beq.s	.nosel1
	BBLITO	#arrowa4,selcx1,selcy1
	tst.b	done
	beq.s	.nosel1
	BLIT	#arrowa4,selcx1,selcy1 ;stop blinking
.nosel1
	cmp.b	#draftteam,PlayerR+team
	beq.s	.nosel2
	BBLITO	#arrowb2,selcx2,selcy2
	tst.b	done+1
	beq.s	.nosel2
	BLIT	#arrowb2,selcx2,selcy2 ;stop blinking
.nosel2

;	jsr	SetSysFont
;	APALETTE	#0
;	PLAT	#10,#16
;	PRINTHEX	#PlayerR+TRACKX,#2
;	PLAT	#50,#16
;	PRINTHEX	#PlayerR+TRACKY,#2
;	PLAT	#10,#30
;	PRINTHEX	#PlayerL+TRACKX,#2
;	PLAT	#50,#30
;	PRINTHEX	#PlayerL+TRACKY,#2
;
;	PLAT	#20,#50
;	PRINTHEX	#PLYRIN4+1,#2
;	PLAT	#60,#50
;	PRINTHEX	#PLYRIN4+2,#2

	rts


set_rosterptr
;make PLAYERSTEAM current with players (players and PLAYERSTEAM are redundant)
	move.l	PlayerL+players,PlayerL+PLAYERSTEAM
	move.l	PlayerL+players+4,PlayerL+PLAYERSTEAM+4
	move.l	PlayerL+players+8,PlayerL+PLAYERSTEAM+8
	move.w	PlayerL+players+12,PlayerL+PLAYERSTEAM+12

	move.l	PlayerR+players,PlayerR+PLAYERSTEAM
	move.l	PlayerR+players+4,PlayerR+PLAYERSTEAM+4
	move.l	PlayerR+players+8,PlayerR+PLAYERSTEAM+8
	move.w	PlayerR+players+12,PlayerR+PLAYERSTEAM+12
AtSetRoster
;set roster addresses for all players
	move.w	#0,d2
.rosterPL	move.w	d2,d0
	move.l	#PlayerL,a0
	jsr	GetRoster
	move.l	#PlayerL+ROSTERPTR,a1
	move.l	a0,(a1,d2.w*4)
	add.w	#1,d2
	cmp.w	#14,d2
	bne.s	.rosterPL

	move.w	#0,d2
.rosterPR	move.w	d2,d0
	move.l	#PlayerR,a0
	jsr	GetRoster
	move.l	#PlayerR+ROSTERPTR,a1
	move.l	a0,(a1,d2.w*4)
	add.w	#1,d2
	cmp.w	#14,d2
	bne.s	.rosterPR
	rts


;***************************************************************************
NEWvs

	cmp.w	#29,FreeBee
	beq	.SayTeams
	cmp.w	#30,FreeBee
	beq	.SayTeams
	cmp.w	#31,FreeBee
	bne	.noSayTeams
.SayTeams	move.b	([AwayPlayer],team),d1
	SOUND	#SetAwayTeam,d1
	move.b	([HomePlayer],team),d1
	SOUND	#SetHomeTeam,d1
	SOUND	#Intro,#Intro
.noSayTeams


	clr.w	done
	clr.w	SoundOnce

	SWITCH	#BUTTON1_1,#81H,#NEWabort
	SWITCH	#BUTTON1_2,#81H,#NEWabort
	SWITCH	#BUTTON1_3,#81H,#NEWabort
	SWITCH	#BUTTON1_4,#81H,#NEWabort

	SWITCH	#BUTTON2_1,#81H,#NEWabort
	SWITCH	#BUTTON2_2,#81H,#NEWabort
	SWITCH	#BUTTON2_3,#81H,#NEWabort
	SWITCH	#BUTTON2_4,#81H,#NEWabort

	move.w	#30*7,vstime	;timeout was 6

NEWIILP

	jsr	NewVSBlit

	jsr	TogglePage


	sub.w	#1,vstime
	beq.s	NEWvstimeout

	cmp.w	#$0101,done
	bne	NEWIILP


NEWvstimeout
	jsr	ButtsOff

	rts

NEWabort
	move.w	#$0101,done
	SOUND	button_sound,button_sound
	rts

;***************************************************************************

NewVSBlit

;	IMAGES	#Title
;	APALETTE	#P_TITLERB
;	BLIT	#pinrb,#0,#0

new09	equ	30+15

	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	BLIT	#scrn09,#0,#2


	APALETTE	#P_LOGOLEFT
	IMAGES	#Logos

	SETPRINT	#17,#22,#neo3,#0
	clr.l	FontAdjust
	move.l	#neo3Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table

	cmp.b	#draftteam,PlayerL+team
	beq.s	NEWdraftlogo1

	tst.w	FreeBee
	beq	NoAllStars1

	cmp.l	#PlayerL,LosingPlayer
	bne	NoAllStars1

	PLOT	#95,#67+46
	move.w	#9,d0
	move.w	#67,d1
	jsr	PrintAllStarLogo
	bra	NEWlogo2

NoAllStars1
	clr.w	d0
	add.b	PlayerL+team,d0
	BLIT	d0,#9,#67
	bra	NEWlogo2

NEWdraftlogo1
	APALETTE	#P_SCOREB	;will re-use some other palette
	BLIT	#logoini,#9,#67

	APALETTE	#P_NEORED
	PLAT	#10+45,#20+22+new09
	move.l	#PlayerL+letters,a0
	jsr	Pletter
	PLAT	#10+45+35,#20+22+15+new09
	move.l	#PlayerL+letters+1,a0
	jsr	Pletter
	PLAT	#10+45+35+35,#20+22+15+15+new09 ;+lr off + logo off + letter off
	move.l	#PlayerL+letters+2,a0
	jsr	Pletter

NEWlogo2
	APALETTE	#P_LOGORIGHT
	IMAGES	#Logos

	cmp.b	#draftteam,PlayerR+team
	beq.s	NEWdraftlogo2

	tst.w	FreeBee
	beq	NoAllStars2

	cmp.l	#PlayerR,LosingPlayer
	bne	NoAllStars2

	PLOT	#290,#67+46
	move.w	#205,d0
	move.w	#67,d1
	jsr	PrintAllStarLogo
	bra	NEWlogodone

NoAllStars2
	clr.w	d0
	add.b	PlayerR+team,d0
	BLIT	d0,#205,#67
	bra	NEWlogodone
NEWdraftlogo2
	APALETTE	#P_SCOREB	;will re-use some other palette
	BLIT	#logoini,#205,#67

	APALETTE	#P_NEOBLU
	PLAT	#10+45+195,#20+22+new09
	move.l	#PlayerR+letters,a0
	jsr	Pletter
	PLAT	#10+45+35+195,#20+22+15+new09
	move.l	#PlayerR+letters+1,a0
	jsr	Pletter
	PLAT	#10+45+35+35+195,#20+22+15+15+new09
	move.l	#PlayerR+letters+2,a0
	jsr	Pletter
NEWlogodone

;series logo or vs
	move.l	SinglePlayer,d1
	beq	printVS
	tst.w	FreeBee
	bne	printVS	;not if free game

	cmp.b	#31,([SinglePlayer],stat_defeat)
	bne	NotWorld

	APALETTE	#P_LOGOWOR
	IMAGES	#Logos
	BLIT	#logowor,#109,#114 ;world series logo

	bra	LogoVsDone
NotWorld
	cmp.b	#28,([SinglePlayer],stat_defeat)
	blt	printVS

	APALETTE	#P_LOGOWOR	;re-use if not the same!
	IMAGES	#Logos
	BLIT	#logocha,#105,#114	;championship series logo

;	APALETTE	#P_FONTY1
;	SETPRINT	#13,#13,#fnt1,#0
;	clr.l	FontAdjust
;	move.l	#fnt1Spacing,FontSpacing
;	move.l	#F1CharTrans,CharTrans	; character translation table
;	PPRINT	#85,#150,"CHAMPIONSHIP SERIES"

	bra	LogoVsDone
printVS
;	SETPRINT	#31,#46,#neo1,#0
;	clr.l	FontAdjust
;	clr.l	FontSpacing ; Non-Proportional Spacing
;	move.l	#NeoCharTrans,CharTrans ; character translation table
;
;	APALETTE	#P_NEWSCORE
;	PLAT	#170,#145
;	PRINT	"VS"

LogoVsDone

;series scores
;	SETPRINT	#49,#30,#fnt5,#0
;	clr.l	FontAdjust
;	move.l	#fnt5Spacing,FontSpacing ; Non-Proportional Spacing
;	move.l	#BIGCharTrans,CharTrans ; character translation table
;	APALETTE	#P_FONTY1

	SETPRINT	#31,#46,#neo1,#0
	clr.l	FontAdjust
;	move.l	#neo1Spacing,FontSpacing ; Non-Proportional Spacing
	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table

	APALETTE	#P_NEOYEL

	PLAT	#87,#209
	move.l	SinglePlayer,d1
	beq	NotSingle

	cmp.b	#28,([SinglePlayer],stat_defeat)
	blt	NoSeries

	tst.w	FreeBee
	bne	NoSeries	;not if free game

	move.b	([SinglePlayer],seriesCNT),d0
	sub.b	([SinglePlayer],winCNT),d0
	cmp.l	#PlayerL,d1
	bne.s	LeftIsComp
	move.b	([SinglePlayer],winCNT),d0 ;left is human
	move.b	d0,Lseries
LeftIsComp
	ext.w	d0
	PRINTDEC d0,#1,JRGT

;	SETPRINT	#16,#24,#fnt2,#0
;	clr.l	FontAdjust
;	move.l	#fnt2Spacing,FontSpacing
;	move.l	#F2CharTrans,CharTrans ; character translation table
;	APALETTE	#P_FONTY1

	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing ; Non-Proportional Spacing
;	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEWSCORE
	PLAT	#153,#193
	PRINT	"GAMES"
	PLAT	#169,#215
	PRINT	"WON"
;right side
;	SETPRINT	#49,#30,#fnt5,#0
;	clr.l	FontAdjust
;	move.l	#fnt5Spacing,FontSpacing ; Non-Proportional Spacing
;	move.l	#BIGCharTrans,CharTrans ; character translation table

	SETPRINT	#31,#46,#neo1,#0
	clr.l	FontAdjust
;	move.l	#neo1Spacing,FontSpacing ; Non-Proportional Spacing
	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table

	APALETTE	#P_NEOYEL

	PLAT	#283,#209
	move.b	([SinglePlayer],seriesCNT),d0
	sub.b	([SinglePlayer],winCNT),d0
	move.l	SinglePlayer,d1
	cmp.l	#PlayerR,d1
	bne.s	RightIsComp
	move.b	([SinglePlayer],winCNT),d0 ;right is human
	move.b	d0,Rseries
RightIsComp
	ext.w	d0
	PRINTDEC d0,#1,JRGT

	tst.w	SoundOnce
	bne.s	.sdone
	move.w	#1,SoundOnce	;for only 1 sound call

	move.b	Rseries,d0
	cmp.b	Lseries,d0
	beq.s	.tie
	blt.s	.Lwin
	SOUND	#LeadSeries,PlayerR+team
	bra	.sdone
.Lwin	SOUND	#LeadSeries,PlayerL+team

.tie
	tst.b	Lseries
	bne.s	.sdone
	tst.b	Rseries
	bne.s	.sdone
	tst.l	SinglePlayer
	beq.s	.sdone
	cmp.b	#31,([SinglePlayer],stat_defeat)
	bne.s	.sdone
	SOUND	#StartWorldSeries,#0
.sdone

NotSingle
NoSeries

	rts

;***************************************************************************

PrintAllStarLogo

	APALETTE	#P_SCOREB	;will re-use some other palette
	BLIT	#logoini,d0,d1


;	APALETTE	#P_FONTY2
	APALETTE	#P_NEWSCORE

	cmp.w	#29,FreeBee
	bne	.notA
	move.l	#.ame,a0
	PRINTC
	move.w	prx_init,prx_coor
	add.w	#17,pry_coor
	move.l	#.leg,a0
	PRINTC
	move.w	prx_init,prx_coor
	add.w	#17,pry_coor
	move.l	#.all,a0
	PRINTC
	move.b	#"A",([LosingPlayer],letters)
	move.b	#" ",([LosingPlayer],letters+1)
	move.b	#"L",([LosingPlayer],letters+2)

	bra	.NotComp
.notA
	cmp.w	#30,FreeBee
	bne	.notN
	move.l	#.nat,a0
	PRINTC
	move.w	prx_init,prx_coor
	add.w	#17,pry_coor
	move.l	#.leg,a0
	PRINTC
	move.w	prx_init,prx_coor
	add.w	#17,pry_coor
	move.l	#.all,a0
	PRINTC
	move.b	#"N",([LosingPlayer],letters)
	move.b	#" ",([LosingPlayer],letters+1)
	move.b	#"L",([LosingPlayer],letters+2)

	bra	.NotComp
.notN
;	cmp.w	#30,FreeBee
;	bne	.notN
	move.l	#.des,a0
	PRINTC
	move.w	prx_init,prx_coor
	add.w	#17,pry_coor
	move.l	#.tea,a0
	PRINTC
	move.b	#"W",([LosingPlayer],letters)
	move.b	#"M",([LosingPlayer],letters+1)
	move.b	#"S",([LosingPlayer],letters+2)
 
.NotComp
	rts

.ame	dc.b	"AMERICAN",0
.leg	dc.b	"LEAGUE",0
.all	dc.b	"ALL STARS",0

.nat	dc.b	"NATIONAL",0

.des	dc.b	"DESIGN",0
.tea	dc.b	"TEAM",0

	.align	2

;***************************************************************************
;CameraProc
;;	sub.l	#120*1092,CameraX	;pan speed, 1092 = 1 pixel per sec
;	sub.w	#4,CameraX
;	bpl.s	.nomin
;	clr.w	CameraX
;;	jsr	DeallocObject
;.nomin
;	DELAY	#1
;	jmp	CameraProc

;***************************************************************************


VSscreen
	clr.b	VScnt

	move.l	AwayPlayer,pinfo	;start with away player

	move.b	([AwayPlayer],team),d1
	SOUND	#SetAwayTeam,d1
	move.b	([HomePlayer],team),d1
	SOUND	#SetHomeTeam,d1
	SOUND	#Intro,#Intro

;	SOUND	#NationalAnthem,#0


	clr.l	PlayerL+ALLSAMEADR
	clr.l	PlayerR+ALLSAMEADR
VSscreen2

;	tst.l	SinglePlayer
;	bne.s	.NotIfSingle
;	SWITCH	#BUTTON1_5,#81H,#WholeTeam
;	SWITCH	#BUTTON2_5,#81H,#WholeTeam
;.NotIfSingle

	jsr	SetDoneVS
	clr.b	TeamAllSame
	move.b	#SelectTeamButton,button_sound
	jsr	ButtsOnVS
;	move.b	#10,PlayerR+Bcursor
;;	move.b	PlayerR+team,PlayerR+Bcursor
;	move.b	#team,PlayerL+Lcursor ;TURN OFF BALLSERVICE CURSOR
;	move.b	#team,PlayerR+Lcursor
;;	move.b	#first_pitcher,PlayerL+Lcursor ;the ball changes this location
;;	move.b	#first_pitcher,PlayerR+Lcursor ;the ball changes this location
;;	move.b	#first_pitcher,PlayerR+Lcursor
;;	move.l	#DayList,menuart
;	move.w	#5,menu_width
;	move.w	#3,menu_height
;;	move.w	#28,xmspace
;	move.w	#75,xcmspace
;	move.w	#83,ymspace
;;	move.w	#1,art_offset
;
;	clr.b	tb_moved
;
;	move.w	#13,PlayerL+max_select
;	move.w	#13,PlayerR+max_select
;	move.w	#14,PlayerL+max_input
;	move.w	#14,PlayerR+max_input
;
;	move.w	#35,topside
;
;	move.w	#256,cardscaleY
;	move.w	#1,cardscaleX
;	move.w	#4,cscaledir	;scaling direction and speed

	move.w	#70,vstime	;timeout

.IILP
;	clr.l	d0
;	move.b	PlayerL+Bcursor,d0
;	ext.w	d0
;	divu	menu_width,d0
;	move.l	d0,d1
;	swap	d1
;	mulu	ymspace,d0
;	add.w	topside,d0	;topside???
;	mulu	xcmspace,d1
;;	add.w	#0,d1	;leftside???
;	move.w	d1,selcx1
;	move.w	d0,selcy1
;;	BLOT	#select1b,d1,d0
;
;	clr.l	d0
;	move.b	PlayerR+Bcursor,d0
;	ext.w	d0
;	divu	menu_width,d0
;	move.l	d0,d1
;	swap	d1
;	mulu	ymspace,d0
;	add.w	topside,d0	;topside???
;	mulu	xcmspace,d1
;	add.w	#58,d1	;leftside???
;	move.w	d1,selcx2
;	move.w	d0,selcy2
;;	BLOT	#select1b,d1,d0


;	tst.w	CameraX
;	bpl.s	.nomin
;	add.w	#16,CameraX
;.nomin

	jsr	blit_VSscreen
	jsr	TogglePage

	jsr	LoadPtrs
	move.l	#PlayerL,a0
	tst.b	START(a5)
	beq.s	.ai
.here
	move.l	#PlayerR,a0
	tst.b	START(a6)
	bne.s	.here2
.ai
	cmp.l	pinfo,a0
	bne.s	.here2
	jsr	setAIpitcher
	DELAY	#50
.here2

;	jsr	finished
;	bne	.IILP
;	tst.w	curtx	;don't curtain out
;	beq	.IILP

	sub.w	#1,vstime
	beq.s	.vstimeout

;	move.b	done,d0
;	cmp.l	#PlayerL,pinfo
;	beq.s	.p1up
;	move.b	done+1,d0
;.p1up	tst.w	d0
;	beq	.IILP

	cmp.w	#$0101,done
	bne	.IILP


.vstimeout
;switch vs screen

	add.b	#1,VScnt
	cmp.b	#2,VScnt
	beq	vsdone
	jsr	MakeSame
	move.l	HomePlayer,pinfo	;next player


;	move.w	#252,cardscaleX
;	move.w	#-4,cscaledir	;scaling direction and speed

	move.w	#30,vstime	;VS duration
VSswitch
;	jsr	blit_VSscreen
	jsr	title_sep

	IMAGES	#Misc
	APALETTE	#P_TITLEBLU
	BLIT	#vs,#130,#60
;	SETPRINT	#31,#46,#neo1,#0
;	clr.l	FontAdjust
;	move.l	#neo1Spacing,FontSpacing ; Non-Proportional Spacing
;	move.l	#NeoCharTrans,CharTrans ; character translation table
;	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals
;	PLOT	#170,#100
;	PRINT	"VS"

	jsr	TogglePage
	sub.w	#1,vstime
	bne.s	VSswitch
;	cmp.w	#4,cardscaleX
;	bgt.s	VSswitch	;wait till very small

;	clr.b	done+1	;enable player 2 buttons

	bra	VSscreen2	;go do player 2 pitcher select

vsdone
	jsr	MakeSame

;	move.b	PlayerL+Bcursor,d0
;	sub.b	#1,d0	;zero based now
;	move.b	d0,PlayerL+first_pitcher
;
;	move.b	PlayerR+Bcursor,d0
;	sub.b	#1,d0	;zero based now
;	move.b	d0,PlayerR+first_pitcher

	move.b	#9,PlayerL+first_pitcher
	move.b	#9,PlayerR+first_pitcher

	jsr	ButtsOff
	SWITCH	#BUTTON1_5,#81H,#0	;turn off switch
	SWITCH	#BUTTON2_5,#81H,#0

	rts


WholeTeam
	add.b	#1,TeamAllSame
	cmp.b	#2,TeamAllSame
	bne.s	.rts
	SWITCH	#BUTTON1_5,#81H,#0	;turn off switch
	SWITCH	#BUTTON2_5,#81H,#0
	move.w	#500,vstime	;more time to pick same guy
.rts	rts


SetDoneVS
	cmp.l	#PlayerL,pinfo
	beq.s	.leftok
	clr.b	done+1
	move.b	#1,done
	bra	.lrdone
.leftok
	clr.b	done
	move.b	#1,done+1
.lrdone
	rts


MakeSame
	cmp.b	#2,TeamAllSame
	bne.s	NotSame
	move.l	pinfo,a0
	lea	players(a0),a1
	move.b	AllSameTeam,d0
	move.b	d0,(a1)+	;1
	move.b	d0,(a1)+	;
	move.b	d0,(a1)+	;
	move.b	d0,(a1)+	;
	move.b	d0,(a1)+	;
	move.b	d0,(a1)+	;
	move.b	d0,(a1)+	;
	move.b	d0,(a1)+	;
	move.b	d0,(a1)+	;
;	move.b	d0,(a1)+	;
;	move.b	d0,(a1)+	;
;	move.b	d0,(a1)+	;
;	move.b	d0,(a1)+	;
;	move.b	d0,(a1)+	;14

	lea	ROSTERPTR(a0),a1
	move.l	ALLSAMEADR(a0),d0
	move.l	d0,(a1)+	;1
	move.l	d0,(a1)+	;
	move.l	d0,(a1)+	;
	move.l	d0,(a1)+	;
	move.l	d0,(a1)+	;
	move.l	d0,(a1)+	;
	move.l	d0,(a1)+	;
	move.l	d0,(a1)+	;
	move.l	d0,(a1)+	;
;	move.l	d0,(a1)+	;
;	move.l	d0,(a1)+	;
;	move.l	d0,(a1)+	;
;	move.l	d0,(a1)+	;
;	move.l	d0,(a1)+	;14
NotSame
	rts


blit_VSscreen
	jsr	title_sep

;	IMAGES	#Initial
;	APALETTE	#P_TTLSE
;	BLIT	#titlesep,#0,#0

;	APALETTE	#P_BALL
	APALETTE	#P_FONTW2

;	BLOT	#player1,#57,#3
;	BLOT	#player2,#248,#3

;	BLIT	#select,#138,#6

	tst.b	tb_moved
	bne	nohelp
	tst.b	blinker
	beq	nologo

;	SETPRINT	#7,#8,#fnt3,#0
;	clr.l	FontAdjust
;;	clr.l	FontSpacing
;	move.l	#fnt3Spacing,FontSpacing
;	move.l	#F3CharTrans,CharTrans	; character translation table

;	PLOT	#155,#100
;	cmp.l	#PlayerL,pinfo
;	bne.s	label2
;	PRINT	"PLAYER 1"
;	bra	labeldone
;label2	PRINT	"PLAYER 2"
;labeldone	CARRET
;	PRINT	" CHOOSE"
;	CARRET
;	PRINT	"STARTING"
;	CARRET
;	PRINT	"PITCHER"
;	bra	nologo
nohelp


;	move.l	pinfo,a4
;	cmp.b	#draftteam,team(a4)
;	beq.s	vsdrlogo
;
;	IMAGES	#Logos
;	move.w	#P_LOGOBRA,d0	;first city
;	move.l	pinfo,a4
;	add.b	team(a4),d0
;	APALETTE	d0
;	OSCALE	#$8a,#$8a
;	clr.w	d0
;	move.b	team(a4),d0
;	BLIT	d0,#139,#91	;logo
;	OSCALE	#$100,#$100	;reset OSCALE
;	ROT_OFF		;reset OSCALE
;	bra	vslogodone
;vsdrlogo
;	APALETTE	#P_FONTYEL
;	OSCALE	#$8a,#$8a
;	PLAT	#175,#100
;	move.l	pinfo,a0
;	jsr	Pletter
;	PLAT	#175+15,#100+15
;	move.l	pinfo,a0
;	lea	1(a0),a0
;	jsr	Pletter
;	PLAT	#175+15+15,#100+15+15
;	move.l	pinfo,a0
;	lea	2(a0),a0
;	jsr	Pletter
;	OSCALE	#$100,#$100	;reset OSCALE
;	ROT_OFF		;reset OSCALE
;
;vslogodone


	move.w	#71,d6	;x
	move.w	#80,d7	;y
	move.w	#9,plpos	;it's a pitcher


;calc attrib address
	move.l	pinfo,a5
	move.b	Bcursor(a5),d0
	sub.b	#1,d0
	ext.w	d0
	move.w	d0,plpos	;for draft_stat label

	move.b	players(a5,d0.w),d1	;get team number
	ext.w	d1

	mulu	#attrib_size,d0	;pos*attsize
	mulu	#teamattrib_size,d1	;team*NumberOfTeamPlayers
	move.l	#ROSTERS,a6
	lea.l	(a6,d1.w),a6	;get to team
	lea.l	(a6,d0.w),a6	;get to position
	move.l	a6,last_players_stats

;	jsr	draft_stat

nologo


;	SETPRINT	#7,#8,#fnt3,#0
;	clr.l	FontAdjust
;	clr.l	FontSpacing
;;	move.l	#fnt2Spacing,FontSpacing
;	move.l	#F3CharTrans,CharTrans	; character translation table


;blit cards
	IMAGES	#Cards
	clr.b	temp

	move.w	#4+6,vscardy

	move.w	#2,vsH	;height-1  was 2
.ylp	move.w	#4,vsW	;width-1
	move.w	#6+6,vscardx	;leftside
.xlp
	cmp.w	#1,vsH
	bne.s	.notmid
	cmp.w	#2,vsW
	beq.s	.skipmid
.notmid
;	APALETTE	#P_CARD
;	BLIT	#back0001,vscardx,vscardy
;	BLIT	#card0001,vscardx,vscardy
;	BLIT	#border,vscardx,vscardy


;	tst.w	cardscaleX
;	beq.s	.fullscale
;	cmp.w	#253,cardscaleX
;	bge.s	.fullscale
;	move.w	cscaledir,d0
;	add.w	d0,cardscaleX
;	bmi.s	.fullscale
;	OSCALE	cardscaleX,cardscaleY
;	CLIP	OFF
;.fullscale

	move.l	pinfo,a5
	move.b	temp,d0
	ext.w	d0

;	PUSHW	d6-d7	;-----

	move.w	vscardx,d6
	move.w	vscardy,d7	;cardy
	move.b	#DIM,card_pal	;dim card pal
	cmp.b	#9,temp
	blt.s	.dimmed
	cmp.b	#12,temp
	bgt.s	.dimmed
	move.b	#NOTDIM,card_pal
	move.b	d0,d1
	add.b	#1,d1
	cmp.b	Bcursor(a5),d1
	bne.s	.dimmed
	sub.w	#3,d6
	sub.w	#3,d7
.dimmed


	jsr	blit_cardVS

;	POPW	d6-d7	;-----

	add.b	#1,temp
.skipmid
	add.w	#75,vscardx
	sub.w	#1,vsW
	bpl	.xlp

	add.w	#83,vscardy	; Increment Coordinates
	sub.w	#1,vsH
	bpl	.ylp


	OSCALE	#$100,#$100	;reset OSCALE
	ROT_OFF		;reset OSCALE
	CLIP	ON


;all the same player
	cmp.b	#2,TeamAllSame
	bne	nosamemess

	APALETTE	#P_NEOYEL
	SETPRINT	#13,#17,#neo4,#0
	clr.l	FontAdjust
	move.l	#neo4Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table
	PPRINT	#70,#193,"   CHOOSE A PLAYER"
	PPRINT	#70,#213,"TO PLAY ENTIRE LINE UP"
nosamemess

;	APALETTE	#P_BALL
;	BLOT	#cities,#8,#182

	IMAGES	#Initial
	APALETTE	#P_BALL

;	cmp.l	#PlayerL,pinfo
;	bne.s	.notp1
;	BBLITO	#select1a,selcx1,selcy1
;	bra.s	.pdone
;.notp1	BBLITO	#select2a,selcx2,selcy2
;.pdone
	rts






printsuffix
	move.b	temp,d0
	cmp.b	#11,d0	;special case
	beq	PSth
	cmp.b	#12,d0	;special case
	beq	PSth
	cmp.b	#13,d0	;special case
	beq	PSth
	ext.w	d0
	ext.l	d0
	divu	#10,d0
	swap	d0
	cmp.w	#1,d0
	beq.s	PSst
	cmp.w	#2,d0
	beq	PSnd
	cmp.w	#3,d0
	beq	PSrd
PSth
	PRINT	"^"
	rts
PSst
	PRINT	"["
	rts
PSnd
	PRINT	"_"
	rts
PSrd
	PRINT	"]"
	rts


setAIteam		;get next team in season
	jsr	Random
	and.b	#00001111b,d0
	cmp.b	#NoY,YND(a1)
	beq.s	.random
	move.b	stat_defeat(a1),d0	;opponents
.random	ext.w	d0
	move.b	(regular_season,d0.w),d1
	move.b	d1,Bcursor(a0)
	rts

regular_season		;team numbers
	dc.b	21,22,09,27,15,16,14,17,24,10,20,12,19,26
	dc.b	5,4,11,23,18,13,2,0,8,1,3,25,6,7

	dc.b	25,6,7	;championship_series

	dc.b	0	;world_series


setAIpitcher
;	move.b	#11,first_pitcher(a0)
	move.b	Inning,d1
	cmp.b	#19,d1
	ble.s	.nolim
	move.b	#19,d1	;stay at end of table
.nolim	ext.w	d1
	move.b	(PitchersByHalfInning,d1.w),d0

	cmp.b	first_pitcher(a0),d0
	beq.s	.notnew	;branch if same guy
	move.b	d0,first_pitcher(a0)
	move.b	d0,FIRSTPITCHER(a0)
	move.w	#0x100,PITCHERSTRENGTH(a0) ; Set Pitcher not tired
.notnew
	move.w	#$0101,done	;flag selected
	rts

PitchersByHalfInning
	dc.b	9,9	;1
	dc.b	9,9	;2
	dc.b	9,9	;3
	dc.b	10,10	;4
	dc.b	10,10	;5
	dc.b	11,11	;6
	dc.b	12,12	;7
	dc.b	13,13	;8
	dc.b	13,13	;9
	dc.b	13,13	;10


ButtsOnD
	move.l	#Enter1D,d2
	move.l	#Enter2D,d3
	clr.w	P1y
;	clr.w	P1yinc
	clr.w	P2y
;	clr.w	P2yinc
	SWITCH	#BUTTON1_1,#81H,d2
	SWITCH	#BUTTON1_2,#81H,d2
	SWITCH	#BUTTON1_3,#81H,d2
	SWITCH	#BUTTON1_4,#81H,d2
	
	SWITCH	#BUTTON2_1,#81H,d3
	SWITCH	#BUTTON2_2,#81H,d3
	SWITCH	#BUTTON2_3,#81H,d3
	SWITCH	#BUTTON2_4,#81H,d3
	rts

ButtsOn	
	move.l	#Enter1,d2
	move.l	#Enter2,d3
	bra.s	butON

ButtsOff	clr.l	d2
	clr.l	d3
	bra.s	butON

ButtsOnM

	move.l	#Enter1M,d2
	move.l	#Enter2M,d3
butON
	SWITCH	#BUTTON1_1,#81H,d2
	SWITCH	#BUTTON1_2,#81H,d2
	SWITCH	#BUTTON1_3,#81H,d2
	SWITCH	#BUTTON1_4,#81H,d2
	
	SWITCH	#BUTTON2_1,#81H,d3
	SWITCH	#BUTTON2_2,#81H,d3
	SWITCH	#BUTTON2_3,#81H,d3
	SWITCH	#BUTTON2_4,#81H,d3

	rts

ButtsOnVS
	move.l	#Enter1VS,d2
	move.l	#Enter2VS,d3

	SWITCH	#BUTTON1_1,#81H,d2
	SWITCH	#BUTTON1_2,#81H,d2
	SWITCH	#BUTTON1_3,#81H,d2
	SWITCH	#BUTTON1_4,#81H,d2
	
	SWITCH	#BUTTON2_1,#81H,d3
	SWITCH	#BUTTON2_2,#81H,d3
	SWITCH	#BUTTON2_3,#81H,d3
	SWITCH	#BUTTON2_4,#81H,d3

	rts

Enter2VS
	tst.b	done+1
	bne.s	.rts
	move.b	#BUTTON2_5,d0
	jsr	SwitchState
	tst.b	d0
	bne.s	.rts	;no done if power pushed
	SOUND	button_sound,button_sound
	move.b	#1,done+1
	move.b	#0,firstt

	move.b	#START2,d0
	jsr	SwitchState
	move.b	d0,stst2

.rts	rts

Enter1VS
	tst.b	done
	bne.s	.rts
	move.b	#BUTTON1_5,d0
	jsr	SwitchState
	tst.b	d0
	bne.s	.rts	;no done if power pushed
	SOUND	button_sound,button_sound
	move.b	#1,done
	move.b	#1,firstt

	move.b	#START1,d0
	jsr	SwitchState
	move.b	d0,stst1

.rts	rts


setclip
	APALETTE	#P_BALL
	move.l	pinfo,a0
	clr.w	d0
	move.b	Bcursor(a0),d0
	mulu	#6,d0	;6 byte table
	add.w	d1,d0
	move.l	#teamstats,a0
	move.b	(a0,d0.w),d0
	move.b	d0,temp
	and.w	#$00ff,d0	;ext to word
	mulu	#3,d0	;fill gauge
	add.w	clipX,d0
	SETCLIP	d0,#0,#384,#256

;	SETCLIP	#0,#0,#134,#256	;test

	rts


setclip2
	APALETTE	#P_BALL
	move.l	pinfo,a0
	clr.w	d0
	move.b	Bcursor(a0),d0
	mulu	#6,d0	;6 byte table
	add.w	d1,d0
	move.l	#teamstats,a0
	move.b	(a0,d0.w),d0
	move.b	d0,temp
	and.w	#$00ff,d0	;ext to word
	mulu	#3,d0	;fill gauge
	move.w	clipX,d1
	sub.w	d0,d1
	SETCLIP	#0,#0,d1,#256

;	SETCLIP	#0,#0,#330,#256	;test

	rts



teamstats      ;BA PO FI PI SP RK     0-28
	dc.b	26,08,09,01,23,07 ;01 atlanta
	dc.b	18,06,01,13,18,09 ;02 baltimore
	dc.b	03,05,25,14,17,06 ;03 boston
	dc.b	06,03,05,15,27,05 ;04 california
	dc.b	15,11,22,09,14,13 ;05 chicago cubs
	dc.b	04,13,17,22,13,23 ;06 chicago white sox
	dc.b	11,09,03,05,01,02 ;07 cincinnati
	dc.b	01,01,11,03,04,01 ;08 cleveland
	dc.b	02,26,16,02,07,08 ;09 colorado
	dc.b	27,10,15,27,24,25 ;10 detroit
	dc.b	19,14,23,11,05,16 ;11 florida
	dc.b	09,27,26,07,02,12 ;12 houston
	dc.b	21,23,04,16,10,19 ;13 kansas city
	dc.b	16,15,28,02,06,04 ;14 los angeles
	dc.b	13,18,14,21,15,21 ;15 milwaukee
	dc.b	05,21,10,28,16,27 ;16 minnesota
	dc.b	23,24,20,08,09,20 ;17 montreal
	dc.b	12,19,24,04,26,11 ;18 new york mets
	dc.b	07,22,02,17,28,10 ;19 new york yankees
	dc.b	17,07,12,25,11,17 ;20 oakland
	dc.b	18,28,06,12,25,18 ;21 philadelphia
	dc.b	20,20,27,20,20,22 ;22 pittsburgh
	dc.b	28,26,21,06,21,24 ;23 st.louis
	dc.b	10,25,18,10,08,14 ;24 san diego
	dc.b	25,12,19,23,03,28 ;25 san francisco
	dc.b	08,04,13,18,12,03 ;26 seattle
	dc.b	14,17,08,19,19,15 ;27 texas
	dc.b	22,16,07,24,22,26 ;28 toronto

	dc.b	1,1,1,1,1,1 ;drafted team
                                
                                

;teamstats           ;BA PO FI PI  0-83
;	dc.b	13,62,59,83     ;atlanta
;	dc.b	36,68,83,47     ;baltimore
;	dc.b	77,71,20,44     ;boston
;	dc.b	68,77,71,42     ;california
;	dc.b	44,53,23,59     ;chicago cubs
;	dc.b	77,47,32,22     ;chicago white sox
;	dc.b	53,70,77,71     ;cincinnati
;	dc.b	83,83,53,77     ;cleveland
;	dc.b	80,10,35,10     ;colorado
;	dc.b	10,56,38,07     ;detroit
;	dc.b	33,44,23,50     ;florida
;	dc.b	62,05,17,68     ;houston
;	dc.b	31,17,74,42     ;kansas city
;	dc.b	42,41,11,80     ;los angeles
;	dc.b	47,32,44,25     ;milwaukee
;	dc.b	71,20,59,04     ;minnesota
;	dc.b	22,14,29,62     ;montreal
;	dc.b	50,29,23,74     ;new york mets
;	dc.b	65,23,80,36     ;new york yankees
;	dc.b	42,65,50,13     ;oakland
;	dc.b	33,02,68,53     ;philadelphia
;	dc.b	22,26,14,28     ;pittsburgh
;	dc.b	10,08,26,65     ;st.louis
;	dc.b	59,11,32,59     ;san diego
;	dc.b	22,50,32,19     ;san francisco
;	dc.b	62,74,47,33     ;seattle
;	dc.b	44,35,62,31     ;texas
;	dc.b	16,41,68,16     ;toronto


;TigglePage
;	APALETTE	#P_BALL
;	BLIT	#opponent,#225,#112
;
;	jsr	TogglePage
;
;	rts


curtain
	PUSHW	d0
	move.w	curtx,d0
	cmp.w	#178,prx_coor
	bgt	.add
	sub.w	d0,prx_coor
	sub.w	d0,prx_init
	bra	.con
.add
	add.w	d0,prx_coor
	add.w	d0,prx_init
.con
	POPW	d0
	rts


LetterList			;called by (a0)
;letter cursor
	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	clr.w	d1
	move.b	([pinfo],Bcursor),d1
	move.l	([pinfodata],LETarray),a0
	BBLIT	<<([pinfodata],LETarrow)>>,<<(a0,d1.w*4)>>,<<(2,a0,d1.w*4)>>

	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
;scrn
	BLOT	<([pinfodata],scrn03)>,<([pinfodata],scrn03X)>,<([pinfodata],scrn03Y)>

	SETPRINT	#17,#22,#neo3,#0
	clr.l	FontAdjust
	move.l	#neo3Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table
	APALETTE	#P_NEOYEL
	PLAT	<([pinfodata],dfmessX)>,#39
	cmp.b	#DraftY,([pinfo],YND) ;is player drafting?
	bne.s	NotDrafting
	PRINT	"DRAFT TEAM"	
NotDrafting
	rts

LETxyA
	dc.w	22,62
	dc.w	41,62
	dc.w	63,62
	dc.w	85,62
	dc.w	106,62
	dc.w	126,62
	dc.w	146,62
	dc.w	22,93
	dc.w	39,93
	dc.w	56,93
	dc.w	75,93
	dc.w	95,93
	dc.w	118,93
	dc.w	145,93
	dc.w	21,125
	dc.w	42,125
	dc.w	66,125
	dc.w	87,125
	dc.w	106,125
	dc.w	126,125
	dc.w	146,125
	dc.w	21,157
	dc.w	43,157
	dc.w	67,157
	dc.w	89,157
	dc.w	108,157
	dc.w	130,157
	dc.w	145,157

LETxyB
	dc.w	213,61
	dc.w	232,61
	dc.w	254,61
	dc.w	276,61
	dc.w	296,61
	dc.w	317,61
	dc.w	337,61
	dc.w	213,92
	dc.w	231,92
	dc.w	247,92
	dc.w	266,92
	dc.w	286,92
	dc.w	309,92
	dc.w	336,92
	dc.w	212,124
	dc.w	234,124
	dc.w	257,124
	dc.w	278,124
	dc.w	297,124
	dc.w	317,124
	dc.w	337,124
	dc.w	212,156
	dc.w	234,156
	dc.w	258,156
	dc.w	280,156
	dc.w	299,156
	dc.w	321,156
	dc.w	337,156


;LetterList			;called by (a0)
	PLAT	leftside,#50

;	SETPRINT	#49,#30,#fnt2,#0
;	move.l	#LetterListAdjust,FontAdjust
;	clr.l	FontSpacing	; Non-Proportional Spacing
;	move.l	#F5CharTrans,CharTrans	; character translation table

	SETPRINT	#22,#34,#neo2,#0
	move.l	#LetterListAdjust,FontAdjust
	clr.l	FontSpacing	; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans	; character translation table

	move.b	#$41,temp

	move.w	menu_height,d4
.ylp	move.w	menu_width,d5
.xlp
	PUSHL	d4-d6

;	APALETTE	#P_FONTDPAL
	jsr	SetPalToSideDim
	move.l	pinfo,a0
	move.b	temp,d0
	sub.b	#$41,d0
	cmp.b	Bcursor(a0),d0
	bne	.notdim
;	APALETTE	#P_BALL
	jsr	SetPalToSide
;	sub.w	#3,pry_coor	;shift selected char up
.notdim

	clr.w	d6
	move.w	#1,d7	; Print One Character
	move.l	#temp,a0
	jsr	Print	; Print Them
	POPL	d4-d6

;	cmp.b	#P_FONTR1,N_PalSel+3
;	beq	.notbright
;	cmp.b	#P_FONTB1,N_PalSel+3
;	beq	.notbright
;	add.w	#3,pry_coor	;unshift selection
;.notbright

	move.w	xmspace,d0
	add.w	d0,prx_coor	; Increment Coordinates
	add.b	#1,temp
	cmp.w	#1,d5
	dbeq	d5,.xlp
	move.w	leftside,prx_coor	; Increment Coordinates

	jsr	curtain

	move.w	ymspace,d0
	add.w	d0,pry_coor	; Increment Coordinates
	cmp.w	#1,d4
	dbeq	d4,.ylp

	rts



MonthList			;called by (a0)
;month cursor
	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	clr.w	d1
	move.b	([pinfo],Bcursor),d1
	move.l	([pinfodata],MONarray),a0
	BBLIT	<<([pinfodata],MONarrow)>>,<<(a0,d1.w*4)>>,<<(2,a0,d1.w*4)>>


	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
;scrn
	BLOT	<([pinfodata],scrn04)>,<([pinfodata],scrn04X)>,<([pinfodata],scrn04Y)>

	SETPRINT	#17,#22,#neo3,#0
	clr.l	FontAdjust
	move.l	#neo3Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table
	APALETTE	#P_NEOYEL
	PLAT	<([pinfodata],dfmessX)>,#39
	cmp.b	#DraftY,([pinfo],YND) ;is player drafting?
	bne.s	NotDrafting2
	PRINT	"DRAFT TEAM"	
NotDrafting2

	rts

MONxyA
	dc.w	19,61
	dc.w	65,61
	dc.w	114,61
	dc.w	18,93
	dc.w	68,93
	dc.w	118,93
	dc.w	15,126
	dc.w	66,126
	dc.w	117,126
	dc.w	17,156
	dc.w	65,156
	dc.w	115,156

MONxyB
	dc.w	208,56
	dc.w	257,56
	dc.w	308,56
	dc.w	210,88
	dc.w	260,88
	dc.w	310,88
	dc.w	207,121
	dc.w	256,121
	dc.w	308,121
	dc.w	208,151
	dc.w	255,151
	dc.w	306,151



;MonthList			;called by (a0)
	PLAT	leftside,#50
;	SETPRINT	#49,#30,#fnt2,#0
;	clr.l	FontAdjust
;	move.l	#fnt2SpacingMONTH,FontSpacing
;	move.l	#F5CharTrans,CharTrans	; character translation table

	SETPRINT	#22,#34,#neo2,#0
	clr.l	FontAdjust
	move.l	#neo2Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table

;	move.b	#$41,temp
	move.b	#0,temp

	move.w	leftside,d3
	move.w	menu_height,d4
.ylp	move.w	menu_width,d5
.xlp
	PUSHL	d3-d6

;	APALETTE	#P_FONTDPAL
	jsr	SetPalToSideDim
	move.l	pinfo,a0
	move.b	temp,d0
	cmp.b	Bcursor(a0),d0
	bne	.notdim
;	APALETTE	#P_BALL
	jsr	SetPalToSide
;	sub.w	#3,pry_coor	;shift selected char up
.notdim
	ext.w	d0
	asl.w	#2,d0	;string length 4
	move.l	#Monthstxt,a0
	lea	(a0,d0.w),a0
	PRINTS	a0

	POPL	d3-d6

;	cmp.b	#P_FONTR1,N_PalSel+3
;	beq	.notbright
;	cmp.b	#P_FONTB1,N_PalSel+3
;	beq	.notbright
;	add.w	#3,pry_coor	;unshift selection
;.notbright
	add.w	xmspace,d3
	move.w	d3,prx_coor	; Increment Coordinates
	jsr	curtain
	add.b	#1,temp
	cmp.w	#1,d5
	dbeq	d5,.xlp

	move.w	leftside,d3	; Increment Coordinates
	move.w	d3,prx_coor

	jsr	curtain

	move.w	ymspace,d0
	add.w	d0,pry_coor	; Increment Coordinates
	cmp.w	#1,d4
	dbeq	d4,.ylp

	rts



DayList			;called by (a0)
;day cursor
	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
	clr.w	d1
	move.b	([pinfo],Bcursor),d1
	move.l	([pinfodata],DAYarray),a0
	BBLIT	<<([pinfodata],DAYarrow)>>,<<(a0,d1.w*4)>>,<<(2,a0,d1.w*4)>>


	IMAGES	#Misc
	APALETTE	#P_NEWSCORE
;scrn
	BLOT	<([pinfodata],scrn05)>,<([pinfodata],scrn05X)>,<([pinfodata],scrn05Y)>


	SETPRINT	#17,#22,#neo3,#0
	clr.l	FontAdjust
	move.l	#neo3Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table
	APALETTE	#P_NEOYEL
	PLAT	<([pinfodata],dfmessX)>,#39
	cmp.b	#DraftY,([pinfo],YND) ;is player drafting?
	bne.s	NotDrafting3
	PRINT	"DRAFT TEAM"	
NotDrafting3


	APALETTE	#P_NEWSCORE
	SETPRINT	#17,#22,#neo3,#0
	clr.l	FontAdjust
	move.l	#neo3Spacing,FontSpacing
	move.l	#NeoCharTrans,CharTrans	; character translation table

	PLAT	<([pinfodata],m29X)>,#164
	PRINT	"2"
	move.w	#165,pry_coor
	sub.w	#2,prx_coor
	PRINT	"9"

	PLAT	<([pinfodata],m30X)>,#164
	PRINT	"3"
	move.w	#165,pry_coor
	sub.w	#2,prx_coor
	PRINT	"0"

	PLAT	<([pinfodata],m31X)>,#164
	PRINT	"3"
	move.w	#165,pry_coor
	sub.w	#1,prx_coor
	PRINT	"1"

	rts

DAYxyA
	dc.w	16,64
	dc.w	35,64
	dc.w	57,64
	dc.w	80,64
	dc.w	101,64
	dc.w	123,64
	dc.w	144,64
	dc.w	18,88
	dc.w	41,88
	dc.w	67,88
	dc.w	92,88
	dc.w	117,88
	dc.w	141,88
	dc.w	19,112
	dc.w	44,112
	dc.w	69,112
	dc.w	92,112
	dc.w	116,112
	dc.w	140,112
	dc.w	20,136
	dc.w	44,136
	dc.w	67,136
	dc.w	92,136
	dc.w	116,136
	dc.w	140,136
	dc.w	19,160
	dc.w	43,160
	dc.w	68,160
	dc.w	93,160
	dc.w	117,160
	dc.w	141,160

DAYxyB
	dc.w	208,62
	dc.w	227,62
	dc.w	249,62
	dc.w	271,62
	dc.w	293,62
	dc.w	314,62
	dc.w	334,62
	dc.w	209,86
	dc.w	233,86
	dc.w	258,86
	dc.w	283,86
	dc.w	308,86
	dc.w	331,86
	dc.w	211,110
	dc.w	236,110
	dc.w	260,110
	dc.w	283,110
	dc.w	307,110
	dc.w	331,110
	dc.w	212,134
	dc.w	235,134
	dc.w	259,134
	dc.w	283,134
	dc.w	306,134
	dc.w	332,134
	dc.w	211,158
	dc.w	235,158
	dc.w	260,158
	dc.w	284,158
	dc.w	308,158
	dc.w	332,158

	.align	2


;;DayList			;called by (a0)
;	PLAT	leftside,#50
;
;;	SETPRINT	#13,#12,#fnt1,#0
;;	clr.l	FontAdjust
;;	move.l	#fnt1Spacing,FontSpacing
;;	move.l	#F5CharTrans,CharTrans	; character translation table
;
;	SETPRINT	#13,#17,#neo3,#0
;	clr.l	FontAdjust
;	move.l	#neo3Spacing,FontSpacing
;	move.l	#NeoCharTrans,CharTrans	; character translation table
;
;;	move.b	#$41,temp
;	move.b	#1,temp
;
;	move.w	leftside,d3
;	move.w	menu_height,d4
;.ylp	move.w	menu_width,d5
;.xlp
;	PUSHL	d3-d6
;
;;	APALETTE	#P_FONTDPAL
;	jsr	SetPalToSideDim
;	move.l	pinfo,a0
;	move.b	temp,d0
;	sub.b	#1,d0
;	cmp.b	Bcursor(a0),d0
;	bne	.notdim
;;	APALETTE	#P_BALL
;	jsr	SetPalToSide
;;	sub.w	#3,pry_coor	;shift selected char up
;.notdim
;
;	PRINTDECB temp,#2,JLEFT
;	POPL	d3-d6
;
;;	cmp.b	#P_FONTR1,N_PalSel+3
;;	beq	.notbright
;;	cmp.b	#P_FONTB1,N_PalSel+3
;;	beq	.notbright
;;	add.w	#3,pry_coor	;unshift selection
;;.notbright
;	move.b	temp,d0
;	move.l	pinfo,a0
;	cmp.b	max_input+1(a0),d0
;	beq.s	.done
;
;	add.w	xmspace,d3	; Increment Coordinates
;	move.w	d3,prx_coor
;	jsr	curtain
;	add.b	#1,temp
;	cmp.w	#1,d5
;	dbeq	d5,.xlp
;
;	move.w	leftside,d3
;	move.w	d3,prx_coor
;
;	jsr	curtain
;
;	move.w	ymspace,d0
;	add.w	d0,pry_coor	; Increment Coordinates
;	cmp.w	#1,d4
;	dbeq	d4,.ylp
;.done
;	rts




;Pletter
;	SETPRINT	#49,#30,#fnt5,#0
;	clr.l	FontAdjust
;	move.l	#fnt5Spacing,FontSpacing ; Non-Proportional Spacing
;	move.l	#BIGCharTrans,CharTrans ; character translation table
;
;	PUSHL	a0
;	move.w	#9999,d6	;don't print
;	move.w	#1,d7	; Print One Character
;	jsr	Print
;	POPL	a0
;
;	move.w	font_width,d0
;	lsr.w	#1,d0
;	sub.w	d0,prx_coor	; Increment Coordinates
;
;	clr.w	d6
;	move.w	#1,d7	; Print One Character
;	cmp.b	#91,(a0)	;1 past Z
;	beq.s	.space
;	jsr	Print	; Print Them
;.space
;	rts

Pletter

	SETPRINT	#31,#46,#neo1,#0
	clr.l	FontAdjust
;	move.l	#neo1Spacing,FontSpacing ; Non-Proportional Spacing
	clr.l	FontSpacing ; Non-Proportional Spacing
	move.l	#NeoCharTrans,CharTrans ; character translation table
	APALETTE	#P_NEWSCORE	;temp? waiting for neo color pals


;	PUSHL	a0
;	move.w	#9999,d6	;don't print
;	move.w	#1,d7	; Print One Character
;	jsr	Print
;	POPL	a0
;
;	move.w	font_width,d0
;	lsr.w	#1,d0
;	sub.w	d0,prx_coor	; Increment Coordinates
;
	clr.w	d6
	move.w	#1,d7	; Print One Character
	cmp.b	#32,(a0)	;space
	beq.s	.space
	jsr	Print	; Print Them
	rts
.space
	move.w	font_width,d0	; add the font width
	add.w	d0,prx_coor	; to the current X coord

	rts

	.import	NeoCharTrans
	.align 	2

;	.export	neo1CharTrans
;neo1CharTrans:
;	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0                ;* 0-15    */
;	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	            ;* 16-31   */
;;                  !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
;	dc.b	00,64,65,63,62,61,38,39,57,58,59,54,41,55,40,47  ;* 32-47   */
;;                0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
;	dc.b	01,02,03,04,05,06,07,08,09,10,42,43,44,53,45,46 ;* 48-63   */
;;                @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
;	dc.b	37,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 64-79   */
;;		P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
;	dc.b	26,27,28,29,30,31,32,33,34,35,36,50,52,51,00,56 ;* 80-95   */
;;                            a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
;;	dc.b	00,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51 ;* 96-111  */
;;                p  q  r  s  t  u  v  w  x  y  z  {  }
;;	dc.b	52,53,54,55,56,57,58,59,63,64,65,48,49,60,66,00 ;* 112-127 */
;
;	dc.b	00,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 96-111  */
;;                         p  q  r  s  t  u  v  w  x  y  z  {  }
;	dc.b	26,27,28,29,30,31,32,33,34,35,36,48,49,60,66,00 ;* 112-127 */
;
;	ds	0
;
;
;	.export	neo2CharTrans
;neo2CharTrans:
;	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0                ;* 0-15    */
;	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	            ;* 16-31   */
;;                  !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
;	dc.b	00,64,65,63,62,61,38,39,57,58,59,54,41,55,40,47  ;* 32-47   */
;;                0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
;	dc.b	01,02,03,04,05,06,07,08,09,10,42,43,44,53,45,46 ;* 48-63   */
;;                @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
;	dc.b	37,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 64-79   */
;;		P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
;	dc.b	26,27,28,29,30,31,32,33,34,35,36,50,52,51,00,56 ;* 80-95   */
;;                            a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
;;	dc.b	00,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51 ;* 96-111  */
;;                p  q  r  s  t  u  v  w  x  y  z  {  }
;;	dc.b	52,53,54,55,56,57,58,59,63,64,65,48,49,60,66,00 ;* 112-127 */
;
;	dc.b	00,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 96-111  */
;;                         p  q  r  s  t  u  v  w  x  y  z  {  }
;	dc.b	26,27,28,29,30,31,32,33,34,35,36,48,49,60,66,00 ;* 112-127 */
;
;	ds	0
;
;
;	.export	neo3CharTrans
;neo3CharTrans:
;	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0                ;* 0-15    */
;	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	            ;* 16-31   */
;;                  !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
;	dc.b	00,64,65,63,62,61,38,39,57,58,59,54,41,55,40,47  ;* 32-47   */
;;                0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
;	dc.b	01,02,03,04,05,06,07,08,09,10,42,43,44,53,45,46 ;* 48-63   */
;;                @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
;	dc.b	37,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 64-79   */
;;		P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
;	dc.b	26,27,28,29,30,31,32,33,34,35,36,50,52,51,00,56 ;* 80-95   */
;;                            a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
;;	dc.b	00,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51 ;* 96-111  */
;;                p  q  r  s  t  u  v  w  x  y  z  {  }
;;	dc.b	52,53,54,55,56,57,58,59,63,64,65,48,49,60,66,00 ;* 112-127 */
;
;	dc.b	00,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 96-111  */
;;                         p  q  r  s  t  u  v  w  x  y  z  {  }
;	dc.b	26,27,28,29,30,31,32,33,34,35,36,48,49,60,66,00 ;* 112-127 */
;
;	ds	0



BIGCharTrans:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0                ;* 0-15    */
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0            ;* 16-31   */
;                  !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
	dc.b	00,37,00,00,00,00,00,43,00,00,00,00,39,41,38,42  ;* 32-47   */
;                     0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
	dc.b	36,27,28,29,30,31,32,33,34,35,00,00,00,00,00,40 ;* 48-63   */
;                     @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
	dc.b	37,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15 ;* 64-79   */
;		 P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
	dc.b	16,17,18,19,20,21,22,23,24,25,26,53,58,59,00,00 ;* 80-95   */
;                a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
	dc.b	00,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 96-111  */
;                p  q  r  s  t  u  v  w  x  y  z  {  }
	dc.b	26,27,28,29,30,31,32,33,34,35,36,00,00,00,00,00 ;* 112-127 */

	ds	0


F1CharTrans:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0                ;* 0-15    */
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0            ;* 16-31   */
;                  !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
	dc.b	00,37,00,00,00,00,00,41,00,00,00,00,38,41,38,42  ;* 32-47   */
;                     0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
	dc.b	36,27,28,29,30,31,32,33,34,35,00,00,00,52,00,43 ;* 48-63   */
;                     @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
	dc.b	37,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15 ;* 64-79   */
;		 P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
	dc.b	16,17,18,19,20,21,22,23,24,25,26,57,58,59,00,00 ;* 80-95   */
;                a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
	dc.b	00,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 96-111  */
;                p  q  r  s  t  u  v  w  x  y  z  {  }
	dc.b	26,27,28,29,30,31,32,33,34,35,36,00,00,00,00,00 ;* 112-127 */

	ds	0

F2CharTrans:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0                ;* 0-15    */
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0            ;* 16-31   */
;                  !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
	dc.b	00,37,00,00,00,00,00,41,00,00,00,00,39,41,38,54  ;* 32-47   */
;                     0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
	dc.b	36,27,28,29,30,31,32,33,34,35,00,00,00,00,00,43 ;* 48-63   */
;                     @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
	dc.b	37,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15 ;* 64-79   */
;		 P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
	dc.b	16,17,18,19,20,21,22,23,24,25,26,56,57,59,00,00 ;* 80-95   */ 56 & 57 were 57 & 58
;                a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
	dc.b	00,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 96-111  */
;                p  q  r  s  t  u  v  w  x  y  z  {  }
	dc.b	26,27,28,29,30,31,32,33,34,35,36,00,00,00,00,00 ;* 112-127 */

	ds	0

F3CharTrans:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0                ;* 0-15    */
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0            ;* 16-31   */
;                     !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
	dc.b	00,37,00,00,00,00,00,41,00,00,00,00,39,41,38,42  ;* 32-47   */
;                     0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
	dc.b	36,27,28,29,30,31,32,33,34,35,40,00,00,00,00,40 ;* 48-63   */
;                     @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
	dc.b	47,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15 ;* 64-79   */
;		 P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
	dc.b	16,17,18,19,20,21,22,23,24,25,26,57,58,59,60,58 ;* 80-95   */
;                a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
	dc.b	58,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 96-111  */
;                p  q  r  s  t  u  v  w  x  y  z  {  }
	dc.b	26,27,28,29,30,31,32,33,34,35,36,00,00,00,00,00 ;* 112-127 */

	ds	0

F5CharTrans:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0                ;* 0-15    */
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0            ;* 16-31   */
;                  !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
	dc.b	00,37,00,00,00,00,00,41,00,00,00,00,39,41,38,42  ;* 32-47   */
;                     0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
	dc.b	36,27,28,29,30,31,32,33,34,35,00,00,00,00,00,43 ;* 48-63   */
;                     @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
	dc.b	37,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15 ;* 64-79   */
;		 P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
	dc.b	16,17,18,19,20,21,22,23,24,25,26,57,58,59,00,00 ;* 80-95   */
;                a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
	dc.b	00,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 96-111  */
;                p  q  r  s  t  u  v  w  x  y  z  {  }
	dc.b	26,27,28,29,30,31,32,33,34,35,36,00,00,00,00,00 ;* 112-127 */

	ds	0


;AdjustableMenuMove	equ	26

BallService
	move.w	PlayerL+TRACKX,tbx1
	move.w	PlayerR+TRACKX,tbx2
	move.b	#0,PlayerL+bat_order
	move.b	#0,PlayerR+bat_order
;	clr.w	P1yinc
;	clr.w	P2yinc
BSlp
	tst.b	done
	bne	.control

;	tst.w	P1yinc	;don't change card while sliding
;	bne	.control

	move.w	tbx1,d0
	sub.w	PlayerL+TRACKX,d0

	cmp.w	#sensitive,d0
	blt.s	.noinc
	move.w	PlayerL+TRACKX,tbx1
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove
	sub.b	#1,PlayerL+Bcursor
	jmp	.nodec
.noinc
	cmp.w	#-sensitive,d0
	bgt.s	.nodec
	move.w	PlayerL+TRACKX,tbx1

	SOUND	#AdjustableMenuMove,#AdjustableMenuMove

	add.b	#1,PlayerL+Bcursor
.nodec
	tst.b	PlayerL+Bcursor
	bpl	.notneg
	move.b	PlayerL+max_select+1,PlayerL+Bcursor
.notneg
	move.b	PlayerL+Bcursor,d0	;max Bcursor value
	cmp.b	PlayerL+max_select+1,d0
	ble	.notmax
	clr.b	PlayerL+Bcursor
.notmax
	move.w	PlayerL+max_input,d0
	cmp.b	PlayerL+Bcursor,d0
	ble	.control

	move.w	art_offset,d0
	add.b	PlayerL+Bcursor,d0
	move.b	PlayerL+Lcursor,d1
	cmp.b	#team,d1	;team value turns this function off
	beq.s	.control
	tst.b	PlayerL+bat_order	;don't change card while ordering
	bne	.control
	ext.w	d1
	move.l	#PlayerL,a0
	move.b	d0,(a0,d1.w)

;handle space char
	cmp.b	#91,(a0,d1.w)	;old space
	bne.s	.notspace
	move.b	#32,(a0,d1.w)	;new space
.notspace
.notletter

.control
Ballclone
	tst.b	done+1
	bne	.control

;	tst.w	P2yinc	;don't change card while sliding
;	bne	.control


	move.w	tbx2,d0
	sub.w	PlayerR+TRACKX,d0

	cmp.w	#sensitive,d0
	blt.s	.noinc
	move.w	PlayerR+TRACKX,tbx2
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove	; Init Sounds System
	sub.b	#1,PlayerR+Bcursor
	jmp	.nodec
.noinc
	cmp.w	#-sensitive,d0
	bgt.s	.nodec
	move.w	PlayerR+TRACKX,tbx2
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove	; Init Sounds System
	add.b	#1,PlayerR+Bcursor
.nodec
	tst.b	PlayerR+Bcursor
	bpl	.notneg
	move.b	PlayerR+max_select+1,PlayerR+Bcursor
.notneg
	move.b	PlayerR+Bcursor,d0	;max Bcursor value
	cmp.b	PlayerR+max_select+1,d0
	ble	.notmax
	clr.b	PlayerR+Bcursor
.notmax
	move.w	PlayerR+max_input,d0
	cmp.b	PlayerR+Bcursor,d0
	ble	.control

	move.w	art_offset,d0
	add.b	PlayerR+Bcursor,d0
	move.b	PlayerR+Lcursor,d1
	cmp.b	#team,d1	;team value turns this function off
	beq.s	.control
	tst.b	PlayerR+bat_order	;don't change card while ordering
	bne	.control
	ext.w	d1
	move.l	#PlayerR,a0
	move.b	d0,(a0,d1.w)

;handle space char
	cmp.b	#91,(a0,d1.w)	;old space
	bne.s	.notspace
	move.b	#32,(a0,d1.w)	;new space
.notspace
.notletter

.control

	DELAY	#1
	jmp	BSlp


BallServiceY
	move.w	PlayerL+TRACKY,tbx1
	move.w	PlayerR+TRACKY,tbx2
	move.b	#0,PlayerL+bat_order
	move.b	#0,PlayerR+bat_order
;	clr.w	P1yinc
;	clr.w	P2yinc
BSlpY
	tst.b	done
	bne	.control

;	tst.w	P1yinc	;don't change card while sliding
;	bne	.control

	move.w	tbx1,d0
	sub.w	PlayerL+TRACKY,d0

	cmp.w	#sensitive,d0
	blt.s	.noinc
	move.w	PlayerL+TRACKY,tbx1
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove
	sub.b	#1,PlayerL+Bcursor
	jmp	.nodec
.noinc
	cmp.w	#-sensitive,d0
	bgt.s	.nodec
	move.w	PlayerL+TRACKY,tbx1

	SOUND	#AdjustableMenuMove,#AdjustableMenuMove

	add.b	#1,PlayerL+Bcursor
.nodec
	tst.b	PlayerL+Bcursor
	bpl	.notneg
	move.b	PlayerL+max_select+1,PlayerL+Bcursor
.notneg
	move.b	PlayerL+Bcursor,d0	;max Bcursor value
	cmp.b	PlayerL+max_select+1,d0
	ble	.notmax
	clr.b	PlayerL+Bcursor
.notmax
	move.w	PlayerL+max_input,d0
	cmp.b	PlayerL+Bcursor,d0
	ble	.control

	move.w	art_offset,d0
	add.b	PlayerL+Bcursor,d0
	move.b	PlayerL+Lcursor,d1
	cmp.b	#team,d1	;team value turns this function off
	beq.s	.control
	tst.b	PlayerL+bat_order	;don't change card while ordering
	bne	.control
	ext.w	d1
	move.l	#PlayerL,a0
	move.b	d0,(a0,d1.w)

;handle space char
	cmp.b	#91,(a0,d1.w)	;old space
	bne.s	.notspace
	move.b	#32,(a0,d1.w)	;new space
.notspace
.notletter

.control
BallcloneY
	tst.b	done+1
	bne	.control

;	tst.w	P2yinc	;don't change card while sliding
;	bne	.control


	move.w	tbx2,d0
	sub.w	PlayerR+TRACKY,d0

	cmp.w	#sensitive,d0
	blt.s	.noinc
	move.w	PlayerR+TRACKY,tbx2
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove	; Init Sounds System
	sub.b	#1,PlayerR+Bcursor
	jmp	.nodec
.noinc
	cmp.w	#-sensitive,d0
	bgt.s	.nodec
	move.w	PlayerR+TRACKY,tbx2
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove	; Init Sounds System
	add.b	#1,PlayerR+Bcursor
.nodec
	tst.b	PlayerR+Bcursor
	bpl	.notneg
	move.b	PlayerR+max_select+1,PlayerR+Bcursor
.notneg
	move.b	PlayerR+Bcursor,d0	;max Bcursor value
	cmp.b	PlayerR+max_select+1,d0
	ble	.notmax
	clr.b	PlayerR+Bcursor
.notmax
	move.w	PlayerR+max_input,d0
	cmp.b	PlayerR+Bcursor,d0
	ble	.control

	move.w	art_offset,d0
	add.b	PlayerR+Bcursor,d0
	move.b	PlayerR+Lcursor,d1
	cmp.b	#team,d1	;team value turns this function off
	beq.s	.control
	tst.b	PlayerR+bat_order	;don't change card while ordering
	bne	.control
	ext.w	d1
	move.l	#PlayerR,a0
	move.b	d0,(a0,d1.w)

;handle space char
	cmp.b	#91,(a0,d1.w)	;old space
	bne.s	.notspace
	move.b	#32,(a0,d1.w)	;new space
.notspace
.notletter

.control

	DELAY	#1
	jmp	BSlpY










;BallService2	;ball service for the Vs screen
	move.w	PlayerL+TRACKX,tbx1
	move.w	PlayerR+TRACKX,tbx2
BSlp2
	tst.b	done
	bne	.control

	move.w	tbx1,d0
	sub.w	PlayerL+TRACKX,d0

	cmp.w	#sensitive,d0
	blt.s	.noinc
	move.w	PlayerL+TRACKX,tbx1
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove	; Init Sounds System
	sub.b	#1,PlayerL+Bcursor
	move.b	#1,tb_moved
	jmp	.nodec
.noinc
	cmp.w	#-sensitive,d0
	bgt.s	.nodec
	move.w	PlayerL+TRACKX,tbx1

	SOUND	#AdjustableMenuMove,#AdjustableMenuMove	; Init Sounds System

	add.b	#1,PlayerL+Bcursor
	move.b	#1,tb_moved
.nodec
	cmp.b	#9,PlayerL+Bcursor
	bne	.notneg
	move.b	PlayerL+max_select+1,PlayerL+Bcursor
.notneg
	move.b	PlayerL+Bcursor,d0	;max Bcursor value
	cmp.b	PlayerL+max_select+1,d0
	ble	.notmax
	move.b	#10,PlayerL+Bcursor	;wrap to first pitcher card
.notmax
;	move.w	PlayerL+max_input,d0
;	cmp.b	PlayerL+Bcursor,d0
;	ble	.control
;
;	move.w	art_offset,d0
;	add.b	PlayerL+Bcursor,d0
;	move.b	PlayerL+Lcursor,d1
;	ext.w	d1
;	move.l	#PlayerL,a0
;	move.b	d0,(a0,d1.w)
.control
	DELAY	#1
	cmp.l	#PlayerL,pinfo
	beq	BSlp2

Ballclone2
	tst.b	done+1
	bne	.control

	move.w	tbx2,d0
	sub.w	PlayerR+TRACKX,d0

	cmp.w	#sensitive,d0
	blt.s	.noinc
	move.w	PlayerR+TRACKX,tbx2
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove	; Init Sounds System
	sub.b	#1,PlayerR+Bcursor
	move.b	#1,tb_moved
	jmp	.nodec
.noinc
	cmp.w	#-sensitive,d0
	bgt.s	.nodec
	move.w	PlayerR+TRACKX,tbx2
	SOUND	#AdjustableMenuMove,#AdjustableMenuMove	; Init Sounds System
	add.b	#1,PlayerR+Bcursor
	move.b	#1,tb_moved
.nodec
	cmp.b	#9,PlayerR+Bcursor
	bne	.notneg
	move.b	PlayerR+max_select+1,PlayerR+Bcursor
.notneg
	move.b	PlayerR+Bcursor,d0	;max Bcursor value
	cmp.b	PlayerR+max_select+1,d0
	ble	.notmax
	move.b	#10,PlayerR+Bcursor
.notmax
;	move.w	PlayerR+max_input,d0
;	cmp.b	PlayerR+Bcursor,d0
;	ble	.control
;
;	move.w	art_offset,d0
;	add.b	PlayerR+Bcursor,d0
;	move.b	PlayerR+Lcursor,d1
;	ext.w	d1
;	move.l	#PlayerR,a0
;	move.b	d0,(a0,d1.w)
.control

	DELAY	#1
	jmp	Ballclone2



InCursXY1			;input pointer xy's
	dc.w	15,240
	dc.w	15+43,240
	dc.w	15+43+43,240
	dc.w	150,217
	dc.w	142,239

	dc.w	384,255	;off screen
	dc.w	384,255	;off screen

InCursXY2
	dc.w	15+192,240
	dc.w	15+43+192,240
	dc.w	15+43+43+192,240
	dc.w	150+192,217
	dc.w	142+192,239

	dc.w	384,255	;off screen
	dc.w	384,255	;off screen


cusp	equ	6

finished
	sub.w	#1,TimeOut
	beq.s	.cdone	;times-up

	jsr	LoadPtrs
	tst.b	START(a5)
	beq.s	.nop1
	tst.b	done
	beq.s	.notdone
.nop1
	tst.b	START(a6)
	beq.s	.done
	tst.b	done+1
	beq.s	.notdone

.done

	tst.w	curtx
	bne.s	.nosnd
	SOUND	#JerseyOpen,#0
.nosnd

	cmp.w	#204,curtx
	beq	.cdone
	add.w	#cusp,curtx	;curtain out speed
	move.w	#1,d0
	rts		;return condition not done
.cdone
	move.w	#0,d0
	rts		;return condition done

.notdone

	cmp.w	#204,curtx
	bne.s	.nosnd2
	SOUND	#JerseyOpen,#0
.nosnd2

	tst.w	curtx
	beq	.nocurtin
	sub.w	#cusp,curtx	;curtain in speed
.nocurtin
	move.w	#1,d0
	rts		;return condition not done



enterSND	equ	22

Enter2

	tst.w	ButtonDelay
	bne	Edone


	tst.b	done+1
	bne	Edone
	SOUND	#SelectTeamButton,#SelectTeamButton	; Init Sounds System
	move.l	#PlayerR,a0
	move.l	#done+1,a1
	bra	Enter
Enter1

	tst.w	ButtonDelay
	bne	Edone


	tst.b	done
	bne	Edone
	SOUND	#SelectTeamButton,#SelectTeamButton	; Init Sounds System
	move.l	#PlayerL,a0
	move.l	#done,a1
Enter
	move.w	#BDelay,ButtonDelay	;delay next button

	cmp.b	#27,Bcursor(a0)
	bne.s	.noBS
;	tst.b	Lcursor(a0)
	cmp.b	#letters,Lcursor(a0)
	beq.s	Edone
	sub.b	#1,Lcursor(a0)
	rts
.noBS
;	cmp.b	#28,Bcursor(a0)	;at END char
	cmp.b	#month-1,Lcursor(a0)	;last initial entered
	bne.s	.noEND
	move.b	#1,(a1)
	rts
.noEND
	move.b	Lcursor(a0),d0
	add.b	#1,Lcursor(a0)
	cmp.b	#month,Lcursor(a0)
	bne.s	Edone
	sub.b	#1,Lcursor(a0)
	move.b	#28,Bcursor(a0)
Edone
	rts


Enter2M
;	tst.b	PlayerR+POWERUP
;	bne.s	.rts	;ignore if powerup
	tst.b	done+1
	bne.s	.rts
	SOUND	button_sound,button_sound
	move.b	#1,done+1
	move.b	#0,firstt

	move.b	#START2,d0
	jsr	SwitchState
	move.b	d0,stst2

.rts	rts

Enter1M
;	tst.b	PlayerL+POWERUP
;	bne.s	.rts	;ignore if powerup
	tst.b	done
	bne.s	.rts
	SOUND	button_sound,button_sound
	move.b	#1,done
	move.b	#1,firstt

	move.b	#START1,d0
	jsr	SwitchState
	move.b	d0,stst1

.rts	rts


;Enter2Dold
;	tst.b	done+1
;	bne	.rts
;	SOUND	#SelectTeamButton,#SelectTeamButton
;
;	cmp.b	#NumberOfTeamPlayers+players-1,PlayerR+Lcursor
;	beq	.done
;;turn off buttons and slide here
;	SWITCH	#BUTTON2_1,#81H,#0
;	SWITCH	#BUTTON2_2,#81H,#0
;	SWITCH	#BUTTON2_3,#81H,#0
;	SWITCH	#BUTTON2_4,#81H,#0
;	move.w	#4,P2yinc
;.SlideP2y
;	DELAY	#1
;	cmp.w	#84,P2y
;	blt	.SlideP2y
;	clr.w	P2yinc
;	clr.w	P2y
;	add.b	#1,PlayerR+Lcursor
;
;	jsr	Random
;	and.b	#00001111b,d0
;	move.b	PlayerR+Lcursor,d1
;	ext.w	d1
;	move.l	#PlayerR,a0
;	move.b	d0,(a0,d1.w)
;	move.b	d0,PlayerR+Bcursor
;	SWITCH	#BUTTON2_1,#81H,#Enter2D
;	SWITCH	#BUTTON2_2,#81H,#Enter2D
;	SWITCH	#BUTTON2_3,#81H,#Enter2D
;	SWITCH	#BUTTON2_4,#81H,#Enter2D
;.rts	rts

.done	move.b	#1,done+1
	rts


BDelay	equ	10
;ButDelay
;	tst.w	ButtonDelay
;	beq.s	.rts
;	POPL	d0	;no return
;	rts
;.rts	rts


Enter1D
	tst.w	ButtonDelay
	bne	rts1

	tst.b	done
	bne	rts1
	move.w	#DraftInputTime,DraftSelTime1
	SOUND	#SelectTeamButton,#SelectTeamButton

	cmp.b	#NumberOfTeamPlayers+players-1,PlayerL+Lcursor
	beq	done1
	cmp.b	#9+players-1,PlayerL+Lcursor ;pitcher select?
	bgt	Enter1Dnobat
;select batting order
	SWITCH	#BUTTON1_1,#81H,#Enter1Dbat
	SWITCH	#BUTTON1_2,#81H,#Enter1Dbat
	SWITCH	#BUTTON1_3,#81H,#Enter1Dbat
	SWITCH	#BUTTON1_4,#81H,#Enter1Dbat
	move.b	#1,PlayerL+bat_order
	move.b	#0,PlayerL+Bcursor

	move.w	#BDelay,ButtonDelay	;delay next button

	rts
Enter1Dbat
	tst.w	ButtonDelay
	bne	rts1

	move.l	#PlayerL,a5
	jsr	sel2pos
;store bat pos
	move.w	#DraftInputTime,DraftSelTime1
	move.b	PlayerL+Lcursor,d0
	ext.w	d0
	sub.b	#players,d0
	move.l	#PlayerL+bat_order+1,a0
	move.b	d1,(a0,d0.w)
Enter1Dnobat
	move.w	#NumberOfTeams-1,PlayerL+max_select
	move.w	#NumberOfTeams,PlayerL+max_input

;turn off buttons and slide here
	SWITCH	#BUTTON1_1,#81H,#0
	SWITCH	#BUTTON1_2,#81H,#0
	SWITCH	#BUTTON1_3,#81H,#0
	SWITCH	#BUTTON1_4,#81H,#0
	move.b	#0,PlayerL+bat_order
;	move.w	#4,P1yinc
;.SlideP1y
;	DELAY	#1
;	cmp.w	#84,P1y
;	blt	.SlideP1y
;	clr.w	P1yinc
	clr.w	P1y
	add.b	#1,PlayerL+Lcursor

	jsr	Random
	and.b	#00001111b,d0
	move.b	PlayerL+Lcursor,d1
	ext.w	d1
	move.l	#PlayerL,a0
	move.b	d0,(a0,d1.w)
	move.b	d0,PlayerL+Bcursor
	SWITCH	#BUTTON1_1,#81H,#Enter1D
	SWITCH	#BUTTON1_2,#81H,#Enter1D
	SWITCH	#BUTTON1_3,#81H,#Enter1D
	SWITCH	#BUTTON1_4,#81H,#Enter1D

	move.w	#BDelay,ButtonDelay	;delay next button

rts1	rts

done1	move.b	#1,done
	rts



Enter2D
	tst.w	ButtonDelay
	bne	rts2

	tst.b	done+1
	bne	rts2
	move.w	#DraftInputTime,DraftSelTime2
	SOUND	#SelectTeamButton,#SelectTeamButton

	cmp.b	#NumberOfTeamPlayers+players-1,PlayerR+Lcursor
	beq	done2
	cmp.b	#9+players-1,PlayerR+Lcursor
	bgt	Enter2Dnobat
;select batting order
	SWITCH	#BUTTON2_1,#81H,#Enter2Dbat
	SWITCH	#BUTTON2_2,#81H,#Enter2Dbat
	SWITCH	#BUTTON2_3,#81H,#Enter2Dbat
	SWITCH	#BUTTON2_4,#81H,#Enter2Dbat
	move.b	#1,PlayerR+bat_order
	move.b	#0,PlayerR+Bcursor

	move.w	#BDelay,ButtonDelay	;delay next button

	rts
Enter2Dbat
	tst.w	ButtonDelay
	bne	rts2

	move.l	#PlayerR,a5
	jsr	sel2pos
;store bat pos
	move.w	#DraftInputTime,DraftSelTime2
	move.b	PlayerR+Lcursor,d0
	ext.w	d0
	sub.b	#players,d0
	move.l	#PlayerR+bat_order+1,a0
	move.b	d1,(a0,d0.w)
Enter2Dnobat
	move.w	#NumberOfTeams-1,PlayerR+max_select
	move.w	#NumberOfTeams,PlayerR+max_input
;turn off buttons and slide here
	SWITCH	#BUTTON2_1,#81H,#0
	SWITCH	#BUTTON2_2,#81H,#0
	SWITCH	#BUTTON2_3,#81H,#0
	SWITCH	#BUTTON2_4,#81H,#0
	move.b	#0,PlayerR+bat_order
;	move.w	#4,P2yinc
;.SlideP2y
;	DELAY	#1
;	cmp.w	#84,P2y
;	blt	.SlideP2y
;	clr.w	P2yinc
	clr.w	P2y
	add.b	#1,PlayerR+Lcursor

	jsr	Random
	and.b	#00001111b,d0
	move.b	PlayerR+Lcursor,d1
	ext.w	d1
	move.l	#PlayerR,a0
	move.b	d0,(a0,d1.w)
	move.b	d0,PlayerR+Bcursor
	SWITCH	#BUTTON2_1,#81H,#Enter2D
	SWITCH	#BUTTON2_2,#81H,#Enter2D
	SWITCH	#BUTTON2_3,#81H,#Enter2D
	SWITCH	#BUTTON2_4,#81H,#Enter2D

	move.w	#BDelay,ButtonDelay	;delay next button

rts2	rts

done2	move.b	#1,done+1
	rts



Blinker
	clr.b	blinker
	DELAY	#5	;off blink time
	move.b	#$ff,blinker
	DELAY	#15	;on blink time
	jmp	Blinker


Monthstxt
	ds	0
	dc.b	"JAN",0
	dc.b	"FEB",0
	dc.b	"MAR",0
	dc.b	"APR",0
	dc.b	"MAY",0
	dc.b	"JUN",0
	dc.b	"JUL",0
	dc.b	"AUG",0
	dc.b	"SEP",0
	dc.b	"OCT",0
	dc.b	"NOV",0
	dc.b	"DEC",0
	dc.b	"   ",0
	ds	0

PlayerPostxt
	ds	0
            dc.b     "DH ",0
            dc.b     "C  ",0
            dc.b     "1B ",0
            dc.b     "2B ",0
            dc.b     "SS ",0
            dc.b     "3B ",0
            dc.b     "LF ",0
            dc.b     "CF ",0
            dc.b     "RF ",0
            dc.b     "P1 ",0
            dc.b     "P2 ",0
            dc.b     "P3 ",0
            dc.b     "P4 ",0
            dc.b     "R  ",0
            dc.b     "   ",0
            dc.b     "   ",0
	ds	0


daycnt	dc.b	31-1,29-1,31-1,30-1,31-1,30-1,31-1,31-1,30-1,31-1,30-1,31-1
;daycnt	dc.b	31-1,31-1,31-1,31-1,31-1,31-1,31-1,31-1,31-1,31-1,31-1,31-1
;feb was 28
LetterListAdjust
	dc.b	0,0 ;space
	dc.b	0,0 ;A
	dc.b	0,0 ;B
	dc.b	0,0 ;C
	dc.b	0,0 ;D
	dc.b	0,0 ;E
	dc.b	0,0 ;F
	dc.b	0,0 ;G
	dc.b	0,0 ;H
	dc.b	1,0 ;I
	dc.b	-5,0 ;J
	dc.b	-5,0 ;K
	dc.b	-4,0 ;L
	dc.b	-5,0 ;M
	dc.b	0,0 ;N
	dc.b	0,0 ;O
	dc.b	0,0 ;P
	dc.b	0,0 ;Q
	dc.b	0,0 ;R
	dc.b	0,0 ;S
	dc.b	0,0 ;T
	dc.b	0,0 ;U
	dc.b	0,0 ;V
	dc.b	-1,0 ;W
	dc.b	6,0 ;X
	dc.b	6,0 ;Y
	dc.b	5,0 ;Z
	dc.b	0,0 ;
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0
	dc.b	5,0 ;57 box
	dc.b	0,0
	dc.b	0,0
	dc.b	0,0


fnt1Spacing:
	dc.b	12		; Width
	dc.b	13		; Width
	dc.b	11		; Width
	dc.b	10		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	12		; Width
	dc.b	7		; Width
	dc.b	10		; Width
	dc.b	13		; Width
	dc.b	11		; Width
	dc.b	14		; Width
	dc.b	13		; Width
	dc.b	10		; Width
	dc.b	12		; Width
	dc.b	11		; Width
	dc.b	13		; Width
	dc.b	11		; Width
	dc.b	12		; Width
	dc.b	12		; Width
	dc.b	13		; Width
	dc.b	17		; Width
	dc.b	14		; Width
	dc.b	12		; Width
	dc.b	11		; Width
	dc.b	7		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	12		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	12		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	7		; Width
	dc.b	10		; Width
	dc.b	5		; Width
	dc.b	9		; Width
	dc.b	15		; Width
	dc.b	10		; Width
	dc.b	9		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	8		; Width
	dc.b	9		; Width
	dc.b	9		; Width
	dc.b	10		; Width
	dc.b	12		; Width
	dc.b	11		; Width
	dc.b	18		; Width


	dc.b	12		; Width
	dc.b	12		; Width
	dc.b	10		; Width
	dc.b	9		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	11		; Width
	dc.b	6		; Width
	dc.b	9		; Width
	dc.b	12		; Width
	dc.b	10		; Width
	dc.b	13		; Width
	dc.b	12		; Width
	dc.b	9		; Width
	dc.b	11		; Width
	dc.b	10		; Width
	dc.b	12		; Width
	dc.b	10		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	12		; Width
	dc.b	16		; Width
	dc.b	13		; Width
	dc.b	11		; Width
	dc.b	10		; Width
	dc.b	6		; Width
	dc.b	9		; Width
	dc.b	9		; Width
	dc.b	11		; Width
	dc.b	9		; Width
	dc.b	9		; Width
	dc.b	11		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	6		; Width
	dc.b	9		; Width
	dc.b	4		; Width
	dc.b	8		; Width
	dc.b	14		; Width
	dc.b	9		; Width
	dc.b	8		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	7		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	9		; Width
	dc.b	8		; Width
	dc.b	11		; Width
	dc.b	18		; Width

fnt2Spacing
	dc.b	20		; Width
	dc.b	23		; Width
	dc.b	20		; Width
	dc.b	17		; Width
	dc.b	20		; Width
	dc.b	20		; Width
	dc.b	20		; Width
	dc.b	18		; Width
	dc.b	21		; Width
	dc.b	13		; Width
	dc.b	18		; Width
	dc.b	22		; Width
	dc.b	19		; Width
	dc.b	25		; Width
	dc.b	23		; Width
	dc.b	19		; Width
	dc.b	20		; Width
	dc.b	20		; Width
	dc.b	22		; Width
	dc.b	19		; Width
	dc.b	22		; Width
	dc.b	22		; Width
	dc.b	22		; Width
	dc.b	31		; Width
	dc.b	24		; Width
	dc.b	21		; Width
	dc.b	21		; Width
	dc.b	13		; Width
	dc.b	19		; Width
	dc.b	18		; Width
	dc.b	20		; Width
	dc.b	18		; Width
	dc.b	18		; Width
	dc.b	20		; Width
	dc.b	18		; Width
	dc.b	18		; Width
	dc.b	19		; Width
	dc.b	9		; Width
	dc.b	8		; Width
	dc.b	9		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	12		; Width
	dc.b	16		; Width
	dc.b	9		; Width
	dc.b	15		; Width
	dc.b	25		; Width
	dc.b	19		; Width
	dc.b	15		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	16		; Width
	dc.b	16		; Width
	dc.b	16		; Width
	dc.b	16		; Width
	dc.b	19		; Width
	dc.b	18		; Width
	dc.b	19		; Width
	dc.b	17		; Width
	dc.b	21		; Width


	dc.b	17		; Width
	dc.b	21		; Width
	dc.b	18		; Width
	dc.b	15		; Width
	dc.b	18		; Width
	dc.b	18		; Width
	dc.b	18		; Width
	dc.b	16		; Width
	dc.b	19		; Width
	dc.b	11		; Width
	dc.b	16		; Width
	dc.b	20		; Width
	dc.b	17		; Width
	dc.b	23		; Width
	dc.b	21		; Width
	dc.b	17		; Width
	dc.b	18		; Width
	dc.b	18		; Width
	dc.b	20		; Width
	dc.b	17		; Width
	dc.b	20		; Width
	dc.b	20		; Width
	dc.b	20		; Width
	dc.b	29		; Width
	dc.b	22		; Width
	dc.b	19		; Width
	dc.b	19		; Width
	dc.b	11		; Width
	dc.b	17		; Width
	dc.b	16		; Width
	dc.b	18		; Width
	dc.b	16		; Width
	dc.b	16		; Width
	dc.b	18		; Width
	dc.b	16		; Width
	dc.b	16		; Width
	dc.b	17		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	10		; Width
	dc.b	14		; Width
	dc.b	7		; Width
	dc.b	13		; Width
	dc.b	23		; Width
	dc.b	17		; Width
	dc.b	13		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	13		; Width
	dc.b	17		; Width
	dc.b	16		; Width
	dc.b	17		; Width
	dc.b	21		; Width

fnt3Spacing:
	dc.b	7		; Width
	dc.b	9		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	8		; Width
	dc.b	5		; Width
	dc.b	7		; Width
	dc.b	8		; Width
	dc.b	6		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	8		; Width
	dc.b	7		; Width
	dc.b	9		; Width
	dc.b	11		; Width
	dc.b	8		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	5		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	4		; Width
	dc.b	6		; Width
	dc.b	9		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	8		; Width


	dc.b	7		; Width
	dc.b	8		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	4		; Width
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	5		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	8		; Width
	dc.b	10		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	4		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	3		; Width
	dc.b	3		; Width
	dc.b	3		; Width
	dc.b	3		; Width
	dc.b	3		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	3		; Width
	dc.b	5		; Width
	dc.b	8		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	8		; Width
;fnt4:

	dc.b	7		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	3		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	3		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	2		; Width
	dc.b	2		; Width
	dc.b	2		; Width
	dc.b	2		; Width
	dc.b	2		; Width
	dc.b	3		; Width
	dc.b	5		; Width
	dc.b	3		; Width
	dc.b	4		; Width
	dc.b	7		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	3		; Width
	dc.b	3		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	4		; Width
	dc.b	5		; Width
	dc.b	5		; Width


















;fnt1Spacing:
;	dc.b	11	; Width
;	dc.b	11	; Width a
;	dc.b	11	; Width b
;	dc.b	09	; Width c
;	dc.b	11	; Width d
;	dc.b	11	; Width e
;	dc.b	10	; Width f
;	dc.b	10	; Width g
;	dc.b	12	; Width h
;	dc.b	09	; Width i
;	dc.b	10	; Width j
;	dc.b	13	; Width k
;	dc.b	08	; Width l
;	dc.b	15	; Width m
;	dc.b	13	; Width n
;	dc.b	10	; Width o
;	dc.b	11	; Width p
;	dc.b	10	; Width q
;	dc.b	11	; Width r
;	dc.b	10	; Width s
;	dc.b	10	; Width t
;	dc.b	11	; Width u
;	dc.b	11	; Width v
;	dc.b	14	; Width w
;	dc.b	12	; Width x
;	dc.b	10	; Width y
;	dc.b	13	; Width z
;	dc.b	08-2	; Width
;	dc.b	11-2	; Width
;	dc.b	09	; Width
;	dc.b	11	; Width
;	dc.b	11	; Width
;	dc.b	10	; Width
;	dc.b	13	; Width
;	dc.b	10	; Width
;	dc.b	10	; Width
;	dc.b	09	; Width
;	dc.b	3	; Width
;	dc.b	6	; Width
;	dc.b	7	; Width
;	dc.b	4	; Width
;	dc.b	5	; Width
;	dc.b	6	; Width
;	dc.b	7	; Width
;	dc.b	9	; Width
;	dc.b	8	; Width
;	dc.b	9	; Width
;	dc.b	7	; Width
;	dc.b	6	; Width
;	dc.b	7	; Width
;	dc.b	6	; Width
;	dc.b	7	; Width
;	dc.b	7	; Width
;	dc.b	6	; Width
;	dc.b	11	; Width
;	dc.b	7	; Width
;	dc.b	10	; Width
;	ds	0

fnt2SpacingMONTH:
adj2	equ	-4
	dc.b	17	
	dc.b	17+adj2+1 ; Width of A
	dc.b	18+adj2 ; Width
	dc.b	16+adj2 ; Width
	dc.b	17+adj2 ; Width
	dc.b	18+adj2 ; Width
	dc.b	17+adj2 ; Width
	dc.b	17+adj2 ; Width
	dc.b	20+adj2 ; Width
	dc.b	13+adj2 ; Width
	dc.b	16+adj2 ; Width
	dc.b	21+adj2 ; Width
	dc.b	14+adj2 ; Width
	dc.b	24+adj2 ; Width
	dc.b	20+adj2 ; Width
	dc.b	16+adj2 ; Width
	dc.b	18+adj2 ; Width
	dc.b	16+adj2 ; Width
	dc.b	18+adj2 ; Width
	dc.b	16+adj2 ; Width
	dc.b	17+adj2 ; Width
	dc.b	19+adj2 ; Width
	dc.b	18+adj2 ; Width
	dc.b	24+adj2 ; Width
	dc.b	22+adj2 ; Width
	dc.b	17+adj2 ; Width
	dc.b	22+adj2 ; Width
	dc.b	13+adj2 ; Width
	dc.b	19+adj2 ; Width
	dc.b	16+adj2 ; Width
	dc.b	18+adj2 ; Width
	dc.b	19+adj2 ; Width
	dc.b	16+adj2 ; Width
	dc.b	21+adj2 ; Width
	dc.b	17+adj2 ; Width
	dc.b	17+adj2 ; Width
	dc.b	15+adj2 ; Width
	dc.b	6+adj2 ; Width
	dc.b	9+adj2 ; Width
	dc.b	10+adj2 ; Width
	dc.b	8+adj2 ; Width
	dc.b	9+adj2 ; Width
	dc.b	10+adj2 ; Width
	dc.b	11+adj2 ; Width
	dc.b	10+adj2 ; Width
	dc.b	12+adj2 ; Width
	dc.b	16+adj2 ; Width
	dc.b	13+adj2 ; Width
	dc.b	9+adj2 ; Width
	dc.b	11+adj2 ; Width
	dc.b	11+adj2 ; Width
	dc.b	11+adj2 ; Width
	dc.b	11+adj2 ; Width
	dc.b	10+adj2 ; Width
	dc.b	18+adj2 ; Width
	dc.b	13+adj2 ; Width
	dc.b	11+adj2 ; Width
	dc.b	22+adj2 ; Width
	dc.b	13+adj2 ; Width
	dc.b	13+adj2 ; Width

	ds	0

;fnt3Spacing:
;adj3	equ	2
;
;	dc.b	7+adj3		; Width 0
;	dc.b	6+adj3		; Width a
;	dc.b	6+adj3		; Width b
;	dc.b	5+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	5+adj3		; Width
;	dc.b	5+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	3+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	5+adj3		; Width
;	dc.b	8+adj3		; Width
;	dc.b	7+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	5+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	8+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	4+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	3+adj3		; Width
;	dc.b	4+adj3		; Width
;	dc.b	4+adj3		; Width
;	dc.b	3+adj3		; Width
;	dc.b	3+adj3		; Width
;	dc.b	4+adj3		; Width
;	dc.b	5+adj3		; Width
;	dc.b	3+adj3		; Width
;	dc.b	4+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	3+adj3		; Width
;	dc.b	3+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	7+adj3		; Width
;	dc.b	6+adj3		; Width
;	dc.b	7+adj3		; Width
;	dc.b	7+adj3		; Width
;	dc.b	8+adj3		; Width
;	dc.b	8+adj3		; Width
;	dc.b	8+adj3		; Width
	   

;OLD
	dc.b	11	; Width
	dc.b	11	; Width a
	dc.b	11	; Width b
	dc.b	09	; Width c
	dc.b	11	; Width d
	dc.b	11	; Width e
	dc.b	10	; Width f
	dc.b	10	; Width g
	dc.b	12	; Width h
	dc.b	09	; Width i
	dc.b	10	; Width j
	dc.b	13	; Width k
	dc.b	08	; Width l
	dc.b	15	; Width m
	dc.b	13	; Width n
	dc.b	10	; Width o
	dc.b	11	; Width p
	dc.b	10	; Width q
	dc.b	11	; Width r
	dc.b	10	; Width s
	dc.b	10	; Width t
	dc.b	11	; Width u
	dc.b	11	; Width v
	dc.b	14	; Width w
	dc.b	12	; Width x
	dc.b	10	; Width y
	dc.b	13	; Width z
	dc.b	08-2	; Width
	dc.b	11-2	; Width
	dc.b	09	; Width
	dc.b	11	; Width
	dc.b	11	; Width
	dc.b	10	; Width
	dc.b	13	; Width
	dc.b	10	; Width
	dc.b	10	; Width
	dc.b	09	; Width
	dc.b	3	; Width
	dc.b	6	; Width
	dc.b	7	; Width
	dc.b	4	; Width
	dc.b	5	; Width
	dc.b	6	; Width
	dc.b	7	; Width
	dc.b	9	; Width
	dc.b	8	; Width
	dc.b	9	; Width
	dc.b	7	; Width
	dc.b	6	; Width
	dc.b	7	; Width
	dc.b	6	; Width
	dc.b	7	; Width
	dc.b	7	; Width
	dc.b	6	; Width
	dc.b	11	; Width
	dc.b	7	; Width
	dc.b	10	; Width
	ds	0


fnt4Spacing:
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	2		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	6		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	5		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	6		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	3		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	2		; Width
	dc.b	2		; Width
	dc.b	2		; Width
	dc.b	2		; Width
	dc.b	2		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	2		; Width
	dc.b	4		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	4		; Width
	dc.b	3		; Width
	dc.b	3		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	5		; Width


	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	3		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	3		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	2		; Width
	dc.b	2		; Width
	dc.b	2		; Width
	dc.b	2		; Width
	dc.b	2		; Width
	dc.b	3		; Width
	dc.b	5		; Width
	dc.b	3		; Width
	dc.b	4		; Width
	dc.b	7		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	3		; Width
	dc.b	3		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	4		; Width
	dc.b	5		; Width
	dc.b	5		; Width

	ds	0





	dc.b	7                    ; Width
	dc.b	4                    ; Width a
	dc.b	4                    ; Width b
	dc.b	3                    ; Width c
	dc.b	4                    ; Width d
	dc.b	3                    ; Width e
	dc.b	3                    ; Width f
	dc.b	4                    ; Width g
	dc.b	4                    ; Width h
	dc.b	2                    ; Width i
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	3                    ; Width
	dc.b	6                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	5                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	6                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	3                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	2                    ; Width
	dc.b	2                    ; Width
	dc.b	2                    ; Width
	dc.b	2                    ; Width
	dc.b	2                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	2                    ; Width
	dc.b	4                    ; Width
	dc.b	6                    ; Width
	dc.b	5                    ; Width
	dc.b	4                    ; Width
	dc.b	3                    ; Width
	dc.b	3                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	4                    ; Width
	dc.b	6                    ; Width

	ds	0


fnt5Spacing:
	dc.b	36		; Width
	dc.b	45		; Width
	dc.b	39		; Width
	dc.b	35		; Width
	dc.b	38		; Width
	dc.b	38		; Width
	dc.b	37		; Width
	dc.b	35		; Width
	dc.b	41		; Width
	dc.b	24		; Width
	dc.b	35		; Width
	dc.b	43		; Width
	dc.b	37		; Width
	dc.b	50		; Width
	dc.b	44		; Width
	dc.b	36		; Width
	dc.b	38		; Width
	dc.b	39		; Width
	dc.b	42		; Width
	dc.b	35		; Width
	dc.b	42		; Width
	dc.b	43		; Width
	dc.b	45		; Width
	dc.b	60		; Width
	dc.b	46		; Width
	dc.b	41		; Width
	dc.b	40		; Width
	dc.b	24		; Width
	dc.b	36		; Width
	dc.b	35		; Width
	dc.b	38		; Width
	dc.b	35		; Width
	dc.b	35		; Width
	dc.b	38		; Width
	dc.b	35		; Width
	dc.b	35		; Width
	dc.b	36		; Width
	dc.b	15		; Width
	dc.b	16		; Width
	dc.b	16		; Width
	dc.b	15		; Width
	dc.b	16		; Width
	dc.b	25		; Width
	dc.b	34		; Width
	dc.b	20		; Width
	dc.b	29		; Width
	dc.b	48		; Width
	dc.b	36		; Width
	dc.b	29		; Width
	dc.b	19		; Width
	dc.b	19		; Width
	dc.b	30		; Width
	dc.b	30		; Width
	dc.b	30		; Width
	dc.b	32		; Width
	dc.b	38		; Width
	dc.b	35		; Width


	dc.b	36		; Width
	dc.b	36		; Width
	dc.b	36		; Width
	dc.b	30		; Width
	dc.b	35		; Width
	dc.b	34		; Width
	dc.b	33		; Width
	dc.b	32		; Width
	dc.b	40		; Width
	dc.b	27		; Width
	dc.b	32		; Width
	dc.b	40		; Width
	dc.b	26		; Width
	dc.b	49		; Width
	dc.b	41		; Width
	dc.b	32		; Width
	dc.b	36		; Width
	dc.b	31		; Width
	dc.b	36		; Width
	dc.b	32		; Width
	dc.b	31		; Width
	dc.b	37		; Width
	dc.b	37		; Width
	dc.b	48		; Width
	dc.b	44		; Width
	dc.b	35		; Width
	dc.b	43		; Width
	dc.b	27		; Width
	dc.b	35		; Width
	dc.b	31		; Width
	dc.b	35		; Width
	dc.b	37		; Width
	dc.b	32		; Width
	dc.b	43		; Width
	dc.b	33		; Width
	dc.b	32		; Width
	dc.b	30		; Width
	dc.b	10		; Width
	dc.b	16		; Width
	dc.b	20		; Width
	dc.b	15		; Width
	dc.b	17		; Width
	dc.b	18		; Width
	dc.b	20		; Width
	dc.b	19		; Width
	dc.b	24		; Width
	dc.b	30		; Width
	dc.b	24		; Width
	dc.b	16		; Width
	dc.b	20		; Width
	dc.b	20		; Width
	dc.b	20		; Width
	dc.b	21		; Width
	dc.b	19		; Width
	dc.b	35		; Width
	dc.b	22		; Width
	dc.b	33		; Width


	ds	0


neo0Spacing
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	4		; Width
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	9		; Width
	dc.b	8		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	9		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	8		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	5		; Width
	dc.b	7		; Width
	dc.b	4		; Width
	dc.b	6		; Width
	dc.b	8		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	4		; Width
	dc.b	4		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	7		; Width
neo1Spacing
	dc.b	11		; Width
	dc.b	19		; Width
	dc.b	13		; Width
	dc.b	19		; Width
	dc.b	19		; Width
	dc.b	20		; Width
	dc.b	19		; Width
	dc.b	19		; Width
	dc.b	18		; Width
	dc.b	20		; Width
	dc.b	19		; Width
	dc.b	19		; Width
	dc.b	19		; Width
	dc.b	19		; Width
	dc.b	18		; Width
	dc.b	19		; Width
	dc.b	13		; Width
	dc.b	18		; Width
	dc.b	19		; Width
	dc.b	8		; Width
	dc.b	11		; Width
	dc.b	19		; Width
	dc.b	9		; Width
	dc.b	27		; Width
	dc.b	18		; Width
	dc.b	19		; Width
	dc.b	19		; Width
	dc.b	19		; Width
	dc.b	13		; Width
	dc.b	18		; Width
	dc.b	13		; Width
	dc.b	18		; Width
	dc.b	19		; Width
	dc.b	27		; Width
	dc.b	20		; Width
	dc.b	19		; Width
	dc.b	16		; Width
	dc.b	29		; Width
	dc.b	9		; Width
	dc.b	9		; Width
	dc.b	9		; Width
	dc.b	7		; Width
	dc.b	11		; Width
	dc.b	18		; Width
	dc.b	9		; Width
	dc.b	19		; Width
	dc.b	29		; Width
	dc.b	24		; Width
	dc.b	16		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	16		; Width
	dc.b	17		; Width
	dc.b	17		; Width
	dc.b	12		; Width
	dc.b	16		; Width
neo2Spacing
	dc.b	8		; Width
	dc.b	14		; Width
	dc.b	10		; Width
	dc.b	14		; Width
	dc.b	15		; Width
	dc.b	15		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	15		; Width
	dc.b	15		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	10		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	6		; Width
	dc.b	8		; Width
	dc.b	14		; Width
	dc.b	7		; Width
	dc.b	20		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	10		; Width
	dc.b	14		; Width
	dc.b	11		; Width
	dc.b	13		; Width
	dc.b	14		; Width
	dc.b	19		; Width
	dc.b	14		; Width
	dc.b	13		; Width
	dc.b	12		; Width
	dc.b	21		; Width
	dc.b	8		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	9		; Width
	dc.b	13		; Width
	dc.b	7		; Width
	dc.b	15		; Width
	dc.b	21		; Width
	dc.b	17		; Width
	dc.b	12		; Width
	dc.b	9		; Width
	dc.b	9		; Width
	dc.b	13		; Width
	dc.b	12		; Width
	dc.b	12		; Width
	dc.b	9		; Width
	dc.b	12		; Width
neo3Spacing
	dc.b	7		; Width
	dc.b	11		; Width
	dc.b	7		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	10		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	10		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	7		; Width
	dc.b	11		; Width
	dc.b	10		; Width
	dc.b	6		; Width
	dc.b	7		; Width
	dc.b	11		; Width
	dc.b	6		; Width
	dc.b	15		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	8		; Width
	dc.b	11		; Width
	dc.b	8		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	15		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	9		; Width
	dc.b	15		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	5		; Width
	dc.b	7		; Width
	dc.b	10		; Width
	dc.b	6		; Width
	dc.b	11		; Width
	dc.b	15		; Width
	dc.b	13		; Width
	dc.b	9		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	7		; Width
	dc.b	5		; Width
neo4Spacing
	dc.b	6		; Width
	dc.b	9		; Width
	dc.b	6		; Width
	dc.b	9		; Width
	dc.b	9		; Width
	dc.b	9		; Width
	dc.b	9		; Width
	dc.b	9		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	9		; Width
	dc.b	9		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	9		; Width
	dc.b	9		; Width
	dc.b	7		; Width
	dc.b	9		; Width
	dc.b	8		; Width
	dc.b	5		; Width
	dc.b	6		; Width
	dc.b	8		; Width
	dc.b	5		; Width
	dc.b	11		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	9		; Width
	dc.b	9		; Width
	dc.b	6		; Width
	dc.b	9		; Width
	dc.b	7		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	11		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	7		; Width
	dc.b	12		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	5		; Width
	dc.b	4		; Width
	dc.b	6		; Width
	dc.b	8		; Width
	dc.b	5		; Width
	dc.b	9		; Width
	dc.b	12		; Width
	dc.b	10		; Width
	dc.b	7		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	6		; Width
	dc.b	7		; Width
neo5Spacing
	dc.b	10		; Width
	dc.b	16		; Width
	dc.b	10		; Width
	dc.b	18		; Width
	dc.b	19		; Width
	dc.b	22		; Width
	dc.b	17		; Width
	dc.b	16		; Width
	dc.b	18		; Width
	dc.b	17		; Width
	dc.b	18		; Width
	dc.b	14		; Width
	dc.b	17		; Width
	dc.b	14		; Width
	dc.b	20		; Width
	dc.b	16		; Width
	dc.b	13		; Width
	dc.b	15		; Width
	dc.b	16		; Width
	dc.b	11		; Width
	dc.b	10		; Width
	dc.b	14		; Width
	dc.b	11		; Width
	dc.b	23		; Width
	dc.b	19		; Width
	dc.b	17		; Width
	dc.b	17		; Width
	dc.b	18		; Width
	dc.b	15		; Width
	dc.b	15		; Width
	dc.b	12		; Width
	dc.b	18		; Width
	dc.b	14		; Width
	dc.b	22		; Width
	dc.b	17		; Width
	dc.b	15		; Width
	dc.b	14		; Width
	dc.b	24		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	8		; Width
	dc.b	7		; Width
	dc.b	13		; Width
	dc.b	16		; Width
	dc.b	8		; Width
	dc.b	15		; Width
	dc.b	24		; Width
	dc.b	21		; Width
	dc.b	13		; Width
	dc.b	14		; Width
	dc.b	13		; Width
	dc.b	23		; Width
	dc.b	22		; Width
	dc.b	21		; Width
	dc.b	18		; Width
	dc.b	17		; Width
neo6Spacing
	dc.b	9		; Width
	dc.b	13		; Width
	dc.b	9		; Width
	dc.b	15		; Width
	dc.b	15		; Width
	dc.b	17		; Width
	dc.b	14		; Width
	dc.b	13		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	15		; Width
	dc.b	13		; Width
	dc.b	14		; Width
	dc.b	13		; Width
	dc.b	17		; Width
	dc.b	13		; Width
	dc.b	11		; Width
	dc.b	12		; Width
	dc.b	14		; Width
	dc.b	10		; Width
	dc.b	9		; Width
	dc.b	11		; Width
	dc.b	9		; Width
	dc.b	18		; Width
	dc.b	16		; Width
	dc.b	13		; Width
	dc.b	14		; Width
	dc.b	15		; Width
	dc.b	12		; Width
	dc.b	12		; Width
	dc.b	10		; Width
	dc.b	15		; Width
	dc.b	12		; Width
	dc.b	18		; Width
	dc.b	15		; Width
	dc.b	12		; Width
	dc.b	12		; Width
	dc.b	20		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	7		; Width
	dc.b	11		; Width
	dc.b	13		; Width
	dc.b	7		; Width
	dc.b	13		; Width
	dc.b	20		; Width
	dc.b	17		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	18		; Width
	dc.b	18		; Width
	dc.b	17		; Width
	dc.b	15		; Width
	dc.b	14		; Width
neo7Spacing
	dc.b	6		; Width
	dc.b	10		; Width
	dc.b	7		; Width
	dc.b	12		; Width
	dc.b	12		; Width
	dc.b	14		; Width
	dc.b	11		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	10		; Width
	dc.b	11		; Width
	dc.b	10		; Width
	dc.b	11		; Width
	dc.b	10		; Width
	dc.b	12		; Width
	dc.b	10		; Width
	dc.b	8		; Width
	dc.b	9		; Width
	dc.b	10		; Width
	dc.b	8		; Width
	dc.b	6		; Width
	dc.b	9		; Width
	dc.b	7		; Width
	dc.b	14		; Width
	dc.b	12		; Width
	dc.b	10		; Width
	dc.b	11		; Width
	dc.b	11		; Width
	dc.b	10		; Width
	dc.b	9		; Width
	dc.b	8		; Width
	dc.b	12		; Width
	dc.b	10		; Width
	dc.b	13		; Width
	dc.b	11		; Width
	dc.b	10		; Width
	dc.b	9		; Width
	dc.b	15		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	6		; Width
	dc.b	8		; Width
	dc.b	10		; Width
	dc.b	6		; Width
	dc.b	10		; Width
	dc.b	15		; Width
	dc.b	14		; Width
	dc.b	8		; Width
	dc.b	9		; Width
	dc.b	9		; Width
	dc.b	14		; Width
	dc.b	14		; Width
	dc.b	13		; Width
	dc.b	12		; Width
	dc.b	11		; Width

	.align	2

	.struct
playballX	ds.w	1
enteriniX	ds.w	1
draftX	ds.w	1
oppX	ds.w	1
YNDscrn	ds.w	1
YNDcursorX	ds.w	1
YNDarrow	ds.w	1
YNDscrnX	ds.w	1
YNDscrnY	ds.w	1

scrn03	ds.w	1
scrn03X	ds.w	1
scrn03Y	ds.w	1
LETarray	ds.l	1
LETarrow	ds.w	1

scrn04	ds.w	1
scrn04X	ds.w	1
scrn04Y	ds.w	1
MONarray	ds.l	1
MONarrow	ds.w	1

scrn05	ds.w	1
scrn05X	ds.w	1
scrn05Y	ds.w	1
DAYarray	ds.l	1
DAYarrow	ds.w	1

dfmessX	ds.w	1

drcostX	ds.w	1

m29X	ds.w	1
m30X	ds.w	1
m31X	ds.w	1

	.endstruct

LeftData
	dc.w	51
	dc.w	33
	dc.w	39
	dc.w	56
	dc.w	scrn02a
	dc.w	20
	dc.w	arrowa4
	dc.w	33
	dc.w	5

	dc.w	scrn03a
	dc.w	7
	dc.w	5
	dc.l	LETxyA
	dc.w	cursora1

	dc.w	scrn04a
	dc.w	7
	dc.w	5
	dc.l	MONxyA
	dc.w	cursora2

	dc.w	scrn05a
	dc.w	7
	dc.w	5
	dc.l	DAYxyA
	dc.w	cursora3

	dc.w	49

	dc.w	60

	dc.w	99
	dc.w	122
	dc.w	147

RightData
	dc.w	242
	dc.w	224
	dc.w	230
	dc.w	247
	dc.w	scrn02b
	dc.w	211
	dc.w	arrowb4
	dc.w	224
	dc.w	2

	dc.w	scrn03b
	dc.w	201
	dc.w	2
	dc.l	LETxyB
	dc.w	cursorb1

	dc.w	scrn04b
	dc.w	201
	dc.w	2
	dc.l	MONxyB
	dc.w	cursorb2

	dc.w	scrn05b
	dc.w	201
	dc.w	2
	dc.l	DAYxyB
	dc.w	cursorb3

	dc.w	241

	dc.w	60+192

	dc.w	290
	dc.w	313
	dc.w	338

	.align	2

	end


