function SimuXRoad()
%SimuXRoad - Simulate the whole crossroad
%
% Syntax:  [~] = SimuXRoad()
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
% Subfunctions: UpdateVehicle, RegLeftTurning, OptLeftTurning, Straight, RightTurning, 
% 				JudgeStage, JudgeStep, JudgeOutside, JudgePhaseEnd
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.02; Last revision: 2017.05.10

%------------- BEGIN MAIN FUNCTION --------------

%--- Set global variable(s) ---
global VehicleList;
global curTime;
global startTime;
global endTime;
global timeStep;
global insideList;

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
	if ~isempty(insideList)
		UpdateVehicle();
	end
end

%------------- END OF MAIN FUNCTION --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Update state(s) of vehicle(s) ---
function UpdateVehicle()
	% Set global variable(s)
	global VehicleList;
	global insideList;
	global curTime;
	% Initialize variable(s)
	signal = JudgeStage();
	isPhaseEnd = JudgePhaseEnd(signal);
	% Update vehicle speed
	UpdateSpeed();
	% Update states
	for i = 1:1:size(insideList, 1)
		% Decide the type of the next step 
		curID = insideList(i, 1);
		stepType = JudgeStep(VehicleList(curID), signal, isPhaseEnd);
		% Calculate the position
		switch stepType
			case 0
				nextPosition = VehicleList(curID).position;
			case 1
				if VehicleList(curID).type == 1
					nextPosition = SimuMotion(VehicleList(curID), 2);
				else
					nextPosition = SimuMotion(VehicleList(curID), 1);
				end
			case 2
				nextPosition = SimuMotion(VehicleList(curID), 3);
			case 3
				nextPosition = SimuMotion(VehicleList(curID), 4);
				% disp(nextPosition);
			otherwise
				disp('Error in SimuXRoad() -> UpdateVehicle()');
		end
		% Update state(s)
		if ~JudgeOutside(nextPosition)
			VehicleList(curID).position = nextPosition;
			if stepType ~= 0
				VehicleList(curID).state = 1;
			end
		else
			VehicleList(curID).state = -1;
			insideList(i) = -1;
		end
		VehicleList(curID).trace = [VehicleList(curID).trace; [curTime, nextPosition]];
	end
	% Update insideList
	insideList(find(insideList==-1))=[];
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
function stepType = JudgeStep(vehicle, signal, isPhaseEnd)
	% Initialize variable(s)
	stepType = 0;
	entry = [vehicle.route(1), vehicle.route(2)];
	% Decide the type of the next step
	switch vehicle.state
		case 0
			if isPhaseEnd
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
						disp('Error in SimuXRoad() -> JudgeStep() -> switch vehicle.state -> case 0');
				end
			end
		case 1
			if isequal(entry, [1, 4]) || isequal(entry, [3, 6]) || isequal(entry, [5, 8]) || isequal(entry, [7, 2])
				stepType = 1;
			elseif isequal(entry, [1, 2]) || isequal(entry, [3, 4]) || isequal(entry, [5, 6]) || isequal(entry, [7, 8])
				stepType = 2;
			else
				stepType = 3;
			end
		otherwise
			disp('Error in SimuXRoad() -> JudgeStep() -> switch vehicle.state');
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

%--- Decide whether vehicles of previous phase(s) have finished their route ---
function isPhaseEnd = JudgePhaseEnd(signal)
	% Set global variable(s)
	global VehicleList;
	global insideList;
	% Initialize variable(s)
	isPhaseEnd = true;
	% Deecide whether 
	for i = 1:1:size(insideList, 1)
		vehicle = VehicleList(insideList(i));
		entry = [vehicle.route(1), vehicle.route(2)];
		if vehicle.state == 1
			switch signal
				case 0
				case 1
					if ~(isequal(entry, [1, 2]) || isequal(entry, [1, 8]) || isequal(entry, [5, 4]) || isequal(entry, [5, 6]))
						isPhaseEnd = false;
					end
				case 2
					if ~(isequal(entry, [1, 4]) || isequal(entry, [5, 8]))
						isPhaseEnd = false;
					end
				case 3
					if ~(isequal(entry, [3, 2]) || isequal(entry, [3, 4]) || isequal(entry, [7, 6]) || isequal(entry, [7, 8]))
						isPhaseEnd = false;
					end
				case 4
					if ~(isequal(entry, [3, 6]) || isequal(entry, [7, 2]))
						isPhaseEnd = false;
					end
				otherwise
					disp('Error in SimuXRoad() -> JudgePhaseEnd() -> switch signal');
			end
		end
	end
end

%------------- END OF SUBFUNCTION(S) --------------