;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1996, IT, INC.	*
;***************************************************************************
	.region.s	"RAM"
	ds	0

FIRST	equ	1
SECOND	equ	2
THIRD	equ	3
HOME	equ	4
PITCH	equ	5

AIPitch	ds.w	1
BatSpeed	ds.w	1
HitTime	ds.w	1

	.export	HitTime
	.import	Temp1,Temp2

;***************************************************************************
;  Start Of Program Code		*
;***************************************************************************
	.region	"RomCode"

	#include	"ramblock.h"
	#include	"ai.h"
	#include	"rosters.h"
	#include	"graphlib.mac"

	.export	AI	; Artificial Intelligence
	.export	InitAI	; Initialize AI

	.export	AIBias	; Bias Speed For AI Level
	.export	AIHomeRun	; Flag Home Run To AI
	.import.s	AILevel	; AI Level
	.export	AILevels	; AI Skill Levels
	.import.s	AtBatPlayer	; Address Of Batting Player
	.import.s	AtPitPlayer	; Address Of Pitching Player
	.import.s	BallActive	; Set If Ball Not Touched Yet
	.import.s	BallInFlight	; Ball Not Picked Up Yet
	.import	Baseball	; Baseball Object
	.import	CalcDistance	; Calculate Distance
	.import.s	CardPtr	; Baseball Card Displayed Flag
	.import.s	ControlPtr
	.import.s	Destination	; Destination Of Ball
	.import	EndRun
	.import.s	FirstRunner	; Runner To First
	.import.s	Flyball	; Set If High Fly Ball
	.import.s	FrameRate
	.import.s	Help1Ptr	; Help Screen Up Flag
	.import.s	HomeRunner	; Runner To Home
	.export	InitSkillLevel	; Init Skill Level
;	.import.s	Inning	; Inning Number
	.import.s	Outfielder	; Outfielder Active Flag
	.import.s	outs	; Number Of Outs
	.import.s	Pitcher	; Pitcher
	.import.s	PitchHeight	; 0 - fastball, 1 - sinker
	.import.s	PitchTime	; Time From Pitcher To Batter
	.import.s	PlayerL	; Left Player Controls
	.import.s	PlayerR	; Right Player Controls
	.import.s	RightField	; Right Fielder
	.import	RunToXY
	.export	SetSkillLevel	; Set Skill Level
	.import	skill_level	; Oper Adj Skill Level
	.import	Steal2nd	; Set If Stealing Second
	.import	Steal3rd	; Set If Stealing Third
	.import.s	SwitchReason	; Switch To Field View Reason
	.import	Random	; Generate Random Number
	.import	TrackPlayer

;***************************************************************************
;   InitAI - Initialize Artificial Intelligence		*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     ALL		*
;***************************************************************************
InitAI:
	move.l	#PlayerL,a0	; Load Address Of Left Player
	move.b	START(a0),d0	; Load Player Started Flag
	eor.b	#1,d0	; Invert The Flag

;	move.b	#1,d0	; FORCE COMPUTER

	move.b	d0,COMPUTER(a0)	; Store Computer Player Status
	clr.w	AIPAUSE(a0)	; Clear Pause Time

	clr.w	TRACKXVEL(a0)	; Clear Track Ball Counts
	clr.w	TRACKX(a0)
	clr.w	TRACKYVEL(a0)	; Clear Track Ball Counts
	clr.w	TRACKY(a0)

	move.l	#PlayerR,a0	; Load Address Of Right Player
	move.b	START(a0),d0	; Load Player Started Flag
	eor.b	#1,d0	; Invert The Flag

;	move.b	#1,d0	; FORCE COMPUTER

	move.b	d0,COMPUTER(a0)	; Store Computer Player Status
	clr.w	AIPAUSE(a0)	; Clear Pause Time

	clr.w	TRACKXVEL(a0)	; Clear Track Ball Counts
	clr.w	TRACKX(a0)
	clr.w	TRACKYVEL(a0)	; Clear Track Ball Counts
	clr.w	TRACKY(a0)

	move.l	AtBatPlayer,a1	; Load Address Of Batter
	move.w	#AI_BATTING,AISTATUS(a1)	; Set AI Status
	move.l	AtPitPlayer,a1	; Load Address Of Pitcher
	move.w	#AI_PITCHING,AISTATUS(a1)	; Set AI Status

	move.w	#-1,PitchTime	; Ball Not Pitched Yet

	move.l	Pitcher+CONTROLBLOCK,a0	; Load Control Block
	move.w	#0*8,d0	; Load Slow Fastball Index
	tst.b	START(a0)	; Check If Human
	bne.s	InitAI_1	; Branch If It Is
	jsr	Random	; Get A Random Number
	and.w	#0x3F,d0	; Extract 0-63
	asl.w	#3,d0	; Multiply By Eight
