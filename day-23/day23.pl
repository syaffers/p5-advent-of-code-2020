#!/usr/bin/perl

##
# Preamble.
#
use warnings;
use strict;
use List::Util qw(max);


sub say {
    print "@_\n";
}

sub crotate {
    ##
    # The crab's cups rotation thing.
    #
    # Need more info? https://adventofcode.com/2020/day/23
    #
    # Args
    # ---
    #     cups (hash reference): reference to the hash containing the linked
    #         list.
    #     n (int): the starting cup number.
    #     m (int): the max cup number.
    #
    # Returns
    # ---
    #     none
    #
    my ($cups, $n, $m) = @_;

    # Get all the numbers of cups being held.
    my $hold_start = $cups->{$n};
    my $hold_middle = $cups->{$hold_start};
    my $hold_end = $cups->{$hold_middle};

    # Get the pointer to whatever is after the held cups.
    my $remainder_start = $cups->{$hold_end};

    # Determine the destination, do not accept if it's in the hold list.
    my $destination = $n;
    do {
        $destination--;
        $destination = $m if $destination <= 0;
    } while ($destination == $hold_start or
             $destination == $hold_middle or
             $destination == $hold_end);
    my $destination_end = $cups->{$destination};

    # Re-point things.
    $cups->{$n} = $remainder_start;
    $cups->{$destination} = $hold_start;
    $cups->{$hold_end} = $destination_end;
}


##
# Intro.
#
my @cups;

while (<STDIN>) {
    my $line = $_;
    chomp($line);

    @cups = split(//, $line);
}


##
# Part 1.
#
# Create linked list.
my %cupsl;
for my $i (1..scalar(@cups)-1) {
    $cupsl{int($cups[$i-1])} = int($cups[$i]);
}
$cupsl{int($cups[scalar(@cups)-1])} = int($cups[0]);

# Loop 100 times.
my $n = int($cups[0]);
my $m = max(@cups);
my $r_cupsl = \%cupsl;
for (1..100) {
    crotate($r_cupsl, $n, $m);
    $n = $r_cupsl->{$n};
}

# Print starting from 1 but exluding it.
my $output = '';
$n = 1;
while (1) {
    $n = $r_cupsl->{$n};
    last if $n == 1;
    $output .= "$n";
}

say "Part 1: $output";


##
# Part 2.
#
# Recreate the linked list.
undef %cupsl;
for my $i (1..scalar(@cups)-1) {
    $cupsl{int($cups[$i-1])} = int($cups[$i]);
}

# Fill in remainder of the list up to 1M.
$n = int($cups[-1]);
for my $i (10..1_000_000) {
    $cupsl{$n} = $i;
    $n = $i;
}
$cupsl{1_000_000} = int($cups[0]);

# Loop for 10M iterations.
$n = int($cups[0]);
$m = 1_000_000;
$r_cupsl = \%cupsl;
for my $i (1..10_000_000) {
    crotate($r_cupsl, $n, $m);
    $n = $r_cupsl->{$n};
}

my $a = $r_cupsl->{1};
my $b = $r_cupsl->{$a};
say "Part 2: " . ($a * $b);
