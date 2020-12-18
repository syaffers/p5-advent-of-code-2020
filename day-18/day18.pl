#!/usr/bin/perl

# Preamble.
use warnings;
use strict;
use integer;
use List::Util qw(sum);


sub eval_expr {
    ##
    # Evaluate the sacrilegious expression left-to-right, being respectful of
    # parentheses.
    #
    # Args
    # ---
    #     expr (list): the list of symbols to be expressed into a tree.
    #
    # Returns
    # ---
    #     hash: the sacrilegious expression tree.
    #
    my @expr = @{$_[0]};
    my @stack;

    while (@expr) {
        my $c = $expr[0];
        if ($c =~ /\d/) {  # Push number into stack.
            push(@stack, shift(@expr));
        } elsif ($c =~ /[\+\*]/) {  # Op, just push into stack and next.
            push(@stack, shift(@expr));
            next;
        } elsif ($c eq '(') {  # Open paren, solve internal before moving on.
            my $pcount = 0;
            my @in_expr;

            # Extract internal expression.
            do {
                $c = shift(@expr);
                push(@in_expr, $c);
                $pcount++ if $c eq '(';
                $pcount-- if $c eq ')';
            } while ($pcount > 0 or !($c eq ')'));

            # Removing outer parens of the internal expression. Perl just had
            # to have a crap syntax for it.
            @in_expr = @in_expr[1..scalar(@in_expr)-2];
            push(@stack, eval_expr(\@in_expr));
        }

        # We only keep 2 numbers and an op in the stack at any time. Pop,
        # compute and push into stack again.
        if (scalar(@stack) > 1) {
            my $b = pop(@stack);
            my $op = pop(@stack);
            my $a = pop(@stack);
            ($op eq '+') ? push(@stack, $a + $b) : push(@stack, $a * $b);
        }
    }

    return pop(@stack);
}

sub create_tree {
    ##
    # Create the sacrilegious expression tree.
    #
    # Args
    # ---
    #     expr (list): the list of symbols to be expressed into a tree.
    #
    # Returns
    # ---
    #     hash: the sacrilegious expression tree.
    #
    my @expr = @{$_[0]};
    my @stack;

    while (@expr) {
        my $c = $expr[0];
        my %curr;

        if ($c =~ /[\d]/) {  # Singleton tree for a number.
            %curr = ('v' => shift(@expr), 'l' => undef, 'r' => undef);
        } elsif ($c =~ /[\+\*]/) { # Push the op straight in, no node.
            push(@stack, shift(@expr));
            next;
        } elsif ($c eq '(') {  # Open paren, solve internal before moving on.
            my $pcount = 0;
            my @in_expr;

            # Extract internal expression.
            do {
                $c = shift(@expr);
                push(@in_expr, $c);
                $pcount++ if $c eq '(';
                $pcount-- if $c eq ')';
            } while ($pcount > 0 or !($c eq ')'));

            @in_expr = @in_expr[1..scalar(@in_expr)-2];
            %curr = %{create_tree(\@in_expr)};
        }

        # Create a subtree if we see a +, we can wrap up *s later.
        if (scalar(@stack) > 1 and $stack[-1] eq '+') {
            my $op = pop(@stack);
            my $left = pop(@stack);
            my %node = ('v' => $op, 'l' => $left, 'r' => \%curr);
            push(@stack, \%node);
        } else {  # Just push the singleton tree otherwise.
            push(@stack, \%curr);
        }
    }

    # Using shift here since we evaluate from left to right.
    while (scalar(@stack) > 1) {
        my $right = pop(@stack);
        my $op = pop(@stack);
        my $left = pop(@stack);
        my %node = ('v' => $op, 'l' => $left, 'r' => $right);
        push(@stack, \%node);
    }

    return pop(@stack);
}

sub eval_tree {
    ##
    # Evaluate the sacrilegious expression tree.
    #
    # Args
    # ---
    #     tree (hash): the root of the expression tree.
    #
    # Returns
    # ---
    #     int: the output of the sacrilegious expression tree.
    #
    my %root = %{$_[0]};

    if ($root{'v'} =~ /\d+/) {
        return int($root{'v'});
    } else {
        if ($root{'v'} eq '+') {
            return eval_tree($root{'l'}) + eval_tree($root{'r'});
        } else {
            return eval_tree($root{'l'}) * eval_tree($root{'r'});
        }
    }
}


# Intro.
my @lines;

while (<STDIN>) {
    my $line = $_;
    $line =~ s/\s//g;
    push(@lines, $line);
}

# Part 1.
my @values;

for my $line (@lines) {
    my @expr = split(//, $line);
    push(@values, eval_expr(\@expr));
}

print "Part 1: ", sum(@values), "\n";

# Part 2.
undef @values;

for my $line (@lines) {
    my @expr = split(//, $line);
    my $tree = create_tree(\@expr);
    push(@values, eval_tree($tree));
}

print "Part 2: ", sum(@values), "\n";
