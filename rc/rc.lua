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
	term.write( " / " .. temp_pid.target .. " ] +" );
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

	if( tpid_sel == 0 ) then term.write( "[kP] " .. temp_pid.kp ); else term.write( " kp  " .. temp_pid.kp ); end
	if( tpid_sel == 1 ) then term.write( "[kI] " .. temp_pid.ki ); else term.write( " kI  " .. temp_pid.ki ); end
	if( tpid_sel == 2 ) then term.write( "[kD] " .. temp_pid.kd ); else term.write( " kD  " .. temp_pid.kd ); end
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

	if( pow_sel == 0 ) then term.write( "[kP] " .. pow_pid.kp ); else term.write( " kp  " .. pow_pid.kp ); end
	if( pow_sel == 1 ) then term.write( "[kI] " .. pow_pid.ki ); else term.write( " kI  " .. pow_pid.ki ); end
	if( pow_sel == 2 ) then term.write( "[kD] " .. pow_pid.kd ); else term.write( " kD  " .. pow_pid.kd ); end
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
	temp_pid.target = temp_pid.target - 50;
	if( temp_pid.target < 0 ) then temp_pid.target = 0; end;
end

bindings["temp"][205] = function ()
	temp_pid.target = temp_pid.target + 50;
end

bindings["tpid"] = {}
bindings["tpid"][15] = function () tpid_sel = ( tpid_sel + 1 ) % 3; end
bindings["tpid"][203] = function () if( tpid_sel == 0 ) then temp_pid.kp = temp_pid.kp - 0.1; elseif( tpid_sel == 1 ) then temp_pid.ki = temp_pid.ki - 0.1; else temp_pid.kd = temp_pid.kd - 0.1; end; end
bindings["tpid"][205] = function () if( tpid_sel == 0 ) then temp_pid.kp = temp_pid.kp + 0.1; elseif( tpid_sel == 1 ) then temp_pid.ki = temp_pid.ki + 0.1; else temp_pid.kd = temp_pid.kd + 0.1; end; end

bindings["ppid"] = {}
bindings["ppid"][15] = function () pow_sel = ( pow_sel + 1 ) % 3; end
bindings["ppid"][203] = function () if( pow_sel == 0 ) then pow_pid.kp = pow_pid.kp - 0.1; elseif( pow_sel == 1 ) then pow_pid.ki = pow_pid.ki - 0.1; else pow_pid.kd = pow_pid.kd - 0.1; end; end
bindings["ppid"][205] = function () if( pow_sel == 0 ) then pow_pid.kp = pow_pid.kp + 0.1; elseif( pow_sel == 1 ) then pow_pid.ki = pow_pid.ki + 0.1; else pow_pid.kd = pow_pid.kd + 0.1; end; end

bindings["exit"] = {}
bindings["exit"][28] = function () stop = 1; end

cursor_position = 1;
reactor = nil
findReactor();
stop=0

temp_pid = {
	["target"] = 200,
	["kp"] = 0,
	["ki"] = 0,
	["kd"] = 0,
	["prevError"] = 0,
	["derivative"] = 0,
	["integral" ]  = 0,
	["maxIntegral"] = 1000,
	["output"]     = 0,
	["last"]       = os.clock()
}


pow_pid = {
	["target"] = 1000,
	["kp"] = 0,
	["ki"] = 0,
	["kd"] = 0,
	["prevError"] = 0,
	["derivative"] = 0,
	["integral" ]  = 0,
	["minIntegral"] = -1000,
	["maxIntegral"] = 1000,
	["output"]     = 0,
	["minOutput"]  = 0,
	["maxOutput"]  = 100,
	["last"]       = os.clock()
}

function updatePid( pid, input )
	local now = os.clock()
	local dt = now - pid.last
	pid.last = now

	local error = target - input

	pid.integral = pid.integral + error * dt
	if( pid.integral < pid.minIntegral ) then
		pid.integral = pid.minIntegral
	elseif( pid.integral > pid.maxIntegral ) then
		pid.integral = pid.maxIntegral
	end

	pid.derivative = ( pid.prevError - error ) / dt;
	pid.prevError = error;

	pid.output = pid.kp * error + pid.ki * pid.integral + pid.kd * pid.derivative
	if( pid.output < pid.minOutput ) then
		pid.output = pid.minOutput;
	elseif( pid.output > pid.maxOutput ) then
		pid.output = pid.maxOutput;
	end

	return pid.output
end

while stop == 0 do
	temp_output = updatePid( temp_pid, reactor.getFuelTemperature()      )
	pow_output  = updatePid( pow_pid,  reactor.getEnergyStored() / 10000 )

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
