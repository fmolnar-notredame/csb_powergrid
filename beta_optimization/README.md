# Beta optimization data

This folder contains the results of finding the global optimum of the stability landscape for each system in the paper.
Specifically, the contents of Fig. 4a are provided here.

## Contents

For each power-grid network we have
- `Original/info.mat`: `P` matrix and original `beta` values, uniform optimum `beta_tilde`, and corresponding lmax (stability) values
- `Original/samples.mat`: A matrix of 200 rows and `(n+1)` columns where `n` is the number of generators. Each row contains
one sample of simulated annealing run (see below). The first column is the best achieved lmax in that run, and the rest are the corresponding beta values.
- `Stress/level_%2.1f_info.mat`: `P` matrix, beta, and lmax values for the system at the indicated stress level
- `Stress/level_%2.1f_samples.mat`: A matrix of 200 rows and `(n+1)` columns where `n` is the number of generators. Each row contains
one sample of simulated annealing run at the indicated stress level. The first column is the best achieved lmax in that run, and the rest are the corresponding beta values.

## Simulated Annealing
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

- `random()` is a uniform random value in [0, 1)

- `T` is the temperature parameter	
