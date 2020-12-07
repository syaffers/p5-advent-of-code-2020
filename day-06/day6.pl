#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use integer;


# Intro.
my $exists = my $all = my $people = 0;
my %questions;

while (<STDIN>) {
    my $line = $_;

    if ($line eq "\n") {
        $exists += scalar(keys(%questions));

        while (my ($question, $count) = each(%questions)) {
            if ($count == $people) {
                $all++;
            }
        }

        $people = 0;
        undef %questions;
    } else {
        chomp($line);
        ++$people;

        for my $char (split(//, $line)) {
            $questions{$char}++;
        }
    }
}

$exists += scalar(keys(%questions));

while (my ($question, $count) = each(%questions)) {
    if ($count == $people) {
        $all++;
    }
}

# Part 1.
print "Part 1: $exists\n";

# Part 2.
print "Part 2: $all\n";
