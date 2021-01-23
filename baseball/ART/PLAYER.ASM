;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************
	.region	"RAM"
	ds	0
	#include	"ramblock.h"
	#include	"pals.h"
	#include	"groms.h"
	#include	"sys.mac"

;***************************************************************************
;   Routines Exported From PLAYER.ASM		*
;***************************************************************************
	.export	Ghost
	.export	AnimPlayer
	.export	DspBody,Split
	.export	GetPosition,ShadowsDown
	.export	RestorePalette
	.export	InitFielders

;***************************************************************************
;  Variable Imports			*
;***************************************************************************
	.import.s	BlitX,BlitY,BlitWidth,BlitFlip,BlitFlop
	.import.s	GroundY2,GroundY
	.import.s	FreezeMask,FreezeTick
	.import.s	SwitchToField,batternum

;***************************************************************************
;  Subroutine Imports		*
;***************************************************************************
	.import	AllocObject	
	.import	Anim,Move
	.import	BlitObject,BlitAObject,BlitSAObject
	.import	CalcFieldCoord
	.import	CreateJoy,InputControl
	.import	DeallocObject
	.import	LoadPtrs
	.import	Switches


;***************************************************************************
;  Fighter Table Imports		*
;***************************************************************************
	.import	BaseTable
	.import	Player,FielderIntro,PitcherIntro,CatcherIntro
	.import	RunnerIntroT,RunnerIntroF,RunnerIntroS

;***************************************************************************
;  RAM Variables Defined In This Section		*
;***************************************************************************
	.export	Objects,FreeObjects,ObjectList
	.export	Pitcher,Batter,FirstBase,SecondBase,ShortStop
	.export	ThirdBase,Catcher,LeftField,CenterField,RightField,FirstRunner
	.export	FlopShadows,DimShadows,DownShadows,NoShadows,ClipShadows
	.export	FlickerShadows,FlickerCnt,ThirdRunner,FirstRunStart,FirstRunPtr
	.export	SecondRunStart,SecondRunPtr,SecondRunner


Objects	 ds.l	1	; Pointer To Object List
FreeObjects ds.l	1	; Pointer To Free Object List
ObjectList	 ds.b	NUMBLOCKS*BLOCKSIZE

Batter	 ds.b	RAMBLOCKSIZE
Pitcher	 ds.b	RAMBLOCKSIZE
FirstBase	 ds.b	RAMBLOCKSIZE
SecondBase	 ds.b	RAMBLOCKSIZE
ShortStop	 ds.b	RAMBLOCKSIZE
ThirdBase	 ds.b	RAMBLOCKSIZE
Catcher	 ds.b	RAMBLOCKSIZE
LeftField	 ds.b	RAMBLOCKSIZE
CenterField ds.b	RAMBLOCKSIZE
RightField	 ds.b	RAMBLOCKSIZE
FirstRunner ds.b	RAMBLOCKSIZE
SecondRunner ds.b	RAMBLOCKSIZE
ThirdRunner ds.b	RAMBLOCKSIZE

	 ds	0
Shadow_Yanchor ds.w	1
ShadowsDown    ds.w	1
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
batternum2	    ds.l	1

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

FREEZEANIM	 equ	1
FREEZESHAKE equ	8
	
;***************************************************************************
;   RestorePalette - Restore A Fighter's Palette                  	*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
RestorePalette:
	move.b	SAVEPAL(a6),PALETTE(a6) ; Restore Palette Number
	rts

;***************************************************************************
;   InitFielders - Initialize All Players Except Batter And Pitcher	*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
InitFielders:                ;Took extra Fielders out
;First Base
	move.w	#500,d2	; Set X Position To Off Screen
	move.l	#FirstBase,a0	; Set Up Third Baseman
	bsr	InitPlayer	; Initialize Object
	move.l	#757*256,WORLDX(a0)	; Set World Coordinates
	move.l	#1098*256,WORLDY(a0)
; Second Base
	move.w    #290,d2	; Set X Position
	move.l	#SecondBase,a0	; Set Up Short Stop
 	bsr	InitPlayer	; Initialize Object
	move.l	#480*256,WORLDX(a0)	; Set World Coordinates
	move.l	#1543*256,WORLDY(a0)
; Short Stop
	move.w    #74,d2	; Set X Position
           move.l	#ShortStop,a0	; Set Up Short Stop
 	bsr	InitPlayer	; Initialize Object
	move.l	#-480*256,WORLDX(a0)	; Set World Coordinates
	move.l	#1543*256,WORLDY(a0)
; Third Base
	move.w	#500,d2	; Set X Position To Off Screen
	move.l	#ThirdBase,a0	; Set Up Third Baseman
	bsr	InitPlayer	; Initialize Object
	move.l	#-757*256,WORLDX(a0)	; Set World Coordinates
	move.l	#1098*256,WORLDY(a0)
; Left Field
	move.w	#500,d2	; Set X Position To Off Screen
	move.l	#LeftField,a0	; Set Up Third Baseman
	bsr	InitPlayer	; Initialize Object
	move.l	#-1873*256,WORLDX(a0)	; Set World Coordinates
	move.l	#2971*256,WORLDY(a0)
; Center Field
	move.w	#500,d2	; Set X Position To Off Screen
	move.l	#CenterField,a0	; Set Up Third Baseman
	bsr	InitPlayer	; Initialize Object
	move.l	#0*256,WORLDX(a0)	; Set World Coordinates
	move.l	#3926*256,WORLDY(a0)
