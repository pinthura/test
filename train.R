library(dplyr)
library(ggplot2)
library(plyr)
library(tidyr)
library(sqldf)
library(faraway)
library(gmodels)
library(sjPlot)
library(snakecase)
library(car)
library(OneR)

tr <- read.csv("D:/enova/Assessment_Files/Assessment Files/training.csv")
attach(tr)
tr$profit <- tr$Retail-tr$Price
#=============
#data cleaning
#=============
tr$Measurements1<-gsub("[x,*,X,+,-]", ",", tr$Measurements)
tr1 <- separate(tr,Measurements1,sep=",", c("len", "wid", "dep"))
tr2 <- transform(tr1, len = as.numeric(len), wid = as.numeric(wid), dep = as.numeric(dep))

tr2$color1 <- substr(tr2$Color,1,1)
aggregate(tr2$len, list(tr2$color1), FUN=mean)
tr2$color1<-as.factor(tr2$color1)

aggregate(tr2$len, list(tr2$Clarity), FUN=mean)
tr2$Clarity1[tr2$Clarity1 == list("N","None")] <- "NA"
aggregate(tr2$len, list(tr2$Clarity1), FUN=mean)
tr2$Clarity1<-as.factor(tr2$Clarity1)

sqldf('Select cut, Polish, count(x) from tr2 group by 1,2') 

tr2$Depth[tr2$Depth == "0"] <- NA
tr2$Table[tr2$Table == "0"] <- NA
ggplot(tr2, aes(x=Depth, y=Table)) + geom_point(shape=1) + geom_smooth(method=lm)

tr2$Shape1<-as.character(tr2$Shape)
tr2$Shape1<-revalue(tr2$Shape1, c("Marwuise"="Marquise", "Marquis"="Marquise", "Oval "="Oval", "ROUND"="Round"))
aggregate(tr2$len, list(tr2$Shape1), FUN=mean)
tr2$Shape1<-as.factor(tr2$Shape1)

tr2$Symmetry1<-as.character(tr2$Symmetry)
tr2$Symmetry1<-revalue(tr2$Symmetry1, c("Execllent"="Excellent", "Faint"="Fair"))
aggregate(tr2$len, list(tr2$Symmetry1), FUN=mean)
tr2$Symmetry1<-as.factor(tr2$Symmetry1)

tr2$Fluroescence1<-as.character(tr2$Fluroescence)
tr2$Fluroescence1[tr2$Fluroescence1 == " "] <- NA
aggregate(tr2$len, list(tr2$Fluroescence1), FUN=mean)
tr2$Fluroescence1<-as.factor(tr2$Fluroescence1)

tr2$profit_flg<-ifelse(tr2$profit>0,"1","0")
tr2$profit_flg<-as.factor(tr2$profit_flg)
tr2$Vendor<-as.factor(tr2$Vendor)
#===============
#model Selection
#===============
tr3 <- tr2[c("X","Carats","Cert","Clarity1","color1","Cut","Depth","Fluroescence1","Known_Conflict_Diamond",
             "Polish","Regions","Shape1","Symmetry1","Table","Vendor","Price","Retail","profit","len","wid","dep","profit_flg")]

#tr4<-tr3[c("Cert","Clarity1","color1","Cut","Fluroescence1","Known_Conflict_Diamond","Polish","Regions","Shape1","Symmetry1","Vendor","profit_flg")]

tr4<-tr3
tr4$Cert<-as.integer(tr4$Cert)
tr4$Clarity1<-as.integer(tr4$Clarity1)
tr4$color1<-as.integer(tr4$color1)
tr4$Cut<-as.integer(tr4$Cut)
tr4$Fluroescence1<-as.integer(tr4$Fluroescence1)
tr4$Known_Conflict_Diamond<-as.integer(tr4$Known_Conflict_Diamond)
tr4$Polish<-as.integer(tr4$Polish)
tr4$Regions<-as.integer(tr4$Regions)
tr4$Shape1<-as.integer(tr4$Shape1)
tr4$Symmetry1<-as.integer(tr4$Symmetry1)
tr4$Vendor<-as.integer(tr4$Vendor)
tr4$profit_flg<-as.integer(tr4$profit_flg)


