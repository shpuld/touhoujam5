
void() CSQC_Ent_Remove =
{
	remove(self);
};

void() CSQC_Shutdown =
{
};


.float ideal_yaw;
.float yaw_speed;
vector player_model_angles;
vector wanted_angles;
entity parachute_model;
entity needle_model;
entity hook_model;
entity ripple_model;
float hook_time;
float drowning_ofs;

vector old_bowl_pos;
float(float isnew) bowl_listen =
{
	self.angles += [sin(time)*0.5, 0, cos(1.1*time+0.5)*0.4];
	
	self.origin_z += sin(1.1 * time) * 1.5;
	
	if (self.frame == 1 && localplayer.frame == 8)
	{	
		old_bowl_pos = self.origin;
		makevectors(localplayer.angles);
		setorigin(self, localplayer.origin - v_right * 20 - v_up * 16);
		if (vlen(self.origin - old_bowl_pos) > 16)
			setorigin(self, old_bowl_pos);
	}
	else if (vlen(old_bowl_pos - self.origin) > 16*60*frametime && vlen(old_bowl_pos - self.origin) < 256)
	{
		// print("wait this isn't right\n");
		old_bowl_pos += (self.origin - old_bowl_pos) * 0.025;
		self.origin = old_bowl_pos;
	}
	else
	{
		old_bowl_pos = self.origin;
	}
	
	ripple_model.origin = [self.origin_x, self.origin_y, 2];
	ripple_model.angles_y = time * 4;
	ripple_model.scale = 1.4;
	addentity(ripple_model);
	
	return 1; 
}


float(float isnew) player_listen =
{
	if (self.entnum == player_localentnum) 
	{
		localplayer = self;
	}
	
	// Boat frame
	if (self.frame == 8)
	{
		self.origin_z += sin(1.1 * time) * 1.5;
		self.angles = getentity(getstatf(STAT_BOAT), GE_ANGLES);
		wanted_angles_y = self.angles_y;
		player_model_angles_y = wanted_angles_y;
		return 1;
	}
	
	vector horvel = [self.velocity_x, self.velocity_y, 0];
	float speed = vlen(horvel);
	if (speed > 20)
	{
		wanted_angles = vectoangles(horvel);
	}
	
	if (self.frame == 2)
	{
		wanted_angles_y = self.angles_y;
	}
	
	if (self.frame == 4)
	{
		wanted_angles = vectoangles(-horvel);
	}
	
	if (speed > 10 || self.frame == 2 || self.frame == 4)
	{
		player_model_angles.y = turn_angle(player_model_angles_y, wanted_angles_y, frametime * 1200);
	}
	
	self.angles = player_model_angles;

	if (self.lerpfrac > 0)
	{
		// Lerpfrac in engine starts at 1 and goes to 0,
		// frame = targetframe, frame2 = previous frame
		self.lerpfrac = 1-(1-self.lerpfrac)*7;
		
		if (self.lerpfrac > 1)
		{
			self.lerpfrac = 1;
		}
		if (self.lerpfrac < 0)
		{
			self.lerpfrac = 0;
		}
	}
	
	parachute_model.origin = self.origin + '0 0 50';
	parachute_model.angles = self.angles;
	if (getstatf(STAT_PARACHUTE))
	{
		parachute_model.scale += frametime * 10;
	}
	else
	{
		parachute_model.scale -= frametime * 10;
	}
	parachute_model.scale = bound(0, parachute_model.scale, 0.8);
	if (parachute_model.scale > 0)
		addentity(parachute_model);
		
	if (getstatf(STAT_DROWNING))
	{
		drowning_ofs -= frametime * 60;
		self.origin_z += drowning_ofs;
		self.angles_z = sin(drowning_ofs * 0.2) * 5;
	}
	else
	{
		drowning_ofs = 0;
	}
	
	if (getstatf(STAT_ITEMS) & IT_NEEDLE)
	{
		float bone = gettagindex(self, "armhand.R");
		vector org = gettaginfo(self, bone);
		needle_model.angles = vectoangles(v_forward, v_up);
		needle_model.origin = org - v_right * 3.25;
		needle_model.scale = 0.9;
		addentity(needle_model);
	}
	
	float camdist = vlen(campos - (self.origin + '0 0 24'));
	if (camdist < 90)
		self.alpha = bound(0.01, (camdist / 45) - 0.5, 1);
	
	traceline(self.origin, self.origin - '0 0 20000', MOVE_NOMONSTERS, self);
	float shadowdist = trace_endpos_z;
	adddecal("playershadow", trace_endpos, trace_plane_normal, crossproduct(trace_plane_normal, '1 0 0') * 0.03, '1 1 1', 0.15);
	tracebox(self.origin, '-8 -8 0', '8 8 16', self.origin - '0 0 20000', MOVE_NOMONSTERS, self);
	if (fabs(trace_endpos_z - shadowdist) > 0.1)
		adddecal("playershadow", trace_endpos, trace_plane_normal, crossproduct(trace_plane_normal, '1 0 0') * 0.03, '1 1 1', 0.15);
	return 1;
}

