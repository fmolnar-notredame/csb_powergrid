function n3_syst_fig
% Figure on 3-particle mass-spring system
%
% In the paper, indexing is different:
%   mass 1 here --> mass 2 in the paper
%   mass 2 here --> mass 1 in the paper
%   mass 3 here --> mass 3 in the paper

tic

J = @(c1,c2,b1,b2,b3) [ ...
    0, 0, 0, 1, 0, 0;
    0, 0, 0, 0, 1, 0;
    0, 0, 0, 0, 0, 1;
    -2*c1, c1, c1, -b1, 0, 0;
    c1, -c1-c2, c2, 0, -b2, 0;
    c1, c2, -c1-c2, 0, 0, -b3];

c1 = 1; c2 = 0;

% Compute non-uniform optimal beta_i's
rng(1)
M = 30;
lmax_g = inf;
options = optimoptions(@fmincon, 'Display', 'off');
for m = 1:M
    b0 = rand(1,3)*4;
    [b, lmax] = fmincon(@(b)lambda_max(J(c1,c2,b(1),b(2),b(3))), ...
        b0, [], [], [], [], 0*[1,1,1], 4*[1,1,1], [], options);
    if lmax < lmax_g
        b_g = b;
        lmax_g = lmax;
    end    
end

% Choose beta_1:
b1 = b_g(1);

% Three cases:
a = 1/5; J_g_under = J(c1, c2, b1, a*b_g(2), a*b_g(3));
fprintf(' underdamped: b1 = %.2f, b2 = %.2f, b3 = %.2f\n', ...
    a*b_g(1), a*b_g(2), a*b_g(3));
a = 5; J_g_over = J(c1, c2, b1, a*b_g(2), a*b_g(3));
fprintf(' overdamped: b1 = %.2f, b2 = %.2f, b3 = %.2f\n', ...
    a*b_g(1), a*b_g(2), a*b_g(3));
J_g = J(c1, c2, b1, b_g(2), b_g(3));
fprintf(' optimal: b1 = %.2f, b2 = %.2f, b3 = %.2f\n', ...
    b_g(1), b_g(2), b_g(3));

% plot the critical modes vs time
plot([0,10], [0,0], '--', 'Color', 0.*[1,1,1], 'LineWidth', 0.3)
hold on
hp = plot_decaying_mode(J_g_under);
set(hp, 'Color', [0.6,0.6,1], 'LineWidth', 2)
hp = plot_decaying_mode(J_g_over);
set(hp, 'Color', [0,0,1], 'LineWidth', 2)
hp = plot_decaying_mode(J_g);
set(hp, 'Color', 'r', 'LineWidth', 3)
hold off
set(gca, 'YScale', 'linear', 'FontSize', 18, ...
    'YLim', [-0.05, 1.05], ...
    'YTick', 0:0.5:1, 'YTickLabel', {'0.0', '0.5', '1.0'})
xlabel('time')
ylabel('potential energy')
legend('energy = 0', 'underdamped', 'overdamped', 'optimal')
title('Fig. 2b: Mass-spring system')


function lmax = lambda_max(J)

ev = eig(J);
[~,i] = min(abs(ev));
ev(i) = [];
lmax = max(real(ev));


function hp = plot_decaying_mode(J)

[V,D] = eig(J);
ev = diag(D);

% initial condition
x0 = [0; 1; -1; 0; 0; 0];

% compute coefficients for the solution
c = V\x0;

% plot
t = linspace(0,10,1000);
x = zeros(size(V,1), length(t));
for k = 1:length(t)
    for j = 1:6
        x(:,k) = x(:,k) + c(j)*exp(ev(j)*t(k))*V(:,j);
    end
end
if max(abs(imag(x(:)))) > 1e-6
    error('x has imaginary part!')
end
x = real(x);

hp = plot(t, 0.5*(x(1,:) - x(2,:)).^2 + 0.5*(x(1,:) - x(3,:)).^2);
