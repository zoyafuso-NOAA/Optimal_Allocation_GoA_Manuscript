###############################################################################
## Project:       True CV and RRMSE of CV across strata for each species for 
##                both optimization types
## Author:        Zack Oyafuso (zack.oyafuso@noaa.gov)
## Description:   Figure 6: Distribution of average true coefficient of 
##                variation (CV) across observed years for each species, level 
##                of sampling effort (color) and number of strata for the 
##                species-specific CV constraint approach. 
##
##                Figure 8: Distribution of average relative root mean square 
##                error (RRMSE) of the coefficient of variation (CV) across 
##                years for a subset of species (see Supplementary S7 for a 
##                full version), level of sampling effort (color) and number 
##                of strata for the species-specific CV constraint approach.
###############################################################################
rm(list = ls())

##################################################
####   Set up directories
##################################################
which_machine = c("Zack_MAC" = 1, "Zack_PC" = 2)[1]

github_dir <- paste0(c("/Users/zackoyafuso/Documents/", 
                       "C:/Users/Zack Oyafuso/Documents/")[which_machine], 
                     "GitHub/Optimal_Allocation_GoA_Manuscript/model_6g/")

figure_dir = paste0(c("/Users/zackoyafuso/", 
                      "C:/Users/Zack Oyafuso/")[which_machine],
                    "Google Drive/MS_Optimizations/",
                    "Manuscript Drafts/figure_plot/")

##################################################
####   Load Data
##################################################
load(paste0(github_dir, "optimization_data.RData"))
stratas = c(5, 10, 15, 20, 30, 60)
NStrata = length(stratas)

##################################################
##  Figure 6: Distribution of average true coefficient of variation (CV) across
##  observed years for each species, level of sampling effort (color) and 
##  number of strata for the species-specific CV constraint approach. 
##################################################
{
  png(file = paste0(figure_dir, "Fig6_True_CV.png"),
      width = 190, 
      height = 150, 
      units = "mm", 
      res = 500)
  
  par(mar = c(0.25, 4, .25, 0), 
      oma = c(4, 1, 2, 0.5), 
      mfrow = c(5, 3))
  
  load(paste0(github_dir, "Spatiotemporal_Optimization_SppSpecificCV/",
              "STRS_Sim_Res_spatiotemporal.RData" ))
  
  for (ispp in 1:ns) {
    
    max_val = max(STRS_true_cv_array[, ispp, , ]) * 1.2
    
    plot(1, 
         type = "n", 
         xlim = c(-0.5, 13.5), 
         axes = F, 
         ann = F, 
         ylim = c(0, max_val) )
    box() 
    abline(v = seq(from = 1.75, 
                   by = 2.5, 
                   length = 5), 
           lty = "dashed", 
           col = "lightgrey")
    axis(side = 2, 
         las = 1, 
         at = pretty(c(0,max_val), 3) )
    
    if (ispp == 2) legend(x = -3, 
                          y = max_val * 1.5, 
                          legend = paste(1:3, "Boat"),
                          fill = c("red", "cyan", "white"), 
                          x.intersp = .5,
                          horiz = T, 
                          xpd = NA, 
                          cex = 1.5, 
                          bty = "n")
    
    legend("top",
           legend = sci_names[ispp], 
           bty = "n", 
           xpd = NA,
           text.font = 3 )
    
    if (ispp %in% c(13:15)) axis(side = 1, 
                                 labels = stratas, 
                                 at = seq(from = 0.5, 
                                          by = 2.5, 
                                          length = 6))
    
    offset = 0
    for (istrata in 1:NStrata) {
      for (isample in 1:3) {
        boxplot( STRS_true_cv_array[, ispp, isample, istrata], 
                 add = T,
                 axes = F, 
                 at = offset, 
                 pch = 16, 
                 cex = 0.5, 
                 col = c("red", "cyan", "white")[isample])
        offset = offset + 0.5
      }
      offset = offset + 1
    }
  }
  
  
  mtext(side = 1, 
        text = "Number of Strata", 
        outer = T, 
        line = 2.5)
  mtext(side = 2, 
        "True CV", 
        outer = T, 
        line = -1)
  dev.off()
}

