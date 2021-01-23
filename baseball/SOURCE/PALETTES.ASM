;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************
	.region.s	"RAM"
	ds	0

palnumber	  ds.w	1
colordata	  ds.l	1
dimplayer	  ds.w	1
dimplayer2	  ds.w	1
dim_percent  ds.w	1
dim_percent2 ds.w	1
tmpa0	  ds.l	1
HomeTeamNum  ds.w	1
AwayTeamNum  ds.w	1
start	  ds.b	1
;***************************************************************************
;***************************************************************************
       	.region	"RomCode"

	.export	LoadAllPals,SetHomePal,LoadCardPals
;	.export	FontSkullClr
	.export	HomeTeamNum,AwayTeamNum
	.import	ClearPalette,PlayerR,PlayerL
	.import	firstteam,start_state1,start_state2
	.import	HomePlayer,AwayPlayer
	.include	"pals.h"
	.include	"graphlib.mac"
	.include	"itvideo2.h"
	.include	"ramblock.h"
	.include	"sys.mac"

LOWER	equ	0
UPPER	equ	1

ALL	equ	0
HALF	equ	2

DEFPAL:	macro	colors,start,palette,num
	dc.l	colors
	dc.b	start|num,palette
	endm



LoadAttractPal:
LoadAllPals:
	LOADPAL	#BallPal,#0,#P_BALL,#255
	LOADPAL	#BallPal,#0,#P_ZONE,#255

	LOADPAL	#field,#0,#P_FIELD,#255
           LOADPAL   #TestFPal,#0,#P_TESTF,#255
	LOADPAL	#View6Pal,#0,#P_V6,#255
           LOADPAL	#bigfield,#0,#P_BIGFIELD,#255
           LOADPAL	#bigfld2,#0,#P_BIGFIELD2,#255
           LOADPAL	#bigfld3,#0,#P_BIGFIELD3,#255
	LOADPAL	#SkyPal,#0,#P_STADIUM,#255

	LOADPAL	#Stands,#0,#P_STANDS,#255

	LOADPAL #BatPal,#0,#P_BAT,#255
;           LOADPAL #FirstPal,#0,#P_FIRST,#255
           LOADPAL #vintage,#0,#P_VINTAGE,#255
;           LOADPAL #winxpal,#0,#P_WINX,#255
;           LOADPAL #wincpal,#0,#P_WINC,#255
           LOADPAL #RadPal,#0,#P_RADCARD,#255
;           LOADPAL #CardPal,#0,#P_CARD,#255
           LOADPAL #BordPal,#0,#P_BORDPAL,#255
           LOADPAL #DimPPal,#0,#P_DIMPPAL,#255
	
;	LOADPAL	#title1,#0,#P_TITLE1,#255
;	LOADPAL	#title2,#0,#P_TITLE2,#255
;	LOADPAL	#title3,#0,#P_TITLE3,#255
;	LOADPAL	#title4,#0,#P_TITLE4,#255
;	LOADPAL	#title5,#0,#P_TITLE5,#255
;	LOADPAL	#title6,#0,#P_TITLE6,#255
;	LOADPAL	#ttlsepal,#0,#P_TTLSE,#255


           LOADPAL  #titlerb,#0,#P_TITLERB,#255
           LOADPAL  #titlebk1,#0,#P_TITLEBK1,#255
           LOADPAL  #titlebk2,#0,#P_TITLEBK2,#255
           LOADPAL  #titleblu,#0,#P_TITLEBLU,#255
           LOADPAL  #titlebrn,#0,#P_TITLEBRN,#255
           LOADPAL  #titlegrn,#0,#P_TITLEGRN,#255
           LOADPAL  #gate,#0,#P_GATE,#255
	LOADPAL	#powerdim,#0,#P_POWERDIM,#255

;	LOADPAL	#Stands,#0,#P_BACKDROP,#255

;	LOADPAL	#backdrop,#0,#P_BACKDROP,#255

           LOADPAL #fire,#0,#P_FIRE,#255
	LOADPAL	#newscore,#0,#P_NEWSCORE,#255


	LOADPAL	#bak1apal,#0,#P_BAK1APAL,#255
	LOADPAL	#bak1bpal,#0,#P_BAK1BPAL,#255
	LOADPAL	#bakd4pal,#0,#P_BAKD4PAL,#255
;	LOADPAL	#fontdpal,#0,#P_FONTDPAL,#255

	LOADPAL	#blackpal,#0,#P_BLACKPAL,#255
;	LOADPAL	#head3d,#0,#P_HEAD3D,#255

	LOADPAL	#itlogo,#0,#P_ITLOGO,#255

	
	LOADPAL	#markcl,#0,#P_MARKCL,#255

	LOADPAL	#sopal,#0,#P_SO,#255

	LOADPAL	#stout01,#0,#P_STOUT01,#255	;bri
	LOADPAL	#lite0,#0,#P_LITE0,#255	;bri
	LOADPAL	#playedrd,#0,#P_PLAYEDRD,#255 ;bri
	LOADPAL	#playedbl,#0,#P_PLAYEDBL,#255 ;bri

	LOADPAL	#scorepal,#0,#P_SCORE,#255
	LOADPAL	#scoreb,#0,#P_SCOREB,#255
          	LOADPAL	#meter2a,#0,#P_METER,#255
;	LOADPAL	#rfontpal,#0,#P_FONTRED,#255
;	LOADPAL	#gfontpal,#0,#P_FONTGRN,#255
;	LOADPAL	#bfontpal,#0,#P_FONTBLU,#255
	LOADPAL	#homer1,#0,#P_HOMER1,#255
	LOADPAL	#dimcard,#0,#P_DIMCARD,#255
	LOADPAL	#dust,#0,#P_DUST,#255
	LOADPAL	#sabr,#0,#P_SABR,#255
	LOADPAL	#club,#0,#P_CLUB,#255
	LOADPAL	#batpt,#0,#P_BATPT,#255

	LOADPAL	#gradienb,#0,#P_GRADB,#255
	LOADPAL	#basemeter,#0,#P_BASEOMETER,#255
	LOADPAL	#celeb01,#0,#P_CELEB01,#255

	LOADPAL	#green,#0,#P_GREEN,#255
	LOADPAL	#ballpurp,#0,#P_PURP,#255

	LOADPAL	#fire0001,#0,#P_FIREWORKS1,#255
	LOADPAL	#spka0001,#0,#P_FIREWORKS2,#255

	LOADPAL	#shota,#0,#P_SHOTA,#255
	LOADPAL	#shotb,#0,#P_SHOTB,#255

	LOADPAL	#mlb,#0,#P_MLB,#255
	LOADPAL	#mlbm,#0,#P_MLBM,#255
	LOADPAL	#mlbpa,#0,#P_MLBPA,#255
	LOADPAL	#hawk,#0,#P_HAWK,#255
	LOADPAL	#logowor,#0,#P_LOGOWOR,#255

