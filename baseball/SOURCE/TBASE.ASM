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


	.region	"RomCode"
	ds	0

;	#include	"itvideo2.h"
;	#include	"anim.mac"
;	#include	"controls.h"
;	#include	"ramblock.h"
;;	#include	"c:\bb\player.h"
;;	#include	"r:\baseball\art\tables\player.h"
;	#include	"bsblsnds.equ"
;	#include	"player.h"
;	#include	"groms.h"
;
;	#include	"joydefs.h"
;	#include	"pals.h"

	#include	"itvideo2.h"
	#include	"sys.h"
	#include	"sys.mac"
	#include	"graphlib.mac"
	#include	"graphlib.h"
	#include	"graphglb.h"
	#include	"macros.h"
	#include	"bsblsnds.equ"
	#include	"player.h"
	#include	"ramblock.h"
	#include	"anim.mac"
	#include	"groms.h"
	#include	"stats.h"
	#include	"audits.h"
	#include	"pals.h"
	#include	"controls.h"


	.global	Random
	.global	BlitObject,BlitAObject,TextObject
;	.export	ThirdWinxObj
	.export	RunnerIntroT
	.import	Third1ObjPtr,DeallocObject,Third2ObjPtr
	.import	BlitClipObj,ThirdView1Obj
	.import	AllocObject
	.import	Anim
	.import	CheckBases
	.export	HomeRunX,HomeRunY
	.import	SetFont2
	.import	SetSysFont
	.import	SetWinFont
	.import	SetFontm
	.import	ProcessTime
	.import	GameTime
	.import	TogglePage
	.import	CreditsMsg
	.import.s	GroundY2,GroundY
	.export	InAttract


	.export	DCardNum
	.region.s	"RAM"

ThirdWin1ptr	ds.l	1
HomeRunX ds.l	1
HomeRunY ds.l	1
StealHome	ds.b	1

ypos	ds.w	1
TempY	ds.w	1
ScreenCount ds.w	1
BallCounter ds.w	1
DCardNum ds.w	1
LoopCount ds.w	1
InAttract	ds.b	1
CardNameNum	ds.b 1


	.region	"RomCode"


;First Base Runners Sprite Animations
RunnerIntroT:
	SETRAM	COUNTER,STOP
	SYSTEM	ClearHomeStuff
	SYSTEM	PutHomeRun
QED	
	
;	SYSTEM	ThirdView1Obj ;third base window
;	SYSTEM	ThirdWinxObj       ;window dirt
	SYSTEM	PutHomeRun
	SYSTEM	CheckBases
	SYSTEM	GiveControlsToBatter
	SETRAM	FirstButton,0

RunnerIntro_0:
	SPRITE1 r06b04,7
	SPRITE1 r06b05,7
	SPRITE1 r06b06,7
	JUMP	LastLoop

		         


;RunToThird:
;	MOVE	-3,0
;	SETRAM	COUNTER,SPRINT
;	SPRITE1 r03b01,4
;	SPRITE1 r03b02,4
;	SPRITE1 r03b03,4
;	SPRITE1 r03b04,4
;	SPRITE1 r03b05,4
;	SPRITE1 r03b06,4
;	SPRITE1 r03b07,4
;	SPRITE1 r03b01,4
;	SPRITE1 r03b02,4
;	SPRITE1 r03b03,4
;	SPRITE1 r03b04,4
;	SPRITE1 r03b05,4
;	SPRITE1 r03b06,4
;	SPRITE1 r03b07,4
;	SETRAM	COUNTER,STOP
;	MOVE	3,0
;
;	SYSTEM	ClearRun ;runner comes on screen, so remove window
;
;	DEALLOC

	.export	LeadTrigger_Home,BackTrigger_3rd

LeadTrigger_Home:		;Do Lead towards home
;	SYSTEM	GiveCounterToBatter	;Set buttons to counter
;	SYSTEM	TTriggerLead_1	;Call Parse Routine
	SYSTEM	GiveControlsToBatter
	QED

BackTrigger_3rd:		;Do return to third
	SYSTEM	GiveCounterToBatter	;Set buttons to counter
	SYSTEM	TTriggerBack_1	;Call Parse Routine
	QED

LastLoop:			;This is called when we
	LASTFRAME	5	;need to loop on last frames
	JUMP	LastLoop
	
LeadToHome:	             	;Lead towards home once anim
	SETRAM  COUNTER,LEADOFF	;Start Background
	SPRITE1 r06b01,8
	SPRITE1 r06b02,8
	SPRITE1 r06b03,8
	SPRITE1 r06b04,7
	SETRAM  COUNTER,STOP	;Stop Backgound
	SPRITE1 r06b05,7
	SPRITE1 r06b06,7
	LOADABS	BaseCount
	JUMPCMP	4,ThirdControl
	LOADABS	BaseCount
	JUMPCMP	3,ThirdControl
	JUMP	LastLoop
ThirdControl:		
	SYSTEM	GiveControlsToBatter	;Give controls to batter
	JUMP	LastLoop	;Loop on last frame

	.align	2

BackToThird:		;Lead back to third
	SPRITE1 r06b05,8
	SETRAM  COUNTER,BACKOFF	;Start backgound
	SPRITE1 r06b04,8
	SPRITE1 r06b03,8
	SPRITE1 r06b02,7
	SPRITE1 r06b01,7
	SETRAM  COUNTER,STOP	;Stop Background
	SPRITE1 r06b06,7
	LOADABS	BaseCount
	JUMPCMP	4,ThirdControl2
	LOADABS	BaseCount
	JUMPCMP	3,ThirdControl2
	JUMP	LastLoop
ThirdControl2:		
	SYSTEM	GiveControlsToBatter	;Give controls to batter
	JUMP	LastLoop	;Loop on last frame

	.align	2
	.import	HomeRunner,BATTER_CONTROLS,CONTROLS_COUNT
	.import	ThirdRunner,STriggerLead_1,STriggerBack_1
	.import	GiveControlsToBatter
	.import	FirstButton,GiveCounterToBatter,BaseCount

TTriggerLead_1:		;Move anim to Parsepointer
;	clr.b	B_ONBASE
;	move.l	#HomeRunner,a0	;Move Object to a0
;	move.b	#-6,B_ONBASE(a0)
;	move.l	Batter+CONTROLBLOCK,a1

;	move.l	#HomeRunner,a0	;Move Object to a0
;	add.l	#3*12*256,WORLDX(a0)
;	sub.l	#3*12*256,WORLDY(a0)
;	bra	LeadOff	;This was added for demo

;	cmp.b	#3,FirstButton	;is he stealing?(press more then 3 times)
;	ble.s	LeadOff	;no, just leading off
	
