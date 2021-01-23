;***************************************************************************
;                      STREET FIGHTER   VIDEO GAME                         *
;                   INCREDIBLE TECHNOLOGIES, INC.                          *
;                    (C) COPYRIGHT 1994, IT, INC.                          *
;***************************************************************************
; Revision History			*
;   1.00	- Internal Test		*
;***************************************************************************
	.region	"RAM"
	ds	0

;***************************************************************************
;  Variable Imports			*
;***************************************************************************
	.import	VBMask
	.import.s	memory_status
	.import.s Mode1,last_cmd,S_Mode1
	.import.s	S_PLN1YTP,S_PLN1XTP
	.import.s	FontSpacing
	.import.s FrameRate,system_status,board_test_flag
	.import.s	Player1Data,Player2Data,CTimer
	.import.s	InitRank,LastRank
	.import.s	BuyIn
	.import.s	loop_flag,operator_timeout
	.import.s	menu_mess,user_rdy_flg
	.import.s	clear_on,Volume
	.import.s	user_sel_flg
	.import	VolumeLevel
	.import.s	pictest,picbyte1,picbyte2,picbyte3
	.import.s	cpunum0,cpunum1,cpunum2
	.import		MoneyPool,FontmSpacing,font_width

;***************************************************************************
;  Subroutine Imports			*
;***************************************************************************
;	.import	FontSkullClr
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
	.import	LoadColors
	.import	LoadAllPals
	.import	DoMenu
	.import	wait_asic_idle
	.import	SetSysFont,SetFont2,SetFont5,SetWinFont
	.import	print_version,LoadColors
	.import	rom_address_table
	.import	diag_head
	.import	diag0
	.import	check_sum_full
	.import	TestUpDown

	.import	SetFontm
	.import	boxram
	.import	boxram_color
	.import	boxram_pixel
	.import	boxram_height
	.import	boxram_width
	.import	boxram_x
	.import	boxram_y
	.import	top_menu_mess
	.import	titlebox1,titlebox2
	.import	chngbox1,chngbox2
	.import	PlayerL,PlayerR,NoTrackBalls,InitTrackball,ReadTrackball


;***************************************************************************
;  RAM Variables Defined In This Section		*
;***************************************************************************
	.export	vram_status0
	.export	vram_status1
	.export grom_bad_flag
	.export	screen_cnt
	.export	picnum,cpunum

SELECT_TUNE	equ	0
;COINCOUNTER_snd	equ	0
;TESTSNDSROM2	equ	0
FADE		equ	0
;CARDDISP_snd	equ	0
;TESTALL		equ	0
;TESTSNDROM0	equ	0
;TESTMUSIC1		equ	0
;TESTMUSIC2		equ	0
KILL		equ	0


;grom checksum test variables
max_set		ds.w 1
grom_set		ds.w 1
cksum_count	ds.w 1
grom_base		ds.l 1
grom_range		ds.l 1
grom_bad_flag	ds.b 1
map_pointer	ds.l 1
grom_label		ds.w 1
grom_blit		ds.w 1
grom_height	ds.w 1
prx_save		ds.w 1
pry_save		ds.w 1
grom_count		ds.w 1
gromsums		ds.l 4*17
rptr		ds.l 1
gptr		ds.l 1
quick_flag     	ds.b 1
grom_title		ds.l 1
print_string	ds.b 16	;place to build print strings

screen_cnt		ds.w 1
holdcnt1		ds.b 1
holdcnt2		ds.b 1

vram_status0	ds.w 1
vram_status1	ds.w 1

Framenum	ds.w 1
FramePal	ds.w 1
FrameBank	ds.w 1
bank	ds.b 1
palette	ds.b 1

current_sound	ds.w 1
sw_pal		ds.b 1
sw_stop        	ds.w 1
sw_cnt         	ds.w 1
sw_map		ds.w 3

loop_delay	ds.w 1
loop_pass	ds.w 1
loop_fail	ds.w 1
palram_status	ds.w 1

;pic variables
picnum		ds.b	1
picmode		ds.b	1
cpunum		ds.b	1

tbx1	ds.b	1
tby1	ds.b	1
tlx1	ds.b	1
tly1	ds.b	1

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
	#include	"pals.h"
	#include	"ramblock.h"
	#include	"groms.h"
	#include	"bsblsnds.equ"

RESET_SND	equ	0;SAYVERIFIED	; reseting oper adjustables, audits, etc

BOTSCR	equ	256
RGTSCR	equ	384
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

LTGRAY	equ	8
BROWN	equ	9
DKGREEN	equ	10
ORANGE	equ	11
DKGRAY	equ	12

;
; palette selections for menu system
;
TITLE	equ	GREEN	; title lines
INSTRUCTION	equ	YELLOW	; operator instructions
CHOICE	equ	BLUE	; menu choices operator can make
HIGHLIGHT	equ	WHITE	; currently selected choice
BADSTUFF	equ	RED	; typically things that are bad

;***************************************************************************
;          DIAGNOSTIC MENUS		*
;***************************************************************************
	.export	diag_menu
diag_menu:	ds	0
	dc.w	((diag_menu_end-diag_menu-6)/8)-1	; TRK
	dc.l	diag_head
	dc.l	screens_title	; VIDEO SCREEN TEST
	dc.l	VStest_menu	;was screens_tst  obe
	dc.l	sound_head	; SOUND TEST
	dc.l	SoundTest
	dc.l	full_grom_title	; FULL GROM CHECKSUM TEST
	dc.l	memory_tst
	dc.l	fast_grom_title	; FAST GROM CHECKSUM TEST
	dc.l	fast_memory_tst
	dc.l	vram_title	; VIDEO RAM TEST
	dc.l	vram_tst
	dc.l	pcontrol_title	; PLAYER CONTROL TEST
	dc.l	pcontrol_tst
;	dc.l	pic_head	; PIC TEST
;	dc.l	PicTest
	dc.l	palram_title	; palette RAM TEST
	dc.l	palram_tst

;	dc.l	art_title	; Volume TEST
;	dc.l	Art_test
;	dc.l	camera_title	; Volume TEST
;	dc.l	camera_test

	dc.l	diag0
	dc.l	0	; exit main_exit
diag_menu_end:


full_grom_title:
	dc.b	"FULL GROM TEST",0
fast_grom_title:
	dc.b	"FAST GROM TEST",0
pcontrol_title:
	dc.b	"PLAYER CONTROL TEST",0
screens_title:
	dc.b	"VIDEO SCREEN TEST",0
vram_title:
	dc.b	"VIDEO RAM TEST",0
	.export	volume_title
volume_title:
	dc.b	"VOLUME SETTINGS",0
art_title:
	dc.b	"ART TEST",0
pic_head:
	dc.b	"PIC TEST",0
palram_title:
	dc.b	"PALETTE RAM TEST",0

;screen_set:
;	dc.b	"CAMERA TEST",0

	.align	4
;*********************************************************************
; System board test for Manufacturing
;*********************************************************************
	.export	board_test
board_test:
	BPALETTE	#127	;42

	DELAY	#30
	jsr	sound_tst
	DELAY	#1
	jsr	vram_tst	; test video ram
	DELAY	#1
	jsr	palram_tst	; test palette ram
	jsr	TogglePage
	DELAY	#1
	jsr	do_quick_checksum	; test groms

;print results of tests
	jsr	TogglePage
	PLOT	#20,#20
	move.w	memory_status,d0	;results of system memory test
	lea	sysmem_string,a0
	bsr	good_bad_print
	CARRET
	jsr	vrt_print
	jsr	prt_print
	jsr	cks_print
	jsr	TogglePage

	move.w	#60*120,operator_timeout ; and wait awhile for operator
bt_1g:
	DELAY	#1
	move.b	#START1,d0
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0	; wait for operator to push start1
	beq	bt_1h	; br if start is pushed
	sub.w	#1,operator_timeout	; only wait so long
	beq	bt_1h			
	bra	bt_1g
bt_1h:
	jsr	LoadAllPals
	jsr	pcontrol_tst	; test player controls
bt_2G
	jsr	TogglePage
	jsr	TogglePage
	rts

here1:	bra	here1
	rts

sysmem_string:
	dc.b	"PROGRAM MEMORY U45-U48\0"
	ds 0


;***************************************************************************
;          New Screen Tests  obe
;***************************************************************************

VStest_menu
	clr.w	d1	; startup pos
	lea	ScTe_menu,a0
	jsr	DoMenu
	cmp.l	#0,a0
	beq	VSdone
	jsr	(a0)

	clr.b	user_rdy_flg
waitkey	DELAY	#1
	tst.b	user_rdy_flg	; check if ready to exit
	beq	waitkey	; Loop Until key Pressed

	bra.s	VStest_menu
VSdone	jmp       cal_oper	; rts from there


	ds	0
ScTe_menu:
	dc.w	7-1	;+0x1000
	dc.l	ScTe_head

	dc.l	sct1
	dc.l	screen2_tst	; Color Adjustment
	dc.l	sct2
	dc.l	screen1_tst	; Screen Grid Patterm
	dc.l	sct3
	dc.l	redscreen_tst	; Red Screen
	dc.l	sct4
	dc.l	greenscreen_tst	; Green Screen
	dc.l	sct5
	dc.l	bluescreen_tst	; Blue Screen
	dc.l	sct6
	dc.l	whitescreen_tst	; White Screen

	dc.l	ScTe0
	dc.l	0	; exit ScTe_exit

ScTe_head:
	dc.b	"VIDEO SCREEN TEST MENU",0
ScTe0:
	dc.b	"RETURN TO MAIN MENU",0


sct1	dc.b	"COLOR PATTERN",0
sct2	dc.b	"SCREEN GRID PATTERN",0
sct3	dc.b	"RED SCREEN",0
sct4	dc.b	"GREEN SCREEN",0
sct5	dc.b	"BLUE SCREEN",0
sct6        dc.b	"WHITE SCREEN",0

;***************************************************************************
;	video screen diagnostics		*
;	various test patterns are displayed	*
;***************************************************************************
;
; array of screen display subroutines
; routines simply display a video test screen and then return
;

diagbank	equ	1
Box1	equ	66
Box2	equ	67

	.export	screen1_tst
	ds 0
screen1_tst:
	move.w	#WHITE,boxram_color
	move.w	#3,boxram_pixel
	move.w	#BOTSCR-1,boxram_height
	move.w	#RGTSCR-1,boxram_width
	move.w	#0,boxram_x
	move.w	#0,boxram_y
	lea	boxram,a0
	jsr	write_vram


	move.w	#BLACK,boxram_color
	move.w	#62,boxram_height
	move.w	#94,boxram_width
	move.w	#2,boxram_x
	move.w	#2,boxram_y
	lea	boxram,a0
	jsr	write_vram

	jsr	across

	move.w	#2,boxram_x
	move.w	#65,boxram_y
	lea	boxram,a0
	jsr	write_vram

	jsr	across

	move.w	#2,boxram_x
	move.w	#65+63,boxram_y
	lea	boxram,a0
	jsr	write_vram

	jsr	across

	move.w	#2,boxram_x
	move.w	#65+63+63,boxram_y
	lea	boxram,a0
	jsr	write_vram

	jsr	across

	jsr	TogglePage
	rts

across
	move.w	#97,boxram_x
	lea	boxram,a0
	jsr	write_vram

	move.w	#97+95,boxram_x
	lea	boxram,a0
	jsr	write_vram

	move.w	#97+95+95,boxram_x
	lea	boxram,a0
	jsr	write_vram
	rts


	.export	screen2_tst
