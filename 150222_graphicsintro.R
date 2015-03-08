# Intro to R graphics and basic plots
# 22 February 2015

#############################
# the first step before ***any*** analysis is to look at the data
# set the working directory before the next step
mydat <- read.table(file.choose(), header=T) # nifty
dim(mydat)
head(mydat)
summary(mydat)
fix(mydat) # inspect to make sure everything is lined up properly. check for missing values (indicated by "NA")

# histograms
##########################################
# start by checking distributions of variables
length(mydat$lifeExp)
hist(mydat$lifeExp)
hist(mydat$lifeExp, breaks=5) # we can change the bin size
hist(mydat$lifeExp, breaks=80) # notice how the y scale changes when you do this

# executing these commands opens a quartz window
# we can open another one manually (click button), or using dev.new()
dev.new()
# whatever we plot next will go into it
hist(mydat[,5]) 
hist(mydat$pop) 
# the quartz window on top (highest number) is the active one. If we execute a new plot, it will go there

# these plots look OK but there are a few things I'd change
summary(mydat$lifeExp)
hist(mydat$lifeExp, xlab="life expectancy (years)", ylab="number of countries", main="Distribution of Life Expectancy \n n = 1704")
# notice how \n puts text onto the next line

# let's plot the 2007 life expectancies only
subset(mydat, year==2007)

# and we'll add a line at the mean, and label it
hist(subset(mydat,year==2007)$lifeExp, xlab="life expectancy (years)", ylab="number of countries", main="Distribution of Life Expectancy in 2007 \n = 142")
abline(v=mean(subset(mydat,year==2007)$lifeExp), col='red', lwd=2, lty=2) 
text(62, 35, 'mean = 67', col='red')

# here's how we can probability densities on the y axis, rather than counts:
hist(subset(mydat, year==2007)$lifeExp, freq=F, breaks=10) 
lines(density(subset(mydat, year==2007)$lifeExp)) # density() fits a curve to the probability densities

# there's much more you can control on a hist plot
?hist

# let's try a few tricks detailed in the help file
hist(subset(mydat,year==2007)$lifeExp, xlim=c(20,90), ylim=c(0,40), main=NULL, xlab=c('life expectancy (years)'), density=50, col='blue', border='black') 
hist(subset(mydat,year==2007)$lifeExp, xlim=c(20,90), ylim=c(0,40), main=NULL, xlab=c('life expectancy (years)'), density=50, col='blue', border='black', las=1) # las changes the axis label orientation 

# we can set the size and dimensions of the quartz window before plotting:
dev.new(width=8, height=4)
hist(subset(mydat,year==2007)$lifeExp, xlim=c(20,90), ylim=c(0,40), main=NULL, xlab=c('life expectancy (years)'), density=100, col='blue', border='black', las=1)
# this is useful when you want to be able to recreate a plot, including it's size and aspect ratio, later on
# las= 1 changes axis tick orientation

# scatterplots
##########################################
x <- 1:100
y <- 100:1
plot(y~x) # plot can take input in the form of a formula
plot(x, y) # or two vectors listed in x, y order

# using plot() on a vector simply plots the variable by row number
plot(mydat$gdpPercap) 
# this is a great way to check for outliers or typos in your data
mydat[mydat$gdpPercap>50000,] # ok

# plotting an entire dataframe gets you a scatterplot matrix:
plot(mydat)
str(mydat) # some are factors
plot(mydat[,c(2,3,5,6)]) # let's focus on the continuous variables
plot(mydat[,c(2,3,5,6)], cex=0.05) # shrinks the points
# point size is controlled with cex: 1 is default. add to make bigger, subtract to make smaller
# point type is controlled with the pch parameter: 1=open circles, 5=open diamonds, 22=open squares, 16=closed circles, 18=closed diamonds, 15=closed squares ...
# no need to remember that when you can just plot them to check
plot(1:30, pch=1:30)
plot(1:100, pch=1:100)

