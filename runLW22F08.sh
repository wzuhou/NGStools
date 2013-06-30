#!/bin/bash
#$ -cwd
#$ -S /bin/sh
#$ -l h_vmem=10G
mkdir tmpLW22F08
DATE=`date`; echo "++++++++++++++++++++++++++++" >tmpLW22F08/LW22F08.log; echo 'starting time: '$DATE  >tmpLW22F08/LW22F08.log
# archive number 1: ABGSA0189
python fix_fq_names.py /media/InternBkp1/repos/ABGSA/ABGSA0189/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_1.fq.gz.clean.dup.clean.gz | pigz >tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_1.fq.gz.clean.dup.clean.gz
python fix_fq_names.py /media/InternBkp1/repos/ABGSA/ABGSA0189/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_2.fq.gz.clean.dup.clean.gz | pigz >tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_2.fq.gz.clean.dup.clean.gz
# quality trimming of reads by sickle
sickle pe -f tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_1.fq.gz.clean.dup.clean.gz -r tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_2.fq.gz.clean.dup.clean.gz -o tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_1.fq.clean.dup.clean.tr -p tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_2.fq.clean.dup.clean.tr -s tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_1.fq.clean.dup.clean.singles.tr -l 45 -t illumina
pigz tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_1.fq.clean.dup.clean.tr
pigz tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_2.fq.clean.dup.clean.tr
# since sequences have offset +64 we need to convert to sanger (offset +33)
python convert_ill_to_sang.py tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_1.fq.clean.dup.clean.tr.gz | gzip -c >tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_1.fq.clean.dup.clean.tr.sa.gz
python convert_ill_to_sang.py tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_2.fq.clean.dup.clean.tr.gz | gzip -c >tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_2.fq.clean.dup.clean.tr.sa.gz
rm tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_1.fq.clean.dup.clean.tr.gz
rm tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_2.fq.clean.dup.clean.tr.gz
mv tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_1.fq.clean.dup.clean.tr.sa.gz tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_1.fq.clean.dup.clean.tr.gz
mv tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_2.fq.clean.dup.clean.tr.sa.gz tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_2.fq.clean.dup.clean.tr.gz
DATE=`date`; echo "++++++++++++++++++++++++++++" >tmpLW22F08/LW22F08.log; echo 'starting bwa-mem mapping of LW22F08 archive 1: '$DATE  >>tmpLW22F08/LW22F08.log
# maping using the bwa-mem algorithm, including sorting of bam
echo 'start mapping using BWA-mem algorithm'
/opt/bwa/bwa-0.7.5a/bwa mem -t 4 -R '@RG\tID:ABGSA0189_1\tSM:LW22F08\tPL:ILLUMINA' /media/InternBkp1/repos/refs/Sus_scrofa.Sscrofa10.2.72.dna.toplevel.fa tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_1.fq.clean.dup.clean.tr.gz tmpLW22F08/120423_I652_FCC0E33ACXX_L3_SZAIPI008160-111_2.fq.clean.dup.clean.tr.gz >tmpLW22F08/aln-ABGSA0189-LW22F08-1-pe.sam
/opt/samtools/samtools-0.1.19/samtools view -Shb -q 10 tmpLW22F08/aln-ABGSA0189-LW22F08-1-pe.sam > tmpLW22F08/aln-ABGSA0189-LW22F08-1-pe.bam
rm tmpLW22F08/aln-ABGSA0189-LW22F08-1-pe.sam
echo 'start sorting'
/opt/samtools/samtools-0.1.19/samtools sort tmpLW22F08/aln-ABGSA0189-LW22F08-1-pe.bam tmpLW22F08/aln-ABGSA0189-LW22F08-1-pe.sorted
rm tmpLW22F08/aln-ABGSA0189-LW22F08-1-pe.bam
DATE=`date`; echo "++++++++++++++++++++++++++++" >tmpLW22F08/LW22F08.log; echo 'finished, produced BAM file tmpLW22F08/aln-ABGSA0189-LW22F08-1-pe.sorted.bam archive 1: '$DATE  >>tmpLW22F08/LW22F08.log
FSIZE=`stat --printf="%s" tmpLW22F08/aln-ABGSA0189-LW22F08-1-pe.sorted.bam`; echo "size of file tmpLW22F08/aln-ABGSA0189-LW22F08-1-pe.sorted.bam is "$FSIZE  >>tmpLW22F08/LW22F08.log
# archive number 2: ABGSA0189
python fix_fq_names.py /media/InternBkp1/repos/ABGSA/ABGSA0189/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_1.fq.gz.clean.dup.clean.gz | pigz >tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_1.fq.gz.clean.dup.clean.gz
python fix_fq_names.py /media/InternBkp1/repos/ABGSA/ABGSA0189/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_2.fq.gz.clean.dup.clean.gz | pigz >tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_2.fq.gz.clean.dup.clean.gz
# quality trimming of reads by sickle
sickle pe -f tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_1.fq.gz.clean.dup.clean.gz -r tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_2.fq.gz.clean.dup.clean.gz -o tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_1.fq.clean.dup.clean.tr -p tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_2.fq.clean.dup.clean.tr -s tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_1.fq.clean.dup.clean.singles.tr -l 45 -t illumina
pigz tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_1.fq.clean.dup.clean.tr
pigz tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_2.fq.clean.dup.clean.tr
# since sequences have offset +64 we need to convert to sanger (offset +33)
python convert_ill_to_sang.py tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_1.fq.clean.dup.clean.tr.gz | gzip -c >tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_1.fq.clean.dup.clean.tr.sa.gz
python convert_ill_to_sang.py tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_2.fq.clean.dup.clean.tr.gz | gzip -c >tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_2.fq.clean.dup.clean.tr.sa.gz
rm tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_1.fq.clean.dup.clean.tr.gz
rm tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_2.fq.clean.dup.clean.tr.gz
mv tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_1.fq.clean.dup.clean.tr.sa.gz tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_1.fq.clean.dup.clean.tr.gz
mv tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_2.fq.clean.dup.clean.tr.sa.gz tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_2.fq.clean.dup.clean.tr.gz
DATE=`date`; echo "++++++++++++++++++++++++++++" >tmpLW22F08/LW22F08.log; echo 'starting bwa-mem mapping of LW22F08 archive 2: '$DATE  >>tmpLW22F08/LW22F08.log
# maping using the bwa-mem algorithm, including sorting of bam
echo 'start mapping using BWA-mem algorithm'
/opt/bwa/bwa-0.7.5a/bwa mem -t 4 -R '@RG\tID:ABGSA0189_2\tSM:LW22F08\tPL:ILLUMINA' /media/InternBkp1/repos/refs/Sus_scrofa.Sscrofa10.2.72.dna.toplevel.fa tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_1.fq.clean.dup.clean.tr.gz tmpLW22F08/120506_I224_FCC0RYYACXX_L4_SZAIPI008160-111_2.fq.clean.dup.clean.tr.gz >tmpLW22F08/aln-ABGSA0189-LW22F08-2-pe.sam
/opt/samtools/samtools-0.1.19/samtools view -Shb -q 10 tmpLW22F08/aln-ABGSA0189-LW22F08-2-pe.sam > tmpLW22F08/aln-ABGSA0189-LW22F08-2-pe.bam
rm tmpLW22F08/aln-ABGSA0189-LW22F08-2-pe.sam
echo 'start sorting'
/opt/samtools/samtools-0.1.19/samtools sort tmpLW22F08/aln-ABGSA0189-LW22F08-2-pe.bam tmpLW22F08/aln-ABGSA0189-LW22F08-2-pe.sorted
rm tmpLW22F08/aln-ABGSA0189-LW22F08-2-pe.bam
DATE=`date`; echo "++++++++++++++++++++++++++++" >tmpLW22F08/LW22F08.log; echo 'finished, produced BAM file tmpLW22F08/aln-ABGSA0189-LW22F08-2-pe.sorted.bam archive 2: '$DATE  >>tmpLW22F08/LW22F08.log
FSIZE=`stat --printf="%s" tmpLW22F08/aln-ABGSA0189-LW22F08-2-pe.sorted.bam`; echo "size of file tmpLW22F08/aln-ABGSA0189-LW22F08-2-pe.sorted.bam is "$FSIZE  >>tmpLW22F08/LW22F08.log
#number of bams: 2
#multiple bam files --> do merge
/opt/samtools/samtools-0.1.19/samtools view -H tmpLW22F08/aln-ABGSA0189-LW22F08-1-pe.sorted.bam | sed 's/SM:unknown/SM:LW22F08/'  | sed 's/PL:sanger/PL:ILLUMINA/' >tmpLW22F08/newheader.txt
/opt/samtools/samtools-0.1.19/samtools view -H tmpLW22F08/aln-ABGSA0189-LW22F08-2-pe.sorted.bam | sed 's/SM:unknown/SM:LW22F08/'  | sed 's/PL:sanger/PL:ILLUMINA/' | grep @RG >>tmpLW22F08/newheader.txt
/opt/samtools/samtools-0.1.19/samtools merge tmpLW22F08/tmpmergedLW22F08.bam tmpLW22F08/aln-ABGSA0189-LW22F08-1-pe.sorted.bam tmpLW22F08/aln-ABGSA0189-LW22F08-2-pe.sorted.bam 
/opt/samtools/samtools-0.1.19/samtools reheader tmpLW22F08/newheader.txt tmpLW22F08/tmpmergedLW22F08.bam >tmpLW22F08/LW22F08_rh.bam
rm tmpLW22F08/tmpmergedLW22F08.bam
/opt/samtools/samtools-0.1.19/samtools index tmpLW22F08/LW22F08_rh.bam
DATE=`date`; echo "++++++++++++++++++++++++++++" >tmpLW22F08/LW22F08.log; echo 'finished merging, produced BAM file tmpLW22F08/LW22F08_rh.bam: '$DATE  >>tmpLW22F08/LW22F08.log
FSIZE=`stat --printf="%s" tmpLW22F08/LW22F08_rh.bam`; echo "size of file tmpLW22F08/LW22F08_rh.bam is "$FSIZE  >>tmpLW22F08/LW22F08.log
# dedup using samtools
echo 'dedupping using samtools'
/opt/samtools/samtools-0.1.19/samtools rmdup tmpLW22F08/LW22F08_rh.bam tmpLW22F08/LW22F08_rh.dedup_st.bam
/opt/samtools/samtools-0.1.19/samtools index tmpLW22F08/LW22F08_rh.dedup_st.bam
DATE=`date`; echo "++++++++++++++++++++++++++++" >tmpLW22F08/LW22F08.log; echo 'finished dedupping using samtools, produced BAM file tmpLW22F08/LW22F08_rh.dedup_st.bam: '$DATE  >>tmpLW22F08/LW22F08.log
FSIZE=`stat --printf="%s" tmpLW22F08/LW22F08_rh.dedup_st.bam`; echo "size of file tmpLW22F08/LW22F08_rh.dedup_st.bam is "$FSIZE  >>tmpLW22F08/LW22F08.log
# re-alignment using GATK-RealignmentTargetCreator+IndelRealigner
java7 -jar /opt/GATK/GATK2.6/GenomeAnalysisTK.jar -T RealignerTargetCreator -R /media/InternBkp1/repos/refs/Sus_scrofa.Sscrofa10.2.72.dna.toplevel.fa -I tmpLW22F08/LW22F08_rh.dedup_st.bam -o tmpLW22F08/LW22F08_rh.dedup_st.reA.intervals
java7 -jar /opt/GATK/GATK2.6/GenomeAnalysisTK.jar -T IndelRealigner -R /media/InternBkp1/repos/refs/Sus_scrofa.Sscrofa10.2.72.dna.toplevel.fa -I tmpLW22F08/LW22F08_rh.dedup_st.bam -targetIntervals tmpLW22F08/LW22F08_rh.dedup_st.reA.intervals -o tmpLW22F08/LW22F08_rh.dedup_st.reA.bam
DATE=`date`; echo "++++++++++++++++++++++++++++" >tmpLW22F08/LW22F08.log; echo 'finished re-aligning, produced BAM file tmpLW22F08/LW22F08_rh.dedup_st.reA.bam: '$DATE  >>tmpLW22F08/LW22F08.log
FSIZE=`stat --printf="%s" tmpLW22F08/LW22F08_rh.dedup_st.reA.bam`; echo "size of file tmpLW22F08/LW22F08_rh.dedup_st.reA.bam is "$FSIZE  >>tmpLW22F08/LW22F08.log
# Recalibration of BAM using GATK-BaseRecalibrator+PrintReads
java7 -jar /opt/GATK/GATK2.6/GenomeAnalysisTK.jar -T BaseRecalibrator -R /media/InternBkp1/repos/refs/Sus_scrofa.Sscrofa10.2.72.dna.toplevel.fa -I tmpLW22F08/LW22F08_rh.dedup_st.reA.bam -knownSites /media/InternBkp1/repos/dbSNP/Ssc_dbSNP138.vcf -o tmpLW22F08/LW22F08_rh.dedup_st.reA.recal.grp
java7 -jar /opt/GATK/GATK2.6/GenomeAnalysisTK.jar -T PrintReads -R /media/InternBkp1/repos/refs/Sus_scrofa.Sscrofa10.2.72.dna.toplevel.fa -I tmpLW22F08/LW22F08_rh.dedup_st.reA.bam -BQSR tmpLW22F08/LW22F08_rh.dedup_st.reA.recal.grp -o tmpLW22F08/LW22F08_rh.dedup_st.reA.recal.bam
DATE=`date`; echo "++++++++++++++++++++++++++++" >tmpLW22F08/LW22F08.log; echo 'finished re-aligning, produced BAM file tmpLW22F08/LW22F08_rh.dedup_st.reA.recal.bam: '$DATE  >>tmpLW22F08/LW22F08.log
FSIZE=`stat --printf="%s" tmpLW22F08/LW22F08_rh.dedup_st.reA.recal.bam`; echo "size of file tmpLW22F08/LW22F08_rh.dedup_st.reA.recal.bam is "$FSIZE  >>tmpLW22F08/LW22F08.log
# old-school variant calling using the pileup algorithm
echo 'old-school variant calling using the pileup algorithm'
/opt/samtools/samtools-0.1.12a/samtools view -u tmpLW22F08/LW22F08_rh.dedup_st.reA.recal.bam | /opt/samtools/samtools-0.1.12a/samtools pileup -vcf /media/InternBkp1/repos/refs/Sus_scrofa.Sscrofa10.2.72.dna.toplevel.fa - >tmpLW22F08/LW22F08_rh.dedup_st.reA.recal_vars-raw.txt
VAR=`cat tmpLW22F08/LW22F08_rh.dedup_st.reA.recal_vars-raw.txt | cut -f8 | head -100000 | sort | uniq -c | sed 's/^ \+//' | sed 's/ \+/\t/' | sort -k1 -nr | head -1 | cut -f2`
let VAR=2*VAR
echo "max depth is $VAR"
/opt/samtools/samtools-0.1.12a/misc/samtools.pl varFilter -D$VAR tmpLW22F08/LW22F08_rh.dedup_st.reA.recal_vars-raw.txt | awk '($3=="*"&&$6>=50)||($3!="*"&&$6>=20)' >tmpLW22F08/LW22F08_rh.dedup_st.reA.recal.vars-flt_final.txt
# variant calling using the mpileup function of samtools
/opt/samtools/samtools-0.1.19/samtools mpileup -C50 -ugf /media/InternBkp1/repos/refs/Sus_scrofa.Sscrofa10.2.72.dna.toplevel.fa tmpLW22F08/LW22F08_rh.dedup_st.reA.recal.bam | /opt/samtools/samtools-0.1.19/bcftools/bcftools view -bvcg -| /opt/samtools/samtools-0.1.19/bcftools/bcftools view - | perl /opt/samtools/samtools-0.1.19/bcftools/bcftools/vcfutils.pl varFilter -D 20 -d 4 >tmpLW22F08/LW22F08_rh.dedup_st.reA.recal.var.mpileup.flt.vcf
# Variant calling using GATK UnifiedGenotyper - parameters need tweaking
java7 -jar /opt/GATK/GATK2.6/GenomeAnalysisTK.jar -R /media/InternBkp1/repos/refs/Sus_scrofa.Sscrofa10.2.72.dna.toplevel.fa -T UnifiedGenotyper -I tmpLW22F08/LW22F08_rh.dedup_st.reA.recal.bam --dbsnp /media/InternBkp1/repos/dbSNP/Ssc_dbSNP138.vcf --genotype_likelihoods_model BOTH -o tmpLW22F08/LW22F08_rh.dedup_st.reA.recal.UG.raw.vcf  -stand_call_conf 50.0 -stand_emit_conf 10.0  -dcov 50
DATE=`date`; echo "++++++++++++++++++++++++++++" >tmpLW22F08/LW22F08.log; echo 'finished variant calling: '$DATE  >>tmpLW22F08/LW22F08.log
