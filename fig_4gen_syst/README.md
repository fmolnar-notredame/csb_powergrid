# Demostrating CSB for 4-generator example system (Fig. 5)

This folder contatins Matlab code that produces a version of Fig. 5 of the paper.

Prerequisites
- able to run Matlab scripts from a given folder
- Matpower installed and available in Matlab path
- Matlab optimization toolbox installed

# Howto

For all the scripts below, it is assumed that they run from `<your_path>/csb_powergrid/fig_4gen_syst` as the current folder.
This repo includes the output of these scripts as .zip files (to avoid overwriting when the scripts are run).

1) Run run_test.m, which will run compute global (heterogeneous) optimal beta. OUT: run_test.mat 
2) Run fig_small_example_2D_compute.m, which will pre-compute the 2D landscape. OUT: fig_small_example_2D_compute.mat
3) Run fig_small_example.m, which will create a preliminary version of Fig. 5. OUT: fig_small_example_export.png
