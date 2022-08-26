package NLIB::Application;

#
# $Id: Application.pm,v 1.18 2014-02-04 09:28:18 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-Application">All Classes</a>

=end html

=head1 NAME

NLIB::Application

=head1 SYNOPSIS

B<construction:>

 my $app = new NLIB::Application (%params);
 $app->run();

B<private:>

 $obj->_init(%data);

B<public:>

 DOCSYNOPSIS

=head1 DESCRIPTION

This is the Description of this class.

=cut

=pod

=head1 MEMBERS

=over

=item I<a_member>

The description of the member.

=item I<session>

The session object. See NLIB::Session(3) for the data structure of a session.

=back

=head1 METHODS AND ACCESSORS

=cut

use strict;
use NLIB;
use NLIB::Constants;

use vars qw(@ISA);
@ISA = qw(NLIB::Object);

=pod

=over

=item B<_init>

This is the default initializer which is called by the constructor.

See section MEMBERS to get a list which memebers are defined for the application.

=back

=cut
sub _init
{
	my $obj = shift;
	my %data = @_;
	$obj->SUPER::_init(%data);

	# AGGREGATES
  defined($data{cgi}) ? ($obj->{cgi} = $data{cgi}) : ($obj->{cgi} = new NLIB::Cgi(debug => $obj->debuglevel()));
  defined($data{dbc}) ? ($obj->{dbc} = $data{dbc}) : ($obj->{dbc} = new NLIB::DbConnector(app => $obj,%data));

  if(defined($data{skip_create_session} && $data{skip_create_session} == 1)){
		$obj->debug(NLIB_DL_DEBUG,"init","Skipping session creationn in SUPER class. Creating session from child.",__LINE__);
	}else{
  	defined($data{session}) ? ($obj->{session} = $data{session}) : ($obj->{session} = new NLIB::Session(app => $obj));
	}
  defined($data{dispatcher}) ? ($obj->{dispatcher} = $data{dispatcher}) : ($obj->{dispatcher} = undef);
}

=pod 

=over

=item B<run>

Runs the application.

=back

=cut
sub run
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"run","",__LINE__);
	$obj->debug(NLIB_DL_BIZ,"run","Application set up and running.",__LINE__);

	my $now = localtime();
	
#	my $to = new NLIB::TableObject(table => "tableobject", app => $obj);
#	$to->getset("param_name","param1");
#	$to->getset("param_value","value1");
#	$to->getset("param_option","option1");

#	my @erg;
#	$to->get(["param_name","param_value","param_option"],\@erg);
#	$obj->debug(NLIB_DL_DEBUG,"run","Ergebnis 1: ".(join(",",@erg)),__LINE__);
#	@erg = ();	
#	$to->setValues(param_name => "name2", param_value => "value2", param_option => "option2");
#	$to->get(["param_name","param_value","param_option"],\@erg);
#	$obj->debug(NLIB_DL_DEBUG,"run","Ergebnis 2: ".(join(",",@erg)),__LINE__);

	# Setup session
	my $s = $obj->getSession();
	$s->collectSessionData();
	$obj->debug(NLIB_DL_BIZ,"run","Collected session data.",__LINE__);

	# Check what to do
	$obj->dispatchRequest();

	$obj->debug(NLIB_DL_BIZ,"run","Application run ready.",__LINE__);

	# Running the application means:
	# 1. Set up the current session state
	#    The basic session is set up during construction
	#    The current session state will be set up here.
	#    The session state is set up based upon either
	#    a) the current action
	#    b) the current workflow
	#    c) both
	#
	# 2. Dispatch the action
	#
	#
	# 3. Render the output
	
#	my $cgi = $obj->getCgi()->getCgi();
#	my $coo = $cgi->cookie(-name => "coo", -value => "val");
#	print $cgi->header(-charset => "utf-8",-cache_control => 'no-cache', -cookie => $cgi->cookie() );
#	my @params = $cgi->param();
#	foreach my $p(@params){
#		print $p." => ".$cgi->param($p)."<br>\n";
#	}

	
#	foreach my $k(sort keys %ENV){
#		print $k." => ".$ENV{$k}."\n";
#	}

}




