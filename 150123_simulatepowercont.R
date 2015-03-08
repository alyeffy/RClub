

# Simulating data for power anaysis, continued

library(nlme)

# imagine a plant growth experiment with 2 treatments applied to a group of plants in each of 5 trays

ntray = 5
ntrt = 2
nrep = 5 # number of plants per treatment per tray
ntray*nrep*ntrt # total number of individuals in the experiment

gmean = 11 # the response variable (growth)
stray = 1.5 # two main sources of variation: variation between trays
sres = 1.0 # and residual variation

# let's generate a dataset
# make the trt and tray columns
(trt<-rep(rep(c(1:ntrt),each=nrep),ntray))
(tray<-factor(rep(c(1:ntray),each=nrep*ntrt)))

# here's the fixed effect of trt
trt.effect<-c(-0.5,0.5) # should sum to 0
sum(trt.effect)

# we'll model the tray effect as a random effect
(tray.effect<-rnorm(ntray,0,stray)) # again it has to sum to 0
tray.effect[5]<- -sum(tray.effect[1:4]) # ensure the 0 sum
sum(tray.effect) # good

# initialize the growth column
(growth = rep(NA,length = c(ntray*ntrt*nrep)))

# generate growth data based on the chosen parameters
set.seed(101)
for(i in 1:length(growth)){
	growth[i] = rnorm(1, gmean + trt.effect[trt[i]] + tray.effect[tray[i]], sres)
}
mean(growth) # as expected	
gmean + trt.effect
tapply(growth,trt,mean) # should match approximately

tray<-as.factor(tray)
trt<-as.factor(trt)

# fit the model
summary(rmmod<-lme(growth~trt,random=~1|tray))
fixef(rmmod) # fixed effects
ranef(rmmod) # random effects

mod1<-lme(growth~trt,random=~1|tray,method='ML')
summary(mod1)
summary(mod1)$tTable['trt2','p-value'] # p for the test of the fixed effect of trt

# let's examine power when we sample 1, 2 or 3 replicate plants
nreps=500
pvals<-matrix(NA,ncol=4,nrow=nreps)
set.seed(111)
for(k in 1:4){
	nrep = k
	(trt<-rep(rep(c(1:ntrt),each=nrep),ntray))
	(tray<-factor(rep(c(1:ntray),each=nrep*ntrt)))
	tray<-as.factor(tray)
	trt<-as.factor(trt)
	for(i in 1:nreps){
		repgrowth = rep(NA,length = c(ntray*ntrt*nrep))
		tray.effect<-rnorm(ntray,0,stray)
		tray.effect2<-tray.effect-mean(tray.effect)
		for(j in 1:length(repgrowth)){
			repgrowth[j] = rnorm(1,gmean+trt.effect[trt[j]]+tray.effect2[tray[j]],sres)
		}
		mod1<-lme(repgrowth~trt,random=~1|tray,method='ML')
		pvals[i,k]<-summary(mod1)$tTable['trt2','p-value']	
		print(i)
	}
}

colnames(pvals) <- c('k1', 'k2', 'k3', 'k4')

summary(pvals) # power analysis
for(i in 1:dim(pvals)[2]){
	print(sum(pvals[,i]<0.05)/(length(pvals[,i])))
} # so our power is 23% for 1 replicate, 53% for two, 74% for 3, and 84% for 4. we probably want at least 4 reps

# what if we have X plants, and we ant to know how many trays we should them over?
nreps=500
pvals<-matrix(NA,ncol=3,nrow=nreps)
set.seed(111)
nrep<-c(3,2,1)
ntray<-c(6,9,18) # keep in mind we need at least 5 levels to properly estimate random effect
nrep*ntray*ntrt 
stray = 1.5 
sres = 1.0 
for(k in 1:3){
	nrepX = nrep[k]
	ntrayX = ntray[k]
	(trt<-rep(rep(c(1:ntrt),each=nrepX),ntrayX))
	(tray<-factor(rep(c(1:ntrayX),each=nrepX*ntrt)))
	tray<-as.factor(tray)
	trt<-as.factor(trt)
	for(i in 1:nreps){
		repgrowth = rep(NA,length = c(ntrayX*ntrt*nrepX))
		tray.effect<-rnorm(ntrayX,0,stray)
		tray.effect2<-tray.effect-mean(tray.effect)
		for(j in 1:length(repgrowth)){
			repgrowth[j] = rnorm(1,gmean+trt.effect[trt[j]]+tray.effect2[tray[j]],sres)
		}
		mod1<-lme(repgrowth~trt,random=~1|tray,method='ML')
		pvals[i,k]<-summary(mod1)$tTable['trt2','p-value']	
		print(i)
	}
}

summary(pvals) # power analysis
for(i in 1:dim(pvals)[2]){
	print(sum(pvals[,i]<0.05)/(length(pvals[,i])))
} # virtually no difference

###

# what if we alter the sources of variation?
nreps=500
set.seed(111)
nrep<-c(2,3,4,5,6)
ntray<-5
nrep*ntray*ntrt 

