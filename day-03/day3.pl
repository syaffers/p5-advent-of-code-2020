#!/usr/bin/perl

# Preamble.
use strict;
use warnings;
use integer;


sub trajectory_trees {
    my ($terrain, $di, $dj, $m, $n) = @_;
    my ($p, $i, $j, $trees) = (0, 0, 0, 0);

    while ($p < ($m * $n)) {
        if (@$terrain[$p] eq '#') {
            ++$trees;
        }
        $i += $di;
        $j = ($j + $dj) % $n;
        $p = $i * $n + $j;
    }

    return $trees;
}

# Intro.
my @terrain;
my ($m, $n) = (0, 0);

while (<STDIN>) {
    my $line = $_;
    chomp($line);

    $m++;
    $n = length($line);
    for my $cell (split(//, $line)) {
        push(@terrain, $cell);
    }
}

# Part 1.
my $trees_1_3 = trajectory_trees(\@terrain, 1, 3, $m, $n);

print "Part 1: $trees_1_3\n";

# Part 2.
my $trees_1_1 = trajectory_trees(\@terrain, 1, 1, $m, $n);
my $trees_1_5 = trajectory_trees(\@terrain, 1, 5, $m, $n);
my $trees_1_7 = trajectory_trees(\@terrain, 1, 7, $m, $n);
my $trees_2_1 = trajectory_trees(\@terrain, 2, 1, $m, $n);
my $trees = $trees_1_1 * $trees_1_3 * $trees_1_5 * $trees_1_7 * $trees_2_1;

print "Part 2: $trees\n";
