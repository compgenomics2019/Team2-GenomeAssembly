#!/bin/bash


# ==============================Check Input Directory===========================================
t=0
q=0
g=0
while getopts "i:tqgh" opt; do
	case "$opt" in
		i)
			dir=$OPTARG;;
		t)
			$t=1;;
		q)
			$q=1;;
		g)
			$g=1;;
		h)
			echo "cmd: ./assmebly.sh -i input_dir "
			exit 0
	esac
done

if [ ! -z "$i"  ];then
	echo "Missing input directory"
	exit 1
fi

if [ ! -d "$dir" ]; then
	echo "No such input directory"
	exit 1
fi

echo "Input directory: $dir"

datapath=${PWD}/$dir

# ==============================Trimming using FaQCs===========================================
# creates 2 new dir's per paired reads: *_qc and *_trimmed; removes *_qc upon completion.

mkdir $datapath/trimmed


# list_reads is a list of all of the reads
list_reads="$(ls $datapath/*.fq*)"
count_reads="$(ls $datapath/*.fq* | wc -l)"
echo Total file: "$count_reads"


i=1
j=2

# Loop thorugh each pair
while [ $i -le $count_reads ]
do 
	new_read1=$(echo $list_reads | awk '{print $'$i'}')
	new_read2=$(echo $list_reads | awk '{print $'$j'}')

	# Prefix is read name eg. CGT2006
	prefix=${new_read1%_*}
	prefix=${prefix##*/}

	echo Preparing $prefix

	# This only evaluates the QC for the raw input reads via the "--qc_only" option; creates *_qc dir's
	FaQCs  -1 $new_read1 -2 $new_read2 --qc_only --adapter -d $datapath/trimmed/"$prefix"_qc

	# Convert last page of quality report to .txt to get the average read quality
	pdftotext -f 8 -l 8 $datapath/trimmed/"$prefix"_qc/QC_qc_report.pdf $datapath/trimmed/"$prefix"_qc/"$prefix"_qc.txt
	
	# Obtain Average Quality of each read
	avg_q="$(awk -F: '$1=="Average"{print $2;exit}' $datapath/trimmed/"$prefix"_qc/"$prefix"_qc.txt)"
	avg_q="$(printf '%.*f\n' 0 "$avg_q")" # round

	# Subtract Average Quality score of each read by 5 is the best cutoff parameter we tried
	qc_cutoff=$[$avg_q-5]

	echo avg_q $avg_q qc_cutoff $qc_cutoff

	echo Trimming...
#	# Trim each set of reads based on the qc_cutoff
	FaQCs  -1 $new_read1 -2 $new_read2 --avg_q $qc_cutoff --min_L 100 --adapter -d $datapath/trimmed/"$prefix"_trimmed

	echo Finshed $prefix
	
	i=$[i+2]
	j=$[j+2]
 done

# Remove initial *_qc dir's; redundant information since the input QC is reported in the report after trimming too
rm -r $datapath/trimmed/*_qc


# ======================Assemble with SPAdes and post-QC with QUAST==============================

list_trimmedDirs="$(ls -d $datapath/trimmed/*trimmed/)"
numOfTrimmedDirs="$(ls -d $datapath/trimmed/*trimmed/ | wc -l)"

mkdir $datapath/quast
i=1
while [ $i -le $numOfTrimmedDirs ]
do 
	path2files=$(echo $list_trimmedDirs | awk '{print $'$i'}')
	prefix=${path2files%_trimmed/}
	prefix=${prefix##*/}
	
	# Run SPAdes
	spades.py --sc --careful -1 "$path2files"QC.1.trimmed.fastq -2 "$path2files"QC.2.trimmed.fastq -s "$path2files"QC.unpaired.trimmed.fastq -o $datapath/assembled/"$prefix"_assemb
	
	# checking with Quast
	quast.py $datapath/assembled/"$prefix"_assemb/contigs.fasta -o $datapath/quast/"$prefix"
	
	# Write assembly to ./dataset/Assembled_Contigs
	mkdir $datapath/Assembled_Contigs
	
	cat $datapath/assembled/"$prefix"_assemb/contigs.fasta > $datapath/Assembled_Contigs/"$prefix"_contigs.fasta
	
	i=$[i+1]
done
	rm -r $datapath/assembled/*_assemb

if [ "$t" -eq "0" ]; then
	rm -r $datapath/trimmed
fi

if [ "$q" -eq "0" ]; then
	rm -r $datapath/quast

fi

exit 0

