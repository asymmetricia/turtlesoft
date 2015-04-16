function httpDownload( url, path )
        local response = http.get( url );
        if response then
                local sResponse = response.readAll();
                response.close();
                local file = fs.open( path, "w" );
                file.write( sResponse );
                file.close();
                return 1;
        else
                print( "Error retrieving " .. url );
                return 0;
        end
end

reactors = {}

print( "Searching for reactors.." );
for i,side in pairs(peripheral.getNames()) do
	if( peripheral.getType( side ) == "BigReactors-Reactor" ) then
		print( "Found reactor on " .. side .. " side" );
		reactors[ side ] = peripheral.wrap( side );
	end
end

while 1 do
	term.setCursorPos( 1, 1 );
	print( "ReactorOS v0.1" );
	for y = 2,19 do
		term.setCursorPos( 1, y );
		term.clearLine();
	end
	sleep(1);
end
