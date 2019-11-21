' ***********************************************************************
' *****
' ***** RS232_Debugger PC - Bridge to - RS232_Debugger.v FPGA Verilog
' *****
' ***** Designed to be compiled with FREEBASIC
' ***** https://www.freebasic.net/
' *****
' ***** Written By Brian Guralnick. November 2019
' ***********************************************************************

const  MAX_MEM          = 16384
const  COM_CACHE        = 1   : REM number of allowed sequential commands
const  COM_PRE_TIMEOUT  = 2   : REM time in ms to wait for flush to take effect
const  COM_POST_TIMEOUT = 20  : REM time in ms to wait for GPU to respond before considering an error
const  COM_FLUSH        = 0   : REM 1 = send 272 null characters before every command  0 = high speed
const  COM_WAIT         = 0   : REM 1 = wait and flush an characters in the PC's RDX before beginning to transmit
const  COM_VERBOSE      = 0   : REM 1= print all com transaction debug information, 2 = print mouse coordinates and keypresses
const  SLEEP_TIME       = 1   : REM The amount of time to sleep in ms between screen refresh and COM access.  Use at least 1 for good multitasking

const  TXT_BOX_x        = 20
const  TXT_BOX_y        = 25


Declare Sub print_setup()
Declare Sub print_hex()
Declare Sub print_dec()
Declare Sub print_mouse()
Declare sub print_select()
Declare Sub gpu_printadr()
Declare Sub color_rg( colm as ubyte, yp as ubyte, xp as ubyte )
Declare Sub ascii_enter()
Declare Sub hex_enter()
Declare Sub inc_cursor(xofs as byte, yofs as byte)
Declare Sub put_undo()
Declare Sub get_undo()
Declare Sub do_commands()
Declare Sub print_ports()
Declare sub click_binary(xp as integer, yp as integer, eb as Ubyte)


Declare Sub read_gpu(mbase as integer, msize as integer)
Declare Sub write_gpu(mbase as integer, msize as integer)
Declare Sub read_gpu_all(mbase as integer, msize as integer)
Declare Sub write_gpu_all(mbase as integer, msize as integer)
Declare Sub com_setport()

Declare Sub save_file(fname as string, start as integer, size as integer)
Declare Sub load_file(fname as string, start as integer, size as integer)
Declare Sub save_dialog()
Declare Sub load_dialog()
Declare Sub save_mif()
Declare Sub file_dialog( i as string, fn as string )
Declare Sub edit16( i as integer )
Declare Sub enter16( i as integer )
Declare Sub box( i as integer )
declare sub show_errors(i as integer)

Declare Sub inputhex (i as string)
Declare Sub inputdec (i as string)


function phex24(byval i As Integer) As String
 dim as string d
 d = hex(i)
  if i<16 then d = "0" + d
  if i<256 then d = "0" + d
  if i<4096 then d = "0" + d
  if i<65536 then d = "0" + d
  if i<1048576 then d = "0" + d
 function = d
end function

function phex16(byval i As Integer) As String
 dim as string d
 d = hex(i)
  if i<16 then d = "0" + d
  if i<256 then d = "0" + d
  if i<4096 then d = "0" + d
 function = d
end function

function p099(byval i As Integer) As String
 dim as string d
 d = str(i)
  if i<10 then d = " " + d
 function = d
end function

function px99(byval i As Integer) As String
 dim as string d
 d = str(i)
  if i<10 then d = "0" + d
 function = d
end function

function p999(byval i As Integer) As String
 dim as string d
 d = str(i)
  if i<100 then d = "0" + d
  if i<10 then d = "0" + d
 function = d
end function

function px999(byval i As Integer) As String
 dim as string d
 d = str(i)
  if i<100 then d = " " + d
  if i<10 then d = " " + d
 function = d
end function

function p9999(byval i As Integer) As String
 dim as string d
 d = str(i)
  if i<1000 then d = "0" + d
  if i<100 then d = "0" + d
  if i<10 then d = "0" + d
 function = d
end function

function px9999(byval i As Integer) As String
 dim as string d
 d = str(i)
  if i<1000 then d = " " + d
  if i<100 then d = " " + d
  if i<10 then d = " " + d
 function = d
end function

function p99999(byval i As Integer) As String
 dim as string d
 d = str(i)
  if i<10000 then d = "0" + d
  if i<1000 then d = "0" + d
  if i<100 then d = "0" + d
  if i<10 then d = "0" + d
 function = d
end function

function px99999(byval i As Integer) As String
 dim as string d
 d = str(i)
  if i<10000 then d = " " + d
  if i<1000 then d = " " + d
  if i<100 then d = " " + d
  if i<10 then d = " " + d
 function = d
end function

