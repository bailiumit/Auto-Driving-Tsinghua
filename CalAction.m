function stateList = CalAction(curState)
%ModifyStrategy - Calculate the convert rate at crossroads (no VMS)
%
% Syntax:  [~] = Main(curDay)
%
% Inputs:
%    curDay - Current day(args)        
%
% Outputs:
%    none
%
% Example: 
%    none
%
% Other m-files required: turningChoice.mat, complianceRate.mat
% Subfunctions: none
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2016.02; Last revision: 2016.02.10

%------------- BEGIN CODE --------------

%--- Set global variables ---
global Crossroad;
global maxSpeed;
global maxTurn;
global xRange;
global xScale;
global yRange;
global yScale;
global dirScale;
global timeScale;

%--- Initialize variable(s) ---
stateList = zeros(0, 4);

%--- Calculate the range of search area ---
searchRange = zeros(1, 4);
maxLength = maxSpeed*timeScale;
searchRange(1) = max(Trim(curState(1)-maxLength, xScale), xRange(1));
searchRange(2) = min(Trim(curState(1)+maxLength, xScale), xRange(2));
searchRange(3) = max(Trim(curState(2)-maxLength, yScale), yRange(1));
searchRange(4) = min(Trim(curState(2)+maxLength, yScale), yRange(2));

%--- Search for possible state(s) ---
for x = searchRange(1):xScale:searchRange(2)
	for y = searchRange(3):yScale:searchRange(4)
		% Judge whether the state is within reach
		[distance, inclination] = CalDnI(x, y, curState(1), curState(2));
		if distance < 0.05
			nextDirection = curState(3)+maxTurn;
			if nextDirection > 360
				nextDirection = nextDirection-360;
			end
			nextState = [x, y, Trim(nextDirection, dirScale), 0];
			stateList = [stateList; nextState];
		elseif distance <= maxLength && abs(inclination-curState(3)) <= maxTurn
			nextState = [x, y, Trim(inclination, dirScale), 0];
			stateList = [stateList; nextState];
		end
	end
end

%------------- END OF CODE --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Calculate the distance and inclination ---
function [distance, inclination] = CalDnI(x, y, x0, y0)
	% Calculate distance
	distance = sqrt((x-x0)^2+(y-y0)^2);
	% Calculate inclination
	if x == x0
		if y > y0
			inclination = 90;
		elseif y == y0
			inclination = 0;
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




