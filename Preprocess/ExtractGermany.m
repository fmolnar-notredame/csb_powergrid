% load mpc
load('ENTSO_E_2009_WINTER.mat');

% convert from DC to AC, and into ps format
ps = mpcdc2psac(mpc); % see transient reactance config inside

% select Germany
aggr = strcmp(ps.busExtra.AreaName,'D')==0;

% elimination
ps2 = Eliminate(ps, aggr);

% dynamics override
ps2 = MakeDynamicsChao(ps2);

% override transient reactances - same as the "working" version of Germany
% P = abs(ps2.gen(:,2));
% ps2.gen_dyn(:,1) = min([200 * P.^(-1.3), 1e-0 * ones(size(P))], [], 2);
% ps2.gen_dyn(:,1) = max([ps2.gen_dyn(:,1), 1e-4 * ones(size(P))], [], 2);

% save | uncomment to overwrite existing sample
% save('germany8', ps2);

%% load existing
load('germany8'); % makes ps2

% plot
stress = [0 : 0.1 : 1.1];
plot_stressed_stability_ps(ps2,stress);

% make P matrices for each stress level
make_stressed_systems_ps('germany8',stress,'stress');

%%  export data for drawing the map

% save adjacency list
[rows,cols,~] = find(ps2.Y);
dlmwrite('germany8_adjacency.txt',[rows,cols]);

% save generator locations
dlmwrite('germany8_generators.txt',ps2.gen(:,1));

Pd = abs(ps2.bus(:,3));
dlmwrite('germany8_Pd.txt',Pd);

Pg = abs(ps2.gen(:,2));
dlmwrite('germany8_Pg.txt',Pg);
