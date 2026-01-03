if( fs.exists( "/stdlib" ) ) then
  if dofile == nil then shell.run("/stdlib") else dofile( "/stdlib" ); end
else
  error( "dome: error: /stdlib missing" );
end

args = {...}
if( table.getn( args ) < 2 or table.getn( args ) > 2 ) then
  error( "usage: expo <x> <y>" );
end

for ty=0,tonumber(args[2]),3 do
  for tx=0,tonumber(args[1]) do
    goto(tx, ty, 1);
    east();
    dig(true, true, true, true);
    if( tx % 7 == 0 ) then
      placeBlockDown(1, true);
    end
  end
  goto(0, ty, 1);
end

goto(0, tonumber(args[2])+1, 1);
goto(0, tonumber(args[2])+1, 0);

north();
