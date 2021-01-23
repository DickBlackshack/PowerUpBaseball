;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************
	#include	"itvideo2.h"
	#include	"ramblock.h"
	#include	"graphlib.h"
	#include	"graphlib.mac"
;	#include	"banks.h"
	#include	"groms.h"
	#include	"pals.h"

;***************************************************************************
;   Routines Exported From OBJECT.ASM		*
;***************************************************************************
	.export	AllocObject	; Allocate Object
	.export	BlitAObject	; Blit Anchored Object
	.export	BlitObject	; Blit Object
	.export	BlitCentered	; Blit Object
	.export	BlitRObject	; Blit Repeating Object
	.export	BlitRSObject	; Blit Repeating Skewed Object
	.export	BlitSineObj	; Blit A Floating Object
	.export	BlitClipObj	; Blit A Clipped Object
	.export	SkewObjectFast
	.export	OScaledObject	; Blit A OScaled Object
	.export	ScaledObject	; Blit A OScaled Object
	.export	BlitHostObj	; Blit A Host Object
	.export	BlitSAObject

	.export	CalcFieldCoord
	.export	DeallocObject,DeallocObjecta1
	.export	Display
	.export	DisplayField
	.export	FlopObject	; Blit A Flopped Object
	.export	InitObjects,InitProcs
	.export	SetCameraY
	.export	SkewObject	; Blit A Skewed Object
	.export	Sort
	.export	TextObject	; Blit A Text Object
	.export	Update

;***************************************************************************
;  Variable Imports			*
;***************************************************************************
	.import.s	BlitHeight,BlitWidth,BlitX,BlitY
	.import.s	pry_coor,prx_init,prx_coor
	.import.s	SpecialsAllowed

	.import	PageLine
	.import.s last_cmd,S_Mode1
	.import	AQStat
	.import	PlayerL,PlayerR

;***************************************************************************
;  System Subroutine Imports		*
;***************************************************************************
	.import	ramdump
 	.import	Anim
	.global	Blit,BlitData
	.import	SetSysFont,SetFont2,SetWinFont,SetScoreFont
	.import	SetFontNeo1,SetFontNeo2,SetFontNeo3,SetFontNeo4
	.import	SetFontNeo5,SetFontNeo6,SetFontNeo7

	.import	Print
	.import	DisplayShadows

;***************************************************************************
;  RAM Variables Defined In This Section		*
;***************************************************************************
	.import.s	ICameraY

	.export	MinimumY

	.import	PriorityTable

BOTSCR equ 256
RGTSCR equ 384

;***************************************************************************
;***************************************************************************
	.region.s	"RAM"
	ds	0
WallY	ds.l	1	; Y Position Of Wall
LastObject	ds.l	1
x_position	ds.w	1
MinimumY	ds.w	1
Count	ds.b	1
object_cnt	ds.w	1
objdis_cnt	ds.w	1

ObjPtrs	ds.l	NUMBLOCKS+20
skwnum	ds.w	1
SwitchTv	ds.b	1



	.export	FieldScale,FieldGromAdr,FieldLine,FieldColumn,YOffset
	.export	ScalingY,ScalingX,FielderScale,FieldX,FieldY,PieceWidth
	.export	PieceHeight,StadiumScale,FieldWorldY


FieldScale	     ds.w	1
FieldGromAdr    ds.l	1
FieldLine	     ds.w	1
FieldColumn     ds.w	1
FieldMiddle     ds.w	1

FieldWorldX     ds.l	1

YArray	     ds.w	256
YOffset	     ds.w	1
ScalingY        ds.l	1
ScalingX        ds.l	1
FielderScale    ds.w	1
FieldX	     ds.w	1	; Field X Position
FieldY	     ds.w	1	; Field Y Position
PieceWidth	     ds.w	1
PieceHeight     ds.w	1
StadiumScale    ds.w	1
FieldWorldY     ds.l	1
LockFieldXY     ds.b	1
BaseballX       ds.l	1
BaseballY       ds.l	1
L_FieldWorldY   ds.l	1	; Locked Field World Y
L_FieldX	     ds.w	1	; Locked Field X Position
L_FieldY	     ds.w	1	; Locked Field Y Position
L_FieldGromAdr  ds.l	1
L_BaseballX     ds.l	1
L_BaseballY     ds.l	1

;***************************************************************************
;  Start Of Program Code		*
;***************************************************************************
	.region	"RomCode"

	ds	0

	.import.s	StartX
	.import.s	GroundY2,GroundY
	.import.s	Objects,FreeObjects,ObjectList
	.import.s	Pitcher,Batter,FirstBase,SecondBase,ShortStop,Baseball
	.import.s	FirstRunner,SecondRunner,ThirdRunner,HomeRunner
	.import.s	ThirdBase,Catcher,LeftField,CenterField,RightField
	.import.s	bankaddress
	.import.s	ShakeYCnt,ShakeYPeriod,ShakeYDist
	.import.s	TimerStatus
	.import.s	S_PLN1YTP,S_PLN1XTP
	.import.s	BallOnGround

****************************************************************************
* InitObjects() - Initializes all objects onto the free list.  Sets up the *
*                 first two objects as the fighters.	*
*				*
* Parameters: NONE			*
* Returns: NONE			*
* Uses: d0,a0,a1			*
****************************************************************************
InitObjects:
	clr.b	LockFieldXY
	move.l	#ScaleYData2,ScalingY
	move.l	#ScaleXData2,ScalingX

	move.w	#NUMBLOCKS-2,d0
	move.l	#ObjectList,a0	
	move.l	a0,FreeObjects	; Initialize Free Pointer
	movea.l	a0,a1
InitObj_1:
	adda.l	#`sizeof(object_struct),a1	; Index To Next Block
	move.l	a1,(a0)	; Store Pointer To Next Block
	move.l	a1,a0
	dbeq	d0,InitObj_1	
	clr.l	(a0)	; Clear Pointer In Last Object Block
	move.l	#Baseball,Objects	; Init Pointer To Active Objects
	move.l	#Batter,Baseball
	move.l	#Pitcher,Batter
	move.l	#FirstBase,Pitcher
	move.l	#SecondBase,FirstBase
	move.l	#ShortStop,SecondBase
	move.l	#ThirdBase,ShortStop
	move.l	#Catcher,ThirdBase
	move.l	#LeftField,Catcher
	move.l	#CenterField,LeftField
	move.l	#RightField,CenterField
	move.l	#FirstRunner,RightField
	move.l	#SecondRunner,FirstRunner
	move.l	#ThirdRunner,SecondRunner
	move.l	#HomeRunner,ThirdRunner
	clr.l	HomeRunner

	clr.l	Batter+CHILD
	clr.l	Pitcher+CHILD
 	clr.l	B_SEEKING+FirstRunner	;Need to Clear Runners from
	clr.l	B_SEEKING+SecondRunner	;seeking bases after going to
	clr.l	B_SEEKING+ThirdRunner	;to batting screen
	clr.l	B_SEEKING+HomeRunner
	clr.l	B_SEEKING+Pitcher
	clr.b	B_HASBALL+Pitcher
	clr.b	B_HASBALL+FirstBase
	clr.b	B_HASBALL+SecondBase
	clr.b	B_HASBALL+ThirdBase
	clr.b	B_HASBALL+ShortStop
	clr.b	B_HASBALL+LeftField
	clr.b	B_HASBALL+RightField
	clr.b	B_HASBALL+CenterField
	clr.b	B_HASBALL+Catcher

	move.b	#1,B_INUSE+Pitcher
	move.b	#1,B_INUSE+FirstBase
	move.b	#1,B_INUSE+SecondBase
	move.b	#1,B_INUSE+ThirdBase
	move.b	#1,B_INUSE+ShortStop
	move.b	#1,B_INUSE+LeftField
	move.b	#1,B_INUSE+RightField
	move.b	#1,B_INUSE+CenterField
	move.b	#1,B_INUSE+Catcher

	clr.l	WORLDXVEL+Pitcher	; Stop X Velocity
	clr.l	WORLDYVEL+Pitcher	; Stop Y Velocity

	rts

InitProcs:
	jsr	InitObjects

	clr.l	Baseball+DISPLAYPROC
	clr.l	Batter+DISPLAYPROC
	clr.l	Pitcher+DISPLAYPROC
	clr.l	FirstBase+DISPLAYPROC
	clr.l	SecondBase+DISPLAYPROC
	clr.l	ShortStop+DISPLAYPROC
	clr.l	ThirdBase+DISPLAYPROC
	clr.l	Catcher+DISPLAYPROC
	clr.l	LeftField+DISPLAYPROC
	clr.l	CenterField+DISPLAYPROC
	clr.l	RightField+DISPLAYPROC
	clr.l	FirstRunner+DISPLAYPROC
	clr.l	SecondRunner+DISPLAYPROC
	clr.l	ThirdRunner+DISPLAYPROC
	clr.l	HomeRunner+DISPLAYPROC

	clr.l	Baseball+UPDATEPROC
	clr.l	Batter+UPDATEPROC
	clr.l	Pitcher+UPDATEPROC
	clr.l	FirstBase+UPDATEPROC
	clr.l	SecondBase+UPDATEPROC
	clr.l	ShortStop+UPDATEPROC
	clr.l	ThirdBase+UPDATEPROC
	clr.l	Catcher+UPDATEPROC
	clr.l	LeftField+UPDATEPROC
	clr.l	CenterField+UPDATEPROC
	clr.l	RightField+UPDATEPROC
	clr.l	FirstRunner+UPDATEPROC
	clr.l	SecondRunner+UPDATEPROC
	clr.l	ThirdRunner+UPDATEPROC
	clr.l	HomeRunner+UPDATEPROC

	clr.l	PlayerL+INPUTROUTINE
	clr.l	PlayerR+INPUTROUTINE

	rts

****************************************************************************
* Display() - Call the display routine for each object                     *
*				*
* Parameters: NONE			*
* Returns: NONE			*
* Uses: all			*
****************************************************************************
	.export	object_cnt,objdis_cnt
Display:
	TRANS	ON	; Turn On Transparency
	PLANES	#PLANEA	; All Displays On Plane A
	clr.w	object_cnt
	clr.w	objdis_cnt
	move.l	Objects,a5	; Load Address Of First Object
Display_1:
	move.l	a5,d0	; Check If Pointer Valid
	beq.s	Display_9	; Exit If Not Defined
	move.l	DISPLAYPROC(a5),a0	; Load Address Of Display Routine
	move.l	a0,d0	; Check If Pointer Valid
	beq.s	Display_2	; Branch If No Display
	add.w	#1,object_cnt
	PUSHL	a5	; Save Pointer To Current Object
	jsr	(a0)	; Execute Display Routine
	POPL	a5	; Retrieve Pointer To Current Object
Display_2:
	move.l	NEXTOBJECT(a5),a5	; Load Pointer To Next Object
	bra	Display_1
Display_9:
	rts

