if( fs.exists( "/stdlib" ) ) then
	dofile( "/stdlib" );
else
	print( "tunnel: error: /stdlib missing" );
	os.exit();
end

function usage()
	print( "usage: tunnel -x <width> -y <length> -z <height> [-s <slope>] [-m] [-u]" );
	print( "	default slope is 0. otherwise, slope is number of blocks per Z level, positive for sloping up, negative for sloping down. 2-3 is a good value for general walkways. Specify -m to enable block-matching. Specify -u for unsafe (but fast) tunnels." );
	os.exit();
end

args = {...}
opts = getopt( args, "xyzsm" );

if     tonumber(opts["x"]) == nil then print( "-x (width) is required" );  usage();
elseif tonumber(opts["y"]) == nil then print( "-y (length) is required" ); usage();
elseif tonumber(opts["z"]) == nil then print( "-z (height) is required" ); usage();
end

tunnel_x = tonumber(opts["x"]);
tunnel_y = tonumber(opts["y"]);
tunnel_z = tonumber(opts["z"]);

slope = 0
if opts["s"] ~= nil then
	if tonumber(opts["s"]) ~= nil then
		slope = tonumber(opts["s"])
	else
		print( "-s (slope) must be numeric" );
		usage();
	end	
end

match = false
if opts["m"] ~= nil then print( "matching enabled." ); match = true; end

if opts["u"] ~= nil then
	print("I, too, like to live dangerously.");
	if(opts["s"] ~= nil) then
		print("But I don't know how to slope while doing so yet.");
		os.exit();
	end
	tx=0; ty=0; tz=0; dir=1;
	// Floor
	while (tx <= tunnel_x) do
		while( (dir == 1 and ty < tunnel_y) or (dir == -1 and ty > -1) ) do
			goto(tx,ty,tz);
			placeBlockDown(1,match);
			while(turtle.detectUp()) do turtle.digUp(); end
			ty = ty + dir;
		end
		dir = -1 * dir
		tx = tx + 1
	end
else
	tunnel( tunnel_x, tunnel_y, tunnel_z, 1, slope, match );
end
