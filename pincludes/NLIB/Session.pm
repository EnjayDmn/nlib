package NLIB::Session;

#
# $Id: Session.pm,v 1.14 2014-02-27 16:18:20 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-Session">All Classes</a>

=end html

=head1 NAME

NLIB::Session

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::Session (%params);

B<private:>

 $obj->_init(%data);

B<public:>

 DOCSYNOPSIS

=head1 DESCRIPTION

NLIB::Session is the basic interactive session object.

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

	# We aggregate the NLIB::Cgi instance
  defined($data{cgi}) ? ($obj->{cgi} = $data{cgi}) : ($obj->{cgi} = $obj->getApp()->getCgi());
 
 	# SESSION PARAMETERS
	# All kind of session params are handled within cookies

 	# All kind of sessions have a session ticket
	defined($data{sess_ticket}) ? ($obj->{sess_ticket} = $data{sess_ticket}) : ($obj->{sess_ticket} = undef);
	
	# A personal session has a user id associated with it
	defined($data{id_user}) ? ($obj->{id_user} = $data{id_user}) : ($obj->{id_user} = NLIB_SESSION_ANONYMOUS_USER);

	# The session flavour
	defined($data{sess_flavour}) ? ($obj->{sess_flavour} = $data{sess_flavour}) : ($obj->{sess_flavour} = undef);

	# The session status
	defined($data{sess_status}) ? ($obj->{sess_status} = $data{sess_status}) : ($obj->{sess_status} = undef);

	# The offset of the session
	defined($data{sess_offset}) ? ($obj->{sess_offset} = $data{sess_offset}) : ($obj->{sess_offset} = undef);

	# The last change of the session
	defined($data{sess_change}) ? ($obj->{sess_change} = $data{sess_change}) : ($obj->{sess_change} = undef);

	# The origin
	defined($data{source_ip}) ? ($obj->{source_ip} = $data{source_ip}) : ($obj->{source_ip} = undef);

	# The session key to encrypt/decrypt the session cookie associated with this session.
	defined($data{sess_key}) ? ($obj->{sess_key} = $data{sess_key}) : ($obj->{sess_key} = undef);

	# NLIB Session Cookie String 
	defined($data{__nlscs}) ? ($obj->{__nlscs} = $data{__nlscs}) : ($obj->{__nlscs} = undef);
	
	# True if the application is determined as already running (i.e. an initial call from the client has been sent and answered)
	# The application is declared as running if the client sends a valid session cookie.
	defined($data{sess_running}) ? ($obj->{sess_running} = $data{sess_running}) : ($obj->{sess_running} = undef);

	# Indicates, wether to perform the default action, nevertheless which request was actually sent.
	defined($data{do_default}) ? ($obj->{do_default} = $data{do_default}) : ($obj->{do_default} = 0);

	#
	# The nlscs structure:
	#
	# id_user:sess_ticket
	#
	#

	# The table object associated with this session
	defined($data{nlib_to_session}) ? ($obj->{nlib_to_session} = $data{nlib_to_session}) : ($obj->{nlib_to_session} = undef);
	defined($data{nlib_session_table}) ? ($obj->{nlib_session_table} = $data{nlib_session_table}) : ($obj->{nlib_session_table} = "nlib_session");

}

=pod

=over

=item B<getIdUser>

Returns the user id of the current user. In anonymous session, the user id NLIB_SESSION_ANONYMOUS_USER is returned.

=back

=cut
sub getIdUser
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getIdUser","",__LINE__);
	return $obj->{id_user};
}


=pod

=over

=item B<setUserLoggedIn($toUser)>

Sets and returns the user id of the current user. This is low-level and just the method accessor. Does not update flavour information!

=back

=cut
sub setUserLoggedIn
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"setUserLoggedIn","",__LINE__);
	my $toUser = shift;
	$obj->{id_user} = $toUser->getId();
	my $curFlav = $obj->{sess_flavour};
	if( ($curFlav & NLIB_SESSION_TYPE_ANONYMOUS) == NLIB_SESSION_TYPE_ANONYMOUS){
		$obj->debug(NLIB_DL_DEBUG,"setUserLoggedIn","Good. Session was anonymous. Going to log in user ".$toUser->getset("uname"),__LINE__);
		$curFlav ^= NLIB_SESSION_TYPE_ANONYMOUS;
		$curFlav |= NLIB_SESSION_TYPE_PERSONAL;
		$obj->debug(NLIB_DL_DEBUG,"setUserLoggedIn","curFlavour: ".$curFlav,__LINE__);
		$obj->{sess_flavour} = $curFlav;
		$obj->save();
	}
	else{
		$obj->debug(NLIB_DL_DEBUG,"setUserLoggedIn","User ".$toUser->getset("uname")." is trying to re-login although already logged-in!",__LINE__);
		# FIXME and DISCUSS: Reset session on unwanted re-login or just dont do nothing?
	}
}


