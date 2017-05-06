function stateList = CalTurningAction(preState, curState)
%CalTurningAction - Calculate available states for next step (for Q-Learning)
%
% Syntax:  stateList = CalTurningAction(preState, curState)
%
% Inputs:
%    preState - previous state       
%    curState - current state       
%
% Outputs:
%    stateList - collection of possible states
%
% Example: 
%    none
%
% Other m-files required: none
% Subfunctions: JudgeExceed, CalDnI, Trim
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.03; Last revision: 2017.05.06

%------------- BEGIN CODE --------------

%--- Set global variable(s) ---
global maxAcc;
global xRange;
global xScale;
global yRange;
global yScale;
global dirScale;
global timeScale;

%--- Initialize variable(s) ---
stateList = zeros(0, 4);

%--- Calculate the next state if keeping current speed ---
nextInitState = curState;
nextInitState(1) = 2*curState(1) - preState(1);
nextInitState(2) = 2*curState(2) - preState(2);

%--- Calculate stateList ---
if curState == preState  % If agent stops, move into neighbor state
	nextState = curState;
	nextState(1) = max(nextState(1)-xScale, xRange(1));
	nextState(2) = min(nextState(2)+yScale, yRange(2));
	stateList = [stateList; nextState];
else  % If agent remains normal
	% Define the area to search
	searchRange = zeros(1, 4);
	maxLength = maxAcc*timeScale*timeScale;
	searchRange(1) = max(Trim(nextInitState(1)-maxLength, xScale), xRange(1));
	searchRange(2) = min(Trim(nextInitState(1)+maxLength, xScale), xRange(2));
	searchRange(3) = max(Trim(nextInitState(2)-maxLength, yScale), yRange(1));
	searchRange(4) = min(Trim(nextInitState(2)+maxLength, yScale), yRange(2));
	% Search for possible state(s)
	for x = searchRange(1):xScale:searchRange(2)
		for y = searchRange(3):yScale:searchRange(4)
			% Judge whether the state is within reach
			[distance, inclination] = CalDnI(x, y, curState(1), curState(2), curState(3));
			if distance <= maxLength
				nextState = zeros(1, 4);
				nextState(1) = Trim(x, xScale);
				nextState(2) = Trim(y, xScale);
				nextState(3) = Trim(inclination, dirScale);
				% Avoid exceeded nextState
				if ~JudgeExceed(nextState(1), nextState(2))
					stateList = [stateList; nextState];
				end
			end
		end
	end
end

%------------- END OF CODE --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Decide whether the agent has exceeded boundaries ---
function isExceed = JudgeExceed(x, y)
	% Set global variable(s)	
	global xRange;
	global yRange;
	% Initialize variable(s)
	isExceed = false;
	% Judge whether the agent is outside the boundary of quadrant 3
	if (x<=0 && y<=0 && x^2/(abs(xRange(1))-1)^2+y^2/(yRange(1))^2 > 1) || ...
	   (yRange(2)*x + xRange(2)*y > 0 || x > xRange(2)/2)
		isExceed = true;
	end
end

%--- Calculate the distance and inclination ---
function [distance, inclination] = CalDnI(x, y, x0, y0, oriInclination)
	% Calculate distance
	distance = sqrt((x-x0)^2+(y-y0)^2);
	% Calculate inclination
	if x == x0
		if y > y0
			inclination = 90;
		elseif y == y0
			inclination = oriInclination;
		else
			inclination = 270;			
		end
	elseif x > x0
		if y >= y0
			inclination = rad2deg(atan((y-y0)/(x-x0)));
		else
			inclination = rad2deg(atan((y-y0)/(x-x0)))+360;
		end
	else
		inclination = rad2deg(atan((y-y0)/(x-x0)))+180;
	end
end

%--- Trim number to corresponding scale ---
function trimNumber = Trim(originNumber, scale)
	% Calculate the trimmed value
	trimNumber = round(originNumber/scale)*scale;
end

%------------- END OF SUBFUNCTION(S) --------------