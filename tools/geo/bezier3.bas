Private Sub _
DrawQCurve3(Byval ax as integer,Byval ay as integer, _
            Byval bx as integer,Byval by as integer, _
            Byval cx as integer,Byval cy as integer, _
            Byval col as integer)
 
  Dim As Single t,tq,onestep,steps
  Dim As Integer x1,y1,x2,y2,ax2,ay2,xo,yo,x,y
  ' steps without any SQR()
  steps =(bx-ax)*(bx-ax)+(by-ay)*(by-ay)
  steps+=(cx-bx)*(cx-bx)+(cy-by)*(cy-by)
  ' adjust control point near to the curve
  bx=bx shl 1 - ax shr 1 - cx shr 1
  by=by shl 1 - ay shr 1 - cy shr 1
  If steps>2 Then
    onestep=1.0/int(steps*0.01)
    bx+=bx:by+=by
    x1=ax-bx+cx
    y1=ay-by+cy
    x2=bx-ax shl 1
    y2=by-ay shl 1
    x=ax:y=ay:t=onestep
    ' plot every pixel from A to C over B
    While (x<>cx) Or (y<>cy)
      Pset(x,y),col
      ' save old position
      xo=x:yo=y
      ' plot only on new position
      While (x=xo) And (y=yo)
        tq=t*t
        x=ax + x1*tq + x2*t
        y=ay + y1*tq + y2*t
        t+=onestep 
      Wend
    Wend
  Else
    Pset(bx,by),col
  End If
End Sub

Sub bezier3(x1, y1, x2, y2, x3, y3, col, n=0, Byval buffer As Any Ptr = 0)
    ' draw 3 point Bezier curve using bresenham type algorithm                                                       
    ' n is number of calculated curve points                                         
    ' if n=0 then number will be estimated from length of lines through control points
    ' x1,y1 and x3,y3 are curve end points, x2,y2 is control point

    If n=0 Then
        n = Int(1.6 * (Sqr((x2-x)*(x2-x) + (y2-y)*(y2-y)) + Sqr((x3-x2)*(x3-x2) + (y3-y2)*(y3-y2))))
    End If
   
    If (buffer) Then
        Pset buffer, (x1, y1), col      ' starting point
        Pset buffer, (x3, y3), col      ' end point
    Else   
        Pset (x1, y1), col              ' starting point
        Pset (x3, y3), col              ' end point
    End If

    nn = n * n
    ex = Int(nn/2)                      ' x cumulative deviation
    ey = ex                             ' y cumulative deviation

    x = x1 
    y = y1
   
    a1 = 2 * (x - 2 * x2 + x3)
    a2 = 2 * (y - 2 * y2 + y3)
    b1 = 2 * n * (x2 - x)
    b2 = 2 * n * (y2 - y)
    flag = 0                            ' new pixel flag
    For i = 1 To n-1
        dx = a1 * i + b1
        ex += dx
        While ex > nn
            x += 1
            ex -= nn
            flag = 1
        Wend
        While ex <= 0
            x -= 1
            ex += nn
            flag = 1
        Wend

        dy = a2 * i + b2
        ey += dy
        While ey > nn
            y += 1
            ey -= nn
            flag = 1
        Wend
        While ey <= 0
            y -= 1
            ey += nn
            flag = 1
        Wend
        If flag Then                    ' new pixel location
            If (buffer) Then
                Pset buffer, (x, y), col
            Else               
                Pset(x, y), col
            End If
            flag = 0
        End If
    Next
End Sub

'
' main
'
dim as integer ax,ay,mx,my,cx,cy,ox,oy
ax=160:ay=220
cx=480:cy=220

screenres 640,480

while inkey=""
  if getmouse(mx,my)=0 and (ox<>mx or oy<>my) then
    ox=mx:oy=my
    screenlock:cls
    ? "white my 'QCurve' and red bresenhem's 'Bezier'"
    line (ax-1,ay-2)-step(4,4), 7,bf
    line (mx-1,my-2)-step(4,4),14,bf
    line (cx-1,cy-2)-step(4,4), 7,bf
    DrawQCurve3(ax,ay,mx,my,cx,cy,15)
    Bezier3(ax,ay,mx,my,cx,cy,4)
    screenunlock
  end if
  sleep 10
wend
End