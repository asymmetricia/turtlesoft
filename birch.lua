if( fs.exists( "/stdlib" ) ) then
  if dofile == nil then shell.run("/stdlib") else dofile( "/stdlib" ); end
else
  error( "dome: error: /stdlib missing" );
end

args = {...}
if( table.getn( args ) ~= 1) then
  error( "usage: birch <n>\nPlace turtle above sapling level one back from first tree position" );
end

trees = args[1];

for x=0,trees-1 do
  dx = x*5;
  for y=0,trees-1 do
    dy = y*5+1;
    goto(dx, dy, 0);
    placeBlockDown(1,1); -- place a sapling
    for z=1,7 do
      goto(dx,dy,dz); -- dig out the tree
    end
  end
end

goto(0,0,0);
north();
