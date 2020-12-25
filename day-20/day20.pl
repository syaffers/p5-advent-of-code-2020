#!/usr/bin/perl

##
# Preamble.
#
use warnings;
use strict;
use integer;
use constant N => 10;
use List::Util qw(all);
use Data::Dumper qw(Dumper);

sub say {
    my ($s) = @_;
    print "$s\n";
}

sub rotate {
    ##
    # Rotate a 2D tile 90 degrees counter-clockwise.
    #
    # Args
    # ---
    #     tile (array reference): array reference to tile. Tiles are 2D arrays.
    #     n (int): width (or height) of tile. Assume square tile.
    #
    # Returns
    # ---
    #     array reference: rotated tile.
    #
    my ($tile, $n) = @_;
    my @rotated;

    for my $i (0..$n-1) {
        for my $j (0..$n-1) {
            $rotated[$i][$j] = $tile->[$j][$n-$i-1];
        }
    }

    return \@rotated;
}

sub hflip {
    ##
    # Horizontally flip a 2D tile.
    #
    # Args
    # ---
    #     tile (array reference): array reference to tile. Tiles are 2D arrays.
    #     n (int): width (or height) of tile. Assume square tile.
    #
    # Returns
    # ---
    #     array reference: flipped tile.
    #
    my ($tile, $n) = @_;
    my @flipped;

    for my $i (0..$n-1) {
        for my $j (0..$n-1) {
            $flipped[$i][$j] = $tile->[$i][$n-$j-1];
        }
    }

    return \@flipped;
}

sub match_edge {
    ##
    # Check with edge matches two tiles. In this way:
    #
    #           ---
    #          | O |
    #           ---
    #            ^ 1
    #   ---  4  ---     ---
    #  | O |<--| R |-->| O |
    #   ---     ---  2  ---
    #          3 v
    #           ---
    #          | O |
    #           ---
    #
    # Args
    # ---
    #     refer (array reference): The reference tile.
    #     other (array reference): The other tile.
    #
    # Returns
    # ---
    #     int: the edge which matches the reference tile and the other tile.
    #         1 for top, 2 for right, 3 for bottom, 4 for left. 0 if no match.
    #
    my ($refer, $other) = @_;

    my ($top, $right, $bottom, $left) = (0) x 4;
    for my $i (0..N-1) {
        # Compare A top to B bottom.
        $top++ if ($refer->[0][$i] eq $other->[N-1][$i]);
        # Compare A right to B left.
        $right++ if ($refer->[$i][N-1] eq $other->[$i][0]);
        # Compare A bottom to B top.
        $bottom++ if ($refer->[N-1][$i] eq $other->[0][$i]);
        # Compare A left to B right.
        $left++ if ($refer->[$i][0] eq $other->[$i][N-1]);
    }

    return 1 if $top == N;
    return 2 if $right == N;
    return 3 if $bottom == N;
    return 4 if $left == N;
    return 0;
}

sub trim {
    ##
    # Trim a tile out of its borders.
    #
    # Args
    # ---
    #     tile (array reference): array reference to tile.
    #
    # Returns
    # ---
    #     array reference: trimmed tile.
    #
    my ($tile) = @_;
    my @trimmed;

    for my $i (1..N-2) {
        for my $j (1..N-2) {
            $trimmed[$i-1][$j-1] = $tile->[$i][$j];
        }
    }

    return \@trimmed;
}

sub merge {
    ##
    # Merge a tile into an image.
    #
    # You got tiles, you wanna slot it into an image at a certain (i, j) index.
    # This is the droid you're looking for.
    #
    # Args
    # ---
    #     image (array reference): The image into which the tile is placed.
    #     tile (array reference): The tile to be inserted.
    #     i (int): The row index of the image where the tile should begin.
    #     j (int): The column index of the image where the tile should begin.
    #     n
    #
    # Returns
    # ---
    #     hash reference: updated tiles.
    #
    my ($image, $tile, $i, $j, $n) = @_;

    for my $di (0..N-2-1) {
        for my $dj (0..N-2-1) {
            $image->[$i+$di][$j+$dj] = $tile->[$di][$dj];
        }
    }
}

sub has_kaiju {
    ##
    # Finds the sea monster in the image.
    #
    # Basically, template match this:
    #
    #                      o  ^
    #    o    oo    oo    ooo 3
    #     o  o  o  o  o  o    v
    #    <------- 20 ------->
    #
    # Args
    # ---
    #     image (array reference): The image containing sea monsters (probably).
    #     i (int): The row index of the image where the template is aligned.
    #     j (int): The column index of the image where the template is aligned.
    #
    # Returns
    # ---
    #     int: got kaiju? 1. no? 0.
    #
    my ($image, $i, $j) = @_;
    my @positions = (
        $image->[$i][$j+18],
        $image->[$i+1][$j],
        $image->[$i+1][$j+5],
        $image->[$i+1][$j+6],
        $image->[$i+1][$j+11],
        $image->[$i+1][$j+12],
        $image->[$i+1][$j+17],
        $image->[$i+1][$j+18],
        $image->[$i+1][$j+19],
        $image->[$i+2][$j+1],
        $image->[$i+2][$j+4],
        $image->[$i+2][$j+7],
        $image->[$i+2][$j+10],
        $image->[$i+2][$j+13],
        $image->[$i+2][$j+16]
    );

    return all { $_ eq '#' } @positions;
}


##
# Intro.
#
my ($m, $id, $tile) = (0, 0, '');
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
        $tile .= $line;
    }
}

