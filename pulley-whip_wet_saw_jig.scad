include <../OpenSCADdesigns/MakeInclude.scad>

pulleyWhipOD = 22;

sawBladeHeight = 7/8 * 25.4;
echo("sawBladeHeight = ", sawBladeHeight);

jigFenceEndX = 100;
jigFenceEndWallY = 6;

jigFenceToBladeCtrY = 50;
bladeCutoutY = 60;

jigBladeTohandEndY = 100;

jigZ = pulleyWhipOD + 15;

jigPullyWhipCtrZ = pulleyWhipOD/2;

jigCornerRadiusFenceEnd = 5;
jigCornerRadiusHandEnd = 20;

jigHandEndX = pulleyWhipOD + jigCornerRadiusHandEnd;

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
			// Fence end:
			fenceEndOffsetX = jigFenceEndX/2 - jigCornerRadiusFenceEnd;
			jigFenceEndOffsetY = jigFenceToBladeCtrY;
			doubleX() translate([fenceEndOffsetX, jigFenceEndOffsetY-jigCornerRadiusFenceEnd, 0]) cylinder(r=jigCornerRadiusFenceEnd, h=jigZ);

			// Hand end:
			handEndOffsetX = jigHandEndX/2 - jigCornerRadiusFenceEnd;
			jighandEndOffsetY = -jigBladeTohandEndY;
			doubleX() translate([handEndOffsetX, jighandEndOffsetY, 0]) cylinder(r=jigCornerRadiusHandEnd, h=jigZ);
		}

		// Remove the blade cutout:
		tcu([-200, -bladeCutoutY/2, -10], [400, bladeCutoutY, sawBladeHeight+10 + 1]);

		// Trim the fence end:
		// tcu([-200, jigFenceToBladeCtrY, -200], 400);
	}
}

module pulleyWhip()
{
	translate([0, jigFenceToBladeCtrY-jigFenceEndWallY, jigPullyWhipCtrZ]) rotate([90,0,0]) 
	{
		xb = 5.5;
		yb = 10;

		z = 200;
		hull()
		{
			cylinder(d=pulleyWhipOD, h=z);
			
			// Bottom cutout 1:
			// (sets the overhang angle)
			tcu([-xb/2, -pulleyWhipOD/2-2, 0], [xb,yb,z]);
		}

		// Bottom cutout 2:
		// (trim off the sharp corners)
		dx = 6;
		tcu([-xb/2-dx/2, -pulleyWhipOD/2-2, 0], [xb+dx,yb,z]);
	}
}

module clip(d=0)
{
	// Trim +X:
	// tcu([-d, -200, -200], 400);

	// Trim -Y:
	// tcu([-200, -400+d, -200], 400);

	// Trim -Y no ghost offset:
	// tcu([-200, -400, -200], 400);
}

if(developmentRender)
{
	// display() itemModule();
	// displayGhost() sawGhost();
	// displayGhost() pulleyWhipGhost();

	translate([0,0,jigZ]) rotate([0,180,0]) display() itemModule();
	displayGhost() printBedGhost();
}
else
{
	rotate([0,180,0]) itemModule();
}

module sawGhost()
{
	bladeDia = 4.5 * 25.4;
	bladeThickness = 1;
	bladeCtrOffsetZ = -bladeDia/2 + sawBladeHeight;
	translate([0, bladeThickness/2, bladeCtrOffsetZ]) rotate([90,0,0]) difference()
	{
		cylinder(d=bladeDia, h=bladeThickness);
		tcy([0, 0, -5], d=5/8*25.4, h=10);
	}
}

module pulleyWhipGhost()
{
	pwd = 22;
	translate([0, jigFenceToBladeCtrY-jigFenceEndWallY, pwd/2]) rotate([90,0,0]) cylinder(d=pwd, h=250);
}

module printBedGhost()
{
	// Bambu A1:
	x = 256;
	y = 256;

	z = 3;

	tcu([-x/2,-y/2-30,-z], [x,y,z]);
}
