package NLIB::JsonPage;

#
# $Id: JsonPage.pm,v 1.3 2014-01-31 18:01:02 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-JsonPage">All Classes</a>

=end html

=head1 NAME

NLIB::JsonPage

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::JsonPage (%params);

B<private:>

 $obj->_init(%data);

B<public:>

 DOCSYNOPSIS

=head1 DESCRIPTION



=cut

=pod

=head1 MEMBERS

=over

=back

=head1 METHODS AND ACCESSORS

=cut

use strict;

use NLIB;
use NLIB::Constants;

use vars qw(@ISA);
@ISA = qw(NLIB::Page);

=pod

=over

=item B<_init(%data)>

This is the default initializer which is called by the constructor.

See section MEMBERS to get a list which memebers are defined for the application.

=back

=cut
sub _init
{
	my $obj = shift;
	my %data = @_;
	$obj->SUPER::_init(%data);

	# A JSON page needs no template and works with the single tag JSON only.

}



=pod

=over

=item B<renderPage>

Renders content connected to the JSON tag. 

=back

=cut
sub renderPage
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"renderPage","",__LINE__);
	$obj->debug(NLIB_DL_BIZ,"renderPage","Begin rendering connected data.",__LINE__);

	$obj->stdout($obj->header());
	if(ref($obj->{content}->{JSON}) ne ""){
		$obj->stdout($obj->{content}->{JSON}->doContent());
	}
	else{
		$obj->stdout($obj->{content}->{JSON});
	}

	$obj->debug(NLIB_DL_BIZ,"renderPage","Finished rendering connected data.",__LINE__);
}




=pod

=over

=item B<header>

=back

=cut
sub header
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"header","",__LINE__);
	
	# building the list of cookies to output
	my @listOfCookies;
	
	my $ncgi = $obj->getApp()->getCgi();
	my $cj = $ncgi->getCookieJar();
	foreach my $ck (keys %{$cj}){
		$obj->debug(NLIB_DL_DEBUG,"header","Cookie key: $ck, value: ".$cj->{$ck},__LINE__);
		
#		# handle persistent cookies
		my $expires = "";
#		if($ck ne "__uname" && $ck ne "__sid"){
#			$expires = "+5y";
#		}
		my $coo;
		
		if($ck eq "__nlscs" && $cj->{$ck} eq ""){
			$coo = CGI::cookie(-name => $ck, -value => $cj->{$ck}, -expires => "-1d", -path => "/");
		}
		else{
			$coo = CGI::cookie(-name => $ck, -value => $cj->{$ck}, -expires => $expires, -path => "/");
		}

		push @listOfCookies, $coo;
	}
	
	return $ncgi->getCgi()->header(-type => "application/json", -charset => 'utf-8', -cache_control => 'no-cache', -cookie => \@listOfCookies);

}





=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
