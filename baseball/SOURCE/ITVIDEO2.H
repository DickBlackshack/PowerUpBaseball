;****************************************************************************
;	 	      IT'S IT42 ASIC EQUATES                           *
;                        INCREDIBLE TECHNOLOGIES, INC.                      *
;                        (C) COPYRIGHT 1994, IT, INC                        *
;****************************************************************************
;                  
;Memory Map:
;

NEWBRDFCT	equ	2


FADE_MAX   equ       120	;96
VRAMCOL	equ	2048	;512
VRAMPAGE	equ	2048	;512
SCR_WIDTH	equ	512	; Screen Width
SCR_HEIGHT	equ	256	; Screen Height
PICMODE	equ	0x40000

RAM	equ	0x400
;RAMSIZE	equ	0x20000-0x400	;was $7c00
RAMSIZE	equ	0x7c00	;was $7c00
STACK	equ	RAM+RAMSIZE	;Last page of ram is for the stack

VIDEO 	equ	$c0000*NEWBRDFCT
ASIC	equ	$500000
          
; read registers
A_STATUS	equ	ASIC	; Chip Status Register      ( 8-bits)
A_ISTATUS	equ	ASIC+(2*2)	; Interrupt Status Register ( 8-bits)
;A_USERREG	equ	ASIC+(4*2)	; User Data Register        ( 8-bits)
A_HLINE	equ	ASIC+(6*2)	; Horizontal Line Count     (12-bits)

; write registers
A_MODE0	equ	ASIC	; Mode Register 0           ( 8-bits)
A_INTCLR	equ	ASIC+(2*2)	; Interrupt Clear Register  ( 8-bits)
A_USERREG	equ	ASIC+(4*2)	; User Data Register        ( 8-bits)
A_MODE1	equ	ASIC+(6*2)	; Mode Register 1           (16-bits)
A_STATE	equ	ASIC+(8*2)	; State Machine Command     ( 4-bits)
A_INTMASK	equ	ASIC+(10*2)	; Interrupt Mask Register   (10-bits)
A_HEIGHT	equ	ASIC+(12*2)	; Height Register           (10-bits)
A_WIDTH	equ	ASIC+(14*2)	; Width Register            (12-bits)
A_GROMADR	equ	ASIC+(16*2)	; GROM Address Register     (16-bits)
A_STARTX	equ 	ASIC+(18*2)	; Starting X Address        (12-bits)
A_STARTY	equ	ASIC+(20*2)	; Starting Y Address        (12-bits)
A_VSCALE	equ	ASIC+(22*2)	; Source Vertical Scale Reg.(16-bits)
A_HSCALE	equ	ASIC+(24*2)	; Source Horiz. Scale Reg.  (16-bits)
A_PIXDX 	equ	ASIC+(26*2)	; Dest. Pixel Delta-X Reg.  ( 8-bits)
A_ROWDY 	equ	ASIC+(28*2)	; Dest. Row Delta-Y Reg.    ( 8-bits)
A_PIXDY 	equ	ASIC+(30*2)	; Dest. Pixel Delta-Y Reg.  ( 8-bits)
A_ROWDX 	equ	ASIC+(32*2)	; Dest. Row Delta-X Reg.    ( 8-bits)
A_GROMWAIT	equ	ASIC+(34*2)	; GROM Wait State Register  ( 8-bits)   
A_LEFTCLIP	equ	ASIC+(36*2)	; Left Clip Window          (12-bits)
A_RGHTCLIP	equ	ASIC+(38*2)	; Right Clip Window         (12-bits)
A_TOPCLIP	equ	ASIC+(40*2)	; Top Clip Window           (12-bits)
A_BOTCLIP	equ	ASIC+(42*2)	; Bottom Clip Window        (12-bits)
A_HLINECP	equ	ASIC+(44*2)	; Horiz. Line INT Compare   (12-bits)
A_GROMSEG	equ	ASIC+(46*2)	; GROM Segment Register     ( 8-bits)
A_XINTSEL	equ	ASIC+(48*2)	; XINT Interrupt Select Reg ( 8-bits)
A_PLN0YTP	equ	ASIC+(68*2)	; Plane 0 Y Tap Point       (16-bits)
A_PLN1YTP	equ	ASIC+(70*2)	; Plane 1 Y Tap Point       (16-bits)
A_PLN2YTP	equ	ASIC+(72*2)	; Plane 2 Y Tap Point       (16-bits)
A_PLN3YTP	equ	ASIC+(74*2)	; Plane 3 Y Tap Point       (16-bits)
A_PLN0XTP	equ	ASIC+(76*2)	; Plane 0 X Tap Point       (16-bits)
A_PLN1XTP	equ	ASIC+(78*2)	; Plane 1 X Tap Point       (16-bits)
A_PLN2XTP	equ	ASIC+(80*2)	; Plane 2 X Tap Point       (16-bits)
A_PLN3XTP	equ	ASIC+(82*2)	; Plane 3 X Tap Point       (16-bits)

