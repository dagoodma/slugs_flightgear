function sendWPToFlightgear(u, lat,lon,alt, command)
%SENDWPTOFLIGHTGEAR
%   Sends a waypoint with the given lat, lon, and altitude in meters to a
%   flightgear UDP stream u.

if (nargin < 5)
    command = '0';
end

fwrite(u,sprintf('%f,%f@%.0f\t%s\t0\t0\t0\n',lon,lat,...
    (alt * 3.28084 ), command));

end

