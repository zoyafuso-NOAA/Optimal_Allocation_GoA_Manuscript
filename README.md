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

