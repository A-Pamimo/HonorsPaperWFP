#' ---
#' title: "IRT Analysis of GE4FS module: `r countryName`"
#' author: "Authors: Sara Viviani & Pablo Diego-Rosell"
#' date: "This notebook was produced on: `r format(Sys.time(), '%d %B, %Y')`"
#' ---
# Contact Sara.Viviani@fao.org or pablo_diego-rosell@gallup.co.uk for questions about this script

# Sample size
if  (countryName %in% levels(dd1$countrynew)) 
{table(dd1$countrynew[dd1$countrynew==countryName])[countryName]
} else {table(dd1$countrynew)}

# Fit model
test.Country <- test.empowerment(countryName, data=dd1)

# Model fitting processing time 
test.Country$runTime

## IRT outputs

# Chronbach alpha
test.Country$raw_alpha

# Chronbach alpha STD (It should be >0.7) 
test.Country$std_alpha

# Rasch model on the total sample
# Infit should be between 0.7 and 1.3 to indicate equal discrimination of items; 
# Severity indicates severity parameters for each question
rr=test.Country$Rasch_total
round(cbind("Severity"=rr$b,"SE"=rr$se.b,"Infit"=rr$infit,"Outfit"=rr$outfit),2)

# Rasch reliability (should be > 0.7)
rr$reliab.fl

# Save residual correlation matrix (should be <0.35 in absolute value to indicate unidimensionality)
write.csv(round(rr$res.corr,2), file=paste(countryName,"/Residual_Correlations_",countryName,".csv",sep =""))

# Screeplot of the residuals should be smoothly decreasing (no big jump) to indicate unidimensionality
screeplot(princomp(rr$mat.res),type="l", main="Screeplot of PCA on residuals") 

# Rasch model by gender
rr.male=  test.Country$Rasch_male
rr.female=  test.Country$Rasch_female
tab.male=round(cbind("Severity"=rr.male$b,"SE"=rr.male$se.b,"Infit"=rr.male$infit,"Outfit"=rr.male$outfit),2)
tab.female=round(cbind("Severity"=rr.female$b,"SE"=rr.female$se.b,"Infit"=rr.female$infit,"Outfit"=rr.female$outfit),2)
rownames(tab.male)=substr(rownames(tab.male),4,15)
par(mfrow=c(1,2))

#' Screeplot of residuals for males
screeplot(princomp(rr.male$mat.res),type="l",main="Screeplot of PCA on residuals - Males")

#' Screeplot of residuals for females
screeplot(princomp(rr.female$mat.res),type="l",main="Screeplot of PCA on residuals - Females")

# DIF by gender
# Visual inspection: Items farther away from the diagonal show greater DIF

plot(rr.male$b,rr.female$b, xlab="Male",ylab="Female",pch=16,col="blue",
     xlim=range(rr.male$b,rr.female$b)*1.2,
     ylim=range(rr.male$b,rr.female$b)*1.2, 
     main="DIF by gender")
text(rr.male$b,rr.female$b,srt=45,pos=1, labels=names(rr.male$b), 
     cex=.7)
abline(c(0,1))

# Test DIF by item
# P-values <0.05 indicate significant difference in estimated item severities between males and females
test.Country$DIF$tab

# Empowerment distribution by gender
# Includes Kolmogorov-Smirnov test to explore difference in distribution between males and females 
#'    
a.male = rr.male$a
gender.var3 = test.Country$data
gender = test.Country$gender
a.female.resc=  test.Country$Score_female
plot(density(a.male[rowSums(gender.var3[which(gender=="Male"),])+1], na.rm=T), col="blue",
     main="Empowerment distribution", ylim=c(0,1))
lines(density(a.female.resc[rowSums(gender.var3[which(gender=="Female"),])+1], na.rm=T), col=2)
legend("topright", lty=1,col=c("blue","red"),legend=c("Male","Female"),
       cex=.8,bty="n",x.intersp = 0.5)
text(1.2, 0.6, paste ("K-S test p",
                      format.pval(test.Country$KS_test_distr$p.value, 
                                  digits = 2, 
                                  eps = 0.001, 
                                  nsmall = 3), 
                      sep =""), 
     cex=0.7)

test.Country$KS_test_distr

# Associate scores to individuals in the sample

scores=matrix(NA, nrow(gender.var3), 1)
rs=rowSums(gender.var3)
for(i in 1:nrow(scores)){
  if(gender[i]=="Male"){
    scores[i]=a.male[rs[i]+1]
  } else{
    scores[i]=a.female.resc[rs[i]+1]
  }
}

# Write a file with individual scores
write.csv(data.frame("WPID"=  test.Country$wpid, "Scores"=scores),
          file=paste(countryName, "/Individual_Scores_", countryName, ".csv", sep =""), 
          row.names = F)
