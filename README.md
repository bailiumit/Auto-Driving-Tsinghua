# Intersection Routing Strategy for Self-driving Vehicles

Welcome! This project is created by [Bai Liu](http://bailiu.me).

### How to manipulate?
1. Open MATLAB
2. Locate **"Current Folder**" of MATLAB to where the source codes are
3. Run aimed part(s) by editting **"Main.m"** (adding or removing relevant comments)
4. Adjust parameter(s) in **"InitializeGlobal.m"**
5. Run **"Main.m"**

### Structure of the system
The project has three optimization objects: left-turning strategy in single-agent case, left-turning strategy in multi-agent case, and traffic signal display strategy. Besides, several files serve as supporting tools.

1. **Console**

	**"Main.m"**: core console, the control center

	**"InitializeGlobal.m"**: define and initialize global variables, including parameters of vehicles, road structure and simulation method

2. **Optimization on left-turning strategy in single-agent case**

	We adopt Q-Learning method here.

	**"OptTurning.m"**: algorithmic implementation of Q-learning

	**"CalTurningAction.m"**: calculates possible future states for a given state in Q-learning, to assist **"OptTurning.m"**

	**"TestTurning.m"**: helps to illustrate the training result

3. **Optimization on left-turning strategy in multi-agent case**

	To be implemented.

4. **Optimization on traffic signal display strategy**

	We adopt SA (simulated annealing), GA (genetic algorithm) and PSO (particle swarm optimization) here.

	**"OptSignal.m"**: Implement SA, GA and PSO

5. **Investigation on how multiple factors impact the optimization effect**

	To be implemented.

6. **Miscellaneous**

	**"SimuXRoad.m"**: simulate the traffic conditions of the intersection for a given amount of time

	**"CalVehicleNum.m"**: calculate the number of vehicle(s) to be geneerated in a given amount of time
	
	**"GenerateVehicle.m"**: generate vehicle objects





