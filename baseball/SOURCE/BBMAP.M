partition{
  overlay{
    region{}  Vectors[addr=0x800000,size=0x400];
    region{}  MAIN	[addr=0x800400];
    region{}  RomCode[addr=0x800400];
	 region{}  basetable;
	 region{}  Checksum;
	 region{}  romlength;
    }rom;
  overlay{
    region{} RAM   [addr=0x400,size=0x7C00];
    } ram;
  overlay{
    region{} RECRAM   [addr=0x600000,size=0x10000];
    } recram;
  overlay{
    region{} BATRAM   [addr=0x610000,size=0x10000];
    } batram;
   } Game;
