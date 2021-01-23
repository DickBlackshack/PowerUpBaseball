;***************************************************************************
;                   INCREDIBLE TECHNOLOGIES, INC.                          *
;                    (C) COPYRIGHT 1994, IT, INC.                          *
;***************************************************************************
	.region.s  "RAM"
	ds	0

;	#define	SHOWSTATS
QUEUESIZE	equ	$2000
QEND	equ	ASICQueue+QUEUESIZE
BOTSCR	equ	256
RGTSCR	equ	384
;***************************************************************************
;   Routines Exported From GAME.ASM		*
;***************************************************************************
	.export	InitQueue,ClearCMD
	.export	ReadVRAM
	.export	DoIScale,DoOScale,DoClip,DoDXDY,DoClear,DoXClip
	.export	TogglePage,PageA,PageB,ClearPage
	.export	DoToggle,DoClrDraw,DoDisplay
	.export	DoNextCmd
	.export	TogglePage
	.export	WaitForVB
	.export	PPrint,Print,HexToDec,CReturn,FormatHex
	.export	BlitFlip,BlitFlop

;***************************************************************************
;  Variable Imports			*
;***************************************************************************
	.import.s	Next_Display,Toggle_Flag,Clear_Flag
	.import.s	Timing_Flag,last_cmd,ScreenInvert2
	.import	sine,YFlip,LA_Flag,BaseTable,WP_Flag
	.import	BaseFlags,XScale,YScale
;	.import	BaseAddress

;***************************************************************************
;  Subroutine Imports			*
;***************************************************************************
	.import	SetSysFont

;***************************************************************************
;  RAM Variables Defined In This Section		*
;***************************************************************************
	.export	BlitX,BlitY,BlitWidth
	.export.s current_pal,dcount
	.export.s Mode1,CharTrans,FontAdjust,AQStat,FontSpacing
	.export.s S_Mode1,S_IntMask
	.export.s PageLine
	.export.s NoAnchorFlag
	.export.s QMode1,FrameRate,dotaddress
	.export	bankaddress

	.export.s	N_PalSel
	;N_Plane,S_Plane

	.export.s AsicQueOut,AsicQueIn

	.export	font_start,prx_coor,pry_coor,font_width	  
	.export	font_height,font_offset
	.export	prx_init,print_field

	.export	PageLine,WaitQueSpace,NoAnchorFlag,rotate_flag
	.export	rotate_angle,Mode1,BlitCommand,DoEnable
	.export	BlitImage,GROMAddress,DoNextCmd,BlitHeight
	.export	BlitX,BlitY,RXFlip,BlitWidth
	.export	CameraX,CameraY
	.export	IdleLoop

	ds	0
ASICQueue	ds.b	QUEUESIZE	; Allocate Asic Queue
CameraX	ds.l	1	; Camera X Position
CameraY	ds.l	1	; Camera Y Position
prx_coor	ds.w	1	;x coord for printing
pry_coor	ds.w	1	;y coor for printing
font_width	ds.w	1	;
font_height	ds.w	1	;
font_start	ds.b	1
font_offset	ds.b	1	;font 0 or font 1
prx_init	ds.w	1	;start x coor
temp_image	ds.b	1	;temp image bank
pp1	ds.b	1	;format hex
pp2	ds.b	1	;format hex

pr_counter	ds.l	1	;temp
print_field	ds.b	22	;print up to 10 bytes of data+null
temp_field	ds.b	12	;used in hex to dec conversion

DrawTemp	ds.b	1
WipeTemp	ds.b	1
blit_head	ds.b	1	;head of blitter second queue 3-11-91 pointer
blit_tail	ds.b	1	;tail of blitter second queue 3-11-91 pointer

FrameRate	ds.w	1
AsicQueIn	ds.w	1	;Front of queue pointer
AsicQueOut	ds.w	1	;End of queue pointer
AQStat	ds.b	1	;Queue active/inactive flag.
FontAdjust	ds.l	1
FontSpacing	ds.l	1
CharTrans	ds.l	1

BlitX	ds.w	1	;do not change the order of these
BlitY	ds.w	1
BlitImage	ds.b	1
BlitFlip	ds.b	1
BlitFlop	ds.b	1

Mode1	ds.w	1
window_x	ds.w	1	;defined in x y 
window_y	ds.w	1
wind_wid	ds.w	1
wind_hgt	ds.w	1
left_clip	ds.w	1
up_clip	ds.w	1
right_clip	ds.w	1
down_clip	ds.w	1
rel_clip_lf	ds.w	1
rel_clip_rt	ds.w	1
rel_clip_up	ds.w	1
rel_clip_dw	ds.w	1
abs_clip_lf	ds.w	1
abs_clip_rt	ds.w	1
abs_clip_up	ds.w	1
abs_clip_dw	ds.w	1
blit_temp	ds.w	1
screen_x	ds.w	1
screen_y	ds.w	1
screen_wid	ds.w	1
screen_hgt	ds.w	1

temp_draw_temp ds.b	1
graph_temp     ds.b	1
current_pal    ds.b	1

PageLine	ds.w	1

S_Mode1	ds.w	1
S_IntMask	ds.w	1

rotate_angle	ds.w	1
rotate_flag	ds.b	1
RXFlip	ds.b	1
RYFlip	ds.b	1
NoAnchorFlag	ds.b	1
CompCount	ds.b	1
DspCount	ds.b	1

N_PalSel	ds.l	1
S_PalSel	ds.l	1
QMode1	ds.w	1
dcount	ds.w	1

ImageBank	ds.b	1

BlitWidth	ds.w	1
BlitHeight	ds.w	1
GROMSegment	ds.l	1
GROMAddress	ds.w	1
bankaddress	ds.l	1
dotaddress	ds.l	1
bankswitch	ds.b	1

BlitCommand	ds.w	1
ormode	ds.w	1
xormode	ds.w	1
andmode	ds.w	1
IdleLoop	ds.w	1
SavePrint	ds.l	1
sav_ptr	ds.w	1
;***************************************************************************
;  Start Of Program Code			*
;***************************************************************************
	.region	"RomCode"
	ds	0

	#include	"itvideo2.h"
	#include	"graphlib.h"
	#include	"graphlib.mac"
	#include	"graphglb.h"
	#include	"sys.mac"

;***************************************************************************
; InitQueue - Initialize ASIC Queue		*
;				*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: NONE				*
;***************************************************************************
InitQueue:
	clr.w	dcount
	clr.w	BlitX
	clr.w	BlitY
	clr.l	CameraX	; Clear Camera X Position
	clr.l	CameraY	; Clear Camera Y Position
	IMAGES	#0
	move.w	#1,FrameRate
	clr.b	rotate_flag
	clr.b	NoAnchorFlag  
	clr.w	QMode1
	clr.b	AQStat	; Clear Queue Status
	clr.b	ImageBank	; Clear Image Bank
	clr.w	PageLine	; Clear Page Line Offset
	clr.w	GROMSegment
	clr.b	bankswitch	; initial bank switch to 0	; Clear Image Bank
;	move.w	#$06,S_Plane	; Disable All Planes
;sj
	move.l	#PLANEPALINIT*0x10000,S_PalSel ; Led On, Disable All Planes, palette 0, LJH 8-17-94
	move.l	#PLANEPALINIT*0x10000,N_PalSel ; Led On, Disable All Planes, palette 0, LJH 8-17-94
;
	move.w	#ASICQueue,AsicQueIn    ; Clear Queue Input Pointer
	move.w	#ASICQueue,AsicQueOut   ; Clear Queue Output Pointer

	move.l	#0,ASICQueue

	move.w	#-1,last_cmd

	PLANES	#PLANEA	; Select The Background Plane
	APALETTE	#0

	rts

;***************************************************************************
; DummyCMD - reset the queue: MUST BE LOCATED BEFORE ALL OTHER xxxCMD's	*
;***************************************************************************
	.export	DummyCMD
DummyCMD:
	move.w	#ASICQueue,AsicQueOut              ;reset the Queue
	jmp	NextCmd

DUMMYCMD	equ	DummyCMD-DummyCMD
BLITCMD	equ	BlitCMD-DummyCMD
CLEARCMD	equ	ClearCMD-DummyCMD
TOGGLECMD	equ	ToggleCMD-DummyCMD
DISPLAYCMD	equ	DisplayCMD-DummyCMD
VINTCMD	equ	VintCMD-DummyCMD
DCLEARCMD	equ	ClearDrawCMD-DummyCMD
VIEWCMD	equ	ViewCMD-DummyCMD
XCLIPCMD	equ	XClipCMD-DummyCMD
YCLIPCMD	equ	YClipCMD-DummyCMD
WAITCMD	equ	WaitCMD-DummyCMD
ENABLECMD	equ	EnableCMD-DummyCMD
CLIPCMD	equ	ClipCMD-DummyCMD
DXDYCMD	equ	DxDyCMD-DummyCMD
ISCALECMD	equ	IScaleCMD-DummyCMD
LOADPALCMD	equ	LoadPalCMD-DummyCMD

;***************************************************************************
; BlitCMD() - Stuff blitter queue with blit info		*
;***************************************************************************
	.export	BlitCMD
BlitCMD:
	RETRIEVE	d1	;get mode 1
	or.w	S_Mode1,d1	;or in mode 1 shadow bits
	move.w	d1,A_MODE1	;write to asic

	RETRIEVE	A_GROMSEG	;grom segment select
	RETRIEVE	A_HEIGHT	;get height
	RETRIEVE	A_WIDTH	;get width
	RETRIEVE	A_GROMADR	;get grom address
	RETRIEVE	A_STARTX	;get starting X position
	RETRIEVE	A_STARTY	;get starting Y position
	
	RETRIEVE	d1	;get BLIT command
	move.w	d1,A_STATE	;start ASIC state machine
	move.w	d1,last_cmd	;indicate last ASIC command

	move.b	#1,AQStat	;show that we're waiting.
	move.w	a0,AsicQueOut	;save queue pointer
;	rte		;get back SR and return
	move	(sp)+,SR	; Recover IRQ Mask
	rts		; All done - exit.

;***************************************************************************
; WaitCMD() - Execute A HOSTREAD Command To Wait For ASIC To Finish	*
;		 		*
; Parameters: NONE			*
; Returns: NONE			*
; Uses:	 lots			*
;***************************************************************************
	.export	WaitCMD
WaitCMD:
	move.w	#400,A_STARTX	;

	move.w	#HOSTREAD,A_STATE	; Wait With Bogus Command
	move.w	#HOSTREAD,last_cmd
	move.b	#1,AQStat	; Show That We're Waiting.
	move.w	a0,AsicQueOut	; Save Queue Pointer
	move	(sp)+,SR	; Recover IRQ Mask
	rts		; All done - exit.

;***************************************************************************
; ClearCMD() - clear screen		*
;		 		*
; Parameters: a0 = queue pointer		*
; Returns: NONE			*
; Uses: NONE				*
;***************************************************************************
	.export	ClearCMD
ClearCMD:
	RETRIEVE	d1	; Retrieve Line To Clear With
	move.w	d1,d2	; Move To D2 For Clear
	RETRIEVE	d1	; Retrieve Number Of Lines
	move.w	d1,d3	; Move For Clear
	move.w	a0,AsicQueOut	; Save Queue Pointer
	jsr	Clear	; Clear The Screen 
	jmp	NextCmd	; Look for more commands.

;***************************************************************************
; VintCMD()				*
;***************************************************************************
	.export	VintCMD
VintCMD:
	RETRIEVE	d1	; Retrieve Line To Interupt On
	move.w	a0,AsicQueOut	; Save Queue Pointer
	move.w	d1,A_HLINECP	; Write Line To ASIC
	move.w	S_IntMask,d0	; Load Interrupt Mask
	ori.w	#HLINE,d0	; Enable Hline Interrupt
	move.w	d0,A_INTMASK	; Write Out Interrupt Mask
	move.w	#HLINE,A_INTCLR	; Clear Previous Interrupt
	move.b	#$80,AQStat	; Set High Bit To Show Waiting On VINT
	move	(sp)+,SR	; Restore Flags/IRQ Priority
	rts

;***************************************************************************
; DisplayCMD			*
;***************************************************************************
	.export	DisplayCMD
DisplayCMD:
	RETRIEVE	d1	; Retrieve Line To Interupt On
	move.w	a0,AsicQueOut	; Save Queue Pointer
	move.w	d1,Next_Display	; next time: use this framerate
	move.b	#$81,AQStat	; Do Something with AQStat
	move.b	#$81,Timing_Flag	;Indicate VBLANK has not taken place yet
	move	(sp)+,SR	; Restore Flags/IRQ Priority
	rts		; Let the Queue stop.

;***************************************************************************
; ToggleCMD			*
;***************************************************************************
	.export	ToggleCMD
ToggleCMD:
	move.w	a0,AsicQueOut	; Save Queue Pointer
	move.b	#1,Toggle_Flag	; tell vblank to toggle
	jmp	NextCmd	; Look for more commands.

;***************************************************************************
; ClearDrawCMD			*
;***************************************************************************
	.export	ClearDrawCMD
ClearDrawCMD:
	move.w	a0,AsicQueOut	; Save Queue Pointer
	move.b	#1,Clear_Flag	; tell vblank to clearscreen
	jmp	NextCmd	; Look for more commands.

;***************************************************************************
; ViewCMD() - Set The Plane A Tap Point For Displaying	*
;		 		*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: NONE			*
;***************************************************************************
	.export	ViewCMD
ViewCMD:	
	RETRIEVE	d1	; Retrieve Viewing Line Number
	move.w	d1,A_PLN0YTP	; Set Plane A Tap Point
	move.w	a0,AsicQueOut	; Save Queue Pointer
	jmp	NextCmd	; Do another command

;***************************************************************************
; EnableCMD()			*
;		 		*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: NONE			*
;***************************************************************************
	.export	EnableCMD
EnableCMD:
	RETRIEVE	d1	; Retrieve Plane Enable Data,lower word = palette info
	RETRIEVE	d0	; Retrieve Plane Enable Data,upper word = plane info

	move.w	a0,AsicQueOut	; Save Queue Pointer
	move.w	d1,PALSELA+2       ; Store Palette byte
	lsr.w	#8,d1
	move.w	d1,PALSELB+2      ; Store Palette byte

	move.w	d0,PLANE+2	; save led , plane , pal config info
	jmp	NextCmd	; Do another command


;***************************************************************************
; ClipCMD()			*
;		 		*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: NONE			*
;***************************************************************************
	.export	ClipCMD
ClipCMD:
	RETRIEVE	d1	; Retrieve Top Clip
	move.w	d1,A_TOPCLIP	; Upper clip value
	RETRIEVE	d1	; Retrieve Bottom Clip
	move.w	d1,A_BOTCLIP	; Lower clip value
	RETRIEVE	d1	; Retrieve Left Clip
	move.w	d1,A_LEFTCLIP	; Left clip value
	RETRIEVE	d1	; Retrieve Right Clip
	move.w	d1,A_RGHTCLIP	; Right clip value
	move.w	a0,AsicQueOut	; Save Queue Pointer
	jmp	NextCmd

