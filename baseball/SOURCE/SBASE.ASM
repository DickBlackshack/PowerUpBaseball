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
;	#include	"itvideo2.h"
;	#include	"anim.mac"
;	#include	"controls.h"
;	#include	"c:\bb\player.h"
;	#include	"r:\baseball\art\tables\player.h"
;	#include	"groms.h"
;	#include	"joydefs.h"
;	#include	"pals.h"
;	#include	"ramblock.h"
;	#include	"graphlib.mac"
;	#include  "graphlib.h"
;	#include	"graphlb.h"
;	#include  "sys.mac"

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

	.export	RunnerIntroS
;	.export	RunToThirdBase
	.import	BlitClipObj,BlitFlip
	.import	AllocObject,DeallocObject
	.import	Anim
	.import	SecondRunPtr,SecondRunStart,Batter
	.import	CheckBases,ThirdRunStart
	.import	ClearUpField
	.import	ClearUp_1
;	.import	RunToSecondBase
	.export	ThirdRunX,ThirdRunY
	.export	Steal3rd
	.import	BATTER_NOCONTROLS


	
	.region.s	"RAM"

frmove 	ds.b	1
RunPtr	ds.l	1
ThirdRunX	ds.l	1
ThirdRunY	ds.l	1
Steal3rd	ds.l	1

;Second Base Runners Sprite Animations
	.region	"RomCode"

RunnerIntroS:
;	SPRITE1	r13h01,10
	SPRITE	rxdb08,7
	SYSTEM	PutThirdRun          	
	SYSTEM	CheckBases
	SYSTEM	GiveControlsToBatter
RunnerIntro_0:
;	SETFLIP
;	SPRITE1	r13h01,50
;	SPRITE1	r13h02,10
;	SPRITE1	r13h03,10
;	SPRITE1	r13h04,10
;	SPRITE1	r13h05,10
;	SPRITE1	r13h06,10
;	SPRITE1	r13h07,20


KeepShift:
	SPRITE	rxdb08,7
	SPRITE	rxdb07,7
	SPRITE	rxdb06,7
	SPRITE	rxdb05,7
	SPRITE	rxdb04,7
	SPRITE	rxdb03,7
	SPRITE	rxdb02,7
	SPRITE	rxdb01,7

	
;	SPRITE	rxdb07,7
;	SPRITE	rxdb06,7

;	SPRITE	rxdb07,7
;	SPRITE	rxdb01,7
;	SPRITE	rxdb02,7
;	SPRITE	rxdb03,7
;	SPRITE	rxdb04,7

	JUMP	KeepShift
	;Last Loop
	
KeepLead:
	SPRITE1 r06f05,7
	SPRITE1 r06f06,7
;	SPRITE1 r06f07,7
;	SPRITE1 r06f08,8
	SPRITE1 r06f04,7
	SPRITE1 r06f05,7
	SPRITE1 r06f06,7
;	SPRITE1 r06f07,7
;	SPRITE1 r06f08,8
;	SPRITE1 r06f09,20
JustStop:
	SPRITE r06f06,127
;	SYSTEM	SecondRunStart
;	JUMP	JustStop	


RunToThirdBase:
	INPUTSUB	BATTER_NOCONTROLS
	SETFLIP
	SYSTEM	MoveRunToThr
	SYSTEM	ShouldSlide
	SPRITE1 r03b01,4
	MOVE	-6,1
	SPRITE1 r03b02,4
	MOVE	-6,0
	SYSTEM	ShouldSlide
	SPRITE1 r03b03,4
	MOVE	-6,0
	SPRITE1 r03b04,4
	MOVE	-6,0
	SOUNDS	PlayerRuns,#0
	SYSTEM	MoveRunToThr
	SYSTEM	ShouldSlide
	SPRITE1 r03b05,4
	MOVE	-6,0
	SPRITE1 r03b06,4
	MOVE	-6,0
	SYSTEM	ShouldSlide
	SPRITE1 r03b07,4
	MOVE	-6,0
	SPRITE1 r03b01,4
	MOVE	-6,1
	INPUTSUB	BATTER_NOCONTROLS
	JUMP	RunToThirdBase
	
