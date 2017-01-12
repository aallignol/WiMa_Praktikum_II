### quick test file to look for exercise

N <- 1000
res <- double(N)


i <- 1
no_variable_selected <- 0
while(i <= N) {

    n <- 200
    p <- 100
    y <- rnorm(n)
    x <- matrix(rnorm(n * p), nrow = n)    
    df <- data.frame(y, x)
    mdl <- lm(y ~ ., df)
    
    stars <- 1 + which(coefficients(summary(mdl))[-1, 4] < 0.05)
    print(no_variable_selected)
    if (length(stars) == 0) {
        no_variable_selected <- no_variable_selected + 1
        next
    }
    else 
        mdl.2 <- lm(y ~ ., df[, c(1, stars)])
    
    aa <- summary(mdl.2)$fstatistic
    
    res[i] <- pf(aa[1L], aa[2L], aa[3L], lower.tail = FALSE)
    i <- i + 1
}
 


### College data

data(College, package = "ISLR")

College$lApps <- log(College$Apps)

library(leaps)
require(caret)

set.seed(1234)
inTrain <- createDataPartition(y = College$lApps,
                               p = .5,
                               list = FALSE)

lm_fwd <- regsubsets(lApps ~ Private + Accept + Enroll +
                       Top10perc  +  Top25perc  +  F.Undergrad  +
                       P.Undergrad  +  Outstate  +  Room.Board  +
                       Books  +  Personal  +  PhD  +  Terminal  +
                       S.F.Ratio  +  perc.alumni  +  Expend  +
                       Grad.Rate,
                     College[inTrain, ], nvmax = 17)


predict.regsubsets <- function(object, newdata, id, ...) {
    form <- as.formula(object$call[[2]])
    mat <- model.matrix(form, newdata)
    coefi <- coef(object, id = id)
    xvars <- names(coefi)
    mat[, xvars] %*% coefi
}

val.errors.train <- rep(NA, 17)
for(i in 1:17) {
    the_prediction <- predict(lm_fwd, College[inTrain, ], id = i)
    val.errors.train[i] <- mean((College$lApps[inTrain] - the_prediction)^2)
}

val.errors.test <- rep(NA, 17)
for(i in 1:17) {
    the_prediction <- predict(lm_fwd, College[-inTrain, ], id = i)
    val.errors.test[i] <- mean((College$lApps[-inTrain] - the_prediction)^2)
}

plot(val.errors.train, type = "l", col = 2)
lines(val.errors.test)
