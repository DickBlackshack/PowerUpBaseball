;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.                          *
;                    (C) COPYRIGHT 1995, IT, INC.                          *
;***************************************************************************

;IMP: External system processes.

	.import	MainProcess
	.import	ClrLines
	.import	TogglePage
	.import	AI,AIInit
	.import	SetSysFont,LoadExceptPal
	.import	Write_to_pic,Read_from_pic,Test_pic_reslt
	.import	ReadTrackball

;import variables	
	.export.s	S_PLN1YTP,S_PLN1XTP
	.import	coin_pro,user_serv_active ;from main.asm
	.import	InitQueue,DoNextICmd
	.import.s Mode1
	.import.s S_Mode1,S_IntMask,ScreenInvert2
	;,S_Plane,N_Plane
	.import	DClear
	.import.s PageLine
	.import.s	prx_coor,pry_coor,font_width
	.import.s	SoundsOff

;EXP: variables
	.export.s VBMask
	.export	AddCycle
	.export.s VBFlag,FrameCount
	.export	ProcessTime,CycleData

	.export	Delay
	.export	Spawn
	.export	SetSwitch
	.export	SetProcess
	.export	Exterminate
	.export	OnDeath
	.export	SendSound,SendSound3
	.export	Random
	.export	SwitchState
	.export	InitCycle

	.export	ASIC_XINT
	.export	ASIC_QINT
	.export	VINT_INT

	.export.s Toggle_Flag,Next_Display,Clear_Flag,Timing_Flag,last_cmd
	.export.s board_test_flag
	.export.s pictest,picbyte1,picbyte2,picbyte3,cpunum0,cpunum1,cpunum2

	#include	"itvideo2.h"
	#include	"sys.h"
	#include	"graphglb.h"
	#include	"graphlib.h"
	#include	"graphlib.mac"
	#include	"ramblock.h"

MAX_CYCLES	equ	24	; Number Of Color Cycling
;
; Clipping Values
;
C_BOTSCR	equ 256			; 7 -x------ Player 1 Down  
C_RGTSCR	equ 384			; 7 -x------ Player 1 Down  

BOTSCR	equ 256			; 6 --x----- Player 1 Left

;****************************************************************
;	     Ram Region
;****************************************************************
	.region.s "RAM"
	.export	rnd1,rnd2,rnd3,memory_status,NewSwitch

	ds	0
memory_status ds.w	1
S_PLN1YTP	ds.w	1
S_PLN1XTP	ds.w	1
rnd_cnt	ds.b	1
snd_pull	ds.b	1
snd_push	ds.b	1
snd_queue	ds.b	64

; 
;Operating system locations.
;
	ds	0	; aligned at even boundary
ProcessTime	ds.w	1	; Process Timer
ExtermCount	ds.b	1	; Number Of Processes Killed Last Time

SwitchCnt	ds.w	1	; Number Of Debounced Switches

NewSwitch	ds.b	48	; Debounced Switch

System	ds.b	1	; System Code vs Process
Switches	ds.w	3	; Switch Data Area
NSwitches	ds.w	3

	ds	0	; force alignment
SwitchData	ds.b	6*48	; Switch Area (32 switches)	  

	ds	0	;align on an even boundary
Process	ds.b	ProcessMax*ProcessLen	; Process Area (512 bytes)

	.export PreviousProc,InactiveList,CurrentProc,SystemStack
	.export excep_addr,exception_num

PreviousProc  ds.l	1	; Previously Active Proc
InactiveList  ds.l	1	; Inactive Process List
CurrentProc   ds.l	1	; Current Process
SystemStack   ds.l	1	; System Stack Address
;
; exception handling variables
;
	.export	exception_num
exception_num	ds.w	1	; processor exception number
excep_sr	ds.w	1	; processor status register
excep_addr	ds.l	1	; exception address
excep_pc	ds.l	1	; exception program counter
excep_registers ds.l	16	; dump of processor registers
reg_number	ds.w	1
dump_address	ds.l	1	; address of memory block to dump
dump_scale	ds.l	1	; amount to change memory address by
printhex_temp	ds.l	1
prx_save	ds.w	1
pry_save	ds.w	1

VBFlag	ds.b	1	; Vertical Blank Flag
ExtermTemp	ds.b	1	; Exterminate Counter
VBMask	ds.b	1
VBLANKcount	ds.b	1

board_test_flag ds.b	1

	.align	2
rnd1	ds.b	1
rnd2	ds.b	1
rnd3	ds.b	1

	.align	4
ITemp	ds.l	1
CycleData	ds.w	(MAX_CYCLES+1)*4	; Color Cycle Information

Next_Display	ds.w	1
Display_Count	ds.w	1
Toggle_Flag	ds.b	1
Clear_Flag	ds.b	1
Timing_Flag	ds.b	1
QFlag	ds.b	1

last_cmd	ds.w	1
vbcount	ds.w	1
FrameCount	ds.w	1
CurFrameCount	ds.w	1

HLineIndex	ds.w	1	

VertFlag	ds.b      1 

;pic variables
pictest	ds.b	1
picbyte1	ds.b	1
picbyte2	ds.b	1
picbyte3	ds.b	1
cpunum0	ds.b	1
cpunum1	ds.b	1
cpunum2	ds.b	1
bdummy 	ds.b	1	; for bad align ???

HLineInts	ds.w	8	; (BOTSCR-1)/3,(2*(BOTSCR-1))/3,BOTSCR-1,0
botscr	ds.w	1

WatchDoggy	ds.w	1

;***************************************************************************
;				*
; POWER-UP VECTORS			*
;				*
;***************************************************************************
	.region	"Vectors"
vectors:
	DC.L	STACK	; 0 Initial 0 Supervisor Stack Ptr value
	DC.L	Reset	; 1 Initial 1 PC value
	DC.L	bad_trap	; 2 bus error
	DC.L	addr_trap	; 3 address error (unaligned word xfer)
	DC.L	illegal_trap	; 4 illegal instr
	DC.L	zero_trap	; 5 zero divide
	DC.L	misc_trap	; 6 CHK instruction
	DC.L	misc_trap	; 7 TRAPV instruction
	DC.L	misc_trap	; 8 priviledge violation
	DC.L	misc_trap	; 9 trace
	DC.L	illegal_trap	; 10 line 1010 emulator
	DC.L	illegal_trap	; 11 line 1111 emulator
	DC.L	bad_trap	; 12 Unused
	DC.L	bad_trap	; 13 Unused
	DC.L	bad_trap	; 14 Format Error
	DC.L	bad_trap	; 15 uninitialized interrupt vector
	DC.L	bad_trap	; 16 Unused
	DC.L	bad_trap	; 17 
	DC.L	bad_trap	; 18 
	DC.L	bad_trap	; 19 
	DC.L	bad_trap	; 20 
	DC.L	bad_trap	; 21
	DC.L	bad_trap	; 22 
	DC.L	bad_trap	; 23 
	DC.L	bad_trap	; 24  spurious interrupt

	DC.L	int_trap	; 25  Level 4 IRQ - (Unused)
	DC.L	ASIC_XINT	; 26  Level 2 IRQ - XINT
	DC.L	ASIC_QINT	; 27  Level 3 IRQ - QINT
	DC.L	VINT_INT	; 28  Level 1 IRQ - VBLANK
	DC.L	int_trap	; 29  Level 5 IRQ - (Unused)
	DC.L	int_trap	; 30  Level 6 IRQ - (Unused)
	DC.L	int_trap	; 31  Level 7 IRQ - (Unused) (NMI)

	DC.L	misc_trap	; 32  TRAP 0
	DC.L	misc_trap	; 33  TRAP 1
	DC.L	bad_batter_trap	; 34  TRAP 2
	DC.L	misc_trap	; 35  TRAP 3
	DC.L	misc_trap	; 36  TRAP 4
	DC.L	misc_trap	; 37  TRAP 5
	DC.L	misc_trap	; 38  TRAP 6
	DC.L	misc_trap2	; 39  TRAP 7
	DC.L	misc_trap	; 40  TRAP 8
	DC.L	misc_trap	; 41  TRAP 9
	DC.L	misc_trap	; 42  TRAP 10
	DC.L	misc_trap	; 43  TRAP 11
	DC.L	misc_trap	; 44  TRAP 12
	DC.L	misc_trap	; 45  TRAP 13
	DC.L	misc_trap	; 46  TRAP 14
	DC.L	misc_trap	; 47  TRAP 15

	DC.L	bad_trap	; 48  UNASSIGNED
	DC.L	bad_trap	; 49  UNASSIGNED
	DC.L	bad_trap	; 50  UNASSIGNED
	DC.L	bad_trap	; 51  UNASSIGNED
	DC.L	bad_trap	; 52  UNASSIGNED
	DC.L	bad_trap	; 53  UNASSIGNED
	DC.L	bad_trap	; 54  UNASSIGNED
	DC.L	bad_trap	; 55  UNASSIGNED
	DC.L	bad_trap	; 56  UNASSIGNED
	DC.L	bad_trap	; 57  UNASSIGNED
	DC.L	bad_trap	; 58  UNASSIGNED
	DC.L	bad_trap	; 59  UNASSIGNED
	DC.L	bad_trap	; 60  UNASSIGNED
	DC.L	bad_trap	; 61  UNASSIGNED
	DC.L	bad_trap	; 62  UNASSIGNED
	DC.L	bad_trap	; 63  UNASSIGNED
vectors_end:

	.region	"RomCode"
	ds	0
;***************************************************************************
; Reset() - Initialize system hardware.		*
;				*
; Parameters: NONE			*
; Returns: NONE			*
; Uses: d0,a0,a1			*
;***************************************************************************
	.export	Reset
	.export	jreset
	.export	dump_address
