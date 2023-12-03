dati<-X4_manuf
attach(dati)
dati
summary(dati)
#Y=la produzione lorda
#K= capitale
#L=lavoro 
#E=energia
#M=altri materiali intermedi.

#EQUAZIONE DI COP DOUGLAS
# y=(K^b1)(L^b2)(E^b3)(M^b4)e^epsilon -> poi trasf logaritmica

cor(dati)

#alta correlazione

#STIMA MINIMI QUADRATI ORDINARI

m1<-lm(y~k+l+e+m)
summary(m1)
res<-resid(m1)
fit<-fitted(m1)
plot(fit,res)

plot(y, res)
plot(k,res)
plot(l,res)
plot(e,res)
plot(m,res)

#dai grafici evidenziamo sparsità, quindi supponiamo omosch.

#dopo aver simato i modelli di BP e White abbiamo
#p-value=0.9179 BP accetto Ho senza log
#p-value=0.9665  WHITE accetto H0 senza log


#STIMA MINIMI QUADRATI ORDINARI con trasf log della dipendente
ly<-log(y)
mod1<-lm(ly~k+l+e+m)
summary(mod1)

res1<-resid(mod1)
fit1<-fitted(mod1)
plot(fit1,res1)

plot(ly, res1)
plot(k,res1)
plot(l,res1)
plot(e,res1)
plot(m,res1)


#TEST DI BP

res12<-res1^2
modres12<-lm(res12~k+l+e+m)
summary(modres12)

#p-value=0.3876 con log


#TEST WHITE 
fit1<-fitted(mod1)
fit12<-fit1^2
modresY<-lm(res12~fit1+fit12)
summary(modresY)

#p-value=0.2988 con log



#trasformiamo modello lineare dividendo per ord srimate
rr<-1/fit1
k1<-k/fit1
l1<-l/fit1
e1<-e/fit1
m1<-m/fit1

modtr<-lm(ly~rr+k1+l1+e1+m1-1)
summary(modtr)
#p-value=3.599e-08

#test bp al modello trasformato

resmodtr<-resid(modtr)
resmodtr2<-resmodtr^2
modrestrBP<-lm(resmodtr2~rr+k1+l1+e1+m1-1)
summary(modrestrBP)
#p-value=0.01032 rifiutiamo Ho

#trasformaz log delle altre varibili
ly<-log(y)
lk<-log(k)
ll<-log(l)
le<-log(e)
lm<-log(m)

modlog<-lm(ly~lk+ll+le+lm)
summary(modlog)

#test BP con trasf log
fitmodlog<-fitted(modlog)
resmodlog<-resid(modlog)
resmodlog2<-resmodlog^2

modlogBP<-lm(resmodlog2~lk+ll+le+lm)
summary(modlogBP)
#p-value=0.7921 accettiamo HO

#NON POSSIAMO ELIMINIARE I REGERSSORI ANCHE SE SONO STATI NON SIGNI, PERCHè CI SERVONO
#NEL MODELLO DI COB DOUGLAS




#CONSIDERIAMO TUTTO IL MODELLO SENZA ELIMINARE NESSUN REGRESSORE
m1<-lm(y~k+l+e+m)
summary(m1)

set.seed(100)
index=sample(1:nrow(dati), 0.7*nrow(dati))

trainY<-dati[index,]
testY<-dati[-index,]

dim(trainY)
dim(testY)

mtrainY<-lm(y~., data=dati)
summary(mtrainY)

mse=function(actual, predicted){mean((actual-predicted)^2)}
rmse=function(actual, predicted){sqrt(mean((actual-predicted)^2))}

mseTRAIN<-mse(actual=trainY$y, predicted=predict(mtrainY,trainY))
mseTRAIN
rmseTRAIN<-rmse(actual=trainY$y, predicted=predict(mtrainY,trainY))
rmseTRAIN

mseTEST<-mse(actual=testY$y, predicted=predict(mtrainY,testY))
mseTEST
rmseTEST<-rmse(actual=testY$y, predicted=predict(mtrainY,testY))
rmseTEST

