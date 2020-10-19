function check_cluster(P,cluster)

n = size(P,1);
c = false(n,1);
c(cluster) = true;
disp('within cluster:')
disp(P(c,c))
disp('links connecting to cluster:')
disp(P(c,~c))
% disp('links connecting from cluster:')
% disp(P(~c,c))
