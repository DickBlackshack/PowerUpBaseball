# Power Up Baseball
This is the source code (and some data) for Power Up Baseball, an unreleased arcade title from Incredible Technologies. This version of the game/source was recovered from the personal archives of [Chris Oberth](https://en.wikipedia.org/wiki/Chris_Oberth).

We found a set of pre-built binaries in the same place as this source code. In the case of art and sound, those binaries are all we've got in terms of ready-to-go material (more on that below), but I also noticed that the source code here also differs from the code that was used to build the program ROM in that pre-built set.

In disassembling the pre-built program ROM, the first meaningful difference I noticed was that AddStrike has additional cases for playing "strike out" and "curve ball strike out" sounds. That code isn't present in the pre-built ROM. There are definitely more differences beyond that, and I haven't charted them all out, but what I've seen leads me to believe that this code is slightly newer than the program ROM. The pre-built set might be from a particular location test. Nonetheless, the program ROM built from this source does appear to function with the pre-built sound/graphics data without modification. Please let me know if you find a difference which is causing problems in that realm!

## Building
The source code here is full of hard-coded absolute paths. Wanting to change as little as possible, I just replicated the drive setup with [DosBox](http://www.dosbox.com). You'll need to download DosBox 0.74, then launch DosBox with -conf dosbox.cfg on the commandline and the working directory set to the repostory root where dosbox.cfg is located. Inside Dosbox, switch to R: and run build.bat. If the build process succeeds, the program ROM file will be located at baseball/SOURCE/BB.BIM.

## Art
The bits and pieces of source art that were on the recovered backup are included here in baseball/ART. The tools needed to build graphics ROM are present and the process is intact, but much of the source art itself is missing or older than the data that was used to produce the graphics ROM in the pre-built set.

baseball/ART/M.BAT kicks off the graphics ROM build, and expects a full set of .img files to be located in baseball/ART/IMAGES. There are some zip files in that directory containing some of .img files. As mentioned, the data is outdated, but can be used to partially observe the build process. Be cautious when doing this, as it can destroy/corrupt data which is used by the source code build. [Noesis](http://richwhitehouse.com/index.php?content=inc_projects.php&showproject=91) can be used to preview those .img files as well, using the fmt_powerupbaseball_img.py script.

The art build could be properly restored by charting out where each .img file is located in the pre-built graphics ROM set. Doing so would probably be somewhat painstaking, but this source could at least be used as a guide to determine where each file is located in ROM.

## Audio
I haven't been able to locate source code for the sound driver. However, baseball/SOUNDS contains some of the remaining sound sources. I haven't confirmed whether these match up to the sound data in the pre-built set.
