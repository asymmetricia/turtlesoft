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

reactor = nil

function findReactor()
	for i,side in pairs(peripheral.getNames()) do
		if( peripheral.getType( side ) == "BigReactors-Reactor" ) then
			reactor = peripheral.wrap( side );
		end
	end
end

function printReactorState()
	term.setCursorPos( 1, 2 );
	if( sel == "state" ) then
		print( "→" );
	else
		print( " " );
	end

	term.setCursorPos( 2, 2 );
	print( "State: " );

	term.setCursorPos( 9, 2 );
	if( reactor.getActive() ) then
		print( " Inactive  [Active]" );
	else
		print( "[Inactive]  Active" );
	end
end

sel = 0;

while 1 do
	term.clear();
	term.setCursorPos( 1, 1 );
	print( "ReactorOS v0.1" );
	if( reactor ~= nil ) then
		printReactorState();

		for y = 3,19 do
			term.setCursorPos( 1, y );
			term.clearLine();
		end
	else
		term.setCursorPos( 1, 2 );
		print( "No Reactor Found" );
		findReactor();
	end
	sleep(1);
end
