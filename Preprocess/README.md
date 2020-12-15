# Preprocessing of power-grid network datasets

### Prerequisites
- MatPower version 5.1  (not the latest!)
- able to run Matlab scripts from a given folder

### Description

The raw data files for the power-grid networks we study are the following:
- 3-generator test system (3-gen): `test_system_3gen.m`
- New England test system (10-gen): `test_system_10gen.m`
- NPCC power grid (48-gen): `data48em.m`
- U.K. power grid (66-gen): `GBreduced.m`
- German power grid (69-gen): `ENTSO_E_2009_WINTER.mat`

Note: The data file for the 4-generator example system in Fig. 5 can be found in the folder "fig_4gen_syst".

For each system, there is a script `Extract_*.m`, which processes the raw data file and computes the stability for a range of stress level.  For each stress level, it executes the following:
- calculates the Effective Network (EN) model
- linearizes the dynamics around the synchronous state
- exports the resulting P matrix and the original beta values in the subfolder with the corresponding system name (as `%s/level%04d_P.txt` and `%s/level%04d_b.txt`, respectively)

For the NPCC, U.K., and German grids, it also does the following:
- fills out missing (complex) impedances and generator dynamic parameters
- calculates the bus admittance matrix
- saves the network state in an internal "ps2" format that resembles MatPower files

For the NPCC and German grids, it also exports the data needed to draw the network on a map.

The processed networks are saved in the following files:
- New England test system (10-gen): `10gen.mat`
- NPCC power grid (48-gen): `data48em2.mat`
- U.K. power grid (66-gen): `GBreduced6.mat`
- German power grid (69-gen): `germany8.mat`

Note that these are the original files that our preprocessing has generated.
Saving these files has been commented out from the scripts above to prevent overwriting the samples.
