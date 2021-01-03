; Test Drawing assembly language
;
; Assembled with 'FWASM.exe'  (C) Brian Guralnick
;
; OP-Code Instruction structure inside the file 'instr.txt'
;
; Follow Microchip's PIC16/18 assembler mnemonic
;
; Compile line            "fwasm drawing.asm"
; The output file will be "drawings.bin'
; The output file         "drawings.lst' shows the generated opcode and error codes.
;
; *** THE COMPILER WILL PLACE 8 BYTES of 0x0 AT THE BEGINNING OF THE .BIN FILE
;
;
; Warning, DEFAULT RADDIX IS HEXADECIMAL
;
; Use d'xxx'        to enter a decimal value
; Use b'0101010100' to enter a binary value
;

	org	0000 ; Power up vector

start

; *************************************************************************************
; ** Draw a dot at coordinates (250,250) with palette color 15
; *************************************************************************************
;	set_x		0,d'250'	; set x0 register to 250
;	set_y		0,d'250'	; set y0 register to 250
;	plot_dot	d'15' 		; plot a dot with palette color 15

; *************************************************************************************
; ** Draw a line from coordinates (200,200) to (300,300) with palette color 14
; *************************************************************************************
	set_x		0,d'200'	; set x0 register to 200
	set_y		0,d'350'	; set y0 register to 200
	set_x		1,d'100'	; set x1 register to 300
	set_y		1,d'200'	; set y1 register to 300
	set_x		2,d'300'	; set x2 register to 300
	set_y		2,d'300'	; set y2 register to 300
	plot_tri_fill   d'13' 		; y0 > y2 > y1

; *************************************************************************************
; ** Draw a line from coordinates (200,200) to (300,300) with palette color 14
; *************************************************************************************
	set_x		0,d'90'	; set x0 register to 200
	set_y		0,d'50' 	; set y0 register to 200
	set_x		1,d'600'	; set x1 register to 300
	set_y		1,d'300'	; set y1 register to 300
	set_x		2,d'180'	; set x2 register to 300
	set_y		2,d'170'	; set y2 register to 300
	plot_tri_fill   d'11' 		; y1 > y2 > y0
	
; *************************************************************************************
; ** Draw a line from coordinates (200,200) to (300,300) with palette color 14
; *************************************************************************************
	set_x		0,d'60'	; set x0 register to 200
	set_y		0,d'250' ; set y0 register to 200
	set_x		1,d'360'	; set x1 register to 300
	set_y		1,d'170'	; set y1 register to 300
	set_x		2,d'290'	; set x2 register to 300
	set_y		2,d'70'	; set y2 register to 300
	plot_tri_fill   d'8' 		; y0 > y1 > y2

; *************************************************************************************
; ** Draw a line from coordinates (200,200) to (300,300) with palette color 14
; *************************************************************************************
	set_x		0,d'80'	; set x0 register to 200
	set_y		0,d'200' ; set y0 register to 200
	set_x		1,d'360'	; set x1 register to 300
	set_y		1,d'140'	; set y1 register to 300
	set_x		2,d'290'	; set x2 register to 300
	set_y		2,d'270'	; set y2 register to 300
	plot_tri_fill   d'9' 		; y2 > y0 > y1

; *************************************************************************************
; ** Draw a line from coordinates (200,200) to (300,300) with palette color 14
; *************************************************************************************
	set_x		0,d'80'	; set x0 register to 200
	set_y		0,d'180' ; set y0 register to 200
	set_x		1,d'360'	; set x1 register to 300
	set_y		1,d'220'	; set y1 register to 300
	set_x		2,d'290'	; set x2 register to 300
	set_y		2,d'110'	; set y2 register to 300
	plot_tri_fill   d'3' 		; y1 > y0 > y2

; *************************************************************************************
; ** Draw a line from coordinates (200,200) to (300,300) with palette color 14
; *************************************************************************************
	set_x		0,d'220'	; set x0 register to 200
	set_y		0,d'210'	; set y0 register to 200
	set_x		1,d'230'	; set x1 register to 300
	set_y		1,d'220'	; set y1 register to 300
	set_x		2,d'210'	; set x2 register to 300
	set_y		2,d'230'	; set y2 register to 300
	plot_tri_fill   d'14' 		; y2 > y1 > y0
	

; *************************************************************************************
; ** Draw a circle, radius 50
; *************************************************************************************
	set_x		0,d'150'	; set x0 register to 150
	set_y		0,d'180'	; set y0 register to 180
	set_x		1,d'50'	; set x1 register to 50
	set_y		1,d'50'	; set y1 register to 50
	plot_circle_fill        d'09' 		; draw a filled circle with palette color 9
	plot_circle	      	   d'14' 		; draw an circle with palette color 14
	set_x		1,d'49'	; set x1 register to 49 (reduce radius by 1)
	set_y		1,d'49'	; set y1 register to 49 (reduce radius by 1)
	plot_circle	      	   d'14' 		; draw an circle with palette color 14

; *************************************************************************************
; ** Draw an ellipse, radius 60,90
; *************************************************************************************
	set_x		0,d'350'	; set x0 register to 150
	set_y		0,d'280'	; set y0 register to 180
	set_x		1,d'60'	; set x1 register to 60
	set_y		1,d'90'	; set y1 register to 90
	plot_circle_fill        d'09' 		; draw a filled circle with palette color 9
	plot_circle	      	   d'14' 		; draw an circle with palette color 14
	
	set_x		1,d'59'	; set x1 register to 59 (reduce radius by 1)
	set_y		1,d'89'	; set y1 register to 89 (reduce radius by 1)
	plot_circle	      	   d'14' 		; draw an circle with palette color 14