; Right Field
	move.w	#500,d2	; Set X Position To Off Screen
	move.l	#RightField,a0	; Set Up Third Baseman
	bsr	InitPlayer	; Initialize Object
	move.l	#1873*256,WORLDX(a0)	; Set World Coordinates
	move.l	#2971*256,WORLDY(a0)

	rts		;Put here to so that there
			;is no runner pic (for now)

	
	move.w	#500,d2
	move.l	#FirstRunner,a0
	bsr	InitPlayer
	
	move.w	#500,d2
	move.l	#Catcher,a0
	bsr	InitPlayer
	
	move.w	#500,d2
	move.l	#ThirdRunner,a0
	bsr	InitPlayer

	move.w	#500,d2
	move.l	#SecondRunner,a0
	bsr	InitPlayer

;	bra	SecondRunStart
;	rts
 	
FirstRunStart:
;********************* First And third Runners ***************
	move.l	#FirstRunner,a0
   	move.l	a0,DATAPTR(a5)
	bsr	InitPlayer
	move.l	#RunnerIntroF,PARSEPOINTER(a0) ; Save In Ram Block
	move.b	#P_VISTPAL00,PALETTE(a0)	; Load Palette Number
;	move.b	#BATTERPAL,PALETTE(a0)	; Load Palette Number
	move.b	#RunnerTopBank,BANK(a0)	; Load Legs Bank Number
	move.w	#350,XPOSITION(a0)
	move.w	#54,YPOSITION(a0)
	move.l	a0,FirstRunPtr
	rts

SecondRunStart:
;********************* Second Runners ***************
	move.l	#SecondRunner,a0
;   	move.l	a0,DATAPTR(a5)
	bsr	InitPlayer
;	move.l	#RunnerIntroS,PARSEPOINTER(a0) ; Save In Ram Block
	move.b	#P_VISTPAL00,PALETTE(a0)	; Load Palette Number
	move.b	#RunnerTopBank,BANK(a0)	; Load Legs Bank Number
	move.w	#154,XPOSITION(a0)
	move.w	#100,YPOSITION(a0)
	move.l	a0,SecondRunPtr
	rts
	
ThirdRunStart:
	move.l	#ThirdRunner,a0
	bsr	InitPlayer
	move.l	#RunnerIntroT,PARSEPOINTER(a0) ; Save In Ram Block
	move.b	#P_VISTPAL00,PALETTE(a0)	; Load Palette Number
	move.b	#RunnerTopBank,BANK(a0)	; Load Legs Bank Number
	move.w	#34,XPOSITION(a0)
	move.w	#54,YPOSITION(a0)

	rts

;***************************************************************************
;   InitPlayer - Initialize Player Ram Block                  	*
;				*
;   Parameters :  A0 - Ram Block Address		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
InitPlayer:
;	move.b	P_VISTPAL,P_OUTFIELDT
	move.w	#1,DURATION(a0)	; Initialize Duration
	move.w	#0x100,d0
	move.w	d0,XFACTOR(a0)	; Initialize X Shift Factor
	move.w	d0,YFACTOR(a0)	; Initialize Y Shift Factor
	move.w	#-1,PICTURE(a0)	; Store Non-Displayable Object
	move.b	#-1,DAMP(a0)	; Set For No Gravity
	clr.w	XVELOCITY(a0)	; Clear X Velocity
	clr.w	YVELOCITY(a0)	; Clear Y Velocity
	clr.b	FLIPFLAG(a0)	; Clear The Flip Flag
	clr.b	FLOPFLAG(a0)	; Clear The Flop Flag
	clr.b	OBJECTTYPE(a0)	; Clear The Object Type
	clr.l	UPDATEPROC(a0)	; Clear Update Procedure
	clr.l	DISPLAYPROC(a0)	; Clear Display Procedure
	clr.l	COLLISIONPROC(a0)	; Clear Collision Procedure
	clr.l	ALWAYSROUTINE(a0)	; Clear The Always Procedure
	clr.l	COLLIDECHAIN(a0)	; Clear The Collision Chain
	clr.b	COLLISIONCLASS(a0)	; Turn Off Collisions
	clr.l	CHILD(a0)	; Clear Child Pointer
	clr.w	ANCHORX(a0)	; Clear X Anchor
	clr.w	ANCHORY(a0)	; Clear Y Anchor
	clr.w	BLITWIDTH(a0)	; Clear Blit Width
	clr.w	BLITHEIGHT(a0)	; Clear Blit Height
	clr.b	DELETED(a0)
	clr.b	BOUNCESOUND(a0)	; Clear The Bounce Sound
	move.b	#1,STATIONARY(a0)	; Set As Non-Stationary
	move.l	#0x40,GRAVITY(a0)	; Store Gravity

	move.l	#AnimPlayer,UPDATEPROC(a0) ; Store Address Of Update Procedure
	move.l	#DspBody,DISPLAYPROC(a0)    ; Store Address Of Display Procedure
	move.w	#-1,CURRENTFRAME(a0)        ; Start With First Frame
	clr.b	GLOBALBANK(a0)	   
	move.b	#10,ZPOSITION(a0)   	; Initialize Z Position
	move.b	#0xFF,OBJECTTYPE(a0)	; Initialize Object Type	
	clr.w	XFACTOR(a0)
	clr.w	YFACTOR(a0)

	move.w	#256,XSCALE(a0)	; Set To Full Size Body
	move.w	#256,YSCALE(a0)	; Set To Full Size Body
	move.w	#0xC0,SCALEFACTOR(a0)	; Set To Half Size

	move.w	#-1,PICTURE(a0)	; Start With Standing Picture
	move.w	d2,XPOSITION(a0)
