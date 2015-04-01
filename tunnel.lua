if( fs.exists( "/stdlib" ) ) then
	dofile( "/stdlib" );
else
	print( "dome: error: /stdlib missing" );
	exit();
end

args = {...}
if( table.getn( args ) ~= 3 ) then
	print( "usage: tunnel <count> <xdim> <zdim>" );
	return;
end

if( args[1] ) then
	for i=1,args[1] do
		tunnelOne( args[2], args[3] );
		north();
	end
end
