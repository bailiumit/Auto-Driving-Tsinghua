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
% Subfunctions: UpdateVehicle, RegLeftTurning, OptLeftTurning, Straight, RightTurning, 
% 				JudgeStage, JudgeStep, JudgeOutside, JudgePhaseEnd
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.02; Last revision: 2017.04.18

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
					nextPosition = OptLeftTurning(VehicleList(curID));
				else
					nextPosition = RegLeftTurning(VehicleList(curID));
				end
			case 2
				nextPosition = Straight(VehicleList(curID));
			case 3
				nextPosition = RightTurning(VehicleList(curID));
				% disp(nextPosition);
			otherwise
				disp('Error in XroadSimulation() -> UpdateVehicle()');
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

%--- Simulate process of turning left in regular route ---
function nextPosition = RegLeftTurning(vehicle)
	% Set global variable(s)
	global timeStep;
	global Crossroad;
	% Initialize variable(s)
	v = vehicle.dynamic(1);
	x = vehicle.position(1);
	y = vehicle.position(2);
	dir = vehicle.position(3);
	% Update the position
	switch vehicle.route(1)
		case 1
			% Intialize trace parameters
			centerX = Crossroad.corner_1_4(1);
			centerY = Crossroad.corner_1_4(2);
			xAxis = Crossroad.corner_1_4(3);
			yAxis = Crossroad.corner_1_4(4);
			L = Crossroad.corner_1_4(5);
		case 3
			% Intialize trace parameters
			centerX = Crossroad.corner_3_6(1);
			centerY = Crossroad.corner_3_6(2);
			xAxis = Crossroad.corner_3_6(3);
			yAxis = Crossroad.corner_3_6(4);
			L = Crossroad.corner_3_6(5);
		case 5
			% Intialize trace parameters
			centerX = Crossroad.corner_5_8(1);
			centerY = Crossroad.corner_5_8(2);
			xAxis = Crossroad.corner_5_8(3);
			yAxis = Crossroad.corner_5_8(4);
			L = Crossroad.corner_5_8(5);
		case 7
			% Intialize trace parameters
			centerX = Crossroad.corner_7_2(1);
			centerY = Crossroad.corner_7_2(2);
			xAxis = Crossroad.corner_7_2(3);
			yAxis = Crossroad.corner_7_2(4);
			L = Crossroad.corner_7_2(5);
		otherwise
			disp('Error in XroadSimulation() -> RegLeftTurning()');
	end
	% Calculate angular velocity
	dRad = pi*v/(2*L)*timeStep;
	% Normalize the position of the vehicle
	xNorm = (x-centerX)/xAxis;
	yNorm = (y-centerY)/yAxis;
	% Calculate the next position of the vehicle
	xNormNew = xNorm*cos(dRad) - yNorm*sin(dRad);
	yNormNew = yNorm*cos(dRad) + xNorm*sin(dRad);
	x = xNormNew*xAxis+centerX;
	y = yNormNew*yAxis+centerY;
	dir = dir+dRad*180/pi;
	if dir < 0
		dir = dir+360;
	elseif dir >= 360
		dir = dir-360;
	end
	nextPosition = [x, y, dir];	
end

