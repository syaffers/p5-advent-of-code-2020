#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use integer;
use List::Util qw(sum min max);


# Intro.
my @adapters;

while (<STDIN>) {
    my $line = $_;
    chomp($line);
    push(@adapters, int($line));
}


# Part 1.
my @sorted = sort {$a <=> $b} @adapters;

# Add our device's and socket's joltage.
push(@sorted, $sorted[-1] + 3);
unshift(@sorted, 0);
my %counter = (1 => 0, 3 => 0);

for my $i (1..scalar(@sorted)-1) {
    my $diff = $sorted[$i] - $sorted[$i-1];
    $counter{$diff}++;
}

my $output = $counter{3} * $counter{1};
print "Part 1: $output\n";

# # Part 2.
# my $exit = 0;

# # Idk, 100 seems like a big enough number to sum up, I'll increase if needed.
# # *SPOILER*: I didn't need to.
# for my $i (2..100) {
#     # Basically sliding window of size i.
#     for my $j (0..scalar(@numbers)-$i) {
#         my @sub = @numbers[$j..$j+$i-1];
#         if (sum(@sub) == $invalid) {
#             print "Part 2: ", min(@sub) + max(@sub), "\n";
#             $exit++;
#             last;
#         }
#     }
#     last if $exit;
# }