; 	clr.b	FirstButton	;0 Button count
;	move.l	#RunToHome,PARSEPOINTER(a0)	;He is stealing!
	rts

LeadOff:			;Leading off		
	move.l	#LeadToHome,PARSEPOINTER(a0);move leadoff to PARSE
	tst.b	ThirdRunner+B_INUSE	;is there a guy on second?
	beq.s	DoneTrig	;no? then done
	jsr	STriggerLead_1	;yes then lead guy on second (sbase)
         	rts		;done
DoneTrig:
	addi.b	#1,FirstButton	;Add one to counter
	rts		;done,return


TTriggerBack_1:		;Go back
  	move.l	#HomeRunner,a0	;move Runner to a0
	cmp.l	#THIRDBASEX,WORLDX(a0)
	ble.s	CantBack
	sub.l	#3*12*256,WORLDX(a0)
	add.l	#3*12*256,WORLDY(a0)
  	move.l	#HomeRunner,a0	;move Runner to a0
	move.l	#BackToThird,PARSEPOINTER(a0);put anim in PARSE

	tst.b	ThirdRunner+B_INUSE	;Is there a guy on second?
	beq.s     DoneTrig2	;no, then branch to done
	jsr	STriggerBack_1	;yes, move guy on second back(sbase)
	rts		;done,return
DoneTrig2:
	subi.b	#1,FirstButton	;subtract one from counter (moving back)
	rts

CantBack:
	move.b	#3,B_ONBASE
	clr.b	FirstButton
	jsr	GiveControlsToBatter
	rts		;return

	.align	2
	

ClearHomeStuff
	clr.b	StealHome
	clr.b	d1

PutHomeRun:
  	move.l	#HomeRunner,a0	;move Runner to a0
	move.l	#THIRDBASEX,WORLDX(a0)	; Set Start X Position
	move.l	#THIRDBASEY,WORLDY(a0)	; Set Start Y Position
	rts
	.align	2
;************************************************************************
;* Attract Credits!
;*
;*
;*
;************************************************************************
	.export	AttractLogoTest
AttractLogoTest:
	move.w	#192,ypos
	move.w	#440,ScreenCount
AttractLogo:
;	IMAGES	#BANK_MISC
	cmp.w	#80,ScreenCount
	bcc	AttractLogo_0
;	APALETTE	#P_IT1	; Palette Number
;	BLIT	#72,#62,#22	; Title Screen
;	APALETTE	#P_IT2	; Palette Number
;	BLIT	#73,#73,#33	; Title Screen
	bra	AttractLogo_1

AttractLogo_0:
;	APALETTE	#P_IT1D	; Palette Number
;	BLIT	#72,#62,#22	; Title Screen
;	APALETTE	#P_IT2D	; Palette Number
;	BLIT	#73,#73,#33	; Title Screen

AttractLogo_1:
;	IMAGES	#BANK_MISC1
;	BLIT	#6,#35,#235	; Copyright
	FRAMERT	#0	;/60 Hz quicker rtn
	jsr	SetSysFont
;	move.w	ProcessTime,GameTime
	jsr	Credits
	sub.w	#0x1,ypos
	jsr	CreditsMsg	; Put Out Coin Message
AttractLogo_2:
	jsr	TogglePage	; Swap Pages
	DELAY	#1
	subq.w	#1,ScreenCount
	bne	AttractLogo

	
Credits:
	SETCLIP	#0,#22,#384,#220
	move.w	ypos,TempY
	APALETTE	#P_BALL
	move.l	#CreditTable,a1
Credits_0:
	move.l	(a1),a2
	cmp.w	#6,TempY
	bcs	Credits_2
	PUSHL	a1
	PLOT	#63,TempY
	PRINTS	a2
Credits_1:
	POPL	a1
Credits_2:
	add.l	#4,a1
	cmp.l	#CreditTable+132,a1
	bcc	Credits_9
;bri	add.w	#16,TempY
	add.w	#9,TempY
	cmp.w	#6,TempY
	bmi	Credits_2
	cmp.w	#220,TempY
	bcs	Credits_0
Credits_9:
	SETCLIP	#0,#0,#384,#256
	rts

; Characters are 16 high
;                                |
CreditString_0:
	dc.b	"            GAME DESIGN:",13,0
CreditString_1:
	dc.b	"               JOHN",13,0
CreditString_2:
	dc.b	"              RICHARD ",13,0
CreditString_3:
	dc.b	"               BRIAN ",13,0
CreditString_4:
	dc.b	13,0
CreditString_5:
	dc.b	"              GAME ART:",13,0
CreditString_6:	       
	dc.b	"                ALAN",13,0
CreditString_7:
	dc.b	"                DONNA",13,0
CreditString_8:
	dc.b	"                ELLEN",13,0
CreditString_9:
	dc.b	13,0
CreditString_10:
	dc.b	"            SOUND DESIGN:",13,0
CreditString_11:
	dc.b	"             KRISTI HALL",13,0
CreditString_12:
	dc.b	"            KYLE JOHNSON",13,0
CreditString_13:
	dc.b	"           HARDWARE DESIGN:",13,0
CreditString_14:
	dc.b	"               TESTING",13,0
CreditString_15:
	dc.b	"               TESTING",13,0
CreditString_16:
	dc.b	13,0
CreditString_17:
	dc.b	"          TECHNICAL SUPPORT:",13,0
CreditString_18:
	dc.b	"            TERRY LITTLE",13,0
CreditString_19:
	dc.b	"               SCOTT ALLIE",13,0
CreditString_20:
	dc.b	"                 ED RECK",13,0
CreditString_21:
	dc.b	13,0
CreditString_22:
	dc.b	"           CABINET GRAPHICS:",13,0
CreditString_23:
	dc.b	"                TESTING",13,0
CreditString_24:
	dc.b	"                TESTING",13,0
CreditString_25:
	dc.b	"                TESTING",13,0
CreditString_26:
	dc.b	13,0
CreditString_27:
	dc.b	"             SPECIAL THANKS:",13,0
CreditString_28:
	dc.b	"              ELAINE DITTON",13,0
CreditString_29:
	dc.b	"                   MLB",13,0
CreditString_30:
	dc.b	13,0
CreditString_31:
	dc.b	"         SOUND RECORDING LOCATION:",13,0
CreditString_32:
	dc.b	"                 TESTING",13,0
CreditString_33:
	dc.b	0
BlankString:
	dc.b	"                      ",0

	.align	4

