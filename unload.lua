if( fs.exists( "/stdlib" ) ) then
	dofile( "/stdlib" );
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
