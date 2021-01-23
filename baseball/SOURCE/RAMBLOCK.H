;***************************************************************************
;                   WILLIAMS BASEBALL VIDEO GAME		*
;                   INCREDIBLE TECHNOLOGIES, INC.	*
;                    (C) COPYRIGHT 1996, IT, INC.	*
;***************************************************************************
object_struct	.struct

NEXTOBJECT  	ds.l  1	; 4 - Pointer To Next Object
PARSEPOINTER	ds.l  1	; 4 - Animation Parse Pointer		
CONTROLBLOCK	ds.l  1	; 4 - Address Of Control Block
XPOSITION   	ds.w  1	; 2 - X Position
YPOSITION   	ds.w  1	; 2 - Y Position
XFRACTION   	ds.b  1	; 1 - X Fractional Part
YFRACTION   	ds.b  1	; 1 - X Fractional Part
XVELOCITY   	ds.w  1	; 2 - X Velocity
YVELOCITY   	ds.w  1	; 2 - Y Velocity
ZPOSITION   	ds.w  1	; 1 - Z Position
GRAVITY     	ds.l  1	; 4 - Gravity Effect

ONGROUND    	ds.b  1	; 1 - On Ground Flag
STATIONARY  	ds.b  1	; 1 - Stationary Object
BOUNCESOUND 	ds.b  1	; 1 - Sound To Output On Bounce
DAMP        	ds.b  1	; 1 - Damp Value Used For Bouncing

PICTURE     	ds.w  1	; 2 - Picture Number
BANK        	ds.b  1	; 1 - Object GROM Bank
PALETTE     	ds.b  1	; 1 - Object Palette
CURRENTFRAME	ds.w  1	; 2 - Current Animation Frame
DURATION    	ds.w  1	; 2 - holds #of frames onscreen (not in 60hz)
DURATIONRESET	ds.w  1	; 2 - Saved Duration Count

UPDATEPROC  	ds.l  1	; 4 - Address Of Update Procedure
DISPLAYPROC 	ds.l  1	; 4 - Address Of Display Procedure
NUMBEROFCHARS	ds.w  1	; 2 - Number Of Characters (Text Object)
STARTCHARACTER	ds.w  1	; 2 - Starting Character (Text Object)
ALWAYSROUTINE	ds.l  1	; 4 - Always Execute This Routine

PARENT      	ds.l  1  	; 4 - Pointer To Parent
TEXTPTR		equ   PARENT	;   - Pointer To Text Data
CHILD       	ds.l  1	; 4 - Pointer To Child

DELETED     	ds.b  1	; 1 - Flag For Deleted Object
FLIPFLAG    	ds.b  1	; 1 - Set If Sprite To Be Flipped
LOOPCOUNTER 	ds.w  1	; 2 - Loop Count Used By LOOP Command
ANIMSTEP		ds.w  1	; 2 - Animation Step Count
EXERETURN   	ds.l  1	; 4 - Subroutine Return Address
COUNTER     	ds.w  1	; 1 - this is a all purpose variable 

ANCHORX     	ds.w  1	; 2 - Anchor X Position
ANCHORY     	ds.w  1	; 2 - Anchor X Position
BLITHEIGHT  	ds.w  1	; 2 - Height Of Object
BLITWIDTH   	ds.w  1	; 2 - Width Of Object
FLOPFLAG    	ds.b  1	; 1 - Flop Flag
OBJECTTYPE		ds.b  1	; 1 - Object Type	
XSCALE		ds.w  1	; 2 - X Scale
YSCALE		ds.w  1	; 2 - Y Scale
XCLIP1		ds.w  1   	; 2 - 
XCLIP2		ds.w  1	; 2 - clipx
YCLIP1		ds.w  1	; 2 - 
YCLIP2		ds.w  1	; 2 -

WORLDX		ds.l  1	; 4 - World X Position In Inches
WORLDY		ds.l  1	; 4 - World Y Position In Inches
WORLDZ		ds.l  1	; 4 - World Z Position In Inches
WORLDXVEL		ds.l  1	; 4 - World X Position In Inches
WORLDYVEL		ds.l  1	; 4 - World Y Position In Inches
WORLDZVEL		ds.l  1	; 4 - World Z Position In Inches
ZOFFSET		ds.w  1	; 2 - Distance Off Ground In Screen Pixels

SCALEFACTOR	ds.w  1	; 2 - Scale Based On Screen Position

VELOCITYDECREMENT	ds.w  1	; 2 - Velocity Decrement

VSPRITETYPE	ds.b  1	; 1 - Velocity Sprite Type
FILLER		ds.b  1	; 1 - One Byte Filler

		.endstruct

;***************************************************************************
; Start Of Player Structure Definition		*
;***************************************************************************
player_struct	.struct

