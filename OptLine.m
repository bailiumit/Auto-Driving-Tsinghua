function OptLine(optType)
%OptLine - Train car following strategy with Q-learning method
%
% Syntax:  [~] = OptLine(optType)
%
% Inputs:
%    optType - 0: auto + auto; 1: auto + normal
%
% Outputs:
%    none
%
% Example: 
%    none
%
% Other m-files required: none
% Subfunctions: Reward, GenRandState, FindMaxState, GetQValue, UpdateQMatrixLine, Trim
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.05; Last revision: 2017.05.09

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
% Temporary
global optType;

%--- Set training parameters ---
alpha = 0.3;	% learning rate
gamma = 0.5;	% discount rate
epsilon = 0.2;	% greedy strategy parameter
discount = 0.9997;	% discount factor of epsilon
iterationTimes = 10000;	% times of iteration
endTime = 10;

%--- Initialize variable(s) ---
tStart = cputime;
emptyCount = 0;

%--- Do training ---
for i = 1:1:iterationTimes
	% Begin timing of the iteration
	tIterStart = cputime;
	% Select an initial state randomly
	[preState, curState, curQ] = GenRandState();
	% Initialize variable(s)
	nextState = zeros(1, 3);
	newQ = 0;
	% Do value iteration until reaching terminal
	for t = 0:timeScaleM:endTime
		% List all possible action(s) 
		nextStateList = CalLineAction(curState, optType);
		if isempty(nextStateList)
			% Update Q			
			newQ = -Inf;
			% Update state
			[preState, curState, curQ] = GenRandState();
			% Update emptyCount
			emptyCount = emptyCount+1;
		else
			% Choose action using epsilon-greedy strategy
			if rand > epsilon
				[nextState, curQ] = FindMaxState(nextStateList);
			else
				randIndex = randi(size(nextStateList, 1));
				nextState = nextStateList(randIndex, : );
				curQ = GetQValue(nextState);
			end
			% Calculate maximum possible Q value of next action
			next2StateList = CalLineAction(nextState, optType);
			% Update Q
			if isempty(next2StateList)
				% Update Q			
				newQ = -Inf;
				% Update state
				[preState, curState, curQ] = GenRandState();
				% Update emptyCount
				emptyCount = emptyCount+1;
			else
				[~, nextMaxQ] = FindMaxState(next2StateList);
				% Update Q matrix
				newQ = curQ + alpha*(Reward(preState, curState, nextState) + gamma*nextMaxQ - curQ);
				% Update state
				preState = curState;
				curState = nextState;
			end
		end
		% Update Q matrix
		UpdateQMatrixLine(curState, newQ);
	end
	% Decrease epsilon
	epsilon = epsilon*discount;
	% End timing of the iteration
	tIterEnd = cputime;
	% Display the iteration information
	zeroNum = sum(sum(sum(sum(QMatrixLine == 0))));
	totalNum = numel(QMatrixLine);
	validNum = totalNum - zeroNum;
	disp(['Iteration: ', num2str(i), '  ', ...
		'Coverage: ', num2str(validNum/totalNum*100), '%  ', ...
		'Iteration Time: ', num2str(tIterEnd-tIterStart), 's  ', ...
		'Total Time: ', num2str(tIterEnd-tStart), 's  ', ...
		'Average Time: ', num2str((tIterEnd-tStart)/i), 's  ', ...
		'Empty Count: ', num2str(emptyCount)]);
	% Save QMatrixLine 
	if mod(i, 50) == 0 || i == iterationTimes
		cd('MatFile');
		save('QMatrixLine.mat', 'QMatrixLine');
		cd('..');
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
	global timeScaleM;
	% Initialize variable(s)
	bestSpeed = 5;
	minThreInt = 3;
	maxThreInt = 7;
	% Calculate the factors of speed
	vFactor1 = abs(curState(2)-bestSpeed)/bestSpeed;
	vFactor2 = abs(curState(3)-bestSpeed)/bestSpeed;
	% Calculate the factor of interval
	if curState(1) < minThreInt
		intFactor = abs(curState(1)-intRange(1))/abs(minThreInt-intRange(1));
	elseif curState(1) > maxThreInt
		intFactor = abs(intRange(2)-curState(1))/abs(intRange(2)-maxThreInt);
	else
		intFactor = Inf;
	end
	% Calculate the reward
	reward = 1/(vFactor1+0.01)^2 + 1/(vFactor2+0.01)^2;
end

%--- Generate random state ---
function [preState, curState, curQ] = GenRandState()
	% Set global variable(s)	
	global intScale;
	global intRange;
	global vScale;
	global vRange;
	global optType;
	% Initialize variable(s)
	preState = zeros(1, 3);
	curState = zeros(1, 3);
	curStateList = zeros(0, 3);
	randVMin = 2;
	randVMax = 6;
	randIntMin = 3;
	randIntMax = 7;
	% Initialize preState
	while isempty(curStateList)
		preState(1) = Trim(randIntMin+(randIntMax-randIntMin)*rand, intScale);
		preState(2) = Trim(randVMin+(randVMax-randVMin)*rand, vScale);
		preState(3) = Trim(randVMin+(randVMax-randVMin)*rand, vScale);
		curStateList = CalLineAction(preState, optType);
	end
	% Initialize curState
	[curState, curQ] = FindMaxState(curStateList);
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
	global QMatrixLine;
	global intScale;
	global vScale;
	global optType;
	% Calculate index of optimization type
	typeIndex = optType+1;
	% Calculate index of interval
	intIndex = floor(state(1)/intScale)+1;
	% Calculate index of speed
	vIndex1 = floor(state(2)/vScale)+1;
	vIndex2 = floor(state(3)/vScale)+1;
	% Calculate the value in Q matrix
	QValue = QMatrixLine(typeIndex, intIndex, vIndex1, vIndex2);
end

%--- Update state in Q matrix ---
function UpdateQMatrixLine(state, QValue)
	% Set global variable(s)	
	global QMatrixLine;
	global intScale;
	global vScale;
	global optType;
	% Calculate index of optimization type
	typeIndex = optType+1;
	% Calculate index of interval
	intIndex = floor(state(1)/intScale)+1;
	% Calculate index of speed
	vIndex1 = floor(state(2)/vScale)+1;
	vIndex2 = floor(state(3)/vScale)+1;
	% Calculate the value in Q matrix
	QMatrixLine(typeIndex, intIndex, vIndex1, vIndex2) = QValue;
end

%--- Trim number to corresponding scale ---
function trimNumber = Trim(originNumber, scale)
	% Calculate the trimmed value
	trimNumber = round(originNumber/scale)*scale;
end

%------------- END OF SUBFUNCTION(S) --------------