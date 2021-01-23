;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************
NOTHING	= 0
STOP	= 1
LEADOFF	= 2
SPRINT	= 3
BACKOFF	= 4
BACKSPRINT	= 5

	ds	0
;	#include	"c:\bb\player.h"
;	#include	"r:\baseball\art\tables\player.h"
;	#include	"r:\baseball\sounds\bsblsnds.equ"
	#include	"bsblsnds.equ"
	#include	"player.h"
	#include	"ramblock.h"
	#include	"pals.h"
	#include	"groms.h"
	#include	"sys.mac"
	#include	"graphlib.mac"
	#include	"graphlib.h"
	#include	"graphglb.h"
	#include	"controls.h" 
	#include	"anim.mac"

;	.export	FirstWinxObj
	.export	RunnerIntroF
	.export   frmove
	.import	BlitClipObj,BlitFlip,Anim
	.import	AllocObject,DeallocObject
	.import	FirstObjPtr,FirstViewObj,FirstRunPtr,FirstRunStart,Batter
	.import	AtBatPlayer,SecondRunStart
	.export	SecondRunX,SecondRunY
	.import	ClearUpField
	.import	ClearUp_1
	.import	ClearUpField_2
	.import	NewBatterUp
	.import	SecondRunStart
	.import	CheckBases
	.import	Dust
	.export	RunToSecondBase
	.export	Steal2nd
	.import	BATTER_NOCONTROLS

	.region.s	"RAM"

frmove 	ds.b	1
RunPtr	ds.l	1
SecondRunX ds.l	1
SecondRunY ds.l	1
Steal2nd	ds.b	1
;First Base Runners Sprite Animations
	.region	"RomCode"

RunnerIntroF:
	SETRAM	COUNTER,STOP
 	SYSTEM	ClearFirstStuff
	SYSTEM	PutSecondRun
QED



;         	SYSTEM	FirstViewObj	;first base window
;	SYSTEM	FirstWinxObj       ;Modified

RunnerIntro_0:
	CLRFLIP
	SPRITE1 r03d01,4

;	SPRITE1	r13h01,50
;	SPRITE1	r13h02,10
;	SPRITE1	r13h03,10
;	SPRITE1	r13h04,10
;	SPRITE1	r13h05,10
;	SPRITE1	r13h06,10
;	SPRITE1	r13h07,10
	JUMP	LastLoop


RunToSecondBase:    ;In box
	INPUTSUB	BATTER_NOCONTROLS
	MOVE	-1,3
	SETRAM	COUNTER,SPRINT
	SETFLIP
RunLoop1:			;Run in the BOX
	SOUNDS	PlayerRuns,#0
	SYSTEM	MoveRunToSec	
	SPRITE1 r03d01,4
	SPRITE1 r03d02,4
	SPRITE1 r03d03,4
	SPRITE1 r03d04,4
	SOUNDS	PlayerRuns,#0
	SYSTEM	MoveRunToSec	
	SPRITE1 r03d06,4
	SPRITE1 r03d07,4
	SPRITE1 r03d09,4
	SPRITE1 r03d10,4
	SOUNDS	PlayerRuns,#0
	SYSTEM	MoveRunToSec	
	SPRITE1 r03d01,4
	SPRITE1 r03d02,4
	SPRITE1 r03d03,4
	SPRITE1 r03d04,4
	SOUNDS	PlayerRuns,#0
	SYSTEM	MoveRunToSec	
	SPRITE1 r03d06,4
	SPRITE1 r03d07,4
	SPRITE1 r03d09,4
	SPRITE1 r03d10,4
	MOVE	3,0

RunSecField:    ;run to second in the field.
	SETRAMW	XPOSITION,375
	SETRAMW	YPOSITION,118
;	MOVE	25,64
	SYSTEM	SetScreenXY
	SETFLIP
