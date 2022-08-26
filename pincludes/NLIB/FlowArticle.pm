package NLIB::Flow;

#
# $Id: FlowArticle.pm,v 1.1 2013-12-20 13:36:13 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-Flow">All Classes</a>

=end html

=head1 NAME

NLIB::Flow

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::Flow (%params);

B<private:>

 $obj->_init(%data);

B<public:>

 DOCSYNOPSIS

=head1 DESCRIPTION

NLIB::Flow is the base class for all flow types.

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

  defined($data{actions}) ? ($obj->{actions} = $data{actions}) : ($obj->{actions} = undef);

	# Register actions within this flow
	$obj->{actions}->{showArticle} = new NLIB::FlowStepShowArticle(app => $obj-getApp());
	$obj->{actions}->{checkoutArticle} = new NLIB::FlowStepCheckoutArticle( app => $obj-getApp());
	$obj->{actions}->{saveArticle} = new NLIB::FlowStepSaveArticle( app => $obj-getApp());
	$obj->{actions}->{checkinArticle} = new NLIB::FlowStepCheckinArticle(app => $obj-getApp());
	$obj->{actions}->{abortCheckoutArticle} = new NLIB::FlowStepAbortCheckoutArticle(app => $obj-getApp());

	$obj->setFollowUps(
		showArticle => qw[ showArticle checkoutArticle  ],
		checkoutArticle => qw[saveArticle checkinArticle abortCheckoutArticle],
		saveArticle => qw[saveArticle checkinArticle abortCheckoutArticle ],
		checkinArticle => qw[showArticle checkoutArticle],
		abortCheckoutArticle => qw[showArticle checkoutArticle]
	);

}

=pod

=over

=item B<setFollowUps>



=back

=cut
sub  setFollowUps
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"setFollowUps","",__LINE__);
	my %f = @_;

	foreach my $a(keys %f){
		my $curStepRegistered = $obj->{actions}->{$a};
		if($curStepRegistered){
			$curStepRegistered->setFollowUps($f->{$a});
		}
	}

}












=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
