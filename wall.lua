if( fs.exists( "/stdlib" ) ) then
	dofile( "/stdlib" );
else
	print( "dome: error: /stdlib missing" );
	exit();
end

args = {...}
if( table.getn( args ) ~= 3 ) then
	print( "usage: wall {left,right} <y> <z>" );
	exit();
end

tx=0; ty=0; tz=0;

while true do
	if( args[1] == "left" ) then
		west(); find(1); turtle.place();
	else
		east(); find(1); turtle.place();
	end
	if( y % 2 == 0 ) then
		-- even Y
		tz=tz+1;
		if( tz >= tonumber(args[3]) ) then
			tz=tz-1;
			ty=ty+1;
		end
	else
		-- odd Y
		tz=tz-1;
				if( tz < 0 ) then
			tz=tz+1
			ty=ty+1
		end
	end
	if( ty >= tonumber(args[2]) ) then
		goto(0,0,0);
		north();
		break;
	end
	goto( tx, ty, tz );
end
