rm(list=ls())
library(RPostgres)
library(tidyverse)
library(lubridate)
library(zoo)

df <- read.csv("data/data.csv")


df <- df %>%
  mutate(total_liabilities = assets - equity) %>%
  mutate(date = as.Date(date))

df <- df[!is.na(df$gvkey), ]
df$interest_income <- NULL
df$interest.expense <- NULL

colSums(is.na(df)) / nrow(df)

market_cap_na_by_firm <- df %>%
  filter(is.na(market_cap)) %>%
  group_by(gvkey, tic) %>%
  summarise(missing_count = n()) %>%
  arrange(desc(missing_count))

gvkeys_to_drop <- market_cap_na_by_firm %>%
  filter(missing_count >= 90) %>%
  pull(gvkey)

data_c <- df %>%
  filter(!(gvkey %in% gvkeys_to_drop))

data_c <- data_c %>%
  group_by(gvkey) %>%
  arrange(gvkey, date) %>%
  mutate(market_cap = zoo::na.approx(market_cap, x = date, na.rm = FALSE)) %>%
  ungroup()

data_c <- data_c %>%
  group_by(gvkey) %>%
  arrange(gvkey, date) %>% 
  fill(market_cap, .direction = "downup") %>%
  ungroup()


data_clean <- drop_na(data_c)
summary(data_clean)
length(unique(data_clean$date))

returns <- read.csv("data/returns.csv")
returns$RET <- as.numeric(returns$RET)


returns <- returns %>%
  transmute(date = as.Date(date), tic = TICKER, return = RET)

quarterly_returns <- returns %>%
  mutate(
    quarter = floor_date(date, unit = "quarter") - days(1)
  ) %>%
  group_by(tic, quarter) %>%
  summarise(
    quarterly_return = prod(1 + return) - 1,
    .groups = "drop"
  )

quarterly_returns <- data.frame(quarterly_returns)
quarterly_returns <- quarterly_returns %>%
  mutate(date = quarter) %>%
  select(tic, quarterly_return, date)


data_clean <- merge(data_clean, quarterly_returns[, c("date", "tic", "quarterly_return")], by = c("date", "tic"), all.x = TRUE)
summary(data_clean)


return_na_by_firm <- data_clean %>%
  filter(is.na(quarterly_return)) %>%
  group_by(gvkey, tic) %>%
  summarise(missing_count = n()) %>%
  arrange(desc(missing_count))
head(return_na_by_firm, 10)

gvkeys_to_drop <- return_na_by_firm %>%
  filter(missing_count >= 70) %>%
  pull(gvkey)

data_clean <- data_clean %>%
  filter(!(gvkey %in% gvkeys_to_drop))

data_clean <- data_clean %>%
  group_by(gvkey) %>%
  arrange(gvkey, date) %>% 
  fill(quarterly_return, .direction = "downup") %>%
  ungroup()
sp500 <- read.csv("data/sp500.csv")

head(sp500)

date_df <- data.frame(
  date = seq(from = as.Date("2001-01-01"), to = as.Date("2025-01-31"), by = "day")
)


sp500 <- sp500 %>%
  transmute(date = mdy(as.character(Date)), sp_price = Open)

sp500 <- left_join(date_df, sp500, by = "date")
sp500 <- sp500 %>% 
  mutate(sp_price = zoo::na.spline(sp_price))

dates <- data.frame(unique(data_clean$date))
colnames(dates) <- "date"

sp500 <- left_join(dates, sp500, by = "date")

sp500$sp_returns <- c(NA, diff(sp500$sp_price) / head(sp500$sp_price, -1))

data_clean <- left_join(data_clean, sp500, by = "date")

data_clean <- drop_na(data_clean)
summary(data_clean)

write.csv(data_clean, "data/data_final.csv", row.names = F)


summary(data_clean)

cade_returns <- subset(data_clean, tic == "CADE", select = quarterly_return)
summary(cade_returns)
