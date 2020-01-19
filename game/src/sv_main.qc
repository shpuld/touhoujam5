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
	
	clientstat(STAT_PARACHUTE, EV_FLOAT, parachuting);
	clientstat(STAT_DROWNING, EV_FLOAT, drowning);
	clientstat(STAT_BOAT, EV_FLOAT, boat_e);
};

void() SpectatorConnect =
{	
};

