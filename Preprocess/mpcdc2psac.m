function ps = mpcdc2psac( mpc, busdata )
% converts a DC powerflow state given as mpc to an AC powerflow in ps form

%% find a DC powerflow solution
mopt = mpoption( ...
    'OUT_ALL', 0, ...
    'VERBOSE', 0, ...
    'PF_DC', 1, ...
    'OUT_SYS_SUM', 0, ...
    'OUT_BUS', 0, 'OUT_BRANCH', 0);

mopt.pf.enforce_q_lims = 0;

bustypes = mpc.bus(:,2); %record the original bus types (may change because q limit forcing)

mpc = runpf(mpc, mopt);
if ~mpc.success
    error('Powerflow failed on initial network\n');    
end

mpc.bus(:,2) = bustypes; % restore bus types! keep it consistent with the original.

%% make sure we have mpc_dyn and bus_dyn. If not, fill in with defaults
mpc = ensure_mpc_dyn(mpc);

% save the original DC Pg values
P = abs(mpc.gen(:,2));
mpc.gen_dyn = [mpc.gen_dyn, P];

% override transient reactances
mpc.gen_dyn(:,1) = min([200 * P .^(-1.3), 1e-0 * ones(size(P))], [], 2);
mpc.gen_dyn(:,1) = max([mpc.gen_dyn(:,1), 1e-4*ones(size(P))], [], 2);
%x_d = min([102.30253 * P.^(-1.35742), x_d_max*ones(size(P))], [], 2);

%% make branch R=0
mpc.branch(:,3) = 0;

%% convert to internal indexing
mpc = ext2int(mpc);
mpc = e2i_field(mpc, 'gen_dyn', 'gen');
mpc = e2i_field(mpc, 'bus_dyn', 'bus');

if isfield(mpc, 'busExtra')
    mpc = e2i_field(mpc, {'busExtra', 'Latitude'}, 'bus');
    mpc = e2i_field(mpc, {'busExtra', 'Longitude'}, 'bus');
    mpc = e2i_field(mpc, {'busExtra', 'AreaName'}, 'bus');
    mpc = e2i_field(mpc, {'busExtra', 'AreaNum'}, 'bus');
end

if (nargin > 1)
    busdata = e2i_data(mpc, busdata, 'bus');
end

%% remove offline generators
on = mpc.gen(:,8) == 1;
mpc.gen = mpc.gen(on,:);
mpc.gen_dyn = mpc.gen_dyn(on,:);

%% build ps.gen and ps.dyn: keep original machine data!
ps.gen = mpc.gen;
ps.gen_dyn = mpc.gen_dyn;
%ps.bus_dyn = mpc.bus_dyn;

%% merge multiple generators on the same bus
% do this for original germany, not for germany2 or germany3
genbus = unique(ps.gen(:,1));

for i = 1 : length(genbus)
    bus = genbus(i);
    gens = ps.gen(:,1) == bus;  %generators on this given bus
    if sum(gens) > 1

        %find row indices of the generators
        nz = find(gens);
        nz1 = nz(1);        
        
        %new dynamical parameters
        Xd = imag(1 / sum(1 / (1j * ps.gen_dyn(gens, 1)))); %parallel connection
        H = sum(ps.gen_dyn(gens, 2));
        D = sum(ps.gen_dyn(gens, 3));
        other = sum(ps.gen_dyn(gens, 4:end));
        newdyn = [Xd H D other];
    
        
        %new generator parameters
        Pg = sum(ps.gen(gens, 2));
        Qg = sum(ps.gen(gens, 3));
        newgen = [ bus, Pg, Qg, sum(ps.gen(gens, 4)), sum(ps.gen(gens, 5)), ps.gen(nz1,6), ...
            100, 1, sum(ps.gen(gens, 9)), sum(ps.gen(gens, 10)), zeros(1, size(ps.gen, 2)-10)];        

        %override the first one with the merged one
        ps.gen_dyn(nz1,:) = newdyn;
        ps.gen(nz1,:) = newgen;
        
        %remove others
        gens(nz1) = false; %mark first one to keep
        keep = ~gens;
        ps.gen_dyn = ps.gen_dyn(keep,:);
        ps.gen = ps.gen(keep,:);
    end
