cmbcheck bb.cmb
rem frsart bb.cmb >errors
combin2 bb.cmb >>errors

split grom00
del grom00.bin
split grom01
del grom01.bin

copy grom*.bin c:\bb
copy groms.asm c:\bb

r:\baseball\tools\awk -f bba.awk groms.asm > groms.h
r:\baseball\tools\awk -f bbb.awk groms.asm >> groms.h
