Usage:

-clone repo into empty directory
-mkdir data
-mkdir data/samples_raw
-mkdir data/samples_raw/{sample_name}
-for each sample, place the fastqs for
 that sample in data/samples_raw/{sample_name}/
-specify path to reference genome in workflow/config/config.yaml

-run with 'snakemake --use-conda'

Output file structure:
└────data/
     ├────mapped_reads/
     |    ├────{sample_name}.bam
     |    └────{sample_name}.bam.bai
     |
     ├────samples/
     |    └────{sample_name}.fastq.gz
     |
     ├────samples_raw/
     |    └────{sample_name}/
     |
     └────variants/
          └────{sample_name}_variants.vcf
