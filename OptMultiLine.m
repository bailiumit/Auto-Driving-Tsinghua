function OptMultiLine()
%OptMultiLine - Train car following strategy with Q-learning method
%
% Syntax:  [~] = OptMultiLine()
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
% Subfunctions: 
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.05; Last revision: 2017.05.06

%------------- BEGIN CODE --------------

%--- Set global variable(s) ---
% Q Matrix
global QMatrixLine;
% Parameters
global intScale;
global intRange;
global vScale;
global vRange;
global timeScaleM;

%--- Set training parameters ---
alpha = 0.5;	% learning rate
gamma = 0.5;	% discount rate
epsilon = 0.2;	% greedy strategy parameter
discount = 0.999;	% discount factor of epsilon
iterationTimes = 1000;	% times of iteration
endTime = 100;

%--- Initialize variable(s) ---
tStart = cputime;

%--- Do training ---
for i = 1:1:iterationTimes
	% Begin timing of the iteration
	tIterStart = cputime;
	% Select an initial state randomly
	preState = GenRandState();
	curState = preState;
	% Do value iteration until reaching terminal
	while ~JudgeTerminal(curState)
		% List all possible action(s) 
		nextStateList = CalLineAction(curState);
		% Choose action using epsilon-greedy strategy
		if rand > epsilon
			[nextState, curQ] = FindMaxState(nextStateList);
		else
			randIndex = randi(size(nextStateList, 1));
			nextState = nextStateList(randIndex, : );
			curQ = GetQValue(nextState);
		end
		% Calculate maximum possible Q value of next action
		next2StateList = CalLineAction(nextState);
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
	zeroNum = sum(sum(sum(QMatrixLine == 0)));
	totalNum = numel(QMatrixLine);
	validNum = totalNum - zeroNum;
	disp(['Iteration: ', num2str(i), '  ', ...
		  'Coverage: ', num2str(validNum/totalNum*100), '%  ', ...
		  'Iteration Time: ', num2str(tIterEnd-tIterStart), 's  ', ...
		  'Total Time: ', num2str(tIterEnd-tStart), 's  ', ...
		  'Average Time: ', num2str((tIterEnd-tStart)/i), 's']);
	% Save QMatrixLine 
	if mod(i, 50) == 0 || i == iterationTimes
		save('QMatrixLine.mat', 'QMatrixLine');
		disp(['Save QMatrixLine in iteration ', num2str(i)]);
	end
end

%------------- END OF CODE --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Calculate reward ---
function reward = Reward(preState, curState, nextState)
	% Set global variable(s)	
	global intScale;
	global intRange;
	global vScale;
	global vRange;
	% Initialize variable(s)
	bestInterval = 3;
	% Calculate the factors of the distance to the previous vehicle

	% Calculate the factors of interval between the two vehicles
	intFactor = abs(curState(1)-bestInterval)/bestInterval;
	% Calculate the factors of comfort level
	l0 = abs(curState(1)-preState(1));
	l1 = abs(nextState(1)-curState(1));
	v0 = l0/timeScale;
	v1 = l1/timeScale;
	a = (v1-v0)/timeScale;
	if a < 0.315
		comfFactor = 1.0;
	elseif a >= 0.315 && a < 0.63
		comfFactor = 0.8;	
	elseif a >= 0.63 && a < 1.0
		comfFactor = 0.6;		
	elseif a >= 1.0 && a < 1.6
		comfFactor = 0.4;
	elseif a >= 1.6 && a < 2.5
		comfFactor = 0.2;
	else
		comfFactor = 0;
	end
	% Calculate the reward
	reward = 1/(intFactor+0.01) - 1/(comfFactor+0.01);
end

%--- Generate random state ---
function state = GenRandState()
	% Set global variable(s)	
	global intScale;
	global intRange;
	global vScale;
	global vRange;
	% Initialize variable(s)
	state = zeros(3, 1);
	% Initialize interval
	state(1) = Trim(intRange(1)+(intRange(2)-intRange(1))*rand, intScale);
	% Initialize speed
	state(2) = Trim(vRange(1)+(vRange(2)-vRange(1))*rand, vScale);
	state(3) = Trim(vRange(1)+(vRange(2)-vRange(1))*rand, vScale);
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

%--- Update state in Q matrix ---
function UpdateQMatrixLine(state, QValue)
	% Set global variable(s)	
	global QMatrixLine;
	global intScale;
	global vScale;
	% Calculate index of interval
	intIndex = fix(state(1)/intScale)+1;
	% Calculate index of speed
	vIndex1 = fix(state(2)/vScale)+1;
	vIndex2 = fix(state(3)/vScale)+1;
	% Calculate the value in Q matrix
	QMatrixLine(intIndex, vIndex1, vIndex2) = QValue;
end

%--- Trim number to corresponding scale ---
function trimNumber = Trim(originNumber, scale)
	% Calculate the trimmed value
	trimNumber = round(originNumber/scale)*scale;
end

%------------- END OF SUBFUNCTION(S) --------------