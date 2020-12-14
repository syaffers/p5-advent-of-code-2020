#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use List::Util qw(sum);


# Intro.
my $depart;
my @buses;

while (<STDIN>) {
    my $line = $_;
    chomp($line);

    if ($line =~ /^[0-9]+$/) {
        $depart = int($line);
    } else {
        for my $id (split(/,/, $line)) {
            next if ($id eq "x");
            push(@buses, int($id));
        }
    }
}

# Part 1.
my $minute = 0;
my $end = 0;

while (1) {
    for my $id (@buses) {
        if ((($depart + $minute) % $id) == 0) {
            print "Part 1: ", $minute * $id, "\n";
            $end++;
        }
    }
    last if $end;
    $minute++;
}

# Part 2.
# I'm sure there's something to do with LCMs and stuff. I'll try it later.
