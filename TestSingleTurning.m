function TestSingleTurning()
%TestSingleTurning - Simulate the left-turning process
%
% Syntax:  [] = TurningSimulation()
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
% Subfunctions: CalQValue, FindMaxState, JudgeTerminal, GetQValue, DrawTurningTrace, Trim
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.03; Last revision: 2017.04.05

%------------- BEGIN CODE --------------

%--- Set global variable(s) ---
global Crossroad;
global xScale;
global yScale;
global yDownNum;
global timeScale;

%--- Initialize variable(s) ---
initialSpeed = randi([0, 20])/2;
curState = [Trim(Crossroad.dir_1_2(3)/2, xScale), -yDownNum*yScale, 90, 0];
preState = curState;
preState(2) = curState(2) - initialSpeed*0.1;
% stateTrace = curState;
stateTrace = zeros(0, 4);

%--- Do testing ---
disp('Testing: ');
while ~JudgeTerminal(curState)
	% Update state
	nextStateList = CalTurningAction(preState, curState);
	[nextState, curQ] = FindMaxState(nextStateList);
	preState = curState;
	curState = nextState;
	% Save current state
	stateTrace = [stateTrace; curState];
	% Display curState
	disp(curState);
end

%--- Display result ---
% Calculate time cost of turning
turningTime = size(stateTrace, 1)*timeScale;
disp(['Turning time is: ', num2str(turningTime)]);
% Draw the trace
DrawTurningTrace(stateTrace);

%------------- END OF CODE --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Calculate/get the Q value of a specific state ---
function QValue = CalQValue(state)
	% Initialize variable(s)
	QValue = GetQValue(state);
	% If the state has not been trained, do calculation
	if QValue == 0
		near3State = SearchNearState(state);

	end
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

%--- Draw trace ---
function DrawTurningTrace(stateTrace)
	% Set global variable(s)	
	global xRange;
	global xScale;
	global yRange;
	global yScale;
	% Draw the trace
	% plot(stateTrace( : , 1), stateTrace( : , 2), 'Marker', '*');
	plot(stateTrace( : , 1), stateTrace( : , 2), 'LineWidth', 1.5);
	axis([xRange(1), xRange(2), yRange(1), yRange(2)])
	grid on;
	hold on;
	% Draw the omitted area
	omitAreaTable = zeros(0, 2);
	for x = xRange(1):xScale:xRange(2)
		for y = yRange(1):yScale:yRange(2)
			if JudgeExceed(x, y)
				omitAreaTable = [omitAreaTable; [x, y]];
			end
		end
	end
	scatter(omitAreaTable( : , 1), omitAreaTable( : , 2), '.');
end

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

%--- Trim number to corresponding scale ---
function trimNumber = Trim(originNumber, scale)
	% Calculate the trimmed value
	trimNumber = round(originNumber/scale)*scale;
end

%------------- END OF SUBFUNCTION(S) --------------