if( fs.exists( "/stdlib" ) ) then
  if dofile == nil then shell.run("/stdlib") else dofile( "/stdlib" ); end
else
  error( "drain: error: /stdlib missing" );
end

args = {...}
if( table.getn( args ) < 3 or table.getn( args ) > 5 ) then
  print( "usage: drain <x> <y> <depth> [<wall>] [<match>]" )
  print( "  progressively fill downward to drain lakes. depth 1 means the turtle will not leave the Z it starts on." )
  print( "  if wall is set, walls will be filled in too. if match is set, walls will match slot 1." )
  return;
end

wall  = table.getn(args) >= 4
match = table.getn(args) >= 5

mx=tonumber(args[1]); my=tonumber(args[2]); mz=-1*tonumber(args[3]);
tx=0; ty=0; tz=0;

dx=1; dy=1; dz=-1;

while true do
  goto(tx,ty,tz);
  if tz < 0 then
    if ty == (my-1) then north(); placeBlock(1,match); end
    if tx == (mx-1) then east();  placeBlock(1,match); end
    if ty == 0      then south(); placeBlock(1,match); end
    if tx == 0      then west();  placeBlock(1,match); end
  end
  if tz > mz then
    placeBlockDown(1, false)
  end

  ty = ty + dy;
  if ty >= my or ty < 0 then
    ty = ty - dy;
    dy = -1 * dy;
    tx = tx + dx;
    if tx >= mx or tx < 0 then
      tx = tx - dx;
      dx = -1 * dx;
      tz = tz + dz;
      if tz < mz then
        break;
      end
    end
  end
end

goto(0,0,0);
north();
