if( fs.exists( "/stdlib" ) ) then
  if dofile == nil then shell.run("/stdlib") else dofile( "/stdlib" ); end
else
  error( "tunnel: error: /stdlib missing" );
end

function usage()
  print( "usage: tunnel -x <width> -y <length> -z <height> [-s <slope>] [-h <h-slope>] [-m] [-u]" );
  print( "  -m = block-matching, -u = unsafe & fast" );
  print( "  -s -- def slope is 0. slope is num/blocks per Z, >0 is up, <0 is down. 2 is a good value for walkways.")
  print( "  -h -- def hslope is 0. slope is num/blocks forward before one block right (h > 0) or left (h < 0). 1 is 45-degree tunnel.")
end

function sloped(y,slope)
  if(slope == 0) then
    return 0;
  elseif(slope>=0) then
    return math.floor((y-1)*slope)+1;
  else
    return math.ceil((y-1)*slope)-1;
  end
end

args = {...}
opts = getopt( args, "xyzsh" );

if     tonumber(opts["x"]) == nil then print( "-x (width) is required" ); usage(); return;
elseif tonumber(opts["y"]) == nil then print( "-y (length) is required" ); usage(); return;
elseif tonumber(opts["z"]) == nil then print( "-z (height) is required" ); usage(); return;
end

tunnel_x = tonumber(opts["x"]);
tunnel_y = tonumber(opts["y"]);
tunnel_z = tonumber(opts["z"]);

slope = 0
if opts["s"] ~= nil then
  if tonumber(opts["s"]) ~= nil and tonumber(opts["s"]) ~= 0 then
    slope = tonumber(opts["s"])
  else
    print( "-s (slope) must be numeric and non-zero" );
    usage(); return;
  end
end

hslope = 0
if opts["h"] ~= nil then
  if tonumber(opts["h"]) ~= nil and tonumber(opts["h"]) ~= 0 then
    hslope = tonumber(opts["h"])
  else
    print( "-h (h-slope) must be numeric and non-zero" );
    usage(); return;
  end
end

match = false
if opts["m"] ~= nil then print( "matching enabled." ); match = true; end

if opts["u"] ~= nil then
  if(slope ~= 0)  then slope  = 1 / slope;  end
  if(hslope ~= 0) then hslope = 1 / hslope; end
  print("I, too, like to live dangerously.");

  minX = -1
  maxX = tunnel_x
  if (hslope<0) then
    minX = -1 + sloped(tunnel_y, hslope)
  else
    maxX = tunnel_x + sloped(tunnel_y, hslope)
  end

  minY = 1
  maxY = tunnel_y

  minZ = -1
  maxZ = tunnel_z

  if (slope<0) then
    minZ = -1 + sloped(tunnel_y, slope)
  else
    maxZ = tunnel_z + sloped(tunnel_z, slope)
  end

  model = {}
  for tx = minX, maxX do
    model[tx] = {}
    for ty = minY, maxY do
      model[tx][ty] = {}
    end
    sleep(0);
  end

  -- Floor
  for ty = minY, maxY do
    xmod = sloped(ty, hslope)
    zmod = sloped(ty, slope)
    from = 0
    to   = tunnel_x - 1
    if (hslope ~= 0 and slope ~= 0) then
      from = -1
      to   = tunnel_x
    end
    for tx = from, to do
      model[tx+xmod][ty][zmod-1] = 1
      model[tx+xmod][ty][tunnel_z+zmod] = 1
    end
  end

  -- Walls
  for ty = minY, maxY do
    xmod = sloped(ty, hslope)
    zmod = sloped(ty, slope)
    for tz = 0, tunnel_z - 1 do
      model[-1+xmod][ty][tz+zmod] = 1
      for tx = 0, tunnel_x - 1 do
        model[tx+xmod][ty][tz+zmod] = -1
      end
      model[tunnel_x+xmod][ty][tz+zmod] = 1
    end
  end

  printModel( model, minZ, false, false, match, nil, false, false );

  if (slope > 0) then
    goto(nil, nil, sloped(maxY, slope) + tunnel_z + 1);
  end
  goto(sloped(maxY, hslope), maxY, nil);
  goto(nil, nil, tunnel_z-1+sloped(maxY, slope)); placeBlockUp(1,match);
  goto(nil, nil, sloped(maxY, slope));
  north();
else
  tunnel( tunnel_x, tunnel_y, tunnel_z, 1, slope, hslope, match );
end
