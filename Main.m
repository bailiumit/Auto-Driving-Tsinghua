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
% 2017.02; Last revision: 2017.06.04

%------------- BEGIN CODE --------------

%--- Start timing ---
tic;

%--- System setting ---
clc;
clear global;
warning off;

%--- Set global variable(s) ---
InitializeGlobal();

%--- Train and test single agent turning strategy ---
% Note: only available to 2-lane road (need to change Crossroad.dir_m_n(2) to 2)
% OptTurning();
% TestTurning();

%--- Train and test multi-agent turning strategy ---
% OptLine(0);
% TestLine(0);
% OptLine(1);
% TestLine(1);

%--- Train and test traffic signal strategy ---
% OptSignal(1);
% OptSignal(2);
% OptSignal(3);
% TestSignal(1);
% TestSignal(2);
% TestSignal(3); 

%--- Display the result ---
SimuXRoad();
DrawMotion();

%--- Investigate how multiple factors impact the optimization effect ---
% InvestigateEffect();

%--- Stop timing ---
toc;

%------------- END OF CODE --------------