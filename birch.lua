if( fs.exists( "/stdlib" ) ) then
  if dofile == nil then shell.run("/stdlib") else dofile( "/stdlib" ); end
else
  error( "birch: error: /stdlib missing" );
end

args = {...}
if( table.getn( args ) < 1 or table.getn(args) > 2) then
  print( "birch: usage: birch <n> [dense]\n       Place turtle above sapling level one back from first tree position\n       If dense, saplings in 1, torches in 2" );
  return;
end

trees = args[1];

max=trees-1

if( table.getn( args ) == 1 ) then
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
    if (dx+5 <= max*5) then
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
else
  newMineArea(max*5+1, max*5+1, 7, 0);
  for dx=0,max*5,2 do
    for dy=1, max*5+1 do
      if( (dy - 1 + dx*2) % 5 == 0 ) then
        placeBlockDown(2,1);
      else
        placeBlockDown(1,1);
      end
    end
  end
end

goto(0,0,0);
north();
