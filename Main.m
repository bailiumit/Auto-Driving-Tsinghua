%Main - Core console
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
% 2017.02; Last revision: 2016.04.05

%------------- BEGIN CODE --------------

%--- Start timing ---
tic;

%--- System setting ---
clc;
clear global;
warning off;

%--- Set global variables ---
global QMatrix;

InitializeGlobal();

%--- Train the turning strategy ---
SingleAgentQL();

% --- Test the turning strategy ---
turningTime = TurningSimulation();

% %--- Do Simulation ---
% % Set parameters
% startTime = 0;
% endTime = 100;
% timeStep = 1;
% % Begin Simulation
% curID = 0;
% for curTime = startTime:timeStep:endTime
% 	for i = 1:1:CalVehicleNum()
% 		[newVehicle, curID] = GenerateVehicle(curID);
% 		AddVehicle(newVehicle);
% 	end
% 	XroadSimulation();
	
% end

%--- Stop timing ---
toc;

%------------- END OF CODE --------------