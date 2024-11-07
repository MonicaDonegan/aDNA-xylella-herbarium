library(seqinr)


args = commandArgs(trailingOnly=TRUE) ## include alignment in fasta format

aln<-read.alignment(args[1], format='fasta')

dna<-(as.matrix.alignment(aln))

isa=as.numeric(apply(dna=="a"|dna=="A",2,sum)>0)
ist=as.numeric(apply(dna=="t"|dna=="T",2,sum)>0)
isc=as.numeric(apply(dna=="c"|dna=="C",2,sum)>0)
isg=as.numeric(apply(dna=="g"|dna=="G",2,sum)>0)
issnp=isa+ist+isc+isg
pos_var=(1:length(issnp))[issnp>1]
pos_non_var=(1:length(issnp))[issnp<2]
snp=dna[,issnp>1]
invariant=dna[,issnp<2]


isa=as.numeric(apply(invariant=="a"|invariant=="A",2,sum)>0) 
ist=as.numeric(apply(invariant=="t"|invariant=="T",2,sum)>0)
isc=as.numeric(apply(invariant=="c"|invariant=="C",2,sum)>0) 
isg=as.numeric(apply(invariant=="g"|invariant=="G",2,sum)>0)
isn=as.numeric(apply(invariant=="n"|invariant=="N",2,sum) == dim(invariant)[1])

output_df<- data.frame('base_type' = c('snp', 'a_invariant', 'c_invariant', 'g_invariant', 't_invariant', 'n_invariant', 'total_bp'), 'count' = 
c(dim(snp)[2], sum(isa), sum(isc), sum(isg),sum(ist), sum(isn), dim(dna)[2])) 

write.csv(output_df, "invariant_sites_recrem_alignment.csv")