;	move.w	#100,XPOSITION(a0)
	add.w	#40,d2
	move.w	#100,YPOSITION(a0)
	move.l	#FielderIntro,PARSEPOINTER(a0) ; Save In Ram Block
	move.l	#Player,FRAMESDATA(a0)	; Save In Ram Block
	clr.l	DEFENDTABLE(a0)	; Save In Ram Block

	clr.l	ALWAYSROUTINE(a0)	; Clear Always Routine Address
	clr.b	BOUNCESOUND(a0)	; Set No Bounce Sound
	move.b	#1,STATIONARY(a0)	; Set As Moving
	clr.w	DURATION(a0)	; Clear Animation Duration
	clr.w	XVELOCITY(a0)	; Clear X Velocity
	clr.b	INVISIBLE(a0)	; Make Player Visible
	clr.b	FREEZETIME(a0)	; Clear Freeze Time
	clr.b	JOYSTICK(a0)
	clr.b	BUTTONSUP(a0)
	move.w	#1,YVELOCITY(a0)	; Clear Y Velocity
	move.b	#10,BUTTONCOUNT(a0)
	clr.b	DELETED(a0)

	move.b	#8,DAMP(a0)

	clr.l	INPUTROUTINE(a0)
	move.b	#1,DERESFLAG(a0)
;	move.b	#P_REDSSHIRT,PALETTE(a0)	; Load Palette Number
	move.b	#P_HOMETPAL00,PALETTE(a0)	; Load Palette Number
	move.b	#P_HOMETPAL00,SAVEPAL(a0)	; Save Save Palette Number
;	move.b	#P_REDSSHIRT,SAVEPAL(a0)	; Save Save Palette Number
	move.b	#FielderTopBank,BANK(a0)	; Load Legs Bank Number
	rts
	
;****************************************************************************
;   AnimPlayer - Execute The Animation Tables For Each Fighter             *
;                                                                           *
;   Parameters :  NONE                                                      *
;   Returns:      NONE                                                      *
;   Modifies:     NONE                                                      *
;****************************************************************************
AnimPlayer:
	tst.w	FreezeTick	; Check If Freezing
	beq.s	AnimP_1	; Branch If Not
	move.b	FreezeTick+1,d0	; Load Tick Count
	and.b	FreezeMask,d0	; And With Freeze Mask
	bne.s	AnimP_5	; Exit If All Frozen
AnimP_1:
	tst.b	FREEZETIME(a6)	; Check If Other Player Frozen
	bne.s	AnimP_5	; Exit If He Is

	tst.b	GHOSTTICK(a5)	; Check If Ghosting
	beq.s	AnimP_2	; Branch If Not
	subq.b	#1,GHOSTTICK(a5)	; Decrement Ghost Counter

	btst.b	#0,GHOSTTICK(a5)	; Ghost On Every Other Frame
	beq.s	AnimP_3	; Branch If Not Time

	jsr	Ghost	; Go Create Ghost
	bra.s	AnimP_3
AnimP_2:
	clr.b	GHOSTPALETTE(a5)	; Clear Ghosting Palette
AnimP_3:
	tst.b	FREEZETIME(a5)	; Check If Movement Is Frozen
	beq.s	AnimP_4	; Branch If Not Frozen
	subq.b	#1,FREEZETIME(a5)	; Decrement Freeze Time
	bra	AnimP_5
AnimP_4:
	jsr	InputControl	; Execute Input Control
	jsr	Anim	; Animate The Player
AnimP_5:
	tst.l	DISPLAYPROC(a5)	; Check If Displaying
	beq.s	AnimP_6	; Branch If Not
	jsr	Split	; Split Fighter Into Parts
AnimP_6:
	tst.b	SwitchToField	; Check If Displaying Field
	beq.s	AnimP_7	; Branch If Not Displaying
	jsr	CalcFieldCoord	; Place Player On Field
AnimP_7:
	rts

;****************************************************************************
;   Split - Extract Torso, Back Arm and Weapon Arm Pictures                 *
;                                                                           *
;   Parameters :  NONE                                                      *
;   Returns:      NONE                                                      *
;   Modifies:     NONE                                                      *
;****************************************************************************
Split:
	move.w	CURRENTFRAME(a5),d7	; Load The Frame Number
	bmi.s	Split_9
	move.l	FRAMESDATA(a5),a0	; Load Address Of Frames Data
	lsl.w	#2,d7	; Multiply By Four
	move.l	(a0,d7.w),a3	; Load Address Of Frame
	move.l	a3,DATAPTR(a5)	; Save Pointer To Dots Data
	move.w	Torso(a3),d3
	move.w	d3,PICTURE(a5)	; Save Body Image Number
Split_9:
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

;	bsr	BlitShadow	; Blit both Player's parts Shadow

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
	jsr	BlitHead	; Display Head
	jsr	BlitBat	; Display Bat
	bra	NotBatter

DspBody_1:
;	jsr	BlitShad
NotBatter:	jsr	BlitLegs	; Display Legs
	jsr	BlitTorso	; Display Torso

	cmp.l	#Batter,a5	; Check If Batter
	bne.s	DspBody_11	; Branch If Not Batter
	jsr	BlitBNum	; Display Bat
DspBody_11:
	OSCALE	#$100,#$100	; Scale Images Down
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
	move.l	DATAPTR(a5),a3	; Load Pointer To Frames Data
	clr.w	d2	; Load Start Index Into Frame
	jsr	GetPosition	; Get Blit Coordinates
	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq	BlitTorso_9	; Branch if not Valid
	cmp.w	#256,YScale	; Check If Full Scale
	beq.s	BlitTorso_1	; Branch If It Is
	add.w	#1,d5	; Move Down One
BlitTorso_1:
	APALETTE	PALETTE(a5)	; Set Palette 
	IMAGES	BANK(a5)	; Set Image Bank
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
	move.l	DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#Legs,d2	; Load Start Index Into Frame
	jsr	GetPosition	; Get Blit Coordinates
	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq.s	BlitLegs_9	; Branch if not Valid
;	move.b	PALETTE(a5),d0	; Load Palette Number
;	addq.b	#1,d0	; Increment Palette Number
;	APALETTE	d0	; Set Palette 
	cmp.l	#Batter,a5	; Check If Batter
	bne.s	HomePal	; Branch If Not Batter
	APALETTE	#P_VISBPAL	; Set Palette 
	bra	Legs_8	
