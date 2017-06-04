function TestSignal(optimizeType)
%TestTurning - Test the training result of vehicle interaction strategy optimization
%
% Syntax:  [] = TestLine(optimizeType)
%
% Inputs:
%    optimizeType
%
% Outputs:
%    none
%
% Example: 
%    none
%
% Other m-files required: none
% Subfunctions: DrawFigure
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.05; Last revision: 2017.05.24

%------------- BEGIN CODE --------------

%--- Set global variable(s) ---
global optType;
global figureNum;

%--- Load data ---
cd('MatFile');
switch optimizeType
	case 1
		load 'SA_Parameter.mat';
		traceT(end) = [];
	case 2
		load 'GA_Parameter.mat';
	case 3
		load 'PSO_Parameter.mat';
	otherwise
		disp('Error in TestSignal()');
end
cd('..');

%--- Draw the curve of traceT ---
figure(figureNum);
iLine = 1:1:size(traceT, 1);
plot(iLine, traceT, 'LineWidth', 2);
figureNum = figureNum+1;

%--- Draw the 3-D graph of timeCost ---
figure(figureNum);
if optimizeType == 2
	plot(1:1:length(timeCost), timeCost, 'LineWidth', 2);
else
	surf(timeCost);
end
figureNum = figureNum+1;

%------------- END OF MAIN FUNCTION --------------
end