dim Shared as string   ink, stemp, cmd_write, cmd_saddr, cmd_read, cmd_reset, cmd_null16, cmd_prefix, com_num, cmd_setp
dim Shared as ubyte    ser_byte
dim Shared as integer  gpu_addr, gpu_addr_now, ser_rxbuf, x, y, z, c, hp, undobase
dim shared as integer  mx,my,mb,mw,mwl,mbl,mwd,mcx1,mcy1,mcz,mcx2,mcy2,mcx,mcy, edit_mode, edit_pos
dim shared as integer  m2cx1,m2cy1,m2cz,m2cx2,m2cy2,m2cx,m2cy,edit_col
Dim Shared read_buffer  (0 To MAX_MEM) As Ubyte
Dim Shared undo_buffer  (0 To 256) As Ubyte
Dim Shared verify_buffer  (0 To 256) As Ubyte
Dim Shared write_buffer (0 To 256) As Ubyte
Dim Shared phex8        (0 To 255) As string
Dim Shared asc_str      (0 To 255) As string
Dim Shared bin_str      (0 To 255) As string
Dim Shared in_port      (0 to 3)   As Ubyte
Dim Shared out_port     (0 to 3)   As Ubyte

dim Shared as integer   mstart,mstop,mpos

Dim Shared com_buffer   (0 To 16) As Ubyte
dim shared as integer   com_addr, com_bytepos, com_command, com_timer, com_txp, com_rxp, com_sxp

dim shared as string    d_filename
dim shared as integer   d_membase, d_memsize

ScreenRes 720,560,16,0,0
cmd_null16 = chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0)
cmd_prefix = chr(128) + chr(128) + chr(255) + chr(255) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0)
cmd_write  = "Writ"     :rem The next 3 BYTEs defines the base address and the next byte defines the number of bytes to write
cmd_read   = "Read"     :rem The next 3 BYTEs defines the base address and the next byte defines the number of bytes to read
cmd_setp   = "SetP"     :rem The next 3 BYTEs defines the base address and the next byte defines the number of bytes to read
cmd_reset  = "ResetNow"
cmd_reset  = cmd_null16 + cmd_prefix + cmd_reset + cmd_reset: Rem this is the full reset sequence

asc_str(0) = " 0 0 0 0"
asc_str(1) = " 0 0 0 1"
asc_str(2) = " 0 0 1 0"
asc_str(3) = " 0 0 1 1"
asc_str(4) = " 0 1 0 0"
asc_str(5) = " 0 1 0 1"
asc_str(6) = " 0 1 1 0"
asc_str(7) = " 0 1 1 1"
asc_str(8) = " 1 0 0 0"
asc_str(9) = " 1 0 0 1"
asc_str(10) = " 1 0 1 0"
asc_str(11) = " 1 0 1 1"
asc_str(12) = " 1 1 0 0"
asc_str(13) = " 1 1 0 1"
asc_str(14) = " 1 1 1 0"
asc_str(15) = " 1 1 1 1"

for x=0 to 255
bin_str(x) = asc_str(int(x/16)) + asc_str(x and 15) + " "
next x


for x=0 to 255
phex8(x) = hex(int(x/16)) + hex((x and 15))
read_buffer(x) = x:rem fill dummy data
asc_str(x) = "."
if x<>7 and x<>0 and x<>32 and x<>13 and not (x>=8 and x<=10) then asc_str(x)=chr(x): rem remove screen bell sound
next x

'for x=0 to MAX_MEM/2-1
'read_buffer(x*2)   = int(x/256) and 255:rem fill dummy data
'read_buffer(x*2+1) = int(x) and 255:rem fill dummy data
'next x

for x=0 to MAX_MEM-1
read_buffer(x)   = 0
next x


?:? "Enter Com# ";:input com_num
'ink="COM"+com_num+":115200,N,8,1,CS,DS,BIN,DT"
ink="COM"+com_num+":921600,N,8,1,CS,DS,BIN,DT"
'ink="COM"+com_num+":19200,N,8,1,CS,DS,BIN,DT"
cls


if com_num="" then color_rg(2,60,1):? "  Com disabled!  ";
if com_num<>"" then
	color_rg(0,60,1):? ink;
	OPEN COM ink For Binary Access AS 1
	?#1,chr(0); : rem Must tx at least 1 character
end if

print_setup()




' Wait for keyboard input
read_gpu_all(0,MAX_MEM)

getmouse mx,my,mw,mb:mbl=mb:mwl=mw
ink=inkey
ink=inkey
ink=""
while (ink<>chr(27) or edit_mode=1) and asc(mid(ink,2,1))<>107

	ink=inkey
	do_commands()

wend : ' program quit

close #1
end




sub print_setup()
color rgb(224,224,64),rgb(0,0,0)
locate 52,1:
? "Keys: PGUP & PGDN & Arrows = Scroll Up / Down    Home & End = Top and Bottom of memory"
? "                +CTRL+     = Scroll faster              ESC = Quit"
? "                       [r] = re-read entire GPU ram     [w] = write entire GPU ram"
?
? "      Click mouse to select either hex numbers or ASCII text.  Use +/-, Wheel mouse,"
? "      click on the the binary bits or decimal #, or type to edit the memory."
? "      [CTRL-z] To undo changes. Hit ENTER/RMB/ESC to exit editing memory.";


locate 39,60:?"SHIFT-S Save Debug_quick_file1"
locate 40,60:?"SHIFT-L Load Debug_quick_file1"
locate 41,60:?"CTRL -S Save Debug_quick_file2"
locate 42,60:?"CTRL -L Load Debug_quick_file2"
locate 43,60:?"[l] Load Binary"
locate 44,60:?"[s] Save Binary"
locate 46,60:?"[m] Save Quartus .mif file"

