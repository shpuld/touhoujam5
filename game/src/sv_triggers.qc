
/*
void() trigger_example =
{
	setmodel(self, self.model);
	self.modelindex = 0;
	self.solid = SOLID_TRIGGER;
	self.touch = something;
};
*/

void() func_illusionary =
{
	setmodel(self, self.model);
	self.solid = SOLID_NOT;
};

void() item_touch =
{
	if (other.classname == "player")
	{
		msg_entity = other;
		BeginEvent(EV_ITEMHELP);
		MulticastByte(self.items);
		multicast('0 0 0', MULTICAST_ONE_R);
		
		pointparticles(PART_PICKUP, self.origin + '0 0 16', '0 0 1');
		other.items |= self.items;
		fake_remove(self);
		sound(other, CHAN_ITEM, "sounds/coinpickup.wav", 0.7, 1, 0.85);
	}	
}

void() item_parachute =
{
	setmodel(self, "models/napkin.iqm");
	self.scale = 0.35;
	self.modelflags = MF_ROTATE;
	self.touch = item_touch;
	self.items = IT_PARACHUTE;
	self.solid = SOLID_TRIGGER;
	setsize(self, '-16 -16 0', '16 16 32');
}

void() item_needle =
{
	setmodel(self, "models/needle.iqm");
	self.modelflags = MF_ROTATE;
	self.touch = item_touch;
	self.items = IT_NEEDLE;
	self.solid = SOLID_TRIGGER;
	self.scale = 1.5;
	self.angles_x = 45;
	setsize(self, '-16 -16 0', '16 16 32');
}

void() item_rope =
{
	setmodel(self, "models/rope.iqm");
	self.modelflags = MF_ROTATE;
	self.touch = item_touch;
	self.items = IT_ROPE;
	self.solid = SOLID_TRIGGER;
	self.scale = 1.2;
	setsize(self, '-16 -16 0', '16 16 32');
}

void() coin_touch =
{
	if (other.classname != "player") return;
	pointparticles(PART_PICKUP, self.origin + '0 0 16', '0 0 1');
	coins++;
	sound(other, CHAN_ITEM, "sounds/coinpickup.wav", 0.6, 1, 125);
	fake_remove(self);
}


void() item_coin =
{
	setmodel(self, "models/coin.iqm");
	self.modelflags = MF_ROTATE;
	self.touch = coin_touch;
	self.solid = SOLID_TRIGGER;
	self.scale = 2.0;
	setsize(self, '-16 -16 0', '16 16 32');
	totalcoins++;
}

void() tele_touch =
{
	if (other.classname != "player") return;
	
	entity tgt = find(world, targetname, self.target);
	if (!tgt) return;
	
	other.angles = tgt.angles;
	other.fixangle = TRUE;
	setorigin(other, tgt.origin);
	other.velocity = '0 0 0';
	other.safe_spot = other.origin;
	if (other.hook) detachhook(other.hook);
	msg_entity = other;
	BeginEvent(EV_TELEPORT);
	multicast('0 0 0', MULTICAST_ONE_R);
}

void() trigger_tele
{
	self.modelindex = 0;
	setsize(self, '-32 -32 0', '32 32 64');
	self.solid = SOLID_TRIGGER;
	
	self.touch = tele_touch;
}

void() trigger_tele_big =
{
	trigger_tele();
	setsize(self, '-64 -64 0', '64 64 128');
}

void() trigger_teleport_br =
{
	trigger_tele();
	setmodel(self, self.model);
	self.modelindex = 0;
};

void() info_null =
{
	self.solid = SOLID_NOT;
	self.modelindex = 0;
}

void() endwarning =
{
	if (other.classname != "player") return;
	
	msg_entity = other;
	BeginEvent(EV_ENDWARNING);
	multicast('0 0 0', MULTICAST_ONE_R);
}

void() trigger_endwarning =
{
	setmodel(self, self.model);
	self.modelindex = 0;
	self.solid = SOLID_TRIGGER;
	
	self.touch = endwarning;
}
