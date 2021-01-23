;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.                          *
;                    (C) COPYRIGHT 1995, IT, INC.                          *
;***************************************************************************
; Revision History			*
;   1.00	- Internal Test		*
;***************************************************************************
	.region	"RAM"
	ds	0

;***************************************************************************
;   Routines Exported From GAME.ASM		*
;***************************************************************************
	.export	MainProcess,message_flag,user_serv_active
	.export	SetSysFont,SetFont2,SetWinFont
	.export	LoadExceptPal
	.export   TestStartCredits
	.export   TestDraftCredits
	.export   TestContCredits
	.export   TakeContCredits
	.export   TakeDraftCredits
	.export   TakeStartCredits
	.export	CreditsMsg
	.export	IncAudit
	.export	CalcAudits	; Update Audits
;obe	.export	Versus_Table
	.export	ScrLevel
	.export	SetFontm
	.export	GameTime
	.export	fix_checksum
;***************************************************************************
;  Variable Imports			*
;***************************************************************************
	.import	VBMask,F3CharTrans,F5CharTrans,Inning,buytime
	.import	PlayerL,PlayerR,NoY,records_reset

	.import.s Mode1,last_cmd,S_Mode1
	.import.s	S_PLN1YTP,S_PLN1XTP
	.import.s	FontSpacing
	.import.s FrameRate,memory_status,board_test_flag
	.import.s	Batter,Pitcher,CTimer
	.import.s	BuyIn,vram_status0,vram_status1
	.import.s	grom_bad_flag,screen_cnt
	.import.s	AttractSem

	.import	records
	.import	RecordSize
	.import	MaxPlayers

;***************************************************************************
;  Subroutine Imports			*
;***************************************************************************
	.import	diag_menu
	.import	FontSkullClr
	.import	BaseTable
	.import	ClrLine250
	.import	ReadVRAM
	.import	SwitchState
	.import	TogglePage
	.import	PageA
	.import	ClearPage
	.import	AttractMode,InitAttract
	.import	InitSwitches
	.import	ResetStats
	.import	GameStart
	.import	GameStart1,GameStart2
	.import	InitCycle,LoadPtrs
	.import	LoadAllPals
	.import	Random
; imports from diag.asm
	.import SystemTest
	.import	board_test
	.import	volume_title
	.import	volume_tst,fnt1Spacing
	.import	FreeBee

;***************************************************************************
;  RAM Variables Defined In This Section		*
;***************************************************************************
	.export	ram_entry
	.export	GameMode,ScreenInvert,ScreenInvert2
	.export	oper_ram
	.export	SoundsOff,temp_val
	.export	menu_mess,operator_timeout
	.export	user_sel_flg
	.export	user_rdy_flg
	.export	clear_on,Volume,loop_flag

	.export	menu_pos
	.export	boxram
	.export	boxram_color
	.export	boxram_pixel
	.export	boxram_height
	.export	boxram_width
	.export	boxram_x
	.export	boxram_y
	.export	CoinFlag
	.export	titlebox1,titlebox2
	.export	chngbox1,chngbox2

KILL                 equ 0       ;kill all channels
ADJUSTABLEMENUMOVE   equ 208
ADJUSTABLEMENUSELECT equ 209
COININ_snd           equ 240      ;coin in 
CREDIT_snd           equ 241      ;credit
COINCOUNTER_snd      equ 249

GameTime		ds.w 1

message_flag	ds.b 1

GameMode 	      	ds.b 1	; game mode indicator
user_serv_flg    	ds.b 1	; user service flag
user_serv_active 	ds.b 1	; user service routine active

	ds	0	; these are all used in read_rom for, align on even
ram_entry      	ds.b 5	; used to point blitter a place in GROM
byte_count     	ds.w 1

menu_entries   	ds.w 1
menu_num	ds.w 1
menu_ptr	ds.l 1
menu_sub	ds.l 1
menu_cnt	ds.w 1
menu_pos	ds.w 1
menu_sec	ds.w 1
menu_flags	ds.b 1

;flags to track operator responses for menus
user_rdy_flg   	ds.b 1	; start button pushed
user_sel_flg	ds.b 1	; select button pushed

clear_on	ds.b	1
temp_val	ds.w	1

test_sound		ds.w 1
que_sound		ds.b 1
test_byte      	ds.b 1
menu_mess      	ds.b 1
Volume		ds.w 1

CoinFlag		ds.b 1
menu_head      	ds.l 1
attract_flag   	ds.b 1

ScreenInvert	ds.w 1	; Set If Screen Should Be Inverted
ScreenInvert2	ds.w 1	; Set If Screen Should Be Inverted
AverageGame	ds.w 1	; Average Game Time

whole_cred		ds.w 1
frac_cred		ds.w 1

test_num		ds.w 1
hexbytes		ds.l 4	; plenty of room to hold hex bytes to print

;diagnostic loop control variables
loop_flag		ds.b 1


backup_ram_status 	ds.b 1
operator_timeout  	ds.w 1

total_coins	ds.w 1
SoundsOff		ds.b 1
MinCamX	ds.w	1

;ram block for box drawing
boxram
boxram_color	ds.w 1
boxram_pixel	ds.w 1
boxram_height	ds.w 1
boxram_width	ds.w 1
boxram_x		ds.w 1
boxram_y		ds.w 1

xsave		ds.w 1
xsave2		ds.w 1
ysave		ds.w 1
isave		ds.w 1

main_menu_pos	ds.w 1
oper_menu_pos	ds.w 1

recadr		ds.l 1
ZRecCnt		ds.w 1	;count the records zeroed

;***************************************************************************
;  Start Of Program Code			*
;***************************************************************************
	.region	"RomCode"

	#include	"sys.mac"
	#include	"itvideo2.h"
	#include	"sys.h"
	#include	"graphlib.mac"
	#include	"graphlib.h"
	#include	"graphglb.h"
	#include	"macros.h"
;	#include	"r:\baseball\sounds\bsblsnds.equ"
	#include	"player.h"
	#include	"bsblsnds.equ"
	#include	"pals.h"
	#include	"ramblock.h"
	#include	"groms.h"

RESET_SND	equ	0;SAYVERIFIED	; reseting oper adjustables, audits, etc

BOTSCR	equ	256
RGTSCR	equ	383	;zero based value
;list of images and bank equates from groms.asm

;IMAGE LIST
;==========
;***************
ram_entry_BANK	equ 0
SYSFONT_BANK	equ 1
GOLDFONT_BANK	equ 1
GRAYFONT_BANK	equ 1
BIGFONT_BANK	equ 1
SCOREFONT_BANK	equ 1

FONT_BANK	equ	1

BLACK	equ	0
WHITE	equ	1
RED	equ	2
GREEN	equ	3
BLUE	equ	4
LTBLUE	equ	4
YELLOW	equ	5
CYAN	equ	6
PURPLE	equ	7
SWDIAG_PAL	equ	16


;
; palette selections for menu system
;
TITLE	equ	GREEN	; title lines
INSTRUCTION	equ	YELLOW	; operator instructions
CHOICE	equ	WHITE ;was BLUE	; menu choices operator can make
HIGHLIGHT	equ	RED ;was WHITE	; currently selected choice
BADSTUFF	equ	RED	; typically things that are bad

;***************************************************************************
;   MainProcess -			*
;				*
;      MainProcess is spawned from reset and is the only process that can	*
;      not be killed.  This process is responsible for monitoring all of	*
;      the background functions. These functions include:	*
;				*
;          1) Monitor coin switches.		*
;          2) Perform attract sequences.		*
;          3) Monitor attract mode and determine when to start game	*
;          4) Monitor game and determine when to go back to attract mode	*
;***************************************************************************
MainProcess:
	move.b	PLYRIN2,d0
	and.b	#0x0E,d0	; Extract Lower Bits
	bne.s	Main_1

	clr.w	test_num
	DELAY	#10
;;	SOUND	#SOUNDSON,#0	; Turn On Sounds
	DELAY	#10
;;jdz	SOUND	#RESET_SND,#0
	DELAY	#10


Main_1:
	APALETTE  #1
	clr.w	ScreenInvert
	clr.w	ScreenInvert2
	jsr	InitSystem
	clr.b	user_serv_active	; user service not active
;
; check battery backed up variables
; if problem, the variables will be reset and
; warning messages displayed.
;
Main_1b:
;trk	move.w	#1234,oper_ram	; induce failure
	clr.b	backup_ram_status	; init results flag
	jsr	init_ram	; test ram for need of initializing
	jsr	do_video_parms	; now it's safe to adjust parameters
	tst.b	backup_ram_status	; check if anything was corrupted
	bne.s	Main_1c	; br if corruption
	tst.w	memory_status	; check for processor memory problems
	beq	Main_1e	; br if ok

;
; display error message(s)
; and wait for operator response
;
Main_1c:
	BPALETTE  #127  ;BLACK
	APALETTE  #TITLE
	PPRINT    #110,#140,"POWER UP BASEBALL V1.5"
	tst.b	backup_ram_status
	beq	Main_1c1
	APALETTE	#BADSTUFF
	PPRINT    #100,#160,"BATTERY BACKUP FAILURE"
	btst.b	#0,backup_ram_status
	beq	nomessage
	PLOT	#100,#175
	PRINTDEC	ZRecCnt,#3,JLEFT
	PRINT    " SCORES RESET"
	jsr	TogglePage
	DELAY	#100	; minimum delay time
nomessage
Main_1c1:
	tst.w	memory_status
	beq.s	Main_1c2
	APALETTE	#BADSTUFF
	PPRINT    #100,#180,"PROGRAM MEMORY FAILURE"
Main_1c2:
	APALETTE	#INSTRUCTION
	PPRINT	#90,#200,"PRESS START 1 TO CONTINUE"
	jsr	TogglePage
	DELAY	#60	; minimum delay time
	tst.b     board_test_flag	; check if will be doing powerup tests
	bne	Main_1f	; if yes go do them
;	move.w	#60*45,operator_timeout	; wait around max of 45 seconds
	move.w	#60*1,operator_timeout	; wait around max of 45 seconds
Main_1d:
	DELAY	#1
	move.b	#START1,d0
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0	; wait for operator to push start1
	beq	Main_2G	; br if pushed
	sub.w	#1,operator_timeout
	bne	Main_1d	; br if haven't timed out
	bra	Main_2G	; continue with startup sequence

Main_1e:
	tst.b     board_test_flag	; check if need to do powerup tests
	beq	Main_2	; br if no tests requested
;
; do powerup hardware tests.
; a processor RAM and Palette RAM test have already been done in intsvc.asm
; will do rest of the tests here and display results
;
Main_1f:
	jsr	board_test
	bra	Main_2G

Main_2:
	PLANES	#PLANEA
	APALETTE  #TITLE
	BPALETTE  #127  ;BLACK

	PPRINT    #110,#140,"POWER UP BASEBALL V1.5"
	PPRINT    #114,#160," SYSTEM STATUS OK"

	jsr	TogglePage
	clr.b	user_serv_flg

Main_2G:
	clr.b	board_test_flag
;	move.b	#1,user_serv_flg	; indicate that we want user service
	SOUND	#0,#0
	SOUND	#0,#0
	SOUND	#0,#0
	SOUND	#0,#0
	DELAY	#20
	SOUND	#251,VolumeLevel+1  ; Set Volume Level
	SOUND	#SetLanguageRating,SpeechRating+1
	bra	Main_pwrup_done

	.align	2

BlackColors	dc.b	0,0,0,0,0,0,0,0,0,0,0,0

	.align	2
;
; power-up code completed
; do any remaining initialization needed for game operation
;
Main_pwrup_done:
	jsr	InitAccounts	; Initailize Accounts
	jsr	LoadAllPals	; Load All Palettes
;***************************************************************************
; normal game sequence code starts here		*
; should not need to go back above this point under normal operation	*
;***************************************************************************

Main_3:
	jsr	InitMainSwitches	; Activate Coin And Start Switches
	move.b	#1,message_flag	; Set Display "Insert Coins" Flag

	clr.b	GameMode	; set game mode to attracts (0)
	move.b	#1,attract_flag

	LOADPAL	#BlackColors,#255,#127,#1 ; Clear BackGround

	SPAWN	#AttractMode,#5	; Start Up Attract Sequence
;	move.w	#1,FreePlay

	jsr	LoadPtrs	; Load Pointer To Player info
	clr.b	START(a5)	; Player 1 Not Started
	clr.b	START(a6)	; Player 2 Not Started
	move.b	#1,COMPUTER(a5)	; Player 1 Is A Computer
	move.b	#1,COMPUTER(a6)	; Player 2 Is A Computer
Main_4:
	DELAY	#2	; delay 2/60 of a second between observations

	tst.b	user_serv_flg	; Check If Service Button Pressed
	bne	ServiceInit	; Branch If Pressed

	btst.b	#7,DIPS	; Check If Test DIP Switch Set
	bne	ServiceInit	; Branch If Set
	jsr	LoadPtrs	; Load Pointer To Player info
	move.b	START(a5),d0	; Check If Either Player Is Started
	or.b	START(a6),d0	; Or In Player 2 Start
	beq	Main_4	; Continue Attract Loop If None Started
	clr.w	FreeBee	;not a free game
Main_4A:
	DELAY	#1	; Delay A Little
	EXTERM    #0	; Kill Off All Tasks
	clr.b	message_flag	; Turn Off Attract Message
	move.b	#1,GameMode	; Set Game Active
	clr.b	AttractSem	; Turn Off Attract Mode
	clr.w	GameTime	; Clear The Game Time
	clr.b	attract_flag	; Clear Attract Flag
	clr.b	user_serv_active	; user service not active
	SPAWN     #GameStart,#6	; Start Up The Game
