//shared definitions

#define printf(x, ...) print(sprintf(x, __VA_ARGS__))


float() srandom = { return 2*random() - 1; }

void() precache_everything =
{
	precache_sound("demon/dland2.wav");
	precache_model("models/testplayer.iqm");
	precache_model("models/barrel.iqm");
	precache_model("models/bowl.iqm");
	precache_model("models/sky.iqm");
	precache_model("models/trigger.iqm");
	precache_model("models/arrow.iqm");
	precache_model("models/needle.iqm");
	precache_model("models/grass.iqm");
	precache_model("models/grass_cut.iqm");
	precache_model("models/grass_debris.iqm");
	precache_model("models/rope.iqm");
	
};