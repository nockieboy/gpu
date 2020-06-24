
Dim r (0 To 7) As Ubyte
dim as string fn, fn256, fn16, fn4, fn1
dim as ubyte x,y,z,c

? "Enter file name > ";:input fn

fn256=fn+"x256.bin"
fn16=fn+"x16.bin"
fn4=fn+"x4.bin"
fn1=fn+"x1.bin"

fn=fn+".raw"

open fn For Binary Access Read As 1
open fn256 For Binary Access Write As 2
open fn16 For Binary Access Write As 3
open fn4 For Binary Access Write As 4
open fn1 For Binary Access Write As 5

while not eof(1)

get #1,,r(0),8

for x=0 to 7
c=int(r(x)/16)+16
?#2,chr(c);
next x

for x=0 to 6 step 2
c=int(r(x)/16)
c=c*16
c=c+int(r(x+1)/16)
?#3,chr(c);
next x

c=0
for x=0 to 3
z=int(r(x)/64)
c=c*4+z
next x
? #4,chr(c);
c=0
for x=4 to 7
z=int(r(x)/64)
c=c*4+z
next x
? #4,chr(c);

c=0
if r(0)>127 then c=c+128
if r(1)>127 then c=c+64
if r(2)>127 then c=c+32
if r(3)>127 then c=c+16
if r(4)>127 then c=c+8
if r(5)>127 then c=c+4
if r(6)>127 then c=c+2
if r(7)>127 then c=c+1
?#5,chr(c);

wend

close 5
close 4
close 3
close 2
close 1

end


