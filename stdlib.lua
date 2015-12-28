home_x=0
home_y=0
home_z=0
x=home_x
y=home_y
z=home_z
p=0
 
function checkSpace()
        for i=1,16 do
                if( turtle.getItemCount(i) == 0 ) then
                        return true;
                end
        end
        return (compact(true,true))>0;
end
 
function compact(order,early)
        countFree=0;
        if( order ) then
                for i=1,15 do
                        if( turtle.getItemCount(i) > 0 and turtle.getItemSpace(i) > 0 ) then
                                turtle.select(i);
                                j=i+1;
                                while( turtle.getItemSpace(i) > 0 and j <= 16 ) do
                                        if( turtle.compareTo(j) ) then
                                                turtle.select(j);
                                                turtle.transferTo(i);
                                                turtle.select(i);
                                                if( early and turtle.getItemCount(j) == 0 ) then
                                                        turtle.select(1);
                                                        return 1;
                                                end
                                        end
                                        j=j+1;
                                end
                        end
                        if( turtle.getItemCount(i) == 0 ) then countFree=countFree+1; end;
                end
        else
                for i=16,1,-1 do
                        if( turtle.getItemCount(i) > 0 and turtle.getItemSpace(i) > 0 ) then
                                turtle.select(i);
                                j=i-1; 
                                while( turtle.getItemSpace(i) > 0 and j >= 1 ) do
                                        if( turtle.compareTo( j ) ) then
                                                turtle.select(j);
                                                turtle.transferTo(i);
                                                turtle.select(i);
                                                if( early and turtle.getItemCount(j) == 0 ) then
                                                        turtle.select(1);
                                                        return 1;
                                                end
                                        end
                                        j=j-1
                                end
                        end
                        if( turtle.getItemCount(i) == 0 ) then countFree=countFree+1; end;
                end
        end
        turtle.select(1);
        return countFree;
end
 
function newMineArea( dimX, dimY, dimZ, zskip )
        modX=1; modY=1; modZ=1;
        if( dimX < 0 ) then modX = -1; end
        if( dimY < 0 ) then modY = -1; end
        if( dimZ < 0 ) then modZ = -1; end
		-- Positive values, regardless of direction.
        minX=0; maxX=dimX*modX-1; tx=0;
        minY=0; maxY=dimY*modY-1; ty=0; 
		minZ = zskip; maxZ=dimZ*modZ-1;
		-- If we're mining more than 3Z, move to the middle of the first layer
		if((maxZ - minZ)+1 >= 3) then tz=minZ*modZ+1*modZ; else tz=minZ*modZ; end
		goto(0, 0, tz);
        zmax = tz; -- Number of completed layers
        dir=0;
        if( dimZ*modZ >= dimX*modX and dimZ*modZ >= dimY*modY ) then
                axis=0;
        elseif( dimY*modY >= dimX*modX ) then
                axis=1;
        else
                axis=2;
        end
        while true do
                if( not checkSpace() ) then
                        goto( home_x, home_y, home_z ); south();
                        if( turtle.detect() ) then
                                for s=1,16 do
                                        turtle.select(s);
                                        if not turtle.drop() then
                                                break
                                        end
                                end
                        end
                        if not checkSpace() then
                                if( zmax > 0 ) then zmax = zmax+2; end
                                print( "NO ROOM IN INVENTORY AFTER " .. zmax .. " FULL LEVELS" );
                                north();
                                exit();
                        else
                                goto( tx, ty, tz );
                        end
                end
                if( modZ < 0 ) then
                        if( z*modZ+1 <= maxZ ) then turtle.digDown(); end
                        if( z*modZ-1 >= minZ ) then while turtle.digUp() do end; end
                else
                        if( z-1 >= minZ ) then turtle.digDown(); end
                        if( z+1 <= maxZ ) then while turtle.digUp() do end; end
                end
                if( dir%2 == 0 ) then
                        if( x % 2 == 0 ) then
                                ty=ty+modY;
                                if( ty*modY > maxY ) then
                                        ty=maxY*modY;
                                        tx=tx+modX;
                                end
                        else
                                ty=ty-modY;
                                if( ty*modY < minY ) then
                                        ty=minY*modY;
                                        tx=tx+modX;
                                end
                        end
                        if( tx*modX > maxX ) then
                                tx=maxX*modX;
                                dir=dir+1;
                                if( tz*modZ == maxZ-3 or tz*modZ == maxZ-2 ) then
                                        zmax = tz+modZ;
                                        tz=maxZ*modZ;
                                elseif( tz*modZ >= maxZ-1 ) then
                                        return;
                                else
                                        zmax = tz+modZ;
                                        tz=tz+modZ*3;
                                end
                        end
                else
                        if( x % 2 == 0 ) then
                                ty=ty-modY;
                                if( ty*modY < minY ) then
                                        ty=minY*modY;
                                        tx=tx-modX;
                                end
                        else
                                ty=ty+modY;
                                if( ty*modY > maxY ) then
                                        ty=maxY*modY;
                                        tx=tx-modX;
                                end
                        end
                        if( tx*modX < minX ) then
                                tx=minX*modX;
                                dir=dir+1;
                                if( tz*modZ == maxZ-3 or tz*modZ == maxZ-2 ) then
                                        zmax = tz+modZ;
                                        tz=maxZ*modZ;
                                elseif( tz*modZ >= maxZ-1 ) then
                                        return;
                                else
                                        zmax = tz+modZ;
                                        tz=tz+modZ*3;
                                end
                        end
                end
                goto( tx, ty, tz );
        end
