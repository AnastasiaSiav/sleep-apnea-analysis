# Sleep Apnea Data Analysis (R)

Statistical analysis of data from a sleep study of patients suspected of having obstructive sleep apnea.
The goal is to find which factors are associated with the **percentage of REM sleep**.
University project for the course *Data Analysis*.

## Data

106 patients, 9 variables (source: Ahmadi et al., 2008, *Sleep and Breathing*, 12, 39–45):

| Variable | Description |
|---|---|
| `age` | Age |
| `gender` | 1 = female, 0 = male |
| `BMI` | Body mass index |
| `necksize` | Neck circumference (cm) |
| `sbp` | Systolic blood pressure (mmHg) |
| `alcohol` | Alcohol use (1 = yes, 0 = no) |
| `caffeine` | Caffeine use (1 = yes, 0 = no) |
| `REM` | Proportion of sleep time in REM |
| `AI` | Arousal index (awakenings per hour of sleep) |

The data file is not included in this repository.

## Methods

- Descriptive statistics, histograms, bar plots and the Shapiro–Wilk normality test
- Pearson and Spearman correlations, Welch t-tests and Wilcoxon tests
- Chi-square and Fisher tests for the categorical variables
- Subgroup analysis by neck size (split at the median, 37.5 cm)
- Multiple linear regression with assumption checks (residual plots, Shapiro–Wilk, Breusch–Pagan, VIF) and stepwise AIC selection

## Key findings

- **Arousal index (AI)** is the strongest factor: more awakenings per hour go with less REM sleep (r = −0.28, p = 0.003). The relationship holds in both neck size groups.
- **Age** is also negatively correlated with REM (r = −0.23, p = 0.018).
- **Alcohol** use is borderline (mean REM 0.110 vs 0.145, p ≈ 0.06).
- **Caffeine** (p = 0.82) and **systolic blood pressure** (p = 0.10) show no significant relationship with REM.
- Patients with a **large neck** have clearly higher BMI, are more often male and tend to have a higher AI, but their REM sleep does not differ from patients with a small neck (p = 0.71).
- The stepwise AIC model keeps **age, neck size, alcohol and AI**. Only AI is significant (p = 0.006), and the model explains a small part of the variation in REM (adjusted R² ≈ 0.11). The model assumptions hold (Shapiro–Wilk p = 0.90, Breusch–Pagan p = 0.44).

## How to run

1. Install the packages: `install.packages(c("psych", "car", "lmtest", "sjPlot"))`
2. Put the data file at `data/04_sleep.csv`, relative to the project folder.
3. Open `sleep_analysis.R` in RStudio, set the working directory to the project folder, and run the script.
