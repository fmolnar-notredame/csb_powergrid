function mpc = pst2matpower(bus, line, mac_con)
%PST2MATPOWER Converts power grid data from PST to MATPOWER format.

% Last modified by Ferenc Molnar
% Rewritten to support multiple generators on a single bus
% and introduce new category: fictitious generator
% Def: a PV bus that has no matching machine data
% It is treated as generator in powerflow (per PST manual)
% but it will be eliminated in the effective network (treated as load)

define_constants

% Using 100MVA system base (not provided in the PST data files).
mpc.baseMVA = 100;

% Set MATPOWER bus data.
% copy bus IDs
mpc.bus(:, BUS_I) = bus(:,1);  

% convert bus types (may change later)
for i = 1 : size(bus,1)
    switch bus(i,10)
        case 1 % swing bus
            mpc.bus(i,BUS_TYPE) = 3;
        case 2 % generator bus (PV bus)
            mpc.bus(i,BUS_TYPE) = 2;
        case 3 % load bus (PQ bus)
            mpc.bus(i,BUS_TYPE) = 1;
    end
end

% copy relevant columns
mpc.bus(:,PD) = bus(:,6) * mpc.baseMVA;
mpc.bus(:,QD) = bus(:,7) * mpc.baseMVA;
mpc.bus(:,GS) = bus(:,8) * mpc.baseMVA;
mpc.bus(:,BS) = bus(:,9) * mpc.baseMVA;
mpc.bus(:,BUS_AREA) = 1; % not provided in PST data, make all area = 1
mpc.bus(:,VM) = bus(:,2);
mpc.bus(:,VA) = bus(:,3);
mpc.bus(:,BASE_KV) = 1; % not provided in PST data
mpc.bus(:,ZONE) = 1;    % not provided in PST data
mpc.bus(:,VMAX) = 1.2;  % not provided in PST data
mpc.bus(:,VMIN) = 0.8;  % not provided in PST data

% Set MATPOWER branch data.
mpc.branch(:,F_BUS) = line(:,1);
mpc.branch(:,T_BUS) = line(:,2);
mpc.branch(:,BR_R) = line(:,3);
mpc.branch(:,BR_X) = line(:,4);
mpc.branch(:,BR_B) = line(:,5);
mpc.branch(:,RATE_A) = 0; % not provided in PST data
mpc.branch(:,RATE_B) = 0; % not provided in PST data
mpc.branch(:,RATE_C) = 0; % not provided in PST data
mpc.branch(:,TAP) = line(:,6);
mpc.branch(:,SHIFT) = line(:,7);
mpc.branch(:,BR_STATUS) = 1; % not provided in PST data
mpc.branch(:,ANGMIN) = -360; % not provided in PST data
mpc.branch(:,ANGMAX) = 360; % not provided in PST data

% Set MATPOWER generator data.
mpc.gen(:,GEN_BUS) = mac_con(:,2); % copy bus IDs
for i = 1 : size(mac_con,1)
    
    bus_id = mac_con(i,2);
    i_bus = (bus(:,1) == bus_id); % indices of buses that match (only one should)
    if (sum(i_bus) > 1)
        error('Error: multiple buses with the same ID = %d', bus_id);
    elseif (sum(i_bus) < 1)
        error('Error: bus %d not found for generator %d', bus_id, i);
    end
    
    % row indices of all generators connected to the same bus (can be multiple)
    i_gen = (mac_con(:,2) == bus_id); 
    n = sum(i_gen); 
    
    % check: if we have multiple generators, there must be more data
    if (n > 1 && size(mac_con,2) < 23)
        error('Error: multiple generators on the same bus, yet no power fraction data was provided.');
    end

    % single or multiple generators: these are the same for all
    mpc.gen(i_gen,QMAX) = bus(i_bus,11) * mpc.baseMVA;
    mpc.gen(i_gen,QMIN) = bus(i_bus,12) * mpc.baseMVA;
    mpc.gen(i_gen,VG) = bus(i_bus,2);
    
    mpc.gen(i_gen,PG) = bus(i_bus,4) * mpc.baseMVA;
    mpc.gen(i_gen,QG) = bus(i_bus,5) * mpc.baseMVA; 

    % multiple generators on bus? then set fractional generation
    if (n > 1)
        mpc.gen(i,PG) = mpc.gen(i,PG) * mac_con(i, 22);
        mpc.gen(i,QG) = mpc.gen(i,QG) * mac_con(i, 23);
    end