;LOGOS LOGOS LOGOS
	LOADPAL	#anglpal,#0,#P_LOGOANG,#255
	LOADPAL	#astlpal,#0,#P_LOGOAST,#255
	LOADPAL	#athlpal,#0,#P_LOGOATH,#255
	LOADPAL	#blulpal,#0,#P_LOGOBLU,#255
	LOADPAL	#bralpal,#0,#P_LOGOBRA,#255
	LOADPAL	#brelpal,#0,#P_LOGOBRE,#255
	LOADPAL	#carlpal,#0,#P_LOGOCAR,#255
	LOADPAL	#cinlpal,#0,#P_LOGOCIN,#255
	LOADPAL	#cublpal,#0,#P_LOGOCUB,#255
	LOADPAL	#dodlpal,#0,#P_LOGODOD,#255
	LOADPAL	#explpal,#0,#P_LOGOEXP,#255
	LOADPAL	#flolpal,#0,#P_LOGOFLO,#255
	LOADPAL	#gialpal,#0,#P_LOGOGIA,#255
	LOADPAL	#indlpal,#0,#P_LOGOIND,#255
	LOADPAL	#marlpal,#0,#P_LOGOMAR,#255
	LOADPAL	#metlpal,#0,#P_LOGOMET,#255
	LOADPAL	#orilpal,#0,#P_LOGOORI,#255
	LOADPAL	#padlpal,#0,#P_LOGOPAD,#255
	LOADPAL	#philpal,#0,#P_LOGOPHI,#255
	LOADPAL	#pirlpal,#0,#P_LOGOPIR,#255
	LOADPAL	#ranlpal,#0,#P_LOGORAN,#255
	LOADPAL	#redlpal,#0,#P_LOGORED,#255
	LOADPAL	#roclpal,#0,#P_LOGOROC,#255
	LOADPAL	#roylpal,#0,#P_LOGOROY,#255
	LOADPAL	#tiglpal,#0,#P_LOGOTIG,#255
	LOADPAL	#twilpal,#0,#P_LOGOTWI,#255
	LOADPAL	#whilpal,#0,#P_LOGOWHI,#255
	LOADPAL	#yanlpal,#0,#P_LOGOYAN,#255
	LOADPAL	#marker,#0,#P_MARKER,#255

;	LOADPAL	#p_fontr1,#0,#P_FONTR1,#255
	LOADPAL	#trophypal,#0,#P_TROPHY,#255
	LOADPAL	#p_fontr2,#0,#P_FONTR2,#255
;	LOADPAL	#p_fontb1,#0,#P_FONTB1,#255
	LOADPAL	#p_fontb2,#0,#P_FONTB2,#255
	LOADPAL	#p_fontw1,#0,#P_FONTW1,#255
	LOADPAL	#p_fontw2,#0,#P_FONTW2,#255
	LOADPAL	#p_fonty1,#0,#P_FONTY1,#255
;	LOADPAL	#p_fonty2,#0,#P_FONTY2,#255
 	LOADPAL	#Nfonty4,#0,#P_NEOYEL,#255
	LOADPAL	#Nfontr4,#0,#P_NEORED,#255
	LOADPAL	#Nfontb4,#0,#P_NEOBLU,#255

	bra	SkipTeams



	.export	LoadTicketPals
LoadTicketPals
            LOADPAL  #sopal,#0,#P_SO,#255
            LOADPAL  #blueso,#0,#P_BLUESO,#255
;            LOADPAL  #tickrddm,#0,#P_TICKRDDM,#255
;            LOADPAL  #tickbldm,#0,#P_TICKBLDM,#255
	rts

LoadCardPals
pldel	equ	1
	LOADPAL	#C_BRAV,#0,#P_BRAV,#255
	LOADPAL	#C_ORIO,#0,#P_ORIO,#255
	DELAY	#pldel
	LOADPAL	#C_REDX,#0,#P_REDX,#255
	LOADPAL	#C_ANGE,#0,#P_ANGE,#255
	DELAY	#pldel
	LOADPAL	#C_CUBS,#0,#P_CUBS,#255
	LOADPAL	#C_WHIT,#0,#P_WHIT,#255
	DELAY	#pldel
	LOADPAL	#C_REDS,#0,#P_REDS,#255
	LOADPAL	#C_INDI,#0,#P_INDI,#255
	DELAY	#pldel
	LOADPAL	#C_ROCK,#0,#P_ROCK,#255
	LOADPAL	#C_TIGE,#0,#P_TIGE,#255
	DELAY	#pldel
	LOADPAL	#C_MARL,#0,#P_MARL,#255
	LOADPAL	#C_ASTR,#0,#P_ASTR,#255
	DELAY	#pldel
	LOADPAL	#C_ROYA,#0,#P_ROYA,#255
	LOADPAL	#C_DODG,#0,#P_DODG,#255
	DELAY	#pldel
	LOADPAL	#C_BREW,#0,#P_BREW,#255
	LOADPAL	#C_TWIN,#0,#P_TWIN,#255
	DELAY	#pldel
	LOADPAL	#C_EXPO,#0,#P_EXPO,#255
	LOADPAL	#C_METS,#0,#P_METS,#255
	DELAY	#pldel
	LOADPAL	#C_YANK,#0,#P_YANK,#255
	LOADPAL	#C_ATHL,#0,#P_ATHL,#255
	DELAY	#pldel
	LOADPAL	#C_PHIL,#0,#P_PHIL,#255
	LOADPAL	#C_PIRA,#0,#P_PIRA,#255
	DELAY	#pldel
	LOADPAL	#C_CARD,#0,#P_CARI,#255
	LOADPAL	#C_PADR,#0,#P_PADR,#255
	DELAY	#pldel
	LOADPAL	#C_GIAN,#0,#P_GIAN,#255
	LOADPAL	#C_MARI,#0,#P_MARI,#255
	DELAY	#pldel
	LOADPAL	#C_RANG,#0,#P_RANG,#255
	LOADPAL	#C_BLUE,#0,#P_BLUE,#255
	LOADPAL	#C_DESI,#0,#P_DESI,#255

	clr.l	d0
	move.b	PlayerL+team,d0
	LOADPAL	<(logopals,d0*4)>,#0,#P_LOGOLEFT,#255

	clr.l	d0
	move.b	PlayerR+team,d0
	LOADPAL	<(logopals,d0*4)>,#0,#P_LOGORIGHT,#255

	rts		 

logopals
	dc.l	bralpal
	dc.l	orilpal
	dc.l	redlpal
	dc.l	anglpal
	dc.l	cublpal
	dc.l	whilpal
	dc.l	cinlpal
	dc.l	indlpal
	dc.l	roclpal
	dc.l	tiglpal
	dc.l	flolpal
	dc.l	astlpal
	dc.l	roylpal
	dc.l	dodlpal
	dc.l	brelpal
	dc.l	twilpal
	dc.l	explpal
	dc.l	metlpal
	dc.l	yanlpal
	dc.l	athlpal
	dc.l	philpal
	dc.l	pirlpal
	dc.l	carlpal
	dc.l	padlpal
	dc.l	gialpal
	dc.l	marlpal
	dc.l	ranlpal
	dc.l	blulpal

	dc.l	p_fontr2	;draft logo palette




;*************************************************************************
;* Set up HomeTeam Palettes as Batter                                    *
;*************************************************************************

SetHomePal:
;	clr.w	a0
	clr.w	HomeTeamNum
	clr.w	AwayTeamNum
;	cmpi.b	#0,firstteam                ;Who was first to pick?
;	bne.s	Plyr2Home	;Go to player 2 home palette
;	move.l	#p1info,a0	; Load Teamnumber for pl 1
	move.b	start_state1,start
;	bra	DoneHome	;branch to home colors
Plyr2Home:	
;	move.l	#p2info,a0	; Load Teamnumber for pl 2
	move.b	start_state2,start

DoneHome:	
;	move.b	team(a0),d0	;move team number to d0
; 	move.b	team(a0),HomeTeamNum
	move.w	([HomePlayer],TEAMNUMBER),d0 	;team number
	move.w	([HomePlayer],TEAMNUMBER),HomeTeamNum 	;team number

	move.l	#HomeColors,a2	; Load Address Of Palettes Table
	asl.w	#4,d0	; by 4
	lea	(a2,d0.w),a2	; Load Palette Address
	move.l	(a2)+,a0	;For the Head

	move.l	a0,tmpa0	;For the White Head/Brown
	move.w	#0,d0	; from 0 
	move.w	#256,d1	; to 256
	move.w	#P_HHATPAL00,d2	;put into Home Hat Pal
	jsr	LoadPalette	;load the palette
	DELAY	#1

	move.l	tmpa0,a0	;For the White Head/Blond
	move.w	#0,d0	; from 0 
	move.w	#256,d1	; to 256
	move.w	#P_HHATPAL01,d2	;put into Home Hat Pal
	jsr	LoadPalette	;load the palette

	move.l	tmpa0,a0	;For the blond Head
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_HHATPAL02,d2
	jsr	LoadPalette

