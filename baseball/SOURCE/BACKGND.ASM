;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************
	.region.s	"RAM"

;***************************************************************************
;   Routines Exported From BACKGND.ASM		*
;***************************************************************************
	.export	InitBackgnd,StartBackgnd

;***************************************************************************
;  Variable Imports			*
;***************************************************************************
	.import	ClearPage,CameraX
	.import.s	SinglePlayer
	.import.s	Batter,Pitcher
	.import.s	BackArt,Objects,NewBack
	.import.s	BlitX,BlitY
	.import.s	MinimumY
	.import.s	TimerStatus
	.import.s	Winner,WinnerObjPtr,AIActive
	.import.s	HighScores
	.import.s	DefeatedSave,temp_val,rnd1
	.import.s	DefeatedTag
	.import	AddCycle
	.import.s	FunTrigger
	.import.s	message_flag
	.import	LastRank,InitRank
	.import	GameMode
	.import	Deskflg,Blankaflg
	.import.s	Flags

;***************************************************************************
;  Subroutine Imports			*
;***************************************************************************
	.import	SetFont2,InitCycle,SetFont4
	.import	Spawn,TogglePage,Random
	.import	SkewObject,BlitObject,AllocObject,BlitRObject
	.import	BlitHostObj
	.import	BlitSineObj,BlitAObject,BlitRSObject
	.import	BlitClipObj,SkewObjectFast
	.import	OScaledObject
	.import	TextObject,ScaledObject,FlopObject
	.import	ClipTextObj
	.import	Anim,Sort,Display
	.import	LoadAttractPal
	.import	AttractCredits

;***************************************************************************
;  RAM Variables Defined In This Section              	*
;***************************************************************************
	.export	GroundY2,GroundY

MINIMUMY	equ	60	; Minimum Y Value For Scrolling

GroundY2	  ds.w	1
GroundY	  ds.l	1

;***************************************************************************
;  Start Of Code			*
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
	#include	"ramblock.h"
	#include	"anim.mac"
	#include	"pals.h"
	#include	"stats.h"
	#include	"audits.h"
	#include	"groms.h"

	.import	Attract
	.import	AttractLogo	
	.import	HighScore1

	.align	2
;****************************************************************************
;   InitBackgnd - Initialize The Background Art Objects                     *
;                                                                           *
;   Parameters :  BackArt - Background Number                               *
;   Returns:      NONE                                                      *
;   Modifies:     NONE                                                      *
;****************************************************************************
StartBackgnd:
	asl.w	#2,d1	; Multiply By Four
	move.l	#Backgrounds,a5	; Load Address Of Background Array
	move.l	(a5,d1.w),a5	; Index To Selected Background
	bra	InitB_3

InitBackgnd:
	BPALETTE	#P_BLACK	;

	move.w	BackArt,d1	; Load Background Number
	asl.w	#2,d1	; Multiply By Four
	move.l	#Backgrounds,a5	; Load Address Of Background Array
	move.l	(a5,d1.w),a5	; Index To Selected Background
	
	clr.l	d0	; Clear D0
	move.w	(a5)+,d0	; Load Ground Y Position
	move.w	d0,GroundY2	; Store Word Version Of Ground Y
InitB_1:
	asl.l	#8,d0	; Multiply By 256
	move.l	d0,GroundY	; Store Long Ground Y
	move.w	(a5)+,MinimumY	; Store Minimum Y

InitB_3:
	clr.b	d1	; Set As Non Collidable
	jsr	AllocObject	; Allocate An Object
	move.w	(a5)+,XPOSITION(a0)	; Set X Position
	move.w	(a5)+,YPOSITION(a0)	; Set Y Position
	move.w	(a5)+,ZPOSITION(a0)	; Load Z Position
	move.b	(a5)+,BANK(a0)	; Set Image Bank
	clr.w	d0	; Clear Upper Byte
	move.b	(a5)+,d0	; Load Picture Number
	move.w	d0,PICTURE(a0)	; Save Picture Number
	clr.w	d0	; Clear Upper Byte
	move.b	(a5)+,d0	; Load Type Of Image
	move.b	d0,OBJECTTYPE(a0)	; Set The Object Type
	move.b	(a5)+,FLIPFLAG(a0)	; Set Up Flip Flag
	asl.w	#2,d0	; Multiply Object Type By Two
	move.l	#TypeJump,a1	; Load Address Of Jump Table
	move.l	(a1,d0),a1	; Load Routine Address
	jmp	(a1)	; Jump To Routine

	.export	TypeJump
