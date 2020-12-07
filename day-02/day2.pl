#!/usr/bin/perl

# Preamble.
use strict;
use warnings;
use integer;

# Intro.
my @mins;
my @maxs;
my @chars;
my @passwords;

while (<STDIN>) {
    if ($_ =~ /([0-9]+)-([0-9]+) ([a-z]): (.*)/) {
        push(@mins, $1);
        push(@maxs, $2);
        push(@chars, $3);
        push(@passwords, $4);
    }
}

# Part 1.
my $valids = 0;

for my $i (0..scalar(@passwords)-1) {
    my $min = $mins[$i];
    my $max = $maxs[$i];
    my $char = $chars[$i];
    my $pass = $passwords[$i];
    my $count = 0;
    
    for my $c (split(//, $pass)) {
        ++$count if ($c eq $char);
    }

    ++$valids if (($count >= $min) and ($count <= $max))
}

print "Part 1: $valids\n";

# Part 2.
$valids = 0;

for my $i (0..scalar(@passwords)-1) {
    my $min = $mins[$i];
    my $max = $maxs[$i];
    my $char = $chars[$i];
    my $pass = $passwords[$i];
    my $count = 0;

    ++$valids if ((substr($pass, $min-1, 1) eq $char) xor 
                  (substr($pass, $max-1, 1) eq $char));
}

print "Part 2: $valids\n";