$tiles{$id} = $tile;
$m = sqrt(scalar(keys(%tiles)));  # Image width and height.

# Break up string tiles into array of arrays.
for $id (keys(%tiles)) {
    my @tile_chr = split(//, $tiles{$id});
    my @tile_arr;
    for my $i (0..N-1) {
        for my $j (0..N-1) {
            $tile_arr[$i][$j] = @tile_chr[$i*N+$j]
        }
    }
    $tiles{$id} = [ @tile_arr ];
}


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
    my $count;

    for my $other_i (@ids) {
        next if $refer_i == $other_i;
        my ($refer, $other) = ($tiles{$refer_i}, $tiles{$other_i});

        # Check all orientations of other against refer.
        for my $i (0..7) {
            $other = rotate($other, N);
            $other = hflip($other, N) if (($i % 4) == 0);
            my $edge = match_edge($refer, $other);
            # If a matching edge is found, increase count and add the
            # neighboring tile.
            if ($edge) {
                $count++;
                push(@{$neighbors{$refer_i}}, $other_i);
            }
        }
    }

    # Two neighbors matched, must be a corner.
    if ($count == 2) {
        $output *= $refer_i;
        $corner_i = $refer_i;  # Keep one of the corners.
    }
}
say "Part 1: $output";


##
# Part 2.
#
# Create a graph of the tiles starting from a corner.
my @frontier = ($corner_i);
my %ortiles = ($corner_i => $tiles{$corner_i});
my %graph;
my %visited;

# BFS, re-orient and create graph.
while (@frontier) {
    my $tile_i = shift(@frontier);
    $visited{$tile_i} = 0;
    $tile = $ortiles{$tile_i};

    for my $other_i (@{$neighbors{$tile_i}}) {
        if (!exists($visited{$other_i})) {
            push(@frontier, $other_i);
            $visited{$other_i} = 0;
        }

        # Find the correct orientation of neighboring tile and store the
        # orientation and the edge at which it matches.
        my $edge;
        my $other = $tiles{$other_i};
        for my $i (0..7) {
            $edge = match_edge($tile, $other);
            last if $edge;
            $other = rotate($other, N);
            $other = hflip($other, N) if (($i % 4) == 0);
        }

        $ortiles{$other_i} = $other;
        $graph{$tile_i}{$other_i} = $edge;
    }
}

# Find the top-left block.
my $topleft;
for my $u (keys(%graph)) {
    my $edge_pos = join('', values(%{$graph{$u}}));
    if ($edge_pos == '23' or $edge_pos == '32') {
        $topleft = $u;
        last;
    }
}

# Form the image.
my ($i, $j, $c) = (0, 0, 0);  # Tile counter.
my @image;
@frontier = ($topleft);
undef %visited;

# Column-first traversal. Consider the digraph:
#
#     0 -> 1 -> 2 -> 3
#     v    V    V    V
#     4 -> 5 -> 6 -> 7
#     v    V    V    V
#     8 -> 9 -> A -> B
#     v    V    V    V
#     C -> D -> E -> F
#
# We want to traverse in the order 0 to F to build the image. To do this, we
# unshift any nodes after -> and push any nodes after v. So if we started at 0,
# our traversal will look like this:
#
#    current node = ., frontier = [0]
#    current node = 0, frontier = [1, 4]
#    current node = 1, frontier = [2, 4, 5]
#    current node = 2, frontier = [3, 4, 5, 6]
#    current node = 3, frontier = [4, 5, 6, 7]
#    current node = 4, frontier = [5, 6, 7, 8]
#
# and so on.
while (@frontier) {
    my $tile_i = shift(@frontier);

    # Add neighbor into frontier but only consider right-joining or
    # bottom-joining neighbors.
    for my $other_i (@{$neighbors{$tile_i}}) {
        if (!exists($visited{$other_i})) {
            # Add next column tile first.
            if ($graph{$tile_i}{$other_i} == 2) {
                unshift(@frontier, $other_i);
                $visited{$other_i} = 0;
            }
            # Bottom-joining tiles to be explored later.
            if ($graph{$tile_i}{$other_i} == 3) {
                push(@frontier, $other_i);
                $visited{$other_i} = 0;
            }
        }
    }

    # Add tile into image at insert position (i, j).
    $tile = trim($ortiles{$tile_i});
    merge(\@image, $tile, $i, $j);

    # Update insert positions.
    $j += (N-2);
    $c++;

    if ($c == $m) {
        $i += (N-2);
        $j = 0;
        $c = 0;
    }
}

# Find sea monsters! For reference, here's what they look like:
#
#                       #  ^
#     #    ##    ##    ### 3
#      #  #  #  #  #  #    v
#     <------- 20 ------->
#
# So we got a window of 20 by 3 to slide around. I'm going to hardcode the
# positions in the has_kaiju function, cause that's fast.

# Check all orientations of the image.
my $image_ = \@image;
my $kaiju_count = 0;
my $k = $m*(N-2);

for my $i (0..7) {
    for my $i (0..$k-3) {
        for my $j (0..$k-20) {
            $kaiju_count += has_kaiju($image_, $i, $j);
        }
    }
    $image_ = rotate($image_, $k);
    $image_ = hflip($image_, $k) if (($i % 4) == 0);
    last if $kaiju_count;
    $kaiju_count = 0;
}

# Final count(down).
my $roughness = 0;
for my $i (0..$k-1) {
    for my $j (0..$k-1) {
        $roughness++ if $image[$i][$j] eq '#';
    }
}

say "Part 2: ".($roughness - $kaiju_count * 15);