Main_5:
	DELAY	#30	; Delay 1/2 Second
	tst.b	user_serv_flg	; Check If Service Switch Pressed
	bne	ServiceInit	; Branch If Pressed
	btst.b	#7,DIPS	; Check If Test DIP Switch Set
	bne	ServiceInit	; Branch If Set
	addq.w	#1,GameTime	; Increment Game Time
	cmp.b	#2,GameMode	; Check If Game Finished
	blt.s	Main_5	; Branch If Still Active

	clr.l	d0	; Clear D0
	move.w	GameTime,d0	; Load The Game Timer
	lsr.w	d0	; Multiply By Two
	add.l	d0,total_time	; Add To Total Game Time
	jsr	CalcAudits	; Update Audits

	DELAY	#1	; Delay A Little
	EXTERM	#0	; Shut Down All Extraneous Tasks
	SOUND	#KILL,#0	; reset Sound System
	tst.w	FreeBee	;team to play against in free game
	bne	Main_4A	;got a free game
	bra	Main_3

;***************************************************************************
TakeContCredits:
	addq.w	#1,total_cont
	move.w	min_cont_credit,d0
	bra.s	TakeCredit
TakeDraftCredits:
	addq.w	#1,total_drafts
	move.w	min_draft_credit,d0	;credits to draft
	mulu	min_start_credit,d0	;what is a credit
	bra.s	TakeDraft
TakeStartCredits:
	move.w	min_start_credit,d0
TakeCredit:
	addq.w	#1,total_games
TakeDraft	cmp.w	MoneyPool,d0
	bgt.s	TakeCredit_1
	tst.w	FreePlay
	bne.s	TakeCredit_1
	sub.w	d0,MoneyPool
TakeCredit_1:
	SOUND	#SOUNDSON,#0	; Turn On Sounds
	jsr	CalcAudits
	rts

;***************************************************************************
TestStartCredits:
	tst.w	FreePlay	; Check If In Free Play
	bne.s	TestSCred_1	; Branch If It Is
	move.w	MoneyPool,d0	; Load Money In The Pool
	cmp.w	min_start_credit,d0	; Check If Enough Credits
	blt.s	TestSCred_2	; Branch If Not
TestSCred_1:
	moveq	#1,d0	; Flag Credits
	rts
TestSCred_2:
	moveq	#0,d0	; Not Enough Credits
	rts

;***************************************************************************
TestDraftCredits:
	tst.w	FreePlay	; Check If In Free Play
	bne.s	TestDCred_1	; Branch If It Is
	move.w	MoneyPool,d0	; Load Money In The Pool
	move.w	min_draft_credit,d1	;credits to draft
	mulu	min_start_credit,d1	;what is a credit
	cmp.w	d1,d0	; Check If Enough Credits
	blt.s	TestDCred_2	; Branch If Not
TestDCred_1:
	moveq	#1,d0	; Flag Credits
	rts
TestDCred_2:
	moveq	#0,d0	; Not Enough Credits
	rts

;***************************************************************************
TestContCredits:
	tst.w	FreePlay	; Check If In Free Play
	bne.s	TestCCred_1	; Branch If It Is
	move.w	MoneyPool,d0	; Load Money In Pool
	cmp.w	min_cont_credit,d0	; Check If Enough Credits
	blt.s	TestCCred_2	; Branch If Not
TestCCred_1:
	moveq	#1,d0	; Flag Credits
	rts
TestCCred_2:
	moveq	#0,d0	; Not Enough Credits
	rts

;***************************************************************************
; display credits for buying innings screen	*
;***************************************************************************
	.export	InCreditsMsg
InCreditsMsg:
;	rts
;	jsr	CoinBookkeeping	; Display by button press total coins
;	tst.b	message_flag	; Check If Message Are Desired
;	beq	InCredMsg_9	; Branch If Not
;	PLOT	#140,#5	; Set Starting Position
;	cmp.b	#2,message_flag	; Check If Message Are Desired
;	bne	InCredMsg_00	; Branch If Not
;	PLOT	#140,#230	; Set Starting Position
;InCredMsg_00:	; Branch If Not

;	jsr	SetWinFont
;	SETPRINT	#20,#23,#fnt2,#0
;	clr.l	FontAdjust
;	clr.l	FontSpacing	; Non-Proportional Spacing
;	move.l	#F5CharTrans,CharTrans	; character translation table
;
;	APALETTE   #P_SYSFONT	; Use Skull Palette
;	APALETTE	#P_FONTW2
;
;	PLANES	#PLANEA	; Display On Plane A
	tst.w	FreePlay	; Check If In Free Play Mode
	beq.s	InCredMsg_0	; Branch If Not Free Play
	PPRINT	#140,#224,"FREE PLAY"	; Print Free Play Message
	rts

InCredMsg_0:
	move.w	min_start_credit,d0	; Load Start Credits
	tst.b	BuyIn	; Check If Buying In
	beq.s	InCredMsg_0A	; Branch If Not
	move.w	min_cont_credit,d0	; Load Continue Credits
InCredMsg_0A:
	move.w	d0,test_num	; Save Credits Value
	sub.w	MoneyPool,d0	; Subtract Money In Pool
	move.w	d0,temp_val	; Save In Temp
	beq	InCredMsg_1	; Branch If Enough Money
	bmi	InCredMsg_1	; Branch If Enough Money

;	PLOT	#117,#5	; Set Starting Position
;	cmp.b	#2,message_flag	; Check If Message Are Desired
;	bne	InCredMsg_0B	; Branch If Not
;	PLOT	#117,#230	; Set Starting Position
InCredMsg_0B:	; Branch If Not

	PLOT	#115,#225	; Set Starting Position
	PRINT	"INSERT "
	PRINTDEC	temp_val,#5,JLEFT
	PRINT	" COIN"
	cmpi.w	#1,temp_val
	beq	InCredMsg_9
	PRINT	"S"
	bra	InCredMsg_9
InCredMsg_1:
;	PLOT	#140,#5	; Set Starting Position
;	cmp.b	#2,message_flag	; Check If Message Are Desired
;	bne	InCredMsg_1a	; Branch If Not
;	PLOT	#140,#230	; Set Starting Position
InCredMsg_1a:	; Branch If Not
;	PRINT	"PRESS START"
InCredMsg_2:
;	jsr	SetSysFont	;temp
;	APALETTE   #P_SYSFONT	; Use Skull Palette
;	APALETTE	#P_FONTW2
;	
;	PLOT	#300,#238
;	#ifdef	MEXICO	; waiting for the slop
;	PLOT	#300,#245
;	#endif
InCredMsg_2a:
	tst.w	MoneyPool
	beq	InCredMsg_9

	move.w	MoneyPool,temp_val
	clr.l	d0
	move.w	temp_val,d0
	divu	test_num,d0
	move.w	d0,temp_val
	move.w	d0,whole_cred
	tst.w	d0
	beq.s	InCredMsg_3
	PUSHL	d0
	PRINTDEC	temp_val,#2,JLEFT
	POPL	d0
InCredMsg_3:
	swap	d0
	move.w	d0,temp_val
	move.w	d0,frac_cred
	tst.w	temp_val
	beq	InCredMsg_4
	PRINT	" "
	PRINTDEC	temp_val,#2,JLEFT
	PRINT	"/"
	PRINTDEC	test_num,#2,JLEFT
InCredMsg_4:
;	PRINT	" CREDIT"
;	cmpi.w	#1,whole_cred
;	blt.s	InCredMsg_9
;	bgt.s	InCredMsg_5
;	tst.w	frac_cred
;	beq.s	InCredMsg_9
InCredMsg_5
;	PRINT	"S"
InCredMsg_9:
	rts


;***************************************************************************
; CreditsMsg - display information on credits at bottom of screen	*
;***************************************************************************
CreditsMsg:
;	rts
	jsr	CoinBookkeeping	; Display by button press total coins
	tst.b	message_flag	; Check If Message Are Desired
	beq	CredMsg_9	; Branch If Not
	PLOT	#140,#5	; Set Starting Position
	cmp.b	#2,message_flag	; Check If Message Are Desired
	bne	CredMsg_00	; Branch If Not
	PLOT	#140,#240	; Set Starting Position
CredMsg_00:	; Branch If Not

;	jsr	SetWinFont
	SETPRINT	#8,#8,#fnt3,#0
	clr.l	FontAdjust
	clr.l	FontSpacing	; Non-Proportional Spacing
	move.l	#F3CharTrans,CharTrans	; character translation table

;	APALETTE   #P_SYSFONT	; Use Skull Palette
	APALETTE	#P_FONTW2

	PLANES	#PLANEA	; Display On Plane A
	tst.w	FreePlay	; Check If In Free Play Mode
	beq.s	CredMsg_0	; Branch If Not Free Play
	PRINT	"FREE PLAY"	; Print Free Play Message
	rts

CredMsg_0:
	move.w	min_start_credit,d0	; Load Start Credits
	tst.b	BuyIn	; Check If Buying In
	beq.s	CredMsg_0A	; Branch If Not
	move.w	min_cont_credit,d0	; Load Continue Credits
CredMsg_0A:
	move.w	d0,test_num	; Save Credits Value
	sub.w	MoneyPool,d0	; Subtract Money In Pool
	move.w	d0,temp_val	; Save In Temp
	beq	CredMsg_1	; Branch If Enough Money
	bmi	CredMsg_1	; Branch If Enough Money

	PLOT	#117,#5	; Set Starting Position
	cmp.b	#2,message_flag	; Check If Message Are Desired
	bne	CredMsg_0B	; Branch If Not
	PLOT	#117,#240	; Set Starting Position
CredMsg_0B:	; Branch If Not

	PRINT	"INSERT "
	PRINTDEC	temp_val,#5,JLEFT
	PRINT	" COIN"
	cmpi.w	#1,temp_val
	beq.s	CredMsg_2
	PRINT	"S"
	bra.s	CredMsg_2
CredMsg_1:
	PLOT	#140,#5	; Set Starting Position
	cmp.b	#2,message_flag	; Check If Message Are Desired
	bne	CredMsg_1a	; Branch If Not
	PLOT	#140,#240	; Set Starting Position
CredMsg_1a:	; Branch If Not
	PRINT	"PRESS START"
CredMsg_2:
	jsr	SetSysFont	;temp
;	APALETTE   #P_SYSFONT	; Use Skull Palette
	APALETTE	#P_FONTW2
	
	PLOT	#300,#241
	#ifdef	MEXICO	; waiting for the slop
	PLOT	#300,#245
	#endif
CredMsg_2a:
	tst.w	MoneyPool
	beq	CredMsg_9

	move.w	MoneyPool,temp_val
	clr.l	d0
	move.w	temp_val,d0
	divu	test_num,d0
	move.w	d0,temp_val
	move.w	d0,whole_cred
	tst.w	d0
	beq.s	CredMsg_3
	PUSHL	d0
	PRINTDEC	temp_val,#2,JLEFT
	POPL	d0
CredMsg_3:
	swap	d0
	move.w	d0,temp_val
	move.w	d0,frac_cred
	tst.w	temp_val
	beq	CredMsg_4
	PRINT	" "
	PRINTDEC	temp_val,#2,JLEFT
	PRINT	"/"
	PRINTDEC	test_num,#2,JLEFT
CredMsg_4:
	PRINT	" CREDIT"
	cmpi.w	#1,whole_cred
	blt.s	CredMsg_9
	bgt.s	CredMsg_5
	tst.w	frac_cred
	beq.s	CredMsg_9
CredMsg_5
	PRINT	"S"
CredMsg_9:
	rts

	.export	CredMsgOnly
CredMsgOnly:
	rts
	jsr	SetSysFont	;temp
	APALETTE   #P_SYSFONT	; Use Skull Palette
	tst.w	FreePlay	; Check If In Free Play Mode
	beq.s	CredMsgO_1	; Branch If Not Free Play
;	PLOT	#300,#10
	PLOT	#145,#10
	PRINT	"FREE PLAY"	; Print Free Play Message
	rts

CredMsgO_1:	; Branch If Not Free Play
;	PLOT	#300,#10
	PLOT	#145,#10
	bra	CredMsg_2a

;***************************************************************************
;***************************************************************************

CoinBookkeeping:	; Display by button press total coins
	cmp.b	#1,GameMode	; Set Game Active
	beq.s	CoinBookExit	; don't display in game

	move.b	#BUTTON1_1,d0 	;jab button has to be pressed
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne	CoinBookExit

	clr.w	d0	; calculate total number of coins
	add.w	coin1_coins,d0
	add.w	coin2_coins,d0
	move.w	d0,total_coins

	jsr	SetSysFont
	APALETTE   #P_SYSFONT
	PLOT	#20,#240
	PRINTDEC   total_coins,#8,JLEFT

CoinBookExit:
	rts

;***************************************************************************
;          init_accounts			*
;          initialize game accounting vars		*
;***************************************************************************
InitAccounts:
	clr.b	user_serv_flg	; clear user service flag
	clr.b	CoinFlag
	rts

ServiceInit:
	DELAY	#1	; 30
	EXTERM    #0	; kill attract mode and any other tasks
	SOUND     #KILL,#0	; turn off all sounds
	SOUND     #SOUNDSOFF,#0	; turn off all sounds
	move.b	#0,GameMode
	clr.w	GameTime	; set the game time to 0
	clr.b	attract_flag
	jsr	InitSwitches
	move.b	#1,user_serv_active	; user service active
	jsr	user_service_rout
	clr.b	user_serv_active	; user service not active
	BPALETTE  #127  ;BLACK
	jmp       Main_1

