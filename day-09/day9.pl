#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use integer;
use List::Util qw(sum min max);


# Intro.
my @numbers;

while (<STDIN>) {
    my $line = $_;
    chomp($line);
    push(@numbers, int($line));
}

# Part 1.
my $invalid;
my @queue = @numbers[0..24];
my %lookup;

for my $i (25..scalar(@numbers)-1) {
    undef(%lookup);
    my $c = $numbers[$i];

    # Store the current number minus the previous 25 numbers and also all the
    # previous 25 numbers. If at least two of these b0is appear more than once,
    # we know there's at least a pear (more commonly, pair).
    for my $m (@queue) {
        $lookup{$c-$m}++;
        $lookup{$m}++;
    }

    # Basically, count values which appear more than once but with more steps.
    my $has_sum = sum(values(%lookup)) - scalar(values(%lookup));
    # Checking the non-pair.
    if ($has_sum < 2) {
        print "Part 1: $c\n";
        $invalid = $c;
        last;
    }

    push(@queue, $numbers[$i]);
    shift(@queue);
}

# Part 2.
my $exit = 0;

# Idk, 100 seems like a big enough number to sum up, I'll increase if needed.
# *SPOILER*: I didn't need to.
for my $i (2..100) {
    # Basically sliding window of size i.
    for my $j (0..scalar(@numbers)-$i) {
        my @sub = @numbers[$j..$j+$i-1];
        if (sum(@sub) == $invalid) {
            print "Part 2: ", min(@sub) + max(@sub), "\n";
            $exit++;
            last;
        }
    }
    last if $exit;
}
