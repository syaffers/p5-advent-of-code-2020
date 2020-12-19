#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use integer;


sub rule2regex {
    ##
    # Recursively convert the rules into a superegex.
    #
    # Args
    # ---
    #     rules (hash): the set of rule IDs and their respective rule.
    #     id (int): the rule ID to start from.
    #     depth (int): the recursion depth to evaluate cyclic rules. Set to -1
    #         to disable this (hack for part 1, mainly).
    #
    # Returns
    # ---
    #     string: the superegex.
    #
    my %rules = %{$_[0]};
    my ($id, $depth) = @_[1..2];
    my ($regex, $add_parens) = ('', 0);  # Init regex and flag to add parens.
    my $rule = $rules{$id};

    return $rule if ($rule =~ /(a|b)/);  # Stop at leaf rules.

    # Stop cyclic recursions when we reach depth 0. Top stop the recursion, we
    # remove the right side of the rule which contains the recursive ID.
    if (($depth == 0) and ($id =~ /(8|11)/)) {
        my @parts = split(/ \| /, $rule);
        $rule = shift(@parts);
    }

    # Loop through each sub rules and form a regex as needed.
    for my $subid (split(/ /, $rule)) {
        if ($subid eq '|') {
            # Add the option regex character.
            $regex .= '|';
            # Flag to add parenthesis surrounding the current regex.
            $add_parens++;
        } else {
            # Decrement the depth of recursion for sub rules which are the same
            # as the current rule ID.
            $depth-- if ($id eq $subid);
            # Recurse for sub rules and append into the final regex.
            $regex .= rule2regex(\%rules, $subid, $depth);
        }
    }

    $regex = "($regex)" if $add_parens;
    return $regex;
}


# Intro.
my @cases;
my %rules;

while (<STDIN>) {
    my $line = $_;
    chomp($line);

    # Add the rules as is, removing quotes for leaf rules.
    if ($line =~ /(\d+): (.*)/) {
        my $id = $1;
        my $rule = $2;
        if ($rule =~ /"(a|b)"/) {
            $rules{$id} = $1
        } else {
            $rules{$id} = $rule;
        }
    } else {
        push(@cases, $line);
    }
}


# Part 1.
my $count = 0;
my $regex = rule2regex(\%rules, '0', -1);
for my $case (@cases) {
    $count++ if ($case =~ /^$regex$/);
}

print "Part 1: $count\n";


# Part 2.
my ($max_count, $depth) = (0, 0);
$rules{'8'} = '42 | 42 8';
$rules{'11'} = '42 31 | 42 11 31';

# Loop until we don't have any change in the number of matches. Probably a bad
# thing to do if there were longer cases that matched later but it works.
while (1) {
    $count = 0;
    $regex = rule2regex(\%rules, '0', $depth++);
    for my $case (@cases) {
        $count++ if ($case =~ /^$regex$/);
    }

    ($count > $max_count) ? $max_count = $count : last;
}

print "Part 2: $count\n";