sjp.corr(tr4,show.legend=TRUE,show.p=TRUE)
sjt.corr(tr4)


CrossTable(tr3$profit_flg, tr3$Known_Conflict_Diamond) 
#shows losses only when Known_Conflict_Diamond=TRUE. Hence will not be investing and removing Known_Conflict_Diamond=TRUE
tr5<-tr3
#drops <- c("Known_Conflict_Diamond")
#tr5<-tr5[!(tr5$profit_flg==0 & tr5$Known_Conflict_Diamond=="TRUE"),!(names(tr5) %in% drops),]
tr5<-tr5[!(tr5$profit_flg==0 & tr5$Known_Conflict_Diamond=="TRUE"),]

outliers <- boxplot(tr5$Carats)$out
sum(count(outliers))
tr5 <- tr5[-which(tr5$Carats %in% outliers),]

tr6<-tr5
tr6$Cert<-as.integer(tr6$Cert)
tr6$Clarity1<-as.integer(tr6$Clarity1)
tr6$color1<-as.integer(tr6$color1)
tr6$Cut<-as.integer(tr6$Cut)
tr6$Fluroescence1<-as.integer(tr6$Fluroescence1)
tr6$Known_Conflict_Diamond<-as.integer(tr6$Known_Conflict_Diamond)
tr6$Polish<-as.integer(tr6$Polish)
tr6$Regions<-as.integer(tr6$Regions)
tr6$Shape1<-as.integer(tr6$Shape1)
tr6$Symmetry1<-as.integer(tr6$Symmetry1)
tr6$Vendor<-as.integer(tr6$Vendor)
tr6$profit_flg<-as.integer(tr6$profit_flg)

sjp.corr(tr6,show.legend=TRUE,show.p=TRUE)
sjt.corr(tr6)


Pflg_m <- glm(profit_flg~RegionsZimbabwe+Polish+Depth+Vendor+Carats, data = tr5, family = binomial)
summary(Pflg_m)

Profit_m <- lm(profit~Regions+Polish+Depth+Vendor+Carats, data = tr5)
summary(Profit_m)
Profit_m2 <- lm(profit~Regions*Vendor*Carats, data = tr5)
summary(Profit_m2)
Profit_m3 <- lm(profit~Regions+Vendor+Carats+Cut, data = tr5)
summary(Profit_m3)
Profit_m4 <- lm(profit~Regions+Vendor+Carats+Cut+color1, data = tr5)
summary(Profit_m4)
Profit_m5 <- lm(profit~Vendor+Carats+color1+Clarity1+len, data = tr5)
summary(Profit_m5)
#selected m4
vif(Profit_m4)

tr5_prof<-tr5
drops2 <- c("Price","Retail","profit_flg")
tr5_prof<-tr5_prof[,!(names(tr5_prof) %in% drops2)]
tr5_prof$Clarity1<-as.character(tr5_prof$Clarity1)
tr5_prof$Clarity1<-revalue(tr5_prof$Clarity1, c("SI1"="SI", "SI2"="SI"))
tr5_prof$Clarity1<-as.factor(tr5_prof$Clarity1)


