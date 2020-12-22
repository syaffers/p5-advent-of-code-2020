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

sub recursive_combat {
    ##
    # Play recursive combat given two decks of cards.
    #
    # Need more info? https://adventofcode.com/2020/day/22
    #
    # Args
    # ---
    #     deck1 (list): list of integers representing the deck for player 1.
    #     deck2 (list): list of integers representing the deck for player 2.
    #
    # Returns
    # ---
    #     int: the winner ID.
    #     list: the winner's deck at the end of the game.
    #
    my @deck1 = @{$_[0]};
    my @deck2 = @{$_[1]};
    my $winner;
    my @win_deck;
    my %states;

    while (1) {
        # Player 1 wins if there is a repeated state and add the state. The |
        # is important! Joining the two decks as is can fail.
        my $state = join('', @deck1) . '|' . join('', @deck2);
        return (1, @deck1) if (exists($states{$state}));
        $states{$state} = 0;

        # Draw card.
        my $card1 = shift(@deck1);
        my $card2 = shift(@deck2);

        # Both deck sizes are at least the card values, play a sub-game to
        # determine the winner.
        if ( (scalar(@deck1) >= $card1) and (scalar(@deck2) >= $card2) ) {
            my @subdeck1 = @deck1[0..$card1-1];  # Copy deck 1.
            my @subdeck2 = @deck2[0..$card2-1];  # Copy deck 2.
            my @output = recursive_combat(\@subdeck1, \@subdeck2);
            $winner = shift(@output);
        } else {  # Otherwise, just see who's got the bigger card.
            $winner = ($card1 > $card2) ? 1 : 2;
        }

        # Push the cards accordingly.
        if ($winner == 1) {
            push(@deck1, ($card1, $card2));
        } else {
            push(@deck2, ($card2, $card1));
        }

        # End recursion if you've got no cards left for any player. Winner is
        # the other guy.
        return (2, @deck2) if (scalar(@deck1) == 0);
        return (1, @deck1) if (scalar(@deck2) == 0);
    }

    return ($winner, @win_deck);
}


##
# Intro.
#
my $player = 0;
my (@deck1, @deck2);

while (<STDIN>) {
    my $line = $_;
    chomp($line);

    if ($line =~ /^\d+$/) {
        push(@deck1, int($line)) if $player == 1;
        push(@deck2, int($line)) if $player == 2;
    } elsif ($line =~ /Player (\d):/) {
        $player = int($1);
    }
}


##
# Part 1.
#
my @win_deck;
my @deck1_ = @deck1;
my @deck2_ = @deck2;

# Play. The. Game.
while (1) {
    my $card1 = shift(@deck1_);
    my $card2 = shift(@deck2_);

    if ($card1 > $card2) {
        push(@deck1_, ($card1, $card2));
    } else {
        push(@deck2_, ($card2, $card1));
    }

    if (scalar(@deck1_) == 0) {
        @win_deck = @deck2_;
        last;
    }
    if (scalar(@deck2_) == 0) {
        @win_deck = @deck1_;
        last;
    }
}

my $output = 0;
for my $i (1..scalar(@win_deck)) {
    $output += (scalar(@win_deck - $i + 1)) * $win_deck[$i-1];
}

say "Part 1: $output";


##
# Part 2.
#
@win_deck = recursive_combat(\@deck1, \@deck2);
shift(@win_deck);

$output = 0;
for my $i (1..scalar(@win_deck)) {
    $output += (scalar(@win_deck - $i + 1)) * $win_deck[$i-1];
}

say "Part 2: $output";
