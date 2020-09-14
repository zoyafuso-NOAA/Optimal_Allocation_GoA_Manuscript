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

*Atheresthes stomias*: arrowtooth flounder

*Gadus chalcogrammus*: Alaska or walleye pollock

*Gadus macrocephalus*: Pacific cod

*Glyptocephalus zachirus*: rex sole

*Hippoglossoides elassodon*: flathead sole

*Hippoglossus stenolepis*: Pacific halibut

*Lepidopsetta bilineata*: southern rock sole

*Lepidopsetta polyxystra*: northern rock sole

*Microstomus pacificus*: Pacific Dover sole

*Sebastes alutus*: Pacific ocean perch 

*Sebastes melanostictus/aleutianus*: blackspotted and rougheye rockfishes. Due 
to identification issues between two rockfishes these two species were combined 
into a species group we will refer as "Sebastes B_R" (blackspotted rockfish and
rougheye rockfish, respectively) hereafter. 

*Limanda aspera*: yellowfin sole     

*Sebastes polyspinis*: northern rockfish

*Sebastes variabilis*: dusky rockfish

*Sebastolobus alascanus*: shortspine thornyhead

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
optimization_data.RData and contains the following variables. 

frame: dataframe of annual mean densities for each species, longitude, and depth 
across grid cells. The dimension is 23339 rows and X columns

frame_raw: dataframe of densities for each species across time, along with the
longitude, and depth of the grid cells. The dimension is 23339x11 rows and X 
columns.

Since this is a workspace that is called up in many other scripts, various 
constants are defined in this script, including: 

true_mean: matrix of mean density for each species and year. This is the 
"truth" that is used to in the performance metrics when simulating surveys. 
Dimension X x X.

sci_names: vector of scientific names for species, used in plots. Length of 15,
saved as the variable ns.

samples: vector of sample sizes corresponding to 1 (n = 280), 2 (n = 550), and 
3 (n = 820) boats. Length of 3, saved as the variable nboats

Niters: numeric, number of times a survey is simulated, set to 1000. 

NTime: numeric, number of years with data, 11 years. 

N: numeric, number of grid cells in the spatial domain, 23339 cells. 

Running the script create a directory called model_6g which will contain all 
the optimization results using model 6g as the operating model. Within this 
directory, three directories are created:

Spatial_Optimization_OneCV: Optimization using spatial variance only, one CV 
applied to all species

Spatiotemporal_Optimization_OneCV: Optimization using spatiotemporal variance, 
one CV applied to all species

Spatiotemporal_Optimization_OneCV: Optimization using spatiotemporal variance, 
one CV applied to all species

This strategy is useful if you are comparing how the optimization results change
with different operating models. 

## Survey Optimization

The SamplingStrata R package is used for the optimization. 

The optimization is run over a range of number of stratas from 5 to 60. Each 
run of the optimization is saved in its own directory with the code template of
StrXRunY where X is the number of strata in the solution and Y is the run 
number. Within each run folder contains:

output/plotdom1.png: genetic algorithm results
outstrata.txt: text file of stratum-level means and variances for each species

solution.png: low-quality snapshot of the solution mapped onto the spatial 
domain

result_list.RData: contains the result of the optimization stored in a named
list called result_list, which contains four sublists:

1) solution: list of three elements: 

1a) indices: dataframe of the solution contained in X1.

1b) aggr_strata: dataframe with strata-level means and variances for each 
species.

1c) frame_new: dataframe that contains the original data, along with the 
solution in the STRATO column.

2) sum_stats: dataframe containing characteristics of the optimized strata, 
e.g., allocated sampling, population size, strata variable characteristics.

3) CV_contraints: vector of CVs from the optimization, of length ns.

4) n: numeric, optimized sample size. 

## Knitting Together Optimization Results

The results from each run are synthesized in the knitting_runs.R script. Four
variables are saved in the optimization_knitted_results.RData workspace:

1) settings: dataframe, contains optimized strata and expected CVs from 
optimization for each species and number of stratas.

2) res_df: data.frame of solutions for each run.

3) strata_list: list of result_list$solution$aggr_strata from each run.

4) strata_stats_list: list of strata-level means and variances across species
for each run.

## Survey Simulation and Perforamnce Metrics
The Simulate_Opt_Survey.R script takes the knitted results and the optimization
data and simulates surveys, then calculates stratum means and vaiances. True 
CV, RRMSE of CV, and bias are calculated on the simulated surveys. The output
consists of X variables saved to workspace 

1) sim_mean: Simulated survey estimates of mean density. Array with dimensions 
(NTime, ns, nboats, NStrata, Niters).

2) sim_cv: Simulated survey estimate of CV. Array with dimensions (NTime, ns, 
nboats, NStrata, Niters).

3) true_cv_array: True CV. Array with dimensions (NTime, ns, nboats, NStrata).

4) rrmse_cv_array: Relative root mean square error of the CV estiamte. Array 
with dimensions (NTime, ns, nboats, NStrata).

5) rel_bias_est: Relative percent bias of survey estimates of mean density
relative to true density. Array with dimensions (NTime, ns, nboats, NStrata).

6) rel_bias_cv: Relative percent bias of survey estimates of CV relative to 
true CV. Array with dimensions (NTime, ns, nboats, NStrata).

## Figures