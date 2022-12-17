###############################################################################
## Project:       Bias of Estimates
## Author:        Zack Oyafuso (zack.oyafuso@noaa.gov)
## Description:   Figure 7: Distribution of percent relative bias in the mean 
##                density estimate across years over all simulated surveys 
##                (11000 total) relative the true mean density for each species,
##                level of sampling effort (color) and number of strata for the 
##                species-specific CV constraint approach.
###############################################################################
rm(list = ls())

##################################################
####   Set up directories
##################################################
which_machine = c("Zack_MAC" = 1, "Zack_PC" = 2)[2]

github_dir <- paste0(c("/Users/zackoyafuso/Documents/", 
                       "C:/Users/Zack Oyafuso/Documents/")[which_machine], 
                     "GitHub/Optimal_Allocation_GoA_Manuscript/model_6g/")

figure_dir = paste0(c("/Users/zackoyafuso/", 
                      "C:/Users/Zack Oyafuso/")[which_machine],
                    "Google Drive/MS_Optimizations/Manuscript Drafts",
                    "/figure_plot/")

##################################################
####   Load Data
##################################################
load(paste0(github_dir, "optimization_data.RData"))
stratas = c(5, 10, 15, 20, 30, 60)
NStrata = length(stratas)

##################################################
####   
##################################################
{
  jpeg(file = paste0(figure_dir, "Fig7_Bias_Est.jpeg"),
      width = 170,
      height = 190,
      units = "mm",
      res = 1000)
  
  par(mar = c(0.25, 4, 0.25, 0), 
      oma = c(2, 1, 2, 0.5), 
      mfrow = c(8, 2))
  
  load(paste0(github_dir, "Spatiotemporal_Optimization_SppSpecificCV/",  
              "STRS_Sim_Res_spatiotemporal.RData") )
  
  for (ispp in 1:ns) {
    
    #Species-Specific y-limits
    temp_bias = array(dim = c(NTime, nboats, 2, Niters))
    
    for (istrata in 1:2) {
      for (iyear in 1:NTime) {
        temp_bias[iyear, , istrata, ] <-
          100 * (STRS_sim_mean[iyear, ispp, , c(3, 6)[istrata], ] -
                   true_mean[iyear, ispp]) /
          true_mean[iyear, ispp]
      }
    }
    
    
    temp_bias_quants <- apply(X = temp_bias, 
                              MARGIN = 1:3,
                              FUN = quantile,
                              probs = c(0.025, 0.25, 0.5, 0.75, 0.975))
    
    ylim_ = max(abs(temp_bias_quants[c("2.5%", "97.5%"), , , ]))
    
    #Base Plot
    plot(1, 
         type = "n", 
         xlim = c(0, 70), 
         axes = F, 
         ann = F, 
         ylim = 1.15 * c(-ylim_, ylim_) )
    abline(h = 0)
    
    for (istrata in 1:2) {
      starting_x <- (istrata-1) * 38
      xs <- starting_x:(starting_x + 10)
      
      for (isample in 1:3) {
        
        polygon(x = c(xs, rev(xs)),
                y = c(temp_bias_quants["2.5%", , isample, istrata],
                      rev(temp_bias_quants["97.5%", , isample, istrata])),
                col = c("red", "dodgerblue", "lightgrey")[isample],
                border = F)
        polygon(x = c(xs, rev(xs)),
                y = c(temp_bias_quants["25%", , isample, istrata],
                      rev(temp_bias_quants["75%", , isample, istrata])),
                col = c("brown", "blue", "darkgrey")[isample],
                border = F )
        points(x = xs,
               y = temp_bias_quants["50%", , isample, istrata], 
               pch = 15,
               cex = 0.5,
               col = rev(grey.colors(11, start = 0, end = 0.9)))
        
        xs <- max(xs):(max(xs) + 10) + 2
        
      }
      
      legend("bottom", 
             legend = sci_names[ispp], 
             bty = "n", 
             text.font = 3 )
      
      box() 
      
      axis(side = 2, 
           las = 1)
      
      
      if(ispp %in% 1:2) axis(side = 3,
                             at = c(17, 55),
                             labels = paste(c(15, 60), "Strata"))
      if(ispp %in% 15) axis(side = 1,
                            at = c(17, 55),
                            labels = paste(c(15, 60), "Strata"))
      
    }
    
    abline(v = 36, lty = "dotted", col = "darkgrey")
  }
  
  ## Legend
  par(mar = c(0, 5, 0, 2))
  plot(1,
       xlim = c(0, 1),
       ylim = c(0, 1),
       type = "n",
       axes = F,
       ann = F)
  
  ## Percentile legend
  rect(xleft = c(0.1, 0.1, 0.3, 0.3, 0.5, 0.5), 
       xright = c(0.2, 0.2, 0.4, 0.4, 0.6, 0.6),
       ybottom = c(0.0, 0.3, 0.0, 0.3, 0.0, 0.3), 
       ytop = c(0.8, 0.5, 0.8, 0.5, 0.8, 0.5),
       col =c("red", "brown", "dodgerblue", "blue", "lightgrey", "darkgrey"),
       border = F)
  points(x = c(0.15, 0.35, 0.55), 
         y = c(0.4, 0.4, 0.4), 
         pch = 15)
  
  text(x = 0,
       y = c(0.025, 0.275, 0.4, 0.525, 0.75),
       labels = paste0(c(5,25,50,75,95), "%"),
       xpd = NA)
  text(x = c(0.15, 0.35, 0.55),
       y = c(0.925, 0.925, 0.925),
       labels = paste(1:3, "Boat"),
       xpd = NA )
  
  ## Years Legend
  points(x = seq(from = 0.7, to = 1, length = 11),
         y = rep(0.5, 11),
         col = rev(grey.colors(11, start = 0, end = 0.9)),
         pch = 15,
         cex = 2)
  text(x = c(0.7, 1),
       y = 0.65,
       labels = c(1996, 2019),
       xpd = NA)
  
  mtext(side = 2, 
        text = "Percent Relative Bias", 
        outer = T, 
        line = -1)
  dev.off()
}