locate 48,60:?"CTRL -R to RESET GPU"


for y=0 to 8
color_rg(1,y+62,1 ):? ,,,"  ";
color_rg(2,y+62,45):? ,,,"      ";
next y


color rgb(224,224,224),rgb(0,0,0)
end sub



sub do_commands()
	if ink="" and edit_mode=0 then read_gpu(gpu_addr,256)
	if ink="" and edit_mode=1 then write_gpu(gpu_addr,256)
	if ink=""		  then com_setport()

	if len(ink)<>0 and COM_VERBOSE=2 then locate 60,32:? len(ink),asc(ink),asc(mid(ink,2,1)),,

	if SLEEP_TIME<>0 then sleep SLEEP_TIME,0:  REM helps allow allow system multitasking

if edit_mode = 0 then
        z= asc(mid(ink,1,1))
	if ink="L" then load_file("Debug_quick_file1.bin",0,MAX_MEM)
	if ink="S" then save_file("Debug_quick_file1.bin",0,MAX_MEM)
	if z  = 12 then load_file("Debug_quick_file2.bin",0,MAX_MEM)
	if z  = 19 then save_file("Debug_quick_file2.bin",0,MAX_MEM)

	if ink="l" then put_undo():load_dialog()
	if ink="s" then            save_dialog()
	if ink="m" then            save_mif()


	if asc(mid(ink,2,1))=71  then gpu_addr=0
	if asc(mid(ink,2,1))=79  then gpu_addr=(MAX_MEM-256)

	if asc(mid(ink,2,1))=132 then gpu_addr=gpu_addr-1024
	if asc(mid(ink,2,1))=118 then gpu_addr=gpu_addr+1024
	if asc(mid(ink,2,1))=73  then gpu_addr=gpu_addr-256
	if asc(mid(ink,2,1))=81  then gpu_addr=gpu_addr+256

	if asc(mid(ink,2,1))=72  then gpu_addr=gpu_addr-16
	if asc(mid(ink,2,1))=80  then gpu_addr=gpu_addr+16

	if asc(mid(ink,2,1))=141 then gpu_addr=gpu_addr-64
	if asc(mid(ink,2,1))=145 then gpu_addr=gpu_addr+64

        z= asc(mid(ink,1,1))
        if z=26  then get_undo()
	if z=18  then for x=0 to 32:? #1,cmd_null16; :next x: ?#1,cmd_reset;  :  REM Reset the GPU


end if


if edit_mode = 1 then  : REM Editing values
        z= asc(mid(ink,1,1))
        if z=13 or z=27 or mb=2 then ink="":edit_mode=0: REM Leaving edit mode
        if z=26  then get_undo: REM Leaving edit mode

	if z>31 and edit_pos=1 and z<128 then ascii_enter()
	if (z>=48 and z<=57) or (z>=asc("a") and z<=asc("f")) and edit_pos = 0 then hex_enter()

	if ink="+" and edit_pos=0 then edit16(1)
	if ink="-" and edit_pos=0 then edit16(-1)

	if asc(mid(ink,2,1))=72  then inc_cursor(0,-1)
	if asc(mid(ink,2,1))=80  then inc_cursor(0,1)
	if asc(mid(ink,2,1))=75  then inc_cursor(-1,0)
	if asc(mid(ink,2,1))=77  then inc_cursor(1,0)



end if


mbl=mb
getmouse mx,my,mw,mb
if mb=-1  then mbl=mb
if mb<>-1 and mbl=-1 then mwl=mw:mbl=0
if mb<>-1 then mwd=mwl-mw:mwl=mw
if mb=-1  then mwd=0
if COM_VERBOSE=2 then locate 49,1:? mx,my,mw,mb;
if edit_mode=0 and my<400 then gpu_addr=gpu_addr + (mwd*16) : rem mouse wheel scroll

	if gpu_addr<0 then gpu_addr=0
	if gpu_addr>(MAX_MEM-256) then gpu_addr=(MAX_MEM-256)


if edit_mode=1 and my<400 then read_buffer(mcz) = read_buffer(mcz) + mwd : REM Mouse wheel edit

	print_hex()
	print_mouse()
	print_ports()

end sub


sub print_ports()

for y=0 to 3
dim as string d

d = " In" + str(y) + "[7:0]=8'b" + bin_str(in_port(y)) + "=8'h" + phex8(in_port(y)) + "=8'd" + p999(in_port(y)) + ". "
color_rg(1,y*2+63,1):? d;

d = " Out" + str(y) + "[7:0]=8'b" + bin_str(out_port(y)) + "=8'h" + phex8(out_port(y)) + "=8'd" + p999(out_port(y)) + ". "
color_rg(2,y*2+63,45):? d;

click_binary(60, y*2+63, y)


next y



end sub




Sub edit16( i as integer )
	x = read_buffer(int(mcz/2)*2)*256 + read_buffer(int(mcz/2)*2+1)
	x=x+i:x=x and 65535
	read_buffer(int(mcz/2)*2) = int(x/256)
	read_buffer(int(mcz/2)*2+1) = x and 255
end sub


