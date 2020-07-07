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
	set_x		0,d'250'	; set x0 register to 250
	set_y		0,d'250'	; set y0 register to 250
	plot_dot	d'15' 		; plot a dot with palette color 15


; *************************************************************************************
; ** Draw a line from coordinates (200,200) to (300,300) with palette color 14
; *************************************************************************************
	set_x		0,d'200'	; set x0 register to 200
	set_y		0,d'200'	; set y0 register to 200
	set_x		1,d'300'	; set x0 register to 300
	set_y		1,d'300'	; set y0 register to 300
	plot_line d'14' 		; draw a line with palette color 14


; *************************************************************************************
; ** Draw a line from coordinates (200,300) to (300,200) with palette color 14
; *************************************************************************************
	set_x		0,d'200'	; set x0 register to 200
	set_y		0,d'300'	; set y0 register to 300
	set_x		1,d'300'	; set x0 register to 300
	set_y		1,d'200'	; set y0 register to 200
	plot_line d'14' 		; draw a line with palette color 14
	

; *************************************************************************************
; ** Draw an outlined box with an outline (200,200)-(300,300) with palette color 14
; *************************************************************************************
	set_x		0,d'200'	; set x0 register to 200
	set_y		0,d'200'	; set y0 register to 200
	set_x		1,d'300'	; set x1 register to 300
	set_y		1,d'300'	; set y1 register to 300
	plot_box	d'14' 		; plot a box with palette color 14


; *************************************************************************************
; ** Draw a filled box within (225,225)-(275,275) with palette color 14
; *************************************************************************************
	set_x		0,d'225'	; set x0 register to 225
	set_y		0,d'225'	; set y0 register to 225
	set_x		1,d'275'	; set x1 register to 275
	set_y		1,d'275'	; set y1 register to 275
	plot_box	d'14' 		; plot a filled box with palette color 14
	

; *************************************************************************************
; ** Draw a filled box within (226,226)-(274,274) with palette color 0
; *************************************************************************************
	set_x		0,d'226'	; set x0 register to 226
	set_y		0,d'226'	; set y0 register to 226
	set_x		1,d'274'	; set x1 register to 274
	set_y		1,d'274'	; set y1 register to 274
	plot_box_fill	d'0' 		; plot a filled box with palette color 0


; *************************************************************************************
; ** Draw a circle (250,250)-(325,325) with palette color 15
; *************************************************************************************
	set_x		0,d'250'	; set x0 register to 250
	set_y		0,d'250'	; set y0 register to 250
	set_x		1,d'325'	; set x1 register to 325
	set_y		1,d'325'	; set y1 register to 325
	plot_circle	d'15' 		; plot an ellipse with palette color 15


; *************************************************************************************
; ** Draw a filled ellipse (250,250)-(300,350) with palette color 9
; *************************************************************************************
	set_x		0,d'175'	; set x0 register to 250 - The ellipse's top-left X position
	set_y		0,d'175'	; set y0 register to 250 - The ellipse's top-left Y position
	set_x		1,d'300'	; set x1 register to 300 - The ellipse's bottom-right X position
	set_y		1,d'350'	; set y1 register to 350 - The ellipse's bottom-right Y position
	plot_circle_fill	d'9' 		; plot a filled ellipse with palette color 9