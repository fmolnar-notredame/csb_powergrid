function explore_cusps(sysindex)
% EXPLORE_CUSPS Interactive GUI function that allows you to explore (the 2D
% cross section of) various cusp hypersurfaces in the beta-parameter space
% of a given system.
%
% Usage: explore_cusps(i)
% 
% where i is the index specifying the system:
% 
% - i = 1: New England test system (10-gen)
% - i = 2: NPCC power grid (48-gen)
% - i = 3: U.K. power grid (66-gen)
% - i = 4: German power grid (69-gen)
% 
% It will open a GUI showing a heat map and level curves of lambda^{max} on
% the plane M, as in Supplementary Fig. 2 of the paper. By simply moving
% the cursor, you will be able to see how lambda^{max} and the full
% eigenvalue spectrum of the Jacobian J changes as a function of the
% position on M.


if nargin == 0
    %sysindex = 1;
    help([mfilename,'.m'])
    return
end

sysnames = {'10gen', '48gen', 'uk', 'germany'};
sysname = sysnames{sysindex};

cdata = imread(['fig_high_dim_cusps_',sysname,'.png']);
load(['axes_',sysname,'.mat'])
load(['beta_optimization_',sysname,'_info.mat'])
P = info.P;

user_data.origo = origo;
user_data.x_basis = x_basis;
user_data.y_basis = y_basis;
user_data.P = P;

switch sysindex
    case 1
        user_data.dx = 10;
        user_data.dy = 10;
    case 2
        user_data.dx = 5;
        user_data.dy = 20;
    case 3
        user_data.dx = 5;
        user_data.dy = 75;
    case 4
        user_data.dx = 5;
        user_data.dy = 50;
end

figure('Position', [18,279,1423,519]);
user_data.main_axes = axes('Position',[0.08,0.11,0.3,0.815]);
image(x_values, y_values(end:-1:1), cdata)
xlabel('\xi_1')
ylabel('\xi_2')
axis square xy
title(sprintf('Synchronization landscape (%s)', sysname))

h = annotation('textbox', [0.4,0.11,0.07,0.815], 'LineStyle', 'none', ...
    'String', '\beta_i:', 'FontSize', 16, 'FontName', 'Courier');
user_data.beta_text = h;

h = annotation('textbox', [0.48,0.11,0.12,0.815], ...
    'String', {'\lambda^{max} =','eigenvalues:'}, 'LineStyle', 'none', ...
    'FontSize', 16, 'FontName', 'Courier');
user_data.ev_text = h;

user_data.ev1_axes = axes('Position',[0.66,0.11,0.3,0.815]);
ev_plot = plot(0,0,'*');
xlim(user_data.dx*[-1,1])
ylim(user_data.dy*[-1,1])
hold on
user_data.lmax_ev_plot = plot(0,0,'ro');
lmax_line = plot([0,0], [-1000,1000], 'k-');
hold off
xlabel('Re(\lambda)')
ylabel('Im(\lambda)')
title('Jacobian eigenvalues')
user_data.ev_plot = ev_plot;
user_data.lmax_line = lmax_line;

set(gcf, 'UserData', user_data)
set(gcf, 'WindowButtonMotionFcn', @WindowButtonMotionCallback)


function [lmax,eval] = GetLmax(P, betas, noskip)

J = [ zeros(size(P)), eye(size(P)); 
    -P, -diag(betas)];

eval = eig(J);

if nargin>2 && noskip
    lmax = max(real(eval));
else
    [~,ix] = min(abs(eval));
    eval(ix) = [];
    lmax = max(real(eval));
end


function WindowButtonMotionCallback(src,evt)

u = src.UserData;
h = u.main_axes;
x = h.CurrentPoint(1,1);
y = h.CurrentPoint(1,2);
xl = xlim(h); yl = ylim(h);
if xl(1) < x && x <= xl(2) && yl(1) < y && y <= yl(2)

    b = u.origo + u.x_basis * x + u.y_basis * y;
    [lmax,ev] = GetLmax(u.P, b, false);
    
    M = 20;
    s = cell(1, M+2);
    [~,i] = sort(b, 'descend');
    if length(b) > M
        i = i(1:M);
        s{end} = '   ...';
    end
    b = b(i);
    s{1} = '\beta_i:';
    for i = 1 : length(b)
        s{i+1} = ['  ', num2str(b(i),'%-7.3f')];
    end
    u.beta_text.String = s;

    i = ( abs(real(ev)-lmax) <= u.dx & abs(imag(ev)) < u.dy );
    u.ev_plot.XData = real(ev(i));
    u.ev_plot.YData = imag(ev(i));
    u.lmax_line.XData = lmax*[1,1];
    u.ev1_axes.XLim = lmax + u.dx*[-1,1];
    
    i = find(abs(lmax - real(ev)) < 0.05);
    u.lmax_ev_plot.XData = real(ev(i));
    u.lmax_ev_plot.YData = imag(ev(i));

    M = 19;
    if length(ev) > M
        [~,i] = sort(real(ev), 'descend');
        ev = ev(i(1:M));
    end
    s = cell(1, length(ev)+3);
    s{1} = sprintf('\\lambda^{max} = %6.3f', lmax);
    s{2} = 'eigenvalues:';
    for i = 1 : length(ev)
        s{i+2} = ['  ', num2str(ev(i),'%-15.3f')];
    end
    s{end} = '   ...';
    u.ev_text.String = s;
        
else
    
    s = '\beta_i:';
    u.beta_text.String = s;
    s = {'\lambda^{max} =', 'eigenvalues:'};
    u.ev_text.String = s;
    u.ev_plot.XData = [];
    u.ev_plot.YData = [];
    
end

