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

# zip the sqlite file
library("zip")
zip::zipr("data/plantlist.zip", "data/plantlist.sqlite",
    include_directories = FALSE)

# cleanup
dbDisconnect(x)
unlink("data/plantlist.sqlite")
