// Empty

void() start_boss_music = { localcmd("music 1\n"); }
void() start_idle_music = { localcmd("music 2\n"); }


void() add_boss_music =
{
	if (bosses_active <= 0)
	{
		start_boss_music();
	}
	bosses_active++;
}

void() remove_boss_music =
{
	bosses_active--;
	if (bosses_active <= 0)
	{
		if (bosses_active < 0) bosses_active = 0;
		music_thinker.nextthink = time + 2;
		music_thinker.think = start_idle_music;
		localcmd("stopmusic\n");
	}
}

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

.entity boat;
.float boat_e;

void(entity hook) detachhook;
void() boat_touch =
{
	if (other.classname == "player")
	{
		if (other.boat) return;
		
		if (time < self.attack_finished) return;
		
		if (other.hook) detachhook(other.hook);
		
		other.boat = self;
		other.boat_e = (float)self;
		
		self.solid = SOLID_NOT;
	}
}

void() boat_check_player_nearby =
{
	entity pl = player_chain_head;
	if (vlen(pl.origin - self.origin) > 60)
	{
		self.attack_finished = time + 0.5;
	}
	else
	{
		self.attack_finished = time + 0.2;
		self.nextthink = time + 0.1;
		self.think = boat_check_player_nearby;
	}
}

void() disembark =
{
	self.boat.solid = SOLID_BBOX;
	self.boat.attack_finished = time + 1;
	self.boat.nextthink = time + 0.8;
	self.boat.think = boat_check_player_nearby;

	self.origin += '0 0 2';
	self.velocity = '0 0 50';
	self.flags -= self.flags & FL_JUMPRELEASED;
	self.boat.velocity = '0 0 0';
	
	self.safe_spot = self.origin;
	
	self.boat = world;
	self.boat_e = 0;
	
	self.health = 3;
	self.dead = FALSE;

}