InitAI_1:
	move.w	d0,AIPitch	; Save Pitch Index

	rts

InitSkillLevel:
	move.w	skill_level,d0	; Load Operation Adj Skill Level
	move.l	#AILevels,a0	; Load Address Of AI Levels
	move.w	(a0,d0.w*2),AILevel	; Store AI Skill Level

	rts

AIHomeRun:
	tst.b	([AtBatPlayer],COMPUTER)	; Check If Computer Player
	beq.s	AIHome_9	; Branch If Not
	sub.w	#0x200,AILevel	; Drop Computer Level Fast
AIHome_9:
	rts

SetSkillLevel:
	move.l	#PlayerR,a0	; Load Address Of Right Player
	move.l	#PlayerL,a1	; Load Address Of Left Player
	tst.b	COMPUTER(a0)	; Check If A0 Is A Computer
	bne.s	SetSkill_1	; Branch If It Is
	exg	a0,a1	; Exhange Register
SetSkill_1:
	move.b	RUNS(a0),d0	; Load Runs Computer Has
	sub.b	RUNS(a1),d0	; Compare With Human
	beq.s	SetSkill_4	; Branch If Equal
	ext.w	d0	; Extend To A Word
	bpl.s	SetSkill_3	; Branch If Computer Winning
	neg.w	d0	; Make It Positive
	cmp.w	#1,d0	; Check If Only One Run
	beq.s	SetSkill_5	; Branch If Only One
	asl.w	#5,d0	; Multiply By 32
	add.w	d0,AILevel	; Increment Computer Level
	cmp.w	#0xB00,AILevel	; Check If In Range
	ble.s	SetSkill_5	; Exit If Fine
	move.w	#0xB00,AILevel	; Use Maximum Value
	bra.s	SetSkill_5
SetSkill_3:
	sub.w	#0x100,AILevel	; Decrement Computer Level
	bpl.s	SetSkill_5	; Branch If Positive
	clr.w	AILevel	; Set Level To Zero
;	bra.s	SetSkill_5
SetSkill_4:
;	add.w	#0x18,AILevel	; Increment Level A Little
SetSkill_5:
	move.w	skill_level,d0	; Load Operator Adj Skill Level
	move.l	#AILevels,a0	; Load Address Of AI Levels
	move.w	(a0,d0.w*2),d1	; Load AI Skill Level
	cmp.w	AILevel,d1	; Compare Level With Adjust
	ble.s	SetSkill_9	; Branch If Fine
	move.w	d1,AILevel	; Force To Minimum Value
SetSkill_9:
	rts




;***************************************************************************
;   AI - Execute Artificial Intelligence		*
;				*
;   Parameters :  A5 - Player Control Block		*
;   Returns:      NONE		*
;   Modifies:     ALL		*
;***************************************************************************
AI:
	move.l	CardPtr,d0	; Load Baseball Card Pointer
	or.l	Help1Ptr,d0	; Or With Help Pointer
	bne.s	AI_9	; Exit If Either Up

	tst.w	AIPAUSE(a5)	; Check If Pausing AI
	beq.s	AI_1	; Branch If Not
     	subq.w	#1,AIPAUSE(a5)	; Decrement Pause Time
AI_1:	
	move.w	AISTATUS(a5),d0	; Load Current AI Status
	cmp.w	#AI_RUNNING,d0	; Check If In Range
	ble.s	AI_4	; Branch If Fine
	trap	#1
AI_4:
	lea.l	AIJump,a1	; Load Address Of Jump Table
	jmp	([a1,d0.w*4])	; Jump To Routine

AI_9:
	rts

AIJump:
	dc.l	AI_Idle	; 0 - AI_IDLE
	dc.l	AI_Pitching	; 1 - AI_PITCHING
	dc.l	AI_Pitched	; 2 - AI_PITCHED
	dc.l	AI_Fielding	; 3 - AI_FIELDING
	dc.l	AI_Batting	; 4 - AI_BATTING
	dc.l	AI_Batted	; 5 - AI_BATTED
	dc.l	AI_Running	; 6 - AI_RUNNING
	dc.l	AI_PreThrow	; 6 - AI_PRETHROW

