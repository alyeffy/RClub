
##############################
### resampling & simulation
##############################
# Jan 23 2015

# There are at least 3 reasons to simulate data:
	# bootstrapping (parametric & nonparametric)
	# permutation randomization tests
	# power analysis
# remember whenever you randomize, results will vary each time you run the analysis. Use set.seed() to keep it reproducible
rnorm(1) # draw from a normal distribution, with default mean = 0 and sd = 1
set.seed(101)
rnorm(1)

# for loops
for(i in 1:10){
	a <- i + 1
	print(a)
}

# functions
myfun <- function(x){
	sum(x)/length(x)
}

myfun(0:10)
a <- 1:5
myfun(a)

myfun <- function(x,y){
	x*y
}

b<-6:10
myfun(a,b)

# confidence intervals
# suppose we have a population of birds
tail.length<-round(rnorm(1000,10,2),2)
hist(tail.length)
mean(tail.length) # the pop mean
# we capture and measure 50 birds
tail.sample<-sample(tail.length,50,replace=F)
hist(tail.sample)
abline(v=mean(tail.sample),col='green') # the sample mean
abline(v=mean(tail.length),col='red',lwd=2) # true pop mean
# if we repeat this many times over, 95% of the time the sample mean will fall within 1.96 SEs of the true population mean 
se <- sd(tail.sample)/sqrt(length(tail.sample)) # get the sample standard error
polygon(c(mean(tail.sample)+1.96*c(-se, se),mean(tail.sample)+1.96*c(se, -se)),c(0,0,100,100),col=rgb(0,1,0,0.25)) # this time it does

# let's convince ourselves
nreps=10000
smean<-rep(NA,nreps)
check<-rep(NA,nreps)
set.seed(8)
for(i in 1:nreps){
	tail.sample<-sample(tail.length,50,replace=F) # 50 is our sample size
	smean[i]<-mean(tail.sample)
	check[i]<-abs(mean(tail.sample)-mean(tail.length)) <= (1.96)*sd(tail.sample)/sqrt(length(tail.sample))
} 
# note the default for sample() is without replacement
summary(smean)
hist(smean,breaks=100)
abline(v=mean(tail.length),col='red') # sample means are distributed around the population mean
check
sum(check)/length(check) # so 95% of the time the sample 95% CI captures the true mean

ttest  <-  t.test(tail.sample) # which is why we can do this with one sample. t.test() gives the CI quickly
str(ttest)
ttest$conf.int

###################
# 1. Bootstrapping
###################
# what we did above works because the sampling distribution of the mean is normally-distributed  
# often we want to estimate things where we don't know the expected sampling distribution
# in these situations we can use R to sample the sample with replacement. this is like pretending the sample data = the population
# this is nonparametric bootstrapping

# again we write a loop with many iterations (10000 is usually decent)
nreps=10000
bsmean<-rep(NA,nreps)
tail.sample # we'll use this sample data
set.seed(8) # why does this have to be outside the loop?
for(i in 1:nreps){
	bssample<-sample(tail.sample,replace=T) # sample with replacement!
	bsmean[i]<-mean(bssample)
}
# note replace = T. this is key for bootstrapping
summary(bsmean)
quantile(bsmean,c(0.025,0.975)) # 95% CI for mean arc turn velocity 1.907, 2.092
hist(bsmean,col='grey');abline(v=mean(tail.length),col='red');abline(v=quantile(bsmean,c(0.025,0.975)),col='green') # the interval in this case covers the population mean

# aside: it's more efficient to use apply...
set.seed(101)
results<-matrix(sample(tail.sample,nreps*length(tail.sample),replace=T),ncol=nreps,nrow=length(tail.sample))
# sets up our random samples in one fell swoop
head(results) 
bsmean2<-apply(results,2,mean) # now we can use apply to do our calcs all at once. this is faster than the serial for loop  
quantile(bsmean2,c(0.025,0.975)) # very similar to the CI for bsmean
quantile(bsmean,c(0.025,0.975))
# what if we upped the reps?

library(boot)
# the boot package automates this, and has additional options for calculating confidence intervals
# the catch is you have to write a custom function for the statistic you're interested in, with a specific format
# here's one for getting the mean:
Bmean <- function(data, i) {
	d <- data[i] # it has to have data and indices. this allows boot() to select the sub-sample 
	return(mean(d)) # insert your function here
} 
# that wasn't so bad

