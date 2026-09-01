# R-trading-pairs-backtest
A statistical arbitrage model built in R backtesting a pairs trading strategy (BHP and RIO for this model). Uses linear regression and a rolling Z-score to capture deviations from the mean and revert price spreads from 2007.

---

## Strategy Overview
* Asset pair: BHP.AX and RIO.AX, using their daily close from yahoo finance.
* Backtest scope: 2007 to present.
* Strategy logic: When rolling Z-score is greater than 2 BHP is overpriced (Short BHP Long RIO), when rolling Z-score is smaller than -2 BHP is underpriced (Long BHP Short RIO).

---

## Mathematical aspect

1. **Hedge Ratio ($\beta$):** Estimated using Ordinary Least Squares (OLS) regression over historical closing prices:
   $$\text{BHP}_t = \beta_0 + \beta_1 \cdot \text{RIO}_t + \epsilon_t$$
2. **Residual Spread Calculation:**
   Using residuals function of linear model in R
3. **Dynamic Signal (Rolling $Z$-Score):** Evaluated over a 60-day rolling window to change based on market shifts:
   $$Z_t = \frac{S_t - \mu_{t, 60}}{\sigma_{t, 60}}$$
4. **Execution Rules:**
   * **Short Spread ($Z_t > +2.0$):** Short 1 dollar of BHP, Long $\beta$ of RIO.
   * **Long Spread ($Z_t < -2.0$):** Long 1 dollar of BHP, Short $\beta$ of RIO.
   * **Mean Reversion Exit ($|Z_t| < 0.2$):** Close active positions.
   * **Execution Lag:** Signals generated at $t$ are executed at $t+1$ to ensure realistic backtesting execution.

---

## Performance Highlights

* **Total Cumulative Growth:** Turned $1.00 base capital into **~$8.00+** across the backtest period (19 years), which is a 700% return or 11.57% per year beating the S&P500.
* **Risk Management:** Market-neutral design buffers against broad equity market crashes (it was able to maintain stability during 2008 GFC & 2020 market shifts with no large drops in growth).

<img width="865" height="542" alt="image" src="https://github.com/user-attachments/assets/0465b845-6de0-4ca6-98eb-d1e11e317a73" />

---

## Stack & R Packages
* **Language:** R
* **Time Series & Data:** `quantmod`, `zoo`, `urca`
* **Statistical Modeling:** `statsmodels` / Base R (`lm`, `rollapply`)