;***************************************************************************
	.export	Coin1
Coin1:
; .if debugmode=="rad"
;	trap	#1
; .endif
	addq.w	#1,coin1_coins	; Increment Coin 1 Count
	move.w	coin1_val,d0	; Load Coin 1 Value
	add.w	d0,MoneyPool	; Add To Money Pool
	move.b	#1,CoinFlag	; Flag A New Coin
	move.w	#buytime,CTimer	; Set Initial Timer
	jsr	CalcAudits	; Calculate Audits
	jsr	coin_sounds	; Output Coin SOund
	rts
Coin2:
; .if debugmode=="rad"
;	trap	#1
; .endif
	addq.w	#1,coin2_coins	; Increment Coin 2 Count
	move.w	coin2_val,d0	; Load Coin 2 Value
	add.w	d0,MoneyPool	; Add To Money Pool
	move.b	#1,CoinFlag	; Flag A New Coin
	move.w	#buytime,CTimer	; Set Initial Timer
	jsr	CalcAudits	; Calculate Audits
	jsr	coin_sounds	; Output Coin SOund
	rts

;**********************************************************************
; Leave these two in for future needs
;**********************************************************************
Coin3:
;	addq.w	#1,coin3_coins	; Increment Coin 3 Count
;	move.w	coin3_val,d0	; Load Coin 3 Value
;	add.w	d0,MoneyPool	; Add To Money Pool
;	move.b	#1,CoinFlag	; Flag A New Coin
;	move.w	#$010A,CTimer	; Set Initial Timer
;	jsr	CalcAudits	; Calculate Audits
;	jsr	coin_sounds	; Output Coin Sound
	rts

Coin4:
;	addq.w	#1,coin4_coins	; Increment Coin 4 Count
;	move.w	coin4_val,d0	; Load Coin 4 Value
;	add.w	d0,MoneyPool	; Add To Money Pool
;	move.b	#1,CoinFlag	; Flag A New Coin
;	move.w	#$010A,CTimer	; Set Initial Timer
;	jsr	CalcAudits	; Calculate Audits
;	jsr	coin_sounds	; Output Coin Sound
	rts

;**********************************************************************
;**********************************************************************

CoinUp:
	and.b	#1,SoundsOff
	eor.b	#1,SoundsOff	; Toggle Sounds
	add.w	#1,MoneyPool	; add 1 to money pool
	move.w	#buytime,CTimer	; Set Initial Timer
	jsr	CalcAudits	; Calculate Audits
	jsr	coin_snd2	; Output Coin Sound
	rts

;***************************************************************************
coin_sounds:
;	addq.w	#1,test_num	; Increment Count
	SOUND	#COINCOUNTER_snd,#0 ; adjust coin meter
coin_snd2:
	tst.b	attract_flag
	beq.s	s_coin
	clr.l	d0
	move.w	MoneyPool,d0
	move.w	min_start_credit,d1
	divu	d1,d0
	swap	d0
	tst.w	d0
	beq.s	s_cred
s_coin
	SOUND	#COININ_snd,#0	; plain old coin sound
	rts
s_cred
	SOUND	#CREDIT_snd,#0	; have enough for game start!!
	rts

;***************************************************************************
; Initialize video and print routine		*
;***************************************************************************
InitSystem:
;	move.w	#1,FrameRate	; Set For 60 Hertz
	clr.w	FrameRate	; Set For 60 Hertz
	clr.w	d0
	move.w	#0x200,A_PLN0YTP
	move.w	d0,A_PLN0XTP

	move.w	#0x100,A_VSCALE
	move.w	#0x100,A_HSCALE

	move.w	d0,S_PLN1XTP
	move.w	d0,S_PLN1YTP

	clr.w	Mode1
	WIDTHPIX	OFF
	LOOKAHEAD	ON
	FLIP	OFF
	FLOP	OFF
	ISCALE	#$100,#$100
	DXDY	#0,#0,#0,#$100
	CLIP	ON
	TRANS	ON	; Turn On Transparency
	PLANES	#PLANEA&PLANEB
	jsr	TogglePage
	jsr	TogglePage

	jsr	LoadColors	; setup palettes for diagnostics
	jsr	SetSysFont	; setup for print routines
	rts

;***************************************************************************
;          set_prints set up for font, blit type, and palette	*
;***************************************************************************
	.import.s FontAdjust,CharTrans
	.import	SysCharTrans,char_trans,MedCharTrans
	.import	SmallAdjust
	.import	Font2Spacing,Font2Adjust

;obe
	.import	FontmSpacing,FontmSpacing2,FontmAdjust,mCharTrans



	.import	Font5Adjust
	.export	SetScoreFont

FONT1_BANK	equ	font0
FONT2_BANK	equ	font1
FONT3_BANK	equ	font2
FONT5_BANK	equ	font2

SetSysFont:
	SETPRINT	#7,#9,#FONT1_BANK,#0
	move.l	#SysCharTrans,CharTrans	; character translation table
	move.l	#SmallAdjust,FontAdjust	; Small Font Adjust Table
	clr.l	FontSpacing	; Non-Proportional Spacing
	rts

;obe
SetFontm:
	SETPRINT	#7,#9,#fontm,#0
	move.l	#mCharTrans,CharTrans	; character translation table
	move.l	#FontmAdjust,FontAdjust	; Small Font Adjust Table
;	clr.l	FontSpacing	; Non-Proportional Spacing
	move.l	#FontmSpacing,FontSpacing		; Non-Proportional Spacing
	rts

	.export	SetFontNeo1,SetFontNeo2,SetFontNeo3,SetFontNeo4
	.export	SetFontNeo5,SetFontNeo6,SetFontNeo7

	.import	neo1Spacing,neo2Spacing
	.import	neo3Spacing,neo4Spacing,neo5Spacing
	.import	neo6Spacing,neo7Spacing

SetFontNeo1:
	SETPRINT	#11,#46,#neo1,#0
	move.l	#NeoCharTrans,CharTrans	; character translation table
	clr.l	FontAdjust	; No Adjust Table
	move.l	#neo1Spacing,FontSpacing	; Proportional Spacing
	rts
SetFontNeo2:
	SETPRINT	#8,#34,#neo2,#0
	move.l	#NeoCharTrans,CharTrans	; character translation table
	clr.l	FontAdjust	; No Adjust Table
	move.l	#neo2Spacing,FontSpacing	; Proportional Spacing
	rts
SetFontNeo3:
	SETPRINT	#7,#22,#neo3,#0
	move.l	#NeoCharTrans,CharTrans	; character translation table
	clr.l	FontAdjust	; No Adjust Table
	move.l	#neo3Spacing,FontSpacing	; Proportional Spacing
	rts
SetFontNeo4:
	SETPRINT	#7,#17,#neo4,#0
	move.l	#NeoCharTrans,CharTrans	; character translation table
	clr.l	FontAdjust	; No Adjust Table
	move.l	#neo4Spacing,FontSpacing	; Proportional Spacing
	rts
SetFontNeo5:
	SETPRINT	#7,#40,#neo5,#0
	move.l	#NeoCharTrans,CharTrans	; character translation table
	clr.l	FontAdjust	; No Adjust Table
	move.l	#neo5Spacing,FontSpacing	; Proportional Spacing
	rts
SetFontNeo6:
	SETPRINT	#7,#32,#neo6,#0
	move.l	#NeoCharTrans,CharTrans	; character translation table
	clr.l	FontAdjust	; No Adjust Table
	move.l	#neo6Spacing,FontSpacing	; Proportional Spacing
	rts
SetFontNeo7:
	SETPRINT	#7,#21,#neo7,#0
	move.l	#NeoCharTrans,CharTrans	; character translation table
	clr.l	FontAdjust	; No Adjust Table
	move.l	#neo7Spacing,FontSpacing	; Proportional Spacing
	rts

	.export	NeoCharTrans
NeoCharTrans:
	dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,-1,00,00  ;* 0-15    */
	dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00  ;* 16-31   */
;		    !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
	dc.b	00,44,42,55,45,46,47,41,49,50,48,51,38,53,37,54  ;* 32-47   */
;		0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
	dc.b	01,02,03,04,05,06,07,08,09,10,40,39,00,52,00,43  ;* 48-63   */
;		@  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
	dc.b	00,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25  ;* 64-79   */
;		P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
	dc.b	26,27,28,29,30,31,32,33,34,35,36,00,00,00,00,00  ;* 80-95   */
;                        a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
	dc.b	00,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25  ;* 96-111  */
;                     p  q  r  s  t  u  v  w  x  y  z  {  }
	dc.b	26,27,28,29,30,31,32,33,34,35,36,48,49,00,00,00  ;* 112-127 */

	.align 	2
SetFont2:
	SETPRINT  #26,#24,#FONT2_BANK,#0
	move.l	#MedCharTrans,CharTrans	; character translation table
	clr.l	FontAdjust
	clr.l	FontSpacing	; Non-Proportional Spacing
	rts

SetWinFont:
	SETPRINT  #9,#8,#FONT3_BANK,#0
	move.l	#MedCharTrans,CharTrans	; character translation table
	clr.l	FontAdjust
	clr.l	FontSpacing	; Non-Proportional Spacing
	rts

SetScoreFont:
	SETPRINT	#18,#30,#FONT5_BANK,#0
	clr.l	FontAdjust
	clr.l	FontSpacing	; Non-Proportional Spacing
	move.l	#MedCharTrans,CharTrans	; character translation table
	rts

InitMainSwitches:
	add.b	#1,VBMask	; disable switch processing
	SWITCH	#COIN1,#81H,#Coin1	; immediate lft Coin subrout.
;;	SWITCH	#COIN2,#81H,#Stop1	; immediate rt. Coin subrout.
	SWITCH	#COIN2,#81H,#Coin2	; immediate rt. Coin subrout.

	clr.b	Inning	;for ticket buying on start button
	move.b	#NoY,PlayerL+YND	;not drafting (checked by start button
	move.b	#NoY,PlayerR+YND	;not drafting

	SWITCH	#START1,#81H,#GameStart1
	SWITCH	#START2,#81H,#GameStart2

	SWITCH	#TESTSW,#81H,#user_service
	SWITCH	#SERVICE,#$81,#CoinUp
	clr.b	VBMask
	rts

ClearCoinSwitches:
	SWITCH	#COIN1,#0,#0	; clear all coin switch routines
	SWITCH	#COIN2,#0,#0
	rts

Stop1:
	trap	#1
	rts

;***************************************************************************
; red is now blue and visa versa

	.export	LoadColors
LoadColors:
	move.l	#$7f00007f,d0
	move.l	#PALETTES+16*1024,a0
	jsr	LoadColor

	move.l	#$007f007f,d0
	move.l	#PALETTES+31*1024,a0
	jsr	LoadColor

	move.l	#$00000000,d0	; BLACK
	move.l	#PALETTES,a0	; palette #0
	jsr	LoadColor

	move.l	#$FFFF00FF,d0	; WHITE
	move.l	#PALETTES+$400,a0	; palette #1
	jsr	LoadColor

	move.l	#$000000FF,d0	; RED
;;	move.l	#$00FF0000,d0	; RED
	move.l	#PALETTES+$800,a0	; palette #2
	jsr	LoadColor

	move.l	#$FF000000,d0	; GREEN
	move.l	#PALETTES+$C00,a0	; palette #3
	jsr	LoadColor

	move.l	#$00FF0000,d0	; BLUE
;	move.l	#$000000FF,d0	; BLUE
	move.l	#PALETTES+$1000,a0	; palette #4
	jsr	LoadColor

	move.l	#$FF0000FF,d0	; YELLOW
;	move.l	#$FFFF0000,d0	; YELLOW
	move.l	#PALETTES+$1400,a0	; palette #5
	jsr	LoadColor

	move.l	#$FFFF0000,d0	; CYAN
;	move.l	#$FF0000FF,d0	; CYAN
	move.l	#PALETTES+$1800,a0	; palette #6
	jsr	LoadColor

	move.l	#$00FF00FF,d0	; PURPLE
	move.l	#PALETTES+$1C00,a0	; palette #7
	jsr	LoadColor

	move.l	#$BFBF00BF,d0	; Light Gray
	move.l	#PALETTES+8*1024,a0 	; palette #8
	jsr	LoadColor

	move.l	#$52300080,d0	; Brown
;	move.l	#$52800030,d0	; Brown
	move.l	#PALETTES+9*1024,a0	; palette #9
	jsr	LoadColor

	move.l	#$7F000000,d0	; Dark Green
	move.l	#PALETTES+10*1024,a0	; palette #10
	jsr	LoadColor

	move.l	#$800000FF,d0	; Orange
;	move.l	#$80FF0000,d0	; Orange
	move.l	#PALETTES+11*1024,a0	; palette #11
	jsr	LoadColor

	move.l	#$3F3F003F,d0	; Dark Gray
	move.l	#PALETTES+12*1024,a0	; palette #12
	jsr	LoadColor

	move.l	#$00000000,d0	; black
	move.l	#PALETTES+15*1024,a0	; palette #15
	jsr	LoadColor

	move.l	#$00000000,d0	; black
	move.l	#PALETTES+127*1024,a0	; palette #127
	jsr	LoadColor

	move.l	#$7f7f0000,d0	; white
	move.l	#PALETTES+17*1024,a0	; palette #17
	jsr	LoadColor

	rts

