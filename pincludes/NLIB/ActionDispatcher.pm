package NLIB::ActionDispatcher;

#
# $Id: ActionDispatcher.pm,v 1.8 2014-01-31 18:01:01 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-ActionDispatcher">All Classes</a>

=end html

=head1 NAME

NLIB::ActionDispatcher

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::ActionDispatcher (%params);

B<private:>

 $obj->_init(%data);

B<public:>

 DOCSYNOPSIS

=head1 DESCRIPTION

NLIB::ActionDispatcher represents a default action dispatcher for an unpersonalized and action based session flavour type. This object is meant to be an interface for inherited objects.

The NLIB::Action dispatcher implements the handling for the type NLIB_SESSION_FLAVOUR_ANON_ACT.

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
@ISA = qw(NLIB::Dispatcher);

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

	# No members defined here, TODO: Inherit and implement your own.
	
}


=pod

=over

=item B<default>



=back

=cut
sub default
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"default","",__LINE__);

	# The default action handler is called, if no or a malformed parameter is given
	my $actionDefault = new NLIB::Action(app => $obj->getApp());
	$actionDefault->doAction();
}




=pod

=over

=item B<dispatchRequest>

The overwritten dispatch method.

=back

=cut
sub dispatchRequest
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"dispatchRequest","",__LINE__);

	# We already have a request here.
	my $req = $obj->getRequest();
	$obj->debug(NLIB_DL_BIZ,"dispatchRequest","Dispatching request: ".$req->getset("req_name"),__LINE__);
	# TODO: Do something with the request, best thing would be to instanciate the appropriate action.

	my $reqName = $req->getset("req_name");
	
	if($reqName eq "login"){
		my $action = new NLIB::ActionLogin(app => $obj->getApp());
		$action->doAction();
	}

	# elsif ...
	elsif($reqName eq "updateWidgets"){
		my $action = new NLIB::ActionWidgetState(app => $obj->getApp());
		$action->doAction();
	}
	
	else{
		# We might pass in here, because we have a request that is not implemented above yet.
		$obj->debug(NLIB_DL_DEBUG,"dispatchRequest","Unhandled request: ".$req->getset("req_name"),__LINE__);
		$obj->default();
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
