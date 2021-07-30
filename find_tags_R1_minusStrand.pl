#!/usr/bin/perl -w
#purpose: to detect tags and its coordinates on minusStrand.
#usage: perl $0 -i sample1_q30.sort.RGadd.rmdu.bam.R1.minusStrand.bam.depth -c 1.35  -d 3  -o sample1_q30.sort.RGadd.rmdu.bam.R1.minusStrand.bam.depth.tags
#-i: input file
#-c : the coverage depth of whole raw sequencing data.
#-d: the depth of tags site should bigger than this value.
#-o: output file

my(@list,%hash1,%hash2,@row,%hash3,$name,$qian1,$max);
use Getopt::Std;
use vars qw($opt_i $opt_c  $opt_d $opt_o);
getopts ('i:c:d:o:');
open IN,$opt_i;
while(<IN>){chomp;
	@list=split;
	$pos=$list[0]."-".$list[1];
	$hash1{$.}=$list[2];
	$hash2{$.}=$_;
	$hash3{$pos}=$_;
}
my $line=keys %hash2;
my $a=10*$opt_c;
if($a<5){
	$max=5;
}else{
	$max=10*$opt_c;
}
close IN;
open OUT,">./$opt_o";
print OUT "#Chr\tPos(1-based)\tdepth(x)\tR1_match_to_+/-_Strand\n";
while($line>0){ 
	if( $hash1{$line}>=$opt_d ){ #
		@list=split /\s+/,$hash2{$line};
		$qian1=$list[1]+1;
		$name=$list[0]."-".$qian1;
		if(defined $hash3{$name}){
			@row=split /\s+/,$hash3{$name}; # !!!!!!
		}else{
			$row[2]=0;
			$row[0]=$list[0];
		}
		if(($row[2]<=$max) and ($list[0] eq $row[0]) and ($list[2]>=$row[2]+$opt_d)){
			print OUT "$hash2{$line}\t-\n"; #R1(含特异扩增引物序列)匹配负负负链   ## !!!!!!!
			$line=$line-1;
		}else{
			$line=$line-1;
		}
	}else{
		$line=$line-1;
	}
}
close OUT;
