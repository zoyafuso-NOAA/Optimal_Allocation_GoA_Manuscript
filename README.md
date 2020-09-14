# Multispecies Stratified Survey Optimization for Gulf of Alaska Groundfishes
 
This repository is provides the code used for an In Prep manuscript by Zack S. 
Oyafuso, Lewis A.K. Barnett and Stan Kotwicki entitled "Incorporating 
spatiotemporal variability and prespecified uncertainty in the optimization of
a multispecies survey design." 

## Overview

Fisheries surveys provide valuable biological information for estimating stock
status and ...

## Species Included

The species set included in the manuscript are a complex of Gulf of Alaska
cods, flatfishes, and rockfishes:

| Scientific Name                     | Common Name                           |
|-------------------------------------|---------------------------------------|
| *Atheresthes stomias*               | arrowtooth flounder                   |
| *Gadus chalcogrammus*               | Alaska or walleye pollock             |
| *Gadus macrocephalus*               | Pacific cod                           |
| *Glyptocephalus zachirus*           | rex sole                              |
| *Hippoglossoides elassodon*         | flathead sole                         |
| *Hippoglossus stenolepis*           | Pacific halibut                       |
| *Lepidopsetta bilineata*            | southern rock sole                    |
| *Lepidopsetta polyxystra*           | northern rock sole                    |
| *Microstomus pacificus*             | Pacific Dover sole                    |
| *Sebastes alutus*                   | Pacific ocean perch                   |
| *Sebastes melanostictus/aleutianus* | blackspotted and rougheye rockfishes* |
| *Limanda aspera*                    | yellowfin sole                        |
| *Sebastes polyspinis*               | northern rockfish                     |
| *Sebastes variabilis*               | dusky rockfish                        |
| *Sebastolobus alascanus*            | shortspine thornyhead                 |

*Due to identification issues between two rockfishes these two species were 
combined into a species group we will refer as "Sebastes B_R" (blackspotted 
rockfish and rougheye rockfish, respectively) hereafter. 

## Input Data

The spatial domain of the survey optimization is the Gulf of Alaska 
divided into a Xnm resolution grid. This is the same grid that used as an 
extrapolation grid in the VAST package and can be accessed :

Code to get this

Density of each species was predicted across the spatiotemporal domain using a 
multispecies vector autoregressive spatiotemporal model using the VAST package. 
Code in the repository zoyafuso-NOAA/MS_OM_GoA/ was used to run the VAST models
and output and diagnotics can be accessed ... Gulf of Alaska bottom-trawl 
catch-per-unit area survey data were used from years 1996, 1999, and the odd
years from 2003-2019. 

Data for the optimization were synthesized in the optimization_data.R script. 
It's purpose is to take the VAST model density predictions and create an input 
dataset in the form that is used in the SamplingStrata package. The VAST output
is accessed in ... as fit.RData. Many iterations of the VAST model were run 
using different combinations of species and spatial settings and are identified
using an alphanumeric code. Details of the spatial settings used here are found
in Supplemental S1. spp_df.csv contained in the data/ directory contains the 
names of the species used for each model. For this paper, we used model 6g. 
Extrapolation_depths.RData contains a variable called Extrapolation_depths 
which is a dataframe that contains the locations, Gulf of Alaska stratum ID,
area, and depths of each grid in the spatial domain. The depth and E_km fields
are used as strata variables. The output of the script is saved as 
optimization_data.RData and contains the following variables and constants. 

| Variable Name | Description                                                                                                                        | Class Type and Dimensions      |
|---------------|------------------------------------------------------------------------------------------------------------------------------------|--------------------------------|
| ns            | Number of species in optimization                                                                                                  | numeric vector, length 1       |
| sci_names     | Scientific species names, used in plots                                                                                            | character vector, length ns    |
| nboats        | Total number of sample sizes of interest, (nboats = 3)                                                                             | numeric vector, length 1       |
| samples       | Range of sample sizes of interest, corresponding to 1 (n = 280), 2 (n = 550), and 3 (n = 820) boats                                | numeric vector, length nboats  |
| NStrata       | Total number of strata scenarios, (NStrata = 6)                                                                                    | numeric vector, length 1       |
| stratas       | Range of number of strata, (stratas = c(5, 10, 15, 20, 30, 60))                                                                    | numeric vector, length NStrata |
| N             | Total number of grid cells in the spatial domain, (N = 23339 cells)                                                                | numeric vector, length 1       |
| NTime         | Total number of years with data, (NTime = 11 years between 1996-2019)                                                              | numeric vector, length 1       |
| Niters        | Total number of times a survey is simulated, (Niters = 1000)                                                                       | numeric vector, length 1       |
| frame         | Annual mean densities for each species, longitude, and depth across grid cells                                                     | dataframe, 23339 r x 19 c      |
| frame_raw     | Densities for each species across observed years, along with longitude and depth across cells                                      | dataframe, 23339X11 R x 20 c   |
| true_mean     | True mean densities for each species and year. This is the "truth" that is used in the performance metrics when simulating surveys | dataframe, 11 r x 15 c         |


