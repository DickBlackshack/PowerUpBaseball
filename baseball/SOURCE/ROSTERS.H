
NumberOfTeams   equ     28 ;regular season (draftable) teams

Attribdata	.struct
	
AT_ethnicity	ds.b	1
AT_number1		ds.b	1
AT_number2		ds.b	1
AT_weight		ds.b	1
AT_height		ds.b	1
AT_batavg		ds.b	1

;AT_POWER		equ	AT_power	
;AT_SPEED		equ	AT_speed	
;AT_RANGE		equ	AT_range	
;AT_GLOVE		equ	AT_glove	
;AT_ARM		equ	AT_arm	

AT_power		ds.b	1
AT_speed		ds.b	1
AT_range		ds.b	1
AT_glove		ds.b	1
AT_arm		ds.b	1
AT_head		ds.b	1
AT_hair		ds.b	1
AT_order		ds.b	1
AT_pitchtype	ds.b	1
AT_bat		ds.b	1
AT_throw		ds.b	1
AT_POWER		ds.b	1
AT_SPEED		ds.b	1
AT_RANGE		ds.b	1
AT_GLOVE		ds.b	1
AT_ARM		ds.b	1
AT_name		ds.b	13
AT_name_terminator	ds.b	1
AT_card		ds.w	1
AT_cardpal		ds.w	1
AT_headart		ds.w	1
AT_namesnd		ds.w	1
AT_nameart		ds.w	1

	.endstruct

