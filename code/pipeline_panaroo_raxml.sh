#!/bin/bash -l

####Dependencies####

## SET NAMES AND FOLDERS
stringname="" #name of job
outgroup="" #name of outgroup strain
output_home="" #path to output dir
gff_folder="" #path to folder of .gff files

module load python/3.6
module load raxml/8.2.11
module load r
module load r-packages
module load java
module list

## panaroo pan-genome alignment
conda activate panaroo
panaroo -i $gff_folder/*.gff -o $output_home/${stringname} --clean-mode strict  --remove-invalid-genes -a core --alignment core --core_threshold 0.95 --threads 4
conda deactivate

## get SNPs only
conda activate snpsites
snp-sites -m -o $output_home/${stringname}/core_gene_snps.aln $output_home/${stringname}/core_gene_alignment.aln
conda deactivate

raxmlHPC -s $output_home/${stringname}/core_gene_snps.aln -n ${stringname}.tree -m GTRCAT -f a -x 12345 -p 12345 -N 10 -o ${outgroup}
mv *${stringname}* $output_home/${stringname}

## run ClonalFrameML
conda activate clonalframe
ClonalFrameML $output_home/${stringname}/RAxML_bestTree.${stringname}.tree $output_home/${stringname}/core_gene_alignment.aln ${stringname}
conda deactivate
#mv *${stringname}* $output_home/${stringname}

## run Homoplasy Finder
Rscript homoplasy_finder.R $output_home/${stringname}/RAxML_bestTree.${stringname}.tree $output_home/${stringname}/core_gene_alignment.fasta $output_home/${stringname}
mv *${stringname}* $output_home/${stringname}

## combine CFML and Homoplasy Finder results
Rscript combine_homoplasy_clonal.R $output_home/${stringname}/${stringname}.importation_status.txt $output_home/${stringname}/*consistencyIndexReport*txt
mv clonal_homoplasy_combo.txt $output_home/${stringname}

### remove recombination
## convert to .fasta extension for CFML removal
cp $output_home/${stringname}/core_gene_alignment.aln $output_home/${stringname}/core_gene_alignment.fasta

python recombination_removal_clonalframe.py -f $output_home/${stringname}/core_gene_alignment.fasta -r $output_home/${stringname}/clonal_homoplasy_combo.txt

mv $output_home/${stringname}/core_gene_alignment_one_line_recombination_removed.fasta $output_home/${stringname}/core_gene_norec.aln

## calculate invariant sites for BEAST, move output to folder

Rscript count_invariant.R $output_home/${stringname}/core_gene_norec.aln 
mv invariant_sites_recrem_alignment.csv $output_home/${stringname}

## get SNPs from no rec alignment

conda activate snpsites
snp-sites -m -o $output_home/${stringname}/core_gene_no_rec_snps.aln $output_home/${stringname}/core_gene_norec.aln
conda deactivate

## re run tree with no rec snps

raxmlHPC -s $output_home/${stringname}/core_gene_no_rec_snps.aln -n ${stringname}_norem.tree  -m GTRCAT -f a -x 12345 -p 12345 -N 100 -T 24 -o ${outgroup}

