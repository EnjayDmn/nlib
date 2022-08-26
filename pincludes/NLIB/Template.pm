package NLIB::Template;

#
# $Id: Template.pm,v 1.4 2014-01-31 18:01:03 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-Template">All Classes</a>

=end html

=head1 NAME

NLIB::Template

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::Template (%params);

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
use NLIB::Exception;

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

	defined($data{tpldir}) ? ($obj->{tpldir} = $data{tpldir}) : ($obj->{tpldir} = NLIB_TEMPLATE_DIR);
	defined($data{tplext}) ? ($obj->{tplext} = $data{tplext}) : ($obj->{tplext} = NLIB_TEMPLATE_EXT );
	
	# The template file
	defined($data{tpl}) ? ($obj->{tpl} = $data{tpl}) : ($obj->{tpl} = NLIB_TEMPLATE_DFLT );
	
	# The loaded template data
	defined($data{tpldata}) ? ($obj->{tpldata} = $data{tpldata}) : ($obj->{tpldata} = undef );

	# Directly load the wanted template
	$obj->loadTpl();	
}


=pod

=over

=item B<loadTpl>

Loads the template as defined in the constructor and stores the data in the private member tpldata.

=back

=cut
sub loadTpl
{
	my $obj = shift;
	$obj->debug(NLIB_DL_TEMPLATE,"loadTpl","Loading template ".$obj->{tpl},__LINE__);

	my $file = $obj->{tpldir}."/".$obj->{tpl}.$obj->{tplext};
	$obj->debug(NLIB_DL_TEMPLATE,"loadTpl","Looking for file ".$file,__LINE__);

	if(open TPL, "<".$file){
		while(<TPL>){
			$obj->{tpldata} .= $_;
		}
		close TPL;
	} else {
		my $error = $!;
		my $e = new NLIB::Exception(etype => NLIB_EXCEPTION_TYPE_NO_TEMPLATE, error => $error, app => $obj->getApp());
		$e->raiseSaveException();
	}
}


=pod

=over

=item B<get>

Returns the loaded template data. Useful when having a template snippet that does not contain any labels to be replaced.

=back

=cut
sub get
{
	my $obj = shift;
	$obj->debug(NLIB_DL_VDEBUG,"get",$obj->{tpl},__LINE__);
	return $obj->{tpldata};
}


=pod

=over

=item B<replace>

Replcaces the current template data defined by the label indicators with their appropriate values. A label in a template is enclosed into two hash '#' signs. Example: ##MY_LABEL##. The label ##MY_LABEL## is then replaced by the appropriate data like this: $tpl->replace(MY_LABEL => $my_value).

Replace returns the acutal template data with the labels substituted by their values.

=back

=cut
sub replace
{
	my $obj = shift;
	my %r = @_;
	
	$obj->debug(NLIB_DL_TEMPLATE,"replace","",__LINE__);

	foreach my $key(keys %r){
		my $value = $r{$key};
		$obj->{tpldata} =~ s/##$key##/$value/g;
		$obj->debug(NLIB_DL_TEMPLATE,"replace","replacing $key with $value",__LINE__); # in verbose mode
	}
	
	# alle anderen leeren
	$obj->{tpldata} =~ s/##.*##//g;

	$obj->debug(NLIB_DL_TEMPLATE,"replace","returning: ".$obj->{tpldata},__LINE__); # in verbose mode
	return $obj->{tpldata};
}


=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