Running the script create a directory called model_6g which will contain all 
the optimization results using model 6g as the operating model. Within the  
model6g/ directory, three directories are created:

| Directory Name                            | Description                                                               |
|-------------------------------------------|---------------------------------------------------------------------------|
| Spatial_Optimization_OneCV                | Optimization using spatial variance only, one CV applied to all species   |
| Spatiotemporal_Optimization_OneCV         | Optimization using spatiotemporal variance, one CV applied to all species |
| Spatiotemporal_Optimization_SppSpecificCV | Optimization using spatiotemporal variance, CV specified for each species |

## Survey Optimization

The SamplingStrata R package is used for the optimization. 

The optimization is run over a range of number of stratas from 5 to 60. Each 
run of the optimization is saved in its own directory with the code template of
StrXRunY where X is the number of strata in the solution and Y is the run 
number. Within each run folder contains:

| File Name            | Description                                                         |
|----------------------|---------------------------------------------------------------------|
| output/plotdom1.png  | Genetic algorithm results                                           |
| output/outstrata.txt | Stratum-level means and variances for each species                  |
| solution.png         | Low-quality snapshot of the solution mapped onto the spatial domain |
| result_list.RData    | Result workspace of the optimization                                |

The result_list.RData workspace contains a named list called result_list, which
consists of the elements:

| Variable Name                    | Description                                                                                                         | Class Type and Dimensions                     |
|----------------------------------|---------------------------------------------------------------------------------------------------------------------|-----------------------------------------------|
| result_list$solution$indices     | Solution indexed by strata, contained in the X1 column                                                              | dataframe, N rows and 2 columns               |
| result_list$solution$aggr_strata | Stratum-level means and variances for each species                                                                  | dataframe, variable number of rows, 9 columns |
| result_list$solution$frame_new   | Original data, along with the solution in the STRATO column.                                                        | dataframe, N rows and 21 columns              |
| result_list$sum_stats            | Characteristics of the optimized strata, e.g., allocated sampling, population size, strata variable characteristics |                                               |
| result_list$CV_constraints       | Expected CV across species                                                                                          | numeric vector, length ns                     |
| result_list$n                    | Optimized total sample size                                                                                         | numeric, length 1                             |

## Knitting Together Optimization Results

The results from each run are synthesized in the knitting_runs.R script. Four
variables are saved in the optimization_knitted_results.RData workspace:

| Variable Name     | Description                                                                 | Class Type and Dimensions                     |
|-------------------|-----------------------------------------------------------------------------|-----------------------------------------------|
| settings          | Optimized strata and expected CV for each species and number of strata      | dataframe, variable number of rows, 19 c      |
| res_df            | Solutions for each run                                                      | dataframe, N rows, variable number of columns |
| strata_list       | Collection of result_list$solution$aggr_strata from each run                | list of variable length                       |
| strata_stats_list | Collection of stratum-level means and variances across species for each run | list of variable length                       |

## Survey Simulation and Perforamnce Metrics
The Simulate_Opt_Survey.R script takes the knitted results and the optimization
data and simulates surveys, then calculates stratum means and vaiances. True 
CV, RRMSE of CV, and bias are calculated on the simulated surveys. The output
consists of six variables saved to workspace STRS_Sim_Res_spatiotemporal.RData:

| Variable Name  | Description                                                                        | Class Type and Dimensions                                  |
|----------------|------------------------------------------------------------------------------------|------------------------------------------------------------|
| sim_mean       | Simulated survey estimates of mean density                                         | Array with dimensions (NTime, ns, nboats, NStrata, Niters) |
| sim_cv         | Simulated survey estimate of CV                                                    | Array with dimensions (NTime, ns, nboats, NStrata, Niters) |
| true_cv_array  | True CV                                                                            | Array with dimensions (NTime, ns, nboats, NStrata)         |
| rrmse_cv_array | Relative root mean square error of the CV estiamte                                 | Array with dimensions (NTime, ns, nboats, NStrata)         |
| rel_bias_est   | Relative percent bias of survey estimates of mean density relative to true density | Array with dimensions (NTime, ns, nboats, NStrata)         |
| rel_bias_cv    | Relative percent bias of survey estimates of CV relative to true CV                | Array with dimensions (NTime, ns, nboats, NStrata)         |

## Figures

Figure 1: 