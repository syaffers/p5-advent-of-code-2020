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
    my %cups = %{$_[0]};
    my $n = $_[1];
    my $m = max(keys(%cups));

    # Form the hold list, and get the starting and ending position of the hold
    # part.
    my $hold_start = $cups{$n};
    my $c = $hold_start;
    my @hold;
    push(@hold, $hold_start);
    for (1..2) {
        $c = $cups{$c};
        push(@hold, $c);
    }
    my $hold_end = $c;
    my $remainder_start = $cups{$hold_end};

    # Determine the destination, do not accept if it's in the hold list.
    my $destination = undef;
    my $d = ($n-1) % ($m+1);
    while (!defined($destination)) {
        $d = $m if $d == 0;
        if (!($d ~~ @hold)) {
            $destination = $d;
            last;
        }
        --$d;
    }
    my $destination_end = $cups{$destination};

    # Re-point things.
    $cups{$n} = $remainder_start;
    $cups{$destination} = $hold_start;
    $cups{$hold_end} = $destination_end;

    return \%cups;
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
    $cupsl{$cups[$i-1]} = int($cups[$i]);
}
$cupsl{$cups[scalar(@cups)-1]} = int($cups[0]);


##
# Part 1.
#
my $n = first {$_} @cups;
for (1..100) {
    %cupsl = %{crotate2(\%cupsl, $n)};
    $n = $cupsl{$n};
}

my $output = '';
$n = 1;
while (1) {
    $n = $cupsl{$n};
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
    $cupsl{$cups[$i-1]} = int($cups[$i]);
}
$cupsl{$cups[scalar(@cups)-1]} = int($cups[0]);

# Loop for 10M iterations.
$n = first {$_} @cups;
for my $i (1..10_000_000) {
    say "$i";
    %cupsl = %{crotate2(\%cupsl, $n)};
    $n = $cupsl{$n};
}

# say "Part 2: @cups";
