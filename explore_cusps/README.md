# Exploring cusp hypersurfaces

This is an interactive Matlab GUI function that allows you to explore (the 2D cross section of) various cusp hypersurfaces in the beta-parameter space of a given system.

Prerequisites
- able to run Matlab scripts from a given folder

# How to

With `<your_path>/csb_powergrid/explore_cusps` as the current folder, run explore_cusps.m with one argument:

  explore_cusps(i)

where i is the index specifying the system:

- i = 1: New England test system (10-gen)
- i = 2: NPCC power grid (48-gen)
- i = 3: U.K. power grid (66-gen)
- i = 4: German power grid (69-gen)

It will open a GUI showing a heat map and level curves of lambda^{max} on the plane M, as in Supplementary Fig. 2 of the paper. By simply moving the cursor, you will be able to see how lambda^{max} and the full eigenvalue spectrum of the Jacobian J changes as a function of the position on M.

