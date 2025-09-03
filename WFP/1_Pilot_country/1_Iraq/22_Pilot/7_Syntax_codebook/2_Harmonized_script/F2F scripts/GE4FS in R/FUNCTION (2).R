test.empowerment=function(country=country.list[1], data=dd1, cond.dif=10){
  t1=proc.time()
  dd=data
  if  (country %in% levels(dd$countrynew)) {
    dd=dd[dd$countrynew==country,]  
    }
    wpid=dd$WPID
    gender.var1=subset(dd,select=c(WP20036 :WP20059  ))
    # Labels
    var.labels=c("Income_No_Permission",
                 "Own_Decisions_Money",                 
                 "Own_Decisions_Medical",
                 "Own_Decisions_Relatives",
                 "Own_Decisions_Friends",
                 "Own_Bank_Account",
                 "Have_Money_Saved",
                 "Own_Property",
                 "Own_Mobile",                                                       
                 "You_Decide_Work",
                 "Took_Money_No_Permission",
                 "Permission_Local_Event",
                 "Permission_Market",          
                 "Most_Time_Housework",
                 "Housework_Prevented_Work",
                 "Housework_Prevent_Education",
                 "Decide_Prevent_Pregnancy",
                 "Harm")
    var.labels.complete=c("Had Income to Use Without Asking For Permission in Past 12 Months",
                          "Can Make Own Decisions About What to do With Money",
                          "Can Make Own Decisions About Seeking Medical or Healthcare Services",
                          "Can Make Own Decisions About Spending Time With Relatives",
                          "Can Make Own Decisions About Spending Time With Friends",
                          "Have Own Account With a Bank or Other Financial Institution",
                          "Have Money Saved To Use if Needed",
                          "Own Property Such as Land, Home, or Other Dwelling",
                          "Own a Mobile Phone",
                          "Who Decides Whether You Can Work For Pay Outside Home",
                          "Anyone in Household Took Money Earned, Received, or Saved Without Permission",
                          "Have to Get Permission to go to a Local Event Alone",
                          "Have to Get Permission to go to Market or Shops Alone",
                          "Person Who Spends the Most Time Doing Housework",
                          "Doing Housework Has Prevented Doing Paid Work in Past 12 Months",
                          "Doing Housework Has Prevented Participating in Education or Training in Past 12 Months",
                          "Able to Decide on Own About Using Methods to Prevent Pregnancy or Sexually-Transmitted Illnesses",
                          "Someone in Household Has Threatened to Harm You or Someone You Care About in Past 12 Months")
    colnames(gender.var1)=var.labels.complete
    wt=dd$wgt
    gender=dd$WP1219
    
    # Transform variables into numeric
    gender.var1[gender.var1=="(DK)" | gender.var1=="(Refused)"]=NA
    for(j in 1:ncol(gender.var1)){
      gender.var1[,j]=factor(gender.var1[,j])
    }
    gender.var2=gender.var1
    for(j in 1:ncol(gender.var1)){
      gender.var2[,j]=as.numeric(gender.var1[,j])
    }
    # Recoding all variables in the same direction (Yes=1=Positive, No=0=Negative)
    gg=gender.var2[,1:9]
    gg[gg==2]=0
    gender.var2[,1:9]=gg
    # Who Decides Whether You Can Work For Pay Outside Home
    gender.var2$`Who Decides Whether You Can Work For Pay Outside Home`[
      gender.var2$`Who Decides Whether You Can Work For Pay Outside Home`==3
    ]=0
    gender.var2$`Who Decides Whether You Can Work For Pay Outside Home`[
      gender.var2$`Who Decides Whether You Can Work For Pay Outside Home`==1
      ]=4
    gender.var2$`Who Decides Whether You Can Work For Pay Outside Home`[
      gender.var2$`Who Decides Whether You Can Work For Pay Outside Home`==2
      ]=1
    gender.var2$`Who Decides Whether You Can Work For Pay Outside Home`[
      gender.var2$`Who Decides Whether You Can Work For Pay Outside Home`==4
      ]=2
    # Anyone in Household Took Money Earned, Received, or Saved Without Permission
    gender.var2$`Anyone in Household Took Money Earned, Received, or Saved Without Permission`=
      gender.var2$`Anyone in Household Took Money Earned, Received, or Saved Without Permission`-1
    # Have to Get Permission to go to a Local Event Alone
    gender.var2$`Have to Get Permission to go to a Local Event Alone`=
      gender.var2$`Have to Get Permission to go to a Local Event Alone`-1
    # Have to Get Permission to go to Market or Shops Alone
    gender.var2$`Have to Get Permission to go to Market or Shops Alone`=
      gender.var2$`Have to Get Permission to go to Market or Shops Alone`-1
    # Person Who Spends the Most Time Doing Housework
    gender.var2$`Person Who Spends the Most Time Doing Housework`=
      gender.var2$`Person Who Spends the Most Time Doing Housework`-1
    gender.var2$`Person Who Spends the Most Time Doing Housework`[
      gender.var2$`Person Who Spends the Most Time Doing Housework`==1
    ]=3
    gender.var2$`Person Who Spends the Most Time Doing Housework`[
      gender.var2$`Person Who Spends the Most Time Doing Housework`==2
      ]=1
    gender.var2$`Person Who Spends the Most Time Doing Housework`[
      gender.var2$`Person Who Spends the Most Time Doing Housework`==3
      ]=2
    # Doing Housework Has Prevented Doing Paid Work in Past 12 Months
    gender.var2$`Doing Housework Has Prevented Doing Paid Work in Past 12 Months`=
      gender.var2$`Doing Housework Has Prevented Doing Paid Work in Past 12 Months`-1
    # Doing Housework Has Prevented Participating in Education or Training in Past 12 Months
    gender.var2$`Doing Housework Has Prevented Participating in Education or Training in Past 12 Months`=
      gender.var2$`Doing Housework Has Prevented Participating in Education or Training in Past 12 Months`-1
    # Able to Decide on Own About Using Methods to Prevent Pregnancy or Sexually-Transmitted Illnesses
    gender.var2$`Able to Decide on Own About Using Methods to Prevent Pregnancy or Sexually-Transmitted Illnesses`[
      gender.var2$`Able to Decide on Own About Using Methods to Prevent Pregnancy or Sexually-Transmitted Illnesses`==2
    ]=0
    gender.var2$`Able to Decide on Own About Using Methods to Prevent Pregnancy or Sexually-Transmitted Illnesses`[
      gender.var2$`Able to Decide on Own About Using Methods to Prevent Pregnancy or Sexually-Transmitted Illnesses`==3
    ]=NA
    # Someone in Household Has Threatened to Harm You or Someone You Care About in Past 12 Months
    gender.var2$`Someone in Household Has Threatened to Harm You or Someone You Care About in Past 12 Months`=
      gender.var2$`Someone in Household Has Threatened to Harm You or Someone You Care About in Past 12 Months`-1
    
    # Overall reliability
    alpha=alpha(gender.var2,check.keys = T)
    
    # Rasch model
    # Dichotomous data
    gender.var3=gender.var2
    gender.var3[gender.var3>1]=1
    colnames(gender.var3)=var.labels
    cat("Fitting the Rasch model")
    rr=RM.w(gender.var3,wt)

    # Rasch model by gender
    cat("Fitting the Rasch model for males")
    rr.male=RM.w(gender.var3[which(gender=="Male"),],wt[which(gender=="Male")])
    cat("Fitting the Rasch model for females")
    rr.female=RM.w(gender.var3[which(gender=="Female"),],wt[which(gender=="Female")])
    # DIF
    dif=EWaldtest(rr.male$b, rr.female$b, rr.male$se.b, rr.female$se.b)
    #
    # Comparison of men and women taking DIF into account
    unique=which(dif$p<0.01 & abs(dif$z)>cond.dif)
    scale=sd(rr.male$b[-unique])/sd(rr.female$b[-unique])
    shift=mean(rr.male$b[-unique])-mean(rr.female$b[-unique])*scale
    b.fem.resc=shift+rr.female$b*scale
    a.male=rr.male$a
    se.a.male=rr.male$a
    a.female.resc=shift+rr.female$a*scale
    se.a.female.resc=rr.female$se.a*scale
    ks.test.distr=ks.test(a.male[rowSums(gender.var3[which(gender=="Male"),])+1],
            a.female.resc[rowSums(gender.var3[which(gender=="Female"),])+1]) # Test difference in distribution
    runTime <- proc.time()-t1
    minutes <- floor(runTime[3]/60)
    seconds <- round(runTime[3])-minutes*60
    runTimeText <- paste ("Elapsed runtime =", minutes, "minutes and", seconds, "seconds")
    return(list("Rasch_total"=rr, "Rasch_male"=rr.male, "Rasch_female"=rr.female, "DIF"=dif,
            "Score_female"=a.female.resc, "KS_test_distr"=ks.test.distr, "data"=gender.var3,
            "raw_alpha"= alpha$total$raw_alpha, "std_alpha"= alpha$total$std.alpha, 
            "gender"=gender,"var.labels"=var.labels,
            "var.labels.complete"=var.labels.complete, "wpid"=wpid, "runTime" = runTimeText))
    }
