"""
First three rules align the reads to reference
then sort and index for further analysis
"""

configfile: "workflow/config/config.yaml"

SAMPLE = ["bc01"]
# REFERENCE = "../data/CaenCA_mtgenome_final.fasta"

rule all:
    input:
        expand("data/variants/{sample}_variants.vcf", sample=SAMPLE)

# merge sample fastqs into one file
rule merge_fastqs:
    output:
        "data/samples/{sample}.fastq"
    shell:
        "cat data/samples_raw/{wildcards.sample}/*.fastq > {output}"

# gzip fastq
rule gzip_fastq:
    input:
        "data/samples/{sample}.fastq"
    output:
        "data/samples/{sample}.fastq.gz"
    shell:
        "gzip {input}"

# align reads using minimap > convert to bam > sort bam
rule align_reads:
    input:
        reads="data/samples/{sample}.fastq.gz",
        ref=expand("{ref}", ref=config["reference"])
    output:
        bam="data/mapped_reads/{sample}.bam"
    conda:
        "workflow/envs/main.yaml"
    shell:
        "minimap2 -ax map-ont {input.ref} {input.reads} | "
        "samtools view -Sb | samtools sort -o {output}"

rule index_reference:
    input:
        ref=expand("{ref}", ref=config["reference"])
    output:
        ref_idx=expand("{ref}.fai", ref=config["reference"])
    conda:
        "workflow/envs/main.yaml"
    shell:
        "samtools faidx {input.ref}"

# index bam
rule index_alignment:
    input:
        bam="data/mapped_reads/{sample}.bam"
    output:
        indexed_bam="data/mapped_reads/{sample}.bam.bai"
    conda:
        "workflow/envs/main.yaml"
    shell:
        "samtools index -b {input.bam}"

# call SNPs using longshot
rule find_variants:
    input:
        bam="data/mapped_reads/{sample}.bam",
        indexed_bam="data/mapped_reads/{sample}.bam.bai",
        ref=expand("{ref}", ref=config["reference"]),
        ref_idx=expand("{ref}.fai", ref=config["reference"])
    output:
        variants="data/variants/{sample}_variants.vcf"
    conda:
        "workflow/envs/main.yaml"
    shell:
        "longshot --ref {input.ref} --bam {input.bam} --out {output.variants}"