AI_Pitching:
	clr.b	POWERUP(a5)	; Clear Powerup
	tst.b	Steal2nd	; Check If Stealing Second
	beq.s	AIPitch_1	; Branch If Not
	move.b	#6,SECONDBUTTON(a5)	; Throw To Second
	bra.s	AIPitch_9
AIPitch_1:
	tst.b	Steal3rd	; Check If Stealing Second
	beq.s	AIPitch_2	; Branch If Not
	move.b	#6,THIRDBUTTON(a5)	; Throw To Third
	bra.s	AIPitch_9
AIPitch_2:
	clr.w	d0	; Load Slow Fastball Index
	tst.b	START(a5)	; Check If Human
	bne.s	AIPitch_3	; Branch If It Is
	jsr	Random	; Get A Random Number
	and.w	#0x3F,d0	; Extract 0-63
	asl.w	#3,d0	; Multiply By Eight
AIPitch_3:
	move.w	d0,AIPitch	; Save Pitch Index
	move.w	#AI_PITCHED,AISTATUS(a5)	; Set New Status
AIPitch_9:
	rts

AI_Pitched:
	tst.w	SwitchReason	; Check If Switched To Field
	bne.s	AI_Pitched1	; Branch If Fielding View
	move.w	AILevel,d2	; Load AI Level
	lsr.w	#4,d2	; Divide By Sixteen
	add.w	#0x80,d2	; Add In Minimum Value
	cmp.w	#0x100,d2	; Check For Minimum
	bge.s	AI_Pitched0	; Branch If Fine
	move.w	#0x100,d2	; Use Minimum
AI_Pitched0:
	move.w	AIPitch,d0	; Load Pitching Index
	move.l	#Pitches,a0	; Load Address Of Pitches

	move.w	0(a0,d0.w),d1	; Load X Velocity
	muls	d2,d1	; Multiply By AI Level
	asr.l	#8,d1	; Divide By 256
	move.w	d1,MAXTRACKXVEL(a5)	; Store Maximum X Velocity

	move.w	2(a0,d0.w),d1
	muls	d2,d1	; Multiply By AI Level
	asr.l	#8,d1	; Divide By 256
	move.w	d1,MAXTRACKYVEL(a5)	; Store Maximum Y Velocity

	move.w	4(a0,d0.w),d1	; Load Last X Velocity
	muls	d2,d1	; Multiply By AI Level
	asr.l	#8,d1	; Divide By 256
	move.w	d1,LASTTRACKXVEL(a5)	; Store Last X Velocity
	move.w	d1,TRACKXVEL(a5)	; Store X Velocity

	move.w	6(a0,d0.w),d1	; Load Last Y Velocity
	muls	d2,d1	; Multiply By AI Level
	asr.l	#8,d1	; Divide By 256
	move.w	d1,LASTTRACKYVEL(a5)	; Store Last Y Velocity
	move.w	d1,TRACKYVEL(a5)	; Store Y Velocity

	rts

AI_Pitched1:
	clr.b	POWERUP(a5)
	move.w	#AI_FIELDING,AISTATUS(a5)	; Set For Fielding
	rts

AI_Fielding:
	move.l	CONTROLOBJECT(a5),a1	; Load Address Of Controlled Player
	tst.b	B_HASBALL(a1)	; Check If Fielder Has The Ball
	beq.s	AI_Field9	; Branch If Not
;	move.w	#AI_PRETHROW,AISTATUS(a1)	; Set AI Status
;	move.w	#2,AIPAUSE(a1)	; Set Short Pause Time
	jsr	ThrowBall	; Set Buttons To Throw Ball
AI_Field9:
	rts

AI_PreThrow:
	move.l	CONTROLOBJECT(a5),a1	; Load Address Of Controlled Player
	jsr	ThrowBall	; Set Buttons To Throw Ball
	move.w	#AI_FIELDING,AISTATUS(a1)	; Set AI Status
	rts

AI_Batting:
	jsr	Random	; Get A Random Number
	and.w	#0x7,d0	; Extract 0-31
	neg.w	d0	; Negate Value
	add.w	#38,d0	; Add In 38
	move.w	d0,HitTime	; Store Batting Value

	jsr	Random	; Get Random Number
	and.w	#0x0F,d0	; Extract Number 0-15

	move.w	AILevel,d1	; Load AI Level
	lsr.w	#7,d1	; Divide By 128
	add.w	#0x12,d1	; Add In Minimum Value
	add.w	d0,d1	; Add In Random Value

	move.w	d1,BatSpeed	; Store Bat Speed

	move.w	#AI_BATTED,AISTATUS(a5)	; Set For Fielding

	jsr	Random	; Get A Random Number
	and.w	#15,d0	; Extract 0-15
	move.l	#PitchTable,a0	; Load Address Of Table
	move.b	(a0,d0.w),PitchHeight	; Set For Pitch Height

	rts

