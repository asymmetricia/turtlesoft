local response = http.get( "https://raw.githubusercontent.com/asymmetricia/turtlesoft/main/stdlib.lua" );
if response then
  local sResponse = response.readAll(); response.close(); local file = fs.open( "/stdlib", "w" ); file.write( sResponse ); file.close();
else
  error( "Error retrieving stdlib" );
end

if dofile == nil then shell.run("/stdlib") else dofile( "/stdlib" ); end

args = {...}
opts = getopt( args, "" );

base_url = "https://raw.githubusercontent.com/asymmetricia/turtlesoft/main/";

files = {}
files["/birch"]    = "birch.lua";
files["/d"]        = "dome.lua";
files["/drain"]    = "drain.lua";
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
files["/reac"]     = "rc/rc.lua";

for f,u in pairs( files ) do
  if( not ( opts[ "soft" ] and fs.exists( f ) ) ) then
    print( "Retrieving " .. base_url .. u );
    fs.delete( f );
    httpDownload( base_url .. u, f );
  end
end
