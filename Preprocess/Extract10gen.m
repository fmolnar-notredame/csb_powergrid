% Extract the 10-gen system, same as for the other ones in the paper
% This was actually made much later, because we never needed the
% network structure of the 10-gen system before.

% plot lmax vs stress level
stress = [0.0 : 0.1 : 2.1];
plot_stressed_stability('test_system_10gen', 0, stress);

% create P matrices for each stress level
make_stressed_systems('test_system_10gen', 0, stress, 'stress');