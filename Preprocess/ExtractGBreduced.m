% creates the GBreduced2 sample, where the 
% dynamical parameters are estimated by Chao's suggestions

mpc = load_system('GBreduced', 0);
ps = mpc2ps_nomerge(mpc);

ps2 = MakeDynamicsChao(ps);

% override transient reactances - same as the "working" version of Germany
% P = abs(ps2.gen(:,2));
% ps2.gen_dyn(:,1) = min([300 * P.^(-1.4), 1e-0 * ones(size(P))], [], 2);
% ps2.gen_dyn(:,1) = max([ps2.gen_dyn(:,1), 1e-4 * ones(size(P))], [], 2);

% set up cutoffs on system base
% gives -5.9 to -6.2, 5.5% improv
% n = size(ps2.gen_dyn, 1);
% ps2.gen_dyn(:,1) = min([ps2.gen_dyn(:,1), 1e-0 * ones(n,1)], [], 2);
% ps2.gen_dyn(:,1) = max([ps2.gen_dyn(:,1), 1e-4 * ones(n,1)], [], 2);

% save it | uncomment to overwrite existing sampel
% save('GBreduced6','ps2');

%% load existing
load('GBreduced6'); % makes ps2

% plot lmax vs stress level
stress = [0.0 : 0.1 : 1.0];
plot_stressed_stability_ps(ps2,stress);

% create P matrices for each stress level
make_stressed_systems_ps('GBreduced6',stress,'stress');

%% map drawing data 
Pd = abs(ps2.bus(:,3));
dlmwrite('GBreduced6_Pd.txt',Pd);

Pg = abs(ps2.gen(:,2));
dlmwrite('GBreduced6_Pg.txt',Pg);
