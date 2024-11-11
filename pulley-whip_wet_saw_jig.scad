include <../OpenSCADdesigns/MakeInclude.scad>

pulleyWhipOD = 22;

sawBladeHeight = 7/7 * 25.4;

jigFenceEndX = 100;
jigFenceEndWallY = 6;

jigHandEndX = 100;

// jigFenceToBladeMinY = 50;
// jigFenceToBladeMaxY = 100;
// jigFenceToBladeCtrY = (jigFenceToBladeMinY + jigFenceToBladeMaxY)/2;


jigFenceToBladeCtrY = 50; //(jigFenceToBladeMinY + jigFenceToBladeMaxY)/2;
// jigFenceToBladeMinY = 50;
// jigFenceToBladeMaxY = 100;

jigBladeTohandEndY = 100;

jigZ = pulleyWhipOD + 15;

jigPullyWhipCtrZ = pulleyWhipOD/2;

jigCornerRadiusFenceEnd = 8;
jigCornerRadiusHandEnd = 20;

module itemModule()
{
	difference()
	{
		body();

		pulleyWhip();
		
	}
}

module body()
{
	difference()
	{
		hull()
		{
			// Fence End:
			fenceEndOffsetX = jigFenceEndX/2 - jigCornerRadiusFenceEnd;
			jigFenceEndOffsetY = jigFenceToBladeCtrY; // - jigCornerRadiusFenceEnd; // + jigCornerRadiusFenceEnd;
			doubleX() translate([fenceEndOffsetX, jigFenceEndOffsetY, 0]) cylinder(r=jigCornerRadiusFenceEnd, h=jigZ);
		}

		tcu([-200, jigFenceToBladeCtrY, -200], 400);
	}
}

module pulleyWhip()
{
	translate([0, jigFenceToBladeCtrY-jigFenceEndWallY, jigPullyWhipCtrZ]) rotate([90,0,0]) difference()
	{
		xb = 6;
		yb = 10;

		xt = 4;
		yt = 10;

		z = 200;
		hull()
		{
			cylinder(d=pulleyWhipOD, h=z);

			// Top:
			tcu([-xt/2, pulleyWhipOD/2-yt+2, 0], [xt,yt,z]);
			
			// Bottom cutout:
			tcu([-xb/2, -pulleyWhipOD/2-2, 0], [xb,yb,z]);
		}
	}
}

module clip(d=0)
{
	// tcu([-d, -200, -200], 400);
}

if(developmentRender)
{
	display() itemModule();
	displayGhost() sawGhost();
	// displayGhost() pulleyWhipGhost();
}
else
{
	itemModule();
}

module sawGhost()
{
	bladeDia = 4.5 * 25.4;
	bladeThickness = 1;
	bladeCtrOffsetZ = -bladeDia/2 + 22;
	translate([0, bladeThickness/2, bladeCtrOffsetZ]) rotate([90,0,0]) difference()
	{
		cylinder(d=bladeDia, h=bladeThickness);
		tcy([0, 0, -5], d=5/8*25.4, h=10);
	}
}

module pulleyWhipGhost()
{
	pwd = 22;
	translate([0, jigFenceToBladeCtrY, pwd/2]) rotate([90,0,0]) cylinder(d=pwd, h=200);
}
