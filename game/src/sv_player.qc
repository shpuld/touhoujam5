
//
//	Player.qc - Various stuff done for the player, including per-frame functions like PlayerPreThink and PlayerPostThink, also client specific stuff like PutClientInServer etc.
//

void() CheckImpulses =
{
	switch (self.impulse)
	{
	default: break;
	}
	self.impulse = 0;
};

vector() get_spawn_point =
{
	entity spawnpoint = world;
	spawnpoint = find(spawnpoint, classname, "info_player_start");

	return spawnpoint.origin + '0 0 1';
};

.float drowning;
.float parachuting;
.entity hook;

void(entity e) detachhook =
{
	e.owner.attack_finished = time + 0.7;
	e.owner.hook = world;
	remove(e);
}

void() hooktouch =
{
	printf("contents: %f\n", pointcontents(self.origin));
	if (pointcontents(self.origin) == -6)
	{
		detachhook(self);
		return;
	}
	
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	self.nextthink = 0;
}

void() hookthink =
{
	self.angles = vectoangles(self.velocity);
	self.nextthink = time + 0.1;
	self.think = hookthink;
}

const float ANIM_IDLE = 0;
const float ANIM_RUN = 1;
const float ANIM_ATTACK = 2;
const float ANIM_HURT = 3;
const float ANIM_DIE = 4;
const float ANIM_JUMP = 5;
const float ANIM_FALL = 6;
const float ANIM_LAND = 7;

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

void() player_hurt =
{
	self.frame = ANIM_HURT;
	self.nextthink = time + 0.2;
	self.think = player_normal;
}

void() player_attack =
{
	self.frame = ANIM_ATTACK;
	self.nextthink = time + 0.4;
	self.think = player_normal;
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
	setorigin(self, get_spawn_point());
	player_normal();
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
		
		
	// Attack
	if (self.button0)
	{
		if (self.items & IT_NEEDLE && time > self.attack_finished)
		{
			print("attack\n");
			self.attack_finished = time + 0.5; 
			traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 48, 0, self);
			if (trace_ent) 
				damage(trace_ent, 5, v_forward, self);
				
			player_attack();
		}
	}
	
	// Jump
	if (self.button2)
	{
		PlayerJump();
		
		if (!(self.flags & FL_ONGROUND) && self.velocity_z < 150 && self.flags & FL_JUMPRELEASED && self.items & IT_PARACHUTE)
		{
			self.flags -= self.flags & FL_JUMPRELEASED;
			if (!self.parachuting)
			{
				print("activate para\n");
				self.velocity_z *= 0.2;
				self.parachuting = TRUE;
			}
			else
			{
				print("deactivate para\n");
				self.parachuting = FALSE;
			}
		}
	}
	else
	{
		
		self.flags = self.flags | FL_JUMPRELEASED;
	}
	
	// Hook
	if (self.button3 && time > self.attack_finished)
	{
		if (self.hook)
		{
			detachhook(self.hook);
		}
		else
		{
			entity newhook = spawn();
			setmodel(newhook, "models/hook.iqm");
			setorigin(newhook, self.origin + self.view_ofs - '0 0 8' + v_forward * 16);
			newhook.velocity = v_forward * 1200;
			newhook.angles = vectoangles(v_forward);
			newhook.movetype = MOVETYPE_TOSS;
			newhook.solid = SOLID_BBOX;
			newhook.touch = hooktouch;
			newhook.owner = self;
			newhook.think = hookthink;
			newhook.nextthink = time + 0.1;
			self.attack_finished = time + 0.2;
			self.hook = newhook;
		}
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
		
		self.drowning = TRUE;
		self.frame = ANIM_FALL;
		self.nextthink = time + 1;
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
	self.health = 100;
	setorigin(self, get_spawn_point());
	self.fixangle = TRUE;
	setsize(self, [-16, -16, 0], [16, 16, 56]);
	self.view_ofs = [0, 0, 48];
	player_normal();
};

void() PutClientInServer =
{
	player_chain_add(self);
	PlayerSpawn();
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
	if (self.drowning)
	{
		runstandardplayerphysics(self);
		self.velocity -= 20 * self.velocity * input_timelength;
		return;
	}
	runstandardplayerphysics(self);
	
	if (self.parachuting)
	{
		if (self.velocity_z < -100)
			self.velocity_z = -100;
			
		makevectors(self.v_angle);
		vector hvel = [self.velocity_x, self.velocity_y];
		
		if (vlen(hvel) > 30)
			self.velocity -= (hvel / vlen(hvel)) * input_timelength * 200;

		vector proposed_velocity = self.velocity + (input_movevalues_x * v_forward + input_movevalues_y * v_right) * input_timelength * 1.5;
		if (vlen([proposed_velocity_x, proposed_velocity_y]) < 250)
			self.velocity = proposed_velocity;
	}
};


