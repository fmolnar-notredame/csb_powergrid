# Code and data for analyzing converse symmetry breaking in power-grid networks

This repository contains data and code for reproducing the results described in our upcoming article in Nature Communications.

**Article title:** Asymmetry underlies stability in power grids

**Authors:** Ferenc Molnar, Takashi Nishikawa, Adilson E. Motter

**Abstract:**
Behavioral homogeneity is often critical for the functioning of network systems
of interacting entities. In power grids, whose stable operation requires
generator frequencies to be synchronized—and thus homogeneous—across the network, previous work
suggests that the stability of synchronous states can be improved
by making the generators homogeneous. Here, we show that a substantial additional
improvement is possible by instead making the generators suitably
heterogeneous. We develop a general method for attributing this counterintuitive
effect to converse symmetry breaking, a recently established phenomenon
in which the system must be asymmetric to maintain a stable symmetric state.
These findings constitute the first demonstration of converse symmetry breaking
in real-world systems, and our method promises to enable identification of
this phenomenon in other networks whose functions rely on behavioral
homogeneity.

## Contents of the repository

The folders in this repository contain data and code for reproducing the results presented in the figures of the paper, as follows:
- **Preprocess:** Copies of the power-grid network datasets and code for preprocessing
- **mass_spring:** Matlab code for analyzing the example mass-spring system (Fig. 1)
- **Fig3D:** Mathematica code and data to generate the stability landscape for the 3-generator system (Fig. 2)
- **Maps:** Data for visualizing the NPCC and Germany power grids on maps (Fig. 3)
- **beta_optimization:** Optimized beta configurations generated by simulated annealing (Figs. 2, 3, and 4a)
- **beta_perturbation:** Detailed data on robustness of stability under beta purturbations (Fig. 4b)
- **basin_stability:** Detailed data generated by attraction basin calculations (Fig. 4c)
- **fig_4gen_syst:** Matlab code for analyzing converse symmetry breaking for the 4-generator example system (Fig. 5)
- **CSB:** Code and results of analyzing converse symmetry breaking for the New England, NPCC, UK, and German systems (Fig. 6)
- **explore_cusps:** Interactive Matlab GUI tool for exploring cusp hypersurfaces (Supplementary Fig. 2)

Please see the README.md file in each folder for further details.
