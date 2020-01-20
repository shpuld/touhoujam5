//shared definitions

#define printf(x, ...) print(sprintf(x, __VA_ARGS__))


const float EV_SETHOOK = 10;
const float EV_REMOVEHOOK = 11;
const float EV_ISLAND = 12;
const float EV_DROWN = 13;
const float EV_TELEPORT = 14;
const float EV_ITEMHELP = 15;

const float STAT_PARACHUTE = 50;
const float STAT_DROWNING = 51;
const float STAT_BOAT = 52;
const float STAT_COINS = 53;
const float STAT_TOTALCOINS = 54;

float PART_SPLASH;
float PART_SMALLSPLASH;
float PART_ENEMYBLOWUP;
float PART_BULLET1HIT;
float PART_PICKUP;
float PART_ATTACK;
float PART_HIT;
float PART_PLAYERHIT;

const float IT_NEEDLE = 1;
const float IT_PARACHUTE = 2;
const float IT_ROPE = 4;


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
	precache_model("models/ripple.iqm");
	precache_model("models/stone.iqm");
	precache_model("models/stone_small.iqm");
	precache_model("models/decor_grass.iqm");
	precache_model("models/fairy.iqm");
	precache_model("models/coin.iqm");
	
	precache_sound("sounds/crabdie.wav");
	precache_sound("sounds/crabhurt.wav");
	precache_sound("sounds/parachuteopen.wav");
	precache_sound("sounds/dunnoimpact1.wav");
	precache_sound("sounds/dunnoimpact2.wav");
	precache_sound("sounds/waterdeath.wav");
	precache_sound("sounds/bulletfire.wav");
	precache_sound("sounds/bulletfirebig.wav");
	precache_sound("sounds/fairydie.wav");
	precache_sound("sounds/fairyhurt.wav");
	precache_sound("sounds/grapplingfire.wav");
	precache_sound("sounds/grapplinghit.wav");
	precache_sound("sounds/playerjump.wav");
	precache_sound("sounds/boatdrive.wav");
	precache_sound("sounds/watersound.ogg");
	precache_sound("sounds/coinpickup.wav");
	precache_sound("sounds/needleimpact.wav");
	precache_sound("sounds/step01.wav");
	
	PART_SPLASH = particleeffectnum("weapons.splash");
	PART_SMALLSPLASH = particleeffectnum("weapons.smallsplash");
	PART_ENEMYBLOWUP = particleeffectnum("weapons.enemy_blowup");
	PART_BULLET1HIT = particleeffectnum("weapons.bullet1_hit");
	PART_PICKUP = particleeffectnum("weapons.pickup");
	PART_ATTACK = particleeffectnum("weapons.attack");
	PART_HIT = particleeffectnum("weapons.hit");
	PART_PLAYERHIT = particleeffectnum("weapons.playerhit");
	
};

float(float a, float b, float amount) turn_angle =
{
	a = anglemod(a);
	b = anglemod(b);
	float diff = b - a;
	
	if (fabs(diff) < amount)
	{
		return b;
	}
	
	if (diff < -180)
	{
		b += 360;	
	}
	else if (diff > 180)
	{
		b -= 360;
	}
	
	if (fabs(b - a) < amount)
	{
		return b;
	}
	if (a < b)
		return a + amount;
	else
		return a - amount;	
}