****************************************************************************
* Update() - Call the update routine for each object                       *
*				*
* Parameters: NONE			*
* Returns: NONE			*
* Uses: all			*
****************************************************************************
Update:
	move.l	Objects,a5	; Load Address Of First Object
Update_1:
	cmp.l	#Baseball,a5	; Check If Baseball Object
	beq.s	Update_2	; Don't Do It Now
	move.l	a5,d0	; Check If Pointer Valid
	beq.s	Update_3	; Exit If Not Defined
	move.l	UPDATEPROC(a5),a0	; Load Address Of Update Routine
	move.l	a0,d0	; Check If Pointer Valid
	beq.s	Update_2	; Branch If No Update
	PUSHL	a5	; Save Pointer To Current Object
	jsr	(a0)	; Execute Update Routine
	POPL	a5	; Retrieve Pointer To Current Object
Update_2:
	move.l	NEXTOBJECT(a5),a5 	; Load Pointer To Next Object
	bra	Update_1
Update_3:
	move.l	#Baseball,a5	; Time To Update Ball Object
	move.l	UPDATEPROC(a5),a0	; Load Address Of Update Routine
	move.l	a0,d0	; Check If Pointer Valid
	beq.s	Update_4	; Branch If No Update
	jsr	(a0)	; Execute Update Routine
Update_4:
	rts

****************************************************************************
* AllocObject() - Allocate an object from the free list                    *
*				*
* Parameters: D1 - Set If Collidable Object		*
* Returns: A0 - Pointer to the allocated object (0 - if none available)	*
* Uses: ALL			*
****************************************************************************
AllocObject:
	move.l	FreeObjects,d0	; Load Address Of Next Free Object
	bne	AllocObj_3	; Branch If One Available

	move.l	Objects,a0	; Load Pointer To Top Object
AllocObj_1:
	move.l	a0,d0	; Check If End Of List
	beq	AllocObj_9	; Branch If None Found
;	cmp.b	#projbank,BANK(a0)	; Check If Blood
;	beq.s	AllocObj_4	; Branch If Blood Object Found
	move.l	NEXTOBJECT(a0),a0	; Load Next Object
	bra.s	AllocObj_1

AllocObj_3:
	move.l	d0,a0	; Move To A Register
	move.l	Objects,d0	; Load Pointer To Top Object
	move.l	NEXTOBJECT(a0),FreeObjects
	move.l	d0,NEXTOBJECT(a0)	; Store Pointer To Top Object
	move.l	a0,Objects	; Store New Top
AllocObj_4:
	move.w	#1,DURATION(a0)	; Initialize Duration
	move.w	#-1,PICTURE(a0)	; Store Non-Displayable Object
	move.b	#-1,DAMP(a0)	; Set For No Gravity
	clr.w	XVELOCITY(a0)	; Clear X Velocity
	clr.w	YVELOCITY(a0)	; Clear Y Velocity
	clr.b	FLIPFLAG(a0)	; Clear The Flip Flag
	clr.b	FLOPFLAG(a0)	; Clear The Flop Flag
	clr.b	OBJECTTYPE(a0)	; Clear The Object Type
	clr.l	UPDATEPROC(a0)	; Clear Update Procedure
	clr.l	DISPLAYPROC(a0)	; Clear Display Procedure
	clr.l	ALWAYSROUTINE(a0)	; Clear The Always Procedure
	clr.l	CHILD(a0)	; Clear Child Pointer
	clr.w	ANCHORX(a0)	; Clear X Anchor
	clr.w	ANCHORY(a0)	; Clear Y Anchor
	clr.w	BLITWIDTH(a0)	; Clear Blit Width
	clr.w	BLITHEIGHT(a0)	; Clear Blit Height
	move.w	#0x256,XSCALE(a0)	; Set For Full Scale
	move.w	#0x256,YSCALE(a0)	; Set For Full Scale
	move.w	#0x256,SCALEFACTOR(a0)	; Set For Full Scale
	clr.b	DELETED(a0)	; Not Delected Yet
	clr.b	BOUNCESOUND(a0)	; Clear The Bounce Sound
	clr.b	STATIONARY(a0)	; Set As Non-Stationary
	clr.b	VSPRITETYPE(a0)	; Not A Velocity Sprite
	move.l	#0x40,GRAVITY(a0)	; Store Gravity
AllocObj_9:
	move.l	a0,d0	; Save Address Of Allocated Object
	rts

****************************************************************************
* DeallocObject() - Flag an object to be deallocated                       *
*				*
* Parameters: NONE			*
* Returns: NONE			*
* Uses: NONE			*
****************************************************************************
DeallocObject:
	move.l	a5,d0	; Check If Object Allocated
	beq.s	Dealloc_1	; Branch If Not
	move.b	#1,DELETED(a5)	; Flag A Deleted Object
Dealloc_1:
	rts

DeallocObjecta1:
	move.l	a1,d0	; Check If Object Allocated
	beq.s	Dealloca1_1	; Branch If Not
	move.b	#1,DELETED(a1)	; Flag A Deleted Object
Dealloca1_1:
	rts

****************************************************************************
* BlitHostObj() - Routine For Displaying An Object using Host Write	*
*				*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL			*
****************************************************************************
BlitHostObj:
	tst.l	PARENT(a5)	; Check Text
	beq	BlitHostObj_9	; exit if null
	PUSHL	a5
hw_10:
	tst.b	AQStat	; check if command queue idle
	beq	hw_20	; br if nothing happening
	nop		; can't do delays
	nop
	nop
	nop
	nop
	nop
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

	POPL	a5
	clr.w	d0
	move.b	PALETTE(a5),d0	; palette #
	move.w	d0,PALSELA+2

	move.w	BLITWIDTH(a5),A_WIDTH	; width
	move.w	BLITHEIGHT(a5),A_HEIGHT	; 512 actually is 256
	move.w	XPOSITION(a5),A_STARTX	; xpos
	move.w	PageLine,d0	; get page being displayed
	eori.w	#$200,d0	; put data on page not being displayed
	add.w	YPOSITION(a5),d0	; ypos
	move.w	d0,A_STARTY

	move.w	#$3,A_STATE
;;	move.w	#$3,last_cmd

	move.w	BLITWIDTH(a5),d0 	; width x the height
	mulu	BLITHEIGHT(a5),d0
	move.l	PARENT(a5),a0	; art address to image
hw_byte0:
	btst.b	#3,A_STATUS+1	; check data register full bit
	bne	hw_byte0	; br if not data not ready
	move.b	(a0)+,A_USERREG+1	; write to ASIC
hw_byte1:
	move.b	d0,WATCHDOG	; will be spending some time here
	dbf	d0,hw_byte0	; check done writing data

BlitHostObj_9:
	rts

****************************************************************************
* BlitClipObj() - Generic Routine For Displaying A Clipped Object	*
*				*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL			*
****************************************************************************
BlitClipObj:
	SETCLIP	XCLIP1(a5),YCLIP1(a5),XCLIP2(a5),YCLIP2(a5)
	jsr	BlitObject	;fall thru
	SETCLIP	#0,#-60,#RGTSCR,#BOTSCR
	rts

****************************************************************************
* BlitObject() - Generic Routine For Displaying An Object	*
*				*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL			*
****************************************************************************
BlitObject:
	move.w	PICTURE(a5),d3	; Frame Number
	cmp.w	#-1,d3	; the -1 is in the low byte (not extended)
	beq	BlitExit
	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	BlitObj_1	; Branch If Not Flipped
	FLIP	ON	; Turn On Flipping
BlitObj_1:
	IMAGES	BANK(a5)	; Load Image Bank

	move.w	XPOSITION(a5),d4	; 2 byte x value
	move.w	YPOSITION(a5),d5	; Load Y Position
	APALETTE	PALETTE(a5)	; Palette Number

	cmp.w	#BOTSCR,d5	; Check If Off Bottom Of Screen
	bge.s	BlitExit	; Exit If Off Screen

	lsl.w	#1,d3	; convert image index to offset
	move.w	d3,d0
	lsl.w	#1,d3
	add.w	d0,d3	; Multiply By Six
	move.l	bankaddress,a2	; Load Bank base Address

	move.w	d5,d0	; Move Y Position To D0
	clr.w	d1	; Clear D1
	move.b	2(a2,d3.w),d1	; Load Blit Height
	add.w	d1,d0	; Add In Blit Height
	bmi.s	BlitExit	; Exit If Off Top Of Screen

	move.w	d4,d0	; Move X Position To D0
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	BlitObj_5	; Branch If Not Flipped
	tst.w	d0	; Check If Off Left
	bmi.s	BlitExit	; Exit If Off Screen
	sub.w	0(a2,d3.w),d0	; Subtract Off Width
	cmp.w	#RGTSCR,d0	; Check If Off Right Of Screen
	bge.s	BlitExit	; Exit If Off Screen
	bra.s	BlitObj_6

BlitObj_5:
	cmp.w	#RGTSCR,d0	; Check If Off Right Of Screen
;obe	bge.s	BlitExit	; Exit If Off Screen
	add.w	0(a2,d3.w),d0	; Add In Width
	subq.w	#1,d0
;obe	bmi.s	BlitExit	; Branch If Off Left Of Screen
BlitObj_6:
	move.w	PICTURE(a5),d3	; Reload Frame Number
	jsr	Blit	; Blit The Object
	add.w	#1,objdis_cnt
	move.w	BlitHeight,BLITHEIGHT(a5)
	move.w	BlitWidth,BLITWIDTH(a5)
BlitExit:
	rts

****************************************************************************
* BlitCentered() - Generic Routine For Displaying An Object	*
*				*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL			*
****************************************************************************
BlitCentered:
	move.w	PICTURE(a5),d3	; Frame Number
	cmp.b	#-1,d3	; the -1 is in the low byte (not extended)
	beq	BlitCExit
	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	BlitCen_1	; Branch If Not Flipped
	FLIP	ON	; Turn On Flipping
BlitCen_1:
	IMAGES	BANK(a5)	; Load Image Bank

	move.w	XPOSITION(a5),d4	; 2 byte x value
	move.w	YPOSITION(a5),d5	; Load Y Position
	APALETTE	PALETTE(a5)	; Palette Number

	lsl.w	#1,d3	; convert image index to offset
	move.w	d3,d0
	lsl.w	#1,d3
	add.w	d0,d3	; Multiply By Six
	move.l	bankaddress,a2	; Load Bank base Address

	move.w	0(a2,d3.w),d6	; Load Blit Width
	clr.w	d7	; Clear D1
	move.b	2(a2,d3.w),d7	; Load Blit Height

	move.w	d6,d0	; Move Blit Width To d0
	asr.w	#1,d0	; Divide By Two
	sub.w	d0,d4	; Shift To Middle Of Object

	move.w	d7,d0	; Move Blit Height To d0
	asr.w	#1,d0	; Divide By Two
	sub.w	d0,d5	; Shift To Middle Of Object

	cmp.w	#BOTSCR,d5	; Check If Off Bottom Of Screen
	bge.s	BlitCExit	; Exit If Off Screen

	move.w	d5,d0	; Move Y Position To D0
	add.w	d7,d0	; Add In Blit Height
	bmi.s	BlitCExit	; Exit If Off Top Of Screen

	move.w	d4,d0	; Move X Position To D0
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	BlitCen_5	; Branch If Not Flipped
	tst.w	d0	; Check If Off Left
	bmi.s	BlitCExit	; Exit If Off Screen
	sub.w	d6,d0	; Subtract Off Width
	cmp.w	#RGTSCR,d0	; Check If Off Right Of Screen
	bge.s	BlitCExit	; Exit If Off Screen
	bra.s	BlitCen_6

