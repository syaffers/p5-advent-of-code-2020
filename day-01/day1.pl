#!/usr/bin/perl

use strict;
use warnings;
use integer;

# Intro.
my @nums;

while (<STDIN>) {
    my $n = int($_);
    push(@nums, $n);
}

# Part 1.
my %lookup;
my $a;
my $b;

for my $n (@nums) {
    if (exists($lookup{$n})) {
        $a = $n;
        $b = $lookup{$n};
        last;
    }
    $lookup{2020-$n} = $n;
}

print "Part 1: ", $a * $b, "\n";

# Part 2.
undef %lookup;
my $c;

for my $n (@nums) {
    for my $m (@nums) {
        if (exists($lookup{$m})) {
            $a = $m;
            $b = $lookup{$m}[0];
            $c = $lookup{$m}[1];
            last;
        }
        if ((2020 - $n - $m) > 0) {
            $lookup{2020-$n-$m} = [($n, $m)];
        }
    }
}

print "Part 2: ", $a * $b * $c, "\n";