;
;	move.l	tmpa0,a0	;For the Hispanic Head
;	move.w	#0,d0
;	move.w	#256,d1
;	move.w	#P_HHATPAL01,d2
;	jsr	LoadPalette
;
;	move.l	tmpa0,a0	;For the Black Head
;	move.w	#0,d0
;	move.w	#256,d1
;	move.w	#P_HHATPAL02,d2
;	jsr	LoadPalette
;
  	move.l	#ghead,a0
	move.w	#0,d0
;CHRIS	move.w	#256,d1	;was 191 168
	move.w	#175,d1	;was 191 168
   	move.w	#P_HHATPAL01,d2
	jsr	LoadPalette
	
  	move.l	#bhead,a0
	move.w	#0,d0
	move.w	#184,d1	;was 191 168
   	move.w	#P_HHATPAL02,d2	;Generic Head Pal
	jsr	LoadPalette

  	move.l	#ghead,a0
	move.w	#0,d0
	move.w	#175,d1	;was 191 168
   	move.w	#P_HHATPAL02,d2	;Generic Head Pal
	jsr	LoadPalette
	
;
;  	move.l	#hedhar04,a0 	;White/Brown
;	move.w	#214,d0
;	move.w	#9,d1
;   	move.w	#P_HHATPAL00,d2
;	jsr	LoadPalette
;
;  	move.l	#hedskn00,a0 	;white/Blond
;	move.w	#0,d0
;	move.w	#191,d1
;   	move.w	#P_HHATPAL03,d2
;	jsr	LoadPalette
;	
;	move.l	#hedhar03,a0	 ;White/Blond
;	move.w	#214,d0
;	move.w	#9,d1
;   	move.w	#P_HHATPAL03,d2
;	jsr	LoadPalette
;
;
;	move.l	#hedskn01,a0	  
;	move.w	#0,d0
;	move.w	#191,d1
;   	move.w	#P_HHATPAL01,d2
;	jsr	LoadPalette
;	
;  	move.l	#hedhar04,a0
;	move.w	#214,d0
;	move.w	#9,d1
;   	move.w	#P_HHATPAL01,d2
;	jsr	LoadPalette
;
;      	move.l	#hedskn02,a0
;	move.w	#0,d0
;	move.w	#191,d1
;   	move.w	#P_HHATPAL02,d2
;	jsr	LoadPalette
;
;  	move.l	#hedhar02,a0
;	move.w	#214,d0
;	move.w	#9,d1
;   	move.w	#P_HHATPAL02,d2
;	jsr	LoadPalette

       	move.l	(a2)+,a0	;For the top
	move.l	a0,tmpa0
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_HOMETPAL00,d2
	jsr	LoadPalette
	DELAY	#1

	move.l	tmpa0,a0
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_HOMETPAL01,d2
	jsr	LoadPalette
	DELAY	#1

          	move.l	tmpa0,a0
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_HOMETPAL02,d2
	jsr	LoadPalette

       	move.l	(a2)+,a0	;For the Bottoms
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_HOMEBPAL,d2
	jsr	LoadPalette
	DELAY	#1

	cmpi.b	#1,start
	bne.s	NoStart

	move.w	HomeTeamNum,d0	
	move.l	#AltColors,a2	; Load Address Of Palettes Table
	asl.w	#2,d0
	lea	(a2,d0.w),a2	; Load Palette Address

	move.l	(a2)+,a0	;For the top
	move.l	a0,tmpa0

	cmp.l	#0,a0    	;If No Alternate Palette
	beq	NoStart

	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_HOMETPAL00,d2
	jsr	LoadPalette
	move.l	tmpa0,a0
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_HOMETPAL01,d2
	jsr	LoadPalette
          	move.l	tmpa0,a0
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_HOMETPAL02,d2
	jsr	LoadPalette
	DELAY	#1



NoStart:
	move.l	#topskn00,a0	;For the top
	move.w	#37,d0
	move.w	#53,d1
	move.w	#P_HOMETPAL00,d2
	jsr	LoadPalette

      	move.l	#topskn01,a0	;For the top
	move.w	#37,d0
	move.w	#53,d1
	move.w	#P_HOMETPAL01,d2
	jsr	LoadPalette
	DELAY	#1

      	move.l	#topskn02,a0	;For the top
	move.w	#37,d0
	move.w	#53,d1
	move.w	#P_HOMETPAL02,d2
	jsr	LoadPalette


;       	move.l	(a2)+,a0	;For the Bottoms
;	move.w	#0,d0
;	move.w	#256,d1
;	move.w	#P_HOMEBPAL,d2
;	jsr	LoadPalette

;	cmpi.b	#1,start_state1
;	bne.s	NoStart

;	move.l	#p1info,a0	; Load Teamnumber
;	move.b	team(a0),d0	
;	move.l	#AltColors,a2	; Load Address Of Palettes Table
;	asl.w	#2,d0
;	lea	(a2,d0.w),a2	; Load Palette Address
;
;	move.l	(a2)+,a0	;For the top

;	cmp.l	#0,a0    	;If No Alternate Palette
;	beq	NoStart
;
;	move.w	#0,d0
;	move.w	#256,d1
;	move.w	#P_HOMETPAL00,d2
;	jsr	LoadPalette



;NoStart:

;*************************************************************************
;* Set up AwayTeam Palettes as Pitcher                                   *
;*************************************************************************

SetAwayPal:
;	cmpi.b	#0,firstteam
;	beq	Plyr2Away
;	move.l	#p1info,a0	; Load Teamnumber
;	move.b	start_state1,start
;	bra	DoneAway
	
Plyr2Away:	
;	move.l	#p2info,a0	; Load Teamnumber
;	move.b	start_state2,start

DoneAway:	
;	move.b	team(a0),d0	
	move.w	([AwayPlayer],TEAMNUMBER),d0 	;team number
	move.w	([AwayPlayer],TEAMNUMBER),AwayTeamNum 	;team number
;	move.b	team(a0),AwayTeamNum

	move.l	#AwayColors,a2	; Load Address Of Palettes Table
	asl.w	#4,d0
	lea	(a2,d0.w),a2	; Load Palette Address
	move.l	(a2)+,a0	;For the Head
   
	move.l	a0,tmpa0	;White head
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_VHATPAL00,d2
	jsr	LoadPalette
	DELAY	#1

	move.l	tmpa0,a0	;White head/Blond
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_VHATPAL01,d2
	jsr	LoadPalette

  	move.l	tmpa0,a0	;For the blond Head
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_VHATPAL02,d2
	jsr	LoadPalette
	
	
;
;
;  	move.l	tmpa0,a0	;For the hispanic Head
;	move.w	#0,d0
;	move.w	#256,d1
;	move.w	#P_VHATPAL01,d2
;	jsr	LoadPalette
;
;	move.l	tmpa0,a0	;For the Black Head
;	move.w	#0,d0
;	move.w	#256,d1
;	move.w	#P_VHATPAL02,d2
;	jsr	LoadPalette
;
	move.l	#ghead,a0
	move.w	#0,d0
;CHRIS	move.w	#168,d1          ;was 192
	move.w	#175,d1          ;was 192
   	move.w	#P_VHATPAL01,d2
	jsr	LoadPalette

  	move.l	#bhead,a0
	move.w	#0,d0
	move.w	#184,d1	;was 191 168
   	move.w	#P_VHATPAL02,d2	;Generic Head Pal
	jsr	LoadPalette

  	move.l	#ghead,a0
	move.w	#0,d0
	move.w	#175,d1	;was 191 168
   	move.w	#P_VHATPAL02,d2	;Generic Blond Pal
	jsr	LoadPalette
	
