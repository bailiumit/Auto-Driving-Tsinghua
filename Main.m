%Main - Core console
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
% 2017.02; Last revision: 2017.04.10

%------------- BEGIN CODE --------------

%--- Start timing ---
tic;

%--- System setting ---
clc;
clear global;
warning off;

%--- Set global variable(s) ---
InitializeGlobal();

global VehicleList;


%--- Train and test the turning strategy ---
% OptTurning();
% TestTurning();

%--- Train and test traffic signal strategy ---
% OptSignal();
% TestSignal();

%--- Train and test road structure strategy ---
% TestStructure();


XroadSimulation();


%--- Stop timing ---
toc;

%------------- END OF CODE --------------