
//
//	Player.qc - Various stuff done for the player, including per-frame functions like PlayerPreThink and PlayerPostThink, also client specific stuff like PutClientInServer etc.
//

void() CheckImpulses =
{
	switch (self.impulse)
	{
	default: break;
	case 1: setorigin(self, find(world, classname, "island1").origin); break;
	case 2: setorigin(self, find(world, classname, "island2").origin); break;
	case 3: setorigin(self, find(world, classname, "island3").origin); break;
	case 4: setorigin(self, find(world, classname, "island4").origin); break;
	case 5: setorigin(self, find(world, classname, "island5").origin); break;
	case 6: setorigin(self, find(world, classname, "island6").origin); break;
	case 7: setorigin(self, find(world, classname, "island7").origin); break;
	case 101: self.items = 7; break;
	}
	self.impulse = 0;
};

vector() get_spawn_point =
{
	entity spawnpoint = world;
	spawnpoint = find(spawnpoint, classname, "info_player_start");

	return spawnpoint.origin + '0 0 1';
};

void(entity e) detachhook =
{
	e.owner.attack_finished_grapple = time + 0.15;
	e.owner.hook = world;
	remove(e);
}

void() hooktouch =
{
	if (pointcontents(self.origin) == -6)
	{
		detachhook(self);
		return;
	}
	
	float surf = getsurfacenearpoint(world, self.origin);
	string text = getsurfacetexture(world, surf);
	if (text != "wood" && other.classname != "misc_bowl")
	{
		detachhook(self);
		return;
	}	
	
	self.nextthink = 0;
	sound(self, CHAN_AUTO, "sounds/grapplinghit.wav", 1, 0.5);
	pointparticles(PART_HIT, self.origin, normalize(self.velocity));
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	
	self.owner.parachuting = FALSE;
	
	// if (vlen(self.owner.velocity) > 250)
	//	self.owner.velocity = normalize(self.owner.velocity)*250;
	
	// if (self.owner.velocity_z < -300)
	//	self.owner.velocity_z = -300;
}

void() hookthink =
{
	self.angles = vectoangles(self.velocity);
	self.nextthink = time + 0.05;
	self.think = hookthink;
	
	if (vlen(self.owner.origin - self.origin) > 1000) detachhook(self);
}

const float ANIM_IDLE = 0;
const float ANIM_RUN = 1;
const float ANIM_ATTACK = 2;
const float ANIM_HURT = 3;
const float ANIM_DIE = 4;
const float ANIM_JUMP = 5;
const float ANIM_FALL = 6;
const float ANIM_LAND = 7;
const float ANIM_BOAT = 8;

void() player_normal =
{
	if (!(self.flags & FL_ONGROUND))
		self.frame = ANIM_FALL;
	else if (vlen(self.velocity) > 50)
		self.frame = ANIM_RUN;
	else
		self.frame = ANIM_IDLE;

	self.nextthink = time + 0.05;
	self.think = player_normal;
}

void() player_jump =
{
	sound(self, CHAN_AUTO, "sounds/playerjump.wav", 0.4, 1, 125);
	self.frame = ANIM_JUMP;
	self.nextthink = time + 0.2;
	self.think = player_normal;
}

void() player_land =
{
	self.frame = ANIM_LAND;
	self.nextthink = time + 0.2;
	self.think = player_normal;
}

void(float amount, vector dir, entity dealer) player_hurt =
{
	sound(self, CHAN_AUTO, "sounds/dunnoimpact2.wav", 0.9, 1, 40);
	sound(self, CHAN_AUTO, "sounds/needleimpact.wav", 0.9, 1, 100);
	pointparticles(PART_PLAYERHIT, self.origin + '0 0 32', '0 0 1');
	self.staggertime = time + 2;
	self.frame = ANIM_HURT;
	self.nextthink = time + 0.25;
	self.think = player_normal;
	
	misses++;
}

void(float amount, vector dir, entity dealer) player_die =
{
	sound(self, CHAN_AUTO, "sounds/dunnoimpact2.wav", 0.9, 1, 20);
	sound(self, CHAN_AUTO, "sounds/needleimpact.wav", 0.9, 1, 500);
	pointparticles(PART_PLAYERHIT, self.origin + '0 0 32', '0 0 1');

	if (self.hook) detachhook(self.hook);
	if (self.parachuting) self.parachuting = FALSE;	

	self.frame = ANIM_DIE;
	self.dead = TRUE;
	self.nextthink = 0;
	self.attack_finished = time + 3;
	self.velocity = dir * 240 + '0 0 350';
	
	misses++;
}

