# radseq-processing-nf
A basic pipeline for cleaning raw reads, genome alignment, and locus assembly with Stacks, implemented with Nextflow.

# Usage

nextflow run https://github.com/marcocrotti/radseq-processing-nf --reads 'path/to/reads' --genome 'path/to/ref_genome' --resultGenome 'path/to/ref_genome' --resultsTrim 'path/to/trimm_files' --resultsAlign 'path/to/aligned_reads' --resultsRAD 'path/to/stacks_results/ --popmap 'path/to/stacks_popmap' --saveMode copy -r main -with-report -with-trace -with-timeline
