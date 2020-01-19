// Empty

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
	drawpic([0, g_height - size_y], "textures/mapbg", size, '1 1 1', 1, 0);
	
	vector isize = [10, 10];
	vector extents = [32678, 32678] ;
	vector sspos;
	vector playerpos = [campos_x/extents_x * size_x + size_x/2, size_y - (campos_y/extents_y * size_y + size_y/2)];
	
	for (int i = 0; i < numislands; i++)
	{
		sspos_x = islands[i][0]/extents_x * size_x + size_x/2;
		sspos_y = size_y - (islands[i][1]/extents_y * size_y + size_y/2);
		drawpic([sspos_x - isize_x/2, g_height - size_y + sspos_y - isize_y/2], "textures/islandx", isize, '0.2 0.1 0.1', 1, 0);
	}
	vector psize = [4, 4];
	drawrotpic([playerpos_x, g_height - size_y + playerpos_y], '-8 -8 0', '8 8 0', "textures/plarrow", '1 1 1', 1, -camang_y + 90);
	// drawfill(playerpos - psize/2 + [0, g_height - size_y], psize, '0.6 0.2 0.1', 1, 0); 
}

void() draw_hud =
{
	float hp = getstatf(STAT_HEALTH);
	string hpstr = sprintf("HP%.0f", hp);
	vector size = '16 16 0';
	drawstring([g_width - size_x * strlen(hpstr), 0], hpstr, size, '1 1 1', 1, 0);
	
	draw_crosshair([8, 2], 4, '0 0 0', 0.25);
	draw_crosshair([6, 2], 5, '1 1 1', 0.6);
	
	draw_map();
	
	float coins = getstatf(STAT_COINS);
	float totalcoins = getstatf(STAT_TOTALCOINS);
	string coinstring = sprintf("%.0f/%.0f Coins", coins, totalcoins);
	drawstring([g_width - size_x * strlen(coinstring), g_height - size_y], coinstring, size, '1 1 1', 1, 0);
	
	if (coins == totalcoins)
	{
		
	}
}