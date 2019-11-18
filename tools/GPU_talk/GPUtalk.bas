' **************************************************
' ***** Designed to be compiled with FREEBASIC
' ***** https://www.freebasic.net/
' *****
' ***** Written By Brian H. G.
' **************************************************
const  MAX_MEM          = 16384
const  COM_CACHE        = 1   : REM number of allowed sequential commands
const  COM_PRE_TIMEOUT  = 2   : REM time in ms to wait for flush to take effect
const  COM_POST_TIMEOUT = 20   : REM time in ms to wait for GPU to respond before considering an error
const  COM_FLUSH        = 0   : REM 1 = send 272 null characters before every command  0 = high speed
const  COM_WAIT         = 0   : REM 1 = wait and flush an characters in the PC's RDX before beginning to transmit
const  COM_VERBOSE      = 0   : REM 1= print all com transaction debug information


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

Declare Sub read_gpu(mbase as integer, msize as integer)
Declare Sub write_gpu(mbase as integer, msize as integer)
Declare Sub read_gpu_all(mbase as integer, msize as integer)
Declare Sub write_gpu_all(mbase as integer, msize as integer)

Declare Sub save_file(fname as string, start as integer, size as integer)
Declare Sub load_file(fname as string, start as integer, size as integer)


dim Shared as string   ink, stemp, cmd_write, cmd_saddr, cmd_read, cmd_reset, cmd_null16
dim Shared as ubyte    ser_byte
dim Shared as integer  gpu_addr, gpu_addr_now, ser_rxbuf, x, y, z, c, hp, undobase
dim shared as integer  mx,my,mb,mw,mwl,mbl,mwd,mcx1,mcy1,mcz,mcx2,mcy2,mcx,mcy, edit_mode, edit_pos
Dim Shared read_buffer  (0 To MAX_MEM) As Ubyte
Dim Shared undo_buffer  (0 To 256) As Ubyte
Dim Shared verify_buffer  (0 To 256) As Ubyte
Dim Shared write_buffer (0 To 256) As Ubyte
Dim Shared hex_str      (0 To 255) As string
Dim Shared asc_str      (0 To 255) As string
Dim Shared bin_str      (0 To 255) As string
dim Shared as integer   mstart,mstop,mpos

Dim Shared com_buffer   (0 To 16) As Ubyte
dim shared as integer   com_addr, com_bytepos, com_command, com_timer, com_txp, com_rxp


ScreenRes 720,480,16,0,0
cmd_null16 = chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0)
cmd_write  = "Writ"     :rem The next 3 BYTEs defines the base address and the next byte defines the number of bytes to write
cmd_read   = "Read"     :rem The next 3 BYTEs defines the base address and the next byte defines the number of bytes to read
cmd_reset  = "ResetNow"
cmd_reset  = cmd_null16 + cmd_null16 + cmd_null16 + cmd_reset + cmd_reset + cmd_reset: Rem this is the full reset sequence

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
hex_str(x) = hex(int(x/16)) + hex((x and 15))
read_buffer(x) = x:rem fill dummy data
asc_str(x) = "."
if x<>7 and x<>0 and x<>32 and x<>13 and not (x>=8 and x<=10) then asc_str(x)=chr(x): rem remove screen bell sound
next x

for x=0 to MAX_MEM/2-1
read_buffer(x*2)   = int(x/256) and 255:rem fill dummy data
read_buffer(x*2+1) = int(x) and 255:rem fill dummy data
next x


?:? "Enter Com# ";:input ink
'ink="COM"+ink+":115200,N,8,1,CS,DS,BIN,DT"   :REM With 50Mhz, use 433.
ink="COM"+ink+":921600,N,8,1,CS,DS,BIN,DT"  :REM With 50Mhz, or 54.
'ink="COM"+ink+":9600,N,8,1,CS,DS,BIN,DT"  :REM with 50Mhz, use 108.
cls
color rgb(224,224,224),rgb(0,0,0)
locate 60,1:? ink;
OPEN COM ink For Binary Access AS 1
?#1,chr(0); : rem Must tx at least 1 character


print_setup()




' Wait for keyboard input
read_gpu_all(0,MAX_MEM)

getmouse mx,my,mw,mb:mbl=mb:mwl=mw
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


locate 39,65:?"SHIFT-S to save file 1"
locate 40,65:?"SHIFT-L to save file 1"
locate 41,65:?"CTRL -S to save file 2"
locate 42,65:?"CTRL -L to save file 2"
locate 43,65:?"[s] Save 256 byte view"
locate 44,65:?"[l] load 256 byte view"
locate 46,65:?"CTRL -R to RESET GPU"

color rgb(224,224,224),rgb(0,0,0)
end sub



sub do_commands()
	if ink="" and edit_mode=0 then read_gpu(gpu_addr,256)
	if ink="" and edit_mode=1 then write_gpu(gpu_addr,256)

	if len(ink)<>0 then locate 60,44:? len(ink),asc(ink),asc(mid(ink,2,1)),

	sleep 1,0:                           'allow system multitasking

