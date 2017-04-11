function OptSignal(optimizeType)
%OptSignal - Optimize traffic signal display strategy
%
% Syntax:  [~] = OptSignal()
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
% MAT-files required: QMatrix.mat
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.04; Last revision: 2017.04.10

%------------- BEGIN MAIN FUNCTION --------------

%--- Set global variable(s) ---
% Templates of static struct
global Vehicle;
global Crossroad;
% Dynamic
global VehicleList;
global curTime;

%--- Optimize traffic signal ---
switch optimizeType
	case 1
		SA();
	case 2
		GA();
    case 3
		PSO();
	otherwise
		disp('Error in OptSignal()');
end

%--- Save signal to .mat file ---
save('signalStrategy.mat', 'Crossroad.signal');

end



%------------- END OF MAIN FUNCTION --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Simulated Anneling ---
function SA()

end

%--- Optimize traffic signal with GA ---
function GA()

end

%--- Optimize traffic signal with PSO ---
function PSO()

end

%------------- END OF SUBFUNCTION(S) --------------