A_DCDX	equ	ASIC+(24*2)	;LJH delta color over x (8 bit int, 8 bit frac)
A_DCDY     equ	ASIC+(128*2)	;LJH delta color over y (8 bit int, 8 bit frac)
A_DX1DY_L  equ	ASIC+(130*2)	;LJH left side delta x over y (16 bit)
A_DX1DY_H  equ	ASIC+(132*2)	;LJH left side delta x over y (4 bit)
A_DX2DY_L  equ	ASIC+(134*2)	;LJH right side delta x over y (16 bit)
A_DX2DY_H  equ	ASIC+(136*2)	;LJH right side delta x over y (4 bit)

; Z-buffer equates
ZBUF	equ	$80000*NEWBRDFCT	;LJH z buffer base address
Z_DZDX	equ	ZBUF+0	;LJH delta x over z (16 bit)
Z_DZDY	equ	ZBUF+4	;LJH delta y over z (16 bit)
Z_START_Z	equ	ZBUF+8	;LJH start z (16 bit int)
Z_XFER	equ	ZBUF+12

; Asic State Commands

NOOP	equ	0	; No Operation
BLITU	equ	1	; Blit Uncompressed
BLITC	equ	2	; Blit Compressed
HOSTWRITE	equ	3	; Host Write To VRAM
HOSTREAD	equ	4	; Host Read From VRAM
VRAM2SHIFT	equ	5	; VRAM To Shift Register Transfer
CLEARSCR	equ	6	; Clear Screen
SHIFT2VRAM	equ	7	; VRAM Shift Register To VRAM Transfer

; Interrupt Bits

BLITCLIP	equ	00000010b	; Blit In Clip Interrupt
HLINE	equ	00000100b	; HLINE Interrupt
EOBLIT	equ	00001000b	; End Of Blit Interrupt
SPECIAL	equ	00010000b	; Special Function Interrupt
VBLANK	equ	00100000b	; Vertical Blank Interrupt
XFER	equ	01000000b	; XFER Interrupt

BLITCLIP_B	equ	1	; Blit In Clip Interrupt
HLINE_B	equ	2	; HLINE Interrupt
EOBLIT_B	equ	3	; End Of Blit Interrupt
SPECIAL_B	equ	4	; Special Function Interrupt
VBLANK_B	equ	5	; Vertical Blank Interrupt
XFER_B	equ	6	; XFER Interrupt

; ASIC Status Bits

VSACTIVE	equ	00000001b	; Set If Vertical Sync Is Active
HBACTIVE	equ	00000010b	; Set If Horizontal Blank Is Active
VBACTIVE	equ	00000100b	; Set If Vertical Blank Is Active
DATAREG	equ	00001000b	; Set If HOSTWRITE Register Is Full
GROMBUS	equ	00010000b	; Set If GROM Bus Is Active
DATARDY	equ	00100000b	; Set If HOSTREAD Data Is Ready
CMDREG	equ	01000000b	; Set If Command Register Is Full
IDLE	equ	10000000b	; Set If ASIC Is Idle

