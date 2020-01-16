//shared definitions

#define printf(x, ...) print(sprintf(x, __VA_ARGS__))


float() srandom = { return 2*random() - 1; }

void() precache_everything =
{
	precache_sound("demon/dland2.wav");
	precache_model("models/testplayer.iqm");
	precache_model("models/barrel.iqm");
	
};