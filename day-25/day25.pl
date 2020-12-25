#!/usr/bin/perl

##
# Preamble.
#
use warnings;
use strict;
use constant P => 20201227;


sub say {
    print "@_\n";
}


##
# Intro.
#
my ($state, $cpk, $dpk) = (0, 0, 0);

while (<STDIN>) {
    my $line = $_;
    chomp($line);

    $cpk = int($line) if $state == 0;
    $dpk = int($line) if $state == 1;
    $state++;
}


##
# Part 1.
#
my ($c, $v, $cls, $dls) = (0, 1, 0, 0);

# Find card loop size.
do {
    $v = ($v * 7) % P;
    $cls++;
} while ($v != $cpk);

# Find door loop size.
($c, $v) = (0, 1);
do {
    $v = ($v * 7) % P;
    $dls++;
} while ($v != $dpk);

# Loop over door loop size the card public key subject.
$v = 1;
for (1..$dls) {
    $v = ($v * $cpk) % P;
}

say "Part 1: $v";


##
# Part 2.
#
say "Part 2: ";
