;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************
	.region.s	"RAM"
	ds	0
;***************************************************************************
;   Routines Exported From ANIM.ASM		*
;***************************************************************************

	.export	InitJoyWatch,JoyWatch
	.export	InputControl,Anim,InitJoys,Move
	.export	ClearJoySeq,ClearButtons,CalcBallPos

;***************************************************************************
;  Variable Imports			*
;***************************************************************************
	.import.s	Baseball	; Baseball Object
	.import.s	BackArt,FrameRate
	.import.s	TimerStatus
	.import.s	GroundY2,GroundY
	.import.s	GameActive,TimerTick2

	.import	aicrouchflag
	.import	PlayerR,PlayerL
	.import.s	FirstCover
	.import.s	CatchYVel	; Ball Y Velocity At Catch
	.import.s	ThrowTime
	.import.s	HomeRun
	.import	Catcher

;***************************************************************************
;  Subroutine Imports		*
;***************************************************************************
	.import	AddCycle
	.import	AI
	.import	BaseTable
	.import	CalcDirection
	.import	CalcDistance
	.import	DeallocObject
	.import	IncAudit
	.import	Objects
	.import	Random
	.import	rnd1
	.import	SendSound

	.import	Switches
	.import	SwitchState
	.import	StadiumY	; Stadium Y Position

;***************************************************************************
;  RAM Variables Defined In This Section		*
;***************************************************************************
	.export	ShakeYPeriod,ShakeYCnt,ShakeYDist
	.export	Flags

PGRAVITY	equ	0x330	; Gravity Effect

	ds	0
passcount	ds.b	1
ShakeYPeriod ds.b	1
ShakeYCnt	ds.b	1
ShakeYDist	ds.b	1

	ds	0
temp	ds.l	1
Flags	ds.w	1
CalcTemp	ds.w	1
SaveA5	ds.l	1
ButtonLoad	ds.b	1

;***************************************************************************
;  Start Of Program Code		*
;***************************************************************************
	.region	"RomCode"

	ds	0
	#include	"sys.mac"
	#include	"itvideo2.h"
	#include	"sys.h"
	#include	"graphlib.mac"
	#include	"graphlib.h"
	#include	"graphglb.h"
	#include	"macros.h"
	#include	"ramblock.h"
	#include	"anim.mac"
	#include	"controls.h"
	#include	"pals.h"
	#include	"joyseq.h"

	.align	2
;***************************************************************************
;   InitJoys - Initailize Joystick Sequence Values	*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
InitJoys:
	move.l	#PlayerL+JOYSEQDATA,a0	; Load Address Of Left Player
	move.l	#PlayerR+JOYSEQDATA,a1	; Load Address Of Right Player
	clr.l	d0	; Clear D0
	move.w	#28-1,d1	; 96+16 Bytes To Clear
InitJoy_1:
	move.l	d0,(a0)+	; Clear Four Bytes
	move.l	d0,(a1)+	; Clear Four Bytes
	dbf	d1,InitJoy_1	; Continue Until Done
	rts

;***************************************************************************
;   Animate - Execute The Animation Tables For Each Fighter	*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
InputControl:
	move.l	CONTROLBLOCK(a5),d0	; Load Controlling Block Address
	beq	Input_Exit	; Exit If Not Controlled
	move.l	d0,a6	; Move To A6
	move.l	INPUTROUTINE(a6),d0	; Load Pointer To Input Table
	beq	Input_Exit	; Exit If No Routine Defined

	clr.b	ButtonLoad	; Not Checking Buttons
	move.l	d0,a0
Input_1:
	clr.w	d0	; Clear D0 Register
	move.b	(a0)+,d0	; Load Input Command
	lea.l	InputJumpTable,a1	; Load Address Of Jump Table
	jmp	([a1,d0.w*4])	; Jump To Routine

InputJumpTable:
	dc.l	Input_Load	  ; 0 - LOAD         Command
	dc.l	Input_Jump	  ; 1 - JUMP         Command
	dc.l	Input_All	  ; 2 - ALLBITS      Command
	dc.l	Input_Any	  ; 3 - ANYBITS      Command
	dc.l	Input_JmpAll	  ; 4 - JUMPALL      Command
	dc.l	Input_JmpAny	  ; 5 - JUMPANY      Command
	dc.l	Input_Anim	  ; 6 - ANIM         Command
	dc.l	Input_Done	  ; 7 - DONE         Command
	dc.l	Input_NotBits	  ; 8 - NOTBITS      Command
	dc.l	Input_LoadObj	  ; 9 - LOADOBJ      Command
	dc.l	Input_IfBkg	  ; A - IFBACKGRND   Command
	dc.l	Input_LoadAbs	  ; B - LOADABS      Command
	dc.l	Input_SetVel	  ; C - SETVEL       Command
	dc.l	Input_JmpCmp	  ; D - JUMPCMP      Command
	dc.l	Input_Maskme	  ; E - MASKME       Command
	dc.l	Input_NoClear	  ; F - NOCLEAR      Command
	dc.l	Input_IfPower	  ;10 - IFPOWER      Command
	dc.l	Input_StandardMove	  ;11 - STANDARDMOVE Command
	dc.l	0	  ;12 -
	dc.l	0	  ;13 -
	dc.l	0	  ;14 -
	dc.l	0	  ;15 -
	dc.l	0	  ;16 - 
	dc.l	0	  ;17 -
	dc.l	0	  ;18 -
	dc.l	0	  ;19 -
	dc.l	0	  ;1A -
	dc.l	0	  ;1B -
	dc.l	0	  ;1C -
	dc.l	0	  ;1D -
	dc.l	0	  ;1E - 
	dc.l	0	  ;1F - 
	dc.l	Input_JumpEqu	  ;20 - JUMPEQU         Command
	dc.l	0	  ;21 -
	dc.l	Input_Only	  ;22 - ONLY            Command
	dc.l	0	  ;23 -
	dc.l	0	  ;24 -
	dc.l	0	  ;25 -
	dc.l	Input_JumpNot	  ;26 - JUMPNOT        Command
	dc.l	0	  ;27 -
	dc.l	0	  ;28

Input_IfPower:
	tst.b	POWERUP(a6)	; Check If Powered Up
	bne	Input_Jump	; Branch If He Is
	addq.l	#3,a0	; Next Instruction Please
	bra	Input_1

Input_Maskme:
	move.l	#FirstCover,a1	; Load Address Of Player Covering First
	cmp.l	(a1)+,a5	; Check If Covering First
	bne.s	Input_Maskme1	; Branch If Not
	move.w	#0xDF,d0	; Load Bit Mask
	btst	#5,d2	; Check For First Base Button
	bne	Input_MaskJump	; Jump If Pressed
	bra	Input_Maskme4

Input_Maskme1:
	cmp.l	(a1)+,a5	; Check If Covering Second
	bne.s	Input_Maskme2	; Branch If Not
	move.w	#0xEF,d0	; Load Bit Mask
	btst	#4,d2	; Check For Second Base Button
	bne	Input_MaskJump	; Jump If Pressed
	bra	Input_Maskme4
Input_Maskme2:
	cmp.l	(a1)+,a5	; Check If Covering Third
	bne.s	Input_Maskme3	; Branch If Not
	move.w	#0xF7,d0	; Load Bit Mask
	btst	#3,d2	; Check For Third Base Button
	bne	Input_MaskJump	; Jump If Pressed
	bra	Input_Maskme4
Input_Maskme3:
	cmp.l	#Catcher,a5	; Check If Covering Home
	bne.s	Input_Maskme4	; Branch If Not
	move.w	#0xFB,d0	; Load Bit Mask
	btst	#2,d2	; Check For Home Plate Button
	bne	Input_MaskJump	; Jump If Pressed
Input_Maskme4:
	addq.l	#3,a0	; Next Instruction Please
	bra	Input_1

Input_MaskJump:
	and.w	d0,d2	; Extract Covered Bit
	beq	Input_MaskJump2	; Branch If Only Button Pressed
	addq.l	#3,a0	; Next Instruction Please
	bra	Input_1

Input_MaskJump2:
	eor.w	#0xFF,d0	; Invert Bit Mask
	move.w	d0,d2	; Restore Value
	bra	Input_Jump

Input_Only:
	move.b	d2,d0	; Move Loaded Value To D0
	cmp.b	(a0)+,d0	; Load Bit Desired
	beq	Input_Done1	; Branch If Comparision
	addq.l	#3,a0	; Next Instruction Please
	bra	Input_1

Input_StandardMove:
	move.l	d2,d0	; Move Loaded Value To D0
	and.b	(a0)+,d0	; Extract Interesting Bits
	bne	Input_Done1	; Branch If Comparision
	addq.l	#3,a0	; Next Instruction Please
	bra	Input_1

Input_LoadAbs:
	clr.b	ButtonLoad	; Not Checking Buttons
	jsr	GetLong	; Get Long Value
	move.l	d0,a1	; Move To Address Register
	move.b	(a1),d2	; Load Input Value Into D2
	move.b	d2,d4	; Copy To D4
	bra	Input_1

Input_Load:
	clr.b	ButtonLoad	; Not Checking Buttons
	move.w	(a0)+,d0	; Load Address Of Value
	cmp.w	#BUTTONS,d0	; Check If Clearing Buttons
	bne.s	Input_Load1	; Branch If Buttons
	move.b	#1,ButtonLoad	; Flag A Loaded Button
Input_Load1:
	move.b	(a6,d0.w),d2	; Load Input Value Into D2
	move.b	d2,d4	; Copy To D4
	bra	Input_1

Input_NoClear:
	clr.b	ButtonLoad	; Not Checking Buttons
	move.w	(a0)+,d0	; Load Address Of Value
	move.b	(a6,d0.w),d2	; Load Input Value Into D2
	move.b	d2,d4	; Copy To D4
	bra	Input_1

Input_LoadObj:
	clr.b	ButtonLoad	; Not Checking Buttons
	move.w	(a0)+,d0	; Load Address Of Value
	move.b	(a5,d0.w),d2	; Load Input Value Into D2
	move.b	d2,d4	; Copy To D4
	bra	Input_1

Input_Jump:
	bsr	GetLong	; Get A Long
	move.l	d0,a0	; Move To Animation Pointer
	bra	Input_1

Input_All:
	move.l	d2,d0	; Move Loaded Value To D0
	move.b	(a0)+,d1	; Load Value From Animation Table
	and.b	d1,d0	; Extract Interesting Bits
 	cmp.b	d0,d1	; See If It Matches
	beq	Input_Done1	; Branch If Comparision
	addq.l	#3,a0	; Next Instruction Please
	bra	Input_1

