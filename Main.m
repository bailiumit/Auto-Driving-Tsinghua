%Main - Calculate the convert rate at crossroads (no VMS)
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

%--- Start timing ---
tic;

%--- System setting ---
clc;
warning off;

%--- Set global variables ---
% Templates of static struct
global Vehicle;
global Crossroad;
% Dynamic
global VehicleList;
global Schedule;
global curTime;

%--- Initialize variables ---
% Define Vehicle
Vehicle = struct('ID', 0, ...
				 'size', [3, 1.8], ...  % length, width (unit: m)
				 'type', 1, ...  % non-auto: 0; auto: 1
				 'dynamic', [15, 0, 30, 1.5], ...  % speed (m/s), acceleration (m/s^2), max speed (m/s), max acceleration (m/s^2)
				 'route', [1, 1, 2], ... % crossID, start entrance, end entrance
				 'position', [1, 0, 0, 0], ...  % laneID, centerX (m), centerY (m), direction (degree)
				 'laneTrace', [], ...  %
				 'crossTrace', zeros(1, 7) ...  % time, crossID, entranceID, laneID, centerX, centerY, direction
				 );
% Define Schedule
Crossroad = struct('signal', [3, 20, 0.3, 0.15, 0.3, 0.15], ... % phase, cycle length, 1&5 s/r, 1&5 l, 3&7 s/r, 3&7 l
				   'dir_1_2', [30, 2, 3.75], ... % length, lane number, lane width (unit: meter)
				   'dir_3_4', [30, 2, 3.75], ... % length, lane number, lane width (unit: meter)
				   'dir_5_6', [30, 2, 3.75], ... % length, lane number, lane width (unit: meter)
				   'dir_7_8', [30, 2, 3.75], ... % length, lane number, lane width (unit: meter)
				   'turningR', 10 ... % radius of the circular bead
				   );
% Initialize dynamic variables
VehicleList = Vehicle;
Schedule = zeros(0, 3); % crossID, vehicleID, status (0: outside crossroad area; 1: inside crossroad area)

%--- Do Simulation ---
% Set parameters
startTime = 0;
endTime = 100;
timeStep = 1;
% Begin Simulation
curID = 0;
for curTime = startTime:timeStep:endTime
	for i = 1:1:CalVehicleNum()
		[newVehicle, curID] = GenerateVehicle(curID);
		AddVehicle(newVehicle);
	end
	XroadSimulation();
	
end

%--- Stop timing ---
toc;

%------------- END OF CODE --------------





