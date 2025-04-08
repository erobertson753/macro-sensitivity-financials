# Macro-Factor Sensitivity in U.S. Financial Firms

This repository contains code and documentation for a research project that applies the first stage of the Fama-MacBeth two-step asset pricing framework to evaluate macroeconomic factor sensitivities across 316 publicly traded U.S. financial and banking firms.

## Project Objective

To identify which financial firms are most resilient to the prevailing macroeconomic environment—characterized by inflationary pressure, widening credit spreads, and a weakening growth outlook (April 2025) by estimating and interpreting firm-level betas to key macro factors.

## Methodology

- **Data Period:** Q1 2001 – Q1 2025  
- **Sample:** U.S. firms with SIC codes 6000–6300  
- **Returns:** Quarterly CRSP firm returns  
- **Factors:**  
  - Inflation (CPI YoY)  
  - Credit spreads (BAA–AAA)  
  - GDP growth (YoY)  
  - Firm controls: Leverage, ROE, MTB

Each firm’s return series was regressed independently using standardized variables. Missing data was interpolated using spline methods (`zoo::na.spline` in R).

## Scoring Model

The following scoring function was developed to assess firm-level macro resilience:

Score = -0.6 × (CPI beta) -0.4 × (Credit Spread beta) +0.5 × (GDP Growth beta)

Only statistically significant betas (p < 0.05) were used.

## Repository Structure
data_analysis.R # Core regression modeling and diagnostics 
scoring.R # Scoring logic and ranking
clean_data.R # Primary data cleaning pipeline
clean_data_2.R # Supplemental cleaning scripts
wrds.R # WRDS query and return calculations
fred_data.py # FRED API data ingestion (Python)
data # A folder containing relevant data files
README.md # This document

## Key Findings

- **Top Resilient Firms:** FRME, CPF, LARK  
- **High-Risk Firms:** VEL, HLI, GAIN  
- Firms with large positive CPI and credit spread betas are most vulnerable under current macro conditions.

## Future Work

- Implement Stage 2 of the Fama-MacBeth regression  
- Expand the model to other sectors (e.g., technology, industrials)  
- Deploy dynamic updating for real-time screening

## Author

**Ethan W. Robertson**  
B.S. Computational & Applied Mathematics and Statistics  
College of William & Mary  
[Portfolio](#) • [LinkedIn](#) • [Email](#)

---

*This project was developed as part of a macro-financial research initiative during the Spring of 2025.*
