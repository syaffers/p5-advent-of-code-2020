#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use integer;
use List::Util qw(sum);
use constant B => 36;


sub dec2binarr {
    ##
    # Create a list of bits from an integer given a bit width.
    #
    # Args
    # ---
    #     n (int): the number to convert into a binary array.
    #     b (int): the width of bits.
    #
    # Returns
    # ---
    #     list: of bits representing the number n.
    #
    my ($n, $b) = @_;
    my @binarr = (0) x $b;

    for my $i (reverse(0..$b-1)) {
        my $xr = 2 ** $i;
        if (($n/$xr) > 0) {
            $binarr[$b-$i-1] = 1;
            $n %= $xr;
        }
    }
    return @binarr;
}

sub binarr2dec {
    ##
    # Convert a binary array into an integer.
    #
    # Args
    # ---
    #     binarr (list): the binary array.
    #
    # Returns
    # ---
    #     int: the number represented by the input binary array.
    #
    my @binarr = @{$_[0]};
    my $b = scalar(@binarr);
    my $n = 0;

    for my $i (reverse(0..$b-1)) {
        $n += $binarr[$b-$i-1] * 2 ** $i;
    }
    return $n;
}


# Intro.
my $max_addr = 0;
my @program;

while (<STDIN>) {
    my $line = $_;
    chomp($line);

    # Just getting the max memory we need.
    if ($line =~ /mem\[([0-9]+)\]/) {
        $max_addr = (int($1) > $max_addr) ? int($1) : $max_addr;
    }
    push(@program, $line);
}


# Part 1.
my @mask;
my %memory;

# Go through the program again.
for my $line (@program) {
    if ($line =~ /^mask = (.*)$/) {
        @mask = split(//, $1);
    } elsif ($line =~ /mem\[([0-9]+)\] = ([0-9]+)/) {
        # Apply mask to number and convert back.
        my $address = int($1);
        my @val_binarr = dec2binarr(int($2), B);
        for my $i (0..scalar(@mask)-1) {
            next if $mask[$i] eq 'X';
            $val_binarr[$i] = int($mask[$i]);
        }

        # Put into the right memory addr.
        $memory{$address} = binarr2dec(\@val_binarr);
    }
}

print "Part 1: ", sum(values(%memory)), "\n";


# Part 2.
undef %memory;
my $k;
my @floating_idxs;

# Go through the program again.
for my $line (@program) {
    if ($line =~ /^mask = (.*)$/) {
        # Get the index of floating bits and count them.
        undef @floating_idxs;
        @mask = split(//, $1);
        for my $i (0..B-1) {
            push(@floating_idxs, $i) if $mask[$i] eq 'X';
        }
        $k = scalar(@floating_idxs);
    } elsif ($line =~ /mem\[([0-9]+)\] = ([0-9]+)/) {
        my $value = int($2);
        my @addr_binarr = dec2binarr(int($1), B);
        my @new_mask = @addr_binarr;

        # Apply mask to memory address converting 1s.
        for my $i (0..B-1) {
            if ($mask[$i] eq '1') {
                $new_mask[$i] = 1;
            }
        }

        # Enumerate all possible floating combinations.
        for my $i (0..2**$k-1) {
            my @bits = dec2binarr($i, $k);

            # Sub all 'X' in to the current bit representation.
            # For example:
            #     @new_mask -> X X 1 1 1 0 1 0 X 0 1
            #     @bits -> 0 1 1
            # Then,
            #     @new_mask -> 0 1 1 1 1 0 1 0 1 0 1
            #
            for my $j (0..$k-1) {
                $new_mask[$floating_idxs[$j]] = $bits[$j]
            }

            # Convert the imputed mask back into int and store.
            my $address = binarr2dec(\@new_mask);
            $memory{$address} = $value;
        }
    }
}

print "Part 2:", sum(values(%memory)), "\n";
