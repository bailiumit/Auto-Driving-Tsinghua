function stateList = CalLineAction(curState, optType)
%CalLineAction - Calculate available states for next step (for Q-Learning)
%
% Syntax:  stateList = CalLineAction(curState, optType)
%
% Inputs:
%    curState - current state    
%    optType - 0: auto + auto; 1: auto + normal
%
% Outputs:
%    stateList - collection of possible states
%
% Example: 
%    none
%
% Other m-files required: none
% Subfunctions: JudgeValid, Trim
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.05; Last revision: 2017.05.07

%------------- BEGIN CODE --------------

%--- Set global variable(s) ---
global maxV;
global maxAcc;
global minAcc;
global intScale;
global intRange;
global vScale;
global vRange;
global timeScaleM;

%--- Set car following model parameter(s) ---
sensitivity = 1;

%--- Initialize variable(s) ---
stateList = zeros(0, 3);
curInt = curState(1);
curV1 = curState(2);
curV2 = curState(3);

%--- Calculate states ---
% Calculate the possible states of the speed of vehicle 1
nextV1Max = Trim(min(curV1+maxAcc*timeScaleM, maxV), vScale);
nextV1Min = Trim(max(curV1+minAcc*timeScaleM, 0), vScale);
nextV1List = nextV1Min:vScale:nextV1Max;
% Calculate the possible states of the speed of vehicle 2
switch optType
	% auto + auto
	case 0
		nextV2Max = Trim(min(curV2+maxAcc*timeScaleM, maxV), vScale);
		nextV2Min = Trim(max(curV2+minAcc*timeScaleM, 0), vScale);
		nextV2List = nextV2Min:vScale:nextV2Max;
	% auto + normal
	case 1
		curAcc2 = max(min(sensitivity*(curV1-curV2), maxAcc), minAcc);
		nextV2 = Trim(max(min(curV2+curAcc2*timeScaleM, maxV), 0), vScale);
		nextV2List = nextV2;
	otherwise
		disp('Error in CalLineAction()');
end

%--- Calculate stateList ---
for i = 1:1:length(nextV1List)
	for j = 1:1:length(nextV2List)
		% Initialize variable(s) 
		nextV1 = nextV1List(i);
		nextV2 = nextV2List(j);
		% Calculate interval
		nextInt = Trim(curInt+((curV1+nextV1)/2)*timeScaleM-((curV2+nextV2)/2)*timeScaleM, intScale);
		% Add to stateList
		state = [nextInt, nextV1, nextV2];
		if JudgeValid(state)
			stateList = [stateList; state];
		end
	end
end

%------------- END OF CODE --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Decide whether the agent is in danger ---
function isValid = JudgeValid(state)
	% Set global variable(s)
	global intRange;
	% Set parameter(s)
	minInt = 0.5;
	% Decide whether the state is valid
	if state(1) >= minInt && state(1) <= intRange(2)
		isValid = true;
	else
		isValid = false;
	end
end

%--- Trim number to corresponding scale ---
function trimNumber = Trim(originNumber, scale)
	% Calculate the trimmed value
	trimNumber = round(originNumber/scale)*scale;
end

%------------- END OF SUBFUNCTION(S) --------------