void() player_attack2 =
{
	sound(self, CHAN_AUTO, "sounds/step01.wav", 0.6, 1, 100);
	sound(self, CHAN_AUTO, "sounds/step01.wav", 0.7, 1, 80);
	pointparticles(PART_ATTACK, self.origin + v_right * 8 + v_up * 32 + v_forward * 20, v_forward);
	traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 64, 0, self);
	float hit = FALSE;
	if (trace_ent)
	{
		damage(trace_ent, 1, v_forward, self);
		hit = TRUE;
	}
	else
	{
		entity nme = findradius(self.origin + self.view_ofs, 138);
		float closest = 9999;
		entity closestnme = world;
		vector dir;
		float dist;
		while (nme)
		{
			if (nme.takes_damage && nme != self)
			{
				dir = (self.origin + self.view_ofs - v_forward * 20) - (nme.origin + '0 0 32');
				if (v_forward * normalize(dir) < -0.6)
				{
					dist = vlen(dir);
					if (dist < 100 + nme.scale * 32 && dist < closest)
					{
						closest = dist;
						closestnme = nme;
					}
				}
			}
			nme = nme.chain;
		}
		
		if (closestnme)
		{
			damage(closestnme, 1, v_forward, self);
			hit = TRUE;
		}
	}
	
	if (hit) pointparticles(PART_HIT, self.origin + self.view_ofs + v_forward * 32, v_forward);
		
	self.nextthink = time + 0.18;
	self.think = player_normal;
}

void() player_attack =
{
	self.frame = ANIM_ATTACK;
	self.nextthink = time + 0.3;
	self.think = player_attack2;
}


void() PlayerJump =
{
	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;
	
	self.weaponframe = 0;
	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	self.button2 = 0;
	player_jump();
};

void() respawn_on_surface =
{
	self.drowning = FALSE;
	self.parachuting = FALSE;
	entity bt = find(world, classname, "misc_bowl");
	if (bt)
	{
		
		//setorigin(self, bt.origin + '0 0 20');
		setorigin(self, self.safe_spot);
		bt.attack_finished = time + 1;
		bt.think = boat_check_player_nearby;
		bt.nextthink = time + 0.5;
		
		// TODO fade
	}
	else
	{
		setorigin(self, self.safe_spot);
		// setorigin(self, get_spawn_point());
	}
	
	// if (self.health == 0)
	//	localcmd("music 2\n");
	
	player_normal();
	
	if (cvar("skill"))
		damage(self, 1, '0 0 1', world);
	else
	{
		self.health = 3;
		self.dead = FALSE;
		misses++;
	}
	
	msg_entity = self;
	BeginEvent(EV_DROWN);
	multicast('0 0 0', MULTICAST_ONE_R);
	
}

