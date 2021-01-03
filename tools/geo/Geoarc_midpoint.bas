Rem GPU bezier/arc/ellipse tester written in 'FreeBasic'
REM Setup by Brian Guralnick
REM 
REM Get the freeBasic compiler at 
REM 
REM 

Declare Sub draw_pixel(xp as integer, yp as integer, colr as Ubyte, colg as Ubyte, colb as Ubyte)  : REM Draws 1 dot with paleted Color
Declare Sub drawLine(x1 as integer, y1 as integer, x2 as integer, y2 As Integer, cr As Ubyte, cg As Ubyte, cb As Ubyte)
Declare Sub draw_ellipse(ByVal xc As integer, ByVal yc As Integer, ByVal a As integer, ByVal b As Integer)
Declare Sub drawArc (inv As Boolean, quadrant As Integer, a As Integer, b As Integer, xc As Integer, yc As Integer, cr As Integer, cg As Integer, cb As Integer)
Declare Sub ellipseMidpoint (inv As Boolean, quadrant As Integer, a As Integer, b As Integer, xc As Integer, yc As Integer, cr As Integer, cg As Integer, cb As Integer)

Dim Shared as Integer mx,mxl,my,myl,mb,mbl,mw,mwl,sx,sy,dx,dy,dz
Dim Shared as Integer destmem, srcmem, max_x,max_y, src_width, dest_width
Dim Shared as Ubyte   show_pset
Dim Shared as String ink

ScreenRes 720,560,16,0,0 : REM open a window a little larger than 640x480

Rem *************************************************************
REM **** Loop drawing the ellipse using the mouse choordinates **
REM **** Use the ESC key to quit **
REM *************************************************************

ink=""
while ink<>chr(27)
	
	GetMouse mx,my,mw,mb
	mx=mx-8
	my=my-8
	
   If mx<>mxl or my<>myl or mb<>mbl then
      
      line (0,0)-(719,559),rgb( 0,0,0 ),BF : rem rem cls fast
		
      sx = 320
      sy = 240
      dx = (mx-320)/4 : if dx<0 then dx=0
      dy = (240-my)/4 : if dy<0 then dy=0
		
      REM These coordinates define points P0,P1,P2 for a Bézier curve top left side
      drawLine (sx,sy,mx,my,128,96,64) 
      drawLine (sx,sy,320,my,128,96,64) 
      drawLine (sx,sy,mx,240,128,96,64) 
      rem Drawline as a line 
      draw_ellipse (sx,sy,dx,dy) 
      rem Drawline as an arc
		
      mxl=mx:myl=my:mbl=mb:mw=mwl : rem store old mouse state
		
      color rgb(255,255,255),rgb(0,0,0)
      locate 69,1
      ? " coord 1ab  (";sx;",";sy;")-(";dx;",";dy;")        "
       
   End if
	
	Sleep 1: rem wait for a keypress before quitting
	ink=InKey
	
Wend

End

REM *************************************************************
REM **** Draw LINE-ARC with the palette color ************
REM *************************************************************
Sub draw_ellipse (ByVal xc As integer, ByVal yc As Integer, ByVal a As integer, ByVal b As Integer)
	
   Dim As Integer cr, cg, cb=0, quad
	
	For quad=0 To 3
   	ellipseMidpoint (TRUE, quad, a, b, xc, yc, cr, cg, cb)
	Next quad
	
End Sub