BlitCen_5:
	cmp.w	#RGTSCR,d0	; Check If Off Right Of Screen
	bge.s	BlitCExit	; Exit If Off Screen
	add.w	0(a2,d3.w),d0	; Add In Width
	subq.w	#1,d0
	bmi.s	BlitCExit	; Branch If Off Left Of Screen
BlitCen_6:
	move.w	PICTURE(a5),d3	; Reload Frame Number
	jsr	Blit	; Blit The Object
	add.w	#1,objdis_cnt
	move.w	BlitHeight,BLITHEIGHT(a5)
	move.w	BlitWidth,BLITWIDTH(a5)
BlitCExit:
	rts

****************************************************************************
* FlopObject() - Generic Routine For Displaying An Object	*
*				*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL			*
****************************************************************************
FlopObject:
	move.w	PICTURE(a5),d3	; Frame Number
	cmp.b	#-1,d3	; the -1 is in the low byte (not extended)
	beq	FlopExit
	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	FlopObj_1	; Branch If Not Flipped
	FLIP	ON	; Turn On Flipping
FlopObj_1:
	FLOP	ON
	IMAGES	BANK(a5)	; Load Image Bank

	move.w	XPOSITION(a5),d4	; 2 byte x value
	move.w	YPOSITION(a5),d5	; Load Y Position
FlopObj_4:
	APALETTE	PALETTE(a5)	; Palette Number

	tst.w	d5	; Check If Off Top Of Screen
	bmi.s	FlopExit	; Exit If Off Screen

	lsl.w	#1,d3	; convert image index to offset
	move.w	d3,d0
	lsl.w	#1,d3
	add.w	d0,d3	; Multiply By Six
	move.l	bankaddress,a2	; Load Bank base Address

	move.w	d5,d0	; Move Y Position To D0
	clr.w	d1	; Clear D1
	move.b	2(a2,d3.w),d1	; Load Blit Height
	sub.w	d1,d0	; Subtract Blit Height
	cmp.w	#BOTSCR,d0	; Check If Off Bottom Of Screen
	bge.s	FlopExit	; Exit If Off Bottom Of Screen

	move.w	d4,d0	; Move X Position To D0
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	FlopObj_5	; Branch If Not Flipped
	tst.w	d0	; Check If Off Left
	bmi.s	FlopExit	; Exit If Off Screen
	sub.w	0(a2,d3.w),d0	; Subtract Off Width
	cmp.w	#RGTSCR,d0	; Check If Off Right Of Screen
	bge.s	FlopExit	; Exit If Off Screen
	bra.s	FlopObj_6

FlopObj_5:
	cmp.w	#RGTSCR,d0	; Check If Off Right Of Screen
	bge.s	FlopExit	; Exit If Off Screen
	add.w	0(a2,d3.w),d0	; Add In Width
	subq.w	#1,d0
	bmi.s	FlopExit	; Branch If Off Left Of Screen
FlopObj_6:
	move.w	PICTURE(a5),d3	; Reload Frame Number
	jsr	Blit	; Blit The Object
	add.w	#1,objdis_cnt
	move.w	BlitHeight,BLITHEIGHT(a5)
	move.w	BlitWidth,BLITWIDTH(a5)
FlopExit:
	FLOP	OFF
	rts

****************************************************************************
* BlitAObject() - Generic Routine For Displaying An Anchored Object	*
*				*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL			*
****************************************************************************
BlitAObject:
	move.w	PICTURE(a5),d3	; Frame Number
	cmp.b	#-1,d3	; the -1 is in the low byte (not extended)
	beq	BlitAExit	; Exit If No Picture
	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	BlitAObj_1	; Branch If Not Flipped
	FLIP	ON	; Turn On Flipping
BlitAObj_1:
	IMAGES	BANK(a5)	; Load Image Bank

	move.w	XPOSITION(a5),d4  ; 2 byte x value
	move.w	YPOSITION(a5),d5	; Load Y Position
	APALETTE	PALETTE(a5)	; Palette Number

	GETANCHOR d3	; Get Anchor Info

	add.w	BlitY,d5	; add relative Y coord
	add.w	BlitX,d4	; add relative X coord

	move.w	BlitX,ANCHORX(a5)	; Save Anchor Info
	move.w	BlitY,ANCHORY(a5)	; Save Anchor Info

	clr.w	BlitX	; Clear X Offset
	clr.w	BlitY	; Clear Y Offset

	cmp.w	#BOTSCR,d5	; Check If Off Bottom Of Screen
	bge.s	BlitAExit	; Exit If Off Screen

	lsl.w	#1,d3	; convert image index to offset
	move.w	d3,d0
	lsl.w	#1,d3
	add.w	d0,d3	; Multiply By Six
	move.l	bankaddress,a2	; Load Bank base Address

	move.w	d5,d0	; Move Y Position To D0
	clr.w	d1	; Clear D1
	move.b	2(a2,d3.w),d1	; Load Blit Height
	add.w	d1,d0	; Add In Blit Height
	bmi.s	BlitAExit	; Exit If Off Top Of Screen

	move.w	d4,d0	; Move X Position To D0
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	BlitAObj_5	; Branch If Not Flipped
	tst.w	d0	; Check If Off Left
	bmi.s	BlitAExit	; Exit If Off Screen
	sub.w	0(a2,d3.w),d0	; Subtract Off Width
	cmp.w	#RGTSCR,d0	; Check If Off Right Of Screen
	bge.s	BlitAExit	; Exit If Off Screen
	bra.s	BlitAObj_6

BlitAObj_5:
	cmp.w	#RGTSCR,d0	; Check If Off Right Of Screen
	bge.s	BlitAExit	; Exit If Off Screen
	add.w	0(a2,d3.w),d0	; Add In Width
	bmi.s	BlitAExit	; Branch If Off Left Of Screen

BlitAObj_6:
	move.w	PICTURE(a5),d3	; Reload Frame Number
	jsr	Blit	; Blit The Object
	add.w	#1,objdis_cnt
	move.w	BlitHeight,BLITHEIGHT(a5)
	move.w	BlitWidth,BLITWIDTH(a5)
BlitAExit:
	rts

****************************************************************************
* BlitScObject() - Displaying An OScaled Screen Guys	*
*				*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL			*
****************************************************************************
SCALF	equ 228	;scale factor
SILVERLT	equ 468	; silver screen limit
SILVERRT	equ 886
SILVERY	equ 40	; ypos for chars on silver screen

	.export	SwitchTv	; flag to turn action off of chars
BlitSAObject:
	move.w	PICTURE(a5),d3	; Frame Number
	cmp.b	#-1,d3	; the -1 is in the low byte (not extended)
	beq	BlitSAExit	; Exit If No Picture

	PUSHL	a0-a1/a5	; Save Registers
	OSCALE	#SCALF,#SCALF	; 128 Scale Images Down
	POPL	 a0-a1/a5

	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	BlitSAObj_1	; Branch If Not Flipped
	FLIP	ON	; Turn On Flipping
BlitSAObj_1:
	IMAGES	BANK(a5)	; Load Image Bank
	tst.b	COUNTER(a5)	; this holds BANKOVERFLOWFLAG value
	beq.s	BlitSAObj_1a
	clr.w	d0
	move.b	BANK(a5),d0
	add.b	#1,d0
	IMAGES	d0
BlitSAObj_1a:
	APALETTE	PALETTE(a5)	; Palette Number

	move.b	#1,SwitchTv	; flag to turn action off of chars
	move.w	XPOSITION(a5),d4	; screen
;	cmp.w	#SILVERLT,d4
;	blt	BlitSAExit1
;	cmp.w	#SILVERRT,d4
;	bgt	BlitSAExit1

	clr.b	SwitchTv	; 0 on 1 off

	muls.w	#SCALF,d4
	asr.l	#8,d4

;	move.w	CameraX,d0
	add.w	#192,d0
	muls.w	#SCALF,d0
	asr.l	#8,d0
	sub.w	#192,d0
	neg.w	d0
	add.w	d0,d4	; player x + Camera

	move.w	YPOSITION(a5),d5	; screen
	muls.w	#SCALF,d5
	asr.l	#8,d5

;	move.w	CameraY,d0	; fighter true Y
	add.w	#120,d0
	muls.w	#SCALF,d0
	asr.l	#8,d0
	sub.w	#120,d0
	neg.w	d0
	add.w	d0,d5	; player x + Camera
	sub.w	#SILVERY,d5

	clr.w	d3
	move.l	B_DATAPTR(a5),a3	; Load Address Of Dots Data
	move.w	Legs(a3),d3	; Load Y Offset
	cmp.w	#-1,d3	; Image Number Valid
	beq	BlitSAExit1

	clr.w	d0
	move.w	LegsX(a3),d0	; Load Y Offset
	muls.w	#SCALF,d0
	asr.l	#8,d0	; divde in half for oscale

	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Is Image Flipped
	beq.s	BlitSA_3
	sub.w	d0,d4	; Subtract X Offset if Flipped
	FLIP	ON	; Turn On Flipping
	bra.s	BlitSA_4

BlitSA_3:
	add.w	d0,d4	; Add X Offset if Not Flipped
BlitSA_4:
	move.w	LegsY(a3),d0	; Load Y Offset
	add.w	#YBIAS,d0	; UnBias Y Offset
	muls.w	#SCALF,d0
	asr.l	#8,d0	; divide by 2 for oscale
	add.w	d0,d5	; Add in Y Offset

	jsr	Blit	; Draw Leg Shadow

BlitSAExit1:
	PUSHL	a0-a1/a5	; Save Registers
	OSCALE	#$100,#$100	; Scale Images Down
	ROT_OFF
	POPL	 a0-a1/a5
BlitSAExit:
	rts

****************************************************************************
* SkewObject() - Generic Routine For Displaying A Skewed Object	*
*  two pixel drop line - 45 degree angle - uncompressed 	*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL		                 	*
****************************************************************************
SkewObject:
	WIDTHPIX	ON
	ISCALE     #$100,#$80	; Set For Half Scale On Y

	IMAGES	BANK(a5)	; Set Bank Number
	APALETTE	PALETTE(a5)	; Palette Number

	move.w	XPOSITION(a5),d4	; 2 byte x value
SkewObj_3:
	move.w	d4,d0	; Move X Position To D0
	sub.w	#(RGTSCR-156)/2,d0	; Subtract Middle Position
	
