function P = MakeP(ps, mode)
% create the P matrix for a given power system
% homogenization modes:
% 1: original system (default)
% 2: make the off-diagonal rowsum of P homogeneous (the mean value)

if nargin < 2
    mode = 1;
end

%% build dynamic EN model manually - steps similar to EN_model and EN_Lmax

[Ynn, Ynr, Yrn, Yrr, ~, ~] = MakeExtendedYbus(ps);
YEN = full(Ynn - Ynr * (Yrr \ Yrn)); % Kron-reduction

% dyn parameters
x_d = ps.gen_dyn(:,1); %transient reactances
H = ps.gen_dyn(:,2);   %inertia constants
D = ps.gen_dyn(:,3);    % damping constants
baseMVA = ps.baseMVA;  %common system base
n = size(H,1);

% System reference frequency omega_R (in radian):
if isfield(ps, 'ref_freq')
    omega_R = 2 * pi * ps.ref_freq;
else
    omega_R = 2 * pi * 60;    
end

% P and Q injected at generator terminals in p.u. on system base MVA.
Pi = ps.gen(:,2) / baseMVA; 
Qi = ps.gen(:,3) / baseMVA;

% Voltage magnitude V and phase angle phi for the generator terminal buses
tb =  ps.gen(:, 1);
V =   ps.bus(tb, 8);
phi = ps.bus(tb, 9) / 180 * pi;

% Compute the complex voltage E at the internal nodes of generators and
% motors.
E = ((V + Qi .* x_d ./ V) + 1j * (Pi .* x_d ./ V)) .* exp(1j * phi);

% calculate inertia and damping coeffs
M = 2*H / omega_R;
D = D / omega_R;

% compute the dyn parameters as defined in eq.(13) in Methods
% we need the steady-state P_mi, which we can compute by solving LHS==0.
% (i.e., in steady state, P_mi == P_ei)

delta = angle(E); % original steady state angles
E_abs = abs(E);

Yabs = abs(YEN);
alpha = angle(YEN);

Dik = bsxfun(@minus, delta, delta.'); %delta(i) - delta(k)
Kik = bsxfun(@times, E_abs, E_abs.') .* Yabs; % |E(i)*E(k)*Y(i,k)|

P_mi = sum(Kik .* sin(Dik - alpha + pi/2), 2);
% sanity check: this is identical to ps.gen(:,2) / baseMVA, because we just
% wrote the steady state in the rotating reference frame. Thus, Pmi 
% does NOT have a component to work against damping, and Pmi=Pgi @ steady state

% now we can compute the dyn parameters
a_i = ( P_mi - E_abs.^2 .* diag(Yabs) .* cos(diag(alpha)) ) ./ M;

Cik = Kik;
for i = 1 : n
    Cik(i,:) = Cik(i,:) ./ M(i);
    Cik(i,i) = 0;
end

gamma = alpha - pi/2;

beta = D ./M;

%% powerflow check
z = sum(Cik .* sin(Dik - gamma),2) - a_i;
if norm(z) > 1e-8
    fprintf('Original system: Powerflow ERROR = %f\n', norm(z));
else
    fprintf('Original system: Powerflow OK\n');
end

%% make the P matrix, for each mode

if mode==1
    
    % original system
    P = -Cik .* cos(Dik - gamma);
    for i = 1 : n
        P(i,i) = - sum(P(i,[1:i-1,i+1:n]));    
    end
    return

elseif mode==2

    % homogenize the "effective" coupling strength, Cik.*cos(Dik - gamma)
    d = sum(Cik .* cos(Dik - gamma), 2); 
    ratios = mean(d) ./ d;

    CIK = Cik;
    for i = 1 : n
        CIK(i,:) = CIK(i,:) * ratios(i);
    end

    % It doesn't affect the calculation below, but a_i should be adjusted so
    % that aa = sum(CIK .* sin(Dik - gamma),2) and the same power flow solution
    % remains valid.

    % powerflow 
    %aa = sum(CIK .* sin(Dik - gamma),2);

    % P matrix
    P = -CIK .* cos(Dik - gamma); % MINUS CIK !!
    for i = 1 : n
        P(i,i) = -sum(P(i,[1:i-1,i+1:n]));
    end
end

end

