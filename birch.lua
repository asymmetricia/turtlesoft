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

max=trees-1

for dx=0,max*5,10 do
  for dy=1,max*5+1,10 do
    goto(dx, dy, 0);     -- goto next tree
    placeBlockDown(1,1); -- place a sapling
    goto(dx, dy, 7);     -- mine out the tree
    if( dy+5 <= max*5+1 ) then
      goto(dx, dy+5, 7);   -- move to next tree
      goto(dx, dy+5, 0);   -- mine out the tree
      placeBlockDown(1,1); -- place a sapling
    end
  end
  if (dx+5 <= max) then
    for dy=max*5+1,1,-10 do
      goto(dx+5, dy, 7);     -- goto next tree
      goto(dx+5, dy, 0);     -- mine out the tree
      placeBlockDown(1,1); -- place a sapling
      if( dy-5 >= 1) then
        goto(dx+5, dy-5, 0);   -- mine out the tree
        placeBlockDown(1,1); -- place a sapling
        goto(dx+5, dy-5, 7);   -- move to next tree
      end
    end
  end
end

goto(0,0,0);
north();