%--- Simulate process of turning left in optimized route ---
function nextPosition = OptLeftTurning(vehicle)
	% Set global variable(s)
	global timeStep;
	global Crossroad;
	global xRange;
	global yRange;
	% Initialize variable(s)
	v = vehicle.dynamic(1);
	x = vehicle.position(1);
	y = vehicle.position(2);
	dir = vehicle.position(3);
	unitDist = v*timeStep; 
	% Update the position
	switch vehicle.route(1)
		case 1
			% Calculate the inclination angle
			startPoint = [Crossroad.dir_1_2(3)/2, yRange(1)];
			endPoint = [xRange(1), Crossroad.dir_3_4(3)/2];
			incRad = pi+atan((endPoint(2)-startPoint(2))/(endPoint(1)-startPoint(1)));
        	% 1: Drive straight at the start
			if y+unitDist <= yRange(1)
				y = y+unitDist;
			elseif x+unitDist*cos(incRad) >= xRange(1)
				% 2: Transition between start and middle
				if y <= yRange(1)
					actualUnitDist = unitDist-(yRange(1)-y);
					x0 = startPoint(1);
					y0 = startPoint(2);
					dir = incRad*180/pi;
				% 3: Drive in inclined route in the middle
				else
					actualUnitDist = unitDist;
					x0 = x;
					y0 = y;
				end
				% Calculate the new position
				x = x0+actualUnitDist*cos(incRad);
				y = y0+actualUnitDist*sin(incRad);
			else
				% 4: Transition between middle and end
				if x >= xRange(2)
					x = xRange(2)-(unitDist-(xRange(1)-x)/cos(incRad));
					y = endPoint(2);
					dir = 180;
				% 5: Drive straight at the end
				else
					x = x-unitDist;
				end
			end
		case 3
			% Calculate the inclination angle
			startPoint = [xRange(2), Crossroad.dir_3_4(3)/2];
			endPoint = [-Crossroad.dir_5_6(3)/2, yRange(1)];
			incRad = pi+atan((endPoint(2)-startPoint(2))/(endPoint(1)-startPoint(1)));
        	% 1: Drive straight at the start
			if x-unitDist >= xRange(2)
				x = x-unitDist;
			elseif y+unitDist*sin(incRad) >= yRange(1)
				% 2: Transition between start and middle
				if x >= xRange(2)
					actualUnitDist = unitDist-(x-xRange(2));
					x0 = startPoint(1);
					y0 = startPoint(2);
					dir = incRad*180/pi;
				% 3: Drive in inclined route in the middle
				else
					actualUnitDist = unitDist;
					x0 = x;
					y0 = y;
				end
				% Calculate the new position
				x = x0+actualUnitDist*cos(incRad);
				y = y0+actualUnitDist*sin(incRad);
			else
				% 4: Transition between middle and end
				if y >= yRange(1)
					x = endPoint(1);
					y = yRange(1)-(unitDist-(yRange(1)-y)/sin(incRad));
					dir = 270;
				% 5: Drive straight at the end
				else
					y = y-unitDist;
				end
			end
        case 5
        	% Calculate the inclination angle
			startPoint = [-Crossroad.dir_5_6(3)/2, yRange(2)];
			endPoint = [xRange(2), -Crossroad.dir_7_8(3)/2];
			incRad = 2*pi+atan((endPoint(2)-startPoint(2))/(endPoint(1)-startPoint(1)));
        	% 1: Drive straight at the start
			if y-unitDist >= yRange(2)
				y = y-unitDist;
			elseif x+unitDist*cos(incRad) <= xRange(2)
				% 2: Transition between start and middle
				if y >= yRange(2)
					actualUnitDist = unitDist-(y-yRange(2));
					x0 = startPoint(1);
					y0 = startPoint(2);
					dir = incRad*180/pi;
				% 3: Drive in inclined route in the middle
				else
					actualUnitDist = unitDist;
					x0 = x;
					y0 = y;
				end
				% Calculate the new position
				x = x0+actualUnitDist*cos(incRad);
				y = y0+actualUnitDist*sin(incRad);
			else
				% 4: Transition between middle and end
				if x <= xRange(2)
					x = xRange(2)+(unitDist-(xRange(2)-x)/cos(incRad));
					y = endPoint(2);
					dir = 0;
				% 5: Drive straight at the end
				else
					x = x+unitDist;
				end
			end
		case 7
			% Calculate the inclination angle
			startPoint = [xRange(1), -Crossroad.dir_7_8(3)/2];
			endPoint = [Crossroad.dir_1_2(3)/2, yRange(2)];
			incRad = atan((endPoint(2)-startPoint(2))/(endPoint(1)-startPoint(1)));
        	% 1: Drive straight at the start
			if x+unitDist <= xRange(1)
				x = x+unitDist;
			elseif y+unitDist*sin(incRad) <= yRange(2)
				% 2: Transition between start and middle
				if x <= xRange(1)
					actualUnitDist = unitDist-(xRange(1)-x);
					x0 = startPoint(1);
					y0 = startPoint(2);
					dir = incRad*180/pi;
				% 3: Drive in inclined route in the middle
				else
					actualUnitDist = unitDist;
					x0 = x;
					y0 = y;
				end
				% Calculate the new position
				x = x0+actualUnitDist*cos(incRad);
				y = y0+actualUnitDist*sin(incRad);
			else
				% 4: Transition between middle and end
				if y <= yRange(2)
					x = endPoint(1);
					y = yRange(2)+(unitDist-(yRange(2)-y)/sin(incRad));
					dir = 90;
				% 5: Drive straight at the end
				else
					y = y+unitDist;
				end
			end
		otherwise
			disp('Error in XroadSimulation() -> Straight()');
	end
	nextPosition = [x, y, dir];
