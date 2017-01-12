#####################################################################
### R file associated with lecture on missing values
### Arthur Allignol <arthur.allignol@uni-ulm.de>
### Modified code from https://www.jstatsoft.org/article/view/v045i03
#####################################################################


library(mice) ## stands for multiple imputation by chained equations
library(lattice) ## Another graphic package
 
head(nhanes) ## CHL (cholesterol) will be the dependent variable

### Check missing value pattern
md.pattern(nhanes)
## 13 individuals with complete data (1st line)
## 7 with only age recorded (last line)


### multiple imputation with default parameters
imp <- mice(nhanes, seed=23109)

imp
## imputation method pmm (predictive mean matching): All variables are
## considered continuous
## PredictorMatrix: All variables are used in
## turn for the imputation model
## By default 5 multiply imputated data sets

### Check your imputation
imp$imp$bmi

imp$imp$hyp

## Check the first completed data
complete(imp)

## the third
complete(imp, action = 3)


### Check graphically whether imputed values are plausible
stripplot(imp, pch=20, cex=1.2) ## red dots are the imputed values

xyplot(imp, bmi~chl|.imp, pch=20, cex=1.4)
xyplot(imp, bmi~hyp|.imp, pch=20, cex=1.4)

densityplot(imp)

### Check convergence
plot(imp) ## not good; the lines don't mix. Increase number of iterations

imp <- mice(nhanes, seed=23109, maxit = 50)
plot(imp)

## Fit your analysis model
fit <- with(imp, lm(chl~age+bmi))

fit

summary(fit)

### Pooled estimates
pool(fit)
round(summary(pool(fit)),2)

### With more imputations (m=50)
imp50 <- mice(nhanes, m=50, seed=553, maxit = 30)

plot(imp50)

fit50 <- with(imp50, lm(chl~age+bmi))

round(summary(pool(fit50)),2)


#######################################
### Modify the imputation model
#######################################

### Structural form
methods(mice) ## gives all the possible imputation model

## Bayesian linear regression, pmm, simple mean imputation
imp <- mice(nhanes, meth = c("", "norm", "pmm", "mean"))

### Same data; age and hyp as factors
str(nhanes2)

imp <- mice(nhanes2, meth = c("", "norm", "norm", "mean"))

imp <- mice(nhanes2, me=c("polyreg","pmm","logreg","norm"))

### There BMI won't be imputed and won't be used in the imputation
### models for the other variables
imp <- mice(nhanes2, meth=c("","","logreg","norm"))

### For doing other changes, it is useful to do a "dry" run (by specifying maxit = 0)
ini <- mice(nhanes2, maxit=0, pri=FALSE)
ini

pred <- ini$pred
pred[,"bmi"] <- 0 ## skip bmi

meth <- ini$meth ## skip bmi through the "method"
meth["bmi"] <- ""

## call mice with the new specifications
imp <- mice(nhanes2, meth=meth, pred=pred, pri=FALSE)
imp$imp$bmi


### Preserving a transformation
nhanes2.ext <- cbind(nhanes2, lchl=log(nhanes2$chl))
ini <- mice(nhanes2.ext, maxit=0, print=FALSE)
meth <- ini$meth
meth["lchl"] <- "~log(chl)" ## specify that lchl id the log of
                            ## chl. This way lchl won't be imputed,
                            ## but only chl. Though mice will keep
                            ## them in sync
pred <- ini$pred
pred[c("hyp","chl"),"lchl"] <- 0
pred["bmi","chl"] <- 0
pred
imp <- mice(nhanes2.ext, meth=meth, pred=pred, seed=38788, print=FALSE)
head(complete(imp))




### interactions continuous variables
nhanes2.ext <- cbind(nhanes2, bmi.chl=NA)
ini <- mice(nhanes2.ext, max=0, print=FALSE)
meth <- ini$meth
meth["bmi.chl"] <- "~I(bmi * chl)" ## specify the interaction (here the variables are cent
pred <- ini$pred
pred[c("bmi","chl"),"bmi.chl"] <- 0 ## bmi.chl won't be imputed, won't
                                    ## be used for imputing the other
                                    ## variables
imp <- mice(nhanes2.ext, meth=meth, pred=pred, seed=51600, print=FALSE)
imp
complete(imp)


### interaction categorical variables
head(ini$pad$data,3)

nhanes2.ext <- cbind(nhanes2,age.1.bmi=NA,age.2.bmi=NA)
ini <- mice(nhanes2.ext, max=0, print=FALSE)
meth <- ini$meth
meth["age.1.bmi"] <- "~I(age.1*(bmi))"
meth["age.2.bmi"] <- "~I(age.2*(bmi))"
pred <- ini$pred
pred[c("age","bmi"),c("age.1.bmi","age.2.bmi")] <- 0
imp <- mice(nhanes2.ext, meth=meth, pred=pred, maxit=10)


### squeeze
nhanes2.ext <- cbind(nhanes2, lchl=NA)
ini <- mice(nhanes2.ext,max=0,pri=FALSE)
meth <- ini$meth
meth[c("lchl","chl")] <- c("~log(chl)","norm")
pred <- ini$pred
pred[c("hyp","chl"),"lchl"] <- 0
pred["bmi","chl"] <- 0
imp <- mice(nhanes2.ext, meth=meth, pred=pred, seed=1, maxit=100)

## some values of chl are negative. Problematic for log(chl)
## To solve that, "squeeze" chl
meth["lchl"] <- "~log(squeeze(chl, bounds=c(100,300)))"
imp <- mice(nhanes2.ext, meth=meth, pred=pred, seed=1, maxit=100)

