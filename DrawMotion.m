function DrawMotion()
%DrawMotion - Draw the animation of the motion of vehicles 
%
% Syntax:  [~] = DrawMotion()
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
% Subfunctions: 
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.05; Last revision: 2017.06.04

%------------- BEGIN MAIN FUNCTION --------------

%--- Set global variable(s) ---
global VehicleList;
global PositionCell;
global startTime;
global endTime;
global timeStep;
global frameTime;
global handle;
global drawRange;

%--- Initialize variable(s) ---
drawRange = [-20, 20, -20, 20];
frameTime = timeStep/5;

%--- Display the animation ---
axis(drawRange);
grid on;
hold on;
for i = 1:1:size(PositionCell, 1)	
	% Initialize variable(s)
	positionTable = PositionCell{i, 1};
	curTime = startTime+(i-1)*timeStep;
	% Display current information
	title(['Time: ', num2str(curTime)],'fontsize',14);
	% Draw vehicle positions
	vehicleHandle = DrawVehicle(positionTable);
	pause(frameTime);
	DeleteVehicle(vehicleHandle)
end

%------------- END OF MAIN FUNCTION --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Draw vehicle positions ---
function vehicleHandle = DrawVehicle(positionTable)
	% Set global variable(s)
	global VehicleList;
	% Initialize variable(s)
	vehicleNum = size(positionTable, 1);
	vehicleHandle = cell(vehicleNum, 1);
	% Draw vehicles onto the figure
	for i = 1:1:vehicleNum
		% Initialize variable(s)
		index = positionTable(i, 1);
		x = positionTable(i, 2);
		y = positionTable(i, 3);
		rad = positionTable(i, 4)/180*pi;
		radC = rad-pi/2;
		l = VehicleList(index).size(1);
		d = VehicleList(index).size(2);
		vType = VehicleList(index).type;
		% Calculate the position of endpoints
		X = zeros(1, 4);
		Y = zeros(1, 4);
		X(1) = x + l/2*cos(rad) + d/2*cos(radC);
		Y(1) = y + l/2*sin(rad) + d/2*sin(radC);
		X(2) = x + l/2*cos(rad) - d/2*cos(radC);
		Y(2) = y + l/2*sin(rad) - d/2*sin(radC);
		X(3) = x - l/2*cos(rad) - d/2*cos(radC);
		Y(3) = y - l/2*sin(rad) - d/2*sin(radC);
		X(4) = x - l/2*cos(rad) + d/2*cos(radC);
		Y(4) = y - l/2*sin(rad) + d/2*sin(radC);
		% Decide the color of the vehicle
		if vType == 1
			colorSpec = [227, 107, 84]/255;
		else
			colorSpec = [75, 145, 194]/255;
		end
		% Draw the vehicles
		vehicleHandle{i, 1} = fill(X, Y, colorSpec);
	end
end

%--- Remove vehicles from the figure ---
function DeleteVehicle(vehicleHandle)
	% Delete vehicle handles
	for i = 1:1:size(vehicleHandle, 1)
		delete(vehicleHandle{i, 1});
	end
end

%------------- END OF SUBFUNCTION(S) --------------