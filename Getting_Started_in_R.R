### Sample R code for Byrne Big Data Seminar
### Spring 2021 - Ryan Womack


###################################################
### install packages
###################################################
install.packages("ISwR", dependencies=TRUE)
install.packages("ggplot2", dependencies=TRUE)
install.packages("dplyr", dependencies=TRUE)
install.packages("RMySQL",dependencies=TRUE) 
install.packages("DBI", dependencies=TRUE) 
install.packages("datanugget", dependencies=TRUE)
update.packages()


###################################################
### 2+2
###################################################
2+2


###################################################
### writing a function
###################################################
funkyadd<-function(x,y)
{
  x+y+1
}
funkyadd(2,2)


###################################################
### samples and distributions
###################################################
sample(1:100,10)
rnorm(10)
rnorm(10, mean=100, sd=20)


###################################################
### package and data loading
###################################################
library("ISwR")
data(cystfibr)
library(help=ISwR)
?cystfibr
summary(cystfibr)


###################################################
### attaching a dataset
###################################################
mean(cystfibr$age)
# this generates an error
# mean(age)
attach(cystfibr)
mean(age)


###################################################
### descriptive statistics
###################################################
sd(age)
var(age)
median(age)
quantile(age)
summary(age)


###################################################
### histogram
###################################################
hist(age)


###################################################
### by
###################################################
by(cystfibr, cystfibr["sex"],summary)


###################################################
### table
###################################################
table(sex)
table(age,sex)


###################################################
### t test
###################################################
t.test(pemax)
mean(pemax)
t.test(pemax, mu=100)
t.test(pemax, mu=90, conf.level=.99)


###################################################
### 2 sample t test
###################################################
t.test(pemax~sex)


###################################################
### linear regression
###################################################
lm(pemax~tlc)
summary(lm(pemax~tlc))
regoutput<-lm(pemax~tlc)
names(regoutput)
regoutput$residuals


###################################################
### predict
###################################################
predict(regoutput)


###################################################
### anova
###################################################
anova(regoutput)


###################################################
### plot
###################################################
plot(regoutput, pch=3)


###################################################
### multiple regression
###################################################
lm(pemax ~ tlc + age + sex)
summary(lm(pemax ~ tlc + age + sex))


###################################################
### graphics with ggplot
###################################################
library(ggplot2)
data(diamonds)
?diamonds
attach(diamonds)

ggplot(diamonds, aes(carat,price)) + geom_point()
ggplot(diamonds, aes(carat,price)) + facet_grid(.~clarity) + geom_point()
ggplot(diamonds, aes(clarity)) + facet_grid(.~cut) + geom_bar(position="dodge")
ggplot(diamonds, aes(carat,price)) + xlim(0,3) + geom_point(colour="steelblue", pch=3) + 
  labs(x="weight of diamond in carats", y="price of diamond in dollars", title="Diamond Data") 
ggplot(diamonds, aes(carat, price)) + geom_point() + geom_smooth(method=lm)

###################################################
### read.table for text data import
###################################################
importdata<-read.table("http://ryanwomack.com/data/myfile.txt")
importdata2<-read.table("http://ryanwomack.com/data/myfile2.txt", header=TRUE, sep=";",row.names="id", na.strings="..", stringsAsFactors=FALSE)


###################################################
### Excel files 
###################################################

# Hadley Wickham's readxl is new, requires no external dependencies on Linux, Mac, Windows
# cannot read from http connection
library(readxl)
download.file("http://ryanwomack.com/data/mydata.xls", "mydata.xls", mode='wb')
importdata8 <- read_excel ("mydata.xls", 1)


###################################################
### Quick dplyr example
###################################################

library(dplyr)
cutdiamonds<- filter(diamonds, cut %in% c("Ideal", "Premium"), color %in% c("D","E","F"))


###################################################
### Databases 
###################################################
library(RMySQL) 
library(DBI) 

# we connect to the publicly available genome server at genome.ucsc.edu
# see that site for documentation of tables and schema

con = dbConnect(MySQL(), host="genome-mysql.cse.ucsc.edu", user="genome", dbname="hg19") 
knownGene = dbReadTable (con, 'knownGene') 
head(knownGene) 
table(knownGene$chrom) 
sort(table(knownGene$chrom), decreasing=TRUE) 

proteins = dbGetQuery(con, "SELECT * FROM knownGene WHERE proteinID='O95872'") 
proteins
proteins[order(proteins$exonEnds, decreasing=TRUE), ]
dbDisconnect(con)


###################################################
### Big Data 
###################################################

# see deltarho.org for an example


###################################################
### Data Nuggets
###################################################
library(datanugget)

# create numeric-only version of diamonds data
diamonds2<-as.data.frame(diamonds[,-c(2:4)])

# create nuggets
my_nugget<-create.DN(diamonds2, RS.num=10000, DN.num1=2000, DN.num2=200, no.cores=0)
my_nugget$`Data Nuggets`
my_nugget$`Data Nugget Assignments`

ggplot(diamonds2, aes(carat,price))+geom_point()
ggplot(my_nugget$`Data Nuggets`, aes(Center1,Center4))+geom_point()+labs(x="carat",y="price")

# further examples

## Generate Datasets N=5*10^5
set.seed(3217)
X = cbind.data.frame(X1=rnorm(5*10^5),
                     X2=rnorm(5*10^5),
                     X3=rnorm(5*10^5))
## We make 3 clusters
X[,1]= X[,1]+2*rep(-1:1,c(1.67*10^5,1.66*10^5,1.67*10^5))
X[,2]= X[,2]+3*rep(c(0,1,0),c(1.67*10^5,1.66*10^5,1.67*10^5))

## But they are hard to see in a scatter plot
plot(X[,1],X[,2],pch=".",col=2,cex=7)

## So we create the data nuggets
my.DN = create.DN(x = X,
                  RS.num = 10^4,
                  DN.num1 = 500,
                  DN.num2 = 250,
                  no.cores = 0)

my.DN$`Data Nuggets`
my.DN$`Data Nugget Assignments`

## Refining step
my.DN2 = refine.DN(x = X,
                   DN = my.DN,
                   scale.tol = .9,
                   shape.tol = .9,
                   min.nugget.size = 2,
                   max.nuggets = 1000,
                   scale.max.splits = 5,
                   shape.max.splits = 5,
                   no.cores = 0)

my.DN2$`Data Nuggets`
my.DN2$`Data Nugget Assignments`

## Define the centers and weights
centers=my.DN2$`Data Nuggets`[,2:4]
w=my.DN2$`Data Nuggets`[,5]

## Plot the data nuggets
plot(centers[,1],centers[,2],pch=16,col=2,cex=sqrt(w)/18)

## Cluster the data nuggets
DN.clus = WKmeans(dataset =centers,k = 3,
                  obs.weights = w,
                  num.init = 3,
                  max.iterations = 30,
                  reassign.prop = .33)

## Plot clusters
plot(centers[,1],centers[,2],pch=16,col=DN.clus[[1]],cex=sqrt(w)/18)

## large example
X = cbind.data.frame(rnorm(10^6),
                     rnorm(10^6),
                     rnorm(10^6),
                     rnorm(10^6),
                     rnorm(10^6))

my.DN = create.DN(x = X,
                  RS.num = 10^5,
                  DN.num1 = 10^4,
                  DN.num2 = 2000,
                  no.cores = 0)

my.DN$`Data Nuggets`
my.DN$`Data Nugget Assignments`
