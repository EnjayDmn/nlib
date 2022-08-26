package NLIB::FlowAuthenticate;

#
# $Id: FlowAuthenticate.pm,v 1.6 2014-01-31 18:01:02 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-FlowAuthenticate">All Classes</a>

=end html

=head1 NAME

NLIB::FlowAuthenticate

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::FlowAuthenticate (%params);

B<private:>

 $obj->_init(%data);

B<public:>

 DOCSYNOPSIS

=head1 DESCRIPTION

NLIB::FlowAuthenticate is the base class for all flow types.

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
use NLIB::ActionLogin;
use NLIB::ActionLogout;

use vars qw(@ISA);
@ISA = qw(NLIB::Flow);

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

  $data{flowname} = "FlowAuthenticate";
	$data{status} = new NLIB::TableObjectRequest(col => ["req_name","logout"],app=>$data{app}); # set auth status explicitly
	$obj->SUPER::_init(%data); # init defaults
	$obj->getApp()->getSession()->setFlavour(NLIB_SESSION_FLAVOUR_ANON_FLOW);
}


=pod

=over

=item B<performRequest>



=back

=cut
sub performRequest
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"performRequest","",__LINE__);
	my $request = shift;

	if($obj->isRequestValid($request))
	{
		$obj->setStatus($request);
		$obj->debug(NLIB_DL_DEBUG,"performRequest","Request is valid, performing action",__LINE__);
		my $reqName = $request->getset("req_name");
		my $action;
		if($reqName eq "login"){
			$action = new NLIB::ActionLogin(app=>$obj->getApp());
		}
		elsif($reqName eq "logout"){
			$action = new NLIB::ActionLogout(app=>$obj->getApp());
		}
		else{ # ANY
			# error: validated request is not available
			$obj->debug(NLIB_DL_DEBUG,"performRequest","Request was ANY, wo we perform default action (logout).",__LINE__);
			$obj->setStatus(new NLIB::TableObjectRequest(col => ["req_name","logout"],app=>$obj->getApp()));
			$action = new NLIB::Action(app=>$obj->getApp());
		}
		$action->doAction();
	}
	else
	{
		$obj->debug(NLIB_DL_DEBUG,"performRequest","Request is invalid, performing default fallback action",__LINE__);
		# set default flow status, logout in this case.
		$obj->setStatus(new NLIB::TableObjectRequest(col => ["req_name","logout"],app=>$obj->getApp()));
		# perform logout action
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
