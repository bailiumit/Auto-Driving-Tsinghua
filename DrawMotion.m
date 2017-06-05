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
% 2017.05; Last revision: 2017.06.05

%------------- BEGIN MAIN FUNCTION --------------

%--- Set global variable(s) ---
global Crossroad;
global VehicleList;
global PositionCell;
global startTime;
global endTime;
global timeStep;
global frameTime;
global handle;
global drawRange;

%--- Initialize variable(s) ---
drawRange = [-25, 25, -25, 25];
frameTime = timeStep/5;
cornerR = Crossroad.turningR;

%--- Set axis ---
axis(drawRange);
axis off;
hold on;

%--- Draw road(s) ---
% Draw line 1
lineLane_1_side = line([3.75*3, 3.75*3], [drawRange(1), -3.75*3-cornerR], 'LineWidth', 2, 'Color', 'k');
lineLane_1_middle_1 = line([3.75*1, 3.75*1], [drawRange(1), -3.75*3-cornerR], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
lineLane_1_middle_2 = line([3.75*2, 3.75*2], [drawRange(1), -3.75*3-cornerR], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
% Draw line 2
lineLane_2_side = line([3.75*3, 3.75*3], [drawRange(2), 3.75*3+cornerR], 'LineWidth', 2, 'Color', 'k');
lineLane_2_middle_1 = line([3.75*1, 3.75*1], [drawRange(2), 3.75*3+cornerR], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
lineLane_2_middle_2 = line([3.75*2, 3.75*2], [drawRange(2), 3.75*3+cornerR], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
% Draw line 3
lineLane_3_side = line([drawRange(4), 3.75*3+cornerR], [3.75*3, 3.75*3], 'LineWidth', 2, 'Color', 'k');
lineLane_3_middle_1 = line([drawRange(4), 3.75*3+cornerR], [3.75*1, 3.75*1], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
lineLane_3_middle_2 = line([drawRange(4), 3.75*3+cornerR], [3.75*2, 3.75*2], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
% Draw line 4
lineLane_4_side = line([drawRange(3), -3.75*3-cornerR], [3.75*3, 3.75*3], 'LineWidth', 2, 'Color', 'k');
lineLane_4_middle_1 = line([drawRange(3), -3.75*3-cornerR], [3.75*1, 3.75*1], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
lineLane_4_middle_2 = line([drawRange(3), -3.75*3-cornerR], [3.75*2, 3.75*2], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
% Draw line 5
lineLane_5_side = line([-3.75*3, -3.75*3], [drawRange(2), 3.75*3+cornerR], 'LineWidth', 2, 'Color', 'k');
lineLane_5_middle_1 = line([-3.75*1, -3.75*1], [drawRange(2), 3.75*3+cornerR], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
lineLane_5_middle_2 = line([-3.75*2, -3.75*2], [drawRange(2), 3.75*3+cornerR], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
% Draw line 6
lineLane_6_side = line([-3.75*3, -3.75*3], [drawRange(1), -3.75*3-cornerR], 'LineWidth', 2, 'Color', 'k');
lineLane_6_middle_1 = line([-3.75*1, -3.75*1], [drawRange(1), -3.75*3-cornerR], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
lineLane_6_middle_2 = line([-3.75*2, -3.75*2], [drawRange(1), -3.75*3-cornerR], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
% Draw line 7
lineLane_7_side = line([drawRange(3), -3.75*3-cornerR], [-3.75*3, -3.75*3], 'LineWidth', 2, 'Color', 'k');
lineLane_7_middle_1 = line([drawRange(3), -3.75*3-cornerR], [-3.75*1, -3.75*1], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
lineLane_7_middle_2 = line([drawRange(3), -3.75*3-cornerR], [-3.75*2, -3.75*2], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
% Draw line 8
lineLane_8_side = line([drawRange(4), 3.75*3+cornerR], [-3.75*3, -3.75*3], 'LineWidth', 2, 'Color', 'k');
lineLane_8_middle_1 = line([drawRange(4), 3.75*3+cornerR], [-3.75*1, -3.75*1], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
lineLane_8_middle_2 = line([drawRange(4), 3.75*3+cornerR], [-3.75*2, -3.75*2], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');
% Draw boundary
lineLane_1_6 = line([0, 0], [drawRange(1), -3.75*3], 'LineWidth', 2, 'LineStyle', '--', 'Color', 'k');
lineLane_3_8 = line([drawRange(4), 3.75*3], [0, 0], 'LineWidth', 2, 'LineStyle', '--', 'Color', 'k');
lineLane_5_2 = line([0, 0], [drawRange(2), 3.75*3], 'LineWidth', 2, 'LineStyle', '--', 'Color', 'k');
lineLane_7_4 = line([drawRange(3), -3.75*3], [0, 0], 'LineWidth', 2, 'LineStyle', '--', 'Color', 'k');
% Draw corner of lane 1 and lane 8
T_1_8 = linspace(pi, pi/2);
X_1_8 = 3*3.75+cornerR + cornerR*cos(T_1_8);
Y_1_8 = -3*3.75-cornerR + cornerR*sin(T_1_8);
plot(X_1_8, Y_1_8, 'k', 'LineWidth', 2);
% Draw corner of lane 1 and lane 8
T_3_2 = linspace(3*pi/2, pi);
X_3_2 = 3*3.75+cornerR + cornerR*cos(T_3_2);
Y_3_2 = 3*3.75+cornerR + cornerR*sin(T_3_2);
plot(X_3_2, Y_3_2, 'k', 'LineWidth', 2);
% Draw corner of lane 1 and lane 8
T_5_4 = linspace(0, -pi/2);
X_5_4 = -3*3.75-cornerR + cornerR*cos(T_5_4);
Y_5_4 = 3*3.75+cornerR + cornerR*sin(T_5_4);
plot(X_5_4, Y_5_4, 'k', 'LineWidth', 2);
% Draw corner of lane 1 and lane 8
T_7_6 = linspace(pi/2, 0);
X_7_6 = -3*3.75-cornerR + cornerR*cos(T_7_6);
Y_7_6 = -3*3.75-cornerR + cornerR*sin(T_7_6);
plot(X_7_6, Y_7_6, 'k', 'LineWidth', 2);

%--- Display the animation of vehicles ---
for i = 1:1:size(PositionCell, 1)	
	% Initialize variable(s)
	positionTable = PositionCell{i, 1};
	curTime = startTime+(i-1)*timeStep;
	% Display current information
	title(['Time: ', num2str(curTime)],'fontsize',14);
	% Draw vehicle positions
	vehicleHandle = DrawVehicle(positionTable);
	% Save image
	set (gcf,'Position',[500,500,500,500], 'color','w');
    F = getframe(gcf);
    cd('Animation');
    	imwrite(F.cdata, ['XRoad_', num2str(curTime*10), '.png']);
	cd('..');
	% pause(frameTime);
	% Delete vehicle positions
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
		l = VehicleList(index).size(1)*0.8;
		d = VehicleList(index).size(2)*0.8;
		vType = VehicleList(index).type;
		origin = VehicleList(index).route(1);
		destination = VehicleList(index).route(2);
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
		routeNum = 10*origin+destination;
		if routeNum == 14 || routeNum == 36 || routeNum == 58 || routeNum == 72 
			colorSpec = [227, 107, 84]/255;
		elseif routeNum == 12 || routeNum == 34 || routeNum == 56 || routeNum == 78
			colorSpec = [245, 204, 100]/255;
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