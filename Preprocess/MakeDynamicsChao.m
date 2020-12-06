function ps = MakeDynamicsChao( ps )
% overwrite the dynamics with Chao's suggestions

% max power generation
maxPg = ps.gen(:,9);
machineBase = maxPg * 1.5; % Chao: machine base = 1.5 * max generation

% number of generators
n = size(ps.gen, 1);

% dynamical parameters on machine base, Chao's suggestions
H = rand(n, 1) * 4 + 1; % [1..5]
D = rand(n, 1) * 2 + 1; % [1..3]

% series: GBreduced3, germany5
%xd = rand(n, 1) * 0.2 + 0.1; % [0.2..0.4]

% series: GBreduced4, germany6
% xd = rand(n, 1) * 0.1 + 0.3; % [0.2..0.4]

% series GBreduced5, germany7
% xd = rand(n, 1) * 0.2 + 0.001;

% series GBreduced6, germany8
xd = rand(n, 1) * 0.1 + 0.001;


% conversion to system base
systemBase = ps.baseMVA;
H = machineBase ./ systemBase .* H;
D = machineBase ./ systemBase .* D;
xd = systemBase ./ machineBase .* xd;

% overwrite dyn
ps.gen_dyn = [xd, H, D];

end

