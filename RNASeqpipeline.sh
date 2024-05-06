#!/bin/bash

SECONDS=0

# Make necessary directories
mkdir data data/fastqc1 data/trimmed_reads data/fastqc2 data/alignments data/quant
echo "Output Directories created!!!"

# Array to hold all BAM files
BAM_FILES=()

for file in Reads/*_1.fastq; do
    echo "Processing file: $file"

    # Place your processing commands here
    base=$(basename -s _1.fastq "$file")

    # Run fastqc
    fastqc "Reads/${base}_1.fastq" "Reads/${base}_2.fastq" -o data/fastqc1

    # Run trimmomatic to trim reads with poor quality
    java -jar trimmomatic-0.39.jar PE "Reads/${base}_1.fastq" "Reads/${base}_2.fastq" \
    "data/trimmed_reads/${base}.trimmed.paired.R1.fastq" "data/trimmed_reads/${base}.trimmed.unpaired.R1.fastq" \
    "data/trimmed_reads/${base}.trimmed.paired.R2.fastq" "data/trimmed_reads/${base}.trimmed.unpaired.R2.fastq" TRAILING:10 -phred33 -threads 4

    echo "Trimmomatic finished running for ${base}!"

    # Run fastqc on trimmed reads
    fastqc "data/trimmed_reads/${base}.trimmed.paired.R1.fastq" "data/trimmed_reads/${base}.trimmed.paired.R2.fastq" -o data/fastqc2
    echo "Fastqc completed for ${base}"

    # Run HISAT2 for alignment
    hisat2 -q -x grch38/genome -1 "data/trimmed_reads/${base}.trimmed.paired.R1.fastq" -2 "data/trimmed_reads/${base}.trimmed.paired.R2.fastq" | samtools sort -o "data/alignments/${base}.bam"
    echo "HISAT2 finished running for ${base}!"

    # Add the BAM file to the array
    BAM_FILES+=("data/alignments/${base}.bam")
done

# Run MultiQC
multiqc data/fastqc1 -o data/multiqc1

# Run MultiQC on second Fastqc reports
multiqc data/fastqc2 -o data/multiqc2

# Run featureCounts for quantification on all BAM files
featureCounts -a Homo_sapiens.GRCh38.111.gtf -T 10 -o data/quant/output_data.txt "${BAM_FILES[@]}"

# clean feature matrix
cut -f1,7- -s data/quant/output_data.txt | cat > data/quant/counts_data.txt

# echo "featureCounts finished running for all samples!"

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
