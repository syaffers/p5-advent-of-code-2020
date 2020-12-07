#!/usr/bin/perl

# Preamble.
use strict;
use warnings;
use integer;
use List::Util qw(max);


# Intro.
my %seats;

while (<STDIN>) {
    my $line = $_;
    my $id = 0;
    my $xr = 9;

    chomp($line);
    for my $part ($line) {
        for my $char (split(//, $part)) {
            if (($char eq 'B') or ($char eq 'R')) {
                $id += 2 ** $xr;
            }
            --$xr;
        }
        $seats{$id} = 1;
    }
}

# Part 1.
my $max_id = max(keys %seats);
print "Part 1: $max_id\n";

# Part 2.
my $prev_seat = 0;

for my $curr_seat (1..1023) {
    if (!exists($seats{$curr_seat})) {
        if (($curr_seat - $prev_seat) > 1) {
            print "Part 2: $curr_seat\n";
            last;
        } else {
            $prev_seat = $curr_seat;
        }
    }
}
