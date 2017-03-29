function InitializeGlobal()
%ModifyStrategy - Calculate the convert rate at crossroads (no VMS)
%
% Syntax:  [~] = Main(curDay)
%
% Inputs:
%    curDay - Current day(args)        
%
% Outputs:
%    none
%
% Example: 
%    none
%
% Other m-files required: turningChoice.mat, complianceRate.mat
% Subfunctions: none
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2016.02; Last revision: 2016.02.10

%------------- BEGIN CODE --------------

%--- Templates of static struct ---
global Vehicle;
global Crossroad;
% Define Vehicle
Vehicle = struct('ID', 0, ...
				 'size', [3, 1.8], ...  % length, width (unit: m)
				 'type', 1, ...  % non-auto: 0; auto: 1
				 'dynamic', [15, 0, 30, 1.5], ...  % speed (m/s), acceleration (m/s^2), max speed (m/s), max acceleration (m/s^2)
				 'route', [1, 1, 2], ... % crossID, start entrance, end entrance
				 'position', [1, 0, 0, 0], ...  % crossID, centerX (m), centerY (m), direction (degree)
				 'laneTrace', [], ...  %
				 'crossTrace', zeros(1, 7) ...  % time, crossID, entranceID, laneID, centerX, centerY, direction
				 );
% Define Schedule
Crossroad = struct('signal', [3, 20, 0.3, 0.15, 0.3, 0.15], ... % phase, cycle length, 1&5 s/r, 1&5 l, 3&7 s/r, 3&7 l
				   'dir_1_2', [30, 2, 3.75], ... % length, lane number, lane width (unit: meter)
				   'dir_3_4', [30, 2, 3.75], ... % length, lane number, lane width (unit: meter)
				   'dir_5_6', [30, 2, 3.75], ... % length, lane number, lane width (unit: meter)
				   'dir_7_8', [30, 2, 3.75], ... % length, lane number, lane width (unit: meter)
				   'turningR', 10 ... % radius of the circular bead
				   );

%--- Dynamic ---
global VehicleList;
global Schedule;
% Initialize dynamic variables
VehicleList = Vehicle;
Schedule = zeros(0, 3); % crossID, vehicleID, status (0: outside crossroad area; 1: inside crossroad area)

%--- Navigation parameters ---
global xRange;
global xScale;
global xLeftNum;
global xRightNum;
global yRange;
global yScale;
global yDownNum;
global yUpNum;
global dirScale;
global dirRange;
global distNum;
global timeScale;
global maxSpeed;
global maxTurn;
% Horizontal Position
xRange = [-Crossroad.dir_5_6(2)*Crossroad.dir_5_6(3), Crossroad.dir_1_2(2)*Crossroad.dir_1_2(3)];
xScale = 0.1;
xLeftNum = abs(fix(xRange(1)/xScale));
xRightNum = fix(xRange(2)/xScale);
xNum = xLeftNum + xRightNum + 1;
% Vertical Position
yRange = [-Crossroad.dir_7_8(2)*Crossroad.dir_7_8(3), Crossroad.dir_3_4(2)*Crossroad.dir_3_4(3)];
yScale = 0.1;
yDownNum = abs(fix(yRange(1)/yScale));
yUpNum = fix(yRange(2)/yScale);
yNum = yUpNum + yDownNum + 1;
% Direction
dirRange = [0, 360];
dirScale = 5;
dirNum = floor((dirRange(2)-dirRange(1))/dirScale) + 1;
% Distance to the front vehicle
distNum = 2;	% 0: safe, 1: unsafe
% Time of per simulation (unit: s)
timeScale = 0.1;
% Limit of action
maxSpeed = 10;
maxTurn = 30;

%--- Others ---
global QMatrix;
global curTime;
% QMatrix
if ~exist('QMatrix.mat')
	QMatrix = zeros(xNum, yNum, dirNum, distNum);
else
	load 'QMatrix.mat';
end

%------------- END OF CODE --------------
end




