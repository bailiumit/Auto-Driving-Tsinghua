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
% Subfunctions: CalExceedType, UpdateQMatrix, CalCorner
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.03; Last revision: 2017.05.11

%------------- BEGIN CODE --------------

%--- Templates of static struct ---
global Vehicle;
global Crossroad;
global maxV;
global maxAcc;
global minAcc;
% Define Vehicle
Vehicle = struct('ID', 0, ...
				 'size', [3, 1.8], ...  % length, width (unit: m)
				 'type', 1, ...  % non-auto: 0; auto: 1
				 'route', [1, 2], ... % start entrance, end entrance
				 'dynamic', [5, 0], ... % speed (m/s), acceleration (m/s^2)
				 'position', [0, 0, 0], ...  % centerX (m), centerY (m), direction (degree)
				 'trace', zeros(1, 4), ...  % time, centerX (m), centerY (m), direction (degree)
				 'state', 0 ...	% outside the crossroad: -1, have not started: 0, inside the crossroad: 1
				 );
% Define Crossroad
Crossroad = struct('signal', [0, 5000, 0.25, 0.25, 0.25, 0.25], ... % phase, cycle length, 1&5 s/r, 1&5 l, 3&7 s/r, 3&7 l
				   'dir_1_2', [30, 3, 3.75], ... % length, lane number, lane width (unit: meter)
				   'dir_3_4', [30, 3, 3.75], ... % length, lane number, lane width (unit: meter)
				   'dir_5_6', [30, 3, 3.75], ... % length, lane number, lane width (unit: meter)
				   'dir_7_8', [30, 3, 3.75], ... % length, lane number, lane width (unit: meter)
				   'turningR', 3, ... % radius of the circular bead
				   'corner_1_8', [10, -10, 11, 11, 17], ... % center x, center y, x axis, y axis, length
				   'corner_3_2', [10, 10, 11, 11, 17], ... % center x, center y, x axis, y axis, length
				   'corner_5_4', [-10, 10, 11, 11, 17], ... % center x, center y, x axis, y axis, length
				   'corner_7_6', [-10, -10, 11, 11, 17], ... % center x, center y, x axis, y axis, length
				   'corner_1_4', [-10, -10, 11, 11, 17], ... % center x, center y, x axis, y axis, length
				   'corner_3_6', [10, -10, 11, 11, 17], ... % center x, center y, x axis, y axis, length
				   'corner_5_8', [10, 10, 11, 11, 17], ... % center x, center y, x axis, y axis, length
				   'corner_7_2', [-10, 10, 11, 11, 17] ... % center x, center y, x axis, y axis, length
				   );
Crossroad.corner_1_8 = CalCorner(18);
Crossroad.corner_3_2 = CalCorner(32);
Crossroad.corner_5_4 = CalCorner(54);
Crossroad.corner_7_6 = CalCorner(76);
Crossroad.corner_1_4 = CalCorner(14);
Crossroad.corner_3_6 = CalCorner(36);
Crossroad.corner_5_8 = CalCorner(58);
Crossroad.corner_7_2 = CalCorner(72);
% cd('MatFile');
% if exist('Signal.mat')
% 	load 'Signal.mat';
% 	Crossroad.signal = optSignal;
% end
% cd('..');
% Limit of action
maxV = 8;
maxAcc = 5;
minAcc = -6;

%--- Simulation variables ---
global VehicleList;
global startTime;
global endTime;
global timeStep;
global autoRatio;
% Initialize dynamic variables
VehicleList = Vehicle;
% Initialize simulation parameters
startTime = 0;
endTime = 1000;
timeStep = 1;
autoRatio = 0.5;

%--- Turning optimization training variables ---
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
timeScale = 0.2;
% QMatrix
cd('MatFile');
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
cd('..');

%--- Line optimization training variables ---
global intScale;
global intRange;
global intNum;
global vScale;
global vRange;
global vNum;
global timeScaleM;
global QMatrixLine;
% Interval
intScale = 0.1;
intRange = [0, 20];
intNum = floor((intRange(2)-intRange(1))/intScale) + 1;
% Speed
vScale = 0.1;
vRange = [0, maxV];
vNum = floor((vRange(2)-vRange(1))/vScale) + 1;
% Time of per simulation (unit: s)
timeScaleM = 0.2;
% QMatrixLine
cd('MatFile');
if ~exist('QMatrixLine.mat')
	QMatrixLine = zeros(2, intNum, vNum, vNum);
else
	load 'QMatrixLine.mat';
end
cd('..');

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

