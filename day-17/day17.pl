#!/usr/bin/perl

##
# Preamble.
#
use warnings;
use strict;
use integer;
use List::Util qw(sum);


sub active_surround_3d {
    ##
    # Find all the active neighbors around a cell in 3D space.
    #
    # Args
    # ---
    #     space (hash): active locations of cells in 3D space.
    #     p (string): the point around which to calculate active neighbors.
    #
    # Returns
    # ---
    #     int: the number of active neighbors around `p`.
    #
    my %space = %{$_[0]};
    my $p = $_[1];

    $p =~ /(-?\d+),(-?\d+),(-?\d+)/;
    my ($x,$y,$z) = (int($1), int($2), int($3));
    my $q = "";
    my $count = 0;

    for my $dx (-1..1) {
        for my $dy (-1..1) {
            for my $dz (-1..1) {
                $q = ($x+$dx).",".($y+$dy).",".($z+$dz);
                next if $p eq $q;
                $count++ if (exists($space{$q}));
            }
        }
    }

    return $count;
}

sub active_surround_4d {
    ##
    # Find all the active neighbors around a cell in 4D space.
    #
    # Args
    # ---
    #     space (hash): active locations of cells in 4D space.
    #     p (string): the point around which to calculate active neighbors.
    #
    # Returns
    # ---
    #     int: the number of active neighbors around `p`.
    #
    my %space = %{$_[0]};
    my $p = $_[1];


    $p =~ /(-?\d+),(-?\d+),(-?\d+),(-?\d+)/;
    my ($x,$y,$z,$w) = (int($1), int($2), int($3), int($4));
    my $q = "";
    my $count = 0;

    for my $dx (-1..1) {
        for my $dy (-1..1) {
            for my $dz (-1..1) {
                for my $dw (-1..1) {
                    $q = ($x+$dx).",".($y+$dy).",".($z+$dz).",".($w+$dw);
                    next if $p eq $q;
                    $count++ if (exists($space{$q}));
                }
            }
        }
    }

    return $count;
}


##
# Intro.
#
my ($c, $x, $y, $z, $w) = (0) x 5;
my ($x_min0, $y_min0, $z_min0, $w_min0) = (1000) x 4;
my ($x_max0, $y_max0, $z_max0, $w_max0) = (-1000) x 4;
my (%space_3d, %space_4d);