end

%% compose the rest of ps data
ps.bus = mpc.bus;
ps.baseMVA = mpc.baseMVA;
ps.Y = makeYbus(mpc);

%% DC to AC conversion


Vmag = ps.bus(:,8);
Vang = ps.bus(:,9)/180.0*pi;
V = Vmag .* exp(1j * Vang); 
I = ps.Y * V;
S = V .* conj(I); %net power injection at a node

a = 0.95; % power factor assumption
aa = sqrt(1-a^2)/a;
P = real(S); % net active power injection at the nodes
Q = imag(S); % net reactive power injection at the nodes

nongenbus = true(size(ps.bus, 1), 1);
nongenbus(ps.gen(:,1)) = false;

%loads: all Q injection comes from Qd
ps.bus(nongenbus,3) = -P(nongenbus) * ps.baseMVA; % Pd
ps.bus(nongenbus,4) = -Q(nongenbus) * ps.baseMVA; % Qd


%generator hosting buses
genbus = ~nongenbus;

Pd = ps.bus(genbus, 3); %demand on generator bus
Qd = Pd * aa; % add reactive power demand with fixed power factor
ps.bus(genbus, 4) = Qd;

%log
temp = sum(Qd > 0);
fprintf('Number of genbuses where nonzero Qd was added: %d\n', temp);

% for each gen hosting bus, distribute the total Qg weighted by Pg
genbuslist = find(genbus);
for i = 1 : length(genbuslist)
    bus = genbuslist(i);    % select the bus
    gens = ps.gen(:,1) == bus;
    
    ngen = sum(gens);
    if (ngen==0); error('weer'); end
    
    Pgs = abs(ps.gen(gens, 2));  %Pg on those generators (before redistrib)
    totalPg = sum(abs(Pgs));     %total Pg on the generators (before redistrib)
    
    if (totalPg == 0)
        portions = ones(ngen, 1) ./ ngen;
    else
        portions = Pgs ./ totalPg;
    end
    
    % amount of Pg and Qg to distribute
    totalPg = P(bus) * ps.baseMVA + ps.bus(bus, 3);
    totalQg = Q(bus) * ps.baseMVA + ps.bus(bus, 4);          
    
    % distribute
    Pg = totalPg .* portions;
    Qg = totalQg .* portions;
    
    ps.gen(gens, 2) = Pg;
    ps.gen(gens, 3) = Qg;
end

% Pg = P(genbus) + Pd;
% Qg = Q(genbus) + Qd;
% 
% ps.gen(:,2) = Pg * ps.baseMVA;
% ps.gen(:,3) = Qg * ps.baseMVA;



%Pd = ps.gen(:,2) - P(genbus) * ps.baseMVA;  % keep the real gen as is, remainder is demand
%ps.bus(genbus, 3) = Pd;
%ps.gen(:,3) = Q(genbus) * ps.baseMVA; % generator takes all of reactive power as generation

% given or default reference frequency
if isfield(mpc, 'ref_freq')
    ps.ref_freq = mpc.ref_freq;
else
    ps.ref_freq = 60;
end

% for US/PowerWorld converted datasets: write better area number from extra bus data
if isfield(mpc, 'busExtra')
    areas = unique(mpc.busExtra.AreaNum);
    for i=1:length(areas)
        areaSelect = mpc.busExtra.AreaNum == areas(i);
        ps.bus(areaSelect, 7) = i;
    end
    
    ps.busExtra = mpc.busExtra;
end


% final check: ps powerflow must work too
[~,success] = runpf_ps(ps);
if ~success
    error('Powerflow failed on final network');
end


end

