aparticle
{
	{
		map particles/puff.tga
		alphagen vertex
		rgbGen vertex
		alphafunc GE128
		blendFunc GL_ONE GL_ONE
	}
}

aring
{
	{
		map particles/ring.tga
		alphagen vertex
		rgbGen vertex
		alphafunc GE128
		blendFunc GL_ONE GL_ONE
	}
}

adot
{
	{
		map particles/dot.tga
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

sky
{
	{
		map models/sky.png
	}
}

sun
{
	{ 
		map models/sun.png
		blendFunc GL_ONE GL_ONE
		rgbGen const 0.5 0.5 0.5
		tcMod rotate -4
	}
	{ 
		map models/sun.png
		blendFunc GL_ONE GL_ONE
		rgbGen const 0.5 0.5 0.5	
		tcMod rotate 9
	}
}

ss_sun
{
	{
		map $white
		blendFunc GL_ONE GL_ONE
		rgbGen vertex
	}
}

cloud1
{
	{
		map models/cloud1.png
		blendFunc GL_ONE GL_ONE
		tcMod scroll 0.01 0
		rgbGen const 0.8 0.8 0.8
	}
	{
		map models/cloud1.png
		blendFunc GL_ONE GL_ONE
		tcMod scroll -0.008 0
		tcMod scale 3 1
		rgbGen const 0.3 0.3 0.3
	}
}

cloud2
{
	{
		map models/cloud2.png
		blendFunc GL_ONE GL_ONE
		tcMod scroll 0.04 0.03
		rgbGen vertex
	}
	{
		map models/cloud2.png
		blendFunc GL_ONE GL_ONE
		tcMod scroll 0.03 0.04
		tcMod scale 0.5 0.5
		rgbGen vertex
	}
}

water
{
	{
		map $white
		rgbGen vertex
	}
}

watersurf
{
	sort 6
	{
		map models/water.png
		blendFunc GL_ONE GL_ONE
		rgbGen const 0.2 0.4 0.4
		tcMod scroll 0.03 0.04
	}
	{
		map models/water.png
		blendFunc GL_ONE GL_ONE
		rgbGen const 0.3 0.3 0.4
		tcMod scroll -0.03 0.04
		tcMod scale 1.5 1.5
	}
	{
		map models/water.png
		blendFunc GL_ONE GL_ONE
		rgbGen const 0.4 0.4 0.6
		tcMod scroll -0.01 -0.02
		tcMod scale 1.25 1.25
	}
}

sinmyoumaru
{
	program fb
	{
		map models/sinmyoumaru
	}
}

bowl
{
	program fb
	{
		map models/bowl
	}
}

coin
{
	program fb
	{
		map models/coin
	}
}

bullet1
{
	program fb
	{
		map models/bullet1
	}
}

sky1
{
	surfaceparm nodraw
}

needle
{
	program fb
	{
		map models/needle
	}
}

napkin
{
	program fb
	{
		map models/napkin
	}
}

rope
{
	program fb
	{
		map models/rope
	}
}

rope_ribbon
{
	{
		map textures/rope_ribbon.tga
	}
}

ripple
{
	{
		map models/ripple.png
		blendFunc GL_ONE GL_ONE
		tcMod scroll 0 0.5
		rgbGen vertex
	}
}

defaultskin
{
	program defaultskin2
	{
		map $diffuse
	}
}

playershadow
{
	polygonOffset 1
	discrete
	sort unlitdecal
	noShadows
	{
		map textures/playershadow
		blendFunc blend
		alphaGen vertex	
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
