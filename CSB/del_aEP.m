function [avg_del, del] = del_aEP(P,Q)
% Deviation from being equitable, to be minimized to find an optimal
% approximate equitable partition.
%
% P: n x n coupling matrix
% Q: n x c indicator matrix (c is the number of clusters)
%    Q(i,j) = 1 if node i belongs to cluster j and
%    Q(i,j) = 0 otherwise

del = P - make_exact_EP(P,Q);
%avg_del = norm(del);  
avg_del = norm(del) / norm(P);  %% update: divide by norm(P), to see relative deviation from P matrix to be made equitable