TypeJump:
	dc.l	InitB_3A	; Normal Object
	dc.l	InitB_3B	; Skewed Object
	dc.l	InitB_3B	; Inverted Skewed Object
	dc.l	InitB_3C	; Special Object
	dc.l	InitB_3D	; Anchored Object
	dc.l	InitB_3E	; Floating Object
	dc.l	InitB_3F	; Repeating Object
	dc.l	InitB_3G	; Repeating Skewed Object
	dc.l	InitB_3H	; Text Object
	dc.l	InitB_3I	; Scaled Object
	dc.l	InitB_3J	; Flopped Object
	dc.l	InitB_3K	; Cliped Object
	dc.l	InitB_3L	; Skewed Lg Object
	dc.l	InitB_3M	; 0Scaled Object
	dc.l	InitB_3N	; ClipText
	dc.l	InitB_3O	; Host Blit
	dc.l	InitB_3P	; Clipped With Values

InitB_3A:
	move.l	#BlitObject,d1	; Load Address Of Display Routine
	bra	InitB_3X
InitB_3B:
	move.l	#SkewObject,d1	; Set Display Proc
	bra	InitB_3X
InitB_3C:
	move.l	(a5)+,d1	; Load Address From Data Table
	bra	InitB_3X
InitB_3D:
	move.l	#BlitAObject,d1	; Loa Address Of Display Routine
	bra	InitB_3X
InitB_3E:
	move.w	#2,YVELOCITY(a0)
	move.w	(a5)+,XVELOCITY(a0)	; Save Starting Position
	move.l	#BlitSineObj,d1	; Load Address Of Display Routine
	bra	InitB_3X
InitB_3F:
	move.l	#BlitRObject,d1	; Load Address Of Display Routine
	bra	InitB_3X

InitB_3G:
	move.l	#BlitRSObject,d1	; Load Address Of Display Routine
	bra	InitB_3X

InitB_3H:
	move.l	#TextObject,d1	; Load Address Of Display Routine
	move.w	#0xFFFF,NUMBEROFCHARS(a0)	; Clear Character Count
	clr.w	STARTCHARACTER(a0)
	move.l	(a5)+,PARENT(a0)	; Set Text Address
	bra.s	InitB_3X

InitB_3I:
	move.l	#ScaledObject,d1	; Load Address Of Display Routine
	bra.s	InitB_3X

InitB_3J:
	move.l	#FlopObject,d1	; Load Address Of Display Routine
	bra.s	InitB_3X

InitB_3K:
	move.l	#BlitClipObj,d1	; Load Address Of Display Routine
	bra.s	InitB_3X

InitB_3L:
	move.l	#SkewObjectFast,d1	; Set Display Proc
	bra.s	InitB_3X
InitB_3M:
	move.l	#OScaledObject,d1	; Set Display Proc
	bra.s	InitB_3X
InitB_3N:
	move.l	#ClipTextObj,d1	; Load Address Of Display Routine
	move.w	#0xFFFF,NUMBEROFCHARS(a0)	; Clear Character Count
	clr.w	STARTCHARACTER(a0)
	move.l	(a5)+,PARENT(a0)	; Set Text Address
	move.w	#0,XCLIP1(a0)
	move.w	#384,XCLIP2(a0)
	bra.s	InitB_3X

InitB_3O:
	move.l	#BlitHostObj,d1	; Load Address Of Display Routine
	move.w	(a5)+,BLITWIDTH(a0)	; Set width
	move.w	(a5)+,BLITHEIGHT(a0)	; Set height
	move.l	(a5)+,PARENT(a0)	; Set Art Address
	bra.s	InitB_3X

InitB_3P:
	move.l	#BlitClipObj,d1	; Load Address Of Display Routine
	move.w	(a5)+,XCLIP1(a0)	; Set X Clip
	move.w	(a5)+,XCLIP2(a0)
	move.w	(a5)+,YCLIP1(a0)	; Set Y Clip
	move.w	(a5)+,YCLIP2(a0)

