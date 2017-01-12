#####################################################################
### R file for lecture on model selection
### Arthur Allignol <arthur.allignol@uni-ulm.de>
#####################################################################

## Here we apply model selection approaches to the Hitters
## data. We wish to predict a baseball player's Salary on the basis of
## various statistics associated with performance in the previous
## year.

data(Hitters, package = "ISLR")

summary(Hitters)

## remove the NA values in salary (that's bad practice...)
Hitters <- na.omit(Hitters)

### Forward selection
require(MASS)

## Fit a full model and a minimal model. These will be use as scope
## for the search
lm_full <- lm(Salary ~ ., Hitters)
lm_min <- lm(Salary ~ 1, Hitters)

## Forward selection 
lm_fwd_mass <- stepAIC(lm_min, scope = list(lower = lm_min, upper = lm_full),
                       direction = "forward")

## Backward selection
lm_bwd_mass <- stepAIC(lm_full, scope = list(lower = lm_min, upper = lm_full),
                       direction = "backward")


### Another function for doing forward/backward selection

## It chooses which variable to include/remove by looking at the
## RSS. The function returns all the models. The user needs to chose
## then.
library(leaps)

lm_fwd <- regsubsets(Salary ~ ., Hitters, method = "forward", nvmax = 19)
lm_bwd <- regsubsets(Salary ~ ., Hitters, method = "backward", nvmax = 19)

plot(lm_fwd , scale = "bic")
plot(lm_fwd , scale = "Cp")

plot(lm_bwd , scale = "bic")

### Explore a bit the results
summ_bwd <- summary(lm_bwd)

summ_bwd$rss

oldpar <- par(mfrow = c(1, 2))
plot(summ_bwd$cp, xlab = "Number of Variables" , ylab = "Cp",
     type = 'l')
plot(summ_bwd$bic, xlab = "Number of Variables" , ylab = "BIC",
     type = 'l')
par(oldpar)

coef(lm_bwd, 6)

### Choose the best model using a test sample
set.seed(1)
train <- sample(c(TRUE, FALSE), nrow(Hitters), replace = TRUE)
test <- !train

lm_test_fwd <- regsubsets(Salary ~ ., Hitters[train, ], method = "forward", nvmax = 19)

plot(lm_test_fwd , scale = "bic")

### Write a function to obtain predictions for regsubsets objects
## object: an object of class regsubsets
## newdata: As in other predict functions
## id: number of variables included in the model (such that we can
##     obtain MSE as a function as the number of variables selected
predict.regsubsets <- function(object, newdata, id, ...) {
    form <- as.formula(object$call[[2]])
    mat <- model.matrix(form, newdata)
    coefi <- coef(object, id = id)
    xvars <- names(coefi)
    mat[, xvars] %*% coefi
}

## Get the MSE as a function of the number of variables
val.errors <- rep(NA,19)
for(i in 1:19) {
    the_prediction <- predict(lm_test_fwd, Hitters[test, ], id = i)
    val.errors[i] <- mean((Hitters$Salary[test] - the_prediction)^2)
}

which.min(val.errors)

## the same with backward selection
lm_test_bwd <- regsubsets(Salary ~ ., Hitters[train, ], method = "backward", nvmax = 19)
val.errors <- rep(NA,19)
for(i in 1:19) {
    the_prediction <- predict(lm_test_bwd, Hitters[test, ], id = i)
    val.errors[i] <- mean((Hitters$Salary[test] - the_prediction)^2)
}

which.min(val.errors) 

### Choose the best model using cross-validation

k <- 10 #number of folds
set.seed(1)

## Cross-validation per hand: Same idea as above, except that we do
## that for each fold in turn
folds <- sample(1:k, nrow(Hitters), replace=TRUE)
cv.errors <- matrix(NA, k, 19, dimnames=list(NULL, paste(1:19)))

for(j in 1:k){
    best.fit <- regsubsets(Salary ~ ., Hitters[folds != j, ], nvmax=19, method = "forward")
    for(i in 1:19) {
        pred <- predict(best.fit, Hitters[folds == j,],id = i)
        cv.errors[j,i] = mean((Hitters$Salary[folds == j] - pred)^2)
    }
}

mean.cv.errors <- apply(cv.errors, 2, mean)
mean.cv.errors

plot(mean.cv.errors,type='b')

### The same using the caret package
library(caret)

## Partition the data
set.seed(1234)
inTrain <- createDataPartition(y = Hitters$Salary,
                               p = .75,
                               list = FALSE)

## The workhorse of the caret function. The method argument controls
## which model to use (see http://topepo.github.io/caret/bytag.html
## for a full list)

## tuneLength creates a grid of length 19 for the tuning parameters --
## in this case the maximum number of variables to include in the
## model
lm_c_fwd <- train(Salary ~ .,
                  data = Hitters[inTrain, ],
                  method = 'leapForward',
                  tuneLength = 19,
                  trControl = trainControl(method = "repeatedcv", repeats = 10))

plot(lm_c_fwd)

predict(lm_c_fwd, newdata = Hitters[-inTrain, ])

### Ridge and lasso
library(glmnet)

x <- model.matrix(Salary~ ., Hitters)[,-1]
y <- Hitters$Salary

## ridge
grid <- 10^seq(10, -2, length=100)

## alpha = 0 fits a ridge model
ridge.mod <- glmnet(x, y, alpha = 0, lambda = grid)

ridge.mod$lambda[50]
coef(ridge.mod)[,50]

ridge.mod$lambda[60]
coef(ridge.mod)[,60]

### Cross-validation for finding the best lambda
## use the same train data as in the caret package

set.seed(4234)
cv.ridge <- cv.glmnet(x[inTrain, ], y[inTrain], alpha = 0)

plot(cv.ridge)

bestlam <- cv.ridge$lambda.min
bestlam

ridge.mod <- glmnet(x[inTrain, ], y[inTrain], alpha = 0, lambda = grid)

ridge.pred <- predict(ridge.mod, s = bestlam, newx = x[-inTrain, ])
mean((ridge.pred - Hitters$Salary[-inTrain])^2)

## lasso (alpha = 1)
lasso.mod <- glmnet(x[inTrain, ], y[inTrain], alpha = 1, lambda = grid)
plot(lasso.mod)

set.seed(6628)
cv.lasso <- cv.glmnet(x[inTrain, ], y[inTrain], alpha = 1)

plot(cv.lasso)

bestlam.l <- cv.lasso$lambda.min
bestlam.l

lasso.pred <- predict(lasso.mod, s = bestlam.l, newx = x[-inTrain, ])
mean((lasso.pred - Hitters$Salary[-inTrain])^2)


lasso.full <- glmnet(x, y, alpha = 1, lambda = grid)
lasso.coef <- predict(lasso.full, type="coefficients", s = bestlam.l)


