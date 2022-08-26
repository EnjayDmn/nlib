package NLIB::ContentWidgetState;

#
# $Id: ContentWidgetState.pm,v 1.1 2014-01-31 18:01:02 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-ContentWidgetState">All Classes</a>

=end html

=head1 NAME

NLIB::ContentWidgetState

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::ContentWidgetState (%params);

B<private:>

 $obj->_init(%data);

B<public:>

 DOCSYNOPSIS

=head1 DESCRIPTION



=cut

=pod

=head1 MEMBERS

=over

=item I<app>

The Applicaiton instance.

=back

=head1 METHODS AND ACCESSORS

=cut

use strict;

use NLIB;
use NLIB::Constants;

use vars qw(@ISA);
@ISA = qw(NLIB::Content);

use URI::Escape;
use MIME::Base64;
use JSON;



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

}

=pod

=over

=item B<doContent>

Sets up the content according to the specific action request. This is the main callback from within NLIB::Page::renderPage(3).

=back

=cut
sub  doContent
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"doContent","",__LINE__);

	my $session = $obj->getApp()->getSession();

	my %json;

	# defaults

	if($session->isPersonal())
	{
		# 
		$obj->debug(NLIB_DL_DEBUG,"doContent","Session is personal. Building JSON answer for user XYZ ",__LINE__);

	}
	else
	{
		# default anonymous view (for ex. login screen)
		$obj->debug(NLIB_DL_DEBUG,"doContent","Session is anonymous. Building JSON answer.",__LINE__);
		
		# Query could be more sophisticated. One should query the follow up table
		# for a defined widget instead of a single defined action
		my $selListOfFollowUps = "select * from nlib_requests where req_name='login'";
		my $sthListOfFollowUps = $obj->getApp()->getDbc()->querySth($selListOfFollowUps);

		my @followUps;
		while(my $refListOfFollowUps = $sthListOfFollowUps->fetchrow_arrayref()){
	
			# Encrypt the request
			my $namEncrypted = $obj->aesEncrypt($refListOfFollowUps->[3],$obj->getKeyAction());
			chomp($namEncrypted);
			chop($namEncrypted);
		
			# Encode the request
			my $namEncoded = encode_base64($namEncrypted);
			chomp ($namEncoded);
			$namEncoded =~ s/=*$//;

			push @followUps, $namEncoded;
			push @{$json{widgets}}, {widgetName => "Login", followUp => \@followUps}
		}
		push @{$json{widgets}}, {widgetName => "AnotherWidget", followUp => ["hi","ho"]}
	}

	$json{status} = "OK";
	$json{running} = 1;

	my $jsonStr = encode_json(\%json);
	return $jsonStr;

}


=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
