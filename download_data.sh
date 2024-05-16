#!/bin/bash

# Create a folder named "Reads" if it doesn't exist
mkdir -p downloads downloads/reads

# Array of SRR accession numbers
SRR_LIST=(
    SRR2422918
    SRR2422919
    SRR2422920
    SRR2422921
    SRR2422922
    SRR2422923
    SRR2422924
    SRR2422925
    SRR2422926
    SRR2422927
    SRR2422928
    SRR2422929
    SRR2422930
    SRR2422931
    SRR2422932
    SRR2422933
    SRR2422934
)

# Loop through each accession number
for SRR in "${SRR_LIST[@]}"; do
    echo "Downloading and extracting reads for $SRR..."

    # Extract 1,000,000 reads from the SRA file
    fastq-dump --split-files -X 100000 $SRR -O downloads/reads
done

echo "Download and extraction complete."

