if( fs.exists( "/stdlib" ) ) then
	if dofile == nil then shell.run("/stdlib") else dofile( "/stdlib" ); end
else
	print( "dome: error: /stdlib missing" );
	exit();
end

args = {...}
if( table.getn( args ) ~= 2 ) then
	print( "usage: staircase {up|down} <n>" );
	exit();
end
print( args[1].." "..args[2] );

for i=1,args[2] do
	if args[1] == "down" then
		staircaseDown();
	else
		staircaseUp();
	end
end
