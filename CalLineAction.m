function stateList = CalLineAction(curState, type)
%CalLineAction - Calculate available states for next step (for Q-Learning)
%
% Syntax:  stateList = CalLineAction(curState, type)
%
% Inputs:
%    curState - current state    
%    type - 0: auto + auto; 1: auto + normal
%
% Outputs:
%    stateList - collection of possible states
%
% Example: 
%    none
%
% Other m-files required: none
% Subfunctions: Trim
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.05; Last revision: 2017.05.06

%------------- BEGIN CODE --------------

%--- Set global variable(s) ---
global maxAcc;
global intScale;
global intRange;
global vScale;
global vRange;
global timeScaleM;

%--- Initialize variable(s) ---
stateList = zeros(0, 3);

%--- Calculate stateList ---
switch type
	% auto + auto
	case 1
		
	% auto + normal
	case 2

	otherwise
		disp('Error in CalLineAction()');
end

%------------- END OF CODE --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Trim number to corresponding scale ---
function trimNumber = Trim(originNumber, scale)
	% Calculate the trimmed value
	trimNumber = round(originNumber/scale)*scale;
end

%------------- END OF SUBFUNCTION(S) --------------