InitB_3X:
	move.l	d1,DISPLAYPROC(a0)	; Set Display Proc

	move.b	(a5)+,PALETTE(a0)	; Save Palette Number
	move.b	(a5)+,STATIONARY(a0)	; Skip Pad Byte

	move.l	(a5)+,PARSEPOINTER(a0)	; Store Animation Procedure
	beq.s	InitB_3Y	; Branch If No Procedure Defined
	move.l	#Anim,UPDATEPROC(a0)	; Store Update Procedure
InitB_3Y:
	move.l	(a5)+,d0	; Load Address Of Pointer
	beq.s	InitB_3Z	; Branch If None Needed
	move.l	d0,a1	; Move Address To A1
	move.l	a0,(a1)	; Save Pointer To Object
InitB_3Z:
	cmp.w	#0xFFFF,(a5)	; Check If More Objects
	bne	InitB_3	; Branch If More
	lea	2(a5),a5	; Index Past Object End
InitB_6:
	clr.w	d0
	move.b	(a5)+,d0	; Load Color Cycle Palette Number
	bmi.s	InitB_7	; Branch If All Done
	clr.w	d1
	move.b	(a5)+,d1	; Load Color Cycle Starting Color
	clr.w	d2
	move.b	(a5)+,d2	; Load Color Cycle Number Of Colors
	clr.w	d3
	move.b	(a5)+,d3	; Load Color Cycle Tick Count
	jsr	AddCycle
	bra	InitB_6	
InitB_7:
InitB_8:
	clr.w	NewBack	; Finished With New Background
	rts

Backgrounds:
	dc.l	PlayField	; 0 - Play Field
	dc.l	TitleScreen	; 1 - Title
	dc.l	PlayAtHome	; 2 - plays at home screen
	dc.l	HalfInn	; 3 - Halfinning
	dc.l	0	; 4 - Hidden 1
	dc.l	InitialScreen	; 5 - Enter Initials
	dc.l	0	; 6 -
	dc.l	0	; 7 -

;****************************************************************************
;****************************************************************************

	.align	2
PlayField:
	dc.w	215,MINIMUMY+6	; Y Position Of Ground
; Play Field
	dc.w	-55,93,2	;66 X,Y-16(v2),Z Position
	dc.b	Background	; Image Bank
	dc.b	test02,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TESTF,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed
; Play Field
	dc.w	63,93,2	;66 X,Y-16(v2),Z Position
	dc.b	Background	; Image Bank
	dc.b	test03,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TESTF,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed
; Play Field
	dc.w	318,93,2	;66 X,Y-16(v2),Z Position
	dc.b	Background	; Image Bank
	dc.b	test03,NORMAL,FLIP	; Image Number,Image Type,Flip
	dc.b	P_TESTF,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; Play Field
	dc.w	446,93,2	;66 X,Y-16(v2),Z Position
	dc.b	Background	; Image Bank
	dc.b	test02,NORMAL,FLIP	; Image Number,Image Type,Flip
	dc.b	P_TESTF,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed


; Stadium
;	dc.w	0,-16,1	; X,Y,Z Position
;	dc.b	Background	; Image Bank
;	dc.b	sky1,NORMAL,NOFLIP	; Image Number,Image Type,Flip
;	dc.b	P_STADIUM,FIXED	; Color Palette, Fixed
;	dc.l	0	; Animation Routine
;	dc.l	0	; No Pointer Needed

;; New Stadium
;	dc.w	0,-60,2	;44 X,Y,Z Position
;	dc.b	Misc	; Image Bank
;	dc.b	bakdrop1,NORMAL,NOFLIP	; Image Number,Image Type,Flip
;	dc.b	P_BACKDROP,FIXED	; Color Palette, Fixed
;	dc.l	0	; Animation Routine
;	dc.l	0	; No Pointer Needed

;; New Stadium
;    	dc.w	65,57,2	;44 X,Y,Z Position
;    	dc.b	Background	; Image Bank
;    	dc.b	awall3,NORMAL,NOFLIP	; Image Number,Image Type,Flip
;    	dc.b	P_BACKDROP,FIXED	; Color Palette, Fixed
;    	dc.l	0	; Animation Routine
;    	dc.l	0	; No Pointer Needed

