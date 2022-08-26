package NLIB::Object;

#
# $Id: Object.pm,v 1.12 2014-01-05 22:19:52 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-Object">All Classes</a>

=end html

=head1 NAME

NLIB::Object

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::Object (%params);

B<private:>

 $obj->_init(%data);

B<public:>

 DOCSYNOPSIS

=head1 DESCRIPTION

NLIB::Object is the base class of all NLIB Objects.

=cut

=pod

=head1 MEMBERS

=over

=item I<debug := NLIB_DL_NONE>

The OR'ed debug level classes.

=back

=head1 METHODS AND ACCESSORS

=cut


use strict;

use NLIB;
use NLIB::Constants;

=pod

=over

=item B<new(%data)>

The basic constructor for all NLIB classes. The %data params are delegated to the NLIB::Object::_init() method.

=back

=cut
sub new
{
	my $class = shift;
	my $ptr = {};
	bless($ptr, $class);
	$ptr->_init(@_);
	return $ptr;
}

=pod

=over

=item B<_init(%data)>

This basic initialization method is called by the constructor. Override this in your subclassed object to set default object values.

=back

=cut
sub _init
{
	my $obj = shift;
	my %data = @_;

	# The current debug levels
	defined($data{debug}) ? ($obj->{debug} = $data{debug}) : ($obj->{debug} = NLIB_DL_NONE);
}

=pod

=over

=item B<debug($level := DL_NONE,$method := "",$msg := "",$line := 0)>

Prints a formatted debug message to STDERR

=back

=cut
sub  debug
{
	my $obj = shift;

  my $level = shift || 0;
  my $method = shift || "";
  my $msg = shift || "";
	my $line = shift || 0;

	my $out;
	if($msg ne ""){$out = sprintf "[%05d] [%05d] %s::%s: %s\n",$$, $line,ref($obj), $method, $msg;}
	else{ $out = sprintf "[%05d] [%05d] %s::%s\n",$$, $line,ref($obj), $method; }

	if($ENV{NLIB_TESTING}){ return $level;	}


	return if ($level == NLIB_DL_NONE);

  if ( ($level & $obj->{debug}) == NLIB_DL_METHOD){
    printf STDERR "[NLIB_DL_METHOD]      %s", $out;
		return;
  }

  if ( ($level & $obj->{debug}) == NLIB_DL_DEBUG){
    printf STDERR "[NLIB_DL_DEBUG]       %s", $out;
		return;
  }

  if ( ($level & $obj->{debug}) == NLIB_DL_TEMPLATE){
    printf STDERR "[NLIB_DL_TEMPLATE]    %s", $out;
		return;
  }

  if ( ($level & $obj->{debug}) == NLIB_DL_SQL){
    printf STDERR "[NLIB_DL_SQL]         %s", $out;
		return;
  }

  if ( ($level & $obj->{debug}) == NLIB_DL_EXCEPTION){
    printf STDERR "[NLIB_DL_EXCEPTION]   %s", $out;
		return;
  }

  if ( ($level & $obj->{debug}) == NLIB_DL_INSTANCE){
    printf STDERR "[NLIB_DL_INSTANCE]    %s", $out;
		return;
  }

  if ( ($level & $obj->{debug}) == NLIB_DL_VDEBUG){
    printf STDERR "[NLIB_DL_VDEBUG]      %s", $out;
		return;
  }

  if ( ($level & $obj->{debug}) == NLIB_DL_TABLE){
    printf STDERR "[NLIB_DL_TABLE]       %s", $out;
		return;
  }

  if ( ($level & $obj->{debug}) == NLIB_DL_SESSION){
    printf STDERR "[NLIB_DL_SESSION]     %s", $out;
		return;
  }

	# The level to track the biz logic, use user-friendly messages
  if ( ($level & $obj->{debug}) == NLIB_DL_BIZ){
    printf STDERR "[NLIB_DL_BIZ]         %s", $out;
		return;
  }



}

=pod

=over

=item B<stdout>

Prints to stdout with regard to $ENV{NLIB_TESTING} flag. If $ENV{NLIB_TESTING} is defined (likely in tests), instead of the whole output only the string "true" is returned.

=back

=cut
sub  stdout
{
	my $obj = shift;
	$obj->debug(NLIB_DL_VDEBUG,"stdout","",__LINE__);
	my $data = shift;
	if(defined($ENV{NLIB_TESTING})){
		return "true";
	}
	print STDOUT $data;
}



=pod

=over

=item B<setDebuglevel>

Set OR'ed debugging level classes. Have a look at NLIB::Constants(3) for exported debug levels.

=back

=cut
sub  setDebuglevel
{
	my $obj = shift;
	$obj->debug(NLIB_DL_VDEBUG,"setDebuglevel","",__LINE__);
	my $levels = shift;
	$obj->{debug} = $levels;
}

=pod

=over

=item B<debuglevel>

Returns the current debug level as OR'ed integer.

=back

=cut
sub debuglevel
{
	my $obj = shift;
	$obj->debug(NLIB_DL_VDEBUG,"debuglevel","",__LINE__);
	return $obj->{debug};
}








=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;

