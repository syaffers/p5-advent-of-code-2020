#!/usr/bin/perl

##
# Preamble.
#
use warnings;
use strict;
use List::Util qw(sum);


sub say {
    print "@_\n";
}

sub automate {
    ##
    # Hexagonal cellular automaton.
    #
    # So 2020 has has a few cellular automatons. And recursions. What's up?
    #
    # Args
    # ---
    #     tiles (hash reference): hash containing currently active hex cells.
    #         The keys are the q,r coordinates concat as a string by `,`.
    #
    # Returns
    # ---
    #     hash reference: updated tiles.
    #
    my ($tiles) = @_;
    my %next_tiles = %{$tiles};
    my @actives = keys(%next_tiles);
    my @fringes;

    # Go through all active tiles.
    while (@actives) {
        # Really convoluted way of taking the first item in hash and converting
        # to two int values.
        my $p = shift(@actives);
        my ($q, $r) = map { int($_) } split(/,/, $p);

        my $count = 0;
        my @neighbors = (
            ($q+1).",".($r),  # E.
            ($q).",".($r+1),  # SE.
            ($q-1).",".($r),  # W.
            ($q).",".($r-1),  # NW.
            ($q-1).",".($r+1),  # SW.
            ($q+1).",".($r-1)  # NE.
        );
        for my $n (@neighbors) {
            $count++ if exists($tiles->{$n});
            # Add cells that are in the fringe (not active but adjacent).
            push(@fringes, $n) if !exists($tiles->{$n});
        }

        # DIE, AUTOMATON!
        delete $next_tiles{"$p"} if (($count == 0) or ($count > 2));
    }

    # Go through all fringe tiles.
    while (@fringes) {
        my $p = shift(@fringes);
        my ($q, $r) = map { int($_) } split(/,/, $p);

        my $count = 0;
        my @neighbors = (
            ($q+1).",".($r),
            ($q).",".($r+1),
            ($q-1).",".($r),
            ($q).",".($r-1),
            ($q-1).",".($r+1),
            ($q+1).",".($r-1)
        );
        for my $n (@neighbors) {
            $count++ if exists($tiles->{$n});
        }

        # RISE, AUTOMATON...
        $next_tiles{"$p"} = 1 if $count == 2;
    }

    return \%next_tiles;
}


##
# Intro.
#
my %tiles;

while (<STDIN>) {
    my $line = $_;
    chomp($line);

    # https://www.redblobgames.com/grids/hexagons/#coordinates-axial.
    my ($q, $r) = (0, 0);

    # Prepare all active tiles.
    my $dir = '';
    for my $d (split(//, $line)) {
        $dir .= $d;
        next if ($d eq 'n') or ($d eq 's');

        $q++ if ($dir eq 'e');
        $r++ if ($dir eq 'se');
        $q-- if ($dir eq 'w');
        $r-- if ($dir eq 'nw');
        if ($dir eq 'sw') { $r++; $q--; }
        if ($dir eq 'ne') { $r--; $q++; }
        $dir = '';
    }

    # Flip the tile at the end.
    if (exists($tiles{"$q,$r"})) {
        delete $tiles{"$q,$r"};  # Flip to white.
    } else {
        $tiles{"$q,$r"} = 1;  # Flip to black.
    }
}


##
# Part 1.
#
say "Part 1: " . sum(values(%tiles));


##
# Part 2.
#
my $r_tiles = \%tiles;

for my $i (1..100) {
    $r_tiles = automate($r_tiles);
}
say "Part 2: " . sum(values(%{$r_tiles}));