Input_NotBits:
	move.b	d2,d0	; Move Loaded Value To D0
	and.b	(a0)+,d0	; Extract Interesting Bits
	beq.s	Input_Done1	; Branch If Comparision
	addq.l	#3,a0	; Next Instruction Please
	bra	Input_1

Input_IfBkg:
	move.w	(a0)+,d0
	cmp.w	BackArt,d0	; Check If This Is The Background
	beq.s	Input_Any	; Branch If It Is
	addq.l	#4,a0	; Next Instruction Please
	bra	Input_1

Input_Any:
	move.l	d2,d0	; Move Loaded Value To D0
	and.b	(a0)+,d0	; Extract Interesting Bits
	bne.s	Input_Done1	; Branch If Comparision
	addq.l	#3,a0	; Next Instruction Please
	bra	Input_1

Input_JmpCmp:
	cmp.b	(a0)+,d2	; Compare With Value
	beq	Input_Jump	; Branch If Comparision
	addq.l	#3,a0	; Next Instruction Please
	bra	Input_1

Input_JmpAll:
	move.l	d2,d0	; Move Loaded Value To D0
	move.b	(a0)+,d1	; Load Value From Animation Table
	and.b	d1,d0	; Extract Interesting Bits
	cmp.b	d0,d1	; See If It Matches
	beq	Input_Jump	; Branch If Comparision
	addq.l	#3,a0	; Next Instruction Please
	bra	Input_1

Input_JmpAny:
	move.l	d2,d0	; Move Loaded Value To D0
	and.b	(a0)+,d0	; Compare With Table Value
	bne	Input_Jump	; Branch If Comparision
	addq.l	#3,a0	; Next Instruction Please
	bra	Input_1

Input_JumpNot:
	move.l	d2,d0	; Move Loaded Value To D0
	and.b	(a0)+,d0	; Compare With Table Value
	beq	Input_Jump	; Branch If Comparision
	addq.l	#3,a0	; Next Instruction Please
	bra	Input_1

Input_JumpEqu:
	tst.b	d2	; Test Loaded Value
	beq	Input_Jump	; Branch If Comparision
	addq.l	#3,a0	; Next Instruction Please
	bra	Input_1

Input_SetVel:
	move.w	(a0)+,XVELOCITY(a5)	; Store X Velocity
	move.w	(a0)+,d0
	neg.w	d0	; Make Y Velocity Negative
	move.w	d0,YVELOCITY(a5)	; Store Y Velocity
	move.b	(a0)+,d0	; Load The Dampen Byte
	bsr	SetDamp	; Set DAMP
	bra	Input_1

Input_Anim:
	clr.b	ButtonLoad	; Buttons Not Loaded
Input_Done1:
	bsr	GetLong	; Get A Long
Input_Done2:
	move.l	PARSEPOINTER(a5),EXERETURN(a5)
	move.l	d0,PARSEPOINTER(a5)	; Save Pointer To Animation Table
	tst.b	ButtonLoad	; Check If Buttons Used
	beq.s	Input_Done3	; Branch If Not
	move.b	BUTTONS(a6),SAVEBUTTONS(a6)	; Save Used Buttons
	jsr	ClearButtons	; Clear Buttons
Input_Done3:
	clr.l	INPUTROUTINE(a6)	; Clear Out Input Routine Address
	clr.l	ALWAYSROUTINE(a5)	; Clear Always Routine Address
	move.w	#1,DURATION(a5)
Input_Done:
Input_Exit:
	rts

;****************************************************************************
;   Anim - Execute One Animation Step                                       *
;                                                                           *
;   Parameters :  NONE                                                      *
;   Returns:      NONE                                                      *
;   Modifies:     NONE                                                      *
;****************************************************************************
Anim:
	jsr	CheckSeeking	; Check If Seeking Position
	bsr	Move	; Move The Player

	move.l	ALWAYSROUTINE(a5),d0	; Load The Always Routine Address
	beq.s	Anim_1	; Branch If None Defined
	move.l	d0,a0	; Move To An Address Register
	jsr	(a0)	; Execute The Routine
Anim_1:
	tst.b	VSPRITETYPE(a5)	; Check If V Sprite Type
	bne.s	Anim_2    
	subq.w	#1,DURATION(a5)	; Decrement Duration
	ble.s	Anim_3	; Branch If Done Waiting
	rts
Anim_2:
	move.w	VELOCITYDECREMENT(a5),d0
	sub.w	d0,DURATION(a5)	; Decrement Duration
	ble.s	Anim_3	; Branch If Done Waiting
	rts

Anim_3:
;	clr.b	VELOCITYDECREMENT(a5)	; Make It Not A Velocity Sprite
	clr.b	VSPRITETYPE(a5)
	move.l	PARSEPOINTER(a5),a0	; Load Pointer To Animation Table
	move.l	a0,d0
	bne.s	Anim_4	; Branch If Good
	rts
Anim_4:
	clr.l	d0	; Clear D0 Register
	move.b	(a0)+,d0	; Load Animation Command
	lea.l	AnimJumpTable,a1	; Load Address Of Jump Table
	jmp	([a1,d0.w*4])	; Jump To Routine

	.export	AnimJumpTable
AnimJumpTable:
	dc.l	Anim_Sprite	; 0 - SPRITE         Command
	dc.l	Anim_Jump	; 1 - JUMP           Command
	dc.l	Anim_Bits	; 2 - BITS           Command
	dc.l	Anim_Semophore	; 3 - SEMOPHORE      Command
	dc.l	Anim_Execute	; 4 - EXECUTE        Command
	dc.l	Anim_QED	; 5 - QED            Command
	dc.l	Anim_SetLoop	; 6 - SETLOOP        Command
	dc.l	Anim_Loop	; 7 - LOOP           Command
	dc.l	Anim_SetMem	; 8 - SETMEM         Command
	dc.l	Anim_Bitse	; 9 - BITSE          Command
	dc.l	Anim_Clear	; A - CLEAR          Command
	dc.l	Anim_LoadAbs	; B - LOADABS        Command
	dc.l	Anim_SetVel	; C - SETVEL         Command
	dc.l	Anim_JmpCmp	; D - JUMPCMP        Command
	dc.l	Anim_JumpRnd	; E - JUMPRND        Command
	dc.l	Anim_SetRanVel 	; F - SETRANVEL      Command
	dc.l	Anim_IfPower	;10 - IFPOWER        Command
	dc.l	Anim_NoFlip	;11 - NOFLIP         Command
	dc.l	Anim_DSprite	;12 - DSPRITE        Command
	dc.l	Anim_Move	;13 - MOVE           Command
	dc.l	Anim_MoveTo	;14 - MOVE           Command
	dc.l	Anim_JumpIndx	;15 - JUMPINDX       Command
	dc.l	Anim_SetRam	;16 - SETRAM         Command
	dc.l	Anim_IncRam	;17 - INCRAM         Command
	dc.l	Anim_DecRam	;18 - DECRAM         Command
	dc.l	Anim_Update	;19 - UPDATE         Command
	dc.l	Anim_WaitRand	;1A - WAITRAND       Command
	dc.l	Anim_Sound	;1B - SOUND          Command
	dc.l	Anim_StopAnim	;1C - STOPANIM       Command
	dc.l	Anim_DSprites	;1D - DSPRITES       Command
	dc.l	Anim_CmpWI	;1E - CMPWI          Command
	dc.l	Anim_CmpBI	;1F - CMPBI          Command
	dc.l	Anim_JumpEqu	;20 - JUMPEQU        Command
	dc.l	Anim_JumpGT	;21 - JUMPGT         Command
	dc.l	Anim_JumpLT	;22 - JUMPLT         Command
	dc.l	Anim_SetDir	;23 - SETDIR         Command
	dc.l	Anim_CmpWIp2	;24 - CMPWIp2        Command
	dc.l	Anim_CmpBIp2	;25 - CMPBIp2        Command
	dc.l	Anim_System	;26 - SYSTEM         Command
	dc.l	Anim_Dealloc	;27 - DEALLOC        Command
	dc.l	Anim_SemSet	;28 - SEMSET         Command
	dc.l	Anim_DirJump	;29 - DIRJUMP        Command
	dc.l	Anim_FaceBall	;2A - FACEBALL       Command
	dc.l	Anim_LastFrame	;2B - LASTFRAME      Command
	dc.l	Anim_Infield	;2C - INFIELD        Command
	dc.l	Anim_SetRam_p2	;2D - SETRAM_P2      Command
	dc.l	Anim_Color_Cycle	;2E - COLORCYCLE     Command
	dc.l	Anim_JoySeq	;2F - JOYSEQ         Command
	dc.l	Anim_SemClr	;30 - SEMCLR         Command
	dc.l	Anim_NearBall	;31 - NEARBALL       Command
	dc.l	Anim_Shake	;32 - SHAKE          Command
	dc.l	Anim_Lunge	;33 - LUNGE          Command
	dc.l	Anim_Friction	;34 - FRICTION       Command
	dc.l	Anim_BallHigher	;35 - BALLHIGHER     Command
	dc.l	Anim_Faster	;36 - FASTER         Command
	dc.l	Anim_Display	;37 - DISPLAY        Command
	dc.l	Anim_SetZ	;38 - SETZ           Command
	dc.l	Anim_SetAbsW	;39 - SETABSW        Command
	dc.l	Anim_SetGrav	;3A - SETGRAV        Command
	dc.l	Anim_SetVelY	;3B - SETVELY        Command
	dc.l	Anim_FrameRate	;3C - FRAMERATE      Command
	dc.l	Anim_SetAbsB	;3D - SETABSB        Command
	dc.l	Anim_InputSub	;3E - INPUTSUB       Command
	dc.l	Anim_Always	;3F - ALWAYS         Command
	dc.l	Anim_BSnd	;40 - BOUNCESND      Command
	dc.l	Anim_NextSprite	;41 - NEXTSPRITE     Command
	dc.l	Anim_Closer	;42 - CLOSER         Command
	dc.l	Anim_Flip  	;43 - FLIP           Command
	dc.l	Anim_BallFaster	;44 - BALLFASTER     Command 
	dc.l	Anim_IfIAm	;45 - IFIAM          Command
	dc.l	Anim_FMove	;46 - FMOVE          Command
	dc.l	Anim_JumpNE	;47 - JUMPNE         Command
	dc.l	Anim_SetPal	;48 - SETPALETTE     Command
	dc.l	Anim_BallFarther	;49 - BALLFARTHER    Command
	dc.l	Anim_SetAI	;4A - SETAI          Command
	dc.l	Anim_IfHasPower	;4B - IFHASPOWER     Command
	dc.l	Anim_Text	;4C - TEXT           Command
	dc.l	Anim_SetRamW	;4D - SETRAMW        Command
	dc.l	Anim_AddRamW	;4E - ADDRAMW        Command
	dc.l	Anim_SubRamW	;4F - SUBRAMW        Command
	dc.l	Anim_Sound2	;50 - SOUND2         Command
	dc.l	Anim_NearWall	;51 - NEARWALL       Command
	dc.l	Anim_SetRamL	;52 - SETRAML        Command
	dc.l	Anim_GoalPos	;53 - GOALPOS        Command
	dc.l	0	;54 - 
	dc.l	Anim_WSprite	;55 - WSPRITE        Command
	dc.l	Anim_Trackball	;56 - TRACKBALL      Command
	dc.l	Anim_Backgnd	;57 - BACKGND        Command
	dc.l	0	;58 - 
	dc.l	0	;59 - 
	dc.l	0	;5A - 
	dc.l	0	;5B - 
	dc.l	0	;5C - FIERCEWHOOSH   Command
	dc.l	0	;5D - 
	dc.l	Anim_SemJump	;5E - SEMJUMP        Command
	dc.l	0	;5F - 
	dc.l	Anim_IncAudit	;60 - INCAUDIT       Command
	dc.l	0	;61 -
	dc.l	0	;62 - 
	dc.l	0	;63 - 
	dc.l	0	;64 - 
	dc.l	0	;65 - 
	dc.l	Anim_Clip	;66 - MOVECLIP       Command
	dc.l	Anim_JumpTo	;67 - JUMPTO         Command
	dc.l	Anim_Sprite	;68 - SPRITE1        Command
	dc.l	Anim_Sprite	;69 - SPRITE2        Command
	dc.l	Anim_OrWI	;6A - ORIW           Command
	dc.l	Anim_VSprite	;6B - VSPRITE        Command
	dc.l	0	;6C - 
	dc.l	0	;6D - 
	dc.l	0	;6E - 
	dc.l	0	;6F - 
	dc.l	Anim_AndWI	;70 - ANDW           Command
	dc.l	0	;71 -
	dc.l	0	;72 -
	dc.l	0	;73 -
	dc.l	0	;74 - 
	dc.l	0	;75 -

