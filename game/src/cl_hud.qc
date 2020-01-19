// Empty

void(vector ch_size, float ch_gap, vector col, float a) draw_crosshair =
{
	drawfill([g_width/2 - ch_size_x - ch_gap, g_height/2 - ch_size_y/2], ch_size, col, a, 0); 
	drawfill([g_width/2 + ch_gap, g_height/2 - ch_size_y/2], ch_size, col, a, 0); 
	drawfill([g_width/2 - ch_size_y/2, g_height/2 - ch_size_x - ch_gap], [ch_size_y, ch_size_x], col, a, 0); 
	drawfill([g_width/2 - ch_size_y/2, g_height/2 + ch_gap], [ch_size_y, ch_size_x], col, a, 0); 
}

void() draw_hud =
{
	float hp = getstatf(STAT_HEALTH);
	string hpstr = sprintf("HP%.0f", hp);
	vector size = '16 16 0';
	drawstring([g_width - size_x * strlen(hpstr), 0], hpstr, size, '1 1 1', 1, 0);
	
	draw_crosshair([8, 2], 4, '0 0 0', 0.25);
	draw_crosshair([6, 2], 5, '1 1 1', 0.6);
}