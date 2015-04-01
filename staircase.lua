local response = http.get( "http://www.pastebin.com/raw.php?i=e974cdJP" );
if response then
	local sResponse = response.readAll(); response.close(); local file = fs.open( "/stdlib", "w" ); file.write( sResponse ); file.close();
else
	print( "Error retrieving stdlib" );
end
dofile( "/stdlib" );


args = {...}
if( table.getn( args ) ~= 2 ) then
	print( "usage: staircase {up|down} <n>" );
end
print( args[1].." "..args[2] );

for i=1,args[2] do
	if args[1] == "down" then
		staircaseDown();
	else
		staircaseUp();
	end
end