; New Stadium
    	dc.w	65,-28,2	;44 X,Y,Z Position
    	dc.b	Background	; Image Bank
    	dc.b	astad3,NORMAL,NOFLIP	; Image Number,Image Type,Flip
    	dc.b	P_STANDS,FIXED	; Color Palette, Fixed
;    	dc.b	P_BALL,FIXED	; Color Palette, Fixed
    	dc.l	0	; Animation Routine
    	dc.l	0	; No Pointer Needed

; New Stadium
;     	dc.w	320,57,2	;44 X,Y,Z Position
;     	dc.b	Background	; Image Bank
;     	dc.b	awall3,NORMAL,FLIP	; Image Number,Image Type,Flip
;     	dc.b	P_BACKDROP,FIXED	; Color Palette, Fixed
;     	dc.l	0	; Animation Routine
;    	dc.l	0	; No Pointer Needed

; New Stadium
     	dc.w	320,-28,2	;44 X,Y,Z Position
;     	dc.w	320,0,12	;44 X,Y,Z Position
     	dc.b	Background	; Image Bank
     	dc.b	astad3,NORMAL,FLIP	; Image Number,Image Type,Flip
     	dc.b	P_STANDS,FIXED	; Color Palette, Fixed
     	dc.l	0	; Animation Routine
     	dc.l	0	; No Pointer Needed

; New Stadium
;   	dc.w	-63,55,2	;44 X,Y,Z Position
;   	dc.b      Background	; Image Bank
;   	dc.b	awall2,NORMAL,NOFLIP	; Image Number,Image Type,Flip
;   	dc.b	P_BACKDROP,FIXED	; Color Palette, Fixed
;   	dc.l	0	; Animation Routine
;   	dc.l	0	; No Pointer Needed

; New Stadium
    	dc.w	-63,-137,2	;44 X,Y,Z Position
   	dc.b	Background	; Image Bank
    	dc.b	astad2,NORMAL,NOFLIP	; Image Number,Image Type,Flip
    	dc.b	P_STANDS,FIXED	; Color Palette, Fixed
    	dc.l	0	; Animation Routine
    	dc.l	0	; No Pointer Needed

;; New Stadium
;   	dc.w	448,55,2	;44 X,Y,Z Position
;   	dc.b      Background	; Image Bank
;   	dc.b	awall2,NORMAL,FLIP	; Image Number,Image Type,Flip
;   	dc.b	P_BACKDROP,FIXED	; Color Palette, Fixed
;   	dc.l	0	; Animation Routine
;   	dc.l	0	; No Pointer Needed
;
; New Stadium
    	dc.w	448,-137,2	;44 X,Y,Z Position
   	dc.b	Background	; Image Bank
    	dc.b	astad2,NORMAL,FLIP	; Image Number,Image Type,Flip
    	dc.b	P_STANDS,FIXED	; Color Palette, Fixed
    	dc.l	0	; Animation Routine
    	dc.l	0	; No Pointer Needed

; New Stadium
   ;	dc.w	0,55,2	;44 X,Y,Z Position
   ;	dc.b	Background	; Image Bank
   ;	dc.b	awall1,NORMAL,NOFLIP	; Image Number,Image Type,Flip
   ;	dc.b	P_BACKDROP,FIXED	; Color Palette, Fixed
   ;	dc.l	0	; Animation Routine
   ;	dc.l	0	; No Pointer Needed


   
; New Stadium
    ;	dc.w	0,-100,2	;44 X,Y,Z Position
    ;	dc.b	Background	; Image Bank
    ;	dc.b	astad1,NORMAL,NOFLIP	; Image Number,Image Type,Flip
    ;	dc.b	P_BACKDROP,FIXED	; Color Palette, Fixed
    ;	dc.l	0	; Animation Routine
    ;	dc.l	0	; No Pointer Needed