end
 
function wallsUp( tdx, tdy )
        for n=0,3 do
                placeBlockUp( 1, false );
                if( x == tdx and y == tdy ) then
                        placeBlockDown(1,false);
                end
                if( x == 0 ) then
                        west(); placeBlock( 1, false );
                else
                        east(); placeBlock( 1, false );
                end
                if( y == 0 ) then
                        south(); placeBlock( 1, false );
                else
                        north(); placeBlock( 1, false );
                end
                if( x == 0 and y == 0 ) then
                        goto( 1, 0, nil );
                elseif( x == 1 and y == 0 ) then
                        goto( 1, 1, nil );
                elseif( x == 0 and y == 1 ) then
                        goto( 0, 0, nil );
                elseif( x == 1 and y == 1 ) then
                        goto( 0, 1, nil );
                end
        end
end
 
function wallsDown( tdx, tdy )
        for n=0,3 do
                if( x == tdx and y == tdy ) then
                        placeBlockUp( 1, false );
                end
                if( x == 0 ) then
                        west(); placeBlock( 1, false );
                else
                        east(); placeBlock( 1, false );
                end
                if( y == 0 ) then
                        south(); placeBlock( 1, false );
                else
                        north(); placeBlock( 1, false );
                end
                if( x == 0 and y == 0 ) then
                        goto( 1, 0, nil );
                elseif( x == 1 and y == 0 ) then
                        goto( 1, 1, nil );
                elseif( x == 0 and y == 1 ) then
                        goto( 0, 0, nil );
                elseif( x == 1 and y == 1 ) then
                        goto( 0, 1, nil );
                end
        end
end
 
function staircaseUp()
        wallsUp();
        goto( nil, nil, z+1 ); wallsUp(0,0);
        goto( nil, nil, z+1 ); wallsUp(1,0);
        goto( nil, nil, z+1 ); wallsUp(1,1);
        goto( nil, nil, z+1 ); wallsUp(0,1);
        goto( 0, 0, nil ); north();
end
 
function staircaseDown()
        wallsDown();
        goto( nil, nil, z-1 ); wallsDown(0,0);
        goto( nil, nil, z-1 ); wallsDown(1,0);
        goto( nil, nil, z-1 ); wallsDown(1,1);
        goto( nil, nil, z-1 ); wallsDown(0,1);
        goto( 0, 0, nil ); north();
end