Anim_GoalPos:
	move.l	B_GOALX(a5),WORLDX(a5)	; Set X Position
	move.l	B_GOALY(a5),WORLDY(a5)	; Set Y Position
	bra	Anim_4

Anim_SetRamL:
	move.w	(a0)+,d0	; Load Memory Address
	move.l	(a0)+,d1	; Load Data Byte
	move.l	d1,(a5,d0.w)	; Store Into Ram Block
	bra	Anim_4

Anim_NearWall:
	move.l	#StadiumY,a0	; Load Address Of Stadium Data
	move.l	WORLDX(a5),d0	; Load X Position
	bpl.s	Anim_NearW1	; Branch If Positive
	neg.l	d0	; Make It Positive
Anim_NearW1:
	lsr.l	#8,d0	; Extract Inches
	lsr.l	#3,d0	; Extract 8 Inches
	lsl.w	#1,d0	; Multiply By Two
	move.w	(a0,d0.w),d0	; Load Stadium Y Position
	lsl.l	#8,d0	; Shift Up Inches
	sub.l	WORLDY(a5),d0	; Subtract Player's Y Position
	bpl.s	Anim_NearW2	; Branch If Fine
	neg.l	d0	; Make Result Positive
Anim_NearW2:
	cmp.l	(a0)+,d0	; Compare With Distance
	ble	Anim_Jump	; Branch If Close To Wall
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_SetAI:
	move.w	(a0)+,d0	; Load AI Status
	move.l	CONTROLBLOCK(a5),d1	; Load Address Of Control Block
	beq	Anim_4	; Branch If Not Defined
	move.l	d1,a1	; Move To An Address Register
	move.w	d0,AISTATUS(a1)	; Set AI Status
	bra	Anim_4
	
Anim_IfIAm:
	jsr	GetLong	; Get Address To Check
	move.l	d0,a1	; Move To Address Register
	cmp.l	(a1),a5	; Check If It Is Me
	beq	Anim_Jump	; Branch If It Is
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_LoadAbs:
	jsr	GetLong	; Get Long Value
	move.l	d0,a1	; Move To Address Register
	move.b	(a1),d4	; Load Input Value Into D2
	bra	Anim_4
	
Anim_SetAbsW:
	jsr	GetLong	; Get Absolute Address
	move.l	d0,a1	; Move To An Address Register
	move.w	(a0)+,(a1)	; Store Value
	bra	Anim_4
	
Anim_SetAbsB:
	jsr	GetLong	; Get Absolute Address
	move.l	d0,a1	; Move To An Address Register
	move.b	(a0)+,(a1)	; Store Value
	bra	Anim_4
	
Anim_StopAnim:
	clr.l	PARSEPOINTER(a5)	; Clear Animation Pointer
	rts

Anim_Friction:
	move.l	WORLDXVEL(a5),d0	; Load Player X Velocity
	asr.l	#2,d0	; Calculate 1/4
	sub.l	d0,WORLDXVEL(a5)	; Slow By 1/4

	move.l	WORLDYVEL(a5),d0	; Load Player Y Velocity
	asr.l	#2,d0	; Calculate 1/4
	sub.l	d0,WORLDYVEL(a5)	; Slow By 1/4
	bra	Anim_4

Anim_BallHigher:
	move.l	#Baseball,a1	; Load Address Of Ball
	move.l	(a0)+,d0	; Load Compare Value
	cmp.l	WORLDZ(a1),d0	; Compare Ball Height
	ble	Anim_Jump	; Branch If Ball Higher
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_BallFarther:
	move.w	(a0)+,d0	; Load Time Frame
	jsr	CalcBallPos	; Calculate Ball Position
	move.l	d4,d6	; Move X To D6
	move.l	d5,d7	; Move Y To D7
	sub.l	WORLDX(a5),d6	; Subtract Player's X Position
	sub.l	WORLDY(a5),d7	; Subtract Player's Y Position
	jsr	CalcDistance	; Calculate Distance
	move.l	(a0)+,d0	; Load Compare Distance
	cmp.l	d0,d1	; Check If Close
	bge	Anim_Jump	; Branch If Ball Higher
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_BallFaster:
	move.l	#Baseball,a1	; Load Address Of Ball
	move.l	(a0)+,d0	; Load Compare Value
	cmp.l	CatchYVel,d0	; Compare Ball Speed
	ble	Anim_Jump	; Branch If Ball Faster
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4
	
Anim_Faster:
	move.l	(a0)+,d0	; Load Compare Value
	move.l	WORLDXVEL(a5),d4	; Load X Velocity
	bpl.s	Anim_Fast1	; Branch If Positive
	neg.l	d4	; Make It Positive
Anim_Fast1:
	move.l	WORLDYVEL(a5),d5	; Load Y Velocity
	bpl.s	Anim_Fast2	; Branch If Positive
	neg.l	d5	; Make It Positive
Anim_Fast2:
	cmp.l	d4,d5	; Check Which Is Larger
	bge.s	Anim_Fast3	; Branch If D5 Greater
	exg	d4,d5	; Swap Values
Anim_Fast3:
	asr.l	#1,d4	; Divide Shorter By Two
	add.l	d4,d5	; Add Two Values
	cmp.l	d5,d0	; Compare Velocity With Compare Value
	ble	Anim_Jump	; Branch If In Infield
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_FaceBall:
	move.w	(a0)+,d0	; Load Time Frame
	tst.b	B_HASBALL(a5)	; Check If Player Has The Ball
	bne	Anim_4	; Branch If He Does
	jsr	CalcBallPos	; Calculate Ball Position
	sub.l	WORLDX(a5),d4	; Subtract My Position X
	sub.l	WORLDY(a5),d5	; Subtract My Position Y
	jsr	CalcDirection	; Determine Player Direction

;	tst.b	FLIPFLAG(a5)	; Check If Flipped
;	beq.s	Anim_Face1	; Branch If Not
;	neg.w	d0	; Negate DIrection
;	add.w	#8,d0	; Calculate Flipped Picture
;	and.w	#0x7,d0	; Force In Range
;Anim_Face1:
	move.b	d0,B_DIRECTION(a5)	; Store The Direction
	bra	Anim_4
	
Anim_Infield:
	move.l	WORLDY(a5),d0	; Load Object's Y Position
	sub.l	#SECONDBASEY+10*12*256,d0	; Subtract Ten Feet Beyond Second
	bmi	Anim_Jump	; Branch If In Infield
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4
	

Anim_Closer:
	move.l	(a0)+,d4	; Load X Position
	sub.l	WORLDX(a5),d4	; Subtract X Position
	bpl.s	Anim_Close1	; Branch If Positive
	neg.l	d4 	; Make Result Positive
Anim_Close1:
	move.l	(a0)+,d5	; Load Y Position
	sub.l	WORLDY(a5),d5	; Subtract Y Position
	bpl.s	Anim_Close2	; Branch If Positive
	neg.l	d5 	; Make Result Positive
Anim_Close2:
	cmp.l	d4,d5	; Check Which Is Larger
	bge.s	Anim_Close3	; Branch If D5 Greater
	exg	d4,d5	; Swap Values
Anim_Close3:
	asr.l	#1,d4	; Divide Shorter By Two
	add.l	d4,d5	; Add Two Values
	cmp.l	(a0)+,d5	; Compare With Distance
	ble	Anim_Jump	; Branch If Close To Ball
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_NearBall:
	move.l	#Baseball,a1	; Load Address Of Ball Object
	move.l	WORLDX(a5),d4	; Load Object's X Position
	sub.l	WORLDX(a1),d4	; Subtract Ball's X Position
	bpl.s	Anim_Near1	; Branch If Positive
	neg.l	d4 	; Make Result Positive
Anim_Near1:
	move.l	WORLDY(a5),d5	; Load Object's Y Position
	sub.l	WORLDY(a1),d5	; Subtract Ball's Y Position
	bpl.s	Anim_Near2	; Branch If Positive
	neg.l	d5 	; Make Result Positive
Anim_Near2:
	cmp.l	d4,d5	; Check Which Is Larger
	bge.s	Anim_Near3	; Branch If D5 Greater
	exg	d4,d5	; Swap Values
