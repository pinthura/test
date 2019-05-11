of <- read.csv("D:/enova/Assessment_Files/Assessment Files/offers.csv")

of$Measurements1<-gsub("[x,*,X,+,-]", ",", of$Measurements)
of1 <- separate(of,Measurements1,sep=",", c("len", "wid", "dep"))
of2 <- transform(of1, len = as.numeric(len), wid = as.numeric(wid), dep = as.numeric(dep))

of2$color1 <- substr(of2$Color,1,1)
aggregate(of2$len, list(of2$color1), FUN=mean)
of2$color1<-as.character(of2$color1)
of2$color1<-revalue(of2$color1, c("S"="U", "T"="U"))
of2$color1<-as.factor(of2$color1)



sqldf('Select cut, Polish, count(x) from of2 group by 1,2') 

of2$Depth[of2$Depth == "0"] <- NA
of2$Table[of2$Table == "0"] <- NA
ggplot(of2, aes(x=Depth, y=Table)) + geom_point(shape=1) + geom_smooth(method=lm)

of2$Shape1<-as.character(of2$Shape)
of2$Shape1<-revalue(of2$Shape1, c("Marwuise"="Marquise", "Marquis"="Marquise", "Oval "="Oval", "ROUND"="Round"))
aggregate(of2$len, list(of2$Shape1), FUN=mean)
of2$Shape1<-as.factor(of2$Shape1)

of2$Cut<-as.character(of2$Cut)
of2$Polish<-as.character(of2$Polish)
count(of2, 'Cut')
of2$Cut<-revalue(of2$Cut, c("Ideal"="Excellent","Fair"="Good"))
of2 <- within(of2, Cut <- ifelse(Cut==" ", Polish, Cut))
of2 <- within(of2, Cut <- ifelse(Cut==" ", paste("Very good"), Cut))
aggregate(of2$len, list(of2$Cut), FUN=mean)
of2$Cut<-as.factor(of2$Cut)

of2$Polish<-as.character(of2$Polish)
of2$Polish<-revalue(of2$Polish, c("Fair"="Good"))
aggregate(of2$len, list(of2$Polish), FUN=mean)
of2$Polish<-as.factor(of2$Polish)

of2$Symmetry1<-as.character(of2$Symmetry)
of2$Symmetry1<-revalue(of2$Symmetry1, c("Execllent"="Excellent", "Faint"="Fair"))
aggregate(of2$len, list(of2$Symmetry1), FUN=mean)
of2$Symmetry1<-as.factor(of2$Symmetry1)

of2$Fluroescence1<-as.character(of2$Fluroescence)
#of2$Fluroescence1[of2$Fluroescence1 == " "] <- NA
of2 <- within(of2, Fluroescence1 <- ifelse(Fluroescence1==" ", paste("None"),Fluroescence1))
aggregate(of2$len, list(of2$Fluroescence1), FUN=mean)
of2$Fluroescence1<-as.factor(of2$Fluroescence1)

of2$Vendor<-as.factor(of2$Vendor)
of2$Known_Conflict_Diamond<-as.factor(of2$Known_Conflict_Diamond)

aggregate(of2$len, list(of2$Clarity), FUN=mean)
colnames(of2)[colnames(of2)=="Clarity"] <- "Clarity1"
of2$Clarity1<-as.character(of2$Clarity1)
of2$Clarity1<-revalue(of2$Clarity1, c("SI1"="SI", "SI2"="SI","VS1"="SI", "VS2"="SI"))
of2$Clarity1<-as.factor(of2$Clarity1)
of2$CaratSQR<-of2$Carats^2

of3 <- of2[c("X","Carats","Cert","Clarity1","color1","Cut","Depth","Fluroescence1","Known_Conflict_Diamond","Polish","Regions","Shape1","Symmetry1","Table","Vendor","len","wid","dep","Offers")]
of5<-of3
of5<-of5[!(of5$Known_Conflict_Diamond=="TRUE"),]
colnames(of5)[colnames(of5)=="Offers"] <- "PriceSQR"
of5$PriceSQR<-as.numeric(of5$PriceSQR)

of5$PriceSQR<-NA

of6<-of5[c("X","Carats","Clarity1","color1","Cut","Fluroescence1","Polish","Shape1","Vendor")]
of6<-of6[!is.na(of6),]

require(reshape2)
of5$id <- rownames(of5) 
melt(of5)
of6['Offers'] 
pred<- round(predict(PriceMod, type = 'response', newdata=of5))
predR<- round(predict(RetailMod, type = 'response', newdata=of5))
of6<-cbind(of5, pred, predR)
of6$Offers<-of6$pred^2
of6$Exp_R_Price<-of6$predR^2
of6 <- within(of6, Offers <- ifelse(pred<0,-Offers,Offers))
of6 <- within(of6, Exp_R_Price <- ifelse(predR<0,-Exp_R_Price,Exp_R_Price))
of6$Exp_Profit<-of6$Exp_R_Price-of6$Offers
summary(of6$Offers)
sum(of6$Offers, na.rm=TRUE)
count(is.na(of6$Offers))

of7<-sqldf('Select *
                ,case when(Exp_R_Price>0 and Offers>0 and Exp_Profit>0) then "1" else "0" end offer_elig 
                ,case when(Exp_Profit>0) then "1" else "0" end as Profit_Flag
                ,case when(Known_Conflict_Diamond="TRUE") then "T" else "F" end as conflict_Flag
                from of6 order by conflict_Flag asc, offer_elig desc,Exp_Profit desc')
of7$Cum_Offer_Stg1<-cumsum(of7$Offers)
of8<-sqldf('Select * ,case when(Cum_Offer_Stg1<5000000) then "1" else "0" end offer_final_Stg1 from of7 ')
of9<-sqldf('Select * from of8 order by conflict_Flag asc, offer_elig desc, Offers asc, Exp_Profit desc')
of9$Cum_Offer_Stg2<-cumsum(of9$Offers)
of10<-sqldf('Select * ,case when(Cum_Offer_Stg2<5000000) then "1" else "0" end offer_final_Stg2 from of9')

write.csv(of10, file = "D:/enova/Assessment_Files/Assessment Files/ofer_prediction.csv")
