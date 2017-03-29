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

%--- Set training parameters ---
alpha = 0.9;	% learning rate
gamma = 0.9;	% discount rate
epsilon = 0.2;	% greedy strategy parameter
iterationTimes = 1000;	% times of iteration

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
		newQ = curQ + alpha*(Reward(nextState) + gamma*nextMaxQ - curQ);
		UpdateQMatrix(curState, newQ);
		% Update state
		curState = nextState;
	end

	disp(nnz(QMatrix)/numel(QMatrix));

end

%--- Save QMatrix ---
save('QMatrix.mat', 'QMatrix');

%------------- END OF CODE --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

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
	% Define factors of the function in different quadrants
	if state(1) >= 0 && state(2) >= 0	% State in quadrant 1
		distFactor = abs(state(1)/xRange(2));
		degFactor = abs(state(3)-180)/(360-180);
		cons = 100;
	elseif state(1) < 0 && state(2) >= 0	% State in quadrant 2
		distFactor = abs((state(1)-xRange(1))/xRange(1));
		degFactor = abs(state(3)-180)/(360-180);
		cons = 200;
	elseif state(1) < 0 && state(2) < 0	% State in quadrant 3
		distFactor = abs(state(2)/yRange(1));
		degFactor = abs(state(3)-90)/(360-90);
		cons = 0;
	else  % State in quadrant 4
		distFactor = sqrt((state(1)^2+state(2)^2)/(xRange(2)^2+yRange(1)^2));
		degFactor = abs(state(3)-135)/(360-135);
		cons = 0;
	end
	% Calculate the reward
	reward = 1/(distFactor+0.01) + 1/(degFactor+0.01) + cons;
end

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

%--- Update state in Q matrix ---
function UpdateQMatrix(state, QValue)
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
	QMatrix(xIndex, yIndex, dirIndex, distIndex) = QValue;
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

%------------- END OF SUBFUNCTION(S) --------------