CreditTable:
	dc.l	CreditString_0
	dc.l	CreditString_1
	dc.l	CreditString_2
	dc.l	CreditString_3
	dc.l	CreditString_4
	dc.l	CreditString_5
	dc.l	CreditString_6
	dc.l	CreditString_7
	dc.l	CreditString_8
	dc.l	CreditString_9
	dc.l	CreditString_10
	dc.l	CreditString_11
	dc.l	CreditString_12
	dc.l	CreditString_13
	dc.l	CreditString_14
	dc.l	CreditString_15
	dc.l	CreditString_16
	dc.l	CreditString_17
	dc.l	CreditString_18
	dc.l	CreditString_19
	dc.l	CreditString_20
	dc.l	CreditString_21
	dc.l	CreditString_22
	dc.l	CreditString_23
	dc.l	CreditString_24
	dc.l	CreditString_25
	dc.l	CreditString_26
	dc.l	CreditString_27
	dc.l	CreditString_28
	dc.l	CreditString_29
	dc.l	CreditString_30
	dc.l	CreditString_31
	dc.l	CreditString_32
	dc.l	CreditString_33

	.align	4


	.align	2
	.export	BallFountain
BallFountain:   ;These are the balls
;	jsr	ROCKVEL
;	move.w	#0,XCLIP1(a5)
;	move.w	#300,XCLIP2(a5)
;	move.w	#247,YCLIP2(a5)
;	move.w	#200,YCLIP1(a5)

	move.w	#240,GroundY2	; Set Ground Position (short)
	move.l	#240*256,GroundY	; Set Ground Position (long)

;	move.w	ProcessTime,d0	; Load Porcoess Time
;	and.w	#0x1F,d0	; Extract Lower Bits
;	bne.s	BallFount_1	; Exit If Not Time
;	jsr	DemoTextObj	; Output Another Ball
;BallFount_1:	

	move.w	ProcessTime,d0	; Load Porcoess Time
	and.w	#0x3,d0	; Extract Lower Bits
	bne.s	BallFount_9	; Exit If Not Time
	jsr	BallFountain2	; Output Another Ball
BallFount_9:	
	rts

BallFountain2:
	jsr	AllocObject	; Allocate An Object
	beq.s	NoBalls	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
           move.w	#65,ZPOSITION(a0)	; Initialize Z Position
	move.w	#ball0071,PICTURE(a0)	; Set Base-O-Meter Picture
	move.l	#BallFAnim,PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_BALL,PALETTE(a0)	; Set Palette Number
	move.w	#180,XPOSITION(a0)	; Set X Position62
	move.w	#240,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
NoBalls:
	rts

	.align	2
	.export	DemoTextObj
	.export	StartText

StartText:			;Design Team Credits w/Cards
	SOUND	#SayHomeTeam,#31
	jsr	DemoBack	;Set Background
	move.l	#TextAnim0,d2	;Set Text String to d2
	jsr	DemoTextObj	;Call Text Display
	move.l	#TextAnim,d2	;Set Text String to d2
	jsr	DemoTextObj	;Call Text Display
	move.l	#TextAnim2,d2	;Set Text String to d2
	jsr	DemoTextObj	;Call Text Display
	move.l	#TextAnim3,d2	;Set Text String to d2
	jsr	DemoTextObj	;Call Text Display
	move.l	#TextAnim4,d2	;Set Text String to d2
	jsr	DemoTextObj	;Call Text Display
	move.l	#TextAnim5,d2	;Set Text String to d2
	jsr	DemoTextObj	;Call Text Display
	move.l	#TextAnim6,d2	;Set Text String to d2
	jsr	DemoTextObj	;Call Text Display
	move.l	#TextAnim7,d2	;Set Text String to d2
	jsr	DemoTextObj	;Call Text Display
	move.l	#TextAnim8,d2	;Set Text String to d2
	jsr	DemoTextObj	;Call Text Display
	move.l	#TextAnim9,d2	;Set Text String to d2
	jsr	DemoTextObj	;Call Text Display
	move.l	#TextAnim10,d2	;Set Text String to d2
	jsr	DemoTextObj	;Call Text Display
	rts


DemoTextObj:		;Display Text Objects
	jsr	AllocObject	; Allocate An Object
	beq.s	DemoText_9	; Branch If None
	move.l	#TextObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
           move.w	#66,ZPOSITION(a0)	; Initialize Z Position
	move.l	d2,PARSEPOINTER(a0)	; Set Animation String
 	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#-200,XPOSITION(a0)	; Set X Position62
	move.w	#180,YPOSITION(a0)	; Set Y Position
	move.b	#6,BANK(a0)	; Set Font Number (neo 6)
	move.w	#255,NUMBEROFCHARS(a0)	; Display All Characters
	clr.w	STARTCHARACTER(a0)	; Start With First Character
	move.l	#DemoText1,PARENT(a0)	; Store Address Of Text String
DemoText_9:
	rts

DemoText0:	dc.b	"DESIGN TEAM",0
DemoText1:	dc.b	"ELLEN ATKINS",13,"ARTIST",0
DemoText2:	dc.b	"RICHARD DITTON",13,"PROGRAMMER",0
DemoText3:	dc.b	"DONNA FOSHEE",13,"ARTIST",0
DemoText4:	dc.b	"KRISTI HALL",13,"SOUND/MUSIC",0
DemoText5:	dc.b	"JOHN NEWCOMER",13,"GAME DESIGNER",0
DemoText6:	dc.b	"ALAN NOON",13,"ARTIST",0
DemoText7:	dc.b	"CHRIS OBERTH",13,"PROGRAMMER",0
DemoText8:	dc.b	"BRIAN SMOLIK",13,"PROGRAMMER",0
DemoText9:	dc.b	"JIM ZIELINSKI",13,"GAME DESIGNER",0
DemoText10: dc.b	"ROGER SHARPE",13,"MARKETING",0

TextAnim0:
	SETRAMW	YPOSITION,170
	SETRAMW	XPOSITION,120
;	SETVEL	400,0,8	; Move Card Down Screen
TextAnim0_1:
;	TEXT	DemoText0
;	LASTFRAME	100
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	DemoText0
	LASTFRAME	100
	TEXT	DemoText0
	LASTFRAME	100
	TEXT	DemoText0
	LASTFRAME	100
	DEALLOC
	JUMP	TextAnim0_1

TextAnim:
	SETRAMW	YPOSITION,190
	SETRAMW	XPOSITION,-180
	SETVEL	500,0,8	; Move Card Down Screen
TextAnim_1:
	TEXT	DemoText1
	LASTFRAME	100
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	DemoText1
	LASTFRAME	100
	TEXT	DemoText1
	LASTFRAME	100
	TEXT	DemoText1
	LASTFRAME	100
	DEALLOC
	JUMP	TextAnim_1


TextAnim2:
	TEXT	DemoText2
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,190
	SETRAMW	XPOSITION,-180
;	LASTFRAME	40	
	SETVEL	500,0,8	; Move Card Down Screen