LoadExceptPal:
	move.l	#$FF0000FF,d0	; CYAN
	move.l	#PALETTES+$400,a0	; palette #1
	jsr	LoadColor
	move.l	#$FFFF00FF,d0	; WHITE
	move.l	#PALETTES+$800,a0	; palette #2
	jsr	LoadColor
	rts

LoadColor:
	move.w	#255,d1
	move.l	a0,a1
	swap	d0
LoadColorSection:		; only load one section
	move.l	d0,(a0)+
	dbf	d1,LoadColorSection
	move.l	#0,(8,a1)	; drop shadow = black
	move.l	#0,(91*4,a1)	; text outline = black
	move.l	#0,(1020,a1)	;
	rts

;***************************************************************************
;				*
;	Start Of Audits And Diagnostics Code	*
;				*
;***************************************************************************

;***************************************************************************
;          calculate all check sum results		*
;***************************************************************************
cal_checksums:
	jsr	cal_oper	; free play and credits
	jsr	CalcAudits
	rts

;***************************************************************************
;          check and calculate operator vars		*
;***************************************************************************
	.export	cal_oper
cal_oper:
	move.l	#oper_ram,a0	; start address
	move.l	#end_oper_ram,a1
	jsr	fix_checksum
	rts

;***************************************************************************
;          check and calculate audit checksums		*
;***************************************************************************
CalcAudits:
	movem.l	d1/a0/a1,-(a7)	; give the game code guys a break
	move.l	#audit_ram,a0
	move.l	#end_audit_ram,a1
	jsr	fix_checksum
	movem.l	(a7)+,d1/a0/a1	; get it all back
	rts

;***************************************************************************
;          set user_serv_flg to indicate service switch press	*
;***************************************************************************
user_service:
	move.b	#1,user_serv_flg	; indicate that we want user service
	rts

;***************************************************************************
;          set flag when any start is pressed		*
;***************************************************************************

	.export	user_ready
	.import.s	picout
user_ready:
	SOUND	#ADJUSTABLEMENUSELECT,#0
	move.b	#1,user_rdy_flg
	rts

;***************************************************************************
;          set flag when any select is pressed		*
;***************************************************************************
	.export	user_select
user_select:
	move.b	#1,user_sel_flg
	rts

;***************************************************************************
;          user service main menu loop		*
;***************************************************************************
MainMenu:
	clr.w	main_menu_pos	; Set To First Menu Item
MainMenuLP
	APALETTE	#WHITE	; Set To White Palette
	PLANES	#PLANEA	; Display On Playe A
	move.w	main_menu_pos,d1	; Set To First Menu Item
	lea	main_menu,a0	; Load Address Of Main Menu
	lea	main_sub,a1	; Load Address Of Main Menu sub menus
	jsr	DoMenu	; Display Menu
	move.w	menu_pos,main_menu_pos
	cmp.l	#0,a0	; Check If All Done
	beq.s	MainMenu_9	; Branch If It Is
	jsr	(a0)	; Execute Menu Item
	jsr	TogglePage	; Display Page
	bra.s	MainMenuLP
MainMenu_9:
	rts



	.align	2
;***************************************************************************
;  DO MENU for all operator adjustables		*
;    enter with:			*
;	a0 - pointing to menu		*
;	a1 - pointing to submenu	obe	*
;	d1 - starting position in menu	*
;				*
;	trk - added view only bit 14 to menu_entries	*
;	trk - added single space bit 13 to menu_entries	*
;    menu_flags:			*
;	bit 7 - variable data field		*
;	bit 6 - view only data field		*
;	bit 5 - single space display lines	*
;	bit 4 - sub menus   obe		*
;***************************************************************************

START_Y	equ	29
TEXT_X	equ	4

	.export	DoMenu
DoMenu:
	move.l	a1,menu_sub	;possible sub menus

	move.w	d1,menu_pos	; d1 holds startup pos
	move.w	(a0)+,d0	; number of entries in menu
	move.w	d0,menu_entries
	and.w	#0x00ff,d0	; upper 8 bits are flags
	move.w	d0,menu_num
	move.w	menu_entries,d0
	lsr.w	#8,d0
	move.b	d0,menu_flags
	move.l	a0,menu_ptr	; save pointer to menu structure
	tst.b	clear_on
	bne.s	DoMenu_1
	jsr	TogglePage	; clear the screen
DoMenu_1:
	move.l	menu_ptr,a0
	move.l	(a0)+,a1	; get pointer to heading
	move.l	a0,menu_ptr
	move.l	a1,menu_head	; name of menu

	clr.b	user_rdy_flg

print_menu:
	jsr	top_menu_mess	; all info for menus
	btst	#7,menu_flags	; check for variables
	beq	pm1
	btst	#6,menu_flags	; check for view only
	bne	pm1
	jsr	change_valxs	; header for changing Values
pm1:
	clr.w	menu_cnt	; current menu item
;          clr.b	FrameCount	; clear the frame counter
;	PLOT	#TEXT_X,#73	; 80;55
	PLOT	#95,#73	; 80;55
	move.w	menu_cnt,d0

menu_loop:
	cmp.w	menu_pos,d0
	bne	norm_msk
	btst	#6,menu_flags	; check for view only
	bne	norm_msk

;obe
	move.w	#WHITE,boxram_color
	move.w	#3,boxram_pixel
	move.w	#20,boxram_height
	move.w	#182,boxram_width

	btst	#7,menu_flags	; if set then do fields
	beq	box_left
	move.w	#RGTSCR-8,boxram_width
box_left
	move.w	#4,boxram_x
	move.w	pry_coor,d0
	sub.w	#6,d0
	move.w	d0,boxram_y
	lea	boxram,a0
	jsr	write_vram

	btst	#4,menu_flags	; check for sub menus
	beq	no_subs
	move.w	menu_cnt,d0
	asl.w	#2,d0	; mult by 4
	move.l	menu_sub,a0
	move.l	(a0,d0.w),a0	; string pointer
	cmp.l	#0,a0
	beq	no_subs
	move.w	prx_coor,xsave
	move.w	pry_coor,ysave
	move.w	prx_init,isave
	jsr	(a0)
	move.w	xsave,prx_coor
	move.w	ysave,pry_coor
	move.w	isave,prx_init
no_subs




	APALETTE  #HIGHLIGHT	; red
	bra.s	on_mask
norm_msk
	APALETTE  #CHOICE
on_mask:
	move.w	menu_cnt,d0
	asl.w	#3,d0	; mult by 8
	move.l	menu_ptr,a0
	move.l	(a0,d0.w),a0	; string pointer


	btst	#7,menu_flags	; if set then do fields
	beq	p_center
	move.w	#7,prx_coor
	jsr	Print
	move.w	#220,prx_coor
	bra.s	pdone
p_center
; centered menu text,  obe
	jsr	PrintCentered
pdone


	btst	#7,menu_flags	; if set then do fields
	beq	no_menu_field

	move.w	menu_cnt,d0
	asl.w	#3,d0	; mult by 8
	add.w	#4,d0	; skip text pointer
	move.l	menu_ptr,a0
	move.l	(a0,d0.w),a1	; get field pointer
	cmp.l	#0,a1
	beq       no_menu_field	; skip if 0
	btst	#6,menu_flags	; if view only then have pointer
	bne	on_mask1
	move.w	(10,a1),d0	; get variable display mode
	move.l	(a1),a1	; get address of variable
	cmpi.w	#2,d0	; check for 16 bit decimal number mode
	bne	on_mask2
on_mask1:
	move.w	(a1),d0	; get 16 bit number from a1 pointer
	and.l     #0ffffh,d0	; make into a long
	move.b	#5,d1	; 5 chars max,  JRGT
	jsr	HexToDec
	PRINTS    #print_field	; print dec value
	bra.s	no_menu_field
on_mask2:			; will print time in min:sec
	move.w	(a1),d1	; get number of seconds
	move.l	#0,d0
on_mask3:
	subi.w	#60,d1
	bmi	on_mask4
	addi.w	#1,d0
	bra.s	on_mask3
on_mask4:
	addi.w	#60,d1
	move.w	d1,menu_sec
	move.b	#2,d1	; 2 chars max, JRGT
	jsr	HexToDec
	PRINTS	#print_field
	PRINT	":"
	clr.l	d0
	move.w	menu_sec,d0
	move.b	#0x42,d1	; 2 digits zero padding
	jsr	HexToDec
	PRINTS	#print_field
no_menu_field:
	CARRET
	btst	#5,menu_flags	; check for single spacing
	bne	nom1
	CARRET
nom1:
	move.w	menu_cnt,d0
	cmp.w	menu_num,d0
	beq	menu_pr_done	; done printing when equal
	add.w	#1,d0
	move.w	d0,menu_cnt
	bra	menu_loop

menu_pr_done:
	jsr	TogglePage
	APALETTE  #CHOICE
	DELAY	#10

no_y_motion:
	DELAY	#1


;obe test
;	jsr	Random
;	move.w	d0,boxram_color
;	move.w	#3,boxram_pixel
;	move.w	#5,boxram_height
;	move.w	#5,boxram_width
;	move.w	#0,boxram_x
;	move.w	#0,boxram_y
;	lea	boxram,a0
;	jsr	write_vram
;	.import	DoToggle
;	jsr	DoToggle
;	DELAY	#4


	tst.b	user_rdy_flg
	bne	got_choice

	btst	#6,menu_flags	; check for view only menu
	bne	no_y_motion

	btst	#7,menu_flags	; if variable fields test for x motion
	beq	skip_x_test

	jsr	TestLeftRight	; test for x motion on buttons or track device
	tst.w	d1
	beq       skip_x_test

	move.w	menu_pos,d0
	asl.w	#3,d0	; mult by 8, 2 long values per entry
	add.w	#4,d0	; skip string pointer
	move.l	menu_ptr,a0
	move.l	(a0,d0.w),a0	; ponter to menu field
	cmp.l	#0,a0
	beq       skip_x_test	; skip null pointers
	move.l	a0,a1	; have pointetr to def_variable table
	move.l	(a1),a0	; pointer to variable
	move.w	(a0),d0	; current value
	tst.w	d1
	bmi	m_sub
	add.w	(8,a1),d0	; add value increment
	bra.s	m_check
m_sub:
	sub.w	(8,a1),d0
m_check:
	cmp.w	(4,a1),d0	; check if new value is too low
	bcs	no_store
	cmp.w	(6,a1),d0
	bgt	no_store
	move.w	d0,(a0)	; new value is in range so store it!
	jsr	cal_oper	; do new check sum
no_store
	SOUND	#ADJUSTABLEMENUMOVE,#0
	bra	print_menu

skip_x_test:
	jsr	TestUpDown	; d1 holds -,0,+ for up nothing or down
	tst.w	d1
	beq       no_y_motion
	add.w	menu_pos,d1	; add current pos to value in d1
test_cond_neg:
	bpl       not_under_y	; if pos we have not gone under
	move.w	menu_num,d1	; add total entries to neg value, ex 6 + (-1) = 5
	bra.s	test_cond_ok	; test again incase value was very negative
not_under_y:
	cmp.w	menu_num,d1	; is d0 < menu_num
	ble       test_cond_ok
	clr.w	d1
test_cond_ok:
	move.w	d1,menu_pos
	SOUND	#ADJUSTABLEMENUMOVE,#0
	bra	print_menu

got_choice:
	tst.w	menu_entries	; if neg then choice must be 0
	bpl       exit_at_will
	tst.w	menu_pos
	beq       exit_at_will
	clr.w	menu_pos
	clr.b	user_rdy_flg
	bra	print_menu
exit_at_will:
	move.w	menu_pos,d0
	asl.w	#3,d0	; 2 long offsets
	add.w	#4,d0	; skip string pointer
	move.l	menu_ptr,a0	; ponter to menu routine
	move.l	(a0,d0.w),a0	; ponter to menu field
	rts		; 0 if an exit was found

;test_values:
;	move.l	#test_fields,a0	; pointer to field to be testes structs
test_val_loop:
	move.l	(a0),a1	; pointer to field
	cmp.l	#0,a1
	beq       test_val_done
	move.w	(a1),d0	; get value in field in A
	cmp.w	(4,a0),d0	; test against lowest value
	bcc       not_too_low	; was bhs
	move.w	(4,a0),d0
	bra.s	store_new_val
not_too_low:
	cmp.w	(6,a0),d0
	bls       no_new_val
	move.w	(6,a0),d0	; get upper limit
store_new_val:
	move.w	d0,(a1)
no_new_val
	lea	(8,a0),a0	; 8 bytes per struct
	bra.s	test_val_loop
test_val_done:
	rts

	.export	print_version
print_version:
	APALETTE	#TITLE
	PPRINT    #TEXT_X+80,#START_Y-8,"POWER UP BASEBALL V1.5"
	rts



;obe
	.export	PrintCentered
PrintCentered
	move.w	prx_coor,xsave2
	move.w	#9999,d6	;prevents blitting

	PUSHW	d7

	jsr	Print
	move.w	prx_coor,d1
	sub.w	xsave2,d1	;length of string
	lsr.w	d1
	move.w	xsave2,d0	;x to center on
	sub.w	d1,d0
	move.w	d0,prx_coor
	clr.w	d6

	POPW	d7

	jsr	Print
	rts

	.import	write_vram

	.align	2
titlebox1:
	dc.w	YELLOW	;color
	dc.w	3	;pixel
	dc.w	30	;height
	dc.w	RGTSCR	;width
	dc.w	0	;x (upper left corner)
	dc.w	0	;y (upper left corner)