if edit_mode = 0 then
        z= asc(mid(ink,1,1))
	if ink="L" then load_file("GPU_dump_file1.bin",0,MAX_MEM)
	if ink="S" then save_file("GPU_dump_file1.bin",0,MAX_MEM)
	if z  = 12 then load_file("GPU_dump_file2.bin",0,MAX_MEM)
	if z  = 19 then save_file("GPU_dump_file2.bin",0,MAX_MEM)

	if ink="l" then put_undo():load_file("GPU_dump_256byte.bin",gpu_addr,256)
	if ink="s" then save_file("GPU_dump_256byte.bin",gpu_addr,256)

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
	if z=18  then ?#1,cmd_reset;:REM Reset the GPU

end if


if edit_mode = 1 then  : REM Editing values
        z= asc(mid(ink,1,1))
        if z=13 or z=27 or mb=2 then ink="":edit_mode=0: REM Leaving edit mode
        if z=26  then get_undo: REM Leaving edit mode

	if z>31 and edit_pos=1 and z<128 then ascii_enter()
	if (z>=48 and z<=57) or (z>=asc("a") and z<=asc("f")) and edit_pos = 0 then hex_enter()



	if asc(mid(ink,2,1))=72  then inc_cursor(0,-1)
	if asc(mid(ink,2,1))=80  then inc_cursor(0,1)
	if asc(mid(ink,2,1))=75  then inc_cursor(-1,0)
	if asc(mid(ink,2,1))=77  then inc_cursor(1,0)



end if



getmouse mx,my,mw,mb
if mb=-1  then mbl=mb
if mb<>-1 and mbl=-1 then mwl=mw:mbl=0
if mb<>-1 then mwd=mwl-mw:mwl=mw
if mb=-1  then mwd=0
rem:locate 49,1:? mx,my,mw,mb
if edit_mode=0 then gpu_addr=gpu_addr + (mwd*16) : rem mouse wheel scroll
	if gpu_addr<0 then gpu_addr=0
	if gpu_addr>(MAX_MEM-256) then gpu_addr=(MAX_MEM-256)


if edit_mode=1 then read_buffer(mcz) = read_buffer(mcz) + mwd : REM Mouse wheel edit

	print_hex()
	print_mouse()


end sub





Sub save_file(fname as string, start as integer, size as integer)
color rgb(255,255,255),rgb(0,0,255)
locate 60,45:? " SAVING  > ";fname;" < ";
color_rg(0,0,0)

'read_gpu_all(start,size)
read_gpu_all(0,MAX_MEM)

open fname For Binary Access Write As 2
put #2,,read_buffer(start),size
close #2
end sub




Sub load_file(fname as string, start as integer, size as integer)
color rgb(255,255,255),rgb(0,0,255)
locate 60,45:? " LOADING > ";fname;" < ";
color_rg(0,0,0)

if size+start > MAX_MEM then size = MAX_MEM-start

open fname For Binary Access Read As 2
get #2,,read_buffer(start),size
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


y=45:if COM_VERBOSE=1 then for x=0 to 3:color_rg(0,x+y,1):? "                ",,:next x
com_rxp=com_rxp+1:com_rxp=com_rxp and 8191
color_rg(1,y,1):?" Com read #" ;com_rxp;" Address ";mbase;". Size ";msize;".",

?#1,cmd_null16;
if COM_FLUSH=1 then
	if COM_VERBOSE=1 then color_rg(1,y+1,1):?" Flushing GPU.",,
	for x=0 to 16
	?#1,cmd_null16;
	next x
endif

com_timer = timer*100 + COM_PRE_TIMEOUT
if COM_WAIT=1 and COM_PRE_TIMEOUT>0 then
	if COM_VERBOSE=1 then color_rg(1,y+1,1):?" Waiting for flush.",,
	while (loc(1)>0 or com_timer>timer*100 )
		if loc(1)>0 then get #1,,com_buffer(0),1:com_timer = timer*100 + COM_PRE_TIMEOUT
	wend
end if


stemp = chr(int(mbase/65536) and 255) + chr(int(mbase/256) and 255) + chr(mbase and 255) + chr(msize-1)
stemp = cmd_read + stemp

if COM_VERBOSE=1 then color_rg(1,y+2,1):?" Sending read command.",,
?#1,stemp;stemp;stemp;


com_timer = timer*100 + COM_POST_TIMEOUT
if COM_VERBOSE=1 then color_rg(1,y+3,1):?" Waiting for response.",,
	while (loc(1)<msize and com_timer>timer*100 )
	sleep 1,0
	wend


z=loc(1)
if z<msize and z<257 then
color_rg(2,y+5,1):?" Error, read # ";com_rxp;" only received ";loc(1);" characters of ";msize;".",
	While ( loc(1)>0 )
	get #1,,com_buffer(0),1
	wend
