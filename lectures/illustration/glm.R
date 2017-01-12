#####################################################################
## R file for GLM lecture
## Arthur Allignol <arthur.allignol@uni-ulm.de>
#####################################################################

library(faraway)

#######################################
## Challenger data -- logistic model
#######################################

data(orings, package = "faraway")

head(orings) # temp: temperature
             # damage: number of damage incidents out of 6 possible

plot(damage/6 ~ temp, orings, xlim = c(25, 85), ylim = c(0, 1))
## linear model !?
abline(lm(damage/6 ~ temp, orings))

## logistic model
log_o <- glm(cbind(damage, 6 - damage) ~ temp, orings, family = binomial) # number of successes and failures in the formula

## see the fit
plot(damage/6 ~ temp, orings, xlim = c(25, 85), ylim = c(0, 1))
x <- seq(25, 85, .1)
lines(x, ilogit(coef(log_o)[1] + coef(log_o)[2] * x))

## probit model
probit_o <- glm(cbind(damage, 6 - damage) ~ temp, orings, family = binomial(link = "probit"))

lines(x, pnorm(coef(probit_o)[1] + coef(probit_o)[2] * x), col = 2)

## Predict the response at 31F
predict(log_o, newdata = data.frame(temp = 31), type = "response")
predict(probit_o, newdata = data.frame(temp = 31), type = "response")

## Confidence interval for the odds-ratio
exp(confint(log_o))


#######################################
## plasma data
#######################################

data(plasma, package = "HSAUR3")

plasma$y <- as.numeric(plasma$ESR == "ESR > 20")

ggplot(plasma, aes(ESR, fibrinogen)) + geom_boxplot()
ggplot(plasma, aes(ESR, globulin)) + geom_boxplot()

## Logistic models
log_plasma_1 <- glm(y ~ fibrinogen, data = plasma, 
                    family = binomial())

summary(log_plasma_1)

log_plasma_2 <- glm(y ~ fibrinogen + globulin, data = plasma, 
                    family = binomial())
summary(log_plasma_2)

anova(log_plasma_1, log_plasma_2, test = "Chisq")

## plots of the residuals/ not very useful
ggplot(log_plasma_2, aes(.fitted, .resid)) + geom_point() + geom_smooth()



## Plot of the effect
df <- data.frame(P = predict(log_plasma_2, type = "response"),
                 fibrinogen = plasma$fibrinogen,
                 globulin = plasma$globulin)

ggplot(df, aes(fibrinogen, globulin, size = P)) +
  geom_point(shape = 21) +
  scale_size(range = c(1, 40)) + ylim(c(25, 50)) + xlim(c(2, 6)) +
  theme_bw()

## estimate dispersion
phi <- sum(residuals(log_plasma_2, type = "pearson")^2 / df.residual(log_plasma_2))

## Should be one. OK!


#######################################
## Solder data -- poisson regression
#######################################

data(solder, package = "faraway")

hist(solder$skips)

ggplot(solder, aes(Opening, skips)) + geom_boxplot()

lm_solder <- lm(skips ~ ., solder)
plot(lm_solder, 1) ## variance increases !

poisson_solder <- glm(skips ~ ., solder, family = poisson())

## deviance residuals
plot(predict(poisson_solder, type = "link"), residuals(poisson_solder, type = "deviance"))

## response residuals
plot(predict(poisson_solder, type = "link"), residuals(poisson_solder, type = "response")) # On the response scale, variance increases with mean. That's normal

## dispersion parameter
phi <- sum(residuals(poisson_solder, type = "pearson")^2) / df.residual(poisson_solder)

## A display to look at the dispersion (p.59)
plot(log(fitted(poisson_solder)), log((solder$skips - fitted(poisson_solder))^2),
     xlab = expression(hat(mu)), ylab = expression((y - hat(mu))^2))
abline(0, 1)

## Negative binomial model
library(MASS)

negb_solder <- glm.nb(skips ~ ., solder)