titlebox2:
	dc.w	BLACK
	dc.w	3
	dc.w	26
	dc.w	RGTSCR-4
	dc.w	2
	dc.w	2
insbox1:
	dc.w	RED
	dc.w	3
	dc.w	29
	dc.w	190
	dc.w	0
	dc.w	32
insbox2:
	dc.w	BLACK
	dc.w	3
	dc.w	25
	dc.w	190-4
	dc.w	0+2
	dc.w	32+2
chngbox1:
	dc.w	RED
	dc.w	3
	dc.w	29
	dc.w	RGTSCR
	dc.w	0
	dc.w	32
chngbox2:
	dc.w	BLACK
	dc.w	3
	dc.w	25
	dc.w	RGTSCR-4
	dc.w	0+2
	dc.w	32+2


opadjbox1:
	dc.w	BLUE
	dc.w	3
	dc.w	79
	dc.w	188
	dc.w	194
	dc.w	55
opadjbox2:
	dc.w	BLACK
	dc.w	3
	dc.w	79-4
	dc.w	188-4
	dc.w	194+2
	dc.w	55+2

;***************************************************************************
;		   PRINT 'STRING' centered	*
;***************************************************************************
PRINTC:	macro	string
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

CReturn12:
	add.w	#12,pry_coor
	move.w	prx_init,prx_coor
	rts



	.export	top_menu_mess
top_menu_mess:

	DELAY	#1
	lea	titlebox1,a0
	jsr	write_vram
	lea	titlebox2,a0
	jsr	write_vram

	APALETTE  #TITLE
	PLOT	#192,#START_Y-18
	move.l	menu_head,a0	; name of menu
	jsr	PrintCentered	; print header
;	bsr	print_version

	PLOT	#TEXT_X,#START_Y
	tst.b	menu_mess
	bne	no_i_mess
	move.w	menu_entries,d0
	btst	#14,d0	; check for view only menu
	beq	select_mess
	CARRET
	CARRET
	APALETTE	#INSTRUCTION
	PRINT	"PRESS START TO EXIT"
	bra	menu_head_mess
select_mess:
	btst	#7,menu_flags	; if set then do fields
	bne	change_ins
	lea	insbox1,a0
	jsr	write_vram
	lea	insbox2,a0
	jsr	write_vram
	CARRET
	APALETTE  #INSTRUCTION
	move.l	#FontmSpacing2,FontSpacing ; sqeeze Spacing
	move.w	#95,prx_coor	;center on this x
	PRINTC	"SELECT WITH 2ND & HOME"
	CARRET
	move.w	#95,prx_coor
	PRINTC	"ACTIVATE WITH START"
	bra	end_ins
change_ins
	lea	chngbox1,a0
	jsr	write_vram
	lea	chngbox2,a0
	jsr	write_vram
	CARRET
	APALETTE  #INSTRUCTION
;	move.l	#FontmSpacing2,FontSpacing ; sqeeze Spacing
	move.w	#192,prx_coor	;center on this x
	PRINTC	"SELECT WITH 2ND & HOME"
	CARRET
	move.w	#192,prx_coor
	PRINTC	"CHANGE VALUE WITH 1ST AND 3RD"
end_ins
	move.l	#FontmSpacing,FontSpacing ; Proportional Spacing

no_i_mess:
menu_head_mess:
	CARRET
	CARRET
;	APALETTE  #TITLE
;	move.l	menu_head,a0	; name of menu
;	jsr	Print	; print header

;menu box
	move.w	#WHITE,boxram_color
	move.w	#3,boxram_pixel
	move.w	menu_num,d0
	add.w	#1,d0	;menu count +1
	mulu.w	#18,d0
	add.w	#8,d0	;space at bottom           	
	move.w	d0,boxram_height

	move.w	#RGTSCR-1,boxram_width
	btst	#7,menu_flags	; if set then do fields
	bne	full_width
	move.w	#190,boxram_width
full_width
	move.w	#0,boxram_x
	move.w	#64,boxram_y
	lea	boxram,a0
	jsr	write_vram

	move.w	#BLACK,boxram_color
	sub.w	#4,boxram_height
	sub.w	#4,boxram_width
	add.w	#2,boxram_x
	add.w	#2,boxram_y
	lea	boxram,a0
	jsr	write_vram

	rts


change_valxs:
	PLOT	#180,#120

	APALETTE  #INSTRUCTION
	PPRINT    #TEXT_X,#200,"TO CHANGE VALUES"
	CARRET
	APALETTE  #INSTRUCTION
	PRINT	"MOVE JOYSTICK LEFT TO DECREASE"
	CARRET
	PRINT	"MOVE JOYSTICK RIGHT TO INCREASE"
	CARRET
exit_xinst:
	rts

;***************************************************************************
;  TestLeftRight will return a value in d1 from		*
;          left or right joystick action on any joystick	*
;	d1 =  0  no motion		*
;	d1 = -1  left motion		*
;	d1 = +1  right motion		*
;***************************************************************************
TestLeftRight:
;	move.w	#-1,d1	; Flag For Left
;	move.b	PLYRIN1,d0	; Load Player 1 Input
;	and.b	PLYRIN2,d0	; And With Player 2 Input
;	btst	#5,d0	; Check For Left
;	beq.s	TestLR_9	; Branch If There Is
;	move.w	#1,d1	; Flag For Right 
;	btst	#4,d0	; Check For Right
;	beq.s	TestLR_9	; Branch If There Is
;	clr.w	d1	; no x motion


	move.b	#BUTTON1_3,d0
	jsr	SwitchState
	move.w	#-1,d1	; Flag For Up
	cmp.b	#SWITCH_CLOSED,d0
	beq.s	TestLR_9

	move.b	#BUTTON1_1,d0
	jsr	SwitchState
	move.w	#1,d1	; Flag For Down
	cmp.b	#SWITCH_CLOSED,d0
	beq.s	TestLR_9


	move.b	#BUTTON2_3,d0
	jsr	SwitchState
	move.w	#-1,d1	; Flag For Up
	cmp.b	#SWITCH_CLOSED,d0
	beq.s	TestLR_9

	move.b	#BUTTON2_1,d0
	jsr	SwitchState
	move.w	#1,d1	; Flag For Down
	cmp.b	#SWITCH_CLOSED,d0
	beq.s	TestLR_9


	clr.w	d1	; No Y Motion
TestLR_9:
	rts

;***************************************************************************
;          TestUpDown will return a value in d1 from	*
;          up or down joystick action on any joystick	*
;	d1 =  0  no motion		*
;	d1 = -1  up motion		*
;	d1 = +1  down motion		*
;***************************************************************************

	.export	TestUpDown
TestUpDown:
	move.b	#BUTTON1_2,d0
	jsr	SwitchState
	move.w	#-1,d1	; Flag For Up
	cmp.b	#SWITCH_CLOSED,d0
	beq.s	TestUD_9

	move.b	#BUTTON1_4,d0
	jsr	SwitchState
	move.w	#1,d1	; Flag For Down
	cmp.b	#SWITCH_CLOSED,d0
	beq.s	TestUD_9


	move.b	#BUTTON2_2,d0
	jsr	SwitchState
	move.w	#-1,d1	; Flag For Up
	cmp.b	#SWITCH_CLOSED,d0
	beq.s	TestUD_9

	move.b	#BUTTON2_4,d0
	jsr	SwitchState
	move.w	#1,d1	; Flag For Down
	cmp.b	#SWITCH_CLOSED,d0
	beq.s	TestUD_9


	clr.w	d1	; No Y Motion
TestUD_9:
	rts

;***************************************************************************
;          OPERATOR Adjustables		*
;***************************************************************************

opadj_tsub
	lea	opadjbox1,a0
	jsr	write_vram
	lea	opadjbox2,a0
	jsr	write_vram

	APALETTE  #BLUE
	PLOT	#289,#61
	PRINTC	"GAME MODE"
	jsr	CReturn12
	PRINTC   "GAME RESET"
	jsr	CReturn12
	PRINTC	"VOLUME SETTING"
	jsr	CReturn12
	PRINTC	"ATTRACT MODE SETTING"
	jsr	CReturn12
	PRINTC	"CREDIT SETTING"
	jsr	CReturn12
	PRINTC	"SKILL SETTING"

	rts


	.export	oper_adj
oper_adj:
	clr.w	oper_menu_pos	; startup pos
oper_adjLP
	move.w	oper_menu_pos,d1	; startup pos
	lea	oper_menu,a0	; operator adjustables
	jsr	DoMenu
	move.w	menu_pos,oper_menu_pos
	cmp.l	#0,a0
	beq       oper_done
	jsr	(a0)
	bra.s	oper_adjLP

oper_done:
	jmp       cal_oper	; rts from there

;***************************************************************************

free_norm:
	lea	mode_menu,a0	; mode select menu
	move.w	FreePlay,d1	; 0 or 1 start pos
	beq       free_ok
	moveq     #1,d1
free_ok:
	jsr	DoMenu
	move.w	a0,d0
	move.w	d0,FreePlay
;;jds hard code test
;	move.w	#1,FreePlay
	jmp       cal_oper

;***************************************************************************

free_award:
	lea	award_menu,a0	; mode select menu
	move.w	FreeAward,d1	; 0 or 1 start pos
	beq       free_awardok
	moveq     #1,d1
free_awardok:
	jsr	DoMenu
	move.w	a0,d0
	move.w	d0,FreeAward
;;jds hard code test
;	move.w	#1,FreePlay
	jmp       cal_oper

;***************************************************************************

speech_setting:
	lea	speech_menu,a0	; mode select menu
	move.w	SpeechRating,d1	; 0 or 1 start pos
	beq       sp_ok
	moveq     #1,d1
sp_ok:
	jsr	DoMenu
	move.w	a0,d0
	move.w	d0,SpeechRating
;;jds hard code test
;	move.w	#1,FreePlay
	jmp       cal_oper



;***************************************************************************
	.export	oper_adj1
oper_adj1:			; not used test
	rts		; Disable Security
	tst.b	picout
	beq.s	oper_adj2
	move.w	GameTime,d0
	and.w	#15,d0
	bne.s	oper_adj2
	jsr	Random
	move.b	d0,d6
	jsr	Random
	asl.l	#8,d6
	move.b	d0,d6
	jsr	Random
	asl.l	#8,d6
	move.b	d0,d6
	jsr	Random
	asl.l	#8,d6
	move.b	d0,d6
	move.l	d6,a0
	move.b	(a0),d0
	move.b	1(a0),(a0)
	move.b	d0,1(a0)
oper_adj2:
	rts

	.export	waitstate_flg
waitstate_norm:
	lea	wmode_menu,a0	; mode select menu
	move.w	waitstate_flg,d1	; 0 or 1 start pos
	beq       wafree_ok
	moveq     #1,d1
wafree_ok:
	jsr	DoMenu
	move.w	a0,d0
	move.w	d0,waitstate_flg
	tst.w	waitstate_flg
	beq.s	SetFast
        move.w	#$33,A_GROMWAIT   ; wait states
	bra.s	SetFast_1
SetFast:
        move.w	#$22,A_GROMWAIT   ; wait states
SetFast_1:
	jmp       cal_oper

;---------------------------------------------------------------------
	.export	ScrLevel
camer_test:
	lea	camera_menu,a0	; mode select menu
	move.w	ScrLevel,d1	; 0 or 1 start pos
	beq       camfree_ok
	moveq     #1,d1
camfree_ok:
	jsr	DoMenu
	move.w	a0,d0
	move.w	d0,ScrLevel
	jmp       cal_oper

;---------------------------------------------------------------------

do_reset:
	clr.w	d1	; startup pos
	lea	reset_menu,a0
	jsr	DoMenu
	cmp.l	#0,a0
	beq       done_reset
	jsr	(a0)
	SOUND	#RESET_SND,#0
	jsr	TogglePage	; display reset message
	DELAY	#90
done_reset:
	jmp       cal_checksums	; recalculate all check sums

;---------------------------------------------------------------------

atm_snd:
	move.w	AttractSounds,d1
	lea	atm_menu,a0	; attract mode sounds menu
	jsr	DoMenu
	jsr	(a0)
	jmp       cal_oper

ocassional:
	move.w	#1,AttractSounds	; Set To Occasional Sounds
	rts

all_off:
	clr.w	AttractSounds	; Turn Off Attract Sounds
	rts

all_on:
	move.w	#2,AttractSounds	; Set To All On
	rts

;---------------------------------------------------------------------
cpcd_adj:
	clr.w	d1
	lea	cpcd_menu,a0	; credits/coins/etc menu
	jsr	DoMenu
	jmp       cal_oper

;---------------------------------------------------------------------
;---------------------------------------------------------------------
ticket_adj:
	clr.w	d1
	lea	ticket_menu,a0	; credits/coins/etc menu
	jsr	DoMenu
	jmp       cal_oper

;---------------------------------------------------------------------

screen_adjx:
	move.w	screen_adj_x,d1
	lea	sax_adj_menu,a0
	jsr	DoMenu
	move.w	a0,d0
	move.w	d0,screen_adj_x
	jsr	cal_oper

	move.w	screen_adj_x,d0	; offset into table
	asl.w	d0
	lea	scr_adj_tab,a0	; table ptr
	move.w	(a0,d0.w),d1	; get num out of table
	move.w	d1,oper_adjx	; save to oper adjustables
	jsr	cal_oper	; recalc checksum
	jsr	do_video_parms	; and pound the ASIC w/ new values
	rts

;---------------------------------------------------------------------

