// Empty

void() draw_hud =
{
	float hp = getstatf(STAT_HEALTH);
	string hpstr = sprintf("HP%.0f", hp);
	vector size = '16 16 0';
	drawstring([g_width - size_x * strlen(hpstr), 0], hpstr, size, '1 1 1', 1, 0);
}