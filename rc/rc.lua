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

function findReactor()
	for i,side in pairs(peripheral.getNames()) do
		if( peripheral.getType( side ) == "BigReactors-Reactor" ) then
			reactor = peripheral.wrap( side );
		end
	end
end

bindings={}

function printReactorState()
	term.setCursorPos( 1, 2 );
	if( state_list[sel] == "state" ) then
		print( "->" );
	else
		print( "  " );
	end

	term.setCursorPos( 3, 2 );
	print( "State: " );

	term.setCursorPos( 10, 2 );
	if( reactor.getActive() ) then
		print( " Inactive  [Active]" );
	else
		print( "[Inactive]  Active" );
	end
end

function cleanup()
end

state_list = { "state", "exit" }

bindings["global"] = {}
bindings["state"][200] = function ()
	if( sel == 1 ) then sel = state_list.maxn() else sel = sel - 1; end
end

bindings["state"][208] = function ()
	if( sel == state_list.maxn() ) then sel = 1 else sel = sel + 1; end
end

bindings["state"]  = {}
bindings["state"][203] = function ()
	if( reactor.getActive() ) then reactor.setActive( false ); end
end

bindings["state"][205] = function ()
	if( not reactor.getActive() ) then reactor.setActive( true ); end
end

bindings["exit"][28] = function () cleanup(); shell.exit(); end

sel = 1;

reactor = nil
findReactor();

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

	term.setCursorPos( 1, 19 );
	if( state_list[sel] == "exit" ) then
		print( "->Exit" );
	else
		print( "  Exit" );
	end

	local event, scancode = os.pullEvent( "key" )
	if( bindings[ state_list[sel] ] ~= nil and bindings[ state_list[sel] ][ scancode ] ~= nil ) then
		bindings[ state_list[sel] ][ scancode ]()
	elseif( bindings[ "global" ] ~= nil and bindings[ "global" ][ scancode ] ~= nil ) then
		bindings[ "global" ][ scancode ]()
	end

	sleep(0);
end
