if( fs.exists( "/stdlib" ) ) then
	dofile( "/stdlib" );
else
	print( "dome: error: /stdlib missing" );
	os.exit();
end

function usage()
	print( "usage: tunnel -x <width> -y <length> -z <height> [-s <slope>]" );
	print( "	default slope is 0. otherwise, slope is number of blocks per Z level, positive for sloping up, negative for sloping down. 2-3 is a good value for general walkways." );
	os.exit();
end

args = {...}
opts = getopt( args, "xyzs" );

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

tunnel( tunnel_x, tunnel_y, tunnel_z, 1, slope );