TextAnim2_2:
	TEXT	DemoText2
	LASTFRAME	100
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	DemoText2
	LASTFRAME	100
	TEXT	DemoText2
	LASTFRAME	100
	TEXT	DemoText2
	LASTFRAME	100
	DEALLOC
	JUMP	TextAnim2_2

TextAnim3:
	TEXT	DemoText3
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	100	
	SETRAMW	YPOSITION,190
	SETRAMW	XPOSITION,-180
	LASTFRAME	120	
	SETVEL	500,0,8	; Move Card Down Screen
TextAnim3_3:
	TEXT	DemoText3
	LASTFRAME	100
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	DemoText3
	LASTFRAME	100
	TEXT	DemoText3
	LASTFRAME	100
	TEXT	DemoText3
	LASTFRAME	100
	DEALLOC
	JUMP	TextAnim3_3

TextAnim4:
	TEXT	DemoText4
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,180
	SETRAMW	XPOSITION,-180
	LASTFRAME	120	
	LASTFRAME	120	
	SETVEL	500,0,8	; Move Card Down Screen
TextAnim4_4:
	TEXT	DemoText4
	LASTFRAME	100
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	DemoText4
	LASTFRAME	100
	TEXT	DemoText4
	LASTFRAME	100
	TEXT	DemoText4
	LASTFRAME	100
	DEALLOC
	JUMP	TextAnim4_4


TextAnim5:
	TEXT	DemoText5
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,180
	SETRAMW	XPOSITION,-180
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	SETVEL	500,0,8	; Move Card Down Screen
TextAnim5_5:
	TEXT	DemoText5
	LASTFRAME	100
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	DemoText5
	LASTFRAME	100
	TEXT	DemoText5
	LASTFRAME	100
	TEXT	DemoText5
	LASTFRAME	100
	DEALLOC
	JUMP	TextAnim5_5


TextAnim6:
	TEXT	DemoText6
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120        
	SETRAMW	YPOSITION,180
	SETRAMW	XPOSITION,-180
	LASTFRAME	120          
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	SETVEL	500,0,8	; Move Card Down Screen
TextAnim6_6:
	TEXT	DemoText6
	LASTFRAME	100
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	DemoText6
	LASTFRAME	100
	TEXT	DemoText6
	LASTFRAME	100
	TEXT	DemoText6
	LASTFRAME	100
	DEALLOC
	JUMP	TextAnim6_6


TextAnim7:
	TEXT	DemoText7
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,180
	SETRAMW	XPOSITION,-180
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	SETVEL	500,0,8	; Move Card Down Screen
TextAnim7_7:
	TEXT	DemoText7
	LASTFRAME	100
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	DemoText7
	LASTFRAME	100
	TEXT	DemoText7
	LASTFRAME	100
	TEXT	DemoText7
	LASTFRAME	100
	DEALLOC
	JUMP	TextAnim7_7


TextAnim8:
	TEXT	DemoText8
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,180
	SETRAMW	XPOSITION,-180
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	SETVEL	500,0,8	; Move Card Down Screen
TextAnim8_8:
	TEXT	DemoText8
	LASTFRAME	100
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	DemoText8
	LASTFRAME	100
	TEXT	DemoText8
	LASTFRAME	100
	TEXT	DemoText8
	LASTFRAME	100
	DEALLOC
	JUMP	TextAnim8_8


TextAnim9:
	TEXT	DemoText9
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,180
	SETRAMW	XPOSITION,-180
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	SETVEL	500,0,8	; Move Card Down Screen
TextAnim9_9:
	TEXT	DemoText9
	LASTFRAME	100
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	DemoText9
	LASTFRAME	100
	TEXT	DemoText9
	LASTFRAME	100
	TEXT	DemoText9
	LASTFRAME	100
	DEALLOC
	JUMP	TextAnim9_9


TextAnim10:
	TEXT	DemoText10
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,180
	SETRAMW	XPOSITION,-180
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	SETVEL	500,0,8	; Move Card Down Screen

TextAnim10_1:
	TEXT	DemoText10
	LASTFRAME	100
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	DemoText10
	LASTFRAME	100
	TEXT	DemoText10
	LASTFRAME	100
	TEXT	DemoText10
	LASTFRAME	100
	DEALLOC
	JUMP	TextAnim10_1

	
BallFAnim:		

    	SETRANVEL    0x0,0x990,1
	SPRITE	ball0005,10
	SPRITE	ball0010,10
	SPRITE	ball0015,10
	SPRITE	ball0020,10
	SPRITE	ball0025,10
	SPRITE	ball0030,10
	SPRITE	ball0035,10
	SPRITE	ball0040,10
	SPRITE	ball0045,10
	SPRITE	ball0050,10
	SPRITE	ball0055,10
	SPRITE	ball0060,10
	SPRITE	ball0065,10
     	DEALLOC

	.align	2




	.export	StartCards

StartCards:
	move.b	#140,CardNameNum
	move.l	#DCardAnim,d2
	jsr	DemoCardObj
	move.l	#DCardAnim2,d2
	jsr	DemoCardObj
	move.l	#DCardAnim3,d2
	jsr	DemoCardObj
	move.l	#DCardAnim4,d2
	jsr	DemoCardObj
	move.l	#DCardAnim5,d2
	jsr	DemoCardObj
	move.l	#DCardAnim6,d2
	jsr	DemoCardObj
	move.l	#DCardAnim7,d2
	jsr	DemoCardObj
	move.l	#DCardAnim8,d2
	jsr	DemoCardObj
	move.l	#DCardAnim9,d2
	jsr	DemoCardObj
	move.l	#DCardAnim10,d2
	jsr	DemoCardObj
	rts


DemoCardObj:
	jsr	AllocObject	; Allocate An Object
	beq.s	DemoCard_9	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
           move.w	#66,ZPOSITION(a0)	; Initialize Z Position
	move.l	d2,PARSEPOINTER(a0)	; Set Animation String
 	move.b	#P_DESI,PALETTE(a0)	; Set Palette Number
	move.w	#420,XPOSITION(a0)	; Set X Position62
	move.w	#170,YPOSITION(a0)	; Set Y Position
	move.b	#Cards,BANK(a0)	; Set Font Number (neo 6)
DemoCard_9:
	rts

DCardAnim:
	SETVEL	-400,0,8	; Move Card Down Screen
DCardAnim_1:
	SPRITE	card3308,100
	SETVEL	0,300,8	; Move Card Down Screen
	SYSTEM	DoCardName
	SPRITE	card3308,100
	SPRITE	card3308,100
	SPRITE	card3308,100
	SPRITE	card3308,100
;	SPRITE	card3308,100
	DEALLOC
	JUMP	DCardAnim_1



