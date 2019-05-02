#!/usr/bin/perl

my ($id, $req) = ($ARGV[0], $ARGV[1]);

use LWP::UserAgent;
use Mojo::DOM;
use JSON::XS;
use Data::Dumper;

sub agent { return LWP::UserAgent->new('agent','perl') }
sub stream { return agent->get(shift)->decoded_content }
sub mirror { agent->mirror(shift, shift) }

sub load {
	my ($local, $remote) = @_;
	if( ! -e "$local" || time() - (stat "$local")[9] > 86400 ) {
		mirror "$remote", "$local";
	}
	open FILE, "<$local";
	$DOM = Mojo::DOM->new(join('',<FILE>));
	close FILE;
	return $DOM;
}

my $result = (load "cache/$id", "$req");
my @props = grep {$_} map {
	$a = $_->attr('property');
	if( ! $a ) { $a = $_->attr('name') }
	if( ! $a ) {0}

	$b = $_->attr('content');
	if( ! $b ) { $b = $_->attr('value') }
	if( ! $b ) {0}

	[ $a, $b ];
} $result->find('head meta')->each;

print Dumper(@props);

