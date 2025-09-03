load("BF_Analysis_Feb2025.RData")


#Assignment Definitions
#burk$Assignment=0
#burk$Assignment[burk$Modality==1 & burk$Form==1]=1
#burk$Assignment[burk$Modality==1 & burk$Form==2]=2
#burk$Assignment[burk$Modality==2 & burk$Form==1]=3
#burk$Assignment[burk$Modality==2 & burk$Form==2]=4


#fes_inc_comp_burk_F2F_long.1=xtabs(~as_factor(HHIncFirst_SRi)+I(CARI_Inc<FES_Cat),data=burk[burk$Assignment==1,])
#fes_inc_comp_burk_F2F_long.2=xtabs(~as_factor(HHIncFirst_SRi)+I(CARI_Inc==FES_Cat),data=burk[burk$Assignment==1,])
#fes_inc_comp_burk_F2F_long.3=xtabs(~as_factor(HHIncFirst_SRi)+I(CARI_Inc>FES_Cat),data=burk[burk$Assignment==1,])

#fes_inc_comp_burk_F2F_long=as.data.frame(cbind(fes_inc_comp_burk_F2F_long.1[,2],fes_inc_comp_burk_F2F_long.2[,2],fes_inc_comp_burk_F2F_long.3[,2]))
#names(fes_inc_comp_burk_F2F_long)=c("Inc<FES","Inc=FES","Inc>FES")


#fes_inc_comp_burk_F2F_short.1=xtabs(~as_factor(HHIncFirst_SRi)+I(CARI_Inc<FES_Cat),data=burk[burk$Assignment==2,])
#fes_inc_comp_burk_F2F_short.2=xtabs(~as_factor(HHIncFirst_SRi)+I(CARI_Inc==FES_Cat),data=burk[burk$Assignment==2,])
#fes_inc_comp_burk_F2F_short.3=xtabs(~as_factor(HHIncFirst_SRi)+I(CARI_Inc>FES_Cat),data=burk[burk$Assignment==2,])

#fes_inc_comp_burk_F2F_short=as.data.frame(cbind(fes_inc_comp_burk_F2F_short.1[,2],fes_inc_comp_burk_F2F_short.2[,2],fes_inc_comp_burk_F2F_short.3[,2]))
#names(fes_inc_comp_burk_F2F_short)=c("Inc<FES","Inc=FES","Inc>FES")

#fes_inc_comp_burk_remote_long.1=xtabs(~as_factor(HHIncFirst_SRi)+I(CARI_Inc<FES_Cat),data=burk[burk$Assignment==3,])
#fes_inc_comp_burk_remote_long.2=xtabs(~as_factor(HHIncFirst_SRi)+I(CARI_Inc==FES_Cat),data=burk[burk$Assignment==3,])
#fes_inc_comp_burk_remote_long.3=xtabs(~as_factor(HHIncFirst_SRi)+I(CARI_Inc>FES_Cat),data=burk[burk$Assignment==3,])

#fes_inc_comp_burk_remote_long=as.data.frame(cbind(fes_inc_comp_burk_remote_long.1[,2],fes_inc_comp_burk_remote_long.2[,2],fes_inc_comp_burk_remote_long.3[,2]))
#names(fes_inc_comp_burk_remote_long)=c("Inc<FES","Inc=FES","Inc>FES")

#fes_inc_comp_burk_remote_short.1=xtabs(~as_factor(HHIncFirst_SRi)+I(CARI_Inc<FES_Cat),data=burk[burk$Assignment==4,])
#fes_inc_comp_burk_remote_short.2=xtabs(~as_factor(HHIncFirst_SRi)+I(CARI_Inc==FES_Cat),data=burk[burk$Assignment==4,])
#fes_inc_comp_burk_remote_short.3=xtabs(~as_factor(HHIncFirst_SRi)+I(CARI_Inc>FES_Cat),data=burk[burk$Assignment==4,])

#fes_inc_comp_burk_remote_short=as.data.frame(cbind(fes_inc_comp_burk_remote_short.1[,2],fes_inc_comp_burk_remote_short.2[,2],fes_inc_comp_burk_remote_short.3[,2]))
#names(fes_inc_comp_burk_remote_short)=c("Inc<FES","Inc=FES","Inc>FES")

ct.pct.tab=function(tab)
{
sumtab=as.data.frame(matrix(0,nrow(tab),2))
sumtab[,1]=rowSums(tab)
sumtab[,2]=round(tab[,1]/rowSums(tab),2)
names(sumtab)=c("Survey Count","Proportion Inc_Cat<FES_Cat")
row.names(sumtab)=row.names(tab)
return(sumtab)
}


burk.1=ct.pct.tab(fes_inc_comp_burk_F2F_long)
burk.2=ct.pct.tab(fes_inc_comp_burk_F2F_short)
burk.3=ct.pct.tab(fes_inc_comp_burk_remote_long)
burk.4=ct.pct.tab(fes_inc_comp_burk_remote_short)
#Get rid of HHs coded "16"
burk.3=burk.3[-16,]
burk.4=burk.4[-16,]
burk.agg=as.data.frame(cbind(burk.1,burk.2,burk.3,burk.4))

