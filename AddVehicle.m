function AddVehicle(newVehicle)
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
% Struct Template
global Vehicle;
global Crossroad;
% Dynamic
global VehicleList;
global Schedule;
global curTime;

%--- Add new vehicle to VehicleList ---
VehicleList(newVehicle.ID) = newVehicle;

%--- Add new vehicle to Schedule ---
Schedule = [Schedule; [newVehicle.route(1), newVehicle.ID, 1]];

%------------- END OF CODE --------------
end