;	asl.w	#1,d0	; Multiply By Two

	PUSHL	d4
           DXDY      #0,#0,d0,#$80
	POPL	d4

	move.w	YPOSITION(a5),d5	; Load Y Position
	move.w	PICTURE(a5),d3	; Frame Number
	jsr	Blit	; Blit The Object

	WIDTHPIX	OFF

	DXDY	#0,#0,#0,#0x100
           ISCALE	#$100,#$100

	rts

****************************************************************************
* SkewObjectFast() - Generic Routine For Displaying A Skewed Object	*
*  one pixel drop line - 45 degree angle - compressed	*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL		                 	*
****************************************************************************
SkewObjectFast:
	WIDTHPIX	ON

	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	SkewObjFast_1	; Branch If Not Flipped
	FLIP	ON	; Turn On Flipping
SkewObjFast_1:
	IMAGES	BANK(a5)	; Set Bank Number
	APALETTE	PALETTE(a5)	; Palette Number

	move.w	XPOSITION(a5),d4	; 2 byte x value
SkewObjFast_3:
	.export	skwnum
	clr.l	d0	; [((-0x1fe*CameraX)/384)+0xff]
;	move.w	CameraX,d0	; skewing based on Camerax
	ext.l	d0	; Extend To Long
	muls	#0x1FE,d0	; 510
	divs	#480,d0	; Screensize * numberof 
	sub.w	#0xFF,d0	; 255
	neg	d0	; negated to make negative
	move.w	d0,skwnum	
	
	PUSHL	d4	; save d4 which is BlitX
           DXDY      #0,#0,d0,#$100
	POPL	d4

	move.w	YPOSITION(a5),d5	; Load Y Position

	lsl.w	#1,d3	; convert image index to offset
	move.w	d3,d0
	lsl.w	#1,d3
	add.w	d0,d3	; Multiply By Six
	move.l	bankaddress,a2	; Load Bank base Address

	move.w	d4,d0	; Move X Position To D0
	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	SkewObjFast_5	; Branch If Not Flipped
	sub.w	0(a2,d3.w),d0	; Subtract Off Width
	FLIP	ON	; Turn On Flipping

SkewObjFast_5:
	move.w	PICTURE(a5),d3	; Frame Number
	jsr	Blit	; Blit The Object

ExitFast:
	WIDTHPIX	OFF
	DXDY	#0,#0,#0,#0x100
	rts

****************************************************************************
* BlitRSObject() - Generic Routine For Displaying A Repeating Skewed Object*
*				*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL			*
****************************************************************************
BlitRSObject:
	WIDTHPIX	ON
	ISCALE     #$100,#$80	; Set For Half Scale On Y

	IMAGES	BANK(a5)	; Set Bank Number
	APALETTE	PALETTE(a5)	; Palette Number

	move.w	XPOSITION(a5),d4	; 2 byte x value
BlitRSObj_3:
	move.w	d4,d0	; Move X Position To D0
	sub.w	#(RGTSCR-156)/2,d0	; Subtract Middle Position
	
;	asl.w	#1,d0	; Multiply By Two

	PUSHL	d4
	DXDY	#0,#0,d0,#$80
	POPL	d4

	move.w	YPOSITION(a5),d5	; Load Y Position
	move.w	d4,XSCALE(a5)	; Save X Position
	move.w	PICTURE(a5),d3	; Frame Number
	jsr	Blit	; Blit The Object

	WIDTHPIX	OFF

	DXDY	#0,#0,#0,#0x100
	ISCALE	#$100,#$100

	rts

****************************************************************************
* BlitSineObj() - Generic Routine For Displaying A Floating Object	*
*				*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL			*
****************************************************************************
BlitSineObj:
	move.w	PICTURE(a5),d3	; Frame Number
	cmp.b	#-1,d3	; the -1 is in the low byte (not extended)
	beq	BlitSExit	; Exit If No Picture
	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	BlitSObj_1	; Branch If Not Flipped
	FLIP	ON	; Turn On Flipping
BlitSObj_1:
	IMAGES	BANK(a5)	; Load Image Bank

	move.w	XPOSITION(a5),d4	; 2 byte x value
	move.w	YPOSITION(a5),d5	; Load Y Position
	move.l	#SineTable,a0	; Load Address Of Sine Table
	move.w	XVELOCITY(a5),d1	; Load Sine Table Index
	move.b	(a0,d1.w),d0	; Load Offset From Sine Table
	ext.w	d0	; Extend To A Word
	add.w	d0,d5	; Add Into Y Position
	add.w	YVELOCITY(a5),d1	; Increment Index
	and.w	#0xFF,d1	; Force Between 0 and 255
	move.w	d1,XVELOCITY(a5)	; Save Next Index

	APALETTE	PALETTE(a5)	; Palette Number

	cmp.w	#BOTSCR,d5	; Check If Off Bottom Of Screen
	bge.s	BlitSExit	; Exit If Off Screen

	lsl.w	#1,d3	; convert image index to offset
	move.w	d3,d0
	lsl.w	#1,d3
	add.w	d0,d3	; Multiply By Six
	move.l	bankaddress,a2	; Load Bank base Address

	move.w	d5,d0	; Move Y Position To D0
	clr.w	d1	; Clear D1
	move.b	2(a2,d3.w),d1	; Load Blit Height
	add.w	d1,d0	; Add In Blit Height
	bmi.s	BlitSExit	; Exit If Off Top Of Screen

	move.w	d4,d0	; Move X Position To D0
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	BlitSObj_5	; Branch If Not Flipped
	tst.w	d0	; Check If Off Left
	bmi.s	BlitSExit	; Exit If Off Screen
	sub.w	0(a2,d3.w),d0	; Subtract Off Width
	cmp.w	#RGTSCR,d0	; Check If Off Right Of Screen
	bge.s	BlitSExit	; Exit If Off Screen
	bra.s	BlitSObj_6

BlitSObj_5:
	cmp.w	#RGTSCR,d0	; Check If Off Right Of Screen
	bge.s	BlitSExit	; Exit If Off Screen
	add.w	0(a2,d3.w),d0	; Add In Width
	bmi.s	BlitSExit	; Branch If Off Left Of Screen

BlitSObj_6:
	move.w	PICTURE(a5),d3	; Reload Frame Number
	GETANCHOR d3	; Get Anchor Info
	jsr	Blit	; Blit The Object
	add.w	#1,objdis_cnt
BlitSExit:
	rts

****************************************************************************
* BlitRObject() - Generic Routine For Displaying A Repeating Object	*
*				*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL			*
****************************************************************************
BlitRObject:
	move.w	PICTURE(a5),d3	; Frame Number
	cmp.b	#-1,d3	; the -1 is in the low byte (not extended)
	beq	BlitRExit
	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	BlitRObj_1	; Branch If Not Flipped
	FLIP	ON	; Turn On Flipping
BlitRObj_1:
	IMAGES	BANK(a5)	; Load Image Bank

	move.w	XPOSITION(a5),d4	; 2 byte x value
	move.w	YPOSITION(a5),d5	; Load Y Position
	APALETTE	PALETTE(a5)	; Palette Number

	cmp.w	#BOTSCR,d5	; Check If Off Bottom Of Screen
	bge.s	BlitRExit	; Exit If Off Screen

	lsl.w	#1,d3	; convert image index to offset
	move.w	d3,d0
	lsl.w	#1,d3
	add.w	d0,d3	; Multiply By Six
	move.l	bankaddress,a2	; Load Bank base Address

	move.w	d5,d0	; Move Y Position To D0
	clr.w	d1	; Clear D1
	move.b	2(a2,d3.w),d1	; Load Blit Height
	add.w	d1,d0	; Add In Blit Height
	bmi.s	BlitRExit	; Exit If Off Top Of Screen

	move.w	d4,d0	; Move X Position To D0
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	BlitRObj_5	; Branch If Not Flipped
	tst.w	d0	; Check If Off Left
	bmi.s	BlitRExit	; Exit If Off Screen
	sub.w	0(a2,d3.w),d0	; Subtract Off Width
	cmp.w	#RGTSCR,d0	; Check If Off Right Of Screen
	bge.s	BlitRExit	; Exit If Off Screen
	bra.s	BlitRObj_6

BlitRObj_5:
	cmp.w	#RGTSCR,d0	; Check If Off Right Of Screen
	bge.s	BlitRExit	; Exit If Off Screen
	add.w	0(a2,d3.w),d0	; Add In Width
	bmi.s	BlitRExit	; Branch If Off Left Of Screen

BlitRObj_6:
	move.w	PICTURE(a5),d3	; Reload Frame Number
	jsr	Blit	; Blit The Object
	add.w	#1,objdis_cnt
BlitRExit:
	rts

****************************************************************************
* ScaledObject() - Generic Routine For Displaying An Object	*
*				*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL			*
****************************************************************************
ScaledObject:
	move.w	PICTURE(a5),d3	; Frame Number
	cmp.b	#-1,d3	; the -1 is in the low byte (not extended)
	beq	ScaleExit
	LOOKAHEAD OFF
	FLIP	OFF	; Turn Off Flipping
	move.w	PICTURE(a5),d3	; Frame Number
	move.w	XPOSITION(a5),d4	; 2 byte x value
	move.w	YPOSITION(a5),d5	; Load Y Position

	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	ScaleObj_1	; Branch If Not Flipped
	FLIP	ON	; Turn On Flipping
ScaleObj_1:
	tst.b	FLOPFLAG(a5)	; Check If Flipped
	beq.s	ScaleObj_2	; Branch If Not Flipped
	FLOP	ON	; Turn On Flipping
ScaleObj_2:
	IMAGES	BANK(a5)	; Load Image Bank
	APALETTE	PALETTE(a5)	; Palette Number
	GETANCHOR	d3	; Get The Anchor

	move.w	BlitX,d0	; Load X Anchor
	ext.l	d0	; Extend To Long
	asl.l	#8,d0	; Multiply By 256
	divs	XSCALE(a5),d0	; Divide By X Scale
	add.w	d0,d4	; Add In Offset

	move.w	BlitY,d0	; Load Y Anchor
	ext.l	d0	; Extend To Long
	asl.l	#8,d0	; Multiply By 256
	divs	YSCALE(a5),d0	; Divide By Y Scale
	add.w	d0,d5	; Add In Offset

	clr.w	BlitX	; Clear The Anchors
	clr.w	BlitY

	ISCALE	XSCALE(a5),YSCALE(a5)	; Set Scale
	move.w	PICTURE(a5),d3	; Frame Number
	jsr	Blit	; Blit The Object
	add.w	#1,objdis_cnt
	ISCALE	#0x100,#0x100	; Set Back To Normal
	LOOKAHEAD ON
	FLOP	OFF	; Turn Off Flopping
ScaleExit:
	rts

