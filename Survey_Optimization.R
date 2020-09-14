###############################################################################
## Project:       Spatiotemporal Survey Optimization
## Author:        Zack Oyafuso (zack.oyafuso@noaa.gov)
## Description:   Conduct SamplingStrata R package multispecies stratified
##                survey optimization
###############################################################################
rm(list = ls())

##################################################
####    Import required packages
##################################################
library(sp)
library(RColorBrewer)
library(raster)

##################################################
####   Set up directories
####
####   Set up some constants of the optimization
####   OneCV: one CV applied to all species
####   SppSpecificCV: species-specific CV
####
####   Set up type of variance used
####   Spatial_Optimization: optimizing using spatial variance only 
####   Spatiotemporal_Optimization: optimizing using spatiotemporal variance
##################################################

which_machine <- c("Zack_MAC" = 1, "Zack_PC" = 2, "Zack_GI_PC" = 3)[2]
VAST_model <- "11" 

SamplingStrata_dir <- paste0(c("/Users/zackoyafuso/",
                               "C:/Users/Zack Oyafuso/",
                               "C:/Users/zack.oyafuso/")[which_machine],
                             "Downloads/SamplingStrata-master/R")

which_CV_method = c("OneCV", "SppSpecificCV")[1]

which_variance = c("Spatial_Optimization", "Spatiotemporal_Optimization")[1]

github_dir <- paste0(c("/Users/zackoyafuso/Documents", 
                       "C:/Users/Zack Oyafuso/Documents",
                       "C:/Users/zack.oyafuso/Work")[which_machine],
                     "/GitHub/Optimal_Allocation_GoA_Manuscript/model_", 
                     VAST_model, "/", which_variance, '_', which_CV_method, '/')

##################################################
####   Load functions from SamplingStrata packages into global environment
####   Load modified buildStrataDF function if using spatiotemporal 
####   stratum variance
##################################################
if (which_variance == "Spatiotemporal_Optimization") { 
  for (ifile in dir(SamplingStrata_dir, full.names = T)) source(ifile)
  source(paste0(dirname(dirname(github_dir)), 
                "/modified_functions/buildStrataDF_Zack.R"))
}

if (which_variance == "Spatial_Optimization") { 
  library(SamplingStrata)
}

##################################################
####   Load Data
##################################################
load(paste0(dirname(github_dir), "/optimization_data.RData"))
load(paste0(dirname(dirname(github_dir)), "/data/Extrapolation_depths.RData"))

stratas <- c(5,10,15,20,30,60)

##################################################
####  lower CV threshold
####  Set to 0.10 for all scenarios (naive assumption)
##################################################
threshold <- matrix(0.1, nrow = ns, ncol = nboats)

##################################################
####   Run optimization
##################################################
par(mfrow = c(6,6), mar = c(2,2,0,0))

for (istrata in 2) {
  
  temp_strata <- stratas[istrata]
  
  ##Initial Condition
  Run <- 1
  isample <- 1
  current_n <- 0
  
  ##Initial Upper CV constraints
  CV_constraints = rep(
    x = ifelse(which_variance == "Spatial_Optimization", 0.2, 0.4), 
    times = ns)
  
  #How much the CV should be reduced by
  creep_rate = ifelse(which_variance == "Spatial_Optimization", 0.01, 0.02)
  
  #Create CV dataframe
  cv <- list()
  for (spp in 1:ns) cv[[paste0("CV", spp)]] <- as.numeric(CV_constraints[spp])
  cv[["DOM"]] <- 1
  cv[["domainvalue"]] <- 1
  cv <- as.data.frame(cv)
  
  while(current_n <= 820){ #Run until you reach 820 samples
    
    #Set wd for output files, create a directory if it doesn"t exist yet
    temp_dir = paste0(github_dir, "Str", temp_strata, "Run",Run)
    if(!dir.exists(temp_dir)) dir.create(temp_dir)
    
    setwd(temp_dir)
    
    #Run optimization
    solution <- optimStrata(method = "continuous",
                            errors = cv, 
                            framesamp = frame,
                            iter = 200,
                            pops = 30,
                            elitism_rate = 0.1,
                            mut_chance = 1 / (temp_strata + 1),
                            nStrata = temp_strata,
                            showPlot = T,
                            parallel = F,
                            writeFiles = T)
    
    sum_stats <- summaryStrata(solution$framenew,
                               solution$aggr_strata,
                               progress=FALSE) 
    
    #Plot Solution
    goa <- SpatialPointsDataFrame(
      coords = Extrapolation_depths[,c("E_km", "N_km")],
      data = data.frame(Str_no = solution$framenew$STRATO) )
    goa_ras <- raster(goa, resolution = 5)
    goa_ras <- rasterize(x = goa, y = goa_ras, field = "Str_no")
    
    png(filename = "solution.png", width = 5, height = 5, units = "in", 
        res = 500)
    plot(goa_ras, axes = F, 
         col = terrain.colors(temp_strata)[sample(temp_strata)])
    dev.off()
    
    #Save Output
    CV_constraints <- expected_CV(strata = solution$aggr_strata)
    current_n <- sum(sum_stats$Allocation)
    isample <- ifelse(current_n < 280, 1, #1 boat
                      ifelse(current_n < 550, 2, #2 boat
                             3)) #3 boat
    result_list <- list(solution = solution, 
                        sum_stats = sum_stats, 
                        CV_constraints = CV_constraints, 
                        n = current_n)
    save(list = "result_list", file = "result_list.RData")
    
    #Set up next run by changing upper CV constraints and reduce CV constraints
    #by the creep rateabsolutely
    Run <- Run + 1
    CV_constraints <- CV_constraints - creep_rate
    
    #Apply lower threshold: if CV is lower than the threshold, set CV to 
    #to the lower theshold
    for (ispp in 1:ns) {
      CV_constraints[ispp] <- 
        ifelse(CV_constraints[ispp]<threshold[ispp, isample],
               threshold[ispp, isample],
               CV_constraints[ispp])
    }
    
    #Create CV dataframe in the formmat of SamplingStrata
    cv <- list()
    for (spp in 1:ns) cv[[paste0("CV", spp)]] <- as.numeric(CV_constraints[spp])
    cv[["DOM"]] <- 1
    cv[["domainvalue"]] <- 1
    cv <- as.data.frame(cv)
  }
}

