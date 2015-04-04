if( fs.exists( "/stdlib" ) ) then
	dofile( "/stdlib" );
else
	print( "dome: error: /stdlib missing" );
	exit();
end

args = {...}
opts = getopt( args, "rznxysw" );
if( opts[ "h" ] ) then
	print( "usage: hypstruc --rbase=<rbase> --rmin=<rmin> --hmin=<hmin> --hmax=<hmax>" );
	print( "       rbase is the radius of the base; rmin is the minimum radius. hmin is the height at which this minimum occurs, and hmax is the overall height of the structure." );
	print( "	Optinal options: [-z <Zskip>] [-n <Nlayers>] [-m] [-d] [-x <startX>] [-y <startY>] [-s <segments>] [-w <which segment>]" );
	print( "	-z Start at (N+1) layer, e.g., -z 1 skips layer 0" );
	print( "	-n Draw only <Nlayers> layers." );
	print( "	-m match" );
	print( "	-d dryrun" );
	print( "	-x Turtle begins at (x,y) instead of center" );
	print( "	-y" );
	print( "	--fill fill the structure" );
	print( "	--clear clear the inside of the structure			" );
	print( "	-s, -w -- only draw a slice. E.g., -s 2 means north half, south half, -w 1 says draw north" );
	exit();
end	

zskip=0;      match=0; 
dryrun=false; x=0;     y=0;
segs=1;       which=1;

if( opts["rbase"] == nil ) then print( "--rbase is required (hypstruc -h for usage)" ); exit(); else rbase = tonumber( opts["rbase"] ); end
if( opts["rmin"] == nil )  then print( "--rmin is required (hypstruc -h for usage)" );  exit(); else rmin  = tonumber( opts["rmin"] );  end
if( opts["hmin"] == nil )  then print( "--hmin is required (hypstruc -h for usage)" );  exit(); else hmin  = tonumber( opts["hmin"] );  end
if( opts["hmax"] == nil )  then print( "--hmax is required (hypstruc -h for usage)" );  exit(); else hmax  = tonumber( opts["hmax"] );  end

layers=hmax;

if( rmin >= rbase ) then print( "rbase must be larger than rmin" ); exit(); end

if( opts["z"] ~= nil ) then zskip  = tonumber( opts["z"] ); end
if( opts["n"] ~= nil ) then layers = tonumber( opts["n"] ); end
if( opts["m"] ~= nil ) then match  = true; print( "Block-matching enabled." );  end
if( opts["d"] ~= nil ) then dryrun = true; end
if( opts["x"] ~= nil ) then x      = tonumber( opts["x"] ); end
if( opts["y"] ~= nil ) then y      = tonumber( opts["y"] ); end
if( opts["s"] ~= nil ) then segs   = tonumber( opts["s"] ); end
if( opts["w"] ~= nil ) then which  = tonumber( opts["w"] ); end
if( opts["clear"] ~= nil ) then print( "Extent clearing enabled." ); end
if( opts["fill"] ~= nil )  then print( "Extent filling enabled." );  end

homeX=x;
homeY=y;

print( "Allocating memory..." );
model = {}
for tx = -rbase,rbase do
	model[tx] = {}
	for ty = -rbase,rbase do
		model[tx][ty] = {}
	end
	sleep(0);
end
print( "Done!" );

print( "Voxelizing model..." );

h_a_squared = rmin * rmin;
h_b_squared = (hmin * hmin) / ( ( rbase * rbase ) / ( h_a_squared ) - 1 );
h_b = math.sqrt( h_b_squared );

-- Iterate from h_y = -hmin to hmax-hmin
steps = hmax * 10;
last_yield_time = os.time();
theta_begin = (math.pi*2) * ( (which-1)/segs );
theta_end   = (math.pi*2) * ( which/segs );
for h_y_i = 0,steps do
	h_y = hmax * h_y_i / steps;
	if( opts[ "debug" ] ~= nil ) then print( "Voxelizing h_y = " .. h_y ); end
	dz = math.floor( h_y + 0.5 );
    if( dz >= zskip + layers ) then
		break;
    end
	if( dz >= zskip ) then
		layer_radius_max = math.sqrt( h_a_squared + h_a_squared * ( h_y - hmin ) * ( h_y - hmin ) / h_b_squared );
		if( opts[ "fill" ] ~= nil or opts[ "clear" ] ~= nil ) then layer_radius_min = 0.5; else layer_radius_min = layer_radius_max end;
		layer_radius = layer_radius_max
		while( layer_radius >= layer_radius_min ) do
			x_end = math.floor( math.cos( theta_end ) * layer_radius + 0.5 );
			y_end = math.floor( math.sin( theta_end ) * layer_radius + 0.5 );
			if( segs ~= 1 ) then model[x_end][y_end][dz]=2; end;
			theta = theta_begin;
			while( theta < theta_end ) do
				if( os.time() > last_yield_time ) then sleep(0); last_yield_time = os.time(); end
				dx = math.floor( math.cos( theta ) * layer_radius + 0.5);
				dy = math.floor( math.sin( theta ) * layer_radius + 0.5);
				if( model[dx][dy][dz] == nil or model[dx][dy][dz] == -1 ) then
					if( opts[ "clear" ] ~= nil and layer_radius ~= layer_radius_max ) then
						model[dx][dy][dz] = -1;
					else
						model[dx][dy][dz] = 1;
					end
				end
				theta = theta + (theta_end-theta_begin)/steps;
			end
			layer_radius = layer_radius - 0.5;
		end
	end
end
print( "Done!" );

if( opts[ "dump" ] ) then
	for ty=rbase,-rbase,-1 do
		s = "";
		for tx=-rbase,rbase do
			if( model[tx][ty][zskip] == 1 ) then
				s = s .. 1;
			elseif( model[tx][ty][zskip] == -1 ) then
				s = s .. '_';
			elseif( model[tx][ty][zskip] == 3 ) then
				s = s .. '*';
			else
				s = s .. 0;
			end
		end
		print( s );
	end
end

print( "Counting voxels..." );
count=0; clear_count=0;
for tx,r in pairs( model ) do
	for ty,c in pairs(r) do
		for tz,v in pairs(c) do
			if( v == 1 ) then
				count = count+1;
			else
				clear_count = clear_count+1;
			end
		end
	end
end

print( "Hyperbolic Structure will require " .. count .. " blocks total." );
if( clear_count > 0 ) then
	print( "Will clear " .. count .. " blocks." );
end
printModel( model, zskip, dryrun, opts[ "verbose" ], match );