skill_adj:
	move.w	skill_level,d1
	lea	skill_menu,a0	; skill level adjust menu
	jsr	DoMenu
	move.w	a0,d0
	move.w	d0,skill_level
	jmp       cal_oper

;---------------------------------------------------------------------

violence_adj:
	move.w	violence_level,d1
	lea	violence_menu,a0	; violence level adjust menu
	jsr	DoMenu
	move.w	a0,d0
	move.w	d0,violence_level
	jmp       cal_oper

;---------------------------------------------------------------------
button_adj:
	move.w	button_type,d1
	lea	button_menu,a0	; button level adjust menu
	jsr	DoMenu
	move.w	a0,d0
	move.w	d0,button_type
	jmp       cal_oper

;***************************************************************************
;          Main Menu                                                       *
;***************************************************************************
	ds	0
main_menu:
	dc.w	4-1+0x1000
	dc.l	main_head

	dc.l	diag_head	; system diagnostics menu
	dc.l	SystemTest
	dc.l	oper_head	; operator adjustable menu
	dc.l	oper_adj
	dc.l	audit_head	; game audit menu
	dc.l	audit_adj
	dc.l	main0
	dc.l	0	; exit main_exit

main_sub
	dc.l	diag_tsub
	dc.l	opadj_tsub
	dc.l	audit_tsub
	dc.l	end_tsub
	dc.l	0

main_head:
	dc.b	"POWER UP BASEBALL TEST MENU  v1.5",0
main0:
	dc.b	"EXIT TEST MENU",0

diag_tsub	ds	0
	lea	diagbox1,a0
	jsr	write_vram
	lea	diagbox2,a0
	jsr	write_vram

	APALETTE  #BLUE
	PLOT	#289,#44
	PRINTC	"VIDEO TEST"
	jsr	CReturn12
	PRINTC	"SOUND TEST"
	jsr	CReturn12
	PRINTC	"GROM TEST"
	jsr	CReturn12
	PRINTC	"VIDEO RAM TEST"
	jsr	CReturn12
	PRINTC	"PLAYER CONTROL TEST"
	jsr	CReturn12
	PRINTC	"PALETTE TEST"

	rts

diagbox1:	ds	0
	dc.w	BLUE
	dc.w	3
	dc.w	78
	dc.w	188
	dc.w	194
	dc.w	39
diagbox2:
	dc.w	BLACK
	dc.w	3
	dc.w	78-4
	dc.w	188-4
	dc.w	194+2
	dc.w	39+2


audit_tsub	ds	0
	lea	auditbox1,a0
	jsr	write_vram
	lea	auditbox2,a0
	jsr	write_vram

	APALETTE  #BLUE
	PLOT	#289,#103
	PRINTC	"VIEW GAME"
	jsr	CReturn12
	PRINTC	"PLAY STATISTICS"

	rts

auditbox1:	ds	0
	dc.w	BLUE
	dc.w	3
	dc.w	28
	dc.w	188
	dc.w	194
	dc.w	99
auditbox2:
	dc.w	BLACK
	dc.w	3
	dc.w	28-4
	dc.w	188-4
	dc.w	194+2
	dc.w	99+2


end_tsub	ds	0
	lea	endbox1,a0
	jsr	write_vram
	lea	endbox2,a0
	jsr	write_vram

	APALETTE  #BLUE
	PLOT	#289,#127
	PRINTC	"END TESTING"

	rts

endbox1:	ds	0
	dc.w	BLUE
	dc.w	3
	dc.w	20
	dc.w	188
	dc.w	194
	dc.w	121
endbox2:
	dc.w	BLACK
	dc.w	3
	dc.w	20-4
	dc.w	188-4
	dc.w	194+2
	dc.w	121+2



;***************************************************************************
;          OPERATOR MENUS		*
;***************************************************************************
oper_menu:	ds	0
	dc.w	9-1
	dc.l	oper_head

	dc.l	oper0
	dc.l	0	; 0 - oper_exit
	dc.l	mode_head
	dc.l	free_norm	; 1 - game mode
	dc.l	reset_head
	dc.l	do_reset	; 2 - resets
	dc.l	volume_title
	dc.l	volume_tst	; 3 - volume settings
	dc.l	atm_head
	dc.l	atm_snd	; 4 - attract mode sounds
	dc.l	cpcd_head
	dc.l	cpcd_adj	; 5 - credits and playing time
;	dc.l	tick_head	
;	dc.l	ticket_adj	; 6 - cards adj
	dc.l	skill_head
	dc.l	skill_adj	; 7 - skill adj
;	dc.l	sax_set_head
;	dc.l	screen_adjx	; 8 - screen x adjustment

	dc.l	fmode_head
	dc.l	free_award	; 9 - free games
	dc.l	speech_head
	dc.l	speech_setting	;10 - speech rating
	
	
;	dc.l	wmode_head
;	dc.l	waitstate_norm	; 1 - game mode
;;	dc.l	cam_head
;;	dc.l	camer_test
;;	dc.l	violence_head
;;	dc.l	violence_adj	; 5 - violence setting
;	dc.l	button_head
;	dc.l	button_adj	; 6 - button configurations

oper_head:
	dc.b	"OPERATOR ADJUSTABLES",0
oper0:
	dc.b	"EXIT ADJUSTABLES",0

;---------------------------------------------------------------------
mode_menu:	ds	0
	dc.w	2-1
	dc.l	mode_head

	dc.l	mode0
	dc.l	0	; normal play
	dc.l	mode1
	dc.l	1	; free play

mode_head:
	dc.b	"GAME MODE SELECTION",0

mode0:
	dc.b	"COIN MODE",0
mode1:
	dc.b	"FREE PLAY",0

;---------------------------------------------------------------------
award_menu:	ds	0
	dc.w	2-1
	dc.l	fmode_head

	dc.l	fmode0
	dc.l	0	; no free games
	dc.l	fmode1
	dc.l	1	; free games

fmode_head:
	dc.b	"FREE GAME AWARDS",0

fmode0:
	dc.b	"NO FREE GAMES",0
fmode1:
	dc.b	"FREE GAMES",0

;---------------------------------------------------------------------
speech_menu:	ds	0
	dc.w	2-1
	dc.l	speech_head

	dc.l	smode0
	dc.l	0	; G RATING
	dc.l	smode1
	dc.l	1	; PG RATING

speech_head:
	dc.b	"SPEECH RATING",0

smode0:
	dc.b	"G-RATED SPEECH",0
smode1:
	dc.b	"PG-RATED SPEECH",0



;---------------------------------------------------------------------
wmode_menu:	ds	0
	dc.w	2-1
	dc.l	wmode_head
	dc.l	wmode0
	dc.l	0	; normal play
	dc.l	wmode1
	dc.l	1	; free play

wmode_head:
	dc.b	"WAITSTATES MODE SELECTION",0

wmode0:
	dc.b	"WAIT STATE 22",0
wmode1:
	dc.b	"WAIT STATE 33",0

;---------------------------------------------------------------------
camera_menu:	ds	0
	dc.w	2-1
	dc.l	cam_head
	dc.l	cam0
	dc.l	0	; 256 line
	dc.l	cam1
	dc.l	1	; 240 line

cam_head:
	dc.b	"CAMERA MODE SELECTION",0

cam0:
	dc.b	"256 LINES MODE",0
cam1:
	dc.b	"240 LINES MODE",0

;---------------------------------------------------------------------
violence_menu:	ds	0
	dc.w	4-1
	dc.l	violence_head	; strokes per coin
	dc.l	violence_set0
	dc.l	0
	dc.l	violence_set1
	dc.l	1
	dc.l	violence_set2
	dc.l	2
	dc.l	violence_set3
	dc.l	3

violence_head:
	dc.b	"VIOLENCE SETTINGS ()",0

violence_set0:
	dc.b	"1. FULL VIOLENCE   ",0
violence_set1:
	dc.b	"2. NO BLOOD ",0
violence_set2:
	dc.b	"3. BLOOD ONLY ",0
violence_set3:
	dc.b	"4. NO VIOLENCE ",0

;---------------------------------------------------------------------
button_menu:	ds	0
	dc.w	3-1
	dc.l	button_head
	dc.l	button0
	dc.l	0	; 5 button
	dc.l	button1
	dc.l	1	; 6 button
	dc.l	button2
	dc.l	2	; 3 button

button_head:
	dc.b	"BUTTON CONFIGURATIONS",0

button0:
	dc.b	"5-BUTTON CONFIGURATION - RECOMMENDED",0
button1:
	dc.b	"6-BUTTON CONFIGURATION",0
button2:
	dc.b	"3-BUTTON CONFIGURATION",0

;---------------------------------------------------------------------
reset_menu:	ds	0
	dc.w	4-1
	dc.l	reset_head
	dc.l	reset0
	dc.l	0
	dc.l	reset1
	dc.l	reset_all
	dc.l	reset2
	dc.l	score_reset
	dc.l	reset3
	dc.l	audit_reset


reset_head:
	dc.b	"GAME RESETS",0
reset0:
	dc.b	"EXIT RESETS",0
reset1:
	dc.b	"RESET ALL TO DEFAULT",0
reset2:
	dc.b	"RESET HIGH SCORES ONLY",0
reset3:
	dc.b	"RESET AUDITS ONLY",0

;---------------------------------------------------------------------
atm_menu:	ds	0
	dc.w	3-1
	dc.l	atm_head

	dc.l	atm1
	dc.l	all_off
	dc.l	atm2
	dc.l	ocassional
	dc.l	atm3
	dc.l	all_on

atm_head:
	dc.b	"ATTRACT MODE SOUNDS",0

atm1:
	dc.b	"ALL OFF",0
atm2:
	dc.b	"OCCASIONAL",0
atm3:
	dc.b	"ALL ON",0

;---------------------------------------------------------------------
cpcd_menu:	ds	0
	dc.w	5-1+0x8000	; adjustable field menu
	dc.l	cpcd_head	; credit per coin left

	dc.l	cpcd0
	dc.l	0	; 0 - exit byte
	dc.l	cpcd1
	dc.l	def_coin1_val	; 1 - coin door 1 value
	dc.l	cpcd2
	dc.l	def_coin2_val	; 2 - coin door 2 value
	dc.l	ica1
	dc.l	def_min_start_credit	; 3 - initial coins to start
;	dc.l	ica2
;	dc.l	def_min_cont_credit	; 4 - coins to continue
	dc.l	DrCost
	dc.l	draft_credit	; 5 - coins to continue

cpcd_head:
	dc.b	"CREDITS SETTINGS",0

cpcd0:
	dc.b	"EXIT",0
cpcd1:
	dc.b	"DOOR 1 VALUE OF COIN        ",0
cpcd2:
	dc.b	"DOOR 2 VALUE OF COIN        ",0
ica1:
	dc.b	"COINS NEEDED FOR CREDIT     ",0
;ica2:
;	dc.b	"COINS NEEDED TO CONTINUE    ",0
DrCost:
	dc.b	"CREDITS NEEDED TO DRAFT     ",0


;---------------------------------------------------------------------
ticket_menu:	ds	0
	dc.w	2-1+0x8000	; adjustable field menu
	dc.l	tick_head	; credit per coin left

	dc.l	tick0
	dc.l	0	; 0 - exit byte
	dc.l	tick1
	dc.l	def_card_val	; 1 - coin door 1 value

tick_head:
	dc.b	"CARD SETTINGS",0

tick0:
	dc.b	"EXIT CARD SETTINGS",0
tick1:
	dc.b	"NUMBER OF WINS PER CARD ",0
;---------------------------------------------------------------------
sax_adj_menu:	ds	0	; JDZ 9-24-90
	dc.w	5-1
	dc.l	sax_set_head	; strokes per coin
	dc.l	sax_set0
	dc.l	0	; exit byte
	dc.l	sax_set1
	dc.l	1	; exit byte
	dc.l	sax_set2
	dc.l	2	; exit byte
	dc.l	sax_set3
	dc.l	3	; exit byte
	dc.l	sax_set4
	dc.l	4	; exit byte

sax_set_head:
	dc.b	"HORIZONTAL SCREEN SET",0    ;JDZ 10-19-90
sax_set0:
	dc.b	"SCREEN ADJUST - 1 LEFT MOST",0     ;JDZ 10-19-90
sax_set1:
	dc.b	"SCREEN ADJUST - 2 ",0	            ;JDZ 10-19-90
sax_set2:
	dc.b	"SCREEN ADJUST - 3 CENTER",0        ;JDZ 10-19-90
sax_set3:
	dc.b	"SCREEN ADJUST - 4 ",0	            ;JDZ 10-19-90
sax_set4:
	dc.b	"SCREEN ADJUST - 5 RIGHT MOST",0    ;JDZ 10-19-90

;---------------------------------------------------------------------
skill_menu:	ds	0
	dc.w	5-1
	dc.l	skill_head	; strokes per coin
	dc.l	skill_set0
	dc.l	0
	dc.l	skill_set1
	dc.l	1
	dc.l	skill_set2
	dc.l	2
	dc.l	skill_set3
	dc.l	3
	dc.l	skill_set4
	dc.l	4

skill_head:
	dc.b	'SKILL LEVEL ADJUSTMENT',0

skill_set0:
	dc.b	'SKILL LEVEL 1 - EASIEST',0
skill_set1:
	dc.b	'SKILL LEVEL 2 ',0
skill_set2:
	dc.b	'SKILL LEVEL 3 ',0
skill_set3:
	dc.b	'SKILL LEVEL 4 ',0
skill_set4:
	dc.b	'SKILL LEVEL 5 - HARDEST',0