complexityY=function(mtrainY){length(coef(mtrainY))-1}
comp<-complexityY(mtrainY)
comp



plot(comp, mseTEST, type="b", col="3",
     ylim=c(min(mseTEST, mseTRAIN)-0.05, max(mseTEST, mseTRAIN)+0.05),
            xlab="comp", ylab="MSE",
            main="MSE train set(r) e test set(g)")
lines(comp, mseTRAIN, type="b", col="2")

#LOOCV k-fold

library(boot)
m0glm<-glm(y~., data=dati)

n<-nrow(dati)
cv.errorL0<-cv.glm(dati,m0glm, K=n)$delta

cv.errorL0



cv.errorK0<-cv.glm(dati,m0glm, K=12)$delta

cv.errorK0

conf<-cbind(cv.errorL0, cv.errorK0)
conf



min(min(cv.errorL0, cv.errorK0))

plot(comp, cv.errorK0, type="b", col="3",
     ylim=c(min(cv.errorL0, cv.errorK0)-0.05, max(cv.errorL0, cv.errorK0)+0.05),
     xlab="comp", ylab="MSE",
     main="MSE LOOCV(r) e k-fold(g)")
lines(comp, cv.errorK0, type="b", col="2")


#RIDGE
library(glmnet)
names(dati)
xx<-dati[,-5]
x<-as.matrix(xx)
x
dim(x)
names(x)
y<-dati$y
y
qq<-seq(10,-2, length=100)
griglia=10^qq

ridge.mods.ALL=glmnet(x,y,alpha=0, lambda=griglia)
dim(coef(ridge.mods.ALL))

plot(ridge.mods.ALL, main="RR, reg. standard", xvar="lambda", label=TRUE)

cv.outK10=cv.glmnet(x,y,lambda=griglia,alpha=0, grouped=FALSE)
plot(cv.outK10)

lambdamin<-cv.outK10$lambda.min
lambdamin

lmin<-cv.outK10$lambda.1se
lmin

ridge.mod.KCV=glmnet(x,y, alpha=0, lambda=lambdamin)
coef(ridge.mod.KCV)

cv.outLOOCV=cv.glmnet(x,y, lambda=griglia, nfolds=n, grouped=FALSE, alpha=0)
plot(cv.outLOOCV, main="LOOCV per dati")
bestLambdaLOOCV<-cv.outLOOCV$lambda.min
bestLambdaLOOCV
cv.outLOOCV$lambda.1se

ridge.mod.kCV=glmnet(x,y,alpha=0, lambda=bestLambdaLOOCV)
coef(ridge.mod.kCV)

#lasso
LASSO.mods.ALL=glmnet(x,y,alpha=1, lambda=griglia)
dim(coef(LASSO.mods.ALL))

plot(LASSO.mods.ALL, main="LASSO, reg. standard", xvar="lambda", label=TRUE)

cv.outK10.Lasso=cv.glmnet(x,y,lambda=griglia,alpha=1, grouped=FALSE)
plot(cv.outK10.Lasso)

lambdaminL<-cv.outK10.Lasso$lambda.min
lambdaminL

lminL<-cv.outK10.Lasso$lambda.1se
lmin

LASSO.mod.KCV=glmnet(x,y, alpha=1, lambda=lambdaminL)
coef(LASSO.mod.KCV)

cv.outLOOCV.LASSO=cv.glmnet(x,y, lambda=griglia, nfolds=n, grouped=FALSE, alpha=1)
plot(cv.outLOOCV.LASSO, main="LOOCV per dati")
bestLambdaLOOCV.LASSO<-cv.outLOOCV.LASSO$lambda.min
bestLambdaLOOCV.LASSO
cv.outLOOCV.LASSO$lambda.1se

LASSO.mod.kCV=glmnet(x,y,alpha=1, lambda=bestLambdaLOOCV)
coef(LASSO.mod.kCV)[,1]

cbind(coef(LASSO.mod.kCV)[,1],coef(ridge.mod.kCV)[,1])

#ELASTIC NET
EN.modes.ALL<-glmnet(x,y,lambda=griglia, alpha=0.1)
plot(EN.modes.ALL, main="EN reg stand", xvar="lambda",label=TRUE)

