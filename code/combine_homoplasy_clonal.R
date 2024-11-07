
args = commandArgs(trailingOnly=TRUE) ## ARGS: [1]CFML file, *importation_status.txt [2] Homoplasy file, *consistencyIndexReport.txt

file=read.table(args[1],header=T)
homfinder<- read.table(args[2], header = T)

homfinder$CF <- 0 # 0 = not in CF, 1 = in CF 
for (j in 1:dim(homfinder)[1]) {
  subset<- file[file$Beg <= homfinder$Position[j],]
  subset<- subset[subset$End >= homfinder$Position[j] ,]
  if (dim(subset)[1] != 0) {
    homfinder$CF[j]<- 1
  }
}

homfinder_only<- homfinder[homfinder$CF == 0, ]
homfinder_only <- homfinder_only[order(homfinder_only$Position),]


start_counter <- homfinder_only$Position[1]
for (j in 1:(dim(homfinder_only)[1] -1)) {
  if (homfinder_only$Position[j+1] == homfinder_only$Position[j] + 1) {
    if (homfinder_only$Position[j] -1 == homfinder_only$Position[j-1]) {
    } else {
      start_counter<- homfinder_only$Position[j]
    }
  } else {
    file[nrow(file) + 1,] <- list("node_filler", start_counter, homfinder_only$Position[j])
    start_counter<- homfinder_only$Position[j+1]
  }
}

write.table(file, 'clonal_homoplasy_combo.txt', row.names = F, quote = F)