set.seed(1234)
bsmean3 <- boot(data=tail.sample, statistic=Bmean, R=10000) # 
bsmean3;plot(bsmean3) # boot creates a 'boot object', which is list. plotting it calls plot.boot()
str(bsmean3) 
bsmean3$t # we can pull out the estimates with $t

# the boot.ci() function can be used on boot objects
boot.ci(bsmean3, type=c("perc")) # matches up well to our other results
help(boot.ci) # there are a several options for "type". bca or bias-corrected and accelerated corrects for skewness in the sampling distrubtion
boot.ci(bsmean3, type=c("all")) # the differences are slight

# so far we've done non-parametric bootstrapping
	# no need for normally-distributed data
	# can use it to get CIs for estimates of virtually any statistic (e.g., median, mode, proportion). it's especially useful when there's no ready formula for a standard error (skewed or zero-inflated data etc), because the theoretical distribution of the statistic is complicated or unknown. 

# e.g., suppose you want CIs on an R2 estimate from a regression
head(mtcars)
mod<-lm(mpg~wt,data=mtcars)
summary(mod);plot(mpg~wt,data=mtcars);abline(mod)

str(summary(mod)) # find the R2...
summary(mod)$r.squared # got it

# now we write a function for this to work with boot. same general format as before
rsq <- function(formula, data, i) {
  d <- data[i,] # allows boot to select sample
  fit <- lm(formula, data=d)
  return(summary(fit)$r.squared)
}
# bootstrapping with 1000 replications
set.seed(4567)
bsrsq <- boot(data=mtcars, statistic=rsq, R=1000, formula=mpg~wt)
bsrsq
plot(bsrsq)
boot.ci(bsrsq, type="bca") # R2 = 0.75 [95% CI = 0.61, 0.84]
# note also that the car package has the Boot() function for bootstrapping lm, glm, and nls regressions

# stopped here 150127

set.seed(4444)
v1 <- rnorm(10)
v2 <- rnorm(10)
cor(v1,v2)

nreps <- 10000
bootcor <- rep(NA, nreps)
for(i in 1:nreps) {
  mysample <- sample(1:length(v1),replace = T)
  v1s <- v1[mysample]
  v2s <- v2[mysample]
  bootcor[i]  <- cor(v1s,v2s)
}
hist(bootcor)

# parametric (or semi-parametric?) bootstrapping can also be used on regression models 
# recall in non-parametric bs, we sample the data, re-fit the model, then repeat
# in (semi)parametric bs, we fit the model, compute residuals, then bootstrap those residuals ... and regenerate a model? (it's a black box to me beyond this)
# e.g.: peacock tail lengths

head(pcocks) # tail length (cm) and date (day of year) from 3 field seasons
plot(trainl~traindate,pcocks,col=as.numeric(pcocks$maleIDno),pch=16)

library(lme4) # the lme4 package for mixed-effects models has a builtin function for parametric bootstrapping
mod<-(lmer(trainl~traindate+(1|maleIDno),pcocks)) # fit a mixed-effects model
summary(mod) # on average the tail grows 8mm/day!
# suppose we wan to know how repeatable tail lengths are
# calculate repeatability or ICC (see Nakagawa and Schielzeth 2010)
sigma2_intercept<-unname(attr(VarCorr(mod)$maleIDno,"stddev"))^2
sigma2_resid<-attr(VarCorr(mod),"sc")^2
sigma2_intercept/(sigma2_intercept+sigma2_resid)
# so 59% of the variation in tail length is accounted for by diffs between males
# let's get CIs on this estimate. we could manually bootstrap the original data and refit the model. another (simpler?) option is semi-parametric bootstrapping. for mixed models, this can be done with the bootMer() function in lme4
# set up the function to get repeatability. note that it doesn't require the same data/indices format as boot()
myrepeat<-function(model){
	sigma2_intercept<-unname(attr(VarCorr(model)$maleIDno,"stddev"))^2
	sigma2_resid<-attr(VarCorr(model),"sc")^2
	return(sigma2_intercept/(sigma2_intercept+sigma2_resid))
}
myrepeat(mod) # make sure it works
bootrep<-bootMer(mod,myrepeat,nsim=1000,seed=101);alarm() # takes a minute so we'll only do 1000
str(bootrep) # again it creates a list object. t is the bootstrapped statistic
summary(bootrep) # summary doesn't tell us anything useful though
hist(bootrep$t)
quantile(bootrep$t,c(0.025,0.975)) # 95% CI around the repeatability estimate are 0.24-0.78

