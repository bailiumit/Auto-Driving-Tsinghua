function UpdateSpeed(insideList)
%UpdateSpeed - Simulate the whole crossroad
%
% Syntax:  [~] = SimuXRoad()
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
% Subfunctions: GenRandState, FindMaxState, GetQValue, Trim
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Department of Automation, Tsinghua University 
% email: liubaichn@126.com
% 2017.05; Last revision: 2017.05.23

%------------- BEGIN MAIN FUNCTION --------------

%--- Set global variable(s) ---
global VehicleList;
global ClassifiedList;
global intScale;

%--- Initialize variable(s) ---
bestSpeed = 5;

%--- Update vehicle speed ---
for i = 1:1:4
	for j = 1:1:4
		k = 1;
		while k <= size(ClassifiedList{i, j}, 1)-1
			% Locate current vehicle
			curID = ClassifiedList{i, j}(k);
			curVehicle = VehicleList(curID);
			if curVehicle.type == 1
				% Locate the vehicle behind
				nextID = ClassifiedList{i, j}(k+1);
				nextVehicle = VehicleList(nextID);
				% Get dynamic properties
				v1 = curVehicle.dynamic(1);
				x1 = curVehicle.position(1);
				y1 = curVehicle.position(2);
				v2 = nextVehicle.dynamic(1);
				x2 = nextVehicle.position(1);
				y2 = nextVehicle.position(2);
				% Initialize variables required to calculate new speed
				interval = Trim(sqrt((x1-x2)^2+(y1-y2)^2)-(curVehicle.size(1)/2+nextVehicle.size(1)/2), intScale);
				curState = [interval, v1, v2];
				if curVehicle.type == 1
					optType = 0;
				else
					optType = 1;
				end
				% Update speed
				nextState = GetNextState(curState, optType);
				VehicleList(curID).dynamic(1) = max(nextState(2), 3);
				VehicleList(nextID).dynamic(1) = max(nextState(3), 3);
				% Set index
				k = k+2;
			else
				if k == 1
					VehicleList(curID).dynamic(1) = bestSpeed;
				else
					prevID = ClassifiedList{i, j}(k-1);
					VehicleList(curID).dynamic(1) = VehicleList(prevID).dynamic(1);
				end
				% Set index
				k = k+1;
			end
		end
	end
end


%------------- END OF MAIN FUNCTION --------------
end



%------------- BEGIN SUBFUNCTION(S) --------------

%--- Get the optimized speed of the next time slot ---
function nextState = GetNextState(curState, optType)

	nextStateList = CalLineAction(curState, optType);
	if ~isempty(nextStateList)
		[nextState, ~] = FindMaxState(nextStateList);
	else
		nextState = [curState(1), 5, 5];
	end

end

%--- Generate random state ---
function [preState, curState, curQ] = GenRandState()
	% Set global variable(s)	
	global intScale;
	global intRange;
	global vScale;
	global vRange;
	global optType;
	% Initialize variable(s)
	preState = zeros(1, 3);
	curState = zeros(1, 3);
	curStateList = zeros(0, 3);
	randVMin = 2;
	randVMax = 6;
	randIntMin = 3;
	randIntMax = 7;
	% Initialize preState
	while isempty(curStateList)
		preState(1) = Trim(randIntMin+(randIntMax-randIntMin)*rand, intScale);
		preState(2) = Trim(randVMin+(randVMax-randVMin)*rand, vScale);
		preState(3) = Trim(randVMin+(randVMax-randVMin)*rand, vScale);
		curStateList = CalLineAction(preState, optType);
	end
	% Initialize curState
	[curState, curQ] = FindMaxState(curStateList);
end

%--- Search for the state with maximum reward ---
function [maxState, maxQ] = FindMaxState(stateList)
	% Initialize variable(s)
	maxState = stateList(1, : );
	maxQ = GetQValue(maxState);
	% Selection sorts
	for i = 2:1:size(stateList, 1)			
		curQ = GetQValue(stateList(i, : ));
		if curQ > maxQ
			maxState = stateList(i, : );
			maxQ = curQ;
		end
	end
end

%--- Map value to index ---
function QValue = GetQValue(state)
	% Set global variable(s)	
	global QMatrixLine;
	global intScale;
	global vScale;
	global optType;
	% Calculate index of optimization type
	typeIndex = optType+1;
	% Calculate index of interval
	intIndex = floor(state(1)/intScale)+1;
	% Calculate index of speed
	vIndex1 = floor(state(2)/vScale)+1;
	vIndex2 = floor(state(3)/vScale)+1;
	% Calculate the value in Q matrix
	QValue = QMatrixLine(typeIndex, intIndex, vIndex1, vIndex2);
end

%--- Trim number to corresponding scale ---
function trimNumber = Trim(originNumber, scale)
	% Calculate the trimmed value
	trimNumber = round(originNumber/scale)*scale;
end

%------------- END OF SUBFUNCTION(S) --------------