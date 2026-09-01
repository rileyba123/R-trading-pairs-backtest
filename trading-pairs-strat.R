library(quantmod)
library(urca)
library(zoo)
getSymbols("BHP.AX", src="yahoo")
getSymbols("RIO.AX", src="yahoo")

chart_Series(Cl(BHP.AX), name = "BHP.AX vs RIO.AX")
add_TA(Cl(RIO.AX), on = 1, col = "blue", lty = 2)

closing_prices <- merge(Cl(BHP.AX), Cl(RIO.AX))
closing_prices <- na.omit(closing_prices)
summary(closing_prices)

model <- lm(BHP.AX.Close ~ RIO.AX.Close, data = closing_prices)
summary(model)
plot(model)
# coefficant is 0.271663 meaning that every bhp is 0.271663 rio this is useful later
spread <- residuals(model)

plot(spread, type = "l", main = "BHP vs RIO Spread (Residuals)", col = "darkgreen", ylab = "Spread ($)")
abline(h = mean(spread, na.rm = TRUE), col = "red", lty = 2)

adf_test <- ur.df(spread, type = "none", selectlags = "AIC")
summary(adf_test)

#make a 60 day window for now could change later
window <- 60

rolling_mean <- rollapply(spread, width = window, FUN = mean, align = 'right', fill = NA)
rolling_sd <- rollapply(spread, width = window, FUN = sd, align = 'right', fill = NA)
z_score <- (spread - rolling_mean) / rolling_sd

plot(z_score, main = "BHP vs RIO Rolling Z-score (60 day window)", col="darkblue", ylab= "Z-score")
abline(h = c(2, -2), col = "red", lty = 2)
abline(h = 0, col = "grey", lty = 3)

position <- ifelse(z_score > 2.0, -1,
            ifelse(z_score < 2.0, 1,
            ifelse(abs(z_score) < 0.2, 0, NA)))

positon <- na.locf(position, na.rm = FALSE)
position[is.na(position)] <- 0

position <- Lag(position, k = 1)

bhp_returns <- ROC(BHP.AX$BHP.AX.Close, type = "discrete")
rio_returns <- ROC(RIO.AX$RIO.AX.Close, type = "discrete")

strategy_returns <- (position * bhp_returns) - (position * 0.271663 * rio_returns)

strategy_returns[is.na(strategy_returns)] <- 0

cumulative_growth <- cumprod(1 + strategy_returns)

plot(cumulative_growth, main = "Pairs Trading Strategy: Cumulative Growth ($1 Base)", 
     col = "darkgreen", ylab = "Portfolio Value ($)", xlab = "Time")
