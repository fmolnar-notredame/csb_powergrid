function mpc = test_system_3gen
%TEST_SYSTEM_3GEN   3-generator test system.
%   mpc = TEST_SYSTEM_3GEN generates struct mpc containing the power flow
%   data for a 9-bus, 3-generator system. This is the 9-bus system in
%   Example 2.6 of Ref. [1]. Adapted from case9.m, which is distributed
%   with the MATPOWER package, by adding dynamic parameters.
%
%   Reference: [1] P.M. Anderson and A.A. Fouad, Power system control and
%   stability (IEEE Press, 2nd edition, 2003).

%
% Copyright (C) 2015  Takashi Nishikawa
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or (at
% your option) any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
% USA.

%   Last modified by Takashi Nishikawa on 1/22/2015

%% system reference frequency (Hz)
mpc.ref_freq = 60;

%% generator dynamic parameters
%  x_d      H      R    D
mpc.gen_dyn = [
   0.0608  23.64   50;
   0.1198  6.40    50;
   0.1813  3.01    50;
];

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	0	0	0	0	1	1   0   16.5	1	1.1	0.9;
	2	2	0	0	0	0	1	1   0   18      1	1.1	0.9;
	3	2	0	0	0	0	1	1   0   13.8	1	1.1	0.9;
	4	1	0	0	0	0	1	1   0   230     1	1.1	0.9;
	5	1	125	50	0	0	1	1   0   230     1	1.1	0.9;
	6	1	90	30	0	0	1	1   0   230     1	1.1	0.9;
	7	1	0	0	0	0	1	1   0   230     1	1.1	0.9;
	8	1	100	35	0	0	1	1   0   230     1	1.1	0.9;
	9	1	0	0	0	0	1	1   0   230     1	1.1	0.9;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	0	0	300	-300	1.04	100	1	250	10	0	0	0	0	0	0	0	0	0	0	0;
	2	163	0	300	-300	1.025	100	1	300	10	0	0	0	0	0	0	0	0	0	0	0;
	3	85	0	300	-300	1.025	100	1	270	10	0	0	0	0	0	0	0	0	0	0	0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	4	0       0.0576	0           250	250	250	1	0	1	-360	360;
	4	5	0.01	0.085	0.088*2     250	250	250	0   0	1	-360	360;
    4	6	0.017	0.092	0.079*2     250	250	250	0   0	1	-360	360;
	6	9	0.039	0.17	0.179*2     150	150	150	0   0	1	-360	360;
	3	9	0       0.0586	0           300	300	300	1   0	1	-360	360;
	8	9	0.0119	0.1008	0.1045*2	150	150	150	0   0	1	-360	360;
	7	8	0.0085	0.072	0.0745*2    250	250	250	0   0	1	-360	360;
	2	7	0       0.0625	0           250	250	250	1   0	1	-360	360;
	5	7	0.032	0.161	0.153*2     250	250	250	0   0	1	-360	360;
];
