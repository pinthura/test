a <- c(2,3,10,2,4,8,1)

maxD <- function(n,a){
b <- data.frame(matrix(0, nrow = n, ncol = n))
if(n>1){
for(i in 2:n){
  for(j in 1:i){
    if(a[i]>a[j]){
      b[i,j]<-a[i]-a[j]
    }
    else {b[i,j]<--1}
  }
  
}
  
#b[is.na(b)]<-0
print(b)
print(max(b))


}}

maxD(n=7,a=a)