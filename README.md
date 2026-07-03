# Tax Competition Game — Game Theory Seminar Project

An agent-based simulation (built in **NetLogo**) modeling **tax competition between regions**, inspired by the Prisoner's Dilemma. Regions choose between high and low tax rates to attract firms and capital, and the model explores how this choice evolves over time through an adaptive learning mechanism, firm migration, and public service quality.

Statistical analysis of simulation results (correlation and linear regression) was performed in **R**.

Created as part of the Game Theory course in the final semester of my bachelor’s studies.

## Table of Contents
- [Background](#background)
- [The Game](#the-game)
- [Nash Equilibrium](#nash-equilibrium)
- [Model](#model)
  - [Basic Version](#basic-version)
  - [Enhanced Version](#enhanced-version)
- [Simulation Parameters](#simulation-parameters)
- [Key Findings](#key-findings)
- [Requirements](#requirements)
- [How to Run](#how-to-run)

## Background

Tax competition describes how regions (cities, states, countries) adjust their tax rates to attract firms, capital, and labor from one another. A region faces a trade-off:

- **High tax rate (H):** higher public revenue per firm, but risks losing firms to regions with more favorable tax conditions.
- **Low tax rate (L):** attracts more firms, but generates lower revenue per firm.

## The Game

Two regions play a simultaneous game with strategies **H** (high tax) and **L** (low tax), based on the classic Prisoner's Dilemma structure (T > R > P > S):

|       | H    | L    |
|-------|------|------|
| **H** | 5, 5 | 2, 8 |
| **L** | 8, 2 | 4, 4 |

## Nash Equilibrium

Working through best responses for each strategy combination shows that both players have an incentive to deviate from **[H, H]**, **[H, L]**, and **[L, H]** — but not from **[L, L]**. 

**The unique Nash Equilibrium is [L, L]:** both regions choose low tax rates to attract firms and capital, even though mutual cooperation on high taxes (H, H) would yield a higher joint payoff.

## Model

### Basic Version

- User-configurable number of players (regions) via slider
- User-configurable payoff values
- Strategies chosen **randomly** (no control over the proportion of V/N)
- No learning mechanism
- A `wealth` variable tracks each region's cumulative payoff
- Regions are color-coded by their chosen strategy

### Enhanced Version

The core `play` procedure is unchanged, but we added several new mechanics:

**Tax rates:** Each region gets an actual tax rate based on its strategy — regions with strategy L get a random rate between 0% – 15%, regions with strategy H between 16% – 35%. The initial share of L vs. H regions is now user-controlled via a slider.

**Companies (`companies`):** Number of firms per region, set by the user (slider range 1 – 50). The count is fixed at the start and doesn't change per region regardless of strategy.

**Public services (`public-services`):** Starts at 10 for every region and evolves each round:

```
PS = PS + sqrt(TR × C × 0.001)
```
where `TR` = tax rate, `C` = number of firms, and `PS` = public services.

Public services also decay each round: **1%** for H regions, **2%** for L regions (representing the cost of maintaining services with lower tax income).

**Learning mechanism:** Each round, a region's probability of switching strategy is:

```
P = (average payoff − region's payoff) / (T − S)
```
where `T` and `S` are the highest and lowest payoffs in the matrix. This is then reduced by a **resistance** term for regions that are already prospering (many firms, good public services):

```
resistance = 0.5 × (C / max C) + 0.5 × (PS / max PS)
```

A region only considers changing strategy if:
1. The payoff range is non-zero (avoids division by zero, and there's no reason to switch if all payoffs are equal),
2. Its payoff is below average,
3. It lags behind other regions in firm count and public service quality.

A random draw then determines whether the switch actually happens — the learning process is **stochastic, not deterministic**, so underperforming regions don't always switch immediately (or at all).

**Firm migration (`inflow-rate`):** Each region is paired with a rival region each round. Firms don't move purely based on tax rates — public service quality also plays a role, via a *retention* value:

```
retention = PS × retention-strength
```
where `retention-strength` (0.05 – 1) is user-configurable. The effective tax rate difference between the two regions is then adjusted:

```
adjusted TR difference = TR difference − rival's retention + own retention
```

A region attracts firms if it's more attractive overall (lower taxes and/or better public services). The rate of firm inflow is controlled by a user-configurable sensitivity parameter, `inflow-rate`. This mechanic gives higher-tax regions a fighting chance against the pure race-to-the-bottom predicted by the Nash Equilibrium, since good public services can offset a tax disadvantage.

## Simulation Parameters

The following parameters were varied across simulation runs (via NetLogo BehaviorSpace):

| Parameter               | Values tested     |
|--------------------------|-------------------|
| `retention-strength`     | 0.3, 0.6          |
| `initial-H`               | 30, 50, 75        |
| `inflow-rate`    | 5, 10, 20         |
| `N` (number of regions)  | 70, 150           |

## Key Findings

**Correlation analysis** (against `countH`, the final number of regions with strategy H):
- `inflow-rate` had the strongest relationship (r ≈ −0.62): faster firm migration strongly reduces the survival of the high-tax strategy.
- `initial-H` and `N` showed weak positive correlations (r ≈ 0.21 – 0.22).
- `retention-strength` showed essentially no correlation with the outcome.

**Linear regression** (`countH ~ initial-H + inflow-rate + N + retention-strength`), R² ≈ 0.475:
- `initial-H` (Estimate ≈ 0.15, significant): starting conditions matter — more initial H-players leads to more surviving H-players.
- `inflow-rate` (Estimate ≈ −1.29, highly significant): faster firm mobility strongly destabilizes the high-tax strategy.
- `N` (Estimate ≈ 0.07, significant): more regions slightly favor the survival of strategy H, possibly due to increased strategic diversity.
- `retention-strength` was **not** statistically significant in this model.

*(Note: correlation does not imply causation.)*

## Requirements

- [NetLogo](https://ccl.northwestern.edu/netlogo/) (developed on version 7.0)
- [R](https://www.r-project.org/) for the statistical analysis (base R functions: `cor`, `lm`, `boxplot`)

## How to Run

1. Open the `.nlogo` model file in NetLogo.
2. Adjust sliders for the parameters of interest (`initial-H`, `companies`, `retention-strength`, etc.).
3. Click **setup**, then **go** to run the simulation.
4. To reproduce the parameter sweep, use NetLogo's **BehaviorSpace** with the parameter values listed above, and export results to CSV.
5. Run the R script against the exported CSV to reproduce the correlation and regression analysis.

