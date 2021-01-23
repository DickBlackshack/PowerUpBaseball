;***************************************************************************
; Palette Names                                                            *
;***************************************************************************

P_SYSFONT        equ   0
P_METERS         equ   P_SYSFONT

P_BALL           equ   1
P_ZONE           equ   2
P_STADIUM        equ   3

P_FIELD          equ   4
P_BIGFIELD       equ   5

P_BORDPAL        equ   6
P_DIMPPAL        equ   7

P_VHATPAL00      equ   8
P_VHATPAL01      equ   9
P_VHATPAL02      equ   10
P_VHATPAL03      equ   11
P_VISTPAL00      equ   12
P_VISTPAL01      equ   13
P_VISTPAL02      equ   14
P_VISBPAL        equ   15

P_RADCARD        equ   16
;P_FIRST         equ   17
P_VINTAGE        equ   17
P_BAT            equ   18
P_DIMCARD        equ   19

P_DESI			  equ	  20

P_V6             equ   21
P_TESTF          equ   22
;P_WINX          equ   23
;P_WINC          equ   24

P_FIRE           equ   23
P_FIREWORKS1     equ   24

P_BAK1APAL       equ   25
P_BAK1BPAL       equ   26
P_BAKD4PAL       equ   27
;P_FONTDPAL      equ   28
P_TTLSE          equ   29
P_LOGOWOR        equ   30
;P_CARD           equ   30

P_HHATPAL00      equ   31
P_HOMETPAL00     equ   32
P_HOMETPAL01     equ   33
P_HOMETPAL02     equ   34
P_HOMEBPAL       equ   35
;P_BACKDROP      equ   36
P_NEWSCORE       equ   36

P_HHATPAL01      equ   37
P_HHATPAL02      equ   38

P_BLACK          equ   39

;logos must be sequencial
P_LOGOBRA        equ   40
P_LOGOORI        equ   41
P_LOGORED        equ   42
P_LOGOANG        equ   43
P_LOGOCUB        equ   44
P_LOGOWHI        equ   45
P_LOGOCIN        equ   46
P_LOGOIND        equ   47
P_LOGOROC        equ   48
P_LOGOTIG        equ   49
P_LOGOFLO        equ   50
P_LOGOAST        equ   51
P_LOGOROY        equ   52
P_LOGODOD        equ   53
P_LOGOBRE        equ   54
P_LOGOTWI        equ   55
P_LOGOEXP        equ   56
P_LOGOMET        equ   57
P_LOGOYAN        equ   58
P_LOGOATH        equ   59
P_LOGOPHI        equ   60
P_LOGOPIR        equ   61
P_LOGOCAR        equ   62
P_LOGOPAD        equ   63
P_LOGOGIA        equ   64
P_LOGOMAR        equ   65
P_LOGORAN        equ   66
P_LOGOBLU        equ   67
P_LOGOLEFT       equ   68
P_LOGORIGHT      equ   69
P_FIREWORKS2     equ   70
P_HOMER1        equ   71

;logo palettes re-used for cards

P_BRAV           equ   P_LOGOBRA
P_ORIO           equ   P_LOGOORI
P_REDX           equ   P_LOGORED
P_ANGE           equ   P_LOGOANG
P_CUBS           equ   P_LOGOCUB
P_WHIT           equ   P_LOGOWHI
P_REDS           equ   P_LOGOCIN
P_INDI           equ   P_LOGOIND
P_ROCK           equ   P_LOGOROC
P_TIGE           equ   P_LOGOTIG
P_MARL           equ   P_LOGOFLO
P_ASTR           equ   P_LOGOAST
P_ROYA           equ   P_LOGOROY
P_DODG           equ   P_LOGODOD
P_BREW           equ   P_LOGOBRE
P_TWIN           equ   P_LOGOTWI
P_EXPO           equ   P_LOGOEXP
P_METS           equ   P_LOGOMET
P_YANK           equ   P_LOGOYAN
P_ATHL           equ   P_LOGOATH
P_PHIL           equ   P_LOGOPHI
P_PIRA           equ   P_LOGOPIR
P_CARI           equ   P_LOGOCAR
P_PADR           equ   P_LOGOPAD
P_GIAN           equ   P_LOGOGIA
P_MARI           equ   P_LOGOMAR
P_RANG           equ   P_LOGORAN
P_BLUE           equ   P_LOGOBLU
		 
P_PLAYEDBL       equ   72
P_PLAYEDRD       equ   73
P_BATPT          equ   74
P_STOUT01        equ   75

P_CLUB           equ   76
P_SABR           equ   77
P_DUST           equ   78
P_METER          equ   79
P_HHATPAL03      equ   80

P_SO             equ   81     
P_LITE0          equ   82
P_SCOREB         equ   83     

P_BLUESO         equ   84
P_CELEB01        equ   85

P_BIGFIELD2      equ   86
P_BIGFIELD3      equ   87

P_NEORED      equ   88
P_GRAYSHADOW     equ   89

P_OUTFIELDT      equ   90
P_OUTFIELDB      equ   91
P_SCORE          equ   92
P_TITLERB        equ   93
P_TITLEBK1       equ   94
;P_TICKRDDM      equ   P_TITLEBK1
P_TITLEBK2       equ   95
;P_TICKBLDM      equ   P_TITLEBK2
P_TITLEBLU       equ   96
P_TITLEBRN       equ   97
P_TITLEGRN       equ   98
P_GATE           equ   99
P_SHOTA          equ   100
P_SHOTB          equ   101
P_POWERDIM       equ   102
P_NEOBLU      equ   103
P_MARKER         equ   104
;P_HEAD3D         equ   105
P_ITLOGO			  equ	  105
P_MARKCL         equ   106
P_STANDS         equ   107
P_BLACKPAL       equ   108
		 
;P_FONTR1         equ   109
P_TROPHY         equ   109
P_FONTR2         equ   110
;P_FONTB1         equ   111
P_FONTB2         equ   112
P_FONTW1         equ   113
P_FONTW2         equ   114
P_FONTY1         equ   115
;P_FONTY2         equ   116
P_NEOYEL         equ   116
P_DALL           equ   117


P_GRADB          equ   118
P_BASEOMETER     equ   119
P_GREEN          equ   120
P_PURP           equ   121

P_MLB            equ	  122
P_MLBM           equ	  123
P_MLBPA          equ	  124
P_HAWK          equ	  125

;126 used