######################
# 2. Permutation tests
######################
# sometimes you want to test whether your observations differ from chance expectation, but there's no known expected probability distribution, and/or parametric assumptions are violated (e.g., orientation data from a circular distribution)
# permutation tests can also be useful for handling small samples and outliers
# the idea is to randomly shuffle the data many times, breaking the association between two things of interest, then see whether your observed (actual) statistic differs from the distribution obtained from randomized data

library(coin)
# the coin package has various functions for permutation tests
# hummingbird turn velocities
arcturns;hist(arcturns) # arcing turns
prturns;hist(prturns) # pitch roll turns
# neither are normally-distributed
turns<-data.frame(velocity=c(arcturns,prturns),type=c(rep('arc',length(arcturns)),rep('pr',length(prturns))))
wilcox_test(velocity~type,data=turns) # nonparametric verion of the t-test takes a formula input
help(wilcox_test) # it's actually a permutation test
# use oneway_test() to test for a difference with >2 levels. plus many other tests in coin 

# we can also write our own permutation tests, for virtually any scenario
# example: nonrandom mating by color
head(tswallow) # tree swallow plumage coloration summarized as xyz coordinates in colour space
# our question is, are paired birds more/less similar in color than expected by chance?

tswallow$contrast<-sqrt((tswallow$x.F-tswallow$x.M)^2+(tswallow$y.F-tswallow$y.M)^2+(tswallow$z.F-tswallow$z.M)^2) # this distance between two points in color space is a measure of contrast, here applied to paired Ms and Fs
hist(tswallow$contrast) 
bscontrast<-rep(NA,10000) # ideally we'd do all possible permutations, but in practice it's fine to do a feasibly large number
set.seed(1990)
for(i in 1:10000){
	order<-sample(nrow(tswallow),replace=F) # unlike bootstrapping, we permute without replacement. results will differ if you don't do this!
	newmaleX<-tswallow$x.M[order]
	newmaleY<-tswallow$y.M[order]
	newmaleZ<-tswallow$z.M[order]
	bscontrast[i]<-mean(sqrt((tswallow$x.F-newmaleX)^2+(tswallow$y.F-newmaleY)^2+(tswallow$z.F-newmaleZ)^2))
}
mean(tswallow$contrast)
quantile(bscontrast,c(0.025,0.975))
hist(bscontrast);abline(v=mean(tswallow$contrast));abline(v=quantile(bscontrast,c(0.025,0.975)),lty=2) # our observed statistic is well within the bounds of the distribution obtained from randomized data
# so we concluce that there's no evidence that they mate nonrandomly by color
2*mean(bscontrast<mean(tswallow$contrast)) # approx. two-tailed p value

# beware: permutation tests put the focus on p-values, rather than estimation. p-values alone are NOT a good measure of the size or importance of an effect.
# remember you can always get CIs on effect size estimates via bootstrapping
# also note that while these tests can be useful for (1) violation of parametric assumptions, (2) small-ish samples, and (3) outliers, they do NOT solve biased sampling, non-independence of data, or heteroscedasticity. same goes for bootstrapping.

###########################
# 3. Power analyses
###########################
# see Ben Bolker's book chapter 5 p. 10-15
# before conducting a study, we often want to know how the properties of a dataset will affect the quality of answers to our questions. this can be important for making decsions about the number of datapoints (sampling intensity) and the distribution of data (design). for e.g:
	# how many sites/individuals/clusters? how many samples per site/individual?
	# what extent of temporal and spatial sampling? what kind of grain/resolution?
	# even or clustered distribution of samples in space or time?
	# balance

# there are several canned functions to do frequentist-style power analysis in R 
help(power.t.test)
help(power.prop.test)
help(power.anova.test)
# (see also the Hmisc package)

# nevertheless it's very useful to be able to simulate these on your own, for
# more flexibility, and to work with more complex anlayses additionally, it can
# be useful to bootstrap the results of a power analysis of a small pilot study,
# to get a better idea of the uncertainty involved