screen2_tst:
;	jsr	LoadColors
;	IMAGES	#diagbank
;	APALETTE	#2

	move.w	#RED,boxram_color
	move.w	#3,boxram_pixel
	move.w	#75,boxram_height
	move.w	#90,boxram_width
	move.w	#0,boxram_x
	move.w	#0,boxram_y
	lea	boxram,a0
	jsr	write_vram

	move.w	#BLUE,boxram_color
	move.w	#96,boxram_x
	lea	boxram,a0
	jsr	write_vram

	move.w	#GREEN,boxram_color
	move.w	#192,boxram_x
	lea	boxram,a0
	jsr	write_vram

	move.w	#PURPLE,boxram_color
	move.w	#288,boxram_x
	lea	boxram,a0
	jsr	write_vram


	move.w	#80,boxram_y

	move.w	#LTGRAY,boxram_color
	move.w	#0,boxram_x
	lea	boxram,a0
	jsr	write_vram

	move.w	#CYAN,boxram_color
	move.w	#96,boxram_x
	lea	boxram,a0
	jsr	write_vram

	move.w	#BROWN,boxram_color
	move.w	#192,boxram_x
	lea	boxram,a0
	jsr	write_vram

	move.w	#DKGREEN,boxram_color
	move.w	#288,boxram_x
	lea	boxram,a0
	jsr	write_vram


	move.w	#160,boxram_y

	move.w	#WHITE,boxram_color
	move.w	#0,boxram_x
	lea	boxram,a0
	jsr	write_vram

	move.w	#YELLOW,boxram_color
	move.w	#96,boxram_x
	lea	boxram,a0
	jsr	write_vram

	move.w	#ORANGE,boxram_color
	move.w	#192,boxram_x
	lea	boxram,a0
	jsr	write_vram

	move.w	#DKGRAY,boxram_color
	move.w	#288,boxram_x
	lea	boxram,a0
	jsr	write_vram


	APALETTE	#BLACK
	move.w	#0,sw_cnt	; use a counter for labeling color blocks
scr210:
	lea	screen2_colors,a0	; base of text table
	move.w	sw_cnt,d0	; index into table
	asl.w	#3,d0	; 8 bytes per entry
	lea	(a0,d0.w),a0	; current entry in table
	move.w	(a0),d1	; x coordinate
	move.w	2(a0),d2	; y coordinate
	move.l	4(a0),a0	; pointer to text
	clr.w	d6	
	move.w	#$7FFF,d7
	jsr	PPrint	; plot and print text
	add.w	#1,sw_cnt
	cmp.w	#12,sw_cnt	; past end of table
	blt.s	scr210	; br if not
	jsr	TogglePage
	rts


	ds 0
screen2_colors:
	dc.w	35,38
	dc.l	s2color1	; red
	dc.w	132,38
	dc.l	s2color2	; blue
	dc.w	220,38
	dc.l	s2color3	; green
	dc.w	315,38
	dc.l	s2color4	; purple
	dc.w	15,112
	dc.l	s2color5	; lite gray
	dc.w	128,112
	dc.l	s2color6	; cyan
	dc.w	216,112
	dc.l	s2color7	; brown
	dc.w	295,112
	dc.l	s2color8	; dark green
	dc.w	24,198
	dc.l	s2color9	; white
	dc.w	119,198
	dc.l	s2color10	; yellow
	dc.w	213,198
	dc.l	s2color11	; orange
	dc.w	302,198
	dc.l	s2color12	; dark gray

s2color1:
	dc.b	"RED",0
s2color2:
	dc.b	"BLUE",0
s2color3:
	dc.b	"GREEN",0
s2color4:
	dc.b	"PURPLE",0
s2color5:
	dc.b	"LITE GRAY",0
s2color6:
	dc.b	"CYAN",0
s2color7:
	dc.b	"BROWN",0
s2color8:
	dc.b	"DARK GREEN",0
s2color9:
	dc.b	"WHITE",0
s2color10:
	dc.b	"YELLOW",0
s2color11:
	dc.b	"ORANGE",0
s2color12:
	dc.b	"DARK GRAY",0

	ds 0

redscreen_tst:
	lea	red_screen,a0
	jsr	write_vram
	jsr	TogglePage
	rts

greenscreen_tst:
	lea	green_screen,a0
	jsr	write_vram
	jsr	TogglePage
	rts

bluescreen_tst:
	lea	blue_screen,a0
	jsr	write_vram
	jsr	TogglePage
	rts

whitescreen_tst:
	lea	white_screen,a0
	jsr	write_vram
	jsr	TogglePage
	rts




;***************************************************************************
; Quick sound test
;***************************************************************************
sound_tst:
;
; run a sound test
;
	jsr	TogglePage
	APALETTE	#WHITE
	PLOT	#20,#30
	PRINT	"SOUND TEST"
	CARRET
	jsr	TogglePage
	SOUND   #213,#0	; sound from SROM0
;;	SOUND   #TESTSNDSROM0,#0	; sound from SROM0
;;	DELAY	#60
;;	SOUND	#TESTSNDSROM1,#0	; sound from SROM1
;;	DELAY	#60
;;	SOUND	#TESTSNDSROM2,#0
;;	DELAY	#60
;;	SOUND	#TESTSNDROM0,#0	; sound from ENSONIC
	DELAY	#60
	rts

;***************************************************************************
; routine to write to VRAM via ASIC
; can draw a line or solid rectangle of any size.
; object is put on current draw page.
; enter with a0 pointing to following parameter block
;   (a0) ->  dc.w  palette to use
;         2  dc.w  data to write
;         4  dc.w  height of object -do not adjust for asic bug. routine does
;         6  dc.w  width of object
;         8  dc.w  x position
;        10  dc.w  y position
;***************************************************************************
	.import	AQStat

	.export	write_vram

write_vram:
wv10:
	tst.b	AQStat	; check if command queue idle
	beq	wv20	; br if nothing happening
	DELAY	#1
	bra.s	wv10
wv20:
	move.w	A_STATUS,d0
	btst	#IDLE_B,d0	; check for idle asic
	beq	wv10	; br if not

	move.w	(a0),d0	; get palette to use
	and.w	#0x7f,d0	; mask for valid palette range
	move.w	d0,PALSELA	; setup palette for this write

	move.w	A_STATUS,d0	; Load ASIC Status

	move.w	#$100,d0	; L/A ON
	or.w	S_Mode1,d0	; and normal bits
	move.w	d0,A_MODE1	; into asic mode1 reg

	move.w	4(a0),d0	; height of object
	move.w	d0,d1
	and.w	#0x300,d1	; check for address bits a8 & a9
	beq	wv100	; br if not set
	and.w	#0xff,d0	; get rid of existing a8 & a9
	btst	#8,d1	; is a8 set
	beq.s	wv90
	or.w	#0x200,d0	; move bit a8 to a9
wv90:
	btst	#9,d1	; is a9 set
	beq.s	wv100
	or.w	#0x100,d0	; move bit a9 to a8
wv100:
	move.w	d0,A_HEIGHT
	move.w	6(a0),A_WIDTH
	move.w	8(a0),A_STARTX
	move.w	PageLine,d0	; get page being displayed
;;sj	eori.w	#$200,d0	; put data on page not being displayed
	add.w	10(a0),d0
	move.w	d0,A_STARTY
;
	move.w	#$3,A_STATE
	move.w	#$3,last_cmd

	move.w	4(a0),d2
	mulu.w	6(a0),d2	; total number of bytes to write
	move.w	2(a0),d0	; byte to write

write_a_byte:
	btst.b	#3,A_STATUS+1	; check data register full bit
	bne.s	write_a_byte	; br if not data not ready
	move.w	d0,A_USERREG	; pixel value to VRAM

	sub.l	#1,d2	; check done writing data
	bne.s	write_a_byte	; br if not
	rts

	.align	2
red_screen:
	dc.w	RED
	dc.w	3
	dc.w	BOTSCR
	dc.w	RGTSCR
	dc.w	0
	dc.w	0

green_screen:
	dc.w	GREEN
	dc.w	3
	dc.w	BOTSCR
	dc.w	RGTSCR
	dc.w	0
	dc.w	0
blue_screen:
	dc.w	BLUE
	dc.w	3
	dc.w	BOTSCR
	dc.w	RGTSCR
	dc.w	0
	dc.w	0
white_screen:
	dc.w	WHITE
	dc.w	3
	dc.w	BOTSCR
	dc.w	RGTSCR
	dc.w	0
	dc.w	0

;***************************************************************************
;          system diagnostic tests		*
;***************************************************************************

	.export	SystemTest
SystemTest:
;;	clr.b	auto_test	;manual test mode
	clr.b	board_test_flag
;;	clr.b	startup_test_flag
	clr.b	loop_flag	;initialize looping variables
	move.w	#1,loop_delay
	clr.w	loop_pass
	clr.w	loop_fail
	clr.w	d1	; Set To First Menu Item
	lea	diag_menu,a0	; System Test Menu
	jsr	DoMenu	; Execute The Menu
	cmp.l     #0,a0	; Test If All Done
	beq.s	SysTest_9	; Branch If It Is

	jsr	(a0)	; Execute Next Item
	bra.s	SystemTest
SysTest_9:
	jsr	TogglePage
	jsr	TogglePage
	rts
here:	bra	here
	rts



;***************************************************************************
;***************************************************************************
SoundTest:
	clr.w	current_sound	; Start With First Sound
	clr.w	d1	; Start With First Menu Item
SoundTest_1:
	lea	sound_menu,a0	; sound menu
	jsr	DoMenu	; Display Menu
	cmp.l	#0,a0	; Check If Exit Chosen
	beq	SoundTest_9	; Branch If It Was
	move.w	a0,current_sound	; Save Sound Index
	SOUND	#KILL,#0	; Init Sound System
	DELAY	#4

	move.w	current_sound,d1	; Reload Current Sound
	sub.w	#1,d1	; Force To Zero Base
	lsl.w	d1
	lea	test_snd,a0	; Load Address Of Sound Table
	move.b	(a0,d1.w),d0	; Load Sound Value
	move.b	1(a0,d1.w),d1	; Load Sound Value
	jsr	SendSound	; Output The Sound

	move.w	current_sound,d1	; Reload Sound Index
	bra.s	SoundTest_1
SoundTest_9:
	SOUND	#KILL,#0	; kill all sounds
	DELAY	#2	; Delay A Little
	rts


sound_menu:	ds	0
	dc.w	8-1
	dc.l	sound_head
	dc.l	sound3
	dc.l	1
	dc.l	sound4
	dc.l	2
	dc.l	sound5
	dc.l	3
	dc.l	sound6
	dc.l	4
	dc.l	sound7
	dc.l	5
	dc.l	sound8
	dc.l	6
	dc.l	sound9
	dc.l	7
	dc.l	sound0
	dc.l	0

sound_head:
	dc.b	"SOUND TEST",0

sound0:
	dc.b	"EXIT",0
sound3:
	dc.b	"SROM0 TEST",0
sound4:
	dc.b	"SROM1 TEST",0
sound5:
	dc.b	"SROM2 TEST",0
sound6:
	dc.b	"SROM3 TEST",0
sound7:
	dc.b	"TEST MUSIC",0	;DISPENSE 1 CARD",0
sound8:
	dc.b	"COIN METER TEST",0
sound9:
	dc.b	"TEST ALL SOUND ROMS",0

;***************************************************************************
	.align	2
test_snd:
	dc.b	TestSndSRom0
	dc.b	0
	dc.b	TestSndSRom1
	dc.b	0
	dc.b	TestSndSRom2
	dc.b	0
	dc.b	TestSndSRom3
	dc.b	0
	dc.b	TestMusic1	;test music         
	dc.b	1
	dc.b	CoinCount	; 8 - Test Coin Meter
	dc.b	0
	dc.b	TestAll	; 9 - Test All
	dc.b	0

	.align	4
;***************************************************************************
;***************************************************************************
PicTest:
	jsr	OperatorsPal
	clr.b	user_rdy_flg
	clr.b	clear_on
	clr.b	menu_mess
	jsr	TogglePage	; Clear Screen
	clr.l	picmode
	clr.l	cpunum
	clr.l	picnum

	DELAY	#5

PicTest_1:
	jsr	SetSysFont	; Set For System Font
	APALETTE	#P_SYSFONT	; Use Font Palette
	PLOT	#100,#23	; Set Screen Position
	PRINT	"PIC TEST"
	PLOT	#10,#53	; Set Screen Position
	PRINT	"TO EXIT PRESS START 1"

	APALETTE	#GREEN	; highlight grom as bad
	PLOT	#10,#100	; Set Screen Position
;	PRINT	"TO RUN PRESS JAB1"
	PRINT	"TO PAUSE PRESS JAB1"

	APALETTE	#RED	; highlight grom as bad
	PLOT	#40,#130	; Set Screen Position
	PRINT	"PIC MODE - "
	and.b	#3,picmode	; cycle 0-3 only
	PRINTDECB picmode,#1,NOPAD

	PLOT	#40,#140	; Set Screen Position
	PRINT	"CPU NUM - "
	PRINTDECB cpunum,#3,NOPAD

	PLOT	#40,#150	; Set Screen Position
	PRINT	"PIC NUM - "
	PRINTDECB picnum,#3,NOPAD