DCardAnim2:
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,170
	SETRAMW	XPOSITION,420
	SETVEL	-400,0,8	; Move Card Down Screen
DCardAnim2_2:
	SPRITE	card3301,100
	SYSTEM	DoCardName
	SETVEL	0,300,8	; Move Card Down Screen
	SPRITE	card3301,100
	SPRITE	card3301,100
	SPRITE	card3301,100
;	SPRITE	card3301,100
	DEALLOC
	JUMP	DCardAnim2_2


DCardAnim3:
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,170
	SETRAMW	XPOSITION,420
	LASTFRAME	110	
	SETVEL	-400,0,8	; Move Card Down Screen
DCardAnim3_3:
	SPRITE	card3310,100
	SETVEL	0,300,8	; Move Card Down Screen
	SYSTEM	DoCardName
	SPRITE	card3310,100
	SPRITE	card3310,100
	SPRITE	card3310,100
;	SPRITE	card3310,100
	DEALLOC
	JUMP	DCardAnim3_3


DCardAnim4:
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,170
	SETRAMW	XPOSITION,420
	LASTFRAME	120	
	LASTFRAME	120	
	SETVEL	-400,0,8	; Move Card Down Screen
DCardAnim4_4:
	SPRITE	card3309,100
	SETVEL	0,300,8	; Move Card Down Screen
	SYSTEM	DoCardName
	SPRITE	card3309,100
	SPRITE	card3309,100
	SPRITE	card3309,100
;	SPRITE	card3309,100
	DEALLOC
	JUMP	DCardAnim4_4

	
DCardAnim5:
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,170
	SETRAMW	XPOSITION,420
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	SETVEL	-400,0,8	; Move Card Down Screen
DCardAnim5_5:
	SPRITE	card3307,100
	SETVEL	0,300,8	; Move Card Down Screen
	SYSTEM	DoCardName
	SPRITE	card3307,100
	SPRITE	card3307,100
	SPRITE	card3307,100
;	SPRITE	card3307,100
	DEALLOC
	JUMP	DCardAnim5_5

	
DCardAnim6:
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,170
	SETRAMW	XPOSITION,420
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	SETVEL	-400,0,8	; Move Card Down Screen
DCardAnim6_6:
	SPRITE	card3304,100
	SETVEL	0,300,8	; Move Card Down Screen
	SYSTEM	DoCardName
	SPRITE	card3304,100
	SPRITE	card3304,100
	SPRITE	card3304,100
	SPRITE	card3304,100
	DEALLOC
	JUMP	DCardAnim6_6

	
DCardAnim7:
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,170
	SETRAMW	XPOSITION,420
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	SETVEL	-400,0,8	; Move Card Down Screen
DCardAnim7_7:
	SPRITE	card3302,100
	SETVEL	0,300,8	; Move Card Down Screen
	SYSTEM	DoCardName
	SPRITE	card3302,100
	SPRITE	card3302,100
	SPRITE	card3302,100
	SPRITE	card3302,100
	DEALLOC
	JUMP	DCardAnim7_7


	
DCardAnim8:
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,170
	SETRAMW	XPOSITION,420
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	SETVEL	-400,0,8	; Move Card Down Screen
DCardAnim8_8:
	SPRITE	card3306,100
	SETVEL	0,300,8	; Move Card Down Screen
	SYSTEM	DoCardName
	SPRITE	card3306,100
	SPRITE	card3306,100
	SPRITE	card3306,100
	SPRITE	card3306,100
	DEALLOC
	JUMP	DCardAnim8_8


DCardAnim9:
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,170
	SETRAMW	XPOSITION,420
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	SETVEL	-400,0,8	; Move Card Down Screen
DCardAnim9_9:
	SPRITE	card3305,100
	SETVEL	0,300,8	; Move Card Down Screen
	SYSTEM	DoCardName
	SPRITE	card3305,100
	SPRITE	card3305,100
	SPRITE	card3305,100
	SPRITE	card3305,100
	DEALLOC
	JUMP	DCardAnim9_9

DCardAnim10:
	SETVEL	0,0,8	; Stationary Card
	LASTFRAME	120	
	SETRAMW	YPOSITION,170
	SETRAMW	XPOSITION,420
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	LASTFRAME	120	
	SETVEL	-400,0,8	; Move Card Down Screen
DCardAnim10_1:
	SPRITE	card3314,100
	SETVEL	0,300,8	; Move Card Down Screen
	SYSTEM	DoCardName
	SPRITE	card3314,100
	SPRITE	card3314,100
	SPRITE	card3314,100
	SPRITE	card3314,100
	DEALLOC
	JUMP	DCardAnim10_1


	.align	2

DemoBack:   ;This is the background for the credits screen
	jsr	AllocObject	; Allocate An Object
	beq.s    	DemoB_1	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#1,ZPOSITION(a0)	; Initialize Z Position
	move.w	#titlerb,PICTURE(a0)	; Set background Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_TITLERB,PALETTE(a0)	; Set Palette Number
	move.w	#0,XPOSITION(a0)	; Set X Position
	move.w	#0,YPOSITION(a0)	; Set Y Position
	move.b	#Title,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary

DemoB_1:
	rts
	.align	2

	.export	StartThanks

StartThanks: 		;Credits w/Thanks
	jsr	DemoBack	;Set Background
	move.l	#CreditAnim0,d2	;Set Text String to d2
	jsr	CreditTextObj	;Call Text Display
	move.l	#CreditAnim1,d2	;Set Text String to d2
	jsr	CreditTextObj	;Call Text Display
	move.l	#CreditAnim2,d2	;Set Text String to d2
	jsr	CreditTextObj	;Call Text Display
	
	rts


CreditTextObj:		;Display Text Objects
	jsr	AllocObject	; Allocate An Object
	beq.s	CreditText_9	; Branch If None
	move.l	#TextObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
           move.w	#66,ZPOSITION(a0)	; Initialize Z Position
	move.l	d2,PARSEPOINTER(a0)	; Set Animation String
 	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#20,XPOSITION(a0)	; Set X Position62
	move.w	#270,YPOSITION(a0)	; Set Y Position
	move.b	#3,BANK(a0)	; Set Font Number (neo 6)
	move.w	#255,NUMBEROFCHARS(a0)	; Display All Characters
	clr.w	STARTCHARACTER(a0)	; Start With First Character
	move.l	#CText0,PARENT(a0)	; Store Address Of Text String
CreditText_9:
	rts