StillRunning:
	INPUTSUB	BATTER_NOCONTROLS
	SOUNDS	PlayerRuns,#0
	SYSTEM	MoveRunToSec	
	SYSTEM	ShouldSlide
	SPRITE1 r03d01,4
	MOVE	-6,-1
	SPRITE1 r03d02,4
	MOVE	-6,0
	SYSTEM	ShouldSlide
	SPRITE1 r03d03,4
	MOVE	-6,-1
	SPRITE1 r03d04,4
	MOVE	-6,0
	SOUNDS	PlayerRuns,#0
	SYSTEM	MoveRunToSec	
	SYSTEM	ShouldSlide
	SPRITE1 r03d06,4
	MOVE	-6,-1
	SPRITE1 r03d07,4
	MOVE	-6,0
	SYSTEM	ShouldSlide
	SPRITE1 r03d09,4
	MOVE	-6,-1
	SPRITE1 r03d10,4
	MOVE	-6,0
           JUMP	StillRunning

SlideSecond1:	   
	CLRFLIP
	SPRITE r44f01,8
	MOVE -12,0
	SPRITE r44f02,8
	MOVE -7,-1
	SPRITE r44f03,8
	MOVE -23,-1   
	SPRITE r44f04,8
	MOVE -13,-1
	SPRITE r44f05,8
	MOVE -5,0
	SPRITE r44f06,12
	MOVE -9,-2
	SPRITE r44f06,12
	MOVE -4,-2
	SPRITE r44f06,12
	MOVE -4,-2
	SPRITE r44f06,12
	MOVE -4,-3
	SPRITE r44f06,90
	DEALLOC
;	SYSTEM	FirstRunStart
	JUMP	RunnerIntro_0
		
SlideSecond2:
	INPUTSUB	BATTER_NOCONTROLS
	CLRFLIP
	SOUNDS	PlayerSlides,#0
	SYSTEM	Dust
	SPRITE r76f01,3
	MOVE -5,5
	SPRITE r76f02,3
	MOVE 2,0
	SPRITE r76f03,6
	MOVE -6,0
	SPRITE r76f04,6
	MOVE 0,1
	SPRITE r76f05,5
	MOVE 0,-1	    
	SPRITE r76f06,5
	MOVE -5,0
	SPRITE r76f07,5
	SPRITE r76f08,5
	MOVE -12,-1
	SPRITE r76f09,5
	MOVE -3,0
	SPRITE r76f10,5
	SPRITE r76f11,5
	MOVE -4,0
	SPRITE r76f12,5
	MOVE -7,0
	SPRITE r76f13,7
	SPRITE r76f14,6
	SPRITE r76f15,6
	SPRITE r76f16,6
	SPRITE r76f17,6
;	SYSTEM	CheckClearUp
	SETRAM	B_ONBASE,2	; Set On Second Base
	SYSTEM	ClearUpField	; Clear Up Field
	SYSTEM	SecondRunStart
	STOPANIM
	
          .align	2

ClearFirstStuff:
	clr.b	Steal2nd
	clr.b	d1	; Set As Non Collidable
	rts

#comment          
FirstWinxObj:   ;This is the View window of the First Base
	clr.b	Steal2nd
	clr.b	d1	; Set As Non Collidable

         ;	
         ;	jsr	AllocObject	; Allocate An Object
         ;	beq.s	First_W	; Branch If None
         ;
         ;	move.l	a5,CHILD(a0) ;store the batters Object pointer 
         ;	move.w	#320,XCLIP1(a0)
         ;	move.w	#373,XCLIP2(a0)
         ;	move.w	#11,YCLIP1(a0)
         ;	move.w	#57,YCLIP2(a0)
         ;	move.l	#BlitClipObj,DISPLAYPROC(a0) ; Store Address Of Display Procedure
         ;	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine was;
         ;	move.w	#10,ZPOSITION(a0)	; Initialize Z Position
         ;	move.w	#winclip1,PICTURE(a0)	; Set Field Picture
         ;	move.l	#FirstWAnim,PARSEPOINTER(a0) ;First Window animation was ;
         ;	move.b	#P_WINC,PALETTE(a0)	; Set Palette Number
         ;	move.w	#112,XPOSITION(a0)	; Set X Position
         ;	move.w	#-54,YPOSITION(a0)	; Set Y Position
         ;	move.b	#Misc,BANK(a0)	; Set Bank Number
         ;	clr.w	STARTCHARACTER(a0)
         ;	move.w	#0xFFFF,NUMBEROFCHARS(a0)
         ;	move.l	a0,RunPtr
;First_W:
 ;	rts
#endcomment	
	.align	2