burk.resp.dist=burk.afgg[,c(1,3,5,7)]
burk.resp.tot=colSums(burk.resp.dist)
burk.resp.pct=burk.resp.dist
for(i in 1:4){burk.resp.pct[,i]=100*round(burk.resp.dist[,i]/burk.resp.tot[i],3)}
#Delete rows with no respondents
burk.resp.pct=burk.resp.pct[rowSums(burk.resp.pct)>0,]
names(burk.resp.pct)=c("F2F/Long","F2F/Short","Remote/Long","Remote/Short")

library(lattice)
barchart(t(burk.resp.pct),col=rainbow(14),
main="Livelihood Distribution by Modality in Burkina Faso",xlab=list(label="Percentage of Respondents",cex=1.2),scales=list(cex=c(1.2,1.2)),
key= list(space="bottom",text=list(row.names(burk.resp.pct)),border=T, cex=1.2,rectangles=list(col=rainbow(14))))


burk$AssignLab=0
burk$AssignLab[burk$Assignment==1]="F2F/Long"
burk$AssignLab[burk$Assignment==2]="F2F/Short"
burk$AssignLab[burk$Assignment==3]="Remote/Long"
burk$AssignLab[burk$Assignment==4]="Remote/Short"

mosaicplot(xtabs(~AssignLab+as_factor(EnuSex)+as_factor(RESPSex),data=burk),col=c("yellow","blue"),xlab="Respondent Gender",ylab="Enumerator Gender",main="Enumerator and Respondent Gender by Assignment Group")


#Work with the subset of med/large farmers
burk.medag=burk[burk$HHIncFirst_SRi==15,]
library(lmer)
library(lmerTest)
mod.fcs.medag=lmer(FCS~as_factor(Modality)+(1|EnuName)+(1|ADMIN5Name),data=burk.medag)
summary(mod.fcs.medag)

par(mfrow=c(1,2))
boxplot(FCS~Modality,data=burk.medag,ylim=c(0,80),col="orange",main="Original FCS Distribution by Modality for Med/Large Agriculture Livelihood")
boxplot(fitted(mod.fcs.medag)~Modality,data=burk.medag[!is.na(burk.medag$FCS),],ylab="FCS Model Estimates",col="blue",ylim=c(0,80),main="Fitted Values with Random Effects for Enumerator and Location")

#FES analysis
#replace 88 values set to "0" with NA as modules were not completed for these HHs
burk.medag$FES.na=burk.medag$FES
burk.medag$FES.na[burk.medag$FES==0]=NA

#best-fitting model with random effects for enumerator and locality and fixed effects for Resp. Sex and interaction between Assignment and Age
mod.fes.re=lmer(formula = FES.na ~ AssignLab * RESPAge + as_factor(RESPSex) + (1 | EnuName) + (1 | ADMIN5Name), data = burk.medag)


par(mfrow=c(1,2))
boxplot(FES~AssignLab,data=burk.medag,col="orange",ylim=c(0,1),xlab="Assignment",main="Original FES Distribution by Assignment for Med/Large Agriculture Livelihood")
boxplot(fitted(mod.fes3.re)~AssignLab,ylim=c(0,1),data=burk.medag[!is.na(burk.medag$FES.na),],xlab="Assignment",ylab="FES Model Estimates",col="blue",main="Fitted Values from Mixed Effects Model")

 
#HHS

lapply(split(burk.medag$HHSNoFood,burk.medag$AssignLab),summary)


mod.hhs.1.re=glmer(formula = HHSNoFood ~ AssignLab + (1 | EnuName) + (1 | ADMIN5Name), data = burk.medag, family = "binomial")
#Sig increase for remote/short and remote/long HHs


mod.hhs.2.re=glmer(formula = HHSBedHung ~ AssignLab + (1|EnuName) + (1|ADMIN5Name),data=burk.medag,family="binomial")
#No sig differences

mod.hhs.3.re=glmer(formula = HHSNotEat ~ AssignLab + (1|EnuName) + (1|ADMIN5Name),data=burk.medag,family="binomial")
#sig increase for remote/short only

mosaicplot(xtabs(~AssignLab+I(fitted(mod.hhs.1.re)>0.5),data=burk.medag[!is.na(burk.medag$HHSNoFood),]),col=c("blue","orange"),
xlab="Assignment",ylab="Estimated Proportion of HHs",main="Estimated Proportion of Med/Large Agr. Households without Food by Assignment")


#CARI Income Indicator

xtabs(~HHInc_Change_None+AssignLab,data=burk.medag)

#No sig differences after accounting for enumerator and locality effects
mod.incnc.re=glmer(formula = HHInc_Change_None ~ AssignLab + (1 | EnuName) + (1 | ADMIN5Name), data = burk.medag, family = "binomial")

#Coping

#Look at proportion of HHs reporting any basic coping:
mod.rcsi.any=glm( I(rCSI>0)~AssignLab,data=burk.medag,family="binomial")
#Initial data show higher percentage of F2F households reporting some kind of coping

mod.rcsi.any.re=glmer( I(rCSI>0)~AssignLab+(1|EnuName)+(1|ADMIN5Name),data=burk.medag,family="binomial")
#No sig. modality-associated differences after accounting for enumerator and locality effects





