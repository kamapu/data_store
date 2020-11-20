# TODO:   Add comment
# 
# Author: Miguel Alvarez
###############################################################################

library(vegtable)
library(vegtable2)
library(biblio)
library(dbaccess)

load("grasslands.rda")

conn <- connect_db2(dbname="veg_databases", user="miguel")

grasslands <- import_sudamerica(conn, get_countries=FALSE)

# Subset database
grasslands <- subset(grasslands, bibtexkey == "SanMartin1998", slot="relations",
		relation="data_source")
grasslands@species <- used_concepts(grasslands, keep_parents=TRUE)
summary(grasslands)

# Change life forms
grasslands@species@taxonTraits$life_form <-
		grasslands@species@taxonTraits$lf_elena

grasslands@species@taxonTraits <-
		grasslands@species@taxonTraits[,
				colnames(grasslands@species@taxonTraits) != "lf_elena"]

# Skip header information and add bibliographic information
grasslands@header <- grasslands@header[!colnames(grasslands@header) %in%
				c("validation_coordinates", "id_cldataveg")]

# TODO: Add references
# Insert this script in the package source

save(grasslands, file="../datastore/data/grasslands.rda")