Reset:	
	ori	#DIRQ,SR	; Disable Interrupts
	move.l	#0,dump_address	;init memory dump pointer

	jmp	quick_memory_test	; check if memory is ok
jreset:
	move.w	d0,d6	; save results

	move.l	#vectors,a0	; source of copy
	move.l	#0,a1	; destination to copy to
Reset_2:
	KICK_DOG
	move.l	(a0)+,(a1)+	; Copy a vector
	cmp.l	#vectors_end,a0	; Done?
	blt.s	Reset_2	; No, loop and copy some more

;Fill ram
	movea.w	 #$400,a0
init_ram:
	move.b	 #$00,(a0)+
	KICK_DOG
	cmp.l	 #$7c00,a0
	blt.s	 init_ram

	move.w	d6,memory_status	; results of quick memory tests

;**************************************************************
; check START1 for power up board test
;**************************************************************
	move.b	PLYRIN1,d0
	not.w	d0
	andi.b	#$02,d0
	beq.s	jreset2		;LJH
	move.b	#1,board_test_flag
	bra	jreset3
jreset2
	move.b	#0,board_test_flag
jreset3:
;**************************************************************

;**************************************************************
	jsr	InitSystem	; Reset entire machine

	.export	MainLoop
MainLoop:
	move.b	#1,System	; Set To System Status
			; This Is System Code
	jsr	Switch	; Process Switch
	clr.b	System	; This Is Not System Code
	jsr	Processes	; Execute EveryThing
	clr.w	WatchDoggy	; Watch Dog Satisfied
	
	KICK_DOG

	bra	MainLoop

;***************************************************************************
;   ProcSounds - Handle The Sound Queue		*
;				*
;   Parameters :  NONE			*
;   Returns:      NONE			*
;   Modifies:     NONE			*
;***************************************************************************
	.export	ProcSounds
ProcSounds:
	clr.w	d0	; Clear Upper Byte Of D0
	move.b	snd_pull,d0	; Load Top Of Sound Queue
	cmp.b	snd_push,d0	; Compare With Bottom Of Sound Queue
	beq	ProcSnd_1	; Branch If Nothing In The Queue
	lea	snd_queue,a0	; Load Sound Queue Addrress
	and.w	#00ffh,d0
	move.b	(0,a0,d0.w),SOUND	; Load Element From Sound Queue
	add.b	#1,d0	; Increment Queue Pointer
	and.b	#31,d0	; Limit Queue Pointer To 0-31
	move.b	d0,snd_pull	; Save Sound Queue Top
ProcSnd_1:
	add.b	#1,rnd_cnt	; Mess With Random Number
	rts

	.export	ReadSwitches,Switches,NSwitches
ReadSwitches:
	clr.l	d0
	move.b	PLYRIN3,d0	; Load Next Byte Of Ports
	lsl.l	#8,d0	; Shift Into Position
	move.b	PLYRIN2,d0	; Load Next Byte Of Ports
	lsl.l	#8,d0	; Shift Into Position
	move.b	PLYRIN1,d0	; Load Next Byte Of Address
	eori.l	#0xFFFFFFFF,d0	; Invert All Input Bits
	move.l	d0,NSwitches	; Save New Switches

	clr.l	d0
;	move.b	SWITCHE,d0	; Load High Byte Of Ports
;	rol.l	#8,d0	; Shift To Upper Byte
	move.b	DIPS,d0	; Load Next Byte Of Ports
	eori.w	#0xFFFF,d0	; Invert All Input Bits
	move.w	d0,NSwitches+4

ReadSwitch_1:
	move.l	NSwitches,d0	; Load New Switches
	move.l	Switches,d1	; Load Last Switch Values
	eor.l	d0,d1	; Determine Which Bits Changed
	beq	ReadSwitch_6	; Branch If Value Not Changed
	move.l	d0,Switches	; Save New Switch Values
	clr.l	d0	; Clear Switch Number
ReadSwitch_2:
	addq.b	#1,d0	; Add One To Switch Number
	lsr.l	#1,d1	; Rotate Change Mask
	bcc	ReadSwitch_2	; Branch If Not Right Bit

	move.l	#NewSwitch,a1	; Load Address Of Switch Changes
	move.w 	SwitchCnt,d2	; Load Number Of Switches
	move.b	d0,(a1,d2.w)	; Save Switch Number
	addq.w	#1,SwitchCnt	; Increment Switch Count
ReadSwitch_5:
	tst.l	d1	; Check For More Changes
	bne	ReadSwitch_2

ReadSwitch_6:
	move.w	NSwitches+4,d0	; Load new Switch Values
	move.w	Switches+4,d1	; Load Last Switch Values
	eor.w	d0,d1	; Determine Which Bits Changed
	beq	ReadSwitch_F	; Branch If Value Not Changed
	move.w	d0,Switches+4	; Save New Switch Values
	move.w	#32,d0	; Set To Second Bank Of Switches
ReadSwitch_7:
	addq.b	#1,d0	; Add One To Switch Number
	lsr.l	#1,d1	; Rotate Change Mask
	bcc	ReadSwitch_7	; Branch If Not Right Bit

	move.l	#NewSwitch,a1	; Load Address Of Switch Changes
	move.w 	SwitchCnt,d2	; Load Number Of Switches
	move.b	d0,(a1,d2.w)	; Save Switch Number
	addq.w	#1,SwitchCnt	; Increment Switch Count
ReadSwitch_9:
	tst.w	d1	; Check For More Changes
	bne	ReadSwitch_7

ReadSwitch_F:
	rts		; Done debouncing.

;****************************************************************************
;	return ramdom from 0-255 in d0		      *
;	uses d0 and d1			       *
;********************************************************
	.export	Random
Random:
	clr.l	d0
	move.b	rnd3,d0
	roxl.b	#4,d0
	move.b	rnd3,d1
	eor.b	d1,d0
	roxl.b	#1,d0

	move.b	rnd1,d0
	roxr.b	#1,d0
	move.b	d0,rnd1
	move.b	rnd2,d0
	roxr.b	#1,d0
	move.b	d0,rnd2
	move.b	rnd3,d0
	roxr.b	#1,d0
	move.b	d0,rnd3
	add.b	rnd_cnt,d0	;add in ramdom IRQ cnt
	rts

init_rnd:
	move.b	#1,rnd1
	move.b	#10,rnd2
	move.b	rnd_cnt,rnd3
	rts

Init_pic:
	clr.l	d0
	move.b	d0,cpunum0
	move.b	d0,cpunum1
	move.b	d0,cpunum2
	move.b	d0,pictest
;set_seed
	move.b	#01H,d0		; The seed should be treated
	move.b	d0,picbyte1	; as 3 sepparate bytes, never
	move.b	d0,picbyte2	; to be zero or $FF.
	move.b	d0,picbyte3

	jsr	Write_to_pic
	rts

;********************************************************
;	setup this version of the 68000		      *
;********************************************************
init_68000:
	move.w	#1,d0
;;	move.w	#0,d0	; turn off cache
	movec	d0,cacr	;enable the cache
	rts
;****************************************************************************
;   InitProcess - Initialize All Processes	 	*
;****************************************************************************
	.export	InitProcess
InitProcess:
	move.l	#MainProcess,(Process+Stack-2)     ; Load Address Of Main Process
			                 ; Store Into Process Stack

	move.l	#(Process+Stack-2),(Process+StackAdr) ;Load Initial Stack Position
	move.l	#Process,CurrentProc               ; Start With Root Process Set Initial Process List
	clr.w	Process+DelayCount                 ; Zero Initial Delay Factor
	clr.l	((Process+((ProcessMax-1)*ProcessLen))+NextProc) ; List Terminator
	clr.l	(Process+NextProc)
	clr.w	ProcessTime	                 ; Zero Processor Timer

	move.l	#(Process+ProcessLen),a0
	move.l	a0,InactiveList	; Initialize Inactive List
	move.l	#(Process+(2*ProcessLen)),a1
InitProc_1:
	move.l	a1,NextProc(a0)
	clr.w	DelayCount(a0)	; Zero Delay Value

	move.l	a1,a0	;next process address now in a0
	add.l	#ProcessLen,a1	;now a1 points to the next one again
	cmp.l	#(Process+((ProcessMax-1)*ProcessLen)),a0
	bne	InitProc_1
	rts

;****************************************************************************
;   InitSwitches - Initialize Switches Info		 *
;****************************************************************************
	.export	InitSwitches
InitSwitches:
	move.l	#SwitchData,a0	; Load Address Of Switch Data
	move.b	#48,d0
InitSwitch_1:
	move.b	#2,(a0)	; Force To Bad Data
	lea	6(a0),a0	; add 6 to the address in a0
	subq.b	#1,d0
	bne.s	InitSwitch_1

	clr.l	d0
	move.b	PLYRIN4,d0	; Load High Byte Of Ports
	rol.l	#8,d0	; Shift To Upper Byte
	or.b	PLYRIN3,d0	; Load Next Byte Of Ports
;trk	and.b	#01110111b,d0	; jeff - mask off unused inputs
	rol.l	#8,d0	; Shift To Upper Byte
	or.b	PLYRIN2,d0	; Load Next Byte Of Address
	rol.l	#8,d0	; Shift To Upper Byte
	or.b	PLYRIN1,d0	; Load Next Byte Of Address
	eori.l	#0xFFFFFFFF,d0	; Invert The Bits
	move.l	d0,Switches	; Store Initial Switch Values
	clr.l	d0
	move.b	SWITCHE,d0	; Load next Byte of Ports
	rol.l	#8,d0	; Shift up
	or.b	DIPS,d0	; last byte
	eori.w	#0xffff,d0	; Invert the bits
	move.w	d0,Switches+4	; store initial switch values

	clr.w	SwitchCnt	; No Switches Debounced
	rts

