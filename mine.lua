if( fs.exists( "/stdlib" ) ) then
	if dofile == nil then shell.run("/stdlib") else dofile( "/stdlib" ); end
else
	print( "dome: error: /stdlib missing" );
	exit();
end

args = {...}
if( table.getn( args ) < 3 or table.getn( args ) > 4 ) then
	print( "usage: dig <x> <y> <z> [<Zskip>]" );
	exit();
end

zskip=0;
if( table.getn( args ) > 3 ) then zskip = tonumber(args[4]); end
if( zskip < 0 ) then
	print( "error: zskip should be >= 0" );
	exit();
end

newMineArea( tonumber(args[1]), tonumber(args[2]), tonumber(args[3]), zskip );
goto(0,0,0);
north();
