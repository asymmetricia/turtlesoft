local response = http.get( "http://www.pastebin.com/raw.php?i=e974cdJP" );
if response then
	local sResponse = response.readAll(); response.close(); local file = fs.open( "/stdlib", "w" ); file.write( sResponse ); file.close();
else
	print( "Error retrieving stdlib" );
end
dofile( "/stdlib" );
south();
for s=1,16 do	
	turtle.select(s);
	turtle.drop();
end
north();