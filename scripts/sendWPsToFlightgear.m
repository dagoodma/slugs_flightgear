%SENDWPSTOFLIGHTGEAR Sends all waypoints to flightgear
%   Sends all waypoints in waypoint array along with initial point (GS) to
%   flightgear via the UDP stream u that must be defined in the path.

PORT = 56832; 
CLOSE_LOOP = 1; % sends the first waypoint again at the end to close the loop

if ~exist('LatPoints','var') || ~exist('LonPoints','var') || ~exist('AltPoints','var') || ~isvector(LatPoints) || ~isvector(LonPoints) || ~isvector(AltPoints) 
    error('No waypoints were defined.');
end
wpCount = length(LatPoints);
if wpCount < 1
    disp('No waypoints to send to flightgear.');
    return;
end

% Make udp connection
u = udp('127.0.0.1',PORT);
fopen(u);
pause(1);
if ~exist('u','var') || ~strcmp(class(u),'udp')
    error('Failed to create a udp socket.');
end

disp('Sending waypoints to flightgear...');

% Load waypoints and clear old ones
sendWPCommandToFlightgear(u,'@CLEAR'); % clear existing waypoints
pause(0.2);
sendWPCommandToFlightgear(u,'@DELETE0'); % clear airport
pause(0.2);

% Send each waypoint
for i=1:wpCount
    sendWPToFlightgear(u,LatPoints(i),LonPoints(i), AltPoints(i));
    pause(0.2);
end

% Send WP1 to close loop
if (CLOSE_LOOP)
    sendWPToFlightgear(u,LatPoints(1),LonPoints(1), AltPoints(1));
    wpCount = wpCount + 1;
end
pause(0.2);

sendWPCommandToFlightgear(u,'waypoint'); % draws all waypoints and legs
pause(0.2);


fprintf('Sent %d waypoints to flightgear to be drawn.\n',wpCount);

