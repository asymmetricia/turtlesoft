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
  -- dig out sideways
  newMineArea( tonumber(args[1]), 1, 3, 0 );

  -- return to row origin
  goto(0,ty,0);

  -- dig out straight
  newMineArea( 1, 3, 3, 0 );

  -- place torches
  for tx=0,tonumber(args[1]),7 do
    goto(tx, ty, 1);
    placeBlockDown(1, true);
  end

  -- return to row origin
  goto(0,ty,1);

  -- advanaced forward
  goto(0,ty+3,1);

  -- reset downward
  goto(0,ty+3,0);
end

north();