;	PLOT	#40,#170	; Set Screen Position
;	PRINT	"CPU NUM0 - "
;	PRINTDECB cpunum0,#3,NOPAD

;	PLOT	#40,#180	; Set Screen Position
;	PRINT	"CPU NUM1 - "
;	PRINTDECB cpunum1,#3,NOPAD

;	PLOT	#40,#190	; Set Screen Position
;	PRINT	"CPU NUM2 - "
;	PRINTDECB cpunum2,#3,NOPAD

;	PLOT	#40,#200	; Set Screen Position
;	PRINT	"PIC PASS - "
;	PRINTDECB picpass,#3,NOPAD

;faster	DELAY	#1
	jsr	TogglePage
	jsr	Dopictest
;	DELAY	#10

	clr.l	d0
	move.b	#START1,d0
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne	PicTest_1
PicTest_9:
	jsr	SetSysFont	; Set For System Font
	jsr	TogglePage
	clr.b	clear_on
	rts

Dopictest:
	move.b	#BUTTON1_1,d0	
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
;	beq.s	Dopictest0
	bne.s	Dopictest0	;free run until button pressed
	rts
Dopictest0:
;	add.b	#1,picmode	;inc picmode
;test	bsr.s	Write_to_pic
	rts	;test

	.export	Test_pic_reslt
Test_pic_reslt:
;test_pic_reslt:
	clr.l	d0		;   Test pic result,
	clr.l	d1		 ;  do something
	move.l	#40000H,d0	 ;  bad if the
	lea	pictest,a0	  ; value in the
	move.b	(a0,d0.l),d1	 ;  ram location
	beq	Test_pic_1	 ;  does not equal
	lea	MoneyPool,a0
	add.w	d1,(a0)		;   zero.
Test_pic_1:
	rts

	.export	Read_from_pic
Read_from_pic:
	clr.l	d0
	clr.l	d1
	move.b	SECURITY+2,d0	;read from pic
	move.b	cpunum,d1	;xfer data to ram location
	eor.b	d1,d0		;if zero then ok
	move.b	d0,pictest	;xfer data to ram location
	rts

	.export	Write_to_pic	;called from intsvc
Write_to_pic:
	clr.l	d0
	move.b	cpunum,d0	;creative way to get picmode
	roxl.w	#8,d0
	or.b	cpunum,d0
	lea	PALETTES,a0
	move.w	(a0,d0.w),d1
	move.b	d1,picmode
	move.b	picmode,d0	;xfer data from ram location
	move.b	d0,SECURITY+2	;write to pic
Pic_mode_sel:			;00=Mode_0, 01=Mode_1, 10=Mode_2, 11=Mode_1
	clr.l	d1
	addi.b	#0,d1		;clear carry and extended bit

	and.b	#3,picmode	;keep lowest 2 bits
	beq	Pic_mode_0	;Mode0
	btst.b	#0,picmode	
	beq	Pic_mode_2	;Mode2
	bra	Pic_mode_1	;Mode1

Pic_mode_0:
	bsr	Pic_rnd		;get random bit
	and.b	#0FEH,cpunum0	;zero out bit 0
	or.b	d0,cpunum0	;OR in new bit

	bsr	Pic_rnd		;get random bit
	move.b	cpunum0,d1
	roxl.b	#1,d1
	and.b	#0FEH,d1
	or.b	d0,d1		;OR in new bit
	move.b	d1,cpunum0

	bsr	Pic_rnd		;get random bit
	move.b	cpunum0,d1
	roxl.b	#1,d1
	and.b	#0FEH,d1
	or.b	d0,d1		;OR in new bit
	and.b	#7H,d1		;keep first 3 bits
	move.b	d1,cpunum0

	bsr	Pic_rnd		;get random bit
	and.b	#0FEH,cpunum1	;zero out bit 0
	or.b	d0,cpunum1	;OR in new bit

	bsr	Pic_rnd		;get random bit
	move.b	cpunum1,d1
	roxl.b	#1,d1
	and.b	#0FEH,d1
	or.b	d0,d1		;OR in new bit
	move.b	d1,cpunum1

	bsr	Pic_rnd		;get random bit
	move.b	cpunum1,d1
	roxl.b	#1,d1
	and.b	#0FEH,d1
	or.b	d0,d1		;OR in new bit
	roxl.b	#2,d1
	and.b	#01CH,d1		;keep first 3 bits
	move.b	d1,cpunum1

	bsr	Pic_rnd		;get random bit
	and.b	#0FEH,cpunum2	;zero out bit 0
	or.b	d0,cpunum2	;OR in new bit

	bsr	Pic_rnd		;get random bit
	move.b	cpunum2,d1
	roxl.b	#1,d1
	and.b	#0FEH,d1
	or.b	d0,d1		;OR in new bit
	move.b	d1,cpunum2

	bsr	Pic_rnd		;get random bit
	move.b	cpunum2,d1
	roxl.b	#1,d1
	and.b	#0FEH,d1
	or.b	d0,d1		;OR in new bit
	roxl.b	#4,d1

	and.b	#070H,d1		;keep first 3 bits
	move.b	d1,cpunum2
	add.b	cpunum0,d1
	add.b	cpunum1,d1
	move.b	d1,cpunum
	rts	
;ok
;*********************************
Pic_mode_1:
	bsr	Pic_rnd		;get random bit
	and.b	#0FEH,cpunum0	;clear out bit 0
	or.b	d0,cpunum0	;OR in new bit

	bsr	Pic_rnd		;get random bit
	move.b	cpunum0,d1
	roxl.b	#1,d1		;shift number left
	and.b	#0FEH,d1	;clear out bit 0
	or.b	d0,d1		;OR in new bit
	move.b	d1,cpunum0

	bsr	Pic_rnd		;get random bit
	move.b	cpunum0,d1
	roxl.b	#1,d1		;shift number left
	and.b	#0FEH,d1	;clear out bit 0
	or.b	d0,d1		;OR in new bit
	move.b	d1,cpunum0

	bsr	Pic_rnd		;get random bit
	move.b	cpunum0,d1
	roxl.b	#1,d1		;shift number left
	and.b	#0FEH,d1	;clear out bit 0
	or.b	d0,d1		;OR in new bit
	move.b	d1,cpunum0

	bsr	Pic_rnd		;get random bit
	move.b	cpunum0,d1
	roxl.b	#1,d1		;shift number left
	and.b	#0FEH,d1	;clear out bit 0
	or.b	d0,d1		;OR in new bit
	move.b	d1,cpunum0

	bsr	Pic_rnd		;get random bit
	move.b	cpunum0,d1
	roxl.b	#1,d1		;shift number left
	and.b	#0FEH,d1	;clear out bit 0
	or.b	d0,d1		;OR in new bit
	move.b	d1,cpunum0

	bsr	Pic_rnd		;get random bit
	move.b	cpunum0,d1
	roxl.b	#1,d1		;shift number left
	and.b	#0FEH,d1	;clear out bit 0
	or.b	d0,d1		;OR in new bit
	move.b	d1,cpunum0

	bsr	Pic_rnd		;get random bit
	move.b	cpunum0,d1
	roxl.b	#1,d1		;shift number left
	and.b	#0FEH,d1	;clear out bit 0
	or.b	d0,d1		;OR in new bit
	move.b	d1,cpunum0

	add.b	cpunum1,d1
	add.b	cpunum2,d1
	move.b	d1,cpunum
	rts
;ok
;*********************************
Pic_mode_2:
	bsr	Pic_rnd		;get random bit
	and.b	#0FEH,cpunum0	;zero out bit 0
	or.b	d0,cpunum0	;OR in new bit

	bsr	Pic_rnd		;get random bit
	move.b	cpunum0,d1
	roxl.b	#1,d1
	and.b	#0FEH,d1
	or.b	d0,d1		;OR in new bit
	move.b	d1,cpunum0

	bsr	Pic_rnd		;get random bit
	move.b	cpunum0,d1
	roxl.b	#1,d1
	and.b	#0FEH,d1
	or.b	d0,d1		;OR in new bit
	and.b	#7H,d1		;keep first 3 bits
	move.b	d1,cpunum0

	bsr	Pic_rnd		;get random bit
	and.b	#0FEH,cpunum1	;zero out bit 0
	or.b	d0,cpunum1	;OR in new bit

	bsr	Pic_rnd		;get random bit
	move.b	cpunum1,d1
	roxl.b	#1,d1
	and.b	#0FEH,d1
	or.b	d0,d1		;OR in new bit
	move.b	d1,cpunum1

	bsr	Pic_rnd		;get random bit
	move.b	cpunum1,d1
	roxl.b	#1,d1
	and.b	#0FEH,d1
	or.b	d0,d1		;OR in new bit
	roxl.b	#2,d1
	and.b	#01CH,d1		;keep first 3 bits
	move.b	d1,cpunum1
	add.b	cpunum0,d1
	add.b	cpunum2,d1
	move.b	d1,cpunum
	rts
;ok
;*********************************
;Pic_rnd:
;	add.b	#1,picpass
;	move.b	picpass,d0
;	eor.b	d0,cpunum0
;	eor.b	d0,cpunum1
;	eor.b	d0,cpunum2
;	andi.b	#1,d0
;	rts
;ok
;*********************************
Pic_rnd:
	clr.l	d0
	move.b	picbyte3,d0	;copy to a working register

	roxl.b	#4,d0
	move.b	picbyte3,d1

	eor.b	d1,d0		;XOR old and new
	roxl.b	#1,d0		;puts needed value into carry

	move.b	picbyte1,d0	;rotate all to the right
	roxr.b	#1,d0
	move.b	d0,picbyte1
	move.b	picbyte2,d0
	roxr.b	#1,d0
	move.b	d0,picbyte2
	move.b	picbyte3,d0
	roxr.b	#1,d0
	move.b	d0,picbyte3
	and.b	#1,d0		;keep lsb
	rts

;***************************************************************************
;***************************************************************************
	.import	cal_oper
	.import	OperatorsPal
MINV	equ 1
MAXV	equ 30

	.export	volume_tst
volume_tst:

	clr.b	user_rdy_flg
	clr.b	clear_on
	clr.b	menu_mess
	jsr	TogglePage	; Clear Screen

	move.w	VolumeLevel,d0	; real backup
	move.w	d0,Volume	; temp
	clr.b	holdcnt1	; how long are we holding this way
	clr.b	holdcnt2	; how long are we holding this way
	SOUND	#HomerunMusic,#0

volume_test:
	DELAY	#1
	lea	titlebox1,a0
	jsr	write_vram
	lea	titlebox2,a0
	jsr	write_vram

	APALETTE  #GREEN
	PLOT	#130,#12
	PRINT	"VOLUME ADJUST"

	move.w	#WHITE,boxram_color
	move.w	#3,boxram_pixel
	move.w	#120+2,boxram_height
	move.w	#40,boxram_width
	move.w	#165,boxram_x
	move.w	#80,boxram_y
	lea	boxram,a0
	jsr	write_vram

	move.w	#BLACK,boxram_color
	move.w	#118,boxram_height
	move.w	#38,boxram_width
	move.w	#166,boxram_x
	move.w	#81,boxram_y
	lea	boxram,a0
	jsr	write_vram

	move.w	#RED,boxram_color
	move.w	#3,boxram_pixel
	move.w	Volume,d0
	asl.w	#2,d0
	move.w	d0,boxram_height
	move.w	#80+60+60+1,d1
	sub.w	d0,d1
	move.w	d1,boxram_y
	lea	boxram,a0
	jsr	write_vram


	APALETTE  #YELLOW
	PLOT	#60,#45	; Set Screen Position
	PRINT	"USE 2ND & HOME TO ADJUST VOLUME"
	PLOT	#110,#60	; Set Screen Position
	PRINT	"TO EXIT PRESS START"

	PLOT	#171,#85	; Set Screen Position
	PRINT	"MAX"

	PLOT	#173,#188	; Set Screen Position
	PRINT	"MIN"

	PLOT	#170,#210	; Set Screen Position
	PRINTDEC	Volume,#4,NOPAD

	move.w	Volume,d4
	asl.w	#3,d4	; mult by 8
	add.w	#73,d4

	DELAY	#1
	jsr	TogglePage
	jsr	VolumeAdjust
	DELAY	#4