;****************************************************************************
;   SpawnProcess - Spawn A Process			 *
;	d0.w = ID, a0.l = address			  *
;	uses a0,a1,a2,d0,d1			  *
;****************************************************************************
	.export	SpawnProcess
SpawnProcess:
	tst.l	InactiveList	; Load First Element Of Inactive List
	beq.s	Spawn_End	; Exit If Not Available
	move.l	InactiveList,a1	; Move To A1
SpawnPro_2:
	move.l	NextProc(a1),InactiveList ; Save Inactive Pointer
	move.l	#Terminate,(Stack-2,a1)	; Set Return Address
	move.l	a0,Stack-6(a1)	; New Process Address
	lea	Stack-6(a1),a0	; add stack-6 + a1 and put in a0
	move.l	a0,StackAdr(a1)	; Store stack pointer address

	move.l	CurrentProc,a2	; Load Current Process Pointer
	move.l	NextProc(a2),NextProc(a1) ; Save Pointer To Next Process

	tst.w	d0	; Test new ID number
	bne	SpawnPro_3	; Branch If Non-Zero
	move.w	ProcessID(a2),d0	; Get current process ID
	add.w	#100,d0	; Create Child Process ID
SpawnPro_3:
	move.w	d0,ProcessID(a1)

	clr.w	Priority(a1)	; Zero Priority
	clr.l	OnDeathAdr(a1)	; Zero On Death Address
	clr.w	DelayCount(a1)	; Zero Delay Value
	move.l	a1,NextProc(a2)	; Save Pointer To Next Process
Spawn_End:
	rts

;****************************************************************************
;   Processes - Execute Processes			 *
;****************************************************************************
	.export	Processes
Processes:
	move.l	CurrentProc,a0	; Load Address Of Current Process
	tst.w	DelayCount(a0)	; Check If Delaying
	beq.s	Process_2	; Branch If Not Delaying
	move.w	ProcessTime,d1	; Load Process Time
	move.w	LastTime(a0),d0	; Load Last Time Value	 
	move.w	d1,LastTime(a0)	; Save Last Update Time
	sub.w	ProcessTime,d0	; Subtract Current Time
	beq.s	Process_End	; Branch If No Time Change
	add.w	DelayCount(a0),d0	; Add Delay Value
	bcs.s	Process_1	; Branch If Time Delay Not Over
	clr.w	d0
Process_1:
	move.w	d0,DelayCount(a0)	; Store New Delay Count
	bra.s	Process_End
Process_2:
	move.l	sp,SystemStack	; Save System Stack Address

	move.l	CurrentProc,a0	; Load Address Of Current Process
	move.l	StackAdr(a0),sp	; Load Stack Pointer
	rts		; Execute Process

Process_End:
	move.l	a0,PreviousProc	; Save Previous Process Pointer
	move.l	NextProc(a0),a0	; Load Pointer To Next Process
	cmp.l	#0,a0
	bne.s	ProcEnd_3	; Branch If Not End Of List
	move.l	#Process,a0	; Load Start Of List
ProcEnd_3:
	move.l	a0,CurrentProc	; Save As Current Process
	move.l	SystemStack,sp	; Load System Stack Address
	rts

;***************************************************************************
;   Delay - Pause Current Process		*
;				*
;   Delay is used to pause the current process for a specified time.  A	*
;   maximum delay of 0xffff is allowed. Other processes are allowed to run *
;   while this process is delayed.  Since this is not a time-sliced system *
;   every process must delay periodically to allow the other processes to	*
;   execute.  Temporary variables and all registers are not guaranteed to	*
;   be unchanged after the delay.		*
;				*
;   Parameters :  d0.w - 1/60s Second To Delay		*
;				*
;   Returns:      NONE			*
;				*
;   Modifies:				*
;      Registers - A0,d0			*
;      Memory    - All (Maybe)		*
;***************************************************************************
	.export	Delay
Delay:
	tst.b	System	; Check If System Or Process
	bne.s	Delay_1	; Branch If System
	move.l	CurrentProc,a0	; Load Address Of Current Process
	move.w	d0,DelayCount(a0)	; Save Delay
	move.l	sp,StackAdr(a0)	; Save Stack Pointer
	move.w	ProcessTime,LastTime(a0) ; Load Process Time Save Last Update Time
	bra.s	Process_End
Delay_1:
	rts

Spawn:
	move.b	#1,VBMask	; Disable Switch Processing
	jsr	SpawnProcess	; Spawn A Process
	clr.b	VBMask	; Enable Switch Processing
	rts

;***************************************************************************
;   Terminate - Terminate The Current Process		*
;				*
;   Parameters :  NONE			*
;				*
;   Returns:      a0 = previous process		*
;				*
;   Modifies:				*
;      Registers - a0,a1,X		*
;      Memory    - None			*
;***************************************************************************
	.export	Terminate
Terminate:
	tst.b	System	; Check If System Or Process
	bne.s	Term_1	; Branch If System
	move.l	CurrentProc,a1	; Load Pointer To Current Process
	move.l	PreviousProc,a0	; Load Pointer To Previous Process
	move.l	NextProc(a1),NextProc(a0) ; Remove Process From Active List

	move.l	InactiveList,NextProc(a1) ; Add Process To Inactive List
	move.l	a1,InactiveList	; Store New Inactive List Head
	move.l	PreviousProc,a0	; Load Pointer To Previous Process
	bra.s	Process_End
Term_1:
	rts

;***************************************************************************
;	d0 = ID			*
;	d1 = Priority		*
;	uses a0			*
;***************************************************************************
	.export	SetProcess
SetProcess:
	tst.b	System	; Check If System Or Process
	bne.s	SetProc_1	; Branch If System
	move.l	CurrentProc,a0	; Load Address Of Current Process
	move.w	d0,ProcessID(a0)	; Save Process ID
	move.w	d1,Priority(a0)	; Save Process Priority
SetProc_1:
	rts

;***************************************************************************
;	OnDeath			*
;	a0 = address		*
;	uses a1			*
;***************************************************************************
	.export	OnDeath
OnDeath:
	tst.b	System	; Check If System Or Process
	bne	OnDeath_1	; Branch If System
	move.l	CurrentProc,a1	; Load Address Of Current Process	 
	move.l	a0,OnDeathAdr(a1)	; Save On Death Address
OnDeath_1:
	rts

;****************************************************************************
;   Exterminate - Kill Off Processes Instantly		 *
;				 *
;      Exterminate allows a process to kill a process or a set of processes.*
;      If the requested process ID is zero, all processes will be killed.	 *
;      An exterminated process is killed instantly with no On Death	 *
;      processing or terminating.		 *
;				 *
;      A process is not allowed to kill itself and no process can kill the  *
;      main process. 			 *
;				 *
;   Parameters :			 *
;	 D0 - Process ID of processes to kill  (0 - if all)	 *
;				 *
;   Returns:				 *
;	 NONE			 *
;				 *
;   Modifies:				 *
;      Registers - a0,a1,		 *
;      Memory    - Process (Process Area)		 *
;****************************************************************************
	.export	Exterminate
Exterminate:
	clr.b	ExtermCount	; Clear Exterminate Count
	move.l	#Process,a0	; Start With Main Process
	move.l	Process+NextProc,a1	; Load Address Of First Process
	cmp.l	#0,a1
	beq	Extr_End	; Branch If No Processes
Extr_1:
	tst.b	System	; Check If System Or Process
	bne	Extr_1A	; Branch If System
	cmp.l	CurrentProc,a1	; Check For Current Process
	beq	Extr_2	; Cannot Commit Suicide
Extr_1A:
	tst.w	d0	; Test Death Process
	beq	Extr_1B	; Branch If All Die
	cmp.w	ProcessID(a1),d0	; Compare With Process
	bne	Extr_2	; Branch If Not To Die
Extr_1B:
	move.l	a1,a3	; Save Process Pointer
	add.b	#1,ExtermCount	; Increment Counter
	move.l	NextProc(a1),d1	; Load Next Process, 
	move.l	a0,a1	; Load Pointer To Previous Process
	move.l	d1,NextProc(a1)	; Remove Process From Active List

	move.l	a3,a1	; Load Pointer To Current Process
	move.l	InactiveList,NextProc(a1) ; Add Process To Inactive List
	move.l	a1,InactiveList	; Store New Inactive List Head
	move.l	a0,a1	; Use Previous Process
Extr_2:
	move.l	a1,a0	; Save Previous Process
	move.l	NextProc(a1),a1	; Load Address Of Next Process
	cmp.l	#0,a1
	bne	Extr_1	; Continue If Not At End

Extr_End:
	tst.b	System	; System Code ?
	bne	ExtrEnd_4	; Branch If Yes
	move.l	#Process,a0	; Start With Main Process
	move.l	a0,a1
ExtrEnd_1:
	cmp.l	CurrentProc,a0	; Check For Current Process
	beq	ExtrEnd_3	; Found Current Process
	move.l	a0,a1	; Save Previous Process
	move.l	NextProc(a0),a0
	cmp.l	#0,a0
	bne	ExtrEnd_1	; Continue If Not At End
ExtrEnd_3:
	move.l	a1,PreviousProc	; Store Previous Process Address
	rts
ExtrEnd_4:
	move.l	#Process,CurrentProc	; As The Current Process
	rts

;****************************************************************************
;   Switch - Process A Switch Change			 *
;****************************************************************************
	.export	Switch,NewSwitch
