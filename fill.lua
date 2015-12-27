if( fs.exists( "/stdlib" ) ) then
	dofile( "/stdlib" );
else
	print( "dome: error: /stdlib missing" );
	exit();
end

args = {...}
if( table.getn( args ) < 2 or table.getn( args ) > 5 ) then
	print( "usage: fill <x> <y> [<depth>] [<n>] [<match>]" );
	print( "       n, if provided, will be the interval to fill. 7 is good for torches." );
	print( "       match, if 1, will indicate that the floor will be replaced with the slot 1 item if it doesn't match" );
	exit();
end

if( table.getn( args ) > 2 ) then
	depth = tonumber(args[3])
	if( depth < 1 ) then
		print( "depth must be greater than 0" );
		exit();
	end
else
	depth = 1
end

if( table.getn( args ) > 3 ) then
	n = tonumber(args[4])
else
	n = 1
end

if( table.getn( args ) > 4 ) then
	match = true
else
	match = false
end

tx=0; ty=0;
modY = 1; modX = 1;
if( tonumber( args[1] ) < 0 ) then modX = -1; end
if( tonumber( args[2] ) < 0 ) then modY = -1; end
dir=1;

goto( nil, nil, -(depth-1) );

while true do
	placeBlockDown( 1, match );

	-- Calculate next position
	if( dir == 1 ) then
		if( (x/n) % 2 == 0 ) then
			-- even X
			ty=ty+modY*n;
			if( ty*modY >= tonumber(args[2])*modY ) then
				ty=ty-modY*n;
				tx=tx+modX*n;
			end
		else
			-- odd X
			ty=ty-modY*n;
			if( ty*modY < 0 ) then
				ty=ty+modY*n;
				tx=tx+modX*n;
			end
		end
	else
		if( (x/n) % 2 == 0 ) then
			ty = ty - modY*n;
			if( ty*modY < 0 ) then
				ty = ty + modY*n;
				tx = tx - modX*n;
			end
		else
			ty = ty + modY*n;
			if( ty*modY >= tonumber(args[2])*modY ) then
				ty = ty - modY*n;
				tx = tx - modX*n;
			end
		end
	end

	-- We end if the column is out-of-bounds..
	if( ( tx*modX >= tonumber(args[1])*modX and dir == 1 ) or ( tx*modX < 0 and dir == -1 ) ) then
		-- And we were are the top layer
		if( z == 0 ) then
			goto( 0, 0, 0 );
			north();
			break;
		end
		-- Otherwise, just move up a layer.
		goto( nil, nil, z+1 );
		tx = tx - dir*modX*n;
		dir = dir * -1;
	end

	goto( tx, ty, nil );
end