#######################################
##  Figure 9:
##  Bias in CV for a subset of species
#######################################

{
  jpeg(file = paste0(figure_dir, paste0("Fig9_Bias_CV.jpeg")),
      width = 170, 
      height = 150, 
      units = "mm", 
      res = 1000)
  
  layout(mat = matrix(c(1:4, 
                        8:11,
                        rep(16, 4),
                        5:7, 15,
                        12:15), nrow = 4), 
         widths = c(1, 1, 0.25, 1, 1))
  
  par(mar = c(0.25, 0, 0.25, 0), 
      oma = c(4, 4.5, 3, 1))
  
  for (itype in 1:2) {
    
    load(paste0(github_dir,
                c("Spatiotemporal_Optimization_OneCV/",
                  "Spatiotemporal_Optimization_SppSpecificCV/")[itype],
                "STRS_Sim_Res_Spatiotemporal.RData"))
    
    
    for (ispp in c(1, 3, 11, 13, 
                   8, 12, 15)) {
      
      #Species-Specific y-limits
      rel_bias = array(dim = c(NTime, nboats, 2, Niters))
      
      for (istrata in 1:2) {
        for (isample in 1:3) {
          abs_bias <- 
            sweep(x = STRS_sim_cv[, ispp, isample, c(3, 6)[istrata], ], 
                  MARGIN = 1,
                  STATS = STRS_true_cv_array[, ispp, isample, c(3, 6)[istrata]],
                  FUN = "-")
          
          rel_bias[ , isample, istrata, ] <- 
            sweep(x = abs_bias, 
                  MARGIN = 1,
                  STATS = STRS_true_cv_array[, ispp, isample, c(3, 6)[istrata]],
                  FUN = "/") * 100
          
        }
      }
      
      
      temp_bias_quants <- apply(X = rel_bias, 
                                MARGIN = 1:3,
                                FUN = quantile,
                                probs = c(0.025, 0.25, 0.5, 0.75, 0.975))
      
      ylim_ = max(abs(temp_bias_quants[c("2.5%", "97.5%"), , , ]))
      
      
      #Base Plot
      plot(1, 
           type = "n", 
           xlim = c(0, 72), 
           ylim = c(-ylim_, ylim_), 
           axes = F, 
           ann = F)
      box()
      abline(h = 0)
      abline(v = 36, lty = "dotted", col = "darkgrey")
      
      if (itype == 1) axis(side = 2, 
                           las = 1 )
      if (itype == 2) legend("bottom", 
                             legend = sci_names[ispp], 
                             bty = "n", 
                             text.font = 3  )
      
      if (ispp %in% c(1,8)) 
        mtext(side = 3, 
              text = c("One-CV\nConstraint",
                       "Spp-Specific CV\nConstraints")[itype],
              cex = 0.85)
      if(ispp %in% 13:15) 
        axis(side = 1,
             at = c(17, 55),
             labels = paste(c(15, 60), "Strata"))
      
      for (istrata in 1:2) {
        starting_x <- (istrata-1) * 38
        xs <- starting_x:(starting_x + 10)
        
        for (isample in 1:3) {
          
          polygon(x = c(xs, rev(xs)),
                  y = c(temp_bias_quants["2.5%", , isample, istrata],
                        rev(temp_bias_quants["97.5%", , isample, istrata])),
                  col = c("red", "dodgerblue", "lightgrey")[isample],
                  border = F)
          polygon(x = c(xs, rev(xs)),
                  y = c(temp_bias_quants["25%", , isample, istrata],
                        rev(temp_bias_quants["75%", , isample, istrata])),
                  col = c("brown", "blue", "darkgrey")[isample],
                  border = F )
          points(x = xs,
                 y = temp_bias_quants["50%", , isample, istrata], 
                 pch = 15,
                 cex = 0.5,
                 col = rev(grey.colors(11, start = 0, end = 0.9)))
          
          xs <- max(xs):(max(xs) + 10) + 2
          
        }
      }
    }
  }
  
  ## Legend
  par(mar = c(0, 2, 3, 2))
  plot(1,
       xlim = c(0, 1),
       ylim = c(0, 1),
       type = "n",
       axes = F,
       ann = F)
  
  ## Percentile legend
  rect(xleft = c(0.1, 0.1, 0.3, 0.3, 0.5, 0.5), 
       xright = c(0.2, 0.2, 0.4, 0.4, 0.6, 0.6),
       ybottom = c(0.0, 0.3, 0.0, 0.3, 0.0, 0.3), 
       ytop = c(0.8, 0.5, 0.8, 0.5, 0.8, 0.5),
       col =c("red", "brown", "dodgerblue", "blue", "lightgrey", "darkgrey"),
       border = F)
  points(x = c(0.15, 0.35, 0.55), 
         y = c(0.4, 0.4, 0.4), 
         pch = 15)
  
  text(x = 0,
       y = c(0.025, 0.275, 0.4, 0.525, 0.75),
       labels = paste0(c(5,25,50,75,95), "%"),
       xpd = NA)
  text(x = c(0.15, 0.35, 0.55),
       y = c(0.925, 0.925, 0.925),
       labels = paste(1:3, "Boat"),
       xpd = NA )
  
  ## Years Legend
  points(x = seq(from = 0.7, to = 1, length = 11),
         y = rep(0.5, 11),
         col = rev(grey.colors(11, start = 0, end = 0.9)),
         pch = 15,
         cex = 2)
  text(x = c(0.7, 1),
       y = 0.65,
       labels = c(1996, 2019),
       xpd = NA)
  
  mtext(side = 2, 
        text = "Percent Relative Bias", 
        outer = T, 
        line = 3)
  dev.off()
}

