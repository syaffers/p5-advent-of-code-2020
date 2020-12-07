#!/usr/bin/perl

# Preamble.
use strict;
use warnings;
use integer;


sub print_hash {
    my %hash = %{$_[0]};

    print "{\n";
    while ((my $key, my $value) = each %hash) {
        print "\t$key: $value,\n";
    }
    print "}\n";
}

sub check_fields {
    my @REQ_FIELDS = qw(byr iyr eyr hgt hcl ecl pid);
    my %passport = %{$_[0]};
    my $fields_exist = 1;

    for my $field (@REQ_FIELDS) {
        $fields_exist &= exists($passport{$field});
    }

    return $fields_exist;
}

sub validate_fields {
    my %passport = %{$_[0]};
    my $is_valid = 1;

    while ((my $field, my $value) = each %passport) {
        if ($field eq "byr") {
            $is_valid &= $value =~ /^(19[2-9][0-9]|200[0-2])$/;
        } elsif ($field eq "iyr") {
            $is_valid &= $value =~ /^(201[0-9]|2020)$/;
        } elsif ($field eq "eyr") {
            $is_valid &= $value =~ /^(202[0-9]|2030)$/;
        } elsif ($field eq "hgt") {
            $is_valid &= $value =~ /^((1[5-8][0-9]|19[0-3])cm|(59|6[0-9]|7[0-6])in)$/;
        } elsif ($field eq "hcl") {
            $is_valid &= $value =~ /^#[0-9a-f]{6}$/;
        } elsif ($field eq "ecl") {
            $is_valid &= $value =~ /^(amb|blu|brn|gry|grn|hzl|oth)$/;
        } elsif ($field eq "pid") {
            $is_valid &= $value =~ /^[0-9]{9}$/;
        }
    }

    return $is_valid;
}

# Intro.
my @passports;
my %passport;
my $fields_pass = 0;
my $valids_pass = 0;

while (<STDIN>) {
    my $line = $_;

    if ($line eq "\n") {
        my $is_field_valid = check_fields(\%passport);
        $fields_pass += $is_field_valid;
        $valids_pass += ($is_field_valid and validate_fields(\%passport));
        undef(%passport);
    } else {
        chomp($line);
        for my $token (split(/ /, $line)) {
            $token =~ /([a-z]{3}):(.*)/;
            $passport{$1} = $2;
        }
    }
}

my $is_field_valid = check_fields(\%passport);
$fields_pass += $is_field_valid;
$valids_pass += ($is_field_valid and validate_fields(\%passport));

# Part 1.
print "Part 1: $fields_pass\n";

# Part 2.

print "Part 2: $valids_pass\n";
