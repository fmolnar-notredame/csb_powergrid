# &beta; optimization data

This folder contains the results of running simulated annealing to find a heterogeneous &beta; assignment that optimizes the stability &lambda;<sup>max</sup>. The best stability identified for each system is plotted in Fig. 4a of the paper.

### Data

The folder for each power-grid network contains:
- `Original/info.mat`: `P` matrix and original &beta; values, homogeneous optimum &beta;<sub>=</sub> (`beta_tilde` in the code below), and corresponding &lambda;<sup>max</sup> values
- `Original/samples.mat`: A matrix of 200 rows and `(n+1)` columns where `n` is the number of generators. Each row contains
one sample of simulated annealing run (see below). The first column is the best achieved &lambda;<sup>max</sup> in that run, and the rest are the corresponding &beta; values.
- `Stress/level_%2.1f_info.mat`: `P` matrix, &beta;, and &lambda;<sup>max</sup> values for the system at the indicated stress level
- `Stress/level_%2.1f_samples.mat`: A matrix of 200 rows and `(n+1)` columns where `n` is the number of generators. Each row contains
one sample of simulated annealing run at the indicated stress level. The first column is the best achieved &lambda;<sup>max</sup> in that run, and the rest are the corresponding &beta; values.

### Optimization code
The optimization is based on simulated annealing with the following procedure for each sample:
```
old_beta = beta_tilde + 10 * dir()
T = 0.05
old_lmax = calculate_lmax(old_beta)
while T > 1e-4:
	new_beta = old_beta + dir() * 20 * T
	new_lmax = calculate_lmax(new_beta)
	if new_lmax < old_lmax OR random() < exp( (old_lmax - new_lmax) / T ):
		old_beta = new_beta
		old_lmax = new lmax
	T = T * 0.99995
```

- `dir()` is a unit-length vector that points to a uniformly random direction in `n`-dimensional space, where `n` is the number of generators.
See formula at https://mathworld.wolfram.com/HyperspherePointPicking.html

- `random()` is a random number distributed uniformly in [0, 1).

- `T` is the temperature parameter.	

