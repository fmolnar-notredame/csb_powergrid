# Beta perturbation data

This folder contains the results of computing the robustness of stability as a function of perturbations in beta value, for each system in the paper.
Specifically, the contents of Fig. 4b are provided here.

## Contents

For each power-grid network we have
- `data.mat`: The response of lmax values to perturbations in beta


## Computation

The results are computed using the following algorithm:

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
where the variables are the following:
- `points_per_direction`: number of samples to take along a given direction
- `samples`: number of random directions to evaluate in n-dimensional beta space
- `random_direction(n)`: a unit-length vector in a uniformly random direction in n-dimensional space, see https://mathworld.wolfram.com/HyperspherePointPicking.html
- `reference`: beta value that is being perturbed
- `epsilon`: step size along the chosen direction

## Results

The results are given in a single `1000x5` matrix, where the columns are as follows:
- column `1`: distance (see `epsilon * (d-1)` from above)
- columm `2`: worst lmax around the uniform optimum (i.e., `max_lmax` when `reference==beta_tilde`)
- column `3`: mean lmax around the uniform optimum (i.e., `mean_lmax` when `reference==beta_tilde`)
- columm `4`: worst lmax around the global optimum (i.e., `max_lmax` when `reference==beta_sa`)
- column `5`: mean lmax around the global optimum (i.e., `mean_lmax` when `reference==beta_sa`)
