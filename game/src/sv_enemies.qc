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
	sound(self, CHAN_AUTO, "sounds/dunnoimpact2.wav", 1, 1);
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
	sound(self, CHAN_AUTO, "sounds/dunnoimpact1.wav", 1, 0.5);
	pointparticles(PART_ENEMYBLOWUP, self.origin, '0 0 1');
	fake_remove(self);
}

.float aistate;
.float shots_left;
enum float { AI_IDLE, AI_CHASING };


void() enemy_think =
{
	entity pl;
	vector vec_to_player;
	self.frame = 0;
	
	if (!self.enemy)
	{
		pl = player_chain_head;
		vec_to_player = pl.origin - self.origin;
		if (vlen(vec_to_player) < 400)
		{
			makevectors(self.angles);
			if (v_forward * normalize(vec_to_player) > 0)
			{
				traceline(self.origin + '0 0 20', pl.origin, MOVE_NOMONSTERS, self);
				if (trace_fraction >= 1)
				{
					self.enemy = pl;
				}
			}
		} 
	}
	else
	{
		vec_to_player = self.enemy.origin - self.origin;
		if (vlen(vec_to_player) > 600)
		{
			self.enemy = world;
		}
		else
		{
			self.ideal_yaw = vectoangles(vec_to_player)[1];
			self.goalentity = self.enemy;
			changeyaw();
			movetogoal(self.movespeed);
			self.frame = 1;
			
			if (random() > 0.6 && time > self.attack_finished)
			{
			
				self.think = self.attack;
				self.nextthink = time + 0.2;
				return;
			}
		}
	}
	
	
	self.nextthink = time + 0.2;
	self.think = enemy_think;
}

void() bullet_touch =
{
	pointparticles(PART_BULLET1HIT, self.origin, trace_plane_normal);
	
	if (other.classname == "player")
	{
		damage(other, 1, normalize(self.velocity), self.owner);
	}
	remove(self);
};

void() crab_shoot1;
void() crab_shoot2 =
{
	if (self.shots_left == 0)
	{
		
		self.think = enemy_think;
		self.nextthink = time + 0.3;
		return;
	}
	
	self.shots_left--;
	
	entity bullet = spawn();
	setmodel(bullet, "models/bullet1.iqm");
	bullet.avelocity = randomvec() * 2000;
	makevectors(self.angles);
	setorigin(bullet, self.origin + v_forward * 20 + v_right * 28 + '0 0 30');
	setsize(bullet, '0 0 0', '0 0 0');
	bullet.velocity = v_forward * 500;
	bullet.movetype = MOVETYPE_FLYMISSILE;
	bullet.touch = bullet_touch;
	bullet.solid = SOLID_BBOX;
	bullet.owner = self;
	
	self.nextthink = time + 0.1;
	self.think = crab_shoot1;
}

void() crab_shoot1 =
{
	if (self.shots_left == 0)
	{
		
		self.think = enemy_think;
		self.nextthink = time + 0.3;
		return;
	}
	
	self.shots_left--;
	
	entity bullet = spawn();
	setmodel(bullet, "models/bullet1.iqm");
	bullet.avelocity = randomvec() * 2000;
	makevectors(self.angles);
	setorigin(bullet, self.origin + v_forward * 20 - v_right * 28 + '0 0 30');
	setsize(bullet, '0 0 0', '0 0 0');
	bullet.velocity = v_forward * 500;
	bullet.movetype = MOVETYPE_FLYMISSILE;
	bullet.touch = bullet_touch;
	bullet.solid = SOLID_BBOX;
	bullet.owner = self;
	
	self.nextthink = time + 0.1;
	self.think = crab_shoot2;
}

void() crab_attack =
{
	self.frame = 2;
	self.nextthink = time + 0.75;
	self.think = crab_shoot1;
	self.shots_left = 6;
	self.attack_finished = time + 2.5;
}

void(float amount, vector dir, entity dealer) crab_die =
{
	self.velocity = dir * 200 + '0 0 400';
	self.movetype = MOVETYPE_TOSS;
	self.solid = SOLID_NOT;
	self.nextthink = time + 2;
	self.think = enemy_die_blowup;
	self.frame = 4;
	sound(self, CHAN_AUTO, "sounds/crabdie.wav", 1, 1);
}



void(float amount, vector dir, entity dealer) crab_hurt =
{
	self.velocity = dir * 100 + '0 0 300';
	self.frame = 3;
	self.nextthink = time  + 0.4;
	self.think = enemy_think;
	sound(self, CHAN_AUTO, "sounds/crabhurt.wav", 1, 1);
}

void() enemy_crab =
{
	setmodel(self, "models/crab.iqm");
	setsize(self, '-16 -16 0', '16 16 56');
	self.solid = SOLID_BBOX;
	self.health = 1;
	self.takes_damage = TRUE;
	self.die = crab_die;
	self.hurt = crab_hurt;
	self.movetype = MOVETYPE_STEP;
	self.enemy = world;
	self.aistate = AI_IDLE;
	self.think = enemy_think;
	self.nextthink = 0.5 + random();
	self.yaw_speed = 10;
	self.attack = crab_attack;
	self.movespeed = 10;
	droptofloor();
}