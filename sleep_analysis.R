# =============================================================================
# Sleep apnea data: what affects the percentage of REM sleep?
# Data: 106 patients from a sleep study in Canada (Ahmadi et al., 2008)
# =============================================================================
# Required packages (install once):
# install.packages(c("psych", "car", "lmtest", "sjPlot"))

library(psych)    # describe()
library(car)      # vif()
library(lmtest)   # bptest()
library(sjPlot)   # tab_model()

# The file uses "-" as separator; the first column holds row names
data <- read.csv("data/04_sleep.csv", sep = "-")

quant_vars <- c("age", "BMI", "necksize", "sbp", "REM", "AI")
cat_vars   <- c("gender", "alcohol", "caffeine")

data$gender   <- factor(data$gender,   levels = c(0, 1), labels = c("male", "female"))
data$alcohol  <- factor(data$alcohol,  levels = c(0, 1), labels = c("no", "yes"))
data$caffeine <- factor(data$caffeine, levels = c(0, 1), labels = c("no", "yes"))

str(data)


# -----------------------------------------------------------------------------
# Helper functions (reused in Questions 1-3 for the full sample and subgroups)
# -----------------------------------------------------------------------------

describe_data <- function(df) {
  print(describe(df[, quant_vars])[, c("n", "mean", "sd", "median", "min", "max", "skew", "kurtosis")])
  for (v in cat_vars) {
    cat("\n", v, "\n")
    print(table(df[[v]]))
    print(round(prop.table(table(df[[v]])), 3))
  }
  cat("\nCorrelation matrix (Pearson):\n")
  print(round(cor(df[, quant_vars]), 3))
}

test_rem <- function(df) {
  # Quantitative predictors: Pearson correlation + Spearman as a robustness check
  for (v in c("AI", "sbp", "age", "BMI", "necksize")) {
    p  <- cor.test(df$REM, df[[v]], method = "pearson")
    sp <- cor.test(df$REM, df[[v]], method = "spearman", exact = FALSE)
    cat(sprintf("REM ~ %-8s  r = %6.3f (p = %.4f)   rho = %6.3f (p = %.4f)\n",
                v, p$estimate, p$p.value, sp$estimate, sp$p.value))
  }
  # Binary predictors: Welch t-test + Wilcoxon (Mann-Whitney) as a robustness check
  for (v in cat_vars) {
    tt <- t.test(REM ~ df[[v]], data = df)
    wt <- wilcox.test(REM ~ df[[v]], data = df, exact = FALSE)
    cat(sprintf("REM ~ %-8s  t-test p = %.4f   Wilcoxon p = %.4f\n", v, tt$p.value, wt$p.value))
  }
}


# =============================================================================
# Question 1: Descriptive statistics and relationships
# =============================================================================

describe_data(data)

# Normality of the quantitative variables
sapply(data[, quant_vars], function(x) shapiro.test(x)$p.value)

par(mfrow = c(2, 3))
for (v in quant_vars) hist(data[[v]], main = v, xlab = v, col = "lightblue")
par(mfrow = c(1, 3))
for (v in cat_vars) barplot(prop.table(table(data[[v]])), main = v, col = c("grey70", "steelblue"))
par(mfrow = c(1, 1))

pairs(data[, quant_vars])

# Relationships among the categorical variables
chisq.test(table(data$gender, data$alcohol))
fisher.test(table(data$gender, data$caffeine))


# =============================================================================
# Question 2: Does REM depend on AI, alcohol, caffeine and sbp?
# =============================================================================

test_rem(data)

par(mfrow = c(2, 2))
plot(REM ~ AI,  data = data, main = "REM vs AI");  abline(lm(REM ~ AI,  data = data), col = "red")
plot(REM ~ sbp, data = data, main = "REM vs sbp"); abline(lm(REM ~ sbp, data = data), col = "red")
boxplot(REM ~ alcohol,  data = data, main = "REM by alcohol")
boxplot(REM ~ caffeine, data = data, main = "REM by caffeine")
par(mfrow = c(1, 1))


# =============================================================================
# Question 3: Small vs large neck size (split at the median)
# =============================================================================

neck_median <- median(data$necksize)   # 37.5 cm
data$neck_group <- factor(ifelse(data$necksize < neck_median, "small", "large"),
                          levels = c("small", "large"))
table(data$neck_group)

for (g in levels(data$neck_group)) {
  cat("\n==================== Neck size:", g, "====================\n")
  sub <- data[data$neck_group == g, ]
  describe_data(sub)
  test_rem(sub)
}

# Direct comparisons between the two groups
t.test(REM ~ neck_group, data = data)
t.test(AI  ~ neck_group, data = data)
wilcox.test(AI ~ neck_group, data = data, exact = FALSE)   # AI is strongly skewed
chisq.test(table(data$neck_group, data$gender))
fisher.test(table(data$neck_group, data$alcohol))

boxplot(REM ~ neck_group, data = data, main = "REM by neck size group")


# =============================================================================
# Question 4: Linear model for REM
# =============================================================================

# neck_group is excluded: it is derived from necksize
full_model <- lm(REM ~ age + gender + BMI + necksize + sbp + alcohol + caffeine + AI, data = data)
summary(full_model)
vif(full_model)

# Model assumptions
par(mfrow = c(2, 2))
plot(full_model)
par(mfrow = c(1, 1))
shapiro.test(residuals(full_model))   # H0: residuals are normal
bptest(full_model)                    # H0: residuals are homoscedastic

# Variable selection with stepwise AIC
step_model <- step(full_model, direction = "both")
summary(step_model)

par(mfrow = c(2, 2))
plot(step_model)
par(mfrow = c(1, 1))
shapiro.test(residuals(step_model))
bptest(step_model)

tab_model(full_model, step_model, digits = 4, dv.labels = c("Full model", "Stepwise AIC model"))
