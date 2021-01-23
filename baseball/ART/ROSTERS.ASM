;***************************************************************************
;                      BASEBALL VIDEO GAME                                 *
;                   INCREDIBLE TECHNOLOGIES, INC.                          *
;                    (C) COPYRIGHT 1995,1996 IT, INC.                      *
;***************************************************************************

	.export ROSTERS,AlphaOrder,DraftAttr
	.export attrib_size,teamattrib_size,ROSTERsize

;	.export NumberOfTeams
	.export NumberOfParms

	#include        "groms.h"
	#include        "pals.h"

	.region   "RomCode"


;L   equ  $98
;M   equ  $90
;S   equ  $80

;L   equ  $ff
;M   equ  $ff
;S   equ  $ff
;LH  equ  $ff
;MH  equ  $ff
;SH  equ  $ff

;L    equ  $a0
;M    equ  $9c
;S    equ  $98


;LH   equ  $b0
;MH   equ  $a0
;SH   equ  $98

W    equ  0
B    equ  2
H    equ  1

L    equ  0
R    equ  1
S    equ  2



ATTRIB  MACRO
	dc.b	\1	; 0 - R_ETHNICITY 
	dc.b	\2	; 1 - R_NUMBERS
	dc.b	\3	; 2 - R_NUMBERS
	dc.b	\4	; 3 - R_WEIGHT
	dc.b	\5	; 4 - R_HEIGHT
	dc.b	\6	; 5 - R_BATAVG

	dc.b	\7	; 6 - R_POWER	
	dc.b	\8	; 7 - R_SPEED	
	dc.b	\9	; 8 - R_RANGE	
	dc.b	\A	; 9 - R_GLOVE	
	dc.b	\B	;10 - R_ARM	
	dc.b	\C	;11 - Head
	dc.b	\D	;12 - Hair
	dc.b	\E	;13 - Batting Order
	dc.b	\F	;14 - Pitch Type
	dc.b	\G	;15 - Bat
	dc.b	\H	;16 - Throw

;	dc.b	154+(101*\7)/100	;17 - Normalized R_POWER	
	dc.b	154+(86*\7)/100	;17 - Normalized R_POWER	
	dc.b	103+(50*\8)/56	;18 - Normalized R_SPEED	
	dc.b	103+(50*\9)/56	;19 - Normalized R_RANGE	
	dc.b	103+(50*\A)/56	;20 - Normalized R_GLOVE	
	dc.b	103+(50*\B)/56	;21 - Normalized R_ARM	

	dc.b	\I	;22 - Name
	dc.b	\J	;35 - Terminator
	dc.w	\K 	;36 - card
	dc.w	\L 	;38 - pal
	dc.w	\M 	;40 - headart
	dc.w	\N 	;42 - namesnd
	dc.w	\O 	;44 - nameart
	ENDM


NumberOfParms   equ     18


AlphaOrder
 dc.b     06,05,02,11,21,03,10,27,01,16,19,12,13,23,20,25,15,07,24,18,00,22,16,17,04,09,08,14 ; 1 - DH            
 dc.b     07,23,20,21,11,03,09,16,18,01,17,10,05,00,12,24,27,14,08,22,13,26,04,02,19,06,15,25 ; 2 - CATCHER
 dc.b     11,17,24,26,10,09,07,08,04,14,20,23,13,21,22,18,00,19,06,27,01,16,03,25,15,05,02,12 ; 3 - 1ST BASE
 dc.b     01,07,22,11,06,27,25,02,13,05,21,19,18,17,15,16,00,09,14,26,20,23,12,04,24,03,10,08 ; 4 - 2ND BASE
 dc.b     10,21,00,19,23,22,03,24,13,26,09,27,16,05,18,06,15,11,12,01,25,04,20,02,14,17,07,08 ; 5 - SHORTSTOP
 dc.b     17,16,11,13,18,06,19,23,08,25,09,22,21,15,00,12,04,02,26,10,14,27,01,07,05,03,24,20 ; 6 - 3RD BASE
 dc.b     16,03,13,07,19,08,24,25,27,06,10,15,20,22,17,04,26,12,02,01,23,09,14,00,21,11,05,18 ; 7 - LEFT FIELD
 dc.b     01,15,08,13,14,09,12,20,03,23,25,00,26,19,02,06,11,17,21,22,05,07,04,27,18,24,10,16 ; 8 - CENTER FIELD
 dc.b     11,01,25,17,27,26,23,24,22,00,21,14,13,12,02,09,15,07,03,06,10,04,16,05,08,20,18,19 ; 9 - RIGHT FIELD
 dc.b     23,09,14,10,02,18,11,16,05,24,03,12,27,17,25,00,13,01,07,04,21,15,08,26,20,06,22,19 ; 10 - STARTER 1          
 dc.b     03,05,12,04,01,00,18,26,23,27,25,17,09,21,07,16,20,22,13,19,10,11,15,08,02,06,14,24 ; 11 - STARTER 2          
 dc.b     15,00,05,25,24,04,20,10,17,07,12,14,03,09,22,26,16,18,06,27,08,11,13,23,19,21,02,01 ; 12 - STARTER 3          
 dc.b     03,22,10,06,13,16,21,20,04,02,27,11,26,19,05,14,07,01,09,12,17,08,15,18,00,23,24,25 ; 13 - STARTER 4          
 dc.b     24,02,06,27,25,09,19,14,17,22,26,05,23,08,04,11,07,21,12,01,10,16,20,03,15,18,00,13 ; 14 - CLOSER 1           


;AlphaOrder
; dc.b     21,09,03,06,25,02,01,18,27,26,07,04,12,13,28,17,10,24,20,11,15,05,22,14,19,16,23,08 ; 1 - DH            
; dc.b     14,10,24,06,23,13,26,01,19,07,12,05,15,21,18,27,08,11,09,25,03,04,20,02,16,28,22,17 ; 2 - CATCHER
; dc.b     17,21,27,23,09,26,19,07,08,06,05,01,28,13,10,25,22,02,16,18,11,14,15,12,03,24,04,20 ; 3 - 1ST BASE
; dc.b     17,01,08,26,24,10,05,02,28,18,27,04,23,09,19,15,16,14,13,12,21,11,03,22,25,07,20,06 ; 4 - 2ND BASE
; dc.b     03,20,24,07,22,14,16,27,28,11,01,18,19,09,25,17,13,26,15,04,23,02,06,05,08,21,10,12 ; 5 - SHORTSTOP
; dc.b     15,23,18,26,17,25,06,24,09,11,20,03,16,04,21,14,02,01,05,07,28,13,12,08,27,10,19,22 ; 6 - 3RD BASE
; dc.b     24,20,19,02,16,27,10,04,06,22,11,26,18,03,23,12,01,15,28,05,13,25,14,21,07,08,17,09 ; 7 - LEFT FIELD
; dc.b     12,01,15,09,23,21,16,22,03,06,27,17,07,04,05,02,28,18,25,14,08,19,20,10,26,11,13,24 ; 8 - CENTER FIELD
; dc.b     10,02,15,19,22,24,20,18,25,16,21,01,14,13,12,17,23,04,27,28,26,11,09,07,08,03,06,05 ; 9 - RIGHT FIELD
; dc.b     16,18,05,11,20,09,26,19,23,02,04,07,12,17,03,22,08,14,06,28,25,21,27,01,10,15,24,13 ; 10 - STARTER 1          
; dc.b     06,05,25,01,04,02,26,15,24,13,21,22,03,19,27,23,16,12,07,20,17,14,18,09,28,11,08,10 ; 11 - STARTER 2          
; dc.b     02,28,27,13,06,03,19,10,21,14,08,22,11,23,12,01,17,09,18,25,07,26,15,24,05,04,16,20 ; 12 - STARTER 3          
; dc.b     25,18,10,01,09,15,04,17,22,19,03,12,20,05,16,23,06,21,24,14,08,07,02,26,27,28,13,11 ; 13 - STARTER 4          
; dc.b     27,20,02,24,15,12,03,17,14,06,21,16,19,28,08,25,22,09,26,07,23,18,10,13,01,05,11,04 ; 14 - CLOSER 1           


ROSTERS:

; Ethicity,Numbers,Weight,Height,Bat.Avg,Power,Speed,Range,Glove,Arm,ERA,Head,Hair,Order,PitchType,Bat,Throw,Name,Terminator,Card,cardPal,headart,namesnd,nameart
AtlantaAttr:                                                             
	         ;E # # W H  AV PW SP RG GL AR H H O P B T  Name           T Card     Pal    headart  snd nameart
	ATTRIB    B,0,7,5,5,140,42,22,00,00,15,2,0,9,0,L,R,"SMITH        ",0,card0101,P_BRAV,h0101v1a,001,name0101 ;	1 - DH           
Att_end 	ATTRIB    W,0,8,4,7,158,80,30,20,25,25,1,0,7,0,R,R,"LOPEZ        ",0,card0102,P_BRAV,h0102v1a,000,name0102 ;	2 - CATCHER         
	ATTRIB    B,2,7,7,7,140,88,24,28,30,25,2,0,4,0,L,L,"MCGRIFF      ",0,card0103,P_BRAV,h0103v1a,002,name0103 ;	3 - 1ST BASE        
	ATTRIB    W,2,0,4,2,127,13,20,38,36,25,0,0,2,0,S,R,"LEMKE        ",0,card0104,P_BRAV,h0104v1a,000,name0104 ;4 - 2ND BASE          	                 
	ATTRIB    W,0,4,6,4,106,65,24,28,30,27,0,1,8,0,R,R,"BLAUSER      ",0,card0105,P_BRAV,h0105v1a,000,name0105 ;5 - SHORTSTOP     	                 
	ATTRIB    W,1,0,7,5,133,81,36,24,16,05,0,0,3,0,S,R,"JONES        ",0,card0106,P_BRAV,h0106v1a,003,name0106 ;	6 - 3RD BASE     
	ATTRIB    W,1,8,8,7,155,92,05,18,20,15,0,0,6,0,L,L,"KLESKO       ",0,card0107,P_BRAV,h0107v1a,004,name0107 ;	7 - LEFT FIELD    
	ATTRIB    B,0,9,5,5,129,53,43,46,40,40,2,0,1,0,R,R,"GRISSOM      ",0,card0108,P_BRAV,h0108v1a,000,name0108 ;	8 - CENTER FIELD 
	ATTRIB    H,2,3,6,7,127,88,34,28,30,45,1,0,5,0,L,L,"JUSTICE      ",0,card0109,P_BRAV,h0109v1a,005,name0109 ;	9 - RIGHT FIELD  
	ATTRIB    W,3,1,3,5,249,73,30,36,38,25,0,0,0,0,R,R,"MADDUX       ",0,card0110,P_BRAV,h0109v1a,006,name0110 ; 10 - STARTER 1     	                 
	ATTRIB    W,4,7,5,6,176,48,28,24,24,25,0,0,0,0,L,L,"GLAVINE      ",0,card0111,P_BRAV,h0109v1a,000,name0111 ; 11 - STARTER 2      	                 
	ATTRIB    W,2,9,4,7,171,88,42,25,25,25,0,0,0,0,R,R,"SMOLTZ       ",0,card0112,P_BRAV,h0109v1a,000,name0112 ; 13 - STARTER 4     	                 
	ATTRIB    W,3,3,6,7,097,68,34,24,24,25,0,0,0,0,L,L,"AVERY        ",0,card0113,P_BRAV,h0109v1a,000,name0113 ; 12 - STARTER 3    	                 
	ATTRIB    W,4,3,6,7,226,99,52,18,25,25,0,0,0,0,R,R,"WOHLERS      ",0,card0114,P_BRAV,h0109v1a,000,name0113 ; 14 - CLOSER 1      	                 
Atl_end                                                                                   	       	                     
BaltAttr:			                                   	       	                 	   	
	         ;E # # W H AV  PW SP RG GL AR H H O P B T   		       	                 	   	
	ATTRIB    B,2,6,9,7,167,81,24,26,28,35,0,0,4,0,S,R,"BONILLA      ",0,card0201,P_ORIO,h0201v1a,011,name0201 ;	6 - 3RD BASE     
	ATTRIB    W,2,3,7,5,125,87,04,18,30,20,0,0,7,0,R,R,"HOILES       ",0,card0202,P_ORIO,h0202v1a,000,name0202 ;	2 - CATCHER      
	ATTRIB    H,2,5,4,5,155,92,34,30,34,36,0,0,3,0,L,L,"PALMEIRO     ",0,card0203,P_ORIO,h0203v1a,000,name0203 ;	3 - 1ST BASE     
	ATTRIB    H,1,2,4,5,150,60,42,54,54,40,0,0,2,0,S,R,"ALOMAR       ",0,card0204,P_ORIO,h0204v1a,007,name0204 ;	4 - 2ND BASE     
	ATTRIB    W,0,8,8,7,131,70,24,35,38,34,0,0,5,0,R,R,"RIPKEN       ",0,card0205,P_ORIO,h0205v1a,008,name0205 ;	5 - SHORTSTOP    
	ATTRIB    W,0,5,6,6,160,70,13,25,26,24,0,0,6,0,L,R,"SURHOFF      ",0,card0206,P_ORIO,h0206v1a,009,name0206 ;	7 - LEFT FIELD   
	ATTRIB    B,1,1,9,7,167,81,45,42,34,14,0,0,8,0,R,R,"HAMMONDS     ",0,card0207,P_ORIO,h0207v1a,000,name0207 ;	6 - 3RD BASE     
	ATTRIB    W,0,9,5,6,131,90,44,46,38,36,0,0,1,0,L,L,"ANDERSON     ",0,card0208,P_ORIO,h0208v1a,010,name0208 ;	7 - LEFT FIELD   
	ATTRIB    B,1,0,5,5,140,42,28,26,24,24,0,0,9,0,L,L,"DEVEREAUX    ",0,card0209,P_ORIO,h0209v1a,000,name0209 ;	1 - DH            
	ATTRIB    W,3,5,4,6,165,71,36,30,25,25,0,0,0,0,R,R,"MUSSINA      ",0,card0210,P_ORIO,h0209v1a,000,name0210 ; 10 - STARTER 1    	                 
	ATTRIB    W,3,6,8,7,150,61,28,25,25,25,0,0,0,0,L,L,"WELLS        ",0,card0211,P_ORIO,h0209v1a,000,name0211 ; 13 - STARTER 4                     
	ATTRIB    W,2,1,8,7,089,54,36,25,25,25,0,0,0,0,R,R,"ERICKSON     ",0,card0212,P_ORIO,h0209v1a,000,name0212 ; 11 - STARTER 2                                      
	ATTRIB    W,2,1,3,5,070,50,30,25,25,25,0,0,0,0,L,L,"MERCKER      ",0,card0213,P_ORIO,h0209v1a,000,name0213 ; 13 - STARTER 4                     
	ATTRIB    W,2,8,9,6,136,95,42,25,25,25,0,4,0,0,L,L,"MYERS        ",0,card0214,P_ORIO,h0209v1a,000,name0214 ; 14 - CLOSER 1                      
					                        
BostonAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    W,3,3,9,7,153,88,29,22,22,30,0,0,4,0,R,R,"CANSECO      ",0,card0301,P_REDX,h0301v1a,012,name0301 ;	1 - DH           
	ATTRIB    W,2,2,5,5,134,82,03,18,24,15,0,0,9,0,R,R,"STANLEY      ",0,card0302,P_REDX,h0302v1a,000,name0302 ;	2 - CATCHER      
	ATTRIB    B,4,2,9,6,150,92,14,18,20,24,0,0,3,0,L,R,"VAUGHN       ",0,card0303,P_REDX,h0303v1a,013,name0303 ;	3 - 1ST BASE     
	ATTRIB    H,1,2,5,6,143,47,33,20,22,25,0,0,6,0,R,R,"CORDERO      ",0,card0304,P_REDX,h0304v1a,000,name0304 ;	5 - SHORTSTOP    
	ATTRIB    W,1,3,4,5,149,86,30,25,26,38,0,0,2,0,R,R,"VALENTIN     ",0,card0305,P_REDX,h0305v1a,014,name0305 ;	5 - SHORTSTOP    
	ATTRIB    W,1,1,6,6,154,57,18,30,34,48,0,0,7,0,R,R,"NAEHRING     ",0,card0306,P_REDX,h0306v1a,000,name0306 ;	6 - 3RD BASE     
	ATTRIB    W,3,9,6,5,149,70,24,24,24,24,0,0,5,0,L,R,"GREENWELL    ",0,card0307,P_REDX,h0307v1a,000,name0307 ;	7 - LEFT FIELD   
	ATTRIB    B,4,6,8,7,169,81,28,27,27,37,0,0,1,0,S,R,"HOSEY        ",0,card0308,P_REDX,h0308v1a,000,name0308 ;	8 - CENTER FIELD 
	ATTRIB    B,2,4,4,6,143,01,43,28,24,05,0,0,8,0,S,R,"MITCHELL     ",0,card0309,P_REDX,h0309v1a,000,name0309 ;	9 - RIGHT FIELD  
	ATTRIB    W,2,1,8,7,120,84,48,25,25,25,0,0,0,0,R,R,"CLEMENS      ",0,card0310,P_REDX,h0309v1a,015,name0310 ; 10 - STARTER 1                     
	ATTRIB    W,2,6,5,5,118,61,38,25,25,25,0,0,0,0,R,R,"SELE         ",0,card0311,P_REDX,h0309v1a,000,name0311 ; 11 - STARTER 2                     
	ATTRIB    W,4,9,6,6,183,61,16,25,25,25,0,0,0,3,R,R,"WAKEFIELD    ",0,card0312,P_REDX,h0309v1a,000,name0312 ; 12 - STARTER 3                     
	ATTRIB    B,3,6,4,4,108,56,28,25,25,25,0,0,0,0,R,R,"GORDON       ",0,card0313,P_REDX,h0309v1a,000,name0313 ; 12 - STARTER 3                     
	ATTRIB    B,5,1,8,7,185,86,46,25,25,25,0,0,0,0,R,R,"SLOCUMB      ",0,card0314,P_REDX,h0309v1a,000,name0314 ; 14 - CLOSER 1                      
					                        
CaliforniaAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    B,4,4,7,7,160,83,15,00,00,00,0,0,4,0,S,R,"DAVIS        ",0,card0401,P_ANGE,h0401v1a,016,name0401 ;	1 - DH           
	ATTRIB    W,1,4,7,6,130,73,02,14,20,12,0,0,8,0,L,R,"FABREGAS     ",0,card0402,P_ANGE,h0402v1a,000,name0402 ;	2 - CATCHER      
	ATTRIB    W,0,6,6,6,145,82,10,48,48,42,0,0,5,0,S,L,"SNOW         ",0,card0403,P_ANGE,h0403v1a,017,name0403 ;	3 - 1ST BASE     
	ATTRIB    W,1,8,5,5,139,46,16,24,24,24,0,0,1,0,R,R,"VELARDE      ",0,card0404,P_ANGE,h0404v1a,000,name0404 ;	4 - 2ND BASE     
	ATTRIB    W,3,3,3,6,155,14,25,34,45,24,0,0,9,0,R,R,"DISARCINA    ",0,card0405,P_ANGE,h0405v1a,000,name0405 ;	5 - SHORTSTOP    
	ATTRIB    W,2,3,6,7,133,65,06,16,30,38,0,0,7,0,R,R,"WALLACH      ",0,card0406,P_ANGE,h1406v1a,000,name0406 ;	6 - 3RD BASE     
	ATTRIB    B,1,6,5,7,162,81,12,20,22,05,0,0,6,0,S,R,"ANDERSON     ",0,card0407,P_ANGE,h0407v1a,018,name0407 ;	7 - LEFT FIELD   
	ATTRIB    W,2,5,5,6,146,88,24,36,42,42,0,0,2,0,L,L,"EDMONDS      ",0,card0408,P_ANGE,h0408v1a,019,name0408 ;	8 - CENTER FIELD 
	ATTRIB    W,1,5,8,7,166,89,18,32,36,48,0,0,3,0,R,R,"SALMON       ",0,card0409,P_ANGE,h0409v1a,020,name0409 ;	9 - RIGHT FIELD  
	ATTRIB    W,3,1,7,8,119,86,38,25,25,25,0,0,0,0,L,L,"FINLEY       ",0,card0410,P_ANGE,h0409v1a,000,name0410 ; 10 - STARTER 1                     
	ATTRIB    W,5,2,7,7,145,43,36,25,25,25,0,0,0,0,L,L,"ABBOTT       ",0,card0411,P_ANGE,h0409v1a,000,name0411 ; 11 - STARTER 2                     
	ATTRIB    W,1,2,4,6,100,65,40,25,25,25,0,0,0,0,R,L,"LANGSTON     ",0,card0412,P_ANGE,h0409v1a,000,name0412 ; 12 - STARTER 3                     
	ATTRIB    W,5,4,5,5,058,39,42,25,25,25,0,0,0,0,R,R,"ONTIVEROS    ",0,card0413,P_ANGE,h0409v1a,000,name0413 ; 13 - STARTER 4                     
	ATTRIB    W,4,0,7,8,156,99,46,25,25,25,0,0,0,0,R,R,"PERCIVAL     ",0,card0414,P_ANGE,h0409v1a,000,name0414 ; 14 - CLOSER 1                      
					                        
ChicagoCubsAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    B,3,0,6,6,132,89,14,00,00,00,2,2,9,0,R,R,"TIMMONS      ",0,card0501,P_CUBS,h0501v1a,0,name0501 ;	1 - PH                   
	ATTRIB    W,0,9,5,6,133,84,04,20,20,06,0,4,6,0,R,R,"SERVAIS      ",0,card0502,P_CUBS,h0502v1a,0,name0502 ;	2 - CATCHER      
	ATTRIB    W,1,7,5,6,163,67,15,46,44,25,0,1,3,0,L,L,"GRACE        ",0,card0503,P_CUBS,h0503v1a,23,name0503 ;	3 - 1ST BASE     
	ATTRIB    W,2,3,5,5,139,86,24,32,38,24,0,4,2,0,R,R,"SANDBERG     ",0,card0504,P_CUBS,h0504v1a,24,name0504 ;	4 - 2ND BASE     
	ATTRIB    H,1,1,4,6,148,68,30,30,30,25,2,0,8,0,R,R,"SANCHEZ      ",0,card0505,P_CUBS,h0805v1a,0,name0505 ;	5 - SHORTSTOP    
	ATTRIB    W,1,2,6,7,157,62,10,12,14,07,0,0,7,0,L,R,"GOMEZ        ",0,card0506,P_CUBS,h0506v1a,0,name0506 ;	6 - 3RD BASE     
 	ATTRIB    W,2,5,4,6,138,65,16,24,25,32,0,5,5,0,L,R,"GONZALES     ",0,card0507,P_CUBS,h0507v1a,25,name0507 ;	7 - LEFT FIELD   
	ATTRIB    B,5,6,4,5,144,51,50,42,32,32,2,6,1,0,S,R,"MCRAE        ",0,card0508,P_CUBS,h0508v1a,0,name0508 ;	8 - CENTER FIELD 
	ATTRIB    B,2,1,4,5,134,94,44,38,24,50,2,6,4,0,R,R,"SOSA         ",0,card0509,P_CUBS,h0509v1a,26,name0509 ;	9 - RIGHT FIELD  
	ATTRIB    H,3,8,8,7,166,57,38,20,25,25,1,6,0,0,R,R,"NAVARRO      ",0,card0510,P_CUBS,h0509v1a,0,name0510 ; 10 - STARTER 1                     
	ATTRIB    H,4,9,5,6,139,64,24,25,25,25,1,5,0,0,R,R,"CASTILLO     ",0,card0511,P_CUBS,h0509v1a,0,name0511 ; 11 - STARTER 2                     
	ATTRIB    W,5,2,4,6,123,55,28,25,25,25,0,4,0,0,R,R,"BULLINGER    ",0,card0512,P_CUBS,h0509v1a,0,name0512 ; 12 - STARTER 3                     
	ATTRIB    W,3,2,2,6,104,78,38,25,25,25,2,6,0,1,R,R,"TRACHSEL     ",0,card0513,P_CUBS,h0509v1a,0,name0513 ; 13 - STARTER 4                     
	ATTRIB    W,1,3,6,7,176,86,38,25,25,25,0,0,0,0,L,R,"WENDELL      ",0,card0514,P_CUBS,h0509v1a,27,name0514 ; 14 - CLOSER 1                      
	         				        	                 			     
ChicagoSoxAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    B,0,3,5,6,150,89,08,00,00,00,0,0,6,0,L,L,"BAINES       ",0,card0601,P_WHIT,h0601v1a,028,name0601 ;	1 - DH           
	ATTRIB    W,2,0,7,6,109,79,04,40,40,46,0,0,7,0,R,R,"KARKOVICE    ",0,card0602,P_WHIT,h0602v1a,000,name0602 ;	2 - CATCHER      
	ATTRIB    B,3,5,9,8,154,94,08,18,14,24,0,0,3,0,R,R,"THOMAS       ",0,card0603,P_WHIT,h0603v1a,029,name0603 ;	3 - 1ST BASE     
	ATTRIB    B,0,5,3,3,129,28,42,37,24,24,0,0,2,0,S,R,"DURHAM       ",0,card0604,P_WHIT,h0604v1a,030,name0604 ;	4 - 2ND BASE     
	ATTRIB    H,1,3,2,5,124,01,26,25,34,18,0,0,8,0,L,R,"GUILLEN      ",0,card0605,P_WHIT,h0605v1a,000,name0605 ;	5 - SHORTSTOP    
	ATTRIB    W,2,3,5,6,148,88,10,35,20,47,0,0,5,0,L,R,"VENTURA      ",0,card0606,P_WHIT,h0606v1a,031,name0606 ;	6 - 3RD BASE     
	ATTRIB    B,0,8,3,4,131,84,15,22,20,08,0,0,1,0,R,R,"PHILLIPS     ",0,card0607,P_WHIT,h0607v1a,000,name0607 ;	6 - 3RD BASE     
	ATTRIB    H,1,0,2,5,153,35,44,36,39,14,0,0,9,0,R,R,"LEWIS        ",0,card0608,P_WHIT,h0608v1a,000,name0608 ;	8 - CENTER FIELD 
	ATTRIB    H,4,5,6,6,118,67,10,16,20,10,0,0,4,0,R,R,"TARTABULL    ",0,card0609,P_WHIT,h0609v1a,000,name0609 ;	1 - DH           
	ATTRIB    H,3,2,7,6,140,74,40,25,25,25,0,0,0,0,R,R,"FERNANDEZ    ",0,card0610,P_WHIT,h0609v1a,132,name0610 ; 10 - STARTER 1                     
	ATTRIB    H,4,0,9,6,114,67,36,25,25,25,0,0,0,0,L,L,"ALVAREZ      ",0,card0611,P_WHIT,h0609v1a,000,name0611 ; 11 - STARTER 2                     
	ATTRIB    W,3,6,5,5,120,60,22,25,25,25,0,0,0,0,R,R,"TAPANI       ",0,card0612,P_WHIT,h0609v1a,000,name0612 ; 13 - STARTER 4                     
	ATTRIB    B,4,6,4,7,029,80,46,25,25,25,0,0,0,0,R,R,"BALDWIN      ",0,card0613,P_WHIT,h0609v1a,000,name0613 ; 12 - STARTER 3                     
	ATTRIB    B,3,9,9,7,163,99,48,25,25,25,0,0,0,0,R,R,"HERNANDEZ    ",0,card0614,P_WHIT,h0609v1a,000,name0614 ; 14 - CLOSER 1                      
					                        
CincinnatiAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    W,1,7,6,5,144,56,35,00,00,00,2,0,9,0,R,R,"SABO         ",0,card0701,P_REDS,h0701v1a,000,name0701 ;	1 - PH           
	ATTRIB    W,1,0,4,6,143,80,12,12,20,04,1,0,6,0,R,R,"TAUBENSEE    ",0,card0702,P_REDS,h0702v1a,000,name0702 ;	2 - CATCHER      
	ATTRIB    W,2,3,7,7,140,69,16,16,20,24,0,0,5,0,L,L,"MORRIS       ",0,card0703,P_REDS,h0703v1a,032,name0703 ;	3 - 1ST BASE     
	ATTRIB    W,2,9,4,4,134,68,24,37,38,45,0,0,7,0,R,R,"BOONE        ",0,card0704,P_REDS,h0704v1a,000,name0704 ;	4 - 2ND BASE     
	ATTRIB    B,1,1,5,5,160,69,51,54,48,50,2,0,3,0,R,R,"LARKIN       ",0,card0705,P_REDS,h0705v1a,033,name0705;	5 - SHORTSTOP    
	ATTRIB    W,3,0,4,5,130,75,14,34,39,46,0,0,8,0,L,R,"BRANSON      ",0,card0706,P_REDS,h0706v1a,000,name0706 ;	6 - 3RD BASE     
	ATTRIB    B,3,9,5,5,144,03,44,44,20,01,0,0,1,0,S,R,"COLEMAN      ",0,card0707,P_REDS,h0707v1a,000,name0707 ;	7 - LEFT FIELD   
	ATTRIB    B,2,2,6,6,151,01,37,40,30,43,2,0,2,0,S,R,"HOWARD       ",0,card0708,P_REDS,h0708v1a,000,name0708 ;	8 - CENTER FIELD 
	ATTRIB    B,1,6,4,6,153,88,47,45,34,54,2,0,4,0,R,R,"SANDERS      ",0,card0709,P_REDS,h0709v1a,034,name0709 ;	9 - RIGHT FIELD  
	ATTRIB    W,4,6,6,8,169,75,46,25,25,25,0,0,0,0,L,L,"SCHOUREK     ",0,card0710,P_REDS,h0709v1a,000,name0710 ; 10 - STARTER 1                     
	ATTRIB    W,5,7,7,7,157,63,44,25,25,25,0,0,0,1,L,L,"SMILEY       ",0,card0711,P_REDS,h0709v1a,000,name0711 ; 11 - STARTER 2                     
	ATTRIB    W,2,1,5,5,130,47,32,25,25,25,0,0,0,0,R,R,"PORTUGAL     ",0,card0712,P_REDS,h0709v1a,000,name0712 ; 12 - STARTER 3                     
	ATTRIB    W,3,4,8,7,150,61,28,25,25,25,0,0,0,1,L,L,"BURBA        ",0,card0713,P_REDS,h0709v1a,000,name0713 ; 13 - STARTER 4                     
	ATTRIB    W,4,5,4,4,189,79,42,25,25,25,0,0,0,0,R,R,"BRANTLEY     ",0,card0714,P_REDS,h0709v1a,000,name0714 ; 14 - CLOSER 1                      
                                                                                   	                       	      
ClevelandAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    B,3,3,8,6,162,83,05,00,00,00,0,0,5,0,S,R,"MURRAY       ",0,card0801,P_INDI,h0801v1a,000,name0801 ;	1 - DH           
	ATTRIB    H,1,5,7,8,100,84,14,34,32,37,0,0,8,0,R,R,"ALOMAR       ",0,card0802,P_INDI,h0802v1a,035,name0802 ;	2 - CATCHER      
	ATTRIB    B,2,3,6,5,118,78,14,12,20,24,0,0,2,0,R,R,"FRANC0       ",0,card0803,P_INDI,h0803v1a,000,name0803 ;	3 - 1ST BASE     
	ATTRIB    H,0,9,6,5,157,64,34,20,22,40,0,0,3,0,S,R,"BAERGA       ",0,card0804,P_INDI,h0804v1a,036,name0804 ;	4 - 2ND BASE     
	ATTRIB    W,1,3,2,4,133,03,34,50,44,12,0,0,9,0,S,R,"VISQUEL      ",0,card0805,P_INDI,h0805v1a,000,name0805 ;	5 - SHORTSTOP    
	ATTRIB    W,2,5,8,7,157,87,24,34,22,30,0,0,6,0,L,R,"THOME        ",0,card0806,P_INDI,h0806v1a,000,name0806 ;	6 - 3RD BASE     
	ATTRIB    B,0,8,7,6,159,99,26,30,26,28,0,0,4,0,R,R,"BELLE        ",0,card0807,P_INDI,h0807v1a,037,name0807 ;	7 - LEFT FIELD   
	ATTRIB    B,0,7,4,5,155,26,54,54,50,48,0,0,1,0,L,L,"LOFTON       ",0,card0808,P_INDI,h0808v1a,038,name0808 ;	8 - CENTER FIELD 
	ATTRIB    H,2,4,5,5,154,89,13,20,26,24,0,0,7,0,R,R,"RAMIREZ      ",0,card0809,P_INDI,h0809v1a,039,name0809 ;	9 - RIGHT FIELD  
	ATTRIB    H,3,2,4,6,176,52,36,25,25,25,0,0,0,0,R,R,"MARTINEZ     ",0,card0810,P_INDI,h0809v1a,040,name0810 ; 11 - STARTER 2                     
	ATTRIB    W,5,5,5,7,136,66,38,25,25,25,0,0,0,0,R,R,"HERSHISER    ",0,card0811,P_INDI,h0809v1a,000,name0811 ; 12 - STARTER 3                     
	ATTRIB    W,2,9,5,5,133,64,40,25,25,25,0,0,0,0,R,R,"MCDOWELL     ",0,card0812,P_INDI,h0809v1a,000,name0812 ; 11 - STARTER 2                     
	ATTRIB    W,4,1,6,7,102,78,40,25,25,25,0,0,0,0,L,R,"NAGY         ",0,card0813,P_INDI,h0809v1a,000,name0813 ; 10 - STARTER 1                     
	ATTRIB    B,4,9,8,7,255,90,52,25,25,25,0,0,0,0,R,R,"MESA         ",0,card0814,P_INDI,h0809v1a,000,name0814 ; 14 - CLOSER 1                      
					                        
ColoradoAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    W,3,5,5,6,174,84,28,00,00,00,0,1,9,0,L,L,"VANDER WAL   ",0,card0901,P_ROCK,h0901v1a,000,name0901 ;	1 - PH           
	ATTRIB    W,3,4,6,5,131,39,09,16,20,40,0,0,7,0,R,R,"OWENS        ",0,card0902,P_ROCK,h0902v1a,000,name0902 ;	2 - CATCHER      
	ATTRIB    H,1,4,9,7,140,87,16,36,40,26,0,0,5,0,R,R,"GALARRAGA    ",0,card0903,P_ROCK,h0903v1a,041,name0903 ;	3 - 1ST BASE     
	ATTRIB    B,2,1,4,4,159,35,43,18,22,08,0,0,1,0,R,R,"YOUNG        ",0,card0904,P_ROCK,h0904v1a,000,name0904 ;	4 - 2ND BASE     
	ATTRIB    W,2,2,3,5,130,01,18,37,38,45,0,0,8,0,S,R,"WEISS        ",0,card0905,P_ROCK,h0905v1a,000,name0905 ;	5 - SHORTSTOP    
	ATTRIB    H,0,9,4,6,155,89,09,11,24,16,0,0,6,0,R,R,"CASTILLA     ",0,card0906,P_ROCK,h0906v1a,042,name0906 ;	6 - 3RD BASE     
	ATTRIB    B,2,6,6,6,133,86,29,29,24,37,0,0,2,0,R,R,"BURKS        ",0,card0907,P_ROCK,h0909v1a,000,name0907 ;	8 - CENTER FIELD 
	ATTRIB    W,3,3,7,7,153,92,38,47,46,54,0,1,4,0,L,R,"WALKER       ",0,card0908,P_ROCK,h0908v1a,044,name0908 ;	9 - RIGHT FIELD  
	ATTRIB    W,1,0,9,7,170,90,34,24,38,46,0,0,3,0,R,R,"BICHETTE     ",0,card0909,P_ROCK,h0907v1a,043,name0909 ;	7 - LEFT FIELD   
	ATTRIB    W,3,0,5,5,119,62,36,25,25,25,0,0,0,0,R,R,"RITZ         ",0,card0910,P_ROCK,h0909v1a,000,name0910 ; 10 - STARTER 1                     
	ATTRIB    W,2,0,5,5,083,57,38,25,25,25,0,0,0,0,R,R,"SWIFT        ",0,card0911,P_ROCK,h0909v1a,000,name0911 ; 12 - STARTER 3                     
	ATTRIB    B,4,4,5,5,064,38,40,25,25,25,0,0,0,0,R,R,"FREEMAN      ",0,card0912,P_ROCK,h0909v1a,000,name0912 ; 13 - STARTER 4                     
	ATTRIB    W,3,1,6,6,121,58,42,25,25,25,0,0,0,0,R,R,"SABERHAGEN   ",0,card0913,P_ROCK,h0909v1a,000,name0913 ; 11 - STARTER 2                     
	ATTRIB    W,1,6,6,5,168,82,46,25,25,25,0,0,0,0,R,R,"LESKANIC     ",0,card0914,P_ROCK,h0909v1a,000,name0914 ; 14 - CLOSER 1                      
					                                                                         
DetroitAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    B,2,0,4,5,135,01,16,00,00,00,0,0,5,0,R,R,"WILLIAMS     ",0,card1001,P_TIGE,h1003v1a,113,name1001 ;	5 - SHORTSTOP    
	ATTRIB    W,1,1,5,5,147,29,21,24,28,10,0,0,8,0,R,R,"AUSMUS       ",0,card2402,P_PADR,h2402v1a,000,name2402 ;	2 - CATCHER      
	ATTRIB    B,4,5,9,7,122,91,01,08,18,24,0,0,4,0,R,R,"FIELDER      ",0,card1003,P_TIGE,h1001v1a,045,name1003 ;	3 - 1ST BASE     
	ATTRIB    W,0,1,4,5,147,59,19,20,24,24,0,0,2,0,L,R,"LEWIS        ",0,card1004,P_TIGE,h1004v1a,000,name1004 ;	4 - 2ND BASE     
	ATTRIB    B,0,4,2,6,105,31,26,25,25,25,0,0,9,0,R,R,"CEDENO       ",0,card2405,P_PADR,h2405v1a,000,name2405 ;	5 - SHORTSTOP    
	ATTRIB    W,2,4,5,6,138,63,09,27,20,27,0,0,3,0,R,R,"FRYMAN       ",0,card1006,P_TIGE,h1006v1a,046,name1006 ;	6 - 3RD BASE     
	ATTRIB    B,3,0,5,5,112,74,34,30,26,24,0,0,6,0,L,R,"NIEVES       ",0,card1007,P_TIGE,h1007v1a,000,name1007 ;	7 - LEFT FIELD   
	ATTRIB    W,0,9,3,4,134,75,38,35,28,15,0,0,1,0,R,R,"CURTIS       ",0,card1008,P_TIGE,h1008v1a,047,name1008 ;	8 - CENTER FIELD 
	ATTRIB    W,0,4,5,5,112,74,34,30,26,24,0,0,7,0,L,R,"HIGGINSON    ",0,card1009,P_TIGE,h1009v1a,000,name1009 ;	7 - LEFT FIELD   
	ATTRIB    W,4,3,6,7,074,57,28,25,25,25,0,0,0,0,R,R,"GOHR         ",0,card1010,P_TIGE,h1009v1a,000,name1010 ; 10 - STARTER 1                     
	ATTRIB    H,4,0,3,5,114,60,34,25,25,25,0,0,0,0,R,R,"LIRA         ",0,card1011,P_TIGE,h1009v1a,000,name1011 ; 11 - STARTER 2                     
	ATTRIB    B,3,2,3,6,024,50,42,25,25,25,0,0,0,0,L,L,"THOMPSON     ",0,card1012,P_TIGE,h1009v1a,000,name1012 ; 12 - STARTER 3                     
	ATTRIB    W,5,7,5,5,053,53,38,25,25,25,0,0,0,0,L,L,"KEAGLE       ",0,card1013,P_TIGE,h1009v1a,000,name1013 ; 13 - STARTER 4                     
	ATTRIB    W,3,3,7,7,075,55,34,25,25,25,0,0,0,0,R,R,"WILLIAMS     ",0,card1014,P_TIGE,h1009v1a,000,name1014 ; 14 - CLOSER 1                      
                                                                                      	                               
FloridaAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    B,0,8,5,7,129,75,15,00,00,00,0,0,9,0,R,R,"DAWSON       ",0,card1101,P_MARL,h1101v1a,000,name1101 ;	1 - PH           
	ATTRIB    B,2,3,5,5,126,74,04,30,30,50,0,0,8,0,R,R,"JOHNSON      ",0,card1102,P_MARL,h1102v1a,048,name1102 ;	2 - CATCHER      
	ATTRIB    W,0,4,6,5,139,81,16,25,28,25,0,0,5,0,R,R,"COLBRUNN     ",0,card1103,P_MARL,h1103v1a,000,name1103 ;	3 - 1ST BASE     
	ATTRIB    B,0,3,5,5,131,05,54,38,26,25,0,0,2,0,S,R,"VERAS        ",0,card1104,P_MARL,h1104v1a,000,name1104 ;	4 - 2ND BASE     
	ATTRIB    W,0,7,4,5,128,79,22,18,24,44,0,0,7,0,R,R,"ABBOTT       ",0,card1105,P_MARL,h1105v1a,000,name1105 ;	5 - SHORTSTOP    
	ATTRIB    B,0,9,5,4,145,64,18,24,25,28,0,0,6,0,S,R,"PENDLETON    ",0,card1106,P_MARL,h1106v1a,049,name1106 ;	6 - 3RD BASE     
	ATTRIB    W,1,9,8,6,151,86,18,18,28,30,0,0,4,0,R,R,"CONINE       ",0,card1107,P_MARL,h1107v1a,050,name1107 ;	7 - LEFT FIELD   
	ATTRIB    B,2,5,5,6,142,58,48,50,36,20,0,0,1,0,S,R,"WHITE        ",0,card1108,P_MARL,h1108v1a,051,name1108 ;	8 - CENTER FIELD 
	ATTRIB    B,1,0,5,5,162,93,15,24,22,44,0,0,3,0,R,R,"SHEFFIELD    ",0,card1109,P_MARL,h1109v1a,052,name1109 ;	9 - RIGHT FIELD  
	ATTRIB    W,3,5,6,7,031,59,44,25,25,25,0,0,0,0,R,R,"BROWN        ",0,card1110,P_MARL,h1109v1a,000,name1110 ; 13 - STARTER 4                     
	ATTRIB    W,3,3,7,6,115,60,36,25,25,25,0,0,0,0,R,R,"BURKETT      ",0,card1111,P_MARL,h1109v1a,000,name1111 ; 10 - STARTER 1                     
	ATTRIB    W,4,8,7,7,158,54,36,25,25,25,0,0,0,0,R,R,"RAPP         ",0,card1112,P_MARL,h1109v1a,000,name1112 ; 11 - STARTER 2                     
	ATTRIB    W,2,5,5,6,140,70,44,25,25,25,0,0,0,0,L,L,"LEITER       ",0,card1113,P_MARL,h1109v1a,000,name1113 ; 12 - STARTER 3                     
	ATTRIB    W,3,1,7,6,165,93,48,25,25,25,0,0,0,0,R,R,"NEN          ",0,card1114,P_MARL,h1109v1a,000,name1114 ; 14 - CLOSER 1                      
					                        
HoustonAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    B,0,6,5,5,159,01,36,32,24,14,0,0,9,0,S,L,"MOUTON       ",0,card1201,P_ASTR,h1201v1a,000,name1201 ;	1 - PH           
	ATTRIB    W,0,3,5,5,150,35,10,20,20,44,0,0,7,0,R,R,"WILKINS      ",0,card1202,P_ASTR,h2002v1a,000,name1202 ;	2 - CATCHER      
	ATTRIB    W,0,5,5,5,145,90,24,24,24,26,0,0,3,0,R,R,"BAGWELL      ",0,card1203,P_ASTR,h1203v1a,054,name1203 ;	3 - 1ST BASE     
	ATTRIB    W,0,7,5,4,151,79,46,50,26,34,0,0,2,0,R,R,"BIGGIO       ",0,card1204,P_ASTR,h1204v1a,055,name1204 ;	4 - 2ND BASE     
	ATTRIB    B,2,4,4,6,131,31,32,23,24,24,0,0,8,0,R,R,"MILLER       ",0,card1205,P_ASTR,h1205v1a,000,name1205 ;	5 - SHORTSTOP    
	ATTRIB    W,1,7,6,5,159,82,30,20,18,08,0,0,5,0,R,R,"BERRY        ",0,card1206,P_ASTR,h1206v1a,056,name1206 ;	6 - 3RD BASE     
	ATTRIB    B,1,6,8,7,151,77,12,22,24,13,0,0,6,0,L,R,"MAY          ",0,card1207,P_ASTR,h1207v1a,000,name1207 ;	7 - LEFT FIELD   
	ATTRIB    B,1,9,4,7,157,00,50,48,26,28,0,0,1,0,R,R,"HUNTER       ",0,card1208,P_ASTR,h1209v1a,000,name1208 ;	8 - CENTER FIELD 
	ATTRIB    B,1,4,7,6,167,40,29,36,30,42,0,0,4,0,R,R,"BELL         ",0,card1209,P_ASTR,h1208v1a,057,name1209 ;	9 - RIGHT FIELD  
	ATTRIB    W,1,5,4,6,091,69,28,25,25,25,0,0,0,0,R,R,"DRABEK       ",0,card1210,P_ASTR,h1209v1a,000,name1210 ; 10 - STARTER 1                     
	ATTRIB    W,1,0,5,5,162,68,28,25,25,25,0,0,0,0,R,L,"HAMPTON      ",0,card1211,P_ASTR,h1209v1a,000,name1211 ; 13 - STARTER 4                     
	ATTRIB    W,3,7,7,7,156,83,40,25,25,25,0,0,0,0,R,R,"REYNOLDS     ",0,card1212,P_ASTR,h1209v1a,000,name1212 ; 11 - STARTER 2                     
	ATTRIB    W,2,1,8,7,106,56,24,25,25,25,0,0,0,0,R,R,"KILE         ",0,card1213,P_ASTR,h1209v1a,000,name1213 ; 12 - STARTER 3                     
	ATTRIB    W,5,9,6,7,176,86,38,25,25,25,0,0,0,0,L,R,"JONES        ",0,card1214,P_ASTR,h1209v1a,058,name1214 ; 14 - CLOSER 1                      
					                                       				   
KansasCityAttr:                                                                      	                               
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    W,1,2,6,6,155,62,15,18,24,24,0,0,6,0,L,L,"VITIELLO     ",0,card1301,P_ROYA,h1301v1a,000,name1301 ;	3 - 1ST BASE     
	ATTRIB    W,2,4,5,6,126,79,08,20,24,24,0,0,8,0,L,R,"MACFARLANE   ",0,card1302,P_ROYA,h1302v1a,000,name1302 ;	2 - CATCHER      
	ATTRIB    B,3,0,2,5,144,01,27,22,14,01,0,0,4,0,S,R,"OFFERMAN     ",0,card1303,P_ROYA,h1303v1a,000,name1305 ;	1 - PH           
	ATTRIB    B,1,0,2,3,152,01,44,28,24,24,0,0,1,0,S,R,"ROBERTS      ",0,card1304,P_ROYA,h1304v1a,059,name1304 ;	7 - LEFT FIELD   
	ATTRIB    W,3,0,2,5,144,01,27,22,14,01,0,0,9,0,S,R,"HOWARD       ",0,card1305,P_ROYA,h1305v1a,000,name1305 ;	1 - PH           
	ATTRIB    W,4,3,5,5,161,01,30,34,30,34,0,0,7,0,L,R,"LOCKHART     ",0,card1306,P_ROYA,h1306v1a,060,name1306 ;	4 - 2ND BASE     
	ATTRIB    B,4,7,3,6,144,06,50,47,34,08,0,0,3,0,L,R,"GOODWIN      ",0,card1307,P_ROYA,h1307v1a,000,name1307 ;	7 - LEFT FIELD   
	ATTRIB    H,5,1,5,5,141,33,48,38,28,12,0,0,2,0,L,L,"DAMON        ",0,card1308,P_ROYA,h1308v1a,061,name1308 ;	8 - CENTER FIELD 
	ATTRIB    B,3,1,5,5,122,08,36,26,20,17,0,0,5,0,L,R,"TUCKER       ",0,card1309,P_ROYA,h1309v1a,000,name1309 ;	9 - RIGHT FIELD  
	ATTRIB    W,5,5,5,6,135,82,44,25,25,25,0,0,0,1,R,R,"APPIER       ",0,card1310,P_ROYA,h1309v1a,000,name1310 ; 11 - STARTER 2                     
	ATTRIB    W,2,3,9,8,142,34,24,25,25,25,0,0,0,0,R,R,"GUBICZA      ",0,card1311,P_ROYA,h1309v1a,000,name1311 ; 10 - STARTER 1                     
	ATTRIB    W,3,3,4,4,108,56,28,25,25,25,0,0,0,2,R,R,"HANEY        ",0,card1312,P_ROYA,h1309v1a,000,name1312 ; 12 - STARTER 3                     
	ATTRIB    W,4,1,4,6,112,60,36,25,25,25,0,0,0,0,R,R,"BELCHER      ",0,card1313,P_ROYA,h1309v1a,000,name1313 ; 13 - STARTER 4                     
	ATTRIB    W,2,1,4,5,158,67,40,25,25,25,0,0,0,0,R,R,"MONTGOMERY   ",0,card1314,P_ROYA,h1309v1a,000,name1314 ; 14 - CLOSER 1                      
					                        
LAAttr:					                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    W,0,7,6,6,139,22,13,00,00,00,0,0,7,0,R,R,"ASHLEY       ",0,card1401,P_DODG,h1401v1a,000,name1401 ;	7 - LEFT FIELD   
	ATTRIB    W,3,1,5,7,173,92,16,24,22,24,0,0,4,0,R,R,"PIAZZA       ",0,card1402,P_DODG,h1402v1a,062,name1402 ;	2 - CATCHER      
	ATTRIB    W,2,3,7,7,148,88,03,14,20,24,0,0,5,0,R,R,"KARROS       ",0,card1403,P_DODG,h1403v1a,000,name1403 ;	3 - 1ST BASE     
	ATTRIB    B,1,4,3,6,128,45,44,30,24,14,0,0,2,0,L,R,"DESHIELDS    ",0,card1404,P_DODG,h1404v1a,000,name1404 ;	4 - 2ND BASE     
	ATTRIB    W,0,7,4,5,128,22,20,38,36,35,0,0,8,0,R,R,"GAGNE        ",0,card1405,P_DODG,h1405v1a,000,name1405 ;	5 - SHORTSTOP    
	ATTRIB    W,1,6,7,6,128,86,09,24,26,24,0,0,6,0,R,R,"BLOWERS      ",0,card1406,P_DODG,h1406v1a,000,name1406 ;	6 - 3RD BASE     
	ATTRIB    W,3,1,5,7,173,92,35,34,36,46,0,0,9,0,R,R,"HOLLANDSWORTH",0,card1407,P_DODG,h1407v1a,000,name1407 ;	1 - DH           
	ATTRIB    W,2,2,2,4,150,01,42,30,30,26,0,0,1,0,L,L,"BUTLER       ",0,card1408,P_DODG,h1408v1a,063,name1408 ;	8 - CENTER FIELD 
	ATTRIB    H,4,3,6,5,143,86,48,54,46,54,0,0,3,0,R,R,"MONDESI      ",0,card1409,P_DODG,h1409v1a,064,name1409 ;	9 - RIGHT FIELD  
	ATTRIB    B,4,8,3,7,147,60,44,25,25,25,0,0,0,0,L,R,"MARTINEZ     ",0,card1410,P_DODG,h1409v1a,065,name1410 ; 10 - STARTER 1                     
	ATTRIB    H,1,6,5,5,203,99,48,25,25,25,0,0,0,4,R,R,"NOMO         ",0,card1411,P_DODG,h1409v1a,066,name1411 ; 11 - STARTER 2                     
	ATTRIB    H,5,9,5,5,177,68,36,25,25,25,0,0,0,0,R,R,"VALDES       ",0,card1412,P_DODG,h1409v1a,000,name1412 ; 12 - STARTER 3                     
	ATTRIB    H,6,1,7,6,155,66,22,25,25,25,0,0,0,0,R,R,"PARK         ",0,card1413,P_DODG,h1409v1a,000,name1413 ; 13 - STARTER 4                     
	ATTRIB    W,3,8,8,8,229,88,42,25,25,25,0,0,0,1,R,R,"WORRELL      ",0,card1414,P_DODG,h1409v1a,000,name1414 ; 14 - CLOSER 1                      
					                        
MilwaukeeAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    W,3,2,6,6,157,89,15,00,00,00,0,0,5,0,R,R,"JAHA         ",0,card1501,P_BREW,h1501v1a,000,name1501 ;	3 - 1ST BASE     
	ATTRIB    W,2,2,7,7,139,82,12,24,24,36,0,0,7,0,L,R,"MATHENY      ",0,card1502,P_BREW,h1502v1a,000,name1502 ;	2 - CATCHER      
	ATTRIB    W,2,0,5,5,156,05,15,20,24,12,0,0,2,0,R,R,"SEITZER      ",0,card1503,P_BREW,h1503v1a,068,name1503 ;	6 - 3RD BASE     
	ATTRIB    H,0,4,3,4,110,01,27,24,26,10,0,0,9,0,S,R,"LISTACH      ",0,card1504,P_BREW,h1504v1a,000,name1504 ;	4 - 2ND BASE     
	ATTRIB    H,0,2,3,4,110,71,34,44,40,46,0,0,8,0,S,R,"VALENTIN     ",0,card1505,P_BREW,h1505v1a,069,name1505 ;	5 - SHORTSTOP    
	ATTRIB    W,2,0,5,5,156,05,15,20,24,12,0,0,6,0,R,R,"CIRILLO      ",0,card1506,P_BREW,h1506v1a,070,name1506 ;	6 - 3RD BASE     
	ATTRIB    B,2,3,6,5,112,81,32,24,24,24,0,0,4,0,R,R,"VAUGHN       ",0,card1507,P_BREW,h1507v1a,067,name1507 ;	1 - DH           
	ATTRIB    B,2,1,2,4,114,01,49,46,40,32,0,0,1,0,S,R,"CARR         ",0,card1508,P_BREW,h1508v1a,000,name1508 ;	8 - CENTER FIELD 
	ATTRIB    W,0,0,7,7,139,82,25,25,28,45,0,0,3,0,L,R,"MIESKE       ",0,card1509,P_BREW,h1509v1a,000,name1509 ;	9 - RIGHT FIELD  
	ATTRIB    W,1,3,5,5,082,61,44,25,25,25,0,0,0,0,L,L,"MCDONALD     ",0,card1510,P_BREW,h1509v1a,000,name1510 ; 13 - STARTER 4                     
	ATTRIB    W,2,5,5,5,098,34,38,25,25,25,0,0,0,1,R,R,"BONES        ",0,card1511,P_BREW,h1509v1a,000,name1511 ; 10 - STARTER 1                     
	ATTRIB    W,5,0,5,5,098,42,40,25,25,25,0,0,0,3,R,R,"SPARKS       ",0,card1512,P_BREW,h1509v1a,000,name1512 ; 11 - STARTER 2                     
	ATTRIB    W,4,2,5,5,123,42,42,25,25,25,0,0,0,0,L,L,"KARL         ",0,card1513,P_BREW,h1509v1a,000,name1513 ; 12 - STARTER 3                     
	ATTRIB    W,3,6,7,7,161,85,46,25,25,25,0,0,0,0,R,R,"FETTERS      ",0,card1514,P_BREW,h1509v1a,000,name1514 ; 14 - CLOSER 1                      
                                                                                   	                       	      
MinnesotaAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    W,0,4,4,5,135,67,25,00,00,00,0,0,2,0,R,R,"MOLITOR      ",0,card1601,P_TWIN,h1601v1a,071,name1601 ;	1 - DH           
	ATTRIB    W,0,9,5,5,129,57,08,16,20,14,0,0,6,0,S,R,"MYERS        ",0,card1602,P_TWIN,h1602v1a,000,name1602 ;	2 - CATCHER      
	ATTRIB    W,3,7,6,8,133,09,29,26,24,38,0,0,7,0,L,R,"STAHOVIAK    ",0,card1603,P_TWIN,h1603v1a,000,name1603 ;	3 - 1ST BASE     
	ATTRIB    W,1,1,4,4,167,50,46,40,36,42,0,0,1,0,R,R,"KNOBLAUCH    ",0,card1604,P_TWIN,h1604v1a,072,name1604 ;	4 - 2ND BASE     
	ATTRIB    W,0,2,4,5,135,69,18,30,26,45,0,0,8,0,R,R,"MEARES       ",0,card1605,P_TWIN,h1605v1a,000,name1605 ;	5 - SHORTSTOP    
	ATTRIB    W,3,1,6,7,124,04,24,20,16,18,0,0,4,0,R,R,"HOLLINS      ",0,card1606,P_TWIN,h1606v1a,000,name1606 ;	6 - 3RD BASE     
	ATTRIB    W,4,0,6,5,139,83,26,28,28,36,0,0,5,0,R,R,"CORDOVA      ",0,card1607,P_TWIN,h1607v1a,073,name1607 ;	7 - LEFT FIELD   
	ATTRIB    B,0,5,6,6,139,22,33,24,24,24,0,0,9,0,R,R,"KELLY        ",0,card1608,P_TWIN,h1608v1a,000,name1908 ;	7 - 2ND BASE     
	ATTRIB    B,3,4,7,1,157,81,22,26,30,38,0,0,3,0,R,R,"PUCKETT      ",0,card1609,P_TWIN,h1609v1a,074,name1609 ;	9 - RIGHT FIELD  
	ATTRIB    W,2,1,6,6,049,62,36,25,25,25,0,0,0,0,R,R,"AGUILERA     ",0,card1610,P_TWIN,h1609v1a,000,name1610 ; 12 - STARTER 3                     
	ATTRIB    W,2,2,5,5,064,37,28,25,25,25,0,0,0,0,R,R,"RADKE        ",0,card1611,P_TWIN,h1609v1a,000,name1611 ; 10 - STARTER 1                     
	ATTRIB    H,3,3,5,5,023,50,32,25,25,25,0,0,0,0,R,R,"RODRIGUEZ    ",0,card1612,P_TWIN,h1609v1a,075,name1612 ; 11 - STARTER 2                     
	ATTRIB    W,3,6,4,5,077,67,40,25,25,25,0,0,0,0,L,L,"ROBERTSON    ",0,card1613,P_TWIN,h1609v1a,000,name1613 ; 13 - STARTER 4                     
	ATTRIB    W,4,1,5,5,076,64,38,25,25,25,0,0,0,0,R,R,"STEVENS      ",0,card1614,P_TWIN,h1609v1a,000,name1614 ; 14 - CLOSER 1                      
					                        
MontrealAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    W,4,0,7,6,107,90,01,00,00,00,0,0,9,0,R,R,"SANTANGELO   ",0,card1701,P_EXPO,h1701v1a,075,name1701 ;	1 - PH           
	ATTRIB    W,2,4,5,6,143,70,05,20,20,42,0,0,8,0,L,R,"FLETCHER     ",0,card1702,P_EXPO,h1702v1a,000,name1702 ;	2 - CATCHER      
	ATTRIB    H,2,5,6,6,155,63,12,18,30,30,0,0,5,0,S,L,"SEGUI        ",0,card1703,P_EXPO,h1703v1a,076,name1703 ;	3 - 1ST BASE     
	ATTRIB    W,0,3,4,5,128,52,37,44,40,36,0,0,2,0,R,R,"LANSING      ",0,card1704,P_EXPO,h1704v1a,000,name1704 ;	4 - 2ND BASE     
	ATTRIB    W,0,4,5,6,143,71,29,26,30,29,0,0,1,0,R,R,"GRUDZIELANEK ",0,card1705,P_EXPO,h1705v1a,000,name1705 ;	5 - SHORTSTOP    
	ATTRIB    W,5,8,7,6,107,75,17,24,24,24,0,0,7,0,R,R,"ANDREWS      ",0,card1706,P_EXPO,h1706v1a,000,name1706 ;	1 - 3RD BASE     
	ATTRIB    B,4,0,7,6,107,93,01,24,24,24,0,0,6,0,R,R,"RODRIGUEZ    ",0,card1707,P_EXPO,h1707v1a,077,name1701 ;	1 - PH           
	ATTRIB    B,3,7,6,6,148,65,44,40,26,24,0,0,3,0,R,R,"WHITE        ",0,card1708,P_EXPO,h1708v1a,078,name1708 ;	8 - CENTER FIELD 
	ATTRIB    H,1,8,5,7,140,76,31,40,30,46,0,0,4,0,R,R,"ALOU         ",0,card1709,P_EXPO,h1709v1a,000,name1707 ;	7 - LEFT FIELD   
	ATTRIB    B,4,5,3,5,154,80,46,25,25,25,0,0,0,0,R,R,"MARTINEZ     ",0,card1710,P_EXPO,h1709v1a,079,name1710 ; 11 - STARTER 2                     
	ATTRIB    W,1,3,5,6,113,78,40,25,25,25,0,0,0,0,L,L,"FASSERO      ",0,card1711,P_EXPO,h1709v1a,000,name1711 ; 10 - STARTER 1                     
	ATTRIB    W,5,0,5,5,145,67,36,25,25,25,0,0,0,1,L,L,"CORMIER      ",0,card1712,P_EXPO,h1709v1a,000,name1712 ; 12 - STARTER 3                     
	ATTRIB    W,4,2,6,6,114,56,40,25,25,25,0,0,0,0,L,L,"RUETER       ",0,card1713,P_EXPO,h1709v1a,000,name1713 ; 13 - STARTER 4                     
	ATTRIB    B,5,1,5,5,124,81,44,25,25,25,0,0,0,0,R,R,"ROJAS        ",0,card1714,P_EXPO,h1709v1a,000,name1714 ; 14 - CLOSER 1                      
					                        
NYMetsAttr:                                                                          	                               
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    B,0,8,6,7,126,63,30,00,00,00,0,0,9,0,R,R,"HUSKEY       ",0,card1801,P_METS,h1801v1a,084,name1801 ;	1 - DH           
	ATTRIB    W,0,9,4,5,140,89,16,24,30,38,0,0,5,0,S,R,"HUNDLEY      ",0,card1802,P_METS,h1802v1a,080,name1802 ;	2 - CATCHER      
	ATTRIB    W,2,6,5,5,145,81,16,36,30,24,0,0,6,0,L,L,"BROGNA       ",0,card1803,P_METS,h1803v1a,081,name1803 ;	3 - 1ST BASE     
	ATTRIB    B,1,5,4,6,144,01,35,36,30,28,0,0,2,0,R,R,"VISCAINO     ",0,card1804,P_METS,h1804v1a,000,name1804 ;	5 - SHORTSTOP    
	ATTRIB    H,1,5,4,6,144,01,35,36,30,28,0,0,8,0,R,R,"ORDONEZ      ",0,card1805,P_METS,h1805v1a,000,name1805 ;	5 - SHORTSTOP    
	ATTRIB    W,1,2,4,6,139,80,28,26,27,24,0,0,4,0,R,R,"KENT         ",0,card1806,P_METS,h1806v1a,000,name1806 ;	4 - 2ND BASE     
	ATTRIB    B,2,3,5,5,149,86,34,24,30,00,0,0,3,0,R,R,"GILKEY       ",0,card1807,P_METS,h1807v1a,082,name1807 ;	7 - LEFT FIELD   
	ATTRIB    B,0,1,2,5,153,35,52,54,54,06,0,0,1,0,L,L,"JOHNSON      ",0,card1808,P_METS,h1808v1a,083,name1808 ;	8 - CENTER FIELD 
	ATTRIB    B,0,3,4,5,130,80,36,30,24,50,0,0,7,0,S,R,"EVERETT      ",0,card1809,P_METS,h1809v1a,000,name1809 ;	9 - RIGHT FIELD  
	ATTRIB    W,4,4,5,5,189,53,42,25,25,25,0,0,0,0,R,R,"ISRINGHAUSEN ",0,card1810,P_METS,h1809v1a,000,name1810 ; 10 - STARTER 1                     
	ATTRIB    W,2,8,7,7,120,58,34,25,25,25,0,0,0,0,R,R,"JONES        ",0,card1811,P_METS,h1809v1a,084,name1811 ; 11 - STARTER 2                     
	ATTRIB    W,3,8,5,7,117,68,38,25,25,25,0,0,0,0,R,R,"HARNISCH     ",0,card1812,P_METS,h1809v1a,000,name1812 ; 12 - STARTER 3                     
	ATTRIB    W,3,2,5,5,131,57,40,25,25,25,0,0,0,0,L,L,"WILSON       ",0,card1813,P_METS,h1809v1a,000,name1813 ; 13 - STARTER 4                     
	ATTRIB    W,3,1,4,4,208,71,44,25,25,25,0,0,0,0,L,L,"FRANCO       ",0,card1814,P_METS,h1809v1a,000,name1814 ; 14 - CLOSER 1                      
					                        
NYYanksAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    B,2,5,6,6,132,72,11,00,00,00,0,0,4,0,S,R,"SIERRA       ",0,card1901,P_YANK,h1901v1a,000,name1901 ;	1 - DH           
	ATTRIB    W,0,7,6,5,131,39,17,30,34,32,0,0,8,0,R,R,"GIRARDI      ",0,card1902,P_YANK,h1902v1a,000,name1902 ;	2 - CATCHER      
	ATTRIB    W,2,3,7,6,146,88,10,20,20,24,0,0,3,0,L,R,"MARTINEZ     ",0,card1903,P_YANK,h1903v1a,085,name1903 ;	3 - 1ST BASE     
	ATTRIB    B,1,8,6,6,139,22,24,25,27,36,0,0,7,0,R,R,"DUNCAN       ",0,card1904,P_YANK,h1904v1a,000,name1904 ;	7 - 2ND BASE     
	ATTRIB    H,0,0,5,5,123,01,31,30,30,26,0,0,9,0,S,R,"JETER        ",0,card1905,P_YANK,h1905v1a,086,name1905 ;	5 - SHORTSTOP    
	ATTRIB    W,1,2,5,6,162,07,15,30,50,34,0,0,2,0,L,R,"BOGGS        ",0,card1906,P_YANK,h1906v1a,087,name1906 ;	6 - 3RD BASE     
	ATTRIB    B,3,0,7,5,143,58,44,42,16,06,0,0,1,0,S,R,"RAINES       ",0,card1907,P_YANK,h1907v1a,000,name1907 ;	7 - LEFT FIELD   
	ATTRIB    B,5,1,6,6,154,71,38,30,30,36,0,0,6,0,S,R,"WILLIAMS     ",0,card1908,P_YANK,h1908v1a,089,name1908 ;	8 - RIGHT FIELD  
	ATTRIB    W,2,1,7,7,150,83,16,26,30,48,0,0,5,0,L,L,"O'NEILL      ",0,card1909,P_YANK,h1909v1a,088,name1909 ;	7 - CENTER FIELD 
	ATTRIB    W,3,6,5,5,151,75,42,25,25,25,0,0,0,0,L,R,"CONE         ",0,card1910,P_YANK,h1909v1a,000,name1910 ; 10 - STARTER 1                     
	ATTRIB    W,3,7,6,6,161,60,40,25,25,25,0,0,0,0,L,L,"ROGERS       ",0,card1911,P_YANK,h1909v1a,000,name1911 ; 10 - STARTER 4                     
	ATTRIB    W,4,6,5,5,121,58,38,25,25,25,0,0,0,0,L,L,"PETTITTE     ",0,card1912,P_YANK,h1909v1a,000,name1912 ; 12 - STARTER 3                     
	ATTRIB    B,1,1,5,5,133,64,40,25,25,25,0,0,0,0,R,R,"GOODEN       ",0,card1913,P_YANK,h1909v1a,000,name1913 ; 11 - STARTER 2                     
	ATTRIB    W,3,5,5,5,183,96,50,25,25,25,0,0,0,1,R,R,"WETTELAND    ",0,card1914,P_YANK,h1909v1a,000,name1914 ; 14 - CLOSER 1                      
					                        
OaklandAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    B,2,9,5,5,139,86,29,00,00,00,0,0,3,0,R,R,"BERROA       ",0,card2001,P_ATHL,h2001v1a,092,name2001 ;	7 - LEFT FIELD   
	ATTRIB    W,3,6,5,6,139,76,03,20,30,40,0,0,7,0,R,R,"STEINBACH    ",0,card2002,P_ATHL,h2002v1a,000,name2002 ;	2 - CATCHER      
	ATTRIB    W,2,5,8,8,137,99,12,36,40,30,0,0,4,0,R,R,"MCGWIRE      ",0,card2003,P_ATHL,h2003v1a,090,name2003 ;	3 - 1ST BASE     
	ATTRIB    W,1,3,4,6,127,01,25,30,24,24,0,0,2,0,S,R,"GATES        ",0,card2004,P_ATHL,h2004v1a,000,name2004 ;	4 - 2ND BASE     
	ATTRIB    W,1,4,3,5,132,44,30,36,38,26,0,0,9,0,R,R,"BORDICK      ",0,card2005,P_ATHL,h2005v1a,000,name2005 ;	5 - SHORTSTOP    
	ATTRIB    W,4,5,6,6,118,67,14,28,24,38,0,0,6,0,R,R,"GIAMBI       ",0,card2006,P_ATHL,h2006v1a,000,name2006 ;	1 - DH           
	ATTRIB    B,2,9,5,5,139,12,24,24,24,24,0,0,1,0,R,R,"YOUNG        ",0,card2007,P_ATHL,h2007v1a,000,name2007 ;	9 - RIGHT FIELD  
	ATTRIB    W,0,7,4,6,132,81,25,27,20,34,0,0,8,0,R,R,"BROSIUS      ",0,card2008,P_ATHL,h2008v1a,091,name2008 ;	6 - 3RD BASE     
	ATTRIB    H,2,3,5,5,139,12,08,16,24,12,0,0,5,0,R,R,"MUNOZ        ",0,card2009,P_ATHL,h2009v1a,131,name2009 ;	7 - LEFT FIELD   
	ATTRIB    W,3,9,5,5,111,53,38,25,25,25,0,0,0,0,L,L,"WOJCIECHOWSKI",0,card2010,P_ATHL,h2009v1a,000,name2010 ; 11 - STARTER 2                     
	ATTRIB    W,5,9,7,8,086,79,42,25,25,25,0,0,0,0,R,R,"VANPOPPEL    ",0,card2011,P_ATHL,h2009v1a,000,name2011 ; 12 - STARTER 3                     
	ATTRIB    W,1,7,5,7,075,30,20,25,25,25,0,0,0,0,R,L,"JOHNS        ",0,card2012,P_ATHL,h2009v1a,000,name2012 ; 13 - STARTER 4                     
	ATTRIB    W,1,7,5,7,102,88,46,25,25,25,0,0,0,0,L,R,"REYES        ",0,card2013,P_ATHL,h2009v1a,000,name2013 ; 10 - STARTER 1                     
	ATTRIB    W,4,1,5,6,088,71,40,25,25,25,0,0,0,0,R,L,"MOHLER       ",0,card2014,P_ATHL,h2009v1a,000,name2014 ; 14 - CLOSER 1                      
                                                                                 	                     	      
PhiladelphiaAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    W,0,8,6,5,158,45,31,00,00,00,0,0,9,0,L,L,"EISENREICH   ",0,card2101,P_PHIL,h2101v1a,000,name2101 ;	7 - LEFT FIELD   
	ATTRIB    H,1,8,6,6,143,70,16,20,24,22,0,0,7,0,L,R,"SANTIAG0     ",0,card2102,P_PHIL,h2102v1a,000,name2102 ;	2 - CATCHER      
	ATTRIB    W,2,5,4,4,153,56,28,24,20,04,0,0,3,0,S,R,"JEFFERIES    ",0,card2103,P_PHIL,h2103v1a,094,name2103 ;	3 - 1ST BASE     
	ATTRIB    W,1,2,4,5,142,15,24,30,34,27,0,0,2,0,L,R,"MORANDINI    ",0,card2104,P_PHIL,h2104v1a,095,name2104 ;	4 - 2ND BASE     
	ATTRIB    W,1,9,3,6,109,01,24,28,32,26,0,0,8,0,S,R,"STOCKER      ",0,card2105,P_PHIL,h2105v1a,000,name2105 ;	5 - SHORTSTOP    
	ATTRIB    W,2,7,5,6,123,73,18,18,17,24,0,4,6,0,R,R,"ZEILE        ",0,card2106,P_PHIL,h0506v1a,000,name2106 ;	6 - 3RD BASE     
	ATTRIB    W,1,0,6,6,128,70,09,20,24,30,0,0,4,0,L,R,"DAULTON      ",0,card2107,P_PHIL,h2107v1a,093,name2107 ;	2 - CATCHER      
	ATTRIB    W,0,4,5,4,132,52,24,22,24,02,0,0,1,0,L,L,"DYKSTRA      ",0,card2108,P_PHIL,h2108v1a,096,name2108 ;	8 - CENTER FIELD 
	ATTRIB    B,2,2,5,5,135,86,31,30,27,50,0,0,5,0,S,R,"WHITEN       ",0,card2109,P_PHIL,h2109v1a,000,name2109 ;	9 - RIGHT FIELD  
	ATTRIB    H,5,0,5,5,163,99,42,25,25,25,0,0,0,0,L,L,"FERNANDEZ    ",0,card2110,P_PHIL,h2109v1a,132,name2110 ; 13 - STARTER 4                     
	ATTRIB    W,4,8,4,6,096,51,28,25,25,25,0,0,0,0,L,R,"SCHILLING    ",0,card2111,P_PHIL,h2109v1a,000,name2111 ; 10 - STARTER 1                     
	ATTRIB    W,4,4,5,5,122,61,38,25,25,25,0,0,0,0,R,R,"GRACE        ",0,card2112,P_PHIL,h2109v1a,098,name2112 ; 11 - STARTER 2                     
	ATTRIB    W,2,8,5,8,064,54,40,25,25,25,0,0,0,0,R,R,"GREEN        ",0,card2113,P_PHIL,h2109v1a,097,name2113 ; 12 - STARTER 3                     
	ATTRIB    W,5,1,8,7,185,86,46,25,25,25,0,0,0,0,R,R,"BOTTALICO    ",0,card2114,P_PHIL,h2109v1a,000,name2114 ; 14 - CLOSER 1                      
					                                          			      
PittsburghAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    B,3,5,6,6,141,50,28,00,00,00,0,0,9,0,L,R,"CLARK        ",0,card2201,P_PIRA,h2201v1a,099,name2201 ;	1 - PH           
	ATTRIB    W,5,2,4,4,130,01,15,24,24,28,0,0,8,0,R,R,"KENDALL      ",0,card2202,P_PIRA,h2202v1a,000,name2202 ;	2 - CATCHER      
	ATTRIB    W,0,7,4,6,133,87,25,25,25,25,0,0,4,0,R,R,"KING         ",0,card2203,P_PIRA,h2203v1a,100,name2203 ;	6 - 1ST BASE     
	ATTRIB    H,1,3,5,6,147,35,34,30,30,34,0,0,7,0,R,R,"GARCIA       ",0,card2204,P_PIRA,h2204v1a,000,name2204 ;	4 - 2ND BASE     
	ATTRIB    W,0,3,4,5,131,59,27,22,28,30,0,0,6,0,R,R,"BELL         ",0,card2205,P_PIRA,h2205v1a,101,name2205 ;	5 - SHORTSTOP    
	ATTRIB    B,1,3,8,5,138,51,24,24,40,26,0,0,5,0,R,R,"HAYES        ",0,card2206,P_PIRA,h2206v1a,000,name2206 ;	6 - 3RD BASE     
	ATTRIB    B,2,8,7,5,141,68,42,44,28,08,0,0,2,0,L,L,"MARTIN       ",0,card2207,P_PIRA,h2207v1a,102,name2207 ;	7 - LEFT FIELD   
	ATTRIB    W,0,5,4,5,136,04,31,26,30,24,0,0,1,0,R,R,"KINGERY      ",0,card2208,P_PIRA,h2208v1a,000,name2208 ;	8 - CENTER FIELD 
	ATTRIB    H,0,6,4,5,150,70,29,28,24,08,0,0,3,0,L,R,"MERCED       ",0,card2209,P_PIRA,h2209v1a,103,name2209 ;	9 - RIGHT FIELD  
	ATTRIB    W,1,5,7,6,158,64,34,25,25,25,0,0,0,0,L,L,"NEAGLE       ",0,card2210,P_PIRA,h2209v1a,000,name2210 ; 10 - STARTER 1                     
	ATTRIB    W,3,4,5,5,072,44,26,25,25,25,0,0,0,0,L,L,"SMITH        ",0,card2211,P_PIRA,h2209v1a,000,name2211 ; 11 - STARTER 2                     
	ATTRIB    W,4,3,6,6,090,65,36,25,25,25,0,0,0,0,R,R,"WAGNER       ",0,card2212,P_PIRA,h2209v1a,000,name2212 ; 12 - STARTER 3                     
	ATTRIB    W,5,7,5,5,101,67,38,25,25,25,0,0,0,0,R,R,"ERICKS       ",0,card2213,P_PIRA,h2209v1a,000,name2213 ; 13 - STARTER 4                     
	ATTRIB    W,3,2,6,5,097,86,40,25,25,25,0,0,0,0,R,R,"CORDOVA      ",0,card2214,P_PIRA,h2209v1a,000,name2214 ; 14 - CLOSER 1                      
					                                                                         
StLouisAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    B,0,1,2,4,100,07,35,00,00,00,0,0,9,0,S,R,"MCGEE        ",0,card2301,P_CARI,h2301v1a,104,name2301 ;	1 - DH           
	ATTRIB    W,1,9,5,6,108,04,15,20,20,28,0,0,8,0,R,R,"PAGNOZZI     ",0,card2302,P_CARI,h2302v1a,000,name2302 ;	2 - CATCHER      
	ATTRIB    W,4,7,5,5,154,15,09,27,30,12,0,0,7,0,L,R,"MABRY        ",0,card2303,P_CARI,h2303v1a,000,name2303 ;	3 - 1ST BASE     
	ATTRIB    H,1,3,3,4,105,01,27,24,34,27,0,0,1,0,S,R,"ALICEA       ",0,card2304,P_CARI,h2304v1a,000,name2304 ;	4 - 2ND BASE     
	ATTRIB    B,1,0,4,5,122,04,43,34,30,34,0,0,2,0,R,R,"CLAYTON      ",0,card2305,P_CARI,h2505v1a,000,name2305 ;	5 - SHORTSTOP    
	ATTRIB    W,0,8,6,5,131,90,09,33,26,16,0,0,6,0,R,R,"GAETTI       ",0,card2306,P_CARI,h2306v1a,000,name2306 ;	6 - 3RD BASE     
	ATTRIB    B,0,6,6,5,138,92,36,30,24,10,2,0,4,0,R,R,"GANT         ",0,card2307,P_CARI,h2307v1a,106,name2307 ;	7 - LEFT FIELD   
	ATTRIB    B,1,6,5,5,139,86,35,30,26,32,0,0,3,0,L,L,"LANKFORD     ",0,card2308,P_CARI,h2308v1a,107,name2308 ;	8 - CENTER FIELD 
	ATTRIB    B,0,3,6,6,148,82,32,26,28,36,0,0,5,0,R,R,"JORDAN       ",0,card2309,P_CARI,h2309v1a,000,name2309 ;	9 - RIGHT FIELD  
	ATTRIB    W,3,6,8,6,152,41,30,25,25,25,0,0,0,0,R,R,"BENES        ",0,card2310,P_CARI,h2309v1a,000,name2310 ; 11 - STARTER 2                     
	ATTRIB    W,3,0,5,7,102,88,46,25,25,25,0,0,0,1,L,R,"STOTTLEMYRE  ",0,card2311,P_CARI,h2309v1a,000,name2311 ; 10 - STARTER 1                     
	ATTRIB    W,3,1,5,6,139,65,44,25,25,25,0,0,0,0,L,L,"OSBORNE      ",0,card2312,P_CARI,h2309v1a,000,name2312 ; 12 - STARTER 3                     
	ATTRIB    W,4,0,5,5,037,64,42,25,25,25,0,0,0,0,R,R,"BENES        ",0,card2313,P_CARI,h2309v1a,000,name2313 ; 13 - STARTER 4                     
	ATTRIB    W,4,3,5,6,088,71,40,25,25,25,0,0,0,2,R,R,"ECKERSLEY    ",0,card2314,P_CARI,h2309v1a,000,name2314 ; 14 - CLOSER 1                      
					                                                                         
SDAttr:				      	                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    B,0,8,4,6,118,62,16,00,00,00,0,0,9,0,L,R,"NEWFIELD     ",0,card2401,P_PADR,h2401v1a,000,name2401 ;	1 - PH           
	ATTRIB    W,1,2,5,5,122,70,29,27,30,38,0,0,6,0,R,R,"FLAHERTY     ",0,card1002,P_TIGE,h1002v1a,000,name1002 ;	2 - CATCHER      
	ATTRIB    W,1,2,6,6,155,62,12,28,26,26,0,0,5,0,L,L,"JOYNER       ",0,card2403,P_PADR,h2403v1a,108,name2403 ;	3 - 1ST BASE     
	ATTRIB    W,0,2,5,5,128,01,26,36,38,30,0,0,7,0,R,R,"REED         ",0,card2404,P_PADR,h2404v1a,000,name2404 ;	4 - 2ND BASE     
	ATTRIB    W,0,4,2,6,105,31,26,25,25,25,0,0,8,0,R,R,"GOMEZ        ",0,card2405,P_TIGE,h2405v1a,000,name2405 ;	5 - SHORTSTOP    
	ATTRIB    W,0,0,6,5,151,84,14,54,50,54,0,0,4,0,S,R,"CAMINITI     ",0,card2406,P_PADR,h2406v1a,109,name2406 ;	6 - 3RD BASE     
	ATTRIB    B,2,4,5,4,150,55,44,40,24,10,0,0,1,0,R,L,"HENDERSON    ",0,card2407,P_PADR,h2407v1a,110,name2407 ;	7 - LEFT FIELD   
	ATTRIB    W,1,2,5,5,149,41,50,54,50,30,0,0,2,0,L,L,"FINLEY       ",0,card2408,P_PADR,h2408v1a,000,name2408 ;	8 - CENTER FIELD 
	ATTRIB    B,1,9,7,3,184,38,14,28,28,24,0,0,3,0,L,L,"GWYNN        ",0,card2409,P_PADR,h2409v1a,111,name2409 ;	9 - RIGHT FIELD  
	ATTRIB    W,4,3,5,8,183,70,44,25,25,25,0,0,0,0,R,R,"ASHBY        ",0,card2410,P_PADR,h2409v1a,000,name2410 ; 10 - STARTER 1                     
	ATTRIB    W,5,0,5,5,137,54,42,25,25,25,0,0,0,0,R,R,"HAMILTON     ",0,card2411,P_PADR,h2409v1a,000,name2411 ; 11 - STARTER 2                     
	ATTRIB    W,0,0,6,7,101,36,26,25,25,25,0,0,0,0,R,R,"TEWKSBURY    ",0,card2412,P_PADR,h2409v1a,000,name2412 ; 13 - STARTER 4                     
	ATTRIB    H,3,4,5,5,081,56,30,25,25,25,0,0,0,3,L,L,"VALENZUELA   ",0,card2413,P_PADR,h2409v1a,000,name2413 ; 12 - STARTER 3                     
	ATTRIB    W,5,1,6,4,136,87,48,25,25,25,0,0,0,0,R,R,"HOFFMANN     ",0,card2414,P_PADR,h2409v1a,000,name2414 ; 14 - CLOSER 1                      
					                                                                         
