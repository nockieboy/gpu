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
Declare Sub drawArcNEW (inv As Boolean, quadrant As Integer, a As Integer, b As Integer, xc As Integer, yc As Integer, cr As Integer, cg As Integer, cb As Integer)

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
    	
      sx = 100
      sy = 500
      dx = (mx-sx)/2 : if dx<0 then dx=0
      dy = (sy-my)/2 : if dy<0 then dy=0
    	
      REM These coordinates define points P0,P1,P2 for a Bézier curve top left side
      line (sx,sy)-(mx,my),RGB(64,64,64) 
      line (sx,sy)-(sx,my),RGB(128,96,64) 
      line (sx+dx,0)-(sx+dx,sy),RGB(128,96,64) 
      line (sx,sy)-(mx,sy),RGB(128,96,64) 
      line (sx,sy-dy)-(560,sy-dy),RGB(128,96,64) 
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
   
wend
end

REM *************************************************************
REM **** Draw LINE-ARC with the palette color ************
REM *************************************************************
Sub draw_ellipse (ByVal xc As integer, ByVal yc As Integer, ByVal a As integer, ByVal b As Integer)

   Dim As Integer cr, cg, cb=0, quad=2
    
   cr=0:cg=255
   drawArcNEW (FALSE, quad, a, b, xc, yc, cr, cg, cb)
   cr=255:cg=0
   drawArcNEW (TRUE, quad, b, a, xc, yc, cr, cg, cb)

End Sub

Sub drawArcNEW (ByVal inv As Boolean, ByVal quadrant As Integer, ByVal Rx As Integer, ByVal Ry As Integer, ByVal xCenter As Integer, ByVal yCenter As Integer, ByVal cr As Integer, ByVal cg As Integer, ByVal cb As Integer)
    
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
    
	p = ( 0.25 * Rx2) + 0.5    : rem In verilog, round off this guy '(0.25 * Rx2)'
	p = p + (Ry2 - (Rx2 * Ry)) : rem In verilog, round off this guy '(0.25 * Rx2)'
	
	While ((px <= py) and Rx > 1)
	
		If yt<=65 then
			If (inv) then
				Locate yt+2,1
			Else
				Locate yt+2,80
			EndIf
			Color rgb(cr,cg,cb) : ? x;" ";y;
			yt=yt+1
		EndIf
		
		Select Case quadrant
	  		Case 0
	   		If (Inv) Then
					draw_pixel(xCenter+y, yCenter+x, cr, cg, cb) : Rem I. Quadrant
				Else
					draw_pixel(xCenter+x, yCenter+y, cr, cg, cb) : Rem I. Quadrant
	   		EndIf
	  		Case 1
	   		If (Inv) Then
					draw_pixel(xCenter-y, yCenter+x, cr, cg, cb) : Rem II. Quadrant
				Else
					draw_pixel(xCenter-x, yCenter+y, cr, cg, cb) : Rem II. Quadrant
	   		EndIf
	  		Case 2
	   		If (Inv) Then
					draw_pixel(xCenter+y, yCenter-x, cr, cg, cb) : Rem III. Quadrant
				Else
					draw_pixel(xCenter+x, yCenter-y, cr, cg, cb) : Rem III. Quadrant
	   		EndIf
	  		Case 3
	   		If (Inv) Then
					draw_pixel(xCenter-y, yCenter-x, cr, cg, cb) : Rem IV. Quadrant
				Else
					draw_pixel(xCenter-x, yCenter-y, cr, cg, cb) : Rem IV. Quadrant
	   		EndIf
	  		Case Else
   			Return
	  	End Select
		
		x  = x + 1
		px = px + twoRy2
		
		If (p <= 0) Then
			p  = p + ( Ry2 + px )
		Else 
			y  = y - 1
			py = py - twoRx2
			p  = p + ( Ry2 + px - py )
		EndIf
	
	Wend


	Rem *************************************************************
	Rem *** Complete line if it is not on the last pixel
	Rem *************************************************************
	If y<2 Then
		
		y=0
		For x=x to Rx
		
			If yt<=65 then
				If (inv) then
					Locate yt+2,1
				Else
					Locate yt+2,80
				EndIf
				Color rgb(cr,cg,255) : ? x;" ";y;
				yt=yt+1
			EndIf
			
			If (Inv)     then  draw_pixel(xCenter+y, yCenter-x, cr, cg, 255) : Rem III. Quadrant
			If (Not Inv) then  draw_pixel(xCenter+x, yCenter-y, cr, cg, 255) : Rem III. Quadrant
		
		Next x
		
	EndIf

End Sub


REM *************************************************************
REM **** Draw a dot with the palette color ************
REM *************************************************************
Sub draw_pixel(xp as integer, yp as integer, colr as Ubyte, colg as Ubyte, colb as Ubyte)
    PSet ( xp,yp ),rgb( colr,colg,colb )
end sub