CText0:	dc.b	"POWER UP BASEBALL TEAM",0
CText1:	dc.b	"ELLEN ATKINS",13,"LEROY BROWN",13,"ELAINE DITTON",13,"SAL DIVITA",13
CText2:	dc.b	"DONNA FOSHEE",13,"DEBBIE FULTON",13,"JIM GREENE",13,"BRIAN JANDULA",13,"KYLE JOHNSON",13
CText3:	dc.b	"AL LASKO",13,"TERRY LITTLE",13,"CARY MEDNICK",13,"JOHN NEWCOMER",13
CText4:	dc.b	"CHRIS OBERTH",13,"BETTY PURCELL",13,"GREG RYZA",13,"TOM SEDOR",13
CText5:	dc.b	"JEFF SIEGRIST",13,"TED VALAVANIS",13,"CHRISTA WOSS",13,0

CText6:	dc.b	"MATT BEATTIE",13,"PAT COX",13,"RICHARD DITTON",13,"NIK EHRLICH",13
CText7:	dc.b	"PAT FITZGERALD",13,"DAWN GRAHAM",13,"KRISTI HALL",13,"STEVE JASKOWIAK",13,"MATT KERN",13
CText8:	dc.b	"DAVE LEVY",13,"ANDY LYCKE",13,"RALPH MELGOSA",13,"ALAN NOON",13
CText9:	dc.b	"JEFF PETERS",13,"MARYANN ROHN",13,"HERMAN SANCHEZ JR",13,"ROGER SHARPE",13
CText10:	dc.b	"BRIAN SMOLIK",13,"DARREN WALKER",13,"JIM ZIELINSKI",13,0


CreditAnim0:
	SETVEL	0,0,8	; Stationary Card
;	LASTFRAME	100
	SETRAMW	YPOSITION,270
	SETRAMW	XPOSITION,80
CreditAnim0_1:
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	CText0
	LASTFRAME	100
	TEXT	CText0
	LASTFRAME	100
	TEXT	CText0
	LASTFRAME	100
	DEALLOC
	JUMP	CreditAnim0_1


CreditAnim1:
	SETVEL	0,0,8	; Stationary Card
;	LASTFRAME	50
	SETRAMW	YPOSITION,270
	SETRAMW	XPOSITION,20
	LASTFRAME	50
CreditAnim1_1:
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	CText1
	LASTFRAME	200
	TEXT	CText1
	LASTFRAME	200
	TEXT	CText1
	LASTFRAME	200
	DEALLOC
	JUMP	CreditAnim1_1

CreditAnim2:
	SETVEL	0,0,8	; Stationary Card
;	LASTFRAME	50
	SETRAMW	YPOSITION,270
	SETRAMW	XPOSITION,200
	LASTFRAME	50
CreditAnim2_2:
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	CText6
	LASTFRAME	200
	TEXT	CText6
	LASTFRAME	200
	TEXT	CText6
	LASTFRAME	200
	DEALLOC
	JUMP	CreditAnim2_2

	.align	2





;***********************************************************************8
	.export	WeWishThanks
WeWishThanks: 		;Credits w/Thanks
	jsr	DemoBack	;Set Background
	move.l	#WishAnim0,d2	;Set Text String to d2
	jsr	WishText3Obj	;Call Text Display
	move.l	#WishAnim1,d2	;Set Text String to d2
	jsr	WishTextYObj	;Call Text Display
	move.l	#WishAnim2,d2	;Set Text String to d2
	jsr	WishTextObj	;Call Text Display
	move.l	#WishAnim3,d2	;Set Text String to d2
	jsr	WishTextObj	;Call Text Display
	move.l	#WishAnim4,d2	;Set Text String to d2
	jsr	WishTextObj	;Call Text Display
	move.l	#WishAnim5,d2	;Set Text String to d2
	jsr	WishTextObj	;Call Text Display
;	move.l	#WishAnim6,d2	;Set Text String to d2
;	jsr	WishTextObj	;Call Text Display
;	move.l	#WishAnim7,d2	;Set Text String to d2
;	jsr	WishTextObj	;Call Text Display
	
	rts

	.align	2

WishTextObj:		;Display Wish Text Objects
	jsr	AllocObject	; Allocate An Object
	beq.s	WishText_9	; Branch If None
	move.l	#TextObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
           move.w	#66,ZPOSITION(a0)	; Initialize Z Position
	move.l	d2,PARSEPOINTER(a0)	; Set Animation String
 	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#20,XPOSITION(a0)	; Set X Position62
	move.w	#270,YPOSITION(a0)	; Set Y Position
	move.b	#3,BANK(a0)	; Set Font Number (neo 6)
	move.w	#255,NUMBEROFCHARS(a0)	; Display All Characters
	clr.w	STARTCHARACTER(a0)	; Start With First Character
	move.l	#WText1,PARENT(a0)	; Store Address Of Text String
WishText_9:
	rts


WishTextYObj:		;Display Wish Text Objects
	jsr	AllocObject	; Allocate An Object
	beq.s	WishTextY_9	; Branch If None
	move.l	#TextObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
           move.w	#66,ZPOSITION(a0)	; Initialize Z Position
	move.l	d2,PARSEPOINTER(a0)	; Set Animation String
; 	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
 	move.b	#P_NEOYEL,PALETTE(a0)	; Set Palette Number
	move.w	#20,XPOSITION(a0)	; Set X Position62
	move.w	#270,YPOSITION(a0)	; Set Y Position
	move.b	#3,BANK(a0)	; Set Font Number (neo 6)
	move.w	#255,NUMBEROFCHARS(a0)	; Display All Characters
	clr.w	STARTCHARACTER(a0)	; Start With First Character
	move.l	#WText1,PARENT(a0)	; Store Address Of Text String
WishTextY_9:
	rts


WishText3Obj:		;Display Wish Text Objects
	jsr	AllocObject	; Allocate An Object
	beq.s	WishText3_9	; Branch If None
	move.l	#TextObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
           move.w	#66,ZPOSITION(a0)	; Initialize Z Position
	move.l	d2,PARSEPOINTER(a0)	; Set Animation String
 	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#20,XPOSITION(a0)	; Set X Position62
	move.w	#270,YPOSITION(a0)	; Set Y Position
	move.b	#6,BANK(a0)	; Set Font Number (neo 6)
	move.w	#255,NUMBEROFCHARS(a0)	; Display All Characters
	clr.w	STARTCHARACTER(a0)	; Start With First Character
	move.l	#WText0,PARENT(a0)	; Store Address Of Text String
WishText3_9:
	rts

	.align	2


WText0:	dc.b	"WE WISH TO THANK",0

