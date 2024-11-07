# Century-old herbarium specimen provides insights into Pierce’s disease of grapevines emergence in the Americas
## Monica A Donegan, Alexandra K Kahn, Nathalie Becker, Andreina Castillo Siri, Paola Campos, Karine Boyer, Alison Colwell, Martial Briand, Rodrigo PP Almeida, Adrien Rieux
This repository contains code for a bioinformatics pipeline to analyze a set of annotated bacterial genomes, remove inferred recombination, make a phylogenteic tree from Donegan, Kahn et al. 2024. 

List of additional softwares and dependencies used in the pipeline: 
1. [panaroo](https://github.com/gtonkinhill/panaroo) 
2. [SNP-sites](https://sanger-pathogens.github.io/snp-sites/)
3. [RAxML](https://github.com/stamatak/standard-RAxML) 
4. [ClonalFrameML](https://github.com/xavierdidelot/ClonalFrameML) 
5. [HomoplasmyFinder](https://github.com/JosephCrispell/homoplasyFinder)

The steps in this pipeline (pipeline_panaroo_raxml.sh) include: 
1. Run a pan-genome alignment with panaroo and extract SNPs with SNP-sites.
2. Run an initial maximum likelihood tree with RAxML.
3. Infer recombinant sites with both ClonalFrameML and HomoplasyFinder, using the best tree from RAxML.
4. Combine results from ClonalFrameML and HomoplasyFinder and remove these sites from the core genome alignment, from panaroo.
5. Calculate invariant sites from the recombination-free core genome for downstream BEAST analyses.
6. Extract SNPs from the recombination-free core genome with SNP-sites.
7. Re-run the maximum likelihood tree with RAxML, using the recombination-free core genome. 

