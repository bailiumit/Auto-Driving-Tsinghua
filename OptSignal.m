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
% 2017.04; Last revision: 2017.05.06

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
		[optS, traceT, timeCost] = SA();
	case 2
		[optS, traceT, timeCost] = GA();
	case 3
		[optS, traceT, timeCost] = PSO();
	otherwise
		disp('Error in OptSignal()');
end

%--- Draw the Figure ---
% figure(figureNum);
iLine = 1:1:size(traceT, 1);
plot(iLine, traceT, 'LineWidth', 2);

%--- Save signal to .mat file ---
optSignal = Crossroad.signal;
optSignal(1) = optS(1);
optSignal(3:6) = optS(2:5);
cd('MatFile');
save('Signal.mat', 'optSignal');
cd('..');

%------------- END OF MAIN FUNCTION --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Optimize traffic signal with SA ---
function [gBestS, traceT, timeCost] = SA()
	% Set global variable(s) 
	global Crossroad;
	iniSignal = Crossroad.signal;
	% Set parameters
	iniTemp = 100;
	minTemp = 10;
	iLoop = 10;
	r = 0.99;
	k = 100;
	scale = [5, 0.1, 0.1, 0.1, 0.1];
	% Initialize optimization variables
	iterationNum = ceil(log(minTemp/iniTemp)/log(r));
	curTemp = iniTemp;
	iniS = [10, 0.25, 0.25, 0.25, 0.25];
	iniT = CalTime(iniS);
	gBestS = iniS;
	gBestT = iniT;
	% Initialize optimization record variables
	tStart = cputime;
	traceS = zeros(iterationNum+1, length(iniS));
	traceS(1,  : ) = iniS;
	traceT = -1000*ones(iterationNum+1, 1);
	traceT(1) = iniT;
	timeCost = -1000*ones(iterationNum, iLoop);
	% Do SA
	for i = 1:1:iterationNum
		disp(['--- Iteration: ', num2str(i), ', Tempature: ', num2str(curTemp), ' ---']);
		% Update agents within loops
		for j = 1:1:iLoop
			% Begin timing of the agent
			tAgentStart = cputime;
			% Generate new signal
			newS = ExamineSignal(gBestS+(0.5-rand(1, 5)).*scale);
			newT = CalTime(newS);
			diffT = newT - gBestT;
			% If new route is better, accept it
			if diffT < 0
				gBestS = newS;
				gBestT = newT;
			% If new route is worse, accept it with probability
			elseif exp(-k*diffT/curTemp) > rand()
				bestRoute = newS;
				gBestT = newT;
			end
			% Calculate optimization data
			tAgentEnd = cputime;
			agentTime = tAgentEnd-tAgentStart;
			totalTime = tAgentEnd-tStart;
			timeCost(i, j) = agentTime;
			disp(['Tempature: ', num2str(curTemp), '  ', ...
				'Iteration: ', num2str(i), '  ', ...
				'Cross Time: ', num2str(newT), '  ', ...
				'Optimal Cross Time: ', num2str(gBestT), '  ', ...
				'Agent Time: ', num2str(agentTime), 's  ', ...
				'Total Time: ', num2str(totalTime), 's']);
		end
		traceS(i+1,  : ) = gBestS;
		traceT(i+1,  : ) = gBestT;
		% Cool down
		curTemp = r*curTemp;
		% Save data
		if mod(i, 5) == 0 || i == iterationNum
			cd('MatFile');
			save('SA_Parameter.mat', 'traceS', 'traceT', 'timeCost');
			cd('..');
			disp(['Save SA parameters in iteration ', num2str(i)]);
		end
	end
	% Recover Crossroad signal
	Crossroad.signal = iniSignal;
end