PitchTable:
	dc.b	0x00,0x02,0x10
	dc.b	0x00,0x02,0x10
	dc.b	0x00,0x02,0x10
	dc.b	0x00,0x02,0x10
	dc.b	0x00,0x02,0x10
	dc.b	0x00,0x02,0x10
	dc.b	0x00

	.align	2
	
AI_Batted:
	move.w	PitchTime,d0	; Check If Pitched Yet
	bmi.s	AI_Bat9	; Exit If Not

	subq.w	#1,PitchTime	; Decrement Pitch Time
	cmp.w	HitTime,d0	; Check If Close To Plate
	bgt.s	AI_Bat9	; Exit If Not

	move.b	PitchHeight,RAWBUTTONS(a5)	; Set Bat Height
	move.w	BatSpeed,MAXTRACKYVEL(a5)	; Set Track Ball Y Velocity
	move.w	BatSpeed,TRACKYVEL(a5)	; Set Track Ball Y Delta
	move.w	BatSpeed,TRACKY(a5)	; Set Track Ball Y Delta
AI_Bat9:
	rts

AI_Running:
	clr.b	RAWBUTTONS(a5)	; Stop At Any Base
	clr.w	TRACKYVEL(a5)	; Clear Trackball Velocity
	tst.b	Flyball	; Check If Fly Ball
	bne.s	AI_Run9	; Don't Run Faster If Fly Ball
	move.l	CONTROLOBJECT(a5),a0	; Load Address Of Controlled Object
	move.b	B_ONBASE(a0),d0	; Load On Base Flags
	ext.w	d0	; Extend To A Word
	move.l	#AI_RunTab,a0	; Load Address Of Running Table
	move.w	(a0,d0.w*2),TRACKYVEL(a5)	; Force Running Faster
	tst.w	d0	; Check If On Base
	bmi.s	AI_Run1	; Branch If Off Base
	tst.b	BallActive	; Check If Ball Picked Up
	beq.s	AI_Run1	; Branch If Not
	move.l	ControlPtr,a0	; Load Address Of Controlled Player
	move.l	WORLDX(a0),d6	; Load World X Of Player
	sub.l	Baseball+WORLDX,d6	; Subtract Baseball Position
	move.l	WORLDY(a0),d7	; Load World Y Of Player
	sub.l	Baseball+WORLDY,d7	; Subtract Baseball Position
	jsr	CalcDistance	; Calculate Distance
	cmp.l	#15*12*256,d1	; Check If Within Fifteen Feet
	ble.s	AI_Run1	; Don't Run If Close
	move.b	#0xFF,RAWBUTTONS(a5)	; Let Him Run
	move.w	#24,TRACKYVEL(a5)	; Move Runners Forward
AI_Run1:
	move.l	#AI_BaseTab,a0	; Load Address Of Bases
	move.b	(a0,d0.w),d0	; Load Base Running Toward
	beq.s	AI_Run9	; Branch If None
	cmp.b	Destination,d0	; Check If Ball Heading There
	bne.s	AI_Run9	; Branch If Not
	neg.w	TRACKYVEL(a5)	; Reverse Direction
AI_Run9:
	rts
	
	dc.w	-24	; -7 - From Home To Third
	dc.w	36	; -6 - From Third To Home
	dc.w	-24	; -5 - From Third To Second
	dc.w	36	; -4 - From Second To Third
	dc.w	-24	; -3 - From Second To First
	dc.w	36	; -2 - From First To Second
	dc.w	0	; -1 - From Home To First
AI_RunTab:
	dc.w	0	;  0 - Inactive
	dc.w	0	;  1 - On First Base
	dc.w	0	;  2 - On Second Base
	dc.w	0	;  3 - On Third Base
	dc.w	0	;  4 - On Home Plate
	dc.w	0	;  5 - In Dug Out

	dc.b	THIRD	; -7 - From Home To Third
	dc.b	HOME	; -6 - From Third To Home
	dc.b	SECOND	; -5 - From Third To Second
	dc.b	THIRD	; -4 - From Second To Third
	dc.b	FIRST	; -3 - From Second To First
	dc.b	SECOND	; -2 - From First To Second
	dc.b	0	; -1 - From Home To First
