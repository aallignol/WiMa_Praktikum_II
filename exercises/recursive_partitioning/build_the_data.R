#####################################################################
### Build the titanic test data
### Arthur Allignol <arthur.allignol@uniulm.de>
#####################################################################

require(titanic)

tit_complete <- read.csv("titanic3.csv",
                         stringsAsFactors = FALSE)

tit_complete <- tit_complete[!duplicated(tit_complete$name), ]

ttest <- titanic_test

test <- merge(ttest, tit_complete[, c("survived", "name")],
              by.x = "Name", by.y = "name", all.x = TRUE)

write.csv(test,
          file = "titanic_test.csv",
          row.names = FALSE)
