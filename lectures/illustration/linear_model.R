#####################################################################
## R file for linear model examples
## Arthur Allignol <arthur.allignol@uni-ulm.de
#####################################################################

library(ggplot2)
library(gridExtra)

#######################################
## Simple linear regression 
#######################################

data(hubble, package = "gamair")
names(hubble) <- c("galaxy", "velocity", "distance")

head(hubble)

## We want to fit the model:
## velocity = \beta0 + distance * beta1 + \varepsilon

## First look at the data
p <- ggplot(hubble, aes(distance, velocity)) + geom_point() + theme_bw()
p

### fit the linear model
lm_mod1 <- lm(velocity ~ distance, hubble)

lm_mod1

summary(lm_mod1)

p + geom_smooth(method = "lm", se = FALSE)

### A look at the design matrix
f <- velocity ~ distance

model.matrix(f, hubble)

## Actually we want a model without intercept because if distance is
## zero, so is the relative speed
f_wo_intercept <- velocity ~ distance - 1

model.matrix(f_wo_intercept, data = hubble)

lm_mod2 <- lm(f_wo_intercept, hubble)
summary(lm_mod2)
anova(lm_mod2)

p + geom_smooth(method = "lm", formula = y ~ x - 1, se = FALSE)

## Plot of the residuals vs fitted
ggplot(lm_mod2, aes(.fitted, .resid)) + geom_point() +
  stat_smooth(method="loess", se = FALSE) +
  geom_hline(yintercept = 0, col = "red", linetype = "dashed") +
  xlab("Fitted values")+ylab("Residuals") +
  ggtitle("Residual vs Fitted") +
  theme_bw()

## Using base graphics 
plot(lm_mod2, which = 1)

## qqplot of the errors
plot(lm_mod2, which = 2) ## with standardised residual = e/SD(e)

## Cook's distance
plot(lm_mod2, which = 4)

## Note that there exists functions to access the different elements
## of the fit
fitted(lm_mod2)
resid(lm_mod2)
coef(lm_mod2)
vcov(lm_mod2)

## Age of the universe
Mpc <- 3.09 * 10^19
ysec <- 60^2 * 24 * 365.25
Mpcyear <- Mpc / ysec
1 / (coef(lm_mod2) / Mpcyear)


#######################################
## A complete example: Insurance redlining
#######################################

data(chredlin, package = "faraway")
head(chredlin)

summary(chredlin)

## First look at the data
p1 <- ggplot(chredlin, aes(race, involact)) + geom_point() + geom_smooth(method = "lm") + theme_bw()

p2 <- ggplot(chredlin, aes(fire, involact)) + geom_point() + geom_smooth(method = "lm") + theme_bw()

p3 <- ggplot(chredlin, aes(theft, involact)) + geom_point() + geom_smooth(method = "lm") + theme_bw()

p4 <- ggplot(chredlin, aes(age, involact)) + geom_point() + geom_smooth(method = "lm") + theme_bw()

p5 <- ggplot(chredlin, aes(income, involact)) + geom_point() + geom_smooth(method = "lm") + theme_bw()

p6 <- ggplot(chredlin, aes(side, involact)) + geom_jitter(width = .2, height = 0) + theme_bw()

grid.arrange(p1, p2, p3, p4, p5, p6,
             ncol = 3, nrow = 2)


### Relationship between involact and race
lm_simple <- lm(involact ~ race, chredlin)
summary(lm_simple)

## Maybe greatest risk of fire and/or theft in some zip code?
p_fire <- ggplot(chredlin, aes(race, fire)) + geom_point() + geom_smooth(method = "lm")
p_theft <- ggplot(chredlin, aes(race, theft)) + geom_point() + geom_smooth(method = "lm")

grid.arrange(p_fire, p_theft, ncol = 2)


#######################################
## Full model
#######################################

lm_full <- lm(involact ~ race + fire + theft + age + log(income), chredlin)
summary(lm_full)

## Do the full model "better" than the simple model?
anova(lm_simple, lm_full)

## some diagnostic plots
plot(lm_full, 1:2)

## E.g., 
plot(chredlin$race, resid(lm_full))

## Partial residuals plots
termplot(lm_full, partial.resid = TRUE, terms = 1:5)

### Remove income to the model
summary(lm(involact ~ race + fire + theft + age, chredlin))

