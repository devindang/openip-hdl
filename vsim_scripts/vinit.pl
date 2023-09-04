#!/usr/bin/perl
use warnings;
use File::Copy qw(copy);
use File::HomeDir qw(home);

print "## ----------- Modelsim Init v1.0 -----------\n";
if( $#ARGV == -1 ){
    print "ERROR: [10] The argument must be assgined.\n";
	die;
} elsif( $#ARGV == 0 ){

} else {
    print "ERROR: [11] Too many arguments, ". ($#ARGV+1) ." arguments passed.\n";
	die;
}
my $path = $ARGV[0];

# create workspace
mkdir $path."/bench" unless(-e $path."/bench");
mkdir $path."/rtl" unless(-e $path."/rlt");
mkdir $path."/vsim" unless(-e $path."/vsim");
copy home().'/tb.v',$path.'/bench/tb.v' unless(-e $path.'/bench/tb.v');
copy home().'/.v',$path.'/rtl/top.v' unless(-e $path.'/rtl/top.v');
copy home().'/makefile',$path.'/vsim/' unless(-e $path.'/vsim/makefile');

print "## Initilization Success!\n";

