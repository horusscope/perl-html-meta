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
sub props {
	grep {$_} map {
		$a = $_->attr('property');
		if( ! $a ) {$a = $_->attr('name')}
		if( ! $a ) {0}

		$b = $_->attr('content');
		if( ! $b ) {$b = $_->attr('value')}
		if( ! $b ) {0}
		
		[$a, $b];
	} shift->each;
}
sub card {
	my $dom = shift;
	my ($meta, $link, $script) =	( $dom->find('head meta')
					, $dom->find('head link')
					, $dom->find('head script') );
	
	my @propMeta = props($meta);
	@title = grep { $_->[0] =~ /^(title|og:title|twitter:title)$/ } @propMeta;
	@desc = grep { $_->[0] =~ /^(description|og:description|twitter:description)$/ } @propMeta;
	@image = grep { $_->[0] =~ /^(image|og:image|twitter:image|twitter:image:src)$/ } @propMeta;
	@alt = grep { $_->[0] =~ /^(alt|og:alt|twitter:image:alt)$/ } @propMeta;
	@siteName = grep { $_->[0] =~ /^(site_name|og:site_name|twitter:site_name)$/ } @propMeta;
	@site = grep { $_->[0] =~ /^(site|og:site|twitter:site)$/ } @propMeta;
	@type = grep { $_->[0] =~ /^(type|og:type|twitter:type)$/ } @propMeta;
	@author = grep { $_->[0] =~ /^(creator|author|og:creator|twitter:creator|og:author|twitter:author)$/ } @propMeta;
	( 'title' => @title? $title[0][1]: ''
	, 'description' => @desc? $desc[0][1]: ''
	, 'image' => @image? $image[0][1]: ''
	, 'alt' => @alt? $alt[0][1]: ''
	, 'site_name' => @siteName? $siteName[0][1]: ''
	, 'site' => @site? $site[0][1]: ''
	, 'type' => @type? $type[0][1]: ''
	, 'author' => @author? $author[0][1]: ''
	);
}
%meta = card $result;
$json = JSON::XS->new->canonical->pretty->encode(\%meta);
print $json;