while (<STDIN>) {
    my $line = $_;
    chomp($line);

    $x = 0;
    for my $c (split(//, $line)) {
        if ($c eq '#') {
            # Perl... I... I just can't... There's no good way to hash tuples.
            # f it, THERE ARE NO TUPLES!!! Python, please take me back. It's
            # like I'm living with an abusive partner.
            # Anyway, I'm keeping a hash of a string representation of the
            # point in 3D and 4D space: "x,y,z" like that so e.g. "-1,5,1".
            $space_3d{"$x,$y,$z"} = 1;
            $space_4d{"$x,$y,$z,$w"} = 1;
            $x_min0 = $x if ($x < $x_min0);
            $y_min0 = $y if ($y < $y_min0);
            $z_min0 = $z if ($z < $z_min0);
            $w_min0 = $w if ($w < $w_min0);
            $x_max0 = $x if ($x > $x_max0);
            $y_max0 = $y if ($y > $y_max0);
            $z_max0 = $z if ($z > $z_max0);
            $w_max0 = $w if ($w > $w_max0);
        }
        $x--;
    }
    $y++;
}


##
# Part 1.
#
my %space_tmp;

# Expand original extent.
my ($x_min, $y_min, $z_min) = ($x_min0-1, $y_min0-1, $z_min0-1);
my ($x_max, $y_max, $z_max) = ($x_max0+1, $y_max0+1, $z_max0+1);

for my $i (1..6) {
    # Copy space into temp space.
    undef %space_tmp;
    for my $p (keys(%space_3d)) {
        $space_tmp{$p} = 1;
    }

    # Loop through all cubes in the extent.
    for $x ($x_min..$x_max) {
        for $y ($y_min..$y_max) {
            for $z ($z_min..$z_max) {
                my $p = "$x,$y,$z";
                $c = active_surround_3d(\%space_3d, $p);
                # If a cube is active w/out 2/3 neighbors, die.
                if (exists($space_3d{$p})) {
                    if (($c==2) or ($c==3)) {
                        $space_tmp{$p} = 1;
                    } else {
                        delete $space_tmp{$p};
                    }
                # Otherwise, inactive w/ 3 neighbors, rise.
                } else {
                    $space_tmp{$p} = 1 if ($c == 3);
                }
            }
        }
    }

    # Copy temp space into space.
    undef %space_3d;
    for my $p (keys(%space_tmp)) {
        $space_3d{$p} = 1;
    }



    # Update extent.
    for my $p (keys(%space_3d)) {
        $p =~ /(-?\d+),(-?\d+),(-?\d+)/;
        ($x, $y, $z) = (int($1), int($2), int($3));
        $x_min = $x if ($x < $x_min);
        $y_min = $y if ($y < $y_min);
        $z_min = $z if ($z < $z_min);
        $x_max = $x if ($x > $x_max);
        $y_max = $y if ($y > $y_max);
        $z_max = $z if ($z > $z_max);
    }

    # Expand extent.
    ($x_min--, $y_min--, $z_min--, $x_max++, $y_max++, $z_max++);
}

print "Part 1: ", sum(values(%space_3d)), "\n";

# Part 2, basically part 1 but DEEPA!.
undef %space_tmp;

# Expand original extent.
my ($w_min, $w_max);
($x_min, $y_min, $z_min, $w_min) = ($x_min0-1, $y_min0-1, $z_min0-1, $w_min0-1);
($x_max, $y_max, $z_max, $w_max) = ($x_max0+1, $y_max0+1, $z_max0+1, $w_max0+1);

for my $i (1..6) {
    # Copy space into temp space.
    undef %space_tmp;
    for my $p (keys(%space_4d)) {
        $space_tmp{$p} = 1;
    }

    # Loop through all cubes in the extent.
    for $x ($x_min..$x_max) {
        for $y ($y_min..$y_max) {
            for $z ($z_min..$z_max) {
                for $w ($w_min..$w_max) {
                    my $p = "$x,$y,$z,$w";
                    $c = active_surround_4d(\%space_4d, $p);
                    # If a cube is active w/out 2/3 neighbors, die.
                    if (exists($space_4d{$p})) {
                        if (($c==2) or ($c==3)) {
                            $space_tmp{$p} = 1;
                        } else {
                            delete $space_tmp{$p};
                        }
                    # Otherwise, inactive w/ 3 neighbors, rise.
                    } else {
                        $space_tmp{$p} = 1 if ($c == 3);
                    }
                }
            }
        }
    }

    # Copy temp space into space.
    undef %space_4d;
    for my $p (keys(%space_tmp)) {
        $space_4d{$p} = 1;
    }

    # Update extent.
    for my $p (keys(%space_4d)) {
        $p =~ /(-?\d+),(-?\d+),(-?\d+),(-?\d+)/;
        ($x, $y, $z, $w) = (int($1), int($2), int($3), int($4));
        $x_min = $x if ($x < $x_min);
        $y_min = $y if ($y < $y_min);
        $z_min = $z if ($z < $z_min);
        $w_min = $w if ($w < $w_min);
        $x_max = $x if ($x > $x_max);
        $y_max = $y if ($y > $y_max);
        $z_max = $z if ($z > $z_max);
        $w_max = $w if ($w > $w_max);
    }

    # Expand extent.
    ($x_min--, $y_min--, $z_min--, $w_min--, $x_max++, $y_max++, $z_max++, $w_max++);
}

print "Part 2: ", sum(values(%space_4d)), "\n";