HomePal	APALETTE	#P_HOMEBPAL	; Set Palette 
Legs_8	move.b	BANK(a5),d0	; Load Bank Number
	addq.b	#1,d0	; Increment Bank
	IMAGES	d0	; Set Image Bank
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
BlitHead:
	move.l	DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#Head,d2	; Load Start Index Into Frame
	jsr	GetPosition	; Get Blit Coordinates
	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq.s	BlitHead_9	; Branch if not Valid
;    	APALETTE	#P_VHATPAL02	; Set Palette 
;	move.b	#P_VHATPAL00,HEADPALETTE(a5)
	APALETTE	HEADPALETTE(a5)	; Set Palette 
	move.b	BANK(a5),d0	; Load Bank Number
	IMAGES	#BatterHead	; Set Image Bank
	cmpi.w	#19,d3
	ble.s	regular
;	add.w	#7,d3
	move.w	batternum,d0
;	trap	#1
;	add.w	#1,d0
	mulu.w	#7,d0
	add.w	d0,d3
;	trap	#1

regular:	jsr	Blit	; Display The Head
;	cmpi.w	#13,d3
;	ble.s	regular2
;	sub.w	#7,d3
;regular2:
BlitHead_9:
	rts



;***************************************************************************
;   BlitBNum -  Blit Batter's Number		*
;                                                                          *
;   Parameters :  a5 - Address Of Object		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
BlitBNum:
	move.l	DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#Tens,d2	; Load Start Index Into Frame
	jsr	GetPosition	; Get Blit Coordinates
	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq.s	BlitBNum_9	; Branch if not Valid
;	APALETTE	#P_HEAD	; Set Palette 
	APALETTE	#P_VHATPAL00	; Set Palette 
	move.b	BANK(a5),d0	; Load Bank Number
	IMAGES	#Misc	; Set Image Bank
	jsr	Blit	; Display The Head

BlitBNum_9:
	
	move.l	DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#Units,d2	; Load Start Index Into Frame
	jsr	GetPosition	; Get Blit Coordinates
	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq.s	BlitBNum_11	; Branch if not Valid
;	APALETTE	#P_HEAD	; Set Palette 
	APALETTE	#P_VHATPAL00	; Set Palette 
	move.b	BANK(a5),d0	; Load Bank Number
	IMAGES	#Misc	; Set Image Bank
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
	move.l	DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#Bat,d2	; Load Start Index Into Frame
	jsr	GetPosition	; Get Blit Coordinates

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
	move.b	BANK(a5),d0	; Load Bank Number
	IMAGES	#BattersBat	; Set Image Bank
	jsr	Blit	; Display The Bat

	FLIP	OFF	; Turn Off Flipping
	FLOP	OFF	; Turn Off Flopping
BlitBat_9:
	rts



;***************************************************************************
;   BlitShad -  Blit Shadow		*
;                                                                          *
;   Parameters :  a5 - Address Of Object		*
;   Returns:      NONE		*
;   Modifies:     ALL                                                      *
;***************************************************************************
BlitShad:
	move.l	DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#Shadow,d2	; Load Start Index Into Frame
	jsr	GetPosition	; Get Blit Coordinates
	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq.s	NoBlitShad	; Branch if not Valid
	APALETTE	#P_BALL	; Set Palette 
	move.b	BANK(a5),d0	; Load Bank Number
	IMAGES	#Misc	; Set Image Bank
	jsr	Blit	; Display The Shadow

NoBlitShad:
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
	move.l	DATAPTR(a5),a3	; Load Address Of Frame Data
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
	move.l	DATAPTR(a5),a3	; Load Address Of Dots Data
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


;***************************************************************************
;   BlitShadow - Blit Fighter Shadows		*
;                                                                          *
;   Parameters :  a5 - Pointing to Fighter Data		*
;   Returns:      NONE                                                     *
;   Modifies:     ALL                                                      *
;***************************************************************************
BOTSCR equ 256
RGTSCR equ 384

	.import	SkewObject

BlitShadow:
	PUSHL	a0-a1/a5	; Save Registers
	DXDY	#0,#0,#0,#0x40	; Scale Images Down
;	DXDY	#0,#0,#0,#0x40	; Scale Images Down

	cmp.l	#Batter,a5	; see if batter
	bne.s	BlitShad_4	; else not
	jsr	HeadShadow
	jsr	BatShadow	; If batter.. add bat

BlitShad_4:
	jsr	BodyShadow	; Blit The Torso Shadow
	jsr	LegsShadow

		
BlitShad_5:
	SETCLIP	#0,#-60,#RGTSCR,#BOTSCR
	DXDY	#0,#0,#0,#0x100	; Reset Scaling
BlitShad_9:
	POPL	 a0-a1/a5
	rts

#comment
	
;	tst.b	INVISIBLE(a5)	; Is Fighter Invisible?
;	beq.s	BlitShad_0	; Branch If Not
;	tst.b	INVISOTAG(a5)	; Check For Inviso Tag
;	bne	BlitShad_9	; Branch If It Is
BlitShad_0:

;	tst.b	MORPHED(a5)	; Is the Fighter Morphed
;	bne	BlitShad_9	; Branch if He is

	DXDY	#0,#0,#0,#0x45	; Scale Images Down

;	tst.w	ClipShadows;
;	bmi.s	BlitShad_3 ;
;	move.w	ClipShadows,d0;
;	sub.w	CameraY,d0    	; Y Screen Coord of Ground
;	tst.b	FlopShadows	; Shadows To Be Flopped;
;	beq.s	BlitShad_2	; Branch If Not;
;BlitShad_1:;
;	SETCLIP	#0,#0,#RGTSCR,d0	; new bottom clip;
;	bra.s	BlitShad_3	                 ;
;BlitShad_2:		                 ;
;	SETCLIP	#0,d0,#RGTSCR,#BOTSCR	; new top clip   ;
BlitShad_3:		                 
BlitShad_4:
	jsr	HeadShadow
	jsr	BodyShadow	; Blit The Torso Shadow
	jsr	LegsShadow
