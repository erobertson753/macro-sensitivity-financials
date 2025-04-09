rm(list=ls())
library(RPostgres)
library(tidyverse)
library(lubridate)
library(zoo)

m_factors <- read.csv("data/macro_factors.csv", header = T)

names(m_factors)[names(m_factors) == 'X'] <- 'date'
summary(m_factors)

m_factors <- m_factors %>% 
  mutate(date = as.Date(date))
summary(m_factors)

m_factors <- m_factors %>%
  arrange(date) %>%
  filter(date >= "1986-01-31") %>%#Constrain observations to where there are minimal NAs
  filter(date <= "2025-02-28") %>% #No CPI or 10 Yr spread data after this date
  mutate(gdp_growth = zoo::na.spline(gdp_growth)) #Interpolate quarterly GDP growth to monthly
summary(m_factors)
#m_factors[,-1] <- scale(m_factors[,-1])
summary(m_factors)
colnames(m_factors)


b_data <- read.csv("data/bank_data.csv", header = T, stringsAsFactors = T)
b_data <- arrange(b_data, desc(market_cap))
head(b_data)

s_data <- read.csv("data/sectors.csv")

s_data <- s_data %>%
  distinct(TICKER, .keep_all = TRUE) %>%
  transmute(tic = TICKER, sector = SICCD)



head(b_data$tic)
length(unique(s_data$tic))
merged <- left_join(b_data, s_data, by = "tic")

merged <- arrange(merged, desc(market_cap))
head(merged)

unique_tickers <- merged %>%
  select(tic, sector) %>%
  distinct()

financials <- unique_tickers %>%
  filter(sector >= 6000 & sector < 6300) %>%
  mutate(joined = T)

data_small <- merged %>%
  left_join(financials, by = c("tic", "sector"), suffix = c("", "_fin")) 
head(data_small)


data_small <- data_small %>%
  filter(!is.na(joined)) %>%
  select(-joined)

data_small %>% distinct(tic) %>% count()

write.csv(data_small, "data/financials_data.csv", row.names = F)

data_small <- arrange(data_small, by = market_cap)
data_small <- data_small %>%
  mutate(date = as.Date(date))
summary(data_small)
head(data_small)


data <- left_join(m_factors, data_small, by = "date")
summary(data)

print(paste0(round((length(data$gvkey) - sum(is.na(data$gvkey))) / length(data$gvkey) * 100, 1), "% of observations matched"))

length(unique(data$date))/12

data_n <- data
summary(data_n)

write.csv(data_n, "data/data.csv", row.names = F)
                        