Sub inputhex( i as string )
dim as string i1
box(7):z=-1
color_rg(7,TXT_BOX_y+0,TXT_BOX_x):? i;

input i1
if i1<>"" then
	if mid(i1,1,2)="0x" then i1=mid(i1,3,len(i1)-2)
	if mid(i1,1,1)="$" then i1=mid(i1,2,len(i1)-1)
	i1 = "&H" + i1
	z= val(i1)
end if

box(0)
end sub



Sub inputdec( i as string )
dim as string i1
box(7):z=-1
color_rg(7,TXT_BOX_y+0,TXT_BOX_x):? i;

input i1
if i1<>"" then
	if mid(i1,1,2)="0x" then i1=mid(i1,3,len(i1)-2):i1 = "&H" + i1
	if mid(i1,1,1)="$" then i1=mid(i1,2,len(i1)-1):i1 = "&H" + i1
	z= val(i1)
endif

box(0)
end sub


Sub box( i as integer )
for y=0 to 9
color_rg(i,TXT_BOX_y-1+y,TXT_BOX_x-1):?"                                                  ";
next y
end sub

'dim shared as string    d_filename
'dim shared as integer   d_membase, d_memsize

Sub save_dialog()
file_dialog("Save binary:",".bin")
if d_filename<>"" then save_file(d_filename,d_membase,d_memsize)

box(0)
end sub
Sub load_dialog()
file_dialog("Load Binary:",".bin")
if d_filename<>"" then load_file(d_filename,d_membase,d_memsize)

box(0)
end sub

Sub save_mif()
dim as integer mifpos
file_dialog("Save a Quartus .mif (Memory Initialization File):",".mif")

if d_filename<>"" then

	OPEN d_filename FOR OUTPUT AS #2
	PRINT #2, "-- Generated by BrianHG's GPUtalk hex editor."
	PRINT #2, ""
	PRINT #2, "WIDTH=8;"
	PRINT #2, "DEPTH=";d_memsize;";"
	PRINT #2, ""
	PRINT #2, "ADDRESS_RADIX=UNS;"
	PRINT #2, "DATA_RADIX=UNS;"
	PRINT #2, ""
	PRINT #2, "CONTENT BEGIN"

	for x=d_membase to d_membase+d_memsize-1

		?#2, mifpos;" : ";read_buffer(x);";"

	mifpos=mifpos + 1
	next x

	PRINT #2, "END;"
	close #2

end if

box(0)
end sub




Sub file_dialog( i as string, fn as string )
dim as string i1,i2,i3
dim as integer mst,mlen,errd,hexin
box(7):z=0
color_rg(7,TXT_BOX_y+0,TXT_BOX_x):? i;
color_rg(7,TXT_BOX_y+1,TXT_BOX_x):? "Enter [filename],[addr start],[data length]:"
color_rg(7,TXT_BOX_y+2,TXT_BOX_x):input i1,i2,i3
hexin=0
if mid(i2,1,2)="0x" then i2=mid(i2,3,len(i2)-2):i2 = "&H" + i2:hexin=1
if mid(i2,1,1)="$" then i2=mid(i2,2,len(i2)-1):i2 = "&H" + i2:hexin=1
if mid(i3,1,2)="0x" then i3=mid(i3,3,len(i3)-2):i3 = "&H" + i3
if mid(i3,1,1)="$" then i3=mid(i3,2,len(i3)-1):i3 = "&H" + i3
mst=val(i2):mlen=val(i3)

if len(i1)>4 and mid(i1,len(i1)-3,1)<>"." then i1=i1+fn
if len(i1)<>0 and len(i1)<5 then i1=i1+fn

d_filename = ""
d_membase = 0
d_memsize = 0
errd=0
if mst >= MAX_MEM or mlen > MAX_MEM then errd=1
if mlen=0 then mlen = MAX_MEM-mst
if mst+mlen > MAX_MEM or errd=1 then errd=1:color_rg(2,TXT_BOX_y+5,TXT_BOX_x):?"Address out of range error.";:color_rg(2,TXT_BOX_y+6,TXT_BOX_x):?"Press any key to continue.";:sleep


if i1<>"" and errd=0 then
	color_rg(7,TXT_BOX_y+4,TXT_BOX_x):? i;" ";i1;"."
	color_rg(7,TXT_BOX_y+5,TXT_BOX_x)
	if hexin = 1 then ?"from addr $";phex24(mst);" to $";phex24(mst+mlen-1);".";
	if hexin = 0 then ?"from addr";mst;" to";mst+mlen-1;".";

	
	color_rg(2,TXT_BOX_y+7,TXT_BOX_x):?"Proceede? [Y/N]"
	fn="":While (fn<>"Y" and fn<>"N" and fn<>chr(27) and fn<>chr(255)):fn=ucase(inkey):sleep 10,0:wend
	d_filename = ""
	if fn="Y" then d_filename=i1:d_membase=mst:d_memsize=mlen
end if

end sub



Sub save_file(fname as string, start as integer, size as integer)
color rgb(255,255,255),rgb(0,0,255)
locate 60,32:? " SAVING  > ";fname;" < ";
color_rg(0,0,0)