# let's start with a simple linear regression. In order to find out whether we can reject the null hypothesis in a single “experiment”, we simulate a data set with a given slope, intercept, and number of data points; run a linear regression; extract the p-value; and see whether it is less than our specified alpha criterion (usually 0.05). Start with just one iteration:
x = 1:20
a = 2; b = 1; sd = 8 
N = 20 # we set the effect size, sd, and sample size
y_det = a+b*x
set.seed(101)
y = rnorm(N,mean=y_det,sd=sd)
m = lm(y~x)
coef(summary(m))["x","Pr(>|t|)"] # the summary object is a matrix, so we can pull out the value we want (here the p-value) using indexing

# now repeat this many times to estimate probability
nsim = 400
pval = numeric(nsim)
set.seed(101)
for (i in 1:nsim) {
  y_det = a+b*x
  y = rnorm(N,mean=y_det,sd=sd)
  m = lm(y~x)
  pval[i] = coef(summary(m))["x","Pr(>|t|)"]
}
# this is the power
sum(pval<0.05)/nsim # so for these parameters (effect size, sd, sample size above), we obtain a p value < 0.05 88.5% of the time. that is the proportion of time we would (correctly) reject the null hypothesis of no relationship between x and y. not bad.
hist(pval)
# stopped here on 3_2_15

# this is good but it could be more useful. for instance, maybe we want to explore different changes to our assumptions or to our sampling design, and see what kind of effects they would have
bvec = seq(-2,2,by=0.1) # let's vary effect size (or the slope b)
power.b = numeric(length(bvec))
for (j in 1:length(bvec)) {
  b = bvec[j]
  for (i in 1:nsim) {
    y_det = a+b*x
    y = rnorm(N,mean=y_det,sd=sd)
    m = lm(y~x)
    pval[i] = coef(summary(m))["x","Pr(>|t|)"]
  }
  power.b[j] = sum(pval<0.05)/nsim
};alarm()
# it takes a minute or two because there are so many models to fit
plot(power.b~bvec,type='b') # a steep increase in power with effect size. 

# an example of bootstrapping pilot data for power
head(iris)
iris.pilot<-iris[c(51:65,136:150),] # we want to know if sepal width varies by species. for a pilot study we grew 15 of each
summary(iris.pilot)
iris.pilot$Species<-factor(iris.pilot$Species) # get rid of the extra level
plot(Sepal.Width~Species,iris.pilot)

means<-tapply(iris.pilot$Sepal.Width,iris.pilot$Species,FUN='mean')
delta<-unname(abs(means[1]-means[2]))
sd<-mean(tapply(iris.pilot$Sepal.Width,iris.pilot$Species,FUN='sd'),na.rm=T)
power.t.test(n=21,delta=delta,sd=sd,type='two.sample',alternative='two.sided') # by trial-and-error, looks like we'll need about 42 plants total for ~80% power, assuming our pilot data are a good indication of the true difference & sd.
# but of course it could've been different...


#bpower is actually just difference between the means
bpower <- function(formula, data, i) {
  d <- data[i,] # allows boot to select sample
  means <- tapply(d$Sepal.Width,d$Species,FUN='mean')
  delta <- unname(abs(means[1] - means[2]))
  return(delta)
}
# our function returns the difference between the means of the two species (our effect size estimate)
# here we do stratified bootstrap sampling to ensure 10 of each in each sample
bspower<-boot(data=iris.pilot,statistic=bpower,R=1000,strata=iris.pilot$Species,formula=Sepal.Width~Species)
head(bspower$t) # now we can get CIs on delta 
hist(bspower$t)
quantile(bspower$t,c(0.025,0.975)) # delta
power.t.test(n=40,delta=delta,sd=sd,type='two.sample',alternative='two.sided')$power
power.t.test(n=40,delta=quantile(bspower$t,0.25),sd=sd,type='two.sample',alternative='two.sided')$power
power.t.test(n=40,delta=quantile(bspower$t,0.75),sd=sd,type='two.sample',alternative='two.sided')$power
# can give us a sense of the uncertainty around our the power estimate

rm(list=ls())

#############################
# sources:
# Dolph Schluter's course https://www.zoology.ubc.ca/~bio501/R/
# http://www.statmethods.net/advstats/bootstrapping.html
# http://www.statmethods.net/stats/resampling.html
# Ben Bolker's book Ecological Models and Data in R http://ms.mcmaster.ca/~bolker/emdbook/chap5A.pdf
# Chris Eckert's R Club 2012


library(animation)


