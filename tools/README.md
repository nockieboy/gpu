# Microcom GPU

## Tools folder

This folder contains two sub-folders:

* PALConverter
* RS232_debugger

PALConverter is a tool written by me in Visual Studio 2017 using C#.  It is a Windows 10 .exe that will convert RGB888 palettes into two of the formats used in the GPU's development - RGB565 and RGB4444.  Paste the source palette (ASCII) into the text box, select the format you want to output, then click Convert.  If you don't specify a file to output to, the converted palette will appear in the text box for you to copy/paste.

RS232_debugger is written by Brian Guralnick, originally to be a tool used specifically in the testing of the Microcom GPU during development.  However, it has grown into a very capable and standalone [project in itself](https://www.eevblog.com/forum/fpga/verilog-rs232-uart-and-rs232-debugger-source-code-and-educational-tutorial/msg2801388/#msg2801388).

RS232_debugger is used to communicate with the GPU hardware directly for testing and debugging during development.