BlitShad_5:
	SETCLIP	#0,#-60,#RGTSCR,#BOTSCR
	DXDY	#0,#0,#0,#0x100	; Reset Scaling
BlitShad_9:
	POPL	 a0-a1/a5
	rts
#endcomment

;***************************************************************************
; BodyShadow - Blit whole Body Shadow		*
;                                                                          *
;   Parameters :  a5	  - Pointing to Fighter Data	*
;   Returns:      NONE                                                     *
;   Modifies:     ALL                                                      *
;***************************************************************************
	.export	BodyShadow
BodyShadow:
	move.w	PICTURE(a5),d3	; Load Frame Number
	cmp.w	#-1,d3 	; Is Frame Defined
	beq	BodyShad_9	; Branch if Not Defined
	IMAGES	BANK(a5)	; Set For Body Bank
	APALETTE	#P_BLACK	; Set Palette For Shadow Palette
	move.l	DATAPTR(a5),a3	; Load Pointer To Frames Data
	clr.w	d2	; Load Start Index Into Frame
	jsr	GetPositionL	; Get Blit Torzo Coordinates
	jsr	Blit 	; Draw Body Shadow
	
BodyShad_9:
	rts

LegsShadow:
	move.w	PICTURE(a5),d3	; Load Frame Number
	cmp.w	#-1,d3 	; Is Frame Defined
	beq	BodyLegs_9	; Branch if Not Defined

	move.b	BANK(a5),d0	; Load Body Bank
	addq.b	#1,d0	; 
	IMAGES	d0	; Set For Body Bank

	APALETTE	#P_BLACK	; Set Palette For Shadow Palette
	move.l	DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#Legs,d2	; Load Start Index Into Frame
	jsr	GetPositionL	; Get Blit Coordinates
	jsr	Blit	; Draw Body Shadow

BodyLegs_9:
	rts


HeadShadow:
	move.w	PICTURE(a5),d3	; Load Frame Number
	cmp.w	#-1,d3 	; Is Frame Defined
	beq	BodyHead_9	; Branch if Not Defined

	move.b	BANK(a5),d0	; Load Body Bank
;	addq.b	#1,d0	; 
	IMAGES	#BatterHead	; Set For Body Bank

	APALETTE	#P_BLACK	; Set Palette For Shadow Palette
	move.l	DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#Head,d2	; Load Start Index Into Frame
	jsr	GetPositionL	; Get Blit Coordinates
	cmp.w	#-1,d3 	; Is Frame Defined
	beq	BodyHead_9	; Branch if Not Defined
	jsr	Blit	; Draw Body Shadow

BodyHead_9:
	rts


BatShadow:
	move.w	PICTURE(a5),d3	; Load Frame Number
	cmp.w	#-1,d3 	; Is Frame Defined
	beq	Bat_9	; Branch if Not Defined

	move.l	DATAPTR(a5),a3	; Load Pointer To Frames Data
	move.w	#Bat,d2	; Load Start Index Into Frame
	jsr	GetPositionL	; Get Blit Coordinates

	bra	FlipSh	
	
;From Here
	btst.b	#0,BatFF(a3)             ;0	; Check For Flop
	beq.s	FlopSh	; Branch If Not
	FLOP	ON	; Turn On Flopping
	move.b	#1,BlitFlop	; Flop The Bat
FlopSh:
	btst.b	#1,BatFF(a3)              ;1	; Check For Flip
	beq.s	FlipSh	; Branch If Not
	FLIP	ON	; Turn On Flopping
	move.b	#1,BlitFlip	; Flip The Bat
FlipSh:	
	IMAGES	#BattersBat	; Set Image Bank
	APALETTE	#P_BLACK	; Set Palette For Shadow Palette

	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq	Bat_8	; Branch if not Valid
;#comment
StartTest:	;Brian Shadow Test
	tst.b	FLOPFLAG(a5)	; Check If Flipped
	bne.s	SDspBody_1B	; Branch If He Is

	btst.b	#0,BatFF(a3)	; Check For Flop
	beq.s	SDspBody_2A	; Branch If Not
	FLOP	ON	; Turn On Flopping
	move.b	#1,BlitFlop	; Flop The Bat
	bra.s	SDspBody_2A
SDspBody_1B:
           btst.b	#0,BatFF(a3)	; Check For Flop
	beq.s	SDspBody_2A	; Branch If Not
	FLOP	OFF	; Turn On Flopping
	move.b	#-1,BlitFlop	
	
SDspBody_2A:
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	bne.s	SDspBody_2B	; Branch If He Is

	btst.b	#1,BatFF(a3)	; Check For Flip
	beq.s	SDspBody_2F	; Branch If Not
	FLIP	ON	; Turn On Flipping
	move.b	#1,BlitFlip	; Flip The Bat
	bra.s	SDspBody_2F
SDspBody_2B:
	btst.b	#1,BatFF(a3)	; Check For Flip
	beq.s	SDspBody_2F	; Branch If Not
	FLIP	OFF	; Turn Off Flipping
	move.b	#-1,BlitFlip	; Set Fr Inverted Flip

SDspBody_2F:
	APALETTE	#P_BLACK	; Set Palette 

	move.b	BANK(a5),d0	; Load Bank Number
	IMAGES	#BattersBat	; Set Image Bank

	cmp.w	#-1,d3	; Is Picture Number not Valid
	beq.s	Bat_9	; Branch if not Valid
	jsr	Blit
