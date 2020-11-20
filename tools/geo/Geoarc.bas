Rem GPU bezier/arc/ellipse tester written in 'FreeBasic'
REM Setup by Brian Guralnick
REM 
REM Get the freeBasic compiler at 
REM 
REM 


Declare Sub draw_pixel(xp as integer, yp as integer, col as Ubyte)  : REM Draws 1 dot with paleted Color
Declare Sub drawLine(x1 as integer, y1 as integer, x2 as integer, y2 As Integer, color_val As Ubyte)

Declare Sub drawLine_arc(x0 As integer, y0 As Integer,x1 as integer, y1 as integer, color_val As Ubyte, arc_ena as Ubyte)

Declare Sub drawEllipse(x1 As integer, y1 As Integer, x2 As integer, y2 As Integer, colour as Integer, filled As Boolean = FALSE)


dim Shared as integer mx,mxl,my,myl,mb,mbl,mw,mwl,sx,sy,dx,dy,dz
dim Shared as integer destmem, srcmem, max_x,max_y, src_width, dest_width
dim shared as Ubyte   show_pset
dim shared as string ink

ScreenRes 720,560,16,0,0 : REM open a window a little larger than 640x480


REM *************************************************************
REM **** Loop drawing the ellipse using the mouse choordinates **
REM **** Use the ESC key to quit **
REM *************************************************************

ink=""
while ink<>chr(27)

	GetMouse mx,my,mw,mb
	
	If mx<>mxl or my<>myl or mb<>mbl then
	
		Line (0,0)-(719,559),rgb( 0,0,0 ),BF : rem rem cls fast
		
		sx = 320
		sy = 240
		dx = mx
		dy = my
		
		' These coordinates define points P0,P1,P2 for a Bézier curve top left side
		'drawLine (sx,sy,dx,dy, 255) 
		
		' Drawline as a line 
		drawLine_arc (sx,sy,dx,dy, 255, 0) 
		' Drawline as an arc
		drawLine_arc (sx,sy,dx,dy, 0  , 1) 
		
		mxl=mx:myl=my:mbl=mb:mw=mwl : rem store old mouse state
		
		Color rgb(255,255,255),rgb(0,0,0)
		Locate 62,1
		? " coord 1ab  (";sx;",";sy;")-(";dx;",";dy;")        "
		? " width      (";dz;")        ";
	 
	End if
	
	Sleep 1: ' wait for a keypress before quitting
	ink=InKey
	
wend
end

REM *************************************************************
REM **** Draw LINE-ARC with the palette color ************
REM *************************************************************

Sub drawLine_arc (byval x0 as Integer, byval y0 as Integer, byval x1 as Integer, byval y1 as integer, byval color_val As UByte, byval arc_ena As UByte)
	
   Dim As integer  dx,dy,x,y,sx,sy,errd,magic,dxf,dyf
   Dim As boolean is_done
	
   ' bounding box's width and height
   ' set the loop's sign
   dx = (x1 - x0)
   dy = (y1 - y0)
	
   If (dx < 0) Then
      dx = -dx
      sx = -1
   Else
      sx = 1
   End If
	
   If (dy > 0) Then
      dy = -dy
      sy = 1
   Else
      sy = -1
   End If
	
   If arc_ena then dy=dy*3 : dx=dx*1
	
   magic = 0
   errd  = dx + dy
   x     = x0
   y     = y0
   is_done = FALSE
	
   While (is_done = False)
   	
      draw_pixel (x,y,color_val)
		
      ' Reached the End
      If (x <= x1 or y <= y1) Then
      	is_done = TRUE
      Else
      	is_done = FALSE
      End If
		
      ' Loop carried
      magic = errd * 2
      if (magic > dy) Then
		
         errd += dy
         x    += sx
         if (arc_ena) then dy=dy-sy*2
		
      End If
   	
      if (magic < dx) Then
		
         errd += dx
         y    += sy
         if (arc_ena) then dx=dx-sx*2
		
      End If
		
		if inkey<>"" then End
		
   Wend

End Sub

REM *************************************************************
REM **** Draw Line Using Bresenham's algorithm ************
REM *************************************************************

Sub drawLine (ByVal x0 as Integer, byval y0 as Integer, byval x1 as Integer, byval y1 as Integer, byval color_val As UByte) 
    Dim As integer  dx,dy,x,y,sx,sy,errd,magic
    Dim As boolean is_done


    ' bounding box's width and height
    ' set the loop's sign
    dx = x1 - x0
    dy = y1 - y0
    
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

    magic = 0
    errd  = dx + dy
    x     = x0
    y     = y0
    is_done = FALSE
    
   While (is_done = False)
		
      draw_pixel (x,y,color_val)
		
      ' Reached the End
      If (x = x1 And y = y1) Then
      	is_done = TRUE
      Else
      	is_done = FALSE
      End If
		
      ' Loop carried
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
REM **** Draw a dot with the palette color ************
REM *************************************************************

Sub draw_pixel(xp as integer, yp as integer, col as Ubyte)
	PSet ( xp,yp ),rgb( 255,255,col )
end sub