;	clr.l	d0
;	move.b	#START1,d0
;	jsr	SwitchState
;	cmp.b	#SWITCH_CLOSED,d0
;	bne	volume_test

	tst.b	user_rdy_flg
	beq	volume_test

exit_vtest:
	move.w	Volume,d0
	move.w	d0,VolumeLevel	; real backup
	jsr	cal_oper	; do new check sum

	SOUND	#FADE,#FADE
;	jsr	SetSysFont	; Set For System Font
	jsr	TogglePage
	clr.b	clear_on
	rts

VolumeAdjust:

	jsr	TestUpDown
	tst.w	d1
	beq.s	volume_exit
	bmi.s	vol_dw1

;	move.b	#JOY1_DW,d0	;check if want to move memory up a lot
;	jsr	SwitchState
;	cmp.b	#SWITCH_CLOSED,d0
;	beq.s	vol_up1
;
;	move.b	#JOY1_LF,d0 	 ;jws check if want to move memory up a lot
;	jsr	SwitchState	 ;jws
;	cmp.b	#SWITCH_CLOSED,d0;jws
;	beq.s	vol_up1
;
;	bra.s	volume_down

vol_up1:
	move.b	Volume+1,d3
	SOUND	#SetVolume,d3
	sub.w	#1,Volume
	cmp.w	#MINV,Volume
	bgt.s	volume_down1
	move.w	#MINV,Volume
	bra.s	volume_exit


	bra.s	volume_down1
volume_down:
	clr.b	holdcnt1	; how long are we holding this way
volume_down1:
	move.b	#JOY1_UP,d0	;check if want to move memory up alot
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	beq	vol_dw1

	move.b	#JOY1_RT,d0	 ;jws check if want to move memory up alot
	jsr	SwitchState	 ;jws
	cmp.b	#SWITCH_CLOSED,d0;jws
	beq	vol_dw1

	bra.s	volume_up	 ;jws

vol_dw1:
	move.b	Volume+1,d3
	SOUND	#SetVolume,d3
	add.w	#1,Volume
	cmp.w	#MAXV,Volume
	blt.s	volume_exit
	move.w	#MAXV,Volume
	bra.s	volume_exit
volume_up:
	clr.b	holdcnt2	; how long are we holding this way
volume_exit:
	rts


;********************************************************************
;
;	G R O M   C H E C K S U M   T E S T
;
; this test performs a checksum test on the Graphics ROMS.
; there are two versions of the test. A quick test designed
; to run about 15 seconds that will only check a portion of each
; GROM set and another exhaustive test run on the complete address range.
;
; the test blits chunks of GROM into the video ram and then
; reads and sums the data from the video ram using the ASIC
;
;********************************************************************
MAX_SETS	equ 16
GROM_SETS	equ 4
;
; rom_address_table table of groms to test
; dc.l - base address of grom set
; dc.l - size of grom set. if zero then skip set
;        $800000 - 16megbit x 4 roms
;        $400000 -  8megbit x 4 roms
;        $200000 -  4megbit x 4 roms
;        $100000 -  2Megbit x 4 roms
;        $080000 -  1Megbit x 4 roms

	.import	rom_address_table
	.import	check_sum_full

	.export	memory_tst

memory_tst:
;trk TEMPORARY
	clr.b	loop_flag
	clr.w	loop_pass
	clr.w	loop_fail
	clr.b	board_test_flag

	move.b	#0,quick_flag	;test complete grom address range
	move.l	#full_grom_title,grom_title
	move.w	#128,grom_height	;size of blit
	bra	grom_common

	.export	do_quick_checksum
fast_memory_tst:
do_quick_checksum:
	move.b	#1,quick_flag	; only do a quick test
	move.l	#fast_grom_title,grom_title
	move.w	#64,grom_height	;size of blit
grom_common:
;;	tst.b	board_test_flag	;check what printing should be done
;;	bne	grt2
	jsr       TogglePageD
;;	bra	grt8
grt2:
;;	move.w	prx_coor,prx_save	; save this spot
;;	move.w	pry_coor,pry_save
;;	move.w	#PAGEB,PageLine	;draw on viewed page
;;	move.w	#PAGEB,A_PLN0YTP	; Set Plane A Tap Point
grt8:
	PLOT      #20,#20
	APALETTE  #WHITE
;;	BPALETTE  #127	;LTBLUE
	CARRET
;	PRINTHEX	#PageLine,#2
	CARRET
	tst.b	quick_flag	;check which type of test
	bne	grt10	;br if quick test
	PRINTS    grom_title
	PRINT     " - 90 SEC TO FINISH"
	bra	grt15
grt10:
	PRINTS    grom_title
grt15:			                            
;;	tst.b	board_test_flag	;check what printing should be done
;;	bne	grt17
	jsr       TogglePageD
grt17:
	CARRET
;	PRINTHEX	#PageLine,#2
	CARRET

memory_tst_loop:
	DELAY     #4
	APALETTE	#42
	BPALETTE	#127	;42

	LOADPAL	#memory_tst_loop,#0,#42,#256

	move.w    SR,-(sp)          ; Push Status Onto Stack
	ori.w     #DIRQ,SR          ; Disable IRQs

	move.w	PageLine,d0	; get current draw page
	tst.b	board_test_flag	; check test environment
	bne	grt18	; br if display page opposite draw page
	tst.b	loop_flag	; check if looping this test
	beq	grt19	; br if looping
grt18:
	eor.w	#$200,d0	; blit to page being displayed
grt19:
	add.w	#128,d0	; blit to bottom half of screen
	move.w	d0,grom_blit

	lea	gromsums,a0
	move.b    #MAX_SETS*4,d0
grt20:			; clear out checksum area
	clr.l     (a0)+
	subq.b    #1,d0
	bne.s     grt20

	move.l	#0,a0	; little bit of magic here
	jsr	get_checksum	; for some unknown reason
			; the first checksum fails on powerup
			; should be looked into TRK 1-7-94

	move.w    #0,grom_set	; grom set number
	move.w	#0,grom_count	; count of all groms
grt100:
	lea	rom_address_table,a1
	move.w	grom_set,d1	; current grom set
	asl.w	#3,d1	; 8 bytes per entry
	move.l	(a1,d1.w),a0	; base address of grom set
	cmp.l	#$ffffffff,a0	; check if at end of table
	beq	grt180	; br if done
	move.l	4(a1,d1.w),d0	; get range
	beq	grt160	; br if should skip this set
	tst.b     quick_flag	; check if long test
	bne	quick_checksum	; br if doing quick test
	swap	d0	; divide by $10000
	move.w	d0,cksum_count	; number of chunks to do
grt145:
	clr.l     d4	; initialize checksum accumulators
	clr.l     d5
	clr.l     d6
	clr.l     d7
grt150:
	btst.b	#2,PLYRIN1	; check if steve has itchy fingers
	beq.s	grt180	; abandon ship
	jsr	get_checksum	; get ckecksum on chunk of grom
	adda.l    #$10000,a0	; bump address to next chunk
	subq.w    #1,cksum_count	; decrement grom loop count
	bne	grt150	; loop if not done with set
	bra	set_done	; done checking this set of groms

quick_checksum:
	move.l	d0,grom_range	; size of grom set
	move.l	a0,grom_base	; base address of grom set to test
;	move.l	#$10000,a1	; grom offset address
	move.l	#$8000,a1	; grom offset address
	clr.l     d4	; initialize checksum accumulators
	clr.l     d5
	clr.l     d6
	clr.l     d7
qchk_next:
	move.l	grom_base,a0
	add.l	a1,a0
;	sub.l	#$8000,a0	; stradle an address boundary
	sub.l	#$4000,a0	; stradle an address boundary
	jsr	get_checksum	; get checksum on chunk of grom
	move.l	a1,d0	; last offset address
	lsl.l	#1,d0	; move address line up
	move.l	d0,a1
	cmp.l	grom_range,d0	; check if done
	blt.s	qchk_next
		
set_done:
	lea	gromsums,a0	; store checksums
	move.w    grom_set,d0
	lsl.w     #4,d0             ; mult by 16
	lea.l     (a0,d0.w),a0      ; a0 = dest for checksum data

	move.l    d4,(0,a0)	; save checksums
	move.l    d5,(4,a0)
	move.l    d6,(8,a0)
	move.l    d7,(12,a0)

grt160:
	addq.w    #1,grom_set	; bump index to next set of groms
	bra       grt100

grt180:
	move.w	grom_set,d0
	lsl.w	#2,d0	; get number of groms
	move.w	d0,max_set
	move      (sp)+,SR	; done getting checksums, turn on world
;
; print out checksums
; special for development RAMIT board
;
	clr.w	grom_count	;count of groms printed
	lea	grom_map,a0	;map that controls order groms are printed
	move.l	a0,map_pointer	;save this
	clr.b	grom_bad_flag

	tst.b	board_test_flag	;check what printing should be done
	beq	grt190
;;	move.w	#PAGEA,PageLine
;;	move.w	#PAGEA+512,A_PLN0YTP	; Set Plane A Tap Point
;;	move.w	prx_save,prx_coor	; restore saved spot
;;	move.w	pry_save,pry_coor
	rts
grt190:
	jsr	TogglePage
	jsr	print_version
	PLOT	#20,#30


	jsr	SetSysFont	;different font for this screen
	move.w	#10,prx_init	;x pos

	jsr	cks_print

	jsr	SetFontm	;restore default font


grt280:
	CARRET		; add a little space
	CARRET
	tst.b     grom_bad_flag	; check if any groms failed
	bne.s	grt290	; br if failed
	APALETTE	#LTBLUE
	PRINTS    grom_title
	PRINT     " PASSED"
	add.w	#1,loop_pass
	bra	grt295
	jsr	TogglePage
	DELAY	#120
	bra	memory_tst
grt290:
	APALETTE	#RED
	PRINTS    grom_title
	PRINT     " FAILED"
	add.w	#1,loop_fail
grt295:
;
; grom test was called from diagnostic menu
; so will wait for operator ready before leaving
;
grt300:
	move.w	#1,loop_delay	;just alittle time between tests
	jsr	operator_exit	;check with operator for exit
	bcs	memory_tst_loop	;operator wants to loop
	rts

;****************************************************************************
; Print results of checksum test
;****************************************************************************
	.export	cks_print
cks_print:
	clr.w	grom_count	;count of groms printed
	lea	grom_map,a0	;map that controls order groms are printed
	move.l	a0,map_pointer	;save this
	clr.b	grom_bad_flag

	CARRET
	CARRET
	APALETTE  #GREEN
;	lea	grom_title,a0
;	clr.w	d6	
;	move.w	#$7FFF,d7
;	jsr	Print	; print title of test
	PRINTS	grom_title
	CARRET
	CARRET
grt200:
	APALETTE  #GREEN
	PRINT    "GROM   CHECKSUM  STAT  GROM   CHECKSUM  STAT"
	CARRET
	CARRET
	clr.w     grom_count	; start at first byte in grom set
grt210:
	and.b	#$7f,grom_bad_flag ; assume this grom will be good
	APALETTE  #LTBLUE
			; calculate offset into checksum table

	move.l	map_pointer,a0	;get pointer to mapping table
	clr.w	d0
	move.b	(a0)+,d0	;GROM number
	move.w	d0,grom_label
	move.b	(a0)+,d0	;offset into checksum table
	lsl.w	#2,d0	;convert to byte address offset
	move.l	a0,map_pointer	;save it away

	lea	gromsums,a0	; calculated checksum table
	lea	check_sum_full,a1	; good checksum table for long test
	tst.b	quick_flag	; check if long test
	beq	grt220	; br if long test
	lea	fastsums,a1	; else use fast checksum table
grt220:
	lea.l     (a0,d0.w),a0
	lea.l     (a1,d0.w),a1
	move.l    a0,gptr	; save pointer to calculated checksum
	move.l    a1,rptr	; save pointer to good checksum
	move.l    (a1),d1	; good checksum
	cmp.l     (a0),d1	; check against what was calculated
	beq	grt225	; br if good checksumm
	move.b	#$81,grom_bad_flag ; mark current grom bad and set test fail
	APALETTE	#RED	; highlight grom as bad