Sub ellipseMidpoint (ByVal inv As Boolean, ByVal quadrant As Integer, ByVal Rx As Integer, ByVal Ry As Integer, ByVal xCenter As Integer, ByVal yCenter As Integer, ByVal cr As Integer, ByVal cg As Integer, ByVal cb As Integer)
	
	Dim As Integer Rx2 = Rx * Rx
	Dim As Integer Ry2 = Ry * Ry
	Dim As Integer twoRx2 = 2 * Rx2
	Dim As Integer twoRy2 = 2 * Ry2
	Dim As Integer p
	Dim As Integer x = 0
	Dim As Integer y = Ry
	Dim As Integer px = 0
	Dim As Integer py = twoRx2 * y
	Dim As Integer yt = 0
	
	Rem Region 1 - INV FALSE
	
	Rem If (Not Inv) Then
		
		cr=0:cg=255
		
		p = ( (Ry2 - (Rx2 * Ry) + (0.25 * Rx2)) ) + 0.5
		
		While (px < py)
			
			If yt<=65 then
			
				If (inv) then
				   Locate yt+2,1
				else
				   Locate yt+2,70
				endif
				
				Color rgb(cr,cg,cb)
				? x,y," ";
				yt=yt+1
			
			EndIf
			
	  		x = x + 1
		  	px = px + twoRy2
			
		   If (p < 0) Then
		      p = p + ( Ry2 + px )
		   Else	
	         y = y - 1
	         py = py - twoRx2
		      p = p + ( Ry2 + px - py )
		   EndIf
			
		  	Rem PlotPoints (xCenter+x, yCenter+y, 0,255,0)
		  	Select Case quadrant
		  		Case 0
		   		draw_pixel(xCenter+x, yCenter+y, cr, cg, cb) : Rem   I. Quadrant
		  		Case 1
		   		draw_pixel(xCenter-x, yCenter+y, cr, cg, cb) : Rem  II. Quadrant
		  		Case 2
		   		draw_pixel(xCenter+x, yCenter-y, cr, cg, cb) : Rem III. Quadrant
		  		Case 3
		   		draw_pixel(xCenter-x, yCenter-y, cr, cg, cb) : Rem  IV. Quadrant
		  		Case Else
	   			Return
		  	End Select
		  
		Wend
	
	Rem Else
		
		Rem Region 2 - INV TRUE
		
		cr=255:cg=0:yt=0
		
		p = ( (Ry2 * (x + 0.5) * (x + 0.5) + Rx2 * (y - 1) * (y - 1) - Rx2 * Ry2) ) + 0.5
		
		While (y > 0)
			
			If yt<=65 then
				If (inv) then
         		locate yt+2,80
         	else
         		locate yt+2,100
				EndIf
				color rgb(cr,cg,255)
				? x,y," ";
				yt=yt+1
			EndIf
			
	  		y = y - 1
		  	py = py - twoRx2
		   If (p > 0) Then
		      p = p + ( Rx2 - py )
		   Else	
	         x = x + 1
	         px = px + twoRy2
		      p = p + ( Rx2 - py + px )
		   EndIf
		   
		  	Rem PlotPoints (xCenter+x, yCenter+y, 255,0,0)
		  	Select Case quadrant
		  		Case 0
			      draw_pixel(xCenter+x, yCenter+y, cr, cg, cb) : Rem   I. Quadrant
		  		Case 1
			      draw_pixel(xCenter-x, yCenter+y, cr, cg, cb) : Rem  II. Quadrantf
		  		Case 2
			      draw_pixel(xCenter+x, yCenter-y, cr, cg, cb) : Rem III. Quadrantf
		  		Case 3
			      draw_pixel(xCenter-x, yCenter-y, cr, cg, cb) : Rem  IV. Quadrant
		  		Case Else
	   			Return
		  	End Select
		  	
		Wend
		
	Rem EndIf
	
End Sub

