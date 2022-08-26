package NLIB::ContentLogout;

#
# $Id: ContentLogout.pm,v 1.2 2014-01-31 18:01:01 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-ContentLogout">All Classes</a>

=end html

=head1 NAME

NLIB::ContentLogout

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::ContentLogout (%params);

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

	my $selListOfActions = "select * from nlib_requests where req_name='logout'";
	my $sthListOfActions = $obj->getApp()->getDbc()->querySth($selListOfActions);
	my $content = "";
	my %json;

	while(my $refListOfActions = $sthListOfActions->fetchrow_arrayref()){
		my $namEncrypted = $obj->aesEncrypt($refListOfActions->[3],$obj->getKeyAction());
		chomp($namEncrypted);
		chop($namEncrypted);
		
		my $namEncoded = encode_base64($namEncrypted);
		chomp ($namEncoded);
		$namEncoded =~ s/=*$//;

		my $valEncoded = encode_base64($refListOfActions->[4]);
		chomp ($valEncoded);
		$valEncoded =~ s/=*$//;

		push @{$json{followUp}}, [$namEncoded, $valEncoded];
		$json{status} = "OK";
		$json{running} = 1;

	}

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