;End Shadow Test
;#endcomment
; 	jsr	Blit	; Draw Body Shadow
Bat_8:
	FLIP	OFF	; Turn Off Flipping
	FLOP	OFF	; Turn Off Flopping
Bat_9:
	rts

#comment
BodyShadow:
	move.w	PICTURE(a5),d3	; Load Frame Number
	cmp.w	#-1,d3 	; Is Frame Defined
	beq	BodyShad_9	; Branch if Not Defined

	move.b	BANK(a5),d0	; Load Body Bank
;	add.b	BANKOVERFLOWFLAG(a5),d0
	IMAGES	d0	; Set For Body Bank

;	tst.b	DimShadows	; Are Dim Shadows On
;	beq.s	BodyShad_0	; Branch if Not
;	APALETTE	PALETTE(a5)	; Palette Number
;	bra.s	BodyShad_1	
;BodyShad_0:
	APALETTE	#P_BLACK	; Set Palette For Shadow Palette
BodyShad_1:

	jsr	GetPosition	; Get Blit Coordinates
	bra	BodyShad_6

	move.w  	XPOSITION(a5),d4	; Load X Position
;	sub.w	CameraX,d4	; Subtract Camera Position

	move.w 	GroundY2,d5	; Load Ground
;	sub.w	CameraY,d5	; Y Screen Coord of Ground

	move.w	GroundY2,d0	; Load Ground Position
	sub.w	YPOSITION(a5),d0	; Get Distance Btwn Ground And Fighter
	lsr.w	#3,d0	; Divide By Eight

;	tst.b	DownShadows	; Are The Shadows Going Down
;	beq.s	BodyShad_2	; Branch if Not Going Down
;	neg.w	d0	; Shadows Go Down
;BodyShad_2:
	sub.w	d0,d5	; Subtract Distance Off The Ground
	sub.w	#3,d5	; Fix Shadow Position
BodyShad_2b:
	move.w	d5,Shadow_Yanchor	; Store Anchor Shadow

	move.l	DATAPTR(a5),a3	; Load Address Of Frame Data
;brian	move.b	Torso(a3),d3	; Get Right Pair of Body
	move.w	Legs(a3),d3	; Get Right Pair of Body
	cmp.w	#-1,d3	; Image Number Valid
	beq	BodyShad_9	; Branch if Image Number Not Valid

;brian	move.w	TorsoX(a3),d0	; Load Body X Offset
	clr.w	d0
	move.b	LegsX(a3),d0	; Load Body X Offset
	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Is Image Flipped
	beq.s	BodyShad_3	; Branch if it is Not
	sub.w	d0,d4	; Subtract X Offset if Flipped
	FLIP	ON	; Turn On Flipping
	bra.s	BodyShad_4
BodyShad_3:
	add.w	d0,d4	; Add X Offset if Not Flipped
BodyShad_4:
;	PUSHL	d3-d5        ;
;	jsr	SkewShadow   ;
;	POPL	d3-d5        ;

;brian	move.w	TorsoY(a3),d0	; Load Y Offset
	clr.w	d0
	move.b	LegsY(a3),d0	; Load Y Offset
	add.w	#YBIAS,d0	; UnBias Y Offset
	lsr.w	#2,d0	; divide by 4 for shadow
 
;	FLOP	OFF	; Turn Flopping Off
;	tst.b	FlopShadows	; Shadows Flopped
;	beq.s	BodyShad_5	; Branch if Not
;	FLOP	ON	; Turn Flopping On
;	neg.w	d0	; Negate Y Offset
BodyShad_5:
	add.w	d0,d5	; Add in Y Offset

BodyShad_6:
	jsr	Blit	; Draw Body Shadow

BodyShad_9:
	rts
#endcomment


	
;***************************************************************************
;   Ghost - Allocates A Fighters Ghost		*
;                                                                          *
;   Parameters :  A5 - Fighters Object		*
;   Returns:      NONE		*
;   Modifies:			*
;***************************************************************************
Ghost:
;	rts
	clr.b	d1	; Set For No Collision
	jsr	AllocObject	; Ghost Object
	beq	Ghost_2	; Branch if Allocation Failed

	; Load Ghost Specific Object Values
	move.w	LASTXPOSITION(a5),XPOSITION(a0)
	move.w	LASTYPOSITION(a5),YPOSITION(a0)
	move.w	ZPOSITION(a5),ZPOSITION(a0)
	sub.w	#20,ZPOSITION(a0)
	move.b	#0x7F,OBJECTTYPE(a0)	; Set Object Type

	move.l	#BlitGhost,DISPLAYPROC(a0)
	move.l	#Anim,UPDATEPROC(a0)

	move.l	#GhostShadow,d0
	move.b	GHOSTPALETTE(a5),d1
	move.b	d1,PALETTE(a0)
	and.b	#3,d1	; Extract Lower Two Bits
	bne.s	Ghost_1	; Branch If Not DIM4 Palette
	move.l	#GhostDisapate,d0	; Set For Ghosting Disapate
Ghost_1:
	move.l	d0,PARSEPOINTER(a0)

	move.b	BANK(a5),BANK(a0)	; Store Bank

	move.b	FLIPFLAG(a5),FLIPFLAG(a0)
	move.w	PICTURE(a5),PICTURE(a0)
	move.w	CURRENTFRAME(a5),CURRENTFRAME(a0)
	move.l	DATAPTR(a5),DATAPTR(a0)

	clr.l	COLLISIONPROC(a0)
	clr.b	COLLISIONMODE(a0)
	move.l	a6,RELATED(a0)
	move.l	a5,PARENT(a0)
Ghost_2:
	rts

BlitGhost:
	APALETTE	PALETTE(a5)	; Load Ghost Palette
	IMAGES	BANK(a5)	; Set Image Bank
	move.w	#Torso,d2
	bsr	BlitPiece