end if

if z>msize then
color_rg(2,y+5,1):?" Error, read # ";com_rxp;" only received ";loc(1);" characters of ";msize;".",
	While ( loc(1)>0 )
	get #1,,com_buffer(0),1
	wend
end if

if z=msize then
	get #1,,read_buffer(mbase),z
	if COM_VERBOSE=1 then color_rg(1,y+4,1):?" Read # ";com_rxp;" was successfull. ",
endif


end sub



' *****************************************************
' ******************* handle RS232 communications
' *****************************************************
' ******************* WRITE
' *****************************************************

Sub write_gpu(mbase as integer, msize as integer)


y=45:if COM_VERBOSE=1 then for x=0 to 3:color_rg(0,x+y,1):? "                ",,:next x
com_txp=com_txp+1:com_txp=com_txp and 8191
color_rg(2,y,1):?" Com write #" ;com_txp," Address";mbase;".","Size";msize;".",

?#1,cmd_null16;
if COM_FLUSH=1 then
	if COM_VERBOSE=1 then color_rg(1,y+1,1):?" Flushing GPU.",,
	for x=0 to 16
	?#1,cmd_null16;
	next x
endif

com_timer = timer*100 + COM_PRE_TIMEOUT
if COM_WAIT=1 and COM_PRE_TIMEOUT>0 then
	if COM_VERBOSE=1 then color_rg(1,y+1,1):?" Waiting for flush.",,
	while (loc(1)>0 or com_timer>timer*100 )
		if loc(1)>0 then get #1,,com_buffer(0),1:com_timer = timer*100 + COM_PRE_TIMEOUT
	wend
end if


stemp = chr(int(mbase/65536) and 255) + chr(int(mbase/256) and 255) + chr(mbase and 255) + chr(msize-1)
stemp = cmd_write + stemp

if COM_VERBOSE=1 then color_rg(1,y+2,1):?" Sending write command.",,
?#1,stemp;stemp;stemp;

if COM_VERBOSE=1 then color_rg(1,y+2,1):?" Sending write data.",,
put #1,,read_buffer(mbase),msize


com_timer = timer*100 + COM_POST_TIMEOUT
if COM_VERBOSE=1 then color_rg(1,y+3,1):?" Waiting for write data echo.",
	while (loc(1)<msize and com_timer>timer*100 )
	wend


z=loc(1)
if z<msize and z<257 then
color_rg(2,y+5,1):?" Error, write #";com_txp,"echo only received";loc(1);" characters of";msize;".",
	While ( loc(1)>0 )
	get #1,,com_buffer(0),1
	wend
end if

if z>msize then
color_rg(2,y+5,1):?" Error, write #";com_txp,"echo received";loc(1);" characters of";msize;".",
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

	if COM_VERBOSE=1 then if c=1 then color_rg(1,y+4,1):?" Write #";com_txp,"was successfull and confirmed.",
	if c=0 then color_rg(2,y+5,1):?" Write #";com_txp,"has returned data errors.",

endif



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
color_rg(c, 3       , 1        ):? "        0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F ":? "      ";

	for y=0 to 15
		z=gpu_addr+y*16:gpu_printadr()
		for x=0 to 15
		locate y*2+5,x*3+7:? " ";hex_str(read_buffer(z+x));" ";
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
color_rg(c, y*2+5   , 1        ):? hex_str(int(z/65536) and 255);hex_str(int(z/256) and 255);hex_str(z and 255)
? "      ";
color_rg(0,0,0)
end sub



















sub print_mouse()


if edit_mode = 0 then

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

		if mx<>-1 then print_dec()



end sub











sub print_dec()

color_rg(0, mcy1*2+5, mcx1*2+57):? ">";
color_rg(4, 0       , 0        ):? asc_str(read_buffer(mcz));
color_rg(5, mcy1*2+5, mcx1*3+7 ):? " ";hex_str(read_buffer(mcz));" ";
color_rg(3, 38      , 1        ):? "Address Hex     :";
color_rg(0, 0       , 0        ):? " ";hex_str(int(mcz/65536) and 255);hex_str(int(mcz/256) and 255);hex_str(mcz and 255); "    ";
color_rg(3, 38      , 30       ):? "Binary        :";
color_rg(0, 0       , 0        ):? bin_str(read_buffer(mcz));
color_rg(3, 40      , 1        ):? "Address Decimal :";
color_rg(0, 0       , 0        ):? mcz,
color_rg(3, 40      , 30       ):? "Decimal       :";
color_rg(0, 0       , 0        ):? " ";read_buffer(mcz);"  ";
color_rg(3, 42      , 30       ):? "16bit Decimal :";

z = read_buffer(int(mcz/2)*2)*256 + read_buffer(int(mcz/2)*2+1)
color_rg(0, 0       , 0        ):? z;"     ";

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
if colm=7 then color rgb(192,255,255),rgb(0,0,224) : REM Blue on red


end sub