Anim_Near3:
	asr.l	#1,d4	; Divide Shorter By Two
	add.l	d4,d5	; Add Two Values
	cmp.l	(a0)+,d5	; Compare With Distance
	ble	Anim_Jump	; Branch If Close To Ball
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_Lunge:
	clr.l	d0	; Clear D3
	move.w	(a0)+,d0	; Load Time Frame
	PUSHL	d0	; Store Time
	jsr	CalcBallPos	; Calculate Ball Position
	POPL	d0	; Retrieve Time
	sub.l	WORLDX(a5),d4	; Subtract My Position X
	sub.l	WORLDY(a5),d5	; Subtract My Position Y
	divs.l	d0,d4	; Calculate X Velocity
	divs.l	d0,d5	; Calculate Y Velocity
	divs.l	d0,d6	; Calculate Y Velocity
	move.l	d4,WORLDXVEL(a5)	; Store X Velocity
	move.l	d5,WORLDYVEL(a5)	; Store Y Velocity
	lsr.w	#1,d0	; Divide Time By Two
	mulu	#PGRAVITY,d0	; Multiply Time/2 By Gravity
	add.l	d0,d6	; Add To Z Velcoity
	move.l	d6,WORLDZVEL(a5)	; Store Y Velocity
	bra	Anim_4
	
Anim_Display:
	jsr	GetLong	; Get New Display Routine Address
	move.l	d0,DISPLAYPROC(a5)	; Store Display Proc.
	bra	Anim_4

Anim_Update:
	jsr	GetLong	; Get New Display Routine Address
	move.l	d0,UPDATEPROC(a5)	; Store Display Proc.
	bra	Anim_4
	
Anim_DSprites:
	lea	B_DIRSPRITES(a5),a1	; Load Address Of Directional Sprites
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	bne.s	AnimDSpr_1	; Branch If He Is
	move.w	(a0)+,(a1)	; Direction 0 -> 0
	move.w	(a0)+,2(a1)	; Direction 1 -> 1
	move.w	(a0)+,4(a1)	; Direction 2 -> 2
	move.w	(a0)+,6(a1)	; Direction 3 -> 3
	move.w	(a0)+,8(a1)	; Direction 4 -> 4
	move.w	(a0)+,10(a1)	; Direction 5 -> 5
	move.w	(a0)+,12(a1)	; Direction 6 -> 6
	move.w	(a0)+,14(a1)	; Direction 7 -> 7
	bra	Anim_4
AnimDSpr_1:
	move.w	(a0)+,(a1)	; Direction 0 -> 0
	move.w	(a0)+,14(a1)	; Direction 1 -> 7
	move.w	(a0)+,12(a1)	; Direction 2 -> 6
	move.w	(a0)+,10(a1)	; Direction 3 -> 5
	move.w	(a0)+,8(a1)	; Direction 4 -> 4
	move.w	(a0)+,6(a1)	; Direction 5 -> 3
	move.w	(a0)+,4(a1)	; Direction 6 -> 2
	move.w	(a0)+,2(a1)	; Direction 7 -> 1
	bra	Anim_4

Anim_DSprite:
	clr.w	d0	; Clear D0
	move.b	B_DIRECTION(a5),d0	; Load Direction Of Object
	lea	B_DIRSPRITES(a5),a1	; Load Address Of Directional Sprites
	move.w	(a1,d0.w*2),d0	; Load Sprite Number
	move.w	d0,CURRENTFRAME(a5)	; Store New Frame Number
	move.w	d0,PICTURE(a5)	; Store For Display
	move.w	DURATIONRESET(a5),DURATION(a5) ; Use Stored Duration
	clr.w	d0	; Clear D0
	move.b	(a0)+,d0	; Load Duration
	cmp.w	#0xFF,d0	; Check If Real
	beq.s	Anim_DS1	; Branch If Not
	move.w	d0,DURATION(a5)	; Store New Duration
Anim_DS1:
	clr.b	VSPRITETYPE(a5)
	bra	Anim_End

Anim_SetDir:
	move.l	(a0)+,d4	; Load X Destination
	sub.l	WORLDX(a5),d4	; Subtract Object's X Position
	move.l	(a0)+,d5	; Load Y Destination
	sub.l	WORLDY(a5),d5	; Subtract Object's Y Position
	jsr	CalcDirection	; Calculate Direction
	move.b	d0,B_DIRECTION(a5)	; Store Object's Direction
	bra	Anim_4

Anim_DirJump:
	move.l	(a0)+,d4	; Load X Destination
	sub.l	WORLDX(a5),d4	; Subtract Object's X Position
	move.l	(a0)+,d5	; Load Y Destination
	sub.l	WORLDY(a5),d5	; Subtract Object's Y Position
	jsr	CalcDirection	; Calculate Direction
	tst.w	d0	; Check If Any Direction
	bpl.s	Anim_Dir1	; Branch If Fine
	clr.w	d0	; Make It Down Direction
Anim_Dir1:
	tst.b	FLIPFLAG(a5)	; Check If Flipped
	beq.s	Anim_Dir2	; Branch If Not
	neg.w	d0	; Negate DIrection
	add.w	#8,d0	; Calculate Flipped Picture
	and.w	#0x7,d0	; Force In Range
Anim_Dir2:
	move.w	d0,d1	; Move Direction To D1
	add.w	d0,d1	; Multiply By Two
	add.w	d0,d1	; Multiply By Three
	lea	(a0,d1.w),a0	; Index Into Jumps
	jsr	GetLong	; Get Jump Address
	move.l	d0,a0	; Move To Animation Pointer
	bra	Anim_4

Anim_NextSprite:
	add.w	#1,CURRENTFRAME(a5)	; Store New Frame Number
	add.w	#1,PICTURE(a5)	; Store For Display
	move.w	DURATIONRESET(a5),DURATION(a5) ; Use Stored Duration
	clr.w	d0	; Clear D0
	move.b	(a0)+,d0	; Load Duration
	cmp.w	#0xFF,d0	; Check If Real
	beq.s	Anim_NS1	; Branch If Not
	move.w	d0,DURATION(a5)	; Store New Duration
Anim_NS1:
	clr.b	VSPRITETYPE(a5)
	bra	Anim_End

	.global	Anim_Sprite
Anim_Sprite:
	move.l	CONTROLBLOCK(a5),d0	; Load Address Of Control Block
	beq.s	Anim_Sprite1	; Branch If None
	move.l	d0,a1	; Move To A1
	move.w	#15,TRACKCOUNT(a1)          ; Set Track Ball Cout
Anim_Sprite1:
	move.w	(a0)+,d0	; Load Frame Number
	move.w	d0,CURRENTFRAME(a5)	; Store New Frame Number
	move.w	d0,PICTURE(a5)	; Store For Display
	move.w	DURATIONRESET(a5),DURATION(a5) ; Use Stored Duration
	clr.w	d0	; Clear D0
	move.b	(a0)+,d0	; Load Duration
	cmp.w	#0xFF,d0	; Check If Real
	beq.s	Anim_Sprite2	; Branch If Not
	move.w	d0,DURATION(a5)	; Store New Duration
Anim_Sprite2:
	clr.b	VSPRITETYPE(a5)
	bra	Anim_End

Anim_VSprite:
Anim_VSprite1:
	move.w	(a0)+,d0	; Load Frame Number (high byte)
	move.w	d0,CURRENTFRAME(a5)	; Store New Frame Number
	move.w	d0,PICTURE(a5)	; Store For Display
	clr.w	d0	; Clear D0
	move.b	(a0)+,d0	; Load Duration
	add.w	d0,DURATION(a5)	; 
	ble	Anim_4
	move.b	#1,VSPRITETYPE(a5)	; Flag As Velocity Sprite
	bra	Anim_End

Anim_WSprite:
	move.w	(a0)+,d0	; Load Frame Number (high byte)
	move.w	d0,CURRENTFRAME(a5)	; Store New Frame Number
	move.w	d0,PICTURE(a5)	; Store For Display
	clr.w	d0	; Clear D0
	move.b	(a0)+,d0	; Load Duration
	move.w	d0,DURATION(a5)	; Store New Duration
	bra	Anim_End

Anim_IncAudit:
	clr.w	d0	; Clear D0
	move.b	(a0)+,d0	; Load Audit Number
	jsr	IncAudit	; Increment Audit
	bra	Anim_4	; Continue On

Anim_Semophore:
	jsr	GetLong	; Get Address To Test
	move.l	d0,a1	; Move To Address Register
	tst.b	(a1)	; Check If Semophore Set
	bne	Anim_4	; Continue On If Set
	move.w	#1,DURATION(a5)	; Store New Duration
     	lea	-4(a0),a0	; Reset To Semophore Command
	bra	Anim_End

Anim_Text:
	jsr	GetLong	; Get Address To Test
	move.l	d0,PARENT(a5)	; Move To Address Register
	bra	Anim_4

Anim_SemSet:
	jsr	GetLong	; Get Address To Test
	move.l	d0,a1	; Move To Address Register
	move.b	#1,(a1)	; Set The Semophore 
	bra	Anim_4

Anim_SemClr:
	jsr	GetLong	; Get Address To Test
	move.l	d0,a1	; Move To Address Register
	clr.b	(a1)	; Clear The Semophore
	bra	Anim_4

Anim_SemJump:
	jsr	GetLong	; Get Address To Test
	move.l	d0,a1	; Move To Address Register
	tst.b	(a1)	; Check If Semophore Set
	bne	Anim_Jump	; Branch If Set
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_WaitRand:
	jsr	Random	; Cycle Random Number
	move.w	(a0)+,d0
	move.w	d0,DURATION(a5)	; Save Duration
	move.w	(a0)+,d0
	and.w	rnd1,d0	; Extract Random Number
	add.w	d0,DURATION(a5)	; Add In Random Duration
	bra	Anim_End

Anim_LastFrame:
	clr.l	d0	; Clear D0
	move.b	(a0)+,d0	; Load New Duration
	beq	Anim_End	; Branch If Already Set
	move.w	d0,DURATION(a5)	; Store New Duration
	bra	Anim_End

Anim_Jump:
	bsr	GetLong	; Get A Long
	move.l	d0,a0	; Move To Animation Pointer
	bra	Anim_4

TRACKSPEED	equ	10
	
Anim_Trackball:
	move.l	CONTROLBLOCK(a5),d0	; Load Address Of Control Block
	beq	Anim_4	; Branch If None
	move.l	d0,a1	; Move To A1
	subq.w	#1,TRACKCOUNT(a1)           ; Decrement Counter
	beq.s	Anim_Track2                 ; Branch If Time Out
	cmp.w	#-TRACKSPEED,TRACKY(a1)	; Compare Track Ball Position
	bge.s	Anim_Track4
	clr.w	TRACKY(a1)	; Clear Trackball

Anim_Track2:
	bsr	GetLong	; Get A Long
	cmp.l	#$00FFFFFF,d0	; Check If -1
	bne.s	Anim_Track3	; Branch If Not
	lea	-16(a0),a0	; Reset To Previous Sprite
	bra	Anim_4

Anim_Track3:
	move.l	d0,a0	; Move To Animation Pointer
	bra	Anim_4

