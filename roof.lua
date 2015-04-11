if( fs.exists( "/stdlib" ) ) then
	dofile( "/stdlib" );
else
	print( "dome: error: /stdlib missing" );
	exit();
end

args = {...}
if( table.getn( args ) < 2 or table.getn( args ) > 3 ) then
	print( "usage: roof <x> <y> [<match>]" );
	exit();
end

if( table.getn( args ) >= 3 ) then
	match = 1;
else
	match = 0;
end

tx=0; ty=0; tz=0;
modX=1; modY=1;

if( tonumber(args[1]) < 0 ) then modX = -1; end
if( tonumber(args[2]) < 0 ) then modY = -1; end

while true do
	find(1);
	while match and not turtle.compareUp() do
		turtle.digUp();
	end
	if not turtle.detectUp() then
		while not turtle.placeUp() do
			turtle.attackUp();
		end
	end

	if( x % 2 == 0 ) then
		-- even X
		ty=ty+modY;
		if( ty*modY >= tonumber(args[2])*modY ) then
			ty=ty-modY;
			tx=tx+modX;
		end
	else
		-- odd X
		ty=ty-modY;
		if( ty*modY < 0 ) then
			ty=ty+modY;
			tx=tx+modX;
		end
	end
	if( tx*modX > tonumber(args[1])*modX ) then
		goto( 0, 0, 0 ); north();
		break;
	end
	goto( tx, ty, tz );
end
