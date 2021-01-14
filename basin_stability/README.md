# Calculation of attraction basin

This folder contains the results of computing basin stability for each system in the paper.
Specifically, the contents of Fig. 4c are provided here.

## System parameters

In the subfolder for each power-grid network, we have `dynamics.mat`, containing all parameters:
- `n`: number of generators
- `H[i]`: inertia coefficient
- `omega`: reference (angular) frequency
- `Pg[i]`: power generated
- `E[i]`: internal voltage magnitude 
- `Ymag[i,k]`: magnitude of complex admittance between `i` and `k`
- `Yang[i,k]`: angle of complex admittance between `i` and `k`
- `delta_star[i]`: steady-state rotor angle
- `beta_tilde[i]`: homogeneous optimal &beta;
- `beta_sa[i]`: heterogeneous optimal &beta; identified by simulated annealing

Angles are in radians, angular velocities are in radians/second, and all power system parameters are in per unit.

## Code

The code for the attraction basin calculation is shown below. In each run, the swing equation is integrated over time with the function `integrate()` (which calls `rhs(x, y, t)` to compute the right hand side of the equation), while checking if synchronization is achieved with `check_sync(x, y)`. `integrate()` uses `rk45_step(rhs, x, y, t)`, a 4th-order Runge-Kutta integrator with adaptive time stepping.

```
//right-hand side of the swing equation
def rhs(x, y, t):
{
  for (i = 0; i < n; i++)
  {
    dxdt[i] = y[i];
    dydt[i] = -beta[i] * y[i] + omega / (2.0 * H[i]) * Pg[i];
    for (int k = 0; k < n; k++)
    {
      dydt[i] -= omega / (2.0 * H[i]) * E[i] * E[k] * Ymag[i,k] * sin(x[i] - x[k] - Yang[i,k] + PI / 2.0);
    }
  }
  return dxdt, dydt
}

// check synchronization at the current state
def check_sync(x, y):
{
  min_freq = inf;
  max_freq = -inf;
  for (i = 0; i < n; i++)
  {
    min_freq = min(min_freq, y[i]);
    max_freq = max(max_freq, y[i]);
  }
  max_freq /= 2.0 * PI;
  min_freq /= 2.0 * PI;
  if (max_freq < 0.3 and min_freq > -0.3)
    return true;
  else
    return false;
}

// time integration
def integrate():
{
  // initialize
  t = 0
  deltaX = 180.0 / 180.0 * PI; // angle to radians
  deltaY = 1.0  * 2*PI; //Hz to rad/s
  for (i = 0; i < n; i++)
  {
    x[i] = delta_star[i] + (random()-0.5) * 2 * deltaX;
    y[i] = (random()-0.5) * 2 * deltaY;
  }

  //time steps
  first_sync = 0;  
  while (t < tmax)
  {
    x, y, t = rk45_step(rhs, x, y, t);
    sync = check_sync(x, y);
    if (sync && first_sync==0)
      first_sync = t;
    else
      first_sync = 0;
  }
  if (first_sync > 0)
    return {true, first_sync}
  else
    return {false, 99.999}
}
```
With `i` indexing the generators, the variables are:
- `t`: time
- `x[i]`: rotor angle
- `y[i]`: rotor angular velocity (frequency)
- `dxdt[i]`: the r.h.s. for the angle
- `dydt[i]`: the r.h.s. for the angular velocity

Addtional parameters are:
- `beta[i]`: combined damping coefficient (`beta==beta_tilde` or `beta==beta_sa`)
- `tmax`: maximum integration time (we used `tmax = 10`)

`random()` is a random number generator returning a real value uniformly distributed between 0 and 1. The time is in seconds, the angles are in radians, and the angular velocities are in radians/second. 

## Results

In the subfolder for each power-grid network, we have:
- `data_beta_tilde.mat`: Basin results when using `beta==beta_tilde` (homogeneous optimum)
- `data_beta_sa.mat`: Basin results when using `beta==beta_sa` (heterogeneous optimum)

In each file, the results are given as a single `1000x2` matrix, where each row is the result of a run,
and the columns are as follows:
- column 1: `0` if not synchronized, `1` if synchronized (according to the sync criteria)
- column 2: Time at which synchronization was achieved for the first time (according to the sync criteria)
