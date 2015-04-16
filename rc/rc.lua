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

	term.write( "- [ " );
	if( reactor == nil ) then
		term.write( "unknown" );
	else
		term.write( math.floor( reactor.getFuelTemperature() + 0.5 ) );
	end
	term.write( " / " .. target_temperature .. " ] +" );
end

function printPower()
	term.setCursorPos( 1, 4 );
	cursor( "power" )
	term.write( "Power: " );

	term.write( math.floor( 100 * reactor.getEnergyStored() / 10000000 + 0.5 ) .. "%" )
end

function printTemperaturePID()
	term.setCursorPos( 1, 5 );
	cursor( "tpid" )
	term.write( "T.PID: " );

	if( tpid_sel == 0 ) then term.write( "[kP] " .. temp_kp ); else term.write( " kp  " .. temp_kp ); end
	if( tpid_sel == 1 ) then term.write( "[kI] " .. temp_ki ); else term.write( " kI  " .. temp_ki ); end
	if( tpid_sel == 2 ) then term.write( "[kD] " .. temp_kd ); else term.write( " kD  " .. temp_kd ); end
	term.write( " o=" .. math.floor( temp_output*10+0.5 ) / 10 );

	term.setCursorPos( 1, 6 );
	term.write( " e=" .. math.floor( temp_pe * 10 + 0.5 ) / 10 );
	term.write( " i=" .. math.floor( temp_i  * 10 + 0.5 ) / 10 );
	term.write( " d=" .. math.floor( temp_pd * 10 + 0.5 ) / 10 );
end

function printPowerPID()
	term.setCursorPos( 1, 7 );
	cursor( "ppid" )
	term.write( "PwPID: " );

	if( pow_sel == 0 ) then term.write( "[kP] " .. pow_kp ); else term.write( " kp  " .. pow_kp ); end
	if( pow_sel == 1 ) then term.write( "[kI] " .. pow_ki ); else term.write( " kI  " .. pow_ki ); end
	if( pow_sel == 2 ) then term.write( "[kD] " .. pow_kd ); else term.write( " kD  " .. pow_kd ); end
	term.write( " o=" .. math.floor( pow_output*10+0.5 ) / 10 );

	term.setCursorPos( 1, 8 );
	term.write( " e=" .. math.floor( pow_pe * 10 + 0.5 ) / 10 );
	term.write( " i=" .. math.floor( pow_i  * 10 + 0.5 ) / 10 );
	term.write( " d=" .. math.floor( pow_pd * 10 + 0.5 ) / 10 );
end

function cleanup()
end

state_list = { "state", "temp", "tpid", "ppid", "exit" }

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

bindings["temp"] = {}
bindings["temp"][203] = function ()
	target_temperature = target_temperature - 50;
	if( target_temperature < 0 ) then target_temperature = 0; end;
end

bindings["temp"][205] = function ()
	target_temperature = target_temperature + 50;
end

bindings["tpid"] = {}
bindings["tpid"][15] = function () tpid_sel = ( tpid_sel + 1 ) % 3; end
bindings["tpid"][203] = function () if( tpid_sel == 0 ) then temp_kp = temp_kp - 0.1; elseif( tpid_sel == 1 ) then temp_ki = temp_ki - 0.1; else temp_kd = temp_kd - 0.1; end; end
bindings["tpid"][205] = function () if( tpid_sel == 0 ) then temp_kp = temp_kp + 0.1; elseif( tpid_sel == 1 ) then temp_ki = temp_ki + 0.1; else temp_kd = temp_kd + 0.1; end; end

bindings["ppid"] = {}
bindings["ppid"][15] = function () pow_sel = ( pow_sel + 1 ) % 3; end
bindings["ppid"][203] = function () if( pow_sel == 0 ) then pow_kp = pow_kp - 0.1; elseif( pow_sel == 1 ) then pow_ki = pow_ki - 0.1; else pow_kd = pow_kd - 0.1; end; end
bindings["ppid"][205] = function () if( pow_sel == 0 ) then pow_kp = pow_kp + 0.1; elseif( pow_sel == 1 ) then pow_ki = pow_ki + 0.1; else pow_kd = pow_kd + 0.1; end; end

bindings["exit"] = {}
bindings["exit"][28] = function () stop = 1; end

target_temperature = 200;
cursor_position = 1;
reactor = nil
findReactor();
stop=0

tpid_sel = 0;
temp_kp = 0;
temp_ki = 0;
temp_kd = 0;
temp_pe = 0;
temp_pd = 0;
temp_i = 0;
temp_output = 0;
temp_last = os.clock()

pow_sel = 0;
pow_kp = 0;
pow_ki = 0;
pow_kd = 0;
pow_pe = 0;
pow_pd = 0;
pow_i = 0;
pow_output = 0;
pow_last = os.clock()

-- Call as pe, pd, i, o, last = pid( input, target, kp, ki, kd, pe, i, last )
function pid( input, target, kp, ki, kd, pe, i, last, min, max )
	local now = os.clock()
	local dt = now - last
	local error = target - input
	local integ = i + error*dt
	local deriv = ( pe - error ) / dt
	output = kp * error + ki * integ + kd * deriv
	if( output < min ) then output = min; elseif( output > max ) then output = max; end;
	return error, deriv, integ, output, now
end

while stop == 0 do
	temp_pe, temp_pd, temp_i, temp_output, temp_last = pid( reactor.getFuelTemperature(), target_temperature, temp_kp, temp_ki, temp_kd, temp_pe, temp_i, temp_last, 0, 100 );
	pow_pe,  pow_pd,  pow_i,  pow_output,  pow_last  = pid( reactor.getEnergyStored(),    10000000,           pow_kp,  pow_ki,  pow_kd,  pow_pe,  pow_i,  pow_last, 0, 100 );

	if( temp_output < pow_output ) then
		reactor.setAllControlRodLevels( 100 - temp_output )
	else
		reactor.setAllControlRodLevels( 100 - pow_output )
	end

	os.startTimer(0.5);
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
		printPower();
		printTemperaturePID();
		printPowerPID();
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

	while true do
		local event,arg = os.pullEvent()
		if event == "key" then
			if( bindings[ state_list[cursor_position] ] ~= nil and bindings[ state_list[cursor_position] ][ arg ] ~= nil ) then
				bindings[ state_list[cursor_position] ][ arg ]()
			elseif( bindings[ "global" ] ~= nil and bindings[ "global" ][ arg ] ~= nil ) then
				bindings[ "global" ][ arg ]()
			end
		elseif event == "timer" then
			break
		end
	end

	sleep(0);
end

cleanup();
