function vehicleNum = CalVehicleNum()
%CalVehicleNum - Calculate the number of vehicles to be generated
%
% Syntax:  vehicleNum = CalVehicleNum()
%
% Inputs:
%    none
%
% Outputs:
%    vehicleNum - the number of vehicles  
%
% Example: 
%    none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2016.02; Last revision: 2016.05.15

%------------- BEGIN CODE --------------

%--- Calculate the number of vehicles in a unit ---
if rand < 0.2
	vehicleNum = 1;
else
	vehicleNum = 0;
end

%------------- END OF CODE --------------
end