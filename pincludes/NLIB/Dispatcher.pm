package NLIB::Dispatcher;

#
# $Id: Dispatcher.pm,v 1.10 2014-01-31 18:01:02 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-Dispatcher">All Classes</a>

=end html

=head1 NAME

NLIB::Dispatcher

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::Dispatcher (%params);

B<private:>

 $obj->_init(%data);

B<public:>

 DOCSYNOPSIS

=head1 DESCRIPTION

NLIB::Dispatcher represents a default dispatcher type. This object is meant to be an interface for inherited objects.

The NLIB::Dispatcher dispatcher implements the methods setPrerequisites and dispatchRequest.

See NLIB::Constants(3), section SESSION FLAVOURS for other available session flavour types. 

Do not use this object directly. Instead, inherit from one of the other NLIB::*Dispatcher classes as needed and implement your own kind of dispatch method.

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
use URI::Escape;
use MIME::Base64;
use JSON;
no warnings FATAL => qw(all);

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

	# The reference to the request table object
  defined($data{request}) ? ($obj->{request} = $data{request}) : ($obj->{request} = undef);
	
}



=pod

=over

=item B<getRequest>



=back

=cut
sub getRequest
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getRequest","",__LINE__);
	
	return $obj->{request};

}




=pod

=over

=item B<requestType>

Get or set the requestType attribute.

=back

=cut
sub requestType
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"requestType","",__LINE__);
	my $type = shift;
	defined($type) ? $obj->{request_type} = $type : ();
	return $obj->{request_type};
}




=pod

=over

=item B<setPrerequisites>

This method is meant to set necessary prerequisites.

=back

=cut
sub  setPrerequisites
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"setPrerequisites","",__LINE__);
	my %prereqs = @_;

}





=pod

=over

=item B<dispatchRequest>

Dispatches the current request. TODO: Inherit and implement your own handler.

=back

=cut
sub  dispatchRequest
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"dispatchRequest","",__LINE__);

	# do the default for now...
	$obj->default();
	
}


=pod

=over

=item B<parseRequest>

Parses the request from query string. All requests are expected to have a single parameter and a single value in the form of 

C<name=value>

If the query string has no parameter or no value or more than exact one parameter this is considered as a B<wrong> kind of request and will lead to the default behaviour (which likely might be a logout).

The I<name> part has the format:

C<$encName = base64_encrypt(aes_encrypt(nlib_requests.req_value, nlib_environment.reg_value(key_action)));>

To get the real value of the name part, do the following:

C<$plainName = base64_decrypt(aes_decrypt($encName, nlib_environment.reg_value(key_action)));>

$PlainName should evaluate to one of the values of the nlib_requests.req_value column, i.e. something like this: 

C<VdT7Q9230g4ZFfFqa6htP8Amu0I>

The I<value> part has the format:

C<$encValue = base64_encrypt(nlib_requests.req_json);>

To get the real value of the value part, do the following:

C<$plainValue = base64_decrypt($encValue);>

$PlainName should evaluate to one of the values of the nlib_requests.req_json column, i.e. something like this: 

C<{"id_document":"0","document_data":""}> 

with the appropriate values set.

=back

=cut
sub  parseRequest
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"parseRequest","",__LINE__);

	my $cgi =  $obj->getApp()->getCgi()->getCgi();
	my @params = $cgi->param();
	
	unless(@params)
	{
		$obj->debug(NLIB_DL_DEBUG,"parseRequest","No params. Returning undef to proceed with session flavour default.",__LINE__);
		return undef;
	}
	
	my $lparams = @params;
	unless($lparams == 1)
	{
		$obj->debug(NLIB_DL_DEBUG,"parseRequest","Wrong number of params: $lparams. Returning undef to proceed with session flavour default.",__LINE__);
		return undef;
	}
	
	# Decode name and value as described.

	$obj->debug(NLIB_DL_DEBUG,"parseRequest","PARAMS: ".(join(",",@params)),__LINE__);
	
	my $p = $params[0];
	my $namEncoded = $params[0];

	my $valEncoded = $cgi->param($namEncoded);
	
	# Decode value
	$obj->debug(NLIB_DL_DEBUG,"parseRequest","valEncoded: ".$valEncoded,__LINE__);
	my $valPlain = decode_base64($valEncoded);
	$obj->debug(NLIB_DL_DEBUG,"parseRequest","valPlain: ".$valPlain,__LINE__);
	my $decodedJSON = decode_json($valPlain);
	$obj->debug(NLIB_DL_DEBUG,"parseRequest","decodedJSON: ".$decodedJSON->{username},__LINE__);
	
	# Decode and decrypt name
	$obj->debug(NLIB_DL_DEBUG,"parseRequest","namEncoded: ".$namEncoded,__LINE__);
	my $namEncrypted = decode_base64($namEncoded."=");
	$obj->debug(NLIB_DL_DEBUG,"parseRequest","namEncrypted: ".$namEncrypted,__LINE__);

	my $namDecrypted = $obj->aesDecrypt($namEncrypted,$obj->getKeyAction());
	if($namDecrypted eq ""){
		$obj->debug(NLIB_DL_DEBUG,"parseRequest","Unable to decrypt request. Returning undef to proceed with session flavour default.",__LINE__);
		return undef;
	}	

	my $toRequest = new NLIB::TableObjectRequest(col => ["req_value",$namDecrypted],app=>$obj->getApp());
	$toRequest->setRequestData($decodedJSON);
	
	$obj->{request} = $toRequest;
	$obj->debug(NLIB_DL_DEBUG,"parseRequest","Returning request table object with id: ".$obj->{request}->getId()." (".$obj->{request}->getset("req_name").")",__LINE__);
	# maybe return the request id?
	return $obj->{request};
}



=pod

=over

=item B<default>

The default action to perform instead of dispatching anything.

=back

=cut
sub  default
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"default","",__LINE__);

}















=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
