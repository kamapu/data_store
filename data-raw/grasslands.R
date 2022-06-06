# TODO:   Import and arrangement of data set 'grasslands'
# 
# Author: Miguel Alvarez
################################################################################

library(vegtableDB)
library(biblioDB)

conn <- connect_db(dbname = "vegetation_v3", user = "miguel")

grasslands <- db2vegtable(conn, database = "sudamerica")

dbDisconnect(conn)

# Subset database
grasslands <- subset(grasslands, bibtexkey  ==  "SanMartin1998",
    slot = "relations", relation = "data_source")
grasslands@species <- used_concepts(grasslands, keep_parents = TRUE)
grasslands

# Change life forms
grasslands@species@taxonTraits$life_form <-
		grasslands@species@taxonTraits$lf_elena

grasslands@species@taxonTraits <-
		grasslands@species@taxonTraits[,
				colnames(grasslands@species@taxonTraits) !=  "lf_elena"]

# Skip header information and add bibliographic information
grasslands@header <- grasslands@header[!colnames(grasslands@header) %in%
				c("validation_coordinates", "id_cldataveg", "remarks")]

# Re arrange slot samples
grasslands@samples <- grasslands@samples[,c("record_id", "ReleveID",
				"TaxonUsageID", "cover_percentage")]

save(grasslands, file = "data/grasslands.rda")
## load("data/grasslands.rda")
