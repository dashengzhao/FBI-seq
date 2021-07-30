#!/usr/bin/perl -w
#purpose: to get all the tag regions on genome where FBI-seq primer binding to.
#usage: perl $0 -t sample1_q30_PlusMinusStrands-merged-sort.bam.depth.tags -s sample1_q30.sort.RGadd.rmdu.bam.R1.sam -l 24  -o  sample1_q30_PlusMinusStrands-merged-sort.bam.depth.tags.region
#-t: input of tags file
#-l: the effective length of FBI-seq primer (exluding the 5'-end adapter sequences, only 3'-end sequences binding to genome template were considered)
#-s: a sam file including the extracted the alignment results of Read1 from initial bam file
#-o: output file 

my($s,$primer_len,%hash3,$nkey,$tem_pos,@num,$max,@line,$key,$all,$bedstart,$bedend,%hash,%exist);
use List::Util qw /max/;
use Getopt::Std;
use vars qw($opt_t $opt_s $opt_o $opt_l);
getopts ('t:s:o:l:');
open IN0,"$opt_t";
$primer_len=$opt_l; 
my $sum=0;
while(<IN0>){chomp;
	next if /^#/;
	@line=split;
	$hash{$.-1}=$_;
	$key=$line[0].$line[1];
	$exist{$key}=0;
	$sum++;
}
close IN0;
open IN1,"$opt_s";
while(<IN1>){chomp;
	next if /^#/;
	next if /^\@/;
	@line=split /\s+/,$_,10;
	if($line[8]>0){
		$key=$line[2].$line[3];
	}else{
		$tem_pos=$line[7]-$line[8]-1;
		$key=$line[2].$tem_pos;
	}
	if(($exist{$key} ==0) and (abs($line[8])<1000) ){   ## span length less than 1000bp.
		push(@{$key},$line[5]);
		if($line[8]>0 and $line[5]=~/^(\d+)S/){
				push(@{"n".$key},$1);
		}elsif($line[8]<0 and $line[5]=~/(\d+)S$/){
				push(@{"n".$key},$1);
		}else{
		}
	}else{
		next;
	}
}
close IN1;
open OUT,">./$opt_o";
print OUT "#Chr\tPos(1-based)\tdepth(x)\tR1_match_to_+/-_Strand\tall_CIGAR_values\tnSoft_clipped\tbedStart(0based)\tbedEnd\n";
for(1..$sum){
	@line=split /\s+/,$hash{$_};	
	$key=$line[0].$line[1];
	$nkey="n".$key;
	@num=@{$nkey};
	for(0..$#num){
		$hash3{$num[$_]}++;
	}
	$max=max (values %hash3);
	DO: for $s (keys %hash3){
		if($hash3{$s}==$max){
			$soft_v=$s;
			last DO;
		}else{
			next;
		}
	}
	%hash3=();
	$all=join(",",@{$key});
	$bedstart1=$line[1]-$soft_v-1;
	$bedend1=$line[1]+$primer_len-$soft_v-1;
	$bedstart2=$line[1]-($primer_len-$soft_v);
	$bedend2=$line[1]+$soft_v;
	if($line[3] eq '+'){    # R1 match to + strand
		if($all ne "" and $soft_v ne ""){
			print OUT "$hash{$_}\t$all\t$soft_v\t$bedstart1\t$bedend1\n";
			$soft_v="";
			next;
		}elsif($all ne "" and $soft_v eq ""){
			print OUT "$hash{$_}\t$all\tperfectMatch\t$bedstart1\t$bedend1\n";  ## perfect match!
		}elsif($all eq ""){
			print OUT "$hash{$_}\tnoCIGAR\tfalsePositive\t$bedstart1\t$bedend1\n"; ## deletion in the middle of read1 when bwa to ref.
		}else{
			
		}
	}else{    # R1 match to - strand
		if($all ne "" and $soft_v ne ""){
			print OUT "$hash{$_}\t$all\t$soft_v\t$bedstart2\t$bedend2\n";
			$soft_v="";
			next;
		}elsif($all ne "" and $soft_v eq ""){
			print OUT "$hash{$_}\t$all\tperfectMatch\t$bedstart2\t$bedend2\n";
		}elsif($all eq ""){
			print OUT "$hash{$_}\tnoCIGAR\tfalsePositive\t$bedstart2\t$bedend2\n";
		}else{
			next;
		}
	}
}
close OUT;
