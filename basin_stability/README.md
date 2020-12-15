# Calculation of attraction basin

This folder contains the results of computing basin stability for each system in the paper.
Specifically, the contents of Fig. 4c are provided here.

## Data

For each power-grid network we have
- `dynamics.mat`: The dynamical parameters for the Swing equation
- `data_beta_tilde.mat`: Basin results when using `beta==beta_tilde` (uniform optimum)
- `data_beta_sa.mat`: Basin results when using `beta==beta_sa` (global heterogeneous optimum)

## Code

The core of the code is shown below. In each run, the swing equation is integrated over time with the function `integrate()` (which calls `rhs(x, y, t)` to compute the right hand side of the equation), while checking if synchronization is achieved with `check_sync(x, y)`. `integrate()` uses `rk45_step(rhs, x, y, t)`, a 4th-order Runge-Kutta integrator with adaptive time stepping.

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
where the variables are the following, with the index indicating the generator:
- `x[i]`: rotor angle
- `y[i]`: rotor angular velocity
- `t`: time
- `beta[i]`: combined damping coefficient
- `H[i]`: inertia coefficient
- `Pg[i]`: power generated
- `E[i]`: internal voltage magnitude 
- `Ymag[i,k]`: magnitude of complex admittance between `i` and `k`
- `Yang[i,k]`: angle of complex admittance between `i` and `k`
- `delta_star[i]`: steady-state rotor angle
- `dxdt[i]`: the r.h.s. for the angle
- `dydt[i]`: the r.h.s. for the velocity
- `random()`: uniform random real value between 0 and 1
- `tmax`: maximum integrated time


All values are per unit, angles are radians, angular velocity is radians/second, and time is seconds.

## Results

The results are given in a single `1000x2` matrix, where each row is the result of a run,
and the columns are as follows:
- column 1: `0` if not synchronized, `1` if synchronized (according to the sync criteria)
- column 2: time when synchronization was achieved (according to the sync criteria)
