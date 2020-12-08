#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use integer;


sub compute {
    ##
    # Run the 🖥️er!
    #
    # Run a program (given as a list of strings) on the 3-instruction computer.
    # See https://adventofcode.com/2020/day/8 for more information.
    #
    # Args
    # ---
    #     program (list): list of strings containing the program.
    #
    # Returns
    # ---
    #     list of
    #         1) the return value, 0 if no loop was detected, 1 otherwise,
    #         2) the value of the accumulator.
    #

    my @program = @{$_[0]};
    my $accumulator = 0;
    my $pc = 0;
    my %pc_visits;

    while (1) {
        # Check if the PC reaches the end of the program.
        if ($pc >= scalar(@program)) {
            return (0, $accumulator);
        }

        # Check if PC is repeated at some point.
        if (exists($pc_visits{$pc})) {
            return (1, $accumulator);
        }

        # Get the op and value and record the PC.
        my ($op, $value) = split(/ /, $program[$pc]);
        $value = int($value);
        $pc_visits{$pc}++;

        if ($op eq 'nop') {  # `nop` just goes to the next instruction.
            $pc++;
        } elsif ($op eq 'acc') {  # `acc` adds into the accumulator and next.
            $accumulator += $value;
            $pc++;
        } elsif ($op eq 'jmp') {  # `jmp` is a relative jump.
            $pc += $value;
        }
    }
}


# Intro.
my @program;

while (<STDIN>) {
    my $line = $_;
    chomp($line);
    push(@program, $line);
}

# Part 1.
my ($rval, $output) = compute(\@program);
print "Part 1: $output\n";


# Part 2.
# Go through each instruction, copy program, swap nop <=> jmp and run until
# success.
for my $i (0..scalar(@program)) {
    if ($program[$i] =~ /^jmp (.*)$/) {
        my @program_cpy = @program;
        @program_cpy[$i] = "nop $1";
        ($rval, $output) = compute(\@program_cpy);
    } elsif($program[$i] =~ /^nop (.*)$/) {
        my @program_cpy = @program;
        @program_cpy[$i] = "jmp $1";
        ($rval, $output) = compute(\@program_cpy);
    }

    if ($rval == 0) {
        print "Part 2: $output\n";
        last;
    }
}