{
  png(file = paste0(figure_dir, "Supplemental_Figures/SFig8_Bias_Est.png"),
      width = 190,
      height = 220,
      units = "mm",
      res = 1000)
  
  par(mar = c(0.25, 4, 0.25, 0), 
      oma = c(2, 1, 2, 0.5), 
      mfrow = c(8, 2))
  
  load(paste0(github_dir, "Spatiotemporal_Optimization_OneCV/",  
              "STRS_Sim_Res_spatiotemporal.RData") )
  
  for (ispp in 1:ns) {
    
    #Species-Specific y-limits
    temp_bias = array(dim = c(NTime, nboats, 4, Niters))
    
    for (istrata in 1:4 ) {
      for (iyear in 1:NTime) {
        temp_bias[iyear, , istrata, ] <-
          100 * (STRS_sim_mean[iyear, ispp, , c(1, 2, 4, 6)[istrata], ] - 
                   true_mean[iyear, ispp]) /
          true_mean[iyear, ispp]
      }
    }
    
    temp_bias_quants <- apply(X = temp_bias, 
                              MARGIN = 1:3,
                              FUN = quantile,
                              probs = c(0.025, 0.25, 0.5, 0.75, 0.975))
    
    ylim_ = max(abs(temp_bias_quants[c("2.5%", "97.5%"), , , ]))
    
    #Base Plot
    plot(1, 
         type = "n", 
         xlim = c(0, 145), 
         axes = F, 
         ann = F, 
         ylim = 1.15 * c(-ylim_, ylim_) )
    abline(h = 0)
    
    for (istrata in 1:4) {
      starting_x <- (istrata-1) * 38
      xs <- starting_x:(starting_x + 10)
      
      for (isample in 1:3) {
        
        polygon(x = c(xs, rev(xs)),
                y = c(temp_bias_quants["2.5%", , isample, istrata],
                      rev(temp_bias_quants["97.5%", , isample, istrata])),
                col = c("red", "dodgerblue", "lightgrey")[isample],
                border = F)
        polygon(x = c(xs, rev(xs)),
                y = c(temp_bias_quants["25%", , isample, istrata],
                      rev(temp_bias_quants["75%", , isample, istrata])),
                col = c("brown", "blue", "darkgrey")[isample],
                border = F )
        points(x = xs,
               y = temp_bias_quants["50%", , isample, istrata], 
               pch = 15,
               cex = 0.5,
               col = rev(grey.colors(11, start = 0, end = 0.9)))
        
        xs <- max(xs):(max(xs) + 10) + 2
        
      }
      
      legend("bottom", 
             legend = sci_names[ispp], 
             bty = "n", 
             text.font = 3 )
      
      box() 
      
      axis(side = 2, 
           las = 1)
      
      
      if(ispp %in% 1:2) axis(side = 3,
                             at = seq(from = 17, by = 38, length = 4 ),
                             labels = paste(c(5, 10, 20, 60), "Strata"))
      if(ispp %in% 15) axis(side = 1,
                            at = seq(from = 17, by = 38, length = 4 ),
                            labels = paste(c(5, 10, 20, 60), "Strata"))
      
    }
    
    abline(v = seq(from = 36, by = 38, length = 4), 
           lty = "dotted", col = "darkgrey")
  }
  
  ## Legend
  par(mar = c(0, 5, 0, 2))
  plot(1,
       xlim = c(0, 1),
       ylim = c(0, 1),
       type = "n",
       axes = F,
       ann = F)
  
  ## Percentile legend
  rect(xleft = c(0.1, 0.1, 0.3, 0.3, 0.5, 0.5), 
       xright = c(0.2, 0.2, 0.4, 0.4, 0.6, 0.6),
       ybottom = c(0.0, 0.3, 0.0, 0.3, 0.0, 0.3), 
       ytop = c(0.8, 0.5, 0.8, 0.5, 0.8, 0.5),
       col =c("red", "brown", "dodgerblue", "blue", "lightgrey", "darkgrey"),
       border = F)
  points(x = c(0.15, 0.35, 0.55), 
         y = c(0.4, 0.4, 0.4), 
         pch = 15)
  
  text(x = 0,
       y = c(0.025, 0.275, 0.4, 0.525, 0.75),
       labels = paste0(c(5,25,50,75,95), "%"),
       xpd = NA)
  text(x = c(0.15, 0.35, 0.55),
       y = c(0.925, 0.925, 0.925),
       labels = paste(1:3, "Boat"),
       xpd = NA )
  
  ## Years Legend
  points(x = seq(from = 0.7, to = 1, length = 11),
         y = rep(0.5, 11),
         col = rev(grey.colors(11, start = 0, end = 0.9)),
         pch = 15,
         cex = 2)
  text(x = c(0.7, 1),
       y = 0.65,
       labels = c(1996, 2019),
       xpd = NA)
  
  mtext(side = 2, 
        text = "Percent Relative Bias", 
        outer = T, 
        line = -1)
  dev.off()
}