#################################
##  Figure 8: Distribution of average relative root mean square error (RRMSE) 
##  of the coefficient of variation (CV) across years for a subset of species 
##  (see Supplementary S7 for a full version), level of sampling effort (color) 
## and number of strata for the species-specific CV constraint approach.
#################################
{
  png(file = paste0(figure_dir, "Fig8_RRMSE_CV.png"),
      width = 190, 
      height = 120, 
      units = "mm", 
      res = 1000)
  
  layout(mat = matrix(c(1:4, 
                        8:11,
                        rep(16, 4),
                        5:7,15,
                        12:15), nrow = 4), 
         widths = c(1, 1, 0.25, 1, 1))
  
  par(mar = c(0, 0, 0, 0), 
      oma = c(4, 4, 3, 1))
  
  for (itype in 1:2) {
    load(paste0(github_dir,
                c("Spatiotemporal_Optimization_OneCV/",
                  "Spatiotemporal_Optimization_SppSpecificCV/")[itype], 
                "STRS_Sim_Res_spatiotemporal.RData" ))
    
    for (ispp in c(1,3,11,13, 9,12,15)) {
      
      max_val = c(0.60, 0.75, 0.50, 
                  0.55, 0.25, 0.50, 
                  0.50, 0.43, 0.35,
                  0.80, 0.75, 0.85,
                  0.55, 1.10, 0.55)[ispp]
      
      plot(1, 
           type = "n", 
           xlim = c(-0.5,13.5), 
           ylim = c(0, max_val),
           axes = F, 
           ann = F )
      
      box()
      abline(v = seq(from = 1.75, 
                     by = 2.5, 
                     length = 5), 
             lty = "dashed", 
             col = "darkgrey")
      if (itype == 1)
        axis(side = 2, 
             las = 1, 
             at = pretty(c(0, max_val), 3))
      
      if (itype == 2) 
        legend("topright", 
               legend = sci_names[ispp], 
               bty = "n", 
               text.font = 3 )
      if (ispp %in% c(13, 15)) 
        axis(side = 1, 
             at = seq(from = 0.5, 
                      by = 2.5, 
                      length = 6),
             labels = stratas)
      if (ispp %in% c(1, 9)) 
        mtext(side = 3, 
              text = c("One-CV\nConstraint",
                       "Spp-Specific CV\nConstraints")[itype])
      
      offset = 0
      for(istrata in 1:NStrata){
        for(isample in 1:3){
          boxplot( STRS_rrmse_cv_array[, ispp, isample, istrata], 
                   add = T,
                   axes = F, 
                   at = offset, 
                   pch = 16, 
                   cex = 0.5,
                   col = c("red", "cyan", "white")[isample] )
          offset = offset + 0.5
        }
        offset = offset + 1
      }
    }
  }
  
  plot(1, 
       type = "n", 
       xlim = c(0,1), 
       ylim = c(0,1), 
       axes = F, 
       ann = F)
  legend("bottom", 
         legend = paste0(1:3, " Boat"), 
         horiz = T, 
         cex = 1.5,
         fill = c("red", "cyan", "white"))
  plot(1, 
       type = "n", 
       axes = F, 
       ann = F)
  
  mtext(side = 1, 
        text = "Number of Strata", 
        outer = T, 
        line = 2.5)
  mtext(side = 2, 
        text = "RRMSE of CV", 
        outer = T, 
        line = 2.5)
  dev.off()
}

################################
## Supplemental S6: Distribution of average true coefficient of variation (CV)
## across observed years for each species, level of sampling effort (color) and
## number of strata for the one-CV constraint approach.
################################
{
  png(file = paste0(figure_dir, "Supplemental_Figures/SFig6_True_CV.png"),
      width = 190, 
      height = 150, 
      units = "mm", 
      res = 1000)
  
  par(mar = c(0.25, 4, 0.25, 0), 
      oma = c(4, 1, 2, 0.5), 
      mfrow = c(5, 3))
  
  load(paste0(github_dir, 
              "Spatiotemporal_Optimization_OneCV/",
              "STRS_Sim_Res_Spatiotemporal.RData"))
  
  for (ispp in 1:ns) {
    
    #Species-specific y-limits
    max_val <-  max(STRS_true_cv_array[, ispp, , ]) * 1.2
    
    #Base Plot
    plot(1, 
         type = "n", 
         xlim = c(-0.5,13.5), 
         ylim = c(0, max_val), 
         axes = F, 
         ann = F )
    box() 
    abline(v = seq(from = 1.75, 
                   by = 2.5, 
                   length = 5), 
           lty = "dashed", 
           col = "lightgrey")
    axis(side = 2, 
         las = 1, 
         at = pretty(c(0,max_val), 3) )
    
    if (ispp == 2) legend(x = -3, 
                          y = max_val * 1.4, 
                          legend = paste(1:3, "Boat"),
                          fill = c("red", "cyan", "white"), 
                          x.intersp = 0.5,
                          horiz = T, 
                          xpd = NA, 
                          cex = 1.5, 
                          bty = "n")
    
    #Species label
    legend("top", 
           legend = sci_names[ispp], 
           bty = "n", 
           text.font = 3 )
    
    if (ispp %in% c(13:15)) axis(side = 1, 
                                 labels = stratas, 
                                 at = seq(from = 0.5, 
                                          by = 2.5, 
                                          length = NStrata))
    
    offset = 0
    for (istrata in 1:NStrata) {
      for (isample in 1:nboats) {
        boxplot( STRS_true_cv_array[, ispp, isample, istrata], 
                 add = T,
                 axes = F, 
                 at = offset, 
                 pch = 16, 
                 cex = 0.5, 
                 col = c("red", "cyan", "white")[isample] )
        offset = offset + 0.5
      }
      offset = offset + 1
    }
  }
  
  #Axes Labels
  mtext(side = 1, 
        text = "Number of Strata", 
        outer = T, 
        line = 2.5)
  mtext(side = 2, 
        text = "True CV", 
        outer = T, 
        line = -1)
  dev.off()
}

