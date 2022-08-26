package NLIB::Page;

#
# $Id: Page.pm,v 1.6 2014-01-05 22:19:52 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-Page">All Classes</a>

=end html

=head1 NAME

NLIB::Page

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::Page (%params);

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
@ISA = qw(NLIB::SubScope);

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

	# A page needs a template, we default to 'nlibMainTemplate'
	defined($data{tpl}) ? ($obj->{tpl} = $data{tpl}) : ($obj->{tpl} = "nlibMainTemplate");

	# Where the template data is stored after loading
	defined($data{tpldata}) ? ($obj->{tpldata} = $data{tpldata}) : ($obj->{tpldata} = undef);

	# This is the container for the split template. Actually a reference to a list.
	defined($data{parts}) ? ($obj->{parts} = $data{parts}) : ($obj->{parts} = undef);

}


=pod

=over

=item B<loadTemplate>

Loads the base template used for final rendering the output. 

=back

=cut
sub loadTemplate
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"loadTemplate","",__LINE__);
	
	my $tpl = new NLIB::Template(tpl => $obj->{tpl}, debug => $obj->debuglevel(),tpldir => NLIB_TEMPLATE_DIR);
	$obj->{tpldata} = $tpl->get();
}


=pod

=over

=item B<splitTemplate>

Split the template.

=back

=cut
sub splitTemplate
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"splitTemplate","",__LINE__);
	my @parts = split /\+\+\+/,$obj->{tpldata};
	$obj->{parts} = \@parts;
}



=pod

=over

=item B<connectContent ($tag, $contentRef)>

Connects the tag $tag to the content of the WebContent object defined by $contentRef.

=back

=cut
sub connectContent
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"connectContent","",__LINE__);
	my $tag = shift;
	my $contentRef = shift;
	my $x = "";	
	$obj->debug(NLIB_DL_DEBUG,"connectContent","Connecting ".(( $x = ref($contentRef)) ne "" ? $x : "SOMEDATA")." to tag '".$tag."'",__LINE__);
	$obj->{content}->{$tag} = $contentRef;
}




=pod

=over

=item B<renderPage>

=back

=cut
sub renderPage
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"renderPage","",__LINE__);
	$obj->debug(NLIB_DL_BIZ,"renderPage","Begin rendering connected data.",__LINE__);

	$obj->stdout($obj->header());

	foreach my $part(@{$obj->{parts}}){
		if ( defined $obj->{content}->{$part}){
			#$obj->debug(NLIB_DL_DEBUG,"renderPage",ref($obj->{content}->{$part}),__LINE__);
			if( ref($obj->{content}->{$part}) =~ m/.*Content.*/g){
				$obj->{content}->{$part}->doContent();
			} else {
				$obj->stdout($obj->{content}->{$part});
			}
		} else {
			$obj->stdout($part);
		}
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
	
	return $ncgi->getCgi()->header(-charset => 'utf-8', -cache_control => 'no-cache', -cookie => \@listOfCookies);

}





=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
