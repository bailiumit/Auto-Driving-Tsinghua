function TurningSimulation()
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
stateTrace = zeros(0, 4);

%--- Do testing ---
disp('Testing');
curState = [randi([0, xRightNum])*xScale, -yDownNum*yScale, 90, 0];
while ~JudgeTerminal(curState)
	nextStateList = CalAction(curState);
	[nextState, curQ] = FindMaxState(nextStateList);
	curState = nextState;
	% Save current state
	stateTrace = [stateTrace; curState];

	disp([curState, curQ]);
end

%--- Draw trace ---
figure(1)
plot(stateTrace( : , 1), stateTrace( : , 2));

%------------- END OF CODE --------------
end

%------------- BEGIN SUBFUNCTION(S) --------------

%--- Calculate/get the Q value of a specific state ---
function QValue = CalQValue(state)
	% Initialize variables
	QValue = GetQValue(state);
	% If the state has not been trained, do calculation
	if QValue == 0
		near3State = SearchNearState(state);

	end
end

%--- Search for the nearest trained state ---
function nearState = SearchNearState(state)
	% Set global variables
	global xRange;
	global yRange;
	global dirRange;


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

%------------- END OF SUBFUNCTION(S) --------------




