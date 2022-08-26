package NLIB::Cgi;

#
# $Id: Cgi.pm,v 1.7 2013-12-17 14:08:41 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-Cgi">All Classes</a>

=end html

=head1 NAME

NLIB::Cgi

=head1 SYNOPSIS

B<construction:>

 my $app = new NLIB::Cgi (%params);
 $app->run();

B<private:>

 $obj->_init(%data);

B<public:>

 DOCSYNOPSIS

=head1 DESCRIPTION

NLIB::Cgi provides means to communicate with the Common Gateway Interface.

=cut

=pod

=head1 MEMBERS

=over

=item I<cgi>

The CGI object.

=back

=head1 METHODS AND ACCESSORS

=cut

use strict;
use CGI;

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
  defined($data{cgi}) ? ($obj->{cgi} = $data{cgi}) : ($obj->{cgi} = new CGI);

	# Internal cookie jar to store cookies during application flow.
  defined($data{cookiejar}) ? ($obj->{cookiejar} = $data{cookiejar}) : ($obj->{cookiejar} = {});
	
}

=pod

=over

=item B<getParamStr($param)>

Returns the value from the list of params

=back

=cut
sub  getParamStr
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getParamStr","",__LINE__);
	my $param = shift;
	return $obj->getCgi()->param($param);
}



=pod

=over

=item B<setParam($param,$value)>

Set $param to $value.

=back

=cut
sub  setParam
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"setParam","",__LINE__);
	my $p = shift;
	my $v = shift;
	$obj->getCgi()->param($p => $v);
}




=pod 

=over

=item B<getCgi>

Returns the CGI object.

=back

=cut
sub getCgi
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getCgi","",__LINE__);
	return $obj->{cgi};
}


=pod

=over

=item B<getCgiCookie($cnam)>

Returns the cookie value of the cookie $cnam from CGI Environment.

=back

=cut
sub  getCgiCookie
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getCgiCookie","",__LINE__);
	my $cnam = shift;
	return $obj->getCgi()->cookie($cnam);
}





=pod

=over

=item B<getCookieJarCookie($cnam)>

Return cookie $cnam from cookie jar. 

=back

=cut
sub  getCookieJarCookie
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getCookieJarCookie","",__LINE__);
	my $cnam = shift;
	return $obj->{cookiejar}->{$cnam};
}


=pod

=over

=item B<setCookieJarCookie($cnam,$cval)>

Puts cookie $cnam with value $cval into cookie jar. Any cookie in cookie jar will be put out during final rendering process. See NLIB::Page::renderPage(3).

=back

=cut
sub  setCookieJarCookie
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"setCookieJarCookie","",__LINE__);
	my $cnam = shift;
	my $cval = shift;
	$obj->{cookiejar}->{$cnam} = $cval;
}




=pod

=over

=item B<getCookieJar>

Returns the cookie jar as a hash reference.

=back

=cut
sub getCookieJar
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getCookieJar","",__LINE__);
	return $obj->{cookiejar};
}



=pod

=over

=item B<getRemoteHost>

Returns the reote host source ip.

=back

=cut
sub getRemoteHost
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getRemoteHost","",__LINE__);

	$obj->{cgi}->remote_host();
}



=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
