#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use integer;


sub play {
    ##
    # Play the elves' weird counting game thing given a starter.
    #
    # Args
    # ---
    #     numbers (hash): the history of the game given the starting numbers.
    #     n (int): the last number said out loud.
    #     step (int): the current step.
    #     end (int): the step to end the game.
    #
    # Returns
    # ---
    #     int: the number last called out at step `end`.
    #
    my %numbers = %{$_[0]};
    my ($n, $step, $end) = @_[1..3];

    while ($step <= $end) {
        if (exists($numbers{$n})) {  # He's a pro...
            my $last = $numbers{$n};
            $numbers{$n} = $step;
            $n = $step - $last;
        } else {  # Buster Scruggs says...
            $numbers{$n} = $step;
            $n = 0;
        }
        $step++;
    }

    return $n;
}


# Intro.
my $n = 0;
my $step = 1;
my %numbers;  # Hash that contains the step that the number was last seen.

while (<STDIN>) {
    my $line = $_;
    chomp($line);

    # Play the starting numbers.
    for my $j (split(',', $line)) {
        if ($step > 1) {
            $numbers{$n} = $step;
        }
        $n = int($j);
        $step++;
    }
}


# Part 1.
print "Part 1: ", play(\%numbers, $n, $step, 2020), "\n";

# Part 2.
print "Part 2: ", play(\%numbers, $n, $step, 30000000), "\n";