################################
## Supplemental S7: Distribution of average relative root mean square error 
## (RRMSE) of the coefficient of variation (CV) across observed years for each
## species, level of sampling effort (color) and number of strata for the 
## species-specific CV constraint approach.
################################
{
  png(file = paste0(figure_dir, "Supplemental_Figures/SFig7_RRMSE_CV.png"),
      width = 190, 
      height = 230, 
      units = "mm", 
      res = 1000)
  
  layout(mat = matrix(c(1:8, 
                        16:23,
                        rep(32, 8),
                        9:15, 31,
                        24:30,31), nrow = 8), 
         widths = c(1, 1, 0.25, 1, 1))
  
  par(mar = c(0, 0, 0, 0), 
      oma = c(4, 4, 3, 1))
  
  for (itype in 1:2) {
    load(paste0(github_dir,
                c("Spatiotemporal_Optimization_OneCV/",
                  "Spatiotemporal_Optimization_SppSpecificCV/")[itype], 
                "STRS_Sim_Res_spatiotemporal.RData" ))
    
    for (ispp in 1:ns) {
      #Species-specific y-limits
      max_val = max(STRS_rrmse_cv_array[, ispp, , ]) * 1.25
      
      #Base plots
      plot(1, 
           type = "n", 
           xlim = c(-0.5,13.5), 
           axes = F, 
           ann = F, 
           ylim = c(0, max_val) )
      
      box()
      abline(v = seq(from = 1.75, 
                     by = 2.5, 
                     length = 5), 
             lty = "dashed", 
             col = "darkgrey")
      if (itype == 1) 
        axis(side = 2, 
             las = 1, 
             at = pretty(c(0, max_val), 3))
      
      if (itype == 2) 
        legend("topright", 
               legend = sci_names[ispp], 
               bty = "n", 
               text.font = 3 )
      if (ispp %in% c(8,15)) 
        axis(side = 1, 
             at = seq(from = 0.5, 
                      by = 2.5, 
                      length = NStrata),
             labels = stratas)
      if (ispp %in% c(1,9)) 
        mtext(side = 3, 
              text = c("One-CV\nConstraint",
                       "Spp-Specific CV\nConstraints")[itype])
      
      offset = 0
      for (istrata in 1:NStrata) {
        for (isample in 1:3) {
          boxplot( STRS_rrmse_cv_array[, ispp, isample, istrata], 
                   add = T,
                   axes = F, 
                   at = offset, 
                   pch = 16, 
                   cex = 0.5,
                   col = c("red", "cyan", "white")[isample] )
          offset = offset + 0.5
        }
        offset = offset + 1
      }
    }
  }
  
  #Legend
  plot(1, 
       type = "n", 
       xlim = c(0, 1), 
       ylim = c(0, 1), 
       axes = F, 
       ann = F)
  legend("bottom", 
         legend = paste0(1:3, " Boat"), 
         horiz = T, 
         cex = 1.5,
         fill = c("red", "cyan", "white"))
  plot(1, 
       type = "n", 
       axes = F, 
       ann = F)
  
  #Axes Labels
  mtext(side = 1, 
        text = "Number of Strata", 
        outer = T, 
        line = 2.5)
  mtext(side = 2, 
        text = "RRMSE of CV", 
        outer = T, 
        line = 2.5)
  dev.off()
}
