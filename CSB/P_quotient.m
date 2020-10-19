function Pq = P_quotient(P,Q)
% Generate a matrix that would be the Laplacian matrix of the quotient
% graph if Q was an equitable partition.

mean_op = (Q'*Q)\Q';
Pq = mean_op*P*Q;
