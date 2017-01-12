#####################################################################
## Test file for the exercises GLM
#####################################################################


require(titanic)
require(data.table)
require(ggplot2)

## bind test and train data

titanic <- titanic_train

dt_titanic <- data.table(titanic)

ggplot(dt_titanic, aes(Age)) + geom_histogram() + facet_grid(.~ Pclass)

aa <- dt_titanic[, list(mage = median(Age, na.rm = TRUE)), by = Pclass][, mage]

dt_titanic[is.na(Age) & Pclass == 3, Age := aa[1]]
dt_titanic[is.na(Age) & Pclass == 1, Age := aa[2]]
dt_titanic[is.na(Age) & Pclass == 2, Age := aa[3]]

test <- glm(Survived ~ factor(Pclass) * Sex + Age + SibSp + Parch + Fare + Embarked,
            dt_titanic, family = binomial)


test2 <- glm(Survived ~ factor(Pclass) * Sex + Age  + Fare,
             dt_titanic, family = binomial)

setkeyv(dt_titanic, c("Ticket"))
