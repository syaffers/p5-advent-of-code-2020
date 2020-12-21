#!/usr/bin/perl

##
# Preamble.
#
use warnings;
use strict;
use integer;


sub say {
    my ($s) = @_;
    print "$s\n";
}

sub print_tile {
    my ($tile, $n) = @_;
    my @tile_ = split(//, $tile);

    for my $i (0..$n-1) {
        for my $j (0..$n-1) {
            print $tile_[$i*$n+$j];
        }
        print "\n";
    }
}

sub rotate {
    my ($tile, $n) = @_;
    my $rotated = '';
    my @tile_ = split(//, $tile);

    for my $i (1..$n) {
        for my $j (1..$n) {
            $rotated .= $tile_[$n*$j-$i];
        }
    }

    return $rotated;
}

sub hflip {
    my ($tile, $n) = @_;
    my $flipped = '';
    my @tile_ = split(//, $tile);

    for my $i (0..$n-1) {
        for my $j (reverse(0..$n-1)) {
            $flipped .= $tile_[$i*$n+$j];
        }
    }

    return $flipped;
}

sub match_edge {
    my ($refer, $other, $n) = @_;
    my @refer_ = split(//, $refer);
    my @other_ = split(//, $other);

    my ($top, $right, $bottom, $left) = (0) x 4;
    for my $i (0..$n-1) {
        # Compare A top to B bottom.
        $top++ if ($refer_[$i] eq $other_[$n*($n-1)+$i]);
        # Compare A right to B left.
        $right++ if ($refer_[($n-1)+$i*$n] eq $other_[$n*$i]);
        # Compare A bottom to B top.
        $bottom++ if ($refer_[$n*($n-1)+$i] eq $other_[$i]);
        # Compare A left to B right.
        $left++ if ($refer_[$n*$i] eq $other_[($n-1)+$i*$n]);
    }

    return 1 if $top == $n;
    return 2 if $right == $n;
    return 3 if $bottom == $n;
    return 4 if $left == $n;
    return 0;
}

sub trim {
    my ($tile, $n) = @_;
    my $trimmed = '';
    my @tile_ = split(//, $tile);

    for my $i (0..$n-1) {
        @tile_[$i] = '';
        @tile_[$n*($n-1)+$i] = '';
        @tile_[$n*$i] = '';
        @tile_[$n*$i+($n-1)] = '';
    }

    return join('', @tile_);
}

sub join_tiles {
    my ($main, $tile, $m, $n) = @_;
    my $joined;
    my @main_ = split(//, $main);
    my @tile_ = split(//, $tile);

    for my $i (0..$m) {
        for my $j (0..$n) {

        }
    }
}

##
# Intro.
#
my ($n, $m, $id, $tile) = (0, 0, 0, '');
my %tiles;

while (<STDIN>) {
    my $line = $_;
    chomp($line);

    if ($line =~ /Tile (\d+):/) {
        $id = int($1);
    } elsif ($line eq '') {
        $tiles{$id} = $tile;
        $tile = '';
    } else {
        $n = length($line);
        $tile .= $line;
    }
}

$tiles{$id} = $tile;


##
# Part 1.
#
my $output = 1;
my $corner_i;
my @ids = keys(%tiles);
my %neighbors;

for my $i (keys(%tiles)) {
    $neighbors{$i} = ();
}

# Loop through all pairs of tiles.
for my $refer_i (@ids) {
    my %edges;

    for my $other_i (@ids) {
        next if $refer_i == $other_i;
        my ($refer, $other) = ($tiles{$refer_i}, $tiles{$other_i});

        # Check all rotations of other against refer.
        for (1..4) {
            $other = rotate($other, $n);
            my $edge = match_edge($refer, $other, $n);
            if ($edge) {
                $edges{$edge} = 1;
                push(@{$neighbors{$refer_i}}, $other_i);
            }
        }

        # Check the flipside rotations too.
        $other = hflip($other, $n);
        for (1..4) {
            $other = rotate($other, $n);
            my $edge = match_edge($refer, $other, $n);
            if ($edge) {
                $edges{$edge} = 1;
                push(@{$neighbors{$refer_i}}, $other_i);
            }
        }

    }
    if (scalar(keys(%edges)) == 2) {
        $output *= $refer_i;
        $corner_i = $refer_i;  # Keep one of the corners.
    };
}
say "Part 1: $output";


##
# Part 2.
#
# Create a digraph of the image blocks starting from a corner. Align as we go.
my @frontier = ($corner_i);
my %ortiles = ($corner_i => $tiles{$corner_i});
my %edges;
my %image;
my %visited;

while (scalar(@frontier)) {
    my $tile_i = shift(@frontier);
    $visited{$tile_i} = 0;
    $tile = $ortiles{$tile_i};

    for my $other_i (@{$neighbors{$tile_i}}) {
        if (!exists($visited{$other_i})) {
            push(@frontier, $other_i);
            $visited{$other_i} = 0;
        }

        my $edge;
        my $other = $tiles{$other_i};
        for my $i (0..7) {
            $edge = match_edge($tile, $other, $n);
            last if $edge;
            $other = rotate($other, $n);
            $other = hflip($other, $n) if (($i % 4) == 0);
        }

        $ortiles{$other_i} = $other;
        $edges{$tile_i}{$other_i} = $edge;
    }
}

# Find the top-left block.
my $topleft;
for my $u (keys(%edges)) {
    my $ne = '';
    for my $v (keys(%{$edges{$u}})) {
        $ne .= "$edges{$u}{$v}";
    }
    if ($ne == '23' or $ne == '32') {
        $topleft = $u;
        last;
    }
}

# Start from the top-left block and build the image.
my $image = '';
my @frontier2 = ($corner_i);
my @frontier3 = ($corner_i);
# my %visited;

$tile = $ortiles{$topleft};
$tile = trim($tile, $n);

while (scalar(@frontier2) + scalar(@frontier3)) {
    my $tile_i;
    if (scalar(@frontier2) == 0) {
        $tile_i = shift(@frontier3);
    } else {
        $tile_i = shift(@frontier2);
    }
    $visited{$tile_i} = 0;
    $tile = $ortiles{$tile_i};

    for my $other_i (@{$neighbors{$tile_i}}) {
        if (!exists($visited{$other_i})) {
            if ($edges{$tile_i}{$other_i} == 2) {
                push(@frontier2, $other_i);
            } else {
                push(@frontier3, $other_i);
            }
            $visited{$other_i} = 0;
        }
    }
}



say "Part 2:";