;
;	move.l	#hedhar04,a0
;	move.w	#214,d0
;	move.w	#9,d1
;   	move.w	#P_VHATPAL00,d2
;	jsr	LoadPalette
;
;	move.l	#hedskn00,a0
;	move.w	#0,d0
;	move.w	#192,d1
;   	move.w	#P_VHATPAL03,d2
;	jsr	LoadPalette
;
;	move.l	#hedhar03,a0
;	move.w	#214,d0
;	move.w	#9,d1
;   	move.w	#P_VHATPAL03,d2
;	jsr	LoadPalette
;
;	move.l	#hedskn01,a0
;	move.w	#0,d0
;	move.w	#192,d1
;   	move.w	#P_VHATPAL01,d2
;	jsr	LoadPalette
;
;  	move.l	#hedhar04,a0
;	move.w	#214,d0
;	move.w	#9,d1
;   	move.w	#P_VHATPAL01,d2
;	jsr	LoadPalette
;		            
;	move.l	#hedskn02,a0
;	move.w	#0,d0
;	move.w	#192,d1
;   	move.w	#P_VHATPAL02,d2
;	jsr	LoadPalette
;
;	move.l	#hedhar02,a0
;	move.w	#214,d0
;	move.w	#9,d1
;   	move.w	#P_VHATPAL02,d2
;	jsr	LoadPalette

	move.l	(a2)+,a0	;For the top
	move.l	a0,tmpa0
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_VISTPAL00,d2
	jsr	LoadPalette

	move.l	tmpa0,a0
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_VISTPAL01,d2
	jsr	LoadPalette
	DELAY	#1

          	move.l	tmpa0,a0
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_VISTPAL02,d2
	jsr	LoadPalette

	move.l	(a2)+,a0	;For the Bottoms
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_VISBPAL,d2
	jsr	LoadPalette
	DELAY	#1


	bra	NoStart2
	cmpi.b	#1,start

	bne.s	NoStart2

	move.w	AwayTeamNum,d0	
	move.l	#AltColors,a2	; Load Address Of Palettes Table
	asl.w	#2,d0
	lea	(a2,d0.w),a2	; Load Palette Address

	move.l	(a2)+,a0	;For the top
	move.l	a0,tmpa0

	cmp.l	#0,a0    	;If No Alternate Palette
	beq	NoStart2

	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_VISTPAL00,d2
	jsr	LoadPalette
	move.l	tmpa0,a0
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_VISTPAL01,d2
	jsr	LoadPalette
          	move.l	tmpa0,a0
	move.w	#0,d0
	move.w	#256,d1
	move.w	#P_VISTPAL02,d2
	jsr	LoadPalette
	DELAY	#1

NoStart2:
		
	move.l	#topskn00,a0	;For the top
	move.w	#37,d0
	move.w	#53,d1
	move.w	#P_VISTPAL00,d2
	jsr	LoadPalette
	DELAY	#1

      	move.l	#topskn01,a0	;For the top
	move.w	#37,d0
	move.w	#53,d1
	move.w	#P_VISTPAL01,d2
	jsr	LoadPalette

	move.l	#topskn02,a0	;For the top
	move.w	#37,d0
	move.w	#53,d1
	move.w	#P_VISTPAL02,d2
	jsr	LoadPalette
	DELAY	#1


;         	cmpi.b	#1,start_state2
;	bne.s	NoStart2
;
;
;	move.l	#p2info,a0	; Load Teamnumber
;	move.b	team(a0),d0	
;	move.l	#AltColors,a2	; Load Address Of Palettes Table
;	asl.w	#2,d0
;	lea	(a2,d0.w),a2	; Load Palette Address
;
;	cmp.l	#0,a0    	;If No Alternate Palette
;	beq	NoStart2
;	
;	move.l	(a2)+,a0	;For the top
;	move.w	#0,d0
;	move.w	#256,d1
;	move.w	#P_VISTPAL00,d2
;	jsr	LoadPalette
;
;NoStart2:

SkipTeams:
	clr.w	d3
	clr.w	d4
	clr.w	d0
	move.w	#P_BLACK,d2
	move.w	#256,d1
	jsr	ClearPalette
	move.w	#0x3030,d3
	move.w	d3,d4
	clr.w	d0
	move.w	#P_GRAYSHADOW,d2
	move.w	#256,d1
	jsr	ClearPalette
	move.w	#0xFFFF,d3
	move.w	d3,d4
	clr.w	d0
	move.w	#126,d2	; P_WHITE
	move.w	#256,d1
	jsr	ClearPalette

	rts

	.export	RestoreFlash2
RestoreFlash2:
	rts

;*************************************************************
;*************************************************************
	.import	VertFlag	; say we are in vertal blank
Wait_Pal:
	clr.b	VertFlag
Wait_1:
	tst.b	VertFlag
	beq.s	Wait_1
	rts

	.export	LoadAttractPal
	.export	LoadGamePal
	.export	OperatorsPal

OperatorsPal:
;	LOADPAL	#FontSkullClr,#0,#P_FONTSKULL,#256
;	LOADPAL	#swdiagclr,#0,#16,#75
	rts

;*************************************************************
;*************************************************************
LoadGamePal:

	rts

HomeColors:
	dc.l	head01	;0 Braves
	dc.l	homet00	;0 Braves
	dc.l	homeb01	;0 Braves
	dc.l	0	;0 Braves
	dc.l	head02	;1 Orioles
	dc.l	homet03	;1 Orioles
	dc.l	homeb00	;1 Orioles
	dc.l	0	;1 Orioles
	dc.l	head00	;2 RedSox
	dc.l	homet01	;2 RedSox
	dc.l	homeb02	;2 RedSox
	dc.l	0	;2 RedSox
	dc.l	head00	;3 Angels
	dc.l	homet00	;3 Angels
	dc.l	homeb01	;3 Angels
	dc.l	0	;3 Angels
	dc.l	head09	;4 Cubs
	dc.l	homet07	;4 Cubs
	dc.l	homeb04	;4 Cubs
	dc.l	0	;4 Cubs
	dc.l	head02	;5 White Sox
	dc.l	homet03	;5 White Sox
	dc.l	homeb00	;5 White Sox
	dc.l	0	;5 White Sox
	dc.l	head03	;6 Reds
	dc.l	homet06	;6 Reds
	dc.l	homeb02	;6 Reds
	dc.l	0	;6 Reds
	dc.l	head00	;7 Indians
	dc.l	homet00	;7 Indians
	dc.l	homeb02	;7 Indians
	dc.l      0	;7 Indians
	dc.l	head02	;8 Rockies
	dc.l	homet03	;8 Rockies
	dc.l	homeb00	;8 Rockies
	dc.l	0	;8 Rockies
	dc.l	head08	;9  Tigers
	dc.l	homet01	;9  Tigers
	dc.l	homeb01	;9  Tigers
	dc.l	0	;9  Tigers
	dc.l	head06	;10 Marlins
	dc.l	homet03	;10 Marlins
	dc.l	homeb00	;10 Marlins
	dc.l	0	;10 Marlins
	dc.l	head00	;11 Astros
	dc.l	homet01	;11 Astros
	dc.l	homeb01	;11 Astros
	dc.l	0	;11 Astros
	dc.l	head07	;12 Royals
	dc.l	homet07	;12 Royals
	dc.l	homeb04	;12 Royals
	dc.l	0	;12 Royals
	dc.l	head07	;13 Dodgers
	dc.l	homet07	;13 Dodgers
	dc.l	homeb04	;13 Dodgers
	dc.l	0	;13 Dodgers
	dc.l	head05	;14 Brewers
	dc.l	homet01	;14 Brewers
	dc.l	homeb01	;14 Brewers
	dc.l	0	;14 Brewers
	dc.l	head00	;15 Twins
	dc.l	homet01	;15 Twins
	dc.l	homeb01	;15 Twins
	dc.l	0	;15 Twins
	dc.l	head07	;16 Expos
	dc.l	homet07	;16 Expos
	dc.l	homeb04	;16 Expos
	dc.l	0	;16 Expos
	dc.l	head07	;17 Mets
	dc.l	homet07	;17 Mets
	dc.l	homeb04	;17 Mets
	dc.l	0	;17 Mets
	dc.l	head00	;18 Yankees
	dc.l	homet01	;18 Yankees
	dc.l	homeb01	;18 Yankees
	dc.l	0	;18 Yankees
	dc.l	head04	;19 Athletics
	dc.l	homet04	;19 Athletics
	dc.l	homeb03	;19 Athletics
	dc.l	0	;19 Athletics
	dc.l	head03	;20 Phillies
	dc.l	homet02	;20 Phillies
	dc.l	homeb02	;20 Phillies
	dc.l	0	;20 Phillies
	dc.l	head02	;21 Pirates
	dc.l	homet08	;21 Pirates
	dc.l	homeb00	;21 Pirates
	dc.l	0	;21 Pirates
	dc.l	head00	;22 Cardnials
	dc.l	homet02	;22 Cardnials
	dc.l	homeb02	;22 Cardnials
	dc.l	0	;22 Cardnials
	dc.l	head00	;23 Padres
	dc.l	homet01	;23 Padres
	dc.l	homeb01	;23 Padres
	dc.l	0	;23 Padres
	dc.l	head02	;24 Giants
	dc.l	homet03	;24 Giants
	dc.l	homeb00	;24 Giants
	dc.l	0	;24 Giants
	dc.l	head00	;25 Mariners
	dc.l	homet05	;25 Mariners
	dc.l	homeb01	;25 Mariners
	dc.l	0	;25 Mariners
	dc.l	head03	;26 Rangers
	dc.l	homet02	;26 Rangers
	dc.l	homeb02	;26 Rangers
	dc.l	0	;26 Rangers
	dc.l	head07	;27 Blue Jays
	dc.l	homet07	;27 Blue Jays
	dc.l	homeb04	;27 Blue Jays
	dc.l	0	;27 Blue Jays
          	dc.l	head00	;28 Draft
	dc.l	homet01	;28 Draft
	dc.l	homeb01	;28 Draft
	dc.l	0	;28 Draft
          	dc.l	head07	;29 AL
	dc.l	homet07	;29 AL
	dc.l	homeb04	;29 AL
	dc.l	0	;29 AL
          	dc.l	head03 	;30 NL
	dc.l	homet02	;30 NL
	dc.l	homeb02	;30 NL
	dc.l	0      	;30 NL
          	dc.l	head02             	;31 DES
	dc.l	homet03	;31 DES
	dc.l	homeb00	;31 DES
	dc.l	0                  	;31 DES


	