end

mpc.gen(:,MBASE) = mac_con(:,3);
mpc.gen(:,GEN_STATUS) = 1; % not provided in PST data
mpc.gen(:,PMAX) = 1e6; % not provided in PST data
mpc.gen(:,PMIN) = 0; % not provided in PST data
% Note: Not setting mpc.gen(:,11:25)

% Deal with those buses with P and Q generation but no generator exists by
% adding a fixtitious generator.
ix = [];
mpc.fic = [];
for i = 1 : size(bus, 1)
    
    %process PQ buses (loads): subtract Pg ang Qg, if any
    if (bus(i,10) == 3)
        mpc.bus(i, PD) = mpc.bus(i, PD) - bus(i, 4) * mpc.baseMVA;
        mpc.bus(i, QD) = mpc.bus(i, QD) - bus(i, 5) * mpc.baseMVA;
        continue
    end
    
    bus_id = bus(i, 1);
    
    % look up generators with matching ID (note: i_gen here indexes mpc.gen)
    i_gen = ( mpc.gen(:,GEN_BUS) == bus_id );
    
    if sum(i_gen) == 0  %no generator says connected to this bus
        fprintf('fictitious bus: %d, type: %d\n', bus_id, bus(i,10));

        %look up this bus in mpc.bus, and override type to 4=fictitious
        i_bus = (mpc.bus(:,BUS_I) == bus_id);
        mpc.bus(i_bus, BUS_TYPE) = 1;
        
%         mpc.bus(i_bus, PD) = mpc.bus(i_bus, PD) - bus(i, 4) * mpc.baseMVA;
%         mpc.bus(i_bus, QD) = mpc.bus(i_bus, QD) - bus(i, 5) * mpc.baseMVA;
        
        %generate fictitious generator mpc.gen entry
%         g = [ ...
%             bus_id, ... % GEN_BUS
%             bus(i,4) * mpc.baseMVA, ... % PG
%             bus(i,5) * mpc.baseMVA, ... % QG
%             1e6, ... % QMAX
%             -1e6, ... % QMIN
%             bus(i,2), ... % VG
%             mpc.baseMVA, ... % MBASE
%             1, ... % GEN_STATUS
%             1e6, ... % PMAX
%             0];     % PMIN
%         mpc.gen = [mpc.gen; g]; %mpc.fic
%         ix = [ix, size(mpc.gen,1)];
     end
end
fprintf('%d fictitious generators were added.\n', length(ix))

% Set generator dynamic parameters for pg_eff_net.m
mpc.gen_dyn(:,1) = mac_con(:,7) * mpc.baseMVA ./ mac_con(:, 3); % x'_{d,i}

%mpc.gen_dyn(:,2) = mac_con(:,16); % H_i THIS IS WRONG, 
%H = 0.5*J*w2 / Sbase,  so it converts like D

mpc.gen_dyn(:,2) = mac_con(:,16) .* mac_con(:, 3) / mpc.baseMVA; %H_i
fprintf('Using fixed conversion for H\n');

%mpc.gen_dyn(:,3) = mac_con(:,17) .* mac_con(:, 3) / mpc.baseMVA + 50; % D_i %
mpc.gen_dyn(:,3) = mac_con(:,17) .* mac_con(:, 3) / mpc.baseMVA; % D_i %
fprintf('Using NO regulation parameter\n');

%NOTE ABOVE
%D_i here only is the damping, not including R_i, which is otherwise 
%assumed to be 0.02  (see estimation:
%   D_m = 0 * P_R/omega_R
%   D_e = 0 * P_R/omega_R
%   R = 0.02 * omega_R/P_R
%
% in the notation of the New J Phys paper.
%D = 50*ones(size(P));

% Dynamic parameters for the fixtitious generators added above will be
% estimated by pg_eff_net.m.
% mpc.gen_dyn(ix,1) = nan; % x'_{d,i}
% mpc.gen_dyn(ix,2) = nan; % H_i
% mpc.gen_dyn(ix,3) = nan; % D_i