;***************************************************************************
; XClipCMD() - Set X Coordinate Clipping	*
;				*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: NONE			*
;***************************************************************************
	.export	XClipCMD
XClipCMD:
	RETRIEVE	d1	; Retrieve Left Clip
	move.w	d1,A_LEFTCLIP	; Left clip value
	RETRIEVE	d1	; Retrieve Right Clip
	move.w	d1,A_RGHTCLIP	; Right clip value
	move.w	a0,AsicQueOut	; Save Queue Pointer
	jmp	NextCmd

;***************************************************************************
; YClipCMD() - Set Y Coordinate Clipping	*
;				*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: NONE			*
;***************************************************************************
	.export	YClipCMD
YClipCMD:
	RETRIEVE	d1	; Retrieve Left Clip
	move.w	d1,A_TOPCLIP	; Upper clip value
	RETRIEVE	d1	; Retrieve Right Clip
	move.w	d1,A_BOTCLIP	; Lower clip value
	move.w	a0,AsicQueOut	; Save Queue Pointer
	jmp	NextCmd

;***************************************************************************
; DxDyCMD()			*
;		 		*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: NONE			*
;***************************************************************************
	.export	DxDyCMD
DxDyCMD:
	RETRIEVE	d1	; Retrieve Pix DX
	move.w	d1,A_PIXDX
	RETRIEVE	d1	; Retrieve Pix DY
	move.w	d1,A_PIXDY
	RETRIEVE	d1	; Retrieve Row DX
	move.w	d1,A_ROWDX
	RETRIEVE	d1	; Retrieve Row DY
	move.w	d1,A_ROWDY
	move.w	a0,AsicQueOut	; Save Queue Pointer
	jmp	NextCmd

;***************************************************************************
;   SetBkgClr - Set Up Background Color	*
;				*
; Parameters: a0.l - Pointer To Background Color	*
;***************************************************************************
	.export	SetBkgClr
SetBkgClr:
	move.l	#PALETTES+0x1FFFC,a1 ; Load Address Of Background Color
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	rts

;***************************************************************************
;   ClearPalette - Load A Color Palette With Single Color	*
;				*
;   Parameters :			*
;	 d0.w - Starting Color Number	*
;	 d1.w - Number of colors being loaded	*
;	 d2.w - Color Palette Number	*
;	 d3.w - Color Value (Red/Green)	*
;	 d4.w - Color Value (Blue)		*
;***************************************************************************
	.export	ClearPalette
ClearPalette:
	andi.l	#0xffff,d2	;/Clear Upper Bytes
	asl.w	#8,d2	; Multiply Palette Number By 256
	add.w	d0,d2	; Add Starting Color Number
	asl.l	#2,d2	;mult by 4 bytes per color
	move.l	#PALETTES,a1	; Load Address Of Palettes
	add.l	d2,a1	;/Add In Offset

	subq.w	#1,d1
ClearPal_1:
	move.w	d3,(a1)+	; Write Green\Red To Color Palette
	move.w	d4,(a1)+	; Write Blue Color To Palette
	dbf	d1,ClearPal_1	; Loop Until Done
	rts

;***************************************************************************
;   LoadPalette - Load A Color Palette for Frame Load Mode	*
;				*
;   Parameters :			*
;	 a0.l - Pointer To Color Data	*
;	 d0.w - Starting Color Number	*
;	 d1.w - Number of colors being loaded	*
;	 d2.w - Color Palette Number	*
;***************************************************************************
	.export	LoadPalette
LoadPalette:		; 68020 rev Jdz
	andi.l	#0xffff,d2	;/Clear Upper Bytes
	lsl.w	#8,d2	; Multiply Palette Number By 256
	add.w	d0,d2	; Add Starting Color Number
	lsl.l	#2,d2	;mult by 4 bytes per color
	move.l	#PALETTES,a1	; Load Address Of Palettes
	add.l	d2,a1	;/Add In Offset

	subq.w	#1,d1
LoadPal_1:
	move.l	-1(a0),(a1)+
	lea	3(a0),a0
	dbf	d1,LoadPal_1	; Loop Until Done
	rts

;***************************************************************************
; LoadPalCMD()			*
;		 		*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: NONE			*
;***************************************************************************
	.export	LoadPalCMD
LoadPalCMD:
	clr.l	d1
	RETRIEVE	d1	; Palette/Start
	lsl.l	#2,d1	; Multiply by 4 bytes per color
	addi.l	#PALETTES,d1
	move.l	d1,a1
	RETRIEVE	d1	;get # of colors
	move.w	d1,d2
	RETRIEVE	d1	;get address of data
	swap	d1
	RETRIEVE	d1          
	move.l	d1,a2
	subq.w	#1,d2

	move.w	a0,AsicQueOut
zLoadPal_1:
	clr.w	d0	; Clear d0
	move.b	(a2)+,d0	; Load Red Color
	move.b	(a2)+,d1	; Load Green Color
	lsl.w	#8,d1	; Shift To Upper Byte
	or.w	d1,d0	; Or Together Reg And Green
	move.w	d0,(a1)+	; Write Green\Red To Color Palette
	move.b	(a2)+,(a1)+	; move blue
	addq	#1,a1	; adjust dest to skip byte

	dbf	d2,zLoadPal_1	; Loop Until Done
	jmp	NextCmd

;****************************************************************
	.export	IScaleCMD
IScaleCMD:
	RETRIEVE	d1	; Retrieve Horizontal Scale Value
	move.w	d1,A_HSCALE	; 
	RETRIEVE	d1	; Retrieve Vertical Scale Value
	move.w	d1,A_VSCALE	; 
	move.w	a0,AsicQueOut	; Save Queue Pointer
	jmp	NextCmd

;***************************************************************************
; DoNextCmd() - Take commands from the blitter queue and process.	*
;***************************************************************************
	.export	DoNextCmd,DoNextICmd,NextCmd
DoNextCmd:
	tst.b	AQStat	;check if queue is busy
	bne.s	NextCmd_3	;branch if busy
DoNextICmd:		;entry point if we just cleared aqstat
	move.w	SR,-(sp)	;push status onto stack
	ori.w	#DIRQ,SR	;disable all interrupts
NextCmd_2:
	move.w	AsicQueOut,a0	;load queue output address
	cmp.w	AsicQueIn,a0	;compare with queue input
	beq.s	NextCmd_1	;branch if nothing in queue
	.export	break
break:
	RETRIEVE	d1	;retrieve next command
	movea.l	#DummyCMD,a1	;get command base address
	jmp	(a1,d1.w)	;and jump to the offset fetched from queue
NextCmd:
	move.w	A_STATUS,d0	;load ASIC status
	btst	#CMDREG_B,d0	;check if command register is full
	beq.s	NextCmd_2	;branch if ASIC not busy
	move.b	#1,AQStat	;make XFER int come to us
NextCmd_1:
	move	(sp)+,SR	; Recover IRQ mask
	rts		; All done - exit.
;	rte		;get SR back and return
NextCmd_3:
	rts		;all done - exit.
					      
;***************************************************************************
;	   BLITTER QUEUE INPUT CALLS	*
;***************************************************************************
	.export	DoClear
DoClear:
	movem.w	d2,-(sp)	; Save D2 On Stack
	DOENABLE
	movem.w	(sp)+,d2	; Get D2 From Stack

	move.w	#8,d1	; 8 Bytes Needed For Clear Command
	jsr	WaitQueSpace	; Wait For Queue Space
	move.w	SR,-(sp)	; Push Status Onto Stack
	ori.w	#DIRQ,SR	; Disable IRQs

	INSERT	#WAITCMD	; Wait For Last Command To End
	INSERT	#CLEARCMD	; Insert Command Into Queue
	INSERT	d2	; Insert Line To Clear With
	INSERT	d3	; Insert Number Of Lines To Clear
	move.w	a0,AsicQueIn	; Save New Queue Input Address
	move	(sp)+,SR	; Pull SR (MUST BE in SUPERVISOR MODE)
	jmp	DoNextCmd

;****************************************************************
	.export	ramdump
ramdump
	KICK_DOG
	move.l	#0x400,a1
ramdumploop	
	move.w	(a1)+,d0
	cmp.l	#(0x400+0x3c00),a1
	bne	ramdumploop   
	bra.s	ramdump

****************************************************************************
* DoVint() - Wait for a raster line interrupt.	*
* Parameters: d2.w = raster line		*
****************************************************************************
	.export	DoVint
DoVint:
	move.w	#4,d1	; 4 Bytes Needed For VINT Command
	jsr	WaitQueSpace	; Wait For Queue Space
	move	SR,-(sp)	; Push Status Onto Stack
	move.w	#DIRQ,SR	; Disable IRQ
	INSERT	#VINTCMD	; Wait for raster line interrupt.
	INSERT	d2	; Insert Raster Line Into Queue
	move.w	a0,AsicQueIn	; Save New Queue Input Address
	move	(sp)+,SR	; MUST BE in SUPERVISOR MODE 
	jmp	DoNextCmd

