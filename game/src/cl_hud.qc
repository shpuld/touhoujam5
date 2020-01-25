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

float endwarningtime;
void() draw_end_warning =
{
	float a = min(1, endwarningtime - time);
	if (a <= 0) return;
	
	string s1 = "Warning, once you enter the mountain";
	string s2 = "there is no coming back anymore.";
	
	string s3 = "Make sure you've done everything you want to!";
	
	vector size = [8, 8];
	
	drawstring([g_width/2 - strlen(s1)*4, g_height/2 - 64], s1, size, '1 1 1', a, 0);
	drawstring([g_width/2 - strlen(s2)*4, g_height/2 - 56], s2, size, '1 1 1', a, 0);
	drawstring([g_width/2 - strlen(s3)*4, g_height/2 - 42], s3, size, '1 1 1', a, 0);
}

void() draw_gameover =
{
	if (gameovertime <= 0) return;
	
	float timesince = time - gameovertime;
	
	string str = "Game Over";
	float size = 32;
	float a = min(1, timesince);
	
	drawfill([0, 0], [g_width, g_height], '0 0 0', a * 0.75, 0);
	
	drawstring([g_width/2 - strlen(str)*size*0.5, g_height/2 - size*0.5] + [sin(time), cos(time)]*5, str, [size, size], '0 0 0', a*0.5, 0);
	drawstring([g_width/2 - strlen(str)*size*0.5, g_height/2 - size*0.5] + [sin(time + 1), cos(time + 1)]*5, str, [size, size], '1 0.2 0.1', a, 0);
	
	string s1 = "Press ESCAPE to open the menu";
	drawstring([g_width/2 - strlen(s1)*4, g_height/2 + 64], s1, [8, 8], '1 1 1', a, 0);
}

float finish_time;
float time_ofs;

void() draw_win =
{
	if (wintime <= 0) return;
	
	if (!finish_time) finish_time = time - time_ofs;
	
	float timesince = time - wintime;
	float a = min(1, timesince);
	vector bgcol = cheats_used ? '0.8 0.1 0.4' : '0 0 0';
	drawfill([0, 0], [g_width, g_height], bgcol, a * 0.75, 0);

	string str = "Victory";
	float size = 32;
	
	drawstring([g_width/2 - strlen(str)*size*0.5, 48] + [sin(time), cos(time)]*5, str, [size, size], '0 0 0', a*0.5, 0);
	drawstring([g_width/2 - strlen(str)*size*0.5, 48] + [sin(time + 1), cos(time + 1)]*5, str, [size, size], '0.9 0.6 0.2', a, 0);
	
	string s1 = "You have beaten the Oni and";
	string s2 = "obtained the miracle mallet!";
	string s3 = "The adventure was a success!";
	string s4 = "Thank you for playing!";
	
	drawstring([g_width/2 - strlen(s1)*4, 64 + 32], s1, [8, 8], '1 1 1', a, 0);
	drawstring([g_width/2 - strlen(s2)*4, 64 + 32 + 8], s2, [8, 8], '1 1 1', a, 0);
	drawstring([g_width/2 - strlen(s3)*4, 64 + 32 + 24], s3, [8, 8], '1 1 1', a, 0);
	drawstring([g_width/2 - strlen(s4)*4, 64 + 38 + 32], s4, [8, 8], '1 1 1', a, 0);
	
	str = "Playtime";
	float minutes = floor(finish_time / 60);
	float seconds = finish_time - floor(finish_time / 60)*60;
	string playtime = sprintf("%.0f minutes %.2f seconds", minutes, seconds);
	drawstring([g_width/2 - strlen(str)*4, g_height/2 - 12], str, [8, 8], '1 1 1', a, 0);
	drawstring([g_width/2 - strlen(playtime)*4, g_height/2], playtime, [8, 8], '1 1 1', a, 0);
	
	float coins = getstatf(STAT_COINS);
	float totalcoins = getstatf(STAT_TOTALCOINS);
		
	string coinstring = sprintf("Coins collected: %.0f/%.0f", coins, totalcoins);
	
	string rank = coins == 0 ? "Are you the Hakurei shrine maiden??" :
		coins <= 25 ? "You really don't need that money huh?" :
		coins <= 40 ? "A decent collection." :
		coins <= 49 ? "You could afford a luxury bowl!" :
		"100% Perfect!!!";
		
	drawstring([g_width/2 - strlen(coinstring)*4, g_height/2 + 32], coinstring, [8, 8], '1 1 1', a, 0);
	drawstring([g_width/2 - strlen(rank)*4, g_height/2 + 32 + 12], rank, [8, 8], '1 1 1', a, 0);
	
	float kills = getstatf(STAT_KILLEDMONSTERS);
	float totalmonsters = getstatf(STAT_TOTALMONSTERS);
	string killstring = sprintf("Enemies defeated: %.0f/%.0f", kills, totalmonsters);
	
	float percent = kills / totalmonsters;
	
	rank = percent == 0 ? "Pacifist!" :
		percent <= 0.4 ? "Didn't enjoy fighting?" :
		percent <= 0.6 ? "Getting rid of everything in your way." :
		percent < 1.0 ? "No sympathy for the crabs." :
		"Doink!";
	
	drawstring([g_width/2 - strlen(coinstring)*4, g_height/2 + 72], killstring, [8, 8], '1 1 1', a, 0);
	drawstring([g_width/2 - strlen(rank)*4, g_height/2 + 72 + 12], rank, [8, 8], '1 1 1', a, 0);
	
	float misses = getstatf(STAT_MISSES);
	string missstring = sprintf("Misses: %.0f", misses);
	
	rank = misses == 0 ? "No Misses!!!" :
		misses == 1 ? "Impressive!" :
		misses == 2 ? "it's a 1cc!" :
		misses == 3 ? "Almost a 1cc!" :
		misses < 6 ? "Not too bad!" :
		misses < 12 ? "Not afraid of swimming." :
		misses < 20 ? "Tends to miss the boat." :
		misses < 30 ? "Blub." : "Blubblublublubblub...";
		
	drawstring([g_width/2 - strlen(missstring)*4, g_height/2 + 112], missstring, [8, 8], '1 1 1', a, 0);
	drawstring([g_width/2 - strlen(rank)*4, g_height/2 + 112 + 12], rank, [8, 8], '1 1 1', a, 0);
	
	str = "Press F12 to screenshot...";
	drawstring([g_width/2 - strlen(str)*4, g_height - 12], str, [8, 8], '1 1 1', a * 0.75, 0);
}


float next_blip;

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
	draw_end_warning();
	
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
	
	if (cvar("cl_hud_timer"))
	{
		
		float minutes = floor((time - time_ofs) / 60);
		float seconds = (time - time_ofs) - minutes*60;
		string timestr = sprintf("%.0f:%.2f", minutes, seconds);
		
		if (finish_time)
		{
			minutes = floor(finish_time / 60);
			seconds = finish_time - minutes*60;
			timestr = sprintf("%.0f:%.2f", minutes, seconds);
		}
		
		drawstring([g_width - 16 * strlen(timestr), 0], timestr, [16, 16], '1 1 1', 1, 0);
	}
	
	draw_gameover();
	draw_win();
}