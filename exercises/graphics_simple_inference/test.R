#####################################################################
## Test with the acupuncture trial
## Arthur Allignol <arthur.allignol@uni-ulm.de>
#####################################################################

library("readxl")
library(data.table)
library(ggplot2)


df_acu <- read_excel("acupuncture_trial.xls", sheet = 3)

dt_acu <- data.table(df_acu)

dt_acu <- dt_acu[, list(id, age, sex,
                        migraine,
                        chronicity,
                        acupuncturist,
                        practice_id,
                        group,
                        pk1, pk2, pk5,
                        f1, f2, f5,
                        gen1, gen2, gen5,
                        withdrawal_reason,
                        acuptreatments,
                        completer,
                        totaldos)]

dt_acu_long <- reshape(dt_acu, varying = list(c("pk1", "pk2", "pk5"),
                                              c("f1", "f2", "f5"),
                                              c("gen1", "gen2", "gen5")),
                       v.names = c("pk", "f", "gen"), 
                       sep = "", dir = "long", idvar = "id")

dt_mean <- dt_acu_long[, list(mpk = mean(pk, na.rm = TRUE),
                              mf = mean(f, na.rm = TRUE),
                              mgen = mean(gen, na.rm = TRUE)),
                       by = list(time, group)]

dt_mean[, Visit := factor(time, labels = c("0", "2", "5"))]
dt_mean[, Group := factor(group, labels = c("Control", "acupuncture"))]

ggplot(dt_mean, aes(Visit, mpk, colour = factor(migraine))) + geom_point(size = 3) +
  geom_path()

ggplot(dt_acu, aes(age, f5, colour = factor(group))) + geom_point()