;***************************************************************************
;          AUDITS menus			*
;***************************************************************************
audit_menu:	ds	0
	dc.w	3-1
	dc.l	audit_head
	dc.l	audit0
	dc.l	0	; exit main_exit
	dc.l	audit1
	dc.l	GameAudits	; display game audits
	dc.l	audit2
	dc.l	reset2_adj	; exit main_exit

audit_head:
	dc.b	"GAME AUDITS",0
audit0:
	dc.b	"EXIT AUDITS",0
audit1:
	dc.b	"REVIEW AUDITS",0
audit2:
	dc.b	"RESET AUDITS",0


reset2_menu:	ds	0
	dc.w	2-1
	dc.l	audit2
	dc.l	reset20
	dc.l	0
	dc.l	reset3a
	dc.l	audit_reset

reset2_head:
	dc.b	"AUDITS RESETS",0
reset20:
	dc.b	"NO RESET AUDITS ",0
reset3a:
	dc.b	"RESET AUDITS ",0

	.export	diag_head
diag_head:
	dc.b	"DIAGNOSTIC TESTS",0
	.export	diag0
diag0:
	dc.b	"RETURN TO MAIN MENU",0
;	dc.b	"EXIT TESTS",0

;***************************************************************************
;          ROM constants			*
;***************************************************************************
; tables to define operator adjustable parameters	*
; used by DoMenu routine			*
; fields are:				*
;	dc.l	address of variable		*
;	dc.w	minimum allowable value		*
;	dc.w	maximum allowable value		*
;	dc.w	increment/decrement value	*
;	dc.w	display type: 2 = 16 bit decimal/ 3 = min:sec	*
;***************************************************************************
	ds	0
draft_credit:
	dc.l	min_draft_credit
	dc.w	1,99,1,2
def_min_cont_credit:
	dc.l	min_cont_credit
	dc.w	1,15,1,2
def_min_start_credit:
	dc.l	min_start_credit
	dc.w	1,15,1,2
def_coin1_val:
	dc.l	coin1_val
	dc.w	1,8,1,2
def_coin2_val:
	dc.l	coin2_val
	dc.w	1,8,1,2
;def_coin3_val:
;	dc.l	coin3_val
;	dc.w	1,8,1,2
;def_coin4_val:
;	dc.l	coin4_val
;	dc.w	1,8,1,2
def_card_val:
	dc.l	card_val
	dc.w	1,15,1,2

scr_adj_tab:	dc.w	30,40,50,60,70,80	; horizontal screen adjust data

;***************************************************************************
;          operator adjustable backed up ram area	*
;***************************************************************************
	.region	"RomCode"
oper_rom:	ds	0
	.region "BATRAM"
oper_ram:	ds	0		; operator ram area
;	BACKUP	backup_failure,dc.w,1234 ; for testing only to induce failures
;jdz
	BACKUP    FreePlay,dc.w,0	; used to indicate free play mode
	BACKUP    button_type,dc.w,0	; indicates 5,6,3 button mode
	BACKUP    min_start_credit,dc.w,2	; minimum tokens needed to start
	BACKUP    min_draft_credit,dc.w,2	; minimum tokens needed to draft
	BACKUP    min_cont_credit,dc.w,2	; minimum tokens needed to continue
	BACKUP    oper_adjx,dc.w,50	; horz screen adjust
	BACKUP    coin1_val,dc.w,1	; coin1 coin door value
	BACKUP    coin2_val,dc.w,1	; coin2 coin door value
;	BACKUP    coin3_val,dc.w,1	; coin3 coin door value
;	BACKUP    coin4_val,dc.w,1	; coin4 coin door value
	BACKUP	violence_level,dc.w,4	; violence level
	BACKUP    AttractSounds,dc.w,0	; turn on or off all sound
	BACKUP    skill_level,dc.w,2	; difficulty level 0 - 4
	BACKUP    screen_adj_x,dc.w,2	; inital setscreen x_pos default
	BACKUP    VolumeLevel,dc.w,15	; turn on or off all sound
	BACKUP    ScrLevel,dc.w,0	; turn on or off all sound
	BACKUP    waitstate_flg,dc.w,0	; used to set wait states
;;	BACKUP    extralines_flg,dc.w,0	; used to toggle between 240 & 256 line mode
	BACKUP    card_val,dc.w,15	; cards per win
	BACKUP    FreeAward,dc.w,1	; used to award free games
	BACKUP    SpeechRating,dc.w,1	; 0=G 1=PG
end_oper_ram: ds.w	1

;***************************************************************************
oper_backup:	ds	0
	ds.w	 end_oper_ram-oper_ram	; backup area for operator adjs, second copy
end_oper_backup: ;ds.w	1

;***************************************************************************
;          audit backed up ram area		*
;***************************************************************************
	.region   "RomCode"
audit_rom:	ds	0
	.region "BATRAM"
audit_ram:	ds	0
	BACKUP    total_start_computer,dc.w,0  ; total games started
	BACKUP    total_start_human,dc.w,0  ; total games started
	BACKUP    total_cont,dc.w,0	; total games continued
	BACKUP	  total_complete,dc.w,0	; total games completed
	BACKUP    total_games,dc.w,0	; total games played
	BACKUP    total_time,dc.l,0	; total time spent playing game in seconds

	BACKUP    coin1_coins,dc.w,0	; total coins1 door plays
	BACKUP    coin2_coins,dc.w,0	; total coins2 door plays
	BACKUP    total_drafts,dc.w,0	; total number of drafts

	BACKUP	chartot1,dc.w,0	; chars picked total
	BACKUP	chartot2,dc.w,0	; chars picked total
	BACKUP	chartot3,dc.w,0	; chars picked total
	BACKUP	chartot4,dc.w,0	; chars picked total
	BACKUP	chartot5,dc.w,0	; chars picked total
	BACKUP	chartot6,dc.w,0	; chars picked total
	BACKUP	chartot7,dc.w,0	; chars picked total
	BACKUP	chartot8,dc.w,0	; chars picked total
	BACKUP	chartot9,dc.w,0	; chars picked total
	BACKUP	chartot10,dc.w,0	; chars picked total
	BACKUP	chartot11,dc.w,0	; chars picked total
	BACKUP	chartot12,dc.w,0	; chars picked total
	BACKUP	chartot13,dc.w,0	; chars picked total
	BACKUP	chartot14,dc.w,0	; chars picked total
	BACKUP	chartot15,dc.w,0	; chars picked total
	BACKUP	chartot16,dc.w,0	; chars picked total
	BACKUP	chartot17,dc.w,0	; chars picked total
	BACKUP	chartot18,dc.w,0	; chars picked total

	BACKUP	secret1,dc.w,0	; hidden meters
	BACKUP	secret2,dc.w,0	; no specials
	BACKUP	secret3,dc.w,0	; no throws
	BACKUP	secret4,dc.w,0	; secret 4
	BACKUP	secret5,dc.w,0	; secret 4
	BACKUP	secret6,dc.w,0	; secret 4
	BACKUP	secret7,dc.w,0	; secret 4
	BACKUP	secret8,dc.w,0	; secret 4
	BACKUP	secret9,dc.w,0	; secret 4
	BACKUP	secret10,dc.w,0	; secret 4
	BACKUP	secret11,dc.w,0	; secret 4
	BACKUP	secret12,dc.w,0	; secret 4
	BACKUP	secret13,dc.w,0	; secret 4
	BACKUP	secret14,dc.w,0	; secret 4
	BACKUP	secret15,dc.w,0	; secret 4
	BACKUP	secret16,dc.w,0	; secret 4
	BACKUP	comptag,dc.w,0	; secret 4
	BACKUP    MoneyPool,dc.w,0	; number of coins in machine

;obe	#include	"chartab.asm"
end_audit_ram: ds.w  1

;*********************************************************
;	score backed up ram area		*
;*********************************************************
	.export	RecordList
	.region "RomCode"
score_rom: ds 0
	.region "BATRAM"
score_ram: ds 0
RecordList:
	BACKUP	score1,dc.l,1090
	BACKUP	score1_name0,dc.b,'JAN'   	;initials & track num  
	BACKUP	null_n1,dc.b,0		;put high score1 stuff here
	
	BACKUP	score2,dc.l,1080
	BACKUP	score2_name0,dc.b,'LPM'   	;initials & track num  
	BACKUP	null_n2,dc.b,0		;put high score1 stuff here

	BACKUP	score3,dc.l,1070
	BACKUP	score3_name0,dc.b,'RWM'   	;initials & track num  
	BACKUP	null_n3,dc.b,0		;put high score1 stuff here

	BACKUP	score4,dc.l,1060
	BACKUP	score4_name0,dc.b,'AVN'   	;initials & track num  
	BACKUP	null_n4,dc.b,0		;put high score1 stuff here

	BACKUP	score5,dc.l,1050
	BACKUP	score5_name0,dc.b,'RAD'   	;initials & track num  
	BACKUP	null_n5,dc.b,0		;put high score1 stuff here

end_score_ram: ds.w 1

	.region   "RomCode"
	ds 0
;***************************************************************************
;          init_ram will initialize backed up RAM if needed	*
;***************************************************************************
	.export	init_ram
init_ram:
	movea.l   #audit_ram,a0
	movea.l   #end_audit_ram,a1
	jsr	check_sum
	beq.s	audit_ok
	ori.b	#2,backup_ram_status	; mark audits as failed
	jsr	audit_reset
;o	jsr	score_reset	; Reset Scores Too
audit_ok

;validate record checksums
	clr.w	ZRecCnt	;
	move.w	#MaxPlayers,d2	;all players
	movea.l	#records,a0
reclp
	move.l	a0,recadr	;save for possible clearing
	lea.l	RecordSize-2(a0),a1	;end of record
	jsr	check_sum
	beq.s	score_ok
	ori.b	#1,backup_ram_status	; mark audits as failed
;zero record
	add.w	#1,ZRecCnt	;count-em
	clr.w	d3
.zrec	clr.b	([recadr],d3.w)
	add.w	#1,d3
	cmp.w	#RecordSize,d3
	bne.s	.zrec

	PUSHL	a0	;save em
	move.l	recadr,a0
	lea.l	RecordSize-2(a0),a1	;point at checksum
	jsr	fix_checksum
	POPL	a0	;save em
score_ok
	lea.l	2(a0),a0	;get past checksum
	sub.w	#1,d2
	bne.s	reclp	;next record
	cmp.w	#400,ZRecCnt	;MaxPlayers/2
	blt.s	NoTotalInit
	jsr	init_records	;init all, if many bad, so default high scores get set
NoTotalInit


	movea.l   #oper_ram,a0
	movea.l   #end_oper_ram,a1
	jsr	check_sum
	beq.s	oper_ok
	ori.b	#4,backup_ram_status	; mark adjustables as failed
	movea.l   #oper_backup,a0
	movea.l   #end_oper_backup,a1
	jsr	check_sum
	bne.s	oper_bad
	jsr	oper_restore
	bra.s	oper_ok
oper_bad
	ori.b	#8,backup_ram_status	; mark adjustables backup as failed
	jsr	oper_reset
;o	jsr	score_reset	; Reset Scores Too
	jsr	set_oper_back
oper_ok
	rts

;***************************************************************************
reset_all:
	jsr	init_records	;clear all player info
;o	jsr	score_reset
	jsr	audit_reset
	jsr	oper_reset
	jsr	set_oper_back	;bad? hits game cnt for player vs comp
	rts

;***************************************************************************

init_records
	jsr	records_reset	;clear all player info

;	clr.w	ZRecCnt	;
	move.w	#MaxPlayers,d2	;all players
	movea.l	#records,a0
.reclp
	move.l	a0,recadr
	lea.l	RecordSize-2(a0),a1	;point at checksum
	jsr	fix_checksum
	move.l	recadr,a0
	add.l	#RecordSize,a0
	sub.w	#1,d2
	bne.s	.reclp	;next record
	rts

;***************************************************************************
	.export	check_sum
check_sum:
	moveq	#0,d0	; initial checksum = 0
	cmpa.l	#$600000,a0
	bge.s	cs_loop	;branch if a player record
	move.w	a0,d0	; initial checksum = address of data
cs_loop
	moveq     #0,d1	; clear out d1
	move.b	(a0)+,d1	; get byte
	add.w	d1,d0	; add to current checksum
	cmpa.l	a1,a0	; check to see if we're at the end
	blo.s	cs_loop	; and keep going if not
	not.w	d0
	cmp.w	(a1),d0	; compare our checksum vs. the real one
	rts		; and return to caller with Z flag indicating

fix_checksum:
	jsr	check_sum
	move.w	d0,(a1)
	rts

;***************************************************************************
;          user_service_rout		*
;          This will exterminate all other tasks		*
;          It will return to MainProcess when done.	*
;***************************************************************************
	.export	user_service_rout
user_service_rout:
	EXTERM    #0	; kill all tasks
	PLANES    #PLANEA&PLANEB
	jsr	TogglePage
	jsr	TogglePage
	jsr	ClearCoinSwitches
	SOUND	#KILL,#0	; turn off all sounds
	DELAY	#2	; wait 1 frame for no good reason
	SOUND	#SOUNDSON,#0	; all sounds on
	DELAY	#2	; wait 1 frame for no good reason
	jsr	InitCycle	; initialize color cycling
	DELAY	#2	; wait 1 frame for no good reason
	jsr	InitSystem	; reset system video
	DELAY	#1	; wait 1 frame for no good reason
