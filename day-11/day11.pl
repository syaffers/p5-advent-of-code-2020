#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use integer;
use List::Util qw(sum);


sub make_lookup {
    ##
    # Create a lookup table of the neighbors for each cell.
    #
    # Args
    # ---
    #     layout (list): the layout.
    #     m (int): the number of rows of the layout.
    #     n (int): the number of columns of the layout.
    #
    # Returns
    # ---
    #     hash: lookup table of the neighbors for each cell.
    #
    my @layout = @{$_[0]};
    my ($m, $n) = @_[1..2];
    my %lookup;

    for my $k (0..scalar(@layout)-1) {
        next if $layout[$k] == 0;
        my @indices;
        my ($has_left, $has_right, $has_up, $has_down) = (0, 0, 0, 0);

        # Check if we can count any left columns.
        if (($k % $n) > 0) {
            push(@indices, $k-1) if ($layout[$k-1] == 1);
            $has_left++;
        }

        # Check if we can count any right columns.
        if (($k % $n) < ($n-1)) {
            push(@indices, $k+1) if ($layout[$k+1] == 1);
            $has_right++;
        }

        # Check if we can count any top rows.
        if ($k >= $n) {
            push(@indices, $k-$n) if ($layout[$k-$n] == 1);
            $has_up++;
        }

        # Check if we can count any bottom rows.
        if ($k < ($m-1)*$n) {
            push(@indices, $k+$n) if ($layout[$k+$n] == 1);
            $has_down++;
        }

        # Check diagonals.
        if ($has_up and $has_left) {
            push(@indices, $k-$n-1) if ($layout[$k-$n-1] == 1);
        }

        if ($has_up and $has_right) {
            push(@indices, $k-$n+1) if ($layout[$k-$n+1] == 1);
        }

        if ($has_down and $has_left) {
            push(@indices, $k+$n-1) if ($layout[$k+$n-1] == 1);
        }

        if ($has_down and $has_right) {
            push(@indices, $k+$n+1) if ($layout[$k+$n+1] == 1);
        }

        $lookup{$k} = [ @indices ];
    }

    return %lookup;
}

sub make_lookup_v2 {
    ##
    # Create a lookup table of the far-adjacent neighbors for each cell.
    #
    # Args
    # ---
    #     layout (list): the layout.
    #     m (int): the number of rows of the layout.
    #     n (int): the number of columns of the layout.
    #
    # Returns
    # ---
    #     hash: lookup table of the far-adjacent neighbors for each cell.
    #
    my @layout = @{$_[0]};
    my ($m, $n) = @_[1..2];
    my %lookup;

    for my $k (0..scalar(@layout)-1) {
        next if $layout[$k] == 0;
        my ($i, $j);
        my @indices;

        # Left check.
        ($i, $j) = ($k / $n, $k % $n - 1);
        while ($j >= 0) {
            if ($layout[$i*$n+$j]) {
                push(@indices, $i*$n+$j);
                last;
            }
            $j--;
        }

        # Right check.
        ($i, $j) = ($k / $n, $k % $n + 1);
        while ($j < $n) {
            if ($layout[$i*$n+$j]) {
                push(@indices, $i*$n+$j);
                last;
            }
            $j++;
        }

        # Up check.
        ($i, $j) = ($k / $n - 1, $k % $n);
        while ($i >= 0) {
            if ($layout[$i*$n+$j]) {
                push(@indices, $i*$n+$j);
                last;
            }
            $i--;
        }

        # Down check.
        ($i, $j) = ($k / $n + 1, $k % $n);
        while ($i < $m) {
            if ($layout[$i*$n+$j]) {
                push(@indices, $i*$n+$j);
                last;
            }
            $i++;
        }

        # Left-up check.
        ($i, $j) = ($k / $n - 1, $k % $n - 1);
        while (($i >= 0) and ($j >= 0)) {
            if ($layout[$i*$n+$j]) {
                push(@indices, $i*$n+$j);
                last;
            }
            $i--;
            $j--;
        }

        # Right-up check.
        ($i, $j) = ($k / $n - 1, $k % $n + 1);
        while (($i >= 0) and ($j < $n)) {
            if ($layout[$i*$n+$j]) {
                push(@indices, $i*$n+$j);
                last;
            }
            $i--;
            $j++;
        }

        # Left-down check.
        ($i, $j) = ($k / $n + 1, $k % $n - 1);
        while (($i < $m) and ($j >= 0)) {
            if ($layout[$i*$n+$j]) {
                push(@indices, $i*$n+$j);
                last;
            }
            $i++;
            $j--;
        }

        # Right-down check.
        ($i, $j) = ($k / $n + 1, $k % $n + 1);
        while (($i < $m) and ($j < $n)) {
            if ($layout[$i*$n+$j]) {
                push(@indices, $i*$n+$j);
                last;
            }
            $i++;
            $j++;
        }

        $lookup{$k} = [ @indices ];
    }

    return %lookup;
}

