function OptTurning()
%OptTurning - Test the training result of left-turning strategy optimization
%
% Syntax:  [~] = OptTurning()
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
% Subfunctions: Reward, FindMaxState, GetQValue, UpdateQMatrix, JudgeTerminal, Trim
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.03; Last revision: 2017.05.17

%------------- BEGIN CODE --------------

%--- Set global variable(s) ---
% Templates of static struct
global Crossroad;
% Q Matrix
global QMatrix;
% Parameters
global xScale;
global yScale;
global yDownNum;

%--- Set training parameters ---
alpha = 0.5;	% learning rate
gamma = 0.5;	% discount rate
epsilon = 0.2;	% greedy strategy parameter
discount = 0.999;	% discount factor of epsilon
iterationTimes = 10000;	% times of iteration

%--- Initialize variable(s) ---
TurningPerform = zeros(0, 5);
tStart = cputime;

%--- Do training ---
for i = 1:1:iterationTimes
	% Begin timing of the iteration
	tIterStart = cputime;
	% Select an initial state randomly
	initialSpeed = randi([0, 20])/2;
	curState = [Trim(Crossroad.dir_1_2(3)/2, xScale), -yDownNum*yScale, 90, 0];
	preState = curState;
	preState(2) = curState(2) - initialSpeed*0.1;
	% Do value iteration until reaching terminal
	while ~JudgeTerminal(curState)
		% List all possible action(s) 
		nextStateList = CalTurningAction(preState, curState);
		% Choose action using epsilon-greedy strategy
		if rand > epsilon
			[nextState, curQ] = FindMaxState(nextStateList);
		else
			randIndex = randi(size(nextStateList, 1));
			nextState = nextStateList(randIndex, : );
			curQ = GetQValue(nextState);
		end
		% Calculate maximum possible Q value of next action
		next2StateList = CalTurningAction(curState, nextState);
		[~, nextMaxQ] = FindMaxState(next2StateList);
		% Update Q matrix
		newQ = curQ + alpha*(Reward(preState, curState, nextState) + gamma*nextMaxQ - curQ);
		UpdateQMatrix(curState, newQ);
		% Update state
		preState = curState;
		curState = nextState;
	end
	% Decrease epsilon
	epsilon = epsilon*discount;
	% End timing of the iteration
	tIterEnd = cputime;
	% Display the iteration information
	infNum = sum(sum(sum(sum(QMatrix == -Inf))));
	zeroNum = sum(sum(sum(sum(QMatrix == 0))));
	totalNum = numel(QMatrix) - infNum;
	validNum = totalNum - zeroNum;
	turningPerform = [i, validNum/totalNum*100, tIterEnd-tIterStart, tIterEnd-tStart, (tIterEnd-tStart)/i];
	TurningPerform = [TurningPerform; turningPerform];
	disp(['Iteration: ', num2str(turningPerform(1)), '  ', ...
		'Coverage: ', num2str(turningPerform(2)), '%  ', ...
		'Iteration Time: ', num2str(turningPerform(3)), 's  ', ...
		'Total Time: ', num2str(turningPerform(4)), 's  ', ...
		'Average Time: ', num2str(turningPerform(5)), 's']);
	% Save QMatrix 
	if mod(i, 100) == 0
		cd('MatFile');
		save('QMatrix.mat', 'QMatrix');
		save('TurningPerform.mat', 'TurningPerform');
		cd('..');
		disp(['Save data in iteration ', num2str(i)]);
	end
end

%------------- END OF CODE --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Calculate reward ---
function reward = Reward(preState, curState, nextState)
	% Set global variable(s) 
	global xRange;
	global yRange;
	global timeScale;
	global Crossroad;
	% Calculate the factors of distance
	destX = xRange(1);
	destY = Crossroad.dir_3_4(3)/2;
	distFactor = ((curState(1)-destX)^2+(curState(2)-destY)^2)/...
				 ((xRange(1)-xRange(2))^2+(yRange(1)-yRange(2))^2);
	% Calculate the factors of degree
	degFactor = abs(curState(3)-135)/45;
	% Calculate the factors of comfort level
	l0 = sqrt((curState(1)-preState(1))^2+(curState(2)-preState(2))^2);
	l1 = sqrt((nextState(1)-curState(1))^2+(nextState(2)-curState(2))^2);
	v0 = l0/timeScale;
	v1 = l1/timeScale;
	drad = deg2rad(nextState(3)-curState(3));
	a_t = (v1*cos(drad)-v0)/timeScale;
	a_r = v1*sin(drad)/timeScale;
	comfDegree = sqrt((1.4*a_t)^2+(1.4*a_r)^2);
	if comfDegree < 0.315
		comfFactor = 1.0;
	elseif comfDegree >= 0.315 && comfDegree < 0.63
		comfFactor = 0.8;	
	elseif comfDegree >= 0.63 && comfDegree < 1.0
		comfFactor = 0.6;		
	elseif comfDegree >= 1.0 && comfDegree < 1.6
		comfFactor = 0.4;
	elseif comfDegree >= 1.6 && comfDegree < 2.5
		comfFactor = 0.2;
	else
		comfFactor = 0;
	end
	% Calculate the reward
	reward = 1/(distFactor+0.01) + 1/(degFactor+0.01) - 1/(comfFactor+0.01);
end

%--- Search for the state with maximum reward ---
function [maxState, maxQ] = FindMaxState(stateList)
	% Initialize variable(s)
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

%--- Map value to index ---
function QValue = GetQValue(state)
	% Set global variable(s)	
	global QMatrix;
	global xScale;
	global xLeftNum;
	global yScale;
	global yDownNum;
	global dirScale;
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
	% Set global variable(s)	
	global QMatrix;
	global xScale;
	global xLeftNum;
	global yScale;
	global yDownNum;
	global dirScale;
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
	% Set global variable(s)	
	global xRange;
	global yRange;
	% Set criterion
	xTerIndexRange = [xRange(1), xRange(1)+0.2];
	yTerIndexRange = [0, yRange(2)];
	% Decide whether vehicle has arrived at the terminal
	if curState(1) >= xTerIndexRange(1) && curState(1) <= xTerIndexRange(2) && ...
	   curState(2) >= yTerIndexRange(1) && curState(2) <= yTerIndexRange(2)
		isTerminal = true;
	else
		isTerminal = false;
	end		
end

%--- Trim number to corresponding scale ---
function trimNumber = Trim(originNumber, scale)
	% Calculate the trimmed value
	trimNumber = round(originNumber/scale)*scale;
end

%------------- END OF SUBFUNCTION(S) --------------