grt225:
	lea	print_string,a0	; place to build grom name
	move.l	#'GRM0',(a0)	; base name
	move.l	#'-0 \0',4(a0)	; base name
	move.w	grom_label,d0
	move.w	d0,d1
	lsr.w	#4,d0
	add.w	#0x30,d0
	move.b	d0,3(a0)	; grom set number 
	and.w	#0xf,d1
	add.w	#0x30,d1
	move.b	d1,5(a0)	; grom byte number
	PRINTS	a0	; print grom name

grt227:
	PRINTHEX  gptr,#4	; print out calculated checksum
	PRINT	"  "
	btst.b	#7,grom_bad_flag	; check if this grom is bad
	beq.s     grt230	; br if grom is good

	PRINT	"BAD   "
	bra	grt240
grt230:
	PRINT	"GOOD  "
grt240:
	move.w	grom_count,d0
	btst	#0,d0	;check which column was printed
	beq.s	grt250
	CARRET		;start a new line
grt250:
	DELAY	#2
	addq.w	#1,grom_count	; bump total grom count
	cmpi.w	#GROM_SETS*2,grom_count ;check if half done
	bne.s	grt260
	CARRET		;extra space
grt260:
	cmpi.w    #GROM_SETS*4,grom_count
	blt       grt210	; br if not done with all groms

	CARRET
	andi.b	#$7f,grom_bad_flag ; leave only composite status
	rts

	ds 0
grom_map:
	dc.b	$00,0,$10,4
	dc.b	$01,1,$11,5
	dc.b	$02,2,$12,6
	dc.b	$03,3,$13,7

	dc.b	$20,8,$30,12
	dc.b	$21,9,$31,13
	dc.b	$22,10,$32,14
	dc.b	$23,11,$33,15


;	dc.b	$01,1,$00,0
;	dc.b	$11,5,$10,4
;	dc.b	$31,9,$30,8
;
;	dc.b	$03,3,$02,2
;	dc.b	$13,7,$12,6
;	dc.b	$33,11,$32,10	
	ds 0

;**********************************************************
; this subroutine blits a chunk of grom into video ram
; then reads and sums the data from the video ram via the ASIC
; checksums are accumulated in data registers D4, D5, D6, and D7
; the checksum registers are not zeroed and a0 is preserved allowing
; this routine to calculate a checksum over any desired address range.
; so make sure those regs are not corrupted when looping 
; through this code!
;
; ENTER WITH: a0 - starting address of GROM to blit
;
; EXITS WITH: d4 - checksum byte0
;             d5 - checksum byte1
;             d6 - checksum byte2
;             d7 - checksum byte3
;             a0 - preserved
;             a1 - preserved
;
	.import	PageLine
;	.import	wait_asic_idle

get_checksum:
;
; first setup the ASIC to blit GROM to video ram
;
	move.b	d0,WATCHDOG	; will be spending some time here
	move.w	#42,PALSELA+2

	move.w    S_Mode1,d0
	move.w    d0,A_MODE1

	move.l	a0,d0	; base address of grom chunk to blit
	move.w	N_PalSel,d1	; Load Enabled Planes
	andi.w	#$3f00,d1	; set bank to zero
	btst	#25,d0	; check if 0x2000000
	beq.s	lowa
	ori.w	#0x8000,d1
	bra.s	lowb
lowa:
	btst	#24,d0	; check if 0x1000000
	beq.s	lowb
	ori.w	#0x4000,d1	; set upper bank
lowb:
	move.w	d1,PLANE+2	; doit
	swap	d0
	move.w    d0,A_GROMSEG
;	move.w    #128,A_HEIGHT	; 512 actually equals 256
	move.w    grom_height,A_HEIGHT ; 512 actually equals 256
	move.w    #512,A_WIDTH
	swap	d0
	move.w    d0,A_GROMADR
	move.w    #0,A_STARTX
	move.w	grom_blit,A_STARTY ; place to blit
	move.w    #1,A_STATE
	move.w    #1,last_cmd

;wa1
;	move.w    A_STATUS,d0       ;Load ASIC Status
;	andi.w    #11000001b,d0
;	cmpi.b    #10000001b,d0
;	bne.s     wa1	;br if not done
;
; setup ASIC to read from video ram
; data regs D4-D7 are used to accumulate
; checksums for each GROM
;
	jsr	wait_asic_idle	;wait to finish
	move.b	d0,WATCHDOG	; will spend some time here

	move.w	#0,A_STARTX
	move.w	#$000,d0	; get page being displayed
;	move.w	PageLine,d0	; get page being displayed
;	eori.w	#$200,d0	; data is on page not being displayed
;	add.w	#128,d0	; put data on botton half of page
;	move.w    d0,A_STARTY	; give them something to look at
	move.w	grom_blit,A_STARTY ; place it was blit

	move.w    #$1ff,ASIC+204    ;wen1 change to read instead of write
	move.w    #$183,ASIC+220    ;trg1 change to read instead of write
           move.w    #$1c0,ASIC+188    ;cas1 change to read instead of write

	move.w    #$3,A_STATE
	move.w    #$3,last_cmd

	move.w    d1,A_USERREG      ;pixel value to user

;	move.w    #16383,d2	;total number of longwords-1 to read
	move.w	#512,d2
	mulu.w	grom_height,d2
	lsr.l	#2,d2
	sub.w	#1,d2	;total number of longwords-1 to read
	clr.l     d3	;holding register for data read in

read_a_byte0:
	btst.b    #3,A_STATUS+1	;check data register full bit
	bne       read_a_byte0	;br if not data not ready
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
	move.b    A_USERREG+1,d3	;get vram data from ASIC
	move.w    d1,A_USERREG      ;start next ASIC vram data read
	add.l     d3,d4	;accumulate checksum for this GROM
read_a_byte1:		;do it all again for next GROM byte
	btst.b    #3,A_STATUS+1
	bne       read_a_byte1
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
	move.b    A_USERREG+1,d3
	move.w    d1,A_USERREG
	add.l     d3,d5
read_a_byte2:		;do it all again for next GROM byte
	btst.b    #3,A_STATUS+1
	bne       read_a_byte2
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
	move.b    A_USERREG+1,d3
	move.w    d1,A_USERREG
	add.l     d3,d6
read_a_byte3:		;do it all again for next GROM byte
	btst.b    #3,A_STATUS+1
	bne       read_a_byte3
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
;	move.b	d0,WATCHDOG
	move.b    A_USERREG+1,d3
	move.w    d1,A_USERREG
	add.l     d3,d7

	dbf       d2,read_a_byte0	;check if done reading chunk of data

	move.w    #$1bf,ASIC+204    ;wen1 change back to writing
	move.w    #$1ff,ASIC+220    ;trg1 change back to writing
        move.w    #$1bf,ASIC+188    ;cas1 change to read instead of write

	move.w	N_PalSel,PLANE+2	; restore old bank
	rts

;****************************************************************
check_sum_fast:


fastsums:
	dc.l	$8f26ed,$8f010a,$8ee5f0,$8efbce
	dc.l	$69c841,$6945c2,$697c65,$6984a5
	dc.l	$689273,$689d0a,$694216,$686945
	dc.l	$0ed079,$0ecf77,$0ed278,$0ecad1

		.comment
	dc.l	$3ac282,$3a5ac0,$3a8463,$3ae186
	dc.l	$3bb20a,$3bce78,$3bd83f,$3bb702
	dc.l	$4ac396,$4afa4a,$4aa60e,$4b08ef
		.endcomment

		.comment
	dc.l      $003ac282,$003a5ac0,$003a8463,$003ae186
	dc.l      $3713b7,$36af1e,$36f48b,$36a97e
	dc.l      $343bbc,$33b002,$33f626,$344da3
	dc.l      $46d2ff,$4739f7,$471a09,$471fe1
	dc.l      $362115,$35f3dc,$35baf2,$356fa2
	dc.l      $3bac02,$3be2c4,$3b9e56,$3c1c96
	dc.l      $3bc70f,$3b59f8,$3b7eac,$3b79c9
	dc.l      $2f1752,$2f7998,$2fa3da,$2f49b6
	dc.l      $3bb20a,$3bce78,$3bd83f,$3bb702
	dc.l      $453122,$455a8e,$45366e,$456be0
	dc.l      $636d7c,$63012a,$6376c0,$6313b0
	dc.l      $552cbd,$5556e5,$55571a,$5568bf
	dc.l      $52be06,$52d5e6,$52b0a1,$528b2b
	dc.l      $46c943,$46a1b5,$46af8f,$46c48e
	dc.l      $3d7318,$3d812b,$3ce893,$3d4c88
	dc.l      $45ffec,$45e864,$46322c,$460043
		.endcomment

	ds 0

;***************************************************************************
;	V R A M   T E S T		*
;***************************************************************************
	.export	vram_tst
vram_tst:
	PLANES    #PLANEA
	jsr	TogglePage
vram_tst_loop:
	PLOT	#20,#20
	APALETTE  #WHITE
	CARRET
	CARRET
	PRINT	"RUNNING VIDEO RAM TEST, FIRST PAGE"
	jsr	TogglePage

	jsr	vram_check	; check current draw page
	move.w	d0,vram_status0

	jsr	TogglePage
	jsr	TogglePage	; clear both pages
	DELAY	#2
	PLOT	#20,#20
	APALETTE  #WHITE
	CARRET
	CARRET
	PRINT	"RUNNING VIDEO RAM TEST, SECOND PAGE"
	jsr	TogglePage	; will have other page as draw page

	jsr	vram_check	; check current draw page
	move.w	d0,vram_status1

	tst.b	board_test_flag	; check if doing powerup tests
	beq	vrt90	; br if not
	rts		; do not display results now
vrt90:
	jsr	TogglePage
	DELAY	#2
	jsr	TogglePage	; clear both pages
	jsr	print_version	; print game title

	PLOT	#20,#30
	jsr	vrt_print
	tst.w	d0	; check results
	bne.s	vrt95	; br if failed
	add.w	#1,loop_pass	; good loop
	bra.s	vrt400
vrt95:
	add.w	#1,loop_fail	; bad loop
;
; vram test was called from diagnostic menu
; so will wait for operator ready before leaving
;
vrt400:
	move.w	#120,loop_delay	;let them see results time between tests
	jsr	operator_exit	;check with operator for exit
	bcs	vram_tst_loop	;operator wants to loop
	rts
;***************************************************************************

;***************************************************************************
	.export	vrt_print
vrt_print:
	CARRET
	APALETTE	#GREEN
	lea	vram_title,a0
	clr.w	d6	
	move.w	#$7FFF,d7
	jsr	Print	; print title of test
	CARRET
	tst.b	board_test_flag
	bne	vrt200	; if board test skip status words

	APALETTE	#LTBLUE
	tst.w	vram_status0
	beq	vrt100	; br if good
	APALETTE	#BADSTUFF
vrt100:
	PRINT	"VIDEO RAM FIRST PAGE STATUS  = "

	PRINTHEX  #vram_status0,#2	; print out status
	CARRET
	APALETTE	#LTBLUE
	tst.w	vram_status1
	beq	vrt110	; br if good
	APALETTE	#BADSTUFF
vrt110:
	PRINT	"VIDEO RAM SECOND PAGE STATUS = "

	PRINTHEX  #vram_status1,#2	; print out status
	CARRET

vrt200:
	lea	u32_string,a0
	move.w	vram_status0,d0
	or.w	vram_status1,d0
	PUSHW	d0
	and.w	#$ff00,d0	; check even byte
	bsr	good_bad_print
	lea	u35_string,a0
	POPW	d0
	and.w	#$00ff,d0	; check odd byte
	bsr	good_bad_print
	CARRET

	move.w	vram_status0,d0
	or.w	vram_status1,d0
	bne	vrt300
	APALETTE	#LTBLUE
	PRINT	"VIDEO RAM TEST PASSED"
	clr.w	d0	;return test passed status
	rts
vrt300:
	APALETTE #BADSTUFF
	PRINT	"VIDEO RAM TEST FAILED"
	move.w	#1,d0	;return test failed status
	rts

u32_string:
	dc.b	'U32\0'
u35_string:
	dc.b	'U35\0'
	ds 0

;***************************************************************************
; this subroutine tests the current draw page of video ram	*
;***************************************************************************
	.import	PageLine

vram_check:
;
; first setup to write to vram
;
vc10:
	tst.b	AQStat	; check if command queue idle
	beq	vc20	; br if nothing happening
	DELAY	#1
	bra.s	vc10
