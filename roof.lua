if( fs.exists( "/stdlib" ) ) then
	dofile( "/stdlib" );
else
	print( "dome: error: /stdlib missing" );
	exit();
end

args = {...}
if( table.getn( args ) ~= 2 ) then
	print( "usage: roof <x> <y>" );
	exit();
end

tx=0; ty=0; tz=0;
modX=1; modY=1;

if( tonumber(args[1]) < 0 ) then modX = -1; end
if( tonumber(args[2]) < 0 ) then modY = -1; end

while true do
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
	print( x .. "," .. y .. " => " .. tx .. "," .. ty );
	if( tx*modX >= tonumber(args[1])*modX ) then
		goto( 0, 0, 0 ); north();
		find(1);
		while not turtle.compareUp() do
			turtle.digUp();
			turtle.placeUp();
			find(1);
		end
		break;
	end
	goto( tx, ty, tz );
	find(1);
	while not turtle.compareUp() do
		turtle.digUp();
		turtle.placeUp();
		find(1);
	end
end
