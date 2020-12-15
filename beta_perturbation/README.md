# Beta perturbation data

This folder contains the results of computing the robustness of stability as a function of perturbations in beta value, for each system in the paper.
Specifically, the contents of Fig. 4b are provided here.

### Code

The changes of stabililty (lmax) under perturbations of beta are computed using the following algorithm:
```
mean_lmax = zeros(points_per_direction)
max_lmax = -inf(points_per_direction)
for s = 1 to samples
  dir = random_direction(n);
  for d = 1 to points_per_direction
    for k = 1 to n
      beta[k] = reference[k] + epsilon * (d-1) * dir[k]
      lmax = compute_lmax(beta)
      mean_lmax[d] += lmax
      max_lmax[d] = max(max_lmax[d], lmax);
    end
  end
end
mean_lmax /= samples
```
- `points_per_direction`: number of samples to take along a given direction
- `samples`: number of random directions to evaluate in n-dimensional beta space
- `random_direction(n)`: a random unit vector uniformly distributed over all possible directions in the `n`-dimensional space; see https://mathworld.wolfram.com/HyperspherePointPicking.html
- `reference`: the original beta value to be perturbed
- `epsilon`: step size along the chosen direction

### Data

In the folder corresponding to each power-grid network, the results of the computations are given in `data.mat`. The file contains a single matrix of size `points_per_direction x 5`, where the columns are as follows:
- column `1`: distance (see `epsilon * (d-1)` from above)
- column `2`: worst lmax around the uniform optimum (i.e., `max_lmax` when `reference==beta_tilde`)
- column `3`: mean lmax around the uniform optimum (i.e., `mean_lmax` when `reference==beta_tilde`)
- column `4`: worst lmax around the global optimum (i.e., `max_lmax` when `reference==beta_sa`)
- column `5`: mean lmax around the global optimum (i.e., `mean_lmax` when `reference==beta_sa`)
