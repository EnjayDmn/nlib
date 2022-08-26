package NLIB::Flow;

#
# $Id: Flow.pm,v 1.7 2014-01-31 18:01:02 nils-1327 Exp $
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

  defined($data{flowname}) ? ($obj->{flowname} = $data{flowname}) : ($obj->{flowname} = undef);
	# The flow status is a reference to an instance of a TableObjectRequest object
  defined($data{status}) ? ($obj->{status} = $data{status}) : ($obj->{status} = new NLIB::TableObjectRequest(col => ["req_name","ANY"],app=>$obj->getApp()));
  defined($data{to_flow_type}) ? ($obj->{to_flow_type} = $data{to_flow_type}) : ($obj->{to_flow_type} = new NLIB::TableObject(table => "nlib_flow_type", col => ["flowname",$obj->{flowname}],app=>$obj->getApp(), create => 0 ));
	
	unless($obj->{to_flow_type}->getId()){
		my $e = new NLIB::Exception(etype => NLIB_EXCEPTION_TYPE_UNREGISTERED_FLOW_TYPE, error => "Instanciation of unregistered flow type.", app => $obj->getApp());
		$e->raiseException();
	}

  defined($data{to_flow_instance}) ? ($obj->{to_flow_instance} = $data{to_flow_instance}) : ($obj->{to_flow_instance} = new NLIB::TableObject(table => "nlib_flow_instance", col => ["id_flow_type",$obj->{to_flow_type}->getId()],app=>$obj->getApp() ));
  defined($data{flow_status}) ? ($obj->{flow_status} = $data{flow_status}) : ($obj->{flow_status} = undef);
	$obj->setInitialStatus(); # ANY	
}




=pod

=over

=item B<setInitialStatus>

Sets initial status to status ANY

=back

=cut
sub setInitialStatus
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"setInitialStatus","",__LINE__);

  $obj->{to_flow_instance} = new NLIB::TableObject(table => "nlib_flow_instance", col => ["id_flow_type",$obj->{to_flow_type}->getId()],app=>$obj->getApp());
	if($obj->{to_flow_instance}->isFresh()){
		$obj->{to_flow_instance}->set(id_flow_type => $obj->{to_flow_type}->getId());
	}
	
	$obj->{flow_status} = new NLIB::TableObject(table => "nlib_flow_status", col => ["id_flow_instance", $obj->{to_flow_instance}->getId(), id_session => $obj->getApp()->getSession()->getSessionId()], app=>$obj->getApp());
	if($obj->{flow_status}->isFresh()){
		$obj->{flow_status}->set( id_flow_instance => $obj->{to_flow_instance}->getId(), id_request => $obj->{status}->getId(), id_user => NLIB_SESSION_ANONYMOUS_USER,id_session => $obj->getApp()->getSession()->getSessionId());
	}
	else{
		$obj->getStatus();
	}
}



=pod

=over

=item B<setStatus>

Sets the status of the flow and returns the new status

=back

=cut
sub setStatus
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"setStatus","",__LINE__);
	my $status = shift;
	$obj->{status} = $status;
	$obj->{flow_status}->set( id_request => $obj->{status}->getId());
	return $obj->{status};
}


=pod

=over

=item B<getStatus>

Returns the current flow status.

=back

=cut
sub getStatus
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getStatus","",__LINE__);
	$obj->{status} = new NLIB::TableObjectRequest(id => $obj->{flow_status}->getset("id_request"),app=>$obj->getApp());
	return $obj->{status};
}


=pod

=over

=item B<performRequest(Request)>

Performs the given request. Request is an already instanciated TableObjectRequest

=back

=cut
sub performRequest
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"performRequest","",__LINE__);
	my $request = shift;

	# 1. Is the request a valid request within the flow?
	# 2. Is the request valid according to the current flow status?
#	pseudo: 
#	if(newReq in Flow == true && newRequest isNextOf curStatus == true)
#	then
#		curStatus = newRequest
#		my action
#		doAction...
		

}



=pod

=over

=item B<isRequestValid($request)>

Checks if the given request is a vlaid follow-up request of the current request status within the flow.

=back

=cut
sub isRequestValid
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"isRequestValid","",__LINE__);
	my $request =  shift;
	my $selRequest = "select * from map_flow_request_followup where id_flow_type = '".$obj->{to_flow_type}->getId()."' and id_request = '".$obj->{status}->getId()."' and id_followup = '".$request->getId()."'";
	my $sthRequest = $obj->getApp()->getDbc()->querySth($selRequest);
	my $valid = $sthRequest->rows;
	$obj->debug(NLIB_DL_DEBUG,"isRequestValid","Valid: $valid",__LINE__);
	return $valid;
}



=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