WText1:	dc.b	"MAJOR LEAGUE BASEBALL",13,13,13,13,13,"MAJOR LEAGUE BASEBALL",13,"PLAYER'S ASSOCIATION",13
WText1_1:	dc.b	13,13,13,13,13,"MLB PHOTOS",13,13,13,13,"ELIAS SPORTS BUREAU INC",13,13,13,13,"ANNOUNCER",13
WText1_2:	dc.b	13,13,13,"SOUTH BEND SILVER HAWKS",13,13,13,13,13,13,"SPECIAL THANKS",13,0
WText2:	dc.b	"CAROLANN DUNN",13,"BRAD SCHLACHTER",13,"PEGGY O'NEILL",13,0
WText3:	dc.b	"SHARON DENNIS",13,"DAVE PATERSON",13,"SANDY YOUNG",13,0

WText4:	dc.b	13,13,"MIKE SCHECHTER",13,"ROY COOLER",13,"ALL THE MAJOR LEAGUE PLAYERS",13,0
WText6:	dc.b	"RICH PILLING",13,"PAUL CUNNINGHAM",13,13
WText7:	dc.b	13,"SEYMOUR SIWOFF",13,"ANTHONY ABILO",13,13
WText8:	dc.b	13,"KEN 'HAWK' HARRELSON",13,"CENTURY LLL STUDIOS",13,13
WText9:	dc.b	13,"JULIE MAGRANE",13,"CURTIS BROOME JR",13,"RICK CARONE",13
WText10:	dc.b	"JASON EVANS",13,13,13
WText11:	dc.b	"NEIL NICASTRO",13,"KEN FEDESNA",13,"ELAINE DITTON",13,"PAUL DUSSAULT",13
WText12:	dc.b	"JOE DILLON",13,"RACHEL DAVIES",13,"LENORE SAYERS",13,"MARK CHAN",13
WText13:	dc.b	"THE CHICAGO CUBS",13,"THE CHICAGO WHITE SOX",13,0





	.align	2


WishAnim0:
	SETVEL	0,0,8	; Stationary Card
;	LASTFRAME	100
	SETRAMW	YPOSITION,270
	SETRAMW	XPOSITION,20
WishAnim0_1:
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	WText0
	LASTFRAME	100
	TEXT	WText0
	LASTFRAME	100
	TEXT	WText0
	LASTFRAME	50
	DEALLOC
	JUMP	WishAnim0_1
	.align	2


WishAnim1:
	SETVEL	0,0,8	; Stationary Card
;	LASTFRAME	50
	SETRAMW	YPOSITION,270
	SETRAMW	XPOSITION,20
	LASTFRAME	60
WishAnim1_1:
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	WText1
	LASTFRAME	200
	TEXT	WText1
	LASTFRAME	200
	TEXT	WText1
	LASTFRAME	200
	TEXT	WText1
	LASTFRAME	200
	TEXT	WText1
	LASTFRAME	100
	DEALLOC
	JUMP	WishAnim1_1

	.align	2
WishAnim2:
	SETVEL	0,0,8	; Stationary Card
;	LASTFRAME	50
	SETRAMW	YPOSITION,270
	SETRAMW	XPOSITION,20
	LASTFRAME	80
WishAnim2_2:
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	WText2
	LASTFRAME	200
	TEXT	WText2
	LASTFRAME	200
;	TEXT	WText2
;	LASTFRAME	200
	DEALLOC
	JUMP	WishAnim2_2

	.align	2

WishAnim3:
	SETVEL	0,0,8	; Stationary Card
;	LASTFRAME	50
	SETRAMW	YPOSITION,270
	SETRAMW	XPOSITION,200
	LASTFRAME	80
WishAnim3_1:
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	WText3
	LASTFRAME	200
	TEXT	WText3
	LASTFRAME	200
	TEXT	WText3
	LASTFRAME	200
	DEALLOC
	JUMP	WishAnim3_1



WishAnim4:
	SETVEL	0,0,8	; Stationary Card
;	LASTFRAME	50
	SETRAMW	YPOSITION,270
	SETRAMW	XPOSITION,20
	LASTFRAME	160
WishAnim4_1:
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	WText4
	LASTFRAME	200
	TEXT	WText4
	LASTFRAME	200
	TEXT	WText4
	LASTFRAME	200
	DEALLOC
	JUMP	WishAnim4_1


WishAnim5:
	SETVEL	0,0,8	; Stationary Card
;	LASTFRAME	50
	SETRAMW	YPOSITION,270
	SETRAMW	XPOSITION,20
	LASTFRAME	100
	LASTFRAME	100
	LASTFRAME	110
WishAnim5_1:
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	WText6
	LASTFRAME	200
	TEXT	WText6
	LASTFRAME	200
	TEXT	WText6
	LASTFRAME	200
	TEXT	WText6
	LASTFRAME	200
	TEXT	WText6
	LASTFRAME	200
	DEALLOC
	JUMP	WishAnim5_1

WishAnim6:
	SETVEL	0,0,8	; Stationary Card
;	LASTFRAME	50
	SETRAMW	YPOSITION,270
	SETRAMW	XPOSITION,20
	LASTFRAME	100
	LASTFRAME	100
	LASTFRAME	100
	LASTFRAME	100
	LASTFRAME	100
	LASTFRAME	100
	LASTFRAME	50
WishAnim6_1:
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	WText11
	LASTFRAME	200
	TEXT	WText11
	LASTFRAME	200
	TEXT	WText11
	LASTFRAME	200
	DEALLOC
	JUMP	WishAnim6_1

WishAnim7:
	SETVEL	0,0,8	; Stationary Card
;	LASTFRAME	50
	SETRAMW	YPOSITION,270
	SETRAMW	XPOSITION,200
	LASTFRAME	100
	LASTFRAME	100
	LASTFRAME	100
	LASTFRAME	100
	LASTFRAME	100
	LASTFRAME	100
	LASTFRAME	50
WishAnim7_1:
	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	WText13
	LASTFRAME	200
	TEXT	WText13
	LASTFRAME	200
	TEXT	WText13
	LASTFRAME	60
	DEALLOC
	JUMP	WishAnim7_1



	.align	2


	.import	blit_draft
	.export	AttractDraft
	.import	PlayerR,PlayerL

	.import Batter
	.import Player
	.import AwayPlayer
	.import HomePlayer
	.import DrDspBody
	.import SetHomePal
	.import AnimDraft
	.import spinner
	.import DoHeadPalette

	.import	LoadCardPals
	.import	DoHeadPal,DoSkinPalette
	.import	SetHomePal
	.import	HomePlayer
	.import	AwayPlayer
	.align	2

