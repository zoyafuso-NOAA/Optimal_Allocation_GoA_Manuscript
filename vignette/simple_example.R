###############################################################################
## Project:       Simple Optimization Example
## Author:        Zack Oyafuso (zack.oyafuso@noaa.gov)
## Description:   Run a very simple and short optimization on Gulf of Alaska
##                groundfishes. This is a reduced form of the actual 
##                multispecies optimization.
##
##                For the "spatiotemporal" option, download the SamplingStrata
##                package from GitHub and note the location of that directory
##                in the SamplingStrata_dir variable:
##                (https://github.com/barcaroli/SamplingStrata). I haven't 
##                found a neater way to insert my own functions into the package
##                so this is the slightly messy workaround until then. 
###############################################################################
rm(list = ls())

##################################################
####   Import Libaries
##################################################
library(sp)
library(raster)
library(RColorBrewer)

##################################################
####   Setup Directories
##################################################
github_dir <- paste0("C:/Users/Zack Oyafuso/Documents/GitHub",
                     "/Optimal_Allocation_GoA_Manuscript/")

SamplingStrata_dir <- paste0( "C:/Users/Zack Oyafuso/Downloads/",
                              "SamplingStrata-master/R/")

##################################################
####   Optimization Settings
####   Which stratum variance to use?
##################################################
which_variance <- c("Spatial", "Spatiotemporal")[1]

##################################################
####   Import Libraries
##################################################
if (which_variance == "Spatial") {
  library(SamplingStrata)
}

if (which_variance == "Spatiotemporal") { 
  
  for (ifile in dir(SamplingStrata_dir, full.names = T)) source(ifile)
  
  source(paste0(github_dir, "/modified_functions/buildStrataDF_Zack.R"))
  
}

##################################################
####   Load Data
##################################################
load(paste0(github_dir, "model_6g/optimization_data.RData"))
load(paste0(github_dir, "/data/Extrapolation_depths.RData"))

##################################################
####   For computation, we'll just use one species
####   frame_raw is only used for the spatiotemporal variance option
####   frame is only used for the spatial variance
##################################################
ns <- 1
frame <- frame[, c("id", "X1", "X2", "Y1", "domainvalue")]
frame_raw <- frame_raw[, c("id", "X1", "X2", "Y1", "year", "domainvalue")]

##################################################
####   Set CV constraints dataframe
##################################################
CV_constraints = 0.10
#Create CV dataframe
cv <- list()
for (spp in 1:ns) cv[[paste0("CV", spp)]] <- as.numeric(CV_constraints[spp])
cv[["DOM"]] <- 1
cv[["domainvalue"]] <- 1
cv <- as.data.frame(cv)

##################################################
####   Run optimization
####   If you want to save the output, first setwd() to the directory you want
####   the output saved to, then turn the writeFiles argumenet to TRUE
####   Iterations are set to 20 for speed but in practice should be in the 
####   hundreds. Population size is 10 for speed but in practice should be 
####   higher (e.g., 30 or 50). 
####
##################################################
num_of_strata = 5

if(which_variance == "Spatial"){
  solution <- SamplingStrata::optimStrata(method = "continuous",
                                          errors = cv, 
                                          framesamp = frame,
                                          iter = 20,
                                          pops = 10,
                                          elitism_rate = 0.1,
                                          mut_chance = 1 / (num_of_strata + 1),
                                          nStrata = num_of_strata,
                                          showPlot = T,
                                          parallel = F,
                                          writeFiles = F)
}

if(which_variance == "Spatiotemmporal"){
  solution <- optimStrata(method = "continuous",
                          errors = cv, 
                          framesamp = frame,
                          iter = 20,
                          pops = 10,
                          elitism_rate = 0.1,
                          mut_chance = 1 / (num_of_strata + 1),
                          nStrata = num_of_strata,
                          showPlot = T,
                          parallel = F,
                          writeFiles = F)
}

##################################################
####   Save Stratum Characteristcs (sum_stats), optimized CV (opt_CV)
####   and which cells belong to each stratum (solution_by_strata)
##################################################
sum_stats <- summaryStrata(solution$framenew,
                           solution$aggr_strata,
                           progress=FALSE) 

opt_CV <- expected_CV(strata = solution$aggr_strata)
solution_by_strata <- solution$framenew$STRATO

##################################################
####   Plot Solution (approximately)
##################################################
goa <- sp::SpatialPointsDataFrame(
  coords = Extrapolation_depths[, c("E_km", "N_km")],
  data = data.frame(Str_no = solution_by_strata) )
goa_ras <- raster::raster(goa, 
                          resolution = 5)
goa_ras <- raster::rasterize(x = goa, 
                             y = goa_ras, 
                             field = "Str_no")

plot(goa_ras, 
     axes = F, 
     col = brewer.pal(name = "Paired", n = 5))