%--- Calculate the parameters of corner ---
function cornerPara = CalCorner(index)
	% Set global variable(s)
	global Crossroad;
	% Calculate center and axes
	switch index
		case 18
			centerX = Crossroad.dir_1_2(2)*Crossroad.dir_1_2(3)+Crossroad.turningR;
			centerY = -(Crossroad.dir_7_8(2)*Crossroad.dir_7_8(3)+Crossroad.turningR);
			xAxis = Crossroad.turningR+Crossroad.dir_1_2(3)/2;
			yAxis = Crossroad.turningR+Crossroad.dir_7_8(3)/2;
		case 32
			centerX = Crossroad.dir_1_2(2)*Crossroad.dir_1_2(3)+Crossroad.turningR;
			centerY = Crossroad.dir_3_4(2)*Crossroad.dir_3_4(3)+Crossroad.turningR;
			xAxis = Crossroad.turningR+Crossroad.dir_1_2(3)/2;
			yAxis = Crossroad.turningR+Crossroad.dir_3_4(3)/2;
		case 54
			centerX = -(Crossroad.dir_5_6(2)*Crossroad.dir_5_6(3)+Crossroad.turningR);
			centerY = Crossroad.dir_3_4(2)*Crossroad.dir_3_4(3)+Crossroad.turningR;
			xAxis = Crossroad.turningR+Crossroad.dir_5_6(3)/2;
			yAxis = Crossroad.turningR+Crossroad.dir_3_4(3)/2;
		case 76
			centerX = -(Crossroad.dir_5_6(2)*Crossroad.dir_5_6(3)+Crossroad.turningR);
			centerY = -(Crossroad.dir_7_8(2)*Crossroad.dir_7_8(3)+Crossroad.turningR);
			xAxis = Crossroad.turningR+Crossroad.dir_5_6(3)/2;
			yAxis = Crossroad.turningR+Crossroad.dir_7_8(3)/2;
		case 14
			centerX = -(Crossroad.dir_5_6(2)*Crossroad.dir_5_6(3)+Crossroad.turningR);
			centerY = -(Crossroad.dir_7_8(2)*Crossroad.dir_7_8(3)+Crossroad.turningR);
			xAxis = Crossroad.turningR+Crossroad.dir_1_2(3)/2+Crossroad.dir_5_6(2)*Crossroad.dir_5_6(3);
			yAxis = Crossroad.turningR+Crossroad.dir_3_4(3)*3/2+Crossroad.dir_7_8(2)*Crossroad.dir_7_8(3);
		case 36
			centerX = Crossroad.dir_1_2(2)*Crossroad.dir_1_2(3)+Crossroad.turningR;
			centerY = -(Crossroad.dir_7_8(2)*Crossroad.dir_7_8(3)+Crossroad.turningR);
			xAxis = Crossroad.turningR+Crossroad.dir_5_6(3)*3/2+Crossroad.dir_1_2(2)*Crossroad.dir_1_2(3);
			yAxis = Crossroad.turningR+Crossroad.dir_3_4(3)/2+Crossroad.dir_7_8(2)*Crossroad.dir_7_8(3);
		case 58
			centerX = Crossroad.dir_1_2(2)*Crossroad.dir_1_2(3)+Crossroad.turningR;
			centerY = Crossroad.dir_3_4(2)*Crossroad.dir_3_4(3)+Crossroad.turningR;
			xAxis = Crossroad.turningR+Crossroad.dir_5_6(3)/2+Crossroad.dir_1_2(2)*Crossroad.dir_1_2(3);
			yAxis = Crossroad.turningR+Crossroad.dir_7_8(3)*3/2+Crossroad.dir_3_4(2)*Crossroad.dir_3_4(3);
		case 72
			centerX = -(Crossroad.dir_5_6(2)*Crossroad.dir_5_6(3)+Crossroad.turningR);
			centerY = Crossroad.dir_3_4(2)*Crossroad.dir_3_4(3)+Crossroad.turningR;
			xAxis = Crossroad.turningR+Crossroad.dir_1_2(3)*3/2+Crossroad.dir_5_6(2)*Crossroad.dir_5_6(3);
			yAxis = Crossroad.turningR+Crossroad.dir_7_8(3)/2+Crossroad.dir_3_4(2)*Crossroad.dir_3_4(3);
		otherwise
			disp('Error in InitializeGlobal() -> CalCorner()');
	end
	% Calculate the length of quarter perimeter
	L = pi/32*(9*(xAxis+yAxis)-5*sqrt(xAxis*yAxis)+3*sqrt((xAxis^2+yAxis^2)/2));
	% Assemble parameters
	cornerPara = [centerX, centerY, xAxis, yAxis, L];
end

%------------- END OF SUBFUNCTION(S) --------------