# same goes for color
plot(1:100, col=1:100, pch=16) # 8 basic colors
plot(1:100, col='red', pch=16) # we can refer to some by name
colors() # list of all color names possible
plot(1:length(colors()), col=colors())
plot(1:length(colors()), type='n'); abline(v=1:length(colors()), col=colors())
plot(1:100, pch=16, col='#8D93E1') # can specify with hex
plot(1:100, pch=16, col=rgb(0, 0.5, 0.5, 0.85)) # or RGB
help(rgb) # the 4th numeric argument is alpha, which gives the opacity. this is useful when you're plotting a lot of overlapping data...
plot(mydat$lifeExp~mydat$gdp, cex=0.5, pch=16, col=rgb(0,0,0,0.25)) 

# jitter can also help
help(jitter)
plot(pop~year, data=mydat, pch=16, cex=0.5)
plot(pop~jitter(year), data=mydat, pch=16, cex=0.5)

# we can connect points sequentially with a line. this is good for time series
treering # comes with R
head(treering)
plot(treering[1850:1950], type='l') 
help(plot) # try 'b' or 'c'. type='n' makes an empty fig

# what if one variable is a factor?
plot(pop~country, mydat) 
boxplot(pop~country, mydat) # so plot gets passed to boxplot in this case

# what if we give it a function?
plot(sin, -pi, 2*pi) # see ?plot.function
plot(log, 0, 10) # it gets passed to curve()

# QQ plots
##########################
# another common plot to inspect distributions of a variable is the QQ plot, which plots the quantiles of the data vs. the expected quantiles from a normal distribtion
par(mfrow=c(1,2)) #also can do mfcol
hist(subset(mydat,year==2007)$lifeExp)
qqnorm(subset(mydat,year==2007)$lifeExp) # not very normal
# mfrow in par sets the rows and columns of panels within the quartz window

# these plots are good for diagnosing skew and long/short tails
# if you have enough data and it's normally distributed, should see a straight line
set.seed(101); x <- rnorm(100) # try changing the sample size
hist(x)
qqnorm(x)
qqline(x) # qqline adds the expected line if the data were normally distributed
abline(a=0, b=1, col='red') # adds a line with slope of 1 and intercept 0. note that the expected qqline need not be the 1:1 line

# boxplots
##########################
# the distribution of a variable is also revealed nicely by a boxplot
boxplot(subset(mydat,year==2007)$gdpPercap)
boxplot(subset(mydat,year==2007)$gdpPercap, ylab="GDP per capita", las=1) # crowded. how to fix it?

# we can change settigns with par...
# mar sets the margins (bottom, left, top, and right). default is c(5.1, 4.1, 4.1, 2.1)
# mgp – sets the axis label locations relative to the edge of the inner plot window. The first value represents the location the labels (i.e. xlab and ylab in plot), the second the tick-mark labels, and third the tick marks. The default is c(3, 1, 0)
# las can also be specified to control orientation of the tick mark labels and any other text added to a plot after the plot's initialization. The options are as follows: las=0 (default) for always parallel to the axis, las=1 for always horizontal, las=2 for always perpendicular to the axis, and las=3 for always vertical
par(mfrow= c(1,1),mar = c(6,6,6,6), mgp = c(5,1,0)) 
boxplot(subset(mydat,year==2007)$gdpPercap, ylab="GDP per capita", las=1, xlab=c('2007')) 
# but now the x axis label is too far away
text(1, -5000, '2007', xpd=NA) # we can add text via x y coords. to print over margin have to add xpd=NA
locator(1)
str(par()) # par() has 72 options to work with!

# adding shapes and lines
##########################
# often we want to add regression lines, confidence intervals, error bars etc to plots

plot(mpg~wt, mtcars, pch=16)
lmod<-lm(mpg ~ wt, data=mtcars) # fit a straight line
summary(lmod)
abline(a=as.numeric(coef(lmod)[1]), b=as.numeric(coef(lmod)[2])) # intercept and slope from the fitted regression
abline(h=mean(mtcars$mpg),lty=2)
abline(v=mean(mtcars$wt),lty=2) # least squares regression always goes through the means

qmod<-glm(mpg~ poly(wt,2), data=mtcars) # maybe a quadratic function is a better fit...
summary(qmod)
# but how to add the fitted line to the plot?

