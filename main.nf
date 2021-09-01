#!/usr/bin/env nextflow


params.saveMode = 'copy'
params.reads = "$baseDir/input_reads/*.{1,2}.fq.gz"
params.genome = "$baseDir/genome/EW_genome.fasta.gz"
params.resultGenome = "$baseDir/genome"
params.resultsTrim = "$baseDir/trim_reads/"
params.resultsAlign = "$baseDir/alignment/"
params.resultsRAD = "$baseDir/stacks/"
params.popmap = "$baseDir/popmap.txt"


log.info """\
         d d R A D S E Q - N F   P I P E L I N E    
         ===================================
         genome: ${params.genome}
         reads: ${params.reads}
         """
         .stripIndent()


genome = file(params.genome)

process genome_index {

	tag "$genome"
	publishDir params.resultGenome, mode: params.saveMode
	
	input:
	file genome 
	
	output:
	path '*' into genome_index_ch
	
	script:
	
	"""
	bwa index ${genome}	
	"""

}


trim_single_in_ch = Channel.fromFilePairs(params.reads)

process trimmomatic_single {

	tag "$genomeName"
	
	publishDir params.resultsTrim, mode: params.saveMode
	
    input:
    tuple genomeName, file(genomeReads) from trim_single_in_ch
	
    output:
	tuple val(genomeName), file("*.trim.{1,2}.fq.gz") into trim_single_out_ch

    script:
	
    fq_1 = genomeName + '.trim.1.fq.gz'
    fq_2 = genomeName + '.trim.2.fq.gz'

    """
    java -jar /usr/bin/trimmomatic-0.38.jar SE -threads 4 -phred33 ${genomeReads[0]} $fq_1 HEADCROP:5 
    java -jar /usr/bin/trimmomatic-0.38.jar SE -threads 4 -phred33 ${genomeReads[1]} $fq_2 HEADCROP:3     
    """
}

process trimmomatic_paired {
	
	tag "$genomeName"
	
	publishDir params.resultsTrim, mode: params.saveMode
	
    input:
    tuple val(genomeName), file(genomeReads) from trim_single_out_ch
	
    output:
    tuple val(genomeName), file("*.P{1,2}.fq.gz") into trim_paired_out_ch

    script:
	
    fq_1_paired = genomeName + '.P1.fq.gz'
    fq_1_unpaired = genomeName + '.U1.fq.gz'
    fq_2_paired = genomeName + '.P2.fq.gz'
    fq_2_unpaired = genomeName + '.U2.fq.gz'

    """
    java -jar /usr/bin/trimmomatic-0.38.jar PE -threads 4 -phred33 ${genomeReads} $fq_1_paired $fq_1_unpaired $fq_2_paired $fq_2_unpaired LEADING:20 TRAILING:20 MINLEN:60 
    """
}


process alignment {	

	tag "$genomeName"
	
	publishDir params.resultsAlign, mode: params.saveMode
	
	
	input:	
	tuple val(genomeName), file(genomeReads) from trim_paired_out_ch
    file index from genome_index_ch.first()
    file genome
    
	output:
	file("${genomeName}.bam") into aligned_ch
	
	script:
		
	"""	
	bwa mem ${genome} ${genomeReads[0]} ${genomeReads[1]} | samtools view -bSq 20 | samtools sort -O bam > ${genomeName}.bam
	"""

}


process stacks_refmap {

	publishDir params.resultsRAD, mode: params.saveMode
	
	input:
	path (sampleReads) from aligned_ch.toList()
	
	output:
	set val("$name"), file("${name}/") into refmap_results
	
	script:
	name= "ref_stacks"
	
	"""
	mkdir ${name}
	ref_map.pl -T 4 --samples $baseDir/alignment/ -o ${name} --popmap ${params.popmap}

	"""

}