void() misc_bowl =
{
	setmodel(self, "models/bowl.iqm");
	setsize(self, '-48 -48 0', '48 48 20');
	self.solid = SOLID_BBOX;
	self.touch = boat_touch;
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

void() decor_stone =
{
	setmodel(self, "models/stone.iqm");
	setsize(self, '-32 -32 -64', '32 32 64');
	self.scale = 2;
	self.solid = SOLID_BBOX;
	self.angles_y = floor(random()*4) * 90;
}

void() decor_stone_big =
{
	setmodel(self, "models/stone.iqm");
	setsize(self, '-64 -64 -128', '64 64 128');
	self.scale = 4;
	self.solid = SOLID_BBOX;
	self.angles_y = floor(random()*4) * 90;
}

void() decor_stone_s =
{
	setmodel(self, "models/stone_small.iqm");
	setsize(self, '-16 -16 -16', '16 16 16');
	self.scale = 2;
	self.solid = SOLID_BBOX;
	self.angles_y = floor(random()*4) * 90;
}

void() decor_stone_xs =
{
	setmodel(self, "models/stone_small.iqm");
	setsize(self, '-16 -16 -16', '16 16 16');
	self.scale = 1;
	self.solid = SOLID_NOT;
	self.angles_y = random() * 360;
}



void() decor_grass =
{
	setmodel(self, "models/decor_grass.iqm");
	setsize(self, '-16 -16 -16', '16 16 16');
	self.scale = 1.8;
	self.solid = SOLID_NOT;
	self.angles_y = random() * 360;
}


void() misc_grass =
{
	setmodel(self, "models/grass.iqm");
	setsize(self, '-24 -24 0', '24 24 64');
	self.solid = SOLID_BBOX;
	self.scale = 1.2;
	self.health = 1;
	self.takes_damage = TRUE;
	self.die = grass_die;
}

.float aistate;
enum float { AI_IDLE, AI_WALKING, AI_CHASING };

void() enemy_die_blowup =
{
	if (self.classname == "giant_enemy_crab" || self.classname == "fairy")
	{
		if (self.aistate == AI_CHASING)
			remove_boss_music();
	}
		
	sound(self, CHAN_AUTO, "sounds/dunnoimpact1.wav", 1, 0.5);
	pointparticles(PART_ENEMYBLOWUP, self.origin, '0 0 1');
	fake_remove(self);
}

.float shots_left;
.float staggertime;

void() enemy_think =
{
	entity pl;
	vector vec_to_player;
	float oldyaw = self.angles_y;
	self.frame = 0;
	
	if (!self.enemy)
	{
		pl = player_chain_head;
		vec_to_player = pl.origin - self.origin;
		if (vlen(vec_to_player) < 750)
		{
			makevectors(self.angles);
			if (v_forward * normalize(vec_to_player) > 0.3)
			{
				traceline(self.origin + '0 0 20', pl.origin + '0 0 30', MOVE_NOMONSTERS, self);
				if (trace_fraction >= 1)
				{
					if (self.classname == "giant_enemy_crab" || self.classname == "fairy")
					{
						if (self.aistate != AI_CHASING)
							add_boss_music();
					}
					self.enemy = pl;
					self.aistate = AI_CHASING;
				}
			}
		}
		
		if (!self.enemy)
		{
			if (self.aistate == AI_IDLE)
			{
				if (random() < 0.05) self.ideal_yaw = random() * 360;
				changeyaw();
				if (oldyaw != self.angles_y) self.frame = 1;
				if (random() < 0.03) self.aistate = AI_WALKING;
			}
			else if (self.aistate == AI_WALKING)
			{
				if (random() < 0.2) self.aistate = AI_IDLE;
				float success = walkmove(self.angles_y, self.movespeed * 0.2);
				self.frame = 1;
				if (!success) self.aistate = AI_IDLE;
			}
		}
	}
	else
	{
		vec_to_player = self.enemy.origin - self.origin;
		if (vlen(vec_to_player) > 900)
		{
			if (self.classname == "giant_enemy_crab" || self.classname == "fairy")
			{
				if (self.aistate == AI_CHASING)
					remove_boss_music();
			}
			self.enemy = world;
			self.aistate = AI_IDLE;
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
		if (other.staggertime < time)
			damage(other, 1, normalize(self.velocity), self.owner);
	}
	remove(self);
};

void() bullet_think =
{
	pointparticles(PART_BULLET1HIT, self.origin, '0 0 1');
	remove(self);
}

void(vector org, vector vel) bullet_spawn =
{
	entity bullet = spawn();
	setmodel(bullet, "models/bullet1.iqm");
	bullet.avelocity = randomvec() * 2000;
	setsize(bullet, '0 0 0', '0 0 0');
	bullet.movetype = MOVETYPE_FLYMISSILE;
	bullet.touch = bullet_touch;
	bullet.think = bullet_think;
	bullet.nextthink = time + 4;
	bullet.solid = SOLID_BBOX;
	bullet.owner = self;
	
	setorigin(bullet, org);
	bullet.velocity = vel;
}

void() crab_shoot1;
void() crab_shoot2 =
{
	if (self.shots_left == 0)
	{
		
		self.think = enemy_think;
		self.nextthink = time + 0.3;
		return;
	}
	
	sound(self, CHAN_AUTO, "sounds/bulletfire.wav", 1, 1);
	
	self.shots_left--;
	
	makevectors(self.angles);
	vector pos = self.origin + v_forward * 20 + v_right * 28 + '0 0 30';
	vector vel = v_forward * 500;
	
	self.ideal_yaw = vectoangles(self.enemy.origin - self.origin, '0 0 1')[1];
	changeyaw();
	
	bullet_spawn(pos, vel);
	
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
	
	sound(self, CHAN_AUTO, "sounds/bulletfire.wav", 1, 1);
	
	self.shots_left--;
	
	makevectors(self.angles);
	vector pos = self.origin + v_forward * 20 - v_right * 28 + '0 0 30';
	vector vel = v_forward * 500;
	
	self.ideal_yaw = vectoangles(self.enemy.origin - self.origin, '0 0 1')[1];
	changeyaw();
	
	bullet_spawn(pos, vel);
	
	self.nextthink = time + 0.1;
	self.think = crab_shoot2;
}

void() spiral_shoot =
{
	self.frame = 1;
	
	if (self.shots_left == 0)
	{
		
		self.think = enemy_think;
		self.nextthink = time + 0.3;
		return;
	}
	
	sound(self, CHAN_AUTO, "sounds/bulletfire.wav", 1, 1);
	
	self.shots_left--;
	
	makevectors(self.angles);
	vector pos = self.origin + v_forward * 20 + '0 0 30';
	bullet_spawn(pos, v_forward * 400);
	bullet_spawn(pos, normalize(v_forward*3 + v_right*2) * 400);
	bullet_spawn(pos, normalize(v_forward*3 - v_right*2) * 400);
	
	self.angles_y += 8;
	
	self.nextthink = time + 0.1;
	self.think = spiral_shoot;
}

void() giant_crab_attack =
{
	self.frame = 2;
	self.nextthink = time + 0.5;
	self.think = spiral_shoot;
	self.shots_left = 60;
	self.attack_finished = time + 10;
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
	
	self.velocity = dir * 70 + '0 0 230';
	
	if (dealer.classname == "player")
	{
		if (self.aistate != AI_CHASING && self.classname == "giant_enemy_crab")
			add_boss_music();
		self.enemy = dealer;
		self.aistate = AI_CHASING;
	}
	sound(self, CHAN_AUTO, "sounds/crabhurt.wav", 1, 1);
	
	if (self.frame == 3 || self.staggertime > time) return;
	
	self.frame = 3;
	self.nextthink = time  + 0.4;
	self.think = enemy_think;
	self.staggertime = time + 0.8;
}

void() fairyshot_touch =
{
	if (other.classname == "player")
		damage(other, 1, self.origin - other.origin, self.owner);
	
	sound(self, CHAN_AUTO, "sounds/bulletfirebig.wav", 1, 1);
	for (int i = 0; i < 16; i++)
	{
		makevectors([0, 22.5 * i, 0]);
		bullet_spawn(self.origin + '0 0 40', v_forward * 350);
	}
	
	remove(self);
}

void() fairy_shoot =
{
	self.ideal_yaw = vectoangles(self.enemy.origin - self.origin)[1];
	changeyaw();
	
	sound(self, CHAN_AUTO, "sounds/bulletfire.wav", 1, 1);
	makevectors(self.angles);
	entity proj = spawn();
	proj.touch = fairyshot_touch;
	proj.movetype = MOVETYPE_TOSS;
	proj.velocity = v_forward * (150 + 100 * self.shots_left);
	proj.owner = self;
	proj.avelocity = randomvec() * 700;
	setmodel(proj, "models/bullet1.iqm");
	proj.scale = 2;
	setorigin(proj, self.origin + v_forward * 32 + '0 0 90');
	setsize(proj, '0 0 0', '0 0 0');
	proj.solid = SOLID_BBOX;
	self.nextthink = time + 0.25;
	
	self.shots_left--;
	
	if (self.shots_left)
		self.think = fairy_shoot;
	else
		self.think = enemy_think;
}

void() fairy_attack =
{
	self.frame = 2;
	self.nextthink = time + 0.6;
	self.think = fairy_shoot;
	self.shots_left = 3;
	self.attack_finished = time + 2.5;
}

void() item_coin;
void(float amount, vector dir, entity dealer) fairy_die =
{
	sound(self, CHAN_AUTO, "sounds/fairydie.wav", 1, 1);
	self.velocity = dir * 200 + '0 0 400';
	self.movetype = MOVETYPE_TOSS;
	self.solid = SOLID_NOT;
	self.nextthink = time + 1.5;
	self.think = enemy_die_blowup;
	self.frame = 4;
}



void(float amount, vector dir, entity dealer) fairy_hurt =
{
	sound(self, CHAN_AUTO, "sounds/fairyhurt.wav", 1, 1);
	self.velocity = dir * 100 + '0 0 300';
	if (dealer.classname == "player")
	{
		if (self.aistate != AI_CHASING)
			add_boss_music();
			
		self.enemy = dealer;
		self.aistate = AI_CHASING;	

	}
	
	if (self.frame == 3 || self.staggertime > time) return;
	
	self.frame = 3;
	self.nextthink = time  + 0.3;
	self.think = enemy_think;
}


void() ai_init =
{
	self.movetype = MOVETYPE_STEP;
	self.enemy = world;
	self.aistate = AI_IDLE;
	self.think = enemy_think;
	self.takes_damage = TRUE;
	self.solid = SOLID_BBOX;
	self.nextthink = 0.5 + random();
	if (!(self.flags & FL_FLY))
		droptofloor();
}

void() enemy_crab =
{
	setmodel(self, "models/crab.iqm");
	setsize(self, '-16 -16 0', '16 16 56');
	self.health = 3;
	self.die = crab_die;
	self.hurt = crab_hurt;
	self.attack = crab_attack;
	ai_init();
	self.movespeed = 10;
	self.yaw_speed = 15;
}

void() giant_enemy_crab =
{
	setmodel(self, "models/crab.iqm");
	setsize(self, '-16 -16 0', '16 16 56');
	self.health = 6;
	self.die = crab_die;
	self.hurt = crab_hurt;
	self.attack = giant_crab_attack;
	self.yaw_speed = 15;
	self.movespeed = 10;
	self.scale = 1.5;
	ai_init();
}

void() fairy =
{
	setmodel(self, "models/fairy.iqm");
	setsize(self, '-16 -16 0', '16 16 56');
	self.health = 5;
	self.flags |= FL_FLY;
	self.die = fairy_die;
	self.hurt = fairy_hurt;
	self.attack = fairy_attack;
	self.yaw_speed = 15;
	self.movespeed = 15;
	self.scale = 2;
	ai_init();
}