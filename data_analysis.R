rm(list=ls())
library(dplyr)
library(tidyr)
library(purrr)
library(plm)
library(broom)
data <- read.csv("data/data_final.csv")

data <- data %>%
  mutate(
    date = as.Date(date),
    leverage = assets / equity,
    roe = net_income / equity,
    mtb = market_cap / book_value,
    market_excess = quarterly_return - risk_free_rate
  )
length(unique(data$tic))
summary(data)

ts_data <- data %>%
  filter(!is.na(quarterly_return), !is.na(leverage), !is.na(roe), !is.na(mtb)) %>%
  select(tic, date, quarterly_return, leverage, roe, mtb, credit_spread, gdp_growth, cpi)

ts_data[,-(1:2)] <- scale(ts_data[,-(1:2)])

firm_betas <- ts_data %>%
  group_by(tic) %>%
  group_map(~ {
    if (nrow(.x) < 24) return(NULL)
    model <- lm(quarterly_return ~ leverage + roe + mtb + credit_spread + gdp_growth + cpi, data = .x)
    tibble(tic = .y$tic, broom::tidy(model))
  }) %>%
  bind_rows()

head(firm_betas)


betas_wide <- firm_betas %>%
  select(tic, term, estimate) %>%
  pivot_wider(names_from = term, values_from = estimate)

pvals_wide <- firm_betas %>%
  select(tic, term, p.value) %>%
  pivot_wider(names_from = term, values_from = p.value, names_prefix = "p_")


summary_wide <- left_join(betas_wide, pvals_wide, by = "tic")

write.csv(summary_wide, "data/results.csv", row.names = F)

research <- summary_wide %>%
  filter(leverage < 0, credit_spread < 0, p_credit_spread < 0.05) %>%
  arrange(cpi)
write.csv(research, "data/research.csv", row.names = F)
