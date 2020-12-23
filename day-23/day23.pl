#!/usr/bin/perl

##
# Preamble.
#
use warnings;
use strict;
use List::Util qw(max first);


sub say {
    print "@_\n";
}

sub print_list {
    my %ll = %{$_[0]};
    my $s = $_[1];
    my $c = $s;

    print '[';
    do {
        print "$c";
        $c = $ll{$c};
        print ', ' if !($c eq $s);
    } while (!($c eq $s));
    say ']';
}

sub crotate2 {
    my ($cups, $n, $m) = @_;

    # Form the hold list, and get the starting and ending position of the hold
    # part.
    my $hold_start = $cups->{$n};
    my $hold_middle = $cups->{$hold_start};
    my $hold_end = $cups->{$hold_middle};
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

# Create linked list.
my %cupsl;
for my $i (1..scalar(@cups)-1) {
    $cupsl{int($cups[$i-1])} = int($cups[$i]);
}
$cupsl{int($cups[scalar(@cups)-1])} = int($cups[0]);


##
# Part 1.
#
my $n = first {$_} @cups;
my $m = max(@cups);
my $r_cupsl = \%cupsl;
for (1..100) {
    crotate2($r_cupsl, $n, $m);
    $n = $r_cupsl->{$n};
}

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
# Fill the list.
for my $i (10..1_000_000) {
    push(@cups, $i);
}

# Recreate the linked list.
undef %cupsl;
for my $i (1..scalar(@cups)-1) {
    $cupsl{int($cups[$i-1])} = int($cups[$i]);
}
$cupsl{int($cups[scalar(@cups)-1])} = int($cups[0]);

# Loop for 10M iterations.
$n = first {$_} @cups;
$n = max(@cups);
$r_cupsl = \%cupsl;
for my $i (1..10_000_000) {
    crotate2($r_cupsl, $n, $m);
    $n = $r_cupsl->{$n};
}

my $a = $r_cupsl->{1};
my $b = $r_cupsl->{$a};
say "Part 2: $a x $b = " . ($a * $b);