Anim_Track4:
	cmp.w	#TRACKSPEED,TRACKY(a1)	; Compare Track Ball Position
	bgt.s	Anim_Track5
	lea	-1(a0),a0	; Reset To Trackball Command
	bra	Anim_End
Anim_Track5:
	addq.l	#3,a0	; Next Instruction Please
	clr.w	TRACKY(a1)	; Clear Trackball
	bra	Anim_4

Anim_JmpCmp:
	cmp.b	(a0)+,d4	; Compare With Value
	beq	Anim_Jump	; Branch If Comparision
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_Bits:
	move.w	(a0)+,d0
	move.b	(a5,d0.w),d1	; Load Value From Player Data
	move.b	(a0)+,d0	; Load Compare Byte
	and.b	d1,d0	; Exclusive And Bits
	bne.s	Anim_Jump	; Branch If Comparision
Anim_Bits1:
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_Sound:
	move.b	(a0)+,d0	; Load sound code
	clr.b	d1	; Dummy second sound
	jsr	SendSound
	bra	Anim_4

Anim_Sound2:
	move.b	(a0)+,d0	; Load sound code
	move.b	(a0)+,d1	; Load sound code
	jsr	SendSound
	bra	Anim_4

Anim_Execute:
	bsr	GetLong	; Get Next Long
	move.l	a0,EXERETURN(a5)	; Store Return Address
	move.l	d0,a0	; Set New Animation Address
	bra	Anim_4

Anim_QED:
	move.l	EXERETURN(a5),a0	; Return From Subroutine
	bra	Anim_4

Anim_SetLoop:
	move.w	(a0)+,d0
	move.w	d0,LOOPCOUNTER(a5)
	bra	Anim_4

Anim_Loop:
	subq.w	#1,LOOPCOUNTER(a5)	; Decrement Counter
	bne	Anim_Jump	; Branch If Not Time-Out
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_Backgnd:
	clr.w	d0	; Clear D0
	move.b	(a0)+,d0	; Load Back Ground To Check
	cmp.w	BackArt,d0	; Check If Background
	beq	Anim_Jump	; Branch If Not
Anim_Back1:
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4
Anim_Back2:
	addq.l	#4,a0	; Next Instruction Please
	bra	Anim_4

Anim_Bitse:
	move.w	(a0)+,d0
	move.b	(a5,d0.w),d1	; Load Player's Data Byte
	move.b	(a0)+,d0	; Load Compare Byte
	and.b	(a0)+,d1	; And With Mask Byte
	cmp.b	d1,d0	; Exclusive And Bits
	beq	Anim_Jump	; Branch If Comparision
Anim_BitsE1:
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_Clear:
	move.w	(a0)+,d0
	cmp.w	#BUTTONS,d0	; Check If Clearing Buttons
	beq.s	Anim_Clear1	; Branch If Buttons
	cmp.w	#SPECIALJOY,d0	; Check If Clearing Special Joy
	beq.s	Anim_Clear2	; Branch If Special Joy
	clr.b	(a5,d0.w)	; Clear Data Byte
	bra	Anim_4
Anim_Clear1:
	bra	Anim_4
Anim_Clear2:
	clr.w	SPECIALJOY(a5)	; Clear Special Joystick Value
	bra	Anim_4

Anim_InputSub:
	bsr	GetLong	; Get A Long
	move.l	CONTROLBLOCK(a5),d1	; Check If Being Controlled
	beq	Anim_4	; Branch If Not
	move.l	d1,a1	; Move To An Address Register
	move.l	d0,INPUTROUTINE(a1)	; Move To Joystick Routine Address
	bra	Anim_4

	.global	Anim_SetVel
Anim_SetVel:
	move.w	(a0)+,d0
	move.w	d0,XVELOCITY(a5)	; Store X Velocity
	move.w	(a0)+,d0
	neg.w	d0	; Make Y Velocity Negative
	move.w	d0,YVELOCITY(a5)	; Store Y Velocity
	move.b	(a0)+,d0	; Load The Dampen Byte
	bsr	SetDamp	; Set DAMP
	bra	Anim_4
	
Anim_JumpRnd: 
	jsr	Random	; Get Random Number
	and.b	#0xFF,d0	; Extract Lower Byte
	and.b	(a0)+,d0	; Mask Out Bits
	lea.l	1(a0,d0.w*4),a0	; Load Routine Address
	bra	Anim_Jump

	.global	Anim_SetRanVel
Anim_SetRanVel:
	move.w	(a0)+,d0
	jsr	Random
	sub.w	#128,d0
	mulu.w	#3,d0
	move.w	d0,XVELOCITY(a5)	; Store X Velocity
	move.w	(a0)+,d0
	neg.w	d0	; Make Y Velocity Negative
	move.w	d0,YVELOCITY(a5)	; Store Y Velocity
	move.b	(a0)+,d0	; Load The Dampen Byte
	bsr	SetDamp	; Set DAMP
	bra	Anim_4

	
Anim_JumpTo: 
	jsr	GetLong	; Get Address To Test
	move.l	d0,a1	; Move To Address Register
	clr.l	d0
	move.b	(a1)+,d0	; Mask Out Bits
	bpl.s	Anim_JumpTo1	; Branch On Positive
	clr.b	d0	; Make It Zero
Anim_JumpTo1:
	lea.l	1(a0,d0.w*4),a0	; Load Routine Address
	bra	Anim_Jump

Anim_Flip:    
	move.b	#2,FLIPFLAG(a5)	; Set The Flip Flag
	bra	Anim_4
Anim_NoFlip:
	clr.b	FLIPFLAG(a5)	; Clear The Flip Flag
	bra	Anim_4

Anim_Clip:
	move.b	(a0)+,d0	; Load X Offset
	ext.w	d0	; Extend The Sign
	add.w	d0,XCLIP1(a5)	; Add To X Position

	move.b	(a0)+,d0	; Load X Offset
	ext.w	d0	; Extend The Sign
	add.w	d0,YCLIP1(a5)	; Store New Y Offset

	move.b	(a0)+,d0	; Load Y Offset
	ext.w	d0	; Extend The Sign
	add.w	d0,XCLIP2(a5)	; Add To X Position

	move.b	(a0)+,d0	; Load Y Offset
	ext.w	d0	; Extend The Sign
	add.w	d0,YCLIP2(a5)	; Store New Y Offset

	bra	Anim_4

Anim_Move:
	move.b	(a0)+,d0	; Load X Offset
	ext.w	d0	; Extend The Sign
	add.w	d0,XPOSITION(a5)	; Add To X Position
	move.b	(a0)+,d0	; Load Y Offset
	ext.w	d0	; Extend The Sign
	add.w	d0,YPOSITION(a5)	; Store New Y Offset
	bra	Anim_4


Anim_FMove:		; Flip X if Anim is Fliped
	move.b	(a0)+,d0	; Load X Offset
	ext.w	d0	; Extend The Sign
	tst.b	FLIPFLAG(a5)	; Test if FLip Set
	beq.s	FMove_1	; If not Branch
	sub.w	d0,XPOSITION(a5)	; Sub To X Position because FLip
	bra.s	FMove_2	; Branch past subtract
FMove_1:
	add.w	d0,XPOSITION(a5)	; Add To X Position
FMove_2:
	move.b	(a0)+,d0	; Load Y Offset
	ext.w	d0	; Extend The Sign
	add.w	d0,YPOSITION(a5)	; Store New Y Offset
	bra	Anim_4


Anim_MoveTo:
	move.b	(a0)+,d0	; Load X Offset
	ext.w	d0	; Extend The Sign
;	move.w	XPOSITION(a5),d2	; Load Player 1 X Position
;	cmp.w	XPOSITION(a6),d2	; Compare With Player 2
;	blt.s	Anim_Move_1	; Branch If Greater
	tst.b	FLIPFLAG(a5)	; Check The Flip Flag
	beq.s	Anim_Move_1	; Branch If Not Flipped
	neg.w	d0	; Negate The Velocity
Anim_Move_1:
	add.w	d0,XPOSITION(a5)	; Add To X Position
	move.b	(a0)+,d0	; Load X Offset
	ext.w	d0	; Extend The Sign
	add.w	d0,YPOSITION(a5)	; Store New Y Offset
	bra	Anim_4
Anim_JumpIndx:
	bsr	GetLong	; Get Address Of Data Byte
	move.l	d0,a1	; Move To A Register
	clr.l	d0	; Clear D0 Register
	move.b	(a1),d0	; Load Random Number
	lea.l	1(a0,d0.w*4),a0	; Load Routine Address
	bra	Anim_Jump
	.export	Anim_SetRam
Anim_SetRam:
	move.w	(a0)+,d0
	move.b	(a0)+,d1	; Load Data Byte
	move.b	d1,(a5,d0.w)	; Store Into Ram Block
	bra	Anim_4

Anim_SetMem:
	bsr	GetLong	; Get A Long
	move.l	d0,a1	; Move To Animation Pointer
	move.b	(a0)+,(a1)
	bra	Anim_4

Anim_SetRamW:
	move.w	(a0)+,d1
	move.w	(a0)+,(a5,d1.w)	; Store Into Ram Block
	bra	Anim_4

Anim_AddRamW:
	move.w	(a0)+,d0
	move.w	d0,d1	; Save In D1
	move.w	(a0)+,d0
	add.w	d0,(a5,d1.w)	; Add Into Ram Block
	bra	Anim_4

Anim_SubRamW:
	move.w	(a0)+,d0
	move.w	d0,d1	; Save In D1
	move.w	(a0)+,d0
	sub.w	d0,(a5,d1.w)	; Subtract From Ram Block
	bra	Anim_4

Anim_SetRam_p2:
	move.w	(a0)+,d0
	move.b	(a0)+,d1	; Load Data Byte
	move.b	d1,(a6,d0.w)	; Store Into Ram Block
	bra	Anim_4

Anim_IncRam:
	move.w	(a0)+,d0
	addq.b	#1,(a5,d0.w)	; Increment Ram Block
	bra	Anim_4

Anim_DecRam:
	move.w	(a0)+,d0
	subq.b	#1,(a5,d0.w)	; Decrement Ram Block
	bra	Anim_4

Anim_OrWI:
	move.w	(a0)+,d0
	move.w	d0,d1	; Save In D1
	move.w	(a0)+,d0
	or.w	d0,(a5,d1.w)	; Or With Ram Block
	bra	Anim_4

Anim_AndWI:
	move.w	(a0)+,d0
	move.w	d0,d1	; Save In D1
	move.w	(a0)+,d0
	and.w	d0,(a5,d1.w)	; And With Ram Block
	bra	Anim_4