vc20:
	move.w	A_STATUS,d0
	btst	#IDLE_B,d0	; check for idle asic
	beq	vc10	; br if not

	move.w	SR,-(sp)	; Push Status Onto Stack
	ori.w	#DIRQ,SR	; Disable IRQs
	move.w	A_STATUS,d0	; Load ASIC Status

	move.w	#$100,d0	; L/A ON
	or.w	 S_Mode1,d0	; and normal bits
	move.w	d0,A_MODE1	; into asic mode1 reg

	move.w	#512,A_HEIGHT	; 512 actually is 256
	move.w	#512,A_WIDTH
	move.w	#0,A_STARTX
	move.w	PageLine,d0	; get page being displayed
	eori.w	#$200,d0	; put data on page not being displayed
	move.w	d0,A_STARTY
;
	move.w	#$3,A_STATE
	move.w	#$3,last_cmd

	move.b	#1,d2	; starting pattern for even vram
	move.b	#80,d3	; starting pattern for odd vram
	move.w	#$ffff,d4	; dbf $10000
	clr.b	d5	; need zero for addx

vc_byte0:
	btst.b	#3,A_STATUS+1	; check data register full bit
	bne	vc_byte0	; br if not data not ready
	move.w	d2,A_USERREG	; pattern for even vram chip
	add.b	#1,d2	; increment data pattern
	addx.b	d5,d2	; this will skew the pattern

vc_byte1:
	btst.b	#3,A_STATUS+1	; check data register full bit
	bne	vc_byte1	; br if not data not ready
	move.w	d3,A_USERREG	; pattern for even vram chip
	add.b	#1,d3	; increment data pattern
	addx.b	d5,d3	; this will skew the pattern

	dbf	d4,vc_byte0	; check done writing data

;vwa1
;	move.w	A_STATUS,d0	; Load ASIC Status
;	andi.w	#11000001b,d0
;	cmpi.b    #10000001b,d0
;	bne.s	vwa1	; br if not done
;;
;; setup ASIC to read from video ram
;; as the data is read, it is checked
;
	jsr	wait_asic_idle	;wait to finish
	move.b	d0,WATCHDOG	; will spend some time here

	move.w	#0,A_STARTX
	move.w	PageLine,d0	; get page being displayed
	eori.w	#$200,d0	; data is on page not being displayed
	move.w	d0,A_STARTY

	move.w	#$1ff,ASIC+204	; wen1 change to read instead of write
	move.w	#$183,ASIC+220	; trg1 change to read instead of write
	move.w	#$1c0,ASIC+188	; cas1 change to read instead of write

	move.w	#$3,A_STATE
	move.w	#$3,last_cmd

	move.w	d0,A_USERREG	; start things going for first byte

	move.b	#1,d2	; starting pattern for even vram
;	move.b	#2,d2	; testing only
	move.b	#80,d3	; starting pattern for odd vram
;	move.b	#81,d3	; testing only
	move.w	#$ffff,d4	; write counter for dbf
	clr.b	d5	; need zero for addx
	clr.w	d6	; flag for bad vrams

vcr_byte0:
	btst.b	#3,A_STATUS+1	; check data register full bit
	bne	vcr_byte0	; br if not data not ready
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
	move.b	A_USERREG+1,d0	; get vram data from ASIC
	move.w	d1,A_USERREG	; start next ASIC vram data read
	cmp.b	d0,d2	; check if correct data
	bne	vcr_bad0	; br if not
vcr_byte01:
	add.b	#1,d2	; increment test pattern
	addx.b	d5,d2	; skew pattern
vcr_byte1:			; do it again for odd vram byte
	btst.b	#3,A_STATUS+1
	bne	vcr_byte1
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
	move.b	d0,WATCHDOG
	move.b	A_USERREG+1,d1
	move.w	d0,A_USERREG	; start next ASIC vram data read
	cmp.b	d1,d3	; check if correct data
	bne	vcr_bad1	; br if not
vcr_byte11:
	add.b	#1,d3	; increment test pattern
	addx.b	d5,d3	; skew pattern

	dbf	d4,vcr_byte0	; check if done reading vram

	move.w	#$1bf,ASIC+204	; wen1 change back to writing
	move.w	#$1ff,ASIC+220	; trg1 change back to writing
	move.w	#$1bf,ASIC+188	; cas1 change to read instead of write

	move.w	d6,d0	; return vram status in d0
	move      (sp)+,SR	; done testing, turn on world
	rts

vcr_bad0:
	or.w	#$100,d6	; mark even vram as bad
	bra.s	vcr_byte01
vcr_bad1:
	or.b	#1,d6	; mark odd vram as bad
	bra.s	vcr_byte11

;********************************************************************
;
;	P A L E T T E   R A M   T E S T
;
;********************************************************************

	.export	palram_tst
	.import	InitCycle

palram_tst:
	jsr	InitCycle
	jsr       TogglePage
	PLOT      #20,#40
	APALETTE  #WHITE
;;	BPALETTE  #LTBLUE
	PRINT     "RUNNING PALETTE RAM TEST"
	jsr       TogglePage
	DELAY	#30
prt_tst_loop:
	jsr	palram_check	; check palette rams

;	jsr	SetSysFont	; Set For System Font
	jsr	LoadColors	; setup palettes for diagnostics
;;	jsr	set_black_pals	;restore palette info
;;	jsr	set_sfont_pal

	tst.b	board_test_flag	;check if doing powerup tests
	beq	prt90	;br if not
	jsr       TogglePage
	rts		;do not display results now
prt90:
	jsr	print_version	; print game title
prt95:
	PLOT	#20,#30
	jsr	prt_print
;
; palette ram test was called from diagnostic menu
; so will wait for operator ready before leaving
;
prt300:
	move.w	#180,loop_delay	;let them see results time between tests
	jsr	operator_exit	;check with operator for exit
	bcs	prt_tst_loop	;operator wants to loop
	rts
;***********************************************************************

;***********************************************************************
	.export	prt_print
prt_print:
	CARRET
	CARRET
	APALETTE	#GREEN
	BPALETTE	#127
	lea	palram_title,a0
	clr.w	d6	
	move.w	#$7FFF,d7
	jsr	Print	; print title of test
	CARRET
	tst.b	board_test_flag	;check if doing powerup tests
	bne	prt150	; skip status word on powerup
	APALETTE  #LTBLUE	; assume good
	BPALETTE  #127	; assume good
	tst.w	palram_status
	beq	prt100	; br if good
	APALETTE	#RED
	BPALETTE	#127
prt100:
	PRINT     "PALETTE RAM STATUS  = "

	PRINTHEX  #palram_status,#2	; print out status
	CARRET

prt150:
	lea	red_string,a0
	move.w	palram_status,d0
	and.w	#$0f00,d0	; check red palette ram
	bsr	good_bad_print
	lea	green_string,a0
	move.w	palram_status,d0
	and.w	#$00f0,d0	; check green palette ram
	bsr	good_bad_print
	lea	blue_string,a0
	move.w	palram_status,d0
	and.w	#$000f,d0	; check blue palette ram
	bsr	good_bad_print
	CARRET

	tst.w	palram_status
	bne	prt200
	APALETTE	#LTBLUE
	BPALETTE	#127
	PRINT	"PALETTE RAM TEST PASSED"
	add.w	#1,loop_pass	; good loop
	bra	prt250
prt200:
	APALETTE #RED
	BPALETTE #127
	PRINT	"PALETTE RAM TEST FAILED"
	add.w	#1,loop_fail	; bad loop
prt250:
	rts

red_string:
	dc.b	'RED\0'
blue_string:
	dc.b	'BLUE\0'
green_string:
	dc.b	'GREEN\0'
	ds 0
;
; routine to print out a character string followed by GOOD or BAD
; if GOOD the phrase is printed in blue color else red
;
; enter with:
;             a0.l - pointer to null terminated text string.
;             d0.w - status word 0 - good !0 - bad
;
good_bad_print:
	tst.w	d0
	bne	bad_string
	APALETTE	#LTBLUE
	PRINTS	a0
	PRINT	" GOOD   "
	rts
bad_string:
	APALETTE	#RED
	PRINTS	a0
	PRINT	" BAD   "
	rts

board_test_carret:
	tst.b	board_test_flag
	bne.s	no_board_carret
	CARRET
no_board_carret:
	rts

;
; palette ram tests
; first test will write and read a series of patterns 
; at each palette address. palette rams are organized
; on long word boundaries with red at byte offset 3
; green at offset 2 and blue at offset 1. The byte at
; offset 0 is unused. the palettes must be written/read
; as long words only.
;
; the address test will put a portion of the longword
; address in the green and red rams and an incrementing
; pattern in the blue ram.
;

PALMASK	equ	0x00ffffff	;palette bytes in long word

	ds 0
ptest_patterns:
	dc.l	4	;number of data patterns
	dc.l	0x00ffffff
	dc.l	0xff555555
	dc.l	0xffaaaaaa
	dc.l	0xff000000	;LAST PATTERN MUST BE ZERO
			;SEE ADDRESS TEST
palram_check:
pal_test:
	lea	PALETTES,a0	;starting address of palette rams
	lea	PALETTES+0x20000,a1 ;end+1 address
pt100:
	lea	ptest_patterns,a2	;list of memory test patterns
	move.l	(a2)+,d2	;number of test patterns
	move.l	#PALMASK,d4	;byte mask for data comparisons
	clr.w	d5	;keep track of which rams are bad
pt110:
	move.l	(a2)+,d3	;get test pattern
pt120:
	move.l	d3,d1
	move.l	d1,(a0)	;longword write
	move.l	(a0),d0
;	neg.w	d0	;test code only
	and.l	d4,d0	;only check valid bytes
	and.l	d4,d1	;ditto
	cmp.l	d0,d1
	beq	pt150	;br if good
	bsr	bad_palette	;figure out which rams are bad
pt150:
	sub.l	#1,d2
	bne	pt110	;br if patterns left
	move.b	d0,WATCHDOG
	add.l	#4,a0	;next memory location to test
	cmp.l	a0,a1	;check if done yet
	bne	pt100	;br if not
;	bra	ptdone	;TRK testing only
;
;address test
;before writing will check to make sure memory is zero
;from previous pattern tests. Nonzero value may indicate
;address imaging problem or residue from pattern test.
;
pt200:
	lea	PALETTES,a0	;starting address of palette rams
	lea	PALETTES+0x20000,a1 ;end+1 address
;	lea	PALETTES+0x8000,a1 ;end+1 address
;	lea	0xe000,a0	;starting address of palette rams
;	lea	0xf000,a1	;end+1 address
	move.l	#0xff030201,d3	;starting pattern to store
	move.l	#0x00000000,d2	;constant for addx
	move.l	#PALMASK,d4	;byte mask for data comparisons
pt210:
	move.b	d0,WATCHDOG	
	move.l	(a0),d0
	and.l	d4,d0	;only check valid bytes
	beq	pt240	;br if good
	clr.l	d1	;looking for zero
	bsr	bad_palette	;figure out which rams are bad
pt240:
	move.l	d3,(a0)+	;store address pattern
	addq.b	#1,d3	;increment red pattern
	addx.b	d2,d3	;this will skew pattern
	ror.l	#8,d3	;get to green
	addq.b	#1,d3	;increment green pattern
	addx.b	d2,d3	;this will skew the pattern
	ror.l	#8,d3	;get to blue
	addq.b	#1,d3	;increment blue pattern
	addx.b	d2,d3	;this will skew the pattern
	ror.l	#8,d3	;get to unused byte
	ror.l	#8,d3	;get back to where we started
	cmp.l	a0,a1	;done yet?
	bne	pt210

	lea	PALETTES,a0	;starting address of palette rams
;	lea	0xe000,a0	;starting address of palette rams
	move.l	#0x00030201,d1	;starting pattern to check for
pt250:
	move.b	d0,WATCHDOG
	move.l	(a0),d0
	and.l	d4,d0
	cmp.l	d0,d1	;check for correct pattern
	beq	pt270	;br if good
	bsr	bad_palette	;figure out which rams are bad
