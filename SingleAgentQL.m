function SingleAgentQL()
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
% 2017.03; Last revision: 2017.03.22

%------------- BEGIN CODE --------------

%--- Set global variables ---
% Templates of static struct
global Vehicle;
global Crossroad;
% Q Matrix
global QMatrix;
% Parameters
global xRange;
global xScale;
global xLeftNum;
global xRightNum;
global yRange;
global yScale;
global yDownNum;
global yUpNum;
global dirScale;
global dirRange;
global distNum;
global timeScale;
global maxSpeed;
global maxTurn;

%--- Initialize variables ---
% Horizontal Position
xRange = [-Crossroad.dir_5_6(2)*Crossroad.dir_5_6(3), Crossroad.dir_1_2(2)*Crossroad.dir_1_2(3)];
xScale = 0.1;
xLeftNum = abs(fix(xRange(1)/xScale));
xRightNum = fix(xRange(2)/xScale);
xNum = xLeftNum + xRightNum + 1;
% Vertical Position
yRange = [-Crossroad.dir_7_8(2)*Crossroad.dir_7_8(3), Crossroad.dir_3_4(2)*Crossroad.dir_3_4(3)];
yScale = 0.1;
yDownNum = abs(fix(yRange(1)/yScale));
yUpNum = fix(yRange(2)/yScale);
yNum = yUpNum + yDownNum + 1;
% Direction
dirRange = [0, 360];
dirScale = 5;
dirNum = floor((dirRange(2)-dirRange(1))/dirScale) + 1;
% Distance to the front vehicle
distNum = 2;	% 0: safe, 1: unsafe
% Time of per simulation (unit: s)
timeScale = 0.1;
% Limit of action
maxSpeed = 10;
maxTurn = 30;
% Q Matrix
QMatrix = zeros(xNum, yNum, dirNum, distNum);

%--- Set training parameters ---
alpha = 0.9;	% learning rate
gamma = 0.9;	% discount rate
epsilon = 0.2;	% greedy strategy parameter
iterationTimes = 100;	% times of iteration

%--- Do training ---
for i = 1:1:iterationTimes
	% Select an initial state randomly
	curState = [randi([0, xRightNum])*xScale, -yDownNum*yScale, 90, 0];
	% Do value iteration until reaching terminal
	while ~JudgeTerminal(curState)
		% List all possible action(s) 
		nextStateList = CalAction(curState);
		% Choose action using epsilon-greedy strategy
		if rand < epsilon
			[nextState, curQ] = FindMaxState(nextStateList);
		else
			randIndex = randi(size(nextStateList, 1));
			nextState = nextStateList(randIndex, : );
			curQ = GetQValue(nextState);
		end
		% Calculate maximum possible Q value of next action
		next2StateList = CalAction(nextState);
		[~, nextMaxQ] = FindMaxState(next2StateList);
		% Update Q matrix
		curQ = curQ + alpha*(Reward(nextState) + gamma*nextMaxQ - curQ);
		% Update state
		curState = nextState;

		disp(curState);
	end
end

%------------- END OF CODE --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Map value to index ---
function QValue = GetQValue(state)
	% Set global variables	
	global QMatrix;
	global xScale;
	global xLeftNum;
	global yScale;
	global yDownNum;
	global dirScale;
	global distNum;
	% Calculate index of xPosition
	xIndex = fix(state(1)/xScale)+xLeftNum+1;
	% Calculate index of yPosition
	yIndex = fix(state(2)/yScale)+yDownNum+1;
	% Calculate index of direction
	dirIndex = fix(state(3)/dirScale)+1;
	% Calculate index of distance status
	distIndex = state(4)+1;
	% Calculate the value in Q matrix
	QValue = QMatrix(xIndex, yIndex, dirIndex, distIndex);
end

%--- Decide whether the vehicle has arrived at the destination ---
function isTerminal = JudgeTerminal(curState)
	% Set global variables	
	global xRange;
	global yRange;
	% Set criterion
	xTerIndexRange = [xRange(1), xRange(1)+1];
	yTerIndexRange = [0, yRange(2)];
	% Decide whether vehicle has arrived at the terminal
	if curState(1) >= xTerIndexRange(1) && curState(1) <= xTerIndexRange(2) && ...
	   curState(2) >= yTerIndexRange(1) && curState(2) <= yTerIndexRange(2)
		isTerminal = true;
	else
		isTerminal = false;
	end		
end

%--- Calculate possible state(s)  ---
function stateList = CalAction(curState)
	% Set global variables
	global Crossroad;
	global maxSpeed;
	global maxTurn;
	global xRange;
	global xScale;
	global yRange;
	global yScale;
	global dirScale;
	global timeScale;
	% Initialize variable(s)
	stateList = zeros(0, 4);
	% Calculate the range of search area
	searchRange = zeros(1, 4);
	maxLength = maxSpeed*timeScale;
	searchRange(1) = max(Trim(curState(1)-maxLength, xScale), xRange(1));
	searchRange(2) = min(Trim(curState(1)+maxLength, xScale), xRange(2));
	searchRange(3) = max(Trim(curState(2)-maxLength, yScale), yRange(1));
	searchRange(4) = min(Trim(curState(2)+maxLength, yScale), yRange(2));
	% Search for possible state(s)
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
end

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

%--- Search for the state with maximum reward ---
function [maxState, maxQ] = FindMaxState(stateList)
	% Initialize variables
	maxState = stateList(1, : );
	maxQ = GetQValue(maxState);
	% Selection sorts
	for i = 2:1:size(stateList, 1)			
		curQ = GetQValue(stateList(i, : ));
		if curQ > maxQ
			maxState = stateList(i, : );
			maxQ = curQ;
		end
	end
end

%--- Calculate reward ---
function reward = Reward(state)
	% Set global variables 
	global xRange;
	global yRange;
	% Calculate the difference to lane 4
	xDistance = state(1) - xRange(1);
	if state(2) > 0
		yDistance = 0;
	else
		yDistance = state(2);
	end
	distFactor = sqrt(xDistance^2+yDistance^2)/sqrt((xRange(1)-xRange(2))^2+(yRange(1)-yRange(2))^2);
	% Calculate the difference to 180 degree
	degFactor = abs(state(3)-180)/180; 
	% Calculate the reward
	reward = 1/distFactor + 1/degFactor;
end

%--- Trim number to corresponding scale ---
function trimNumber = Trim(originNumber, scale)
	% Calculate the trimmed value
	trimNumber = round(originNumber/scale)*scale;
end

%------------- END OF SUBFUNCTION(S) --------------




