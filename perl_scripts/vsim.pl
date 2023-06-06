#!usr/bin/perl
use warnings;

$fin = '../src/we.txt';
$fout = '../src/out.txt';
$n_signal = 0;
$trig_sel = 0;
$signal_name;
@signal_list;
$line_num = 0;
$start = 0;
$end = 10;

open(FH,'<',$fin) or die $!;
open(OUT_FH,'>',$fout) or die $!;

while (my $line = <FH>) {
	if($line =~ /\/(?<name>\w+)\s+/) {
		$signal_name = $+{name};
		$n_signal = $n_signal + 1;
		push(@signal_list,$signal_name);
	} elsif ($line =~ /^\s*\d/) {
		last;
	}
}

print "Set trigger style: [0] for trigger all, [p] to get selected parts, or select [d] as your valid signal.\n";
print "\[0\]. Trigger all. (Default)\n";
print "\[p\]. Selected parts.\n";
foreach my $i (0 .. $#signal_list) {
	print "\[" . ($i+1) . "\]. " . $signal_list[$i] . "\n";
}

$trig_sel = <STDIN>;
chomp($trig_sel) if defined $trig_sel;
if($trig_sel eq "p") {
	print "Input the start and end. example 100,300 \n";
	my $start_end = <STDIN>;
	$start_end =~ /(\d+),(\d+)/;
	$start = $1;
	$end = $2;
} elsif($trig_sel > ($#signal_list+1)) {
	print "Invalid number!\n";
	exit;
} elsif($trig_sel eq 0) {
	$index = '';
} else {
	$index = $trig_sel;
}

while (my $line = <FH>) {
    if ($line =~ /^\s*\d/) {
        $line_num = $line_num+1;
        $line =~ /\s+\d+0\s+/;
        $line1 = $';
        $line1 =~ s/\d+\'h//g;
        my @list = split(/\s/,$line1);
        if($trig_sel eq "p") {
			if ($line_num>=$start && $line_num<=$end) {
				print OUT_FH $line1;
			}
        } elsif($trig_sel eq 0) {
			print OUT_FH $line1;
		} else {
			if($list[($index-1)] eq 1) {
				print OUT_FH $line1;
			}
		}
    }
}

