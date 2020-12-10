#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use integer;
use Memoize;

memoize('count_paths');

sub count_paths {
    ##
    # Recursive path counter. Where's Dom Cobb at?
    #
    # If we reach the target adapter, there has to be one path from the source
    # adapter. Otherwise, we add up the possible paths to the target from each
    # adapter that is compatible with the current adapter.
    #
    # Args
    # ---
    #     adapters (hash): hash of adapters and their compatible adapters from
    #         the original set of adapters.
    #     source (int): the joltage of the current adapter.
    #     target (int): the joltage of the target adapter.
    #
    # Returns
    # ---
    #     int: number of paths from the source adapter to the target adapter.
    #

    my %adapters = %{$_[0]};
    my ($source, $target) = @_[1..2];

    if ($source == $target) {
        return 1;
    }

    my $count = 0;
    for my $next (@{$adapters{$source}}) {
        $count += count_paths(\%adapters, $next, $target);
    }
    return $count;
}


# Intro.
my @adapters;

while (<STDIN>) {
    my $line = $_;
    chomp($line);
    push(@adapters, int($line));
}


# Part 1.
my @sorted = sort {$a <=> $b} @adapters;

# Add our device's joltage and socket's joltage.
push(@sorted, $sorted[-1] + 3);
unshift(@sorted, 0);
my %counter = (1 => 0, 3 => 0);

for my $i (1..scalar(@sorted)-1) {
    my $diff = $sorted[$i] - $sorted[$i-1];
    $counter{$diff}++;
}

my $output = $counter{3} * $counter{1};
print "Part 1: $output\n";

# Part 2.
# Create a traversal graph for adapters.
my %graph;

for my $adapter (@sorted) {
    my @nexts = ();
    for my $next ($adapter+1..$adapter+3) {
        if ($next ~~ @sorted) {
            push(@nexts, $next);
        }
    }
    $graph{$adapter} = [@nexts];
}

# The number of ways you can combine adapters is equal to the number of
# possible adapters you can pick at the current point in time and their
# combination of adapters and so on until you get to your device.
my $ways = count_paths(\%graph, 0, $sorted[-1]);
print "Part 2: $ways\n";
