function TestLine(optType)
%TestTurning - Test the training result of vehicle interaction strategy optimization
%
% Syntax:  [] = TestLine(optType)
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
% Subfunctions: GenRandState, FindMaxState, GetQValue, DrawTurningTrace, Trim
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.05; Last revision: 2017.05.10

%------------- BEGIN CODE --------------

%--- Set global variable(s) ---
global optType;

%--- Set test parameter(s) ---
endTime = 5;
timeScaleTestLine = 0.2;
tArray = 0:timeScaleTestLine:endTime;

%--- Initialize variable(s) ---
[preState, curState, curQ] = GenRandState();
% stateTrace = curState;
stateTrace = zeros(0, 3);

%--- Do testing ---
disp('Testing: ');
for t = 0:timeScaleTestLine:endTime
	% Update state
	nextStateList = CalLineAction(curState, optType);
	[nextState, curQ] = FindMaxState(nextStateList);
	preState = curState;
	curState = nextState;
	% Save current state
	stateTrace = [stateTrace; curState];
	% Display curState
	disp(curState);
end

%--- Display result ---
DrawTurningTrace(tArray, stateTrace);

%------------- END OF CODE --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

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

%--- Draw trace ---
function DrawTurningTrace(tArray, stateTrace)
	% Draw the traces of vehicle speed
	yyaxis left;
	plot(tArray, stateTrace( : , 2), 'LineWidth', 1.5);
	hold on;
	plot(tArray, stateTrace( : , 3), 'LineWidth', 1.5);
	ylim([0, max(max(stateTrace( : , 2:3)))*1.25]);
	ylabel('Speed (m/s)')
	% Draw the trace of interval
	yyaxis right;
	plot(tArray, stateTrace( : , 1), 'LineWidth', 1.5);
	ylim([0, max(stateTrace( : , 1))*1.5]);
	ylabel('Distance (m)')
	% Others
	xlabel('time(s)');
	legend('Vehicle 1', 'Vehicle 2', 'Interval');
	grid on;
end

%--- Trim number to corresponding scale ---
function trimNumber = Trim(originNumber, scale)
	% Calculate the trimmed value
	trimNumber = round(originNumber/scale)*scale;
end

%------------- END OF SUBFUNCTION(S) --------------