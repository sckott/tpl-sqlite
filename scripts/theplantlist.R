# remove previous version if it exists
unlink("data/plantlist.sqlite")

library("taxize")
library("data.table")

dir <- file.path(tempdir(), "jkl")
tpl_get(dir)

files <- list.files(dir, full.names = TRUE)
df <- rbindlist(lapply(files, fread), fill = TRUE)
head(df)
str(df)

# rename columns
names(df) <- gsub("\\s", "_", tolower(names(df)))

# make full name column
df$scientificname <- paste(df$genus, df$species)

library("RSQLite")
library("DBI")
x <- dbConnect(RSQLite::SQLite(), "data/plantlist.sqlite")
dbWriteTable(x, "tpl", df)
dbListTables(x)

# create indices
RSQLite::dbExecute(x, 'CREATE UNIQUE INDEX id ON tpl (id)')
RSQLite::dbExecute(x, 'CREATE INDEX sciname ON tpl (scientificname)')

# test it
# dbGetQuery(x, 'SELECT * FROM tpl LIMIT 5')

# zip the sqlite file
library("zip")
unlink("data/plantlist.zip")
zip::zipr("data/plantlist.zip", "data/plantlist.sqlite",
    include_directories = FALSE)

# cleanup
dbDisconnect(x)
