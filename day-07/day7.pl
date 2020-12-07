#!/usr/bin/perl

# Preamble.
# I need to start commenting code 😅, it's day 7 FFS.
use warnings;
use strict;
use integer;


sub can_contain {
    ##
    # Recursive functions that does WOW 🤩!
    #
    # It's nothing special really, just a recursive function checks if a bag
    # can contain your target bag given the traverse-ty.
    #
    # Args
    # ---
    #     bags (hash): hash containing the bags and what bags they can contain.
    #     current_bag (str): the current bag color being looked at.
    #     target_bag (str): the droid you're looking for.
    #
    # Returns
    # ---
    #     int; basically False if 0, True otherwise.
    #

    my %bags = %{$_[0]};
    my $current_bag = $_[1];
    my $target_bag = $_[2];

    # If we reach our target bag, report true.
    if ($current_bag eq $target_bag) {
        return 1;
    }

    # If we reach a leaf bag, clearly we can't reach our target bag.
    if (!defined($bags{$current_bag})) {
        return 0;
    }

    # Recursive case.
    my $count = 0;
    for my $sub_bag (@{$bags{$current_bag}}) {
        $count += can_contain(\%bags, $sub_bag->{'color'}, $target_bag);
    }
    return $count;
}

sub count_inside {
    ##
    # Recursive functions that does... things 😒
    #
    # Counts how many bags you're smuggling in your target bag given the
    # traverse-ty.
    #
    # Args
    # ---
    #     bags (hash): hash containing the bags and what bags they can contain.
    #     target_bag (str): the target bag color.
    #
    # Returns
    # ---
    #     int; the total number of illegally Russian doll-ed bags.
    #

    my %bags = %{$_[0]};
    my $target_bag = $_[1];

    # Singleton bags don't contain anything.
    if (!defined($bags{$target_bag})) {
        return 0;
    }

    # Check all sub-bags and add the count of the sub-bags plus their sub-bags
    # and so on.
    my $count = 0;
    for my $sub_bag (@{$bags{$target_bag}}) {
        $count += $sub_bag->{'count'} +
                  $sub_bag->{'count'} *
                  count_inside(\%bags, $sub_bag->{'color'});
    }
    return $count;
}


# Intro.
my %bags;

while (<STDIN>) {
    my $line = $_;
    my @sub_bags;

    # CHOMP!
    chomp($line);
    $line =~ /(.*) bags contain (.*)/;
    my $bag = $1;  # Color part.
    my $sub_bags_str = $2;  # Everything else.

    # Make a hash of bags to list of bags which are dict of count and color.
    if ($sub_bags_str eq "no other bags.") {  # Leaf bags.
        $bags{$bag} = undef;
    } else {  # Matryoshka bags.
        for my $bag_str (split(/, /, $sub_bags_str)) {
            $bag_str =~ /([0-9]+) (.*) bag[s]*/;
            my %sub_bag;  # PERL!!! Y U SO NOT TUPLE-FRIENDLY!!!
            $sub_bag{'count'} = $1;
            $sub_bag{'color'} = $2;
            push(@sub_bags, \%sub_bag);  # Push in the pointer to the hash.
        }
        $bags{$bag} = [@sub_bags];
    }
}

# Part 1.
my $ways = 0;

# Loop through all bags and see if it can contain `shiny gold`.
for my $bag (keys(%bags)) {
    $ways += can_contain(\%bags, $bag, 'shiny gold') > 0;
}
# Decrement since we are counting the `shiny gold` bag as being able to
# contain itself, I mean let's be real. *I* can't even contain myself.
print "Part 1: ", --$ways, "\n";


# Part 2.
my $count = count_inside(\%bags, 'shiny gold');
print "Part 2: $count\n";
