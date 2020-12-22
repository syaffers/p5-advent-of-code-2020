#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use List::Util qw(reduce);


# Intro.
my $depart;
my (@buses, @delays);

while (<STDIN>) {
    my $line = $_;
    my $delay = -1;
    chomp($line);

    if ($line =~ /^[0-9]+$/) {
        $depart = int($line);
    } else {
        for my $id (split(/,/, $line)) {
            $delay++;
            next if ($id eq "x");
            push(@buses, int($id));
            push(@delays, $delay);  # Store the difference mod id.
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
# Turns out CRT is the answer. Heard of it before, just didn't know what it was
# for. We need to find the time at which all buses are in that particular
# config which happens to be solving the following system of equations:
#
#     x ≡ s_1 (mod bus_1)
#     x ≡ s_2 (mod bus_2)
#      ...
#     x ≡ s_n (mod bus_n)
#
# where s_i is the starting time for that bus calculated as (bus_i - d_i) where
# d_i is the delay based on the schedule. This system is solved by using CRT.
# I forego the calculation of the first bus since the calculation for its part
# is 0.
my $N = reduce {$a * $b} @buses;
my $time = 0;

# CRT, basically.
for my $i (1..scalar(@buses)-1) {
    my $bus = $buses[$i];
    my $s = $bus - $delays[$i];  # s_i
    my $n = $N / $bus;  # N_i
    my $x = $n % $bus;  # x_i

    for my $j (0..$bus-1) {
        if ((($x * $j) % $bus) == 1) {
            $x = $j;
            last;
        }
    }

    $time += $s * $n * $x;
}

$time %= $N;
print "Part 2: $time\n";
