# Computational Genomics Genome Assembly Pipeline

## SUMMARY

This pipeline is designed by Team 2, Group 1. The purpose is to assemble genomes from PE Illumina reads
in a manner that checks the quality of reads and executes the necessary quality controls for optimized assemblies. 

This pipeline features tools including FaQCs, SPAdes, and QUAST. These are responsible for trimming, assembly,
and post-assembly quality assessment respectively. Please consult the publicly available documentation for 
these tools for further help.

** Written by Dipro Chakraborty, Maggie Fisher, Nishant Gerald, Tzu-Chuan Huang ,Jihyun Park , Jiahan Zhan, Mingyue
Zhang ** 

## INSTALL


Below are directions for installing this pipeline; make sure [python3](https://www.python.org/download/releases/3.0/) is installed.

* [FaQCs](https://github.com/LANL-Bioinformatics/FaQCs): Quality Control and trimming
* [SPAdes](http://cab.spbu.ru/software/spades/): De Bruijn graph assembler
* [QUAST](http://quast.sourceforge.net/quast): Post-assmebly quality control

## GETTING STARTED
### Download script and data
```
git clone https://github.gatech.edu/compgenomics2019/Team2-GenomeAssembly
cd Team2-GenomeAssembly
# you are required to put all the raw input reads in one directory 
```

## Synopsis

**Input options**: One input directory must be specifed.

`-i` Raw data directory: specify the path of your input directory. You could have several files in the directory. The script will assemble all the raw data for you. The raw data must be **fastq** files.


**Other options**: 

`-t` Keep the trimming data for your reference; all of the trimming data will be in the **trim** directory under the Input directory.

`-q` Keep the Quast reports for your reference; all of the reports will be in the **quast** directory under the Input directory

## Short description
`./assembly.sh` will automatically evaluate the QC for the raw input reads  and carry out the proper trimming to perform the assembly outcome for you. 

**Paramaters**:
The pipeline will trim the raw reads at (average Q-score minus 5) for a gentle trimming cutoff.
During assembly, both paired and unpaired reads will be used by SPAdes. The --careful flag will be used to produce better results, minimizing mismatches and short indels.
Please refer to [FaQCs](https://github.com/LANL-Bioinformatics/FaQCs) and [SPAdes](http://cab.spbu.ru/software/spades/) for detailed discription.

* The script will generate a trimming directory for each pair in your input file directory and will be named  **trimmed** if `-t` is used.
* The script will generate a directory containing a quast report for each assembly in your input file directory and will be named  **quast** if `-q` is used.
* All of the assemblies will be in the Assembled\_Contigs directory under the Input directory and each name will be  **\<Paired file name\>\_contigs.fasta**.



## Usage example

```
Only specify the Input dataset directory 
./assembly.sh -i ./dataset 

Keep the trimming data and quast results
./assembly.sh -i ./dataset -q -t
```