Switch:
	move.w	SwitchCnt,d2	; Check For Any Debounced Switches
	beq.s	Switch_End	; Branch If No Switch
	subq	#1,d2	; Decrement Switch Count
	move.w	d2,SwitchCnt	; Store New Count

	move.l	#NewSwitch,a1	; Load Address Of Switch Array
	clr.w	d0	; Clear D0
	move.b	(a1,d2.w),d0	; Load Switch Value
	move.w	d0,d3	; Move To D3
	jsr	SwitchState	; Determine Switch Value
	sub.b	#1,d3	; Force Between 0 and 63
	mulu	#6,d3	; mult by 6
	move.l	#SwitchData,a0	; Load High Byte Of SwitchData
	move.b	(a0,d3.w),d1	; Load Switch Value For Process
	and.b	#7FH,d1	; Extract Switch Value
	cmp.b	d0,d1	; Check If New Value Causes Process
	bne.s	Switch	; Try Another If No Go

	tst.b	(a0,d3.w)	; Check If Spawn Or JSR
	bpl.s	Switch_2	; Branch If Spawn
	add.b	#2,d3
	move.l	(a0,d3.w),d0	; Load Switch Subroutine
	beq	Switch	; Try Another If Invalid

	move.l	d0,a0
	jsr	(a0)	; Execute Routine
	bra.s	Switch
Switch_2:
	add.b	#2,d3
	move.l	(a0,d3.w),d0	; Load Switch Process
	beq	Switch	; Try Another If Invalid
	move.l	d0,a0
	bsr	SwitchSpawn	; Spawn Process
	bra.s	Switch
Switch_End:
	rts

SwitchSpawn:
	jsr	Spawn	; Spawn Process
	cmp.l	#0,a1	; Test Process Address
	beq	SwitchS_End	; Branch If No Process
	clr.w	ProcessID(a1)	; Clear Process ID
SwitchS_End:
	rts

;****************************************************************************
;	a0 = address 
;	d0 = switch number
;	d1 = value or switch type
n;****************************************************************************

SetSwitch:
	sub.b	#1,d0
	and.w	#00ffh,d0	;word like
	move.l	#SwitchData,a1	; Load Address Of Switch Data
	mulu	#6,d0	; mult by 6
	move.b	d1,(a1,d0.w)	; Save Switch Value
	add.b	#2,d0
	move.l	a0,(a1,d0.w)	; Save Process Address
	rts

;
;---------------------------------------------------------------------
; NAME: SwitchState
;
;	FUNCTION: return a state of a switch
;
;	INPUT:	d0 = 1 based index of switch desired
;
;	RETURNS:	d0 = 0 - Switch Open
;	  	     1 - Switch Closed
;	  	     2 - Switch Being Debounced (Unused in FB)
;---------------------------------------------------------------------
;
SwitchState:
	subq.b	#1,d0	;convert to 0 based indexing
	move.l	Switches,d1	; Load Last Switch Values first lword
	cmpi.b	#32,d0	; check if in first lwork
	blt	SwitchState_1
	move.w	Switches+4,d1	; switch is in third work
SwitchState_1:
	btst	d0,d1	; Check If Bit Is Set
	bne.s	SwitchState_2	; Branch If Bit Set
	move.b	#SWITCH_OPEN,d0
	rts
SwitchState_2:
	move.b	#SWITCH_CLOSED,d0
	rts

;***************************************************************************
;       SendSound		                 	*
;***************************************************************************
SendSound:
;	rts
;;Jds	btst.b	#3,PLYRIN4	; Check If Pause On
;;Jds	bne.s	SendSound_0	; Branch If Not
;;Jds	clr.b	d0
SendSound_0:
	PUSHL	a1/d2
SendSound_1:
	move.b	snd_push,d2	;snd_push put on queue
	sub.b	snd_pull,d2
	and.b	#0x3E,d2
	cmp.b	#0x3E,d2
	beq.s	SendSound_9	;wait for the que to empty

	move.b	snd_push,d2
	and.w	#00ffh,d2
	move.l	#snd_queue,a1
	move.b	d0,(a1,d2.w)	;send sounds by putting them on queue
	add.b	#1,d2
	and.b	#31,d2
	move.b	d1,(a1,d2.w)	;send sounds by putting them on queue
	add.b	#1,d2
	and.b	#31,d2
	move.b	d2,snd_push
SendSound_9:
	POPL	a1/d2
	rts

SendSound3:
	PUSHL	a1/d2
SendSound3_1:
	move.b	snd_push,d2
	and.w	#00ffh,d2
	move.l	#snd_queue,a1
	move.b	d0,(a1,d2.w)	;send sounds by putting them on queue
	add.b	#1,d2
	and.b	#31,d2
	move.b	d1,(a1,d2.w)	;send sounds by putting them on queue
	add.b	#1,d2
	and.b	#31,d2
	move.b	d3,(a1,d2.w)	;send sounds by putting them on queue
	add.b	#1,d2
	and.b	#31,d2
	move.b	d2,snd_push
	POPL	a1/d2
	rts

;***************************************************************************
;* bad_trap() - Catchall Exception interrupt service routine.	*
;***************************************************************************
bad_trap:		    
	move.w	#0,exception_num
	bra	print_exception

;****************************************************************************
;* illegal_trap() - Illegal instruction		 *
;****************************************************************************
illegal_trap:	
	move.w	#1,exception_num
	bra	print_exception
;****************************************************************************
;* addr_trap() - address error (unaligned word xfer)
;****************************************************************************
addr_trap:
	move.w	#2,exception_num
	bra	print_exception0

;****************************************************************************
;* zero_trap() - Divide by zero error
;****************************************************************************
zero_trap:
	move.w	#3,exception_num
	bra	print_exception

;****************************************************************************
;* misc_trap() - Misc bad things that can happen
;****************************************************************************
misc_trap:
	move.w	#4,exception_num
	bra	print_exception

;****************************************************************************
;* int_trap() - IRQ at unexpected level
;****************************************************************************
int_trap:
	move.w	#5,exception_num
	bra	print_exception

;****************************************************************************
;* misc_trap2() - 
;****************************************************************************
misc_trap2:
	move.w	#6,exception_num
	bra	print_exception

;****************************************************************************
;* misc_trap() - Misc bad things that can happen
;****************************************************************************
bad_batter_trap:
	move.w	#7,exception_num
	bra	print_exception

watch_trap:
	move.w	#8,exception_num
	bra	print_exception


;****************************************************************
;	enter with exception_num holding a number indicating *
;	the type of exception.  Print the message to the     *
;	restored screen                                      *
;****************************************************************

	.global	print_exception,print_exception0
	.import	MainInitSys
print_exception0:		;bus or address error exception
	move.l	(2,sp),excep_addr ;move address of the execption to excep_addr
	add.l	#8,sp	;adjust stack for common processing
print_exception:		;all other exceptions
;	jmp	print_exception	;OUT takeout
print_exception1:
	clr.w	WatchDoggy
	move.w	(sp),excep_sr	;status register at time of exception
	move.l	(2,sp),excep_pc	;program counter at time of exception
	add.l	#6,sp	;supervisor stack at pre-exception
	movem.l	d0-d7/a0-a7,excep_registers ;save all the registers
	move.l	#STACK,sp	; Init Stack Pointer (software reset)
;	move.l	#0,dump_address	;init memory dump pointer
	move.l	#0x100,dump_scale	;and inc/dec scale
	jsr	InitSystem	;reset entire machine
	jsr	SetSysFont	;setup font for printing
	jsr	LoadExceptPal	;setup palettes for printing
;	PLANES	#PLANEA
	PLANES	#PLANEA&PLANEB
	APALETTE	#0
	BPALETTE	#127
	jsr	TogglePage	;clear draw page
	jsr	TogglePage	;clear draw page
;	PLANES	#PLANEA
print_error:
	APALETTE	#1
;	BPALETTE	#1
	PPRINT	#20,#20,"PROCESSOR EXCEPTION:  "
	move.w	exception_num,d0
	asl.w	#2,d0	;mult by 4
	move.l	#exception_ptr,a0
	move.l	(a0,d0.w),a0	;get pointer to text
	jsr	Print
	CARRET
	cmpi.w	#2,exception_num
	bne	print_pc
	PRINT	"ADDRESS "
	PRINTHEX	#excep_addr,#4
	CARRET
print_pc:
	CARRET
	PRINT	"PC "
	PRINTHEX	#excep_pc,#4
	PRINT	" SR "
	PRINTHEX	#excep_sr,#2
	CARRET
print_registers:
	move.w	#0,reg_number	;register number
print_next_register:
	move.w	reg_number,d0
	and.w	#0x3,d0	;check if at line boundary
	bne	pnr20
	CARRET
	cmp.w	#8,reg_number	;check if starting address registers
	bne	pnr20
	CARRET
pnr20:
	lea	register_labels,a0 ;register labels
	move.w	reg_number,d0
	asl.w	#2,d0
	lea	(a0,d0.w),a0	;pointer to text
	jsr	Print
	lea	excep_registers,a0 ;register storage area
	move.w	reg_number,d0
	asl.w	#2,d0	;4 bytes per register
	lea	(a0,d0.w),a0	;address of where register is stored
	PRINTHEX	a0,#4	;print register
	PRINT	" "
	add.w	#1,reg_number
	cmp.w	#16,reg_number
	bne	print_next_register
	CARRET
	CARRET

	move.w	#0,reg_number	;memory word to display
print_next_word:
	move.w	reg_number,d0
	and.w	#0x7,d0	;check if at line boundary
	bne	dm20
	CARRET
	tst.w	reg_number	;check if starting dump
	bne	dm10
	move.w	prx_coor,prx_save	;mark this spot for later
	move.w	pry_coor,pry_save
