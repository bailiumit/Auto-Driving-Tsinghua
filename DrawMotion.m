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
% Subfunctions: 
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.05; Last revision: 2017.05.15

%------------- BEGIN MAIN FUNCTION --------------

%--- Set global variable(s) ---
global PositionCell;
global startTime;
global endTime;
global timeStep;
global frameTime;
global handle;
global drawRange;

%--- Initialize variable(s) ---
drawRange = [-20, 20, -20, 20];
frameTime = timeStep;

%--- Display the animation ---
axis(drawRange);
grid on;
hold on;
for i = 1:1:size(PositionCell, 1)
	% Initialize variable(s)
	positionTable = PositionCell{i, 1};
	curTime = startTime+(i-1)*timeStep;
	% Draw the figure
	handle = scatter(positionTable( : , 2), positionTable( : , 3), 'k');
	title(['Time: ', num2str(curTime)],'fontsize',14);
	pause(frameTime);
	delete(handle);
end

%------------- END OF MAIN FUNCTION --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------


%------------- END OF SUBFUNCTION(S) --------------