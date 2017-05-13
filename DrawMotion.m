function DrawMotion()
%DrawMotion - Draw the animation of the motion of vehicles 
%
% Syntax:  [~] = DrawMotion()
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
% Subfunctions: TrimPosition
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.05; Last revision: 2017.05.13

%------------- BEGIN MAIN FUNCTION --------------

%--- Set global variable(s) ---
global PositionCell;
global startTime;
global endTime;
global timeStep;
global handle;
global drawRange;

%--- Initialize variable(s) ---
drawRange = [-20, 20, -20, 20];
TrimmedPositionCell = TrimPosition();

%--- Display the animation ---
axis(drawRange);
grid on;
hold on;
for i = 1:1:size(TrimmedPositionCell, 1)
	% Initialize variable(s)
	positionTable = TrimmedPositionCell{i, 1};
	curTime = startTime+(i-1)*timeStep;
	% Draw the figure
	handle = scatter(positionTable( : , 2), positionTable( : , 3), 'k');
	title(['Time: ', num2str(curTime)],'fontsize',14);
	pause(timeStep);
	delete(handle);
end

%------------- END OF MAIN FUNCTION --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Select the points within given range ---
function TrimmedPositionCell = TrimPosition()
	% Set global variable(s)
	global PositionCell;
	global drawRange;
	% Initialize variable(s)
	cellLength = size(PositionCell, 1);
	TrimmedPositionCell = cell(cellLength, 1);

	for i = 1:1:cellLength
		positionTable = PositionCell{i, 1};
		xList = positionTable( : , 2);
		yList = positionTable( : , 3);
		xValidIndex = intersect(find(xList>=drawRange(1)), find(xList<=drawRange(2)));
		yValidIndex = intersect(find(yList>=drawRange(3)), find(yList<=drawRange(4)));
		validIndex = intersect(xValidIndex, yValidIndex);
		TrimmedPositionCell{i, 1} = positionTable(validIndex, : );
	end
end

%------------- END OF SUBFUNCTION(S) --------------