vector hookpos;
float(float isnew) hook_listen =
{
	makevectors(self.angles);
	hookpos = self.origin - v_forward * 20;
	
	hook_time = 1;

	return 1;
}

.float coin_flash_time;
float(float isnew) coin_listen =
{
	if (isnew) self.coin_flash_time = time + random() * 2;
	
	if (!localplayer) return 1;
	
	vector dir = self.origin - localplayer.origin;
	float dist = vlen(dir);
	
	if (time > self.coin_flash_time)
	{
		
		pointparticles(PART_COINFLASH, self.origin + '0 0 28' + randomvec() * 5 + normalize(campos - self.origin) * 20, '0 0 1');
		self.coin_flash_time = time + 1 + random() * 2;
	}
	
	self.angles_y = anglemod(time * 360 * 1.1);
	self.origin_z += sin(time * 2.5) * 7;
	
	if (dist < closest_coin)
		closest_coin = dist;
		
	return 1;
}

entity sky;
entity watersurf;
vector sun_dir;
noref void(float apiver, string enginename, float enginever) CSQC_Init =
{
	precache_everything();
	
	sky = spawn();
	setmodel(sky, "models/sky.iqm");
	sky.scale = 1.25;
	
	watersurf = spawn();
	setmodel(watersurf, "models/watersurf.iqm");
	
	cl_editor_init();
	
	makevectors('60 45 0');
	sun_dir = -v_forward;
	
	deltalisten("models/bowl.iqm", bowl_listen, 0);
	deltalisten("models/sinmyoumaru.iqm", player_listen, 0);
	deltalisten("models/hook.iqm", hook_listen, 0);
	deltalisten("models/coin.iqm", coin_listen, 0);
	
	parachute_model = spawn();
	needle_model = spawn();
	hook_model = spawn();
	ripple_model = spawn();
	setmodel(parachute_model, "models/napkin.iqm");
	setmodel(needle_model, "models/needle.iqm");
	setmodel(hook_model, "models/hook.iqm");
	setmodel(ripple_model, "models/ripple.iqm");
	
	localcmd("fog 0.025 0.55 0.82 1 1 0\n");
};

noref void() CSQC_WorldLoaded =
{
};

noref void(float isnew) CSQC_Ent_Update =
{
	// printf("csqc ent update %f\n", isnew);
};

void() draw_hook =
{
	if (hookpos == '0 0 -999999')
		return;
		
	
	if (hook_time <= 0)
	{
		hook_time = 0;
		return;
	}
	
	vector e = localplayer.origin + '0 0 32';
	vector s = hookpos;

	float len = vlen(e-s);
	
	vector fwd = normalize(e-s);
	vector up = normalize(campos-s);
	vector rgt = normalize(crossproduct(fwd, up));
	
	if (hook_time < 0.90 && vlen(e-s) > 42)
	{
		hook_model.origin = s * hook_time + e * (1 - hook_time);
		hook_model.angles = vectoangles(fwd);
		addentity(hook_model);
		s = hook_model.origin;
	}
		
	hook_time -= frametime * 10;
	
	float w = 1.25;
	R_BeginPolygon("rope_ribbon", 0, 0);
	
	R_PolygonVertex(s + rgt * w, [1, 0], '1 1 1', 1);
	R_PolygonVertex(s - rgt * w, [0, 0], '1 1 1', 1);
	R_PolygonVertex(e - rgt * w, [0, len*0.05], '1 1 1', 1);
	R_PolygonVertex(e + rgt * w, [1, len*0.05], '1 1 1', 1);
	
	R_EndPolygon();
};