###################################
## Supplemental Figure 9 
## Bias in CV Estimate relative to True CV
###################################

{
  png(file = paste0(figure_dir,  
                    "Supplemental_Figures/SFig9_Bias_CV.png"),
      width = 190, 
      height = 220, 
      units = "mm", 
      res = 1000)
  
  par(mar = c(0.25, 4, 0.25, 0), 
      oma = c(2, 1, 2, 0.5), 
      mfrow = c(8, 2))
  
  load(paste0(github_dir, "Spatiotemporal_Optimization_OneCV/",  
              "STRS_Sim_Res_spatiotemporal.RData") )
  
  for (ispp in 1:ns) {
    
    #Species-Specific y-limits
    temp_bias = array(dim = c(NTime, nboats, 4, Niters))
    
    for (istrata in 1:4 ) {
      for (iyear in 1:NTime) {
        abs_bias <-
          sweep(x = STRS_sim_cv[iyear, ispp, , c(1, 2, 4, 6)[istrata], ], 
                STATS = STRS_true_cv_array[iyear, ispp, , c(1, 2, 4, 6)[istrata]],
                MARGIN = 1,
                FUN = "-") 
        
        temp_bias[iyear, , istrata, ] <-
          sweep(x = abs_bias, 
                STATS = STRS_true_cv_array[iyear, ispp, , c(1, 2, 4, 6)[istrata]],
                MARGIN = 1,
                FUN = "/") * 100
        
      }
    }
    
    temp_bias_quants <- apply(X = temp_bias, 
                              MARGIN = 1:3,
                              FUN = quantile,
                              probs = c(0.025, 0.25, 0.5, 0.75, 0.975))
    
    ylim_ = max(abs(temp_bias_quants[c("2.5%", "97.5%"), , , ]))
    
    #Base Plot
    plot(1, 
         type = "n", 
         xlim = c(0, 145), 
         axes = F, 
         ann = F, 
         ylim = 1.15 * c(-ylim_, ylim_) )
    abline(h = 0)
    
    for (istrata in 1:4) {
      starting_x <- (istrata-1) * 38
      xs <- starting_x:(starting_x + 10)
      
      for (isample in 1:3) {
        
        polygon(x = c(xs, rev(xs)),
                y = c(temp_bias_quants["2.5%", , isample, istrata],
                      rev(temp_bias_quants["97.5%", , isample, istrata])),
                col = c("red", "dodgerblue", "lightgrey")[isample],
                border = F)
        polygon(x = c(xs, rev(xs)),
                y = c(temp_bias_quants["25%", , isample, istrata],
                      rev(temp_bias_quants["75%", , isample, istrata])),
                col = c("brown", "blue", "darkgrey")[isample],
                border = F )
        points(x = xs,
               y = temp_bias_quants["50%", , isample, istrata], 
               pch = 15,
               cex = 0.5,
               col = rev(grey.colors(11, start = 0, end = 0.9)))
        
        xs <- max(xs):(max(xs) + 10) + 2
        
      }
      
      legend("bottom", 
             legend = sci_names[ispp], 
             bty = "n", 
             text.font = 3 )
      
      box() 
      
      axis(side = 2, 
           las = 1)
      
      
      if(ispp %in% 1:2) axis(side = 3,
                             at = seq(from = 17, by = 38, length = 4 ),
                             labels = paste(c(5, 10, 20, 60), "Strata"))
      if(ispp %in% 15) axis(side = 1,
                            at = seq(from = 17, by = 38, length = 4 ),
                            labels = paste(c(5, 10, 20, 60), "Strata"))
    }
    
    abline(v = seq(from = 36, by = 38, length = 4), 
           lty = "dotted", col = "darkgrey")
  }
  
  ## Legend
  par(mar = c(0, 5, 0, 2))
  plot(1,
       xlim = c(0, 1),
       ylim = c(0, 1),
       type = "n",
       axes = F,
       ann = F)
  
  ## Percentile legend
  rect(xleft = c(0.1, 0.1, 0.3, 0.3, 0.5, 0.5), 
       xright = c(0.2, 0.2, 0.4, 0.4, 0.6, 0.6),
       ybottom = c(0.0, 0.3, 0.0, 0.3, 0.0, 0.3), 
       ytop = c(0.8, 0.5, 0.8, 0.5, 0.8, 0.5),
       col =c("red", "brown", "dodgerblue", "blue", "lightgrey", "darkgrey"),
       border = F)
  points(x = c(0.15, 0.35, 0.55), 
         y = c(0.4, 0.4, 0.4), 
         pch = 15)
  
  text(x = 0,
       y = c(0.025, 0.275, 0.4, 0.525, 0.75),
       labels = paste0(c(5,25,50,75,95), "%"),
       xpd = NA)
  text(x = c(0.15, 0.35, 0.55),
       y = c(0.925, 0.925, 0.925),
       labels = paste(1:3, "Boat"),
       xpd = NA )
  
  ## Years Legend
  points(x = seq(from = 0.7, to = 1, length = 11),
         y = rep(0.5, 11),
         col = rev(grey.colors(11, start = 0, end = 0.9)),
         pch = 15,
         cex = 2)
  text(x = c(0.7, 1),
       y = 0.65,
       labels = c(1996, 2019),
       xpd = NA)
  
  mtext(side = 2, 
        text = "Percent Relative Bias", 
        outer = T, 
        line = -1) 
  dev.off()
}

