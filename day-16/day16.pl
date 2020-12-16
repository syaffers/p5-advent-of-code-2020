#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use integer;
use List::Util qw(min max sum);


# Intro.
my ($state, $n_fields) = (0, 0);
my @fields;
my @others;
my @ticket;
my %meta;

while (<STDIN>) {
    my $line = $_;

    if ($line =~ /^\n$/) {
        $state++;
        next;
    }

    chomp($line);

    # Read ticket metadata.
    if ($state == 0) {
        $line =~ /([a-z\s]+): (\d+)-(\d+) or (\d+)-(\d+)/;
        my $field = $1;
        push(@fields, $field);
        $meta{$field.'.lo'} = [int($2), int($3)];  # Low range.
        $meta{$field.'.hi'} = [int($4), int($5)];  # High range.
        $n_fields++;
    # Read my ticket.
    } elsif ($state == 1) {
        if ($line =~ /^[0-9]/) {
            @ticket = map { int($_) } split(/,/, $line);
        }
    # Read other tickets.
    } else {
        if ($line =~ /^[0-9]/) {
            push(@others, $line);
        }
    }
}

# Part 1.
my $error = 0;
my @error_lines;

for my $other (@others) {
    my $error_line = 0;
    for my $v (split(/,/, $other)) {
        $v = int($v);
        my $count = 0;
        for my $i (0..$n_fields-1) {
            my ($a, $b) = @{$meta{$fields[$i].'.lo'}};
            my ($c, $d) = @{$meta{$fields[$i].'.hi'}};

            if (($v >= $a and $v <= $b) or ($v >= $c and $v <= $d)) {
                $count++;
            }
        }

        if ($count == 0) {
            $error += $v;
            $error_line++;
        }
    }
    push(@error_lines, $error_line);
}

print "Part 1: $error\n";

# Part 2.
# Create an empty hash for each column in order.
my %columns;
for my $j (0..scalar(@ticket)-1) {
    $columns{$j} = [ ];
}

# Populate columns into hash.
for my $i (0..scalar(@others)-1) {
    next if ($error_lines[$i]);

    my @values = split(/,/, $others[$i]);

    for my $j (0..scalar(@values)-1) {
        my $v = int($values[$j]);
        push(@{$columns{$j}}, $v)
    }
}

# Figure out mapping.
my %mapping;
my $threshold = sum(map {1 - $_} @error_lines);

while (scalar(keys(%mapping)) < $n_fields) {
    my $target_field;
    my $target_column;

    # Check each column against each field, there has to be one unique mapping.
    for my $i (keys(%columns)) {
        my $xfactor = 0;  # The uniqueness factor (an X-Factor, you might say.)

        for my $j (0..scalar(@fields)-1) {
            my $field = $fields[$j];
            my ($a, $b) = @{$meta{$field.'.lo'}};
            my ($c, $d) = @{$meta{$field.'.hi'}};
            my $field_score = 0;

            # Check how many rows the field satisfy.
            for my $v (@{$columns{$i}}) {
                if (($v >= $a and $v <= $b) or ($v >= $c and $v <= $d)) {
                    $field_score++;
                }
            }

            # The field satisfies all rows, then we increase the x-factor and
            # remember the column and field.
            if ($field_score == $threshold) {
                $xfactor++;
                $target_field = $field;
                $target_column = $i;

                last if $xfactor > 1;  # Break early if not unique.
            }
        }

        # The x-factor has to equal 1 if there is only one field that works
        # works with every row of a column. When we get this, save the mapping
        # and remove the field from the @fields list and remove the column from
        # the %columns hash.
        if ($xfactor == 1) {
            # Add mapping.
            $mapping{$target_field} = $target_column;

            # Remove field.
            my $index = 0;
            $index++ until $fields[$index] eq $target_field;
            splice(@fields, $index, 1);

            # Remove column index.
            delete $columns{$target_column};
        }
    }
}

my $output =
  $ticket[$mapping{"departure location"}] *
  $ticket[$mapping{"departure station"}] *
  $ticket[$mapping{"departure platform"}] *
  $ticket[$mapping{"departure track"}] *
  $ticket[$mapping{"departure date"}] *
  $ticket[$mapping{"departure time"}];

print "Part 2: $output\n";
