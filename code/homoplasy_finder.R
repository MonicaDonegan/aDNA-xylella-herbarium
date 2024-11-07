args = commandArgs(trailingOnly=TRUE) ## ARGS: [1] best tree [2] core alignment [3] file path

options(java.parameters = "-Xmx8g")
install.packages("rJava")
library(rJava)
library(devtools)
library(homoplasyFinder) 

incon_pos<- runHomoplasyFinderInJava(treeFile=args[1], fastaFile=args[2], path=args[3])