end

%--- Simulate process of driving straight ---
function nextPosition = Straight(vehicle)
	% Set global variable(s)
	global timeStep;
	% Initialize variable(s)
	v = vehicle.dynamic(1);
	x = vehicle.position(1);
	y = vehicle.position(2);
	dir = vehicle.position(3);
	% Update the position
	switch vehicle.route(1)
		case 1
			y = y+v*timeStep;
		case 3
			x = x-v*timeStep;
        case 5
			y = y-v*timeStep;
		case 7
			x = x+v*timeStep;
		otherwise
			disp('Error in XroadSimulation() -> Straight()');
	end
	nextPosition = [x, y, dir];
end

%--- Simulate process of turning right ---
function nextPosition = RightTurning(vehicle)
	% Set global variable(s)
	global timeStep;
	global Crossroad;
	% Initialize variable(s)
	v = vehicle.dynamic(1);
	x = vehicle.position(1);
	y = vehicle.position(2);
	dir = vehicle.position(3);
	% Update the position
	switch vehicle.route(1)
		case 1
			% Intialize trace parameters
			centerX = Crossroad.corner_1_8(1);
			centerY = Crossroad.corner_1_8(2);
			xAxis = Crossroad.corner_1_8(3);
			yAxis = Crossroad.corner_1_8(4);
			L = Crossroad.corner_1_8(5);
		case 3
			% Intialize trace parameters
			centerX = Crossroad.corner_3_2(1);
			centerY = Crossroad.corner_3_2(2);
			xAxis = Crossroad.corner_3_2(3);
			yAxis = Crossroad.corner_3_2(4);
			L = Crossroad.corner_3_2(5);
        case 5
			% Intialize trace parameters
			centerX = Crossroad.corner_5_4(1);
			centerY = Crossroad.corner_5_4(2);
			xAxis = Crossroad.corner_5_4(3);
			yAxis = Crossroad.corner_5_4(4);
			L = Crossroad.corner_5_4(5);
		case 7
			% Intialize trace parameters
			centerX = Crossroad.corner_7_6(1);
			centerY = Crossroad.corner_7_6(2);
			xAxis = Crossroad.corner_7_6(3);
			yAxis = Crossroad.corner_7_6(4);
			L = Crossroad.corner_7_6(5);
		otherwise
			disp('Error in XroadSimulation() -> RightTurning()');
	end
	% Calculate angular velocity
	dRad = pi*v/(2*L)*timeStep;
	% Normalize the position of the vehicle
	xNorm = (x-centerX)/xAxis;
	yNorm = (y-centerY)/yAxis;
	% Calculate the next position of the vehicle
	xNormNew = xNorm*cos(dRad) + yNorm*sin(dRad);
	yNormNew = yNorm*cos(dRad) - xNorm*sin(dRad);
	x = xNormNew*xAxis+centerX;
	y = yNormNew*yAxis+centerY;
	dir = dir-dRad*180/pi;
	if dir < 0
		dir = dir+360;
	elseif dir >= 360
		dir = dir-360;
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
						disp('Error in XroadSimulation() -> JudgeStep() -> switch vehicle.state -> case 0');
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
			disp('Error in XroadSimulation() -> JudgeStep() -> switch vehicle.state');
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
					disp('Error in XroadSimulation() -> JudgePhaseEnd() -> switch signal');
			end
		end
	end
end

%------------- END OF SUBFUNCTION(S) --------------