## Outliers?
plot(lm_full, 4)

chredlin[c("60607", "60610"), ]

ind <- match(c("60607", "60610"), row.names(chredlin))

summary(lm(involact ~ race + fire + theft + age + log(income), chredlin,
           subset = -ind))


#######################################
## Another complete example: Anorexia data
#######################################

data(anorexia, package = "MASS")

anorexia$treatment <- factor(anorexia$Treat)
anorexia$weight_gain <- anorexia$Postwt - anorexia$Prewt

ggplot(anorexia, aes(x = Prewt, y = weight_gain)) +
  geom_point() + geom_smooth(method = "lm")

ggplot(anorexia, aes(x = Prewt, y = weight_gain, colour = treatment, fill = treatment)) +
  geom_point() + geom_smooth(method = "lm")

f_anorexia <- weight_gain ~ Prewt + treatment + Prewt:treatment # alternatively: Postwt ~ Prewt * treatment
model.matrix(f_anorexia, anorexia)

## relevel the treatment variable
anorexia$treatment <- relevel(anorexia$treatment, ref = "Cont")

f_anorexia <- weight_gain ~ Prewt + treatment + Prewt:treatment # alternatively: Postwt ~ Prewt * treatment
head(model.matrix(f_anorexia, anorexia))

lm_anorexia <- lm(f_anorexia, anorexia)

plot(anorexia$treatment, resid(lm_anorexia)) ## smaller errors for the controls...

anova(lm_anorexia)

## Specific group comparison using contrasts
require(multcomp)

K <- matrix(c(0, 0, -1, 1, 0, 0), 1)
data.frame(coef(lm_anorexia), t(K))

summary(glht(lm_anorexia, linfct = K))


#######################################
## Some simulated data to show what can go wrong
#######################################

## heteroskedasticity

x <- rnorm(100, 5, 3)
y <- 3 * x + x * rnorm(100)

df <- data.frame(x, y)

ggplot(df, aes(x, y)) + geom_point() + geom_smooth(method = "lm")

alm <- lm(y ~ x, df)
plot(alm, 1)

summary(alm)

## robust SEs
library(sandwich)
sqrt(diag(vcovHC(alm)))

### Non linear model
x <- rnorm(100, 5, 3)
y <- 3 * x + 2 * x^2 + rnorm(100)

blm <- lm(y ~ x)

plot(blm, 1) ## Problem !!!

## Solution
clm <- lm(y ~ x + I(x^2))
plot(clm, 1)


## Illustration of splines
funky <- function(x) {
    sin(2 * pi * x^3)^3
}

x <- seq(0, 1, 0.01)

y <- funky(x) + rnorm(101) * 0.2

require(splines)
dlm <- lm(y ~ bs(x, degree = 3)); summary(dlm)
elm <- lm(y ~ bs(x, degree = 6)); summary(elm)
flm <- lm(y ~ bs(x, degree = 12)); summary(flm)

par(mfrow = c(1, 3))
plot(dlm, 1)
plot(elm, 1)
plot(flm, 1)
par(mfrow = c(1, 1))

### Add some interaction examples
n <- 1000

x <- rnorm(n, 0, 5)
treatment <- factor(rbinom(n, 2, .5))

tmp <- model.matrix(~ treatment)

y <- 3 * x - 1 * tmp[, "treatment1"] - 2 * tmp[, "treatment2"] +
  2 * tmp[, "treatment1"] * x +
  1.5 * tmp[, "treatment2"] * x +
  rnorm(100, 0, 3)

df <- data.frame(x = x, treatment, y = y)

lm_full <- lm(y ~ x * treatment, df)

lm_no_int <- lm(y ~ x + treatment, df)

## residuals vs fitted 
par(mfrow = c(1, 2))
plot(lm_no_int, 1)
plot(lm_full, 1)
par(mfrow = c(1, 1))

## The explanation
par(mfrow = c(1, 2))
plot(lm_no_int, 1, col = df$treatment)
plot(lm_full, 1, col = df$treatment)
par(mfrow = c(1, 1))

## resid vs ttt
par(mfrow = c(1, 2))
plot(df$treatment, resid(lm_no_int))
plot(df$treatment, resid(lm_full))
par(mfrow = c(1, 1))