'read_gpu_all(start,size)
read_gpu_all(0,MAX_MEM)

open fname For Binary Access Write As 2
put #2,,read_buffer(start),size
close #2
end sub




Sub load_file(fname as string, start as integer, size as integer)

if size+start > MAX_MEM then size = MAX_MEM-start
open fname For Binary Access Read As 2

color rgb(255,255,255),rgb(0,0,255)
locate 60,32:? " LOADING > ";fname;" < With";lof(2);" bytes.";
color_rg(0,0,0)

if lof(2)>0 then
	if lof(2)<size then size=lof(2)
	if size+start>MAX_MEM then size=MAX_MEM-start
	if size>0 then get #2,,read_buffer(start),size
end if


if lof(2)<1 then
	box(2)
	color_rg(7,TXT_BOX_y+1,TXT_BOX_x):?"   Cannot load file."
	color_rg(7,TXT_BOX_y+3,TXT_BOX_x):?"   Press any key to continue."
	sleep
	box(0)
end if

close #2


'write_gpu_all(start,size)
write_gpu_all(0,MAX_MEM)

end sub


' *****************************************************
' ******************* handle RS232 communications
' *****************************************************
' ******************* READ
' *****************************************************

Sub read_gpu_all(mbase as integer, msize as integer)
for mpos=mbase to msize-1 step 256
read_gpu(mpos,256)
next mpos
end sub


Sub write_gpu_all(mbase as integer, msize as integer)
for mpos=mbase to msize-1 step 256
write_gpu(mpos,256)
next mpos
end sub



Sub read_gpu(mbase as integer, msize as integer)
if com_num<>"" then

y=45:if COM_VERBOSE=1 then for x=0 to 3:color_rg(0,x+y,1):? "                ",,:next x
com_rxp=com_rxp+1:com_rxp=com_rxp and 8191
color_rg(1,y,1):?" Com read #" ;px9999(com_rxp);" Address ";px99999(mbase);" with";px9999(msize);" bytes.   ";

?#1,cmd_null16;
if COM_FLUSH=1 then
	if COM_VERBOSE=1 then color_rg(1,y+1,1):?" Flushing GPU.  ";
	for x=0 to 16
	?#1,cmd_null16;
	next x
endif

com_timer = timer*100 + COM_PRE_TIMEOUT
if COM_WAIT=1 and COM_PRE_TIMEOUT>0 then
	if COM_VERBOSE=1 then color_rg(1,y+1,1):?" Waiting for flush.  ";
	while (loc(1)>0 or com_timer>timer*100 )
		if loc(1)>0 then get #1,,com_buffer(0),1:com_timer = timer*100 + COM_PRE_TIMEOUT
	wend
end if


stemp = chr(int(mbase/65536) and 255) + chr(int(mbase/256) and 255) + chr(mbase and 255) + chr(msize-1)
stemp = cmd_read + stemp

if COM_VERBOSE=1 then color_rg(1,y+2,1):?" Sending read command.  ";
?#1,cmd_prefix;stemp;stemp;


com_timer = timer*100 + COM_POST_TIMEOUT
if COM_VERBOSE=1 then color_rg(1,y+3,1):?" Waiting for response.  ";
	while (loc(1)<msize and com_timer>timer*100 )
	sleep 1,0
	wend


z=loc(1)
if z<msize and z<257 then
color_rg(2,y+5,1):?" Error, read #";px9999(com_rxp);" received";px9999(loc(1));" bytes of";px9999(msize);".  ";
	While ( loc(1)>0 )
	get #1,,com_buffer(0),1
	wend
end if

if z>msize then
color_rg(2,y+5,1):?" Error, read #";px9999(com_rxp);" received";px9999(loc(1));" bytes of ";px9999(msize);".  ";
	While ( loc(1)>0 )
	get #1,,com_buffer(0),1
	wend
end if

if z=msize then
	get #1,,read_buffer(mbase),z
	if COM_VERBOSE=1 then color_rg(1,y+4,1):?" Read #";px9999(com_rxp);" was successfull.  ";
endif



end if
end sub



' *****************************************************
' ******************* handle RS232 communications
' *****************************************************
' ******************* WRITE
' *****************************************************

Sub write_gpu(mbase as integer, msize as integer)
if com_num<>"" then


y=45:if COM_VERBOSE=1 then for x=0 to 3:color_rg(0,x+y,1):? "                ",,:next x
com_txp=com_txp+1:com_txp=com_txp and 8191
color_rg(2,y,1):?" Com write #" ;px9999(com_txp);" Address ";px99999(mbase);" with";px9999(msize);" bytes.  ";

?#1,cmd_null16;
if COM_FLUSH=1 then
	if COM_VERBOSE=1 then color_rg(1,y+1,1):?" Flushing GPU.  ";
	for x=0 to 16
	?#1,cmd_null16;
	next x
endif

com_timer = timer*100 + COM_PRE_TIMEOUT
if COM_WAIT=1 and COM_PRE_TIMEOUT>0 then
	if COM_VERBOSE=1 then color_rg(1,y+1,1):?" Waiting for flush.  ";
	while (loc(1)>0 or com_timer>timer*100 )
		if loc(1)>0 then get #1,,com_buffer(0),1:com_timer = timer*100 + COM_PRE_TIMEOUT
	wend