=pod

=over

=item B<getFlavour>

Returns the session's flavour.

=back

=cut
sub  getFlavour
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getFlavour","",__LINE__);
	return $obj->{sess_flavour};
}


=pod

=over

=item B<setFlavour($flavour)>

Set the current session flavour to flavour. Returns the new flavour.

=back

=cut
sub setFlavour
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"setFlavour","",__LINE__);
	my $flavour = shift;
	$obj->{sess_flavour} = $flavour;
	return $obj->{sess_flavour};
}

=pod

=over

=item B<isPersonal>

Returns the user id != NLIB_SESSION_ANONYMOUS_USER (0) if the session is of personal type.

=back

=cut
sub isPersonal
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"isPersonal","",__LINE__);
	return $obj->{id_user};
}


=pod

=over

=item B<collectSessionData>

Collect all available session data from the environment (i.e. from the __nlscs cookie).

=back

=cut
sub collectSessionData
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"collectSessionData","",__LINE__);

	# Get the nlib cgi to work with
	my $cgi = $obj->{cgi};
	
	# Retrieve the nlib session ccokie string
	$obj->{__nlscs} = $cgi->getCgiCookie("__nlscs");

	#
	# Determine cases. Either a cookie is found or not. In the latter case a new cookie will be generated for an anonymous session.
	# It is up to the application to determine, in which case a personalized session is required.
	#

	# No cookie/ empty cookie
	if($obj->{__nlscs} eq ""){
		$obj->debug(NLIB_DL_SESSION,"collectSessionData","No cookie __nlscs, creating new session.",__LINE__);
		#$obj->debug(NLIB_DL_SESSION,"collectSessionData","Session flavour will be NLIB_SESSION_FLAVOUR_ANON_FLOW.",__LINE__);
		$obj->debug(NLIB_DL_SESSION,"collectSessionData","Setting user id to NLIB_SESSION_ANONYMOUS_USER.",__LINE__);
		$obj->debug(NLIB_DL_SESSION,"collectSessionData","Setting session status to NLIB_SESSION_ANONYMOUS_ACTION.",__LINE__);
		$obj->setupAnonymousActionSession();
		#$obj->setupAnonymousFlowSession();
		$obj->{do_default} = 1;
		return $obj;
	}
	
	# We have a cookie, now get the session info from it.
	$obj->debug(NLIB_DL_SESSION,"collectSessionData","Cookie __nlscs exists: ".$obj->{__nlscs},__LINE__);
	unless($obj->findSessionTicket()){
		$obj->debug(NLIB_DL_SESSION,"collectSessionData","No valid session for cookie __nlscs found.",__LINE__);
		$obj->setupAnonymousActionSession();
		#$obj->setupAnonymousFlowSession();
		$obj->{do_default} = 1;
		return $obj;
	}

	# Found session data, setup session object.
	$obj->setupSessionFromTable();

	#$obj->debug(NLIB_DL_SESSION,"collectSessionData","No valid session for cookie __nlscs found.",__LINE__);
	#$obj->debug(NLIB_DL_SESSION,"collectSessionData","Retrieved cookie information from __nlscs: ".$obj->aesDecrypt($nlscs,$key),__LINE__);
	#$cgi->setCookieJarCookie("__nlscs",$nlscs);

}


=pod

=over

=item B<setupAnonymousFlowSession>



=back

=cut
sub setupAnonymousFlowSession
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"setupAnonymousFlowSession","",__LINE__);

	$obj->{sess_flavour} = NLIB_SESSION_TYPE_ANONYMOUS | NLIB_SESSION_STYLE_WEBFLOW; # i.e. NLIB_SESSION_FLAVOUR_ANON_FLOW;
	my $now = $obj->getNow();
	$obj->{sess_offset} = $now;
	$obj->{sess_change} = $now;
	$obj->{source_ip} = $obj->{cgi}->getRemoteHost();
	$obj->{sess_ticket} = $obj->getSha1B64();
	$obj->{sess_key} = $obj->getSha1B64();
	$obj->{sess_status} = NLIB_DEFAULT_ANONYMOUS_ACTION;
	$obj->{id_user} = NLIB_SESSION_ANONYMOUS_USER;
	$obj->{sess_running} = undef;

	$obj->debug(NLIB_DL_SESSION,"setupAnonymousFlowSession","Creating new session table object.",__LINE__);
	$obj->{nlib_to_session} = new NLIB::TableObject(table => $obj->{nlib_session_table}, app => $obj->getApp()); 

	$obj->save();
		
	my $aes = $obj->aesEncrypt($obj->{id_user}.";;".$obj->{sess_ticket},$obj->{sess_key});
	$obj->{cgi}->setCookieJarCookie("__nlscs",$aes);


}





