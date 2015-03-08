
##########################
# Stratified bootstrapping
#########################

# aka how to bootstrap a structured/repeated-measures dataset
library(boot)
library(nlme)
library(lme4)
library(MuMIn)

# simple scenario with 2 blocks
set.seed(101)
x <- rnorm(50, 10, 1)
y <- rnorm(50, 10.2, 1)
total <- c(x, y)
block <- as.factor(c(rep("x",length(x)), rep("y",length(y))))
t.test(total~block)
mydat<-data.frame(cbind(total, block))

bsdiff <- function(data,i){
	d<-data[i,]
	mean(subset(d,block==1)$total)-mean(subset(d,block==2)$total)
}
set.seed(101)
b <- boot(mydat, bsdiff, strata=block, R = 10000)
boot.ci(b, type='bca') # similar to what we saw in t-test result

# what if we have repeated measures of a bunch of subjects?
data(Orthodont) # load the orthodont dataset provided in the nlme package
ortho<-data.frame(Orthodont)
ortho$sub<-factor(ortho$Subject,order=F)
summary(ortho) # modified to make new column for subject 

mod<-lme(distance~age*Sex,random=~1|sub,data=ortho)
#from mumin package
r.squaredGLMM(mod) # marginal Rglmm2, represents variance explained by all fixed effects in the model (Nakagawa and Schielzeth 2013 MEE)
unname(r.squaredGLMM(mod)[1])

rsb <- function(data,i){
	d<-data[i,]
	mod<-lme(distance~age*Sex,random=~1|sub,data=d)
	return(unname(r.squaredGLMM(mod)[1]))
}
b <- boot(data=ortho,rsb,strata=ortho$sub,R = 1000)
plot(b)

# let's do the same thing with a lme4 model (glmm)
mod<-lmer(distance~age*Sex+(1|sub),data=ortho)
# note with lmer/lme4, the random effect has to be a factor or it won't work
unname(r.squaredGLMM(mod)[1]) # same model
rsb <- function(data,i){
	d<-data[i,]
	mod<-lmer(distance~age*Sex+(1|sub),data=d)
	return(unname(r.squaredGLMM(mod)[1]))
}
b2 <- boot(data=ortho,rsb,strata=ortho$sub, R = 100)
plot(b2)