VSACTIVE_B	equ	0	; Set If Vertical Sync Is Active
HBACTIVE_B	equ	1	; Set If Horizontal Blank Is Active
VBACTIVE_B	equ	2	; Set If Vertical Blank Is Active
DATAREG_B	equ	3	; Set If HOSTWRITE Register Is Full
GROMBUS_B	equ	4	; Set If GROM Bus Is Active
DATARDY_B	equ	5	; Set If HOSTREAD Data Is Ready
CMDREG_B	equ	6	; Set If Command Register Is Full
IDLE_B	equ	7	; Set If ASIC Is Idle

; 
; ASIC Mode Register 1
;

;	bit	0	; Enable/Disable Transparency     (1/0)
;	bil	1	; Enable/Disable Flip             (1/0)
;	bit	2	; Enable/Disable Flop             (1/0)
;	bit	3	; Enable/Disable Rotation         (1/0)	
;	bit	4	; End-Of-Row DX Positive/Negative (1/0)
;	bit	5	; End-Of-Row DY Positive/Negative (1/0)
;	bit	6-7	; 1, 2, 4 Byte Wide VRAM bus
;	bit	8	; Enable/Disable GROM Look-Ahead  (1/0)
;	bit	9	; Lower/Upper Nibble GROM Wait    (1/0)
;	bit	10	; Enable/Disable Clipping         (1/0)
;	bit	11	; 4/8 Bits-Per-Pixel              (1/0)
;	bit	12	; Wrap/Clip Out-Of-Bounds Pixels  (1/0)
;	bit	13	; OPTION Register
;	bit	14	; Enable/Disable Interrupts       (1/0)
;	bit	15	; Comp/Non-Comp End-Of-Row Calc.  (1/0)

SOUND	equ	$480001	;Sound port.
;
PALETTES	equ	$580000
;
; Plane Enables
;
LED		equ	1111111000000000B
PLANEA	equ	1111110100000000B	;ljh, bit 0 = 
PLANEB	equ	1111101100000000B	;ljh
PLANEPALINIT equ ((~PLANEA|~PLANEB)&LED)	;both planes off, led on pals 0, config 0
PLANE	equ	$700000	; -------x LED
			; ------x- Plane A Enable
			; -----x-- Plane B Enable
			; ---x---- Palette Configuration


PALSELA	equ	$300000
PALSELB	equ	$380000	; -xxxxxxx Planes B&C Palette

WATCHDOG	equ	$400000
SECURITY	equ	$680000	; Security Chip

			

; Input\Output
;
PLYRIN1	equ	$80001	; SWITCH A
			; 8 x------- Player 1 Up  
			; 7 -x------ Player 1 Down  
			; 6 --x----- Player 1 Left
			; 5 ---x---- Player 1 Right
			; 4 ----x--- Player 1 Button 2
			; 3 -----x-- Player 1 Button 1
			; 2 ------x- Player 1 Start
			; 1 -------x Player 1 Coin

PLYRIN2	equ	$100001	; SWITCH B
			;16 x------- Player 2 Up
			;15 -x------ Player 2 Down
			;14 --x----- Player 2 Left
			;13 ---x---- Player 2 Right
			;12 ----x--- Player 2 Button 2
			;11 -----x-- Player 2 Button 1
			;10 ------x- Player 2 Start
			; 9 -------x Player 2 Coin

PLYRIN3	equ	$180001	; SWITCH C
			;24 x------- Player 2 Button 6
			;23 -x------ Player 1 Button 6
			;22 --x----- Player 2 Button 5
			;21 ---x---- Player 1 Button 5
			;20 ----x--- Player 2 Button 4
			;19 -----x-- Player 1 Button 4
			;18 ------x- Player 2 Button 3
			;17 -------x Player 1 Button 3