****************************************************************************
* OScaledObject() - Generic Routine For Displaying An Object	*
*				*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL			*
****************************************************************************
OScaledObject:
	move.w	PICTURE(a5),d3	; Frame Number
	cmp.b	#-1,d3	; the -1 is in the low byte (not extended)
	beq	OScaleExit
	LOOKAHEAD ON
	FLIP	OFF	; Turn Off Flipping

	PUSHL	a0-a1/a5	; Save Registers
	move.w	XCLIP2(a5),skwnum
	OSCALE	skwnum,skwnum	; 128 Scale Images Down
	POPL	 a0-a1/a5

	move.w	PICTURE(a5),d3	; Frame Number
	move.w	XPOSITION(a5),d4	; 2 byte x value
	move.w	YPOSITION(a5),d5	; Load Y Position

	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	OScaleObj_1	; Branch If Not Flipped
	FLIP	ON	; Turn On Flipping
OScaleObj_1:
	tst.b	FLOPFLAG(a5)	; Check If Flipped
	beq.s	OScaleObj_2	; Branch If Not Flipped
	FLOP	ON	; Turn On Flipping
OScaleObj_2:
	IMAGES	BANK(a5)	; Load Image Bank

	APALETTE	PALETTE(a5)	; Palette Number
	GETANCHOR	d3	; Get The Anchor

	move.w	BlitX,d0	; Load X Anchor
	ext.l	d0	; Extend To Long
	muls.w	skwnum,d0
	asr.l	#8,d0	; divde in half for oscale

	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Is Image Flipped
	beq.s	BlitOSA_3
	sub.w	d0,d4	; Subtract X Offset if Flipped
	FLIP	ON	; Turn On Flipping
	bra.s	BlitOSA_4

BlitOSA_3:
	add.w	d0,d4	; Add X Offset if Not Flipped
BlitOSA_4:
	move.w	BlitY,d0	; Load Y Anchor
	add.w	#YBIAS,d0	; UnBias Y Offset
	muls.w	skwnum,d0
	asr.l	#8,d0	; divide by 2 for oscale
	add.w	d0,d5	; Add in Y Offset

	clr.w	BlitX	; Clear The Anchors
	clr.w	BlitY

	move.w	PICTURE(a5),d3	; Frame Number
	jsr	Blit	; Blit The Object
	add.w	#1,objdis_cnt

	PUSHL	a0-a1/a5	; Save Registers
	OSCALE	#$100,#$100	; Scale Images Down
	ROT_OFF
	POPL	 a0-a1/a5

	LOOKAHEAD ON
	FLOP	OFF	; Turn Off Flopping
OScaleExit:
	rts

****************************************************************************
* TextObject() - Generic Routine For Displaying A Text String	*
*				*
* Parameters: A5 - Pointer to Object		*
* Returns: NONE			*
* Uses: ALL			*
****************************************************************************
	.export	ClipTextObj

ClipTextObj:
	SETCLIP	XCLIP1(a5),YCLIP1(a5),XCLIP2(a5),YCLIP2(a5)
	jsr	TextObject
	SETCLIP	#0,#0,#RGTSCR,#BOTSCR
	rts

TextObject:
	tst.l	PARENT(a5)	; Check Text
	beq	TextExit	; Exit If No Text

	clr.w	d2	; Clear D0
	move.b	BANK(a5),d2	; Load Bank Number
	move.l	#TextBanks,a0	; Load Address Of Banks
	move.b	(a0,d2.w),d1	; Load Font Bank Number
	IMAGES	d1	; Set Image Bank

	move.l	#TextSubs,a0	; Load Address Of Text Subroutines
	move.l	(a0,d2.w*4),a0	; Load Subroutine Address
	tst.l	a0	; Make Sure A Valid Address
	beq.s	TextExit	; Branch If Not
	jsr	(a0)	; Set Up Text

	move.w	XPOSITION(a5),d4	; 2 byte x value
	move.w	d4,prx_coor	;2 bytes in ram
	move.w	d4,prx_init	;2 bytes in ram
	move.w	YPOSITION(a5),pry_coor	;2 byte in ram

	APALETTE	PALETTE(a5)	; Setup Palette
	move.w	NUMBEROFCHARS(a5),d7	; Load Number Of Characters
	beq.s	TextExit	; Exit If No Characters
	move.w	STARTCHARACTER(a5),d6	; Load Starting Character
	move.l	PARENT(a5),a0	; Reload Text Address

	jsr	Print	; Print The String
TextExit:
	rts

TextSubs:
	dc.l	SetSysFont	; Bank 0
	dc.l	SetFontNeo1	; Bank 1
	dc.l	SetFontNeo2	; Bank 2
	dc.l	SetFontNeo3	; Bank 3
	dc.l	SetFontNeo4	; Bank 4
	dc.l	SetFontNeo5	; Bank 5
	dc.l	SetFontNeo6	; Bank 6
	dc.l	SetFontNeo7	; Bank 7

TextBanks:	
	dc.b	font0
	dc.b	neo1
	dc.b	neo2
	dc.b	neo3
	dc.b	neo4
	dc.b	neo5
	dc.b	neo6
	dc.b	neo7

SetCameraY:
	tst.b	ShakeYDist	; Check If Shaking
	beq.s	SetCamY_4	; Branch If Not
	subq.b	#1,ShakeYCnt	; Decrement Counter
	bne.s	SetCamY_4	; Branch If Counter Not Zero
	move.b	ShakeYPeriod,ShakeYCnt	; Reload Counter
	neg.b	ShakeYDist	; Negate The Distance
	bmi.s	SetCamY_4	; Branch If Negative
	subq.b	#2,ShakeYDist	; Decrement Distance
	bpl.s	SetCamY_4	; Branch If Positive
	clr.b	ShakeYDist	; Clear Distance
SetCamY_4:	
	rts

****************************************************************************
* Sort() - Remove deallocated objects and sort based on z position         *
*				*
* Parameters: NONE			*
* Returns: NONE			*
* Uses: ALL			*
****************************************************************************
Sort:
	move.l	Objects,a5	; Load Address Of First Object
Sort_1:
	move.l	a5,d0	; Check If Pointer Valid
	beq.s	Sort_4	; Exit If Not Defined
	tst.b	DELETED(a5)	; Check If Root Is Deallocated
	beq.s	Sort_3	; Branch If Active
	move.l	FreeObjects,a0	; Load Address Of Free Objects
	move.l	a5,FreeObjects	; Save New Free Object Pointer
	move.l	NEXTOBJECT(a5),a1	; Load Address Of Next Object
	move.l	a0,NEXTOBJECT(a5)	; Link Into Free Object Chain
	move.l	a1,a5	; Next Object Please
	move.l	a5,Objects	; Save Pointer To New First Object
	bra.s	Sort_1
Sort_2:
	move.l	a5,d0	; Check If Pointer Valid
	beq.s	Sort_4	; Exit If Not Defined
	tst.b	DELETED(a5)	; Check If Deallocated
	beq.s	Sort_3	; Branch If Still Active
	move.l	FreeObjects,a0	; Load Address Of Free Objects
	move.l	a5,FreeObjects	; Save New Free Object Pointer
	move.l	NEXTOBJECT(a5),a1	; Load Address Of Next Object
	move.l	a0,NEXTOBJECT(a5)	; Link Into Free Object Chain
	move.l	a1,NEXTOBJECT(a6)	; Save In Precious Object
	move.l	a1,a5	; Next Object Please
	bra	Sort_2
Sort_3:
	move.l	a5,a6	; Save Address Of Last Object
	move.l	NEXTOBJECT(a5),a5	; Load Pointer To Next Object
	bra	Sort_2
Sort_4:
	move.l	Objects,a5	; Load Address Of First Object
	move.l	#ObjPtrs,a4	; Load Address Of Object Pointers
	bra.s	Sort_5A
Sort_5:
	move.l	NEXTOBJECT(a5),a5	; Load Next Object Address
Sort_5A:	
	move.l	a5,(a4)+	; Store Object Address
	move.l	a5,d0	; Move To D0 For Compare
	bne.s	Sort_5	; Continue If More

Sort_6:
	move.l	#ObjPtrs,a0	; Load Address Of Object Pointers
	lea	4(a0),a1	; Load Address Of Second Pointer
	clr.b	d1	; Flag No Changes This Pass
Sort_7:
	move.l	(a0),a2	; Load Pointer To Object
	move.l	(a1),a3	; Load Pointer To Object
	move.w	ZPOSITION(a2),d0	; Load Z Position Of First Object
	cmp.w	ZPOSITION(a3),d0	; Compare With Other Z Position
	bls.s	Sort_8	; Branch If Less Than
	moveq	#1,d1	; Flag A Change
	move.l	a3,(a0)	; Swap The Entries
	move.l	a2,(a1)
Sort_8:
	lea	4(a0),a0	; Index To Next Pointer
	lea	4(a1),a1
	tst.l	(a1)	; Check If All Done
	bne.s	Sort_7	; Branch If More
	tst.b	d1	; Check If Any Changes
	bne.s	Sort_6	; Branch If Another Pass Needed
	move.l	#ObjPtrs,a0	; Load Address Of Object Pointers
	move.l	(a0)+,a1	; Load First Pointer
	move.l	a1,Objects	; Store First Object
Sort_9:
	move.l	(a0)+,d0	; Load Next Pointer
	move.l	d0,NEXTOBJECT(a1)	; Store Linking Pointer
	move.l	d0,a1	; Move On To Next Object
	tst.l	d0
	bne.s	Sort_9	; Continue If More

	move.l	FreeObjects,d0
	cmp.l	Objects,d0
	bne.s	Sort_A	
	jsr	ramdump
Sort_A:
	rts

