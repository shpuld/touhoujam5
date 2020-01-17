
//
//	Player.qc - Various stuff done for the player, including per-frame functions like PlayerPreThink and PlayerPostThink, also client specific stuff like PutClientInServer etc.
//

void() PlayerJump =
{
	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;
	
	self.weaponframe = 0;
	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	self.button2 = 0;
};


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

.float parachuting;
void() PlayerPreThink =
{	
	CheckImpulses();
	makevectors(self.v_angle);
	if(self.button0)
	{
		if (self.items & IT_NEEDLE && time > self.attack_finished)
		{
			print("attack\n");
			self.attack_finished = time + 0.5; 
			traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 48, 0, self);
			if (trace_ent) 
				damage(trace_ent, 5, v_forward, self);
		}
	}
	if(self.button2)
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
				self.gravity = 0.15;
			}
			else
			{
				print("deactivate para\n");
				self.parachuting = FALSE;
				self.gravity = 1;
			}
		}
	}
	else
	{
		
		self.flags = self.flags | FL_JUMPRELEASED;
	}
	
};

void() PlayerPostThink =
{
	if (self.flags & FL_ONGROUND && self.parachuting)
	{
		print("turning off para\n");
		self.parachuting = FALSE;
		self.gravity = 1;
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
	setmodel(self, "models/testplayer.iqm");
	self.movetype = MOVETYPE_WALK;
	self.health = 100;
	setorigin(self, get_spawn_point());
	self.fixangle = TRUE;
	setsize(self, [-16, -16, 0], [16, 16, 56]);
	self.view_ofs = [0, 0, 48];
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
	runstandardplayerphysics(self);
	
	if (self.parachuting)
	{
		makevectors(self.v_angle);
		vector proposed_velocity = self.velocity + (input_movevalues_x * v_forward + input_movevalues_y * v_right) * input_timelength * 1.5;
		if (vlen([proposed_velocity_x, proposed_velocity_y]) < 300)
			self.velocity = proposed_velocity;
	}
};


