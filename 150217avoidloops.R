
######################
# avoiding loops in R
######################

# now that you know how to loop, you may be tempted to use them all the time
# today we'll practice not using them

# here's an example of what I mean:

head(iris) # suppose we want a new column that categorizes by sepal length
summary(iris$Sepal.Length) 

iris$sep.group <- 0
for (i in 1:length(iris$Sepal.Length)){
	if(iris$Sepal.Length[i] > 5 & iris$Sepal.Length[i] < 6){
		iris$sep.group[i] <- 1
	}
	if(iris$Sepal.Length[i] >= 6){
		iris$sep.group[i] <- 2
	}
}
head(iris)
plot(Sepal.Length~sep.group,iris)

# this works, but it's long and ugly, with a high probability of mistakes
# also if we had a lot of data it would be very slow

##########
# ifelse
##########

# ifelse() can do this in a vectorized way:

iris$sep.group2 <- ifelse(iris$Sepal.Length > 6, 1, 0)
help(ifelse)

# what if we want 3 groups? We can use nested ifelse() statements:

iris$sep.group3 <- ifelse(iris$Sepal.Length > 5 & iris$Sepal.Length < 6, 1,
					ifelse(iris$Sepal.Length >= 6, 2, 0))
					
# separated onto 2 lines for ease of reading only
# we can see this gives the same result as the loop above:
plot(sep.group~sep.group3, iris, pch=16)

# you can nest as many ifelses as you want, but be careful about your final category - it assigns the last value to whatever values are left over that didn't meet any condition (including if a value is NA)

# other ways ifelse() can be useful:

### to create a column with group/category means:
iris$meansep.byspecies <- ifelse(iris$Species=='virginica',  
               mean(iris$Sepal.Length[iris$Species=='virginica'], na.rm=TRUE),
               ifelse(iris$Species=='versicolor',
               mean(iris$Sepal.Length[iris$Species=='versicolor'], na.rm=TRUE),
               mean(iris$Sepal.Length[iris$Species=='setosa'], na.rm=TRUE)))

### to recode missing values:
iris$Sepal.Width[c(2,4,5)] <- NA # first we create them, since iris has no NAs
head(iris)

iris$sep.w2 <- ifelse(is.na(iris$Sepal.Width),
                      9999, 
                      iris$Sepal.Width)
head(iris)

### create a column that combines values from two others, depending on some condition:
iris$flowerID <- 1:length(iris[,1]) # first let's create an ID# for each flower
tail(iris)

iris$ID.long <- ifelse(iris$flowerID < 10, 
                paste(iris$Species, "-00", iris$flowerID, sep=""),
                ifelse(iris$flowerID < 100,
                paste(iris$Species, "-0", iris$flowerID, sep=""),
                paste(iris$Species, "-", iris$flowerID, sep="")))
head(iris);tail(iris)

# they apply family of functions is another useful set of tools for avoiding writing loops

##########
# 1. apply
##########

help(apply)
# what are these margins? either rows (1), columns (2) or both (1:2). By both, we mean apply the function to each individual value

# create a matrix of 10 rows x 2 columns
(m <- matrix(c(1:10, 11:20), nrow = 10, ncol = 2))
# mean of the rows
apply(m, 1, mean)
# mean of the columns
apply(m, 2, mean)
# divide all values by 2
apply(m, 1:2, function(x) x/2) # rows and columns

# that last example was rather trivial; you could just as easily do:
m/2 

# by the way, apply actually uses a loop internally
# let's do a comparison:
N <- 10000
x1 <- runif(N)
x2 <- runif(N)
(d <- as.data.frame(cbind(x1, x2))) # suppose we want row means

# the explicit loop
system.time(
for(loop in 1:length(d[,1])) {
	d$mean1[loop] <- mean(c(d[loop,1], d[loop,2]))
}
)
# takes just over 1 second

# now we'll use apply to do the same thing
system.time(d$mean2 <- apply(d, 1, mean)) 
# using apply to get the row means takes < 0.1 seconds

# now let's try the fully vecotrized rowMeans() function:
system.time(d$mean3 <- rowMeans(d[,1:2]))
# fastest at < 0.001 seconds

head(d)

# while we're timing things, let's compare initializing vs. growing a vector:

start <- Sys.time()
x <- c()
for(i in 1:100000){
	x = c(x,i)
}
Sys.time() - start # takes >20 seconds

start <- Sys.time()
x <- rep(1,100000)
for(i in 2:100000){
	x[i] <- x[i-1]+1
}
Sys.time() - start # down to <0.20 seconds.  

start <- Sys.time()
z <- 1:100000
Sys.time() - start 

# moving on to the other functions in the apply family...

##########
# 2. by
##########

help(by)

# read a little further: “a data frame is split by row into data frames subsetted by the values of one or more factors, and function ‘FUN’ is applied to each subset in turn.”
# so, we use by() where factors are involved.

# get the mean of the first 4 flower measurements, by species
by(iris[, 1:4], iris$Species, colMeans)
# so by provides a way to split your data by factors and do calculations on each subset. It returns an object of class “by”

##########
# 3. tapply
##########