=pod

=over

=item B<getDispatcher>



=back

=cut
sub getDispatcher
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getDispatcher","",__LINE__);

	return $obj->{dispatcher};

}





=pod

=over

=item B<dispatchRequest>

Determine the current session flavour and instanciate the appropriate dispatcher.

=back

=cut
sub  dispatchRequest
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"dispatchRequest","",__LINE__);

	# Check session flavour
	my $s = $obj->getSession();
	my $flavour = $s->getFlavour();
	
	# 1 == 0 -----------------------
	if(1 == 0)
	{
		if($flavour ==  NLIB_SESSION_FLAVOUR_ANON_ACT){
			$obj->debug(NLIB_DL_BIZ,"dispatchRequest","Session flavour is of type NLIB_SESSION_FLAVOUR_ANON_ACT.",__LINE__);
			$obj->{dispatcher} = new NLIB::ActionDispatcher(app => $obj);
		}
		elsif($flavour ==  NLIB_SESSION_FLAVOUR_ANON_FLOW){
			$obj->debug(NLIB_DL_BIZ,"dispatchRequest","Session flavour is of type NLIB_SESSION_FLAVOUR_ANON_FLOW.",__LINE__);
			$obj->{dispatcher} = new NLIB::FlowDispatcher(app => $obj);
		}
		elsif($flavour ==  NLIB_SESSION_FLAVOUR_PERS_ACT){
			$obj->debug(NLIB_DL_BIZ,"dispatchRequest","Session flavour is of type NLIB_SESSION_FLAVOUR_PERS_ACT.",__LINE__);
			$obj->{dispatcher} = new NLIB::PersonalActionDispatcher(app => $obj);
		}
		elsif($flavour ==  NLIB_SESSION_FLAVOUR_PERS_FLOW){
			$obj->debug(NLIB_DL_BIZ,"dispatchRequest","Session flavour is of type NLIB_SESSION_FLAVOUR_PERS_FLOW.",__LINE__);
			$obj->{dispatcher} = new NLIB::PersonalFlowDispatcher(app => $obj);
		}
		else{
			$obj->debug(NLIB_DL_EXCEPTION,"dispatchRequest","Error: Unknown session flavour: ".$flavour,__LINE__);
			my $e = new NLIB::Exception(etype => NLIB_EXCEPTION_TYPE_UNKONWN_FLAVOUR, error => "Unknown session flavour type: (".$flavour.")", app => $obj);
			$e->raiseException();
		}
	} # 1 == 0 -----------------------

	$obj->{dispatcher} = new NLIB::ActionDispatcher(app => $obj);
	unless(defined($obj->{dispatcher}->parseRequest())){
		$obj->debug(NLIB_DL_BIZ,"run","No request, going to perform default action.",__LINE__);
		$obj->{dispatcher}->default();
		$obj->debug(NLIB_DL_BIZ,"run","Finished performing default action.",__LINE__);
	}
	else{
		$obj->debug(NLIB_DL_BIZ,"run","Request available, going to dispatch request.",__LINE__);
		$obj->{dispatcher}->dispatchRequest();
		$obj->debug(NLIB_DL_BIZ,"run","Finished performing request.",__LINE__);
	}
}












=pod

=over

=item B<getCgi>

Returns the NLIB::Cgi object.

=back

=cut
sub  getCgi
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getCgi","",__LINE__);
	return $obj->{cgi};
}

=pod

=over

=item B<getDbc>

Returns the default database connector.

=back

=cut
sub  getDbc
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getDbc","",__LINE__);
	return $obj->{dbc};
}


=pod

=over

=item B<getSession>

Returns the session.

=back

=cut
sub getSession
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getSession","",__LINE__);
	return $obj->{session};

}







=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
