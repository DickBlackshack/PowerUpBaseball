;***************************************************************************
;                   INCREDIBLE TECHNOLOGIES, INC.                          *
;                    (C) COPYRIGHT 1995, IT, INC.                          *
;***************************************************************************
	.region	"RomCode"
	ds	0

Shad01	equ	0
ball  	equ	0

club0132	equ	0
bf2ab003	equ	0
bf2at004	equ	0
bf2ab004	equ	0
bf2at005	equ	0
bf2ab005	equ	0
bf2at006	equ	0
bf2ab006	equ	0
bf2at007	equ	0
bf2ab007	equ	0
bf2at008	equ	0
bf2ab008	equ	0
bf2at009	equ	0
bf2ab009	equ	0
bf2at011	equ	0
bf2ab011	equ	0
bf2at012	equ	0
bf2ab012	equ	0
bf2at013	equ	0
bf2ab013	equ	0
bf2at014	equ	0
bf2ab014	equ	0
bf2at015	equ	0
bf2ab015	equ	0
bf2at016	equ	0
bf2ab016	equ	0

UNUSED	equ	-1


	#include	"groms.h"
	.export	Player
	.align 2
Player:
;	#include "q:\baseball\art\tables\plyrtab"
;	#include "q:\baseball\art\tables\plyrfrms"
	#include "plyrtab"
	#include "plyrfrms"

	end

