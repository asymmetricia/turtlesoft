if( fs.exists( "/stdlib" ) ) then
	if dofile == nil then shell.run("/stdlib") else dofile( "/stdlib" ); end
else
	print( "tunnel: error: /stdlib missing" );
	os.exit();
end

function usage()
	print( "usage: tunnel -x <width> -y <length> -z <height> [-s <slope>] [-h <h-slope>] [-m] [-u]" );
	print( "  Specify -m to enable block-matching. Specify -u for unsafe (but fast) tunnels." );
	print( "	-s -- default slope is 0. otherwise, slope is number of blocks per Z level, positive for sloping up, negative for sloping down. 2-3 is a good value for general walkways.")
	print( "  -h -- default hslope is 0. otherwise, slope is number of blocks forward before one block right (h > 0) or left (h < 0). 1 is 45-degree tunnel.")
	os.exit();
end

function sloped(y,slope)
	if(slope == 0) then
		return 0;
	elseif(slope>=0) then
		return math.floor((y-1)*slope)+1;
	else
		return math.ceil((y-1)*slope)-1;
	end
end

args = {...}
opts = getopt( args, "xyzsh" );

if     tonumber(opts["x"]) == nil then print( "-x (width) is required" );  usage();
elseif tonumber(opts["y"]) == nil then print( "-y (length) is required" ); usage();
elseif tonumber(opts["z"]) == nil then print( "-z (height) is required" ); usage();
end

tunnel_x = tonumber(opts["x"]);
tunnel_y = tonumber(opts["y"]);
tunnel_z = tonumber(opts["z"]);

slope = 0
if opts["s"] ~= nil then
	if tonumber(opts["s"]) ~= nil and tonumber(opts["s"]) ~= 0 then
		slope = tonumber(opts["s"])
	else
		print( "-s (slope) must be numeric and non-zero" );
		usage();
	end	
end

hslope = 0
if opts["h"] ~= nil then
  if tonumber(opts["h"]) ~= nil and tonumber(opts["h"]) ~= 0 then
    hslope = tonumber(opts["h"])
  else
    print( "-h (h-slope) must be numeric and non-zero" );
    usage();
  end
end

match = false
if opts["m"] ~= nil then print( "matching enabled." ); match = true; end

if opts["u"] ~= nil then
	if(slope ~= 0) then slope = 1 / slope; end
	if(hslope ~= 0) then hslope = 1 / hslope; end
	print("I, too, like to live dangerously.");

	tx=0; ty=1; tz=0; dir=1;
	-- Floor
	while (tx < tunnel_x + hslope * tunnel_y) do
		-- Note that tunnel runs form y=1 to y=(tunnel_y), i.e., starts one ahead of turtle starting pos
		while( (dir == 1 and ty <= tunnel_y) or (dir == -1 and ty > 0) ) do
			tz = sloped(ty,slope);
			goto(tx+sloped(ty,hslope),ty,nil); goto(nil,nil,tz);
			placeBlockDown(1,match);
			while turtle.digUp() do end
			ty = ty + dir;
		end
		ty = ty - dir;
		dir = -1 * dir;
		tx = tx + 1;
	end
	-- Right Wall
	tx=tunnel_x; level=1;
	if dir == 1 then ty=1; else ty = tunnel_y; end
	while (level <= tunnel_z) do -- We'll go _above_ target Z
		while( (dir == 1 and ty <= tunnel_y) or (dir == -1 and ty > 0) ) do
			tz = sloped(ty,slope) + level;
			tx = sloped_x(ty, slope);
			goto(tx+sloped(ty,hslope),ty,nil); goto(nil,nil,tz);
			placeBlockDown(1,match);
			ty = ty + dir;
		end
		ty = ty - dir;
		dir = -1 * dir;
		level = level + 1;
	end
	-- Roof
	if dir == 1 then ty=1; else ty=tunnel_y; end
	tx=tunnel_x-1;
	if(slope>=0) then tz = math.floor((ty-1) * slope + tunnel_z - 1) else tz=math.ceil((ty-1)*slope + tunnel_z - 1); end
	while(tx > -1) do
		while((dir == 1 and ty <= tunnel_y) or (dir == -1 and ty > 0)) do
			tz = sloped(ty,slope)+tunnel_z-1;
			goto(tx+sloped(ty,hslope),ty,nil); goto(nil,nil,tz);
			placeBlockUp(1,match);
			if(tunnel_z>1) then while turtle.digDown() do end; end
			ty = ty + dir;
		end
		ty = ty - dir;
		dir = -1 * dir;
		tx = tx - 1;
	end
	-- Left Wall
	tx = -1; level = 1;
	if dir == 1 then ty=1; else ty = tunnel_y; end
	while (level <= tunnel_z) do -- We'll go _above_ target Z
		while( (dir == 1 and ty <= tunnel_y) or (dir == -1 and ty > 0) ) do
			tz = sloped(ty,slope)+level;
			goto(tx+sloped(ty,hslope),ty,nil); goto(nil,nil,tz);
			placeBlockDown(1,match);
			ty = ty + dir;
		end
		ty = ty - dir;
		dir = -1 * dir;
		level = level + 1;
	end
	goto(nil,nil,z+1); goto(sloped(ty,hslope),y,z);
	goto(nil,nil,sloped(y,slope)+tunnel_z-1); placeBlockUp(1,match);
	goto(nil,nil,sloped(y,slope));
	while (y<tunnel_y) do
		if(slope<0) then
			goto(x+sloped(ty,hslope),y+1,nil); goto(nil,nil,sloped(y,slope));
		else
			goto(x+sloped(ty,hslope),nil,sloped(y+1,slope)); goto(nil,y+1,nil);
		end
	end
	north();
else
	tunnel( tunnel_x, tunnel_y, tunnel_z, 1, slope, hslope, match );
end
