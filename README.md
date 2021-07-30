# **A pipeline for PTMA tags detection by FBI-seq :**

##  Step00: Hypothesizing that you have get a duplication-removed bam file named by sample1_q30.sort.RGadd.rmdu.bam.
##  Step01: to extract the alignment results of Read1 from bam file.
```
samtools view -f 64 -F 128 -h sample1_q30.sort.RGadd.rmdu.bam > sample1_q30.sort.RGadd.rmdu.bam.R1.sam
```
##  Step02: to split resulting sam file to two files.
```
perl ./sam_filter_split.pl -i sample1_q30.sort.RGadd.rmdu.bam.R1.sam -m sample1_q30.sort.RGadd.rmdu.bam.R1.minusStrand.sam -p sample1_q30.sort.RGadd.rmdu.bam.R1.plusStrand.sam
```
##  Step03: to calculate the base depth in one sam file.
```
samtools view -bS sample1_q30.sort.RGadd.rmdu.bam.R1.minusStrand.sam > sample1_q30.sort.RGadd.rmdu.bam.R1.minusStrand.bam
samtools index -c sample1_q30.sort.RGadd.rmdu.bam.R1.minusStrand.bam
samtools depth  sample1_q30.sort.RGadd.rmdu.bam.R1.minusStrand.bam > sample1_q30.sort.RGadd.rmdu.bam.R1.minusStrand.bam.depth
```
##  Step04: to calculate the base depth in another sam file.
```
samtools view -bS sample1_q30.sort.RGadd.rmdu.bam.R1.plusStrand.sam > sample1_q30.sort.RGadd.rmdu.bam.R1.plusStrand.bam
samtools index -c sample1_q30.sort.RGadd.rmdu.bam.R1.plusStrand.bam
samtools depth  sample1_q30.sort.RGadd.rmdu.bam.R1.plusStrand.bam > sample1_q30.sort.RGadd.rmdu.bam.R1.plusStrand.bam.depth
```
##  Step05: to detect PTMA tags in minus and plus strands of reference genome.
```
perl ./find_tags_R1_plusStrand.pl -i sample1_q30.sort.RGadd.rmdu.bam.R1.plusStrand.bam.depth -c 1.35  -d 3 -o sample1_q30.sort.RGadd.rmdu.bam.R1.plusStrand.bam.depth.tags
perl ./find_tags_R1_minusStrand.pl -i sample1_q30.sort.RGadd.rmdu.bam.R1.minusStrand.bam.depth -c 1.35  -d 3  -o sample1_q30.sort.RGadd.rmdu.bam.R1.minusStrand.bam.depth.tags
```
##  Step06: to merge PTMA tags detected in minus and plus strands of reference genome to one file.
```
perl ./merge_plus-minus-Strand-tags-sort.pl  sample1_q30.sort.RGadd.rmdu.bam.R1.plusStrand.bam.depth.tags  sample1_q30.sort.RGadd.rmdu.bam.R1.minusStrand.bam.depth.tags  sample1_q30_PlusMinusStrands-merged-sort.bam.depth.tags
```
##  Step07: to get all the tag regions on genome where FBI-seq primer binding to.
```
perl ./extr_RefSeqPrimerBindingRegion.pl -t sample1_q30_PlusMinusStrands-merged-sort.bam.depth.tags -s sample1_q30.sort.RGadd.rmdu.bam.R1.sam -l 24  -o  sample1_q30_PlusMinusStrands-merged-sort.bam.depth.tags.region
```
***Tips***: 
 In the output file sample1_q30_PlusMinusStrands-merged-sort.bam.depth.tags.region, (1) some spurious tags caused by indel may be included, so you can fiter out these bad tags marked with charecters "noCIGAR" in the column of "all_CIGAR_values"; (2) the last two columns showed 0-based genomic coordinates, which will help to extract corresponding genomic sequences by command of "bedtools getfasta" if necessary.
 
 The detailed explanation of paramerers of custom perl scripts in aboving steps, could be obtained by looking into corresponding scripts contents.