#comment
	SYSTEM	MoveRunToThr
	SYSTEM	ShouldSlide
	SPRITE1 r03b02,4
	MOVE	-6,0
	SPRITE1 r03b03,4
	MOVE	-6,0
	SYSTEM	ShouldSlide
	SPRITE1 r03b04,4
	MOVE	-6,0
	SPRITE1 r03b05,4
	MOVE	-6,1
	SYSTEM	MoveRunToThr
	SYSTEM	ShouldSlide
	SPRITE1 r03b06,4
	MOVE	-6,1
	SPRITE1 r03b07,4
 	MOVE	-6,1
	SPRITE1 r03b01,4
	MOVE	-6,0
	SPRITE1 r03b02,4
	MOVE	-6,0
	SPRITE1 r03b03,4
	MOVE	-6,0
	SPRITE1 r03b04,4
	MOVE	-6,0
	SPRITE1 r03b05,4
	MOVE	-6,0
	SPRITE1 r03b06,4
	MOVE	-6,0
	SPRITE1 r03b07,4
	MOVE	-6,0
	SPRITE1 r03b01,4
	MOVE	-6,0
	SPRITE1 r03b02,4
	MOVE	-6,0
	SPRITE1 r03b03,4
	MOVE	-6,1
	SPRITE1 r03b04,4
	MOVE	-6,1
	SPRITE1 r03b05,4
	MOVE	-6,1
	SPRITE1 r03b06,4
	MOVE	-6,1
JustStop2:
	SPRITE1 r03b07,4
#endcomment	
;	SYSTEM	Anim_NoFlip
;	DEALLOC	 
;	SYSTEM	SecondRunStart
;	JUMP	RunnerIntro_0
;	JUMP	JustStop2
	.align	2
	
SlideThird2:
	INPUTSUB	BATTER_NOCONTROLS
	SPRITE1 r03b07,4
	SETRAM	B_ONBASE,3
	SYSTEM	ClearUpField
	SYSTEM	ThirdRunStart
	STOPANIM
	
	.align	2

;ClearRun:
;	rts

;CheckSecondRunner has in it's CHILD pointer, the First base runner
;the runner sets his COUNTER to a direction and the FirstWAnim
;will automatically follow the movements of that runner

	.align	2
CheckSecondRunner
	move.l	CHILD(a5),a0
	clr.l	d0
	move.b	COUNTER(a0),d0
	tst.b	d0
	beq.s	CheckSecondRunner_9

	move.l	#SecondRunnerTable,a1
	move.l	(a1,d0.w*4),a1 
	jsr	(a1)

CheckSecondRunner_9
	rts

SecondRunnerTable:
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

	.export	LeadTrigger_3rd,BackTrigger_2nd

LeadTrigger_3rd:	              	;Does the Leading to third
;	SYSTEM	GiveCounterToBatter	;Put counter on buttons
	SYSTEM	STriggerLead_1	;Call routine to do anim
	SYSTEM	GiveControlsToBatter
	QED
BackTrigger_2nd:		;Go back to second
	SYSTEM	GiveCounterToBatter	;Put counter on buttons
	SYSTEM	STriggerBack_1	;Call routine to do anim
	QED

	
LastLoop:			;Loops on the last frame
	LASTFRAME	5
	JUMP	LastLoop
	
LeadToThird:		;Lead to third anim
	SYSTEM	GiveCounterToBatter	;Put counter on buttons
	MOVE -2,0
	SPRITE	rxda01,7
	MOVE -3,0
	SPRITE	rxda02,7
	SPRITE	rxda03,7
	SPRITE	rxda04,7
	MOVE -3,0
	SPRITE	rxda05,7
	MOVE -4,0
	SPRITE	rxda06,7
	MOVE -3,0
;	SPRITE	rxda07,7
;	MOVE -1,0
	
;	SPRITE r06f06,8
;	SPRITE r06f05,8
;	MOVE -2,0
;	SPRITE r06f04,8
;	MOVE -5,1
;	SPRITE r06f03,7
;	MOVE -5,0
;	SPRITE r06f02,7
;	MOVE -3,0
;	SPRITE r06f01,7
	LOADABS	BaseCount
	JUMPCMP	2,SecondControl
	JUMP	KeepShift

;	JUMP	LastLoop
SecondControl:		
	SYSTEM	GiveControlsToBatter	;Give controls to batter
	JUMP	KeepShift	;Loop on last frame
;	JUMP	LastLoop
	.align	2

BackToSecond:		;Back to second anim
	SYSTEM	GiveCounterToBatter	;Put counter on buttons
	SPRITE r06f01,8
;	MOVE 4,1
	SPRITE r06f02,8
	MOVE 3,0
	SPRITE r06f03,8
	MOVE 5,0
	SPRITE r06f04,7
	MOVE 5,-1
	SPRITE r06f05,7
	MOVE 2,0
	SPRITE r06f06,7
