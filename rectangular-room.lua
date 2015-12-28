if( fs.exists( "/stdlib" ) ) then
	dofile( "/stdlib" );
else
	print( "dome: error: /stdlib missing" );
	exit();
end

args = {...}
opts = getopt( args, "rznxysw" );
if( opts[ "x" ] == nil or opts[ "h" ] ) then
	print( "usage: recroom -x <x> [-y <y>] [-z <z>] [-w <wall thickness>] [--zskip=<Zskip>] [-n <Nlayers>] [-m] [-d] [-startx=<startX>] [-starty=<startY>]" );
	print( "	-xN -yN -ZN -- *external* dimensions" );
	print( "	-m match     -d dryrun" );
	print( "	--floor=<N> -- use N as item type for floor, default 1" );
	print( "	--walls=<N> -- As above, default same as floor" );
	print( "	--ceiling=<N> -- As above, default same as walls" );
	print( "	--roof=<N> -- If 1, the ceiling will be one unit thicker and the top will be Roof material instead of Ceiling material. The overall height will be preserved." );
	print( "	--clear clear the inside of the room" );
	print( "	Note: Turtle begins in bottom-right corner of interior space." );
	exit();
end	

dimX=tonumber(opts["x"])-1
if( opts["y"] == nil ) then dimY = dimX; else dimY=tonumber(opts["y"])-1; end
if( opts["z"] == nil ) then dimZ = dimX; else dimZ=tonumber(opts["z"])-1; end

zskip=0; match=false; dryrun=false; x=0; y=0; verbose=false;
layers=dimZ;

if( opts["clear"] ~= nil ) then clear = 1; end
if( opts["zskip"] ~= nil ) then zskip = tonumber( opts["z"] ); end
if( opts["n"] ~= nil ) then layers = tonumber( opts["n"] ); end
if( opts["m"] ~= nil or opts["match"] ~= nil ) then print( "Block-matching enabled." ); match = true; end
if( opts["d"] ~= nil ) then dryrun = true; end
if( opts["startx"] ~= nil ) then x = tonumber( opts["startx"] ); end
if( opts["starty"] ~= nil ) then y = tonumber( opts["starty"] ); end
if( opts["w"] ~= nil ) then wallthickness = tonumber( opts["w"] ); else wallthickness = 1; end

mat_floor = 1; mat_walls = 1; mat_ceiling = 1; mat_roof = 0;
if( opts["floor"]   ~= nil ) then mat_floor   = tonumber( opts["floor"] ); mat_walls = floor; mat_ceiling = floor; end
if( opts["walls"]   ~= nil ) then mat_walls   = tonumber( opts["walls"] ); mat_ceiling = mat_walls; end
if( opts["ceiling"] ~= nil ) then mat_ceiling = tonumber( opts["ceiling"] ); end
if( opts["roof"]    ~= nil ) then mat_roof    = tonumber( opts["roof"] ); end
if( opts["verbose"] ~= nil ) then verbose = true; end

if( mat_roof ~= 0 ) then
	roof_msg = " with roof in material " .. mat_roof;
else
	roof_msg = " without roof";
end

print( "Printing recroom " .. (dimX+1) .. " W x " .. (dimY+1) .. " L x " .. (dimZ+1) .. "H in materials " .. mat_floor .. ", " .. mat_walls .. ", " .. mat_ceiling  .. roof_msg );

homeX=x;
homeY=y;

print( "Allocating memory..." );
model_floor   = {}
model_walls   = {}
model_ceiling = {}
model_roof    = {}
for tx = -1,dimX-1 do 
	model_floor[tx]   = {}
	model_walls[tx]   = {}
	model_ceiling[tx] = {}
	model_roof[tx]    = {}
	for ty = -1,dimY-1 do
		model_floor[tx][ty]   = {}
		model_walls[tx][ty]   = {}
		model_ceiling[tx][ty] = {}
		model_roof[tx][ty]    = {}
	end
	sleep(0);
end
print( "Done!" );

if( clear ) then
	fillvalue = -1;
else
	fillvalue = 1;
end

count = 0;
counts = {0,0,0,0};
clear_count = 0;	

print( "Voxelizing model..." );
-- Solid from (-1) to (-1+wallthickness-1)
for i_z = -1,wallthickness-2 do
	for i_y=-1,dimY-1 do for i_x=-1,dimX-1 do
		model_floor[i_x][i_y][i_z] = 1;
		count = count+1;
		counts[1] = counts[1]+1;
	end; end
end

-- Walls from (-1+wallthickness+1) to (dimZ-2-wallthickness)
for i_z = -1, dimZ-2-wallthickness do
	for i_x = -1,dimX-2 do
		for i_y = -1,dimY-2 do
			if(i_x < -1+wallthickness or i_x > dimX - 2 - wallthickness or i_y < -1-wallthickness or i_y > dimY - 2 - wallthickness) then
				model_walls[i_x][i_y][i_z] = 1;
				count = count + 1;
				counts[2] = counts[2] + 1;
			end
		end
	end
end

-- If no roof, ceiling from (dimz-2-wallthickness) to (dimz-2)
-- If roof, ceiling from (dimz-3-wallthickness) to (dimz-3) and roof on dimz-2.
if mat_roof == 0 then
	for i_z = dimZ - 1 - wallthickness, dimZ - 2 do
		for i_y=-1,dimY-1 do for i_x=-1,dimX-1 do
			model_ceiling[i_x][i_y][i_z] = 1;
			count = count+1;
			counts[3] = counts[3]+1;
		end; end
	end
else
	for i_z = dimZ - 2 - wallthickness, dimZ - 3 do
		for i_y=-1,dimY-1 do for i_x=-1,dimX-1 do
			model_ceiling[i_x][i_y][i_z] = 1;
			count = count+1;
			counts[3] = counts[3]+1;
		end; end
	end
	for i_y=-1,dimY-1 do for i_x=-1,dimX-1 do
		model_roof[i_x][i_y][dimZ-2] = 1;
		count = count+1;
		counts[4] = counts[4]+1;
	end; end
end
print( "Done!" );

print( "Recroom will require " .. count .. " blocks total." );
print( "      Floor: " .. counts[1]  .. " Walls: " .. counts[2] .. " Ceiling: " .. counts[3] .. " Roof: " .. counts[4] );

if( clear_count > 0 ) then
	print( "Will clear " .. count .. " blocks." );
end

print( "Printing floor in material " .. mat_floor );
printModel( model_floor,   zskip, dryrun, verbose, match, mat_floor, false, true);

print( "Printing walls in material " .. mat_walls );
printModel( model_walls,   zskip, dryrun, verbose, match, mat_walls, false   );

print( "Printing ceiling in material " .. mat_ceiling );
printModel( model_ceiling, zskip, dryrun, verbose, match, mat_ceiling, mat_roof == 0, true );

if( mat_roof ~= 0 ) then
	print( "Printing roof in material " .. mat_roof );
	printModel( model_roof, zskip, dryrun, verbose, match, mat_roof, true, true );
end