SFAttr:					                                                                         
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    W,1,7,4,6,098,77,10,00,00,00,0,0,9,0,L,L,"PHILLIPS     ",0,card2501,P_GIAN,h2501v1a,000,name2501 ;	1 - PH           
	ATTRIB    W,0,8,6,5,126,06,02,26,40,28,0,0,8,0,R,R,"MANWARING    ",0,card2502,P_GIAN,h2502v1a,000,name2502 ;	2 - CATCHER      
	ATTRIB    W,4,6,5,5,151,81,09,22,24,24,0,0,5,0,R,L,"CARREON      ",0,card2503,P_GIAN,h2503v1a,000,name2503 ;	3 - 1ST BASE     
	ATTRIB    W,0,6,3,5,112,58,18,24,24,24,0,0,2,0,R,R,"THOMPSON     ",0,card2504,P_GIAN,h2504v1a,000,name2504 ;	4 - 2ND BASE     
	ATTRIB    B,1,2,4,6,148,68,45,32,26,54,2,0,7,0,R,R,"DUNSTON      ",0,card2505,P_GIAN,h0505v1a,112,name2505 ;	5 - SHORTSTOP    
	ATTRIB    W,0,9,7,6,168,89,17,46,50,46,0,0,4,0,R,R,"WILLIAMS     ",0,card2506,P_GIAN,h2506v1a,113,name2506 ;	6 - 3RD BASE     
	ATTRIB    B,2,5,4,6,147,92,48,44,36,48,0,0,3,0,L,L,"BONDS        ",0,card2507,P_GIAN,h2507v1a,114,name2507 ;	7 - LEFT FIELD   
	ATTRIB    H,2,8,6,6,134,40,35,38,34,28,0,0,1,0,L,L,"JAVIER       ",0,card2508,P_GIAN,h2508v1a,000,name2508 ;	8 - CENTER FIELD 
	ATTRIB    B,0,1,8,6,132,83,42,26,24,42,0,0,6,0,R,R,"HILL         ",0,card2509,P_GIAN,h2509v1a,115,name2509 ;	9 - RIGHT FIELD  
	ATTRIB    W,3,0,5,5,103,53,36,25,25,25,0,0,0,0,R,R,"LEITER       ",0,card2510,P_GIAN,h2509v1a,000,name2510 ; 12 - STARTER 3                     
	ATTRIB    W,5,0,7,6,146,91,44,25,25,25,0,0,0,0,R,R,"GARDNER      ",0,card2511,P_GIAN,h2509v1a,000,name2511 ; 11 - STARTER 2                     
	ATTRIB    W,3,1,7,7,139,59,30,25,25,25,0,0,0,0,R,R,"FERNANDEZ    ",0,card2512,P_GIAN,h2509v1a,132,name2512 ; 10 - STARTER 1                     
	ATTRIB    W,4,5,5,5,040,39,20,25,25,25,0,0,0,0,R,L,"WATSON       ",0,card2513,P_GIAN,h2509v1a,000,name2513 ; 13 - STARTER 4                     
	ATTRIB    W,4,7,9,6,107,64,42,25,25,25,0,0,0,0,R,R,"BECK         ",0,card2514,P_GIAN,h2509v1a,000,name2514 ; 14 - CLOSER 1                      
					                                                                         
SeattleAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    H,1,1,5,5,177,87,16,00,00,00,0,0,4,0,R,R,"MARTINEZ     ",0,card2601,P_MARI,h2601v1a,116,name2601 ;	1 - DH           
	ATTRIB    W,0,6,5,7,139,56,10,24,24,34,0,0,8,0,R,R,"WILSON       ",0,card2602,P_MARI,h2602v1a,000,name2602 ;	2 - CATCHER      
	ATTRIB    W,1,1,8,6,118,93,10,24,16,24,0,0,6,0,L,R,"SORRENTO     ",0,card2603,P_MARI,h2603v1a,000,name2603 ;	3 - 1ST BASE     
	ATTRIB    B,2,8,1,3,148,01,31,26,16,06,0,0,2,0,S,R,"CORA         ",0,card2604,P_MARI,h2604v1a,000,name2604 ;	4 - 2ND BASE     
	ATTRIB    H,0,9,5,5,143,51,30,48,36,30,0,0,9,0,R,R,"RODRIGUEZ    ",0,card2605,P_MARI,h2605v1a,117,name2605 ;	5 - SHORTSTOP    
	ATTRIB    W,1,6,7,6,128,86,24,34,30,30,0,0,7,0,R,R,"DAVIS        ",0,card2606,P_MARI,h2606v1a,118,name2606 ;	6 - 3RD BASE     
	ATTRIB    W,2,9,5,5,144,07,32,24,24,24,0,0,1,0,S,R,"BRAGG        ",0,card2607,P_MARI,h2607v1a,000,name2607 ;	7 - LEFT FIELD   
	ATTRIB    B,2,4,7,7,131,93,48,54,48,52,0,0,3,0,L,L,"GRIFFEY JR   ",0,card2608,P_MARI,h2608v1a,119,name2608 ;	8 - CENTER FIELD 
	ATTRIB    W,1,9,7,7,131,94,20,24,28,50,0,0,5,0,R,R,"BUHNER       ",0,card2609,P_MARI,h2609v1a,120,name2609 ;	9 - RIGHT FIELD  
	ATTRIB    W,5,1,8,9,222,99,52,25,25,25,0,0,0,0,R,L,"JOHNSON      ",0,card2610,P_MARI,h2609v1a,121,name2610 ; 10 - STARTER 1                     
	ATTRIB    W,2,9,8,7,084,45,38,25,25,25,0,0,0,0,R,R,"BOSIO        ",0,card2611,P_MARI,h2609v1a,000,name2611 ; 11 - STARTER 2                     
	ATTRIB    W,3,4,5,6,095,64,38,25,25,25,0,0,0,0,L,L,"HITCHCOCK    ",0,card2612,P_MARI,h2609v1a,000,name2612 ; 13 - STARTER 4                     
	ATTRIB    W,4,0,5,5,037,64,42,25,25,25,0,0,0,0,R,R,"WOLCOTT      ",0,card2613,P_MARI,h2609v1a,000,name2613 ; 13 - STARTER 4                     
	ATTRIB    W,1,3,6,7,108,97,50,25,25,25,0,0,0,0,R,R,"CHARLTON     ",0,card2614,P_MARI,h2609v1a,000,name2614 ; 14 - CLOSER 1                      
					                                                                         
TexasAttr:					                                                                 
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    W,1,5,7,6,119,93,01,18,30,12,0,0,6,0,S,R,"TETTLETON    ",0,card2801,P_BLUE,h2701v1a,000,name2701 ;	1 - DH           
	ATTRIB    W,0,7,6,4,152,59,24,36,30,50,0,0,7,0,R,R,"RODRIGUEZ    ",0,card2802,P_BLUE,h2702v1a,122,name2702 ;	2 - CATCHER      
	ATTRIB    W,2,2,5,5,151,75,20,30,32,25,0,0,3,0,L,L,"CLARK        ",0,card2803,P_BLUE,h2703v1a,123,name2703 ;	3 - 1ST BASE     
	ATTRIB    B,0,1,2,4,139,15,36,28,24,24,0,0,2,0,R,R,"MCLEMORE     ",0,card2804,P_BLUE,h2704v1a,000,name2704 ;	4 - 2ND BASE     
	ATTRIB    W,2,3,4,6,110,53,29,35,30,38,0,0,9,0,R,R,"ELSTER       ",0,card2805,P_BLUE,h2705v1a,000,name2705 ;	5 - SHORTSTOP    
	ATTRIB    W,1,6,5,6,168,93,18,24,26,28,0,0,5,0,R,R,"PALMER       ",0,card2806,P_BLUE,h2706v1a,000,name2706 ;	6 - 3RD BASE     
	ATTRIB    W,2,9,5,5,136,70,13,24,26,32,0,0,8,0,L,L,"GREER        ",0,card2809,P_BLUE,h2709v1a,124,name2707 ;	9 - RIGHT FIELD  
	ATTRIB    B,2,4,4,6,136,13,28,32,30,04,0,0,1,0,L,R,"HAMILTON     ",0,card2808,P_BLUE,h2708v1a,000,name2708 ;	8 - CENTER FIELD 
	ATTRIB    B,0,0,7,7,148,93,25,24,24,24,0,0,4,0,R,R,"GONZALES     ",0,card2807,P_BLUE,h2707v1a,000,name2709 ;	7 - LEFT FIELD   
	ATTRIB    B,4,4,6,6,131,57,42,25,25,25,0,0,0,0,R,R,"HILL         ",0,card2810,P_BLUE,h2709v1a,125,name2710 ; 13 - STARTER 4                     
	ATTRIB    W,5,9,8,6,111,70,42,25,25,25,0,0,0,2,R,R,"PAVLIK       ",0,card2811,P_BLUE,h2709v1a,000,name2711 ; 12 - STARTER 3                     
	ATTRIB    W,3,6,6,6,161,60,40,25,25,25,0,0,0,0,L,L,"WITT         ",0,card2812,P_BLUE,h2709v1a,000,name2712 ; 10 - STARTER 1                     
	ATTRIB    B,4,6,8,8,053,51,36,25,25,25,0,0,0,1,R,L,"OLIVER       ",0,card2813,P_BLUE,h2709v1a,000,name2713 ; 11 - STARTER 2                     
	ATTRIB    W,4,0,6,7,178,57,42,25,25,25,0,0,0,0,R,R,"HENNEMAN     ",0,card2814,P_BLUE,h2709v1a,000,name2714 ; 14 - CLOSER 1                      
                                                                                 	                     	     
TorontoAttr:				                        
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   		                        	         
	ATTRIB    B,0,4,4,5,135,67,11,00,00,00,0,0,6,0,R,R,"DELGADO      ",0,card2701,P_RANG,h2801v1a,000,name2801 ;	1 - DH           
	ATTRIB    B,5,3,6,7,121,04,09,24,24,38,0,0,8,0,L,R,"MARTINEZ     ",0,card2702,P_RANG,h2802v1a,126,name2802 ;	2 - CATCHER      
	ATTRIB    W,0,9,7,8,146,34,12,29,38,34,0,0,4,0,L,L,"OLERUD       ",0,card2703,P_RANG,h2803v1a,127,name2803 ;	3 - 1ST BASE     
	ATTRIB    B,1,2,4,5,150,60,32,29,36,40,0,0,2,0,S,R,"CEDENO       ",0,card2704,P_RANG,h2804v1a,000,name2804 ;	4 - 2ND BASE     
	ATTRIB    H,0,8,5,5,122,64,27,34,20,28,0,0,9,0,R,R,"GONZALES     ",0,card2705,P_RANG,h2805v1a,128,name2805 ;	5 - SHORTSTOP    
	ATTRIB    W,3,3,7,6,122,74,15,26,24,36,0,0,5,0,R,R,"SPRAGUE      ",0,card2706,P_RANG,h2806v1a,000,name2806 ;	6 - 3RD BASE     
	ATTRIB    B,2,9,8,7,127,82,25,27,24,15,0,0,3,0,R,R,"CARTER       ",0,card2707,P_RANG,h2807v1a,129,name2807 ;	7 - LEFT FIELD   
	ATTRIB    B,0,2,5,5,148,01,50,50,30,04,0,0,1,0,S,R,"NIXON        ",0,card2708,P_RANG,h2808v1a,000,name2808 ;	8 - CENTER FIELD 
	ATTRIB    W,1,5,5,7,144,79,24,24,24,42,0,0,7,0,L,L,"GREEN        ",0,card2709,P_RANG,h2809v1a,130,name2809 ;	9 - RIGHT FIELD  
	ATTRIB    W,4,1,6,6,074,60,44,25,25,25,0,0,0,0,R,R,"HENTGEN      ",0,card2710,P_RANG,h2809v1a,000,name2810 ; 10 - STARTER 1                     
	ATTRIB    W,2,8,7,7,148,75,40,25,25,25,0,0,0,0,L,L,"HANSON       ",0,card2711,P_RANG,h2809v1a,000,name2811 ; 11 - STARTER 2                     
	ATTRIB    W,4,8,4,6,096,51,28,25,25,25,0,0,0,0,L,R,"QUANTRILL    ",0,card2712,P_RANG,h2809v1a,000,name2812 ; 10 - STARTER 1                     
	ATTRIB    B,6,6,5,5,014,62,34,25,25,25,0,0,0,0,R,R,"GUZMAN       ",0,card2713,P_RANG,h2809v1a,000,name2813 ; 12 - STARTER 3                     
	ATTRIB    W,4,0,4,4,169,47,44,25,25,25,0,0,0,0,L,L,"TIMLIN       ",0,card2714,P_RANG,h2809v1a,000,name2814 ; 14 - CLOSER 1                      
						                                                          
						                 
