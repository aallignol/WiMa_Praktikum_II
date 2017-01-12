#####################################################################
## Create a simple data example for SAS
## Arthur Allignol <arthur.allignol@uni-ulm.de>
#####################################################################

set.seed(1313)

n <- 20

id <- seq(1:n)
disease <- rbinom(n, 1, 0.5)
a_factor <- rbinom(n, 1, 0.3)
a_factor[seq(1, 20, 5)] <- "."
another_factor <- sample(1:5, n, replace = TRUE)
center <- sample(c("Ulm", "Stuttgart", "Freiburg", "Karlsruhe"), 20, replace = TRUE)
visit_1 <- rnorm(20)
visit_2 <- rnorm(20)
visit_3 <- rnorm(20)
visit_1_d <- sample(seq.Date(as.Date("2012-05-16"), as.Date("2012-12-12"), 1), n, rep = TRUE)
visit_2_d <- sample(seq.Date(as.Date("2013-05-16"), as.Date("2013-12-12"), 1), n, rep = TRUE)
visit_3_d <- sample(seq.Date(as.Date("2014-05-16"), as.Date("2014-12-12"), 1), n, rep = TRUE)

df <- data.frame(id,
                 disease,
                 a_factor,
                 another_factor,
                 center,
                 visit_1,
                 visit_2,
                 visit_3,
                 visit_1_d,
                 visit_2_d,
                 visit_3_d)


write.csv(df, file = "illustration/df.csv",
          row.names = FALSE)
