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
% Subfunctions: GenerateSize, GenerateType, GenerateRoute, GenerateDynamic, GeneratePosition, InitializePosition, Trim
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.02; Last revision: 2017.05.15

%------------- BEGIN MAIN FUNCTION --------------

%--- Set global variable(s) ---
% Templates of static struct
global Vehicle;
global Crossroad;
% Dynamic
global VehicleList;
global curTime;
global timeStep;

%--- Initialize variable(s) ---
newVehicle = Vehicle;
newID = curID+1;

%--- Generate the parameters of the vehicle ---
newVehicle.ID = newID;
newVehicle.size = GenerateSize();
newVehicle.type = GenerateType();
% newVehicle.route = GenerateRoute();
newVehicle.route = [1, 4];
newVehicle.dynamic = GenerateDynamic();
newVehicle.position = GeneratePosition(newVehicle.size, newVehicle.route, newVehicle.type);
newVehicle.trace = [curTime-timeStep, newVehicle.position];
newVehicle.state = 0;

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
	% Set global variable(s)
	global autoRatio;
	% Initialize variables
	if rand <= autoRatio
		newType = 1;
	else
		newType = 0;
	end
end

%--- Generate the route of vehicles randomly ---
function newRoute = GenerateRoute()
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
					disp('Error in GenerateVehicle() -> GenerateRoute() -> switch newStart, case 1');
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
					disp('Error in GenerateVehicle() -> GenerateRoute() -> switch newStart, case 3');
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
					disp('Error in GenerateVehicle() -> GenerateRoute() -> switch newStart, case 5');
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
					disp('Error in GenerateVehicle() -> GenerateRoute() -> switch newStart, case 7');
			end
		otherwise
			disp('Error in GenerateVehicle() -> GenerateRoute() -> switch newStart');
	end
	% Generate return value
	newRoute = [newStart, newEnd];
end

%--- Generate the initial speed of vehicles randomly ---
function newSpeed = GenerateDynamic()
	% Set global variable(s)	
	global vScale;
	% Initialize variable(s)
	randVMin = 2;
	randVMax = 6;
	newSpeed = Trim(randVMin+(randVMax-randVMin)*rand, vScale);
end

%--- Adjust the initial position of the vehicle ---
function newPosition = GeneratePosition(newSize, newRoute, newType)
	% Set global variable(s)
	global Crossroad;
	global VehicleList;
	global ClassifiedList;
	% Initialize variable(s)
	interval = 2;
	cellIndex = ClassifyVehicle(newRoute, newType);
	% Calculate new position
	if isempty(ClassifiedList{cellIndex(1), cellIndex(2)})
		newPosition = InitializePosition(newRoute);
	else
		% Initialize variable(s)
		lastID = ClassifiedList{cellIndex(1), cellIndex(2)}(end);
		lastVehicle = VehicleList(lastID);
		xLeftBound = -Crossroad.dir_5_6(2)*Crossroad.dir_5_6(3)-Crossroad.turningR;
		xRightBound = Crossroad.dir_1_2(2)*Crossroad.dir_1_2(3)+Crossroad.turningR;
		yDownBound = -Crossroad.dir_7_8(2)*Crossroad.dir_7_8(3)-Crossroad.turningR;
		yUpBound = Crossroad.dir_3_4(2)*Crossroad.dir_3_4(3)+Crossroad.turningR;
		isAtXRoad = false;
		% Decide whether the vehicle has arrived at the crossroad area
		switch lastVehicle.route(1)
			case 1
				if lastVehicle.route(2) >= yDownBound
					isAtXRoad = true;	
				end
			case 3
				if lastVehicle.route(1) <= xRightBound
					isAtXRoad = true;	
				end
			case 5
				if lastVehicle.route(2) <= yUpBound
					isAtXRoad = true;	
				end
			case 7
				if lastVehicle.route(1) >= xLeftBound
					isAtXRoad = true;	
				end
			otherwise
				disp('Error in GenerateVehicle() -> GeneratePosition()');
		end
		% Calculate the position
		if lastVehicle.state == 1 && isAtXRoad
			newPosition = InitializePosition(newRoute);
		else
			switch newRoute(1)
				case 1
					newPosition = lastVehicle.position;
					newPosition(2) = newPosition(2) - (lastVehicle.size(1)/2+newSize(1)/2+interval);
				case 3
					newPosition = lastVehicle.position;
					newPosition(1) = newPosition(1) + (lastVehicle.size(1)/2+newSize(1)/2+interval);
				case 5
					newPosition = lastVehicle.position;
					newPosition(2) = newPosition(2) + (lastVehicle.size(1)/2+newSize(1)/2+interval);
				case 7
					newPosition = lastVehicle.position;
					newPosition(1) = newPosition(1) - (lastVehicle.size(1)/2+newSize(1)/2+interval);
				otherwise
					disp('Error in GenerateVehicle() -> GeneratePosition()');
			end
		end
	end