; New Stadium
    ;	dc.w	86,1,2	;44 X,Y,Z Position
    ;	dc.b	Background	; Image Bank
    ;	dc.b	ascore,NORMAL,NOFLIP	; Image Number,Image Type,Flip
    ;	dc.b	P_BACKDROP,FIXED	; Color Palette, Fixed
    ;	dc.l	0	; Animation Routine
    ;	dc.l	0	; No Pointer Needed

	dc.w	$FFFF	; End Of Object
	dc.w	$FFFF	; End Of Color Cycles


TitleScreen:
	dc.w	256+15,MINIMUMY+6	; Y Position Of Ground
#comment
; Title Part 1
	dc.w	0,0,0	; X,Y,Z Position
	dc.b	Title	; Image Bank
	dc.b	back,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TITLE1,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; Title Part 2
	dc.w	83,8,1	; X,Y,Z Position
	dc.b	Title	; Image Bank
	dc.b	banner,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TITLE2,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; Title Part 3
	dc.w	70,0,2	; X,Y,Z Position
	dc.b	Title	; Image Bank
	dc.b	bats,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TITLE3,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; Title Part 4
	dc.w	43,0,3	; X,Y,Z Position
	dc.b	Title	; Image Bank
	dc.b	dirt,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TITLE4,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; Title Part 5
	dc.w	103,17,4	; X,Y,Z Position
	dc.b	Title	; Image Bank
	dc.b	green,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TITLE5,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; Title Part 6
	dc.w	18,52,5	; X,Y,Z Position
	dc.b	Title	; Image Bank
	dc.b	title,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TITLE6,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed
#endcomment

; Title Part 1
	dc.w	0,0,0	; X,Y,Z Position
	dc.b	Title	; Image Bank
	dc.b	titlebk1,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TITLEBK1,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; Title Part 2
	dc.w	192,0,1	; X,Y,Z Position
	dc.b	Title	; Image Bank
	dc.b	titlebk2,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TITLEBK2,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; Title Part 3
	dc.w	35,90,2	; X,Y,Z Position
	dc.b	Title	; Image Bank
	dc.b	titleblu,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TITLEBLU,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; Title Part 4
	dc.w	48,0,3	; X,Y,Z Position
	dc.b	Title	; Image Bank
	dc.b	titlebrn,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TITLEBRN,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; Title Part 5
	dc.w	123,43,4	; X,Y,Z Position
	dc.b	Title	; Image Bank
	dc.b	titlegrn,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TITLEGRN,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

	dc.w	$FFFF	; End Of Object
	dc.w	$FFFF	; End Of Color Cycles



InitialScreen:
	dc.w	256+15,MINIMUMY+6	; Y Position Of Ground

;InitialScreen 1
;	dc.w	0,0,2	; X,Y,Z Position
;	dc.b	Initial	; Image Bank
;	dc.b	inite,NORMAL,NOFLIP	; Image Number,Image Type,Flip
;	dc.b	P_INITE,FIXED	; Color Palette, Fixed
;	dc.l	0	; Animation Routine
;	dc.l	0	; No Pointer Needed



;InitialScreen 2
;	dc.w	17,255,2	; X,Y,Z Position
;	dc.b	Initial	; Image Bank
;	dc.b	initf,NORMAL,NOFLIP	; Image Number,Image Type,Flip
;	dc.b	P_INITF,FIXED	; Color Palette, Fixed
 ;	dc.l	0	; Animation Routine
 ;	dc.l	0	; No Pointer Needed

;InitialScreen 3
;	dc.w	138,89,1	; X,Y,Z Position
;	dc.b	Initial	; Image Bank
;	dc.b	yes,NORMAL,NOFLIP	; Image Number,Image Type,Flip
 ;	dc.b	P_FNT1,FIXED	; Color Palette, Fixed
 ;	dc.l	0	; Animation Routine
;	dc.l	0	; No Pointer Needed

;InitialScreen 4
;	dc.w	132,161,1	; X,Y,Z Position
;	dc.b     	Initial	; Image Bank
;	dc.b	no,NORMAL,NOFLIP	; Image Number,Image Type,Flip
;	dc.b	P_FNT1,FIXED	; Color Palette, Fixed
;	dc.l	0	; Animation Routine
;	dc.l	0	; No Pointer Needed


	dc.w	$FFFF	; End Of Object
	dc.w	$FFFF	; End Of Color Cycles


