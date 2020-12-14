# Basin stability data

This folder contains the results of computing basin stability for each system in the paper.
Specifically, the contents of Fig. 4c are provided here.

## Contents

For each power-grid network we have
- `dynamics.mat`: The dynamical parameters for the Swing equation
- `data_beta_tilde.mat`: Basin results when using beta==beta_tilde (uniform optimum)
- `data_beta_sa.mat`: Basin results when using beta==beta_sa (global heterogeneous optimum)

## Simulations

In each run the Swing equation is integrated over time. Specifically, the right-hand side (r.h.s) is given by the following code:
```
for (i = 0; i < n; i++)
{
	dxdt[i] = y[i];
	dydt[i] = -beta[i] * y[i] + omega / (2.0 * H[i]) * Pg[i];
	for (int k = 0; k < n; k++)
	{
		dydt[i] -= omega / (2.0 * H[i]) * E[i] * E[k] * Ymag[i,k] * sin(x[i] - x[k] - Yang[i,k] + PI / 2.0);
	}
}
```
where the variables are the following, with the index indicating the generator:
- `x[i]`: rotor angle
- `y[i]`: rotor angular velocity
- `beta[i]`: damping coefficient
- `H[i]`: inertia coefficient
- `Pg[i]`: power generated
- `E[i]`: internal voltage magnitude 
- `Ymag[i,k]`: magnitude of complex admittance between `i` and `k`
- `Yang[i,k]`: angle of complex admittance between `i` and `k`
- `dxdt[i]`: the r.h.s. for the angle
- `dydt[i]`: the r.h.s. for the velocity


All values are per unit, angles are radians, and angular velocity is radians/second.

## Results

The results are given in a single `1000x2` matrix, where each row is the result of a run,
and the columns are as follows:
- column `1`: `0`: not synchronized, `1`: synchronized (according to the sync criteria)
- columm `2`: time when synchronization was achieved (according to the sync criteria)