sub step {
    ##
    # Run a step in the simulation.
    #
    # Let's face it, it's not people sitting down: it's a cellular automaton...
    #
    # Args
    # ---
    #     layout (list): the layout at the current time.
    #     lookup (hash): lookup table for the neighbors of each cell.
    #     c (int): the number of neighbors before a cell dies.
    #     m (int): the number of rows of the layout.
    #     n (int): the number of columns of the layout.
    #
    # Returns
    # ---
    #     list: the new layout after one step in the simulation.
    #
    my @layout = @{$_[0]};
    my %lookup = %{$_[1]};
    my ($c, $m, $n) = @_[2..5];
    my @layout_cpy = @layout;

    for my $i (keys(%lookup)) {
        # A really convoluted way to count the adjacents.
        my $count = sum(map {$layout[$_] == 2} @{$lookup{$i}});

        if ($count == 0) {
            $layout_cpy[$i] = 2;
        }
        if ($count >= $c) {
            $layout_cpy[$i] = 1;
        }
    }

    return @layout_cpy;
}

sub is_diff_layout {
    ##
    # Layout differential function.
    #
    # Calculate if a layout is different to another.
    #
    # Args
    # ---
    #     layout (list): the layout at the current time.
    #     prev_layout (list): the layout at the previous time.
    #
    # Returns
    # ---
    #     int: 1 if it's different, 0 otherwise.
    #
    my @layout = @{$_[0]};
    my @prev_layout = @{$_[1]};

    for my $i (0..scalar(@layout)-1) {
        return 1 if $layout[$i] != $prev_layout[$i];
    }
    return 0;
}

# Intro.
my ($m, $n);  # Size of layout.
my @layout;

while (<STDIN>) {
    my $line = $_;
    chomp($line);

    $n = 0;
    for my $cell (split(//, $line)) {
        push(@layout, $cell eq 'L' ? 1 : 0);
        $n++;
    }
    $m++;
}

my @layout_backup = @layout;

# Part 1.
my $diff = 1;
my @prev_layout = @layout;
my %lookup = make_lookup(\@layout, $m, $n);
while ($diff) {
    @layout = step(\@prev_layout, \%lookup, 4, $m, $n);
    $diff = is_diff_layout(\@layout, \@prev_layout);
    @prev_layout = @layout;
}

my $output = sum(map {$_ == 2} @layout);
print "Part 1: $output\n";

# Part 2.
$diff = 1;
@layout = @layout_backup;
@prev_layout = @layout;
%lookup = make_lookup_v2(\@layout, $m, $n);
while ($diff) {
    @layout = step(\@prev_layout, \%lookup, 5, $m, $n);
    $diff = is_diff_layout(\@layout, \@prev_layout);
    @prev_layout = @layout;
}

$output = sum(map {$_ == 2} @layout);
print "Part 2: $output\n";
