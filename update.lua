args = {...}
opts = getopt( args, "" );

base_url = "https://raw.githubusercontent.com/pdbogen/turtlesoft/master/";

files = { "/d" = "dome.lua", "/f" = "fill.lua", "/hypstruc" = "hyperboloid-structure.lua", "/m" = "mine.lua", "/recroom" = "rectangular-room.lua", "/r" = "roof.lua", "/sc" = "staircase.lua", "/stdlib" = "stdlib.lua", "/t" = "tunnel.lua", "/unload" = "unload.lua", "/update" = "update.lua", "/w" = "wall.lua", }

for f,u in ipairs( files ) do
	if( not ( opts[ "soft" ] and fs.exists( f ) ) ) then
		fs.delete( f );
		httpDownload( base_url .. u, f );
	end
end
