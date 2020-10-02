Rem GPU geometry engine simulator/tester written in 'FreeBasic'
REM Setup by Brian Guralnick
REM 
REM Get the freeBasic compiler at 
REM 
REM 

rem 16 bit command buffer:
rem
rem Idea - fdat(0/1)  bits =  1 1 1 1 1 1                         (Read vertically)
rem                           5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
rem                         [primary][  primary 12 bit data  ]
rem                         [command][                       ]
rem
rem                         [extend command][ 8 bit data for ]
rem                         [              ][extended command]

rem This means there are 15 functions.  Allow func 15 through 8 to set the 12 bit data registers
rem IE: while func bit 15=1. When func bit 15=0, there will be 128 additional functions where you
rem have access to the lower 8 bit data word.
rem
rem For the first 8 functions, you will be basically setting 8 different 12 bit registers
rem For the alternate 128 instructions, you will be setting multiple 8 bit registers
rem and executing state machines.


Declare Sub read_palette()                                          : REM loads the GPU palette into memory
Declare Sub draw_pixel(xp as integer, yp as integer, col as Ubyte)  : REM Draws 1 dot with paleted Color
Declare Sub drawLine(x1 as integer, y1 as integer, x2 as integer, y2 As Integer, color_val As Ubyte)
Declare Sub drawFilledTriangle(x1 as integer, y1 as integer, x2 as integer, y2 As Integer, x3 as integer, y3 As Integer, color_val As Ubyte)
Declare Sub drawEllipse(x1 As integer, y1 As Integer, x2 As integer, y2 As Integer, colour as Integer, filled As Boolean = FALSE)
Declare Sub func_plot(draw_type as Ubyte, color_type as Ubyte, color_val as Ubyte, dst_mem as integer, sx as integer, sy as integer, dx as integer, dy as integer, tx as integer, ty as integer, zx as integer, zy as integer, mx as integer, my as integer)

Declare Sub setup_linegen_num ( byval i as integer)
Declare Sub run_linegen_num ( byval i as integer, byval stop_Y_pos as integer, byval color_val as UByte  )

Dim Shared As Integer xa(2),ya(2),xb(2),yb(2)
Dim Shared As Integer dx(2),dy(2),sx(2),sy(2)
Dim Shared As Integer magic(2),errd(2)
Dim Shared As Integer is_done(2)
Dim Shared As Integer out_y


Dim Shared fdat (0 To 1) As Ubyte
Dim Shared pal_dat_r (0 To 255) As Ubyte
Dim Shared pal_dat_g (0 To 255) As Ubyte
Dim Shared pal_dat_b (0 To 255) As Ubyte
dim Shared as integer funcdata12, x0,y0,x1,y1,x2,y2,x3,y3,x4,y4,c1,c2,c3,c4
dim Shared as integer destmem, srcmem, max_x,max_y, src_width, dest_width
dim shared as Ubyte   funcdata8,func1,func2,func3, draw_collision, blit_collision, show_pset
dim shared as string ink

ScreenRes 720,560,16,0,0 : REM open a window a little larger than 640x480
read_palette(): REM initially load the palette into memory

out_y = 3 : Rem Set y-position of ordering Output

REM *************************************************************
REM **** Open the 'drawing.bin' file ************
REM *************************************************************
Open "drawing.bin" For Binary Access Read As 1

REM *************************************************************************
REM **** perform a loop while characters still exist in the file ************
REM *************************************************************************
while not eof(1)

REM *************************************************************************
REM **** Read 2 bytes as the command format dat is 16 bits wide ************
REM *************************************************************************
	get #1,,fdat(1), 1 : REM Big endian order
	get #1,,fdat(0), 1 : REM Big endian order

REM decode 16 bit instruction
	funcdata12 = fdat(1) + ( fdat(0) and 15) * 256 : Rem separate out a 12 bit number
	funcdata8  = fdat(1)
	func1      = int (fdat(0)/16) : Rem separate out 16 possible main functions.
	func2      = int (fdat(0) and 127) : Rem separate out 128 possible sub functions
	func3      = fdat(1)