dm10:
	move.l	dump_address,a0
	move.w	reg_number,d0
	asl.w	#1,d0	;2 bytes per word
	lea	(a0,d0.w),a0	;address of word
	move.l	a0,printhex_temp
	PRINTHEX	#printhex_temp+1,#3 ;print address of memory
	PRINT	"  "
dm20:
	move.l	dump_address,a0	;base address of block being displayed
	move.w	reg_number,d0
	asl.w	#1,d0	;2 bytes per word
	lea	(a0,d0.w),a0	;address of word to print
	PRINTHEX	a0,#2	;print memory word
	PRINT	" "
	add.w	#1,reg_number
	cmp.w	#128,reg_number
	bne	print_next_word
	CARRET
	CARRET
	PRINT	"JOY1 UP/DOWN +/-MEMORY JOY1 LEFT/RIGHT +/-SCALE"
	move.w	prx_save,prx_coor	;restore marked spot
	move.w	pry_save,pry_coor
	move.l	dump_address,d0	;dump memory base address
	move.l	dump_scale,d1	;dump scale
	rol.l	#8,d0	;skip upper two digits
	rol.l	#8,d1
	bra.s	dm110	;enter loop
dm100:
	move.w	font_width,d2
	add.w	d2,prx_coor	;skip digit
dm110:
	rol.l	#4,d0	;next digit of address
	rol.l	#4,d1
	move.l	d1,d2
	and.l	#0xf,d2	;check if this digit is scale column
	beq	dm100	;br if not
	and.l	#0xf,d0	;isolate digit to print
	move.b	d0,printhex_temp
	lea	printhex_temp,a0
	move.w	#1,d0
	jsr	FormatHex	;convert hex byte to ascii digits
	APALETTE	#2
;	BPALETTE	#2
	lea	print_field+1,a0	;pointer to digit
	jsr	Print	;print it
;	PRINT	"PRESS START 1 TO RESET"
;	BANKSW	#0x00
	jsr	TogglePage

wait_around:
	move.w	ProcessTime,d0
	add.w	#4,d0
wait_around1:
	KICK_DOG
	cmp.w	ProcessTime,d0
	bne	wait_around1

wait_abit:
	move.w	#400,prx_coor	;2 bytes in ram
	move.w	#100,pry_coor	;2 byte in ram
	PRINTHEX	#0,#1	; Keep ASIC Warm
	move.w	ProcessTime,d0
	add.w	#1,d0
wait_abit1:
	clr.w	WatchDoggy	; Clear The Doggy
	KICK_DOG
	cmp.w	ProcessTime,d0
	bne	wait_abit1

wait_up:
	move.b	#BUTTON1_2,d0	;check if want to move memory up
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne	wait_down
	move.l	dump_scale,d0
	add.l	d0,dump_address
	bra	print_error
wait_down:
	move.b	#BUTTON1_4,d0	;check if want to move memory down
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne	scale_right
	move.l	dump_scale,d0
	sub.l	d0,dump_address
	bra	print_error
scale_right:
	move.b	#BUTTON1_1,d0	;check if want to move memory up alot
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne	scale_left
	move.l	dump_scale,d0	;get current scale
	and.l	#0x000000f0,d0	;check if at tens column
	bne	scale_left	;if so no more right
	move.l	dump_scale,d0	;get scale
	lsr.l	#4,d0	;move one digit to the right
	move.l	d0,dump_scale
	bra	print_error
scale_left:
	move.b	#BUTTON1_3,d0	;check if want to move memory down alot
	jsr	SwitchState
	cmp.b	#SWITCH_CLOSED,d0
	bne	wait_abit
	move.l	dump_scale,d0	;get current scale
	and.l	#0x00f00000,d0	;check if at hundred thousands column
	bne	wait_abit	;if so no more left
	move.l	dump_scale,d0	;get scale
	lsl.l	#4,d0	;move one digit to the left
	move.l	d0,dump_scale
	bra	print_error

grim_reaper:
	bra	grim_reaper	; force hardware reset to make sure
		; the world is knocked upside the head



exception_ptr:
	dc.l	excep0
	dc.l	excep1
	dc.l	excep2
	dc.l	excep3
	dc.l	excep4
	dc.l	excep5
	dc.l	excep6
	dc.l	excep7
	dc.l	excep8

;****************************************************************
;	rom data area
;****************************************************************

excep0:	dc.b	"BAD TRAP ERROR",0
excep1:	dc.b	"ILLEGAL INSTRUCTION ERROR",0
excep2:	dc.b	"ILLEGAL ADDRESS ERROR",0
excep3:	dc.b	"ZERO DIVIDE",0
excep4:	dc.b	"MISC BAD THINGS",0
excep5:	dc.b	"INTERRUPT REQUEST",0
excep6:	dc.b	"PIC REQUEST",0
excep7:	dc.b	"BAD BATTER",0
excep8:	dc.b	"WATCH DOG RESET",0

register_labels:
	dc.b	"D0 ",0
	dc.b	"D1 ",0
	dc.b	"D2 ",0
	dc.b	"D3 ",0
	dc.b	"D4 ",0
	dc.b	"D5 ",0
	dc.b	"D6 ",0
	dc.b	"D7 ",0
	dc.b	"A0 ",0
	dc.b	"A1 ",0
	dc.b	"A2 ",0
	dc.b	"A3 ",0
	dc.b	"A4 ",0
	dc.b	"A5 ",0
	dc.b	"A6 ",0
	dc.b	"A7 ",0

	.export	Debouncers
Debouncers:
	dc.b	1,1,1,1,3,3,1,1
	dc.b	1,1,1,1,3,3,1,1
	dc.b	1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1
	.align	4

;****************************************************************
;   AddCycle - Add An Entry To Color Cycling Table
;
;   Parameters :	d0 - Palette # 
;		d1 - start color #
;		d2 - Number of colors
;		d3 - Tick count
;
;	Uses CycleData:
;		dc.b curtick
;		dc.b maxtick
;		dc.w # colors to cycle
;		dc.l Absolute Address of (last color + 1)
;
;****************************************************************
	.export	AddCycle
AddCycle:
	move.w	SR,-(sp)	; Push Status Onto Stack
	ori.w	#DIRQ,SR	; Disable IRQs
	jsr	doaddcyc
	move.w	(sp)+,SR
	rts
doaddcyc:
	andi.l	#$0000ffff,d0	;mask appropriately
	asl.w	#8,d0	;palette number * 256
	add.w	d1,d0	;+ start number
	add.w	d2,d0	;+ number to cycle
	lsl.l	#2,d0	;* 4 bytes per color
	add.l	#PALETTES,d0	;+ palettes

	move.w	#MAX_CYCLES-1,d4	                 ; Load Number Of Color Cycles
	movea.w	#CycleData,a0	; Load Address Of Cycle Table
AddCyc_1:
	tst.b	(1,a0)	; Check If Entry Available
	beq.s	AddCyc_2	; Branch If Not In Use
	cmp.l	(4,a0),d0	; are we updating this info
	bne.s	AddCyc_2	; no, so try some more
	move.l	d0,(4,a0)	; set end cycle address
	move.w	d2,(2,a0)	; Store number of colors
	move.b	d3,(0,a0)	; Store Tick Counter (current) = terminal
	move.b	d3,(1,a0)	; Store Tick Counter (terminal) DO THIS LAST!
	rts
AddCyc_2:
	lea  (8,a0),a0	; Index To Next Entry
	dbf  d4,AddCyc_1	; Continue Until Done
			; not currently used, so make a new one
	move.w	#MAX_CYCLES-1,d4	                 ; Load Number Of Color Cycles
	movea.w	#CycleData,a0	; Load Address Of Cycle Table
AddCyc_3:
	tst.b	(1,a0)	; Check If Entry Available
	bne.s	AddCyc_4	; Branch If In Use
	move.l	d0,(4,a0)	; set end cycle address
	move.w	d2,(2,a0)	; Store number of colors
	move.b	d3,(0,a0)	; Store Tick Counter (current) = terminal
	move.b	d3,(1,a0)	; Store Tick Counter (terminal) DO THIS LAST!
	rts
AddCyc_4:
	lea  (8,a0),a0	; Index To Next Entry
	dbf  d4,AddCyc_3	; Continue Until Done
	rts

;****************************************************************************
;   InitCycle - Initialize Color Cycling		 *
;					 *
;	Uses CycleData:
;		dc.b curtick
;		dc.b maxtick
;		dc.w # colors to cycle
;		dc.l Absolute address of (last color + 1)
;
;****************************************************************************
	.export	InitCycle
InitCycle:
	move.w	SR,-(sp)	; Push Status Onto Stack
	ori.w	#DIRQ,SR	; Disable IRQs
	move.w	#(MAX_CYCLES-1)*8,d0               ; Load Number Of Color Cycles
	movea.w	#CycleData,a0	; Load Address Of Cycle Table
	moveq	#0,d1
InitCyc_1:
	move.w	d1,(a0,d0.w)	; clear out maxtick and curtick
	subq.w	#8,d0	; Decrement D0
	bpl	InitCyc_1	; Continue Until Done

	move.w	(sp)+,SR
	rts

;****************************************************************************
;   CycleColors - Cycle Colors   ** INTERRUPT ROUTINE **
;
;	Uses CycleData:
;		dc.b curtick
;		dc.b maxtick
;		dc.w # colors to cycle
;		dc.l Absolute address of (last color + 1)
;
;****************************************************************************
	.export	CycleColors