SineTable:
	dc.b	0/32,2/32,5/32,7/32,10/32,12/32,15/32,17/32
	dc.b	20/32,22/32,24/32,27/32,29/32,31/32,34/32,36/32
	dc.b	38/32,41/32,43/32,45/32,47/32,49/32,51/32,54/32
	dc.b	56/32,58/32,60/32,62/32,63/32,65/32,67/32,69/32
	dc.b	71/32,72/32,74/32,76/32,77/32,79/32,80/32,82/32
	dc.b	83/32,84/32,86/32,87/32,88/32,89/32,90/32,91/32
	dc.b	92/32,93/32,94/32,95/32,96/32,96/32,97/32,98/32
	dc.b	98/32,99/32,99/32,99/32,100/32,100/32,100/32,100/32
	dc.b	100/32,100/32,100/32,100/32,100/32,99/32,99/32,99/32
	dc.b	98/32,98/32,97/32,96/32,96/32,95/32,94/32,93/32
	dc.b	92/32,91/32,90/32,89/32,88/32,87/32,86/32,84/32
	dc.b	83/32,82/32,80/32,79/32,77/32,76/32,74/32,72/32
	dc.b	71/32,69/32,67/32,65/32,63/32,62/32,60/32,58/32
	dc.b	56/32,53/32,51/32,49/32,47/32,45/32,43/32,41/32
	dc.b	38/32,36/32,34/32,31/32,29/32,27/32,24/32,22/32
	dc.b	20/32,17/32,15/32,12/32,10/32,7/32,5/32,2/32
	dc.b	0/32,-2/32,-5/32,-7/32,-10/32,-12/32,-15/32,-17/32
	dc.b	-20/32,-22/32,-24/32,-27/32,-29/32,-31/32,-34/32,-36/32
	dc.b	-38/32,-41/32,-43/32,-45/32,-47/32,-49/32,-51/32,-54/32
	dc.b	-56/32,-58/32,-60/32,-62/32,-63/32,-65/32,-67/32,-69/32
	dc.b	-71/32,-72/32,-74/32,-76/32,-77/32,-79/32,-80/32,-82/32
	dc.b	-83/32,-84/32,-86/32,-87/32,-88/32,-89/32,-90/32,-91/32
	dc.b	-92/32,-93/32,-94/32,-95/32,-96/32,-96/32,-97/32,-98/32
	dc.b	-98/32,-99/32,-99/32,-99/32,-100/32,-100/32,-100/32,-100/32
	dc.b	-100/32,-100/32,-100/32,-100/32,-100/32,-99/32,-99/32,-99/32
	dc.b	-98/32,-98/32,-97/32,-96/32,-96/32,-95/32,-94/32,-93/32
	dc.b	-92/32,-91/32,-90/32,-89/32,-88/32,-87/32,-86/32,-84/32
	dc.b	-83/32,-82/32,-80/32,-79/32,-77/32,-76/32,-74/32,-72/32
	dc.b	-71/32,-69/32,-67/32,-65/32,-63/32,-62/32,-60/32,-58/32
	dc.b	-56/32,-53/32,-51/32,-49/32,-47/32,-45/32,-43/32,-41/32
	dc.b	-38/32,-36/32,-34/32,-31/32,-29/32,-27/32,-24/32,-22/32
	dc.b	-20/32,-17/32,-15/32,-12/32,-10/32,-7/32,-5/32,-2/32

	.align	2

;***************************************************************************
;   DisplayField - Display Perspected Field		*
;                                                                          *
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
SWidth	equ	512
SHeight	equ	128

;EndGromAdr    equ	0xE1DD78+150*1466
;StartGromAdr  equ	0xBE5D6A+1466

EndGromAdr    equ	0xDBA718+150*1466
StartGromAdr  equ	0xB827A0+1466

YFudge	   equ	230

DisplayField:
	PUSHL	a5	; Save Object Address

	PLANES	#PLANEA	; All Displays On Plane A

	IMAGES	#Background	; Image Bank
	APALETTE	#P_STADIUM	; Palette Number
	BLIT	#sky02,#0,#0
	BLIT	#sky03,#128,#0
	BLIT	#sky04,#256,#0

	LOOKAHEAD	OFF
	IMAGES	#Field	; Load Image Bank
	APALETTE	#P_BIGFIELD	; Palette Number
	WIDTHPIX	ON
	CLIP	ON

	move.l	#FieldData2,a5	; Load Pointer To Data
	move.l	#ScaleYData2,ScalingY
	move.l	#ScaleXData2,ScalingX

	move.w	#255,FieldLine	; Set Y Coordinate


	tst.b	LockFieldXY	; Check If XY Locked
	bne	DspField_C	; Branch If It Is

	move.l	#EndGromAdr,d3	; Load GROM Address
	move.l	#Baseball,a0	; Load Address Of Ball
	move.l	WORLDX(a0),d1	; Load Ball X Position
	cmp.l	#0xA0000,d1	; Check For Maximum
	ble.s	DspField_1	; Branch If Fine
	move.l	#0xA0000,d1	; Load Maximum Value
DspField_1:
	cmp.l	#-0xA0000,d1	; Check For Maximum
	bge.s	DspField_Z	; Branch If Fine
	move.l	#-0xA0000,d1	; Load Minimum Value
DspField_Z:
	move.l	d1,FieldWorldX	; Save Fielder X Position

	tst.l	d1	; Check X Position
	bpl.s	DspField_A	; Branch If Positive
	neg.l	d1	; Make It Positive
DspField_A:
	move.l	d1,BaseballX	; Save X Position
	lsr.l	#8,d1	; Extract Inches
	lsr.l	#3,d1	; Extract Eight Inches
	lsl.l	#1,d1	; Multiply By Two
	move.l	#StadiumY,a1	; Load Address Of Stadium Y's
	move.w	(a1,d1.w),d1	; Load Y Distance
	lsl.l	#8,d1	; Shift Up To Inches
	add.l	#20*12*256,d1	; Add Twenty Feet
	move.l	WORLDY(a0),d0	; Load Ball Y Position
	move.l	d0,BaseballY	; Save Y Position
	cmp.l	d0,d1	; Check If In Range
	bge.s	DspField_B	; Branch If Fine
	move.l	d1,d0	; Use Maximum Y
	move.b	#1,LockFieldXY	; Force Field To Stay Put
DspField_B:
	move.l	d0,FieldWorldY	; Save Field World Y

	asr.l	#8,d0
	asr.l	#1,d0
	sub.w	#60,d0
	move.w	d0,FieldY
	add.w	#YFudge,d0

	neg.w	d0	; Negate The Value
	muls.w	#1466,d0	; Multiply By Width
	add.l	d0,d3	; Calculate Starting Line
	move.l	d3,FieldGromAdr	; Save Grom Address

	move.l	FieldWorldX,d0	; Load Ball X Position
	asr.l	#8,d0
	asr.l	#1,d0
	move.w	d0,FieldX
	tst.b	LockFieldXY	; Check If Locked
	beq.s	DspField_D	; Branch If Not
	move.l	FieldGromAdr,L_FieldGromAdr
	move.l	FieldWorldY,L_FieldWorldY
	move.w	FieldX,L_FieldX
	move.w	FieldY,L_FieldY
	move.l	BaseballX,L_BaseballX
	move.l	BaseballY,L_BaseballY
	bra.s	DspField_D
DspField_C:
	move.l	L_FieldGromAdr,FieldGromAdr
	move.l	L_FieldWorldY,FieldWorldY
	move.w	L_FieldX,FieldX
	move.w	L_FieldY,FieldY
	move.l	L_BaseballX,BaseballX
	move.l	L_BaseballY,BaseballY
DspField_D:
	move.l	#YArray,a6
	move.w	FieldY,YOffset

DisplayFld_1:
	PUSHL	d1-d5
	move.w	(a5)+,d0	; Load Field Scale
	move.w	d0,FieldScale	; Save The Scale
	ISCALE	d0,#0x100	; Set The Scale
	POPL	d1-d5

	move.w	FieldScale,d2	; Load Scaling Factor

	clr.l	d0	; Clear D0
	sub.w	FieldX,d0	; Subtract Field X Offset
	ext.l	d0	; Extend To A Long
	asl.l	#8,d0	; Multiply By 256
	divs	d2,d0	; Divide By Scale
	add.w	#192,d0	; Position To Mid Screen
	move.w	d0,d4	; Store X Position
	move.w	d4,FieldColumn	; Save Field Column Position
	bmi	DspField_2	; Branch If Not On Screen
	FLIP	ON	; Turn On Flipping
	move.w	d4,d1	; Load Needed Line Length Width
	add.w	#1,d1	; Make Wide Enough
	move.w	#1,d2	; One Line High
	move.l	FieldGromAdr,d3	; Load Grom Address
	move.w	FieldLine,d5	; Load Y Screen Position

	cmp.w	#384,d4	; Check If Starting Off Screen
	ble.s	DspField_1A	; Branch If Not
	sub.w	#384,d4	; Calculate Amount Off-Screen
	mulu	FieldScale,d4	; Multiply By Scale
	lsr.l	#8,d4	; Divide By 256
	add.l	d4,d3	; Move In Grom Space
	move.w	#384,d4	; Set Starting X
	move.w	#385,d1	; Load Screen Width + 1
DspField_1A:
	jsr	BlitData	; Display Data
DspField_2:
	FLIP	OFF
	move.w	FieldColumn,d4	; Reload X Screen Position
	addq.w	#1,d4	; Move Over One
	cmp.w	#384,d4	; Check If All Off Screen
	bge.s	DspField_3	; Branch If It Is
	move.w	#385,d1	; Load Screen Width + 1
	sub.w	d4,d1	; Calculate Line Length
	move.w	#1,d2	; One Line High
	move.l	FieldGromAdr,d3	; Load Grom Address
	move.w	FieldLine,d5	; Load Y Screen Position

	tst.w	d4	; Check If Starting Off Screen
	bpl.s	DspField_2A	; Branch If On Screen
	neg.w	d4	; Calculate Amount Off-Screen
	mulu	FieldScale,d4	; Multiply By Scale
	lsr.l	#8,d4	; Divide By 256
	add.l	d4,d3	; Move In Grom Space
	clr.w	d4	; Set Starting X
	move.w	#385,d1	; Load Screen Width + 1
DspField_2A:

	jsr	BlitData	; Display Data
DspField_3:
	clr.l	d0
	move.w	(a5)+,d0	; Load Line Up
	cmp.w	#0xFFFF,d0	; Check If Done
	beq.s	DspField_4	; Branch If Done

	sub.l	d0,FieldGromAdr	; Move Up Picture

DspField_3A:
	cmp.l	#StartGromAdr,FieldGromAdr	; Check If In Range
	bge.s	DspField_3B	; Branch If Fine
	add.l	#87*1466,FieldGromAdr	; Move Down In Groms
	bra.s	DspField_3A

DspField_3B:
	divu	#1466,d0	; Calculate Y Distance
	add.w	d0,YOffset	; Add Into Y Offset
	move.w	YOffset,(a6)+	; Store Y Position

	subq.w	#1,FieldLine	; Move Up Screen
	bra	DisplayFld_1	; Branch If Not Done

DspField_4:
	ISCALE	#0x100,#0x100

	move.w	#0x7FFF,(a6)+	; Store Y Position

	POPL	a5	; Retrieve Object Address

	jmp	DspField_40
DspField_40:
	move.l	BaseballX,d0	; Load Ball X Position
	lsr.l	#8,d0	; Extract Inches
	lsr.l	#3,d0	; Extract Eight Inches
	lsl.l	#1,d0	; Multiply By Two
	move.l	#StadiumY,a0	; Load Address Of Stadium Y's
	move.w	(a0,d0.w),d0	; Load Y Distance
	lsl.l	#8,d0	; Shift Up To Inches
	move.l	d0,WORLDY(a5)	; Save As World Y

	jsr	CalcFieldCoord	; Calculate Field Coordinates

	clr.l	d0	; Load Player X Position
	sub.w	FieldX,d0	; Subtract Field X Offset
	ext.l	d0	; Extend To A Long
	asl.l	#8,d0	; Multiply By 256
	divs	d2,d0	; Divide By Scale
	add.w	#192,d0	; Position To Mid Screen
	move.w	d0,FieldMiddle	; Store X Position

	move.w	FieldLine,d0	; Load Last Field Line
	add.w	#2,d0	; Move Down A Little
	cmp.w	YPOSITION(a5),d0	; Check If At Top Of Screen
	bgt.s	DspField_4A	; Branch If It Is

	move.w	XPOSITION(a5),d0	; Load X Position Of Foul Pole

	sub.w	FieldMiddle,d0	; Subtract Middle Of Field


	move.l	#1414*256,d1	; Load Pixel Size Of Stadium
	divu	d0,d1	; Divide By Size
	move.w	d1,StadiumScale	; Store Stadium Scale
	bra.s	DspField_4B

