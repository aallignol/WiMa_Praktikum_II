## test file

data(hprice, package = "faraway")

### SIIdata

## Creation of the data files for the exercises
data(SIIdata, package = "nlmeU")

require(data.table)

dt_sii <- data.table(SIIdata)

dt_school <- dt_sii[, .SD[1, list(housepov)], by = schoolid]

dt_class <- dt_sii[, .SD[1, list(yearstea, mathknow, mathprep, schoolid)], by = classid]

dt_pupil <- dt_sii[, list(childid, schoolid, classid,
                          sex, minority, mathkind,
                          mathgain, ses)]

write.csv(dt_school, file = "school.csv", row.names = FALSE)
write.csv(dt_class, file = "class.csv", row.names = FALSE)
write.csv(dt_pupil, file = "pupil.csv", row.names = FALSE)