CycleColors:
;;Jds	btst.b	#2,PLYRIN4	; Check If Pause On
;;	bne.s	CycleCol_1	; Branch If Not
;;	rts
CycleCol_1:

	move.w	SR,-(sp)	; Push Status Onto Stack
	ori.w	#DIRQ,SR	; Disable IRQs
	PUSHL	d3-d7/a3-a4	                 ;save regs
	movea.w	#CycleData+(MAX_CYCLES*8),a3       ;calulate end of cycletable
	movea.w	#CycleData,a2	                 ;calulate where we stop
cclp1
	subq.l	#8,a3	;adjust for next entry in table
	move.l	a3,a0	;copy to scratch area
	move.b	(a0),d7	;get curtick
	subq.b	#1,d7	;decr
	bmi.s	ccskip	;if it was 0, skip
	move.b	d7,(a0)+	;save curtick
	bne.s	ccskip	;if not zero, skip
	move.b	(a0)+,(a3)	;reload maxtick to curtick
	move.w	(a0)+,d7	;get # colors to cycle
	move.l	(a0),a0	;get address of last color
	bsr.s	do_cycle
ccskip
	cmp.l	a2,a3	;see if we're finished
	bne	cclp1	;branch if not
	POPL	d3-d7/a3-a4	;restore regs
	move.w	(sp)+,SR

	tst.w	A_HLINE

	rts

;	 nop

	.export	do_cycle
do_cycle
	move.l	(-4,a0),ITemp	;last color -> ITemp
	subq.w	#8,d7	;test if less than 8
	bmi	dc_lt8	;finish off
dc_loop
	movem.l	(-36,a0),d0-d6/a4 ; 80 - load 8 colors (16+8n)
	movem.l	d0-d6/a4,-(a0)	; 72 - store 1 color up (8+8n)
	subq.w	#8,d7	;  4 - adjust counter
	bpl.s	dc_loop	; 10 - if cnt >= 0, keep going
			;----
			;166 cycles / 8 colors = 20.75 cycles / color
			;This can be increased by doing more than 8 at once
dc_lt8
	addq.w	#8,d7
	asl.w	#2,d7
	move.l	#dc_table,a4
	move.l	(a4,d7.w),a4
	jmp	(a4)
dc_7
	movem.l	(-28,a0),d0-d5
	movem.l	d0-d5,-(a0)
	move.l	ITemp,-(a0)
	rts
dc_6
	movem.l	(-24,a0),d0-d4
	movem.l	d0-d4,-(a0)
	move.l	ITemp,-(a0)
	rts
dc_5
	movem.l	(-20,a0),d0-d3
	movem.l	d0-d3,-(a0)
	move.l	ITemp,-(a0)
	rts
dc_4
	movem.l	(-16,a0),d0-d2
	movem.l	d0-d2,-(a0)
	move.l	ITemp,-(a0)
	rts
dc_3
	movem.l	(-12,a0),d0-d1
	movem.l	d0-d1,-(a0)
	move.l	ITemp,-(a0)
	rts
dc_2
	move.l	(-8,a0),d0
	move.l	d0,-(a0)
	move.l	ITemp,-(a0)
	rts
dc_1
	move.l	ITemp,-(a0)
	rts
dc_0
	move.l	ITemp,(a0)
	rts

dc_table
	dc.l	dc_0,dc_1,dc_2,dc_3,dc_4,dc_5,dc_6,dc_7

;****************************************************************
	.export	old_hline
old_hline:
	tst.b	AQStat	; Was The Queue Waiting
	bpl	skipit	; Branch If Not
	move.w	S_IntMask,A_INTMASK                ; Write Out Interrupt Mask Shadow
	clr.b	AQStat	; Clear Queue Status
	jsr	DoNextICmd	 ; Stuff more things into the blitter.
skipit	rts

;****************************************************************
;	InitSystem cleans up the entire system after powerup or after
;	a processor exception error
;****************************************************************
	.export	InitSystem
InitSystem:
	move.b	#1,VBMask	; actually VIRQ, used to disable switch processing
	move.b	#1,VBLANKcount	; Some small number
	clr.b	VBFlag	; Clear Vertical Blank Flag
	move.w	#HLINEMAX,HLineIndex	; Clear Horisontal check

	clr.w	S_PLN1XTP
	clr.w	S_PLN1YTP

	jsr	init_68000	; init this version of the 68000
	jsr	InitVideo

	jsr	init_rnd

	jsr	Init_pic
	jsr	Read_from_pic	; setup for first test


	jsr	InitSwitches	; Initialize Switches
	jsr	InitProcess	; Initialize Processes
	jsr	InitQueue	; Initialize ASIC Queue
	jsr	InitCycle	; Initialize Color Cycling

;jws	jsr	Test_pic_reslt	; 1st verif. "B-4" video is set up

	clr.b	snd_pull
	clr.b	snd_push	; prepare the sound queue

	andi	#$F9FF,SR	; Enable IRQs, Blitter & Vertical
	ori	#$2100,SR	; make sure we are in superv. mode

	clr.b	VBMask	; actually VIRQ, used to enable switch processing

	rts

;****************************************************************
	.export	Init_Timing
Init_Timing:
	clr.w	Display_Count
	clr.w	Next_Display
	clr.b	Toggle_Flag
	clr.b	Clear_Flag
	clr.b	Timing_Flag
	move.w	botscr,d0
	sub.w	#1,d0
	move.w	d0,A_HLINECP	                 ;Line for fake VBLANK
;; set up horizontal line ints
;; (BOTSCR-1)/3,(2*(BOTSCR-1))/3,BOTSCR-1,0	
	clr.w	d1
	move.w	botscr,d0	; Load Bottom Screen Line
	subq.w	#1,d0	; Move Up One Line
	lsr.w	#3,d0	; Divide By Eight
	move.w	d0,d1
	move.w	d1,HLineInts	; Store First Interrupt (1/8)
	add.w	d0,d1	; Calculate 2/8
	move.w	d1,HLineInts+2	; Store Second Interrupt (2/8)
	add.w	d0,d1	; Calculate 3/8
	move.w	d1,HLineInts+4	; Store Third Interrupt (3/8)
	add.w	d0,d1	; Calculate 4/8
	move.w	d1,HLineInts+6	; Store Fourth Interrupt (4/8)
	add.w	d0,d1	; Calculate 5/8
	move.w	d1,HLineInts+8	; Store Fifth Interrupt (5/8)
	add.w	d0,d1	; Calculate 6/8
	move.w	d1,HLineInts+10	; Store Sixth Interrupt (6/8)
	add.w	d0,d1	; Calculate 7/8
	move.w	d1,HLineInts+12	; Store Seventh Interrupt (7/8)
	
	move.w	botscr,d1
	sub.w	#1,d1
	move.w	d1,HLineInts+14
;;
;;sj	move.w	#BOTSCR-1,A_HLINECP	                 ;Line for fake VBLANK
	move.w	#0101000100B,S_IntMask
	move.w	S_IntMask,A_INTMASK
	move.w	#01000000B,A_XINTSEL               ;XINT = XFER
	move.w	#01111110B,A_INTCLR                ;Clear all ints
	jsr	ClrLines	;Clear Line 255 and 511 For Clear Screen
	rts

;****************************************************************
;* InitVideo() - Initialize Video Processing, TI 34061 & IT 4400
;****************************************************************
	.export	InitVideo
InitVideo:

;;	move.w    #10000111B,A_MODE0                 ; Set Up Mode 0 Register
	move.w    #10001111B,A_MODE0                 ; Set Up Mode 0 Register

	move.w    #0101000100B,S_IntMask
	move.w    S_IntMask,A_INTMASK

	move.w    #$11,A_VSCALE
	move.w    #$00,A_GROMSEG
	move.w    #$15,ASIC+132

	move.w    #0,A_PLN0YTP        ; plane0 y tap point
	move.w    #0,A_PLN1YTP
	move.w    #0,A_PLN2YTP ;ASIC+72
	move.w    #0,A_PLN3YTP ;ASIC+74
	move.w    #0,A_PLN0XTP ;ASIC+76
	move.w    #0,A_PLN1XTP ;ASIC+78
	move.w    #0,A_PLN2XTP ;ASIC+80
	move.w    #0,A_PLN3XTP ;ASIC+82
	move.w    #$80,ASIC+168                       ;ras0
	move.w    #$c0,ASIC+172                       ;ras1
	move.w    #$1c0,ASIC+176                      ;ras2
	move.w    #$1c0,ASIC+180                      ;ras3
	move.w    #$1cf,ASIC+184                      ;cas0
;
;  CAS1 - $1BF for 70ns Video RAM
;       - $1CF for 80ns Video RAM
;
	move.w    #$1cf,ASIC+188                      ;cas1

	move.w    #$1e3,ASIC+192                      ;cas2
	move.w    #$1cf,ASIC+196                      ;cas3

	move.w    #$1ff,ASIC+200                     ;wen0
;
;  WEN1 - $1BF for 70ns Video RAM
;       - $1CF for 80ns Video RAM
;
	move.w    #$1cf,ASIC+204                     ;wen1

	move.w    #$1ff,ASIC+208                     ;wen2
	move.w    #$00f,ASIC+212                     ;wen3
	move.w    #$18f,ASIC+216                     ;trg0
	move.w    #$1ff,ASIC+220                     ;trg1
	move.w    #$0f,ASIC+224                      ;trg2
	move.w    #$0f,ASIC+228                      ;trg3
	move.w    #$1ff,ASIC+232                     ;dsf0
	move.w    #$1ff,ASIC+236                     ;dsf1
	move.w    #$1ff,ASIC+240                     ;dsf2
	move.w    #$000,ASIC+244                     ;dsf3


	.import	ScrLevel