REM *************************************************************
REM **** For the upper main function set the appropriate 12 bit registers ************
REM *************************************************************
if func1 > 7 then
	if func1=8  then x0=funcdata12
	if func1=9  then x1=funcdata12
	if func1=10 then x2=funcdata12
	if func1=11 then x3=funcdata12
	if func1=12 then y0=funcdata12
	if func1=13 then y1=funcdata12
	if func1=14 then y2=funcdata12
	if func1=15 then y3=funcdata12
end if

REM *************************************************************
REM **** All other possible 127 functions ************
REM *************************************************************

if func1<8 then
REM *************************************************************
REM **** Set 24 bit screen memory registers ************
REM *************************************************************
	if func2=127 then destmem = y0*4096 + x0: Rem set 24 bit destination screen memory pointer for plotting
	if func2=126 then destmem = y1*4096 + x1: Rem set 24 bit destination screen memory pointer for plotting
	if func2=125 then destmem = y2*4096 + x2: Rem set 24 bit destination screen memory pointer for plotting
	if func2=124 then destmem = y3*4096 + x3: Rem set 24 bit destination screen memory pointer for plotting
	
	if func2=123 then srcmem  = y0*4096 + x0: Rem set 24 bit source screen memory pointer for blitter copy
	if func2=122 then srcmem  = y1*4096 + x1: Rem set 24 bit source screen memory pointer for blitter copy
	if func2=121 then srcmem  = y2*4096 + x2: Rem set 24 bit source screen memory pointer for blitter copy
	if func2=120 then srcmem  = y3*4096 + x3: Rem set 24 bit source screen memory pointer for blitter copy

	if func2=119 then destmem = y0*4096 + x0:srcmem  = x1*4096 + y1: Rem both source and destination pointers for blitter copy
	if func2=118 then destmem = y1*4096 + x1:srcmem  = x0*4096 + y0: Rem both source and destination pointers for blitter copy
	if func2=117 then destmem = y2*4096 + x2:srcmem  = x3*4096 + y3: Rem both source and destination pointers for blitter copy
	if func2=116 then destmem = y3*4096 + x3:srcmem  = x2*4096 + y2: Rem both source and destination pointers for blitter copy

	if func2=115 then dest_width   = x2  : Rem Sets the number of bytes per horizontal line in the destination raster
	if func2=114 then src_width    = y2  : Rem Sets the number of bytes per horizontal line in the destination raster
	if func2=113 then dest_width   = x3  : Rem Sets the number of bytes per horizontal line in the destination raster
	if func2=112 then src_width    = y3  : Rem Sets the number of bytes per horizontal line in the destination raster

REM *************************************************************
REM **** Set screen width and height limits ************
REM *************************************************************

	if func2=95 then max_x = x0: max_y = y0 : REM set the maximum width and height of the screen
	if func2=94 then max_x = x1: max_y = y1 : REM set the maximum width and height of the screen
	if func2=93 then max_x = x2: max_y = y2 : REM set the maximum width and height of the screen
	if func2=92 then max_x = x3: max_y = y3 : REM set the maximum width and height of the screen

	if func2=91 then draw_collision = 0     : REM Clear the pixel drawing collision counter
	if func2=90 then blit_collision = 0     : REM Clear the blitter copy pixel collision counter

REM *************************************************************
REM **** Numerous plotting functions ************
REM *************************************************************

	if func2>0 and func2<90  then func_plot(func2,1,func3,destmem,x0,y0,x1,y1,x2,y2,x3,y3,max_x,max_y) : rem draw oval filled

REM *************************************************************
REM **** reset function ************
REM *************************************************************

	if func2=0 and func3=255 then
	x0=0:x1=0:x2=0:x3=0:x4=0
	y0=0:y1=0:y2=0:y3=0:y4=0
	max_x=0:max_y=0
	end if


