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
% Subfunctions: SA, GA, PSO
% MAT-files required: QMatrix.mat
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.04; Last revision: 2017.04.24

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
		traceT = SA();
	case 2
		traceT = GA();
    case 3
		[optSignalPara, traceT, timeCost] = PSO();
	otherwise
		disp('Error in OptSignal()');
end

% figure(figureNum);
iLine = 1:1:size(traceT, 1);
plot(iLine, traceT, 'LineWidth', 2);

%--- Save signal to .mat file ---
optSignal = Crossroad.signal;
optSignal(1) = optSignalPara(1);
optSignal(3:5) = optSignalPara(2:4);
optSignal(6) = 1-sum(optSignalPara(2:4));
save('signalStrategy.mat', 'optSignal');

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
function [optSignalPara, traceT, timeCost] = PSO()
	% Set global variable(s) 
	global Crossroad;
	% Set PSO parameters
	iterationNum = 100;
	agentNum = 10;
	w = 0.9;
	c1 = 0.5;
	c2 = 0.5;
	% Initialize variables
	tStart = cputime;
	iniSignal = Crossroad.signal;
	iniS = [0, 0.25, 0.25, 0.25];
	iniT = CalTime(iniS);
	gBestS = iniS;
	gBestT = iniT;
	traceS = zeros(iterationNum+1, length(iniS));
	traceS(1,  : ) = iniS;
	traceT = zeros(iterationNum+1, 1);
	traceT(1) = iniT;
	timeCost = zeros(iterationNum, agentNum);
	% Initialize agents
	for i = 1:1:agentNum
		iniV = rand(1, length(iniS))-0.5;
		Agent(i) = struct('curV', iniV, ...
						  'curS', iniS, ...
						  'curT', iniT, ...
						  'pBestS', iniS, ...
						  'pBestT', iniT);
	end
	% Do iteration
	for i = 1:1:iterationNum
		disp(['--- Iteration: ', num2str(i), ' ---']);
		for j = 1:1:agentNum
			% Begin timing of the agent
			tAgentStart = cputime;
			% Update curV
			Agent(j).curV = w*Agent(j).curV + c1*rand()*(Agent(j).pBestS-Agent(j).curS) + c2*rand()*(gBestS-Agent(j).curS);
			% Update curS and curT
			Agent(j).curS = ExamineSignal(Agent(j).curS + Agent(j).curV);
			Agent(j).curT = CalTime(Agent(j).curS);
			% Update pBestS and pBestT
			if Agent(j).curT < Agent(j).pBestT
				Agent(j).pBestS = Agent(j).curS;
				Agent(j).pBestT = Agent(j).curT;
				% Update gBestS and gBestT
				if Agent(j).curT < gBestT
					gBestS = Agent(j).curS;
					gBestT = Agent(j).curT;
				end
			end
			% End timing of the agent
			tAgentEnd = cputime;
			% Calculate optimization data
			agentTime = tAgentEnd-tAgentStart;
			totalTime = tAgentEnd-tStart;
			timeCost(i, j) = agentTime;
			% Display agent data
			disp(['Iteration: ', num2str(i), '  ', ...
				  'Agent: ', num2str(i), '  ', ...
			  	  'Agent Time: ', num2str(agentTime), 's  ', ...
				  'Total Time: ', num2str(totalTime), 's']);
		end
		% Mark current gBestS and gBestT
		traceS(i+1,  : ) = gBestS;
		traceT(i+1,  : ) = gBestT;
		% Save data
		if mod(i, 5) == 0
			save('ParaPSO.mat', 'traceS', 'traceT');
			disp(['Save PSO parameters in iteration ', num2str(i)]);
		end
	end
	% Return optimal signal
	Crossroad.signal = iniSignal;
	optSignalPara = gBestS;
end

%--- Do simulation and calculate the average traveling time ---
function aveTime = CalTime(signal)
	% Set global variable(s) 
	global Crossroad;
	global VehicleList;
	global timeStep;
	% Do the simulation
	Crossroad.signal(1) = signal(1);
	Crossroad.signal(3:5) = signal(2:4);
	Crossroad.signal(6) = 1-sum(signal(2:4));
	XroadSimulation();
	% Initialize variable(s)
	timeList = zeros(0, 1);
	for i = 1:1:size(VehicleList, 2)
		if VehicleList(i).state == -1
			timeList = [timeList; size(VehicleList(i).trace, 1)*timeStep];
		end
	end
	% Calculate the time
	aveTime = mean(timeList);
end

%--- Examine the signal to ensure its validity ---
function validSignal = ExamineSignal(signal)
	% Initialize variable(s)
	validSignal = signal;
	lowBound = 0.1;
	upBound = 0.6;
	propotion = [signal(2:4), 1-sum(signal(2:4))];
	% Do the correction
	for i = 1:1:length(propotion)
		if propotion(i) < lowBound
			propotion(i) = lowBound;
		elseif propotion(i) > upBound
			propotion(i) = upBound;
		end		
	end
	% Do nomalization
	propotion = propotion/sum(propotion);
	validSignal(2:4) = propotion(1:3);
end

%------------- END OF SUBFUNCTION(S) --------------