DspField_4A:
	move.w	FieldLine,YPOSITION(a5)	; Save Y Position

	move.l	#650*12*256,d0	; Load 450 Feet
	sub.l	FieldWorldY,d0	; Subtract World Y
	asr.l	#8,d0	; Extract Integer Part
	mulu	d0,d0	; Square The Result
	divu	#0xD100,d0	; Divide By Constant Factor
	add.w	#0x100,d0	; Add Minimum Scale

	move.w	FieldX,d1	; Load Field X
	bpl.s	DspField_4A1	; Branch If Positive
	neg.w	d1	; Make It Positive
DspField_4A1:
	asr.w	#2,d1	; Divide By Four
	sub.w	d1,d0	; Decrement Scale

	move.w	d0,StadiumScale	; Store Scale Factor


DspField_4B:
	WIDTHPIX	OFF

	IMAGES	#FieldWall	; Load Image Bank
	APALETTE	#P_STANDS	; Palette Number

	move.l	#SWidth*256,d0	; Load Width Of Art
	divu	StadiumScale,d0	; Divide By Scale
	move.w	d0,PieceWidth	; Save Art Width

	move.l	#SHeight*256,d0	; Load Height Of Art
	divu	StadiumScale,d0	; Divide By Scale
	move.w	d0,PieceHeight	; Save Art Height

	CLIP	ON
;	CLIP	OFF
	ISCALE	StadiumScale,StadiumScale
	FLOP	ON

;***************************************************************************
;	BLITDATA - set up and start the blitter.	*
;	d1 = Blit Width		*
;	d2 = Blit Height		*
;	d3 = GROM Address		*
;	d4 = X coord		*
;	d5 = Y coord		*
;***************************************************************************
	move.l	#StadiumTable,a6	; Load Address Of Stadium Data
DspField_5:
	move.w	#SWidth,d1	; Load Stadium Piece Width
	move.w	#SHeight,d2	; Load Stadium Piece Height

	clr.l	d4	; Clear D4
	move.w	(a6)+,d4	; Load Stadium Piece X Offset
	bmi.s	DspField_6	; Exit If Negative

	mulu	PieceWidth,d4	; Multiply By Piece Width
	add.w	FieldMiddle,d4	; Add In Display X

	clr.l	d5	; Clear D5
	move.w	(a6)+,d5	; Load Stadium Piece Y Offset
	mulu	PieceHeight,d5	; Multiply By Piece Height
	neg.w	d5	; Negate Result
	add.w	YPOSITION(a5),d5	; Add In Display Y

	move.l	(a6)+,d3	; Load Grom Address

	cmp.w	#384,d4	; Check If Off Screen
	bge.s	DspField_5	; Branch If It Is

	jsr	BlitData	; Display Stadium Piece
	bra.s	DspField_5

DspField_6:
	FLIP	ON
	move.l	#StadiumTable,a6	; Load Address Of Stadium Data
DspField_7:
	move.w	StadiumScale,d0	; Load Scale Value
	move.w	#SWidth,d1	; Load Stadium Piece Width
	move.w	#SHeight,d2	; Load Stadium Piece Height

	clr.l	d4	; Clear D4
	move.w	(a6)+,d4	; Load Stadium Piece X Offset
	bmi.s	DspField_8	; Exit If Negative

	mulu	PieceWidth,d4	; Multiply By Piece Width
	neg.w	d4	; Negate Result
	add.w	FieldMiddle,d4	; Add In Display X

	clr.l	d5	; Clear D4
	move.w	(a6)+,d5	; Load Stadium Piece X Offset
	mulu	PieceHeight,d5	; Multiply By Piece Height
	neg.w	d5	; Negate Result
	add.w	YPOSITION(a5),d5	; Add In Display Y

	move.l	(a6)+,d3	; Load Grom Address

	tst.w	d4	; Check If Off Screen
	bmi.s	DspField_7	; Branch If It Is

	jsr	BlitData	; Display Stadium Piece
	bra.s	DspField_7
DspField_8:

	FLIP	OFF
	FLOP	OFF
	CLIP	ON

DspField_9:
	ISCALE	#0x100,#0x100

	PLANES	#PLANEA	; All Displays On Plane A
	IMAGES	#Field	; Load Image Bank
	APALETTE	#P_BIGFIELD3	; Palette Number
	WIDTHPIX	OFF
	LOOKAHEAD	ON

	jsr	DisplayShadows	; Display All Shadows

	rts

StadiumTable:
	dc.w	0,0	; X,Y
	dc.l	0x000000	; Grom Address
	dc.w	1,0	; X,Y
	dc.l	0x010000	; Grom Address
	dc.w	2,0	; X,Y
	dc.l	0x020000	; Grom Address

	dc.w	0,1	; X,Y
	dc.l	0x030000	; Grom Address
	dc.w	1,1	; X,Y
	dc.l	0x040000	; Grom Address
	dc.w	2,1	; X,Y
	dc.l	0x050000	; Grom Address

	dc.w	0,2	; X,Y
	dc.l	0x060000	; Grom Address
	dc.w	1,2	; X,Y
	dc.l	0x070000	; Grom Address
	dc.w	2,2	; X,Y
	dc.l	0x080000	; Grom Address

;	dc.w	1,3	; X,Y
;	dc.l	0x090000  	; Grom Address
;	dc.w	2,3	; X,Y
;	dc.l	0x0A0000  	; Grom Address

;	dc.w	1,4	; X,Y
;	dc.l	0x0B0000  	; Grom Address
;	dc.w	2,4	; X,Y
;	dc.l	0x0C0000  	; Grom Address

	dc.w	0xFFFF	; End Of Stadium

HomeX	equ	0x0	; Home Plate X
HomeY	equ	0x0	; Home Plate Y
FirstX	equ	0x17C	; First Base X
FirstY	equ	0x17C	; First Base Y

XOrigin	equ	HomeX	; Offset From World To Screen X
YOrigin	equ	HomeY	; Offset From World To Screen Y

XFactor	equ	(FirstX-HomeX)/763	; 763 = Inches To First
YFactor	equ	(FirstY-HomeY)/763	; 763 = Inches To First
;
; YFactor and XFactor are both near .5 so I used a divide by two shift (RAD)
;
CalcFieldCoord:
;
; Calculate Y Position
;
	move.l	WORLDY(a5),d0	; Load Player Y Position
	asr.l	#8,d0	; Shift To Integral Part
	asr.w	#1,d0	; Divide By Two (Should Be Multiply By YFactor)
	cmp.w	FieldY,d0	; Check If Off Bottom Of Screem
	bgt.s	CalcFld_1	; Branch If All On Screen
	move.w	FieldY,d1	; Load Field Position
	sub.w	d0,d1	; Subtract Player Position
	add.w	#256,d1	; Place Off Screen
	move.w	d1,YPOSITION(a5)	; Store New Y Position
	move.w	#256,d0	; Load Full Scale
	bra.s	CalcFld_3

CalcFld_1:
	move.w	#256,d1	; Clear d0
	move.l	#YArray,a0
CalcFld_2:
	subq.w	#1,d1	; Decrement Counter
	cmp.w	(a0)+,d0	; Check If Found
	bgt.s	CalcFld_2	; Branch If Not

	cmp.w	FieldLine,d1	; Compare With Wall
	bgt.s	CalcFld_2A	; Branch If Fine
	move.w	FieldLine,d1	; Load Wall Y Position
CalcFld_2A:
	move.w	d1,YPOSITION(a5)	; Store New Y Position

;
; Calculate Scaling
;
	move.w	#256,d0	; Load Full Scale

	cmp.w	#256,d1	; Check If Off Screen
	bge.s	CalcFld_3	; Branch If Should Be Full

	move.l	ScalingY,a0	; Load Address Of Data Array
	neg.w	d1	; Array Is Upside Down
	add.w	#256,d1	; Index Into Array
	asl.w	#1,d1	; Multiply By Two
	move.w	(a0,d1.w),d0	; Load Scale Value
CalcFld_3:
	move.w	d0,SCALEFACTOR(a5)	; Store Scale Factor

;
; Calculate X Position
;
	move.l	ScalingX,a0	; Load Address Of Scaling Array
	move.w	YPOSITION(a5),d1	; Load Y Position
	cmp.w	#256,d1	; Check If Off Screen
	blt.s	CalcFld_4	; Branch If Not
	move.w	#255,d1	; Load Screen Bottom
CalcFld_4:
	neg.w	d1	; Negate Y Position
	add.w	#255,d1	; Calculate Distance From Bottom
	asl.w	#1,d1	; Multiply By Two
	move.w	(a0,d1.w),d2	; Load Scaling Factor

	move.l	WORLDX(a5),d0	; Load Player X Position
	asr.l	#8,d0	; Shift To Integral Part
	asr.w	#1,d0	; Divide By Two (Should Be Multiply By YFactor)
	sub.w	FieldX,d0	; Subtract Field X Offset
	ext.l	d0	; Extend To A Long
	asl.l	#8,d0	; Multiply By 256
	divs	d2,d0	; Divide By Scale
	add.w	#192,d0	; Position To Mid Screen
	move.w	d0,XPOSITION(a5)	; Store X Position
CalcField_9:
	rts

ScaleYData2:	
	dc.w	256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256
	dc.w	256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256
	dc.w	256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256
	dc.w	256,256,256,256,256,256,256,256
	dc.w	256,255,253,252,251,250,248,247,246,244,243,242
	dc.w	241,239,238,237,236,234,233,232,230,229,228,227
	dc.w	225,224,223,221,220,219,218,216,215,214,212,211
	dc.w	210,209,207,206,205,204,202,201,200,198,197,196
	dc.w	195,193,192,191,189,188,187,186,184,183,182,180

	dc.w	179,178,177,174,172,170,169,168,166
	dc.w	164,163,161,159,156,155,154,152,151
	dc.w	148,147,146,143,141,140,138,137,136
	dc.w	133,132,131,128,125,124,123,122,120
	dc.w	118,116,115,113,110,109,108,106,105

;	dc.w	179,178,177,175,174,173,172,170,169,168,166,165
;	dc.w	164,163,161,160,159,157,156,155,154,152,151,150
;	dc.w	148,147,146,145,143,142,141,140,138,137,136,134
;	dc.w	133,132,131,129,128,127,125,124,123,122,120,119
;	dc.w	118,116,115,114,113,111,110,109,108,106,105,104

	dc.w	102,101,100,99,97,96,95,93,92,91,90,88
	dc.w	87,86,84,83,82,81,79,78,77,76,74,73
	dc.w	72,70,69,68,67,65,64,63,61,60,59,58
	dc.w	56,55,54,52,51,50,49,47,46,45,44,42
	dc.w	41,40,38,37,36,35,33,32,31,29,28,27
	dc.w	26,24,23,22,20,19,18,17,15,14,13,12

