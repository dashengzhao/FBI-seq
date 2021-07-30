#!/usr/bin/perl -w
#purpose: to detect tags and its coordinates on plusStrand.
#usage: perl $0 -i sample1_q30.sort.RGadd.rmdu.bam.R1.plusStrand.bam.depth -c 1.35  -d 3 -o sample1_q30.sort.RGadd.rmdu.bam.R1.plusStrand.bam.depth.tags
#-i: input file
#-c : the coverage depth of whole raw sequencing data.
#-d: the depth of tags site should bigger than this value.
#-o: output file

my(@list,%hash1,%hash2,%hash3,@row,$name,$hou1,$all_line,$max);
use Getopt::Std;
use vars qw($opt_i $opt_c $opt_d $opt_o);
getopts ('i:c:d:o:');
open IN,$opt_i;
while(<IN>){chomp;
	@list=split;
	$pos=$list[0]."-".$list[1];
	$hash1{$.}=$list[2];
	$hash2{$.}=$_;
	$hash3{$pos}=$_;
}
close IN;
open OUT,">./$opt_o";
print OUT "#Chr\tPos(1-based)\tdepth(x)\tR1_match_to_+/-_Strand\n";
my $line=1;
$all_line=keys %hash2;
my $a=10*$opt_c;
if($a<5){
	$max=5;
}else{
	$max=10*$opt_c;
}
while($line<$all_line){ 
	if($hash1{$line}>=$opt_d){ #depth >= $opt_d
		@list=split /\s+/,$hash2{$line};
		$hou1=$list[1]-1;
		$name=$list[0]."-".$hou1;
		if(defined $hash3{$name}){
			@row=split /\s+/,$hash3{$name};
		}else{
			$row[2]=0;
			$row[0]=$list[0];
		}
		if(($row[2]<=$max) and ($list[0] eq $row[0]) and ($list[2]>=$row[2]+$opt_d)){
			print OUT "$hash2{$line}\t+\n"; #R1(含特异扩增引物序列)匹配正链
			$line++;
		}else{
			$line++;
		}
	}else{
		$line++;
	}
}
close OUT;
