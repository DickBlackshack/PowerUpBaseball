# FS stands for field seperator
# Redefine FS to be tabs, commas, or spaces
BEGIN {
      FS = "\t|\t\t|\ |\.IMG";
      printf(";list of images and bank equates from groms.asm\n\n")

      printf("UNUSED equ -1\n")
      printf(";IMAGE LIST\n")
      printf(";=========\n")
      }	

/fonts/ {next}
/font1/ {next}
/fontb/ {next}
/font4/ {next}

/; Image/ {
      printf("%s\tequ %s\n",$7,$4)
      next
      }

