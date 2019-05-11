mf <- read.csv("C:/Users/Kavisha/Downloads/sample.csv")

moneyFlowIndex <- function(n) {
mf$TP<-(mf$High+mf$Low+mf$Close)/3
mf$MF<- mf$TP*mf$Volume


for(Day in length(mf$MF)){
ifelse(mf$MF[Day]>mf$MF[Day-1],mf$PMF[Day]<-(mf$MF[Day]-mf$MF[Day-1]),mf$NMF[Day]<-(mf$MF[Day-1]-mf$MF[Day]))}

for(mf$Day in 2:n){
mf$PMF<-rowsum(mf$MFC>0) 
mf$NMF<-rowsum(mf$MFC<0)
mf$MR<-rowsum(mf$MFC>0)/rowsum(mf$MFC<0)}

mf$MFI<-100*mf$MR/(1+mf$MR)

}