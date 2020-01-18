//shared definitions

#define printf(x, ...) print(sprintf(x, __VA_ARGS__))


const float EV_SETHOOK = 10;
const float EV_REMOVEHOOK = 11;

const float STAT_PARACHUTE = 50;
const float STAT_DROWNING = 51;

float PART_SPLASH;
float PART_SMALLSPLASH;
float PART_ENEMYBLOWUP;

float() srandom = { return 2*random() - 1; }

void() precache_everything =
{
	precache_sound("demon/dland2.wav");
	precache_model("models/sinmyoumaru.iqm");
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
	precache_model("models/hook.iqm");
	precache_model("models/napkin.iqm");
	precache_model("models/crab.iqm");
	precache_model("models/bullet1.iqm");
	
	precache_sound("sounds/crabdie.wav");
	precache_sound("sounds/crabhurt.wav");
	precache_sound("sounds/parachuteopen.wav");
	precache_sound("sounds/dunnoimpact1.wav");
	precache_sound("sounds/dunnoimpact2.wav");
	
	PART_SPLASH = particleeffectnum("weapons.splash");
	PART_SMALLSPLASH = particleeffectnum("weapons.smallsplash");
	PART_ENEMYBLOWUP = particleeffectnum("weapons.enemy_blowup");
	
};