AI_BaseTab:
	dc.b	0	;  0 - Inactive
	dc.b	0	;  1 - On First Base
	dc.b	0	;  2 - On Second Base
	dc.b	0	;  3 - On Third Base
	dc.b	0	;  4 - On Home Plate
	dc.b	0	;  5 - In Dug Out

	.align	2
AI_Idle:
	rts

;***************************************************************************
;   AIBias - Modify Speed Based On AILevel		*
;				*
;   Parameters :  d3 - Speed		*
;   Returns:      d3 - Biased Speed		*
;   Modifies:     ALL		*
;***************************************************************************
AIBias:
	PUSHL	d0
	move.w	AILevel,d0	; Load AI Level
	add.w	#0x700,d0	; Add In $800
	mulu	d0,d3	; Multiply By Speed
	asr.l	#8,d3	; Divide By 256
	asr.l	#4,d3	; Divide By 16 More
	POPL	d0
	rts

;***************************************************************************
;   ThrowBall - Throw Ball To A Base		*
;				*
;   Parameters :  a5 - Player Control Block		*
;	       a1 - Controlled Player		*
;   Returns:      NONE		*
;   Modifies:     ALL		*
;***************************************************************************
ThrowBall:
;     	0 1 2 3 0/1 0/2 0/3 1/2 1/3 2/3 0/1/2 0/1/3 1/2/3 0/1/2/3/4

	clr.w	d4	; Clear D4
	move.l	#ThrowFlags,a2	; Load Address Of Flags
	move.l	#HomeRunner,a0	; Load Address Of Home Runner
Throw_1:
	tst.b	B_INUSE(a0)	; Check If In Use
	beq.s	Throw_2	; Branch If Not
	tst.b	B_OUT(a0)	; Check If Out
	bne.s	Throw_2	; Branch If He Is
	move.b	B_ONBASE(a0),d0	; Load On Base Flag
	ext.w	d0	; Extend To A Word
	bpl.s	Throw_2	; Branch If He Is

	cmp.l	#HomeRunner,a0	; Check If Home Runner
	beq.s	Throw_1A	; Branch If It Is

	cmp.l	#20*256,B_SEEKING(a0)	; Check If Close
	ble.s	Throw_2	; Branch If Close
Throw_1A:
	or.b	(a2,d0.w),d4	; Flag Active Runner
Throw_2:
	sub.l	#`sizeof(player_struct),a0	; Index To Next Fielder
	cmp.l	#FirstRunner,a0	; Check If Done
	bge.s	Throw_1

	move.l	#BaseRunners,a0	; Load Address Of Runner Table
	move.b	(a0,d4.w),d4	; Load Runner Offset

	clr.w	d0
	move.l	#Pitcher,a0	; Load Address Of Pitcher
	move.l	#ThrowTable,a2	; Load Address Of Throw Table
	cmp.b	#2,outs	; Check For Two Outs
	bne.s	Throw_3	; Branch If Not
	move.l	#ThrowTable2,a2	; Load Address Of 2 Out Throw Table
Throw_3:
	cmp.l	a0,a1	; Check If This Object
	beq.s	Throw_4	; Branch If Found
	addq.w	#1,d0	; Increment Counter
	add.l	#`sizeof(player_struct),a0	; Index To Next Fielder
	cmp.l	#RightField,a0	; Check If Done
	blt.s	Throw_3
Throw_4:
	lea.l	ThrowJump,a0	; Load Address Of Index Table
	jmp	([a0,d0.w*4])	; Jump To Routine

TPitCat:
	add.w	#6*16,d4	; Load Pitcher Offset
	bra.s	Throw_5

TFirst:
	add.w	#2*16,d4	; Load First Offset
	bra.s	Throw_5

TSecond:
	add.w	#3*16,d4	; Load Second Offset
	bra.s	Throw_5

TShort:
	add.w	#5*16,d4	; Load Short Stop Offset
	bra.s	Throw_5

TThird:
	add.w	#4*16,d4	; Load Third Offset
	bra.s	Throw_5

TOutfield:
	cmp.l	#170*12*256,Baseball+WORLDY ; Check If Deep Outfield
	bge.s	Throw_5	; Branch If Long
	add.w	#16,d4	; Index To Short Outfield