;	MOVE -4,-1
	LOADABS	BaseCount
	JUMPCMP	2,SecondControl2
	JUMP	LastLoop
SecondControl2:		
	SYSTEM	GiveControlsToBatter	;Give controls to batter
	JUMP	LastLoop	;Loop on last frame

	.align	2
	.import	ThirdRunner,BATTER_CONTROLS,CONTROLS_COUNT
	.import	SecondRunner,FTriggerLead_1,FTriggerBack_1
	.import	FirstButton,GiveCounterToBatter
	.import	GiveControlsToBatter,BaseCount
	.export	STriggerLead_1,STriggerBack_1

STriggerLead_1:	               	;Check's runners and does anim
	cmp.b	#1,FirstButton	;Is he stealing?
	ble.s	LeadOff	;no, then leadoff
	clr.b	B_ONBASE
	move.l	#ThirdRunner,a0	;Move Runner on second to a0
	move.b	#-4,B_ONBASE(a0)
	move.l	Batter+CONTROLBLOCK,a1
;	tst.b	POWERUP(a1)	; Check If Powered Up
;	bne.s	Steal_3rd
	
	tst.b	Steal3rd
	bne	Stealing
	move.l	#ThirdRunner,a0	;Move Runner on second to a0
;	sub.l	#3*12*256,WORLDX(a0)
;	sub.l	#3*12*256,WORLDY(a0)

	cmp.b	#1,FirstButton	;Is he stealing?
	ble.s	LeadOff	;no, then leadoff

Steal_3rd:
	move.b	#1,Steal3rd
	move.b	#4,FirstButton

	move.l	#ThirdRunner,a0	;Move runner to a0
	jsr	GiveCounterToBatter	;Give controls to batter
	move.l	#RunToThirdBase,PARSEPOINTER(a0);Stealing! Run to third
 ;	jsr	FTriggerLead_1	;Yes, then move guy on first (fbase)
	rts

LeadOff:			;Just leading off
 ;	move.l	#LeadToThird,PARSEPOINTER(a0);Move lead to PARSE
	tst.b	SecondRunner+B_INUSE	;is there a guy on first?
	beq.s	DoneTrig	;no? then done
;	trap	#1
	jsr	FTriggerLead_1	;Yes, then move guy on first (fbase)
	
Stealing:
	rts
	
	.align	2

DoneTrig:			;Done
	addi.b	#1,FirstButton	;Add 1 to buttoncounter
	rts		;Return

STriggerBack_1:		;Going back to second
	move.l	#ThirdRunner,a0	;Move runner to a0
	tst.b	Steal3rd
	bne	CantBack
	cmp.l	#SECONDBASEX,WORLDX(a0)
	bge.s	CantBack
	add.l	#3*12*256,WORLDX(a0)
	add.l	#3*12*256,WORLDY(a0)
	move.l	#ThirdRunner,a0	;Move runner to a0
	move.l	#BackToSecond,PARSEPOINTER(a0);Jam PARSE
	
	tst.b	SecondRunner+B_INUSE	;Is there a guy on first?
	beq.s	DoneTrig2	;No? then done
	jsr	FTriggerBack_1	;Yes, move guy on first (fbase)
	rts		;done
DoneTrig2:			
	subi.b	#1,FirstButton	;Subtract one from counter
	rts		;done
CantBack:
	move.b	#1,B_ONBASE
	clr.b	FirstButton
	jsr	GiveControlsToBatter
	rts		;return

	.align	2
	
PutThirdRun:
	move.l	#ThirdRunner,a0	;Move runner to a0
	move.l	#SECONDBASEX,WORLDX(a0)	; Set Start X Position
	move.l	#SECONDBASEY,WORLDY(a0)	; Set Start Y Position
	clr.b	Steal3rd
;	clr.b	Steal2nd
	clr.b	FirstButton
	rts
	.align	2

;work from here

MoveRunToThr:
	move.l	#ThirdRunner,a0	;Move runner to a0
	sub.l	#4*12*256,WORLDX(a0)
	sub.l	#4*12*256,WORLDY(a0)
	rts
	.align	2
ShouldSlide:		;Slide 7 feet before base
	move.l	#ThirdRunner,a0	;Move runner to a0
	cmp.l	#THIRDBASEX+6*12*256,WORLDX(a0)
	bge.s	doneshould
	move.l	#SlideThird2,PARSEPOINTER(a0);JAM PARSE
doneshould:
	rts