BlitGhost_2:
	rts

GhostShadow
	LASTFRAME	1
	DECRAM	ZPOSITION
	LASTFRAME	1
	DECRAM	ZPOSITION
	LASTFRAME	1
	DECRAM	ZPOSITION
	LASTFRAME	2
	DEALLOC

GhostDisapate:
	LASTFRAME	1
	DECRAM	PALETTE
	DECRAM	ZPOSITION
	LASTFRAME	1
	DECRAM	PALETTE
	DECRAM	ZPOSITION
	LASTFRAME	1
	DECRAM	PALETTE
	DECRAM	ZPOSITION
	LASTFRAME	2
	DEALLOC


;***************************************************************************
;   BlitPiece			*
;                                                                          *
;   Parameters :  D2 - Offset Into a Frame 		*
;                 A5 - Fighter's Object		*
;   Returns:      NONE                                                     *
;   Modifies:			*
;***************************************************************************
	.align	2
BlitPiece:
 	move.w	XPOSITION(a5),d4	; Load X Position
 	move.w	YPOSITION(a5),d5	; Load Y Position
	move.l	DATAPTR(a5),a3	; Load Address Of Dots Data

	move.w	TorsoX(a3,d2.w),d0	; Load X Offset of Torso
	move.w	TorsoY(a3,d2.w),d1	; Load Y Offset of Torso
	
	add.w	#YBIAS,d1	; Unbias Y Offset
	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	BlitPiece_1	; Branch If Not
	neg.w	d0	; Negate The X Offset
	FLIP	ON	; Turn On Flipping
BlitPiece_1:
	add.w	d0,d4	; Add To X Position
	add.w	d1,d5	; Add To Y Position
	move.w	(a3,d2.w),d3	; Load Image Number
	cmp.w	#-1,d3	; Is Image Number Valid
	beq.s	BlitPiece_2	; Branch if Not Valid
	jsr	Blit	; Draw the Piece
BlitPiece_2:
	rts

;***************************************************************************
;   BlitDeadPiece			*
;                                                                          *
;   Parameters :  D2 - Offset Into a Frame 		*
;                 A5 - Fighter's Object		*
;   Returns:      NONE                                                     *
;   Modifies:			*
;***************************************************************************
	.align	2
BlitDeadPiece:
 	move.w	XPOSITION(a5),d4	; Load X Position
	move.w	XFACTOR(a5),d1	; Load X Scroll Factor
	beq.s	BlitDeadObj_3	; Branch If Not Scrolling
;	move.w	CameraX,d0	; Load Camera Position
	cmp.w	#0x100,d1	; Check If Player Scroll
	beq.s	BlitDeadObj_2	; Branch If It Is
	muls	d1,d0	; Multiply By Camera Position
	asr.l	#8,d0	; Divide By 256
BlitDeadObj_2:
	sub.w	d0,d4	; Add Into X Position

BlitDeadObj_3:
	move.w	YPOSITION(a5),d5	; Load Y Position
;	sub.w	CameraY,d5	; Load Camera Position
;	move.w	YFACTOR(a5),d1	; Load Y Scroll Factor
;	beq.s	BlitDeadObj_4	; Branch If None
;	move.w	CameraY,d0	; Load Camera Position
;	cmp.w	#0x100,d1	; Check If Player Scroll
;	beq.s	BlitDeadObj_3A	; Branch If It Is
;	muls	d1,d0	; Multiply By Camera Position
;	asr.l	#8,d0	; Divide By 256
;BlitDeadObj_3A:
;	sub.w	d0,d5	; Add Into Y Position
;BlitDeadObj_4:

	move.l	DATAPTR(a5),a3	; Load Address Of Dots Data
	move.w	TorsoX(a3,d2.w),d0	; Load X Offset of Torso
	move.w	TorsoY(a3,d2.w),d1	; Load Y Offset of Torso
	
	add.w	#YBIAS,d1	; Unbias Y Offset
	FLIP	OFF	; Turn Off Flipping
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	BlitDeadPiece_1	; Branch If Not
	neg.w	d0	; Negate The X Offset
	FLIP	ON	; Turn On Flipping
BlitDeadPiece_1:
	add.w	d0,d4	; Add To X Position
	add.w	d1,d5	; Add To Y Position
	move.w	(a3,d2.w),d3	; Load Image Number
	cmp.w	#-1,d3	; Is Image Number Valid
	beq.s	BlitDeadPiece_2	; Branch if Not Valid
	jsr	Blit	; Draw the Piece
BlitDeadPiece_2:
	rts

	rts

