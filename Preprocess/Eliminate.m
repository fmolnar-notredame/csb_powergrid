function ps = Eliminate( ps, elim )
% Eliminate the indicated buses from the network

%% ensure elim is logical
if ~islogical(elim)
    elim = ismember(ps.bus(:,1), elim);
end

%% figure out generator buses (those with at least one machine attached)
genbus = false(size(ps.bus, 1), 1);
genbus(ps.gen(:,1),1) = true;

%% partition Ybus according to elimination
keep = ~elim;
Ykk = ps.Y(keep, keep);
Yke = ps.Y(keep, elim);
Yek = ps.Y(elim, keep);
Yee = ps.Y(elim, elim);

% select generators for elimination
busIDs = ps.bus(elim, 1);
gens = ismember(ps.gen(:,1), busIDs);


%% formulate results
ps.Y = Ykk - Yke * (Yee \ Yek); % Kron-reduction

ps.bus = ps.bus(keep, :);
ps.gen = ps.gen(~gens, :);
ps.gen_dyn = ps.gen_dyn(~gens, :);

%% relabel buses and generators
genbus = genbus(keep);
ps.bus(:,1) = 1 : size(ps.bus,1);
ps.gen(:,1) = ps.bus(genbus, 1);

end

