# TODO:   Import and arrangement of data set 'grasslands'
# 
# Author: Miguel Alvarez
################################################################################

library(vegtableDB)
library(biblioDB)
library(sfheaders)

conn <- connect_db(dbname = "vegetation_v3", user = "miguel")

grasslands <- db2vegtable(conn, database = "sudamerica")

DBI::dbDisconnect(conn)

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

# Get coordinates
coordinates <- sf_to_df(grasslands@relations$plot_centroid, fill = TRUE)
grasslands$longitude <- with(coordinates, x[match(grasslands$plot_centroid,
            plot_centroid)])
grasslands$latitude <- with(coordinates, y[match(grasslands$plot_centroid,
            plot_centroid)])

# Delete unnecessary headers
grasslands@header <- grasslands@header[ , !names(grasslands@header) %in%
        c("plot_centroid", "syntax_bbl_alvarez2022", "syntax_ecoveg_alvarez2022")]
grasslands <- clean(grasslands)
grasslands@syntax <- list()
grasslands

save(grasslands, file = "data/grasslands.rda")
## load("data/grasslands.rda")