pt270:
	clr.l	(a0)+	;clear it out
	addq.b	#1,d1	;increment red pattern
	addx.b	d2,d1	;this will skew pattern
	ror.l	#8,d1	;get to green
	addq.b	#1,d1	;increment green pattern
	addx.b	d2,d1	;this will skew the pattern
	ror.l	#8,d1	;get to blue
	addq.b	#1,d1	;increment blue pattern
	addx.b	d2,d1	;this will skew the pattern
	ror.l	#8,d1	;get to unused byte
	ror.l	#8,d1	;get back to where we started
	cmp.l	a0,a1	;done yet?
	bne	pt250	;br if not
ptdone:
	move.w	d5,palram_status	;save test results
	rts
;
; routine to determine which palette rams have bad pattern
; bad palette information is in d5
; d0 has pattern read, d1 has pattern wanted
; d0 is destroyed
;
bad_palette:
	eor.l	d1,d0	;find bad bits
	tst.b	d0	;red bad?
	beq	bp100
	or.w	#0x000f,d5	;mark red bad
bp100:
	lsr.l	#8,d0
	tst.b	d0	;green bad?
	beq	bp200
	or.w	#0x00f0,d5	;mark green bad
bp200:
	lsr.l	#8,d0
	tst.b	d0	;blue bad?
	beq	bp300
	or.w	#0x0f00,d5	;mark blue bad	
bp300:
	rts
;***************************************************************************
;	joystick and button test		*
;	layout of game panel is displayed on screen	*
;	buttons and joystick positions are highlighted when closed	*
;***************************************************************************

	.export	pcontrol_tst
pcontrol_tst:
;	LOADPAL	#FontSkullClr,#0,#P_SYSFONT,#256
	LOADPAL	#SwdiagOffClrs,#0,#SWDIAG_PAL,#42

	clr.b	user_rdy_flg
	clr.b	clear_on
	clr.b	menu_mess
	jsr	InitCycle	; Turn Off Color Cycling
	jsr	TogglePage	; Clear Screen

;obe	jsr	SetSysFont	; Set For System Font
;obe	APALETTE	#P_SYSFONT	; Use Font Palette
;obe	PLOT	#10,#53	; Set Screen Position
;obe	PRINT	"TO EXIT PRESS START 1 AND START 2"

;obe	jsr	print_version
;;	jsr	SetFont2	; Set For Large Font
;;	PLOT	#60,#2	; Set Screen Position
;;	PRINT	"STREET FIGHTER"	; Output Message

;obe	jsr	SetSysFont	; Set For System Font
;	IMAGES	#miscbank	; Set To Diagnostic Bank
;	APALETTE	#SWDIAG_PAL	; Set Palette
;	BLIT	#swdiag1,#0,#70	; Blit Control Panel Picture
;; print SERVICE over START
;obe	jsr	SetWinFont	; Set For System Font
;obe	APALETTE	#P_SYSFONT
;obe	PLOT	#3,#210			; Set Screen Position
;obe	TRANS	OFF
;obe	PRINT	"SERV."
;obe	TRANS	ON

;;
;;
;;	move.w	#SWDIAG_PAL,d1	; Set Palette
;;	lea	test_screen,a1
;;  	jsr	host_write
;;
;obe	jsr	SetSysFont	; Restore System Font
	DELAY	#1
	jsr	TogglePage
	DELAY	#10

	clr.l	sw_map	; bit map of sw closures
	clr.w	sw_map+4

;	move.b	TRACKPORT1,d0
;	and.b	#00001111b,d0
;	move.b	d0,tlx1
;	move.b	TRACKPORT1,d0
;	lsr.b	#4,d0
;	move.b	d0,tly1

	jsr	InitTrackball
	move.w	#100,PlayerL+TRACKX
	move.w	#100+192,PlayerR+TRACKX
	move.w	#130,PlayerL+TRACKY
	move.w	#130,PlayerR+TRACKY
	clr.b	NoTrackBalls	; Let Track Balls Roll
	clr.b	PlayerL+COMPUTER
	clr.b	PlayerR+COMPUTER

switch_test:
	DELAY	#1

;obe

	lea	titlebox1,a0
	jsr	write_vram
	lea	titlebox2,a0
	jsr	write_vram

	APALETTE  #GREEN
	PLOT	#110,#12
	PRINT	"PLAYER CONTROL TESTS"

	PLOT	#60,#29+5
	lea	chngbox1,a0
	jsr	write_vram
	lea	chngbox2,a0
	jsr	write_vram
	CARRET
	APALETTE  #INSTRUCTION
	PRINT	"TO EXIT PRESS START 1 AND START 2"

;	clr.w	d0
;	move.b	TRACKPORT1,d0
;	and.b	#00001111b,d0
;	move.b	d0,d1
;	move.b	#0,d2	;prepare for no_wrap
;	and.b	#00001100b,d0
;	beq.s	wrap
;	cmp.b	#00001100b,d0
;	bne.s	no_wrap
;wrap	move.b	tlx1,d3	;MUST EOR FROM A REGISTER!!!
;	eor.b	d3,d0
;	and.b	#00001100b,d0
;	cmp.b	#00001100b,d0	;wrap if both bits changed??
;	bne.s	no_wrap
;	move.b	#16,d2	;prepare for inc_wrap
;	btst.b	#3,d1
;	beq.s	inc_wrap
;	move.b	#-16,d2
;no_wrap
;inc_wrap
;	move.b	tbx1,d0
;	and.b	#11110000b,d0
;	or.b	d1,d0
;	add.b	d2,d0
;	move.b	d0,tbx1
;	move.b	d1,tlx1	;update last read
;
;
;	clr.w	d1
;	move.b	tly1,d1

	jsr	ReadTrackball

	move.w	PlayerL+TRACKY,d1
	sub.w	#130,d1
	neg.w	d1
	add.w	#130,d1
	move.w	PlayerL+TRACKX,d0
	jsr	TrackLimit
	PLOT	d0,d1
	PRINT	"TRACKBALL 1"

	move.w	PlayerR+TRACKY,d1
	sub.w	#130,d1
	neg.w	d1
	add.w	#130,d1
	move.w	PlayerR+TRACKX,d0
	jsr	TrackLimit
	PLOT	d0,d1
	PRINT	"TRACKBALL 2"



;	PLOT	#10,#83	; Set Screen Position
;	PRINTHEX	#PLYRIN1,#4
;	CARRET
;	PRINTHEX	#PLYRIN2,#4
;	CARRET
;	PRINTHEX	#PLYRIN3,#4
;	CARRET
;	PRINTHEX	#PLYRIN4,#4
;	CARRET
;	PRINTHEX	#DIPS,#4
;	CARRET
;	PRINTHEX	#SWITCHE,#4
;	CARRET
;	PRINTHEX	#TRACKPORT1,#4
;	CARRET
;	PRINTHEX	#TRACKPORT2,#4
;	CARRET

	move.w	#16,boxram_color
	move.w	#8,boxram_height
	move.w	#8*9,boxram_width
	clr.w	boxram_pixel

	clr.w	sw_cnt
boxlp
	move.w	sw_cnt,d1
	asl.w	#4,d1	;16 bytes per entry
	lea	sw_pal_map,a0
	lea	(a0,d1.w),a0
	move.b	(a0),d0
	beq	boxdone
	move.b	1(a0),boxram_pixel+1
	move.w	2(a0),boxram_x
	move.w	4(a0),boxram_y
	lea	6(a0),a0
	PUSHL	a0
	lea	boxram,a0
	jsr	write_vram
	move.w	#BLUE,PALSELA	;force palette
	POPL	a0
	move.w	boxram_x,d1
	move.w	boxram_y,d2

	jsr	PPrint

	add.w	#1,sw_cnt
	bra	boxlp
boxdone
	jsr	TogglePage


	clr.w	sw_cnt
switch_loop:
	move.w	sw_cnt,d1
	asl.w	#4,d1	;16 bytes per entry
	lea	sw_pal_map,a0
	lea	(a0,d1.w),a0
	move.b	(a0),d0
	beq	switch_done
	move.b	1(a0),sw_pal	; save palette entry for later
	jsr	SwitchState
	move.l	sw_map,d1	; assume first longword
	move.w	sw_cnt,d2	; get switch number
	cmpi.w	#32,d2	; check if in first longword
	blt.s	sw_first
	move.w	sw_map+4,d1	; in third word
sw_first:
	cmp.b	#SWITCH_CLOSED,d0
	bne.s	sw_open
	bset	d2,d1	; switch is closed
	bne.s	sw_done	; br if already closed
	move.l	#SwdiagOnClrs,a0	; use closed palette
	bra.s	sw_paint
sw_open:
	bclr	d2,d1	; switch is open
	beq.s	sw_done	; br if already open
	move.l	#SwdiagOffClrs,a0	; use open palette
sw_paint:
	cmpi.w	#32,d2	; check if in first longword
	blt	sw_paint1
	move.w	d1,sw_map+4	; save new map in third word
	bra.s	sw_paint2
sw_paint1:
	move.l	d1,sw_map	; save new map in first longword
sw_paint2:
	clr.w	d0
	move.b	sw_pal,d0	; palette entry
	move.w	d0,d1
	add.w	d0,d1
	add.w	d0,d1
	lea	(a0,d1.w),a0	; offset into source palette
	move.w	#1,d1	; load one entry
	move.w	#SWDIAG_PAL,d2
	jsr	LoadPalette
sw_done:
	add.w	#1,sw_cnt
	bra	switch_loop
switch_done:		;check button and joystick combo for exit
	move.b	#START1,d0
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne	switch_test
	move.b	#START2,d0
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne	switch_test

exit_new:
	jsr	TogglePage
	clr.b	clear_on
	rts

TrackLimit
	cmp.w	#10,d0
	bgt.s	.lxok
	move.w	#10,d0
.lxok	cmp.w	#380,d0
	blt.s	.rxok
	move.w	#380,d0
.rxok

	cmp.w	#80,d1
	bgt.s	.lyok
	move.w	#80,d1
.lyok	cmp.w	#240,d1
	blt.s	.ryok
	move.w	#240,d1
.ryok

	rts

;***************************************************************************
; Switch to palette mapping table		*
; each switch has it's own pallette entry		*
; Switch value of 0 used to mark end of table		*
; palette entries $80 and above are used for special cases	*
;***************************************************************************
sw_pal_map: 	ds	0
	dc.b	COIN1,34
	dc.w	20,70	;X,Y
	dc.b	"COIN1    ",0	;LABEL
	dc.b	START1,14
	dc.w	20,80
	dc.b	"START1   ",0
;	dc.b	JOY1_UP,6
;	dc.w	20,70
;	dc.b	"JOY1-UP  ",0
;	dc.b	JOY1_DW,10
;	dc.w	20,80
;	dc.b	"JOY1-DW  ",0
;	dc.b	JOY1_LF,12
;	dc.w	20,90
;	dc.b	"JOY1-LF  ",0
;	dc.b	JOY1_RT,8
;	dc.w	20,100
;	dc.b	"JOY1-RT  ",0
	dc.b	BUTTON1_1,15
	dc.w	20,110
	dc.b	"FIRST    ",0
	dc.b	BUTTON1_2,16
	dc.w	20,120
	dc.b	"SECOND   ",0
	dc.b	BUTTON1_3,17
	dc.w	20,130
	dc.b	"THIRD    ",0
	dc.b	BUTTON1_4,18
	dc.w	20,140
	dc.b	"HOME     ",0
	dc.b	BUTTON1_5,19
	dc.w	20,150
	dc.b	"POWER    ",0
;	dc.b	BUTTON1_6,38
;	dc.w	20,160
;	dc.b	"BUTTON1-6",0

	dc.b	COIN2,36
	dc.w	210,70
	dc.b	"COIN2    ",0
	dc.b	START2,28
	dc.w	210,80
	dc.b	"START2   ",0
;	dc.b	JOY2_UP,20
;	dc.w	210,70
;	dc.b	"JOY2-UP  ",0
;	dc.b	JOY2_DW,24
;	dc.w	210,80
;	dc.b	"JOY2-DW  ",0
;	dc.b	JOY2_LF,26
;	dc.w	210,90
;	dc.b	"JOY2-LF  ",0
;	dc.b	JOY2_RT,22
;	dc.w	210,100
;	dc.b	"JOY2-RT  ",0
	dc.b	BUTTON2_1,29
	dc.w	210,110
	dc.b	"FIRST    ",0
	dc.b	BUTTON2_2,30
	dc.w	210,120
	dc.b	"SECOND   ",0
	dc.b	BUTTON2_3,31
	dc.w	210,130
	dc.b	"THIRD    ",0
	dc.b	BUTTON2_4,32
	dc.w	210,140
	dc.b	"HOME     ",0
	dc.b	BUTTON2_5,33
	dc.w	210,150
	dc.b	"POWER    ",0
