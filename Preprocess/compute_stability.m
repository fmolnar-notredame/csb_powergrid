function [success, is_stable, results] = compute_stability(mpc, c, xd_max)

% disable singular warning: powflow will fail anyway if so
%warnStruct = warning('off', 'MATLAB:singularMatrix');
%warning(warnStruct);

% Scale each load and generator by c.
mpc.bus(:,3) = c * mpc.bus(:,3); %scale up active power load
mpc.bus(:,4) = c * mpc.bus(:,4); %scale up reactive power load
mpc.gen(:,2) = c * mpc.gen(:,2); %scale up active power generated
% note, some will be overwritten by powerflow

[~, success] = runpf(mpc, mpoption('verbose', 0, 'out.all',0));

results = nan;
is_stable = false;
if success
    if (nargin > 2)
        est_dyn.max_xd = xd_max;
        model = pg_eff_net(mpc, est_dyn);
    else
        model = pg_eff_net(mpc);
    end
    results = pg_eff_net_lin_stability(model);  
    is_stable = results.max_lyap < 0;
        
end

end