=pod

=over

=item B<setupAnonymousActionSession>

Setup a session of flavour type NLIB_SESSION_TYPE_ANONYMOUS | NLIB_SESSION_STYLE_ACTION with default behaviour.

=back

=cut
sub  setupAnonymousActionSession
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"setupAnonymousActionSession","",__LINE__);


	# Creating new (anon) session data means:
		
	# This is or'ed into 'flavour':
	# 1. Setting the session type
	# 2. Setting the session style
		
	# 3. Setting the session offset
	# 4. Setting the session change
	# 5. Setting the source ip
	# 6. Generating and setting the session ticket
	# 7. Generating and setting the session key
	# 8. According to the session style, setting the action or web flow step
	# 9. Cleaning up any unwanted cgi params
	# 10.Storing the session data and retrieving the reference id
	# 11. Creating the __nlscs cookie.
	# 12. Putting the __nlscs cookie into cookie jar.


	$obj->{sess_flavour} = NLIB_SESSION_TYPE_ANONYMOUS | NLIB_SESSION_STYLE_ACTION; # i.e. NLIB_SESSION_FLAVOUR_ANON_ACT;
	my $now = $obj->getNow();
	$obj->{sess_offset} = $now;
	$obj->{sess_change} = $now;
	$obj->{source_ip} = $obj->{cgi}->getRemoteHost();
	$obj->{sess_ticket} = $obj->getSha1B64();
	$obj->{sess_key} = $obj->getSha1B64();
	$obj->{sess_status} = NLIB_DEFAULT_ANONYMOUS_ACTION;
	$obj->{id_user} = NLIB_SESSION_ANONYMOUS_USER;
	$obj->{sess_running} = undef;

#	unless(defined($obj->{nlib_to_session})){
		$obj->debug(NLIB_DL_SESSION,"setupAnonymousActionSession","Creating new session table object.",__LINE__);
		$obj->{nlib_to_session} = new NLIB::TableObject(table => $obj->{nlib_session_table}, app => $obj->getApp()); 
#	}

	$obj->save();
		
	#$obj->setFlavourDependentStatus();
	my $aes = $obj->aesEncrypt($obj->{id_user}.";;".$obj->{sess_ticket},$obj->{sess_key});
	$obj->{cgi}->setCookieJarCookie("__nlscs",$aes);

}

=pod

=over

=item B<save>

Save current session state

=back

=cut
sub save
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"save","",__LINE__);
	$obj->{nlib_to_session}->set(
		id_user =>  $obj->{id_user},
		sess_flavour =>  $obj->{sess_flavour},
		sess_offset =>  $obj->{sess_offset},
		sess_change =>  $obj->{sess_change},
		source_ip =>  $obj->{source_ip},
		sess_ticket =>  $obj->{sess_ticket},
		sess_key =>  $obj->{sess_key}
	);
}



=pod

=over

=item B<getAvailableSessionTickets>

Returns the list of active session tickets, (and their ids) from the db session table.

=back

=cut
sub  getAvailableSessionTickets
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getAvailableSessionTickets","",__LINE__);

	my $selSessionTickets = "select id,sess_ticket from ".$obj->{nlib_session_table};
	my $sthSessionTickets = $obj->getApp()->getDbc()->querySth($selSessionTickets);
	while (my $refSessionTickets = $sthSessionTickets->fetchrow_arrayref()){
		$obj->debug(NLIB_DL_SESSION,"getAvailableSessionTickets",$refSessionTickets->[0].", ".$refSessionTickets->[1],__LINE__);
	}
}



=pod

=over

=item B<findSessionTicket>

Try to find a session ticket in db which is stored within the __nlscs cookie

=back

=cut
sub  findSessionTicket
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"findSessionTicket","",__LINE__);

	# although we might serch for all sessions (worst) it is likely that we are one of the latest...
	my $selSessionTickets = "select * from ".$obj->{nlib_session_table}. " order by id desc"; 
	my $sthSessionTickets = $obj->getApp()->getDbc()->querySth($selSessionTickets);
	while (my $refSessionTickets = $sthSessionTickets->fetchrow_arrayref()){
		$obj->debug(NLIB_DL_SESSION,"getAvailableSessionTickets","Trying __nlscs cookie against ".$refSessionTickets->[0].", key: ".$refSessionTickets->[7],__LINE__);
		if($obj->{__nlscs} && $refSessionTickets->[7]){
			my $decrypted = $obj->aesDecrypt($obj->{__nlscs},$refSessionTickets->[7]);
			my ($id,$ticket) = split ";;",$decrypted;
			if(defined($ticket) && $ticket eq $refSessionTickets->[6])
			{
				$obj->debug(NLIB_DL_SESSION,"getAvailableSessionTickets","Found Session: ".$decrypted.", id_user: ".$refSessionTickets->[1].", ticket: ".$refSessionTickets->[6],__LINE__);
				# We have found a key, so establish connection and return the reference to the table object as a defined value
				$obj->{nlib_to_session} = new NLIB::TableObject(table => $obj->{nlib_session_table},id => $refSessionTickets->[0],app => $obj->getApp());
				return $obj->{nlib_to_session};
			}
		}
	}
	# No valid session found, return undef in any case.
	return undef;
}







