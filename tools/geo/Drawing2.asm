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
	set_x		0,d'100'	; set x0 register to 200
	set_y		0,d'200'	; set y0 register to 200
	set_x		1,d'200'	; set x1 register to 300
	set_y		1,d'350'	; set y1 register to 300
	set_x		2,d'300'	; set x2 register to 300
	set_y		2,d'300'	; set y2 register to 300
	plot_tri_fill   d'11' 		; y1 > y2 > y0
	
; *************************************************************************************
; ** Draw a line from coordinates (200,200) to (300,300) with palette color 14
; *************************************************************************************
	set_x		0,d'200'	; set x0 register to 200
	set_y		0,d'350' ; set y0 register to 200
	set_x		1,d'300'	; set x1 register to 300
	set_y		1,d'300'	; set y1 register to 300
	set_x		2,d'100'	; set x2 register to 300
	set_y		2,d'200'	; set y2 register to 300
	plot_tri_fill   d'8' 		; y0 > y1 > y2

; *************************************************************************************
; ** Draw a line from coordinates (200,200) to (300,300) with palette color 14
; *************************************************************************************
	set_x		0,d'300'	; set x0 register to 200
	set_y		0,d'300' ; set y0 register to 200
	set_x		1,d'100'	; set x1 register to 300
	set_y		1,d'200'	; set y1 register to 300
	set_x		2,d'200'	; set x2 register to 300
	set_y		2,d'350'	; set y2 register to 300
	plot_tri_fill   d'9' 		; y2 > y0 > y1

; *************************************************************************************
; ** Draw a line from coordinates (200,200) to (300,300) with palette color 14
; *************************************************************************************
	set_x		0,d'300'	; set x0 register to 200
	set_y		0,d'300' ; set y0 register to 200
	set_x		1,d'200'	; set x1 register to 300
	set_y		1,d'350'	; set y1 register to 300
	set_x		2,d'100'	; set x2 register to 300
	set_y		2,d'200'	; set y2 register to 300
	plot_tri_fill   d'3' 		; y1 > y0 > y2

; *************************************************************************************
; ** Draw a line from coordinates (200,200) to (300,300) with palette color 14
; *************************************************************************************
	set_x		0,d'100'	; set x0 register to 200
	set_y		0,d'200'	; set y0 register to 200
	set_x		1,d'300'	; set x1 register to 300
	set_y		1,d'300'	; set y1 register to 300
	set_x		2,d'200'	; set x2 register to 300
	set_y		2,d'350'	; set y2 register to 300
	plot_tri_fill   d'14' 		; y2 > y1 > y0
	
; *************************************************************************************
; ** Draw a line from coordinates (200,300) to (300,200) with palette color 14
; *************************************************************************************
;	set_x		0,d'250'	; set x0 register to 200
;	set_y		0,d'200'	; set y0 register to 200
;	set_x		1,d'200'	; set x1 register to 300
;	set_y		1,d'250'	; set y1 register to 300
;	set_x		2,d'350'	; set x2 register to 300
;	set_y		2,d'350'	; set y2 register to 300
;	plot_line       d'1' 		; draw a line with palette color 14



