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

function cursor( state )
	local x,y = term.getCursorPos()
	if( state_list[cursor_position] == state ) then
		term.write( "->" );
	else
		term.write( "  " );
	end
	term.setCursorPos( 3, y )
end

function printReactorState()
	term.setCursorPos( 1, 2 );
	cursor( "state" )
	term.write( "State: " );

	term.setCursorPos( 10, 2 );
	if( reactor.getActive() ) then
		term.write( " Inactive  [Active]" );
	else
		term.write( "[Inactive]  Active" );
	end
end

function printTemperature()
	term.setCursorPos( 1, 3 );
	cursor( "temp" )
	term.write( " Temp: " );

	term.setCursorPos( 10, 3 );
	term.write( "- [ " );
	if( reactor == nil ) then
		term.write( "unknown" );
	else
		term.write( math.floor( reactor.getFuelTemperature() + 0.5 ) );
	end
	term.write( " / " .. target_temperature .. " ] +" );
end

function cleanup()
end

state_list = { "state", "temp", "exit" }

bindings["global"] = {}
bindings["global"][200] = function ()
	if( cursor_position == 1 ) then cursor_position = table.maxn( state_list ) else cursor_position = cursor_position - 1; end
end

bindings["global"][208] = function ()
	if( cursor_position == table.maxn( state_list ) ) then cursor_position = 1 else cursor_position = cursor_position + 1; end
end

bindings["state"]  = {}
bindings["state"][203] = function ()
	if( reactor.getActive() ) then reactor.setActive( false ); end
end

bindings["state"][205] = function ()
	if( not reactor.getActive() ) then reactor.setActive( true ); end
end

bindings["temperature"] = {}
bindings["temperature"][203] = function ()
	target_temperature = target_temperature - 50;
	if( target_temperature < 0 ) then target_temperature = 0; end;
end

bindings["temperature"][205] = function ()
	target_temperature = target_temperature + 50;
end

bindings["exit"] = {}
bindings["exit"][28] = function () stop = 1; end

target_temperature = 200;
cursor_position = 1;
reactor = nil
findReactor();
stop=0

while stop == 0 do
	term.clear();
	term.setCursorPos( 1, 1 );
	term.write( "ReactorOS v0.1" );
	if( reactor ~= nil ) then
		for y = 2,19 do
			term.setCursorPos( 1, y );
			term.clearLine();
		end

		printReactorState();
		printTemperature();
	else
		term.setCursorPos( 1, 2 );
		term.write( "No Reactor Found" );
		findReactor();
	end

	term.setCursorPos( 1, 19 );
	if( state_list[cursor_position] == "exit" ) then
		term.write( "->Exit" );
	else
		term.write( "  Exit" );
	end

	local event, scancode = os.pullEvent( "key" )
	if( bindings[ state_list[cursor_position] ] ~= nil and bindings[ state_list[cursor_position] ][ scancode ] ~= nil ) then
		bindings[ state_list[cursor_position] ][ scancode ]()
	elseif( bindings[ "global" ] ~= nil and bindings[ "global" ][ scancode ] ~= nil ) then
		bindings[ "global" ][ scancode ]()
	end

	sleep(0);
end

cleanup();