## Test
X2 <- 2 * (logLik(negb_solder) - logLik(poisson_solder))

pchisq(X2, df = 1, lower.tail=FALSE)


#######################################
## tb_real -- poisson regression with offset
#######################################

library(readxl)

tb_real <- read_excel("tb_real.xlsx")

## model with offset
mod1 <- glm(reactors ~ offset(log(par)) + factor(type) +
              factor(sex) + factor(age), family = poisson, data = tb_real)


## #######################################
## ## nes96 -- multinomial regression
## #######################################
require(ggplot2)
require(dplyr)

data(nes96, package = "faraway")

party <-  nes96$PID
levels(party) <- c("Democrat","Democrat",
                   "Independent","Independent", "Independent",
                   "Republican","Republican")
inca <- c(1.5,4,6,8,9.5,10.5,11.5,12.5,13.5,14.5,16,18.5,
          21,23.5, 27.5,32.5,37.5,42.5,47.5,55,67.5,82.5,97.5,115)
income <- inca[unclass(nes96$income)]
rnes96 <- data.frame(party, income, education=factor(nes96$educ, ordered = FALSE), age=nes96$age)
summary(rnes96)

## Descriptive display
egp <- group_by(rnes96, education, party) %>%
  summarise(count=n()) %>%
  group_by(education) %>%
  mutate(etotal=sum(count), proportion=count/etotal)
ggplot(egp, aes(x=education, y=proportion, group=party, linetype=party)) +
  geom_line()

igp <- mutate(rnes96, incomegp=cut_number(income,7)) %>%
  group_by(incomegp, party) %>%
  summarise(count=n()) %>%
  group_by(incomegp) %>%
  mutate(etotal=sum(count), proportion=count/etotal)
ggplot(igp, aes(x=incomegp, y=proportion, group=party, linetype=party))+geom_line()

## multinomial model
library(nnet)

mmod <- multinom(party ~ age + education + income, rnes96)

cc <- c(0, -1.373895, -3.048576)
exp(cc)/ sum(exp(cc))

predict(mmod, newdata = data.frame(age = 0, education = "MS", income = 0), type = "probs")

## compute predicted probabilities for a range of incomes
newdata <- data.frame(age = mean(rnes96$age),
                      education = "BAdeg",
                      income = c(1.5, 10.5, 21, 42.5, 97.5))

predict(mmod, newdata = newdata, type = "probs")


#######################################
## CHFLS: Happiness in China
#######################################

data(CHFLS, package = "HSAUR3")

## Different form of the model in polr()
## Use Helmert contrast for the ordered factors

opts <- options(contrasts = c("contr.treatment",
                              "contr.helmert"))

require(MASS)

CHFLS_polr <- polr(R_happy ~ ., CHFLS)

## Understand Helmert contrasts
H <- with(CHFLS, contr.helmert(table(R_health)))
rownames(H) <- levels(CHFLS$R_health)
colnames(H) <- paste(levels(CHFLS$R_health)[-1], "- avg")
H

library(multcomp)
cftest(CHFLS_polr)

CHFLS_polr_simple <- polr(R_happy ~ R_health, CHFLS)
cftest(CHFLS_polr_simple)

dd <- data.frame(R_health = c("Poor", "Not good", "Fair", "Good", "Excellent"))
dd$R_health <- ordered(dd$R_health, levels = dd$R_health)

my_pred <- data.frame(predict(CHFLS_polr_simple, newdata = dd, type = "probs"))

my_pred_long <- reshape(my_pred, dir = "long", varying = names(my_pred), v.names = "Prob",
                        timevar = "happiness", times = names(my_pred))

my_pred_long$happiness <- factor(my_pred_long$happiness,
                                 levels = names(my_pred))

my_pred_long <- cbind(my_pred_long, rep(dd, 4))

ggplot(my_pred_long, aes(happiness, Prob, colour = R_health)) +
  geom_point(size = 5) + geom_line(aes(x = as.numeric(factor(happiness)))) +
  ylim(c(0, 1))
