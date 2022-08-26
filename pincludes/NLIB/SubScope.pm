package NLIB::SubScope;

#
# $Id: SubScope.pm,v 1.9 2014-02-27 16:18:20 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-SubScope">All Classes</a>

=end html

=head1 NAME

NLIB::SubScope

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::SubScope (%params);

B<private:>

 $obj->_init(%data);

B<public:>

 DOCSYNOPSIS

=head1 DESCRIPTION

NLIB::SubScope is the base class for all sub scope classes. Sub scope classes reside on the same level as scope classes do, but define a special interface. For instance, all sub scope classes aggregate the NLIB::Application scope class.

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
use CGI;
use Digest::SHA1  qw(sha1 sha1_hex sha1_base64);
use Crypt::AES::CTR;

use NLIB;
use NLIB::Constants;

use vars qw(@ISA);
@ISA = qw(NLIB::Object);

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

	# AGGREGATES
  defined($data{app}) ? ($obj->{app} = $data{app}) : ($obj->{app} = undef);
	unless(defined($obj->{app})){return undef;}

	# Set debuglevel through app
	$obj->setDebuglevel($obj->getApp()->debuglevel());
	
}


=pod

=over

=item B<save>

Save anything that needs to be saved. Override in subclass as necessary.

=back

=cut
sub save
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"save","",__LINE__);
}


=pod

=over

=item B<getApp>

Returns the application object.

=back

=cut
sub getApp
{
	my $obj = shift;
	$obj->debug(NLIB_DL_VDEBUG,"getApp","",__LINE__);
	return $obj->{app};
}

=pod

=over

=item B<getSha1B64>

Returns a random sha1 string.

=back

=cut
sub getSha1B64
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getSha1B64","",__LINE__);
	my $z = rand(scalar(localtime()));
	$z =~ s/.*\.//;
	return sha1_base64($z);
}


=pod

=over

=item B<aesEncrypt($message, $key)>

Encrypts the message $message with the given key $key.

Returns the aes-encrypted message.

=back

=cut
sub aesEncrypt
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"aesEncrypt","",__LINE__);
	my $message = shift;
	my $key = shift;
	return Crypt::AES::CTR::encrypt($message,$key,256);
}

=pod

=over

=item B<aesDecrypt>

Decrytps aes encrypted $aes string with $key.

Returns the decrypted message.

=back

=cut
sub aesDecrypt
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"aesDecrypt","",__LINE__);
	my $aes = shift;
	my $key = shift;
	return Crypt::AES::CTR::decrypt($aes,$key,256);
}


=pod

=over

=item B<getNow>

Returns a NOW string that can be used for DATETIME fields in db.

=back

=cut
sub getNow
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getNow","",__LINE__);
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  my $now = sprintf("%s-%02s-%02s %s:%s:%s",($year+1900),($mon+1),$mday,$hour,$min,$sec);

	return $now;
}





=pod

=over

=item B<getKeyMaster>

Returns the master key from db

=back

=cut
sub  getKeyMaster
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getKeyMaster","",__LINE__);
	my $selKeyMaster = "select reg_value from nlib_environment where reg_key = 'key_master' limit 1";
	my $sthKeyMaster = $obj->getApp->getDbc()->querySth($selKeyMaster);
	if($sthKeyMaster->rows){
		my $refKeyMaster = $sthKeyMaster->fetchrow_arrayref();
		return $refKeyMaster->[0];
	}
	return undef;
}






=pod

=over

=item B<getKeyAction>

Returns the action key from db

=back

=cut
sub  getKeyAction
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getKeyAction","",__LINE__);
	my $selKeyA = "select reg_value from nlib_environment where reg_key = 'key_action' limit 1";
	my $sthKeyA = $obj->getApp->getDbc()->querySth($selKeyA);
	if($sthKeyA->rows){
		my $refKeyA = $sthKeyA->fetchrow_arrayref();
		return $refKeyA->[0];
	}
	return undef;
}






=pod

=over

=item B<quote>

Quotes an unquoted string.

=back

=cut
sub quote
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"quote","",__LINE__);
	my $inp = shift;
	$inp =~ s/\\/\\\\/g;
	$inp =~ s/\'/\\\'/g;
	$inp =~ s/\"/\\\"/g;
	$inp =~ s/\(/\\\(/g;
	$inp =~ s/\)/\\\)/g;
	return $inp;
}





=pod

=over

=item B<querySth>



=back

=cut
sub  querySth
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"querySth","",__LINE__);
	my $query = shift;
	return $obj->getApp->getDbc()->querySth($query);
}


=pod

=over

=item B<do>



=back

=cut
sub  do
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"do","",__LINE__);
	my $query = shift;
	return $obj->getApp->getDbc()->do($query);
}








=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