Throw_5:
	clr.w	d1	; Clear D1
	move.b	(a2,d4),d1	; Load Button To Press
	bmi.s	Throw_6	; Branch If No Button
	move.l	#ButtonTable,a0	; Load Address Of Button Table
	move.w	(a0,d1.w*2),d0	; Load Button Address
	move.b	#6,(a5,d0.w)	; Press Button
	clr.b	POWERUP(a5)	; Set For No Power Throw
;	cmp.w	#FIRSTBUTTON,d0	; Check If First Base
;	bne.s	Throw_9	; Branch If Not
;	move.b	#1,POWERUP(a5)	; Set For Power Throw
	bra.s	Throw_9

Throw_6:
	move.l	#HomeRunner,a0	; Load Address Of Home Runner
	move.l	#PickOffFlags,a1	; Load Address Of PickOff Flags
Throw_7:
	tst.b	B_INUSE(a0)	; Check If In Use
	beq.s	Throw_8	; Branch If Not
	tst.b	B_OUT(a0)	; Check If Out
	bne.s	Throw_8	; Branch If He Is
	move.b	B_ONBASE(a0),d0	; Load On Base Flag
	ext.w	d0	; Extend To A Word
	move.b	(a1,d0.w),d1	; Load Button To Press
	ext.w	d1	; Extend To A Word
	bmi.s	Throw_8	; Branch If Nothing To Do
	move.l	WORLDY(a0),d0	; Load Runner's Y Position
	sub.l	B_GOALY(a0),d0	; Subtract Goal
	bpl.s	Throw_7A	; Branch If Positive
	neg.l	d0	; Make It Positive
Throw_7A:
	cmp.l	#25*12*156,d0	; Check For 25 Feet
	bge.s	Throw_8	; Branch If More

	move.l	#ButtonTable,a0	; Load Address Of Button Table
	move.w	(a0,d1.w*2),d0	; Load Button Address
	move.b	#6,(a5,d0.w)	; Press Button
	move.b	#1,POWERUP(a5)	; Set For Power Throw
	bra.s	Throw_9
Throw_8:
	move.l	CHILD(a0),a0	; Index To Next Fielder
	tst.l	a0	; Check If Done
	bne.s	Throw_7	; Branch If Not
Throw_9:
	rts

ThrowJump:
	dc.l	TPitCat	; 0 - Pitcher
	dc.l	TFirst	; 1 - FirstBase
	dc.l	TSecond	; 2 - SecondBase
	dc.l	TShort	; 3 - ShortStop
	dc.l	TThird	; 4 - ThirdBase
	dc.l	TPitCat	; 5 - Catcher
	dc.l	TOutfield	; 6 - LeftField
	dc.l	TOutfield	; 7 - CenterField
	dc.l	TOutfield	; 8 - RightField

	
	dc.b	0x00	; -7 - From Home To Third
	dc.b	0x08	; -6 - From Third To Home
	dc.b	0x00	; -5 - From Third To Second
	dc.b	0x04	; -4 - From Second To Third
	dc.b	0x00	; -3 - From Second To First
	dc.b	0x02	; -2 - From First To Second
	dc.b	0x01	; -1 - From Home To First
ThrowFlags:
	dc.b	0	;  0 - Inactive
	dc.b	0	;  1 - On First Base
	dc.b	0	;  2 - On Second Base
	dc.b	0	;  3 - On Third Base
	dc.b	0	;  4 - On Home Plate
	dc.b	0	;  5 - In Dug Out

	dc.b	2	; -7 - From Home To Third
	dc.b	-1	; -6 - From Third To Home
	dc.b	1	; -5 - From Third To Second
	dc.b	-1	; -4 - From Second To Third
	dc.b	0	; -3 - From Second To First
	dc.b	-1	; -2 - From First To Second
	dc.b	-1	; -1 - From Home To First
PickOffFlags:
	dc.b	-1	;  0 - Inactive
	dc.b	-1	;  1 - On First Base
	dc.b	-1	;  2 - On Second Base
	dc.b	-1	;  3 - On Third Base
	dc.b	-1	;  4 - On Home Plate
	dc.b	-1	;  5 - In Dug Out


	.align	2

