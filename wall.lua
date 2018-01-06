if( fs.exists( "/stdlib" ) ) then
	if dofile == nil then shell.run("/stdlib") else dofile( "/stdlib" ); end
else
  print( "wall: error: /stdlib missing" );
  exit();
end

args = {...}
if( table.getn( args ) < 3 or table.getn( args ) > 4 ) then
  print( "usage: wall {left,right} <y> <z> [<match>]" );
  exit();
end

if( table.getn( args ) < 4 ) then
  match = 0;
else
  match = 1;
end

tx=0; ty=0; tz=0;

target_z = tonumber(args[3])
delta_z  = (target_z > 0 and 1) or -1

while true do
  if( args[1] == "left" ) then
    west();
  else
    east();
  end

  placeBlock( 1, match );

  if( y % 2 == 0 ) then
    -- even Y
    tz=tz+delta_z;
    if( tz*delta_z >= target_z*delta_z ) then
      tz=tz-delta_z;
      ty=ty+1;
    end
  else
    -- odd Y
    tz=tz-delta_z;
    if( tz*delta_z < 0 ) then
      tz=tz+delta_z
      ty=ty+1
    end
  end
  if( ty >= tonumber(args[2]) ) then
    goto(0,0,0);
    north();
    break;
  end
  goto( tx, ty, tz );
end
