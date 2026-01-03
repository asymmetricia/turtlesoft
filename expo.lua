if( fs.exists( "/stdlib" ) ) then
  if dofile == nil then shell.run("/stdlib") else dofile( "/stdlib" ); end
else
  error( "dome: error: /stdlib missing" );
end

args = {...}
if( table.getn( args ) < 2 or table.getn( args ) > 2 ) then
  error( "usage: expo <x> <y>" );
end

function unload()
  sx=x;
  sy=y;
  sz=z;
  goto(x, y, 1);
  goto(0, y, 1);
  goto(0, -1, 1);
  if (turtle.detectDown()) then
    for s=2,16 do
      turtle.select(s);
      turtle.dropDown();
    end
  end

  if (not checkSpace()) then
    goto(0, 0, 1);
    goto(0, 0, 0);
    error("NO CHEST OR NO ROOM IN CHEST");
  end

  goto(0, sy, 1);
  goto(sx, sy, 1);
  goto(sx, sy, sz);
end

for ty=0,tonumber(args[2]) do
  -- advance and dig up/down/forward
  goto(0, ty, 1);
  if ( not dig(true, true, true) ) then
    unload();
    if ( not dig(true, true, true) ) then
      -- shouldn't really happen, bail out
      goto(0, 0, 0);
      error("dig failed even after unloading");
    end
  end

  if( ty % 3 == 0 ) then
    for tx=0,tonumber(args[1]) do
      -- advance sideways
      goto(tx, ty, 1);
      east();

      -- dig out
      if ( not dig(tx < tonumber(args[1]), true, true) ) then
        unload();
        if ( not dig(tx < tonumber(args[1]), true, true) ) then
          goto(0, 0, 0);
          error("dig failed even after unloading");
        end
      end

      -- place torch on sevens
      if( tx % 7 == 0 ) then
        placeBlockDown(1, true);
      end
    end

    -- reset to row start, run along top for convenience
    goto(x, y, 2);
    goto(0, ty, 2);
    goto(0, ty, 1);
  end
end

goto(0, tonumber(args[2])+1, 1);
goto(0, tonumber(args[2])+1, 0);

north();