AttractDraft: 	;Display Wish Text Objects

	jsr	DoDraftText
	move.b	#1,InAttract
	move.w	#0,([HomePlayer],TEAMNUMBER) ;draft team (save first?)
	move.w	#0,([AwayPlayer],TEAMNUMBER) ;draft team (save first?)
	jsr	SetHomePal

	move.l	#Batter,a5	; Batter
	jsr	DoHeadPalette
 	jsr	DoSkinPalette

       	jsr	DemoBack	;Set Background



	jsr	LoadCardPals
	jsr	AllocObject	; Allocate An Object
	beq	Draft_9	; Branch If None
	move.l	#DraftCall,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	clr.l	PARSEPOINTER(a0)	; Set Animation String

	move.w	#0,PlayerL+TEAMNUMBER ;draft team (save first?)
	move.w	#0,PlayerR+TEAMNUMBER ;draft team (save first?)
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


	move.w	#0,PlayerL+cardX

	move.b	#players+2,PlayerL+Lcursor

	move.l	#PlayerL,a5
	move.b	#1,present(a5)

	move.b	#0,PlayerL+players+2

	jsr	SetHomePal

Draft_9:
	rts

	.align	2




DraftCall:
	move.w	ProcessTime,d0	; Load Porcoess Time
	and.w	#63,d0	; Extract Lower Bits
	cmp.w	#63,d0
	bne.s	DontChange	; Exit If Not Time
	add.b	#1,PlayerL+players+2
DontChange:

	move.l	#PlayerL,a5
	jsr	blit_draft
;	trap	#1
	rts
	.align	2


DoDraftText

	move.l	#DraftAnim0,d2	;Set Text String to d2
	jsr	DraftTextObj	;Call Text Display
	
	rts

	.align	2

DraftTextObj:		;Display Text Objects
	jsr	AllocObject	; Allocate An Object
	beq.s	DraftText_9	; Branch If None
	move.l	#TextObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
           move.w	#66,ZPOSITION(a0)	; Initialize Z Position
	move.l	d2,PARSEPOINTER(a0)	; Set Animation String
 	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#20,XPOSITION(a0)	; Set X Position62
	move.w	#270,YPOSITION(a0)	; Set Y Position
	move.b	#3,BANK(a0)	; Set Font Number (neo 6)
	move.w	#255,NUMBEROFCHARS(a0)	; Display All Characters
	clr.w	STARTCHARACTER(a0)	; Start With First Character
	move.l	#DText0,PARENT(a0)	; Store Address Of Text String
DraftText_9:
	rts
	.align	2

DText0:	dc.b	"DRAFT A TEAM!",13,13
DText1:	dc.b	"CHOOSE FROM OVER",13
DText2:	dc.b	"400 PLAYERS!",13,13
DText3:	dc.b	"CREATE YOUR OWN",13
DText4:	dc.b	"ALL-STAR TEAM!!!!",13,13
DText5:	dc.b	"FIND SPECIAL",13
DText6:	dc.b	"HIDDEN TEAMS!",13,0

	.align	2

DraftAnim0:
	SETVEL	0,0,8	; Stationary Card
;	LASTFRAME	100
	SETRAMW	YPOSITION,20
	SETRAMW	XPOSITION,195
DraftAnim0_1:
;	SETVEL	0,300,8	; Move Card Down Screen
	TEXT	DText0
	LASTFRAME	100
	TEXT	DText0
	LASTFRAME	100
	TEXT	DText0
	LASTFRAME	100
	TEXT	DText0
	LASTFRAME	100
	TEXT	DText0
	LASTFRAME	100
	TEXT	DText0
	LASTFRAME	100
	TEXT	DText0
	LASTFRAME	100
	TEXT	DText0
	LASTFRAME	100
	DEALLOC
	JUMP	DraftAnim0_1

	.align	2

	.export	DoITStuff
DoITStuff:
	jsr	ITLogo
	jsr	ITTextObj	;Call Text Display
	SOUND	#Crowd3,#Crowd3

	rts

	.align	2

ITTextObj:		;Display Text Objects
	jsr	AllocObject	; Allocate An Object
	beq.s	ITText_9	; Branch If None
	move.l	#TextObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
           move.w	#66,ZPOSITION(a0)	; Initialize Z Position
	move.l	#ITAnim0,PARSEPOINTER(a0)	; Set Animation String
 	move.b	#P_NEWSCORE,PALETTE(a0)	; Set Palette Number
	move.w	#70,XPOSITION(a0)	; Set X Position62
	move.w	#70,YPOSITION(a0)	; Set Y Position
	move.b	#3,BANK(a0)	; Set Font Number (neo 6)
	move.w	#255,NUMBEROFCHARS(a0)	; Display All Characters
	clr.w	STARTCHARACTER(a0)	; Start With First Character
	move.l	#ITText0,PARENT(a0)	; Store Address Of Text String
ITText_9:
	rts
	.align	2
		   
ITText0:	dc.b	"      DEVELOPED FOR ",13,13
ITText1:	dc.b	" WILLIAMS/BALLY/MIDWAY",13
ITText3:	dc.b	"          BY",13
ITText4:	dc.b	"INCREDIBLE TECHNOLOGIES",13,0

	.align	2

ITAnim0:
	SETVEL	0,0,8	; Stationary Card
	SETRAMW	YPOSITION,300
	SETRAMW	XPOSITION,80
ITAnim0_1:
	SETVEL	0,200,8	; Move Card Down Screen
	TEXT	ITText0
	LASTFRAME	100
	TEXT	ITText0
	LASTFRAME	100
	TEXT	ITText0
	LASTFRAME	100
	TEXT	ITText0
	LASTFRAME	100
	JUMP	ITAnim0_1
	.align	2


ITLogo:   ;This is the logo box
	jsr	AllocObject	; Allocate An Object
	beq.s    	NoLogo	; Branch If None
	move.l	#BlitObject,DISPLAYPROC(a0)	; Store Address Of Display Procedure
	move.l	#Anim,UPDATEPROC(a0)	; Set Animation Routine
	move.w	#30,ZPOSITION(a0)	; Initialize Z Position
	move.w	#it0001,PICTURE(a0)	; Set Base-O-Meter Picture
	clr.l	PARSEPOINTER(a0)	; Set Animation String
;	move.l	#LogoAnim,PARSEPOINTER(a0)	; Set Animation String
	move.b	#P_ITLOGO,PALETTE(a0)	; Set Palette Number
	move.w	#120,XPOSITION(a0)	; Set X Position
	move.w	#70,YPOSITION(a0)	; Set Y Position
	move.b	#Misc,BANK(a0)	; Set Bank Number
	move.b	#1,STATIONARY(a0)	; Set As Stationary
NoLogo:

	rts
	.align	2

DoCardName:
	SOUND3	#SetCurrentPlayer,#0,CardNameNum
;	SOUND3	#SetCurrentPlayer,#0,#146
	SOUND	#SayPlayerName,#0
	add.b	#1,CardNameNum
	rts
	.align	2






