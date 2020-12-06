function mpc = test_system_50gen
%TEST_SYSTEM_50GEN   50-generator test system.
%	mpc = TEST_SYSTEM_50GEN generates data for the 50-generator, 145-bus
%   test case from to which dynamic parameters taken from
%
%       V.Vittal. Transient stability test systems for direct stability
%       methods. Power Systems, IEEE Transactions on, 7(1):37-43, feb 1992.
%
%   are added manually by T. Nishikawa. The test case data was converted
%   from the IEEE Common Data Format (dd50cdf.txt), which was downloaded
%   from
%
%       http://www.ee.washington.edu/research/pstca/dyn50/pg_tcadd50.htm
%
%   using cdf2matp, rev. 2327 on 8/2/2014. 

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

mpc = loadcase('dd50cdf.m');
mpc.ref_freq = 60;
s = load('test_system_50gen_dyn_data.mat', 'data');
data = sortrows(s.data,1);
N = size(data,1);
if any(mpc.gen(:,1) ~= data(:,1))
    error('Generator bus numbers do not match up.')
end
mpc.gen_dyn = zeros(N,3);
mpc.gen_dyn(:,1) = data(:,3); % x'_d in p.u. on 100 MVA base
mpc.gen_dyn(:,2) = data(:,2); % H in sec
mpc.gen_dyn(:,3) = 50; % D in p.u.