=pod

=over

=item B<setupSessionFromTable>

Sets appropriate session values to work with from the persistent table object.

=back

=cut
sub  setupSessionFromTable
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"setupSessionFromTable","",__LINE__);

	unless($obj->{nlib_to_session}){
		return undef;
	}

	$obj->{sess_flavour} = $obj->{nlib_to_session}->getset("sess_flavour");
	$obj->{sess_offset} = $obj->{nlib_to_session}->getset("sess_offset");
	$obj->{sess_change} = $obj->{nlib_to_session}->getset("sess_change"); # get old change
	$obj->{source_ip} = $obj->{nlib_to_session}->getset("source_ip");
	$obj->{sess_ticket} = $obj->{nlib_to_session}->getset("sess_ticket");
	$obj->{sess_key} = $obj->{nlib_to_session}->getset("sess_key");
	$obj->{sess_status} = NLIB_DEFAULT_ANONYMOUS_ACTION; # check what to do...
	$obj->{id_user} = $obj->{nlib_to_session}->getset("id_user");
	#$obj->{current_user} = $obj->{nlib_to_session}->getset("id_user");

	# Set application to running state
	$obj->{sess_running} = 1;

	# update session change
	my $lastChange = $obj->{sess_change};
	$obj->{sess_change} = $obj->getNow();
	$obj->{nlib_to_session}->set(sess_change => $obj->{sess_change});
	
	my $aes = $obj->aesEncrypt($obj->{id_user}.";;".$obj->{sess_ticket},$obj->{sess_key});
	$obj->{cgi}->setCookieJarCookie("__nlscs",$aes);

}





=pod

=over

=item B<isRunning>

Returns 1 or undef

=back

=cut
sub  isRunning
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"isRunning","",__LINE__);

	return $obj->{sess_running};
}





=pod

=over

=item B<setFlavourDependentStatus>

Set the session status in accordance to the current flavour.

Setting the status means: 

=over 

=item Determine the flavour type which, should be one of NLIB_SESSION_FLAVOUR_*

=item In case of a personal type, set the user info

=item In case of an anonymous type, reset the user info

=item In case of an action type, set the session action accordingly

=item In case of a web flow type, set the flow type and flow params accordingly

=item Determining, if to use default values or operate with given values from environment.

=back

=back

=cut
sub setFlavourDependentStatus
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"setFlavourDependentStatus",__LINE__);


}




=pod

=over

=item B<setActionState>

Determines the session style and sets the action or web flow step.

Because an action is the atomic part of a web flow step this method is called setActionState.

=back

=cut
sub setActionState
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"setActionState","",__LINE__);

	# switch session style
	if($obj->{sess_style} == NLIB_SESSION_STYLE_ACTION){
		$obj->debug(NLIB_DL_SESSION,"setActionState","Determined session style NLIB_SESSION_STYLE_ACTION (".NLIB_SESSION_STYLE_ACTION.")",__LINE__);
		# do action specific things
	}
	elsif($obj->{sess_style} == NLIB_SESSION_STYLE_WEBFLOW){
		$obj->debug(NLIB_DL_SESSION,"setActionState","Determined session style NLIB_SESSION_STYLE_WEBFLOW (".NLIB_SESSION_STYLE_WEBFLOW.")",__LINE__);
		# do webflow specific things
		#$obj->{sess_webflow} = $obj->getDefaultWebflow();
	}
	else{
		$obj->debug(NLIB_DL_SESSION,"setActionState","Determined unknown style (".$obj->{sess_style}.")",__LINE__);
		# Unknown session style, raise exception4
		my $e = new NLIB::Exception(etype => NLIB_EXCEPTION_TYPE_UNKONWN_SESSION_STYLE, error => "Unknown session style type: (".$obj->{sess_style}.")", app => $obj->getApp());
		$e->raiseException();
	}
}



=pod

=over

=item B<getSessionTicket>

Returns the session ticket

=back

=cut
sub  getSessionTicket
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getSessionTicket","",__LINE__);
	return $obj->{sess_ticket};
}


=pod

=over

=item B<getSessionId>

Returns the id of the corresponding (aggregated) session table object.

=back

=cut
sub getSessionId
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getSessionId","",__LINE__);
	return $obj->{nlib_to_session}->getId();
}




=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