PlayAtHome:
	dc.w	215,MINIMUMY+6	; Y Position Of Ground
;
;   	dc.w	-183,55,2	;44 X,Y,Z Position
;   	dc.b      Background	; Image Bank
;   	dc.b	awall2,NORMAL,NOFLIP	; Image Number,Image Type,Flip
;   	dc.b	P_BACKDROP,FIXED	; Color Palette, Fixed
;   	dc.l	0	; Animation Routine
;   	dc.l	0	; No Pointer Needed
;

    	dc.w	-183,-137,2	;44 X,Y,Z Position
   	dc.b	Background	; Image Bank
    	dc.b	astad2,NORMAL,NOFLIP	; Image Number,Image Type,Flip
    	dc.b	P_STANDS,FIXED	; Color Palette, Fixed
    	dc.l	0	; Animation Routine
    	dc.l	0	; No Pointer Needed


	dc.w	-183,93,2	;66 X,Y-16(v2),Z Position
	dc.b	Background	; Image Bank
	dc.b	test01,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TESTF,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; Play Field
	dc.w	-55,93,2	;66 X,Y-16(v2),Z Position
	dc.b	Background	; Image Bank
	dc.b	test02,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TESTF,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed
; Play Field
	dc.w	63,93,2	;66 X,Y-16(v2),Z Position
	dc.b	Background	; Image Bank
	dc.b	test03,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TESTF,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed
; Play Field
	dc.w	318,93,2	;66 X,Y-16(v2),Z Position
	dc.b	Background	; Image Bank
	dc.b	test03,NORMAL,FLIP	; Image Number,Image Type,Flip
	dc.b	P_TESTF,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; Play Field
	dc.w	446,93,2	;66 X,Y-16(v2),Z Position
	dc.b	Background	; Image Bank
	dc.b	test02,NORMAL,FLIP	; Image Number,Image Type,Flip
	dc.b	P_TESTF,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; New Stadium
;    	dc.w	65,55,2	;44 X,Y,Z Position
;    	dc.b	Background	; Image Bank
;    	dc.b	awall3,NORMAL,NOFLIP	; Image Number,Image Type,Flip
;    	dc.b	P_BACKDROP,FIXED	; Color Palette, Fixed
;    	dc.l	0	; Animation Routine
;    	dc.l	0	; No Pointer Needed

; New Stadium
    	dc.w	65,-28,2	;44 X,Y,Z Position
    	dc.b	Background	; Image Bank
    	dc.b	astad3,NORMAL,NOFLIP	; Image Number,Image Type,Flip
    	dc.b	P_STANDS,FIXED	; Color Palette, Fixed
    	dc.l	0	; Animation Routine
    	dc.l	0	; No Pointer Needed

; New Stadium
;     	dc.w	320,55,2	;44 X,Y,Z Position
;     	dc.b	Background	; Image Bank
;     	dc.b	awall3,NORMAL,FLIP	; Image Number,Image Type,Flip
;     	dc.b	P_BACKDROP,FIXED	; Color Palette, Fixed
;     	dc.l	0	; Animation Routine
;    	dc.l	0	; No Pointer Needed

; New Stadium
     	dc.w	320,-28,2	;44 X,Y,Z Position
     	dc.b	Background	; Image Bank
     	dc.b	astad3,NORMAL,FLIP	; Image Number,Image Type,Flip
     	dc.b	P_STANDS,FIXED	; Color Palette, Fixed
     	dc.l	0	; Animation Routine
     	dc.l	0	; No Pointer Needed

; New Stadium
;   	dc.w	-63,55,2	;44 X,Y,Z Position
;   	dc.b      Background	; Image Bank
;   	dc.b	awall2,NORMAL,NOFLIP	; Image Number,Image Type,Flip
;   	dc.b	P_BACKDROP,FIXED	; Color Palette, Fixed
;   	dc.l	0	; Animation Routine
;   	dc.l	0	; No Pointer Needed

