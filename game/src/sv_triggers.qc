
/*
void() trigger_example =
{
	setmodel(self, self.model);
	self.modelindex = 0;
	self.solid = SOLID_TRIGGER;
	self.touch = something;
};
*/

void() info_null =
{
};

void() func_illusionary =
{
	setmodel(self, self.model);
	self.solid = SOLID_NOT;
};

void() item_touch =
{
	if (other.classname == "player")
	{
		other.items |= self.items;
		fake_remove(self);
	}
}

void() item_parachute =
{
	setmodel(self, "models/barrel.iqm");
	self.scale = 0.5;
	self.modelflags = MF_ROTATE;
	self.touch = item_touch;
	self.items = IT_PARACHUTE;
	self.solid = SOLID_TRIGGER;
	setsize(self, '-16 -16 0', '16 16 32');
	
}