//
//	Main.qc - mostly functions that will be called from the engine and are expected to exist
//

void() main =
{
};

//called for each frame that QC runs
void() StartFrame =
{
};

void() worldspawn =
{	
	precache_everything();
	
	sv_editor_init();
	
	ambientsound('0 0 500', "sounds/watersound.ogg", 1, 0);
	
	clientstat(STAT_PARACHUTE, EV_FLOAT, parachuting);
	clientstat(STAT_DROWNING, EV_FLOAT, drowning);
	clientstat(STAT_BOAT, EV_FLOAT, boat_e);
	
	editor_load_ents("default");
	editor_play();
};

void() SpectatorConnect =
{	
};

void(float num) setisland = 
{
	island_positions[num] = self.origin;
	numislands++;
};

void() island1 = { setisland(0); }
void() island2 = { setisland(1); }
void() island3 = { setisland(2); }
void() island4 = { setisland(3); }
void() island5 = { setisland(4); }