; New Stadium
    	dc.w	-63,-137,2	;44 X,Y,Z Position
   	dc.b	Background	; Image Bank
    	dc.b	astad2,NORMAL,NOFLIP	; Image Number,Image Type,Flip
    	dc.b	P_STANDS,FIXED	; Color Palette, Fixed
    	dc.l	0	; Animation Routine
    	dc.l	0	; No Pointer Needed

; New Stadium
;   	dc.w	448,55,2	;44 X,Y,Z Position
;   	dc.b      Background	; Image Bank
;   	dc.b	awall2,NORMAL,FLIP	; Image Number,Image Type,Flip
;   	dc.b	P_BACKDROP,FIXED	; Color Palette, Fixed
;   	dc.l	0	; Animation Routine
;   	dc.l	0	; No Pointer Needed
;
; New Stadium
    	dc.w	448,-137,2	;44 X,Y,Z Position
   	dc.b	Background	; Image Bank
    	dc.b	astad2,NORMAL,FLIP	; Image Number,Image Type,Flip
    	dc.b	P_STANDS,FIXED	; Color Palette, Fixed
    	dc.l	0	; Animation Routine
    	dc.l	0	; No Pointer Needed

	dc.w	$FFFF	; End Of Object
	dc.w	$FFFF	; End Of Color Cycles











	dc.w	255,MINIMUMY+6	; Y Position Of Ground
; Play Field
	dc.w	-192,93,2	;66 X,Y-16(v2),Z Position
	dc.b	Background	; Image Bank
	dc.b	test01,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TESTF,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed
; Play Field
	dc.w	-64,93,2	;66 X,Y-16(v2),Z Position
	dc.b	Background	; Image Bank
	dc.b	test02,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TESTF,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed
; Play Field
	dc.w	63,93,2	;66 X,Y-16(v2),Z Position
	dc.b	Background	; Image Bank
	dc.b	test03,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_TESTF,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed
; Play Field
	dc.w	318,93,2	;66 X,Y-16(v2),Z Position
	dc.b	Background	; Image Bank
	dc.b	test03,NORMAL,FLIP	; Image Number,Image Type,Flip
	dc.b	P_TESTF,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; Play Field
	dc.w	446,93,2	;66 X,Y-16(v2),Z Position
	dc.b	Background	; Image Bank
	dc.b	test02,NORMAL,FLIP	; Image Number,Image Type,Flip
	dc.b	P_TESTF,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; New Stadium
	dc.w	-192,-132,2	;44 X,Y,Z Position
	dc.b	Misc	; Image Bank
	dc.b	ball0084,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_STANDS,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; New Stadium
	dc.w	-60,-115,2	;44 X,Y,Z Position
	dc.b	Misc	; Image Bank
	dc.b	ball0084,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_STANDS,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; New Stadium
	dc.w	68,3,2	;44 X,Y,Z Position
	dc.b	Misc	; Image Bank
	dc.b	ball0084,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_STANDS,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; New Stadium
	dc.w	322,3,2	;44 X,Y,Z Position
	dc.b	Misc	; Image Bank
	dc.b	ball0084,NORMAL,FLIP	; Image Number,Image Type,Flip
	dc.b	P_STANDS,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

; New Stadium
	dc.w	450,-115,2	;44 X,Y,Z Position
	dc.b	Misc	; Image Bank
	dc.b	ball0084,NORMAL,FLIP	; Image Number,Image Type,Flip
	dc.b	P_STANDS,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

	dc.w	$FFFF	; End Of Object
	dc.w	$FFFF	; End Of Color Cycles



HalfInn:
	dc.w	255,MINIMUMY+6	; Y Position Of Ground
;
	dc.w	0,0,2	;66 X,Y-16(v2),Z Position
	dc.b	Initial	; Image Bank
	dc.b	bakdrp3b,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_BAK1BPAL,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed
;
	dc.w	180,0,2	;66 X,Y-16(v2),Z Position
	dc.b	Initial	; Image Bank
	dc.b	bakdrp3a,NORMAL,NOFLIP	; Image Number,Image Type,Flip
	dc.b	P_BAK1APAL,FIXED	; Color Palette, Fixed
	dc.l	0	; Animation Routine
	dc.l	0	; No Pointer Needed

	dc.w	$FFFF	; End Of Object
	dc.w	$FFFF	; End Of Color Cycles


	end



