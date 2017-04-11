function XroadSimulation()
%XroadSimulation - Simulate the whole crossroad
%
% Syntax:  [~] = XroadSimulation()
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
% Subfunctions: JudgeStage
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.02; Last revision: 2017.02.20

%------------- BEGIN MAIN FUNCTION --------------

%--- Set global variable(s) ---
% Templates of static struct
global Vehicle;
global Crossroad;
% Dynamic
global VehicleList;
global curTime;

global insideList;

global startTime;
global endTime;
global timeStep;

%--- Initialize variable(s) ---
insideList = zeros(0, 1);

%--- Do Simulation ---
newID = 0;
for curTime = startTime:timeStep:endTime
	% Add new vehicle(s)
	for i = 1:1:CalVehicleNum()
		[newVehicle, newID] = GenerateVehicle(newID);
		VehicleList(newID) = newVehicle;
		insideList = [insideList; newID];
	end
	% Update state(s) of all vehicle(s)
	UpdateVehicle();
end

% disp(insideList);

%------------- END OF MAIN FUNCTION --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Update state(s) of vehicle(s) ---
function UpdateVehicle()
	% Initialize global variable(s)
	global VehicleList;
	global insideList;
	global curTime;
	% Initialize variable(s)
	signal = JudgeStage();
	% Update states
	for i = 1:1:size(insideList, 1)
		% Decide the type of the next step 
		curID = insideList(i, 1);
		stepType = JudgeStep(VehicleList(curID), signal);
		% Calculate the position
		switch stepType
			case 0
				nextPosition = Vehic.leList(curID).position;
			case 1
				nextPosition = LeftTurning(VehicleList(curID));
			case 2
				nextPosition = Straight(VehicleList(curID));
			case 3
				nextPosition = RightTurning(VehicleList(curID));
			otherwise
				disp('Error in XroadSimulation() -> UpdateVehicle()');
		end
		% Update state(s)
		if ~JudgeOutside(nextPosition)
			VehicleList(curID).position = nextPosition;
			VehicleList(curID).trace = [VehicleList(curID).trace; [curTime, VehicleList(curID).position]];
		else
			VehicleList(curID).state = 0;
			insideList(i) = -1;
		end
	end
	% Update insideList
	insideList(find(insideList==-1))=[];
end

%--- Simulate left turning process ---
function nextPosition = LeftTurning(vehicle)
	% Initialize variable(s)
	x = vehicle.position(1);
	y = vehicle.position(2);
	dir = vehicle.position(3);

	switch vehicle.route(1)
		case 1
			y = y+1;
		case 3
			x = x-1;
        case 5
			y = y-1;
		case 7
			x = x+1;
		otherwise
			disp('Error in XroadSimulation() -> LeftTurning()');
	end

	nextPosition = [x, y, dir];

end

%--- Simulate left turning process ---
function nextPosition = Straight(vehicle)
	% Initialize variable(s)
	x = vehicle.position(1);
	y = vehicle.position(2);
	dir = vehicle.position(3);

	switch vehicle.route(1)
		case 1
			y = y+1;
		case 3
			x = x-1;
        case 5
			y = y-1;
		case 7
			x = x+1;
		otherwise
			disp('Error in XroadSimulation() -> Straight()');
	end

	nextPosition = [x, y, dir];
end

%--- Simulate left turning process ---
function nextPosition = RightTurning(vehicle)
	% Initialize variable(s)
	x = vehicle.position(1);
	y = vehicle.position(2);
	dir = vehicle.position(3);

	switch vehicle.route(1)
		case 1
			y = y+1;
		case 3
			x = x-1;
        case 5
			y = y-1;
		case 7
			x = x+1;
		otherwise
			disp('Error in XroadSimulation() -> RightTurning()');
	end

	nextPosition = [x, y, dir];
end

%--- Decide the stage of the signal ---
function signal = JudgeStage()
	% Set global variable(s)
	global Crossroad;
	global curTime;
	% Calculate the proportion of the signal process
	remainder = rem(curTime-Crossroad.signal(1), Crossroad.signal(2));
	if remainder < 0
		remainder = remainder + Crossroad.signal(2);
	end
	proportion = remainder/Crossroad.signal(2);
	% Calculate the signal stage
	if proportion <= Crossroad.signal(3)
		signal = 1;
	elseif proportion <= Crossroad.signal(3)+Crossroad.signal(4)
		signal = 2;
	elseif proportion <= Crossroad.signal(3)+Crossroad.signal(4)+Crossroad.signal(5)
		signal = 3;
	elseif proportion <= Crossroad.signal(3)+Crossroad.signal(4)+Crossroad.signal(5)+Crossroad.signal(6)
		signal = 4;
	else
		signal = 0;
	end
end

%--- Decide the next step of the vehicle (0: still, 1: turn left, 2: drive straight, 3: turn right) ---
function stepType = JudgeStep(vehicle, signal)
	% Initialize variable(s)
	stepType = 0;
	entry = [vehicle.route(1), vehicle.route(2)];
	% Decide the type of the next step
	switch signal
		case 0
			
		case 1
			if isequal(entry, [1, 2]) || isequal(entry, [5, 6])
				stepType = 2;
			elseif isequal(entry, [1, 8]) || isequal(entry, [5, 4])
				stepType = 3;
			end
		case 2
			if isequal(entry, [1, 4]) || isequal(entry, [5, 8])
				stepType = 1;
			end
		case 3
			if isequal(entry, [3, 4]) || isequal(entry, [7, 8])
				stepType = 2;
			elseif isequal(entry, [3, 2]) || isequal(entry, [7, 6])
				stepType = 3;
			end
		case 4
			if isequal(entry, [3, 6]) || isequal(entry, [7, 2])
				stepType = 1;
			end	
		otherwise
			disp('Error in XroadSimulation() -> JudgeStep()');
	end
end

%--- Decide whether the vehicle has left the crossroad ---
function isOutside = JudgeOutside(position)
	% Set global variable(s)
	global Crossroad;
	% Initialize variable(s)
	isOutside = false;
	xLeftBound = -Crossroad.dir_5_6(2)*Crossroad.dir_5_6(3)-Crossroad.turningR;
	xRightBound = Crossroad.dir_1_2(2)*Crossroad.dir_1_2(3)+Crossroad.turningR;
	yDownBound = -Crossroad.dir_7_8(2)*Crossroad.dir_7_8(3)-Crossroad.turningR;
	yUpBound = Crossroad.dir_3_4(2)*Crossroad.dir_3_4(3)+Crossroad.turningR;
	if position(1) < xLeftBound || position(1) > xRightBound || position(2) < yDownBound || position(2) > yUpBound
		isOutside = true;
	end
end

%------------- END OF SUBFUNCTION(S) --------------