;		MAXXVEL,MAXYVEL,LASTXVEL,LASTYVEL
Pitches:
	dc.w	0x0000,0x0014,0x0000,0x0014	; Fastball 1
	dc.w	0x0000,0x0018,0x0000,0x0018	; Fastball 2
	dc.w	0x0000,0x001C,0x0000,0x001C	; Fastball 3
	dc.w	0x0000,0x0020,0x0000,0x0020	; Fastball 4

	dc.w	0x0000,0x0024,0x0000,0x0024	; Fastball 5
	dc.w	0x0000,0x0028,0x0000,0x0028	; Fastball 6
	dc.w	0x0000,0x002C,0x0000,0x002C	; Fastball 7
	dc.w	0x0000,0x0030,0x0000,0x0030	; Fastball 8

	dc.w	0x0014,0x0018,0x0014,0x0018	; Fastball 9
	dc.w	0x0014,0x001C,0x0014,0x001C	; Fastball 10
	dc.w	0x0014,0x0020,0x0014,0x0018	; Fastball 11
	dc.w	0x0014,0x0024,0x0014,0x001C	; Fastball 12

	dc.w	0x0014,0x0020,0xFFEC,0x0020	; Fastball 13
	dc.w	0x0014,0x0028,0xFFEC,0x0028	; Fastball 14
	dc.w	0x0014,0x0020,0xFFEC,0x0020	; Fastball 15
	dc.w	0x0014,0x0028,0xFFEC,0x0028	; Fastball 16

	dc.w	0x0012,0x0000,0xFFEE,0x0000	; Right Curve 1
	dc.w	0x0018,0x0000,0xFFE8,0x0000	; Right Curve 2
	dc.w	0x0022,0x0000,0xFFDE,0x0000	; Right Curve 3
	dc.w	0x002C,0x0000,0xFFD4,0x0000	; Right Curve 4

	dc.w	0x0012,0x0010,0xFFEE,0x0010	; Right Curve 5
	dc.w	0x0018,0x0010,0xFFE8,0x0010	; Right Curve 6
	dc.w	0x0022,0x0010,0xFFDE,0x0010	; Right Curve 7
	dc.w	0x002C,0x0010,0xFFD4,0x0010	; Right Curve 8

	dc.w	0x0012,0x0018,0xFFEE,0x0018	; Right Curve 9
	dc.w	0x0018,0x0018,0xFFE8,0x0018	; Right Curve 10
	dc.w	0x0022,0x0018,0xFFDE,0x0018	; Right Curve 11
	dc.w	0x002C,0x0018,0xFFD4,0x0018	; Right Curve 12

	dc.w	0x0012,0x0020,0xFFEE,0x0020	; Right Curve 13
	dc.w	0x0018,0x0020,0xFFE8,0x0020	; Right Curve 14
	dc.w	0x0022,0x0020,0xFFDE,0x0020	; Right Curve 15
	dc.w	0x002C,0x0020,0xFFD4,0x0020	; Right Curve 16

	dc.w	0x0012,0x0000,0x0012,0x0000	; Left Curve 1
	dc.w	0x0018,0x0000,0x0018,0x0000	; Left Curve 2
	dc.w	0x0022,0x0000,0x0022,0x0000	; Left Curve 3
	dc.w	0x002C,0x0000,0x002C,0x0000	; Left Curve 4

	dc.w	0x0012,0x0010,0x0012,0x0010	; Left Curve 5
	dc.w	0x0018,0x0010,0x0018,0x0010	; Left Curve 6
	dc.w	0x0022,0x0010,0x0022,0x0010	; Left Curve 7
	dc.w	0x002C,0x0010,0x002C,0x0010	; Left Curve 8

	dc.w	0x0012,0x0018,0x0012,0x0018	; Left Curve 9
	dc.w	0x0018,0x0018,0x0018,0x0018	; Left Curve 10
	dc.w	0x0022,0x0018,0x0022,0x0018	; Left Curve 11
	dc.w	0x002C,0x0018,0x002C,0x0018	; Left Curve 12

	dc.w	0x0012,0x0020,0x0012,0x0020	; Left Curve 13
	dc.w	0x0018,0x0020,0x0018,0x0020	; Left Curve 14
	dc.w	0x0022,0x0020,0x0022,0x0020	; Left Curve 15
	dc.w	0x002C,0x0020,0x002C,0x0020	; Left Curve 16

	dc.w	0x0000,0x0014,0x0000,0xFFEC	; Sinker 1
	dc.w	0x0000,0x0018,0x0000,0xFFE8	; Sinker 2
	dc.w	0x0000,0x001C,0x0000,0xFFE4	; Sinker 3
	dc.w	0x0000,0x0020,0x0000,0xFFE0	; Sinker 4

	dc.w	0x0000,0x0022,0x0000,0xFFDE	; Sinker 5
	dc.w	0x0000,0x0024,0x0000,0xFFDC	; Sinker 6
	dc.w	0x0000,0x0026,0x0000,0xFFDA	; Sinker 7
	dc.w	0x0000,0x0028,0x0000,0xFFD8	; Sinker 8

	dc.w	0x0010,0x0014,0x0010,0xFFEC	; Sinker 9
	dc.w	0x0010,0x0014,0xFFF0,0xFFEC	; Sinker 10
	dc.w	0x0014,0x0018,0x0014,0xFFE8	; Sinker 11
	dc.w	0x0014,0x0018,0xFFEC,0xFFE8	; Sinker 12
	dc.w	0x0010,0x001C,0x0010,0xFFE4	; Sinker 13
	dc.w	0x0010,0x001C,0xFFF0,0xFFE4	; Sinker 14
	dc.w	0x0014,0x0024,0x0014,0xFFDC	; Sinker 15
	dc.w	0x0014,0x0024,0xFFEC,0xFFDC	; Sinker 16


