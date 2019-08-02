library("taxize")
library("data.table")

dir <- file.path(tempdir(), "jkl")
tpl_get(dir)

files <- list.files(dir, full.names = TRUE)
df <- rbindlist(lapply(files, fread), fill = TRUE)
head(df)
str(df)

library("RSQLite")
library("DBI")
x <- dbConnect(RSQLite::SQLite(), "data/plantlist.sqlite")
dbWriteTable(x, "tpl", df)
dbListTables(x)

# test it
dbGetQuery(x, 'SELECT * FROM tpl LIMIT 5')

# cleanup
dbDisconnect(x)