# use the predict() function. first set up the set of x values to plot over:
weights <- seq(0, 6, by=0.01)
predictys <- predict(qmod, newdata=data.frame(wt=weights))

plot(mpg~wt, mtcars, pch=16)
points(predictys~weights, type='l', col='red')

# the predict function is really handy. we can use it to plot CIs around a regression prediction line, for instance
# first let's see how polygon works:
plot(mpg~wt, mtcars, pch=16)
polygon(x = c(3, 4, 4, 3), y = c(15, 15, 25, 25), border=NA, col=rgb(1,0,0,0.25))

# use predict() to get standard error of prediction values
predfit <- predict(qmod, newdata=data.frame(wt=weights), se.fit=T)
str(predfit)

# now plot the prediction line:
plot(mpg~wt, mtcars, pch=16)
points(predfit$fit~weights, type='l', col='blue')
# add upper and lower bounds using 1.96*SE for the 95% CI:
points(c(predfit$fit-1.96*predfit$se.fit)~weights, type='l', col='blue', lty=2)
points(c(predfit$fit+1.96*predfit$se.fit)~weights, type='l', col='blue', lty=2)
# now fill in the 95% CI:
polygon(x=c(weights, rev(weights)), y=c(predfit$fit+1.96*predfit$se.fit,rev(predfit$fit-1.96*predfit$se.fit)), col=rgb(0,0,1,0.25), border=NA)

# what about error bars?
# lots of ways to do this in R. most basic is segments:
mydat80s <- subset(mydat, year>1979 & year<1990)
tapply(mydat80s$lifeExp, mydat80s$continent, 'mean')
means <- tapply(mydat80s$lifeExp, mydat80s$continent, 'mean') # save the means
se <- tapply(mydat80s$lifeExp, mydat80s$continent, 'sd') / sqrt(tapply(mydat80s$lifeExp, mydat80s$continent, 'length')) # save the SEs

plot(means) # notice because this is a vector we get row number on the x. but we can remove the x axis and add our own: 
plot(means, pch=16, ylim=c(40, 80), xaxt='n', xlab=NA, ylab=c('life expectancy (years)'), family='Times', las=1)
axis(1, at=1:5, levels(mydat80s$continent), family='Times')
# now add error bars for the 95% CIs
segments(x0 = 1:5, y0 = means-1.96*se, y1 = means+1.96*se)

# surprisingly R doesn't have a function to draw regular error bars "out of the box", although there are packages that do this. here's a good workaround... just draw arrows with horizontal arrowheads:
sds <- tapply(mydat80s$lifeExp, mydat80s$continent, 'sd')
plot(means, pch=16, ylim=c(40, 80), xaxt='n', xlab=NA, ylab=c('life expectancy (years)'), family='Times', las=1)
axis(1, at=1:5, levels(mydat80s$continent), family='Times')
arrows(1:5, means+sds, 1:5, means-sds, length=0.05, angle=90, code=3)
# length is not the length of the whole arrow, but rather the lenght of the arrowhead. code determines which end the arrowheads get added to (3=both). angle=90 gives us flat arrowheads... error bars!

#store par settings
opar <- par()
#restore from opar
par(opar)
#only way to reset par in rstudio
dev.off()

# identifying points
############################
plot(iris$Sepal.Length, iris$Petal.Length)
identify(iris$Sepal.Length, iris$Petal.Length, labels=row.names(iris)) # here's a way of identifying the rows of plotted points

plot(iris$Sepal.Length, iris$Petal.Length)
locator(n=1,type="o") # do this to get the coordinates of any point. have to tell it how many you want though
coords<-locator(4, type='l') # save those coords
coords

plot(iris$Sepal.Length, iris$Petal.Length, pch=22, cex=0.5)
text(iris$Sepal.Length, iris$Petal.Length, pos=4, offset=0.35, cex=0.5) # puts the row number beside each data point. You can also specify a label as follows:

plot(iris$Sepal.Length, iris$Petal.Length, pch=10, cex=1.5)
text(iris$Sepal.Length, iris$Petal.Length, labels=iris$Species, pos=4, offset=0.35, cex=0.5) 

