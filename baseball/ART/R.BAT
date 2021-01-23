combin2 rad.cmb >errors

split rad00
split rad01

del rad00.bin
del rad01.bin

rem copy rad*.bin c:\bb\grom*.bin
rem copy rad.asm c:\bb\groms.asm
rem r:\baseball\tools\awk -f bba.awk rad.asm > c:\bb\groms.h
rem r:\baseball\tools\awk -f bbb.awk rad.asm >> c:\bb\groms.h

