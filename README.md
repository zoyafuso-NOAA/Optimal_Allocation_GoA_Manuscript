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

Gadus chalcogrammus: Alaska or walleye pollock

Gadus macrocephalus: Pacific cod

Glyptocephalus zachirus: rex sole

Hippoglossoides elassodon: flathead sole

Hippoglossus stenolepis: Pacific halibut

Lepidopsetta bilineata: southern rock sole

Lepidopsetta polyxystra: northern rock sole

Microstomus pacificus: Pacific Dover sole

Sebastes alutus: Pacific ocean perch 

Sebastes melanostictus/aleutianus: blackspotted and rougheye rockfishes. Due to 
identification issues between two rockfishes these two species were combined 
into a species group we will refer as "Sebastes B_R" (blackspotted rockfish and
rougheye rockfish, respectively) hereafter. 

Limanda aspera: yellowfin sole     

Sebastes polyspinis: northern rockfish

Sebastes variabilis: dusky rockfish

Sebastolobus alascanus: shortspine thornyhead

## Input Data

The spatiotemporal domain of the survey optimization is the Gulf of Alaska 
divided into a Xnm resolution grid. This is the same grid that used as an 
extrapolation grid in the VAST package and can be accessed :

Code to get this