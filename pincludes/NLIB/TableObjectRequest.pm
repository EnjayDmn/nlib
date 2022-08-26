package NLIB::TableObjectRequest;

#
# $Id: TableObjectRequest.pm,v 1.3 2014-02-04 23:05:46 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-TableObjectRequest">All Classes</a>

=end html

=head1 NAME

NLIB::TableObjectRequest

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::TableObjectRequest (%params);

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
use MIME::Base64;

use vars qw(@ISA);
@ISA = qw(NLIB::TableObject);

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

	# We need to init the table before the super constructor
	$data{table} = "nlib_requests";
	$obj->SUPER::_init(%data);

	# Here we store the given request data as from-json-decoded hash ref
  defined($data{request_data}) ? ($obj->{request_data} = $data{request_data}) : ($obj->{request_data} = undef);
}


=pod

=over

=item B<getRequestData($requestData)>

Retrieves internal decoded request data into OUT parameter $requestData as hash reference.

=back

=cut
sub getRequestData
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getRequestData","",__LINE__);
	my $requestData = shift;
	$$requestData = $obj->{request_data};
}

=pod

=over

=item B<setRequestData($requestData)>

Stores given request data. Param requestData must be a from-json-decoded hash reference (IN-Parameter).

=back

=cut
sub setRequestData
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"setRequestData","",__LINE__);
	my $requestData = shift;

	$obj->{request_data} = $requestData;
	$obj->debug(NLIB_DL_DEBUG,"setRequestData",$obj->{request_data}->{username},__LINE__);

}


=pod

=over

=item B<encodeRequest>



=back

=cut
sub encodeRequest
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"encodeRequest","",__LINE__);

	my $namEncrypted = $obj->aesEncrypt($obj->getset("req_value"),$obj->getKeyAction());
	chomp($namEncrypted);
	chop($namEncrypted);
		
	my $namEncoded = encode_base64($namEncrypted);
	chomp ($namEncoded);
	$namEncoded =~ s/=*$//;

	return $namEncoded;

}



=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
