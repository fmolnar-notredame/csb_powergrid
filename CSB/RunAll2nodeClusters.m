% Make P matrices for all possible 2-node clusters and compute similarity
% Generates EQ_* folders and similarity_*.csv files

sysnames = {'10gen', '48gen', 'uk', 'germany'};
sysIndex = 4; % <--------------- select the current system using this index
sysname = sysnames{sysIndex};

% load original system's P matrix and betas
fname = sprintf('%s_P_orig.dat', sysname);
P = dlmread(fname);

fname = sprintf('%s_beta_orig.dat', sysname);
beta_orig = dlmread(fname).';

fname = sprintf('%s_beta_SA.dat', sysname);
betas = dlmread(fname);
beta_SA = betas(end,:);

% verify basic lmax values
fprintf('--------------------------------------\n');
fprintf('System: %s\nLmax_orig: %f\nLmax_SA: %f\n', ...
    sysname, GetLmax(P, beta_orig), GetLmax(P, beta_SA));
   
n = size(P,1);
fprintf('norm(P) = %f\n', norm(P));

%% Loop over all possible 2-node clusters, compute similarity

fname = sprintf('similarity_%s.csv', sysname);
f = fopen(fname, 'w');
fprintf(f, 'node1,node2,sim_out,sim_in,sim_both,avg_del,avg_del_normed\n');

mkdir(['EQ_' sysname]);

for a = 1 : n
    fprintf('progress: %d/%d\n', a, n);
    for b = a+1 : n
        % initialize P matrix (set zero diagonal)
        P2 = zero_diagonal(P);
        
        % calculate similarity
        indices1 = [1:a-1, a+1:b-1, b+1:n, b];
        indices2 = [1:a-1, a+1:b-1, b+1:n, a];       
        sim_in = norm(P2(a,indices1) - P2(b,indices2))/(norm(P2(a,indices1)) + norm(P2(b,indices2)));
        sim_out = norm(P2(indices1,a) - P2(indices2,b))/(norm(P2(indices1,a) + norm(P2(indices2,b))));
        sim_both = norm( [P2(a,indices1).' ; P2(indices1,a)] - [P2(b,indices2).' ; P2(indices2,b)]);
        
        % create partitioning
        indices = [1:a-1, a, b, a+1:b-1, b+1:n];
        clusters = [1:a-1, a, a, a+1:n-1];
        Q = full(sparse(indices, clusters, ones(1,n)));

        % make exact equitable P matrix
        PEQ = make_exact_EP(P,Q);
        del = P - PEQ;
        avg_del = norm(del);  
        avg_del_norm = norm(del) / norm(P);  %% update: divide by norm(P), to see relative deviation from P matrix to be made equitable
        
        fprintf(f, '%d,%d,%f,%f,%f,%f,%f\n', a, b, sim_out, sim_in, sim_both,...
            avg_del, avg_del_norm);
        
        % save the exact equitable P matrix
        fname = sprintf('EQ_%s/P_%d_%d.dat', sysname, a, b);
        dlmwrite(fname, PEQ);
    end
end

fclose(f);
