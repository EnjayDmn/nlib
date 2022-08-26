package NLIB::PersonalFlowDispatcher;

#
# $Id: PersonalFlowDispatcher.pm,v 1.2 2013-12-18 12:25:50 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-PersonalFlowDispatcher">All Classes</a>

=end html

=head1 NAME

NLIB::PersonalFlowDispatcher

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::PersonalFlowDispatcher (%params);

B<private:>

 $obj->_init(%data);

B<public:>

 DOCSYNOPSIS

=head1 DESCRIPTION

NLIB::PersonalFlowDispatcher represents a default flow dispatcher for a personalized and flow based session flavour type. This object is meant to be an interface for inherited objects.

The dispatcher implements the handling for the type NLIB_SESSION_FLAVOUR_PERS_FLOW.

See NLIB::Constants(3), section SESSION FLAVOURS for other available session flavour types. 

Do not use this object directly. Instead, inherit from it and implement your own kind of dispatch method.

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
@ISA = qw(NLIB::FlowDispatcher);

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

  #defined($data{app}) ? ($obj->{app} = $data{app}) : ($obj->{app} = undef);
	# No members defined here, TODO: Inherit and implement your own.
	
}


=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