end if


stemp = chr(int(mbase/65536) and 255) + chr(int(mbase/256) and 255) + chr(mbase and 255) + chr(msize-1)
stemp = cmd_write + stemp

if COM_VERBOSE=1 then color_rg(1,y+2,1):?" Sending write command.  ";
?#1,cmd_prefix;stemp;stemp;

if COM_VERBOSE=1 then color_rg(1,y+2,1):?" Sending write data.  ";
put #1,,read_buffer(mbase),msize


com_timer = timer*100 + COM_POST_TIMEOUT
if COM_VERBOSE=1 then color_rg(1,y+3,1):?" Waiting for write data echo.  ";
	while (loc(1)<msize and com_timer>timer*100 )
	wend


z=loc(1)
if z<msize and z<257 then
color_rg(2,y+5,1):?" Error, write #";px9999(com_txp);" verify received ";px9999(loc(1));" bytes of";px9999(msize);".  ";
	While ( loc(1)>0 )
	get #1,,com_buffer(0),1
	wend
end if

if z>msize then
color_rg(2,y+5,1):?" Error, write #";px9999(com_txp);" verify received ";px9999(loc(1));" bytes of ";px9999(msize);".  ";
	While ( loc(1)>0 )
	get #1,,com_buffer(0),1
	wend
end if

if z=msize then
	get #1,,verify_buffer(0),z
	c=1

	for x=0 to z-1
	if read_buffer(mbase+x)<>verify_buffer(x) then c=0
	next x

	if COM_VERBOSE=1 then if c=1 then color_rg(1,y+4,1):?" Write #";px9999(com_txp);" was confirmed.  ";
	if c=0 then color_rg(2,y+5,1):?" Write #";px9999(com_txp);" verify has data errors. ";:if COM_VERBOSE=1 then show_errors(mbase)


end if
end if
end sub

sub show_errors(q as integer)
for y=0 to 15
for x=0 to 15
c=1
if read_buffer(q+x+y*16)<>verify_buffer(x+y*16) then c=2
color_rg(c, y*2+5+1, x*3+7 ):? " ";phex8(verify_buffer(x+y*16));" ";
next x
next y
end sub




' *****************************************************
' ******************* handle RS232 communications
' *****************************************************
' ******************* Set Out0,1,2,3, Read In0,1,2,3
' *****************************************************

Sub com_setport()
dim as integer msize
msize = 4

if com_num<>"" then

y=61:if COM_VERBOSE=1 then for x=0 to 3:color_rg(0,x+y,1):? "                ",:next x
com_sxp=com_sxp+1:com_sxp=com_sxp and 8191
if COM_VERBOSE=1 then color_rg(1,y,1):?" Com Setport #" ;px9999(com_sxp);". ";

?#1,cmd_null16;
if COM_FLUSH=1 then
	if COM_VERBOSE=1 then color_rg(1,y+1,1):?" Flushing COM. ";
	for x=0 to 16
	?#1,cmd_null16;
	next x
endif

com_timer = timer*100 + COM_PRE_TIMEOUT
if COM_WAIT=1 and COM_PRE_TIMEOUT>0 then
	if COM_VERBOSE=1 then color_rg(1,y+1,1):?" Waiting for flush. ";
	while (loc(1)>0 or com_timer>timer*100 )
		if loc(1)>0 then get #1,,com_buffer(0),1:com_timer = timer*100 + COM_PRE_TIMEOUT
	wend
end if


stemp = chr(out_port(0)) + chr(out_port(1)) + chr(out_port(2)) + chr(out_port(3))
stemp = cmd_setp + stemp

if COM_VERBOSE=1 then color_rg(1,y+2,1):?" Sending Set Port Command. ";
?#1,cmd_prefix;stemp;stemp;


com_timer = timer*100 + COM_POST_TIMEOUT
if COM_VERBOSE=1 then color_rg(1,y+3,1):?" Waiting for response. ";
	while (loc(1)<msize and com_timer>timer*100 )
	sleep 1,0
	wend


z=loc(1)
if z<msize and z<257 then
color_rg(2,y+5,1):?" Error, read #";px9999(com_sxp);". Received ";px9999(loc(1));" bytes of ";px9999(msize);".";
	While ( loc(1)>0 )
	get #1,,com_buffer(0),1
	wend
end if

if z>msize then
color_rg(2,y+5,1):?" Error, read #";px9999(com_sxp);". Received";px9999(loc(1));" bytes of ";px9999(msize);".";
	While ( loc(1)>0 )
	get #1,,com_buffer(0),1
	wend
end if

if z=msize then
	get #1,,in_port(0),z
	if COM_VERBOSE=1 then color_rg(1,y+4,1):?" Setport #";px9999(com_sxp);" was successfull.";
endif



end if
end sub


' *****************************************************
' ******************* End of handle RS232 communications
' *****************************************************




sub put_undo()
undobase=gpu_addr
for x=0 to 255
undo_buffer(x)=read_buffer(x+gpu_addr)
next x
end sub

sub get_undo()
for x=0 to 255
read_buffer(x+undobase)=undo_buffer(x)
next x
print_dec()
end sub