AwayColors:
	dc.l	head01	;0 Braves
	dc.l	awayt00	;0 Braves
	dc.l	awayb01	;0 Braves
	dc.l	0	;0 Braves
	dc.l	head02	;1 Orioles
	dc.l	altrt06;awayt07	;1 Orioles
	dc.l	awayb00	;1 Orioles
	dc.l	0	;1 Orioles
	dc.l	head00	;2 RedSox
	dc.l	awayt01	;2 RedSox
	dc.l	awayb02	;2 RedSox
	dc.l	0	;2 RedSox
	dc.l	head00	;3 Angels
	dc.l	altrt00;awayt01	;3 Angels
	dc.l	awayb01	;3 Angels
	dc.l	0	;3 Angels
	dc.l	head09	;4 Cubs
	dc.l	altrt12;awayt12	;4 Cubs
	dc.l	awayb04	;4 Cubs
	dc.l	0	;4 Cubs
	dc.l	head02	;5 White Sox
	dc.l	altrt10;awayt03	;5 White Sox
	dc.l	awayb00	;5 White Sox
	dc.l	0	;5 White Sox
	dc.l	head03	;6 Reds
	dc.l	awayt02	;6 Reds
	dc.l	awayb02	;6 Reds
	dc.l	0	;6 Reds
	dc.l	head00	;7 Indians
	dc.l	altrt00;awayt01	;7 Indians
	dc.l	awayb01	;7 Indians
	dc.l      0	;7 Indians
	dc.l	head02	;8 Rockies
	dc.l	awayt08	;8 Rockies
	dc.l	awayb00	;8 Rockies
	dc.l	0	;8 Rockies
	dc.l	head08	;9  Tigers
	dc.l	altrt09;awayt10	;9  Tigers
	dc.l	awayb01	;9  Tigers
	dc.l	0	;9  Tigers
	dc.l	head06	;10 Marlins
	dc.l	awayt06	;10 Marlins
	dc.l	awayb00	;10 Marlins
	dc.l	0	;10 Marlins
	dc.l	head00	;11 Astros
	dc.l	altrt01;awayt01	;11 Astros
	dc.l	awayb01	;11 Astros
	dc.l	0	;11 Astros
	dc.l	head07	;12 Royals
	dc.l	altrt08;awayt09	;12 Royals
	dc.l	awayb04	;12 Royals
	dc.l	0	;12 Royals
	dc.l	head07	;13 Dodgers
	dc.l	awayt09	;13 Dodgers
	dc.l	awayb04	;13 Dodgers
	dc.l	0	;13 Dodgers
	dc.l	head05	;14 Brewers
	dc.l	altrt03;awayt05	;14 Brewers
	dc.l	awayb03	;14 Brewers
	dc.l	0	;14 Brewers
	dc.l	head00	;15 Twins
	dc.l	awayt01	;15 Twins
	dc.l	awayb01	;15 Twins
	dc.l	0	;15 Twins
	dc.l	head07	;16 Expos
	dc.l	awayt13	;16 Expos
	dc.l	awayb04	;16 Expos
	dc.l	0	;16 Expos
	dc.l	head07	;17 Mets
	dc.l	awayt09	;17 Mets
	dc.l	awayb04	;17 Mets
	dc.l	0	;17 Mets
	dc.l	head00	;18 Yankees
	dc.l	awayt01	;18 Yankees
	dc.l	awayb01	;18 Yankees
	dc.l	0	;18 Yankees
	dc.l	head04	;19 Athletics
	dc.l	altrt02;awayt04	;19 Athletics
	dc.l	awayb05	;19 Athletics
	dc.l	0	;19 Athletics
	dc.l	head03	;20 Phillies
	dc.l	awayt02	;20 Phillies
	dc.l	awayb02	;20 Phillies
	dc.l	0	;20 Phillies
	dc.l	head02	;21 Pirates
	dc.l	awayt11	;21 Pirates
	dc.l	awayb00	;21 Pirates
	dc.l	0	;21 Pirates
	dc.l	head00	;22 Cardnials
	dc.l	awayt01	;22 Cardnials
	dc.l	awayb02	;22 Cardnials
	dc.l	0	;22 Cardnials
	dc.l	head00	;23 Padres
	dc.l	awayt14	;23 Padres
	dc.l	awayb01	;23 Padres
	dc.l	0	;23 Padres
	dc.l	head02	;24 Giants
	dc.l	awayt03	;24 Giants
	dc.l	awayb00	;24 Giants
	dc.l	0	;24 Giants
	dc.l	head00	;25 Mariners
	dc.l	altrt04;awayt01	;25 Mariners
	dc.l	awayb01	;25 Mariners
	dc.l	0	;25 Mariners
	dc.l	head03	;26 Rangers
	dc.l	awayt02	;26 Rangers
	dc.l	awayb02	;26 Rangers
	dc.l	0	;26 Rangers
	dc.l	head07	;27 Blue Jays
	dc.l	altrt11;awayt09	;27 Blue Jays
	dc.l	awayb04	;27 Blue Jays
	dc.l	0	;27 Blue Jays
          	dc.l	head03	;28 Draft
	dc.l	altrt07;awayt02	;28 Draft
	dc.l	awayb02	;28 Draft
	dc.l	0	;28 Draft
          	dc.l	head07	;29 AL
	dc.l	awayt09	;29 AL
	dc.l	awayb04	;29 AL
	dc.l	0	;29 AL
          	dc.l	head03 	;30 NL
	dc.l	awayt02	;30 NL
	dc.l	awayb02	;30 NL
	dc.l	0      	;30 NL
          	dc.l	head02                     	;31 DES
	dc.l	altrt10;awayt03  	;31 DES
	dc.l	awayb00          	;31 DES
	dc.l	0                          	;31 DES