PlayerFiller  	ds.b  `sizeof(object_struct) ; 
;*
;* Baseball Player Specific Definitions Follow:
;* 
B_DIRECTION	ds.b  1	; 1 - Player Direction
B_INUSE		ds.b  1	; 1 - Set If Object In Use
B_SEEKING		ds.l  1	; 2 - Set If Seeking A Position
B_DATAPTR     	ds.l  1	; 4 - Address Of Position Information

B_GOALX		ds.l  1	; 4 - World Ending X Position In Inches
B_GOALY		ds.l  1	; 4 - World Ending Y Position In Inches
B_GOALPP		ds.l  1	; 4 - Parse Pointer At Ending Position

B_TORSOBANK   	ds.b  1	; 1 - Torso Bank
B_HEADBANK    	ds.b  1	; 1 - Head Bank
B_HEADPALETTE	ds.b  1	; 1 - Head PALETTE
B_TOPPALETTE	ds.b  1	; 1 - Top Palette
B_BOTPALETTE	ds.b  1	; 1 - Bottom Palette
B_NUMPALETTE	ds.b  1	; 1 - Number Palette

B_FRAMESDATA  	ds.l  1	; 4 - Address Of Frames Data
B_DIRSPRITES	ds.w  8	;16 - Directional Sprites
B_STANDINGFRAME	ds.w  1	; 2 - Player's Standing Frame
B_RUNNINGANIM	ds.l  1	; 4 - Running Animation Pointer
B_RUNNINGEND	ds.l  1	; 4 - Running Animation End
B_RUNNERGOAL	ds.w  1	; 2 - Base Runner Is Heading Toward
B_MOVABLE		ds.b  1	; 1 - Set If Movable By Trackball
B_HASBALL		ds.b  1	; 1 - Set If Object Has The Ball
B_ONBASE		ds.b  1	; 1 - Set If Runner On Base
B_OUT		ds.b  1	; 1 - Set If Runner Is Out
B_FORCED		ds.b  1	; 1 - Set If Runner Was Forced To Run
B_COVERING		ds.b  1	; 1 - Set If Covering A Base
B_ROSTERADR	ds.l  1	; 4 - address of roster entry
B_SLIDING		ds.b  1	; 1 - Set If Runner Is Sliding
B_FORCEBACK	ds.b  1	; 1 - Set If Runner Forced Back To Starting Base
B_ONSCREEN		ds.b  1	; 1 - Set If Player Is On Sreen
B_ONWALL		ds.b  1	; 1 - Set Of Player On the Wall
B_CATCHACTIVE	ds.b  1	; 1 - Set If Player Can Catch
B_FILLET		ds.b  1

		.endstruct

;***************************************************************************
; Start Of Control Structure Definition		*
;***************************************************************************
control_struct	.struct

CONTROLOBJECT	ds.l  1	; 4 - Pointer To Controlled Object
TEAMNUMBER		ds.w  1	; 2 - Team Number 
COMPUTER    	ds.b  1	; 1 - Computer Controlled = 1
DEADFLAG    	ds.b  1	; 1 - Set If Dead
INPUTROUTINE	ds.l  1	; 4 - Input Subroutine Address
AISTATUS		ds.w  1	; 2 - Status Of AI
AICOUNT		ds.w  1	; 2 - Counter Used By AI
AIPAUSE		ds.w  1	; 2 - AI Pause Time

;-------------------------------------------------from SELECT, use to be pinfo

NumberOfTeamPlayers	equ   14 	;if changed check getrec and selectteam

menudataBEGIN 	ds.b  0

letters		ds.b  3 	;THESE MUST BE TOGETHER
month		ds.b  1 	;THESE MUST BE TOGETHER
dayofmonth		ds.b  1 	;THESE MUST BE TOGETHER
team		ds.b  1 	;THESE MUST BE TOGETHER
stat_defeat	ds.b  1	;defeated teams

FILLER1		ds.b  1	; 1 - Filler Byte

stat_win		ds.w  1
stat_lost		ds.w  1
;stat_ba		ds.w  1	;batting average
stat_hits		ds.w  1	;for batting average
stat_atbats		ds.w  1	;for batting average
BeatGame		ds.w  1	;inc every world series win

;went to end
;stat_homeruns 	ds.w  1
;stat_steals 	ds.w  1
;stat_strikeouts 	ds.w  1
stat_lastgame 	ds.w  1

first_pitcher 	ds.b  1
players		ds.b  NumberOfTeamPlayers+1	;number of bbplayers+1
          
present		ds.b  1
YND		ds.b  1
Bcursor		ds.b  1	;ball cursor
Lcursor		ds.b  1	;letter cursor
max_select		ds.w  1
max_input		ds.w  1
bat_order		ds.b  10	;first player (DH) is at bat_order+1
cardX		ds.w  1
dnamex		ds.w  1
dnamexinc		ds.w  1
winCNT		ds.b  1	;count of wins in series
seriesCNT		ds.b  1	;games played in series
checkzum		ds.w  1

menudataEND	ds.b  0

;-------------------------------------------------from SELECT, use to be pinfo


BUTTONS     	ds.b  1	; 1 - Buttons Value
JOYSTICK    	ds.b  1	; 1 - Joystick Value

SPECIALJOY  	ds.w  1	; 2 - Special Joystick Sequence Bits
JOYSEQDATA  	ds.b  96	; 96 - Joystick Sequence Data
			;  ------------------------------------
			;  |   Seq Index    |   Current Tick  |
			;  ------------------------------------
JOYSEQDECAY	ds.b  16	; 16 - Joystick Sequence Decay Ticks

TRACKY		ds.w  1	; 2 - Trackball Y Position
TRACKX		ds.w  1	; 2 - Trackball X Position
TRACKCOUNT  	ds.w  1	; 2 - Trackball Timer
LASTTRACKX		ds.b  1	; 1 - Last Track Ball X Position
LASTTRACKY		ds.b  1	; 1 - Last Track Ball Y Position
LASTTRACKXVEL	ds.w  1	; 2 - Track Ball X Velocity
LASTTRACKYVEL	ds.w  1	; 2 - Track Ball Y Velocity
NEWTRACKX		ds.b  1	; 1 - Track Ball X Position
NEWTRACKY		ds.b  1	; 1 - Track Ball Y Position
TRACKXVEL		ds.w  1	; 2 - Track Ball X Velocity
TRACKYVEL		ds.w  1	; 2 - Track Ball Y Velocity
TRACKXDELTA	ds.w  8	;16 - Last Eight X Deltas
TRACKYDELTA	ds.w  8	;16 - Last Eight X Deltas
TRACKXCNT		ds.w  1	; 2 - Counter Into Delta Table	
TRACKYCNT		ds.w  1	; 2 - Counter Into Delta Table
MAXTRACKXVEL	ds.w  1	; 2 - Track Ball X Velocity
MAXTRACKYVEL	ds.w  1	; 2 - Track Ball Y Velocity

SAVEJOYSTICK	ds.b  1	; 1 - Saved Joystick Value
SAVEBUTTONS	ds.b  1	; 1 - Buttons Saved For NOTSAMEBUTTON Command

IMAX		equ   100
INNINGSSCORE	ds.b  IMAX	;IMAX - Runs Scored By Inning, and as many extra innings as possible

RUNS		ds.b  1	; 1 - Total Runs
HITS		ds.b  1	; 1 - Total Hits
ERRORS		ds.b  1	; 1 - Total Errors
START       	ds.b  1	; 1 - Player Started Flag
			;-1 - Player Dead        (Only Human)
			; 0 - Player Not Started (No Human In Control)
			; 1 - Player Alive       (Human)

NEWBUTTON   	ds.b  1	; 1 - Set If New Button Pressed
BUTTONCOUNT 	ds.b  1	; 1 - Button Delay Timer

LASTJOYSTICK     	ds.b  1	; 1 - Previous Frame's Joystcik Value
STARTBUTTON	ds.b  1	; 1 - Start Button Timeout
FIRSTBUTTON	ds.b  1	; 1 - First Base Button Timeout
SECONDBUTTON	ds.b  1	; 1 - Second Bae Button Timeout
THIRDBUTTON	ds.b  1	; 1 - Third Base Button Timeout
HOMEBUTTON		ds.b  1	; 1 - Home Plate Button Timeout

PLAYERSTEAM	ds.b  14	;14 - players team numbers for drafted team
FIRSTPITCHER	ds.b  1	; 1 - position number of first pitcher
UNUSEDBYTE           ds.b  1
PITAVAIL		ds.l  1	; 4 - pitcher flag bits 0=used, index by pos number
PITCHERSTRENGTH	ds.w  1	; 2 - Pitcher Strength 0-255
BATTINGORDER	ds.b  10	;10 - batting order

ROSTERPTR		ds.l  14	; 56 - points to roster attribute table for each player
BATTERNUM		ds.w  1	; 2 - based batter order count
POWERUP		ds.b  1	; 1 - Powerup Flag
INNINGSBOUGHT	ds.b  1	; 1 - innings paid for
TICKETXPOS		ds.w  1	; 2 - x position of sliding buyin tickets
TOTALPOWER		ds.w  1	; 2 - Total amount of power for PowerUp
ALLSAMEADR		ds.l  1	; 4 - roster adr of player for whole team

POWERTHROW		ds.b  1	; 1 - Set if throw is going to be a Power throw.
POWERNUM		ds.b  1	; 1 - Set to the number of the powerup.
RAWBUTTONS		ds.b  1	; 1 - Raw Button Values
BOZOFACTOR		ds.b  1	; 1 - How Big An Idiot Is The Player?

stat_homeruns 	ds.w  1
stat_steals 	ds.w  1
stat_strikeouts 	ds.w  1
SpecialTeam		ds.w  1	;1=preset initials were entered

HOMERUNSCNT	ds.w  1	; 2 - count of home runs hit
STEALSCNT		ds.w  1	; 2 - count of steals
STRIKEOUTSCNT	ds.w  1	; 2 - count of strikeouts by pitcher
ATBATSCNT		ds.w  1	;count of at bats for batting average
BEANCNT		ds.w  1	;count walks for batting average
		.endstruct

;***************************************************************************		         
NUMBLOCKS   	equ 30	; Number Of Object Blocks

FRICTION    	equ 84	; 64
YBIAS       	equ -96
PLAYERY		equ 40+16
TORSOZ		equ 63
BUTTONUPDECAY	equ 6	; Time Before Button Up Deacys
MPH		equ 100
METERZ		equ 216
BALLGRAVITY 	equ 90

;***************************************************************************
; Batting Positions			*
;***************************************************************************
L    equ  0       ;Left
R    equ  1       ;Right
S    equ  2       ;Switch

;***************************************************************************
; Fielding Positions			*
;***************************************************************************
PITCHER	 	equ  0
CATCHER		equ  1	 
FIRSTBASEMAN 	equ  2
SECONDBASEMAN 	equ  3
SHORTSTOP	 	equ  4
THIRDBASEMAN 	equ  5
LEFTFIELD	 	equ  6
CENTERFIELD 	equ  7
RIGHTFIELD	 	equ  8

;***************************************************************************
; Switch To Field Reasons		*
;***************************************************************************
BALLHIT		equ 1	; Batter Hit Ball
PICKOFFFIRST	equ 2	; Pick Off At First
PICKOFFSECOND	equ 3	; Pick Off At Second
PICKOFFTHIRD	equ 4	; Pick Off At Third
PICKOFFHOME	equ 5	; Pick Off At Home
BACKFROMHOME	equ 6	;coming back from the play at home

;***************************************************************************
; Interesting Positions		*
;***************************************************************************
HOMEPLATEX		equ 0
HOMEPLATEY		equ 0

FIRSTBASEX		equ 763*256
FIRSTBASEY		equ 763*256

SECONDBASEX	equ 0
SECONDBASEY	equ 1527*256

THIRDBASEX		equ -763*256
THIRDBASEY		equ 763*256

PITCHERX		equ 0
PITCHERY		equ 726*256

;***************************************************************************
; Timer Statuses			*
;***************************************************************************
T_RUNNING		equ 0
T_GAMEOVER		equ 1
T_PREGAME		equ 2
T_TIMEOUT		equ 3

;***************************************************************************
; Background Object Types		*
;***************************************************************************
NORMAL	equ	0
SKEW	equ	1	; Normal Skew   (Floor)
SKEWI	equ	2	; Inverted Skew (Roof)
DEFINE	equ	3	; Special Blit
ANCHORED	equ	4	; Anchored Object
FLOATING	equ	5	; Floating Object (Sine Table)
REPEATING	equ	6	; Repeating Object
REPSKEW	equ	7	; Repeating Skewed Object
TEXT	equ	8	; Text Object
SCALED	equ	9	; Scaled Object
FLOPPED	equ	10	; Flopped Object
CLIPPED	equ	11	; Clipped Object
SKEWFAST	equ	12	; Skewed Larger sizes
OSCALED	equ	13	; OScaled Object
CTEXT	equ	14	;special clipped text
HOST	equ	15	; Special Host Object
CLIPSET	equ	16	; Clipped Using Set Value

FLIP	equ	2
NOFLIP	equ	0

FIXED	equ	1
MOVEABLE	equ	0

ON	equ	0x01
OFF	equ	0x00

;***************************************************************************
; Frame Data Block Equates                                                 *
;***************************************************************************
;Index Label	Bytes Needed	Equate	Offset into Table	

Torso	equ	0	
TorsoX   	equ	2	
TorsoY	equ	3	

Legs	equ	4
LegsX	equ	6	
LegsY	equ	7

Bat	equ	8
BatX	equ	10
BatY	equ	11
BatFF	equ	12

HBall	equ	8
HBallX	equ	10
HBallY	equ	11

Tens	equ	13
TensX	equ	15
TensY	equ	16

Units	equ	17
UnitsX	equ	19
UnitsY	equ	20

Head	equ	21
HeadX	equ	22
HeadY	equ	23

Shadow	equ	21
ShadowX	equ	22
ShadowY	equ	23


