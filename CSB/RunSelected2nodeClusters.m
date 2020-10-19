% Run the landscape of chosen 2-node clusters to see which one is the best
% Landscape is made in 2 levels of zoom

sysnames = {'10gen', '48gen', 'uk', 'germany'};
sysIndex = 2; % <--------------------- select the system using this index
sysname = sysnames{sysIndex};

fname = sprintf('%s_P_orig.dat', sysname);
P = dlmread(fname);
n = size(P,1);

fname = sprintf('%s_beta_SA.dat', sysname);
betas = dlmread(fname);
beta_SA = betas(end,:);

fprintf('--------------------------------------\n');
fprintf('System: %s\nLmax_SA: %f\n', ...
    sysname, GetLmax(P, beta_SA));

% load cluster choices (candidates based on avg_del and similarity)
fname = sprintf('cluster_choice_%s.dat', sysname);
C = dlmread(fname);

%% make landscape for each cluster

res = 200;
bmin = 1;   % zoom level 1
bmax = 20;

for q = 1 : size(C,1)
    a = C(q,1);
    b = C(q,2);
    fprintf('Cluster: %d,%d\n', a, b);
    
    %% Make exact equitable P matrix
    indices = [1:a-1, a, b, a+1:b-1, b+1:n];
    clusters = [1:a-1, a, a, a+1:n-1];
    Q = full(sparse(indices, clusters, ones(1,n)));
    PEQ = make_exact_EP(P,Q);
    
    %% Make J matrix template
    J = [zeros(n,n), eye(n,n); -PEQ, -diag(beta_SA)];
    
    %% Landscape zoom 1
    L1 = zeros(res, res);
    beta_a = linspace(bmin, bmax, res);
    beta_b = linspace(bmin, bmax, res);
    
    parfor j = 1:res % parfor
        JJ = J; % local copy
        Lj = zeros(res,1); % j-th column of L1
        fprintf('  zoom 1, j=%d\n', j);
        
        for i = 1:res
            JJ(n+a, n+a) = -beta_a(j); % a varies horizontally
            JJ(n+b, n+b) = -beta_b(i); % b varies vertically
            Lj(i) = GetLmaxJ(JJ);
        end
        
        % store
        L1(:,j) = Lj;
    end
    
    % global opt
    [~,i] = min(L1(:));
    [i,j] = ind2sub(size(L1), i); % row index i, col index j
    lmax_opt = L1(i,j);
    bopt_a = beta_a(j);
    bopt_b = beta_b(i);
    
    % opt along diagonal
    lmax2 = diag(L1);
    [~,i] = min(lmax2);
    lmax_tilde = lmax2(i);
    btilde = beta_a(i);
    
    figure(1);
    imagesc(beta_a, beta_b, L1);
    hold on;
    plot(bopt_a, bopt_b, 'w.', 'MarkerSize', 16);
    plot(btilde, btilde, 'r.', 'MarkerSize', 16);
    hold off;
    
    %% Zoom level 2 calculation
    ba_range = abs(btilde - bopt_a);
    ba_ctr = (btilde + bopt_a)/2;
    
    bb_range = abs(btilde - bopt_b);
    bb_ctr = (btilde + bopt_b)/2;
    
    bmin_a = ba_ctr - ba_range * 0.7;
    bmax_a = ba_ctr + ba_range * 0.7;
    
    bmin_b = bb_ctr - bb_range * 0.7;
    bmax_b = bb_ctr + bb_range * 0.7;    
    
    %% Landscape zoom 2
    L2 = zeros(res, res);
    
    beta_a2 = linspace(bmin_a, bmax_a, res);
    beta_b2 = linspace(bmin_b, bmax_b, res);
    
    parfor j = 1:res % parfor
        JJ = J; % local copy
        Lj = zeros(res,1); % j-th column of L1
        fprintf('  zoom 2, j=%d\n', j);
        
        for i = 1:res
            JJ(n+a, n+a) = -beta_a2(j); % a varies horizontally
            JJ(n+b, n+b) = -beta_b2(i); % b varies vertically
            Lj(i) = GetLmaxJ(JJ);
        end
        
        % store
        L2(:,j) = Lj;
    end
    
    % global opt
    [~,i] = min(L2(:));
    [i,j] = ind2sub(size(L2), i); % row index i, col index j
    lmax_opt = L2(i,j);
    bopt_a2 = beta_a2(j);
    bopt_b2 = beta_b2(i);
    
    %% Opt along diagonal, refined
    bt = linspace(btilde-1, btilde+1, res*4);
    Lt = zeros(res,1);
    
    for i = 1:res*4
        J(n+a, n+a) = -bt(i);
        J(n+b, n+b) = -bt(i);
        Lt(i) = GetLmaxJ(J);
    end
    
    % find min
    [~,i] = min(Lt);
    lmax_tilde = Lt(i);
    btilde2 = bt(i);
    
    figure(2);
    imagesc(beta_a2, beta_b2, L2);
    hold on;
    plot(bopt_a2, bopt_b2, 'w.', 'MarkerSize', 16);
    plot(btilde2, btilde2, 'r.', 'MarkerSize', 16);
    hold off;
    
    
    %% save stats
    
    fname = sprintf('Results_%s/landscape_%s_%d_%d.dat', sysname, sysname, a, b);
    dlmwrite(fname, L2);
    
    fname = sprintf('Results_%s/landscape_args_%s_%d_%d.dat', sysname, sysname, a, b);
    f = fopen(fname, 'w');
    fprintf(f, '%f,%f,%f,%f\n', bmin_a, bmax_a, bmin_b, bmax_b); % extent
    fprintf(f, '%f,%f,%f\n', bopt_a2, bopt_b2, lmax_opt); % global min
    fprintf(f, '%f,%f\n', btilde2, lmax_tilde); % uniform min
    fprintf(f, '%f\n', lmax_opt / lmax_tilde - 1); % rel. improvment
    fclose(f);
    
end