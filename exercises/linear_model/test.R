
## Creation of the interaction data set

n <- 1000
set.seed(534534)

x <- rnorm(n, 0, 5)
treatment <- factor(rbinom(n, 2, .5))

tmp <- model.matrix(~ treatment)

y <- 3 * x - 1 * tmp[, "treatment1"] - 2 * tmp[, "treatment2"] +
  2 * tmp[, "treatment1"] * x +
  1.5 * tmp[, "treatment2"] * x +
  rnorm(100, 0, 3)

df <- data.frame(x = x, treatment, y = y)


write.csv(df, file = "df.csv", row.names = FALSE)
