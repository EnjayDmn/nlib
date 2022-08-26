package NLIB::ActionWidgetState;

#
# $Id: ActionWidgetState.pm,v 1.1 2014-01-31 18:01:01 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-ActionWidgetState">All Classes</a>

=end html

=head1 NAME

NLIB::ActionWidgetState

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::ActionWidgetState (%params);

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
use NLIB::ContentWidgetState;

use vars qw(@ISA);
@ISA = qw(NLIB::Action);

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

=item B<doAction>

Perform the main action.

=back

=cut
sub doAction
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"doAction","",__LINE__);
	$obj->debug(NLIB_DL_BIZ,"doAction","Performing action.",__LINE__);

	my $page;
	$page = new NLIB::JsonPage(app => $obj->getApp());
	$page->connectContent( JSON => new NLIB::ContentWidgetState(app => $obj->getApp()));
	$page->renderPage();
}




=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