lmMod <- lm(profit ~ . , data = na.omit(tr5_prof))
selectedMod <- step(lmMod)
summary(selectedMod)
vif(selectedMod)
lmMod1 <- lm(profit ~ Carats + Clarity1 + color1 + Polish + Regions + Shape1 + Vendor + len + dep, data = na.omit(tr5_prof))
selectedMod1 <- step(lmMod1)
try<-step(lm(profit ~ Carats + Clarity1 + color1 + Vendor , data = na.omit(tr5_prof)))
summary(try)
vif(try)
try.res=resid(try)
plot(try) 
Select_final<-try
prediction <- round(predict(Select_final, type = 'response', na.omit(tr5_prof)))
eval_model(na.omit(tr5_prof)$profit, prediction)
#==========
tr5_ret<-tr5
drops2 <- c("Price","profit_flg","profit")
tr5_ret<-tr5_ret[,!(names(tr5_ret) %in% drops2)]
tr5_ret$Clarity1<-as.character(tr5_ret$Clarity1)
tr5_ret$Clarity1<-revalue(tr5_ret$Clarity1, c("SI1"="SI", "SI2"="SI","VS1"="SI", "VS2"="SI"))
tr5_ret$Clarity1<-as.factor(tr5_ret$Clarity1)
tr5_ret$RetailSQR<-tr5_ret$Retail^0.5
tr5_ret<-tr5_ret[,!(names(tr5_ret) %in% c("Retail"))]
ggplot(na.omit(tr5_ret), aes(x=Carats, y=RetailSQR)) + geom_point(shape=1)
ggplot(tr5, aes(x=Carats, y=Retail^0.5)) + geom_point(shape=1)

lmModRR <- lm(RetailSQR~ . , data = na.omit(tr5_ret))
ModR <- step(lmModRR)
summary(ModR)
vif(ModR)
RetailMod<-step(lm(RetailSQR ~ Carats + Clarity1 + color1  + Shape1 + Vendor+ Cut + Fluroescence1     , data = tr5_ret))
summary(RetailMod)
vif(RetailMod)
plot(RetailMod) 
residualPlot(RetailMod)

#==========
tr5_prof<-tr5
drops2 <- c("Retail","profit_flg","profit")
tr5_prof<-tr5_prof[,!(names(tr5_prof) %in% drops2)]
tr5_prof$Clarity1<-as.character(tr5_prof$Clarity1)
tr5_prof$Clarity1<-revalue(tr5_prof$Clarity1, c("SI1"="SI", "SI2"="SI","VS1"="SI", "VS2"="SI"))
tr5_prof$Clarity1<-as.factor(tr5_prof$Clarity1)
#tr5_prof$CaratSQR<-tr5_prof$Carats^2
tr5_prof$PriceSQR<-tr5_prof$Price^0.5
tr5_prof<-tr5_prof[,!(names(tr5_prof) %in% c("Price"))]
ggplot(na.omit(tr5_prof), aes(x=Carats, y=PriceSQR)) + geom_point(shape=1)

lmMod <- lm(PriceSQR~ . , data = na.omit(tr5_prof))
Mod <- step(lmMod)
summary(Mod)
vif(Mod)
PriceMod<-step(lm(PriceSQR ~ Carats + Cert + Clarity1 + color1 + Cut + Fluroescence1 + Polish + Regions + Shape1 + Vendor     , data = tr5_prof))
summary(PriceMod)
vif(PriceMod)
plot(PriceMod) 
residualPlot(PriceMod)


w <- abs(rstudent(try)) < 3 & abs(cooks.distance(try)) < 4/nrow(try$model)
try2 <- update(try, weights=as.numeric(w))
summary(try2)
vif(try2)
plot(try2) 



prediction <- round(predict(PriceMod, type = 'response', data=na.omit(tr5_prof)))
prediction<-prediction^2
eval_model(na.omit(tr5_prof)$PriceSQR, prediction)
eval_model(tr5_prof$PriceSQR, prediction)


price_m <- lm(Price~profit+Regions+Vendor+Carats+Cut, data = tr5)
summary(price_m)
price_m2 <- lm(Price~profit+Vendor+Carats+Cut, data = tr5)
summary(price_m2)
price_m3 <- lm(Price~profit+Vendor+Carats+Polish, data = tr5)
summary(price_m3)
price_m4 <- lm(Price~profit+Regions+Vendor+Carats+Polish, data = tr5)
summary(price_m4)
#selected price_m


write.csv(tr5_prof, file = "D:/enova/Assessment_Files/Assessment Files/tr5_prof.csv")





















