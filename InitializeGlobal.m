function InitializeGlobal()
%InitializeGlobal - Initialize global variables
%
% Syntax:  [~] = InitializeGlobal()
%
% Inputs:
%    none      
%
% Outputs:
%    none
%
% Example: 
%    none
%
% Other m-files required: none
% Subfunctions: CalExceedType, UpdateQMatrix
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.03; Last revision: 2017.04.10

%------------- BEGIN CODE --------------

%--- Templates of static struct ---
global Vehicle;
global Crossroad;
% Define Vehicle
Vehicle = struct('ID', 0, ...
				 'size', [3, 1.8], ...  % length, width (unit: m)
				 'type', 1, ...  % non-auto: 0; auto: 1
				 'route', [1, 2], ... % start entrance, end entrance
				 'position', [0, 0, 0], ...  % centerX (m), centerY (m), direction (degree)
				 'trace', zeros(1, 5), ...  % time, centerX (m), centerY (m), direction (degree)
				 'state', 1 ...	% outside the crossroad: 0, inside the crossroad: 1
				 );
% Define Crossroad
Crossroad = struct('signal', [0, 120, 0.3, 0.15, 0.3, 0.15], ... % phase, cycle length, 1&5 s/r, 1&5 l, 3&7 s/r, 3&7 l
				   'dir_1_2', [30, 2, 3.75], ... % length, lane number, lane width (unit: meter)
				   'dir_3_4', [30, 2, 3.75], ... % length, lane number, lane width (unit: meter)
				   'dir_5_6', [30, 2, 3.75], ... % length, lane number, lane width (unit: meter)
				   'dir_7_8', [30, 2, 3.75], ... % length, lane number, lane width (unit: meter)
				   'turningR', 10 ... % radius of the circular bead
				   );
if exist('signalStrategy.mat')
	load 'signalStrategy.mat';
	Crossroad.signal = signalStrategy;
end

%--- Simulation variables ---
global VehicleList;
global curTime;
global startTime;
global endTime;
global timeStep;
% Initialize dynamic variables
VehicleList = Vehicle;
% Initialize simulation parameters
startTime = 0;
endTime = 1000;
timeStep = 0.5;

%--- Q-learning variables ---
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
global maxAcc;
global QMatrix;
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
timeScale = 0.3;
% Limit of action
maxAcc = 10;
% QMatrix
if ~exist('QMatrix.mat')
	QMatrix = -Inf*ones(xNum, yNum, dirNum, distNum);
	for x = -xLeftNum*xScale:xScale:xRightNum*xScale
		for y = -yDownNum*yScale:yScale:yUpNum*yScale
			if CalExceedType(x, y) == 0
				for dir = 90:dirScale:180
					UpdateQMatrix([x, y, dir, 0], 0);
				end
			end
		end
	end
else
	load 'QMatrix.mat';
end

%------------- END OF CODE --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Decide whether the agent has exceeded boundaries ---
function exceedType = CalExceedType(x, y)
	% Set global variable(s)	
	global xRange;
	global yRange;
	% Initialize variable(s)
	exceedType = 0;
	% Judge whether the agent is outside the boundary of quadrant 3
	if x<=0 && y<=0 && x^2/(abs(xRange(1))-1)^2+y^2/(yRange(1))^2 > 1
		exceedType = 1;
	% Judge whether the agent is outside the boundary of quadrant 1, 2, 4
	elseif yRange(2)*x + xRange(2)*y > 0 || x > xRange(2)/2
		exceedType = 2;
	end
end

%--- Update state in Q matrix ---
function UpdateQMatrix(state, QValue)
	% Set global variable(s)	
	global QMatrix;
	global xScale;
	global xLeftNum;
	global yScale;
	global yDownNum;
	global dirScale;
	% Calculate index of xPosition
	xIndex = fix(state(1)/xScale)+xLeftNum+1;
	% Calculate index of yPosition
	yIndex = fix(state(2)/yScale)+yDownNum+1;
	% Calculate index of direction
	dirIndex = fix(state(3)/dirScale)+1;
	% Calculate index of distance status
	distIndex = state(4)+1;
	% Calculate the value in Q matrix
	QMatrix(xIndex, yIndex, dirIndex, distIndex) = QValue;
end

%------------- END OF SUBFUNCTION(S) --------------