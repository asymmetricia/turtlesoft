if( fs.exists( "/stdlib" ) ) then
	if dofile == nil then shell.run("/stdlib") else dofile( "/stdlib" ); end
else
	print( "dome: error: /stdlib missing" );
	exit();
end

south();
for s=1,16 do	
	turtle.select(s);
	turtle.drop();
end
north();
