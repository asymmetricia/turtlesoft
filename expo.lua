if( fs.exists( "/stdlib" ) ) then
  if dofile == nil then shell.run("/stdlib") else dofile( "/stdlib" ); end
else
  error( "dome: error: /stdlib missing" );
end

args = {...}
if( table.getn( args ) < 2 or table.getn( args ) > 2 ) then
  error( "usage: expo <x> <y>" );
end

-- dig forward
newMineArea( 1, tonumber(args[2]), 3, 0 );

for ty=0,tonumber(args[2]),3 do
  goto(0,ty,0);
  newMineArea( tonumber(args[1]), 16, 3, 0 );
end

goto(0,0,0);
north();