# color ramps
##########################
# here's how to control color by factor level in a plot:
plot(gdpPercap~jitter(year), mydat, pch=16, cex=0.5, ylim=c(0,50000), col=as.numeric(mydat$continent))

# what about using color to indicate the value of another variable?
help(rainbow) # R has several color ramp palette functions
plot(1:10, col=heat.colors(10), pch=16)
col=rainbow(10)
col
plot(1:10, col=rainbow(10), pch=16)
plot(1:100, col=rainbow(100), pch=16) # 
plot(1:100, col=rainbow(150), pch=16) # to avoid having red at both ends of the scale

plot(gdpPercap~jitter(year), mydat, pch=16, cex=0.5, ylim=c(0,50000), col=rainbow(9)[round(mydat$lifeExp,-1)/10]) 
# not very useful without a legend, unfortunately. we'll get there beolow

# you can make custom color ramps too...
myramp <- colorRampPalette(c("light green", "pink"))
myramp(100)
plot(1:100, col=myramp(100), pch=16)

library(dichromat) # the dichromat packages converts RGB colors to approximate what people with the most common forms of color blindness would see. useful for checking your figs
plot(1:100,col=dichromat(rainbow(100)),pch=16)
# dichromat also has color-blind friendly color palettes/ramps to explore
colorschemes

# legends
################################
plot(gdpPercap~jitter(year), mydat, pch=16, cex=0.5, ylim=c(0,50000), col=rainbow(9)[round(mydat$lifeExp,-1)/10])  
# this plot isn't very useful without a legend
legend(x=1950, y=50000, legend=rev(levels(factor(round(mydat$lifeExp,-1)))), pch=15, col=rev(rainbow(9)[2:8]), title='life exp (years)', bty='n', xpd = NA) #xpd = NA lets you put the legend outside the plot
# luckily R has a canned function to make lengends. the upper left corner of the legend box gets positioned at the coordinates supplied. you can also use character strings like 'bottomleft' or 'topright' as a shorthand to control position
# bty='n' removes the border
# you can making legends for different line types as well, by specifying lty instead of, or in addition to, col

# for something like this we really want a gradient legend...
# I couldn't find a canned function to do this with the base plot(), but there are some custom functions that people have shared online e.g. by Aurélien Madouasse at https://aurelienmadouasse.wordpress.com/2012/01/13/legend-for-a-continuous-color-scale-in-r/

# the corrplot() package has a way to do build a gradient legend on a separate plot:
library(corrplot)
layout(matrix(c(1,2), nrow=1, ncol=2, byrow = TRUE), widths=c(5,2))
# so let's open a window with two panels side-by-side. layout let's you do this and control the sizes of the panels within the window
# note that layout takes a matrix. the numbers in the matrix specify the order in which to plot. 0 means skip that panel (no plot).
plot(gdpPercap~jitter(year), mydat, pch=16, cex=0.5, ylim=c(0,50000), col=rainbow(90)[round(mydat$lifeExp)]) # plot the first fig. this time the point colors could take any value from 1:90
# now we'll plot the color legend as a gradient on the second, smaller panel
par(mar=c(4,0,3.,0)) # specify the margins for the second plot 
plot(0, type='n', xlim=c(0,1.5), ylim=c(0,1), axes=FALSE, ann=FALSE)
# plot a totally empty plot
colorlegend(rainbow(90)[20:83], labels=seq(20,83,by=10))
# from the corrplot package
# incomplete because there's no name
text(1.1, 0.5, 'life expectancy (years)', srt=90) # srt to rotate the text

# here's another way to do it on a second, separate plot. this time we use the base function image()
# first we create two panels side by side again:
layout(matrix(c(1,2), 1, 2, byrow=T), widths=c(5,1))
par(mar=rep(0.5,4), oma=rep(3,4), las=1) # we set the inner and outer margins, and specify that all axis labels be reoriented
plot(gdpPercap~jitter(year), mydat, pch=16, cex=0.5, ylim=c(0,50000), col=rainbow(90)[round(mydat$lifeExp)]) # unfortunately the axis labels of the original plot end up outside the margins, so we'd have to do some edits to get them visible again
image(1, 24:83, t(24:83), col=rainbow(90)[24:83], axes=F) # now draw the color gradient
axis(4) # adds the axis for the color legend on the right