Anim_CmpWI:
	move.w	(a0)+,d0
	move.w	(a5,d0.w),d1	; Load Compare Value
	move.w	(a0)+,d0
	cmp.w	d1,d0	; Perform The Compare
	move.w	sr,Flags	; Save The Flags
	bra	Anim_4

Anim_CmpPlayer:
	move.w	(a0)+,d0
	move.b	(a5,d0.w),d1	; Load Compare Value
	move.b	(a0)+,d0	; Load Compare Immediate
	cmp.b	d1,d0	; Perform The Compare
	move.w	sr,Flags	; Save The Flags
	bra	Anim_4

	.global	Anim_CmpBI
Anim_CmpBI:
	move.w	(a0)+,d0
	move.b	(a5,d0.w),d1	; Load Compare Value
	move.b	(a0)+,d0	; Load Compare Immediate
	cmp.b	d1,d0	; Perform The Compare
	move.w	sr,Flags	; Save The Flags
	bra	Anim_4

Anim_CmpWIp2:
	move.w	(a0)+,d0
	move.w	(a6,d0.w),d1	; Load Compare Value
	move.w	(a0)+,d0
	cmp.w	d1,d0	; Perform The Compare
	move.w	sr,Flags	; Save The Flags
	bra	Anim_4

Anim_CmpBIp2:
	move.w	(a0)+,d0
	move.b	(a6,d0.w),d1	; Load Compare Value
	move.b	(a0)+,d0	; Load Compare Immediate
	cmp.b	d1,d0	; Perform The Compare
	move.w	sr,Flags	; Save The Flags
	bra	Anim_4

Anim_IfPower:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	beq.s	Anim_IfP_1	; Branch If Not In Control
	move.l	d0,a1	; Move Address Of Control Block To A1
	tst.b	POWERUP(a1)	; Check If Powered Up
	bne	Anim_Jump	; Branch If He Is
Anim_IfP_1:
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_IfHasPower:
	move.l	CONTROLBLOCK(a5),d0	; Load Control Block
	beq.s	Anim_IfHP1	; Branch If Not In Control
	move.l	d0,a1	; Move Address Of Control Block To A1
	move.b	(a0)+,d0	; Load Power Up Number
	cmp.b	POWERNUM(a1),d0	; Check If Powered Up
	beq	Anim_Jump	; Branch If He Is
Anim_IfHP1:
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_JumpEqu:
	move.w	Flags,sr	; Retrieve The Flags
	beq	Anim_Jump	; Branch If Comparision
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_JumpNE:
	move.w	Flags,sr	; Retrieve The Flags
	bne	Anim_Jump	; Branch If Less Than
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_JumpLT:
	move.w	Flags,sr	; Retrieve The Flags
	bgt	Anim_Jump	; Branch If Greater Than
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_JumpGT:
	move.w	Flags,sr	; Retrieve The Flags
	blt	Anim_Jump	; Branch If Less Than
	addq.l	#3,a0	; Next Instruction Please
	bra	Anim_4

Anim_System:
	bsr	GetLong	; Get Address To Execute
	move.l	d0,a1	; Move Address To A1
	move.l	a0,PARSEPOINTER(a5)
	jsr	(a1)	; Execute The Routine
	move.l	PARSEPOINTER(a5),a0
	bra	Anim_4

	.import	CardPtr
Anim_Dealloc:
	move.b	#1,DELETED(a5)	; Remove The Object
	rts

;***************************************************************************
;   CalcBallPos - Calculate Ball Position After A Period Of Time	*
;				*
;   Parameters :  d0 - Time After Which Position Is Checked	*
;   Returns:      d4 - X Position Of Ball		*
;	       d5 - Y Position Of Ball		*
;	       d6 - Z Position of Ball		*
;   Modifies:     d0,d1,d4,d5,d6,a1		*
;***************************************************************************
CalcBallPos:
	move.l	#Baseball,a1	; Load Address Of Ball Data
	tst.l	DISPLAYPROC(a1)	; Check If Displayed
	beq	CalcBall_7	; Branch If Not
	tst.w	ThrowTime	; Check If Ball Thrown
	bne	CalcBall_5	; Branch If It Was
	
	move.l	WORLDX(a1),d4	; Load X Position
	move.l	WORLDY(a1),d5	; Load Y Position
	move.l	WORLDZ(a1),d6	; Load Z Position

	move.l	WORLDXVEL(a1),d2	; Load X Velocity
	move.l	WORLDYVEL(a1),d3	; Load Y Velocity
	move.l	WORLDZVEL(a1),d7	; Load Z Velocity

	move.w	d0,CalcTemp	; Save Counter
	move.l	#StadiumY,a2	; Load Address Of Stadium Data
CalcBall_1:
	add.l	d2,d4	; Add X Velocity
	add.l	d3,d5	; Add Y Velocity
	add.l	d7,d6	; Add Z Velocity
	sub.l	#BALLGRAVITY,d7	; Add In Gravity Effect

	move.l	d4,d0	; Load X Position
	bpl.s	CalcBall_2	; Branch If Positive
	neg.l	d0	; Make It Positive
CalcBall_2:
	lsr.l	#8,d0	; Extract Inches
	lsr.l	#3,d0	; Extract 8 Inches
	lsl.w	#1,d0	; Multiply By Two
	move.w	(a2,d0.w),d0	; Load Stadium Y Position
	lsl.l	#8,d0	; Shift Up Inches
	cmp.l	d5,d0	; Load Ball's Y Position
	bge	CalcBall_3	; Branch If Fine
	tst.b	HomeRun	; Check If Already A Home Run
	bne.s	CalcBall_9	; Branch If It Was

	neg.l	d2	; Bounce Off The Wall X Velocity
	asr.l	#2,d2	; Divide By Four
	neg.l	d3	; Bounce Off The Wall Y Velocity
	asr.l	#2,d3	; Divide By Four
CalcBall_3:
	tst.l	d6	; Check Ball Height
	bpl	CalcBall_4	; Branch If Still In Air

	move.l	d2,d0	; Load X Velocity
	asr.l	#2,d0	; Divide By Four
	sub.l	d0,d2	; Slow Ball Down

	move.l	d3,d0	; Load Y Velocity
	asr.l	#2,d0	; Divide By Four
	sub.l	d0,d3	; Slow Ball Down

	move.l	d2,d0	; Load X Velocity
	bpl.s	CalcBall_3A	; Branch If Positive
	neg.l	d0 	; Make It Positive
CalcBall_3A:
	move.l	d3,d1	; Load Y Velocity
	bpl.s	CalcBall_3B	; Branch If Positive
	neg.l	d1 	; Make It Positive
CalcBall_3B:
	add.l	d0,d1	; Add The Two Velocities
	cmp.l	#0x200,d1	; Check If Slow
	bge.s	CalcBall_3C	; Branch If not
	clr.l	d2	; Stop X Velocity
	clr.l	d3	; Stop Y Velocity
CalcBall_3C:
	neg.l	d7	; Make Z Velocity Positive Again
	asr.l	#1,d7	; Divide By Two
	clr.l	d6	; Clear Z Position
CalcBall_4:
	subq.w	#1,CalcTemp	; Decrement Time Count
	bne.s	CalcBall_1	; Continue Until Done
	bra.s	CalcBall_9

CalcBall_5:
	cmp.w	ThrowTime,d0	; Check If Parameter Greater Than Time
	bge.s	CalcBall_6	; Branch If It Was
	move.l	WORLDX(a1),d4	; Load X Position
	move.l	WORLDY(a1),d5	; Load Y Position
	move.w	d0,d1	; Save Copy Of Time In D1
	beq.s	CalcBall_9	; Exit If No Time
	muls	WORLDXVEL(a1),d0	; Multiply Time By Velocity
	add.l	d0,d4	; Add To X Position
	muls	WORLDYVEL(a1),d1	; Multiply Time By Velocity
	add.l	d1,d5	; Add To Y Position
	clr.l	d6	; No Z Position
	bra.s	CalcBall_9
CalcBall_6:
	move.l	B_GOALX(a1),d4	; Load Goal As X Position
	move.l	B_GOALY(a1),d5	; Load Goal As Y Position
	clr.l	d6	; No Z Position
	bra.s	CalcBall_9
CalcBall_7:
	move.l	WORLDX(a1),d4	; Load X Position
	move.l	WORLDY(a1),d5	; Load Y Position
	clr.l	d6	; No Z Position
CalcBall_9:
	rts

	.align	2
Anim_Color_Cycle:
	clr.w	d1
	clr.w	d2
     	move.b	(a0)+,d0	; Load palette
	move.b	(a0)+,d1	; Load start
        	move.b	(a0)+,d2	; Load number
        	move.b	(a0)+,d3	; Load ticks
	PUSHL	a0
	jsr	AddCycle	; Add The Color Cycle
	POPL	a0
	bra	Anim_4


	.export	Anim_JoySeq
Anim_JoySeq:
	trap	#1
	bsr	GetLong	; Get The Joystick Sequence Address
	clr.w	d1	; Clear Upper Byte Of Bit Number	
	move.b	(a0)+,d1	; Load Bit To Set On Sequence Found
	asl.w	#3,d1	; Multiply By Eight
	lea	JOYSEQDATA(a5),a1	; Load Address Of Data In Ramblock
	lea	(a1,d1.w),a1	; Load Address Of This Bit's Data
	move.l	d0,(a1)+	; Store Address Of Joystick Sequence
	clr.w	(a1)+	; Clear Index Into Sequence Array
	move.b	(a0)+,(a1)	; Load/Store Tick Count For Sequence
	bra	Anim_4

Anim_Shake:
	move.b	(a0)+,ShakeYDist	; Save Shake Amount
	move.b	(a0)+,d0
	move.b	#3,ShakeYPeriod	; Load Shake Period
	move.b	(a0)+,d0	; Load Total Shake Times
	move.b	ShakeYPeriod,ShakeYCnt	; Activate Shaking
	bra	Anim_4

Anim_SetZ:
	move.w	(a0)+,ZPOSITION(a5)	; Store Z Position
	bra	Anim_4


Anim_SetGrav:
	bsr	GetLong	; Get The Gravity Value
	move.l	d0,GRAVITY(a5)	; Store Gravity Value
	bra	Anim_4

Anim_SetVelY:
	move.w	(a0)+,d0
	neg.w	d0	; Make Y Velocity Negative
	move.w	d0,YVELOCITY(a5)	; Store Y Velocity
	move.b	(a0)+,d0	; Load The Dampen Byte
	bsr	SetDamp	; Set DAMP
	bra	Anim_4

Anim_FrameRate:
	move.w	(a0)+,d0
	move.w	d0,FrameRate	; Store The Frame Rate
	bra	Anim_4