;	.export FirstWAnim
;FirstWAnim:
;	ALWAYS	CheckFirstRunner	
;	SETVEL	0,0,-1
;	LASTFRAME 127
;         	JUMP	FirstWAnim

;CheckFirstRunner has in it's CHILD pointer, the First base runner
;the runner sets his COUNTER to a direction and the FirstWAnim
;will automatically follow the movements of that runner

	.align	2
CheckFirstRunner
	move.l	CHILD(a5),a0
	clr.l	d0
	move.b	COUNTER(a0),d0
	tst.b	d0
	beq.s	CheckFirstRunner_9

	move.l	#FirstRunnerTable,a1
	move.l	(a1,d0.w*4),a1 
	jsr	(a1)

CheckFirstRunner_9
	rts

FirstRunnerTable:
	dc.l	0
	dc.l	Stop	
	dc.l	Leadoff	
	dc.l	Sprint	
	dc.l	Backoff	
	dc.l	Backsprint

LEADSPEEDX		equ 0x8f
LEADSPEEDY		equ 0x4f	;was 5f
SPRINTSPEEDX	equ 0x13f
SPRINTSPEEDY	equ 0x0ff

	.align	2
Stop	
	clr.w	XVELOCITY(a5)
	clr.w	YVELOCITY(a5)
	rts

	.align	2
Leadoff	
	move.w	#LEADSPEEDX,XVELOCITY(a5)
	move.w	#LEADSPEEDY,YVELOCITY(a5)
	rts
	
	.align	2
Sprint	
	move.w	#SPRINTSPEEDX,XVELOCITY(a5)
	move.w	#SPRINTSPEEDY,YVELOCITY(a5)
	rts
	
	.align	2
Backoff	
	move.w	#-LEADSPEEDX,XVELOCITY(a5)
	move.w	#-LEADSPEEDY,YVELOCITY(a5)
	rts
	
	.align	2
Backsprint
	move.w	#-SPRINTSPEEDX,XVELOCITY(a5)
	move.w	#-SPRINTSPEEDY,YVELOCITY(a5)
	rts

	.align	2

;FirstBox:
;	SEMSET	FirstObjPtr
;         	SYSTEM	FirstViewObj
;	QED
ClearBViews:
;	SEMSET	FirstObjPtr
	SYSTEM	ClearBViews2
	QED

	.align	2

ClearBViews2:
	move.l	FirstObjPtr,a5
	jsr	DeallocObject
	rts

	.align	2

	.export	LeadTrigger_2nd,BackTrigger_1st

LeadTrigger_2nd:		;Do leading to Second
;	SYSTEM	GiveCounterToBatter	;Set counter to buttons
	SYSTEM	FTriggerLead_1	;Start anim
	SYSTEM	GiveControlsToBatter
	QED


BackTrigger_1st:		;Do back to Second
	SYSTEM	GiveCounterToBatter	;Set counter to buttons
	SYSTEM	FTriggerBack_1	;Start anim
	QED
LastLoop:			;Loop on last frame
	LASTFRAME	5
	JUMP	LastLoop
	.align	2
LeadToSecond:		;Lead to second anim
	SPRITE1 r06f01,8
	SETRAM  COUNTER,LEADOFF	;Move Background
	SPRITE1 r06f02,8
	SPRITE1 r06f03,8
	SPRITE1 r06f04,7
	SPRITE1 r06f05,7
	SETRAM  COUNTER,STOP	;Stop Background
	SPRITE1 r06f06,7
	LOADABS	BaseCount
	JUMPCMP	4,FirstControl
	LOADABS	BaseCount
	JUMPCMP	1,FirstControl
	JUMP	LastLoop
FirstControl:		
	SYSTEM	GiveControlsToBatter	;Give controls to batter
	JUMP	LastLoop	;Loop on last frame
	.align	2

BackToFirst:		;Go back to first anim
	SPRITE1 r06f06,8
	SETRAM  COUNTER,BACKOFF	;Move background
	SPRITE1 r06f05,8
	SPRITE1 r06f04,8
	SPRITE1 r06f03,7
	SPRITE1 r06f02,7
	SETRAM  COUNTER,STOP	;Stop Background
	SPRITE1 r06f01,7
	LOADABS	BaseCount
	JUMPCMP	1,FirstControl2
	LOADABS	BaseCount
	JUMPCMP	4,FirstControl2
	JUMP	LastLoop