end if

wend : rem process until all bytes in file are finished
close #1


REM *************************************************************
REM **** Finished reading file, press ESC key to quit ************
REM *************************************************************


color rgb(0,255,0),rgb(0,0,0)
locate 67,1
? " Finished drawing.bin.  Press ESC key to close window. "

ink=""
while ink<>chr(27)
sleep 10,0: rem wait for a keypress before quitting
ink=inkey
wend
end


REM *************************************************************
REM **** The PLOT functions ************
REM *************************************************************
REM draw_type     = what type of geometric object to draw
REM color_type    = (will be used in GPU to define the bits/pixel)
REM color_val     = Will be used to define the drawing pen color
REM dst_mem       = defines the base memory address of the screen display
REM sx,sy...zx,zy = defines the drawing coordinates
REM mx,my         = defines the maximum X&Y locations allowed to be plotted

Sub func_plot(draw_type as Ubyte, color_type as Ubyte, color_val as Ubyte, dst_mem as integer, sx as integer, sy as integer, dx as integer, dy as integer, tx as integer, ty as integer, zx as integer, zy as integer, mx as integer, my as integer)

dim as integer x,y,z

color rgb(255,255,255),rgb(0,0,0)
locate 62,1
? " Func Plot   ";draw_type;" ";color_type;" ";color_val;"        "
? " base Addr= ";dst_mem;"        "
? " coord 1ab  (";sx;",";sy;")-(";dx;",";dy;")        "
? " coord 2ab  (";tx;",";ty;")-(";zx;",";zy;")        "
? " x&y limit  (";mx;",";my;")       ";

if draw_type = 0 then                : REM ********* Draw a Dot at sx,sy
	draw_pixel (sx,sy,color_val)
	end if

