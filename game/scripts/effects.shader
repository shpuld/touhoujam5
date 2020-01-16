aparticle
{
	{
		map $nearest:particles/ccloud.tga
		alphagen vertex
		rgbGen vertex
		alphafunc GE128
		blendFunc GL_ONE GL_ONE
	}
}

adot
{
	{
		map $nearest:particles/dot.tga
		alphagen vertex
		rgbGen vertex
		alphafunc GE128
	}
}

dotdecal
{
    sort 6
    polygonOffset
    {
		map $nearest:particles/dot.tga
		alphagen vertex
		rgbGen vertex
		alphafunc GE128
	}
}


menu/cursor
{
	{
		map gfx/xhair
	}
}

rocket
{
    {
        map $nearest:models/rocket.png
    }
}

spark
{
    {
        map $nearest:models/spark.png
    }
}

exploring
{
    {
        map $nearest:models/exploring.png
    }
}

hitring
{
	{
        map models/hitring.png
    }
}
