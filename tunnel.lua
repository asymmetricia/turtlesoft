local response = http.get( "http://www.pastebin.com/raw.php?i=e974cdJP" );
if response then
	local sResponse = response.readAll(); response.close(); local file = fs.open( "/stdlib", "w" ); file.write( sResponse ); file.close();
else
	print( "Error retrieving stdlib" );
end
dofile( "/stdlib" );

args = {...}
if( table.getn( args ) ~= 3 ) then
	print( "usage: tunnel <count> <xdim> <zdim>" );
	return;
end

if( args[1] ) then
	for i=1,args[1] do
		tunnelOne( args[2], args[3] );
		north();
	end
end