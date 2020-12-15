# Converse symmetry breaking calculations

### Prerequisites
- able to run Matlab scripts from a given folder
- able to run Python 3 scripts from the same folder
- for the optional steps, able to run pdfLatex 

### How to

For all the scripts below, it is assumed that they are run with `<your_path>/csb_powergrid/CSB` as the current folder.
This repository includes the output of these scripts as .zip files. Re-running the scripts may take a few hours.

1) Run `RunAll2nodeClusters.m` to make the P matrices for all possible 2-node clusters
	OUT: `similarity_*.csv`, `EQ_*/P_%d_%d.dat`

2) Run `make_similarity_graphs.py` to visualize similarity and select the top 20 clusters
	OUT: `cluster_choice_*.dat` files, `Results_*` folders containing similarity graphs (`graph_*_sim_%d_[%d,%d].png`)

3) Run RunSelected2nodeClusters.m to compute the 2D stability landscape as a function of the betas of the symmetrized generators
	OUT: `Results*/landscape_*_%d_%d.dat` and `Results*/landscape_args_*_%d_%d.dat`

4) Run RunClusterZoominInterpolation.m to compute the precise stability values as the systems are interpolated between
	original and exact-equitable.
	OUT: Results*/interp2_beta_[opt/tilde]_%s_%d_%d.dat, Results*/interp2_lmax_%s_%d_%d.dat

5) OPTIONAL: run make_interpolation_plots.py to plot the results from (4)

6) OPTIONAL: run plot_landscapes.py to plot the 2D stability landscapes from (3)

7) OPTIONAL: run make_landscape_slides.py to create a slideshow of all 2-node cluster similarities and landscapes.
	NOTE: this requires (5) and (6) to run before this one.
	OUT: Landscape_choices.tex -- compile this with pdflatex to create the actual slideshow as Landscape_choices.pdf
	NOTE: if the tex file is empty, it means that the files from the previous steps were not found.

8) Run make_pub_figure.py to make the prototype of Fig. 4 in the paper. This script uses the other make_pub*.py files to plot each section.
	NOTE: The landscape plotting function in make_pub_b.py computes the landscapes and saves them to cache files (plot_landscape_*.npz).
	      These cache files speed up plotting the next time, since the landscapes take some time to compute. 
              If you want to force recomputation, just delete these .npz files.
