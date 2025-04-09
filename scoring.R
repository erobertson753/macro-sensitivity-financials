rm(list=ls())
library(reshape2)
library(ggplot2)

df <- read.csv("data/research.csv")

scored <- df %>%
  mutate(
    inflation_risk = cpi * (p_cpi < 0.05),
    credit_risk = credit_spread * (p_credit_spread < 0.05),
    growth_exposure = gdp_growth * (p_gdp_growth < 0.05),
    total_score = -0.6 * inflation_risk - 0.4 * credit_risk + 0.5 * growth_exposure
  ) %>%
  arrange(desc(total_score))
head(scored)

scored <- df %>%
  filter(
    p_cpi < 0.1,
    p_credit_spread < 0.1,
    p_gdp_growth < 0.1
  ) %>%
  mutate(
    inflation_risk = cpi,
    credit_risk = credit_spread,
    growth_exposure = gdp_growth,
    total_score = -0.6 * inflation_risk - 0.4 * credit_risk + 0.5 * growth_exposure
  ) %>%
  arrange(desc(total_score))

head(scored)



write.csv(scored, "data/rankings_final.csv", row.names = F)
