function nextPosition = SimuMotion(vehicle, motionType)
%SimuMotion - Simulate the whole crossroad
%
% Syntax:  nextPosition = SimuMotion(vehicle, motionType)
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
% Subfunctions: RegLeftTurning, OptLeftTurning, Straight, RightTurning
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.05; Last revision: 2017.05.10

%------------- BEGIN MAIN FUNCTION --------------

%--- Call function according to motionType ---
switch motionType
	case 1
		nextPosition = RegLeftTurning(vehicle);
	case 2
		nextPosition = OptLeftTurning(vehicle);
	case 3
		nextPosition = Straight(vehicle);
	case 4
		nextPosition = RightTurning(vehicle);
	otherwise
		disp('Error in SimuMotion()');
end

%------------- END OF MAIN FUNCTION --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

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
			disp('Error in SimuXRoad() -> RegLeftTurning()');
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
			disp('Error in SimuXRoad() -> Straight()');
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
			disp('Error in SimuXRoad() -> Straight()');
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
			disp('Error in SimuXRoad() -> RightTurning()');
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

%------------- END OF SUBFUNCTION(S) --------------