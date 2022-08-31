## Prenatal Exposure to SARS and Birth Weight: Exploiting a Natural Experiment in Hong Kong

#### Research Statement 

- By exploiting SARS as an exogenous source of stress, this paper examines whether prenatal maternal exposure to such stress affects birth weight with the applicatin of OLS/ANOVA, Propensity Score Matching, and Bootstrapping.

#### Outline

- Introduction
- Background
  - SARS as a Public Health Crisis
  - Maternal Stress as Mechanisms
  - SARS as Exogenous Sources of Maternal Stress
- Literature Review
- Methods
  - Data
  - Variables
  - Models
    - Treat SARS as a Experiment (randomized)
      - OLS/ANOVA
    - Treat SARS as a Quasi-Experiment (non-randomized)
      - Propensity Score Matching
      - OLS/ANOVA
      - Bootstrapping
- Results
  - $Y_i = \alpha + \beta\space T + e_i$ where $\beta = E(Y_i^T - Y_i^C)$ is the Average Treatment Effect (ATE) 
- Discussion and Conclusion

#### PDF Preview

https://github.com/mingzhao1103/Stata_SARS/blob/main/report.pdf

*NOTE*

Difference-in-Differences (DID)
$Y = \beta_0 + \beta_1 \space Treat + \beta_2 \space Time + \beta_3 \space (Treat*Time) + e_i$

$\beta_3$ captures $DID$: the pure effects of treatment
$DID = (treatment_after - treatment_before) - (control_after - control_before)$
The assumption is that in the absense of any treatment, both treatment group and the control group would have followed parallel trends over time