AltColors:
;	dc.l	awayt00	;0 Braves
	dc.l	0	;0 Braves
	dc.l	altrt06	;1 Orioles
;	dc.l	awayt01	;2 RedSox
	dc.l	0	;2 RedSox
	dc.l	altrt00	;3 Angels
	dc.l	altrt12	;4 Cubs
	dc.l	altrt10	;5 White Sox
	dc.l	0	;6 Reds
	dc.l	altrt00	;7 Indians
	dc.l	0	;8 Rockies
	dc.l	altrt09	;9 Tigers
	dc.l	altrt05	;10 Marlins
	dc.l	altrt01	;11 Astros
	dc.l	altrt08	;12 Royals
	dc.l	0	;13 Dodgers
	dc.l	altrt03	;14 Brewers
	dc.l	0	;15 Twins
	dc.l	0	;16 Expos
	dc.l	0	;17 Mets
	dc.l	0	;18 Yankees
	dc.l	altrt02	;19 Athletics
	dc.l	0	;20 Phillies
	dc.l	0	;21 Pirates
	dc.l	0	;22 Cardnials
	dc.l	0	;23 Padres
	dc.l	0	;24 Giants
	dc.l	altrt04	;25 Mariners
	dc.l	0	;26 Rangers
	dc.l	altrt11	;27 Blue Jays
	dc.l	altrt07	;28 Draft
	 
	.export	LoadSelectPal
LoadSelectPal

;	move.w	#1,palnumber
;.zpal	clr.w	d3
;	clr.w	d4
;	clr.w	d0
;	move.w	palnumber,d2
;	move.w	#256,d1
;	jsr	ClearPalette
;	add.w	#1,palnumber
;	cmp.w	#256,palnumber
;	bne.s	.zpal

	LOADPAL	#BallPal,#0,#P_BALL,#255 ;
	LOADPAL	#BordPal,#0,#P_BORDPAL,#255 ;
	DELAY	#pldel
	LOADPAL	#titlerb,#0,#P_TITLERB,#255 ;
	LOADPAL	#titleblu,#0,#P_TITLEBLU,#255 ;
	DELAY	#pldel
	LOADPAL	#gate,#0,#P_GATE,#255 ;
	LOADPAL	#bak1apal,#0,#P_BAK1APAL,#255 ;
	DELAY	#pldel
	LOADPAL	#bak1bpal,#0,#P_BAK1BPAL,#255 ;
;	LOADPAL	#fontdpal,#0,#P_FONTDPAL,#255 ;
	LOADPAL	#meter2a,#0,#P_METER,#255 ;
	DELAY	#pldel
	LOADPAL	#dimcard,#0,#P_DIMCARD,#255 ;
;LOGOS
	LOADPAL	#anglpal,#0,#P_LOGOANG,#255
	DELAY	#pldel
	LOADPAL	#astlpal,#0,#P_LOGOAST,#255
	LOADPAL	#athlpal,#0,#P_LOGOATH,#255
	DELAY	#pldel
	LOADPAL	#blulpal,#0,#P_LOGOBLU,#255
	LOADPAL	#bralpal,#0,#P_LOGOBRA,#255
	DELAY	#pldel
	LOADPAL	#brelpal,#0,#P_LOGOBRE,#255
	LOADPAL	#carlpal,#0,#P_LOGOCAR,#255
	DELAY	#pldel
	LOADPAL	#cinlpal,#0,#P_LOGOCIN,#255
	LOADPAL	#cublpal,#0,#P_LOGOCUB,#255
	DELAY	#pldel
	LOADPAL	#dodlpal,#0,#P_LOGODOD,#255
	LOADPAL	#explpal,#0,#P_LOGOEXP,#255
	DELAY	#pldel
	LOADPAL	#flolpal,#0,#P_LOGOFLO,#255
	LOADPAL	#gialpal,#0,#P_LOGOGIA,#255
	DELAY	#pldel
	LOADPAL	#indlpal,#0,#P_LOGOIND,#255
	LOADPAL	#marlpal,#0,#P_LOGOMAR,#255
	DELAY	#pldel
	LOADPAL	#metlpal,#0,#P_LOGOMET,#255
	LOADPAL	#orilpal,#0,#P_LOGOORI,#255
	DELAY	#pldel
	LOADPAL	#padlpal,#0,#P_LOGOPAD,#255
	LOADPAL	#philpal,#0,#P_LOGOPHI,#255
	DELAY	#pldel
	LOADPAL	#pirlpal,#0,#P_LOGOPIR,#255
	LOADPAL	#ranlpal,#0,#P_LOGORAN,#255
	DELAY	#pldel
	LOADPAL	#redlpal,#0,#P_LOGORED,#255
	LOADPAL	#roclpal,#0,#P_LOGOROC,#255
	DELAY	#pldel
	LOADPAL	#roylpal,#0,#P_LOGOROY,#255
	LOADPAL	#tiglpal,#0,#P_LOGOTIG,#255
	DELAY	#pldel
	LOADPAL	#twilpal,#0,#P_LOGOTWI,#255
	LOADPAL	#whilpal,#0,#P_LOGOWHI,#255
	DELAY	#pldel
	LOADPAL	#yanlpal,#0,#P_LOGOYAN,#255

;	LOADPAL	#p_fontr1,#0,#P_FONTR1,#255 ;
	LOADPAL	#trophypal,#0,#P_TROPHY,#255
	DELAY	#pldel
	LOADPAL	#p_fontr2,#0,#P_FONTR2,#255 ;
;	LOADPAL	#p_fontb1,#0,#P_FONTB1,#255 ;
	DELAY	#pldel
	LOADPAL	#p_fontb2,#0,#P_FONTB2,#255 ;
	LOADPAL	#p_fontw1,#0,#P_FONTW1,#255 ;
	DELAY	#pldel
	LOADPAL	#p_fontw2,#0,#P_FONTW2,#255 ;
	LOADPAL	#p_fonty1,#0,#P_FONTY1,#255
	DELAY	#pldel
	LOADPAL	#Nfonty4,#0,#P_NEOYEL,#255
	LOADPAL	#Nfontr4,#0,#P_NEORED,#255
	DELAY	#pldel
	LOADPAL	#Nfontb4,#0,#P_NEOBLU,#255

	LOADPAL	#DallPal,#0,#P_DALL,#255

	rts


;************************************************************************
;	Characters palettes
;************************************************************************

	include	"q:\baseball\art\palettes\batpal.pal"
;	include	"q:\baseball\art\palettes\firstpal.pal"
	include	"q:\baseball\art\palettes\vintage.pal"
;	include	"q:\baseball\art\palettes\winxpal.pal"
;	include	"q:\baseball\art\palettes\wincpal.pal"
           include	"q:\baseball\art\palettes\radpal.pal"
;	include	"q:\baseball\art\palettes\cubtpal.pal"
;	include	"q:\baseball\art\palettes\cubdtpal.pal"
;	include	"q:\baseball\art\palettes\cubbpal.pal"
;	include	"q:\baseball\art\palettes\oakbpal.pal"
;	include	"q:\baseball\art\palettes\oaktpal.pal"
;	include	"q:\baseball\art\palettes\oakdtpal.pal"
;	include	"q:\baseball\art\palettes\oakhpal.pal"
;	include	"q:\baseball\art\palettes\cubshirt.pal"
;	include	"q:\baseball\art\palettes\cubspant.pal"
;	include	"q:\baseball\art\palettes\cubsnum.pal"
;	include	"q:\baseball\art\palettes\cubsptch.pal"