;
; setup switches for operator responses
; activate all switches for operator's convience
;
	SWITCH	#START1,#81h,#user_ready ;start button pressed
	SWITCH	#START2,#81h,#user_ready
	SWITCH	#BUTTON1_2,#81H,#user_select ;select button pressed
	SWITCH	#BUTTON2_2,#81H,#user_select
	SWITCH	#BUTTON1_1,#81H,#user_select ;select button pressed
	SWITCH	#BUTTON2_1,#81H,#user_select

	clr.b	clear_on
	clr.b	menu_mess

;obe
	jsr	SetFontm	; setup for print routines

	jsr	MainMenu	; main menu loop

	btst.b	#7,DIPS
	bne	user_service_rout
	jsr	TogglePage
	clr.b	user_serv_flg
	rts

;***************************************************************************
;          handle coins per game requirements		*
;***************************************************************************
;          AUDITS			*
;***************************************************************************
audit_adj:
	clr.w	d1	; startup pos
	lea	audit_menu,a0	; audits menu
	jsr	DoMenu
	cmp.l	#0,a0
	beq       audit_done
	jsr	(a0)
	bra.s	audit_adj

audit_done:
	jmp       CalcAudits	; rts from there

;***************************************************************************

reset2_adj:
	clr.w	d1
	lea	reset2_menu,a0	; do audit_reset menu
	jsr	DoMenu
	cmp.l	#0,a0
	beq       done2_reset
	jsr	(a0)
	SOUND	#RESET_SND,#0
	jsr	TogglePage	; display reset message
	DELAY	#90
done2_reset:
	jmp       cal_checksums	; recalculate all check sums

;***************************************************************************
;	display game audits		*
;***************************************************************************
GameAudits:
	clr.w	d0	; calculate total number of coins
	add.w	coin1_coins,d0
	add.w	coin2_coins,d0
;	add.w	coin3_coins,d0
;	add.w	coin4_coins,d0
	move.w	d0,total_coins

	clr.w	AverageGame	; Clear Average Game Time
	move.l	total_time,d0	; Load Total Time
;	move.w	total_games,d1	; Load Total Games
	move.w	total_start_computer,d1 ;games started
	beq.s	GameAud_0	; Branch If Zero
	divu	d1,d0	; Calculate Average Time
	move.w	d0,AverageGame	; Store Average Game Time
GameAud_0:
	clr.b	clear_on
	clr.b	menu_mess
	clr.w	screen_cnt	; Start With First Screen
	jsr	TogglePage	; Clear Screen
	move.w	#10,MinCamX	;was 10
	clr.b	user_rdy_flg	; Clear Start Pressed Flag
GameAud_1:



	DELAY	#1
	lea	titlebox1,a0
	jsr	write_vram
	lea	titlebox2,a0
	jsr	write_vram
	APALETTE  #TITLE
	PLOT	#192,#START_Y-18
	move.l	menu_head,a0	; name of menu
	jsr	PrintCentered	; print header

	PLOT	#TEXT_X,#START_Y+5
	lea	chngbox1,a0
	jsr	write_vram
	lea	chngbox2,a0
	jsr	write_vram
	CARRET
	APALETTE  #INSTRUCTION
	move.w	#192,prx_coor	;center on this x
	PRINTC	"PRESS START TO CONTINUE"
	CARRET
;	move.w	#192,prx_coor
;	PRINTC	"CHANGE VALUE WITH 2ND AND HOME"


;	APALETTE	#TITLE
;	cmp.w	#1,screen_cnt	; index into list
;	bne.s	GameAud_1a
	APALETTE	#GREEN
	PLOT	MinCamX,#60
;	bra.s	GameAud_1b
;GameAud_1a:
;	bsr	print_version
;	PLOT	#20,#32-16
;GameAud_1b:


	clr.l	FontSpacing	; Non-Proportional Spacing
	jsr	SetSysFont	; setup for print routines

	move.w	#10,prx_init	;x pos

	lea	AuditDisplays,a0	; screen display list
	move.w	screen_cnt,d0	; index into list
	asl.w	#2,d0	; 4 bytes per entry
	move.l	(a0,d0.w),a0	; routine to call
	jsr	(a0)	; display screen
	jsr	SetFontm	; setup for print routines
	jsr	TogglePage	; Display The Page

	cmp.w	#1,screen_cnt	; index into list
	bne.s	GameAud_2

;	jsr	audit_left
;	jsr	audit_right
	DELAY	#1	; nothing happened so just short delay
	tst.b	user_rdy_flg	; check if ready to exit
	beq	GameAud_1	; Loop Until Start Pressed

GameAud_2:
	DELAY	#1	; nothing happened so just short delay
	tst.b	user_rdy_flg	; check if ready to exit
	beq.s	GameAud_2	; Loop Until Start Pressed

	clr.b	user_rdy_flg	; Clear Start Pressed Flag
	SOUND	#ADJUSTABLEMENUSELECT,#0	; Put Out Sound
	add.w	#1,screen_cnt	; Increment Screen Count
;;sj added 1 screen to game audits
	cmp.w	#2,screen_cnt	; Check If All Done
	bne	GameAud_1	; Display Next Screen
	jsr	TogglePage
	clr.b	clear_on
	rts




audit_left:
	move.b	#JOY1_LF,d0	;check if want to move memory up alot
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne.s	audit_left2
audit_left1:
	move.w	MinCamX,d0
	add.w	#5,d0	; rate of movement
	cmp.w	#10,d0
	bgt.w	audit_left2
	move.w	d0,MinCamX
	bra.s	audit_left3
audit_left2:
	move.b	#JOY2_LF,d0	;check if want to move memory up alot
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	beq.s	audit_left1
audit_left3:
	rts

audit_right:
	move.b	#JOY1_RT,d0	;check if want to move memory up alot
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne.s	audit_right2
audit_right1:
	move.w	MinCamX,d0
	sub.w	#5,d0	; rate of movement
	cmp.w	#-230,d0
	ble.w	audit_right2
	move.w	d0,MinCamX
	bra.s	audit_right3
audit_right2:
	move.b	#JOY2_RT,d0	;check if want to move memory up alot
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	beq.s	audit_right1
audit_right3:
	rts
	

;***************************************************************************
; Array Of Audits Screens		*
;***************************************************************************
AuditDisplays:
	dc.l	AuditsPage1	; Page 1
	dc.l	AuditsPage3	; Page 3
;	dc.l	AuditsPage2	; Page 2

	.export	AuditsPage1
AuditsPage1:
	PRINTS	#APString1	; Display Audits Page 1
	rts

AuditsPage2:
	PRINTS	#APString2	; Display Audits Page 2
	rts

AuditsPage3:
	PRINTS	#APString3	; Display Audits Page 3
	rts

APString1:
	dc.b	13,0xff,YELLOW
;	dc.b	"PRESS START TO CONTINUE",13,13,0xff,GREEN
	dc.b	"AUDITS SCREEN 1",13,13,0xff,WHITE
	dc.b	"COIN DOOR 1-COINS . . . .  "
	WORDSTRING coin1_coins,5,JRGTS
	dc.b	13,"COIN DOOR 2-COINS . . . .  "
	WORDSTRING coin2_coins,5,JRGTS
	dc.b	13,"TOTAL COINS . . . . . . .  "
	WORDSTRING total_coins,5,JRGTS
	dc.b	13,13,"GAMES STARTED VS COMPUTER  "
	WORDSTRING total_start_computer,5,JRGTS
	dc.b	13,"GAMES STARTED VS PLAYER    "
	WORDSTRING total_start_human,5,JRGTS
	dc.b	13,"GAMES CONTINUED . . . . .  "
	WORDSTRING total_cont,5,JRGTS
	dc.b	13,"GAMES COMPLETED . . . . .  "
	WORDSTRING total_complete,5,JRGTS
	dc.b	13,"TOTAL DRAFTS  . . . . . .  "
	WORDSTRING total_drafts,5,JRGTS
;	dc.b	13,"TAG GAMES COMPLETED . . . ."
;	WORDSTRING comptag,5,JRGTS
	dc.b	0

APString2:
	dc.b	13,0xff,GREEN
	dc.b	"AUDITS SCREEN 2",13,13,0xff,WHITE

	dc.b	0

APString3:
	dc.b	13,0xff,YELLOW
	dc.b	"AUDITS SCREEN 3",13,13,0xff,WHITE
	dc.b	"AVERAGE GAME TIME         "
	WORDSTRING AverageGame,5,JRGTS
	dc.b	" SEC.",13,13

	dc.b	"TOTAL GAME TIME         "
	LONGSTRING total_time,5,JRGTS
	dc.b	" SEC.",13,13

	dc.b	0

;***************************************************************************
;          reset score ram		*
;***************************************************************************
	.align	2
score_reset:
	APALETTE	#BADSTUFF
	PPRINT    #90,#60,"HIGH SCORES RESET"
;	COPY      score_rom,score_ram,#(end_score_ram-score_ram)
;	
;	movea.l   #score_ram,a0
;	movea.l   #end_score_ram,a1
;	jsr	fix_checksum
;;	jsr	ResetStats	; /Reset PowerUp Data

	jsr	init_records	;clear all player info

	rts

;***************************************************************************
;          audit_reset resets audit information		*
;***************************************************************************
audit_reset:
	APALETTE	#BADSTUFF
	PPRINT    #90,#80,"AUDITS RESET"
	COPY      audit_rom,audit_ram,#(end_audit_ram-audit_ram)
	movea.l   #audit_ram,a0
	movea.l   #end_audit_ram,a1
	jsr	fix_checksum
	rts

;***************************************************************************
;          copy operator adjustables from backup copy	*
;          from ram to ram		*
;***************************************************************************
oper_restore:
	COPY      oper_backup,oper_ram,#(end_oper_ram-oper_ram)

	jsr	do_video_parms
	APALETTE	#BADSTUFF
	PPRINT    #90,#100,"OPERATOR ADJUSTABLES RESTORED"

	move.w	end_oper_backup,end_oper_ram
	rts

;***************************************************************************
;          copy operator adjustable defaults and major inits	*
;          from rom to ram		*
;***************************************************************************
oper_reset:
	COPY      oper_rom,oper_ram,#(end_oper_ram-oper_ram)

	jsr	do_video_parms
	APALETTE	#BADSTUFF
	PPRINT    #90,#100,"OPERATOR ADJUSTABLES RESET"

	movea.l   #oper_ram,a0
	movea.l   #end_oper_ram,a1
	jsr	fix_checksum
	rts

;***************************************************************************
;          copy good oper_ram to oper_backup and move checksum	*
;***************************************************************************
set_oper_back:
	COPY      oper_ram,oper_backup,#(end_oper_ram-oper_ram)
	move.w	end_oper_ram,end_oper_backup
	rts

;***************************************************************************
do_video_parms:
	move.w	#RGTSCR+100,d0	; screen width + total porches
	sub.w	oper_adjx,d0	; minus front porch in oper_adjx
;	move.w	d0,ASIC+124	; equals = end blank, start active

	move.w	#100,d0	; back porch = porches
	sub.w	oper_adjx,d0	; minus front porch in oper_adjx
;	move.w	d0,ASIC+128	; equals = end active, start blank

	clr.w	ScreenInvert
	clr.w	ScreenInvert2
	btst.b	#5,DIPS
	beq.s	dvpx
	move.w	#1,ScreenInvert
	move.w	#1,ScreenInvert2
dvpx
	rts


;***************************************************************************
; Name:	wait_asic_idle			*
; Desc:	Wait for the queue to empty and the asic to stop all activity	*
; Enter:					*
; Exit:					*
; Comment:					*
;***************************************************************************
	.export	wait_asic_idle

wait_asic_idle:
;	POPL	d0
;	move.l	d0,lock_addr
;	PUSHL	d0
	cmpi.w	#HOSTREAD,last_cmd
	beq.s	wa2
	cmpi.w	#HOSTWRITE,last_cmd
	beq.s	wa2
wa1:
;	move.w	#0,WATCHDOG	; just incase
;	move.w	#4,lock_mode
	move.w	A_STATUS,d0	;Load ASIC Status
	andi.w	#11000000b,d0
	cmpi.b	#10000000b,d0
	bne.s	wa1	;If not, Keep Waiting
	bra.s	wax

wa2:
;	move.w	#0,WATCHDOG	; just incase
;	move.w	#5,lock_mode
	move.w	A_STATUS,d0	;Load ASIC Status
	andi.w	#01000000b,d0
	cmpi.b	#00000000b,d0
	bne.s	wa2
wax:
;	move.w	#1000,d0
;delay:
;	sub.w	#1,d0
;	bne	delay	
	rts


;***************************************************************************
;				*
;	G A M E   A U D I T S		*
;				*
; Game audits will be generated using information gathered during	*
; the course of game play. Information will be gathered using 	*
; subroutine calls to record events that happen, and provide	*
; other information about the game.		*
;				*
; One call will be made to an audit initialization routine to	*
; setup audit variables needed during a game.		*
; 				*
; A game is considered finished when the peg_4q_complete call	*
; is made. End of game auditing is done at this time.	*
; The only thing done in case of overtime is to peg that event happening	*
;				*
;***************************************************************************

IncAudit:
	movem.l	d1/a0/a1,-(a7)	; give the game code guys a break
	move.l	#audit_ram,a0	; Load Address Of First Audit
	asl.w	#1,d0	; Multiply Index By Two
	add.w	#1,(a0,d0.w)	; Increment Audit
	move.l	#audit_ram,a0
	move.l	#end_audit_ram,a1
	jsr	fix_checksum
	movem.l	(a7)+,d1/a0/a1	; get it all back
	rts

	end





