if( fs.exists( "/stdlib" ) ) then
	dofile( "/stdlib" );
else
	print( "dome: error: /stdlib missing" );
	exit();
end

args = {...}
opts = getopt( args, "rznxyswfc" );
if( opts[ "r" ] == nil or opts[ "h" ] ) then
	print( "usage: dome -r <radius> [-z <Zskip>] [-n <Nlayers>] [-m] [-d] [-x <startX>] [-y <startY>] [-s <segments>] [-w <which segment>]" );
	print( "	-m, --match match materials" );
	print( "	-d dryrun" );
	print( "	-f, --fill  fill the hemisphere" );
	print( "	-c, --clear clear the inside of the hemisphere" );
	print( "	-s, -w -- only draw a slice. E.g., -s 2 means north half, south half, -w 1 says draw north" );
	exit();
end	

cosine_cache = {}
function cosine( theta )
	if( cosine_cache[ theta ] == nil ) then
		cosine_cache[ theta ] = math.cos( theta );
	end
	return cosine_cache[ theta ];	
end

radius=tonumber(opts["r"])
zskip=0; match=0; dryrun=false; x=0; y=0;
segs=1; which=1;  fill = 0;
layers=radius*2;

if( opts["f"] ~= nil or opts[ "fill" ] ~= nil ) then print( "Block-fill enabled." ); fill = 1; end
if( opts["z"] ~= nil ) then zskip = tonumber( opts["z"] ); end
if( opts["n"] ~= nil ) then layers = tonumber( opts["n"] ); end
if( opts["m"] ~= nil or opts["match"] ~= nil ) then print( "Block-matching enabled." ); match = 1; end
if( opts["c"] ~= nil or opts["clear"] ~= nil ) then print( "Block clearing enabled." ); clear = 1; end
if( opts["d"] ~= nil ) then dryrun = true; end
if( opts["x"] ~= nil ) then x = tonumber( opts["x"] ); end
if( opts["y"] ~= nil ) then y = tonumber( opts["y"] ); end
if( opts["s"] ~= nil ) then segs = tonumber( opts["s"] ); end
if( opts["w"] ~= nil ) then which = tonumber( opts["w"] ); end

homeX=x;
homeY=y;

print( "Allocating memory..." );
model = {}
for tx = -radius,radius do
	model[tx] = {}
	for ty = -radius,radius do
		model[tx][ty] = {}
	end
	sleep(0);
end
print( "Done!" );

print( "Voxelizing model..." );
steps = radius*10;
segsize = steps * 4 / segs;
last_yield_time = os.time();
theta_begin = (math.pi*2) * ( (which-1)/segs );
theta_end = (math.pi*2) * ( which/segs );
print( "Building for theta from " .. theta_begin .. " to " .. theta_end );
for i_z = 0,steps do
        theta_z = (math.pi/2) * (i_z / steps);
        dz = math.floor( math.sin( theta_z ) * radius + 0.5 );
        if( dz >= zskip + layers ) then
                break;
        end
        if( dz >= zskip ) then
                prev_x = -1; prev_y = -1;
                lr = math.cos( theta_z ) * radius;
                lr_max = lr;
                lr_min = lr_max;
                if( fill or clear ) then lr_min = 0.5; end;
                while( lr >= lr_min ) do
                        x_end = math.floor( math.cos( theta_end ) * lr + 0.5 );
                        y_end = math.floor( math.sin( theta_end ) * lr + 0.5 );
			if( segs ~= 1 ) then model[x_end][y_end][dz]=2; end;
                        theta = theta_begin;
                        while( theta < theta_end ) do
                                if( os.time() > last_yield_time ) then sleep(0); last_yield_time = os.time(); end
                                dx = math.floor( math.cos( theta ) * lr + 0.5);
                                dy = math.floor( math.sin( theta ) * lr + 0.5);
                                if( model[dx][dy][dz] == nil or model[dx][dy][dz] == -1 ) then
                                        if( clear and lr ~= lr_max ) then
                                                model[dx][dy][dz] = -1;
                                        else
                                                model[dx][dy][dz] = 1;
                                        end
                                end
                                theta = theta + (theta_end-theta_begin)/steps;
                        end
                        lr = lr - 0.5;
                end
        end
end
print( "Done!" );

if( opts[ "dump" ] ) then
	for ty=radius,-radius,-1 do
		s = "";
		for tx=-radius,radius do
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

print( "Dome will require " .. count .. " blocks total." );
if( clear_count > 0 ) then
	print( "Will clear " .. count .. " blocks." );
end
printModel( model, zskip, dryrun, opts[ "verbose" ], match, 0, true, fill or clear );
