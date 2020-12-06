
mpc = load_system('data48em', 2);
ps2 = mpc2ps_nomerge(mpc);

dyn = ps2.gen_dyn;
n = size(dyn, 1);
D = rand(n, 1) * 2 + 1; %make random
% note, 48-gen system is already on system base

%put back xd and H, those are fine
ps2.gen_dyn = [dyn(:,[1,2]), D];

stress = 0.1 : 0.1 : 1.4;
plot_stressed_stability_ps(ps2,stress);

%user stop: do you like? if so, continue to save

% save it | uncomment to overwrite existing sample
% save('data48em2','ps2');

% create system | folder created, P matrices for each stress level are made
% stress=1  is the original system, find it by the stress level from the
% "stress" vector above
make_stressed_systems_ps('data48em2',stress,'stress');

%% load and export data for drawing the map
load('data48em2');

gens = ps2.gen(:,1);
dlmwrite('npcc_generators.txt',gens);

[rows,cols,~] = find(ps2.Y);
dlmwrite('npcc_adjacency.txt',[rows,cols]);

Pd = abs(ps2.bus(:,3));
dlmwrite('npcc_Pd.txt',Pd);

Pg = abs(ps2.gen(:,2));
dlmwrite('npcc_Pg.txt',Pg);

