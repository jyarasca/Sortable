#!/usr/local/bin/perl

# Sortable Programming Challenge
# Written by Joel Yarascavitch
# September 26, 2013

use warnings;
use strict;
use JSON;

my $products_filename = "products.txt";
my $listings_filename = "listings.txt";
my $output_filename = "output.txt";
my @products;
my @listings;
my $json = JSON->new;

# Push the contents of the PRODUCTS file into an array for each line
open (PRODUCTS, "<:encoding(UTF-8)", $products_filename) 
	or die("Can't open $products_filename: $!\n");
while (<PRODUCTS>) {
	push (@products, $json->decode($_));
}
close (PRODUCTS);

# Push the contents of the LISTINGS file into an array for each line
open (LISTINGS, "<:encoding(UTF-8)", $listings_filename)
	or die("Can't open $listings_filename: $!\n");
while (<LISTINGS>) {
	push (@listings, $json->decode($_));
}
close (LISTINGS);

open (OUTPUT, '> output.txt')
	or die("Can't open $output_filename: $!\n");
binmode(OUTPUT, ":utf8");
foreach my $p_item (@products) {
	my $p_manufacturer = $p_item->{"manufacturer"};
	my $p_model = $p_item->{"model"};
	my %o_item = ();

	# Intialize the output item to contain the "product_name" and a "listings" key (defaulted to NULL)
	# which will be assigned an array of matches from the listings.txt file
	$o_item{"product_name"} = $p_item->{"product_name"};
	$o_item{"listings"} = ();
	foreach my $l_item (@listings) {
		my $l_manufacturer = $l_item->{"manufacturer"};
		my $l_title = $l_item->{"title"};
		# Ensure that either: (case insensitive)
		#   1. Entire product manufacturer matches at start of listing manufacturer
		#   2. Enture listing manufacturer matches at start of product manufacturer
		next if (not(($p_manufacturer =~ m/^\Q$l_manufacturer\E/i) or ($l_manufacturer =~ m/^\Q$p_manufacturer\E/i)));
		# Ensure that the entire (product model) matches 
		# inside the (listing title), case insensitive
		next if ($l_title !~ m/\Q$p_model\E/i);

		# Valid match detected, save to output item, hashed under "listings"
		push (@{$o_item{"listings"}}, $l_item);
	}
	# Save output entry inside the output file
	# Order the JSON data in reverse since it is more convenient to 
	# read the key: "product_name" before "listings"
	print OUTPUT $json->sort_by(sub { $JSON::PP::b cmp $JSON::PP::a })->encode(\%o_item)."\n";
}
close (OUTPUT);
