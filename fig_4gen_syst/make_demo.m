function [P, ps] = make_demo()
% Create a 4-node demo for Cluster-CSB 
% must have: symmetric cluster 2x2

% system reference frequency (Hz)
mpc.ref_freq = 60;

% generator dynamic parameters
%  x_d  H     D
mpc.gen_dyn = [
   0.3  10.0   50;
   0.3  10.0   50;
   0.3  10.0   50;
   0.3  10.0   50;
];

% MATPOWER Case Format : Version 2
mpc.version = '2';

% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	0	0	0	0	1	1   0   100     1	1.1	0.9;
	2	2	0	0	0	0	1	1   0   100     1	1.1	0.9;
	3	2	0	0	0	0	1	1   0   100     1	1.1	0.9;
    4	2	0	0	0	0	1	1   0   100     1	1.1	0.9;	
	5	1	200	100	0	0	1	1   0   100     1	1.1	0.9;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	0	0	3000	-3000	1.0	100	1	300	10	0	0	0	0	0	0	0	0	0	0	0;
	2	100	0	3000	-3000	1.0	100	1	300	10	0	0	0	0	0	0	0	0	0	0	0;
	3	100	0	3000	-3000	1.0	100	1	300	10	0	0	0	0	0	0	0	0	0	0	0;
	4	10	0	3000	-3000	1.0	100	1	300	10	0	0	0	0	0	0	0	0	0	0	0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax

% symmetric branch data: source node is arbitrary (0)
branch = [
    % node A to center | must be the same as below
    0	1	0.05	1.2     1.9     250	250	250	0   0	1	-360	360;
	0	4	0.05	1.2     1.9     250	250	250	0   0	1	-360	360;
	0	5	0.05    1.2     1.9     250	250	250	0   0	1	-360	360;
];

br1 = branch;
br1(:,1) = 2; % source node

br2 = branch;
br2(:,1) = 3; % source node

% put it together
mpc.branch = [br1; br2]; 

%% convert to PS

ps = mpc2ps_nomerge(mpc);

P = MakeP(ps, 1);

end

