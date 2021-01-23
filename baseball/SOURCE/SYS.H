;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1995, IT, INC.	*
;***************************************************************************

SERVICE	equ	34                ; Service Switch
TESTSW	equ	33                ; Test Switch

COIN1	equ	1
START1     equ	2
JOY1_RT    equ	5
JOY1_LF    equ	6
JOY1_DW    equ	7
JOY1_UP    equ	8

BUTTON1_1  equ	3
BUTTON1_2  equ	4
BUTTON1_3  equ	17
BUTTON1_4  equ	19
BUTTON1_5  equ	21
BUTTON1_6  equ	23

COIN2      equ	9
START2     equ	10
JOY2_RT    equ	13
JOY2_LF    equ	14
JOY2_DW    equ	15
JOY2_UP    equ	16

BUTTON2_1  equ	11
BUTTON2_2  equ	12
BUTTON2_3  equ	18
BUTTON2_4  equ	20
BUTTON2_5  equ	22
BUTTON2_6  equ	24

FIRSTBASE1  equ       BUTTON1_1
SECONDBASE1 equ       BUTTON1_2
THIRDBASE1  equ       BUTTON1_3
HOMEPLATE1  equ       BUTTON1_4

FIRSTBASE2  equ       BUTTON2_1
SECONDBASE2 equ       BUTTON2_2
THIRDBASE2  equ       BUTTON2_3
HOMEPLATE2  equ       BUTTON2_4

SWITCH_OPEN equ      0
SWITCH_CLOSED equ    1
SWITCH_DEBOUNCE equ  2

SW_SPAWN   equ	01H	; spawn task at switch press
SW_INT     equ	41H	; execute routine out of interrupt (NMI)
SW_SOON    equ	81H	; after current process executes a DELAY

;          --------------------
;          | Count  | Color # |
;          |     Pointer      |
;          |  To Color Data   |
;          --------------------
;
COLORCNT   equ	16	; Number Of Color Cycling


;             PROCESS EQUATES
ProcessMax   equ     10	; Number Of Processes
ProcessLen   equ     256	; Length Of A Process Block
Stack        equ     ProcessLen-2	; Process Stack Start


NextProc     equ     0	; Address Of Next Process Block (long)
DelayCount   equ     4	; ProcessTime When Active Again (word)
StackAdr     equ     6	; Address Of Process Stack            (long)
LastTime     equ     10	; Last Time Check For Activation(word)
ProcessID    equ     12	; Process ID Used For Kill & Exterminate (word)
Priority     equ     14	; Process Priority (word)
OnDeathAdr   equ     16	; Address To Execute If Process Is Killed (word)

