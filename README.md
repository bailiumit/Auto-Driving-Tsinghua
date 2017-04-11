# Intersection Routing Strategy for Self-driving Vehicles

Welcome! This project is created by [Bai Liu](http://bailiu.me).

### How to manipulate?
1. Open MATLAB
2. Locate **"Current Folder**" of MATLAB to where the source codes are
3. Edit **"Main.m"** by adding or removing relevant comments
4. Run **"Main.m"**

### Structure of the system
The project has three optimization parts: left-turning strategy, traffic signal display strategy and intersection structure. Besides, several files serve as supporting tools.

1. **Optimization on left-turning strategy**

	We adopt Q-Learning method here.

	**"OptTurning.m"**: algorithmic implementation of Q-learning

	**"CalAction.m"**: calculates possible future states for a given state in Q-learning, which provides supporting functions for **"OptTurning.m"**

	**"TestTurning.m"**: helps to illustrate the training result

2. **Optimization on traffic signal display strategy**

	We adopt SA (simulated annealing), GA (genetic algorithm) and PSO (particle swarm optimization) here.

	**"OptSignal.m"**: algorithmic implementation of SA, GA and PSO

3. **Optimization on intersection structure**

	To be implemented.

4. **Supporting tools**

	**"Main.m"**: core console, the control center

	**"XroadSimulation.m"**: simulate the traffic conditions of the intersection for a given amount of time

	**"InitializeGlobal.m"**: define and initialize global variables, including parameters of vehicles, road structure and simulation method

	**"CalVehicleNum.m"**: calculate the number of vehicle(s) to be geneerated in a given amount of time
	
	**"GenerateVehicle.m"**: generate vehicle objects





