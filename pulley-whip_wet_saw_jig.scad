include <../OpenSCADdesigns/MakeInclude.scad>
include <../OpenSCADdesigns/chamferedCylinders.scad>
use <../OpenSCADdesigns/torus.scad>

makeJig = false;
makeTest = false;

pulleyWhipOD = 22;
pulleyWhipOemLength = 300 + 143;
echo(str("pulleyWhipOemLength = ", pulleyWhipOemLength));

pulleyWhipMinLength = 355; // B.4.6 350mm min. + 55mm extra.
pullyWhipMaxLength = 420;
pulleyWhipLenghts = [pulleyWhipMinLength, 380, 400, pullyWhipMaxLength];

pulleyWhipMaxCutOff = pulleyWhipOemLength - pulleyWhipMinLength;
echo(str("pulleyWhipMaxCutOff = ", pulleyWhipMaxCutOff));

sawBladeHeight = 7/8 * 25.4 + 2;
echo("sawBladeHeight = ", sawBladeHeight);

jigFenceEndX = 130;
jigFenceEndWallY = 6;

jigFenceToBladeCtrY = pulleyWhipMaxCutOff + jigFenceEndWallY;
echo(str("jigFenceToBladeCtrY = ", jigFenceToBladeCtrY));
bladeCutoutY = 10;

jigBladeTohandEndY = 80;

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
	difference()
	{
		union()
		{
			// Fence end dimensions:
			fenceEndOffsetX = jigFenceEndX/2 - jigCornerRadiusFenceEnd;
			jigFenceEndOffsetY = jigFenceToBladeCtrY;
			
			// Hand end dimensions:
			handEndOffsetX = pulleyWhipOD/2 + 4;
			jighandEndOffsetY = -(jigBladeTohandEndY - jigCornerRadiusHandEnd);

			// Middle section dimensions:
			middleOffsetX = handEndOffsetX + jigCornerRadiusHandEnd - jigCornerRadiusFenceEnd;
			middleOffsetY = pullyWhipMaxLength - pulleyWhipMinLength + bladeCutoutY/2 + 2.9965; // MAGIC NUMBER WARNING!!!

			hull()
			{		
				// Hand end:		
				doubleX() translate([handEndOffsetX, jighandEndOffsetY, 0]) corner(r=jigCornerRadiusHandEnd);

				// Middle:
				doubleX() translate([middleOffsetX, jigFenceEndOffsetY-20, 0]) corner(r=jigCornerRadiusFenceEnd);
			}
			
			// Fence end:
			hull()
			{
				doubleX() translate([middleOffsetX, middleOffsetY, 0]) corner(r=jigCornerRadiusFenceEnd);
				doubleX() translate([fenceEndOffsetX, jigFenceEndOffsetY-jigCornerRadiusFenceEnd, 0]) corner(r=jigCornerRadiusFenceEnd);
			}

			// Blade center marks:
			for(l = pulleyWhipLenghts)
			{
				middleEndX = (middleOffsetX + jigCornerRadiusFenceEnd) * 2;
				x = middleEndX + 2;
				y = 1;
				z = 35;
				
				yPos = l - pulleyWhipMinLength;
				hull()
				{
					tcu([-middleEndX/2, yPos-1, 0], [middleEndX, 2, z+2]);
					tcu([-x/2, yPos-0.5, 0], [x, 1, z]);
				}
			}
		}

		// Remove the blade cutouts:
		for(l = pulleyWhipLenghts)
		{
			bladeCutout(pulleyWhipLength = l);
		}

		// recesss to grip the pulley-whip:
		od = 100;
		cd = 25;
		hull() 
		{
			translate([0, -jigBladeTohandEndY/2, 0]) 
			{
				translate([0, 0, od/2 + jigZ - 8]) rotate([90,0,0]) torus3a(outsideDiameter=od, circleDiameter=cd);
				x = 15;
				y = 10; //cd - 5;
				tcu([-x/2, -y/2, pulleyWhipOD-3], [x, y, 100]);
			}
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

	// Trim finder recess:
	// tcu([-200, -400+d-40, -200], 400);
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
	if(makeJig) rotate([0,0,90]) rotate([0,180,0]) itemModule();
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
