#####################################################################
### Analyssi fo survival data --- R script
### Arthur Allignol <arthur.allignol@uni-ulm.de>
#####################################################################


#######################################
## Comparison of medical therapies to aid smokers quit
#######################################

data(pharmacoSmoking, package = "asaur")


### First look at the data
summary(pharmacoSmoking)

hist(pharmacoSmoking$priorAttempts)

table(pharmacoSmoking$relapse)

with(pharmacoSmoking, table(relapse, grp))

### non-parametric estimation
require(survival)

km_all <- survfit(Surv(ttr, relapse) ~ 1, pharmacoSmoking)

km_all

summary(km_all)

plot(km_all)

require(ggfortify)
autoplot(km_all)

autoplot(km_all, censor.col = "red", censor.size = 10)

## compute Nelson-Aalen estimator
aa_all <- cumsum(km_all$n.event / km_all$n.risk)

autoplot(km_all, fun = "cumhaz") + theme_bw()

### Compare survival curves
km_grp <- survfit(Surv(ttr, relapse) ~ grp, pharmacoSmoking)

autoplot(km_grp)

autoplot(km_grp, fun = "cumhaz")


#######################################
## Channing retirement center
#######################################

data(channing, package = "KMsurv")

km_channing <- survfit(Surv(ageentry, age, death) ~ 1, channing) # Problem

channing[channing$ageentry >= channing$age, ] # same age of entry and
                                              # age of exit. Need to
                                              # fix that. Add half a
                                              # year to exit age

channing <- within(channing, {
    age <- ifelse(age > ageentry, age, age + 6) # age is in month
    age <- age / 12
    ageentry <- ageentry / 12
})


km_channing <- survfit(Surv(ageentry, age, death) ~ 1, channing)

### Plot of Y(t)
plot(km_channing$time, km_channing$n.risk, type = "s",
     ylab = expression(Y(t)), xlab = "Age")

## Survival probability
autoplot(km_channing, censor.col = "red")

autoplot(km_channing, censor = FALSE, xlim = c(60, 100))

km_c_gender <- survfit(Surv(ageentry, age, death) ~ factor(gender), channing)
autoplot(km_c_gender,
         censor = FALSE, xlim = c(60, 100))

table(channing$gender, channing$death)

nev <- km_c_gender[1]$n.event
nrisk <- km_c_gender[1]$n.risk
times <- km_c_gender[1]$time

## A graphical explanation
old.par <- par(no.readonly = TRUE)
nf <- layout(matrix(c(1, 2)), heights = c(1, 0.6))

par(mar = c(0.5, 4, 3.5, 2) + 0.1)
plot(times, nrisk, type = "s", xaxt = "n", xlab = "",
     lwd = 2, ylab = expression(Y(t)))

par(mar = c(5, 4, 0, 2) + 0.1)
plot(times, nev, type = "n", xlab = "Age",
     ylab = expression(paste(Delta, N(t))))
for (i in seq_along(nev)) {
    segments(times[i], 0, times[i], nev[i], lwd = 3)
}

par(old.par)

## Then we compute P(T > t, T >= 70)
km_c_gender_70 <- survfit(Surv(ageentry, age, death) ~ factor(gender), channing,
                       subset = age >= 70)

autoplot(km_c_gender_70,
         censor = FALSE, xlim = c(65, 100))


#######################################
## Comparison of medical therapies to aid smokers quit
#######################################

cox_grp <- coxph(Surv(ttr, relapse) ~ grp, pharmacoSmoking)


### Graphical test of proportional hazards assumption
## The function ensures that the estimates are evaluated 
## at the same time points in both groups
compute_na <- function(x, time) {

    na <- cumsum(x$n.event/x$n.risk)
    
    ind <- findInterval(time, x$time)
    tmp <- numeric(length(time))
    place <- which(ind != 0)
    tmp[place] <- na[ind]

    tmp
}

the_times <- sort(unique(km_grp$time))

na_comb <- compute_na(km_grp[1], the_times)
na_patch <- compute_na(km_grp[2], the_times)

plot(na_comb, na_patch, type = "s", lwd = 2)
abline(0, exp(coef(cox_grp)[1]), lwd = 2, col = "gray")

### with cox.zph: schoenfeld residuals
ph_grp <- cox.zph(cox_grp)
plot(ph_grp)
abline(h = coef(cox_grp[1]), col = "red")


######################
### A bigger model ###
######################

cox_1 <- coxph(Surv(ttr, relapse) ~ grp + age + gender + race + employment +
                 yearsSmoking + levelSmoking + priorAttempts,
               pharmacoSmoking)

summary(cox_1)
anova(cox_1)

anova(cox_grp, cox_1)

### Investigate functional form of some variables
## Compare the martingale residuals of the null model to 
## the variables
cox_null <- coxph(Surv(ttr, relapse) ~ 1, pharmacoSmoking)

pharmacoSmoking$rr.0 <- residuals(cox_null, type = "martingale")

ggplot(pharmacoSmoking, aes(age, rr.0)) + geom_point() + geom_smooth()
ggplot(pharmacoSmoking, aes(priorAttempts, rr.0)) + geom_point() + geom_smooth()

### Remove this weird individual
pharmacoSmoking_out <- pharmacoSmoking[pharmacoSmoking$priorAttempts < 50, ] # remove 2 ind

cox_2 <- coxph(Surv(ttr, relapse) ~ grp + age + gender + race + employment +
                 yearsSmoking + levelSmoking + priorAttempts,
               pharmacoSmoking_out)

pharmacoSmoking[pharmacoSmoking$priorAttempts == 1000, ]

## quite influencial, but we'll remove priorAttempts from the model

#######################
### A reduced model ###
#######################

cox_3 <- coxph(Surv(ttr, relapse) ~ grp + age + employment,
               pharmacoSmoking)

anova(cox_3, cox_1)

summary(cox_3)

### test the proportional hazards assumption
test_3 <- cox.zph(cox_3)

old <- par(mfrow = c(2, 2))
plot(test_3)
par(old)


################################
### Time-dependent variables ###
################################

data(icu.pneu, package = "kmi")

aa <- icu.pneu[order(icu.pneu$id, icu.pneu$start), ]

cox_icu <- coxph(Surv(start, stop, status) ~ pneu + age + sex, icu.pneu)

old <- par(mfrow = c(1, 3))
plot(cox.zph(cox_icu))
par(old)

hist(icu.pneu$stop, xlim = c(0, 80))
