function [ ps, busdata ] = mpc2ps_nomerge( mpc )
% convert mpc to ps, do not merge generators on the same bus

%% find a powerflow solution
mopt = mpoption( ...
    'OUT_ALL', 0, ...
    'VERBOSE', 0, ...
    'PF_DC', 0, ...
    'OUT_SYS_SUM', 0, ...
    'OUT_BUS', 0, 'OUT_BRANCH', 0);

mopt.pf.enforce_q_lims = 0;

bustypes = mpc.bus(:,2); %record the original bus types (may change because q limit forcing)

mpc = runpf(mpc, mopt);
if ~mpc.success
    error('Powerflow failed on initial network\n');    
end

% expand Q limits if needed
mpc.gen(:,4) = max([mpc.gen(:,3), mpc.gen(:,4)-1, mpc.gen(:,4)+1],[],2);
mpc.gen(:,5) = min([mpc.gen(:,3), mpc.gen(:,5)-1, mpc.gen(:,5)+1],[],2);

%% make sure we have mpc_dyn and bus_dyn. If not, fill in with defaults
mpc = ensure_mpc_dyn(mpc);

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


%% compose the rest of ps data
ps.bus = mpc.bus;
ps.baseMVA = mpc.baseMVA;
ps.Y = makeYbus(mpc);

% given or default reference frequency
if isfield(mpc, 'ref_freq')
    ps.ref_freq = mpc.ref_freq;
else
    ps.ref_freq = 60;
end

% final check: ps powerflow must work too
[~,success] = runpf_ps(ps);
if ~success
    error('Powerflow failed on final network\n');
end

end