###################################
## Supplemental Figure 10
## Bias in CV Estimate relative to True CV
###################################

{
  png(file = paste0(figure_dir,  
                    "Supplemental_Figures/SFig10_Bias_CV.png"),
      width = 190, 
      height = 220, 
      units = "mm", 
      res = 1000)
  
  par(mar = c(0.25, 4, 0.25, 0), 
      oma = c(2, 1, 2, 0.5), 
      mfrow = c(8, 2))
  
  load(paste0(github_dir, "Spatiotemporal_Optimization_SppSpecificCV/",  
              "STRS_Sim_Res_spatiotemporal.RData") )
  
  for (ispp in 1:ns) {
    
    #Species-Specific y-limits
    temp_bias = array(dim = c(NTime, nboats, 4, Niters))
    
    for (istrata in 1:4 ) {
      for (iyear in 1:NTime) {
        abs_bias <-
          sweep(x = STRS_sim_cv[iyear, ispp, , c(1, 2, 4, 6)[istrata], ], 
                STATS = STRS_true_cv_array[iyear, ispp, , c(1, 2, 4, 6)[istrata]],
                MARGIN = 1,
                FUN = "-") 
        
        temp_bias[iyear, , istrata, ] <-
          sweep(x = abs_bias, 
                STATS = STRS_true_cv_array[iyear, ispp, , c(1, 2, 4, 6)[istrata]],
                MARGIN = 1,
                FUN = "/") * 100
        
      }
    }
    
    temp_bias_quants <- apply(X = temp_bias, 
                              MARGIN = 1:3,
                              FUN = quantile,
                              probs = c(0.025, 0.25, 0.5, 0.75, 0.975))
    
    ylim_ = max(abs(temp_bias_quants[c("2.5%", "97.5%"), , , ]))
    
    #Base Plot
    plot(1, 
         type = "n", 
         xlim = c(0, 145), 
         axes = F, 
         ann = F, 
         ylim = 1.15 * c(-ylim_, ylim_) )
    abline(h = 0)
    
    for (istrata in 1:4) {
      starting_x <- (istrata-1) * 38
      xs <- starting_x:(starting_x + 10)
      
      for (isample in 1:3) {
        
        polygon(x = c(xs, rev(xs)),
                y = c(temp_bias_quants["2.5%", , isample, istrata],
                      rev(temp_bias_quants["97.5%", , isample, istrata])),
                col = c("red", "dodgerblue", "lightgrey")[isample],
                border = F)
        polygon(x = c(xs, rev(xs)),
                y = c(temp_bias_quants["25%", , isample, istrata],
                      rev(temp_bias_quants["75%", , isample, istrata])),
                col = c("brown", "blue", "darkgrey")[isample],
                border = F )
        points(x = xs,
               y = temp_bias_quants["50%", , isample, istrata], 
               pch = 15,
               cex = 0.5,
               col = rev(grey.colors(11, start = 0, end = 0.9)))
        
        xs <- max(xs):(max(xs) + 10) + 2
        
      }
      
      legend("bottom", 
             legend = sci_names[ispp], 
             bty = "n", 
             text.font = 3 )
      
      box() 
      
      axis(side = 2, 
           las = 1)
      
      
      if(ispp %in% 1:2) axis(side = 3,
                             at = seq(from = 17, by = 38, length = 4 ),
                             labels = paste(c(5, 10, 20, 60), "Strata"))
      if(ispp %in% 15) axis(side = 1,
                            at = seq(from = 17, by = 38, length = 4 ),
                            labels = paste(c(5, 10, 20, 60), "Strata"))
    }
    
    abline(v = seq(from = 36, by = 38, length = 4), 
           lty = "dotted", col = "darkgrey")
  }
  
  ## Legend
  par(mar = c(0, 5, 0, 2))
  plot(1,
       xlim = c(0, 1),
       ylim = c(0, 1),
       type = "n",
       axes = F,
       ann = F)
  
  ## Percentile legend
  rect(xleft = c(0.1, 0.1, 0.3, 0.3, 0.5, 0.5), 
       xright = c(0.2, 0.2, 0.4, 0.4, 0.6, 0.6),
       ybottom = c(0.0, 0.3, 0.0, 0.3, 0.0, 0.3), 
       ytop = c(0.8, 0.5, 0.8, 0.5, 0.8, 0.5),
       col =c("red", "brown", "dodgerblue", "blue", "lightgrey", "darkgrey"),
       border = F)
  points(x = c(0.15, 0.35, 0.55), 
         y = c(0.4, 0.4, 0.4), 
         pch = 15)
  
  text(x = 0,
       y = c(0.025, 0.275, 0.4, 0.525, 0.75),
       labels = paste0(c(5,25,50,75,95), "%"),
       xpd = NA)
  text(x = c(0.15, 0.35, 0.55),
       y = c(0.925, 0.925, 0.925),
       labels = paste(1:3, "Boat"),
       xpd = NA )
  
  ## Years Legend
  points(x = seq(from = 0.7, to = 1, length = 11),
         y = rep(0.5, 11),
         col = rev(grey.colors(11, start = 0, end = 0.9)),
         pch = 15,
         cex = 2)
  text(x = c(0.7, 1),
       y = 0.65,
       labels = c(1996, 2019),
       xpd = NA)
  
  mtext(side = 2, 
        text = "Percent Relative Bias", 
        outer = T, 
        line = -1) 
  dev.off()
}
