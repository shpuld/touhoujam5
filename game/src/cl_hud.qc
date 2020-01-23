// Empty

float fadetime;

void() draw_fade =
{
	fadetime -= frametime * 2.5;
	float a = bound(0, fadetime, 1);
	if (a > 0)
		drawfill([0, 0], [g_width, g_height], '0 0 0', a);
}

void(vector ch_size, float ch_gap, vector col, float a) draw_crosshair =
{
	drawfill([g_width/2 - ch_size_x - ch_gap, g_height/2 - ch_size_y/2], ch_size, col, a, 0); 
	drawfill([g_width/2 + ch_gap, g_height/2 - ch_size_y/2], ch_size, col, a, 0); 
	drawfill([g_width/2 - ch_size_y/2, g_height/2 - ch_size_x - ch_gap], [ch_size_y, ch_size_x], col, a, 0); 
	drawfill([g_width/2 - ch_size_y/2, g_height/2 + ch_gap], [ch_size_y, ch_size_x], col, a, 0); 
}

vector islands[10];
float numislands;

void(vector isl) addisland =
{
	islands[numislands] = isl;
	numislands++;
}

void() draw_map =
{
	vector size = [100, 100];
	drawpic([0, g_height - size_y], "textures/mapbg", size, '1 1 1', 0.85, 0);
	
	vector isize = [10, 10];
	vector extents = [32678, 32678];
	vector ofs = [0, -8];
	vector sspos;
	vector playerpos = [campos_x/extents_x * size_x + size_x/2, size_y - (campos_y/extents_y * size_y + size_y/2) + ofs_y];
	
	for (int i = 0; i < numislands; i++)
	{
		sspos_x = islands[i][0]/extents_x * size_x + size_x/2 + ofs_x;
		sspos_y = size_y - (islands[i][1]/extents_y * size_y + size_y/2) + ofs_y;
		drawpic([sspos_x - isize_x/2, g_height - size_y + sspos_y - isize_y/2], "textures/islandx", isize, '0.2 0.1 0.1', 0.7, 0);
	}
	vector psize = [4, 4];
	drawrotpic([playerpos_x, g_height - size_y + playerpos_y], '-6 -6 0', '6 6 0', "textures/plarrow", '1 1 1', 0.7, -camang_y + 90);
	// drawfill(playerpos - psize/2 + [0, g_height - size_y], psize, '0.6 0.2 0.1', 1, 0); 
}

float helptime;
float helpitem;
void() draw_item_help =
{
	float a = min(1, helptime - time);
	if (a <= 0) return;
	
	string name = "";
	string desc = "";
	
	switch (helpitem)
	{
		case IT_NEEDLE: name = "A Needle!"; desc = "You could use it like a sword..."; break;
		case IT_PARACHUTE: name = "A Napkin!"; desc = "Works as a parachute for a tiny creature..."; break;
		case IT_ROPE: name = "A Thread!"; desc = "Combined with a needle it's a grappling hook..."; break;
		default: name = "A Strange Item"; desc = "I... I... I..."; break;
	}
	
	float ypos = 50;
	
	string str = "You found...";
	vector size = '16 16 0';
	drawstring([g_width/2 - strlen(str)*size_x*0.5, ypos], str, size, '1 1 1', a, 0);
	ypos += 16 + 8;
	
	size = '32 32 0';
	drawstring([g_width/2 - strlen(name)*size_x*0.5, ypos], name, size, '1 1 1', a, 0);
	ypos += 32 + 8;
	
	size = '8 8 0';
	drawstring([g_width/2 - strlen(desc)*size_x*0.5, ypos], desc, size, '1 1 1', a, 0);
}

float next_blip;
float finish_time;
float time_ofs;
void() draw_hud =
{
	draw_fade();
	
	if (!cvar("cl_hud")) return;
	
	float hp = getstatf(STAT_HEALTH);
	string hpstr = sprintf("%.0f/3", hp);
	vector size = '16 16 0';
	float danger = hp <= 1 ? min(1, fabs(sin(time*4)) + 0.2) : 1;
	drawpic([4, g_height - 100 - 16 - 16], "textures/heart", size, [1, 0.7*danger, 0.9*danger], 1, 0);
	drawstring([4 + 16 + 4, g_height - 100 - 16 - 16], hpstr, size, [1, danger, danger], 1, 0);
	
	draw_crosshair([4, 2], 3, '0 0 0', 0.2);
	draw_crosshair([3, 2], 4, '1 1 1', 0.5);
	
	draw_map();
	draw_item_help();
	
	float coins = getstatf(STAT_COINS);
	float totalcoins = getstatf(STAT_TOTALCOINS);
	string coinstring = sprintf("%.0f/%.0f", coins, totalcoins);

	float coinflash = 0;
	if (closest_coin < 3000)
	{
		coinflash = next_blip <= 0.2 ? next_blip * 5 : 0;
		next_blip -= frametime;
	}
	if (next_blip <= 0)
	{
		next_blip = 
			closest_coin < 500 ? 0.2 :
			closest_coin < 1000 ? 0.4 :
			closest_coin < 2000 ? 0.8 :
			closest_coin < 3000 ? 1.6 : 0.2;
	}
		
	
	drawpic([4, g_height - 100 - 16], "textures/coin", size, '1 1 1', 1, 0);
	drawpic([4 - 2, g_height - 100 - 16 - 2], "textures/coin", size + [4, 4], '1 1 1' * coinflash * 0.75, 1, 1);
	drawstring([4 + 16 + 4, g_height - 100 - 16], coinstring, size, '1 1 1', 1, 0);
	
	if (coins == totalcoins)
	{
		if (!finish_time) finish_time = time - time_ofs;
		
		string s1 = "Congratulations!";
		string s2 = "You get the Miracle Mallet now!";
		string s3 = "Except we ran out of time to add it...";
		string s4 = "Thank you for playing!";
		
		drawstring([g_width/2 - strlen(s1)*4, g_height/2 - 32], s1, [8, 8], '1 1 1', 1, 0);
		drawstring([g_width/2 - strlen(s2)*4, g_height/2 - 24], s2, [8, 8], '1 1 1', 1, 0);
		drawstring([g_width/2 - strlen(s3)*4, g_height/2 - 16], s3, [8, 8], '1 1 1', 1, 0);
		drawstring([g_width/2 - strlen(s4)*4, g_height/2 + 8], s4, [8, 8], '1 1 1', 1, 0);
	}
	
	if (cvar("cl_hud_timer"))
	{
		string timestr = sprintf("%.3f", time - time_ofs);
		drawstring([g_width - 16 * strlen(timestr), 0], timestr, [16, 16], '1 1 1', 1, 0);
		if (finish_time)
		{
			timestr = sprintf("%.3f", finish_time);
			drawstring([g_width - 16 * strlen(timestr), 16], timestr, [16, 16], '0.5 1 0.1', 1, 0);
		}
	}
}