%--- Optimize traffic signal with GA ---
function [gBestS, traceT, timeCost] = GA()
	% Set global variable(s) 
	global Crossroad;
	iniSignal = Crossroad.signal;
	% Set parameters
	iterationNum = 100;
	agentNum = 20;
	PCross = 0.3;
	PVari = 0.5;
	scale = [5, 0.1, 0.1, 0.1, 0.1];
	% Initialize optimization variables
	for i = 1:1:agentNum
		iniS = ExamineSignal([20*rand, rand, rand, rand, rand]);
		iniT = CalTime(iniS);
		iniF = CalFitness(iniT);
		Agent(i) = struct('S', iniS, ...
						'T', iniT, ...
						'F', iniF);
	end
	[gBestT, optIndex] = min([Agent.T]);
	gBestS = Agent(optIndex).S;
	% Initialize optimization record variables
	tStart = cputime;
	traceS = zeros(iterationNum+1, length(gBestS));
	traceS(1,  : ) = gBestS;
	traceT = zeros(iterationNum+1, 1);
	traceT(1) = gBestT;
	timeCost = zeros(iterationNum, 1);
	% Do GA
	for i = 1:1:iterationNum
		% Begin timing of the agent
		tIterStart = cputime;		
		% Update agents within loops
		oddAgent = [];
		for j = 1:1:agentNum
			% Cross & Variance
			if mod(j, 2) == 1
				oddAgent = Agent(RWSelection());
			else 
				evenAgent = Agent(RWSelection());
				% Cross
				Cross();
				% Variation
				Variation();
				% Update time cost and f value
				oddAgent.T = CalTime(oddAgent.S);
				oddAgent.F = CalFitness(oddAgent.T);
				evenAgent.T = CalTime(evenAgent.S);
				evenAgent.F = CalFitness(evenAgent.T);
				% Add processed agents into new agent list
				NewAgent(j-1) = oddAgent;
				NewAgent(j) = evenAgent;
			end
		end
		% Elitism (replace the worst agent in NewAgent with the optimal agent in Agent)
		[~, optIndex] = min([Agent.T]);
		[~, worstIndex] = max([NewAgent.T]);
		NewAgent(worstIndex) = Agent(optIndex);
		% Update agent of the generation
		Agent = NewAgent;
		% Mark current gBestS and gBestT
		[gBestT, optIndex] = min([Agent.T]);
		gBestS = Agent(optIndex).S;
		traceT(i+1,  : ) = gBestT;
		traceS(i+1,  : ) = gBestS;
		% Calculate optimization data
		tIterEnd = cputime;
		iterTime = tIterEnd-tIterStart;
		totalTime = tIterEnd-tStart;
		timeCost(i) = iterTime;
		disp(['Iteration: ', num2str(i), '  ', ...
			'Optimal Cross Time: ', num2str(gBestT), '  ', ...
			'Iteration Time: ', num2str(iterTime), 's  ', ...
			'Total Time: ', num2str(totalTime), 's']);
		% Save data
		if mod(i, 5) == 0 || i == iterationNum
			cd('MatFile');
			save('GA_Parameter.mat', 'traceS', 'traceT', 'timeCost');
			cd('..');
			disp(['Save GA parameters in iteration ', num2str(i)]);
		end
	end
	% Recover Crossroad signal
	Crossroad.signal = iniSignal;

	% Roulette Wheel Selection
	function index = RWSelection()
		% Initialize variable(s)
		agentNum = size(Agent, 2);
		rNum = rand;
		fTable = [Agent.F];
		fSum = sum(fTable);
		% Calculate index
		for k = 1:1:agentNum
			if rNum > sum(fTable(1:k-1))/fSum && rNum <= sum(fTable(1:k))/fSum
				index = k;
			end
		end
	end

	% Calculate fitness value
	function F = CalFitness(T)
		F = exp(32-T);
	end

	% Cross
	function Cross()
		% Backup
		tempAgent = oddAgent;
		% Cross for oddAgent
		oddAgent.S = ExamineSignal((1-PCross)*oddAgent.S + PCross*evenAgent.S);
		% Cross for evenAgent
		evenAgent.S = ExamineSignal((1-PCross)*evenAgent.S + PCross*tempAgent.S);
	end
	
	% Variation
	function Variation()
		% Cross for oddAgent
		oddAgent.S = ExamineSignal(oddAgent.S+PVari*(0.5-rand(1, 5)).*scale);
		% Cross for evenAgent
		evenAgent.S = ExamineSignal(evenAgent.S+PVari*(0.5-rand(1, 5)).*scale);
	end
end

%--- Optimize traffic signal with PSO ---
function [gBestS, traceT, timeCost] = PSO()
	% Set global variable(s) 
	global Crossroad;
	iniSignal = Crossroad.signal;
	% Set parameters
	iterationNum = 100;
	agentNum = 20;
	w = 0.8;
	c1 = 1;
	c2 = 1;
	% Initialize optimization variables
	iniS = [10, 0.25, 0.25, 0.25, 0.25];
	iniT = CalTime(iniS);
	gBestS = iniS;
	gBestT = iniT;	
	% Initialize optimization record variables
	tStart = cputime;
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
	% Do PSO
	for i = 1:1:iterationNum
		disp(['--- Iteration: ', num2str(i), ' ---']);
		% Update agents within loops
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
			% Calculate optimization data
			tAgentEnd = cputime;
			agentTime = tAgentEnd-tAgentStart;
			totalTime = tAgentEnd-tStart;
			timeCost(i, j) = agentTime;
			disp(['Iteration: ', num2str(i), '  ', ...
				'Agent: ', num2str(i), '  ', ...
				'Cross Time: ', num2str(Agent(j).curT), '  ', ...
				'Optimal Cross Time: ', num2str(gBestT), '  ', ...
				'Agent Time: ', num2str(agentTime), 's  ', ...
				'Total Time: ', num2str(totalTime), 's']);
		end
		% Mark current gBestS and gBestT
		traceS(i+1,  : ) = gBestS;
		traceT(i+1,  : ) = gBestT;
		% Save data
		if mod(i, 5) == 0 || i == iterationNum
			cd('MatFile');
			save('PSO_Parameter.mat', 'traceS', 'traceT', 'timeCost');
			cd('..');
			disp(['Save PSO parameters in iteration ', num2str(i)]);
		end
	end
	% Recover Crossroad signal
	Crossroad.signal = iniSignal;
end

%--- Do simulation and calculate the average traveling time ---
function aveTime = CalTime(signal)
	% Set global variable(s) 
	global Crossroad;
	global VehicleList;
	global timeStep;
	% Do the simulation
	Crossroad.signal(1) = signal(1);
	Crossroad.signal(3:6) = signal(2:5);
	SimuXRoad();
	% Initialize variable(s)
	timeList = zeros(0, 1);
	for i = 1:1:size(VehicleList, 2)
		timeList = [timeList; size(VehicleList(i).trace, 1)*timeStep];
	end
	% Calculate the time
	aveTime = mean(timeList);
end

%--- Examine the signal to ensure its validity ---
function validSignal = ExamineSignal(signal)
	% Initialize variable(s)
	validSignal = signal;
	proportion = signal(2:5);
	lowBound = 0.1;
	upBound = 0.5;
	% Do the correction
	for i = 1:1:length(proportion)
		if proportion(i) < lowBound
			proportion(i) = lowBound;
		elseif proportion(i) > upBound
			proportion(i) = upBound;
		end
	end
	% Do nomalization
	proportion = proportion/sum(proportion);
	validSignal(2:5) = proportion;
end

%------------- END OF SUBFUNCTION(S) --------------