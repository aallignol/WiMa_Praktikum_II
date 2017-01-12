#####################################################################
### R code for mixed models lecture
### Arthur Allignol <arthur-allignol@uni-ulm.de>
#####################################################################

require(data.table)
require(ggplot2)

#######################################
### High school and Beyond
#######################################


### Data preparation

require(nlme)

data(MathAchieve)
data(MathAchSchool)

Bryk <- as.data.frame(MathAchieve[, c("School", "SES", "MathAch")])

Bryk <- merge(Bryk, MathAchSchool, 
              by = "School", all.x = TRUE)

bryk <- data.table(Bryk)

bryk[, meanses := mean(SES), by = School]
bryk[, cses := SES - meanses]

bryk <- bryk[, list(School, SES, MathAch,
                    Sector, cses, meanses)]
bryk[, ':='(sector = as.character(Sector),
            school = as.character(School))]


### Data exploration

set.seed(66549)
ind.p <- sample(bryk[sector == "Public", school], 20)
ind.c <- sample(bryk[sector == "Catholic", school], 20)

ggplot(bryk[school %in% ind.p], aes(cses, MathAch)) + geom_point() +
  geom_smooth(method = "lm") +
  facet_wrap(~ school, scale = "free") +
  theme_bw()

ggplot(bryk[school %in% ind.c], aes(cses, MathAch)) + geom_point() +
  geom_smooth(method = "lm") +
  facet_wrap(~ school, scale = "free") +
  theme_bw()

require(lme4)

cat.list <- nlme::lmList(MathAch ~ cses | school, subset = sector=="Catholic",
                         data=bryk)
pub.list <- nlme::lmList(MathAch ~ cses | school, subset = sector=="Public",
                         data=bryk)

test.cat <- bryk[sector == "Catholic", coef(lm(MathAch ~ cses)), by = school]

## linear model for each school
plot(intervals(cat.list), main="Catholic")
plot(intervals(pub.list), main="Public")

cat.coef <- coef(cat.list)
pub.coef <- coef(pub.list)

old <- par(mfrow=c(1, 2))
boxplot(cat.coef[, 1], pub.coef[, 1], main="Intercepts",
    names=c("Catholic", "Public"))
boxplot(cat.coef[, 2], pub.coef[, 2], main="Slopes",
    names=c("Catholic", "Public"))
par(old)

## The models
bryk[, sector := factor(sector, levels = c("Public", "Catholic"))]

#############
## Model 1 ##
#############

bryk_lmm_1 <- lmer(MathAch ~ meanses*cses + sector*cses + (cses | school),
                  bryk)

## Without random slope
bryk_lmm_2 <- lmer(MathAch ~ meanses*cses + sector*cses + (1 | school),
                   bryk)

## THE FIXED EFFECTS ARE THE SAME !! IMPORTANT WITH REML
anova(bryk_lmm_1, bryk_lmm_2, refit = FALSE)

bryk_lmm_3 <- lmer(MathAch ~ meanses*cses + sector*cses + (cses - 1 | school),
                  bryk)

anova(bryk_lmm_1, bryk_lmm_3, refit = FALSE)

## We keep bryk_lme_2


##########################
## Wald tests and anova ##
##########################

require(lmerTest)

bryk_lmm_2 <- lmer(MathAch ~ meanses*cses + sector*cses + (1 | school),
                   bryk)

## class(bryk_lmm_2)

anova(bryk_lmm_2)
summary(bryk_lmm_2)


### Looking at the random parts ###

school_effects <- ranef(bryk_lmm_2)$school
school_effects$school <- row.names(school_effects)
names(school_effects) <- c("intercept", "school")

schools <- bryk[!duplicated(school), list(school, sector)]

school_effects <- merge(school_effects, schools, by = "school")

ggplot(school_effects, aes(x = intercept, fill = sector)) + geom_density(alpha = .3)



### Diagnostic
qres <- residuals(bryk_lmm_2)
qqnorm(qres)
qqline(qres)

plot(fitted(bryk_lmm_2), resid(bryk_lmm_2), col = as.integer(bryk$sector))

qrand <- ranef(bryk_lmm_2)$school[["(Intercept)"]]
qqnorm(qrand)
qqline(qrand)


######################
### Beat the blues ###
######################

data("BtheB", package = "HSAUR3")

BtheB$subject <- factor(rownames(BtheB))
nobs <- nrow(BtheB)
BtheB_long <- reshape(BtheB, idvar = "subject",
    varying = c("bdi.2m", "bdi.3m", "bdi.5m", "bdi.8m"),
    direction = "long")
BtheB_long$time <- rep(c(2, 3, 5, 8), rep(nobs, 4))
names(BtheB_long)[names(BtheB_long) == "treatment"] <- "trt"

## display of the data
layout(matrix(1:2, nrow = 1))
ylim <- range(BtheB[,grep("bdi", names(BtheB))],
              na.rm = TRUE)
