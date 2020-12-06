% Extract the 10-gen system, same as for the other ones in the paper
% This was actually made much later, because we never needed the
% network structure of the 10-gen system before.

mpc = load_system('test_system_10gen', 0);
ps2 = mpc2ps(mpc);
save('10gen.mat', 'ps2');

% plot lmax vs stress level
stress = [0.0 : 0.1 : 1.5];
plot_stressed_stability_ps(ps2,stress);

% create P matrices for each stress level
make_stressed_systems_ps('10gen',stress,'stress');