PLYRIN4	equ	$200001	; SWITCH D
			;32 x------- Unused
			;31 -x------ Unused
			;30 --x----- Unused
			;29 ---x---- Unused
			;28 ----x--- Unused
			;27 -----x-- Unused
			;26 ------x- Unused
			;25 -------x Unused

DIPS	equ	$280001
			;40 x------- Dip 4 (User Service)
			;39 -x------ Dip 3 (Violence)
			;38 --x----- Dip 2 (2/4 Player)
			;37 ---x---- Dip 1 (Sync Inv)
			;36 ----x--- SIRQ
			;35 -----x-- VINT
			;34 ------x- Service Switch
			;33 -------x Test Switch

SWITCHE	equ	$780001
			;48 x------- Unused
			;47 -x------ Unused
			;46 --x----- Unused
			;45 ---x---- Unused
			;44 ----x--- Unused
			;43 -----x-- Unused
			;42 ------x- Unused
			;41 -------x Unused

SERIALPORT	equ	$200400	; Serial Port


TRACKPORT1	equ	$180801
TRACKPORT2	equ	$181001


; Read Addresses
MR1A	equ	SERIALPORT+0x00	; Mode Register 1A
MR2A	equ	SERIALPORT+0x00	; Mode Register 2A
SRA	equ	SERIALPORT+0x02	; Status Register A
BRGTEST	equ	SERIALPORT+0x04	; Baud Rate Generator Test
RHRA	equ	SERIALPORT+0x06	; Rx Holding Register A
IPCR	equ	SERIALPORT+0x08	; Input Port Change Register
ISR	equ	SERIALPORT+0x0A	; Interrupt Status Register
CTU	equ	SERIALPORT+0x0C	; Counter/Timer Upper
CTL	equ	SERIALPORT+0x0E	; Counter/Timer Lower
MR1B	equ	SERIALPORT+0x10	; Mode Register 1B
MR2B	equ	SERIALPORT+0x10	; Mode Register 2B
SRB	equ	SERIALPORT+0x12	; Status Register B
TEST16X	equ	SERIALPORT+0x14	; 1X/16X Test
RHRB	equ	SERIALPORT+0x16	; Rx Holding Register B
IVR	equ	SERIALPORT+0x18	; Interrupt Vector Register
INPORT	equ	SERIALPORT+0x1A	; Input Port
STARTCC	equ	SERIALPORT+0x1C	; Start Counter Command
STOPCC	equ	SERIALPORT+0x1E	; Stop Counter Command

; Write Addresses
;MR1A	equ	SERIALPORT+0x00	; Mode Register 1A
;MR2A	equ	SERIALPORT+0x00	; Mode Register 2A
CSRA	equ	SERIALPORT+0x02	; Clock Select Register A
CRA	equ	SERIALPORT+0x04	; Command Register A
THRA	equ	SERIALPORT+0x06	; Tx Holding Register A
ACR	equ	SERIALPORT+0x08	; Aux. Control Register
IMR	equ	SERIALPORT+0x0A	; Interrupt Mask Register
CRUR	equ	SERIALPORT+0x0C	; Counter/Timer Upper Register
CTLR	equ	SERIALPORT+0x0E	; Counter/Timer Lower Register
;MR1B	equ	SERIALPORT+0x10	; Mode Register 1B
;MR2B	equ	SERIALPORT+0x10	; Mode Register 2B
CSRB	equ	SERIALPORT+0x12	; Clock Select Register B
CRB	equ	SERIALPORT+0x14	; Command Register B
THRB	equ	SERIALPORT+0x16	; Tx Holding Register B
;IVR	equ	SERIALPORT+0x18	; Interrupt Vector Register
OPCR	equ	SERIALPORT+0x1A	; Output Port Conf. Register
SOPBC	equ	SERIALPORT+0x1C	; Set Output Port Bits Command
ROPBC	equ	SERIALPORT+0x1E	; Reset Output Port Bits Command



