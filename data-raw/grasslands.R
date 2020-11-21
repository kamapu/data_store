# TODO:   Import and arrangement of data set 'grasslands'
# 
# Author: Miguel Alvarez
################################################################################

library(vegtable)
library(vegtable2)
library(biblio)
library(dbaccess)

load("grasslands.rda")

conn <- connect_db2(dbname="veg_databases", user="miguel")

grasslands <- import_sudamerica(conn, get_countries=FALSE)

dbDisconnect(conn)

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
				c("validation_coordinates", "id_cldataveg", "remarks")]

# Re arrange slot samples
grasslands@samples <- grasslands@samples[,c("record_id", "ReleveID",
				"TaxonUsageID", "cover_percentage")]

# Adding bibliographic references
conn <- connect_db2(dbname="references_db", user="miguel")

Query <- paste0("SELECT * FROM miguel2020.main_table\n",
		"WHERE bibtexkey = 'SanMartin1998';")

Ref <- dbGetQuery(conn, Query)

dbDisconnect(conn)

veg_relation(grasslands, "data_source") <- cbind(data_source=veg_relation(grasslands,
				"data_source")$data_source,
		Ref[, apply(Ref, 2, function(x) !is.na(x))])

summary(grasslands)

# Insert this script in the package source

save(grasslands, file="../datastore/data/grasslands.rda")
