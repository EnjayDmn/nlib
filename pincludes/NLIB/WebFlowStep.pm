package NLIB::WebFlowStep;

#
# $Id: WebFlowStep.pm,v 1.1 2013-12-10 23:17:31 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-WebFlowStep">All Classes</a>

=end html

=head1 NAME

NLIB::WebFlowStep

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::WebFlowStep (%params);

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

}




=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
