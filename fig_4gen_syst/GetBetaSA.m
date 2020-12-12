function [beta_SA, lmax_SA, betas] = GetBetaSA(P, beta_range, sa_runs)
% Find beta_SA by running a number of simulated annealing runs or genetic
% algorithm.

n = size(P,1);
J = [zeros(n,n), eye(n,n); -P, -zeros(n)];
diags = 2*n*n+n+1 : 2*n+1 : 4*n*n; % linear index of betas in the J matrix

% opts = optimoptions("simulannealbnd");
% opts.Display = 'none';
% opts.FunctionTolerance = 1e-8;
% opts.ReannealInterval = 500;
% opts.MaxFunctionEvaluations = 10000 * n;
% opts.InitialTemperature = 1;

opts = optimoptions('ga');
opts.Display = 'none';

lb = zeros(n,1);
ub = ones(n,1) * beta_range;

betas = zeros(n, sa_runs); % record each annealing result
lmaxs = zeros(n,1);

% parfor q = 1 : sa_runs
for q = 1 : sa_runs
    
    fprintf('.');
    b0 = rand(n,1) * beta_range;    
    J1 = J;
    
    % run simulated annealing
    %[beta, lmax] = simulannealbnd(@(x) GetLmaxJBeta(J1,diags,x), b0, lb, ub, opts);
    
    % run genetic algorithm
    op = opts;
    op.InitialPopulationMatrix = b0;
    [beta, lmax] = ga(@(x) GetLmaxJBeta(J1,diags,x), n, [], [], [], [], lb, ub, [], opts);
    betas(:,q) = beta;
    lmaxs(q) = lmax;
    
end
fprintf('\n');

[~,i] = min(lmaxs);
lmax_SA = lmaxs(i);
beta_SA = betas(:,i);

end

