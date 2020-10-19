function [tf, D] = isEP(P,Q)
% Check if the partition Q is equitable for matrix P
%
% P: n x n coupling matrix
% Q: n x c indicator matrix (c is the number of clusters)
%    Q(i,j) = 1 if node i belongs to cluster j and
%    Q(i,j) = 0 otherwise

% Averaging operator: takes the mean over nodes in each cluster.
mean_op = (Q'*Q)\Q';

% The element-wise deviations from Q being an equitable partition. The
% (i,j) element of the matrix P*Q is the total strength of the inputs
% received by node i from the nodes in cluster j.  Multiplying from left by
% Q*mean_op takes the average over nodes in each cluster and then
% distributes to each of these nodes.  Thus, D(i,j) is the deviation of the
% strength of input, cluster j --> node i, from the average over cluster j.
% The matrix D would be zero if Q is an equitable partition.
D = P*Q - Q*mean_op*P*Q;

tf = ( norm(D) < 1e-10 );