EN.modes.ALL<-glmnet(x,y,lambda=griglia, alpha=0.3)
plot(EN.modes.ALL, main="EN reg stand", xvar="lambda",label=TRUE)

EN.modes.ALL<-glmnet(x,y,lambda=griglia, alpha=0.7)
plot(EN.modes.ALL, main="EN reg stand", xvar="lambda",label=TRUE)

EN.modes.ALL<-glmnet(x,y,lambda=griglia, alpha=0.9)
plot(EN.modes.ALL, main="EN reg stand", xvar="lambda",label=TRUE)


cv.outK10.EN01=cv.glmnet(x,y,lambda=griglia, alpha=0.1,grouped=FALSE)
plot(cv.outK10.EN01, main="EN alpha=0.1: k-fold CV per dati")

bestLambda.EN01<-cv.outK10.EN01$lambda.min
bestLambda.EN01

EN01.mod.kCV
coef(EN01.mod.kCV)

cv.outK10.EN02=cv.glmnet(x,y,lambda=griglia, alpha=0.3,grouped=FALSE)
plot(cv.outK10.EN02, main="EN alpha=0.3: k-fold CV per dati")

bestLambda.EN02<-cv.outK10.EN02$lambda.min
bestLambda.EN02

EN02.mod.kCV
coef(EN02.mod.kCV)



cv.outK10.EN03=cv.glmnet(x,y,lambda=griglia, alpha=0.7,grouped=FALSE)
plot(cv.outK10.EN03, main="EN alpha=0.7: k-fold CV per dati")

bestLambda.EN03<-cv.outK10.EN03$lambda.min
bestLambda.EN03

EN03.mod.kCV
coef(EN03.mod.kCV)


cv.outK10.EN04=cv.glmnet(x,y,lambda=griglia, alpha=0.9,grouped=FALSE)
plot(cv.outK10.EN04, main="EN alpha=0.9: k-fold CV per dati")

bestLambda.EN04<-cv.outK10.EN04$lambda.min
bestLambda.EN04

EN04.mod.kCV
coef(EN04.mod.kCV)

cbind(coef(LASSO.mod.kCV)[,1], coef(ridge.mod.kCV)[,1],coef(EN01.mod.kCV)[,1],coef(EN02.mod.kCV)[,1],
      coef(EN03.mod.kCV)[,1], coef(EN04.mod.kCV)[,1])
#confronto tra tutti i modelli per vedere eventuale cambio di segno dei regressori
#solo in e con Lasso e alpha=0.1 è zero


#SCELTA modello con migliore MSE


mse.minLASSO<-cv.outK10.Lasso$cvm[cv.outK10.Lasso$lambdainL==cv.outK10.Lasso$lambda.min]
mse.minRR<-cv.outK10$cvm[cv.outK10$lambda==cv.outK10$lambda.min]
mse.minEN01<-cv.outK10.EN01$cvm[cv.outK10.EN01$lambda==cv.outK10.EN01$lambda.min]
mse.minEN02<-cv.outK10.EN02$cvm[cv.outK10.EN02$lambda==cv.outK10.EN02$lambda.min]
mse.minEN03<-cv.outK10.EN03$cvm[cv.outK10.EN03$lambda==cv.outK10.EN03$lambda.min]
mse.minEN04<-cv.outK10.EN04$cvm[cv.outK10.EN04$lambda==cv.outK10.EN04$lambda.min]

cbind(mse.minLASSO,mse.minRR,mse.minEN01,mse.minEN02,mse.minEN03,mse.minEN04)

min(cbind(mse.minLASSO,mse.minRR,mse.minEN01,mse.minEN02,mse.minEN03,mse.minEN04))


#FACCIO CONFRONTO CON MODELLO CON MSE MIGLIORE E MODELLO LINEARE 
cbind((coef(EN02.mod.kCV)[,1]), coef(m1))


#notiamo che per il regressore e c'è un czmbio di segno se consideriamo il modello
#che minimizza l'MSE e il modello pieno, quindi non posso interpretare come negli OLS


