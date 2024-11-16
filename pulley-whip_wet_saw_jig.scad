include <../OpenSCADdesigns/MakeInclude.scad>
include <../OpenSCADdesigns/chamferedCylinders.scad>

makeJig = false;
makeTest = false;

pulleyWhipOD = 22;
pulleyWhipOemLength = 300 + 143;
echo(str("pulleyWhipOemLength = ", pulleyWhipOemLength));

pulleyWhipMinLength = 355; // B.4.6 350mm min. + 55mm extra.

pulleyWhipMaxCutOff = pulleyWhipOemLength - pulleyWhipMinLength;
echo(str("pulleyWhipMaxCutOff = ", pulleyWhipMaxCutOff));

sawBladeHeight = 7/8 * 25.4 + 2;
echo("sawBladeHeight = ", sawBladeHeight);

jigFenceEndX = 120;
jigFenceEndWallY = 6;

jigFenceToBladeCtrY = pulleyWhipMaxCutOff + jigFenceEndWallY;
echo(str("jigFenceToBladeCtrY = ", jigFenceToBladeCtrY));
bladeCutoutY = 10;

jigBladeTohandEndY = 100;

jigZ = pulleyWhipOD + 20;
echo(str("jigZ = ", jigZ));

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
	pulleyWhipLenghts = [pulleyWhipMinLength, 380, 400, 420];
	difference()
	{
		union()
		{
			hull()
			{
				// Fence end:
				fenceEndOffsetX = jigFenceEndX/2 - jigCornerRadiusFenceEnd;
				jigFenceEndOffsetY = jigFenceToBladeCtrY;
				// Middle:
				doubleX() translate([fenceEndOffsetX, -20, 0]) corner(r=jigCornerRadiusFenceEnd);
				// Fence end:
				doubleX() translate([fenceEndOffsetX, jigFenceEndOffsetY-jigCornerRadiusFenceEnd, 0]) corner(r=jigCornerRadiusFenceEnd);

				// Hand end:
				handEndOffsetX = pulleyWhipOD/2 + 4;
				jighandEndOffsetY = -(jigBladeTohandEndY - jigCornerRadiusHandEnd);
				doubleX() translate([handEndOffsetX, jighandEndOffsetY, 0]) corner(r=jigCornerRadiusHandEnd);
			}

			// Blade center marks:
			for(l = pulleyWhipLenghts)
			{
				x = jigFenceEndX + 2;
				y = 1;
				z = 35;
				
				yPos = l - pulleyWhipMinLength;
				hull()
				{
					tcu([-jigFenceEndX/2, yPos-1, 0], [jigFenceEndX, 2, z+2]);
					tcu([-x/2, yPos-0.5, 0], [x, 1, z]);
				}
			}
		}

		// Remove the blade cutouts:
		for(l = pulleyWhipLenghts)
		{
			bladeCutout(pulleyWhipLength = l);
		}
	}
}

module bladeCutout(pulleyWhipLength)
{
	y = pulleyWhipLength - pulleyWhipMinLength;
	tcu([-200, -bladeCutoutY/2 + y, -10], [400, bladeCutoutY, sawBladeHeight+10 + 1]);
}

module corner(r)
{
	simpleChamferedCylinder(d = 2*r, h = jigZ, cz = 4);
}

module pulleyWhip()
{
	translate([0, jigFenceToBladeCtrY-jigFenceEndWallY, jigPullyWhipCtrZ]) rotate([90,0,0]) 
	{
		xb = 5.5;
		yb = 10;

		z = 300;
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
	display() itemModule();
	// displayGhost() sawGhost();
	// displayGhost() pulleyWhipGhost();

	// translate([0,0,jigZ]) rotate([0,180,0]) display() itemModule();
	// displayGhost() printBedGhost();

	// display() testItem();
}
else
{
	if(makeJig) rotate([0,180,0]) itemModule();
	if(makeTest) rotate([0,180,0]) testItem();
}

module testItem()
{
	difference() 
	{
		itemModule();
		tcu([-200, -80, -20], 400);
	}
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
