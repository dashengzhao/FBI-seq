#!/usr/bin/perl -w
#purpose: split sam File to 2 category according to the values of 9th column's +/-.
#usage: perl $0 -i sample1_q30.sort.RGadd.rmdu.bam.R1.sam -m sample1_q30.sort.RGadd.rmdu.bam.R1.minusStrand.sam -p sample1_q30.sort.RGadd.rmdu.bam.R1.plusStrand.sam
#-i: input file
#-p: output file for plus strand
#-m: output file for minus strand

my(@line);
use Getopt::Std;
use vars qw($opt_i $opt_p $opt_m);
getopts ('i:p:m:');

open IN,"$opt_i";
open OUT1,">./$opt_p";
open OUT2,">./$opt_m";
while(<IN>){chomp;
	@line=split;
	if(/^\@/){
		print OUT1 "$_\n";
		print OUT2 "$_\n";
	}else{
		if($line[8]>0 and $line[8]<1000){  # span length less than 1 kb.
			print OUT1 "$_\n";
		}elsif($line[8]<0 and (abs($line[8])<1000) ){  # span length less than 1 kb.
			print OUT2 "$_\n";
		}else{
			next;
		}
	}
}
close IN;
close OUT1;
close OUT2;