Sub drawArc (ByVal inv As Boolean, ByVal quadrant As Integer, ByVal af As Integer, ByVal bf As Integer, ByVal xc As Integer, ByVal yc As Integer, ByVal cr As Integer, ByVal cg As Integer, ByVal cb As Integer)
	
	Dim As Integer sigma, x=0, y, a, b, a2, b2, fa2, fb2, yt=0
	
	If (inv) Then
		a=bf
		b=af
	Else
		a=af
		b=bf
	EndIf
	
	a2 = a*a
	b2 = b*b
	fa2 = 4*a2
	fb2 = 4*b2
	y=b
	
	sigma = 2*b2+a2*(1-2*b)
   While ((b2*x <= a2*y) and b>0)
	
		If yt<=65 then
			
			If (inv) then
			   Locate yt+2,1
			else
			   Locate yt+2,70
			endif
			
			Color rgb(cr,cg,cb)
			? x,y," ";
			yt=yt+1
			
		EndIf
   	
   	Select Case quadrant
   		Case 0
	   		If (inv) Then
		      	draw_pixel(xc+y, yc+x, cr, cg, cb) : Rem   I. Quadrant
	   		Else
	   			draw_pixel(xc+x, yc+y, cr, cg, cb) : Rem   I. Quadrant
	   		EndIf
   		Case 1
	   		If (inv) Then
		      	draw_pixel(xc-y, yc+x, cr, cg, cb) : Rem  II. Quadrant
	   		Else
	   			draw_pixel(xc-x, yc+y, cr, cg, cb) : Rem  II. Quadrant
	   		EndIf
   		Case 2
	   		If (inv) Then
		      	draw_pixel(xc+y, yc-x, cr, cg, cb) : Rem III. Quadrant
	   		Else
	   			draw_pixel(xc+x, yc-y, cr, cg, cb) : Rem III. Quadrant
	   		EndIf
   		Case 3
	   		If (inv) Then
		      	draw_pixel(xc-y, yc-x, cr, cg, cb) : Rem  IV. Quadrant
	   		Else
	   			draw_pixel(xc-x, yc-y, cr, cg, cb) : Rem  IV. Quadrant
	   		EndIf
   		Case Else
   			Return
   	End Select
   	
		If (sigma>= 0) Then
			sigma += fa2*(1-y)
			y=y-1
		EndIf
		sigma = sigma + b2*(4*x+6)
		x=x+1
		
   Wend

	REM Finish Line if y hasn't landed on 0
	If y<=1 Then
  		y=0
    	For x=x to a
		
			If yt<=65 then
				If (inv) then
         		locate yt+2,1
         	else
         		locate yt+2,70
				EndIf
				color rgb(cr,cg,255)
				? x,y," ";
				yt=yt+1
			endif
			
      	If (inv) Then
		      draw_pixel(xc+y, yc+x, cr, cg, cb) : Rem   I. Quadrant
		      draw_pixel(xc-y, yc+x, cr, cg, cb) : Rem   II. Quadrant
		      draw_pixel(xc+y, yc-x, cr, cg, cb) : Rem   III. Quadrant
		      draw_pixel(xc-y, yc-x, cr, cg, cb) : Rem   IV. Quadrant
      	Else
		      draw_pixel(xc+x, yc+y, cr, cg, cb) : Rem   I. Quadrant
		      draw_pixel(xc-x, yc+y, cr, cg, cb) : Rem   II. Quadrant
		      draw_pixel(xc+x, yc-y, cr, cg, cb) : Rem   III. Quadrant
		      draw_pixel(xc-x, yc-y, cr, cg, cb) : Rem   IV. Quadrant
      	EndIf
    	Next x
	EndIf
	
End Sub

REM *************************************************************
REM **** Draw Line Using Bresenham's algorithm ************
REM *************************************************************
Sub drawLine (ByVal x0 as Integer, byval y0 as Integer, byval x1 as Integer, byval y1 as Integer, byval cr As UByte, byval cg As UByte, byval cb As UByte) 
   Dim As integer  dx,dy,x,y,sx,sy,errd,magic
   Dim As boolean is_done

   Rem bounding box's width and height
   Rem set the loop's sign
   dx = x1 - x0
   dy = y1 - y0
    
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

   magic = 0
   errd  = dx + dy
   x     = x0
   y     = y0
   is_done = FALSE
    
   While (is_done = False)
		
      draw_pixel (x,y,cr,cg,cb)
		
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
REM **** Draw a dot with the palette color ************
REM *************************************************************
Sub draw_pixel(xp as integer, yp as integer, colr as Ubyte, colg as Ubyte, colb as Ubyte)
	PSet ( xp,yp ),rgb( colr,colg,colb )
end sub
