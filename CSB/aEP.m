function [avg_del, p, del] = aEP(P,c)
% Find an optimal partitition minimizing the deviation from being equitable
% (del_aEP.m), normalized by the geometric mean of the cluster sizes, over
% all non-trivial possible partitions.

%orig_path = path;
%addpath('./SetPartFolder/SetPartFolder')

% Find 
n = size(P,1);
if nargin < 2
    p = SetPartition(n);
else
    if c == n
        error('Partition size must be < n.')
    end
    p = SetPartition(n,c);
end

% Remove the partition with all trivial clusters.
keep = true(size(p));
for i = 1:length(p)        
    if length(p{i}) > n-1 || length(p{i}) == 1
        keep(i) = false;
    end
end
p = p(keep);

avg_del = nan(size(p));
del = cell(size(p));
for i = 1:length(p)
    c = length(p{i}); % number of clusters in partition i
    Q = zeros(n,c);
    cs = zeros(1,c);
    for j = 1:c
        ix = p{i}{j};
        cs(j) = length(ix);
        for k = 1:length(ix)
            Q(ix(k),j) = 1;
        end
    end
    [avg_del(i), del{i}] = del_aEP(P,Q);
    avg_del(i) = avg_del(i)/(prod(cs)^(1/c));
end

% save
save('aEP.mat', 'p', 'avg_del')
save('aEP_del.mat', 'del')

k = 10;
[~,i] = sort(avg_del, 'ascend');
avg_del = avg_del(i(1:k));
del = del(i(1:k));
p = p(i(1:k));
if nargout == 0
    fprintf('%d optimal partitions:\n', k)
    opt.header = 'none';
    opt.partindent = '';
    for kk = 1:k
        fprintf('  avg_del = %5.3f: ', avg_del(kk));
        DispPartObj(p(kk),[],opt)
    end
end

%path(orig_path)
