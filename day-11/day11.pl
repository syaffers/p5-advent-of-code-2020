#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use integer;
use List::Util qw(sum min max);


sub check_surround {
    my @layout = @{$_[0]};
    my ($m, $n, $k) = @_[1..3];
    my @indices;
    my ($count, $has_left, $has_right, $has_up, $has_down) = (0, 0, 0, 0, 0);

    # Check if we can count any left columns.
    if (($k % $n) > 0) {
        push(@indices, $k-1) if ($layout[$k-1] > 0);
        $count++ if ($layout[$k-1] > 1);
        $has_left++;
    }

    # Check if we can count any right columns.
    if (($k % $n) < ($n-1)) {
        push(@indices, $k+1) if ($layout[$k+1] > 0);
        $count++ if ($layout[$k+1] > 1);
        $has_right++;
    }

    # Check if we can count any top rows.
    if ($k >= $n) {
        push(@indices, $k-$n) if ($layout[$k-$n] > 0);
        $count++ if ($layout[$k-$n] > 1);
        $has_up++;
    }

    # Check if we can count any bottom rows.
    if ($k < ($m-1)*$n) {
        push(@indices, $k+$n) if ($layout[$k+$n] > 0);
        $count++ if ($layout[$k+$n] > 1);
        $has_down++;
    }

    # Check diagonals.
    if ($has_up and $has_left) {
        push(@indices, $k-$n-1) if ($layout[$k-$n-1] > 0);
        $count++ if ($layout[$k-$n-1] > 1);
    }

    if ($has_up and $has_right) {
        push(@indices, $k-$n+1) if ($layout[$k-$n+1] > 0);
        $count++ if ($layout[$k-$n+1] > 1);
    }

    if ($has_down and $has_left) {
        push(@indices, $k+$n-1) if ($layout[$k+$n-1] > 0);
        $count++ if ($layout[$k+$n-1] > 1);
    }

    if ($has_down and $has_right) {
        push(@indices, $k+$n+1) if ($layout[$k+$n+1] > 0);
        $count++ if ($layout[$k+$n+1] > 1);
    }

    return ($count, @indices);
}

sub step {
    my @layout = @{$_[0]};
    my ($m, $n) = @_[1..2];
    my @layout_cpy = @layout;

    for my $i (0..scalar(@layout)-1) {
        next if $layout[$i] == 0;
        my ($count, @indices) = check_surround(\@layout, $m, $n, $i);

        if ($count == 0) {
            $layout_cpy[$i] = 2;
        }
        if ($count >= 4) {
            $layout_cpy[$i] = 1;
        }
    }

    return @layout_cpy;
}

sub layout_diff {
    my @layout = @{$_[0]};
    my @prev_layout = @{$_[1]};
    my $count = 0;

    for my $i (0..scalar(@layout)-1) {
        $count++ if $layout[$i] != $prev_layout[$i];
    }
    return $count;
}

sub print_layout {
    my @layout = @{$_[0]};
    my ($m, $n) = @_[1..2];

    for my $i (0..$m-1) {
        for my $j (0..$n-1) {
            my $k = $i*$n+$j;
            my $c = $layout[$k] == 0 ? '.' :
                        ($layout[$k] == 1 ? 'L' : '#');
            print "$c";
        }
        print "\n";
    }
}

# Intro.
my ($m, $n);
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

# Part 1.
my $diff;
my @prev_layout = @layout;
while (1) {
    @layout = step(\@prev_layout, $m, $n);
    $diff = layout_diff(\@layout, \@prev_layout);
    last if $diff == 0;
    @prev_layout = @layout;
}

my $output = sum(map {$_ == 2} @layout);
print "Part 1: $output\n";

# Part 2.
