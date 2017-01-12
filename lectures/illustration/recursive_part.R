#####################################################################
### R File for Recursive Partitioning lecture
### Arthur Allignol <arthur.allignol@uni-ulm.de>
#####################################################################

## The boston data set

library(MASS)

data(Boston, package = "MASS")

### Create a training sample: That's the data that we'll be used to
### fit the models
set.seed(1)
train <- sample(1:nrow(Boston), nrow(Boston)/2)

### Tree
tree.boston <- rpart(medv ~ ., Boston, subset = train)
summary(tree.boston)

plot(tree.boston)
text(tree.boston,pretty=0)

printcp(tree.boston)

cp.opt <- with(data.frame(tree.boston$cptable), CP[which.min(xerror)]) 
tree.boston <- prune(tree.boston, cp = cp.opt)

yhat <- predict(tree.boston, newdata = Boston[-train, ])
boston.test <- Boston[-train, "medv"]

plot(yhat, boston.test)
abline(0,1)

## Mean squared error
mean((yhat - boston.test)^2)


################################
## Bagging and Random Forests ##
################################

library(randomForest)
set.seed(1)

## Bagging: That's a random forest without random selection of the
## variables, thus mtry = number of covariates
bag.boston <- randomForest(medv ~ ., data = Boston, subset = train, mtry = 13, importance = TRUE)
bag.boston

yhat.bag <- predict(bag.boston, newdata = Boston[-train, ])
plot(yhat.bag, boston.test)
abline(0,1)

mean((yhat.bag - boston.test)^2)

## less trees
bag.boston <- randomForest(medv ~ ., data = Boston, subset = train, mtry = 13, ntree = 25)
yhat.bag <- predict(bag.boston, newdata = Boston[-train, ])
mean((yhat.bag-boston.test)^2)

## Random Forest
set.seed(1)
rf.boston <- randomForest(medv ~ ., data = Boston, subset = train, mtry = 6, importance = TRUE)

yhat.rf <- predict(rf.boston, newdata = Boston[-train, ])
mean((yhat.rf-boston.test)^2)

importance(rf.boston)
varImpPlot(rf.boston)
