function [newVehicle, newID] = GenerateVehicle(curID)
%GenerateVehicle - Generate the object of vehicle struct
%
% Syntax:  [newVehicle, newID] = GenerateVehicle(curID)
%
% Inputs:
%    curID - ID of current vehicle       
%
% Outputs:
%    newVehicle - structure of new vehicle    
%    newID - ID of new vehicle    
%
% Example: 
%    none
%
% Other m-files required: none
% Subfunctions: GenerateSize, GenerateType, GenerateDynamic, GenerateRoute, InitializePosition, 
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.02; Last revision: 2017.02.20

%------------- BEGIN MAIN FUNCTION --------------

%--- Set global variables ---
% Templates of static struct
global Vehicle;
global Crossroad;
% Dynamic
global VehicleList;
global Schedule;
global curTime;

%--- Initialize variables ---
newVehicle = Vehicle;
newID = curID+1;

%--- Generate the parameters of the vehicle ---
newVehicle.ID = newID;
newVehicle.size = GenerateSize();
newVehicle.type = GenerateType();
newVehicle.dynamic = GenerateDynamic();
newVehicle.route = GenerateRoute();
newVehicle.position = InitializePosition(newVehicle.route);

%------------- END OF MAIN FUNCTION --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Generate the size of vehicles randomly ---
function newSize = GenerateSize()
	newLength = 2 + 1.5*rand;
	newWidth = 1.5 + 0.8*rand;
	newSize = [newLength, newWidth];
end

%--- Generate the type of vehicles randomly ---
function newType = GenerateType()
	newType = 1;
end

%--- Generate the dynamic of vehicles randomly ---
function newDynamic = GenerateDynamic()
	newDynamic = [15, 0, 30, 1.5];
end

%--- Generate the route of vehicles randomly ---
function newRoute = GenerateRoute()
	% Determine the crossroad
	newCrossID = 1;
	% Determine the start direction
	newStart = 2*randi([1, 4]) - 1;
	% Determine the end direction
	endIndex = randi([1, 3]);
	switch newStart
		case 1
			switch endIndex
				case 1
					newEnd = 4;
				case 2
					newEnd = 2;
				case 3
					newEnd = 8;
				otherwise
					disp('Error in switch newStart, case 1');
			end
		case 3
			switch endIndex
				case 1
					newEnd = 6;
				case 2
					newEnd = 4;
				case 3
					newEnd = 2;
				otherwise
					disp('Error in switch newStart, case 3');
			end
		case 5
			switch endIndex
				case 1
					newEnd = 8;
				case 2
					newEnd = 6;
				case 3
					newEnd = 4;
				otherwise
					disp('Error in switch newStart, case 5');
			end
		case 7
			switch endIndex
				case 1
					newEnd = 2;
				case 2
					newEnd = 8;
				case 3
					newEnd = 6;
				otherwise
					disp('Error in switch newStart, case 7');
			end
		otherwise
			disp('Error in switch newStart');
	end
	% Generate return value
	newRoute = [newCrossID, newStart, newEnd];
end

%--- Initialize the position of vehicles ---
function originPosition = InitializePosition(route)
	% Set global variables
	global Crossroad;
	switch route(2)
		case 1
			% Determine the laneID
			switch route(3)
				case 4
					newLaneID = 1;
				case 2
					newLaneID = randi([1, Crossroad.dir_1_2(2)]);
				case 8
					newLaneID = Crossroad.dir_1_2(2);
				otherwise
					disp('Error in switch route(2), case 1');
			end
			% Calculate X and Y
			newX = (newLaneID-0.5) * Crossroad.dir_1_2(3);
			newY = -(Crossroad.dir_7_8(2)*Crossroad.dir_7_8(3)+Crossroad.turningR+Crossroad.dir_1_2(1));
			% Initialize direction
			newDirection = 90;
		case 3
			% Determine the laneID
			switch route(3)
				case 6
					newLaneID = 1;
				case 4
					newLaneID = randi([1, Crossroad.dir_3_4(2)]);
				case 2
					newLaneID = Crossroad.dir_3_4(2);
				otherwise
					disp('Error in switch route(2), case 3');
			end
			% Calculate X and Y
			newX = Crossroad.dir_1_2(2)*Crossroad.dir_1_2(3)+Crossroad.turningR+Crossroad.dir_3_4(1);
			newY = (newLaneID-0.5) * Crossroad.dir_3_4(3);
			% Initialize direction
			newDirection = 180;
		case 5
			% Determine the laneID
			switch route(3)
				case 8
					newLaneID = 1;
				case 6
					newLaneID = randi([1, Crossroad.dir_5_6(2)]);
				case 4
					newLaneID = Crossroad.dir_5_6(2);
				otherwise
					disp('Error in switch route(2), case 5');
			end
			% Calculate X and Y
			newX = -(newLaneID-0.5) * Crossroad.dir_5_6(3);
			newY = Crossroad.dir_3_4(2)*Crossroad.dir_3_4(3)+Crossroad.turningR+Crossroad.dir_5_6(1);
			% Initialize direction
			newDirection = 0;
		case 7
			% Determine the laneID
			switch route(3)
				case 2
					newLaneID = 1;
				case 8
					newLaneID = randi([1, Crossroad.dir_7_8(2)]);
				case 6
					newLaneID = Crossroad.dir_7_8(2);
				otherwise
					disp('Error in switch route(2), case 7');
			end
			% Calculate X and Y
			newX = - (Crossroad.dir_5_6(2)*Crossroad.dir_5_6(3)+Crossroad.turningR+Crossroad.dir_7_8(1));
			newY = - (newLaneID-0.5) * Crossroad.dir_7_8(3);
			% Initialize direction
			newDirection = -90;
		otherwise
			disp('Error in switch route(2)');
	end
	% Generate return value
	originPosition = [newLaneID, newX, newY, newDirection];
end

%------------- END OF SUBFUNCTION(S) --------------