function placeBlock( slot, match )
	if(type(match)=="number") then match = (match==1); end
	if turtle.detect() and not match then return; end
	find( slot );
	if turtle.compare() then return; end
	while not turtle.place() do if turtle.detect() then turtle.dig(); else turtle.attack(); end; end
end

function placeBlockUp( slot, match )
	if(type(match)=="number") then match = (match==1); end
	if turtle.detectUp() and not match then return; end
	find( slot );
	if turtle.compareUp() then return; end
	while not turtle.placeUp() do if turtle.detectUp() then turtle.digUp(); else turtle.attackUp(); end; end
end

function placeBlockDown( slot, match )
	if(type(match)=="number") then match = (match==1); end
	if turtle.detectDown() and not match then return; end
	find( slot );
	if turtle.compareDown() then return; end
	while not turtle.placeDown() do if turtle.detectDown() then turtle.digDown(); else turtle.attackDown(); end; end
end

-- Advance == 1   if turtle should move forward into first open block of tunnel,
--         == nil if turtle is starting "in the wall" of last segment
function tunnel( xdim, ydim, zdim, advance, slope, match )
	modX=1; modZ=1; modY=1;
	xdim = tonumber(xdim) or 1
	ydim = tonumber(ydim) or 1
	zdim = tonumber(zdim) or 2
	slope = tonumber(slope) or 0
	if(type(match) == "boolean") then match=match else match=false; end

	-- Z will actually take these values, i.e., minZ=maxZ=0 would be one block high
	if( zdim < 0 ) then
		minZ = z+zdim+1; maxZ = z;
		modZ = -1;
	else
		minZ = z;
		maxZ = z+zdim-1;
	end

	if( xdim < 0 ) then
		minX = x+xdim+1; maxX = x;
		modX = -1;
	else
		minX = x;
		maxX = x+xdim-1;
	end

	if( advance ~= nil ) then
		goto( nil, y+1, nil );
	end

	minY = y;
	maxY = y + ydim - 1;

	ty=y; tx=x; tz=z;

	while true do
		if( z == minZ ) then
			placeBlockDown( 1, match );
		end
		if( z == maxZ ) then
			placeBlockUp( 1, match );
		end

		-- Optimize to reduce turns
		--       ^   N = 0
		-- W=3 <   > E = 1
		--       v   S = 2
		if( p == 2 ) then
			if( modX == 1 ) then
				west();
			else
				east();
			end
		end
		if( p == 0 ) then
			placeBlock( 1, match );
			-- if modX is positive we'll be heading east, so face east last
			if( modX == 1 ) then
				if( x == minX ) then
					west(); placeBlock( 1, match );
				end
				if( x == maxX ) then
					east(); placeBlock( 1, match );
				end
			else
				if( x == maxX ) then
					east(); placeBlock( 1, match );
				end
				if( x == minX ) then
					west(); placeBlock( 1, match );
				end
			end
		elseif( p == 1 ) then
			if( x == maxX ) then
				placeBlock( 1, match );
			end
			north(); placeBlock( 1, match );
			if( x == minX ) then
				west(); placeBlock( 1, match );
			end
		elseif( p == 3 ) then
			if( x == minX ) then
				placeBlock( 1, match );
			end
			north(); placeBlock( 1, match );
			if( x == maxX ) then
				east(); placeBlock( 1, match );
			end
		end
	
		-- Motion control
		tz = tz + modZ;

		if( (tz > maxZ and modZ > 0) or (tz < minZ and modZ < 0) ) then
			-- z hit bounds, move in x instead
			tz = tz - modZ;
			tx = tx + modX;
			modZ = modZ * -1;
		end

		if( (tx > maxX and modX > 0) or (tx < minX and modX < 0) ) then
			-- x hit bounds, move in y instead
			tx = tx - modX;
			ty = ty + modY;
			modX = modX * -1;
			if( (ty <= maxY) and (slope ~= 0) and ((ty - minY) % math.abs( slope ) == 0) ) then
				-- Time to shift in Z
				-- Note that if we hit this, modZ is already flipped

				-- To slope, we need to move to the corresponding corner in the 
				-- new plane. We should adjust bounds and control the order of 
				-- moves

				if( slope > 0 ) then
					minZ = minZ + 1
					maxZ = maxZ + 1
					if( tz < minZ ) then
						tz = minZ;
						goto( nil, nil, tz );
						goto( nil, ty, nil );
					else
						tz = maxZ;
						goto( nil, ty, nil );
						goto( nil, nil, tz );
					end
				else
					minZ = minZ - 1
					maxZ = maxZ - 1
					if( tz > maxZ ) then
						tz = maxZ;
						goto( nil, nil, tz );
						goto( nil, ty, nil );
					else
						tz = minZ;
						goto( nil, ty, nil );
						goto( nil, nil, tz );
					end
				end
			end
		end

		if( ty > maxY ) then
			goto( minX, nil, minZ );
			north();
			return;
		end
		goto( tx, ty, tz );
	end