Anim_Always:
	bsr	GetLong	; Get The Joystick Sequence Address
	move.l	d0,ALWAYSROUTINE(a5)	; Store Always Routine Address
	beq	Anim_4	; Branch If None Defined
	move.l	d0,a1	; Move Address To A1
	move.l	a0,PARSEPOINTER(a5)
	jsr	(a1)	; Execute The Routine
	move.l	PARSEPOINTER(a5),a0
	bra	Anim_4

Anim_BSnd:
	move.b	(a0)+,BOUNCESOUND(a5)	; Store The Bounce Sound
	bra	Anim_4

Anim_SetPal:
	move.b	(a0)+,PALETTE(a5)	; Set New Palette
	bra	Anim_4

Anim_End:
	move.l	a0,PARSEPOINTER(a5)	; Save Pointer To Animation Table
	rts

GetLong:
	clr.l	d0	; Clear D0 Register
	move.w	(a0)+,d0	; Load First Two Bytes
	rol.l	#8,d0	; Shift To Upper Byte
	or.b	(a0)+,d0	; Load Next Byte Of Address
	rts

	.export	SoundStage
SoundStage:
	rts

;***************************************************************************
;   SetDamp - Set The Dampen Effect		*
;				*
;   Parameters :  A5 - Pointer To Fighter's Ram Block	*
;	   D0 - Requested Damp		*
;   Returns:      NONE		*
;   Modifies:     D0			*
;***************************************************************************
SetDamp:
	tst.b	d0	; Check If Damp Is Zero
	bne.s	SetDamp_1	; Branch If It Isn't
	tst.b	ONGROUND(a5)	; Check If On Ground
	bne.s	SetDamp_1	; Branch If He Is
	move.b	#8,d0	; Set Damp To 8 If In Air
SetDamp_1:
	move.b	d0,DAMP(a5)	; Store Dampen
	rts

;****************************************************************************
;   Move - Move The Player                                                  *
;                                                                           *
;   Parameters :  NONE                                                      *
;   Returns:      NONE                                                      *
;   Modifies:     NONE                                                      *
;****************************************************************************
Move:
	tst.b	STATIONARY(a5)	; Check If Stationary
	bpl.s	Move_0	; Branch If It Is In World

	move.l	WORLDX(a5),d0	; Load X Position
	add.l	WORLDXVEL(a5),d0	; Add In  X Velocity
	move.l	d0,WORLDX(a5)	; Store New World Position

	move.l	WORLDY(a5),d1	; Load Y Position
	add.l	WORLDYVEL(a5),d1	; Add In Y Velocity
	move.l	d1,WORLDY(a5)	; Store New World Position

	move.l	WORLDZ(a5),d2	; Load Z Position
	add.l	WORLDZVEL(a5),d2	; Add In Z Velocity
	move.l	d2,WORLDZ(a5)	; Store New World Position
	bpl.s	Move__	; Branch If Above Ground
	clr.l	WORLDZ(a5)
	clr.l	WORLDZVEL(a5)
Move__:
	sub.l	#PGRAVITY,WORLDZVEL(a5)	; Add In Gravity Effect

	tst.b	OBJECTTYPE(a5)	; Check If Player
	bpl.s	MoveWorld_1	; Branch If Not
	tst.b	B_HASBALL(a5)	; Check If This Object Has Ball
	beq.s	MoveWorld_1	; Branch If Not

	move.l	#Baseball,a0	; Load Address Of Ball
	move.l	d0,WORLDX(a0)	; Force Ball To Object
	move.l	d1,WORLDY(a0)	; Force Ball To Object
MoveWorld_1:
	asr.l	#8,d1	; Extract Inches
	asr.l	#2,d1	; Extract 4" Increments
	add.w	#3*40,d1	; Add Forty Feet
	neg.w	d1	; Negate Result
	add.w	#0x7FFF,d1	; Add Big Number
	move.w	d1,ZPOSITION(a5)	; Store Object's Z Position

Move_0:
	tst.b	STATIONARY(a5)	; Check If Stationary
	bne	Move_9	; Branch If It Is

	move.w	XVELOCITY(a5),d2	; Load X Velocity
	ext.l	d2	; Extend The Sign
	move.w	YVELOCITY(a5),d3	; Load Y Velocity
	ext.l	d3	; Extend The Sign

	clr.l	d4
	move.w	YPOSITION(a5),d4	; Load Y Position	
	ext.l	d4	; Extend To A Long
	asl.l	#8,d4	; Shift Y Position Up 8
	clr.b	ONGROUND(a5)	; Set Off Ground
	move.b	YFRACTION(a5),d4	; Load Y Fractional Part
	cmp.l	GroundY,d4 	; Check If Standing On Ground
	bne.s	Move_1	; Branch If Not On Ground
	move.b	#1,ONGROUND(a5)	; Set On Ground
	tst.w	d3	; Check If Any Y Velocity
	beq	Move_5A	; Branch If No Velocity
Move_1:
	add.l	d3,d4	; Add Y Velocity To Y Position

	cmp.b	#8,DAMP(a5)	; Check If No Ground
	bge.s	Move_5	; Branch If There Isn't

	cmp.l	GroundY,d4	; Check If On Ground
	blt.s	Move_4	; Branch If Above Ground

Move_1A:
Move_1B:
	move.b	#1,ONGROUND(a5)	; Set On Ground
	move.l	GroundY,d4	; Force Player On Ground
	neg.l	d3	; Negate The Y Velocity
	move.b	DAMP(a5),d0	; Load The Dampen Byte
	bmi.s	Move_5	; Branch If No Dampen
	asr.l	d0,d3	; Dampen Out Y Velocity
	move.l	d3,temp
Move_2:
	cmp.w	#-0x100,d3	; Check If Velocity Less Than 3
	blo.s	Move_5	; Branch If Greater
	clr.l	d3	; Clear Y Velocity
	clr.l	d2	; Clear X Velocity
;	move.w	#1,DURATION(a5)	; Store 1 For Duration
Move_4:
	tst.b	DAMP(a5)	; Check If Gravity Is In Effect
	bmi.s	Move_5	; Branch If No Gravity

	add.l	GRAVITY(a5),d3	; Add In Gravity Effect

	bne.s	Move_5	; Branch If Velocity Is Non-Zero
	addq.l	#1,d3	; Make Velocity 1
Move_5:
	move.b	d4,YFRACTION(a5)	; Store Y Fractional Part
	asr.l	#8,d4	; Shift Y Position
	move.w	d4,YPOSITION(a5)	; Store New Y Position
	move.w	d3,YVELOCITY(a5)	; Store New Y Velocity
	move.w	d2,XVELOCITY(a5)	; Store New X Velocity
	bra.s	Move_6
Move_5A:
	asr.l	#8,d4	; Shift Y Position
Move_6:
	tst.w	d2	; Check If X Velocity
	beq.s	Move_9	; Exit If No X Velocity
	clr.l	d0	; Clear D0
	move.w	XPOSITION(a5),d0	; Load X Position
	asl.l	#8,d0	; Shift Into Position
	move.b	XFRACTION(a5),d0	; Load Fractional Part
	add.l	d2,d0	; Add In X Velocity
	move.b	d0,XFRACTION(a5)	; Save Fractional Part
	asr.l	#8,d0	; Shift Out X Position
	move.w	d0,XPOSITION(a5)	; Save New X Position
	cmp.w	GroundY2,d4	; Check If On Ground
	blt.s	Move_9	; Branch If Above Ground
	tst.w	d3	; Check If Any Y Velocity
	beq.s	Move_6A	; Use Friction In No Y Velocity
	tst.b	DAMP(a5)	; Check If Any Dampening
	bne.s	Move_9	; Branch If Dampened
Move_6A:
	tst.w	d2	; Check X Velocity For Direction
	bpl.w	Move_7	; Branch If Positive
	add.w	#FRICTION,d2	; Add In Friction
	bmi.w	Move_8	; Branch If Still Negative
	clr.w	d2	; Clear X Velocity
	bra.s	Move_8
Move_7:
	sub.w	#FRICTION,d2	; Subtract Off Friction
	bpl.w	Move_8	; Branch If Still Positive
	clr.w	d2	; Clear X Velocity
Move_8:
	move.w	d2,XVELOCITY(a5)	; Store New X Velocity
Move_9:
	rts

;***************************************************************************
;   CheckSeeking - Check If Seeking A Position		*
;                                                                          *
;   Parameters :  NONE                                                     *
;   Returns:      NONE                                                     *
;   Modifies:     NONE                                                     *
;***************************************************************************
CheckSeeking:
	tst.b	OBJECTTYPE(a5)	; Check If Player Object Type
	bpl.s	ChkSeek_9	; Exit If Not Player
	tst.l	B_SEEKING(a5)	; Check If Seeking A Position
	beq.s	ChkSeek_9	; Branch If Not
	sub.l	#0x100,B_SEEKING(a5)	; Decrement Seeking Count
	bpl.s	ChkSeek_9
;	move.l	B_GOALX(a5),WORLDX(a5)	; Force X Position
;	move.l	B_GOALY(a5),WORLDY(a5)	; Force Y Position
	move.l	B_GOALPP(a5),PARSEPOINTER(a5) ; Set To Ending Parse Pointer
	clr.w	DURATION(a5)	; Start Up Animation
	clr.l	WORLDXVEL(a5)	; Stop X Velocity
	clr.l	WORLDYVEL(a5)	; Stop Y Velocity
	clr.l	B_SEEKING(a5)	; Clear Seeking
ChkSeek_9:
	rts

;****************************************************************************
;   JoyWatch - Monitor Joysticks And Buttons For Changes                    *
;                                                                           *
;   Parameters :  NONE                                                      *
;   Returns:      NONE                                                      *
;   Modifies:     NONE                                                      *
;****************************************************************************
InitJoyWatch:
	SWITCH	#FIRSTBASE1,#81H,#FirstBase1
	SWITCH	#SECONDBASE1,#81H,#SecondBase1
	SWITCH	#THIRDBASE1,#81H,#ThirdBase1
	SWITCH	#HOMEPLATE1,#81H,#HomePlate1

	SWITCH	#FIRSTBASE2,#81H,#FirstBase2
	SWITCH	#SECONDBASE2,#81H,#SecondBase2
	SWITCH	#THIRDBASE2,#81H,#ThirdBase2
	SWITCH	#HOMEPLATE2,#81H,#HomePlate2
	rts

