args = {...}
opts = getopt( args, "" );

base_url = "https://raw.githubusercontent.com/pdbogen/turtlesoft/master/";

files = {}
files["/d"]        = "dome.lua";
files["/f"]        = "fill.lua";
files["/hypstruc"] = "hyperboloid-structure.lua";
files["/m"]        = "mine.lua";
files["/recroom"]  = "rectangular-room.lua";
files["/r"]        = "roof.lua";
files["/sc"]       = "staircase.lua";
files["/stdlib"]   = "stdlib.lua";
files["/t"]        = "tunnel.lua";
files["/unload"]   = "unload.lua";
files["/update"]   = "update.lua";
files["/w"]        = "wall.lua";

for f,u in ipairs( files ) do
	if( not ( opts[ "soft" ] and fs.exists( f ) ) ) then
		fs.delete( f );
		httpDownload( base_url .. u, f );
	end
end
