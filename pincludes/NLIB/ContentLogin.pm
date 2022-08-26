package NLIB::ContentLogin;

#
# $Id: ContentLogin.pm,v 1.2 2014-01-31 18:01:01 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-ContentLogin">All Classes</a>

=end html

=head1 NAME

NLIB::ContentLogin

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::ContentLogin (%params);

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
use NLIB::TableObjectUser;

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

	my $requestData;
	$obj->getApp()->getDispatcher()->getRequest()->getRequestData(\$requestData);
	$obj->debug(NLIB_DL_DEBUG,"doContent","Request Data: ".$requestData->{username},__LINE__);

	unless(defined($requestData->{username}) && defined ($requestData->{password})){
		# Exception: wrong request parameter structure.
		my $e = new NLIB::Exception(etype => NLIB_EXCEPTION_TYPE_WRONG_REQUEST_PARAMETER_STRUCTURE, error => "Wrong request parameter structure.", app => $obj->getApp());
		$e->raiseException();
	}

	# find user and compare password
	my $toUser = new NLIB::TableObjectUser(col => ["uname", $requestData->{username}], app => $obj->getApp(), create => 0);

	my %json;
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