;	include	"q:\baseball\art\palettes\cardpal.pal"

	include	"q:\baseball\art\palettes\bordpal.pal"
	include	"q:\baseball\art\palettes\dimppal.pal"
	include	"q:\baseball\art\palettes\testpant.pal"
	include	"q:\baseball\art\palettes\testtop.pal"
	include	"q:\baseball\art\palettes\scorepal.pal"
	include	"q:\baseball\art\palettes\scoreb.pal"
	include	"q:\baseball\art\palettes\head3d.pal"
	include	"q:\baseball\art\palettes\itlogo.pal"
	include	"q:\baseball\art\palettes\markcl.pal"
;	include	"q:\baseball\art\palettes\so.pal"
	include	"q:\baseball\art\palettes\ghead.pal"
	include	"q:\baseball\art\palettes\bhead.pal"
	include	"q:\baseball\art\palettes\dust.pal"
	include	"q:\baseball\art\palettes\sabr.pal"
	include	"q:\baseball\art\palettes\club.pal"
;bri
	include	"q:\baseball\art\palettes\fire.pal"
	include	"q:\baseball\art\palettes\stout01.pal"
	include	"q:\baseball\art\palettes\stout02.pal"
	include	"q:\baseball\art\palettes\lite0.pal"
	include	"q:\baseball\art\palettes\batpt.pal"
	include	"q:\baseball\art\palettes\playedrd.pal"
	include	"q:\baseball\art\palettes\playedbl.pal"
	include	"q:\baseball\art\palettes\green.pal"
	include	"q:\baseball\art\palettes\ballpurp.pal"

 
;	include	"q:\baseball\art\palettes\redtpal.pal"
;	include	"q:\baseball\art\palettes\redbpal.pal"
;	include	"q:\baseball\art\palettes\redsnum.pal"
;;	include	"q:\baseball\art\palettes\cubsptch.pal"

	include	"q:\baseball\art\palettes\skypal.pal"
	include	"q:\baseball\art\palettes\field.pal"
	include	"q:\baseball\art\palettes\testfpal.pal"
	include	"q:\baseball\art\palettes\view6pal.pal"
	include	"q:\baseball\art\palettes\bigfield.pal"
	include	"q:\baseball\art\palettes\bigfld2.pal"
	include	"q:\baseball\art\palettes\bigfld3.pal"
	include	"q:\baseball\art\palettes\ballpal.pal"
;	include	"q:\baseball\art\palettes\zone.pal"
	include	"q:\baseball\art\palettes\hedskn00.pal"
	include	"q:\baseball\art\palettes\hedskn01.pal"
	include	"q:\baseball\art\palettes\hedskn02.pal"

	include	"q:\baseball\art\palettes\marker.pal"

	include	"q:\baseball\art\palettes\topskn00.pal"
	include	"q:\baseball\art\palettes\topskn01.pal"
	include	"q:\baseball\art\palettes\topskn02.pal"
	include	"q:\baseball\art\palettes\topskn03.pal"

;	include	"q:\baseball\art\palettes\title1.pal"
;	include	"q:\baseball\art\palettes\title2.pal"
;	include	"q:\baseball\art\palettes\title3.pal"
;	include	"q:\baseball\art\palettes\title4.pal"
;	include	"q:\baseball\art\palettes\title5.pal"
;	include	"q:\baseball\art\palettes\title6.pal"
 ;	include	"q:\baseball\art\palettes\ttlsepal.pal"

            include  "q:\baseball\art\palettes\titlerb.pal"
            include  "q:\baseball\art\palettes\titlebk1.pal"
            include  "q:\baseball\art\palettes\titlebk2.pal"
            include  "q:\baseball\art\palettes\titleblu.pal"
            include  "q:\baseball\art\palettes\titlebrn.pal"
            include  "q:\baseball\art\palettes\titlegrn.pal"
            include  "q:\baseball\art\palettes\gate.pal"
	include	"q:\baseball\art\palettes\powerdim.pal"

	include	"q:\baseball\art\palettes\newscore.pal"

	
;	include	"q:\baseball\art\palettes\backdrop.pal"

	include	"q:\baseball\art\palettes\bak1apal.pal"
	include	"q:\baseball\art\palettes\bak1bpal.pal"
	include	"q:\baseball\art\palettes\bakd4pal.pal"
;	include	"q:\baseball\art\palettes\fontdpal.pal"
	include	"q:\baseball\art\palettes\meter2a.pal"
;	include	"q:\baseball\art\palettes\rfontpal.pal"
;	include	"q:\baseball\art\palettes\gfontpal.pal"
;	include	"q:\baseball\art\palettes\bfontpal.pal"
	include	"q:\baseball\art\palettes\homer1.pal"
	include	"q:\baseball\art\palettes\dimcard.pal"
	include	"q:\baseball\art\palettes\gradienb.pal"
