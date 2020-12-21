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


##
# Intro.
#
my (%ingredients, %allergens, %appearance, %table);

while (<STDIN>) {
    my $line = $_;
    chomp($line);

    $line =~ /(.*) \(contains (.*)\)/;
    my @ingredients_ = split(/ /, $1);
    my @allergens_ = split(/, /, $2);

    # Count the appearance of an allergen in the food.
    for my $a (@allergens_) {
        $allergens{$a} = 1;  # Keep a set of allergens.
        if (exists($appearance{$a})) {
            $appearance{$a}++;
        } else {
            $appearance{$a} = 1;
        }
    }

    # Count the appearance of an ingredient in the food.
    for my $i (@ingredients_) {
        $ingredients{$i} = 1;  # Keep a set of ingredients.
        if (exists($appearance{$i})) {
            $appearance{$i}++;
        } else {
            $appearance{$i} = 1;
        }
    }

    # Create a table of allergen-ingredient appearances.
    for my $i (@ingredients_) {
        for my $a (@allergens_) {
            if (exists($table{$a}{$i})) {
                $table{$a}{$i}++;
            } else {
                $table{$a}{$i} = 1;
            }
        }
    }
}


##
# Part 1.
#
# Create a list of unsafe ingredients.
my %unsafe;
for my $a (keys(%allergens)) {
    for my $i (keys(%ingredients)) {
        next if !exists($table{$a}{$i});
        if ($table{$a}{$i} == $appearance{$a}) {
            $unsafe{$i} = 1;
        }
    }
}

# Count all other ingredients.
my $count = 0;
for my $i (keys(%ingredients)) {
    next if (exists($unsafe{$i}));
    $count += $appearance{$i};
}
say "Part 1: $count";


##
# Part 2.
#
# Find the unique mapping of allergen to unsafe ingredient by checking the
# number of appearances of the allergen in all food. It should match the count
# in the table exactly once.
my @pairs;
while (keys(%allergens)) {
    for my $a (keys(%allergens)) {
        my $n = $appearance{$a};
        my $match = 0;
        my $match_ingr;

        for my $i (keys(%unsafe)) {
            if ($table{$a}{$i} == $n) {
                $match++;
                $match_ingr = $i;
            }
        }

        # Once mapped, remove that unsafe ingredient to get a reduced table.
        if ($match == 1) {
            push(@pairs, "$a|$match_ingr");  # For sorting later.
            delete $allergens{$a};
            delete $table{$a};
            delete $unsafe{$match_ingr};
        }
    }
}

# Sort based on allergen name and collect ingredients.
my @output;
for my $p (sort(@pairs)) {
    $p =~ /[a-z]+\|([a-z]+)/;
    push(@output, $1);
}
print "Part 2: ", join(',', @output), "\n";
