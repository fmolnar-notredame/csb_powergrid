% Extract the 3-gen system, same as for the other ones in the paper

% plot lmax vs stress level
stress = [0.0 : 0.1 : 2.6];
plot_stressed_stability('test_system_3gen', 0, stress);

% create P matrices for each stress level
make_stressed_systems('test_system_3gen', 0, stress, 'stress');

% save ps2 system

mpc = load_system('test_system_3gen', 0);
ps2 = mpc2ps(mpc);

% uncomment to overwrite existing
% save('test_system_3gen','ps2');