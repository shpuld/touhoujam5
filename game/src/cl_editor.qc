
// CLIENT BLOCK

float grid_size;

float last_scroll_time;

float view_unlocked;

// Call this in CSQC_Init
void() cl_editor_init =
{
	registercommand("toggleeditmode");
	
	grid_size = 16;
}

float selected_entity_index;

string entlist[] = {
	"misc_barrel",
	"misc_box"
};

vector entity_menu_scroll;

void(string id, vector pos, vector size, __inout vector scrollofs) entity_list =
{
	sui_fill(pos, size, '0.2 0.2 0.2', 0.75, 0);
	sui_list_view_begin(strcat(id, "scrl"), pos, size, [size_x - 6, 16], entlist.length, scrollofs, [0, 6]);
	vector listitem_pos = '0 0 0';
	for (float index = sui_list_item(listitem_pos); index > -1; index = sui_list_item(listitem_pos))
	{
		sui_push_frame(listitem_pos, [size_x - 6, 16]);
		string iid = strcat(id, ftos(index));
		sui_action_element([0, 0], [size_x -6, 16], iid, sui_noop);
		if (sui_is_hovered(iid)) sui_fill([0, 0], [size_x - 6, 16], '1 1 1', 0.1, 0);
		if (sui_is_clicked(iid)) selected_entity_index = index;
		sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
		if (selected_entity_index == index)
			sui_fill([0, 0], [size_x - 6, 16], '1 1 1', 0.2, 0);
		sui_text([0, 0], [8, 8], entlist[index], '1 1 1', 1, 0);
		sui_pop_frame();
	}
	sui_list_view_end();	
};

void() cl_editor_draw =
{
	if (!getstatf(STAT_ED_MODE)) return;
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_END]);
	sui_text([0, -8], [16, 16], "EDIT MODE", '1 0.1 0.1', 1, 0);
	sui_text([0, -32], [8, 8], sprintf("Grid size: %d", grid_size), '1 1 1', 1, 0);
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
	sui_fill([0, 0], [4, 4], '0 0 0', 0.5, 0);
	sui_fill([0, 0], [2, 2], '1 1 1', 0.75, 0);
	
	vector ent_menu_size = [120, 200];
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_END]);
	sui_push_frame([0, 0], ent_menu_size);
	
	sui_fill([0, 0], ent_menu_size, '0 0 0', 0.5, 0);
	entity_list("entlist", [0, 0], ent_menu_size - [2, 2], entity_menu_scroll);
	
	sui_pop_frame();

}

// This must be called in CSQC_ConsoleCommand
// input entity self
// input string cmd: same as in CSQC_ConsoleCommand
// output float: TRUE if command was handled, FALSE if not
float(string cmd) cl_editor_command =
{
	float argc = tokenize(cmd);
	switch (argv(0))
	{
	case "toggleeditmode":
		if (getstatf(STAT_ED_MODE)) setcursormode(FALSE);
		else setcursormode(TRUE);
		
		localcmd("cmd toggleeditmode\n");
		return TRUE;
		break;
	default: break;
	}
	return FALSE;
}

float(float evtype, float scanx, float chary, float devid) cl_editor_input_event =
{
	if (!getstatf(STAT_ED_MODE)) return FALSE;
	
	switch(evtype)
	{
	case IE_KEYDOWN:
		if (chr2str(chary) == "n") {
			localcmd(sprintf("cmd edit_add %s\n", entlist[selected_entity_index]));
		}
		if (scanx == K_MOUSE1) { 
			if (!getcursormode(TRUE))
				localcmd("cmd edit_select\n");
			return TRUE;
		}
		if (scanx == K_UPARROW) { localcmd("cmd edit_move 0\n"); return TRUE; }
		if (scanx == K_DOWNARROW) { localcmd("cmd edit_move 1\n"); return TRUE; }
		if (scanx == K_LEFTARROW)
		{
			if (ctrl_held && shift_held)
				localcmd("cmd edit_rotate 15\n");
			else if (shift_held)
				localcmd("cmd edit_rotate 45\n");
			else
				localcmd("cmd edit_move 2\n");
			return TRUE;
		}
		if (scanx == K_RIGHTARROW)
		{
			if (ctrl_held && shift_held)
				localcmd("cmd edit_rotate -15\n");
			else if (shift_held)
				localcmd("cmd edit_rotate -45\n");
			else
				localcmd("cmd edit_move 3\n");
			return TRUE;
		}
		if (scanx == K_PGUP) { localcmd("cmd edit_move 4\n"); return TRUE; }
		if (scanx == K_PGDN) { localcmd("cmd edit_move 5\n"); return TRUE; }
		if (scanx == K_DEL) { localcmd("cmd edit_delete\n"); return TRUE; }
		
		if (scanx == K_MOUSE2) { setcursormode(FALSE); return TRUE; }
		break;
	case IE_KEYUP:
		if (scanx == K_MWHEELUP) 
		{
			if (time - last_scroll_time < 0.1) return FALSE;
			grid_size *= 2;
			grid_size = min(256, grid_size);
			localcmd(sprintf("cmd edit_grid %f\n", grid_size));
			last_scroll_time = time;
			return TRUE;
		}
		if (scanx == K_MWHEELDOWN) 
		{
			if (time - last_scroll_time < 0.1) return FALSE;
			grid_size *= 0.5;
			grid_size = max(1, grid_size);
			localcmd(sprintf("cmd edit_grid %f\n", grid_size));
			last_scroll_time = time;
			return TRUE;
		}
		
		if (scanx == K_MOUSE2) { setcursormode(TRUE); return TRUE; }
		break;
	case IE_MOUSEDELTA:
		break;
	case IE_MOUSEABS:
		break;
	}
	
	return FALSE;
}
