#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use List::Util qw(sum);


sub move {
    my ($inst, $x, $y, $dir) = @_;
    $inst =~ /([A-Z])([0-9]+)/;

    my $action = $1;
    my $steps = int($2);
    my $ddir;
    { # DAMN IT PERL! Y U DO THIS! I CAN'T MOD NEGATIVES W/ INTEGER AND I CAN'T
      # INT DIVIDE W/OUT IT.
        use integer;
        $ddir = $steps / 90;
    }

    if ($action eq "N") {
        return ($x, $y+$steps, $dir);
    } elsif ($action eq "S") {
        return ($x, $y-$steps, $dir);
    } elsif ($action eq "E") {
        return ($x+$steps, $y, $dir);
    } elsif ($action eq "W") {
        return ($x-$steps, $y, $dir);
    } elsif ($action eq "L") {
        return ($x, $y, ($dir - $ddir) % 4);
    } elsif ($action eq "R") {
        return ($x, $y, ($dir + $ddir) % 4);
    } else {
        return ($x+$steps, $y, $dir) if ($dir == 0);
        return ($x, $y-$steps, $dir) if ($dir == 1);
        return ($x-$steps, $y, $dir) if ($dir == 2);
        return ($x, $y+$steps, $dir) if ($dir == 3);
    }
}

sub move_wp {
    my ($inst, $x, $y, $x_wp, $y_wp) = @_;
    $inst =~ /([A-Z])([0-9]+)/;

    my $action = $1;
    my $steps = int($2);

    if ($action eq "N") {
        return ($x, $y, $x_wp, $y_wp+$steps);
    } elsif ($action eq "S") {
        return ($x, $y, $x_wp, $y_wp-$steps);
    } elsif ($action eq "E") {
        return ($x, $y, $x_wp+$steps, $y_wp);
    } elsif ($action eq "W") {
        return ($x, $y, $x_wp-$steps, $y_wp);
    } elsif ($action eq "L") {
        return ($x, $y, -$y_wp, $x_wp) if ($steps == 90);
        return ($x, $y, -$x_wp, -$y_wp) if ($steps == 180);
        return ($x, $y, $y_wp, -$x_wp) if ($steps == 270);
        return ($x, $y, $x_wp, $y_wp) if ($steps == 360);
    } elsif ($action eq "R") {
        return ($x, $y, $y_wp, -$x_wp) if ($steps == 90);
        return ($x, $y, -$x_wp, -$y_wp) if ($steps == 180);
        return ($x, $y, -$y_wp, $x_wp) if ($steps == 270);
        return ($x, $y, $x_wp, $y_wp) if ($steps == 360);
    } else {
        return ($x + $steps*$x_wp, $y + $steps*$y_wp, $x_wp, $y_wp);
    }
}


# Intro.
my @insts;

while (<STDIN>) {
    my $line = $_;
    chomp($line);
    push(@insts, $line);
}

# Part 1.
my ($x, $y, $dir) = (0, 0, 0);  # dir: 0 -> E, 1 -> S, 2 -> W, 3 -> N.
for my $inst (@insts) {
    ($x, $y, $dir) = move($inst, $x, $y, $dir);
}
print "Part 1: ", abs($x) + abs($y), "\n";

# Part 2.
($x, $y) = (0, 0);
my ($x_wp, $y_wp) = (10, 1);
for my $inst (@insts) {
    ($x, $y, $x_wp, $y_wp) = move_wp($inst, $x, $y, $x_wp, $y_wp);
}
print "Part 2: ", abs($x) + abs($y), "\n";
