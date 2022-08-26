package NLIB::Exception;

#
# $Id: Exception.pm,v 1.5 2014-01-31 18:01:02 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-Exception">All Classes</a>

=end html

=head1 NAME

NLIB::Exception

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::Exception (%params);

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
use NLIB::JsonPage;
use JSON;

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

	# Raise exception with HTML header or not
	defined($data{h}) ? ($obj->{h} = $data{h}) : ($obj->{h} = undef);
	defined($data{etpl}) ? ($obj->{etpl} = $data{etpl}) : ($obj->{etpl} = NLIB_EXCEPTION_TEMPLATE);
	defined($data{etype}) ? ($obj->{etype} = $data{etype}) : ($obj->{etype} = NLIB_EXCEPTION_TYPE_DEFAULT);
	defined($data{error}) ? ($obj->{error} = $data{error}) : ($obj->{error} = undef);

}


=pod

=over

=item B<raiseException>

Raise the current exception

=back

=cut
sub  raiseException
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"raiseException","",__LINE__);

	my $estr = $obj->{estr}->{$obj->{etype}};
	my $now = localtime();

	$obj->debug(NLIB_DL_EXCEPTION,"raiseException","Exception ".$obj->getExceptionString($obj->{etype})." (".$obj->{etype}.")  raised on ".$now.", exiting.",__LINE__);
	$obj->debug(NLIB_DL_EXCEPTION,"raiseException","Exception message: ".$obj->{error},__LINE__);
	if($obj->getApp()->getSession()->isRunning()){
		my %json;
		$json{status} = "ERROR";
		$json{request} = $obj->getApp()->getDispatcher()->getRequest()->getset("req_name");
		$json{response} = "safeException";
		$json{exceptionString} = $obj->getExceptionString($obj->{etype});
		$json{exceptionType} = $obj->{etype};
		$json{error} = $obj->{error};
		my $content = encode_json(\%json);	
		$obj->stdout($content);
	}
	else{

		my $page;
		$page = new NLIB::Page(tpl => $obj->{etpl}, app => $obj->getApp());
		$page->loadTemplate();
		$page->splitTemplate();
		my $content = "<p>Exception type: ".$obj->getExceptionString($obj->{etype})." (0x".$obj->{etype}.")</p>\n";
		if(defined($obj->{error})){
			$content .= "<p>Details: ".$obj->{error}."</p>\n";
		}
		$page->connectContent(CONTENT => $content);
		$page->connectContent(DATE => scalar(localtime()));
		$page->renderPage();
	}
	
	exit(0);

}



=pod

=over

=item B<raiseSaveException>

Raises the current exception in a way that no external template is needed. This is to avoid deep recursion but still providing (web) content output. To serve other formatted output this method should be overridden in a special inherited exception class

=back

=cut
sub  raiseSaveException
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"raiseSaveException","",__LINE__);

	my $now = localtime();
	$obj->stdout('<html><head><title>NLIB Exception</title></head><body><h1>NLIB Exception</h1><hr><p>This is a special exception prevent from deep recursion. It is likely that some template path is not set correctly. Please contact your system maintainer.</p><hr><small><i>Exception generated on '.$now.'</i></small></body></html>'."\n");
	$obj->debug(NLIB_DL_EXCEPTION,"raiseSaveException","Save Exception raised on ".$now.", exiting.",__LINE__);
	exit(0);
}



=pod

=over

=item B<exceptionHeader>

Print a HTTP header

=back

=cut
sub  exceptionHeader
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"exceptionHeader","",__LINE__);

	my $cgi = new NLIB::Cgi;
	$obj->stdout($cgi->getCgi()->header(-charset => 'utf-8'));

}


=pod

=over

=item B<getExceptionString>



=back

=cut
sub getExceptionString
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getExceptionString",__LINE__);
	my $enum = shift;

	return scalar("NLIB_EXCEPTION_TYPE_DEFAULT") if ($enum == NLIB_EXCEPTION_TYPE_DEFAULT);
	return scalar("NLIB_EXCEPTION_TYPE_NO_TEMPLATE") if ($enum == NLIB_EXCEPTION_TYPE_NO_TEMPLATE);
	return scalar("NLIB_EXCEPTION_TYPE_DBERROR") if ($enum == NLIB_EXCEPTION_TYPE_DBERROR);
	return scalar("NLIB_EXCEPTION_TYPE_TABLE_WITHOUT_NAME") if ($enum == NLIB_EXCEPTION_TYPE_TABLE_WITHOUT_NAME);
	return scalar("NLIB_EXCEPTION_TYPE_TABLE_HAS_NO_COLUMNS") if ($enum == NLIB_EXCEPTION_TYPE_TABLE_HAS_NO_COLUMNS);
	return scalar("NLIB_EXCEPTION_TYPE_UNKONWN_SESSION_STYLE") if ($enum == NLIB_EXCEPTION_TYPE_UNKONWN_SESSION_STYLE);
	return scalar("NLIB_EXCEPTION_TYPE_UNKONWN_FLAVOUR") if ($enum == NLIB_EXCEPTION_TYPE_UNKONWN_FLAVOUR);
	return scalar("NLIB_EXCEPTION_TYPE_UNREGISTERED_FLOW_TYPE") if ($enum == NLIB_EXCEPTION_TYPE_UNREGISTERED_FLOW_TYPE);
	return scalar("NLIB_EXCEPTION_TYPE_WRONG_REQUEST_PARAMETER_STRUCTURE") if ($enum == NLIB_EXCEPTION_TYPE_WRONG_REQUEST_PARAMETER_STRUCTURE);
	return scalar("NLIB_EXCEPTION_TYPE_UNKNOWN");

}


=pod

=head1 SEE ALSO

NLIB(3), the NLIB README and the documentation subdirectory.

=head1 AUTHOR

 Copyright (c) 2013 
 
 Nils Doormann <nils@inandout-cologne.de>


=cut


1;