if draw_type = 1 then                : REM ********* Draw a Line from (sx,sy)-(dx,dy) (Using Bresenham's Line Algorithm)
	drawLine(sx,sy,dx,dy,color_val)
End if

if draw_type = 2 then                : REM ********* Draw a Box inside area (sx,sy)-(dx,dy)
	for x=sx to dx
		draw_pixel (x,sy,color_val)
		draw_pixel (x,dy,color_val)
	next x
	for y=sy to dy
		draw_pixel (sx,y,color_val)
		draw_pixel (dx,y,color_val)
	next y
End if

if draw_type = 2+8 then                : REM ********* Draw a filled Box inside area (sx,sy)-(dx,dy)
	for y=sy to dy
		for x=sx to dx
			draw_pixel (x,y,color_val)
		next x
	next y
end If

If draw_type = 4 Then                : REM ********* Draw a ellipse within Rectangle bounded by sx,sy,dx,dy
	drawEllipse(sx, sy, dx, dy, color_val)
EndIf

If draw_type = 4+8 Then                : REM ********* Draw a filled ellipse within Rectangle bounded by sx,sy,dx,dy
	drawEllipse(sx, sy, dx, dy, color_val, TRUE)
EndIf

if draw_type = 3+8 then                : REM ********* Draw a triangle with points (sx,sy),(dx,dy),(tx,ty)
	drawFilledTriangle(sx,sy,dx,dy,tx,ty,color_val)
End if


REM *************************************************************
sleep : REM PAUSE for keypress after every plot command
REM *************************************************************
end Sub

REM *************************************************************
REM **** Draw Ellipse Using Bresenham's algorithm ************
REM *************************************************************

Sub drawEllipse(ByVal x0 As Integer, ByVal y0 As Integer, ByVal x1 As Integer, ByVal y1 As Integer, ByVal colour as Integer, ByVal filled As Boolean = FALSE)
   Dim As Integer a = Abs(x1-x0), b = Abs(y1-y0), b1, x : Rem values of diameter
   Dim As Integer dx = 4*(1-a)*b*b, dy = 4*(b1+1)*a*a : Rem error increment
   Dim As Integer errd = dx + dy + b1 * a * a, e2 : Rem error of 1.step

	b1 = b And 1

   if (x0 > x1) then 
   	x0 = x1
   	x1 = x1 + a : Rem if called with swapped points
   End If
   if (y0 > y1) Then
   	y0 = y1 : Rem .. exchange them
   End If
   y0 = y0 + (b + 1) / 2
   y1 = y0 - b1 : Rem starting pixel
   a = a*(8*a)
   b1 = 8*b*b

   While (x0 <= x1)
      draw_pixel(x1, y0, colour) : Rem   I. Quadrant
      draw_pixel(x0, y0, colour) : Rem   II. Quadrant
      draw_pixel(x0, y1, colour) : Rem   III. Quadrant
      draw_pixel(x1, y1, colour) : Rem   IV. Quadrant
      If (filled) Then
	      For x=x0 to x1
				draw_pixel (x, y0, colour)
				draw_pixel (x, y1, colour)
	      Next x
      EndIf
      e2 = 2*errd
      If (e2 <= dy) Then 
       	y0 = y0 + 1
       	y1 = y1 - 1
       	dy = dy + a
       	errd = errd + dy : rem  y Step
      End If 
      If (e2 >= dx Or 2*errd > dy) Then
       	x0 = x0 + 1
       	x1 = x1 - 1
       	dx = dx + b1
       	errd = errd + dx : rem x Step
      End If
   Wend
  
   While (y0 - y1 < b)  : Rem too early stop of flat ellipses a=1
       draw_pixel(x0 - 1, y0, colour) : Rem -> finish tip of Ellipse
       y0 = y0 + 1
       draw_pixel(x1 + 1, y0, colour) 
       draw_pixel(x0 - 1, y1, colour)
       y1 = y1 - 1
       draw_pixel(x1 + 1, y1, colour) 
   Wend

End Sub

REM *************************************************************
REM **** Draw Line Using Bresenham's algorithm ************
REM *************************************************************

Sub drawLine (ByVal x0 as Integer, byval y0 as Integer, byval x1 as Integer, byval y1 as Integer, byval color_val As UByte) 
    Dim As integer  dx,dy,x,y,sx,sy,errd,magic
    Dim As boolean is_done

locate 1,1

    Rem bounding box's width and height
    dx = x1 - x0
    dy = y1 - y0
    
    Rem set the loop's sign
    if (dx < 0) Then
        dx = -dx
        sx = -1
    Else
        sx = 1
    End If
    
    if (dy > 0) Then
        dy = -dy
        sy = 1
    Else
        sy = -1
    End If

	 Rem set initial values
    magic = 0
    errd  = dx + dy
    x     = x0
    y     = y0
    is_done = FALSE
    
   While (is_done = False)
      Rem plot(x, y, color)
      draw_pixel (x,y,color_val)

      Rem Reached the End
      If (x = x1 And y = y1) Then
      	is_done = TRUE
      Else
      	is_done = FALSE
      End If

      Rem Loop carried
      magic = errd shl 1
      if (magic > dy) Then
         errd += dy
         x    += sx
      End If
        
      if (magic < dx) Then
         errd += dx
         y    += sy
      End If
   Wend

End Sub

REM *************************************************************
REM **** Read 256 color GPU 4444 palette memory ************
REM *************************************************************

Sub read_palette()
Open "palette.bin" For Binary Access Read As 1
	for x1=0 to 255
		get #1,,fdat(0), 1 : REM Little edian
		get #1,,fdat(1), 1 : REM Little edian

		func1 = fdat(0) and 15
		pal_dat_r(x1) = func1*16+func1
		func1 = int(fdat(1)/16) and 15
		pal_dat_g(x1) = func1*16+func1
		func1 = fdat(1) and 15
		pal_dat_b(x1) = func1*16+func1
	next x1
close #1
end sub


REM *************************************************************
REM **** Draw a dot with the palette color ************
REM *************************************************************

Sub draw_pixel(xp as integer, yp as integer, col as Ubyte)
	PSet ( xp,yp ),rgb( pal_dat_r(col),pal_dat_g(col),pal_dat_b(col) )
if (show_pset) then ? xp,yp
end sub


Rem *************************************************************
REM **** Draw filled triangle algorithm ************
REM *************************************************************

Sub drawFilledTriangle (ByVal x0 as Integer, byval y0 as Integer, byval x1 as Integer, byval y1 as Integer, byval x2 as Integer, byval y2 as Integer, byval color_val As UByte) 
   
   Dim As Integer i,raster_Y_pos,raster_X_pos,next_face
	
	locate 1,1 : show_pset = 0
	
	? y0, : ? y1, : ? y2,
	
	If (y0 >= y1 and y1 >= y2 ) Then
		Locate out_y,1:? "y0>y1>y2", : out_y += 1		
		xa(0) = x2 : rem LineGen 0 start & end
		ya(0) = y2
		xb(0) = x0
		yb(0) = y0
		xa(1) = x2 : rem LineGen 1 start & end
		ya(1) = y2
		xb(1) = x1
		yb(1) = y1
		xa(2) = x1 : rem LineGen 2 start & end
		ya(2) = y1
		xb(2) = x0
		yb(2) = y0
	ElseIf (y1 >= y2 And y2 >= y0) Then
		Locate out_y,1:? "y1>y2>y0", : out_y += 1
		xa(0) = x0 : rem LineGen 0 start & end
		ya(0) = y0
		xb(0) = x1
		yb(0) = y1
		xa(1) = x0 : rem LineGen 1 start & end
		ya(1) = y0
		xb(1) = x2
		yb(1) = y2
		xa(2) = x2 : Rem LineGen 2 start & end
		ya(2) = y2
		xb(2) = x1
		yb(2) = y1
	ElseIf (y2 >= y0 And y0 >= y1) Then
		Locate out_y,1:? "y2>y0>y1", : out_y += 1
		xa(0) = x1 : rem LineGen 0 start & end
		ya(0) = y1
		xb(0) = x2
		yb(0) = y2
		xa(1) = x1 : rem LineGen 1 start & end
		ya(1) = y1
		xb(1) = x0
		yb(1) = y0
		xa(2) = x0 : rem LineGen 2 start & end
		ya(2) = y0
		xb(2) = x2
		yb(2) = y2
	ElseIf (y0 >= y2 And y2 >= y1) Then
		Locate out_y,1:? "y0>y2>y1", : out_y += 1
		xa(0) = x1 : rem LineGen 0 start & end
		ya(0) = y1
		xb(0) = x0
		yb(0) = y0
		xa(1) = x1 : rem LineGen 1 start & end
		ya(1) = y1
		xb(1) = x2
		yb(1) = y2
		xa(2) = x2 : rem LineGen 2 start & end
		ya(2) = y2
		xb(2) = x0
		yb(2) = y0
	ElseIf (y2 >= y1 And y1 >= y0) Then
		Locate out_y,1:? "y2>y1>y0", : out_y += 1
		xa(0) = x0 : rem LineGen 0 start & end
		ya(0) = y0
		xb(0) = x2
		yb(0) = y2
		xa(1) = x0 : rem LineGen 1 start & end
		ya(1) = y0
		xb(1) = x1
		yb(1) = y1
		xa(2) = x1 : rem LineGen 2 start & end
		ya(2) = y1
		xb(2) = x2
		yb(2) = y2
	ElseIf (y1 >= y0 And y0 >= y2) Then
		Locate out_y,1:? "y1>y0>y2" : out_y += 1
		xa(0) = x2 : rem LineGen 0 start & end
		ya(0) = y2
		xb(0) = x1
		yb(0) = y1
		xa(1) = x2 : rem LineGen 1 start & end
		ya(1) = y2
		xb(1) = x0
		yb(1) = y0
		xa(2) = x0 : rem LineGen 2 start & end
		ya(2) = y0
		xb(2) = x1
		yb(2) = y1
	EndIf
  
	For i = 0 to 2 : Rem Setup all 3 line gens
        setup_linegen_num ( i )
	Next i

	REM the integers 'next_face' and 'raster_X_pos' will be used for something.

	next_face = 1
	
	run_linegen_num ( 0, ya(0)+1, color_val ) : Rem start the triangle's first line
   run_linegen_num ( 1, ya(0)+1, color_val ) : Rem start the triangle's second line

	If ( yb(0) - ya(0) > 2 ) Then :REM If the triangles height is more than 2 pixels
	
	   For raster_Y_pos = ya(0)+1 to yb(0)-1	
   	
    		run_linegen_num ( 0, raster_Y_pos, color_val )   			:REM draw first triangle line until raster_Y_pos
	    	run_linegen_num ( next_face, raster_Y_pos, color_val )   :REM draw second or third triangle line until raster_Y_pos
		
			Rem Only if there are any empty pixels to fill inbetween the 2 triangle edges, raster fill them in
		
			If ( (xa(0)+2) <= xa(next_face) ) Then : Rem Check one direction
			
	      	For raster_X_pos = xa(0) + 1 to xa(next_face) - 1
	      	
	      		draw_pixel ( raster_X_pos, raster_Y_pos, color_val )
	      	
	      	Next raster_X_pos
	      
			End If	
		
			If ( (xa(0)-2) >= xa(next_face) ) Then	: Rem Check opposite direction
			
				For raster_X_pos = xa(next_face) + 1 to xa(0) - 1
				
					draw_pixel ( raster_X_pos, raster_Y_pos, color_val )
				
				Next raster_X_pos
			
			End If	
		
			Rem If the second triangle line reached it's end, finish second line and switch over to the third triangle line
			If ( raster_Y_pos = yb(1) ) Then run_linegen_num ( 1, -1, color_val ) : next_face = 2 
		
	   Next raster_Y_pos
   
   EndIf

   run_linegen_num ( 0, yb(0)+1, color_val ) : Rem finish the triangle's first line
   run_linegen_num ( 2, yb(0)+1, color_val ) : Rem finish the triangle's third line

	Locate 1,1 : show_pset = 0

End Sub


Sub setup_linegen_num ( byval i as integer )

   Rem bounding box's width and height for the three line generators
   Rem And set the loop's sign

   dx(i) = xb(i) - xa(i)
   dy(i) = yb(i) - ya(i)

   If (dx(i) < 0) Then
      dx(i) = -dx(i)
      sx(i) = -1
   Else
      sx(i) = 1
   End If
    
   If (dy(i) > 0) Then
      dy(i) = -dy(i)
      sy(i) = 1
   Else
      sy(i) = -1
   End If
   
   magic(i)   = 0
   errd(i)    = dx(i) + dy(i)
   is_done(i) = 0

End Sub

Sub run_linegen_num ( byval i as integer, byval stop_Y_pos as integer, byval color_val as UByte  )

   While (is_done(i) = 0 and stop_Y_pos<>ya(i) )
	
      draw_pixel (xa(i), ya(i), color_val)
	
      Rem Reached the End
      If (xa(i) = xb(i) And ya(i) = yb(i) ) Then
      	is_done(i) = 1
      Else
      	is_done(i) = 0
      End If
	
      Rem Line 1 carried
      magic(i) = errd(i) shl 1
      if (magic(i) > dy(i)) Then
         errd(i) += dy(i)
         xa(i)    += sx(i)
      End If
        
      if (magic(i) < dx(i)) Then
         errd(i) += dx(i)
         ya(i)    += sy(i)
      End If
   Wend

End Sub

