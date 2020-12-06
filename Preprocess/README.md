# Preprocessing the raw power grid networks

Prerequisites
- MatPower version 5.1  (not the latest!)
- able to run Matlab scripts from a given folder

# Description

The raw power grid data files are the following.
- test_system_10gen.m ("10gen")
- data48em.m ("48gen")
- GBreduced.m ("UK")
- ENTSO_E_2009_WINTER.mat ("Germany")

For each system, there is an "Extract_*.m" script that executes the preprocessing of the given network.
These include the following steps:
- Fill out missing (complex) impedances and generator dynamic parameters
- Calculate the bus admittance matrix
- Save the network state in an internal "ps2" format that resembles MatPower files
- Calculate the Effective Network (EN) model
- Linearize dynamics around the frequency-synchronous stable fixed point
- Export the linearized system matrix as P matrices and original beta vectors
- Export data needed to draw the network on a map

The processed networks are saved in the following files:
- 10gen.mat ("10gen")
- data48em2.mat ("48gen")
- GBreduced6.mat ("UK")
- germany8.mat ("Germany")

Note that these are the original files that our preprocessing has generated.
Saving these files has been commented out from the scripts above to prevent overwriting the samples.

The P matrices (linearized dynamics) are computed for a number of "stress levels", which are
different power-flow states where the original power generated and consumed (both real and reactive) have been
multiplied by the stress level. Therefore the unmodified system is found at the stress level of 1.0.
These files are saved in subfolders with the corresponding system name.