DotOffsets:
	dc.b	CollideData	; 00 - 000000
	dc.b	CollideData+4	; 01 - 000001
	dc.b	CollideData+4	; 02 - 000010
	dc.b	CollideData+8	; 03 - 000011
	dc.b	CollideData+4	; 04 - 000100
	dc.b	CollideData+8	; 05 - 000101
	dc.b	CollideData+8	; 06 - 000110
	dc.b	CollideData+12	; 07 - 000111
	dc.b	CollideData+4	; 08 - 001000
	dc.b	CollideData+8	; 09 - 001001
	dc.b	CollideData+8	; 10 - 001010
	dc.b	CollideData+12	; 11 - 001011
	dc.b	CollideData+8	; 12 - 001100
	dc.b	CollideData+12	; 13 - 001101
	dc.b	CollideData+12	; 14 - 001110
	dc.b	CollideData+16	; 15 - 001111
	dc.b	CollideData+4	; 16 - 010000
	dc.b	CollideData+8	; 17 - 010001
	dc.b	CollideData+8	; 18 - 010010
	dc.b	CollideData+12	; 19 - 010011
	dc.b	CollideData+8	; 20 - 010100
	dc.b	CollideData+12	; 21 - 010101
	dc.b	CollideData+12	; 22 - 010110
	dc.b	CollideData+16	; 23 - 010111
	dc.b	CollideData+8	; 24 - 011000
	dc.b	CollideData+12	; 25 - 011001
	dc.b	CollideData+12	; 26 - 011010
	dc.b	CollideData+16	; 27 - 011011
	dc.b	CollideData+12	; 28 - 011100
	dc.b	CollideData+16	; 29 - 011101
	dc.b	CollideData+16	; 30 - 011110
	dc.b	CollideData+20	; 31 - 011111
	dc.b	CollideData+4	; 32 - 100000
	dc.b	CollideData+8	; 33 - 100001
	dc.b	CollideData+8	; 34 - 100010
	dc.b	CollideData+12	; 35 - 100011
	dc.b	CollideData+8	; 36 - 100100
	dc.b	CollideData+12	; 37 - 100101
	dc.b	CollideData+12	; 38 - 100110
	dc.b	CollideData+16	; 39 - 100111
	dc.b	CollideData+8	; 40 - 101000
	dc.b	CollideData+12	; 41 - 101001
	dc.b	CollideData+12	; 42 - 101010
	dc.b	CollideData+16	; 43 - 101011
	dc.b	CollideData+12	; 44 - 101100
	dc.b	CollideData+16	; 45 - 101101
	dc.b	CollideData+16	; 46 - 101110
	dc.b	CollideData+20	; 47 - 101111
	dc.b	CollideData+8	; 48 - 110000
	dc.b	CollideData+12	; 49 - 110001
	dc.b	CollideData+12	; 50 - 110010
	dc.b	CollideData+16	; 51 - 110011
	dc.b	CollideData+12	; 52 - 110100
	dc.b	CollideData+16	; 53 - 110101
	dc.b	CollideData+16	; 54 - 110110
	dc.b	CollideData+20	; 55 - 110111
	dc.b	CollideData+12	; 56 - 111000
	dc.b	CollideData+16	; 57 - 111001
	dc.b	CollideData+16	; 58 - 111010
	dc.b	CollideData+20	; 59 - 111011
	dc.b	CollideData+16	; 60 - 111100
	dc.b	CollideData+20	; 61 - 111101
	dc.b	CollideData+20	; 62 - 111110
	dc.b	CollideData+24	; 63 - 111111

	dc.b	CollideData+4	; 64 -1000000
	dc.b	CollideData+8	; 65 -1000001
	dc.b	CollideData+8	; 66 -1000010
	dc.b	CollideData+12	; 67 -1000011
	dc.b	CollideData+8	; 68 -1000100
	dc.b	CollideData+12	; 69 -1000101
	dc.b	CollideData+12	; 70 -1000110
	dc.b	CollideData+16	; 71 -1000111
	dc.b	CollideData+8	; 72 -1001000
	dc.b	CollideData+12	; 73 -1001001
	dc.b	CollideData+12	; 74 -1001010
	dc.b	CollideData+16	; 75 -1001011
	dc.b	CollideData+12	; 76 -1001100
	dc.b	CollideData+16	; 77 -1001101
	dc.b	CollideData+16	; 78 -1001110
	dc.b	CollideData+20	; 79 -1001111
	dc.b	CollideData+8	; 80 -1010000
	dc.b	CollideData+12	; 81 -1010001
	dc.b	CollideData+12	; 82 -1010010
	dc.b	CollideData+16	; 83 -1010011
	dc.b	CollideData+12	; 84 -1010100
	dc.b	CollideData+16	; 85 -1010101
	dc.b	CollideData+16	; 86 -1010110
	dc.b	CollideData+20	; 87 -1010111
	dc.b	CollideData+12	; 88 -1011000
	dc.b	CollideData+16	; 89 -1011001
	dc.b	CollideData+16	; 90 -1011010
	dc.b	CollideData+20	; 91 -1011011
	dc.b	CollideData+16	; 92 -1011100
	dc.b	CollideData+20	; 93 -1011101
	dc.b	CollideData+20	; 94 -1011110
	dc.b	CollideData+24	; 95 -1011111
	dc.b	CollideData+8	; 96 -1100000
	dc.b	CollideData+12	; 97 -1100001
	dc.b	CollideData+12	; 98 -1100010
	dc.b	CollideData+16	; 99 -1100011
	dc.b	CollideData+12	;100 -1100100
	dc.b	CollideData+16	;101 -1100101
	dc.b	CollideData+16	;102 -1100110
	dc.b	CollideData+20	;103 -1100111
	dc.b	CollideData+12	;104 -1101000
	dc.b	CollideData+16	;105 -1101001
	dc.b	CollideData+16	;106 -1101010
	dc.b	CollideData+20	;107 -1101011
	dc.b	CollideData+16	;108 -1101100
	dc.b	CollideData+20	;109 -1101101
	dc.b	CollideData+20	;110 -1101110
	dc.b	CollideData+24	;111 -1101111
	dc.b	CollideData+12	;112 -1110000
	dc.b	CollideData+16	;113 -1110001
	dc.b	CollideData+16	;114 -1110010
	dc.b	CollideData+20	;115 -1110011
	dc.b	CollideData+16	;116 -1110100
	dc.b	CollideData+20	;117 -1110101
	dc.b	CollideData+20	;118 -1110110
	dc.b	CollideData+24	;119 -1110111
	dc.b	CollideData+16	;120 -1111000
	dc.b	CollideData+20	;121 -1111001
	dc.b	CollideData+20	;122 -1111010
	dc.b	CollideData+24	;123 -1111011
	dc.b	CollideData+20	;124 -1111100
	dc.b	CollideData+24	;125 -1111101
	dc.b	CollideData+24	;126 -1111110
	dc.b	CollideData+28	;127 -1111111
			      

	end