sub hex_enter()
z=-1
c=asc(ink)
if c>=48 and c<=57 then z=c-48
if c>=asc("a") and c<=asc("f") then z=c-asc("a")+10

if z<>-1 and hp=0 then read_buffer(mcz)=(read_buffer(mcz) and 15) + z*16:hp=1
if z<>-1 and hp=2 then read_buffer(mcz)=(read_buffer(mcz) and 240) + z

print_dec()

if hp=2 then hp=0:inc_cursor(1,0)
if hp=1 then hp=2

end sub



sub ascii_enter()
read_buffer(mcz) = asc(ink)
print_dec()
inc_cursor(1,0)
print_dec()
end sub


sub inc_cursor(xofs as byte, yofs as byte)
mcx1=mcx1+xofs
mcy1=mcy1+yofs
if mcx1>15 then mcx1=0:mcy1=mcy1+1
if mcx1<0  then mcx1=15:mcy1=mcy1-1

if mcy1>15 then mcy1=mcy1-1:if xofs=1 then mcx1=15:REM UNDO BUFFER BUG gpu_addr=gpu_addr+16:if gpu_addr>(MAX_MEM-256) then gpu_addr=(MAX_MEM-256) Rem rend of screen
if mcy1<0 then  mcy1=mcy1+1:if xofs=-1 then mcx1=0

mcz=gpu_addr+mcy1*16+mcx1
print_dec()
end sub



sub print_hex()

c=1:if edit_mode=1 and edit_pos=0 then c=2
color_rg(c, 3       , 1        ):? "       +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +A +B +C +D +E +F ":? "      ";

	for y=0 to 15
		z=gpu_addr+y*16:gpu_printadr()
		for x=0 to 15
		locate y*2+5,x*3+7:? " ";phex8(read_buffer(z+x));" ";
		next x

		for x=0 to 15
		locate y*2+5,x*2+57:? " ";asc_str(read_buffer(z+x));
		next x

	next y

c=1:if edit_mode=1 and edit_pos=1 then c=2
color_rg(c, 3       , 57        ):? "                                  ";
for y=3 to 36:locate y,90:?" ";
next y
color_rg(0,0,0)

end sub

sub gpu_printadr()
color_rg(c, y*2+5   , 1        ):? phex24(z)
? "      ";
color_rg(0,0,0)
end sub






sub print_mouse()

const ADDRhy     = 38
const ADDRdy     = 40
const ADDRx1     = 1
const ADDRx2     = 24
const datbiny    = 38
const datdec8y   = 40
const datdec16y  = 42
const datdecx1   = 27
const datdecx2   = 46
const datbin2    = 58
const datbinx128 = 43
const datbinx64  = 45
const datbinx32  = 47
const datbinx16  = 49
const datbinx8   = 51
const datbinx4   = 53
const datbinx2   = 55
const datbinx1   = 57

edit_col=0

if edit_mode = 0 then

		m2cx = (mx+4)/8
		m2cy = (my+4)/8
	if m2cy = ADDRhy  and m2cx >= ADDRx1 and m2cx <= ADDRx2 then edit_col = 1
	if m2cy = ADDRdy  and m2cx >= ADDRx1 and m2cx <= ADDRx2 then edit_col = 2
	if edit_col=1 and mb=1 then inputhex("Enter new hex address:"):if z>0 then gpu_addr=z and 1048560
	if edit_col=2 and mb=1 then inputdec("Enter new decimal address:"):if z>0 then gpu_addr=z and 1048560


	if mx<450 then

		mcx = (mx-64)/24
		mcy = (my-34)/16

		if mcx>=0 and mcx<16 and mcy>=0 and mcy<16 then

			mcx1=mcx:mcy1=mcy
			mcz=gpu_addr+mcy1*16+mcx1

			if mb = 1 then edit_mode=1:edit_pos=0:put_undo()


		end if
	end if


	if mx>450 then

		mcx = (mx-459)/16
		mcy = (my-34)/16

		if mcx>=0 and mcx<16 and mcy>=0 and mcy<16 then

			mcx1=mcx:mcy1=mcy
			mcz=gpu_addr+mcy1*16+mcx1

			if mb = 1 then edit_mode=1:edit_pos=1:put_undo()

		end if
	end if
end if :rem EDIT mode 0


