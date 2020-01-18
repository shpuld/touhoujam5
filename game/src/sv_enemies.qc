// Empty

void() misc_barrel =
{
	setmodel(self, "models/barrel.iqm");
	setsize(self, '-12 -12 0', '12 12 36');
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_TOSS;
	
	entity targetent = find(world, targetname, self.target);
	if (target)
		self.velocity = (targetent.origin - self.origin) * 4 + '0 0 400';
	
	self.touch = sub_fake_remove;
}

void() misc_bowl =
{
	setmodel(self, "models/bowl.iqm");
	setsize(self, '-48 -48 -24', '48 48 16');
	self.solid = SOLID_BBOX;
}


void(float amount, vector dir, entity dealer) grass_die =
{
	setmodel(self, "models/grass_cut.iqm");
	
	entity debris = spawn();
	setorigin(debris, self.origin);
	setmodel(debris, "models/grass_debris.iqm");
	debris.movetype = MOVETYPE_TOSS;
	debris.solid = SOLID_NOT;
	debris.velocity = dir * 300 + '0 0 500';
	self.solid = SOLID_NOT;
}

void() misc_grass =
{
	setmodel(self, "models/grass.iqm");
	setsize(self, '-24 -24 0', '24 24 64');
	self.solid = SOLID_BBOX;
	self.health = 1;
	self.takes_damage = TRUE;
	self.die = grass_die;
}


void() enemy_die_blowup =
{

	fake_remove(self);
}

void() crab_think =
{
	self.frame = 0;
}


void(float amount, vector dir, entity dealer) crab_die =
{
	self.velocity = dir * 200 + '0 0 400';
	self.movetype = MOVETYPE_TOSS;
	self.solid = SOLID_NOT;
	self.nextthink = time + 2;
	self.think = enemy_die_blowup;
	self.frame = 4;
}



void(float amount, vector dir, entity dealer) crab_hurt =
{
	self.frame = 3;
	self.nextthink = time  + 0.4;
	self.think = crab_think;
}

void() enemy_crab =
{
	setmodel(self, "models/crab.iqm");
	setsize(self, '-24 -24 0', '24 24 64');
	self.solid = SOLID_BBOX;
	self.health = 3;
	self.takes_damage = TRUE;
	self.die = crab_die;
	self.hurt = crab_hurt;
	self.movetype = MOVETYPE_STEP;
}