local response = http.get( "http://www.pastebin.com/raw.php?i=e974cdJP" );
if response then
	local sResponse = response.readAll(); response.close(); local file = fs.open( "/stdlib", "w" ); file.write( sResponse ); file.close();
else
	print( "Error retrieving stdlib" );
end
dofile( "/stdlib" );

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