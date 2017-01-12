require(ggplot2)
library(dplyr)
library(data.table)
require(gridExtra)

require(HSAUR3)
data(USmelanoma)

data("faithful", package = "datasets")

data("Titanic", package = "datasets")

write.csv(USmelanoma, file = "/data/Ulm/Teaching/SS_2016/WiMa_Praktikum/lectures/illustration/USmelanoma.csv",
          row.names = FALSE, na = '.')
write.csv(faithful, file = "/data/Ulm/Teaching/SS_2016/WiMa_Praktikum/lectures/illustration/faithful.csv",
          row.names = FALSE, na = '.')