end
 
function find(target)
        if( turtle.getItemCount( target ) > 1 ) then
                turtle.select(target);
                return 1;
        end
        for i=1,16 do
                if( i ~= target ) then
                        turtle.select(i);
                        if( turtle.compareTo( target ) ) then
                                turtle.transferTo( target );
                                turtle.select(target);
                                return 1;
                        end
                end
        end
        goto( home_x, home_y, nil );
        goto( nil, nil, home_z );
        north();
        print( "NO MATERIAL FOUND" );
        exit();
end
 
function checkFuel()
        if( turtle.getFuelLevel() > (math.abs(x)-home_x)+(math.abs(y)-home_y)+(math.abs(z)-home_z)+10 ) then
                return 1;
        end
        print( "INSUFFICIENT FUEL" );
        goto( home_x, home_y, home_z ); north();
        exit();
end
 
function goto(tx,ty,tz)
        if( tx == nil ) then
                tx = x;
        end
        if( ty == nil ) then
                ty = y;
        end
        if( tz == nil ) then
                tz = z;
        end
        if( tx ~= home_x or ty ~= home_y or tz ~= home_z ) then
                checkFuel();
        end
        while( z < tz ) do
                if( turtle.up() ) then
                        z=z+1;
                else
                        turtle.digUp();
                end
        end
        while( z > tz ) do
                if( turtle.down() ) then
                        z=z-1;
                else
                        turtle.digDown();
                end
        end
        while( y < ty ) do
                if( p == 2 and turtle.back() ) then
                        y=y+1;
                else
                        north();
                        if turtle.forward() then
                                y=y+1;
                        else
                                turtle.dig();
                        end
                end
        end
        while( y > ty ) do
                if( p == 0 and turtle.back() ) then
                        y=y-1;
                else
                        south();
                        if turtle.forward() then
                                y=y-1;
                        else
                                turtle.dig();
                        end
                end
        end
        while( x < tx ) do
                if( p == 3 and turtle.back() ) then
                        x=x+1;
                else
                        east();
                        if turtle.forward() then
                                x=x+1;
                        else
                                turtle.dig();
                        end
                end
        end
        while( x > tx ) do
                if( p == 1 and turtle.back() ) then
                        x=x-1;
                else
                        west();
                        if turtle.forward() then
                                x=x-1;
                        else
                                turtle.dig();
                        end
                end
        end
end
 
function north()
        if( p == 2 ) then
                turtle.turnLeft(); turtle.turnLeft();
        end
        if( p == 1 ) then
                turtle.turnLeft();
        end
        if( p == 3 ) then
                turtle.turnRight();
        end
        p=0;
end
 
function east()
        if( p == 0 ) then
                turtle.turnRight();
        end
        if( p == 2 ) then
                turtle.turnLeft();
        end
        if( p == 3 ) then
                turtle.turnLeft(); turtle.turnLeft();
        end
        p=1;
end
 
function west()
        if( p == 0 ) then
                turtle.turnLeft();
        end
        if( p == 1 ) then
                turtle.turnLeft(); turtle.turnLeft();
        end
        if( p == 2 ) then
                turtle.turnRight();
        end
        p=3;