;Head Palettes
;	include	"q:\baseball\art\palettes\hb1blu.pal"
;	include	"q:\baseball\art\palettes\hb2blu.pal"
;	include	"q:\baseball\art\palettes\hw1blu.pal"
;	include	"q:\baseball\art\palettes\hw2blu.pal"
;	include	"q:\baseball\art\palettes\hh1blu.pal"
;	include	"q:\baseball\art\palettes\hh1grn.pal"

	include	"q:\baseball\art\palettes\blackpal.pal"

	include	"q:\baseball\art\palettes\head00.pal"
	include	"q:\baseball\art\palettes\head01.pal"
	include	"q:\baseball\art\palettes\head02.pal"
	include	"q:\baseball\art\palettes\head03.pal"
	include	"q:\baseball\art\palettes\head04.pal"
	include	"q:\baseball\art\palettes\head05.pal"
	include	"q:\baseball\art\palettes\head06.pal"
	include	"q:\baseball\art\palettes\head07.pal"
	include	"q:\baseball\art\palettes\head08.pal"
	include	"q:\baseball\art\palettes\head09.pal"

	
	include	"q:\baseball\art\palettes\hedhar02.pal"
	include	"q:\baseball\art\palettes\hedhar03.pal"
	include	"q:\baseball\art\palettes\hedhar04.pal"
	                         
	include	"q:\baseball\art\palettes\homet00.pal"
	include	"q:\baseball\art\palettes\homet01.pal"
	include	"q:\baseball\art\palettes\homet02.pal"
	include	"q:\baseball\art\palettes\homet03.pal"
	include	"q:\baseball\art\palettes\homet04.pal"
	include	"q:\baseball\art\palettes\homet05.pal"
	include	"q:\baseball\art\palettes\homet06.pal"
	include	"q:\baseball\art\palettes\homet07.pal"
	include	"q:\baseball\art\palettes\homet08.pal"

	include	"q:\baseball\art\palettes\homeb00.pal"
	include	"q:\baseball\art\palettes\homeb01.pal"
	include	"q:\baseball\art\palettes\homeb02.pal"
	include	"q:\baseball\art\palettes\homeb03.pal"
	include	"q:\baseball\art\palettes\homeb04.pal"
	
	include	"q:\baseball\art\palettes\awayt00.pal"
	include	"q:\baseball\art\palettes\awayt01.pal"
	include	"q:\baseball\art\palettes\awayt02.pal"
	include	"q:\baseball\art\palettes\awayt03.pal"
	include	"q:\baseball\art\palettes\awayt04.pal"
	include	"q:\baseball\art\palettes\awayt05.pal"
	include	"q:\baseball\art\palettes\awayt06.pal"
	include	"q:\baseball\art\palettes\awayt07.pal"
	include	"q:\baseball\art\palettes\awayt08.pal"
	include	"q:\baseball\art\palettes\awayt09.pal"
	include	"q:\baseball\art\palettes\awayt10.pal"
	include	"q:\baseball\art\palettes\awayt11.pal"
	include	"q:\baseball\art\palettes\awayt12.pal"
	include	"q:\baseball\art\palettes\awayt13.pal"
	include	"q:\baseball\art\palettes\awayt14.pal"

	include	"q:\baseball\art\palettes\awayb00.pal"
	include	"q:\baseball\art\palettes\awayb01.pal"
	include	"q:\baseball\art\palettes\awayb02.pal"
	include	"q:\baseball\art\palettes\awayb03.pal"
	include	"q:\baseball\art\palettes\awayb04.pal"
	include	"q:\baseball\art\palettes\awayb05.pal"
	
	include	"q:\baseball\art\palettes\altrt00.pal"
	include	"q:\baseball\art\palettes\altrt01.pal"
	include	"q:\baseball\art\palettes\altrt02.pal"
	include	"q:\baseball\art\palettes\altrt03.pal"
	include	"q:\baseball\art\palettes\altrt04.pal"
	include	"q:\baseball\art\palettes\altrt05.pal"
	include	"q:\baseball\art\palettes\altrt06.pal"
	include	"q:\baseball\art\palettes\altrt07.pal"
	include	"q:\baseball\art\palettes\altrt08.pal"
	include	"q:\baseball\art\palettes\altrt09.pal"
	include	"q:\baseball\art\palettes\altrt10.pal"
	include	"q:\baseball\art\palettes\altrt11.pal"
	include	"q:\baseball\art\palettes\altrt12.pal"
	include	"q:\baseball\art\palettes\anglpal.pal"
	include	"q:\baseball\art\palettes\astlpal.pal"
	include	"q:\baseball\art\palettes\athlpal.pal"
	include	"q:\baseball\art\palettes\blulpal.pal"
	include	"q:\baseball\art\palettes\bralpal.pal"
	include	"q:\baseball\art\palettes\brelpal.pal"
	include	"q:\baseball\art\palettes\carlpal.pal"
	include	"q:\baseball\art\palettes\cinlpal.pal"
	include	"q:\baseball\art\palettes\cublpal.pal"
	include	"q:\baseball\art\palettes\dodlpal.pal"
	include	"q:\baseball\art\palettes\explpal.pal"
	include	"q:\baseball\art\palettes\flolpal.pal"
	include	"q:\baseball\art\palettes\gialpal.pal"
	include	"q:\baseball\art\palettes\indlpal.pal"
	include	"q:\baseball\art\palettes\marlpal.pal"
	include	"q:\baseball\art\palettes\metlpal.pal"
	include	"q:\baseball\art\palettes\orilpal.pal"
	include	"q:\baseball\art\palettes\padlpal.pal"
	include	"q:\baseball\art\palettes\philpal.pal"
	include	"q:\baseball\art\palettes\pirlpal.pal"
	include	"q:\baseball\art\palettes\ranlpal.pal"
	include	"q:\baseball\art\palettes\redlpal.pal"
	include	"q:\baseball\art\palettes\roclpal.pal"
	include	"q:\baseball\art\palettes\roylpal.pal"
	include	"q:\baseball\art\palettes\tiglpal.pal"
	include	"q:\baseball\art\palettes\twilpal.pal"
	include	"q:\baseball\art\palettes\whilpal.pal"
	include	"q:\baseball\art\palettes\yanlpal.pal"
	include	"q:\baseball\art\palettes\c_brav.pal"
	include	"q:\baseball\art\palettes\c_orio.pal"
	include	"q:\baseball\art\palettes\c_redx.pal"
	include	"q:\baseball\art\palettes\c_ange.pal"
	include	"q:\baseball\art\palettes\c_cubs.pal"
	include	"q:\baseball\art\palettes\c_whit.pal"
	include	"q:\baseball\art\palettes\c_reds.pal"
	include	"q:\baseball\art\palettes\c_indi.pal"
	include	"q:\baseball\art\palettes\c_rock.pal"
	include	"q:\baseball\art\palettes\c_tige.pal"
	include	"q:\baseball\art\palettes\c_marl.pal"
	include	"q:\baseball\art\palettes\c_astr.pal"
	include	"q:\baseball\art\palettes\c_roya.pal"
	include	"q:\baseball\art\palettes\c_dodg.pal"
	include	"q:\baseball\art\palettes\c_brew.pal"
	include	"q:\baseball\art\palettes\c_twin.pal"
	include	"q:\baseball\art\palettes\c_expo.pal"
	include	"q:\baseball\art\palettes\c_mets.pal"
	include	"q:\baseball\art\palettes\c_yank.pal"
	include	"q:\baseball\art\palettes\c_athl.pal"
	include	"q:\baseball\art\palettes\c_phil.pal"
	include	"q:\baseball\art\palettes\c_pira.pal"
	include	"q:\baseball\art\palettes\c_card.pal"
	include	"q:\baseball\art\palettes\c_padr.pal"
	include	"q:\baseball\art\palettes\c_gian.pal"
	include	"q:\baseball\art\palettes\c_mari.pal"
	include	"q:\baseball\art\palettes\c_rang.pal"
	include	"q:\baseball\art\palettes\c_blue.pal"
	include	"q:\baseball\art\palettes\c_desi.pal"

	include	"q:\baseball\art\palettes\stands.pal"

;	include	"q:\baseball\art\palettes\p_fontr1.pal"
	include	"q:\baseball\art\palettes\trophy.pal"
	include	"q:\baseball\art\palettes\p_fontr2.pal"
;	include	"q:\baseball\art\palettes\p_fontb1.pal"
	include	"q:\baseball\art\palettes\p_fontb2.pal"
	include	"q:\baseball\art\palettes\p_fontw1.pal"
	include	"q:\baseball\art\palettes\p_fontw2.pal"
	include	"q:\baseball\art\palettes\p_fonty1.pal"
;	include	"q:\baseball\art\palettes\p_fonty2.pal"
	include	"q:\baseball\art\palettes\dallpal.pal"

	include	"q:\baseball\art\palettes\sopal.pal"
	include	"q:\baseball\art\palettes\blueso.pal"
;	include	"q:\baseball\art\palettes\tickrddm.pal"
;	include	"q:\baseball\art\palettes\tickbldm.pal"

	include	"q:\baseball\art\palettes\basemete.pal"
	include	"q:\baseball\art\palettes\celeb01.pal"

	include	"q:\baseball\art\palettes\fire0001.pal"
	include	"q:\baseball\art\palettes\spka0001.pal"

	include	"q:\baseball\art\palettes\shota.pal"
	include	"q:\baseball\art\palettes\shotb.pal"
	include	"q:\baseball\art\palettes\mlb.pal"
	include	"q:\baseball\art\palettes\mlbm.pal"
	include	"q:\baseball\art\palettes\mlbpa.pal"
	include	"q:\baseball\art\palettes\hawk.pal"
	include	"q:\baseball\art\palettes\logowor.pal"

	include	"q:\baseball\art\palettes\nfontb1.pal"
	include	"q:\baseball\art\palettes\nfontb2.pal"
	include	"q:\baseball\art\palettes\nfontb3.pal"
	include	"q:\baseball\art\palettes\nfontb4.pal"

	include	"q:\baseball\art\palettes\nfontr1.pal"
	include	"q:\baseball\art\palettes\nfontr2.pal"
	include	"q:\baseball\art\palettes\nfontr3.pal"
	include	"q:\baseball\art\palettes\nfontr4.pal"

;	include	"q:\baseball\art\palettes\nfontw1.pal"
;	include	"q:\baseball\art\palettes\nfontw2.pal"
	include	"q:\baseball\art\palettes\nfontw3.pal"
	include	"q:\baseball\art\palettes\nfontw4.pal"

	include	"q:\baseball\art\palettes\nfonty1.pal"
	include	"q:\baseball\art\palettes\nfonty2.pal"
	include	"q:\baseball\art\palettes\nfonty3.pal"
	include	"q:\baseball\art\palettes\nfonty4.pal"


	end