void() PlayerPreThink =
{	
	CheckImpulses();
	makevectors(self.v_angle);
	
	if (self.drowning)
	{
		if (time > self.attack_finished)
		{
			pointparticles(PART_SMALLSPLASH, self.origin, '0 0 1');
			self.attack_finished = time + 0.1;
		}
		return;
	}
	
	if (self.dead)
	{
		if (time > self.attack_finished) 
		{
			if (cvar("skill"))
			{
				if (self.dead != 2)
				{
					msg_entity = self;
					BeginEvent(EV_GAMEOVER);
					multicast('0 0 0', MULTICAST_ONE_R);
					self.dead = 2;
				}
			}
			else
				respawn_on_surface();
		}
		return;
	}
	
	if (self.boat)
	{
		if (self.button2)
		{
			disembark();
		}
		return;
	}
		
		
	// Attack
	if (self.button0)
	{
		if (self.items & IT_NEEDLE && time > self.attack_finished)
		{
			self.attack_finished = time + 0.52; 
				
			player_attack();
		}
	}
	
	// Jump
	if (self.button2)
	{
		PlayerJump();
		
		if (
			!(self.flags & FL_ONGROUND) &&
			self.velocity_z < 250 &&
			self.flags & FL_JUMPRELEASED &&
			self.items & IT_PARACHUTE &&
			time > self.attack_finished_para &&
			!self.hook
		)
		{
			self.flags -= self.flags & FL_JUMPRELEASED;
			if (!self.parachuting)
			{
				sound(self, CHAN_AUTO, "sounds/parachuteopen.wav", 1, 1);
				self.velocity_z = 180;
				self.parachuting = TRUE;
				self.attack_finished_para = time + 0.3;
				if (vlen(self.velocity) > 600)
					self.velocity = normalize(self.velocity) * 600;
			}
			else
			{
				sound(self, CHAN_AUTO, "sounds/parachuteopen.wav", 0.9, 1, 75);
				self.parachuting = FALSE;
				self.attack_finished_para = time + 0.55;
			}
		}
		
		if (self.hook && self.flags & FL_JUMPRELEASED)
		{
			detachhook(self.hook);
		}
	}
	else
	{
		
		self.flags = self.flags | FL_JUMPRELEASED;
	}
	
	// Hook
	if (self.button3)
	{
		if (time > self.attack_finished_grapple && self.items & IT_ROPE)
		{
			if (self.hook)
			{
				if (self.mouse2released)
					detachhook(self.hook);
			}
			else if (self.mouse2released)
			{
				entity newhook = spawn();
				setmodel(newhook, "models/hook.iqm");
				setorigin(newhook, self.origin + [0, 0, self.maxs_z] + v_forward * 16);
				newhook.velocity = v_forward * 2000;
				newhook.angles = vectoangles(v_forward);
				newhook.movetype = MOVETYPE_FLYMISSILE;
				newhook.solid = SOLID_BBOX;
				newhook.touch = hooktouch;
				newhook.owner = self;
				newhook.think = hookthink;
				newhook.nextthink = time + 0.1;
				self.attack_finished_grapple = time + 0.1;
				self.hook = newhook;
				
				sound(self, CHAN_AUTO, "sounds/grapplingfire.wav", 1, 1);
			}
		}
		self.mouse2released = FALSE;
	}
	else
	{
		self.mouse2released = TRUE;
	}
	
};

void() PlayerPostThink =
{
	if (self.flags & FL_ONGROUND && self.parachuting)
	{
		self.parachuting = FALSE;
	}
	
	if (pointcontents(self.origin - '0 0 1') == -6 && !self.drowning)
	{
		if (edit_mode) return;
		
		if (self.hook) detachhook(self.hook);
		
		sound(self, CHAN_AUTO, "sounds/waterdeath.wav", 1, 1, 125);
		self.drowning = TRUE;
		self.frame = ANIM_FALL;
		self.nextthink = time + 1.8;
		self.think = respawn_on_surface;
		pointparticles(PART_SPLASH, self.origin, '0 0 1');
		self.attack_finished = time + 0.1;
	}
};

void() ClientKill =
{
};

//called when a client connects to the server
void() ClientConnect =
{
	// print("Client connect\n");
};

void() PlayerSpawn =
{
	self.classname = "player";
	self.solid = SOLID_SLIDEBOX;
	setmodel(self, "models/sinmyoumaru.iqm");
	self.movetype = MOVETYPE_WALK;
	self.health = 3;
	setorigin(self, get_spawn_point());
	self.angles = find(world, classname, "info_player_start").angles;
	self.fixangle = TRUE;
	setsize(self, [-12, -12, 0], [12, 12, 56]);
	self.view_ofs = [0, 0, 48];
	self.hurt = player_hurt;
	self.die = player_die;
	self.takes_damage = TRUE;
	self.dead = FALSE;
	self.safe_spot = self.origin;
	player_normal();
	self.items = 0;
	
	
	if (mapname == "menu")
	{
		self.movetype = MOVETYPE_NONE;
		self.modelindex = 0;
	}
	else
	{
		localcmd("music 2\n");
	}
};

void() PutClientInServer =
{
	player_chain_add(self);
	PlayerSpawn();
	
	msg_entity = self;
	BeginEvent(EV_ISLAND);
	MulticastByte(numislands);
	for (int i = 0; i < numislands; i++)
		MulticastVector(island_positions[i]);
	multicast('0 0 0', MULTICAST_ONE_R);
};

void() ClientDisconnect =
{
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has left the game.\n");
};


void() SetNewParms =
{
};

void() SetChangeParms =
{
};

void() info_player_start =
{
};

void(float elapsedtime) SV_PausedTic =
{
	// if (elapsedtime > 2) setpause(0);
};

float(string cmd) sv_editor_command;

void(string command_string) SV_ParseClientCommand =
{
	if (sv_editor_command(command_string)) return;
	
	tokenize(command_string);
	string cmd = argv(0);
	switch (cmd)
	{
	default: break;
	}
	clientcommand(self, command_string);
};