;	dc.b	BUTTON2_6,39
;	dc.w	210,160
;	dc.b	"BUTTON2-6",0

	dc.b	SERVICE,40	; special case for serivce switch
	dc.w	210,200
	dc.b	"SERVICE  ",0
	dc.b	TESTSW,41	; another special for test switch
	dc.w	210,210
	dc.b	"TESTSW   ",0
	dc.b	0	; end of table

	.align	2

SwdiagOffClrs:
	dc.b	[42*3]$33
; dc.b $00,$00,$00,$87,$57,$00,$3F,$00,$00,$00,$00,$00  ; 00-03
; dc.b $00,$00,$FF,$FF,$00,$00,$AF,$6B,$00,$A3,$5F,$00  ; 04-07
; dc.b $AF,$6B,$00,$A3,$5F,$00,$AF,$6B,$00,$A3,$5F,$00  ; 08-11
; dc.b $AF,$6B,$00,$A3,$5F,$00,$00,$00,$B3,$00,$00,$B3  ; 12-15
; dc.b $00,$00,$B3,$00,$00,$B3,$00,$00,$B3,$00,$00,$B3  ; 16-19
; dc.b $AF,$6B,$00,$A3,$5F,$00,$AF,$6B,$00,$A3,$5F,$00  ; 20-23
; dc.b $AF,$6B,$00,$A3,$5F,$00,$AF,$6B,$00,$A3,$5F,$00  ; 24-27
; dc.b $B3,$00,$00,$B3,$00,$00,$B3,$00,$00,$B3,$00,$00  ; 28-31
; dc.b $B3,$00,$00,$B3,$00,$00,$4B,$4B,$CB,$00,$00,$4B  ; 32-35
; dc.b $B3,$0,$0,$4B,$0,$0,$0,$0,$B3,$B3,$0,$0          ; 36-39	
; dc.b $67,$67,$67,$67,$67,$67	                ; 40-41

SwdiagOnClrs:
	dc.b	[42*3]150
; dc.b $00,$00,$00,$87,$57,$00,$3F,$00,$00,$00,$00,$00  ; 00-03
; dc.b $00,$00,$FF,$FF,$00,$00,$00,$FF,$FF,$00,$FF,$FF  ; 04-07
; dc.b $00,$FF,$FF,$00,$FF,$FF,$00,$FF,$FF,$00,$FF,$FF  ; 08-11
; dc.b $00,$FF,$FF,$00,$FF,$FF,$00,$FF,$FF,$00,$FF,$FF  ; 12-15
; dc.b $00,$FF,$FF,$00,$FF,$FF,$00,$FF,$FF,$00,$FF,$FF  ; 16-19
; dc.b $FF,$00,$80,$FF,$00,$80,$FF,$00,$80,$FF,$00,$80  ; 20-23
; dc.b $FF,$00,$80,$FF,$00,$80,$FF,$00,$80,$FF,$00,$80  ; 24-27
; dc.b $FF,$00,$80,$FF,$00,$80,$FF,$00,$80,$FF,$00,$80  ; 28-31
; dc.b $FF,$00,$80,$FF,$00,$80,$00,$FF,$FF,$00,$FF,$FF  ; 32-35
; dc.b $FF,$00,$80,$FF,$00,$80,$00,$FF,$FF,$FF,$00,$80  ; 36-39
; dc.b $FF,$00,$80,$FF,$00,$80	                ; 40-41

S_test_1Clrs:
 dc.b $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
 dc.b $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
 dc.b $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
 dc.b $0,$0,$0,$FF,$FF,$FF,$0,$0,$0,$FF,$FF,$FF
 dc.b $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
 dc.b $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
 dc.b $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
 dc.b $0,$0,$0,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

	.align	2
;***************************************************************************
;***************************************************************************
	.import	LoadAllPals

Art_test:
	jsr	LoadAllPals
	clr.b	user_rdy_flg
	clr.b	clear_on
	clr.w	Framenum
	clr.w	FramePal
	clr.w	FrameBank
	clr.b	menu_mess
	jsr	TogglePage	; Clear Screen
	jsr	SetSysFont
art_tst:
	APALETTE	#P_SYSFONT	; Use Font Palette
	PPRINT	#20,#30,"FRAME NUMBER :	 "
	PLOT	#150,#30	; Set Screen Position
	PRINTDEC   Framenum,#4,NOPAD
	PPRINT	#20,#50,"FRAME PALETTE :  "
	PLOT	#150,#50	; Set Screen Position
	PRINTDECB   palette,#4,NOPAD
	PPRINT	#20,#70,"FRAME BANK : "
	PLOT	#150,#70	; Set Screen Position
	PRINTDECB   bank,#4,NOPAD

	jsr	SetPalette
	jsr	SetImages

	BLIT	Framenum,#100,#80	; Blit Control Panel Picture

	jsr	TogglePage
	jsr	ArtAdjust
	DELAY	#10

	move.b	#START1,d0
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne	art_tst

exit_atest:
	SOUND	#0,#0
	jsr	SetSysFont	; Set For System Font
	jsr	TogglePage
	clr.b	clear_on
	rts

ArtAdjust:
	move.b	#JOY1_DW,d0	;check if want to move memory up alot
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne.s	art_down
art_up1:
	sub.w	#1,Framenum
	cmp.w	#-1,Framenum
	bgt.s	art_down
	move.w	#0,Framenum
art_down:
	move.b	#JOY1_UP,d0	;check if want to move memory up alot
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne.s	art_left
art_dw:
	add.w	#1,Framenum
	cmp.w	#255,Framenum
	blt.s	art_left
	move.w	#255,Framenum
art_left:
	move.b	#JOY1_LF,d0	;check if want to move memory up alot
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne.s	art_rght

	add.w	#1,FrameBank
	cmp.w	#28,FrameBank
	blt.s	art_rght
	move.w	#27,FrameBank
art_rght:
	move.b	#JOY1_RT,d0	;check if want to move memory up alot
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne.s	art_pal1
	sub.w	#1,FrameBank
	cmp.w	#0,FrameBank
	bgt.s	art_pal1
	move.w	#1,FrameBank
art_pal1:
	move.b	#BUTTON1_1,d0	;check if want to move memory up alot
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne.s	art_pal2

	add.w	#1,FramePal
	cmp.w	#28,FramePal
	blt.s	art_pal2
	move.w	#27,FramePal
art_pal2:
	move.b	#BUTTON2_1,d0	;check if want to move memory up alot
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne.s	art_exit
	sub.w	#1,FramePal
	cmp.w	#0,FramePal
	bgt.s	art_exit
	move.w	#0,FramePal
art_exit:
	rts

SetPalette
	move.w	FrameBank,d0
	move.l	#charimagebanks,a1
	move.b	(a1,d0.w),bank
	IMAGES 	bank
	rts

SetImages:
	move.w	FramePal,d0
	move.l	#charimagepalettes,a1
	move.b	(a1,d0.w),palette
	APALETTE palette
	rts

charimagepalettes:

charimagebanks:

	.align	2

;
; routine to print standard ending on a system test
; and then wait for operator to exit with ignition switch
; or start test loop with turbo switch
; 
operator_exit:
	CARRET
operator_exit2:
	CARRET 
operator_exit1:
	CARRET
	tst.b	loop_flag	;check if looping
	bne	operator_loop
	APALETTE	#YELLOW
	PRINT     "PRESS START TO EXIT"
	CARRET
	PRINT	"PRESS FIRSTBASE TO LOOP TEST"
	CARRET
	jsr       TogglePage
	clr.b     user_rdy_flg
	clr.b	user_sel_flg

oper_wait:
	DELAY     #1

	tst.b     user_rdy_flg
	beq       oper_select
	andi	#$fe,ccr	;clear carry to exit test
	rts
oper_select:
	tst.b	user_sel_flg
	beq	oper_wait
	move.b	#1,loop_flag
	PPRINT	#20,#20,"TEST IS BEING LOOPED"
	jsr	TogglePage
	ori	#1,ccr	;set carry to enter loop mode
	rts

operator_loop:
	APALETTE	#LTBLUE
	PRINT	"TEST PASSED  "
	PRINTDEC	loop_pass,#5,JRGT
	move.w	loop_fail,d0
	bsr	status_palette
	PRINT	"    TEST FAILED  "
	PRINTDEC	loop_fail,#5,JRGT
	CARRET
	CARRET	
	APALETTE	#YELLOW
	PRINT     "PRESS START TO EXIT"
	jsr	TogglePage
	DELAY	loop_delay

	tst.b     user_rdy_flg
	beq       oper_loop
	andi	#$fe,ccr	;clear carry to exit test
	rts
oper_loop:
	ori	#1,ccr	;set carry to continue loop mode
	rts
	
;
; routine to set palette based on value in d0
; d0 == zero palette LTBLUE and return zero status
; d0 != zero palette RED and return nonzero status
;
status_palette:
	PUSHL	d0	;save original value
	tst.w	d0
	beq	good_palette	;br if good
	move.b	#RED,d0
	bra	set_palette
good_palette:
	move.b	#LTBLUE,d0	;good palette color
set_palette
	APALETTE	d0
	POPL	d0
	tst.w	d0
	rts

;
;another temporary patch
;
TogglePageD:
	jsr	TogglePage
	DELAY	#2
	rts
;****************************************************************************
;
;****************************************************************************
	.export	host_write
host_write:
	PUSHL	a1
	PUSHW	d1
hw_10:
	tst.b	AQStat	; check if command queue idle
	beq	hw_20	; br if nothing happening
	DELAY	#1
	bra.s	hw_10
hw_20:
	move.w	A_STATUS,d0
	btst	#IDLE_B,d0	; check for idle asic
	beq	hw_10	; br if not

	move.w	A_STATUS,d0	; Load ASIC Status
	move.w	#$100,d0	; L/A ON
	or.w	S_Mode1,d0	; and normal bits
	ori.w	#Q_TRANSON,d0
	move.w	d0,A_MODE1	; into asic mode1 reg

	POPW	d1
	POPL	a1
	move.w	d1,PALSELA+2

	move.w	4(a1),A_WIDTH
	move.w	6(a1),A_HEIGHT	; 512 actually is 256
	move.w	8(a1),A_STARTX
	move.w	PageLine,d0	; get page being displayed
	eori.w	#$200,d0	; put data on page not being displayed
	add.w	10(a1),d0
	move.w	d0,A_STARTY

	move.w	#$3,A_STATE
	move.w	#$3,last_cmd

	move.w	4(a1),d0
	mulu	6(a1),d0
	move.l	(a1),a0
hw_byte0:
	btst.b	#3,A_STATUS+1	; check data register full bit
	bne	hw_byte0	; br if not data not ready
	move.b	(a0)+,A_USERREG+1	; write to ASIC
hw_byte1:
	move.b	d0,WATCHDOG	; will be spending some time here
	dbf	d0,hw_byte0	; check done writing data

	rts

sjj_art:
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
	dc.b	34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34
	dc.b	34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34
	dc.b	34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34
	dc.b	36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36
	dc.b	36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36
	dc.b	36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36
	dc.b	6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
	dc.b	6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
	dc.b	6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
	dc.b	10,10,10,10,10,10,14,14,14,14,14,14,14,14,10,10,10,10,10,10
	dc.b	10,10,10,10,10,10,14,14,14,14,14,14,14,14,10,10,10,10,10,10
	dc.b	10,10,10,10,10,10,14,14,14,14,14,14,14,14,10,10,10,10,10,10
	dc.b	12,12,12,12,12,12,28,28,28,28,28,28,28,28,12,12,12,12,12,12
	dc.b	12,12,12,12,12,12,28,28,28,28,28,28,28,28,12,12,12,12,12,12
	dc.b	12,12,12,12,12,12,28,28,28,28,28,28,28,28,12,12,12,12,12,12
	dc.b	8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8

test_screen:
	dc.l	sjj_art	; art address
	dc.w	20	; width
	dc.w	20	; height
	dc.w	180	; x
	dc.w	120	; y

	.align	2
	dc.w	0

	end