ScaleXData2:
	dc.w	142,143,143,144,145,145,146,146
	dc.w	147,147,148,149,149,150,150,151
	dc.w	152,152,153,153,154,155,155,156
	dc.w	157,157,158,159,159,160,161,162
	dc.w	162,163,164,165,165,166,167,168
	dc.w	169,169,170,171,172,173,174,174
	dc.w	175,176,177,178,179,180,181,182
	dc.w	183,184,185,186,187,188,189,190
	dc.w	191,192,193,194,196,197,198,199
	dc.w	200,202,203,204,205,207,208,209
	dc.w	211,212,214,215,217,218,220,221
	dc.w	223,224,226,227,229,231,233,234
	dc.w	236,238,240,242,244,245,247,250
	dc.w	252,254,256,258,260,263,265,267
	dc.w	270,272,275,277,280,282,285,288
	dc.w	291,294,297,300,303,306,310,313
	dc.w	316,320,324,327,331,335,339,343
	dc.w	347,352,356,361,366,371,376,381
	dc.w	386,392,397,403,409,416,422,429
	dc.w	436,443,450,458,466,474,483,492
	dc.w	501,511,521,532,543,555,567,579
	dc.w	593,607,621,637,653,670,689,708
	dc.w	728,750,773,798


FieldData2:
;	dc.w	128,0
;	dc.w	128,1466
;	dc.w	129,0
;	dc.w	129,1466
;	dc.w	130,1466
;	dc.w	130,0
;	dc.w	130,1466
;	dc.w	131,1466
;	dc.w	131,0
;	dc.w	132,1466
;	dc.w	132,1466
;	dc.w	133,0
;	dc.w	133,1466
;	dc.w	134,1466
;	dc.w	134,0
;	dc.w	134,1466
;	dc.w	135,1466
;	dc.w	135,0
;	dc.w	136,1466
;	dc.w	136,1466
;	dc.w	137,1466
;	dc.w	137,0
;	dc.w	138,1466
;	dc.w	138,1466
;	dc.w	139,1466
;	dc.w	139,0
;	dc.w	140,1466
;	dc.w	140,1466
;	dc.w	141,1466
;	dc.w	141,1466
;	dc.w	142,0
	dc.w	142,1466
	dc.w	143,1466
	dc.w	143,1466
	dc.w	144,1466
	dc.w	145,0
	dc.w	145,1466
	dc.w	146,1466
	dc.w	146,1466
	dc.w	147,1466
	dc.w	147,1466
	dc.w	148,1466
	dc.w	149,1466
	dc.w	149,0
	dc.w	150,1466
	dc.w	150,1466
	dc.w	151,1466
	dc.w	152,1466
	dc.w	152,1466
	dc.w	153,1466
	dc.w	153,1466
	dc.w	154,1466
	dc.w	155,1466
	dc.w	155,1466
	dc.w	156,1466
	dc.w	157,1466
	dc.w	157,1466
	dc.w	158,1466
	dc.w	159,1466
	dc.w	159,1466
	dc.w	160,1466
	dc.w	161,2932
	dc.w	162,1466
	dc.w	162,1466
	dc.w	163,1466
	dc.w	164,1466
	dc.w	165,1466
	dc.w	165,1466
	dc.w	166,2932
	dc.w	167,1466
	dc.w	168,1466
	dc.w	169,1466
	dc.w	169,2932
	dc.w	170,1466
	dc.w	171,1466
	dc.w	172,1466
	dc.w	173,2932
	dc.w	174,1466
	dc.w	174,1466
	dc.w	175,2932
	dc.w	176,1466
	dc.w	177,1466
	dc.w	178,2932
	dc.w	179,1466
	dc.w	180,2932
	dc.w	181,1466
	dc.w	182,2932
	dc.w	183,1466
	dc.w	184,2932
	dc.w	185,1466
	dc.w	186,2932
	dc.w	187,1466
	dc.w	188,2932
	dc.w	189,2932
	dc.w	190,1466
	dc.w	191,2932
	dc.w	192,2932
	dc.w	193,1466
	dc.w	194,2932
	dc.w	196,2932
	dc.w	197,2932
	dc.w	198,2932
	dc.w	199,1466
	dc.w	200,2932
	dc.w	202,2932
	dc.w	203,2932
	dc.w	204,2932
	dc.w	205,2932
	dc.w	207,2932
	dc.w	208,2932
	dc.w	209,2932
	dc.w	211,2932
	dc.w	212,4398
	dc.w	214,2932
	dc.w	215,2932
	dc.w	217,2932
	dc.w	218,4398
	dc.w	220,2932
	dc.w	221,2932
	dc.w	223,4398
	dc.w	224,2932
	dc.w	226,4398
	dc.w	227,2932
	dc.w	229,4398
	dc.w	231,2932
	dc.w	233,4398
	dc.w	234,4398
	dc.w	236,4398
	dc.w	238,2932
	dc.w	240,4398
	dc.w	242,4398
	dc.w	244,4398
	dc.w	245,4398
	dc.w	247,4398
	dc.w	250,5864
	dc.w	252,4398
	dc.w	254,4398
	dc.w	256,4398
	dc.w	258,5864
	dc.w	260,4398
	dc.w	263,5864
	dc.w	265,4398
	dc.w	267,5864
	dc.w	270,5864
	dc.w	272,5864
	dc.w	275,5864
	dc.w	277,5864
	dc.w	280,5864
	dc.w	282,5864
	dc.w	285,5864
	dc.w	288,7330
	dc.w	291,5864
	dc.w	294,7330
	dc.w	297,7330
	dc.w	300,5864
	dc.w	303,7330
	dc.w	306,7330
	dc.w	310,8796
	dc.w	313,7330
	dc.w	316,7330
	dc.w	320,8796
	dc.w	324,8796
	dc.w	327,8796
	dc.w	331,8796
	dc.w	335,8796
	dc.w	339,8796
	dc.w	343,10262
	dc.w	347,8796
	dc.w	352,10262
	dc.w	356,10262
	dc.w	361,11728
	dc.w	366,10262
	dc.w	371,11728
	dc.w	376,11728
	dc.w	381,11728
	dc.w	386,13194
	dc.w	392,13194
	dc.w	397,13194
	dc.w	403,13194
	dc.w	409,14660
	dc.w	416,14660
	dc.w	422,14660
	dc.w	429,16126
	dc.w	436,16126
	dc.w	443,17592
	dc.w	450,17592
	dc.w	458,19058
	dc.w	466,17592
	dc.w	474,20524
	dc.w	483,20524
	dc.w	492,21990
	dc.w	501,21990
	dc.w	511,23456
	dc.w	521,23456
	dc.w	532,26388
	dc.w	543,26388
	dc.w	555,27854
	dc.w	567,29320
	dc.w	579,30786
	dc.w	593,32252
	dc.w	607,33718
	dc.w	621,36650
	dc.w	637,36650
	dc.w	653,41048
	dc.w	670,42514
	dc.w	689,43980
	dc.w	708,48378
	dc.w	728,51310
	dc.w	750,54242
	dc.w	773,57174
	dc.w	798,0xFFFF


	.export	StadiumY
StadiumY:
	dc.w	4517,4515,4512,4510,4508,4505,4503,4501
	dc.w	4498,4496,4494,4492,4489,4487,4485,4482
	dc.w	4479,4477,4474,4471,4468,4466,4463,4460
	dc.w	4457,4454,4452,4449,4446,4443,4440,4437
	dc.w	4434,4431,4428,4425,4421,4418,4415,4412
	dc.w	4409,4405,4402,4399,4396,4393,4389,4386
	dc.w	4383,4379,4376,4373,4369,4366,4363,4360
	dc.w	4356,4353,4350,4346,4343,4339,4336,4332
	dc.w	4328,4325,4321,4317,4314,4310,4306,4303
	dc.w	4299,4295,4292,4288,4284,4280,4276,4271
	dc.w	4267,4263,4259,4255,4251,4246,4242,4238
	dc.w	4234,4230,4225,4221,4217,4213,4208,4204
	dc.w	4200,4196,4191,4187,4183,4179,4174,4170
	dc.w	4166,4162,4157,4153,4149,4145,4140,4136
	dc.w	4132,4128,4123,4119,4115,4111,4106,4102
	dc.w	4098,4092,4087,4082,4076,4071,4066,4060
	dc.w	4055,4049,4044,4039,4033,4028,4022,4017
	dc.w	4011,4006,4000,3994,3988,3982,3977,3971
	dc.w	3965,3959,3953,3948,3942,3936,3930,3924
	dc.w	3917,3911,3905,3898,3892,3885,3879,3872
	dc.w	3866,3859,3853,3846,3840,3834,3826,3819
	dc.w	3812,3805,3798,3791,3784,3777,3769,3762
	dc.w	3755,3748,3741,3734,3727,3719,3710,3702
	dc.w	3694,3686,3678,3669,3661,3653,3645,3637
	dc.w	3629,3620,3612,3604,3595,3587,3578,3569
	dc.w	3560,3552,3543,3534,3526,3517,3508,3499
	dc.w	3491,3482,3473,3464,3455,3445,3436,3427
	dc.w	3418,3408,3399,3390,3381,3371,3362,3353
	dc.w	3344,3334,3326,3317,3308,3300,3291,3282
	dc.w	3273,3265,3256,3247,3239,3230,3221,3212
	dc.w	3204,3193,3183,3173,3162,3152,3142,3131
	dc.w	3121,3111,3101,3090,3080,3070,3059,3049
	dc.w	3039,3029,3019,3009,2999,2989,2980,2970
	dc.w	2960,2950,2940,2930,2920,2910,2900,2889
	dc.w	2878,2868,2857,2846,2835,2824,2813,2800
	dc.w	2800,2800,2800,2800,2800,2800,2800,2800
	dc.w	2800,2800,2800,2800,2800,2800,2800,2800
	dc.w	2800,2800,2800,2800,2800,2800,2800,2800
	dc.w	2800,2800,2800,2800,2800,2800,2800,2800
	dc.w	2800,2800,2800,2800,2800,2800,2800,2800
	dc.w	2800,2800,2800,2800,2800,2800,2800,2800
	dc.w	2800,2800,2800,2800,2800,2800,2800,2800
	dc.w	2800,2800,2800,2800,2800,2800,2800,2800
	dc.w	2800,2800,2800,2800,2800,2800,2800,2800
	dc.w	2800,2800,2800,2800,2800,2800,2800,2800
	dc.w	2800,2800,2800,2800,2800,2800,2800,2800
	dc.w	2800,2800,2800,2800,2800,2800,2800,2800
	

	end
	




