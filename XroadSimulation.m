function XroadSimulation()
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

%------------- BEGIN MAIN FUNCTION --------------

%--- Set global variables ---
% Templates of static struct
global Vehicle;
global Crossroad;
% Dynamic
global VehicleList;
global Schedule;
global curTime;

%--- Initialize variables ---
[vehicleNum, ~] = size(Schedule);
signal = JudgeStage();

%---  ---
if signal ~= 0
	switch signal
	case 1
		body
	case 2
		body
	case 3
		body
	case 4
		body
	otherwise
		disp('Error in switch signal');
end



end



%------------- END OF MAIN FUNCTION --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Decide the stage of the signal ---
function signal = JudgeStage()
	% Set global variables
	global Crossroad;
	global curTime;
	% Calculate the proportion of the signal process
	remainder = rem(curTime-Crossroad.signal(1), Crossroad.signal(2));
	if remainder < 0
		remainder = remainder + Crossroad.signal(2);
	end
	proportion = remainder/Crossroad.signal(2);
	% Calculate the signal stage
	if proportion <= Crossroad.signal(3)
		signal = 1;
	elseif proportion <= Crossroad.signal(3)+Crossroad.signal(4)
		signal = 2;
	elseif proportion <= Crossroad.signal(3)+Crossroad.signal(4)+Crossroad.signal(5)
		signal = 3;
	elseif proportion <= Crossroad.signal(3)+Crossroad.signal(4)+Crossroad.signal(5)+Crossroad.signal(6)
		signal = 4;
	else
		signal = 0;
	end
end


%------------- END OF SUBFUNCTION(S) --------------