FirstControl2:		
	SYSTEM	GiveControlsToBatter	;Give controls to batter
	JUMP	LastLoop	;Loop on last frame

	.align	2
	.import	SecondRunner,BATTER_CONTROLS,CONTROLS_COUNT
 	.import	GiveControlsToBatter,BaseCount,FirstButton
	.import	GiveCounterToBatter
	.import	ThirdRunner
	.export	FTriggerLead_1,FTriggerBack_1
	.align	2

FTriggerLead_1:		;Start leading off
	cmp.b	#1,FirstButton	;is he stealing?
	ble.s	LeadOff	;No, leadoff

;	clr.b	B_ONBASE
	move.l	#SecondRunner,a0	;Move runner to a0
	move.b	#-2,B_ONBASE(a0)
;	move.l	Batter+CONTROLBLOCK,a1
;	tst.b	POWERUP(a1)	; Check If Powered Up
;	bne.s	Steal_2nd

	tst.b	Steal2nd
	bne	Stealing
	move.l	#SecondRunner,a0	;Move runner to a0
;	sub.l	#3*12*256,WORLDX(a0)	;was SecondRunX
;	add.l	#3*12*256,WORLDY(a0)
			;so no stealing will happen
	cmp.b	#1,FirstButton	;is he stealing?
	ble.s	LeadOff	;No, leadoff

Steal_2nd:
	move.b	#1,Steal2nd
	move.b	#4,FirstButton

	move.l	#SecondRunner,a0	;Move runner to a0
	jsr	GiveCounterToBatter	;Give controls to batter
	move.l	#RunToSecondBase,PARSEPOINTER(a0);Stealing!Run to second
	rts		;return
LeadOff:
;	move.l	#LeadToSecond,PARSEPOINTER(a0) ;Just lead off
	addi.b	#1,FirstButton	;Add one to button counter
Stealing:
	rts		;retrun

	.align	2
FTriggerBack_1:
	tst.b	Steal2nd
	bne	CantBack
	move.l	#SecondRunner,a0	;Move runner to a0
	cmp.l	#FIRSTBASEX,WORLDX(a0)
	bge.s	CantBack
	add.l	#3*12*256,WORLDX(a0)
	sub.l	#3*12*256,WORLDY(a0)
	move.l	#SecondRunner,a0	;Move runner to a0
	move.l	#BackToFirst,PARSEPOINTER(a0);JAM PARSE
    ;	subi.b	#1,FirstButton	;Subtract 1 from counter
	rts
CantBack:
	move.b	#1,B_ONBASE
    ;	clr.b	FirstButton
	jsr	GiveControlsToBatter
	rts		;return

	.align	2
PutSecondRun:
	move.l	#SecondRunner,a0	;Move runner to a0
	move.l	#FIRSTBASEX,WORLDX(a0)	; Set Start X Position
	move.l	#FIRSTBASEY,WORLDY(a0)	; Set Start Y Position
	clr.b	FirstButton
	rts
	.align	2

MoveRunToSec:
	move.l	#SecondRunner,a0	;Move runner to a0
	sub.l	#4*12*256,WORLDX(a0)
	add.l	#4*12*256,WORLDY(a0)
	rts
	.align	2

ShouldSlide:		;Slide 7 feet before base
	move.l	#SecondRunner,a0	;Move runner to a0
	cmp.l	#SECONDBASEX+6*12*256,WORLDX(a0)
	bge.s	doneshould
	move.l	#SlideSecond2,PARSEPOINTER(a0);JAM PARSE
doneshould:
	rts

	.align	2
SetScreenXY:
	move.l	#SecondRunner,a0	;Move runner to a0
	move.l	#FIRSTBASEX,WORLDX(a0)	; Set Start X Position
	move.l	#FIRSTBASEY,WORLDY(a0)	; Set Start Y Position
	sub.l	#31*12*256,WORLDX(a0)
	add.l	#31*12*256,WORLDY(a0)
	rts
	.align	2
CheckClearUp:
	move.b	#2,B_ONBASE+SecondRunner
	move.l	#SecondRunner,d0
	jsr	ClearUp_1
	clr.b	B_INUSE+SecondRunner
	clr.l	SecondRunner+UPDATEPROC
RunnerOnThird:
	rts
	.align	2