;***************************************************************************
; DoWait() - Wait for last instruction to finish                         	*
;	   (MUST BE DONE WHEN ENABLED PLANES CHANGE) (ASIC PROBLEM #3)	*
;		 		*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: NONE			*
;***************************************************************************
	.export	DoWait
DoWait:
	move.w	#2,d1	; 4 Bytes Needed For WAIT Command
	jsr	WaitQueSpace	; Wait For Queue Space
	move	SR,-(sp)	; Push Status Onto Stack
	move.w	#DIRQ,SR	; Disable IRQ
	INSERT	#WAITCMD	; Wait for raster line interrupt.
	move.w	a0,AsicQueIn	; Save New Queue Input Address
	move	(sp)+,SR	; MUST BE in SUPERVISOR MODE 
	jmp	DoNextCmd

;***************************************************************************
; DoClip - Set Up The ASIC Clip Values		*
;		 		*
; Parameters: d2.w - Top Clip		*
;	    d3.w - Bottom Clip		*
;	    d4.w - Left Clip		*
;	    d5.w - Right Clip		*
; Returns: NONE			*
; Uses: d0,d1,a0			*
;***************************************************************************
	.export	DoClip
DoClip:
	move.w	#12,d1	; 10 Bytes Needed For CLIP Command
	jsr	WaitQueSpace	; Wait For Queue Space
	move	SR,-(sp)	; Push Status Onto Stack
	move.w	#DIRQ,SR	; Disable IRQ's
	INSERT	#WAITCMD	; Wait for raster line interrupt.
	INSERT	#CLIPCMD	; Output CLIP Command

;	btst.b	#1,N_Plane+1	; Check If Plane A Is Enabled
;	bne.s	DoClip1	; Branch If Not
	tst.w	ScreenInvert2
	beq.s	DoClip2

	move.w	#BOTSCR,d1	;top
	sub.w	d2,d1
	move.w	d1,d2

	move.w	#(BOTSCR-1),d1	;bot
	sub.w	d3,d1
	move.w	d1,d3

	move.w	#RGTSCR,d1	;left
	sub.w	d4,d1
	move.w	d1,d4

	move.w	#(RGTSCR-1),d1	;right
	sub.w	d5,d1
	move.w	d1,d5

	exg	d2,d3	;exchange top & bot clip parms
	exg	d4,d5	;exchange left & right clip parms
DoClip2
	add.w	PageLine,d2
	add.w	PageLine,d3
DoClip1
	add.w	#VRAMPAGE,d2
	INSERT	d2	; Insert Top Clip Value
	add.w	#VRAMPAGE,d3
	INSERT	d3	; Insert Bottom Clip Value
	add.w	#VRAMCOL,d4
	INSERT	d4	; Insert Left Clip Value
	add.w	#VRAMCOL,d5
	INSERT	d5	; Insert Right Clip Value
	move.w	a0,AsicQueIn	; Save New Queue Input Address
	move	(sp)+,SR	; restore flags/IRQ priority
	jmp	DoNextCmd

;***************************************************************************
; DoXClip - Set Up The ASIC X Coordinate Clip Values	*
;		 		*
; Parameters: d2.w - Left Clip		*
;	    d3.w - Right Clip		*
;				*
; Returns: NONE			*
;				*
; Uses: d0,d1,a0			*
;***************************************************************************
	.export	DoXClip
DoXClip:
	move.w	#8,d1	; 8 Bytes Needed For CLIP Command
	jsr	WaitQueSpace	; Wait For Queue Space
	move	SR,-(sp)	; Push Status Onto Stack
	move.w	#DIRQ,SR	; Disable IRQ's
	INSERT	#WAITCMD	; Output WAIT Command
	INSERT	#XCLIPCMD	; Output CLIP Command
;	btst.b	#1,N_Plane+1	; Check If Plane A Is Enabled
;	bne.s	doxclip2	; Branch If Not
	tst.w	ScreenInvert2
	bne.s	dxcusd
doxclip2
	add.w	#VRAMCOL,d2
	INSERT	d2	; Insert Left Clip Value
	add.w	#VRAMCOL,d3
	INSERT	d3	; Insert Right Clip Value
	move.w	a0,AsicQueIn	; Save New Queue Input Address
	move	(sp)+,SR	; restore flags/IRQ priority
	jmp	DoNextCmd
dxcusd
	exg	d2,d3	;exchange left & right clip parms

	move.w	#RGTSCR,d1	;left
	sub.w	d2,d1
	add.w	#VRAMCOL,d1
	INSERT	d1	; Insert Left Clip Value

	move.w	#(RGTSCR-1),d1	;right
	sub.w	d3,d1
	add.w	#VRAMCOL,d1
	INSERT	d1	; Insert Right Clip Value

	move.w	a0,AsicQueIn	; Save New Queue Input Address
	move	(sp)+,SR	; restore flags/IRQ priority
	jmp	DoNextCmd

;***************************************************************************
; DoYClip - Set Up The ASIC Y Coordinate Clip Values	*
;		 		*
; Parameters: d2.w - Top Clip		*
;	    d3.w - Bottom Clip		*
;				*
; Returns: NONE			*
;				*
; Uses: d0,d1,a0			*
;***************************************************************************
	.export	DoYClip
DoYClip:
	move.w	#8,d1	; 8 Bytes Needed For CLIP Command
	jsr	WaitQueSpace	; Wait For Queue Space
	move	SR,-(sp)	; Push Status Onto Stack
	move.w	#DIRQ,SR	; Disable IRQ's
	INSERT	#WAITCMD	; Output WAIT Command
	INSERT	#YCLIPCMD	; Output CLIP Command
;	btst.b	#1,N_Plane+1	; Check If Plane A Is Enabled
;	bne.s	doyclip2	; Branch If Not
	tst.w	ScreenInvert2
	bne.s	dycusd
doyclip2
	add.w	#VRAMPAGE,d2
	INSERT	d2	; Insert Top Clip Value
	add.w	#VRAMPAGE,d3
	INSERT	d3	; Insert Bottom Clip Value
	move.w	a0,AsicQueIn	; Save New Queue Input Address
	move	(sp)+,SR	; restore flags/IRQ priority
	jmp	DoNextCmd
dycusd
	exg	d2,d3	;exchange top & bottom clip parms

	move.w	#BOTSCR,d1	;top
	sub.w	d2,d1
	add.w	#VRAMPAGE,d1
	INSERT	d1	; Insert Top Clip Value

	move.w	#(BOTSCR-1),d1	;bot
	sub.w	d3,d1
	add.w	#VRAMPAGE,d1
	INSERT	d1	; Insert Bottom Clip Value

	move.w	a0,AsicQueIn	; Save New Queue Input Address
	move	(sp)+,SR	; restore flags/IRQ priority
	jmp	DoNextCmd

;***************************************************************************
; DoView()  visable page		*
;		 		*
; Parameters: d2.b = page number		*
; Returns: NONE			*
; Uses: d0,d1,a0			*
;***************************************************************************
	.export	DoView
DoView:
	move.w	#4,d1	; 4 Bytes Needed For VIEW Command
	jsr	WaitQueSpace	; Wait For Queue Space
	move	SR,-(sp)	; Push Status Onto Stack
	move.w	#DIRQ,SR	; Disable IRQ's
	INSERT	#VIEWCMD	; Insert View Command
	INSERT	d2	; Insert Viewing Line Number
	move.w	a0,AsicQueIn	; Save New Queue Input Address
	move	(sp)+,SR	; restore flags/IRQ priority
	jmp	DoNextCmd

;***************************************************************************
; Clear() - Clears The Number Of Lines Specified       	*
;			                 	*
; Parameters: d2.w - Line To Use For Clearing The Screen	*
;	    d3.w - Number Of Lines To Clear          	*
; Returns: NONE		                 	*
; Uses: NONE		                 	*
;***************************************************************************
	.export	Clear
	.export	DClear
Clear: 
	jsr	WaitForVB	; Scott Says Do This "crucial"
DClear:
	PUSHW	d2-d3

	move.l	#$ffffffff,PALSELA	;/test
;;	move.w	#$ff,PALSELB+2	;/test

	move.w	#$100,A_VSCALE
	move.w	#$100,A_HSCALE
	move.w	#$0,A_PIXDX
	move.w	#$100,A_ROWDY
	move.w	#$0,A_PIXDY
	move.w	#$0,A_ROWDX

	move.w	S_Mode1,d1	; Or In Mode 1 Shadow Bits
	andi.w	#$FFFE,d1	; Turn Off Transparency
	ori.w	#$0004,d1	; Turn On Flop
	andi.w	#$FBFF,d1	; Turn Off Clipping
	ori.w	#$100,d1	; turn on grom l/a
	move.w	d1,A_MODE1	; Set Up Mode 1 Register

	POPW	d2-d3
	move.w	#32,A_WIDTH
	move.w	#0,A_STARTX
	move.w	d2,A_STARTY
	move.w	#1,A_HEIGHT
	move.w	#$10,A_HSCALE
	move.w	#$007f,A_GROMSEG
	move.w	#$FF00,A_GROMADR
	move.w	#BLITU,A_STATE
	move.w	#BLITU,last_cmd

	move.w	#40,d0
stall:	
	dbf	d0,stall
ds_wait1
	move.w	A_STATUS,d0	;Load ASIC Status
	andi.w	#11000000b,d0
	cmpi.b	#10000000b,d0
	bne.s	ds_wait1	;If not, Keep Waiting

;	move.w	#$ff,PALSELA	;restore palette

	move.w	#$100,A_HSCALE
	move.w	#1,A_WIDTH
	move.w	#0,A_STARTX
	move.w	d2,A_STARTY	; Setup Line To Use For Clearing
	move.w	d3,A_HEIGHT	; Set Up Number Of Lines To Clear
	move.w	#CLEARSCR,A_STATE ; Clear Screen
	move.w	#CLEARSCR,last_cmd

	move.w	#40,d0
stall2:	
	dbf	d0,stall2

ds_wait2
           move.w    A_STATUS,d0       ;Load ASIC Status
           andi.w    #11000000b,d0
           cmpi.b    #10000000b,d0
           bne.s     ds_wait2          ;If not, Keep Waiting
;	move.l	#-1,S_PalSel
	rts

;***************************************************************************
;       WAITBLITTER		                 	*
;			                 	*
;	     Wait here until the blitter is done.    	*
;***************************************************************************
	.export	WaitForASIC
WaitForASIC:
	move.w	A_STATUS,d0	; Load ASIC Status
	btst	#CMDREG_B,d0	; Test IDLE Bit
	bne.s	WaitForASIC	; Branch If Still Busy
	rts

;***************************************************************************
;       WAITBLITTER		                 	*
;			                 	*
;	     Wait here until the blitter is done.    	*
;***************************************************************************
	.export	WaitForVB
WaitForVB:
	move.w	A_STATUS,d0	; Load ASIC Status
	btst	#VBACTIVE_B,d0	; Test Vertical Blank Bit
	beq.s	WaitForVB	; Branch If Still Busy
	rts

;***************************************************************************
;   ReadVRAM - Read VRAM Array Into An Array	*
;				*
;   Parameters :			*
;	 a0.l - Pointer To Memory Area	*
;	 d0.w - Starting X Position		*
;	 d1.w - Starting Y Position		*
;	 d2.w - Width Of VRAM Area		*
;	 d3.w - Height Of VRAM Area		*
;***************************************************************************
	.export	ReadVRAM
ReadVRAM:
	move.w	#0000100000B,A_INTMASK             ; Disable All But VBLANK
	move.w	S_Mode1,A_MODE1	; Write Mode 1 Value To ASIC
	move.w	d3,A_HEIGHT	; Write Height To ASIC
	move.w	d2,A_WIDTH	; Write Width To ASIC
	clr.w	d4
	move.w	d0,A_STARTX	; Write Starting X To ASIC
	move.w	d1,A_STARTY	; Write Starting Y To ASIC
;	 move.w	 #HOSTREAD,A_STATE                 ; Start ASIC State Machine
	move.w	#10,d5
ReadV_1:
ReadV_2:
	move.w	A_STATUS,d0	; Load Status Of ASIC
	andi.w	#$20,d0	; Check If Data Register Ready
	bne.s	ReadV_2	; Branch If Not Ready
	KICK_DOG
	move.w	A_USERREG,d0	; Load VRAM Data
;	move.b	d0,(a0)+	; Store In Memory
	cmp.b	(a0)+,d0	; Store In Memory
	bne.s	BadRead
	addq.w	#1,d4
	cmp.w	d4,d2
	bne.s	ReadV_1
	clr.w	d4
	addq.w	#1,d5
	cmp.w	d5,d3
	bne.s	ReadV_1
	move.w	S_IntMask,A_INTMASK                ; Write Out Interrupt Mask Shadow
	rts

	.export	BadRead
BadRead:
	KICK_DOG
	bra	BadRead

;***************************************************************************
;	Draw to PageA or PageB	                 	*
;	set print parameters also	                 	*
;***************************************************************************
	.export	PageA
PageA:
	clr.w	PageLine
	VIEW	#PAGEA
	rts
PageB:
	move.w	#256,PageLine
	VIEW	#PAGEB
	rts

;***************************************************************************
;	ClearPage clears current draw_page           	*
;***************************************************************************
	.export	ClearPage
ClearPage:
	rts

;***************************************************************************
; DoDXDY - Set Up ASIC DX/DY Values		*
;		 		*
; Parameters: d2.w - PIXDX Value		*
;	    d3.w - PIXDY Value		*
;	    d4.w - ROWDX Value		*
;	    d5.w - ROWDY Value		*
; Returns: NONE			*
; Uses: d0,d1,a0			*
;***************************************************************************
	.export	DoDXDY
DoDXDY:
	move.w	#10,d1	; 10 Bytes Needed For DXDY Command
	jsr	WaitQueSpace	; Wait For Queue Space
	move	SR,-(sp)	; Push Status Onto Stack
	move.w	#DIRQ,SR	; Disable IRQ's
	INSERT	#DXDYCMD	; Insert DXDY Command

	clr.b	RXFlip
	clr.b	RYFlip
	btst.b	#TST_FLIP,QMode1+1
	beq.s	jd1
	move.b	#1,RXFlip
jd1	btst.b	#TST_FLOP,QMode1+1
	beq.s	jd2
	move.b	#1,RYFlip
jd2	andi.w	#Q_FLIPOFF,QMode1
	andi.w	#Q_FLOPOFF,QMode1
	tst.w	d2
	bmi.s	pdxneg
	andi.w	#1111111111111101B,QMode1          ;flip = (pdx < 0)
	bra.s	pdxmeet
pdxneg:
	ori.w	#0000000000000010B,QMode1
	neg.w	d2
pdxmeet:	
	INSERT	d2	; Insert PIXDX Value
	tst.w	d3
	bmi.s	pdyneg
	andi.w	#1111111111101111B,QMode1          ;bit 4 = (pdy < 0)
	bra.s	pdymeet
pdyneg:
	ori.w	#0000000000010000B,QMode1
	neg.w	d3
pdymeet:
	INSERT	d3	; Insert PIXDY Value
	tst.w	d4
	bmi.s	rdxneg
	ori.w	#0000000000100000B,QMode1          ;bit 5 = !(rdx < 0)
	bra.s	rdxmeet
rdxneg:
	andi.w	#1111111111011111B,QMode1
	neg.w	d4
rdxmeet:
	INSERT	d4	; Insert ROWDX Value
	tst.w	d5
	bmi.s	rdyneg
	andi.w	#1111111111111011B,QMode1          ;flop = (rdy < 0)
	bra.s	rdymeet
rdyneg:
	ori.w	#0000000000000100B,QMode1
	neg.w	d5
rdymeet:
	INSERT	d5	; Insert ROWDY Value
	move.w	a0,AsicQueIn	; Save New Queue Input Address
	move	(sp)+,SR	; restore flags/IRQ priority
	jmp	DoNextCmd

;****************************************************************
	.export	DoIScale
DoIScale:
	move.w	#6,d1	; 6 Bytes Needed For SCALE Command
	jsr	WaitQueSpace	; Wait For Queue Space
	move	SR,-(sp)	; Push Status Onto Stack
	move.w	#DIRQ,SR	; Disable IRQ's
	INSERT	#ISCALECMD	                 ; Insert Scale Command
	INSERT	d2	; Insert Horizontal Scale Value
	INSERT	d3	; Insert Vertical Scale Value
	move.w	a0,AsicQueIn	; Save New Queue Input Address
	move	(sp)+,SR	; restore flags/IRQ priority
	jmp	DoNextCmd

;****************************************************************
	.export	DoOScale
DoOScale:
	cmpi	#$100,d6
	blt	dosz
	btst	#3,Mode1
	beq.s	dosx
	move.w	#$ff,d6
dosz:
	ori.w	#8,Mode1
	DXDY	d6,#0,#0,d7
	rts
dosx:
	DXDY	#0,#0,#0,d7
	rts

;****************************************************************
	.export	DoLoadPal
DoLoadPal:
	move.w	#10,d1	; 10 Bytes Needed For LOADPAL Command
	jsr	WaitQueSpace	; Wait For Queue Space
	move	SR,-(sp)	; Push Status Onto Stack
	move.w	#DIRQ,SR	; Disable IRQ

	INSERT	#LOADPALCMD	; loadpal
	INSERT	d3	; to this abs color #
	INSERT	d2	; this # of colors
	move.l	a2,d1
	swap	d1
	INSERT	d1
	swap	d1
	INSERT	d1

	move.w	a0,AsicQueIn	;  Save New Queue Input Address
	move	(sp)+,SR	; MUST BE in SUPERVISOR MODE 
	jmp	DoNextCmd
	nop

;***************************************************************************
;  FormatHex       			*
;	     Enter with a0 holding pointer to field  	*
;	     d0 holding number of bytes              	*
;		number of bytes must not exceed 10 	*
;***************************************************************************
	.export	FormatHex
FormatHex:  
	clr.w	d1	; clear d1 = pp2, d0 = pp1
	asl.b	d0	; 2 * the number of bytes to display
	move.l	#print_field,a2	; address of destination field
	move.l	#hex_tab,a1
fr_hex_loop:
	move.b	(a0),d2	; get first byte
	lsr.b	#4,d2	; d2 holds top 4 bits/16
	and.w	#15,d2	; lower 16 bits
	move.b	(a1,d2),(a2,d1)	; get print digit 
	add.b	#1,d1	; add 1 to dest offset count
	move.b	(a0)+,d2	; get source data again
	and.w	#15,d2	; lower 16 bits
	move.b	(a1,d2),(a2,d1)	; get print digit 
	add.b	#1,d1	; add 1 to dest offset count
	cmp.b	d1,d0
	bne	fr_hex_loop
	clr.b	(a2,d1)	; end of string
	rts

;***************************************************************************
;       Hex_to_dec converts a 32 bit number to dec      	*
;       enter with 32 bit value in d0 and justification flag  	*
;       in d1 ored with the number of letters to be printed    	*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: d0,d1,d2,d3,d4,d5			*
;       a0,a1				*
;***************************************************************************
	.export	HexToDec
HexToDec:
	move.b	d1,d2	; copy justification flag
	and.b	#127-64-32,d1	; -64 for no padding, d1 = num letters

	move.l	#temp_field,a1	; pointer to digit counts
	move.l	#comp_field,a0	; pointer to long sub values

	clr.b	d5	; d5 used as sign byte
	btst	#5,d2	; are we in the signed mode
	beq	next_sub_loop	; if no skip neg test	 
	tst.l	d0	; if neg then take abs
	bpl	next_sub_loop
	neg.l	d0	; make pos
	move.b	#-1,d5	; set sign byte to -

next_sub_loop:
	clr.b	(a1)	; start at 0 for this digit count
sub_loop:
	sub.l	(a0),d0	; reduce until carry S
	bcs	got_under
	add.b	#1,(a1)	; add to current digit count
	bra	sub_loop	; keep subtracting
got_under:
	add.l	(a0)+,d0	; get back to value and point to comp_filed
	add.l	#1,a1	; add 1 to temp field
	cmp.l	#(comp_field+(9*4)),a0             ; are we done comparing
	beq	sub_loop_done
	bra	next_sub_loop	; continue if not
sub_loop_done:
	move.b	d0,(a1)	; move final digits into temp_field

	move.b	#10,d0
	sub.b	d1,d0	; 10 - num letters in d0
	and.w	#0ffh,d0	; word offset to source data
	move.l	#temp_field,a0	; source pointer
	move.l	#print_field,a1	; index into dest data
	clr.b	d3	; found 0 flag

	tst.b	d2	; test justification mode
	bmi	just_left	; left if -, right if +

	btst	#5,d2	; are we in the signed mode
	beq	right_just_loop
	move.b	#' ',(a1)+	; make room for sign flag
right_just_loop:
	move.b	(a0,d0.w),d4	; d4 hold digit
	beq	found_0_r
	move.b	#1,d3	; indicate that we found a non 0
	bra	found_non_0_r
found_0_r:
	tst.b	d3	; if 1 then we have found a 0
	bne	found_non_0_r
	cmp.w	#9,d0	; are we on last letter
	beq	found_non_0_r	; if so then print the 0

	btst	#6,d2	; if we are in the no pad mode
	bne	found_non_0_r	; then print the 0 always.

	move.b	#' ',d4	; pad with leading spaces
	bra	skip_ascii_conv_r
found_non_0_r:
	tst.b	d5	; tst sing byte
	bpl	pos_r	; if pos then skip
	clr.b	d5	; clear sign flag
	move.b	#'-',(-1,a1)	; put neg sign one char back
pos_r:	
	add.b	#'0',d4	; convert to ascii
skip_ascii_conv_r:
	move.b	d4,(a1)+	; destination
	add.w	#1,d0	; increment source offset
	cmp.w	#10,d0
	bne	right_just_loop
	move.b	#0,(a1)	; end of string marker
	bra	exit_hex_to_dec
just_left:
	tst.b	d5	; test dign
	bpl	just_left_a
	move.b	#'-',(a1)+	; move in a neg sign
just_left_a:
	move.b	(a0,d0.w),d4	; d4 hold digit
	beq	found_0_l
	move.b	#1,d3	; indicate that we found a non 0
	bra	found_non_0_l
found_0_l:
	tst.b	d3	; if 1 then we have found a 0
	bne	found_non_0_l
	cmp.w	#9,d0	; are we on last letter
	bne	skip_letter	; if not then don't print the 0
found_non_0_l:
	add.b	#'0',d4	; convert to ascii
	move.b	d4,(a1)+	; destination
skip_letter:
	add.w	#1,d0	; source offset
	cmp.w	#10,d0	; have we reach max
	bne	just_left_a
	move.b	#0,(a1)	; end of string indicator
exit_hex_to_dec:
	rts

; ****************************************************************
comp_field:
	dc.l	1000000000
	dc.l	 100000000
	dc.l	  10000000
	dc.l	   1000000
	dc.l	    100000
	dc.l	     10000
	dc.l	      1000
	dc.l	       100
	dc.l	        10

hex_tab:
	dc.b	'0123456789ABCDEF'
	ds	0	; align prg counter

;****************************************************************
CReturn:
	move.w	font_height,d0
	add.w	d0,pry_coor
	move.w	prx_init,prx_coor
	rts

;***************************************************************************
;  PPrint - Print Text To The Screen		*
;				*
;   Parameters :  d1.w - X Position For Text	*
;	       d2.w - Y Position For Text	*
;	       a0   - Pointer to string	*
;***************************************************************************
PPrint: 
	move.w	d1,prx_init	; store left margin
	move.w	d1,prx_coor	; store print X position
	move.w	d2,pry_coor	; store print Y position
Print:
	clr.l	SavePrint	; Clear Saved Address
	clr.w	BlitX	; clear X offset for next blit
	clr.w	BlitY	; clear Y offset for next blit
	tst.l	FontSpacing	; Check If Proportional
	bne	ProPrint	; Print It Propo
	move.l	a0,a3	; use a0 for backward compatability
QPrint:
	andi.w	#Q_FLIPOFF&Q_FLOPOFF,QMode1 ; no flipping of flopping
	move.b	ImageBank,temp_image        ; save image bank
	IMAGES	font_offset	          ; set up font bank

	move.l	CharTrans,a4	; 255 byte translation table
	bra.s	Print_1	; initiate printing

Print_0:
	move.w	font_width,d0	; add the font width
	add.w	d0,prx_coor	; to the current X coord
Print_1:
	clr.w	d0
	move.b	(a3)+,d0	; load character from string
	ble.s	Print_B	; if finished, or palette needs changing
	clr.w	d3	; clear upper byte
	move.b	(a4,d0.w),d3	; get actual char offset
	ble.s	Print_A	; if non-printable
	sub.b	font_start,d3	; subtract starting character number
	move.w	prx_coor,d4	; load X position
	move.w	pry_coor,d5	; load Y position

	move.l	FontAdjust,d0	; Load Font Adjust Address
	beq.s	Print_2	; Branch If No Adjust Table
	move.l	d0,a2	; Move To A2
	move.w	d3,d0	; Load Character Number To d0
	lsl.w	#1,d0	; Multiply By Two
	move.b	(a2,d0.w),d1	; Load X Offset
	ext.w	d1
	add.w	d1,d4	; Offset X Position
	move.b	1(a2,d0.w),d1	; Load Y Offset
	add.b	d1,d5	; Offset Y Position
Print_2:
	tst.w	d6	; Check If Printing This Character
	bne.s	Print_3	; Branch If Not
	bsr	Blit	; BLIT the character
	bra.s	Print_4
Print_3:
	subq.w	#1,d6	; Decrement Starting Number
Print_4:
	clr.w	d3	; clear upper byte
	subq.w	#1,d7	; Decrement Counter
	bne.s	Print_0	; and keep printing
	bra.s	Print_E	; Exit If Done
Print_A:
	beq.s	Print_0	; if non-printable, continue
	bsr	CReturn	; otherwise, do a C/R
	bra.s	Print_1	; and keep printing
Print_B:
	beq.s	Print_E	; Branch If End
	cmp.b	#0xFF,d0	; Check If Palette Change
	beq.s	Print_P	; Branch If It Is

	clr.l	d0	; Clear D0 Register
	move.b	(a3)+,d0	; Load High Byte Of Address
	rol.l	#8,d0	; Shift To Upper Byte
	or.b	(a3)+,d0	; Load Next Byte Of Address
	rol.l	#8,d0	; Shift To Upper Byte
	or.b	(a3)+,d0	; Load Next Byte Of Address
	rol.l	#8,d0	; Shift To Upper Byte
	or.b	(a3)+,d0	; Load Next Byte Of Address

	move.l	d0,a0	; Move Address To A0
	move.b	(a3)+,d2	; Load Type Of Print
	beq.s	Print_C	; Branch If Print Hex
	clr.l	d0	; Clear D0
	move.b	(a0),d0	; Load Byte
	subq.b	#1,d2	; Check If Byte Print
	beq.s	Print_B1	; Branch If Byte Print
	move.w	(a0),d0	; Load Word
	ext.l	d0	; Extend To A Long
	subq.b	#1,d2	; Check If Word Print
	beq.s	Print_B1	; Branch If Word Print
	move.l	(a0),d0	; Load Long
Print_B1:
	move.b	(a3)+,d1	; Load Number Of Bytes
	or.b	(a3)+,d1	; Or In Justification Flags
	jsr	HexToDec	; Convert To Decimal
	bra.s	Print_D
Print_C:
	move.b	(a3)+,d0	; Load Number Of Bytes
	jsr	FormatHex	; Convert To Hex
Print_D:
	move.l	a3,SavePrint	; Save Current Printing Address
	move.l	#print_field,a3	; Load New String Address
	bra	Print_1	; Continue Printing

Print_E:
	move.l	SavePrint,a3	; Check If More Print Needed
	clr.l	SavePrint	; Clear Printing Address
	move.l	a3,d0	; Load Into A3
	bne	Print_1	; Continue Print If Needed
	IMAGES	temp_image	; otherwise NULL, restore image bank
	rts		; and exit
Print_P
	move.b	(a3)+,d0	; load character from string
	APALETTE	d0	; and set it up
	clr.w	d0	; clear upper byte
	clr.w	d3	; clear upper byte
	bra	Print_1	; keep printing

	.export	ProPrint
ProPrint:
	move.l	a0,a3	; use a0 for backward compatability
	andi.w	#Q_FLIPOFF&Q_FLOPOFF,QMode1 ; no flipping or flopping
	move.b	ImageBank,temp_image        ; save image bank
	IMAGES	font_offset	          ; set up font bank

	move.l	CharTrans,a4	; 255 byte translation table
	move.l	FontSpacing,a6	; Load Address oF Spacing Table
	bra.s	ProPrint_1	; initiate printing
ProPrint_0:
	move.w	font_width,d0	; add the font width
	add.w	d0,prx_coor	; to the current X coord
ProPrint_1:
	clr.w	d0	; clear upper byte
	move.b	(a3)+,d0	; load character from string
	ble.s	ProPrint_B	; if finished, or palette needs changing
	clr.w	d3
	move.b	(a4,d0.w),d3	; get actual char offset
	ble.s	ProPrint_A	; if non-printable
	move.b	(a6,d3.w),font_width+1 ; Save Character Width
	sub.b	font_start,d3	; subtract starting character number
	move.w	prx_coor,d4	; load X position
	move.w	pry_coor,d5	; load Y position

	move.l	FontAdjust,d0	; Load Font Adjust Address
	beq.s	ProPrint_2	; Branch If No Adjust Table
	move.l	d0,a2	; Move To A2
	move.w	d3,d0	; Load Character Numver To d0
	lsl.w	#1,d0	; Multiply By Two
	move.b	(a2,d0.w),d1	; Load X Offset
	ext.w	d1
	add.w	d1,d4	; Offset X Position
	move.b	1(a2,d0.w),d1	; Load Y Offset
	add.b	d1,d5	; Offset Y Position
ProPrint_2:
	tst.w	d6	; Check If Printing This Character
	bne.s	ProPrint_3	; Branch If Not
	bsr	Blit	; BLIT the character in question
	bra.s	ProPrint_4
ProPrint_3:
	subq.w	#1,d6	; Decrement Starting Number
ProPrint_4:
	clr.w	d3	; clear upper byte
	subq.w	#1,d7	; Decrement Counter
	bne.s	ProPrint_0	; and keep printing
	bra.s	ProPrint_E	; Exit If Done
ProPrint_A:
	beq.s	ProPrint_0	; if non-printable, continue
	bsr	CReturn	; otherwise, do a C/R
	bra.s	ProPrint_1	; and keep printing
ProPrint_B:
	beq.s	ProPrint_E	; Branch If End
	cmp.b	#0xFF,d0	; Check If Palette Change
	beq.s	ProPrint_P	; Branch If It Is

	clr.l	d0	; Clear D0 Register
	move.b	(a3)+,d0	; Load High Byte Of Address
	rol.l	#8,d0	; Shift To Upper Byte
	or.b	(a3)+,d0	; Load Next Byte Of Address
	rol.l	#8,d0	; Shift To Upper Byte
	or.b	(a3)+,d0	; Load Next Byte Of Address
	rol.l	#8,d0	; Shift To Upper Byte
	or.b	(a3)+,d0	; Load Next Byte Of Address

	move.l	d0,a0	; Move Address To A0
	move.b	(a3)+,d2	; Load Type Of Print
	beq.s	ProPrint_C	; Branch If Print Hex
	clr.l	d0	; Clear D0
	move.b	(a0),d0	; Load Byte
	subq.b	#1,d2	; Check If Byte Print
	beq.s	ProPrint_B1	; Branch If Byte Print
	move.w	(a0),d0	; Load Word
	ext.l	d0	; Extend To A Long
	subq.b	#1,d2	; Check If Word Print
	beq.s	ProPrint_B1	; Branch If Word Print
	move.l	(a0),d0	; Load Long
ProPrint_B1:
	move.b	(a3)+,d1	; Load Number Of Bytes
	or.b	(a3)+,d1	; Or In Justification Flags
	jsr	HexToDec	; Convert To Decimal
	bra.s	ProPrint_D
ProPrint_C:
	move.b	(a3)+,d0	; Load Number Of Bytes
	jsr	FormatHex	; Convert To Hex
ProPrint_D:
	move.l	a3,SavePrint	; Save Current Printing Address
	move.l	#print_field,a3	; Load New String Address
	bra	ProPrint_1	; Continue Printing

ProPrint_E:
	move.l	SavePrint,a3	; Check If More Print Needed
	clr.l	SavePrint	; Clear Printing Address
	move.l	a3,d0	; Load Into A3
	bne	ProPrint_1	; Continue Print If Needed
	IMAGES	temp_image	; otherwise NULL, restore image bank
	rts		; and exit
ProPrint_P
	move.b	(a3)+,d0	; load character from string
	APALETTE	d0	; and set it up
	bra	ProPrint_1	; keep printing


;***************************************************************************
;	BLIT - set up and start the blitter.		*
;	d3 = image number		*
;	d4 = X coord		*
;	d5 = Y coord		*
;				*
;	Uses:	a0-a2/d0-d5 (except d2)		*
;***************************************************************************
	.export	Blit
Blit:
	DOENABLE
	add.w	BlitY,d5	; add relative Y coord
	add.w	BlitX,d4	; add relative X coord

	add.w	CameraX,d4	; Set Camera Position
	add.w	CameraY,d5	; Set Camera Position

;obe
;	btst.b	#1,N_Plane+1	; check if plane A is enabled
;;old	btst.b    #5,N_PalSel+1	; Check If Plane A Is Enabled
;	bne.s     SetImage_4a	; Branch If Not

	tst.w	ScreenInvert2
	beq.s	SetImage_5

	move.w    #BOTSCR-1,d0
	sub.w     d5,d0
	move.w    d0,d5
	move.w    #RGTSCR-1,d0
	sub.w     d4,d0
	move.w    d0,d4
	bra.s     SetImage_5
SetImage_4a:
	tst.w     ScreenInvert2
	beq.s     SetImage_5
	
	move.w    #255,d0
	sub.w     d5,d0
	move.w    d0,d5
	move.w    #511,d0
	sub.w     d4,d0
	move.w    d0,d4
SetImage_5:

;from above
;	btst.b	#1,N_Plane+1	; check if plane A is enabled
;	bne.s	Bobe	; branch if not A
	add.w	PageLine,d5	; add current page to Y coord
Bobe
	move.l	bankaddress,a2	; image bank base address in bankaddress
	lsl.w	#1,d3	; convert image index to offset
	move.w	d3,d0
	lsl.w	#1,d3
	add.w	d0,d3	; Multiply By Six
	move.b	3(a2,d3.w),GROMSegment+1 ;GROM bank address

	addi.w	#VRAMCOL,d4	; locate the VRAM
	addi.w	#VRAMPAGE,d5

	move.w	#18,d1	; 18 bytes needed for blit command
	jsr	WaitQueSpace	; wait for queue space

	move.w	SR,-(sp)	; push status onto stack
	ori.w	#DIRQ,SR	; disable irqs

	INSERT	#BLITCMD	; blit command code, a0 = valid AsicQueIn

	move.w	Mode1,d1	; load user mode 1
	or.w	QMode1,d1
	or.w	ormode,d1	; set type of end-of-row calc
;	and.w	andmode,d1	; turn off clipping for plane C
	move.w	xormode,d0	; invert the appropriate flags for screen flop
	eor.w	d0,d1     
Blit_3:
	INSERT	d1	; insert mode register 1
	INSERT	GROMSegment	; insert GROM segment number

	clr.w	d0
	move.b	2(a2,d3.w),d0	; Load Blit Height
	bne.s	heightOK
	move.w	#701,d0	;445 FORCE HEIGHT OF TOP10NUM ART
heightOK
	move.w	d0,BlitHeight	; Save Blit Height
	INSERT	d0	; insert blit height
	move.w	0(a2,d3.w),d0	; Load Blit Width
	move.w	d0,BlitWidth	; Save Blit Width
	INSERT	d0	; insert blit width
	INSERT	<(4,a2,d3.w)>	; insert grom address

	tst.b	BlitFlip	; Check If Flipped
	beq.s	Blit_3B	; Branch If Not
	bmi.s	Blit_3A	; Branch If Flipped Flip

	add.w	BlitWidth,d4	; Move X Position Over

	bra.s	Blit_3B
Blit_3A:
	sub.w	BlitWidth,d4	; Move X Position Over
Blit_3B:
	tst.b	BlitFlop	; Check If Flopped
	beq.s	Blit_3C	; Branch If Not
	add.w	BlitHeight,d5	; Move Y Position Down
Blit_3C:
	clr.b	BlitFlip	; Clear Flags
	clr.b	BlitFlop	; Clear Flags

	INSERT	d4	; insert X position
	INSERT	d5	; insert Y position
	INSERT	BlitCommand	; insert state machine ID

	move.w	a0,AsicQueIn	; save queue pointer
	move	(sp)+,SR	; pull sr (must be in supervisor mode)

	clr.w	BlitX	; clear X offset for next blit
	clr.w	BlitY	; clear Y offset for next blit

	tst.b	AQStat	; check if queue is busy
	beq.s	Blit_4
	rts
Blit_4:
	bra	DoNextICmd	; no blit tasks - initiate this one.
	nop

;***************************************************************************
;	BatBLIT - custom blit for bat, uses scaled blitwidth and height
;	d3 = image number		*
;	d4 = X coord		*
;	d5 = Y coord		*
;				*
;	Uses:	a0-a2/d0-d5 (except d2)		*
;***************************************************************************
	.export	BatBlit
BatBlit:
	DOENABLE
	add.w	BlitY,d5	; add relative Y coord
	add.w	BlitX,d4	; add relative X coord

	add.w	CameraX,d4	; Set Camera Position
	add.w	CameraY,d5	; Set Camera Position

;obe
;	btst.b	#1,N_Plane+1	; check if plane A is enabled
;;old	btst.b    #5,N_PalSel+1	; Check If Plane A Is Enabled
;	bne.s     SetImage_4a	; Branch If Not

	tst.w	ScreenInvert2
	beq.s	BatSetImage_5

	move.w    #BOTSCR-1,d0
	sub.w     d5,d0
	move.w    d0,d5
	move.w    #RGTSCR-1,d0
	sub.w     d4,d0
	move.w    d0,d4
	bra.s     BatSetImage_5
BatSetImage_4a:
	tst.w     ScreenInvert2
	beq.s     BatSetImage_5
	
	move.w    #255,d0
	sub.w     d5,d0
	move.w    d0,d5
	move.w    #511,d0
	sub.w     d4,d0
	move.w    d0,d4
BatSetImage_5:

;from above
;	btst.b	#1,N_Plane+1	; check if plane A is enabled
;	bne.s	Bobe	; branch if not A
	add.w	PageLine,d5	; add current page to Y coord

	move.l	bankaddress,a2	; image bank base address in bankaddress
	lsl.w	#1,d3	; convert image index to offset
	move.w	d3,d0
	lsl.w	#1,d3
	add.w	d0,d3	; Multiply By Six
	move.b	3(a2,d3.w),GROMSegment+1 ;GROM bank address

	addi.w	#VRAMCOL,d4	; locate the VRAM
	addi.w	#VRAMPAGE,d5

	move.w	#18,d1	; 18 bytes needed for blit command
	jsr	WaitQueSpace	; wait for queue space

	move.w	SR,-(sp)	; push status onto stack
	ori.w	#DIRQ,SR	; disable irqs

	INSERT	#BLITCMD	; blit command code, a0 = valid AsicQueIn

	move.w	Mode1,d1	; load user mode 1
	or.w	QMode1,d1
	or.w	ormode,d1	; set type of end-of-row calc
;	and.w	andmode,d1	; turn off clipping for plane C
	move.w	xormode,d0	; invert the appropriate flags for screen flop
	eor.w	d0,d1     
BatBlit_3:
	INSERT	d1	; insert mode register 1
	INSERT	GROMSegment	; insert GROM segment number

	clr.w	d0
	move.b	2(a2,d3.w),d0	; Load Blit Height
	move.w	d0,BlitHeight	; Save Blit Height
	INSERT	d0	; insert blit height
	move.w	0(a2,d3.w),d0	; Load Blit Width
	move.w	d0,BlitWidth	; Save Blit Width
	INSERT	d0	; insert blit width
	INSERT	<(4,a2,d3.w)>	; insert grom address

;correct width & height for scaling
	move.w	BlitWidth,d0
	move.w	XScale,d1	; Load X Scale
	muls	d1,d0	; Multiply By Scale
	add.l	#255,d0	; Round Up
	asr.l	#8,d0	; Divide By 256
	move.w	d0,BlitWidth	; d0=scaled BlitWidth

	move.w	BlitHeight,d0
	move.w	YScale,d1	; Load X Scale
	muls	d1,d0	; Multiply By Scale
	add.l	#255,d0	; Round Up
	asr.l	#8,d0	; Divide By 256
	move.w	d0,BlitHeight	; d0=scaled BlitHeight
;


	tst.b	BlitFlip	; Check If Flipped
	beq.s	BatBlit_3B	; Branch If Not
	bmi.s	BatBlit_3A	; Branch If Flipped Flip

	add.w	BlitWidth,d4	; Move X Position Over

	bra.s	BatBlit_3B
BatBlit_3A:
	sub.w	BlitWidth,d4	; Move X Position Over
BatBlit_3B:
	tst.b	BlitFlop	; Check If Flopped
	beq.s	BatBlit_3C	; Branch If Not
	add.w	BlitHeight,d5	; Move Y Position Down
BatBlit_3C:
	clr.b	BlitFlip	; Clear Flags
	clr.b	BlitFlop	; Clear Flags

	INSERT	d4	; insert X position
	INSERT	d5	; insert Y position
	INSERT	BlitCommand	; insert state machine ID

	move.w	a0,AsicQueIn	; save queue pointer
	move	(sp)+,SR	; pull sr (must be in supervisor mode)

	clr.w	BlitX	; clear X offset for next blit
	clr.w	BlitY	; clear Y offset for next blit

	tst.b	AQStat	; check if queue is busy
	beq.s	BatBlit_4
	rts
BatBlit_4:
	bra	DoNextICmd	; no blit tasks - initiate this one.
	nop

;***************************************************************************
;	BLITDATA - set up and start the blitter.	*
;	d1 = Blit Width		*
;	d2 = Blit Height		*
;	d3 = GROM Address		*
;	d4 = X coord		*
;	d5 = Y coord		*
;				*
;	Uses:	a0-a2/d0-d5 (except d2)		*
;***************************************************************************
	.export	BlitData

BlitData:
	move.l	d3,GROMSegment	; Save GROM Address
	move.w	d1,BlitWidth	; Save Width
	move.w	d2,BlitHeight	; Save Height
	DOENABLE
	tst.w	ScreenInvert2	; Check If Screen Inverted
	beq.s	BlitData_1	; Branch If Not

	move.w    #BOTSCR-1,d0
	sub.w     d5,d0
	move.w    d0,d5
	move.w    #RGTSCR-1,d0
	sub.w     d4,d0
	move.w    d0,d4

BlitData_1:
	add.w	PageLine,d5	; add current page to Y coord

	addi.w	#VRAMCOL,d4	; locate the VRAM
	addi.w	#VRAMPAGE,d5

	move.w	#18,d1	; 18 bytes needed for blit command
	jsr	WaitQueSpace	; wait for queue space

	move.w	SR,-(sp)	; push status onto stack
	ori.w	#DIRQ,SR	; disable irqs

	INSERT	#BLITCMD	; blit command code, a0 = valid AsicQueIn

	move.w	Mode1,d1	; load user mode 1
	or.w	QMode1,d1
	or.w	ormode,d1	; set type of end-of-row calc
	move.w	xormode,d0	; invert the appropriate flags for screen flop
	eor.w	d0,d1     

	INSERT	d1	; insert mode register 1
	INSERT	GROMSegment	; insert GROM segment number
	INSERT	BlitHeight	; insert blit height
	INSERT	BlitWidth	; insert blit width
	INSERT	GROMSegment+2	; insert grom address

	INSERT	d4	; insert X position
	INSERT	d5	; insert Y position
	INSERT	BlitCommand	; insert state machine ID

	move.w	a0,AsicQueIn	; save queue pointer
	move	(sp)+,SR	; pull sr (must be in supervisor mode)

	tst.b	AQStat	; check if queue is busy
	beq.s	BlitData_2
	rts
BlitData_2:
	bra	DoNextICmd	; no blit tasks - initiate this one.
	nop

;****************************************************************
	.export	DoDisplay
DoDisplay:
	move.w	#4,d1	; 4 bytes needed for display command
	jsr	WaitQueSpace	; wait for queue space
	move	SR,-(sp)	; push status onto stack
	move.w	#DIRQ,SR	; disable IRQ
	INSERT	#DISPLAYCMD	; wait for VBLANK
	INSERT	d2	; this number of times
	move.w	a0,AsicQueIn	; save new queue input address
	move.b	#1,Timing_Flag	; indicate display put on queue
	move	(sp)+,SR	; must be in supervisor mode 
	jmp	DoNextCmd

;****************************************************************
	.export	DoToggle
DoToggle:
	move.w	#2,d1	; 2 bytes needed for toggle command
	jsr	WaitQueSpace	; wait for queue space
	move	SR,-(sp)	; push status onto stack
	move.w	#DIRQ,SR	; disable IRQ
	INSERT	#TOGGLECMD	; insert toggle page command
	move.w	a0,AsicQueIn	; save new queue input address
	eori.w	#$200,PageLine	; alternate current draw page
	move	(sp)+,SR	; must be in supervisor mode 
	jmp	DoNextCmd

;****************************************************************
	.import.s FrameCount
showit:
	jsr	SetSysFont	; pick a font to use
	APALETTE	#0	; and a palette
	PLOT	#25,#75	; and a screen locn
;	QUICKDEC	FrameCount,#1,RJUST ; show frame rate
;	QUICKDEC	dcount,#4,RJUST	  ; show number of blits
	clr.w	dcount	; clear number of blits
	rts

;***************************************************************************
;	TogglePage toggles visable and draw pages    	*
;***************************************************************************
	
TogglePage: 
	clr.w	BlitX	; Clear X Blitter Offset
	clr.w	BlitY	; Clear Y Blitter Offset
	
	#ifdef	SHOWSTATS
	bsr.s	showit	; Display Stats
	#endif

	
Toggle_0:
	btst.b	#6,DIPS	; Check If Pause On
	beq.s	Toggle_1	; Branch If Not
	DELAY	#1
	bra.s	Toggle_0
	
Toggle_1:
	tst.b	Timing_Flag	; Check If Togglepage Already Pending
	beq.s	Toggle_3	; If Not Branch
	clr.w	IdleLoop	; Clear Loop Count
Toggle_2:
	KICK_DOG
	addq.w	#1,IdleLoop	; Increment Loop Count
	DELAY	#0	; otherwise, we've gotten too far ahead
	tst.b	Timing_Flag	; so wait 'til current toggle is executed
	bne.s	Toggle_2	; if we have time, this will allow others to run often
Toggle_3:
	jsr	DoToggle	; onto the queue, put toggle page
	jsr	DoClrDraw	; also, clear draw page
	move.w	FrameRate,d2	; get the frame rate desired,
	jsr	DoDisplay	; and put that on the queue as well
	tst.w	FrameRate	; if framerare is zero,
	beq.s	Toggle_5	; do a token DELAY because we're short on time
Toggle_4:
	DELAY	#1	; old method, wait for toggle page to take
	tst.b	Timing_Flag	; effect before we're allowed to run
	bne.s	Toggle_4	; any more of the game.
	move.l	#-1,S_PalSel
	rts
Toggle_5:
	DELAY	#0	; short on time: token delay.
	nop
	nop
	nop
	nop
	nop
	move.l	#-1,S_PalSel
	rts		; if time available Toggle_2 will eat it up.

	.comment
TogglePage: 
	clr.w	BlitX	; Clear X Blitter Offset
	clr.w	BlitY	; Clear Y Blitter Offset
Toggle_1:
	DELAY	#0	; Let The Muti-tasker Run
	tst.b	Timing_Flag	; Check If Done Waiting
	bne.s	Toggle_1	; Branch If Not
	jsr	DoToggle	; Toggle The Pages
	jsr	DoClrDraw	; Clear The Current Screen
	move.l	#-1,S_PalSel
	move.w	#1,d2
	jsr	DoDisplay	#1	; Display The New Screen
	rts
	.endcomment


;***************************************************************************
	.export	DoClrDraw
DoClrDraw:
;	movem.w	d2,-(sp)	; save d2 on stack
;	DOENABLE
;	movem.w	(sp)+,d2	; retrieve d2 from stack

	move.w	#2,d1	; 2 bytes needed for dclear command
	jsr	WaitQueSpace	; wait for queue space
	move	SR,-(sp)	; push status onto stack
	move.w	#DIRQ,SR	; disable iRQ
	INSERT	#DCLEARCMD	; insert clear drawpage command
	move.w	a0,AsicQueIn	; save new queue input address
	move	(sp)+,SR	; must be in supervisor mode 
	jmp	DoNextCmd

;***************************************************************************
; WaitQueSpace - Wait For Enough Queue Space	*
; Parameters :  D1 - Number Of Bytes Required	*
; Uses: a0-a1/d0-d1			*
;***************************************************************************
	.export	WaitQueSpace
WaitQueSpace:
	addq.w	#4,d1	; leave extra space between in and out
	move.w	AsicQueIn,a0	; get the address of queue in pointer
			  
	lea	(a0,d1.w),a1	; will this cause a queue overflow?
	cmp.w	#QEND,a1
	blt.s	wq2	; no, so branch
wq0
	cmp.w	AsicQueOut,a0	; check queue output
	blt.s	wq0	; if between here and end, wait
	clr.w	d0
wq1
	move.w	d0,(a0)+	; pad the queue with NOPs
	cmp.w	#QEND,a0
	blt.s	wq1	; until it's filled to the end
	movea.w	#ASICQueue,a0	; then reset to beginning
wq2
	move.w	AsicQueOut,d0
	sub.w	a0,d0	; d0 = out - in = available space
	bgt.s	wq3	; if posative, and non-zero, check if room
wq4	
	rts		; if negative, all is OK
wq3
	cmp.w	d0,d1	; compare avail to needed
	bge.s	wq2	; if needed is more, loop back
	rts		  

	.export	char_trans
char_trans:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0                ;* 0-15    */
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	            ;* 16-31   */
;                            !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
	dc.b	00,42,44,00,00,00,37,38,00,00,00,00,40,00,41,00  ;* 32-47   */
;                            0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
	dc.b	01,02,03,04,05,06,07,08,09,10,39,00,43,00,46,45 ;* 48-63   */
;                         @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
	dc.b	00,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 64-79   */
;		P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
	dc.b	26,27,28,29,30,31,32,33,34,35,36,00,00,00,00,00 ;* 80-95   */
;                         a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
	dc.b	00,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 96-111  */
;                         p  q  r  s  t  u  v  w  x  y  z
	dc.b	26,27,28,29,30,31,32,33,34,35,36,00,00,00,00,00 ;* 112-127 */

	.export	SysCharTrans
SysCharTrans:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0                ;* 0-15    */
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	            ;* 16-31   */
;                  !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
	dc.b	00,64,65,63,62,61,38,39,57,58,59,54,41,55,40,47  ;* 32-47   */
;                0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
	dc.b	01,02,03,04,05,06,07,08,09,10,42,43,44,53,45,46 ;* 48-63   */
;                @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
	dc.b	37,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 64-79   */
;		P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
	dc.b	26,27,28,29,30,31,32,33,34,35,36,50,52,51,00,56 ;* 80-95   */
;                            a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
;	dc.b	00,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51 ;* 96-111  */
;                p  q  r  s  t  u  v  w  x  y  z  {  }
;	dc.b	52,53,54,55,56,57,58,59,63,64,65,48,49,60,66,00 ;* 112-127 */

	dc.b	00,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 96-111  */
;                         p  q  r  s  t  u  v  w  x  y  z  {  }
	dc.b	26,27,28,29,30,31,32,33,34,35,36,48,49,60,66,00 ;* 112-127 */

	ds	0

	.export	MedCharTrans
MedCharTrans:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0                ;* 0-15    */
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	            ;* 16-31   */
;                  !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
	dc.b	00,37,00,00,00,00,00,43,00,00,00,00,39,41,38,42  ;* 32-47   */
;                0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
	dc.b	01,02,03,04,05,06,07,08,09,10,00,00,00,00,00,40 ;* 48-63   */
;                @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
	dc.b	37,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 64-79   */
;		 P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
	dc.b	26,27,28,29,30,31,32,33,34,35,36,00,00,00,00,00 ;* 80-95   */
;                a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
	dc.b	00,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 96-111  */
;                p  q  r  s  t  u  v  w  x  y  z  {  }
	dc.b	26,27,28,29,30,31,32,33,34,35,36,00,00,00,00,00 ;* 112-127 */

	ds	0

	.export	SmallAdjust
SmallAdjust:
	dc.b	0,0	; 00 - Space
	dc.b	0,0	; 01 - 0
	dc.b	1,0	; 02 - 1
	dc.b	0,0	; 03 - 2
	dc.b	0,0	; 04 - 3
	dc.b	0,0	; 05 - 4
	dc.b	0,0	; 06 - 5
	dc.b	0,0	; 07 - 6
	dc.b	0,0	; 08 - 7
	dc.b	0,0	; 09 - 8
	dc.b	0,0	; 10 - 9
	dc.b	0,0	; 11 - A
	dc.b	0,0	; 12 - B
	dc.b	0,0	; 13 - C
	dc.b	0,0	; 14 - D
	dc.b	0,0	; 15 - E
	dc.b	0,0	; 16 - F
	dc.b	0,0	; 17 - G
	dc.b	0,0	; 18 - H
	dc.b	0,0	; 19 - I
	dc.b	0,0	; 20 - J
	dc.b	0,0	; 21 - K
	dc.b	0,0	; 22 - L
	dc.b	0,0	; 23 - M
	dc.b	0,0	; 24 - N
	dc.b	0,0	; 25 - O
	dc.b	0,0	; 26 - P
	dc.b	0,0	; 27 - Q
	dc.b	0,0	; 28 - R
	dc.b	0,0	; 29 - S
	dc.b	0,0	; 30 - T
	dc.b	0,0	; 31 - U
	dc.b	0,0	; 32 - V
	dc.b	0,0	; 33 - W
	dc.b	0,0	; 34 - X
	dc.b	0,0	; 35 - Y
	dc.b	0,0	; 36 - Z
	dc.b	1,2	; 37 - @
	dc.b	0,0	; 38 - '
	dc.b	1,0	; 39 - '
	dc.b	1,3	; 40 - ,
	dc.b	1,3	; 41 - .
	dc.b	1,0	; 42 - !
	dc.b	0,0	; 43 - <
	dc.b	0,0	; 44 - $
	dc.b	1,0	; 45 - ?
	dc.b	0,0	; 46 - >
	dc.b	0,0	; 47
	dc.b	0,0	; 48
	dc.b	0,0	; 49
	dc.b	0,0	; 50
	dc.b	0,0	; 51
	dc.b	1,0	; 52
	dc.b	0,0	; 53 eq
	dc.b	0,0	; 54
	dc.b	0,2	; 55 mi
	dc.b	0,4	; 56
	dc.b	0,0	; 57
	dc.b	0,0	; 58
	dc.b	0,0	; 59
	dc.b	0,0	; 60
	dc.b	0,0	; 61
	dc.b	0,0	; 62
	dc.b	1,0	; 63
	dc.b	1,0	; 64 !
	dc.b	0,0	; 65
	dc.b	0,0	; 66


	.export	Font2Adjust
Font2Adjust:
	dc.b	0,0	; 00 - Space
	dc.b	0,0	; 01 - 0
	dc.b	0,0 	; 02 - 1
	dc.b	0,0	; 03 - 2
	dc.b	0,0	; 04 - 3
	dc.b	0,0	; 05 - 4
	dc.b	0,0	; 06 - 5
	dc.b	0,0	; 07 - 6
	dc.b	0,0	; 08 - 7
	dc.b	0,0	; 09 - 8
	dc.b	0,0	; 10 - 9
	dc.b	0,0	; 11 - A
	dc.b	0,0	; 12 - B
	dc.b	0,0	; 13 - C
	dc.b	0,0	; 14 - D
	dc.b	0,0	; 15 - E
	dc.b	0,0	; 16 - F
	dc.b	0,0	; 17 - G
	dc.b	0,0	; 18 - H
	dc.b	0,0	; 19 - I
	dc.b	0,0	; 20 - J
	dc.b	0,0	; 21 - K
	dc.b	0,0	; 22 - L
	dc.b	0,0	; 23 - M
	dc.b	0,0	; 24 - N
	dc.b	0,0	; 25 - O
	dc.b	0,0	; 26 - P
	dc.b	0,0	; 27 - Q
	dc.b	0,0	; 28 - R
	dc.b	0,0	; 29 - S
	dc.b	0,0	; 30 - T
	dc.b	0,0	; 31 - U
	dc.b	0,0	; 32 - V
	dc.b	0,0	; 33 - W
	dc.b	0,0	; 34 - X
	dc.b	0,0	; 35 - Y
	dc.b	0,0	; 36 - Z
	dc.b	0,0	; 37 - !
	dc.b	0,0	; 38 - .
	dc.b	0,0	; 39 - ,
	dc.b	0,0	; 40 - ?
	dc.b	0,0	; 41 - -
	dc.b	0,0	; 42 - /
	dc.b	0,0	; 43 - '

	.export	Font2Spacing
Font2Spacing:
	dc.b	7	; 00 - Space
	dc.b	13	; 01 - 0
	dc.b	10 	; 02 - 1
	dc.b	13	; 03 - 2
	dc.b	14	; 04 - 3
	dc.b	13	; 05 - 4
	dc.b	14	; 06 - 5
	dc.b	13	; 07 - 6
	dc.b	13	; 08 - 7
	dc.b	13	; 09 - 8
	dc.b	13	; 10 - 9
	dc.b	13	; 11 - A
	dc.b	14	; 12 - B
	dc.b	13	; 13 - C
	dc.b	13	; 14 - D
	dc.b	12	; 15 - E
	dc.b	13	; 16 - F
	dc.b	13	; 17 - G
	dc.b	13	; 18 - H
	dc.b	7 	; 19 - I
	dc.b	13	; 20 - J
	dc.b	14	; 21 - K
	dc.b	13	; 22 - L
	dc.b	15	; 23 - M
	dc.b	13	; 24 - N
	dc.b	13	; 25 - O
	dc.b	14	; 26 - P
	dc.b	14	; 27 - Q
	dc.b	14	; 28 - R
	dc.b	13	; 29 - S
	dc.b	13	; 30 - T
	dc.b	13	; 31 - U
	dc.b	13	; 32 - V
	dc.b	15	; 33 - W
	dc.b	13	; 34 - X
	dc.b	13	; 35 - Y
	dc.b	13	; 36 - Z
	dc.b	7 	; 37 - !
	dc.b	13	; 38 - ?
	dc.b	7 	; 39 - .
	dc.b	9 	; 40 - -



;obe

	.export	mCharTrans
mCharTrans:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0                ;* 0-15    */
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	            ;* 16-31   */
;		!  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
	dc.b	00,64,65,63,62,61,39,55,57,58,59,54,41,49,53,47  ;* 32-47   */
;		0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
	dc.b	01,02,03,04,05,06,07,08,09,10,42,43,44,53,45,46 ;* 48-63   */
;		@  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
	dc.b	37,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 64-79   */
;		P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
	dc.b	26,27,28,29,30,31,32,33,34,35,36,50,52,51,00,56 ;* 80-95   */
;                            a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
;	dc.b	00,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51 ;* 96-111  */
;                p  q  r  s  t  u  v  w  x  y  z  {  }
;	dc.b	52,53,54,55,56,57,58,59,63,64,65,48,49,60,66,00 ;* 112-127 */

	dc.b	00,38,46,13,14,15,16,17,18,19,20,21,22,23,24,25 ;* 96-111  */
;                         p  q  r  s  t  u  v  w  x  y  z  {  }
	dc.b	26,27,28,29,30,31,32,33,34,35,36,48,49,60,66,00 ;* 112-127 */

	ds	0

	.export	FontmAdjust
FontmAdjust:
	dc.b	0,0	; 00 - Space
	dc.b	0,0	; 01 - 0
	dc.b	0,0 	; 02 - 1
	dc.b	0,0	; 03 - 2
	dc.b	0,0	; 04 - 3
	dc.b	0,0	; 05 - 4
	dc.b	0,0	; 06 - 5
	dc.b	0,0	; 07 - 6
	dc.b	0,0	; 08 - 7
	dc.b	0,0	; 09 - 8
	dc.b	0,0	; 10 - 9
	dc.b	0,0	; 11 - A
	dc.b	0,0	; 12 - B
	dc.b	0,0	; 13 - C
	dc.b	0,0	; 14 - D
	dc.b	0,0	; 15 - E
	dc.b	0,0	; 16 - F
	dc.b	0,0	; 17 - G
	dc.b	0,0	; 18 - H
	dc.b	0,0	; 19 - I
	dc.b	0,0	; 20 - J
	dc.b	0,0	; 21 - K
	dc.b	0,0	; 22 - L
	dc.b	0,0	; 23 - M
	dc.b	0,0	; 24 - N
	dc.b	0,0	; 25 - O
	dc.b	0,0	; 26 - P
	dc.b	0,0	; 27 - Q
	dc.b	0,0	; 28 - R
	dc.b	0,0	; 29 - S
	dc.b	0,0	; 30 - T
	dc.b	0,0	; 31 - U
	dc.b	0,0	; 32 - V
	dc.b	0,0	; 33 - W
	dc.b	0,0	; 34 - X
	dc.b	0,0	; 35 - Y
	dc.b	0,0	; 36 - Z
	dc.b	0,0	; 37 - !
	dc.b	0,0	; 38 - .
	dc.b	0,0	; 39 - ,
	dc.b	0,0	; 40 - ?
	dc.b	0,0	; 41 - -
	dc.b	0,0	; 42 - /
	dc.b	0,0	; 43 - '

	dc.b	0,0	; 44
	dc.b	0,0	; 45
	dc.b	0,0	; 46
	dc.b	0,0	; 47
	dc.b	0,0	; 48
	dc.b	0,3	; 49
	dc.b	0,0	; 50
	dc.b	0,0	; 51
	dc.b	0,0	; 52
	dc.b	0,6	; 53
	dc.b	0,0	; 54
	dc.b	0,0	; 55
	dc.b	0,0	; 56
	dc.b	0,0	; 57
	dc.b	0,0	; 58
	dc.b	0,0	; 59
	dc.b	0,0	; 60

	.export	FontmSpacing
FontmSpacing:
	dc.b	5	; 00 - Space
	dc.b	8	; 01 - 0
	dc.b	7 	; 02 - 1
	dc.b	8	; 03 - 2
	dc.b	8	; 04 - 3
	dc.b	8	; 05 - 4
	dc.b	8	; 06 - 5
	dc.b	8	; 07 - 6
	dc.b	8	; 08 - 7
	dc.b	8	; 09 - 8
	dc.b	8	; 10 - 9
	dc.b	8	; 11 - A
	dc.b	8	; 12 - B
	dc.b	8	; 13 - C
	dc.b	8	; 14 - D
	dc.b	8	; 15 - E
	dc.b	8	; 16 - F
	dc.b	8	; 17 - G
	dc.b	8	; 18 - H
	dc.b	4 	; 19 - I
	dc.b	8	; 20 - J
	dc.b	8	; 21 - K
	dc.b	7	; 22 - L
	dc.b	12	; 23 - M
	dc.b	9	; 24 - N
	dc.b	9	; 25 - O
	dc.b	8	; 26 - P
	dc.b	9	; 27 - Q
	dc.b	8	; 28 - R
	dc.b	8	; 29 - S
	dc.b	8	; 30 - T
	dc.b	8	; 31 - U
	dc.b	9	; 32 - V
	dc.b	13	; 33 - W
	dc.b	9	; 34 - X
	dc.b	8	; 35 - Y
	dc.b	8	; 36 - Z
	dc.b	8	; 37 - !
	dc.b	8	; 38 - ?
	dc.b	8 	; 39 - .
	dc.b	8 	; 40 - -

	dc.b	8	; 41
	dc.b	8	; 42
	dc.b	8	; 43
	dc.b	8	; 44
	dc.b	8	; 45
	dc.b	8	; 46
	dc.b	8	; 47
	dc.b	8	; 48
	dc.b	8	; 49
	dc.b	8	; 50
	dc.b	8	; 51
	dc.b	8	; 52
	dc.b	4	; 53
	dc.b	8	; 54
	dc.b	4	; 55
	dc.b	8	; 56
	dc.b	8	; 57
	dc.b	8	; 58
	dc.b	8 	; 59
	dc.b	8 	; 60

	.export	FontmSpacing2
FontmSpacing2:
	dc.b	5	; 00 - Space
	dc.b	8	; 01 - 0
	dc.b	7 	; 02 - 1
	dc.b	8	; 03 - 2
	dc.b	8	; 04 - 3
	dc.b	8	; 05 - 4
	dc.b	8	; 06 - 5
	dc.b	8	; 07 - 6
	dc.b	8	; 08 - 7
	dc.b	8	; 09 - 8
	dc.b	8	; 10 - 9
	dc.b	7	; 11 - A
	dc.b	7	; 12 - B
	dc.b	7	; 13 - C
	dc.b	7	; 14 - D
	dc.b	7	; 15 - E
	dc.b	7	; 16 - F
	dc.b	7	; 17 - G
	dc.b	7	; 18 - H
	dc.b	4 	; 19 - I
	dc.b	7	; 20 - J
	dc.b	7	; 21 - K
	dc.b	7	; 22 - L
	dc.b	12	; 23 - M
	dc.b	9	; 24 - N
	dc.b	8	; 25 - O
	dc.b	7	; 26 - P
	dc.b	9	; 27 - Q
	dc.b	7	; 28 - R
	dc.b	7	; 29 - S
	dc.b	7	; 30 - T
	dc.b	7	; 31 - U
	dc.b	9	; 32 - V
	dc.b	13	; 33 - W
	dc.b	9	; 34 - X
	dc.b	7	; 35 - Y
	dc.b	7	; 36 - Z
	dc.b	8	; 37 - !
	dc.b	8	; 38 - ?
	dc.b	8 	; 39 - .
	dc.b	8 	; 40 - -

	dc.b	8	; 41
	dc.b	8	; 42
	dc.b	8	; 43
	dc.b	8	; 44
	dc.b	8	; 45
	dc.b	8	; 46
	dc.b	8	; 47
	dc.b	8	; 48
	dc.b	8	; 49
	dc.b	8	; 50
	dc.b	8	; 51
	dc.b	8	; 52
	dc.b	4	; 53
	dc.b	8	; 54
	dc.b	4	; 55
	dc.b	8	; 56
	dc.b	8	; 57
	dc.b	8	; 58
	dc.b	8 	; 59
	dc.b	8 	; 60



	.align	2

;***************************************************************************
;   ClrLines - Clear Screen Lines 255 And 511 For Use In Clear Screen	*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:			*
;      Registers - d0		*
;      Memory    - None		*
;***************************************************************************
	.export	ClrLines
ClrLines:
;	move.w	#0x0,PLANE	; Enable All Planes
	move.w	#0xFF,PALSELA+2
	move.w	#0xFF,PALSELB+2
	move.w	#$100,d0	; Load $100 Into D0
	move.w	d0,A_VSCALE	; Initialize Vertical Scale Register
	move.w	d0,A_HSCALE	; Initialize Horiz. Scale Register
	move.w	d0,A_ROWDY	; Initialize Row DY Register
	move.w	#0,A_PIXDX	; Initialize Pixel DX Register
	move.w	#0,A_PIXDY	; Initialize Pixel DY Register
	move.w	#0,A_ROWDX	; Initialize Row DX Register
	move.w	#0,A_TOPCLIP	; Upper clip value
	move.w	#BOTSCR,A_BOTCLIP	; Lower clip value
	move.w	#0,A_LEFTCLIP	; Left clip value
	move.w	#RGTSCR,A_RGHTCLIP	; Right clip value

	jsr	jclear2

	move.w	#5,A_STATE
	move.w	#5,last_cmd
	rts

;***************************************************************************
jclear2:
	clr.b	rotate_flag
	move.w	#0,A_STARTX	; Set Column To Zero
	move.w	#1,A_HEIGHT	; Set Height To One Line
	move.w	#SCR_WIDTH,A_WIDTH ; Set Width To Screen Width
	move.w	#255,A_STARTY	; Set Line To 255

	move.w	#HOSTWRITE,A_STATE ; Set Up For Host Write
	move.w	#HOSTWRITE,last_cmd
	move.w	#SCR_WIDTH-1,d0	; Load Screen Width
	KICK_DOG
Clr255_2:
	move.w	#255,A_USERREG	  ; Write Value To VRAM
	dbf	d0,Clr255_2	; Branch If More

	move.w	#0,A_STARTX	; Set Column To Zero
	move.w	#1,A_HEIGHT	; Set Height To One Line
	move.w	#SCR_WIDTH,A_WIDTH ; Set Width To Screen Width
	move.w	#511,A_STARTY	; Set Line To 511

	move.w	#HOSTWRITE,A_STATE ; Set Up For Host Write
	move.w	#HOSTWRITE,last_cmd
	move.w	#SCR_WIDTH-1,d0	; Load Screen Width
	KICK_DOG
Clr511_2:
	move.w	#255,A_USERREG	  ; Write Value To VRAM
	dbf	d0,Clr511_2	; Branch If More

	rts

;****************************************************************************
	.export	QuickHex
QuickHex:
	clr.l	d2
	move.l	#$30303030,print_field
	clr.b	print_field+5
;ones
	move.w	d0,d2
	beq	qdone
	divu	#10,d2
	clr.w	d2
	swap	d2
	sub.w	d2,d0
	add.b	#$30,d2
	move.b	d2,print_field+4	;1's = 10's remainder
;tens
	move.w	d0,d2	;d2.l = d0.w
	beq.s	qdone	;if finished, leave now
	divu	#100,d2	;divide
	clr.w	d2	;clear out bits 16-31 for next time
	swap	d2	;get remainder
	sub.w	d2,d0	;adjust d0 for next time
	lsr.w	#3,d2	;make table index
	move.l	#tens_field,a0	;into ascii digit table
	move.b	(a0,d2.w),print_field+3 ;10's = 100's remainder
;hundreds
	move.w	d0,d2
	beq.s	qdone
	divu	#1000,d2
	clr.w	d2
	swap	d2
	sub.w	d2,d0
	lsr.w	#6,d2
	move.l	#hund_field,a0
	move.b	(a0,d2.w),print_field+2 ;100's = 1000's remainder
;thousands
	move.w	d0,d2
	beq.s	qdone
	divu	#10000,d2
	clr.w	d2
	swap	d2
	sub.w	d2,d0
	lsr.w	#4,d2
	lsr.w	#5,d2
	move.l	#thou_field,a0
	move.b	(a0,d2.w),print_field+1 ;1000's = 10000's remainder
;ten-thousands
	tst.w	d0
	beq.s	qdone
	lsr.w	#6,d0
	lsr.w	#7,d0
	move.l	#tthou_field,a0
	move.b	(a0,d0.w),print_field
qdone
	move.w	d1,d0	;get number of char to print
	andi.w	#$0f,d0	;and mask off just info
	move.w	#5,a3	;subtract the number from 5
	suba.w	d0,a3	;and use it as an offset
	adda.w	#print_field,a3	;into print_field

	andi.b	#$c0,d1	;get justification flags
	bmi.s	qrts	;if pad w/ 0, exit now
	beq.s	qleft	;if left just, eat up 0's
qright
	move.l	a3,a1	;right justify
qrightlp	move.b	(a1)+,d1	;get next char
	beq.s	qrts	;if done, exit
	cmpi.b	#$30,d1	;is it a '0' ?
	bne.s	qrts	;no, so we're done
	move.b	#$20,(-1,a1)	;yes, so replace it w/ a space
	bra.s	qrightlp	;and keep checking
qleft
	move.b	(a3)+,d1	;left just - get the next char
	beq.s	qldone2	;if at end, back off 2 chars
	cmpi.b	#$30,d1	;is it a zero ?
	bne.s	qleft	;yes, so keep looking
qldone	lea	(-1,a3),a3	;back off 1 character
qrts	jmp	QPrint	;print the string
qldone2	lea	(-2,a3),a0	;back off 2 chars
	jmp	QPrint	;print the string


tens_field dc.b	"0123X4567X89"
hund_field dc.b	"01X23X45X67X8X9"
thou_field dc.b	"01X2X3X4X5X6X7X8X9"
tthou_field dc.b	"012345X6"
	ds	0
;****************************************************************************
	.export	DoEnable,DoEnable2
DoEnable:
	move.l	N_PalSel,d0
	cmp.l	S_PalSel,d0	;compare with current
	beq.s	DoEnable_1	;branch if already there
DoEnable2:
	move.w	#8,d1	;10 bytes needed for enable command
	jsr	WaitQueSpace	;wait for queue space
	move.w	SR,-(sp)	;push status onto stack
	ori.w	#DIRQ,SR	;disable irq
	move.l	N_PalSel,S_PalSel
;	move.w	N_Plane,S_Plane
	INSERT	#WAITCMD	;insert command into queue
	INSERT	#ENABLECMD	;insert command into queue
	INSERT	N_PalSel+2	;insert palette data in queue
	INSERT	N_PalSel	;insert palette data in queue
;	INSERT	N_Plane         ;insert plane data in queue
	move.w	a0,AsicQueIn	;save new queue input address
	move.w	(sp)+,SR	;pull (must be in supervisor mode)
DoEnable_1:
	rts

;***************************************************************************
	.export	NewPlane
NewPlane:
	clr.w	xormode
	tst.w	ScreenInvert2	;if screen is upside-down
	beq.s	newp_1
	move.w	#$36,xormode	;invert the appropriate flags
newp_1
;	btst.b	#1,N_Plane+1	;check if plane A is enabled
;	beq.s	newp_2	;branch if it is
;	move.w	#$fbff,andmode	;plane C = no clipping
;	move.w	N_Plane,d0
;	cmp.w	S_Plane,d0	;compare with current
;	bne.s	DoEnable2	;branch if already there
;	rts
;newp_2
	move.w	#$ffff,andmode	;plane A = don't mess w/ stuff
	move.l	N_PalSel,d0
	cmp.l	S_PalSel,d0	;compare with current
	bne.s	DoEnable2	;branch if already there
	rts

;***************************************************************************
	.export	NewImageBank
NewImageBank:
	move.b	d0,ImageBank
	andi.w	#$ff,d0
	lsl.w	#2,d0	;X4 for pointerlist

	move.l	#DotTable,a2	;add to start of pointer table
	move.l	(a2,d0.w),dotaddress	;get address of this banks image data

	move.l	#BaseTable,a1	;add to start of pointer table
	move.l	(a1,d0.w),a1	;get address of this banks image data
	move.l	a1,bankaddress	;and save for later blits

	lsr.w	#2,d0	; Make Into A Byte Index
	move.w	d0,sav_ptr	; save d0
;	move.l	#BaseAddress,a1	;get Bank bondries pointer 
;	move.b	-1(a1,d0.w),d0
;	cmp.b	bankswitch,d0	; check to see if it needs switching
;	beq.s	doneswitchbank	; mask check
;	move.b	d0,bankswitch
;	cmp.b	#1,d0	;
;	beq.s	switch_1
;	cmp.b	#2,d0	; slop art
;	beq.s	switch_2
;switch_0:
;	BANKSW	#B_SET0                    	;#0x0
;	bra.s	doneswitchbank
;switch_1:
;	BANKSW	#B_SET1                    	;#0x4000 
;	bra.s	doneswitchbank
;switch_2:
;	BANKSW	#B_SET2                    	;#0x8000
doneswitchbank:
	move.w	sav_ptr,d0	; save d0
	move.l	#BaseFlags,a1	;add to start of pointer table
	move.b	-1(a1,d0.w),d0	;assume compression same for all items in this bank
	btst.b	#0,d0	;test compression bit
	beq.s	newb_noncomp	;and branch accordingly
newb_comp
	move.w	#$8000,ormode	;EOR calc based on compression
	move.w	#$02,BlitCommand	;save the blit command for quick retrieval
	rts
newb_noncomp
	clr.w	ormode	;EOR calc based on non-compressed
	move.w	#$01,BlitCommand	;save the blit command for quick retrieval
newb_not
	rts

;***************************************************************************
;  GetAnchor - Get the anchor point for an image		*
;				*
;  d0.w - Image number			*
;  a0.l - dotaddress (base dot address for this image bank)	*
;***************************************************************************
	.export	GetAnchor
GetAnchor:
	lsl.w	#2,d0	;convert image index to offset
	move.w	(a0,d0.w),d1	;get X anchor point
	btst.b	#1,QMode1+1	;check to see if image is flipped
	bne.s	GetAnchor_1	;if it is, OK
	neg.w	d1	;otherwise, negate to compensate
GetAnchor_1:
	move.w	d1,BlitX	;store to use as a blit offset
	move.w	(2,a0,d0.w),d1	;get Y anchor point
	btst.b	#2,QMode1+1	;check to see if it's flopped
	bne.s	GetAnchor_2	;if it is, OK
	neg.w	d1	;otherwise, negate to compensate
GetAnchor_2:
	move.w	d1,BlitY	;save as a blit offset
	rts

;***************************************************************************
; GetScreen - Get the screen coordinate for an object	*
;				*
; d0.w - Image number		*
; a0.l - dotaddress (base dot address for this image bank)	*
;***************************************************************************
	.export	GetScreen
GetScreen:
	lsl.w	#2,d0	;convert image index to offset
	move.w	(a0,d0.w),BlitX	;get X screen coord
	move.w	(2,a0,d0.w),BlitY ;get Y screen coord
	rts

	.export	make_normal
make_normal:
	move.w	#0000000000000000B,Mode1           ;Turn off rotation
	andi.w	#1111111111110111B,QMode1	;in both mode 
	ISCALE	#$100,#$100
	DXDY	#0,#0,#0,#$100
	rts

;****************************************************************
;   LoadPalette - Load A Color Palette for Frame Load Mode      *
;				     *
;   Parameters :			     *
;	 a0.l - Pointer To Color Data	     *
;	 d0.w - Starting Color Number	     *
;	 d1.w - Number of colors being loaded	     *
;	 d2.w - Color Palette Number	     *
;				     *
;   Returns:			     *
;	 NONE			     *
;				     *
;   Modifies:			     *
;      Registers - a0,d0,d1		     *
;      Memory    - None		     *
;****************************************************************
	.export	LoadPalette_per
LoadPalette_per:
	move.l	a0,(a1,d2.w*4)
	and.l	#0ffffh,d2	;
	asl.w	#8,d2	; Multiply Palette Number By 256
	add.w	d0,d2	; Add Starting Color Number
	asl.l	#2,d2	;mult by 4 bytes per color
	move.l	#PALETTES,a1	; Load Address Of Palettes
	lea	(a1,d2.l),a1	; Pointer To Desired Color Palette

	subq.w	#1,d1	; decrement the color number
LoadPal_1_per:

LoadPalBlue:
	clr.w	d2
	move.b	(a0),d2	; Load Blue Color
	tst.w	d4
	beq.s	LoadPalB_1
	mulu.w	d3,d2
	asr.l	#8,d2
LoadPalB_1:
	move.b	d2,d0
	asl.l	#8,d0	; Shift Into Upper Byte

LoadPalRed:
	clr.w	d2
	move.b	1(a0),d2	; Load Red Color
	tst.w	d5
	beq.s	LoadPalR_1
	mulu.w	d3,d2
	asr.l	#8,d2
LoadPalR_1:
	or.b	d2,d0	; Load Red Color
	asl.l	#8,d0	; Shift Into Upper Byte
          
LoadPalGreen:
	clr.w	d2
	move.b	2(a0),d2	; Load Green Color
	tst.w	d6
	beq.s	LoadPalG_1
	mulu.w	d3,d2
	asr.l	#8,d2
LoadPalG_1:
	or.b	d2,d0	; Load Green Color

	lea	3(a0),a0	;
	move.l	d0,(a1)+	; Write Green\Red To Color Palette
	dbf	d1,LoadPal_1_per	; Loop Until Done
no_load_pal_per:
	rts


	.region	"RomCode"
	.export	DotTable


Misc:
	dc.w	0x000D,0x000A	;0= dust0001 spfx
	dc.w	0x0014,0x0011	;1 = dust0002 spfx
	dc.w	0x0015,0x0014	;2 = dust0003 spfx
	dc.w	0x0015,0x0019	;3 = dust0004 spfx
	dc.w	0x0021,0x0023	;4 = dust0005 spfx
	dc.w	0x0024,0x001E	;5 = dust0006 spfx
	dc.w	0x0023,0x0020	;6 = dust0007 spfx
	dc.w	0x0023,0x0024	;7 = dust0008 spfx
	dc.w	0x0021,0x0026	;8 = dust0009 spfx
	dc.w	0x001C,0x002F	;9 = dust0010 spfx
	dc.w	0x001F,0x002B	;10 = dust0011 spfx
	dc.w	0x0020,0x002B	;11 = dust0012 spfx
	dc.w	0x001C,0x002A	;12 = dust0013 spfx
	dc.w	0x001D,0x0029	;13 = dust0014 spfx
	dc.w	0x001A,0x0022	;14 = dust0015 spfx
	dc.w	0x001D,0x001D	;15 = dust0016 spfx
	dc.w	0x001F,0x001D	;16 = dust0017 spfx
	dc.w	0x0024,0x0015	;17 = dust0018 spfx
	dc.w	0x0023,0x0012	;18 = dust0019 spfx

	dc.w	0x0000,0x0000	;  19 = ball0020 misc
	dc.w	0x0000,0x0000	;  20 = ball0021 misc
	dc.w	0x0000,0x0000	;  21 = ball0022 misc
	dc.w	0x0000,0x0000	;  22 = ball0023 misc
	dc.w	0x0000,0x0000	;  23 = ball0024 misc
	dc.w	0x0000,0x0000	;  24 = ball0025 misc
	dc.w	0x0000,0x0000	;  25 = ball0026 misc
	dc.w	0x0000,0x0000	;  26 = ball0027 misc
	dc.w	0x0000,0x0000	;  27 = ball0028 misc
	dc.w	0x0000,0x0000	;  28 = ball0029 misc
	dc.w	0x0000,0x0000	;  29 = ball0030 misc
	dc.w	0x0000,0x0000	;  30 = ball0031 misc
	dc.w	0x0000,0x0000	;  31 = ball0032 misc
	dc.w	0x0000,0x0000	;  32 = ball0033 misc
	dc.w	0x0000,0x0000	;  33 = ball0034 misc
	dc.w	0x0000,0x0000	;  34 = ball0035 misc
	dc.w	0x0000,0x0000	;  35 = ball0036 misc
	dc.w	0x0000,0x0000	;  36 = ball0037 misc
	dc.w	0x0000,0x0000	;  37 = ball0038 misc
	dc.w	0x0000,0x0000	;  38 = ball0039 misc
	dc.w	0x0000,0x0000	;  39 = ball0040 misc
	dc.w	0x0000,0x0000	;  40 = ball0041 misc
	dc.w	0x0000,0x0000	;  41 = ball0042 misc
	dc.w	0x0000,0x0000	;  42 = ball0043 misc
	dc.w	0x0000,0x0000	;  43 = ball0044 misc
	dc.w	0x0000,0x0000	;  44 = ball0045 misc
	dc.w	0x0000,0x0000	;  45 = ball0046 misc
	dc.w	0x0000,0x0000	;  46 = ball0047 misc
	dc.w	0x0000,0x0000	;  47 = ball0048 misc
	dc.w	0x0000,0x0000	;  48 = ball0049 misc
	dc.w	0x0000,0x0000	;  49 = ball0050 misc
	dc.w	0x0000,0x0000	;  50 = ball0051 misc
	dc.w	0x0000,0x0000	;  51 = ball0052 misc
	dc.w	0x0000,0x0000	;  52 = ball0053 misc
	dc.w	0x0000,0x0000	;  53 = ball0054 misc
	dc.w	0x0000,0x0000	;  54 = ball0055 misc
	dc.w	0x0000,0x0000	;  55 = ball0056 misc
	dc.w	0x0000,0x0000	;  56 = ball0057 misc
	dc.w	0x0000,0x0000	;  57 = ball0058 misc
	dc.w	0x0000,0x0000	;  58 = ball0059 misc
	dc.w	0x0000,0x0000	;  59 = ball0060 misc
	dc.w	0x0000,0x0000	;  60 = ball0061 misc
	dc.w	0x0000,0x0000	;  61 = ball0062 misc
	dc.w	0x0000,0x0000	;  62 = ball0063 misc
	dc.w	0x0000,0x0000	;  63 = ball0064 misc
	dc.w	0x0000,0x0000	;  64 = ball0065 misc
	dc.w	0x0000,0x0000	;  65 = ball0066 misc
	dc.w	0x0000,0x0000	;  66 = ball0067 misc
	dc.w	0x0000,0x0000	;  67 = ball0068 misc
	dc.w	0x0000,0x0000	;  68 = ball0069 misc
	dc.w	0x0000,0x0000	;  69 = ball0070 misc
	dc.w	0x0000,0x0000	;  70 = ball0071 misc
	dc.w	0x0000,0x0000	;  71 = ball0072 misc
	dc.w	0x0000,0x0000	;  72 = ball0073 misc
	dc.w	0x0000,0x0000	;  73 = ball0074 misc
	dc.w	0x0000,0x0000	;  74 = ball0075 misc
	dc.w	0x0000,0x0000	;  75 = ball0076 misc
	dc.w	0x0000,0x0000	;  76 = ball0077 misc
	dc.w	0x0000,0x0000	;  77 = ball0078 misc
	dc.w	0x0000,0x0000	;  78 = ball0079 misc
	dc.w	0x0000,0x0000	;  79 = ball0080 misc
	dc.w	0x0000,0x0000	;  80 = ball0081 misc
	dc.w	0x0000,0x0000	;  81 = ball0082 misc
	dc.w	0x0000,0x0000	;  82 = ball0083 misc
	dc.w	0x0000,0x0000	;  83 = ball0084 misc
	dc.w	0x0000,0x0000	;  84 = ballt pieces
	dc.w	0x0000,0x0000	;  85 = zone1 misc
	dc.w	0x0000,0x0000	;  86 = zone2 misc
	dc.w	0x0000,0x0000	;  87 = zone3 misc
	dc.w	0x0000,0x0000	;  88 = zone1a misc
	dc.w	0x0000,0x0000	;  89 = zone3a misc
	dc.w	0x0000,0x0000	;  90 = winclip1 misc
	dc.w	0x0000,0x0000	;  91 = w20001 misc
	dc.w	0x0000,0x0000	;  92 = w20002 misc
	dc.w	0x0000,0x0000	;  93 = w20003 misc
	dc.w	0x0000,0x0000	;  94 = w20004 misc
	dc.w	0x0000,0x0000	;  95 = w20005 misc
	dc.w	0x0000,0x0000	;  96 = winclip3 misc
	dc.w	0x0000,0x0000	;  97 = meter06 misc
	dc.w	0x0000,0x0000	;  98 = meterred misc
	dc.w	0x0000,0x0000	;  99 = meteryel misc
	dc.w	0x0000,0x0000	; 100 = metergry misc
	dc.w	0x0000,0x0000	; 101 = meter2a misc
	dc.w	0x0000,0x0000	; 102 = metertrb misc
	dc.w	0x0000,0x0000	; 103 = metermsh misc
	dc.w	0x0000,0x0000	; 104 = marker1 misc
	dc.w	0x0000,0x0000	; 105 = marker2 misc
	dc.w	0x0000,0x0000	; 106 = ballmark pieces
	dc.w	0x0000,0x0000	; 107 = vs misc
	dc.w	0x0000,0x0000	; 108 = playedrd misc
	dc.w	0x0000,0x0000	; 109 = label misc
	dc.w	0x0000,0x0000	; 110 = dirt0001 misc
	dc.w	0x0000,0x0000	; 111 = dirt0002 misc
	dc.w	0x0000,0x0000	; 112 = dirt0003 misc
	dc.w	0x0000,0x0000	; 113 = dirt0003 misc
	dc.w	0x0000,0x0000	; 114 = dirt0003 misc
	dc.w	0x0000,0x0000	; 115 = dirt0003 misc
	dc.w	0x0000,0x0000	; 116 = dirt0003 misc
	dc.w	0x0000,0x0000	; 117 = dirt0003 misc
	dc.w	0x0000,0x0000	; 118 = dirt0003 misc
	dc.w	0x0000,0x0000	; 119 = dirt0003 misc
	dc.w	0x0000,0x0000	; 120 = dirt0003 misc
	dc.w	0x0000,0x0000	; 121 = dirt0003 misc
	dc.w	0x0000,0x0000	; 122 = rock0001 misc
	dc.w	0x0000,0x0000	; 123 = rock0002 misc
	dc.w	0x0000,0x0000	; 124 = rock0003 misc
	dc.w	0x0000,0x0000	; 125 = rock0004 misc
	dc.w	0x0000,0x0000	; 126 = rock0005 misc
	dc.w	0x0000,0x0000	; 127 = rock0006 misc
	dc.w	0x0000,0x0000	; 128 = rock0007 misc
	dc.w	0x0000,0x0000	; 129 = rock0008 misc
	dc.w	0x0000,0x0000	; 130 = rock0009 misc
	dc.w	0x0000,0x0000	; 131 = rock0010 misc
	dc.w	0x0000,0x0000	; 132 = rock0011 misc
	dc.w	0x0000,0x0000	; 133 = rock0012 misc
	dc.w	0x0000,0x0000	; 134 = rock0013 misc
	dc.w	0x0000,0x0000	; 135 = rock0014 misc
	dc.w	0x0000,0x0000	; 136 = rock0015 misc
	dc.w	0x0000,0x0000	; 137 = score misc
	dc.w	0x0000,0x0000	; 138 = safe misc
	dc.w	0x0000,0x0000	; 139 = bigout misc
	dc.w	0x0000,0x0000	; 140 = strikem misc
	dc.w	0x0000,0x0000	; 141 = scoreb misc
	dc.w	0x0000,0x0000	; 142 = cardmesh misc
	dc.w	0x0000,0x0000	; 143 = ticketrd misc
	dc.w	0x0000,0x0000	; 144 = shad01 pieces
	dc.w	0x0000,0x0000	; 145 = shad02 pieces
	dc.w	0x0000,0x0000	; 146 = shad03 pieces
	dc.w	0x0000,0x0000	; 147 = shad04 pieces
	dc.w	0x0000,0x0000	; 148 = shad05 pieces
	dc.w	0x0000,0x0000	; 149 = shad06 pieces
	dc.w	0x0000,0x0000	; 150 = shad07 pieces
	dc.w	0x0000,0x0000	; 151 = shad08 pieces
	dc.w	0x0000,0x0000	; 152 = testclip field
	dc.w	0x0000,0x0000	; 153 = n00001 numbers
	dc.w	0x0000,0x0000	; 154 = n00002 numbers
	dc.w	0x0000,0x0000	; 155 = n00003 numbers

	dc.w	0x0004,0xFFFC	; 156 = fire0001 spfx
	dc.w	0x0005,0x0006	;  = fire0002 spfx
	dc.w	0x0007,0x000F	;  = fire0003 spfx
	dc.w	0x0008,0x0018	;  = fire0004 spfx
	dc.w	0x0009,0x0014	;  = fire0005 spfx
	dc.w	0x0009,0x0019	;  = fire0006 spfx
	dc.w	0x0009,0x001C	;  = fire0007 spfx
	dc.w	0x0009,0x001C	;  = fire0008 spfx
	dc.w	0x000A,0x001B	;  = fire0009 spfx

DotTable:
	dc.l	0	;  0 = ram_entry
	dc.l	0	;  1 = FieldWall
	dc.l	0	;  2 = font0
	dc.l	0	;  3 = font1
	dc.l	0	;  4 = font2
	dc.l	0	;  5 = fontm
	dc.l	0	;  6 = BatterTopBank
	dc.l	0	;  7 = BatterBottomBank
	dc.l	0	;  8 = BatterHead
	dc.l	0	;  9 = BattersBat
	dc.l	0	; 10 = PitcherTopBank
	dc.l	0	; 11 = PitcherBottomBank
	dc.l	0	; 12 = FielderTopBank
	dc.l	0	; 13 = FielderBottomBank
	dc.l	0	; 14 = CatcherTopBank
	dc.l	0	; 15 = CatcherBottomBank
	dc.l	0	; 16 = NumbersBank
	dc.l	0	; 17 = RunnerTopBank
	dc.l	0	; 18 = RunnerBottomBank
	dc.l	0	; 19 = Background
	dc.l	Misc	; 20 = Misc
	dc.l	0	; 21 = Cards
	dc.l	0	; 22 = fnt1
	dc.l	0	; 23 = fnt5
	dc.l	0	; 24 = fnt2
	dc.l	0	; 25 = fnt3
	dc.l	0	; 26 = fnt4
	dc.l	0	; 27 = Title
	dc.l	0	; 28 = Initial
	dc.l	0	; 29 = Logos
	dc.l	0	; 30 = Field


	end
