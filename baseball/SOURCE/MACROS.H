;****************************************************************
;       General macros						*
;       Incredible Technologies (C) 1990                        *
;****************************************************************

;****************************************************************
;       FILL will fill up to 0ffffh bytes with a value          *
;****************************************************************
FILL    #macro  dest,val,num
	move.l	dest,a0
	move.b	val,d0
	move.w	num,d1
	sub.w	#1,d1			;for dbf below
flll\@:
	move.b	d0,(a0)+
	dbf	d1,flll\@
        endm

;****************************************************************
;       COPY from source to dest num of bytes                   *
;****************************************************************
COPY    macro  source,dest,num
	move.w	num,d0
	sub.w	#1,d0			;use for dbf
	lea.l	source,a0
	lea.l	dest,a1
copppp\@:
	move.b	(a0)+,(a1)+
	dbf	d0,copppp\@
        endm     
                


;****************************************************************
;	draw a quick line using absoulte screen coords.		*
;****************************************************************
QLINE		#macro xstart,ystart,xendm,yendm
	ldd	$xstart
	std	xstr
	ldd	$ystart
	std	ystr
	ldd	$xendm
	std	xend
	ldd	$yendm
	std	yend
	jsr	quick_line
	#endm

;****************************************************************
;	draw a line with respect to a 0,0 cebter point within	*
;	a defined window.					*
;****************************************************************
LINE		#macro xstart,ystart,xendm,yendm
	ldd	$xstart
	std	line_x1
	ldd	$ystart
	std	line_y1
	ldd	$xendm
	std	line_x2
	ldd	$yendm
	std	line_y2
	jsr	line
	#endm

	
;****************************************************************
;       Read data from graphics ROM macro                       *
;****************************************************************
READROM         #macro  baseoff,imageoff,startoff,dest,num
                lda     $baseoff
                sta     base_off
                lda     $imageoff
                sta     image_off
                ldx     $dest
                ldy     $startoff
                ldd     $num
                jsr     read_rom
                #endm

;****************************************************************
;       Sprite macros which draw sprites to the screen          *
;       via the processor instead of the blitter                *
;****************************************************************
BLIT_SPRITE     #macro  x,y,data_ptr,buf_ptr
                ldb     $x
                lda     $y
                ldx     $data_ptr
                ldy     $buf_ptr
                jsr     finish_blit
                #endm

REPLACE_SPRITE  #macro  buf_ptr
                ldy     $buf_ptr
                jsr     replace_data
                #endm

RESET_SPRITE    #macro  buf_ptr
                ldd     #0ffffh
                ldy     $buf_ptr
                std     ,y
                #endm
SET_SPR_DIM     #macro  x,y
                lda     $x
                ldb     $y
                jsr     set_sprite_dim
                #endm
;****************************************************************
;               Save VRAM to unused VRAM area                   *
;****************************************************************

SAVE_BACK       #macro rest_buf,vram_srcx,vram_srcy
        ldd     $rest_buf
        ldx     #(($vram_srcy*256)+$vram_srcx)
        jsr     finish_save
        #endm

RESTORE_BACK    #macro rest_buf,vram_srcx,vram_srcy
        ldd     $rest_buf
        ldx     #(($vram_srcy*256)+$vram_srcx)
        jsr     finish_restore
        #endm

;****************************************************************
;	bank mem in and out					*
;****************************************************************
BANK	#macro	
	#ifndef  BANKISIN
	import	bank_mem
	#define  BANKISIN
	#endif
	ldx	#bank_rout$$
	jsr	bank_mem
	region	"RomCode1"
bank_rout$$:
	#endm

ENDBANK	#macro	num
	rts
	region	"RomCode$num"
	#endm