;Proper values
;	tst.w	ScrLevel
;	bne.s	Setlines
;256 lines
	move.w    #286,ASIC+100      ;Vertical total - start sync
	move.w    #281,ASIC+104      ;Vertical end sync, start blank
	move.w    #259,ASIC+108      ;Vertical end blank, start active
	move.w    #3,ASIC+112        ;Vertical end active, start blank
	move.w	#256,botscr
;	bra.s	Setlines1
;240 lines
;Setlines:
;	move.w    #262,ASIC+100      ;Vertical total - start sync
;	move.w    #257,ASIC+104      ;Vertical end sync, start blank
;	move.w    #243,ASIC+108      ;Vertical end blank, start active
;	move.w    #3,ASIC+112        ;Vertical end active, start blank
;	move.w	#240,botscr
Setlines1:

;	move.w    #508,ASIC+116      ;Horizontal total - start sync
;	move.w    #484,ASIC+120      ;Horizontal end sync, start blank
;	move.w    #434,ASIC+124      ;Horizontal end blank, start active
;	move.w    #50,ASIC+128       ;Horizontal end active, start blank

	move.w    #508,ASIC+116      ;Horizontal total - start sync
	move.w    #470,ASIC+120      ;Horizontal end sync, start blank
	move.w    #420,ASIC+124      ;Horizontal end blank, start active
	move.w    #36,ASIC+128       ;Horizontal end active, start blank

	move.w    #$820,ASIC+248    ;refresh, Bit11 & Bit12 =Planes active 0=1
	move.w    #$100,ASIC+252
;WAIT states
;;	.import	waitstate_flg
;;	tst.w	waitstate_flg
;;	beq.s	SetFast
           move.w    #$33,A_GROMWAIT   ; wait states
;;	bra.s	SetFast_1
SetFast:
;;           move.w    #$22,A_GROMWAIT   ; wait states
SetFast_1:
	move.w    #0101000010000000B,S_Mode1
	move.w    S_Mode1,A_MODE1
	TRANS     OFF
;;	move.w    #5,A_STATE        ;m2sr

	clr.w     Mode1

	clr.w	d0
;	move.w	d0,S_Plane	; Clear Plane Shadow Value
;	move.w	d0,N_Plane	; Clear Plane Shadow Value
	
	move.w  d0,PALSELA+2        ; Clear Palette Select For Plane 0
	move.w  d0,PALSELB+2        ; Clear Palette Select For Planes 1 & 2
	move.w	d0,PLANE+2 	    ;Led On, Enable All Planes, palette 0, LJH 8-17-94


	clr.w     QMode1
	clr.w     Mode1
	WIDTHPIX  OFF
	LOOKAHEAD ON
	FLIP      OFF
	FLOP      OFF
	CLIP      ON
	TRANS     ON                ; Turn On Transparency

	jsr       Init_Timing       ;Init VLBANK Timing Variables
	rts

;****************************************************************
;****************************************************************************
;   VINT_INT - Vertical Blank Interrupt Handler (Not Used)	  *
;****************************************************************************
	.export	VINT_INT
VINT_INT:
	rte

;****************************************************************************
;   ASIC_QINT - Quick Interrupt Handler used by HLINE IRQ (Simulate VBLANK) *
;****************************************************************************

HLINEMAX	equ	16

	.export	ASIC_QINT
ASIC_QINT:
	movem.l	d0-d2/a0-a2,-(sp)
	cmp.w	#HLINEMAX,HLineIndex	; Check If Last H Line
	bne.s	ASIC_QINT1	; Branch If Not
	clr.w	HLineIndex	; Start Again
	bsr.s	vblank_handle

	KICK_DOG

	addq.w	#1,WatchDoggy	; Increment Watch Dog
	cmp.w	#120,WatchDoggy	; Check For Two Seconds
	blt.s	ASIC_QINT1	; Branch If Not
	movem.l	(sp)+,d0-d2/a0-a2
	jmp	watch_trap
ASIC_QINT1:
	move.l	#HLineInts,a0	; Load Address Of Horiz Ints
	move.w	HLineIndex,d0	; Load Index
	move.w	(a0,d0.w),A_HLINECP	; Set Horiz Line Interrupt
	move.w	#HLINE,A_INTCLR	; Clear The Interrupt
	addq.w	#2,HLineIndex	; Increment Interrupt Index
	jsr	ReadTrackball	; Update Trackball
	jsr	ProcSounds	; Process Sound Queue
	movem.l	(sp)+,d0-d2/a0-a2
	rte

;;HLineInts:	dc.w	(BOTSCR-1)/3,(2*(BOTSCR-1))/3,BOTSCR-1,0

;****************************************************************
;ASIC_QINT:
;	movem.l	d0-d2/a0-a2,-(sp)
;	bsr.s	vblank_handle
;	move.w	#HLINE,A_INTCLR
;	movem.l	(sp)+,d0-d2/a0-a2
;	rte
;****************************************************************
	.export	vblank_handle
	.export	VertFlag	; say we are in vertal blank
vblank_handle:
	jsr	DisplayUpdate	; Possibly Clear Screen and Toggle Page
	jsr	CycleColors	; Cycle Colors
	jsr	ReadSwitches	; Read Switches
	add.b	#1,VBFlag	; Flag Vertical Blank
	addq.w	#1,ProcessTime	; Increment Process Time
	addq.w	#1,vbcount	; Increment Process Time
	addq.b	#1,VBLANKcount
	move.b	#1,VertFlag	; say we are in vertal blank
	tst.b	QFlag
	beq	vbhc
	clr.b	AQStat
	jsr	DoNextICmd
vbhc	
	move.w	N_PalSel,d0	;get LED/PALSEL shadow register
	bclr	#8,d0	;set LED via frame count variable
	btst.b	#4,VBLANKcount
	beq.s	vbhx
	bset	#8,d0
vbhx
	move.w	d0,S_PalSel	;update the shadow register
	move.w	d0,N_PalSel	;update the shadow register

	move.w	d0,PLANE+2	;and the hardware register

	jsr	Write_to_pic
	rts

;****************************************************************
;   ASIC_XINT - Interrupt Handler For ASIC
;****************************************************************
	.export	ASIC_XINT
ASIC_XINT: 		;INT (44)
	movem.l	d0-d2/a0-a2,-(sp) ;save registers

	add.b	#1,rnd_cnt	; random add

	btst.b	#XFER_B,A_ISTATUS+1 ;check for XFER interrupt
	beq.s	xint_exit	;branch If No XFER (8)
xint_loop:
	move.w	#XFER,A_INTCLR	;clear The Interrupt (20)
	tst.b	AQStat	;was the queue waiting for this? (12)
	ble.s	xint_fin	;if zero, or minus, skip it
	clr.b	AQStat	;clear The Status (16)
	jsr	DoNextICmd	;stuff more things into the blitter. (12)
xint_fin
	btst.b	#XFER_B,A_ISTATUS+1 ;check for XFER interrupt
	bne.s	xint_loop	;if present, loop back
xint_exit:
	move.w	#00111010b,A_INTCLR ;clear anything that might annoy us
	movem.l	(sp)+,d0-d2/a0-a2 ;restore regs and exit.
	rte		; (20)

;****************************************************************
;ASIC_XINT:		 ;INT (44)
;	 movem.l	 d0-d2/a0-a2,-(sp) ;save registers
;xint_loop:
;	 btst.b	 #XFER_B,A_ISTATUS+1 ;check for XFER interrupt
;	 beq.s	 xint_exit	 ;branch If No XFER (8)
;	 move.w	 #XFER,A_INTCLR	 ;clear The Interrupt (20)
;	 bsr.s	 xfer_handle	 ;handle the interrupt (18)
;
;			 ;this code goes after active int handlers
;xint_fin			 ;exit if all interrupts cleared
;	 tst.b	 A_ISTATUS+1	 ;test the Interrupt status of the ASIC (+1 for byte) (12)
;	 bne.s	 xint_loop	 ;if anything, loop through Interrupts again (8)
;xint_exit:
;	 move.w	 #00111010b,A_INTCLR
;	 movem.l	 (sp)+,d0-d2/a0-a2 ;restore regs and exit.
;	 rte		 ; (20)
;****************************************************************

	.export	xint_no_xfer
xint_no_xfer:
	move.w	A_ISTATUS,d0	;get the ASIC Interrupt Status back

	btst	#HLINE_B,d0    
	beq.s	xint_no_hline
	move.w	#HLINE,A_INTCLR
xint_no_hline:

	btst	#BLITCLIP_B,d0
	beq.s	xint_no_blitclip
	move.w	#BLITCLIP,A_INTCLR
xint_no_blitclip:

	btst	#EOBLIT_B,d0   
	beq.s	xint_no_eoblit
	move.w	#EOBLIT,A_INTCLR
xint_no_eoblit:

	btst	#SPECIAL_B,d0  
	beq.s	xint_no_special
	move.w	#SPECIAL,A_INTCLR
xint_no_special:

	btst	#VBLANK_B,d0
	beq.s	xint_no_vblank
	move.w	#VBLANK,A_INTCLR
xint_no_vblank:

	bra	xint_fin

;****************************************************************
;	Diplay Timing Routines
;****************************************************************
DisplayUpdate:
	clr.b	QFlag	
	subq.w	#1,Display_Count	; Decrement Display Counter
	bgt	DspUpdate_F	; Branch If Not Time Out

	tst.b	Timing_Flag	; if not waiting to display
	bpl	DspUpdate_F	; don't do anything
	clr.b	Timing_Flag	; otherwise clear timing flag,
	move.w	Next_Display,Display_Count ; re-load the display counter,
	move.w	CurFrameCount,FrameCount   ; indicate the previous frames' frame rate
	move.w	vbcount,CurFrameCount      ; indicate the this frames' frame rate
	clr.w	vbcount	; and clear counter for next frame

	cmpi.w	#HOSTREAD,last_cmd
	beq.s	DspUpdate_2
	cmpi.w	#HOSTWRITE,last_cmd
	beq.s	DspUpdate_2