F	equ	0	; First
C	equ	1	; Second
T	equ	2	; Third
H	equ	3	; Home

ButtonTable:
	dc.w	FIRSTBUTTON	; First Base
	dc.w	SECONDBUTTON	; Second Base
	dc.w	THIRDBUTTON	; Third Base
	dc.w	HOMEBUTTON	; Home Plate

BaseRunners:
	dc.b	15	; 0 - None
	dc.b	0	; 1 - First
	dc.b	1	; 2 - Second
	dc.b	4	; 3 - First/Second
	dc.b	2	; 4 - Third
	dc.b	5	; 5 - First/Third
	dc.b	7	; 6 - Second/Third
	dc.b	10	; 7 - First/Second/Third
	dc.b	3	; 8 - Home
	dc.b	6	; 9 - First/Home
	dc.b	8	; A - Second/Home
	dc.b	11	; B - First/Second/Home
	dc.b	9	; C - Third/Home
	dc.b	12	; D - First/Third/Home
	dc.b	12	; E - Second/Third/Home
	dc.b	13	; F - All
			  
; 0-1 OUTS          	F S T H F F F S S T F F S A
;	                  S T H T H H S S T L
;		                    T H H L
ThrowTable:
	dc.b	C,C,T,H,T,C,C,T,C,T,T,T,C,C,0,-1 ; 0 - deep outfielder
	dc.b	C,C,T,H,C,T,H,C,C,H,T,C,H,C,0,-1 ; 1 - short outfielder
	dc.b	F,C,T,H,F,F,F,C,H,H,F,F,H,F,0,-1 ; 2 - first
	dc.b	F,C,T,H,C,F,F,C,H,H,C,C,C,C,0,-1 ; 3 - second
	dc.b	F,C,T,H,C,F,F,C,H,H,T,H,T,T,0,-1 ; 4 - third
	dc.b	F,C,T,H,C,F,F,C,H,H,C,C,C,C,0,-1 ; 5 - shortstop
	dc.b	F,C,T,H,F,F,F,C,H,H,T,H,H,H,0,-1 ; 6 - pitcher/catcher

; 2 OUTS          	F S T H F F F S S T F F S A
;	                  S T H T H H S S T L
;		                    T H H L
ThrowTable2:
	dc.b	C,C,T,H,T,T,H,T,C,T,C,C,C,C,0,-1 ; 0 - deep outfielder
	dc.b	C,C,T,H,C,T,H,T,H,T,C,C,C,C,0,-1 ; 1 - short outfielder
	dc.b	F,C,T,H,F,F,F,C,H,H,F,F,H,F,0,-1 ; 2 - first
	dc.b	F,C,T,H,F,F,F,C,C,T,C,C,C,C,0,-1 ; 3 - second
	dc.b	F,C,T,H,F,F,F,C,H,T,T,T,T,T,0,-1 ; 4 - third
	dc.b	F,C,T,H,F,F,F,C,C,T,C,C,C,C,0,-1 ; 5 - shortstop
	dc.b	F,C,T,H,F,F,F,C,H,H,F,H,H,H,0,-1 ; 6 - pitcher/catcher
	
AILevels:	dc.w	0x000	; Skill Level 0
	dc.w	0x200	; Skill Level 1
	dc.w	0x400	; Skill Level 2
	dc.w	0x600	; Skill Level 3
	dc.w	0x800	; Skill Level 5

	end


