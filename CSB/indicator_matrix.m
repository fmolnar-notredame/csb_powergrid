function Q = indicator_matrix(p)
% Generate the indicator matrix Q, which is the same as the matrix H in the
% paper:
%
% Graph partitions and cluster synchronization in networks of oscillators,
% Michael T. Schaub, Neave O'Clery, Yazan N. Billeh, Jean-Charles Delvenne,
% Renaud Lambiotte, and Mauricio Barahona, Chaos 26, 094821 (2016).

% find the number of nodes from p
n = zeros(size(p));
for k = 1:length(p)
    n(k) = max(p{1}{k});
end
n = max(n);

% number of clusters in partition i
c = length(p{1}); 

% create indicator matrix Q
Q = zeros(n,c);
cs = zeros(1,c);
for j = 1:c
    ix = p{1}{j};    
    cs(j) = length(ix);
    for k = 1:length(ix)
        Q(ix(k),j) = 1;
    end
end
