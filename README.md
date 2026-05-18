# Mathematical Modeling Portfolio Optimization with CAPM

## Overview

This project develops a portfolio optimization framework based on the Capital Asset Pricing Model (CAPM) using mixed-integer goal programming techniques. The objective was to construct realistic portfolios that balance expected return and systematic risk while incorporating practical investment constraints commonly faced in institutional portfolio management.

The framework combines financial modeling, optimization theory, and computational implementation to analyze how varying investor preferences and target constraints influence portfolio selection and efficient frontier behavior.

The optimization model was implemented in SAS using PROC OPTMODEL, while Python was used for financial data collection and preprocessing through the Yahoo Finance API.

---

# Research Objective

The primary objective of this project was to:

- Optimize portfolio allocation under CAPM assumptions
- Analyze the trade-off between expected return and systematic risk
- Incorporate realistic portfolio construction constraints
- Generate efficient frontiers under different investor preference scenarios
- Evaluate how practical constraints influence feasible portfolio solutions

The project integrates concepts from:

- Portfolio optimization
- Capital Asset Pricing Model (CAPM)
- Goal programming
- Mixed-integer optimization
- Financial engineering
- Operations research

---

# Asset Universe

The portfolio universe consisted of:

- 20 individual equities
- 5 bond ETFs
- 1 risk-free asset

The assets were selected to provide exposure across:

- technology
- financials
- healthcare
- energy
- industrials
- fixed income

Bond ETFs included exposure to:

- U.S. Treasuries
- investment-grade bonds
- high-yield bonds
- inflation-protected securities
- emerging market debt

The risk-free asset was represented using a 3-month U.S. Treasury bill proxy.

---

# Portfolio Optimization Framework

The optimization problem was formulated as a mixed-integer goal programming model.

## Objective Function

The model minimizes undesirable deviations from target return and target beta levels.

```math
\min Z = w_R d_R^- + w_\beta d_\beta^+
```

Where:

- `w_R` = weight assigned to return deviation
- `w_β` = weight assigned to beta deviation
- `d_R^-` = underachievement of target return
- `d_β^+` = excess portfolio beta above target

---

# CAPM Risk Framework

Portfolio systematic risk is measured using CAPM beta.

## Portfolio Return Constraint

```math
\sum_{i=1}^{25} r_i x_i + r_f x_f + d_R^- - d_R^+ = R_0
```

---

## Portfolio Beta Constraint

```math
\sum_{i=1}^{25} \beta_i x_i + d_\beta^- - d_\beta^+ = \beta_0
```

Where:

- `r_i` = expected return of asset `i`
- `β_i` = CAPM beta of asset `i`
- `x_i` = capital allocated to asset `i`
- `R_0` = target portfolio return
- `β_0` = target portfolio beta

---

# Investment Constraints

The framework incorporated realistic investment constraints commonly used in institutional portfolio construction.

## Budget Constraint

```math
\sum_{i=1}^{25} x_i + x_f = B
```

Total portfolio allocation must equal the available investment budget.

---

## Diversification Constraint

```math
x_i \leq 0.10B
```

No single asset could exceed 10% of the portfolio.

---

## Bond Allocation Constraint

```math
\sum_{i \in Bonds} x_i \geq 0.20B
```

At least 20% of the portfolio must be allocated to bonds.

---

## Cardinality Constraint

```math
\sum_{i=1}^{25} y_i \leq K
```

The portfolio was limited to a maximum number of selected assets.

---

# Methodology

The workflow consisted of:

1. Financial data collection using Python and Yahoo Finance API  
2. Data preprocessing and parameter construction  
3. CAPM beta estimation  
4. Goal programming formulation  
5. Mixed-integer optimization implementation in SAS  
6. Efficient frontier generation  
7. Scenario and sensitivity analysis  

---

# Computational Implementation

## Python Workflow

Python was used for:

- financial data collection
- preprocessing
- return calculations
- beta estimation
- dataset preparation

The processed datasets were exported for optimization analysis in SAS.

---

## SAS Optimization

The optimization framework was implemented using:

- SAS PROC OPTMODEL
- mixed-integer linear programming (MILP)
- branch-and-bound optimization

The solver incorporated:

- presolve reductions
- binary asset-selection variables
- iterative re-optimization across preference scenarios

---

# Efficient Frontier Analysis

The project generated efficient frontiers by repeatedly solving the optimization problem under varying:

- target return levels
- target beta levels
- investor preference weights

Three primary regimes emerged:

## Risk-Averse Regime
- high allocation to risk-free assets
- low beta exposure
- conservative portfolio structure

## Transition Regime
- increased risky asset exposure
- moderate return and beta growth
- gradual diversification changes

## Return-Seeking Regime
- stable dominant portfolios
- higher systematic risk exposure
- reduced risk-free allocation

---

# Key Findings

- Efficient frontiers exhibited discrete piecewise behavior due to integer constraints
- Practical investment constraints significantly restricted feasible solutions
- Multiple investor preference combinations converged to identical portfolios
- Portfolio stability regions emerged under binding diversification constraints
- Cardinality restrictions materially affected portfolio flexibility

---

# Key Insights

- Real-world investment constraints strongly influence portfolio optimization outcomes
- Goal programming provides flexibility for balancing competing objectives
- Mixed-integer constraints create non-smooth efficient frontiers
- Portfolio solutions often stabilize once dominant feasible allocations emerge

---

# Technology Stack

- Python
- Yahoo Finance API
- Pandas
- NumPy
- SAS
- SAS PROC OPTMODEL
- Excel
- File I/O

---

# References

- Markowitz, Harry. *Portfolio Selection.*

- Sharpe, William F. *Capital Asset Prices: A Theory of Market Equilibrium under Conditions of Risk.*

- Black, Fischer, and Robert Litterman. *Global Portfolio Optimization.*

- Fama, Eugene F., and Kenneth R. French. *Common Risk Factors in the Returns on Stocks and Bonds.*

- Charnes, Cooper, and Ferguson. *Optimal Estimation of Executive Compensation by Linear Programming.*

- Tobin, James. *Liquidity Preference as Behavior Towards Risk.*