if edit_mode = 1 then


		m2cx = (mx+4)/8
		m2cy = (my+4)/8
		'locate m2cy,m2cx:? m2cx;

		if m2cy = datbiny    and m2cx >= datdecx1 and m2cx <= datbin2  then edit_col = 3
		if m2cy = datdec8y   and m2cx >= datdecx1 and m2cx <= datdecx2 then edit_col = 4
		if m2cy = datdec16y  and m2cx >= datdecx1 and m2cx <= datdecx2 then edit_col = 5

	if edit_col=4 and mb=1 then inputdec("Enter new data byte:"):if z>0 then read_buffer(mcz)=z and 255
	if edit_col=5 and mb=1 then inputdec("Enter new data for 16bit byte:"):if z>0 then z=z and 65535:read_buffer(int(mcz/2)*2)=int(z/256):read_buffer(int(mcz/2)*2+1)=z and 255




		if m2cx = datbinx128 and edit_col=3 and mbl=0 and mb=1 then read_buffer(mcz)=read_buffer(mcz) xor 128
		if m2cx = datbinx64  and edit_col=3 and mbl=0 and mb=1 then read_buffer(mcz)=read_buffer(mcz) xor 64
		if m2cx = datbinx32  and edit_col=3 and mbl=0 and mb=1 then read_buffer(mcz)=read_buffer(mcz) xor 32
		if m2cx = datbinx16  and edit_col=3 and mbl=0 and mb=1 then read_buffer(mcz)=read_buffer(mcz) xor 16
		if m2cx = datbinx8   and edit_col=3 and mbl=0 and mb=1 then read_buffer(mcz)=read_buffer(mcz) xor 8
		if m2cx = datbinx4   and edit_col=3 and mbl=0 and mb=1 then read_buffer(mcz)=read_buffer(mcz) xor 4
		if m2cx = datbinx2   and edit_col=3 and mbl=0 and mb=1 then read_buffer(mcz)=read_buffer(mcz) xor 2
		if m2cx = datbinx1   and edit_col=3 and mbl=0 and mb=1 then read_buffer(mcz)=read_buffer(mcz) xor 1

end if : rem edit mode 1

		if mx<>-1 then print_dec()

end sub



sub click_binary(xp as integer, yp as integer, eb as Ubyte)

		m2cx = (mx+4)/8
		m2cy = (my+4)/8
		'locate m2cy,m2cx:? m2cx;m2cy;

if m2cy=yp and m2cx+2 > xp and m2cx-16 < xp then
color_rg(7,yp,xp-1):? bin_str(out_port(eb));
out_port(eb)=out_port(eb) + mwd
	if m2cx = (xp + 0 ) and mbl=0 and mb=1 then out_port(eb)=out_port(eb) xor 128
	if m2cx = (xp + 2 ) and mbl=0 and mb=1 then out_port(eb)=out_port(eb) xor 64
	if m2cx = (xp + 4 ) and mbl=0 and mb=1 then out_port(eb)=out_port(eb) xor 32
	if m2cx = (xp + 6 ) and mbl=0 and mb=1 then out_port(eb)=out_port(eb) xor 16
	if m2cx = (xp + 8 ) and mbl=0 and mb=1 then out_port(eb)=out_port(eb) xor 8
	if m2cx = (xp + 10) and mbl=0 and mb=1 then out_port(eb)=out_port(eb) xor 4
	if m2cx = (xp + 12) and mbl=0 and mb=1 then out_port(eb)=out_port(eb) xor 2
	if m2cx = (xp + 14) and mbl=0 and mb=1 then out_port(eb)=out_port(eb) xor 1
	end if

end sub




sub print_dec()

color_rg(0, mcy1*2+5, mcx1*2+57):? ">";
color_rg(4, 0       , 0        ):? asc_str(read_buffer(mcz));
color_rg(5, mcy1*2+5, mcx1*3+7 ):? " ";phex8(read_buffer(mcz));" ";


z=3:if edit_col=1 then z=7
color_rg(z, 38      , 1        ):? "Address Hex     :";
z=0:if edit_col=1 then z=7
color_rg(z, 0       , 0        ):? " ";phex24(mcz); "    ";

z=3:if edit_col=2 then z=7
color_rg(z, 40      , 1        ):? "Address Decimal :";
z=0:if edit_col=2 then z=7
color_rg(z, 0       , 0        ):? mcz,


z=3:if edit_col=3 then z=7
color_rg(z, 38      , 27       ):? "Binary        :";
z=0:if edit_col=3 then z=7
color_rg(z, 0       , 0        ):? bin_str(read_buffer(mcz));


z=3:if edit_col=4 then z=7
color_rg(z, 40      , 27       ):? "Decimal       :";
z=0:if edit_col=4 then z=7
color_rg(z, 0       , 0        ):? " ";read_buffer(mcz);"  ";

z=3:if edit_col=5 then z=7
color_rg(z, 42      , 27       ):? "16bit Decimal :";
y = read_buffer(int(mcz/2)*2)*256 + read_buffer(int(mcz/2)*2+1)
z=0:if edit_col=5 then z=7
color_rg(z, 0       , 0        ):? y;"     ";

end sub


sub color_rg( colm as ubyte, yp as ubyte, xp as ubyte )

if xp<>0 and yp<>0 then locate yp,xp

if colm=0 then color rgb(224,224,224),rgb(0,0,0)    : REM white text

if colm=1 then color rgb(255,255,255),rgb(32,96,0) : REM Green outline
if colm=2 then color rgb(255,255,255),rgb(128,16,0) : REM Red outline

if colm=3 then color rgb(0,0,0),rgb(224,224,224)    : REM Negative white
if colm=4 then color rgb(0,0,0),rgb(255,255,255)    : REM Negative white X-bright

if colm=5 then color rgb(192,255,255),rgb(96,48,16) : REM Blue on dark red

if colm=6 then color rgb(192,255,255),rgb(0,224,224) : REM Blue on green
if colm=7 then color rgb(255,255,64),rgb(0,0,128) : REM Blue on red


end sub