help(tapply)
# sounds complicated, but it's not
# usage is “tapply(X, INDEX, FUN = NULL, …, simplify = TRUE)”, where X is “an atomic object, typically a vector” and INDEX is “a list of one or more factors, each of same length as X”

# so to go back to the iris data, “Species” might be a factor and “iris$Petal.Width” would give us a vector of values. We could then run something like:

tapply(iris$Petal.Length, iris$Species, mean)

# compare to:
by(iris$Petal.Length, iris$Species, mean)

# difference is that by() adds some things to the output

##########
# 4. eapply
##########

help(eapply)

# this one is a little trickier, since you need to know something about environments in R. An environment is a self-contained object with its own variables and functions
# for example, let's create an environment:
e <- new.env()

# two environment variables, a and b
(e$a <- 1:10)
(e$b <- 11:20)

# mean of the variables
eapply(e, mean)

# I don’t create my own environments, but they’re commonly used by R packages such as Bioconductor so it’s good to know how to handle them

##########
# 5. lapply
##########

help(lapply)

# so lapply returns a list. An example:
# create a list with 2 elements
(l <- list(a = 1:10, b = 11:20))

# the mean of the values in each element
lapply(l, mean)

# the sum of the values in each element
lapply(l, sum)

# the lapply documentation covers sapply, vapply and replicate. Let’s do that.

	##########
	# 5.1 sapply
	##########

help(lapply)

# so if lapply would have returned a list with elements $a and $b, sapply will return either a vector, with elements [[‘a’]] and [[‘b’]], or a matrix, with column names “a” and “b”. Returning to our previous simple example:
	
# create a list with 2 elements
(l <- list(a = 1:10, b = 11:20))

# mean of values using sapply
(l.mean <- sapply(l, mean))
# what type of object was returned?
class(l.mean)
# it's a numeric vector, so we can get element "a" like this
l.mean[['a']]

# when does it return a matrix? depends on the function, I guess?

	##########
	# 5.2 vapply
	##########

# a third argument is supplied to vapply, which you can think of as a kind of template for the output. The documentation uses the fivenum function as an example, so let’s go with that.
help(fivenum)

(l <- list(a = 1:10, b = 11:20))

# fivenum of values using vapply
l.fivenum <- vapply(l, fivenum, c("Min"=0, "1st Q"=0, "Median"=0, "3rd Q"=0, "Max"=0))
class(l.fivenum)
# let's see it
l.fivenum

# returned a matrix, where the column names correspond to the original list elements, and the row names to the 3rd argument supplied to vapply

	##########
	# 5.3 replicate
	##########

# the replicate function is very useful. It takes two mandatory arguments: the number of replications, and the function to replicate
# An example – let’s simulate 10 normal distributions, each with 10 observations:

replicate(10, rnorm(10))

# so replicate and apply together make for a convenient way of running a simulation and collecting the results without loops
# e.g.:
results <- data.frame(replicate(1000, rpois(10, 5)))
(apply(results, 2, FUN='mean'))
hist(apply(results, 2, FUN='mean'))

# is there a timing advantage over a loop?

system.time(results <- data.frame(replicate(10000, rpois(10, 5))))

results <- data.frame(matrix(nrow=10, ncol=10000))
system.time(for(i in 1:10000){ results[,i] <- rpois(10, 5)}) # yes.

##########
# 6. mapply
##########

# mapply is a multivariate version of sapply
# mapply applies FUN to the first elements of each argument, the second elements, the third elements, and so on.”

# here’s a simple example example:
(l1 <- list(a = c(1:10), b = c(11:20)))
(l2 <- list(c = c(21:30), d = c(31:40)))

# sum the corresponding elements of l1 and l2
mapply(sum, l1$a, l1$b, l2$c, l2$d)

# here, we sum l1$a[1] + l1$b[1] + l2$c[1] + l2$d[1] (1 + 11 + 21 + 31) to get 64, the first element of the returned list. All the way through to l1$a[10] + l1$b[10] + l2$c[10] + l2$d[10] (10 + 20 + 30 + 40) = 100, the last element.

##########
# 7. rapply
##########

# rapply is a recursive version of lapply
# rapply applies functions to lists in different ways, depending on the arguments supplied
# this is best illustrated by examples:

# let's start with our usual list:
(l <- list(a = 1:10, b = 11:20))

# log2 of each value in the list
rapply(l, log2)

# log2 of each value in each list
rapply(l, log2, how = "list")
 
# what if the function is the mean?
rapply(l, mean)
rapply(l, mean, how = "list")

# so the output of rapply depends on both the function and the how argument. When how = “list” (or “replace”), the original list structure is preserved. Otherwise, the default is to unlist, which results in a vector
# You can also pass a “classes=” argument to rapply. For example, in a mixed list of numeric and character variables, you could specify that the function act only on the numeric values with “classes = numeric”.


#########################
# content from:
# Neil Saunders at https://nsaunders.wordpress.com/2010/08/20/a-brief-introduction-to-apply-in-r/
# http://www.r-bloggers.com/for-loops-and-how-to-avoid-them/



rm(list=ls())