stray = 0.75
sres = 0.75
pvals<-matrix(NA,ncol=length(nrep),nrow=nreps)
for(k in 1:length(nrep)){
	nrepX = nrep[k]
	(trt<-rep(rep(c(1:ntrt),each=nrepX),ntray))
	(tray<-factor(rep(c(1:ntray),each=nrepX*ntrt)))
	tray<-as.factor(tray)
	trt<-as.factor(trt)
	for(i in 1:nreps){
		repgrowth = rep(NA,length = c(ntray*ntrt*nrepX))
		tray.effect<-rnorm(ntray,0,stray)
		tray.effect2<-tray.effect-mean(tray.effect)
		for(j in 1:length(repgrowth)){
			repgrowth[j] = rnorm(1,gmean+trt.effect[trt[j]]+tray.effect2[tray[j]],sres)
		}
		mod1<-lme(repgrowth~trt,random=~1|tray,method='ML')
		pvals[i,k]<-summary(mod1)$tTable['trt2','p-value']	
		print(i)
	}
}

(results1<-apply(pvals,2,FUN=function(x) sum(x<0.05)/length(x)))

stray = 0.75
sres = 1.0
pvals<-matrix(NA,ncol=length(nrep),nrow=nreps)
for(k in 1:length(nrep)){
	nrepX = nrep[k]
	(trt<-rep(rep(c(1:ntrt),each=nrepX),ntray))
	(tray<-factor(rep(c(1:ntray),each=nrepX*ntrt)))
	tray<-as.factor(tray)
	trt<-as.factor(trt)
	for(i in 1:nreps){
		repgrowth = rep(NA,length = c(ntray*ntrt*nrepX))
		tray.effect<-rnorm(ntray,0,stray)
		tray.effect2<-tray.effect-mean(tray.effect)
		for(j in 1:length(repgrowth)){
			repgrowth[j] = rnorm(1,gmean+trt.effect[trt[j]]+tray.effect2[tray[j]],sres)
		}
		mod1<-lme(repgrowth~trt,random=~1|tray,method='ML')
		pvals[i,k]<-summary(mod1)$tTable['trt2','p-value']	
		print(i)
	}
}

(results2<-apply(pvals,2,FUN=function(x) sum(x<0.05)/length(x)))

#these differ in the amout of tray vs. residual variance
stray = 1.0
sres = 0.75
pvals<-matrix(NA,ncol=length(nrep),nrow=nreps)
for(k in 1:length(nrep)){
	nrepX = nrep[k]
	(trt<-rep(rep(c(1:ntrt),each=nrepX),ntray))
	(tray<-factor(rep(c(1:ntray),each=nrepX*ntrt)))
	tray<-as.factor(tray)
	trt<-as.factor(trt)
	for(i in 1:nreps){
		repgrowth = rep(NA,length = c(ntray*ntrt*nrepX))
		tray.effect<-rnorm(ntray,0,stray)
		tray.effect2<-tray.effect-mean(tray.effect)
		for(j in 1:length(repgrowth)){
			repgrowth[j] = rnorm(1,gmean+trt.effect[trt[j]]+tray.effect2[tray[j]],sres)
		}
		mod1<-lme(repgrowth~trt,random=~1|tray,method='ML')
		pvals[i,k]<-summary(mod1)$tTable['trt2','p-value']	
		print(i)
	}
}

(results3<-apply(pvals,2,FUN=function(x) sum(x<0.05)/length(x)))

stray = 1.0
sres = 1.0
pvals<-matrix(NA,ncol=length(nrep),nrow=nreps)
for(k in 1:length(nrep)){
	nrepX = nrep[k]
	(trt<-rep(rep(c(1:ntrt),each=nrepX),ntray))
	(tray<-factor(rep(c(1:ntray),each=nrepX*ntrt)))
	tray<-as.factor(tray)
	trt<-as.factor(trt)
	for(i in 1:nreps){
		repgrowth = rep(NA,length = c(ntray*ntrt*nrepX))
		tray.effect<-rnorm(ntray,0,stray)
		tray.effect2<-tray.effect-mean(tray.effect)
		for(j in 1:length(repgrowth)){
			repgrowth[j] = rnorm(1,gmean+trt.effect[trt[j]]+tray.effect2[tray[j]],sres)
		}
		mod1<-lme(repgrowth~trt,random=~1|tray,method='ML')
		pvals[i,k]<-summary(mod1)$tTable['trt2','p-value']	
		print(i)
	}
}

(results4<-apply(pvals,2,FUN=function(x) sum(x<0.05)/length(x)))

plot(results1~nrep,type='l',ylim=c(0,1),ylab=c('power'),xlab=c('replicates'));points(results2~nrep,col='red',type='l');points(results3~nrep,col='green',type='l');
points(results4~nrep,col='blue',type='l')
# so the number of replicate plants here has a strong effect on power
# as expected this relationship is influenced by the amount of residual variance (here, measurement error + between-plant variance)
# interestingly the amount of variance between trays doesn't affect this relationship. what if we could only apply one treatment per tray? 



#########################
# source: Chris Eckert's Queen's University R Club 2012



