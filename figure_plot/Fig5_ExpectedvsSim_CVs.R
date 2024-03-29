###############################################################################
## Project:       Expected versus Simulated CVs
## Author:        Zack Oyafuso (zack.oyafuso@noaa.gov)
## Description:   Figure 5: Comparison of the relative difference between 
##                expected and realized coefficient of variation (CV) of 
##                abundance. Specifically, this shows the percent difference of 
##                the true CV relative to the upper CV constraint associated 
##                with a ten-strata, two boat of survey effort scenario 
##                (n = 550) across all included species. The left and center 
##                plots show optimizations using the one-CV constraint approach.
##                The right plot shows an optimization using the species-
##                specific CV constraint approach (refer to the main text for 
##                how CVs were specified across species). For the species-
##                specific CV constraint approach, a value of 0.10 was chosen 
##                as the lowest a CV constraint could be specified (indicated 
##                by the blue borders). Positive values indicate that the 
##                observed True CV is greater than what is expected from the 
##                optimization. Negative or near-zero values indicate that the 
##                observed true CV meets the CV expectations of the 
##                optimization. Results were qualitatively consistent with 
##                other scenarios.
###############################################################################
rm(list = ls())

############################
## Set up directories
#############################
which_machine <- c("Zack_MAC" = 1, "Zack_PC" = 2)[2]
github_dir <- paste0(c("/Users/zackoyafuso/Documents/", 
                       "C:/Users/Zack Oyafuso/Documents/")[which_machine], 
                     "GitHub/Optimal_Allocation_GoA_Manuscript/model_6g/")

figure_dir <- paste0(c('/Users/zackoyafuso/', 
                       'C:/Users/Zack Oyafuso/')[which_machine],
                     'Google Drive/MS_Optimizations/',
                     'Manuscript Drafts/figure_plot/')

load(paste0(github_dir, "optimization_data.RData"))

################
## Plot Settings
################
plot_settings = data.frame(
  path = c("Spatial_Optimization_OneCV", 
           "Spatiotemporal_Optimization_OneCV",
           "Spatiotemporal_Optimization_SppSpecificCV"),
  subtitle = c("Spatial Only\n(One-CV Constraint)", 
               "Spatiotemporal\n(One-CV Constraint)",
               "Spatiotemporal\n(Spp-Specific CV Constraints)"))

####################
{
  jpeg(filename = paste0(figure_dir, "Fig5_choke_spp.jpeg"),
      width = 170, 
      height = 100, 
      units = "mm", 
      res = 1000)
  
  par(mfrow = c(1, 3), 
      mar = c(3, 0, 3, 0), 
      oma = c(1, 12, 0, 1))
  
  for (irow in 1:3) {
    
    ## Load Data
    load(paste0(github_dir, plot_settings$path[irow], 
                "/STRS_Sim_Res_spatiotemporal.RData"))
    load(paste0(github_dir, plot_settings$path[irow],
                "/optimization_knitted_results.RData"))
    
    ## Subset out the 10-strata, 2 boat scenario
    sub_settings <- subset(settings, 
                           strata == 5)
    sample_idx <- which.min(abs(sub_settings$n - 550))
    
    cv_constraint <- unlist(sub_settings[sample_idx, paste0("CV_", 1:ns)])
    
    abs_diff <- sweep(x = STRS_true_cv_array[,, 2, 2], 
                      MARGIN = 2, 
                      STATS = cv_constraint,
                      FUN = '-')
    
    rel_diff <- 100 * sweep(x = abs_diff, 
                            MARGIN = 2, 
                            STATS = cv_constraint,
                            FUN = '/')
    
    ## Plot
    border_color <- switch(irow,
                           "1" = "black",
                           "2" = "black",
                           "3" = ifelse(cv_constraint <= 0.1, "blue", "black"))
    boxplot(rel_diff, 
            horizontal = TRUE, 
            add = F, 
            axes = F,
            pch = 16, 
            cex = 0.5, 
            ylim = c(-75,180),
            main = plot_settings$subtitle[irow],
            cex.main = 0.90,
            border = border_color)
    box()
    abline(v = 0, 
           col = "darkgrey", 
           lty = "dashed")
    axis(side = 1)
    if (irow == 1) axis(side = 2, 
                        labels = sci_names, 
                        las = 1, 
                        font = 3, 
                        at = 1:ns)
  }
  
  mtext(side = 1, 
        text = paste0("% Difference of the True CV ",
                      "Relative to the CV Constraint"), 
        outer = T, 
        line = 0)
  dev.off()
}

############################################
## Supplementary Figure
############################################
stratas = c(5, 10, 15, 20, 30, 60)
which_strata = c(2,4:6)

{
  png(filename = paste0(figure_dir, 
                        "Supplemental_Figures/SFig3_choke_spp.png"),
      width = 190, 
      height = 205, 
      units = "mm", 
      res = 500)
  
  par(mfrow = c(4, 3), 
      mar = c(0, 0, 0, 0), 
      oma = c(3.5, 12, 3.5, 1))
  
  for (istrata in which_strata) {
    for (irow in 1:3){
      
      ## Load Data
      load(paste0(github_dir, plot_settings$path[irow], 
                  "/STRS_Sim_Res_spatiotemporal.RData"))
      load(paste0(github_dir, plot_settings$path[irow],
                  "/optimization_knitted_results.RData"))
      
      ## Subset data to 2 boat, istrata strata
      sub_settings <- subset(settings, 
                             strata == stratas[istrata])
      sample_idx <- which.min(abs(sub_settings$n - 550))
      
      cv_constraint <- unlist(sub_settings[sample_idx, 
                                           paste0("CV_", 1:ns)])
      
      abs_diff <- sweep(x = STRS_true_cv_array[,, 2, 2], 
                        MARGIN = 2, 
                        STATS = cv_constraint,
                        FUN = '-')
      
      rel_diff <- 100 * sweep(x = abs_diff, 
                              MARGIN = 2, 
                              STATS = cv_constraint,
                              FUN = '/')
      
      ## Plot
      border_color <- switch(
        irow,
        "1" = "black",
        "2" = "black",
        "3" = ifelse(cv_constraint <= 0.1, "blue", "black"))
      
      boxplot(rel_diff, 
              horizontal = TRUE, 
              add = F, 
              axes = F,
              pch = 16, 
              cex = 0.5, 
              ylim = c(-75,200),
              border = border_color)
      
      if (istrata == 2) mtext(side = 3, 
                              text = plot_settings$subtitle[irow], 
                              line = 0.5,
                              cex = 0.8)
      box()
      abline(v = 0, 
             col = "darkgrey", 
             lty = "dashed")
      if (istrata == 6) axis(side = 1)
      if (irow == 1) axis(side = 2, 
                          labels = sci_names, 
                          las = 1, 
                          font = 3, 
                          at = 1:ns)
      if (irow == 2) mtext(side = 3, 
                           line = -1.5,
                           text = paste("    ", stratas[istrata], 
                                        "Strata") )
    }
    mtext(side = 1, 
          text = paste0("Percent Difference of the True CV ",
                        "Relative to the CV Constraint"), 
          outer = T, 
          line = 2.5)
  }
  dev.off()
}