// CALLED EVERY CLIENT RENDER FRAME
void(float width, float height, float menushown) CSQC_UpdateView =
{
	//clear and update our global screen resolution vars
	clearscene();
	g_width = width;
	g_height = height;
	
	
	//disable quake status bar and quake crosshair
	setproperty(VF_DRAWENGINESBAR, 0);	
	setproperty(VF_DRAWCROSSHAIR, 0);

	campos = getproperty(VF_ORIGIN);
	camang = getproperty(VF_ANGLES);
	
	if (campos_z < 4 && campos_z > -64) campos_z = 4;
	
	sky.origin = [campos_x, campos_y, 0];
	addentity(sky);
	
	setproperty(VF_ANGLES, camang);
	setproperty(VF_ORIGIN, campos);
	
	// Set before calling addentities which calls deltalistens
	closest_coin = 35000;
	
	//autoadd entities received from servers for drawing
	addentities(MASK_ENGINE);
	
	draw_hook();
	
	/*
	R_BeginPolygon("watersurf", 0, 0);
	
	float fac = 10;
	R_PolygonVertex(fac*[4096, 4096, 0] + '0 0 5', fac*[0, 0], '1 1 1', 1);
	R_PolygonVertex(fac*[4096, -4096, 0] + '0 0 5', fac*[10, 0], '1 1 1', 1);
	R_PolygonVertex(fac*[-4096, -4096, 0] + '0 0 5', fac*[10, 10], '1 1 1', 1);
	R_PolygonVertex(fac*[-4096, 4096, 0] + '0 0 5', fac*[0, 10], '1 1 1', 1);
	
	R_EndPolygon();
	*/
	
	watersurf.origin_z = 3 + campos_z * 0.005;
	watersurf.scale = 16;
	addentity(watersurf);
	
	//does what you think it does
	renderscene();
	
	makevectors(camang);
	float sunstrength = max(0, (v_forward * sun_dir - 0.65));
	sunstrength += bound(0, (-camang_x + 25) * 0.005, 0.25);
	sunstrength = bound(0, sunstrength, 1.2);
	
	vector sun_screen_pos = project(sky.origin + sun_dir * -1000000);
	if (sun_screen_pos_z > 0) sun_screen_pos_y = -90000;
	if (sun_screen_pos_y < 0) sun_screen_pos_y = 0;
	if (sun_screen_pos_y > g_height) sun_screen_pos = 0;
	
	float top = sun_screen_pos_y - g_height * 1.5;
	float bot = sun_screen_pos_y + g_height * 1.5;
	
	R_BeginPolygon("ss_sun", 0, 1);
	vector col = '0.8 0.6 0.4' * sunstrength;
	R_PolygonVertex([0, top, 0], [0, 0], '0 0 0', 1);
	R_PolygonVertex([g_width, top, 0], [0, 0], '0 0 0', 1);
	R_PolygonVertex([g_width, sun_screen_pos_y, 0], [0, 0], col, 1);
	R_PolygonVertex([0, sun_screen_pos_y, 0], [0, 0], col, 1);
	
	R_EndPolygon();
	
	R_PolygonVertex([0, sun_screen_pos_y, 0], [0, 0], col, 1);
	R_PolygonVertex([g_width, sun_screen_pos_y, 0], [0, 0], col, 1);
	R_PolygonVertex([g_width, bot, 0], [0, 0], '0 0 0', 1);
	R_PolygonVertex([0, bot, 0], [0, 0], '0 0 0', 1);
	
	R_EndPolygon();
	
	draw_hud();
	
	sui_begin(g_width, g_height);
	
	cl_editor_draw();
	
	sui_end();
};

float(string cmd) CSQC_ConsoleCommand =
{
	if (cl_editor_command(cmd)) return TRUE;
	
	tokenize(cmd);
	switch(argv(0))
	{
		default:
			return FALSE;
	}
	return TRUE;
};

float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent =
{
	sui_input_event(evtype, scanx, chary, devid);
	
	switch(evtype)
	{
	case IE_KEYDOWN:
		if (scanx == K_LALT || scanx == K_RALT)
			alt_held = TRUE;
		if (scanx == K_LCTRL || scanx == K_RCTRL)
			ctrl_held = TRUE;
		if (scanx == K_LSHIFT || scanx == K_RSHIFT)
			shift_held = TRUE;
		break;
	case IE_KEYUP:
		if (scanx == K_LALT || scanx == K_RALT)
			alt_held = FALSE;
		if (scanx == K_LCTRL || scanx == K_RCTRL)
			ctrl_held = FALSE;
		if (scanx == K_LSHIFT || scanx == K_RSHIFT)
			shift_held = FALSE;
		break;
	case IE_MOUSEDELTA:
		break;
	case IE_MOUSEABS:
		cursor_pos_x = scanx;
		cursor_pos_y = chary;
		break;
	}
	
	if (cl_editor_input_event(evtype, scanx, chary, devid))
		return TRUE;
		
	return FALSE;
};

void() CSQC_Parse_Event =
{
	float first = readbyte();
	switch(first) {
		case EV_ED_UPDATE:
			cl_editor_update_selection();
			break;
		case EV_ISLAND:
			float amount = readbyte();
			for (int i = 0; i < amount; i++) addisland(readvector());
			break;
		case EV_DROWN:
			fadetime = 1;
			break;
		case EV_TELEPORT:
			fadetime = 1;
			break;
		case EV_ITEMHELP:
			helptime = time + 5;
			helpitem = readbyte();
			break;
		default:
			printf("No action for byte %f\n", first);
			break;
	}
};


float(string key, string val) find_player_id =
{
	for (int currentindex = 0; currentindex < maxclients; currentindex++)
	{
		if (getplayerkeyvalue(currentindex, key) == val) return currentindex;
	}
	return -1;
}

void(string printmsg, float printlvl) CSQC_Parse_Print =
{
	print(printmsg);
};