tau <- subset(BtheB, treatment == "TAU")[,
    grep("bdi", names(BtheB))]
boxplot(tau, main = "Treated as usual", ylab = "BDI",
        xlab = "Time (in months)", names = c(0, 2, 4, 6, 8),
        ylim = ylim)
btheb <- subset(BtheB, treatment == "BtheB")[,
    grep("bdi", names(BtheB))]
boxplot(btheb, main = "Beat the Blues", ylab = "BDI",
        xlab = "Time (in months)", names = c(0, 2, 4, 6, 8),
        ylim = ylim)

dt <- data.table(BtheB_long)

ci <- function(x) {
    n <- length(x)
    se <- sd(x, na.rm = TRUE)/sqrt(n)
    ciMult <- se * qt(.975, n - 1)
    Mean <- mean(x, na.rm = TRUE)
    list(Mean = Mean, ciMult = ciMult)
}

ggplot(dt[, ci(bdi), by = list(trt, time)], aes(x = factor(time), y = Mean, colour = trt)) +
  geom_point(size = 5) +
  geom_errorbar(aes(ymin = Mean - ciMult, ymax = Mean + ciMult), width = .2)


## The models
BtheB_lmer1 <- lmer(bdi ~ bdi.pre + time + trt + 
                      drug + length + (1 | subject), data = BtheB_long,
                    REML = TRUE, na.action = na.omit)

BtheB_lmer2 <- lmer(bdi ~ bdi.pre + time + trt + 
                      drug + length + (time | subject), data = BtheB_long,
                    REML = TRUE, na.action = na.omit)

anova(BtheB_lmer1, BtheB_lmer2, refit = FALSE)

summary(BtheB_lmer1)

## Compare with ML estimation
BtheB_lmer1_ml <- lmer(bdi ~ bdi.pre + time + trt + 
                         drug + length + (1 | subject), data = BtheB_long,
                       REML = FALSE, na.action = na.omit)

## Model checking
layout(matrix(1:2, ncol = 2))
qint <- ranef(BtheB_lmer1)$subject[["(Intercept)"]]
qres <- residuals(BtheB_lmer1)
qqnorm(qint, ylab = "Estimated random intercepts",
       xlim = c(-3, 3), ylim = c(-20, 20),
       main = "Random intercepts")
qqline(qint)
qqnorm(qres, xlim = c(-3, 3), ylim = c(-20, 20),
       ylab = "Estimated residuals",
       main = "Residuals")
qqline(qres)

## interaction with time ?
BtheB_lmer11 <- lmer(bdi ~ bdi.pre + time * trt + 
                      drug + length + (1 | subject), data = BtheB_long,
                    REML = FALSE, na.action = na.omit)


### With GEE
osub <- order(as.integer(BtheB_long$subject))

BtheB_long <- BtheB_long[osub,] ## That's really important

require(geepack)

btb_gee <- geeglm(bdi ~ bdi.pre + time + trt + 
                    drug + length, data = BtheB_long, id = subject, 
                  family = gaussian, corstr = "independence")

btb_gee1 <- geeglm(bdi ~ bdi.pre + time + trt + 
                     drug + length, data = BtheB_long, id = subject, 
                   family = gaussian, corstr = "exchangeable")

coef(btb_gee)
coef(btb_gee1)
summary(BtheB_lmer1)$coef[, 1]

###########################
### Respiratory Illness ###
###########################

## data preparation
data("respiratory", package = "HSAUR3")
resp <- subset(respiratory, month > "0")
resp$baseline <- rep(subset(respiratory, month == "0")$status,  
                     rep(4, 111))
resp$nstat <- as.numeric(resp$status == "good")
resp$month <- resp$month[, drop = TRUE]
names(resp)[names(resp) == "treatment"] <- "trt"
levels(resp$trt)[2] <- "trt"

resp_glm <- glm(status ~ centre + trt + gender + 
                  baseline + age, data = resp, family = "binomial")

require(geepack)

resp_gee1 <- geeglm(nstat ~ centre + trt + gender + 
                      baseline + age, data = resp, family = "binomial", 
                    id = subject, corstr = "independence", 
                    scale.fix = TRUE, scale.value = rep(1, nrow(resp)))

resp_gee2 <- geeglm(nstat ~ centre + trt + gender + 
                      baseline + age, data = resp, family = "binomial", 
                    id = subject, corstr = "exchangeable", 
                    scale.fix = TRUE, scale.value = rep(1, nrow(resp)))

exp(coef(resp_gee2)["trttrt"] +
    c(-1, 1) *
    summary(resp_gee2)$coefficients["trttrt", "Std.err"] *
                    qnorm(0.975))


### GLMM
resp_glmer <- glmer(status ~ centre + trt + gender + 
                      baseline + age + (1 | subject),
                    data = resp, family = "binomial")