summary(round(mydat$lifeExp)) # I used 24:83 because that's the range of life expectancies

# fine control
############################
nf <- layout(matrix(c(1,1,0,2), 2, 2, byrow=TRUE)) 
layout.show(nf) # layout.show() allows you to see the layout. note that the 0 allows us to add blank spaces that R won't plot in

# suppose you want to add boxplots around the borders of a scatterplot:
# fig takes a four item vector, wherein positions one and three define, in percentages of the quartz device region, the starting points of the x and y axes, respectively. positions two and four define the end points. check the default with par()$fit
par(fig=c(0,0.8,0,0.8), new=TRUE)
plot(mtcars$wt, mtcars$mpg, xlab="Car Weight", ylab="Miles Per Gallon")
par(fig=c(0,0.8,0.55,1), new=TRUE)
boxplot(mtcars$wt, horizontal=TRUE, axes=FALSE)
par(fig=c(0.65,1,0,0.8), new=TRUE)
boxplot(mtcars$mpg, axes=FALSE)
mtext("Enhanced Scatterplot", side=3, outer=TRUE, line=-3) 
# mtext allows you to write text directly on the margins. no guesswork about coordinates. line starts at 0 (outside of plot) and counts outwards, so make it more negative to move inwards

# see here for a diagram showing the margin definitions: http://research.stowers-institute.org/mcm/efg/R/Graphics/Basics/mar-oma/index.htm

# removing the box can help draw the eye to what counts
plot(mtcars$wt, mtcars$mpg, xlab="Car Weight", ylab="Miles Per Gallon", bty='n')

# or leave axes out and redraw them manually:
x  <- 1:100
y1 <- rnorm(100)
y2 <- rnorm(100) + 100

par(mar=c(5,5,5,5), fig=c(0, 1, 0.5, 1))
plot(x, y1, pch=0, type="b", col="red", yaxt="n", ylab="", xlab="", axes=F)
axis(side=2, at=c(-2,0,2))
mtext("red stuff", side = 2, line=2.5, at=0)

par(fig=c(0, 1, 0, 0.5), new=T) # plots on top of the current plot
plot(x, y2, pch=1, type="b", col="blue", yaxt="n", ylab="", xlab="", axes=F)
axis(side=4, at=c(98,100,102), labels=c("98%","100%","102%"))
mtext("blue stuff", side=4, line=2.5, at=100)

quartzFonts() # see the base fonts available
# here's how we modify the size and font usage of the quartz window:
par(mfrow=c(1,2), family='Times-Roman', ps=12) # make everything Times New Roman
boxplot(mydat$lifeExp, main="life expectancy (years)", las=1)
boxplot(mydat$gdpPercap, main="GDP per capita ($)", las=1)
mtext('boxplots', side=1, line=2, cex=2)

# saving automatically
############################
# first, change the working directory to be where you want your plot(s) saved
# then sandwich the graph-making code inbetween these 2 new commands:

levels(iris$Species)
Spp <- ifelse(iris$Species=='setosa', 1, ifelse(iris$Species=='versicolor', 15, 2))

pdf(file="myplot.pdf")

plot(iris$Sepal.Length, iris$Petal.Length, type="n", xlab="", ylab="", las=1, tcl=-0.35)
points(iris$Sepal.Length, iris$Petal.Length, pch=Spp, col=as.numeric(iris$Species)+1)
title(main="species differentiation in floral morphology", cex.main=1.25, xlab="sepal length (mm)", ylab="petal length (mm)")
legend(7, 2, c("I. setosa","I. versicolor","I. virginica"), pch=c(1,15,2), cex=1, col=2:4)

dev.off()

# output gets saved to a PDF file, for further tweaking in adobe illustrator or embedding in a manuscript. The other widely used options are: postscript(), png(), jpeg()
# this can be very useful if you need to generate and save a lot of plots automatically using a loop (e.g., to make an animation outside of R)

rm(list=ls()) # clean up the workspace