end
 
function south()
        if( p == 0 ) then
                turtle.turnLeft(); turtle.turnLeft();
        end
        if( p == 1 ) then
                turtle.turnRight();
        end
        if( p == 3 ) then
                turtle.turnLeft();
        end
        p=2;
end
 
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
 
function getopt( arg, options )
  local tab = {}
  for k, v in ipairs(arg) do
    if string.sub( v, 1, 2) == "--" then
      local x = string.find( v, "=", 1, true )
      if x then tab[ string.sub( v, 3, x-1 ) ] = string.sub( v, x+1 )
      else      tab[ string.sub( v, 3 ) ] = true
      end
    elseif string.sub( v, 1, 1 ) == "-" then
      local y = 2
      local l = string.len(v)
      local jopt
      while ( y <= l ) do
        jopt = string.sub( v, y, y )
        if string.find( options, jopt, 1, true ) then
          if y < l then
            tab[ jopt ] = string.sub( v, y+1 )
            y = l
          else
            tab[ jopt ] = arg[ k + 1 ]
          end
        else
          tab[ jopt ] = true
        end
        y = y + 1
      end
    end
  end
  return tab
end
 
function nextPoint( list, point )
        max_z = 0;
        for tx,rank in pairs(list) do
                for ty,col in pairs(rank) do
                        for tz,v in pairs(col) do
                                if( tz > max_z ) then
                                        max_z = tz;
                                end
                        end
                end
        end
        best=nil; dist=9999999999999999999999;
        for tz = point[3], max_z do
                for tx,rank in pairs(list) do
                        for ty,col in pairs(rank) do
                                if( col[ tz ] == 1 or col[tz] == -1 ) then
                                        d = dist3d( point, {tx,ty,tz} );
                                        if( best == nil or d < dist ) then
                                                best = {tx,ty,tz};
                                                dist = d;
                                        end
                                end
                        end
                end
                if( best ~= nil ) then
                        return best;
                end
        end
        return nil;
end

function dist3d( p1, p2 )
--      return math.sqrt( (p1[1]-p2[1])^2 + (p1[2]-p2[2])^2 + (p1[3]-p2[3])^2 );
-- Taxi geometry. THIS IS MINECRAFT.
        return math.abs( p1[1]-p2[1] ) + math.abs( p1[2]-p2[2] ) + math.abs( p1[3]-p2[3] );
end
 
