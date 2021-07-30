#!/usr/bin/perl -w
#purpose: to merge plus and minus strand tags into one file and then sort to output file.
#usage: perl $0  sample1_q30.sort.RGadd.rmdu.bam.R1.plusStrand.bam.depth.tags  sample1_q30.sort.RGadd.rmdu.bam.R1.minusStrand.bam.depth.tags  sample1_q30_PlusMinusStrands-merged-sort.bam.depth.tags


my(@line,$num,%hash1,%hash2,$chr,$pos);
open IN0,"$ARGV[0]";
while(<IN0>){chomp;
	next if /^#/;
	@line=split /\s+/,$_,3;
	$num=$1 if ($line[0]=~/chr(.*)/i);
	$hash1{$line[0]}=$num;
	$hash2{$line[0]}{$line[1]}=$line[2];
}
close IN0;
open IN1,"$ARGV[1]";
while(<IN1>){chomp;
	next if /^#/;
	@line=split /\s+/,$_,3;
	$num=$1 if ($line[0]=~/chr(.*)/i);
	$hash1{$line[0]}=$num;
	$hash2{$line[0]}{$line[1]}=$line[2];
}
close IN1;
open OUT,">./$ARGV[2]";
print OUT "#Chr\tPos(1-based)\tdepth(x)\tR1_match_to_+/-_Strand\n";
for $chr (sort {$hash1{$a}<=>$hash1{$b}} keys %hash1){
	for $pos (sort {$a<=>$b} keys %{$hash2{$chr}}){
		print OUT "$chr\t$pos\t$hash2{$chr}{$pos}\n" if ($pos >= 30); ##染色体前30bp不考虑！
	}
}
close OUT;