;************************************************************************			       	                 
						                                                      
						                                                      
attrib_size     equ           Att_end-AtlantaAttr			                              
teamattrib_size equ           Atl_end-AtlantaAttr			                              
						                                                      
						                                                      
						                                                      
						                                                      
DraftAttr: ;THIS IS JUST A PLACE HOLDER				                                      
                                                                                                      
ROSTERsize	equ	DraftAttr-ROSTERS                                                             
                                                                                                      
	         ;E # # W H  AV PW SP RG GL AR H H O P B T   			                      
	ATTRIB    W,0,4,4,5,135,72,12,00,00,00,0,0,2,0,R,R,"DELGADO      ",0,card2801,P_BLUE,h0401v1a,379,name2701   ;	1 - DH           
	ATTRIB    W,5,3,6,7,121,11,00,00,00,00,0,0,8,0,L,R,"MARTINEZ     ",0,card2802,P_BLUE,h0402v1a,379,name2702   ;	2 - CATCHER      
	ATTRIB    W,0,9,7,8,146,45,00,00,00,00,0,0,4,0,L,L,"OLERUD       ",0,card2803,P_BLUE,h0403v1a,379,name2703   ;	3 - 1ST BASE     
	ATTRIB    W,1,2,4,5,150,67,30,00,00,00,0,0,1,0,S,R,"CEDENO       ",0,card2804,P_BLUE,h0404v1a,379,name2704   ;	4 - 2ND BASE     
	ATTRIB    W,0,8,5,5,122,70,04,00,00,00,0,0,9,0,R,R,"GONZALES     ",0,card2804,P_BLUE,h0405v1a,383,name2809   ;	5 - SHORTSTOP    
	ATTRIB    W,3,3,7,6,122,78,00,00,00,00,0,0,5,0,R,R,"SPRAGUE      ",0,card2806,P_BLUE,h0406v1a,384,name2706   ;	6 - 3RD BASE     
	ATTRIB    W,2,9,8,7,127,85,12,00,00,00,0,0,3,0,R,R,"CARTER       ",0,card2807,P_BLUE,h0407v1a,385,name2707   ;	7 - LEFT FIELD   
	ATTRIB    W,0,2,5,5,148,00,50,00,00,00,0,0,1,0,S,R,"NIXON        ",0,card2808,P_RANG,h0408v1a,386,name2708   ;	8 - CENTER FIELD 
	ATTRIB    W,1,5,5,7,144,82,01,00,00,00,0,0,6,0,L,L,"GREEN        ",0,card2809,P_BLUE,h0409v1a,387,name2705   ;	9 - RIGHT FIELD  
	ATTRIB    W,4,1,6,6,074,60,46,00,00,00,0,0,0,0,R,R,"HENTGEN      ",0,card2810,P_BLUE,h0409v1a,388,name2710   ;10 - STARTER 1                     
	ATTRIB    W,2,8,7,7,148,75,44,00,00,00,0,0,0,0,L,L,"HANSON       ",0,card2811,P_REDX,h0409v1a,389,name2711   ;11 - STARTER 2                     
	ATTRIB    W,4,8,4,6,096,51,38,00,00,00,0,0,0,0,L,R,"QUANTRILL    ",0,card2812,P_PHIL,h0409v1a,390,name2712   ;10 - STARTER 1                     
	ATTRIB    W,6,6,5,5,014,62,41,00,00,00,0,0,0,0,R,R,"GUZMAN       ",0,card2813,P_BLUE,h0409v1a,391,name2713   ;12 - STARTER 3                     
	ATTRIB    W,4,9,4,4,169,47,44,00,00,00,0,0,0,0,L,L,"CASTILLO     ",0,card2814,P_BLUE,h0409v1a,392,name2714   ;14 - CLOSER 1     
                                                                                                      
                                                                                                      
                                                                                                 
                                                                                                      
AmericanLeagueAttrB:                                                                                  
	         ;E # # W H  AV PW SP RG GL AR H H O P B T                                            
	ATTRIB    B,4,2,9,6,150,92,14,18,20,24,0,0,6,0,L,R,"VAUGHN       ",0,card0303,P_REDX,h0303v1a,013,name0303 ;	3 - 1ST BASE     
	ATTRIB    W,0,7,6,4,152,59,24,36,30,50,0,0,9,0,R,R,"RODRIGUEZ    ",0,card2802,P_BLUE,h2702v1a,122,name2802 ;	2 - CATCHER      
	ATTRIB    B,3,5,9,8,154,94,08,18,14,24,0,0,4,0,R,R,"THOMAS       ",0,card0603,P_WHIT,h0603v1a,029,name0603 ;	3 - 1ST BASE     
	ATTRIB    H,1,2,4,5,150,60,42,54,54,40,0,0,2,0,S,R,"ALOMAR       ",0,card0204,P_ORIO,h0204v1a,007,name0204 ;	4 - 2ND BASE     
	ATTRIB    W,0,8,8,7,131,70,24,35,38,34,0,0,7,0,R,R,"RIPKEN       ",0,card0205,P_ORIO,h0205v1a,008,name0205 ;	5 - SHORTSTOP    
	ATTRIB    W,1,2,5,6,162,07,15,30,50,34,0,0,8,0,L,R,"BOGGS        ",0,card1906,P_YANK,h1906v1a,087,name1906 ;	6 - 3RD BASE     
	ATTRIB    B,0,8,7,6,159,99,26,30,26,28,0,0,5,0,R,R,"BELLE        ",0,card0807,P_INDI,h0807v1a,037,name0807 ;	7 - LEFT FIELD   
	ATTRIB    B,0,7,4,5,155,26,54,54,50,48,0,0,1,0,L,L,"LOFTON       ",0,card0808,P_INDI,h0808v1a,038,name0808 ;	8 - CENTER FIELD 
	ATTRIB    B,2,4,7,7,131,93,48,54,48,52,0,0,3,0,L,L,"GRIFFEY JR   ",0,card2608,P_MARI,h2608v1a,119,name2608 ;	8 - CENTER FIELD 
	ATTRIB    W,4,1,6,7,102,78,40,25,25,25,0,0,0,0,L,R,"NAGY         ",0,card0813,P_INDI,h0809v1a,000,name0813 ; 10 - STARTER 1                     
	ATTRIB    W,5,9,8,6,111,70,42,25,25,25,0,0,0,2,R,R,"PAVLIK       ",0,card2711,P_BLUE,h2709v1a,000,name2811 ; 12 - STARTER 3                     
	ATTRIB    W,4,6,5,5,121,58,38,25,25,25,0,0,0,0,L,L,"PETTITTE     ",0,card1912,P_YANK,h1909v1a,000,name1912 ; 12 - STARTER 3                     
	ATTRIB    W,4,0,7,8,156,99,46,25,25,25,0,0,0,0,R,R,"PERCIVAL     ",0,card0414,P_ANGE,h0409v1a,000,name0414 ; 14 - CLOSER 1                      
	ATTRIB    B,3,9,9,7,163,99,48,25,25,25,0,0,0,0,R,R,"HERNANDEZ    ",0,card0614,P_WHIT,h0609v1a,000,name0614 ; 14 - CLOSER 1                      
                                                                                                      
                                                                                                      
NatioanlLeagueAttrB:                                                                                  
	         ;E # # W H  AV PW SP RG GL AR H H O P B T                                            
	ATTRIB    W,0,5,5,5,145,90,24,24,24,26,0,0,7,0,R,R,"BAGWELL      ",0,card1203,P_ASTR,h1203v1a,054,name1203 ;	3 - 1ST BASE     
	ATTRIB    W,3,1,5,7,173,92,16,24,22,24,0,0,4,0,R,R,"PIAZZA       ",0,card1402,P_DODG,h1402v1a,062,name1402 ;	2 - CATCHER      
	ATTRIB    B,2,7,7,7,140,88,24,28,30,25,2,0,5,0,L,L,"MCGRIFF      ",0,card0103,P_BRAV,h0103v1a,002,name0103 ;	3 - 1ST BASE        
	ATTRIB    W,0,7,5,4,151,79,46,50,26,34,0,0,1,0,R,R,"BIGGIO       ",0,card1204,P_ASTR,h1204v1a,055,name1204 ;	4 - 2ND BASE     
	ATTRIB    B,1,1,5,5,160,69,51,54,48,50,2,0,9,0,R,R,"LARKIN       ",0,card0705,P_REDS,h0705v1a,033,name0705;	5 - SHORTSTOP    
	ATTRIB    W,0,9,7,6,168,89,17,46,50,46,0,0,6,0,R,R,"WILLIAMS     ",0,card2506,P_GIAN,h2506v1a,113,name2506 ;	6 - 3RD BASE     
	ATTRIB    B,1,9,7,3,184,38,14,28,28,24,0,0,2,0,L,L,"GWYNN        ",0,card2409,P_PADR,h2409v1a,111,name2409 ;	9 - RIGHT FIELD  
	ATTRIB    B,2,5,4,6,147,92,48,44,36,48,0,0,3,0,L,L,"BONDS        ",0,card2507,P_GIAN,h2507v1a,114,name2507 ;	7 - LEFT FIELD   
	ATTRIB    W,1,0,9,7,170,90,34,24,38,46,0,0,8,0,R,R,"BICHETTE     ",0,card0909,P_ROCK,h0907v1a,043,name0909 ;	7 - LEFT FIELD   
	ATTRIB    W,2,9,4,7,171,88,42,25,25,25,0,0,0,0,R,R,"SMOLTZ       ",0,card0112,P_BRAV,h0109v1a,000,name0112 ; 13 - STARTER 4     	                 
	ATTRIB    W,3,5,6,7,031,59,44,25,25,25,0,0,0,0,R,R,"BROWN        ",0,card1110,P_MARL,h1109v1a,000,name1110 ; 13 - STARTER 4                     
	ATTRIB    W,3,2,2,6,104,78,38,25,25,25,2,6,0,1,R,R,"TRACHSEL     ",0,card0513,P_CUBS,h0509v1a,000,name0513 ; 13 - STARTER 4                     
	ATTRIB    W,4,3,6,7,226,99,52,18,25,25,0,0,0,0,R,R,"WOHLERS      ",0,card0114,P_BRAV,h0109v1a,000,name0114 ; 14 - CLOSER 1      	                 
	ATTRIB    W,3,8,8,8,229,88,42,25,25,25,0,0,0,1,R,R,"WORRELL      ",0,card1414,P_DODG,h1409v1a,000,name1414 ; 14 - CLOSER 1                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
;DesignTeamattrB:                                                                                  
;	         ;E # # W H  AV PW SP RG GL AR H H O P B T                                            
;	ATTRIB    W,1,6,5,1,163,99,12,24,54,26,0,0,4,0,R,R,"DITTON       ",0,card3301,P_DESI,h2901v1a,000,name2901 ;	3 - 1ST BASE     
;	ATTRIB    W,0,0,6,5,144,80,20,24,54,24,0,0,8,0,L,L,"OBERTH       ",0,card3302,P_DESI,h2902v1a,000,name2902 ;	2 - CATCHER      
;	ATTRIB    W,2,6,5,6,145,81,24,28,54,25,0,0,9,0,R,R,"HARRELSON    ",0,card3303,P_DESI,h2903v1a,000,name2903 ;	3 - 1ST BASE        
;	ATTRIB    W,1,3,5,7,179,79,46,54,54,34,0,0,2,0,R,R,"NOON         ",0,card3304,P_DESI,h2904v1a,000,name2904 ;	4 - 2ND BASE     
;	ATTRIB    W,0,9,5,5,172,90,36,54,54,47,0,0,3,0,R,R,"ZIELINSKI    ",0,card3305,P_DESI,h2905v1a,000,name2905;	5 - SHORTSTOP    
;	ATTRIB    W,3,6,5,6,158,84,39,54,54,54,0,0,6,0,R,R,"SMOLIK       ",0,card3306,P_DESI,h2906v1a,000,name2906 ;	6 - 3RD BASE     
;	ATTRIB    W,3,3,9,8,170,96,03,16,54,54,0,0,5,0,S,R,"NEWCOMER     ",0,card3307,P_DESI,h2907v1a,000,name2907 ;	9 - RIGHT FIELD  
;	ATTRIB    W,2,5,1,1,147,64,54,54,54,24,0,0,1,0,R,R,"ATKINS       ",0,card3308,P_DESI,h2908v1a,000,name2908 ;	7 - LEFT FIELD   
;	ATTRIB    W,1,1,3,5,141,67,34,34,54,24,0,0,7,0,L,L,"HALL         ",0,card3309,P_DESI,h2909v1a,000,name2909 ;	7 - LEFT FIELD   
;	ATTRIB    W,0,0,1,1,171,88,54,25,25,25,0,0,0,0,R,R,"FOSHEE       ",0,card3310,P_DESI,h2909v1a,000,name2910 ; 13 - STARTER 4     	                 
;	ATTRIB    W,0,0,6,6,164,59,44,25,25,25,0,0,0,0,R,R,"EVANS        ",2,card3311,P_DESI,h2909v1a,000,name2911 ; 13 - STARTER 4                     
;	ATTRIB    W,0,0,6,6,121,78,38,25,25,25,0,0,0,1,R,R,"CARONE       ",0,card3312,P_DESI,h2909v1a,000,name2912 ; 13 - STARTER 4                     
;	ATTRIB    B,0,0,6,8,137,99,52,25,25,25,0,0,0,0,R,R,"BROOME       ",1,card3313,P_DESI,h2909v1a,000,name2913 ; 14 - CLOSER 1      	                 
;	ATTRIB    W,0,0,5,5,167,88,54,25,25,25,0,0,0,1,R,R,"SHARPE       ",0,card3314,P_DESI,h2909v1a,000,name2914 ; 14 - CLOSER 1                      
;                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      



                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      



                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      


                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      



                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      

                                                                                                      

                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      



                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      



                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      


                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      



                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      

                                                                                                      

                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      



                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      



                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      


                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      



                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      



                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      



                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      



                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      



                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      



                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      


                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      
                                                                                                      