DspUpdate_1:
	move.w	A_STATUS,d0	; Load ASIC Status
	andi.w	#(IDLE|CMDREG|VSACTIVE),d0 ; Extract IDLE, VB, CMD REG
	cmpi.b	#(IDLE|VSACTIVE),d0	; Check For IDLE And VB
	bne.s	DspUpdate_1
	bra.s	DspUpdate_3
DspUpdate_2
	move.w	A_STATUS,d0	; Load ASIC Status
	andi.w	#(CMDREG|VSACTIVE),d0	; Extract VB, CMD REG
	cmpi.b	#(VSACTIVE),d0	; Check For VB
	bne.s	DspUpdate_2
DspUpdate_3
	tst.b	Toggle_Flag
	beq.s	DspUpdate_4
	move.w	PageLine,d0
	eori.w	#$200,d0
	addi.w	#VRAMPAGE,d0	;jeff - prob should do this
	move.w	d0,A_PLN0YTP	;View Page = Page not Drawing to
	move.w	d0,A_PLN1YTP	;View Page = Page not Drawing to

	move.w	#0,A_PLN0XTP	; jeff - set x tap somewhere else
	move.w	#0,A_PLN1XTP	; jeff - set x tap somewhere else
DspUpdate_4:
	tst.b	Clear_Flag
	beq.s	DspUpdate_7

	PUSHL	d3
	move.w	PageLine,d2
	addi.w	#255+VRAMPAGE,d2
	move.w	#512,d3	; 512 goes to 256 lines because of ASIC height bug
	jsr	DClear
	POPL	d3

	cmpi.w	#HOSTREAD,last_cmd
	beq.s	DspUpdate_6
	cmpi.w	#HOSTWRITE,last_cmd
	beq.s	DspUpdate_6
DspUpdate_5:
	move.w	A_STATUS,d0	; Load ASIC Status
	andi.w	#11000000b,d0
	cmpi.b	#10000000b,d0
	bne.s	DspUpdate_5	; If not, Keep Waiting
	bra.s	DspUpdate_7
DspUpdate_6:
	move.w	A_STATUS,d0	; Load ASIC Status
	andi.w	#01000000b,d0
	cmpi.b	#00000000b,d0
	bne.s	DspUpdate_6	; If not, Keep Waiting
DspUpdate_7:
	move.b	Toggle_Flag,d0
	or.b	Clear_Flag,d0
	beq.s	DspUpdate_8
	move.w	PageLine,d1
	addi.w	#VRAMPAGE,d1
	move.w	d1,A_TOPCLIP	; Upper clip value
	addi.w	#C_BOTSCR,d1	; Clip to bottom screen
	move.w	d1,A_BOTCLIP	; Lower clip value
	move.w	#VRAMCOL,A_LEFTCLIP	; Left clip value
	move.w	#C_RGTSCR+VRAMCOL,A_RGHTCLIP	; Right clip value
	clr.b	Toggle_Flag
	clr.b	Clear_Flag
DspUpdate_8:

	tst.w	ScreenInvert2
	beq.s	DspUpdate_A

	move.w	#16,d0
	sub.w	S_PLN1YTP,d0
	move.w	d0,A_PLN1YTP	; Store The Y Tap Point
	move.w	#128,d0
	sub.w	S_PLN1XTP,d0
	bclr	#0,d0
	move.w	d0,A_PLN1XTP	; Store Background X Tap Point
	bra.s	DspUpdate_B
DspUpdate_A:
	move.w	S_PLN1YTP,A_PLN1YTP	; Store The Y Tap Point
	move.w	S_PLN1XTP,d0
	bclr	#0,d0
	move.w	d0,A_PLN1XTP	; Store Background X Tap Point
DspUpdate_B:
	clr.b	AQStat	; We're Waiting for DoNextICMD
	move.b	#1,QFlag	; make sure we get one
DspUpdate_F:
	rts

;****************************************************************************
;
; Memory tests for checking processor ram
; these are low level power up tests
; no working ram is needed to run the tests
; all variables are kept in processor registers
;
; quick_memory_test:
;    this test quits at the first sign of trouble
;
; quick memory test works on one 32 bit memory location at a time
; various data patterns are written and checked.
; only 32 bit access is checked
; the last pattern written is the address of that location
;
; After all locations have been checked the test starts over
; and checks to see if the address written to each 32 bit location
; is still there. This provides a crude address line check
;
; Register Usage:
;  a0 - memory location being tested
;  d0 - typically data read back
;  d1 - typically data to write
;  d2 - dbf loop counter
;  d3 - dbf loop counter - typically memory count
;
MEMORY_COUNT equ	(($8000/4)-1)
	ds 0
mtest_patterns:
	dc.l	3-1	;number of patterns for dbf loop
	dc.l	0xffffffff
	dc.l	0x55aaaa55
	dc.l	0x00000000

quick_memory_test:
	lea	0,a0	;starting memory to test
	move.w	#MEMORY_COUNT,d3	;long words to test
bt100:
	lea	mtest_patterns,a2	;list of memory test patterns
	move.l	(a2)+,d2	;number of test patterns
bt110:
	move.l	(a2)+,d1	;get test pattern
	move.l	d1,(a0)	;simple 32 bit write
	move.l	(a0),d0
;TRK	not.l	d0	;testing purposes only
	cmp.l	d0,d1
	bne.s	p1mem_fail	;br if bad

	dbf	d2,bt110	;br if patterns left
	move.l	a0,(a0)+	;setup for address check later
	KICK_DOG		;Give the dog a bone
	dbf	d3,bt100	;check if done
;
;address test
;check if address written to each 32 bit location is still there.
;
bt200:
	lea	0,a0	;starting memory to test
	move.w	#MEMORY_COUNT,d3	;long words to test
	KICK_DOG		;Give the dog a bone
bt250:
	move.l	a0,d0
	cmp.l	(a0),d0	;check for correct address
	bne.s	p2mem_fail	;br if bad
	clr.l	(a0)+	;then clear it out
	dbf	d3,bt250	;done yet?

	bra	more_memory_tests

	move.w	#0,d0	;no problems found
	jmp	jreset
p1mem_fail:
	move.w	#1,d0
	jmp	jreset
p2mem_fail:
	move.w	#2,d0
	jmp	jreset

;
; byte, word, and longword memory access tests
;
; Register Usage:
;  a0 - memory location being tested
;  a1 - pointer to memory test pattern
;  a6 - return address
;  d0 - typically data read back
;  d1 - typically data to write
;  d2 - dbf loop counter
;  d3 - dbf loop counter - typically memory count
;  d6 - memory test being run
;
TESTMEMORY	equ	$400

more_memory_tests:
	move.w	#15,d3	;outer loop count
mmt_loop:
	KICK_DOG		;Give the dog a bone
byte_write:
	lea	TESTMEMORY,a0
	lea	memtest_patterns,a1
	move.w	#15,d2
bw_loop:
	move.w	#$10,d6	;memory test number
	move.b	(a1)+,d0
	move.b	d0,(a0)
	cmp.b	(a0)+,d0
	bne	read_verify_fail
	dbra	d2,bw_loop
	lea	bw_return,a6
	bra	read_verify
bw_return:

word_write:
	lea	TESTMEMORY,a0
	lea	memtest_patterns,a1
	move.w	#7,d2
ww_loop:
	move.w	#$20,d6	;memory test number
	move.w	(a1)+,d0
	move.w	d0,(a0)
	cmp.w	(a0)+,d0
	bne	read_verify_fail
	dbra	d2,ww_loop
	lea	ww_return,a6
	bra	read_verify
ww_return:

word1_write:
	lea	TESTMEMORY,a0
	lea	memtest_patterns,a1
	move.w	#14,d2
ww1_loop:
	move.w	#$20,d6	;memory test number
	move.w	(a1),d0
	move.w	d0,(a0)
	cmp.w	(a0),d0
	bne	read_verify_fail
	add.l	#1,a0
	add.l	#1,a1
	dbra	d2,ww1_loop
	lea	ww1_return,a6
	bra	read_verify
ww1_return:

long1_write:
	lea	TESTMEMORY,a0
	lea	memtest_patterns,a1
	move.w	#12,d2
lw1_loop:
	move.w	#$20,d6	;memory test number
	move.l	(a1),d0
	move.l	d0,(a0)
	cmp.l	(a0),d0
	bne	read_verify_fail
	add.l	#1,a0
	add.l	#1,a1
	dbra	d2,lw1_loop
	lea	lw1_return,a6
	bra	read_verify
lw1_return:

	dbra	d3,mmt_loop	;do the whole sequence a few times
	move.w	#0,d0	;no problems found
	jmp	jreset

read_verify:
	lea	TESTMEMORY,a0
	lea	memtest_patterns,a1
	move.w	#3,d2
read_verify_loop:
	cmp.l	(a0)+,(a1)+
	bne.s	read_verify_fail
	clr.l	-4(a0)
	dbra	d2,read_verify_loop
	jmp	(a6)
read_verify_fail:
	move.w	d6,d0	;failed memory test
	jmp	jreset	;blow it away on first error

	.align	4
memtest_patterns:
	dc.b	$00,$11,$22,$33,$44,$55,$66,$77
	dc.b	$88,$99,$aa,$bb,$cc,$dd,$ee,$ff

	end