function printModel( model, zskip, dryrun, verbose, match, material, final, dense )
	if( zskip == nil )    then zskip = 0;       end
	if( dryrun == nil )   then dryrun = 0;      end
	if( verbose == nil )  then verbose = false; end
	if( match == nil or match == 0 ) then match = false; end
	if( material == nil ) then material = 1;    end
	if( final == nil )    then final = true;    end
	if( dense == nil )    then dense = false;   end


	if( verbose and dense ) then print( "Using dense fill algorithm" ); end
	plist = {}
	
	if( dense ) then
		if( verbose ) then print( "dense first point selection" ); end;
		for cx,ylist in pairs(model) do
			for cy,zlist in pairs(ylist) do
				for cz,action in pairs(zlist) do
					if cz >= zskip then
						table.insert( plist, {cx,cy,cz,action} )
					end
				end
			end
		end
		sel_pt = nil;
		for k,pt in pairs(plist) do
			if( sel_pt == nil or 
			    pt[3] < plist[sel_pt][3] or 
			    pt[3] == plist[sel_pt][3] and pt[1] < plist[sel_pt][1] or 
			    pt[3] == plist[sel_pt][3] and pt[1] == plist[sel_pt][1] and pt[2] < plist[sel_pt][2] )
			then
				sel_pt = k;
			end
		end
		if sel_pt == nil then print( "no points found in model?!" ); return; end;
		point = plist[sel_pt];
		if(verbose) then print( "dense selected " .. textutils.serialise(point) ); end
		action = point[4];
		table.remove( plist, sel_pt );
	else
		point = nextPoint( model, { 0,0,zskip } );
		if(point == nil) then print("Error: No first point found"); end
		refpoint = point;
		if(verbose) then print( "Printing " .. point[1] .. "," .. point[2] .. "," .. point[3] ); end
		action = model[point[1]][point[2]][point[3]];
		model[point[1]][point[2]][point[3]]=2;
		-- if( not dryrun ) then goto( point[1], point[2], point[3] ); end
	end
	
	last_yield_time = os.time()

	modX = 1; modY = 1;
	
	while( point ~= nil ) do
		if( os.time() > last_yield_time ) then sleep(0); last_yield_time = os.time(); end
		if( verbose ) then print( table.concat( point, "," ) .. "=" .. action ); end
		if( not dryrun ) then
			goto( nil, nil, point[3]+1 );
			goto( point[1], point[2], nil );
		end
		if( not dryrun ) then
			if( action == 1 ) then
				placeBlockDown( material, match );
			else
				turtle.digDown();
			end
		end
	-- Find the next closest point from our reference.
	-- If it's distance>2, instead find the next closest point from here.
		if( dense ) then
			if( verbose ) then print( "dense subsequent point selection" ); end;
			sel_pt = nil;
			for k,pt in pairs(plist) do
				-- First pass, only look at blocks on the current working column.
				if( pt[1] == x and pt[3] == z-1 ) then
					if( sel_pt == nil or
					    ( modY == 1  and pt[2] <= plist[sel_pt][2] ) or
					    ( modY == -1 and pt[2] >= plist[sel_pt][2] ) )
					then
						sel_pt = k;
					end
				end
			end
			-- Second pass, look anywhere on this layer.
			if( sel_pt == nil ) then
				for k,pt in pairs(plist) do
					if( pt[3] == z-1 ) then
						if( sel_pt == nil or
						    ( modX == 1  and pt[1] < plist[sel_pt][1] ) or
						    ( modX == -1 and pt[1] > plist[sel_pt][1] ) )
						then
							sel_pt = k;
						elseif( pt[1] == plist[sel_pt][1] ) then
							-- Note, we inverted the relationship here, because if we
							-- change columns, we change direction.
							if( ( modY == 1  and pt[2] >= plist[sel_pt][2] ) or
							    ( modY == -1 and pt[2] <= plist[sel_pt][2] ) )
							then
								sel_pt = k;
							end
						end
					end
				end
				if( sel_pt ~= nil ) then
					modY = modY * -1;
				end
			end
			-- Third pass, look on other layers.
			if( sel_pt == nil ) then
				for k,pt in pairs(plist) do
					if( sel_pt == nil or pt[3] < plist[sel_pt][3] ) then
						sel_pt = k;
					elseif( pt[3] == plist[sel_pt][3] ) then
						-- Note that ase above, _both_ relationship tests are inverted
						if( ( modX == 1  and pt[1] > plist[sel_pt][1] ) or
						    ( modX == -1 and pt[1] < plist[sel_pt][1] ) )
						then
							sel_pt = k;
						elseif( pt[1] == plist[sel_pt][1] ) then
							if( ( modY == 1  and pt[1] >= plist[sel_pt][2] ) or
							    ( modY == -1 and pt[1] <= plist[sel_pt][2] ) )
							then
								sel_pt = k;
							end
						end
					end
				end
				if( sel_pt ~= nil ) then
					modY = modY * -1;
					modX = modX * -1;
				end
			end
			if( sel_pt == nil ) then break; end
			point = plist[sel_pt];
			action = point[4];
			table.remove( plist, sel_pt );
		else
			point = nextPoint( model, refpoint )
			if( point == nil ) then break; end
			if( dist3d( point, refpoint ) > 2 ) then
				point = nextPoint( model, point );
				refpoint = point;
			end
		end
		action = model[point[1]][point[2]][point[3]];
		model[point[1]][point[2]][point[3]]=2;
	end
	
	if( not dryrun and final ) then
		goto( homeX,homeY, nil );
		goto( nil, nil, z+1 );
		north();
	end
end