JoyWatch:
	move.l	#PlayerL,a5	; Load Address Of Left Player
	move.l	#PlayerR,a6	; Load Address Of Right Player
	bsr	JoySub	; Read The Joystick/Buttons

	move.l	#PlayerR,a5	; Load Address Of Right Player
	move.l	#PlayerL,a6	; Load Address Of Left Player
	bsr	JoySub	; Read The Joystick/Buttons

	tst.b	COMPUTER(a6)	; Check If Computer Player
	bne.s	JoyWatch_1	; Branch If It Is
	move.b	PLYRIN1,d0	; Load Player Controls
	lsr.b	#2,d0	; Shift Down Buttons
	and.b	#3,d0	; Extract Button Bits
	move.b	PLYRIN3,d1	; Load Other Buttons
	lsl.b	#2,d1	; Shift Up Two Bits
	or.b	#0xA8,d1	; Extract Upper Bits
	or.b	d1,d0	; Or Together Buttons
	eor.b	#0xFF,d0	; Invert The Switches
	move.b	d0,RAWBUTTONS(a6)	; Store Raw Buttons

	move.w	#BUTTON1_5,d0	; Load Switch Number For Power Up
	jsr	SwitchState	; Determine Switch State
	move.b	d0,POWERUP(a6)	; Store Powerup Value
JoyWatch_1:

	tst.b	COMPUTER(a5)	; Check If Computer Player
	bne.s	JoyWatch_2	; Branch If It Is
	move.b	PLYRIN2,d0	; Load Player Controls
	lsr.b	#2,d0	; Shift Down Buttons
	and.b	#3,d0	; Extract Button Bits
	move.b	PLYRIN3,d1	; Load Other Buttons
	lsl.b	#1,d1	; Shift Up One Bits
	and.b	#0xFC,d1	; Extract PLayer 2 Bits
	or.b	#0xA8,d1	; Extract Upper Bits
	or.b	d1,d0	; Or Together Buttons
	eor.b	#0xFF,d0	; Invert The Switches
	move.b	d0,RAWBUTTONS(a5)	; Store Raw Buttons

	move.w	#BUTTON2_5,d0	; Load Switch Number For Power Up
	jsr	SwitchState	; Determine Switch State
	move.b	d0,PlayerR+POWERUP	; Store Powerup Value
JoyWatch_2:
	rts

	.export	JoySub
JoySub:
	tst.b	COMPUTER(a5)	; Check If Computer Player
	beq.s	JoySub_0	; Branch If It Isn't
	jsr	AI	; Process AI
JoySub_0:
	lea	STARTBUTTON(a5),a0	; Load Address Of Start Button
	clr.w	d0	; Clear Button Mask
	move.w	#5,d1	; Five Buttons To Check
JoySub_1:
	asl.b	#1,d0	; Shift Over Mask
	tst.b	(a0)+	; Check If Button Set
	beq.s	JoySub_2	; Branch If Not
	subq.b	#1,-1(a0)	; Decrement Counter
	or.b	#1,d0	; Flag The Button
JoySub_2:
	subq.w	#1,d1	; Decrement Counter
	bne.s	JoySub_1	; Continue Until Done
JoySub_3:
	asl.b	#2,d0	; Shift Into Position
	move.b	d0,BUTTONS(a5)	; Pass Buttons On To Player
	bne.s	JoySub_4	; Branch If Not Buttons
	clr.b	NEWBUTTON(a5)
JoySub_4:
	tst.b	COMPUTER(a5)	; Check If Computer Player
	bne.s	JoySub_5	; Branch If It Is
	bsr	CheckSeq	; Check Player Sequence
JoySub_5:
	rts

;***************************************************************************
;  Player 1 Controls 
;***************************************************************************
	.export	ButtonSelect1
ButtonSelect1:
	lea	PlayerL,a0	; Load Address Of Player 1
	tst.b	START(a0)	; Check If Computer Player
	beq.s	ButSel1_1	; Branch If It Is
	move.b	BUTTONCOUNT(a0),STARTBUTTON(a0)
ButSel1_1:
	move.b	#1,d0
	bra	NewButton1

FirstBase1:
	lea	PlayerL,a0	; Load Address Of Player 1
	tst.b	START(a0)	; Check If Computer Player
	beq.s	FirstBase1_1	; Branch If It Is
	move.b	BUTTONCOUNT(a0),FIRSTBUTTON(a0)
FirstBase1_1:
	move.b	#2,d0
	bra.s	NewButton1

SecondBase1:
	lea	PlayerL,a0	; Load Address Of Player 1
	tst.b	START(a0)	; Check If Computer Player
	beq.s	SecondBase1_1	; Branch If It Is
	move.b	BUTTONCOUNT(a0),SECONDBUTTON(a0)
SecondBase1_1:
	move.b	#3,d0
	bra.s	NewButton1

ThirdBase1:
	lea	PlayerL,a0	; Load Address Of Player 1
	tst.b	START(a0)	; Check If Computer Player
	beq.s	ThirdBase1_1	; Branch If It Is
	move.b	BUTTONCOUNT(a0),THIRDBUTTON(a0)
ThirdBase1_1:
	move.b	#4,d0
	bra.s	NewButton1

HomePlate1:
	lea	PlayerL,a0	; Load Address Of Player 1
	tst.b	START(a0)	; Check If Computer Player
	beq.s	HomePlate1_1	; Branch If It Is
	move.b	BUTTONCOUNT(a0),HOMEBUTTON(a0)
HomePlate1_1:
	move.b	#5,d0
;	bra.s	NewButton1

NewButton1:
	move.b	d0,NEWBUTTON(a0)
	rts

;***************************************************************************
;  Player 2 Controls 
;***************************************************************************
	.export	ButtonSelect2
ButtonSelect2:
	lea	PlayerR,a0	; Load Address Of Player 2
	tst.b	START(a0)	; Check If Computer Player
	beq.s	ButSel2_1	; Branch If It Is
	move.b	BUTTONCOUNT(a0),STARTBUTTON(a0)
ButSel2_1:
	move.b	#1,d0
	bra	NewButton1

FirstBase2:
	lea	PlayerR,a0	; Load Address Of Player 2
	tst.b	START(a0)	; Check If Computer Player
	beq.s	FirstBase2_1	; Branch If It Is
	move.b	BUTTONCOUNT(a0),d0
	move.b	d0,FIRSTBUTTON(a0)
FirstBase2_1:
	move.b	#2,d0
	bra	NewButton1

SecondBase2:
	lea	PlayerR,a0	; Load Address Of Player 2
	tst.b	START(a0)	; Check If Computer Player
	beq.s	SecondBase2_1	; Branch If It Is
	move.b	BUTTONCOUNT(a0),SECONDBUTTON(a0)
SecondBase2_1:
	move.b	#3,d0
	bra	NewButton1

ThirdBase2:
	lea	PlayerR,a0	; Load Address Of Player 2
	tst.b	START(a0)	; Check If Computer Player
	beq.s	ThirdBase2_1	; Branch If It Is
	move.b	BUTTONCOUNT(a0),THIRDBUTTON(a0)
ThirdBase2_1:
	move.b	#4,d0
	bra	NewButton1

HomePlate2:
	lea	PlayerR,a0	; Load Address Of Player 2
	tst.b	START(a0)	; Check If Computer Player
	beq.s	HomePlate2_1	; Branch If It Is
	move.b	BUTTONCOUNT(a0),HOMEBUTTON(a0)
HomePlate2_1:
	move.b	#5,d0
	bra	NewButton1

ClearButtons:
	clr.b	d0	; Clear D0
	clr.b	BUTTONS(a6)	; Clear Buttons Byte
	clr.b	FIRSTBUTTON(a6)	; Clear Jab Button
	clr.b	SECONDBUTTON(a6)	; Clear Strong Button
	clr.b	THIRDBUTTON(a6)	; Clear Fierce Button
	clr.b	HOMEBUTTON(a6)	; Clear Short Button
	clr.b	STARTBUTTON(a6)	; Clear Roundhouse Button
	rts

;***************************************************************************
;   CheckSeq - Check For Button Input Sequences		*
;				*
;   Parameters :  NONE		*
;   Returns:      NONE		*
;   Modifies:     NONE		*
;***************************************************************************
	.export	CheckSeq
CheckSeq:
	move.b	RAWBUTTONS(a5),d2	; Load Buttons Value
	lea	JOYSEQDATA(a5),a3	; Index To Joystick Sequences
	move.l	#SpecialJoySeq,a4	; Load Address Of Sequences
CheckS_1:
	move.l	(a4),d0	; Load Buttons Sequence Value
	bmi	CheckS_6	; Branch If All Done
	move.l	d0,a0	; Move To An Address Register
	clr.w	d1	; Clear D1
	move.b	(a3),d1	; Load Sequence Index
	move.b	d1,d3	; Save In D3
	move.b	RAWBUTTONS(a5),d2	; Load Buttons Value
	and.b	(a0,d1.w),d2	; Extract Interesting Bits
	addq.w	#1,d1	; Increment Sequence
	cmp.b	(a0,d1.w),d2	; Check If Desired Buttons Value
	bne.s	CheckS_2	; Branch If Not A Good One
	addq.w	#1,d1	; Increment Sequence
	move.b	d1,(a3)	; Store New Value
	cmp.b	#0xFF,(a0,d1.w)	; Check If Done
	beq.s	CheckS_3	; Branch If All Done 
CheckS_2:
	cmp.b	#2,d3	; Check If Looking For Second Value
	bne.s	CheckS_2C	; Branch If Not
	move.b	RAWBUTTONS(a5),d2	; Load Buttons Value
	and.b	(a0),d2	; Extract First Interesting Bits
	cmp.b	1(a0),d2	; Check If First Desired Buttons Value
	beq.s	CheckS_5	; Branch If It Is
CheckS_2C:
	addq.b	#1,1(a3)	; Increment Tick Count
	move.b	5(a4),d0	; Load Time Limit
	cmp.b	1(a3),d0	; Check If Out Of Time
	beq.s	CheckS_4	; Branch If Time Up
	bra.s	CheckS_5
CheckS_3:
	move.l	6(a4),a0	; Load Address Of Routine
	jsr	(a0)	; Execute Routine
CheckS_4:
	clr.b	(a3)	; Restart Sequenece
	clr.b	1(a3)	; Clear Timer
CheckS_5:
	lea	10(a4),a4	; Index To Next Sequence
	lea	2(a3),a3	; Index To Next Sequence
	bra	CheckS_1	; Branch If More Bits
CheckS_6:
	rts

TrapIt:
	trap	#1
	rts

;***************************************************************************
;***************************************************************************
ClearJoySeq:
	lea	JOYSEQDATA(a5),a1	; Load Address Of Player Data
	clr.l	d0	; Clear D0
	move.w	#28,d1	; 96+16 Bytes To Clear
ClrJoyS_1:
	move.l	d0,(a1)+	; Restart Sequence
	subq.w	#1,d1	; Decrement Counter
	bne.s	ClrJoyS_1	; Continue Until Done
	rts


	end




