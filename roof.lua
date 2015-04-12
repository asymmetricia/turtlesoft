if( fs.exists( "/stdlib" ) ) then
	dofile( "/stdlib" );
else
	print( "dome: error: /stdlib missing" );
	exit();
end

args = {...}
if( table.getn( args ) < 2 or table.getn( args ) > 4 ) then
	print( "usage: roof <x> <y> [<n>] [<match>]" );
	print( "	<n> -- only fill every n'th square" );
	exit();
end

tx=0;    ty=0;   tz=0;
modX=1;  modY=1; n=1;
match=0;

if( table.getn( args ) >= 3 ) then n = tonumber(args[3]); end
if( table.getn( args ) >= 4 ) then match = 1; end
if( tonumber(args[1]) < 0 ) then modX = -1; end
if( tonumber(args[2]) < 0 ) then modY = -1; end

while true do
	placeBlockUp( 1, match );

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
	if( tx*modX > tonumber(args[1])*modX ) then
		goto( 0, 0, 0 ); north();
		break;
	end
	goto( tx, ty, tz );
end
