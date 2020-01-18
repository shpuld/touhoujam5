
void() CSQC_Ent_Remove =
{
	remove(self);
};

void() CSQC_Shutdown =
{
};

float(float isnew) bowl_listen =
{
	self.angles += [sin(time)*2, 0, cos(1.1*time+0.5)*1.8];
	return 1; 
}

float(float isnew) player_listen =
{
	if (self.entnum == player_localentnum) localplayer = self;
	
	return 1;
}

vector hookpos;
float(float isnew) hook_listen =
{
	makevectors(self.angles);
	hookpos = self.origin - v_forward * 20;

	return 1;
}

entity sky;
vector sun_dir;
noref void(float apiver, string enginename, float enginever) CSQC_Init =
{
	precache_everything();
	
	sky = spawn();
	setmodel(sky, "models/sky.iqm");
	
	cl_editor_init();
	
	makevectors('60 45 0');
	sun_dir = -v_forward;
	
	deltalisten("models/bowl.iqm", bowl_listen, 0);
	deltalisten("models/testplayer.iqm", player_listen, 0);
	deltalisten("models/hook.iqm", hook_listen, 0);
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
		
	vector e = localplayer.origin + '0 0 24';
	vector s = hookpos;
	
	float len = vlen(e-s);
	
	vector fwd = normalize(e-s);
	vector up = normalize(campos-s);
	vector rgt = normalize(crossproduct(fwd, up));
	
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
	
	sky.origin = [campos_x, campos_y, 0];
	addentity(sky);
	
	setproperty(VF_ANGLES, camang);
	
	//autoadd entities received from servers for drawing
	
	// hack:
	hookpos = '0 0 -999999';
	addentities(MASK_ENGINE);
	
	draw_hook();
	
	R_BeginPolygon("watersurf", 0, 0);
	
	float fac = 10;
	R_PolygonVertex(fac*[4096, 4096, 0] + '0 0 3', fac*[0, 0], '1 1 1', 1);
	R_PolygonVertex(fac*[4096, -4096, 0] + '0 0 3', fac*[10, 0], '1 1 1', 1);
	R_PolygonVertex(fac*[-4096, -4096, 0] + '0 0 3', fac*[10, 10], '1 1 1', 1);
	R_PolygonVertex(fac*[-4096, 4096, 0] + '0 0 3', fac*[0, 10], '1 1 1', 1);
	
	R_EndPolygon();
	
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
