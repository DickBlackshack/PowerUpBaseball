# FS stands for field seperator
# Redefine FS to be tabs, commas, or spaces
BEGIN {
      FS = "\t|\t\t|\ |\.IMG";
      printf(";list of images and bank equates from groms.asm\n\n")

      printf(";BANKS LIST\n")
      printf(";=========\n")
      }	

/dc.l/ {
      printf("%s\t\tequ %s\n",$3,$5)
      next
      }
