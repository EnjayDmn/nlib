package NLIB::FlowDispatcher;

#
# $Id: FlowDispatcher.pm,v 1.5 2014-01-31 18:01:02 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-FlowDispatcher">All Classes</a>

=end html

=head1 NAME

NLIB::FlowDispatcher

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::FlowDispatcher (%params);

B<private:>

 $obj->_init(%data);

B<public:>

 DOCSYNOPSIS

=head1 DESCRIPTION

NLIB::FlowDispatcher represents a default flow dispatcher for an unpersonalized and flow based session flavour type. This object is meant to be an interface for inherited objects.

The dispatcher implements the handling for the type NLIB_SESSION_FLAVOUR_ANON_FLOW.

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
use NLIB::ActionWidgetState;

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
}

=pod

=over

=item B<dispatchRequest>



=back

=cut
sub dispatchRequest
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"dispatchRequest","",__LINE__);

	my $req = $obj->getRequest();
	$obj->debug(NLIB_DL_DEBUG,"dispatchRequest","Request: ".$req->getset("req_name"),__LINE__);

	my $reqName = $req->getset("req_name");
	
	if($reqName eq "login"){
		my $flowAuthenticate = new NLIB::FlowAuthenticate(app => $obj->getApp());
		$flowAuthenticate->performRequest($req);
	}
	elsif($reqName eq "logout"){
		my $flowAuthenticate = new NLIB::FlowAuthenticate(app => $obj->getApp());
		$flowAuthenticate->performRequest($req);
	}
	elsif($reqName eq "updateWidgets"){
		my $actionWidgetState = new NLIB::ActionWidgetState(app => $obj->getApp());
		$actionWidgetState->doAction($req);
	}


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

	my $flowAuthenticate = new NLIB::FlowAuthenticate(app => $obj->getApp());
	$flowAuthenticate->performRequest(new NLIB::TableObjectRequest(col => ["req_name","ANY"],app=>$obj->getApp()) );
}


=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
