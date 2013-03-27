# GPEDA - Gaussian Process sampling EDA algorithm (name subject to change )

GPEDA is a popullaiton based optimization heuristic combining ideas of Efficient Global Optimization 
algorithm by Jones et. al and the estimation of distribution algorithms. More details will be added 
to this readme later on.

# Using the package

To use functions from the package you first need to run the startup script with

```matlab
run src/startup.m
```

This also initializes the GPML package.

## Running an optimization

GPEDA is a popullaiton based optimization heuristic. On a very high level it works by randomly 
(but inteligently) generating groups of solution candidates (or individuals) called generations, 
evolving the solution.

To run an optimization, you only need to call the `gpeda` function once, with the right
set of parameters. An example optimization could look like the following example

```matlab
opts.popSize = 10;
opts.lowerBound = -5;
opts.upperBound = 5;

opts.eval.handle = @(x) ( sum(x.^2, 2) );
opts.doe.n = 20; % initial dataset
opts.sampler.target = 0.001; % testing on x^2, we know the target
opts.stop.evaluations = 100;

[xopt run] = gpeda(opts, @evalHandle, @doeRandom, @sampleGibbs, [], @stopNEvals);
```

First we set some general options: the number of individuals in each generation `popSize` and bounds of the
randomly generated solutions (limits in each coordinate dimensions, other types of constraints are not implemented).

Then we set options for individual pieces of the optimizer and start the optimizer by calling the main function. The 
options struct contains a field for each of the pieces named the same as the respective parameter to `gpeda`.

In this example, as an evaluator, we will use `@evalHandle`, which evaluates a solution by passing it to a provided 
function handle. As an initial dataset generator (or design of experiment) we'll use `@doeRandom`, uniformly 
distributed random dataset. For sampling (i.e. generating new population based on the dataset), we're using 
the Monte-Carlo sampler (which will soon be surpassed by much more efficient Gibbs sampler).

The last two options are restart and stop conditions. The optimization starts a first attempt and runs as long as restart
conditions are false. Then a new attempt is started. This loop continues as long as stop conditions aren't met. Both 
stop and restart condition functions get the current run structure as a parameter.

## Multiple samplers or conditions

This example uses a single function for sampling, restart and stop conditions. In reality, we would use multiple functions
at least for the stop conditions (stopping based just on number of function evaluations isn't really what we want).

You would pass multiple functions in as a cell array containing function handles. The respective field in the options 
struct should also contain a cell array containing option structs for each individual function.

For samplers, the results of all the functions are concatenated. For conditions an or operation is performed, i.e. it is 
enough for just one condition to be true to restart/stop the optimization.

# Moving parts

As shown in the example above, the method uses a handful of parts to acomplish the goal. Each part is a function called
either by you directly or by the optimization loop. The only exception is a model, which holds too much state and is 
therefore passed around as a structure.

## Model

The Gaussian Process model is the key part of the whole system. It is used to generalize information from the dataset
and direct the optimization to the optimum. There are four key parts of working with the model:

1.  Intialization
2.  Training 
3.  Prediction
4.  probabilty of improvement estimation

Typical work with the model could look like this

```matlab
M = modelInit(1);
x = doeRandom(-5, 5, struct('n', 20));
y = x.^2;

plot(x, y, 'o');

M = modelTrain(M, x, y);

z = linspace(-5, 5, 101)';
[m s2] = modelPredict(M, z);

plotErr1(z, m, s2, x, y);
```

First we initialize the model using `modelInit(1)`. Returned model has input dimension `1` and default structure 
(mean, covariance, likelihood and inference functions). Next, we generate random data and evaluate them using a simple
quadratic function. Using `modelTrain(M, x, y)` we then train a model on the data, make predictions for a vector `z` using
`[m s2] = modelPredict(M, z)` and plot the resulting Gaussian Process with the `plotErr1` helper function. `m` and `s2` 
will be prediction mean and error estimate for each input from the vector `z`.

Based on the prediction and error estimate, we can next compute the probabilty of improvement for each input from `z` using
the `modelGetPOI` function and plot it like so:

```matlab
poi = modelGetPOI(M, z, -1.3);

hold on;
plot(z, poi, 'g-');
plot([-5 5], [0 0], 'k-');
plot([-5 5], [-1.3 -1.3], 'k--');
```

The probability of improvement is normally used by the sampler to get new population based on the model.

## Sampler

If you wanted to use the sampler manually, you would call one of the functions starting with `sample`. Currently the
fastest method is the Gibbs sampler (`sampleGibbs`). You'd get a new population as follows:

```matlab
nsamp = 20;
opts.target = 0;

population = sampleGibbs(M, -5, 5, nsamp, opts);
```

First set the number of samples and the target function value desired (used for PoI estimate), then call the function
to get back a `n` by `dim` matrix of the generated inputs.

## Design of experiment

To start the optimization, we need an initial model, based on an initial dataset. That dataset is either known or can
be generated by a design of expermient function. 

Currently only a uniformly distributed random DoE is implemented in the `doeRandom` function.

## Evaluator

To evaluate generated solution candidates and obtain new information about the optimized function, the optimizer uses
one of the evaluators. Evaluators share a common interface for different strategies of evaluation one could need.

Currently only an online function handle evaluator `evalHandle` is implemented.

## Restart/Stop conditions

For the optimization to end, there have to be some stopping conditions, e.g. optimum was reached, no further improvement
was made, evaluation budget was reached, etc... Some of these situation don't necessarily mean we need to stop 
the optimization altogether, but may tell us it will be better to start over. Thus we distinguish between stop 
conditions and restart conditions. Both functions have the same calling interface though: They get the run 
history structure as a parameter and must return true (i.e. stop now) or false (i.e. continue).

### Optimization run history structure

The run history structure contains the optimization run options and complete course of the optimization upto the current
point. The optimization is performed in attempts, each of which ends by a restart caused by one of the restart conditions
being met. The whole run ends when one of the stop conditions is met.

The structure contains the following fields

  options     - (struct) the global options gpeda was originally called with
  attempt     - (integer) current optimization attempt
  attempts    - (cell array) attempts history for the whole run
  evaluations - (integer) number of true function evaluations performed so far

The attempts cell array contains individual attempts structure, consisting of the following fields:

  model       - (struct) the model structure
  iterations  - (integer) the number of iterations performed in the current run
  dataset     - (struct) dataset of the current attempet (contains x and y fields)
  populations - (cell array) n-by-D matrices of populations in each iteration, where n is the population size.
  bests       - (struct) best inputs (x field) and outputs (y, m and s2 in yms2 field) for each iteration as
                n-by-D and n-by-3 matrices respectively, where n is the number of improvements made between generations.

# Contributing

For now, contact one of the authors if you want to contribute.

## File structure

The package code itself is located in the `src` directory. The experiment scripts for testing
various pieces or whatever should go into the `exp` directory. 

# Credits

GPEDA was created by Lukáš Bajer and Viktor Charypar from Faculty of Mathematics and Physics (FMP), Charles University in Prague and Faculty of Nuclear Sciences and Physical Engineering, Czech Techincal University in Prague, respectively.

# License
GPEDA is Copyright © 2013 by Lukáš Bajer and Viktor Charypar. It will be relased as a free software once we decide on the license.