end

%--- Initialize the position of vehicles ---
function originPosition = InitializePosition(newRoute)
	% Set global variable(s)
	global Crossroad;
	switch newRoute(1)
		case 1
			% Determine the laneID
			switch newRoute(2)
				case 4
					newLaneID = 1;
				case 2
					newLaneID = randi([2, Crossroad.dir_1_2(2)]);
				case 8
					newLaneID = Crossroad.dir_1_2(2);
				otherwise
					disp('Error in GenerateVehicle() -> InitializePosition() -> switch route(2), case 1');
			end
			% Calculate X and Y
			newX = (newLaneID-0.5) * Crossroad.dir_1_2(3);
			newY = -(Crossroad.dir_7_8(2)*Crossroad.dir_7_8(3)+Crossroad.turningR);
			% Initialize direction
			newDirection = 90;
		case 3
			% Determine the laneID
			switch newRoute(2)
				case 6
					newLaneID = 1;
				case 4
					newLaneID = randi([2, Crossroad.dir_3_4(2)]);
				case 2
					newLaneID = Crossroad.dir_3_4(2);
				otherwise
					disp('Error in GenerateVehicle() -> InitializePosition() -> switch route(2), case 3');
			end
			% Calculate X and Y
			newX = Crossroad.dir_1_2(2)*Crossroad.dir_1_2(3)+Crossroad.turningR;
			newY = (newLaneID-0.5) * Crossroad.dir_3_4(3);
			% Initialize direction
			newDirection = 180;
		case 5
			% Determine the laneID
			switch newRoute(2)
				case 8
					newLaneID = 1;
				case 6
					newLaneID = randi([2, Crossroad.dir_5_6(2)]);
				case 4
					newLaneID = Crossroad.dir_5_6(2);
				otherwise
					disp('Error in GenerateVehicle() -> InitializePosition() -> switch route(2), case 5');
			end
			% Calculate X and Y
			newX = -(newLaneID-0.5) * Crossroad.dir_5_6(3);
			newY = Crossroad.dir_3_4(2)*Crossroad.dir_3_4(3)+Crossroad.turningR;
			% Initialize direction
			newDirection = 0;
		case 7
			% Determine the laneID
			switch newRoute(2)
				case 2
					newLaneID = 1;
				case 8
					newLaneID = randi([2, Crossroad.dir_7_8(2)]);
				case 6
					newLaneID = Crossroad.dir_7_8(2);
				otherwise
					disp('Error in GenerateVehicle() -> InitializePosition() -> switch route(2), case 7');
			end
			% Calculate X and Y
			newX = - (Crossroad.dir_5_6(2)*Crossroad.dir_5_6(3)+Crossroad.turningR);
			newY = - (newLaneID-0.5) * Crossroad.dir_7_8(3);
			% Initialize direction
			newDirection = 270;
		otherwise
			disp('Error in GenerateVehicle() -> InitializePosition() -> switch route(2)');
	end
	% Generate return value
	originPosition = [newX, newY, newDirection];
end

%--- Classify vehicles according to their routes ---
function cellIndex = ClassifyVehicle(route, type)
	% Classify vehicles
	switch 10*route(1)+route(2)
		case 14
			if type == 1
				cellIndex = [1, 1];
			else
				cellIndex = [1, 2];
			end
		case 12
			cellIndex = [1, 3];
		case 18
			cellIndex = [1, 4];
		case 36
			if type == 1
				cellIndex = [2, 1];
			else
				cellIndex = [2, 2];
			end
		case 34
			cellIndex = [2, 3];
		case 32
			cellIndex = [2, 4];
		case 58
			if type == 1
				cellIndex = [3, 1];
			else
				cellIndex = [3, 2];
			end
		case 56
			cellIndex = [3, 3];
		case 54
			cellIndex = [3, 4];
		case 72
			if type == 1
				cellIndex = [4, 1];
			else
				cellIndex = [4, 2];
			end
		case 78
			cellIndex = [4, 3];
		case 76
			cellIndex = [4, 4];
		otherwise
			disp('Error in GenerateVehicle() -> ClassifyVehicle()');
	end
end

%--- Trim number to corresponding scale ---
function trimNumber = Trim(originNumber, scale)
	% Calculate the trimmed value
	trimNumber = round(originNumber/scale)*scale;
end

%------------- END OF SUBFUNCTION(S) --------------