void() SV_RunClientCommand =
{
	if (self.boat)
	{
		entity bt = self.boat;
		bt.angles_y = turn_angle(bt.angles_y, self.angles_y, input_timelength * (65 - vlen(bt.velocity * 0.05)));
		makevectors(bt.angles);
		
		if (input_movevalues_x < 0) input_movevalues_x *= 0.5;
		bt.velocity -= 0.5 * bt.velocity * input_timelength;
		bt.velocity += v_forward * input_movevalues_x * input_timelength * 0.55;
		// setorigin(bt, bt.origin + bt.velocity * input_timelength);
		
		vector tracedir = v_forward;
		vector combined_vel = '0 0 0';
		float hits = 0;
		int rays = 16;
		
		if (time > bt.attack_finished && vlen(bt.velocity) > 40)
		{
			pointparticles(PART_SMALLSPLASH, bt.origin - v_forward * 32 + v_right * 32, v_forward + v_up);
			pointparticles(PART_SMALLSPLASH, bt.origin - v_forward * 32 - v_right * 32, v_forward + v_up);
			bt.attack_finished = time + (0.25 - vlen(bt.velocity) * 0.0005);
			sound(bt, CHAN_AUTO, "sounds/boatdrive.wav", 0.7, 1);
		}
		
		for (int i = 0; i < rays; i++)
		{
			traceline(bt.origin + '0 0 4', bt.origin + '0 0 4' + v_forward * 42 + bt.velocity * input_timelength, 0, self);
			if (trace_fraction < 1)
			{
				combined_vel -= vlen(bt.velocity) * v_forward;
				hits++;
				// printf("hitting at %v\n", trace_endpos);
			}
				
			rotatevectorsbyangle([0, 360 / rays, 0]);
		}
		
		// Brute force bounds check
		if (bt.origin_x < -15000) bt.velocity_x = 300;
		if (bt.origin_x > 15000) bt.velocity_x = -300;
		if (bt.origin_y < -16100) bt.velocity_y = 300;
		if (bt.origin_y > 13000) bt.velocity_y = -300;
		
		if (hits)
			bt.velocity += combined_vel / hits;
			
		setorigin(bt, bt.origin + bt.velocity * input_timelength);
		
		setorigin(self, bt.origin + v_right * 20 + v_up * 16);
		self.frame = ANIM_BOAT;
		return;
	}
	if (self.drowning)
	{
		input_movevalues *= 0.1;
		runstandardplayerphysics(self);
		self.velocity -=  0.8 * self.velocity * input_timelength;
		return;
	}
	
	if (self.frame == ANIM_HURT)
		input_movevalues *= 0.2;
		
	if (self.frame == ANIM_ATTACK)
		input_movevalues *= 0.3;
		
	if (self.dead)
		input_movevalues *= 0;
		
		
	runstandardplayerphysics(self);

	makevectors([0, self.angles_y, 0]);
	
	vector hvel = [self.velocity_x, self.velocity_y];
	vector proposed_velocity = self.velocity + (input_movevalues_x * v_forward + input_movevalues_y * v_right) * input_timelength * 1.5;
	
	if (self.parachuting)
	{		
		if (vlen(hvel) > 30)
			self.velocity -= (hvel / vlen(hvel)) * input_timelength * 200;
		
		if (vlen([proposed_velocity_x, proposed_velocity_y]) < 250)
			self.velocity = proposed_velocity;
			
		if (self.velocity_z < -100)
			self.velocity_z = -100;
	}
	else
	{
		if (vlen([proposed_velocity_x, proposed_velocity_y]) < 320)
			self.velocity = proposed_velocity;
	}
	
	if (self.hook && self.hook.movetype == MOVETYPE_NONE)
	{
		vector dist = self.origin - self.hook.origin;
	
	
		if (vlen(dist) > 64)
		{	
			// self.owner.velocity *= 0.85;
			self.velocity_z += cvar("sv_gravity")*0.3 * input_timelength;
			self.velocity -= normalize(dist) * bound(0, vlen(dist)*4, 1500) * input_timelength;
			if (self.flags & FL_ONGROUND)
			{
				self.velocity += '0 0 190';
				self.flags -= self.flags & FL_ONGROUND;
			}
		}
		if (self.origin_z < 36 && self.velocity_z < 0 && self.hook.origin_z > 100)
			self.velocity_z += 1600 * input_timelength;
		if (self.origin_z < 8 && self.velocity_z < 0 && self.hook.origin_z > 100)
			self.velocity_z += 1000 * input_timelength;
	}
};


