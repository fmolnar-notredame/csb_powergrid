# Exploring cusp hypersurfaces

Prerequisites
- able to run Matlab scripts from a given folder

# How to

With `<your_path>/csb_powergrid/explore_cusps` as the current folder, run explore_cusps.m with one argument:

  explore_cusps(sysindex)

where sysindex is the index specifying the system:

- sysindex = 1: New England test system (10-gen)
- sysindex = 2: NPCC power grid (48-gen)
- sysindex = 3: U.K. power grid (66-gen)
- sysindex = 4: German power grid (69-gen)

It will open a GUI showing a heat map and level curves of $\lambda^{max}$.  be able to 

