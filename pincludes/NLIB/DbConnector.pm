package NLIB::DbConnector;

#
# $Id: DbConnector.pm,v 1.8 2014-02-27 16:18:20 nils-1327 Exp $
#

use strict;
use DBI;

use NLIB;
use NLIB::Constants;

use vars qw(@ISA);
@ISA = qw(NLIB::SubScope);

sub _init
{
	my $obj = shift;
	my %data = @_;
	$obj->SUPER::_init(%data);

	defined($data{dbnam}) ? ($obj->{dbnam} = $data{dbnam}) : ($obj->{dbnam} = "nlib");
	defined($data{dbuser}) ? ($obj->{dbuser} = $data{dbuser}) : ($obj->{dbuser} = "nils");
	defined($data{dbpass}) ? ($obj->{dbpass} = $data{dbpass}) : ($obj->{dbpass} = "");
	defined($data{dbhost}) ? ($obj->{dbhost} = $data{dbhost}) : ($obj->{dbhost} = "localhost");
	defined($data{dbport}) ? ($obj->{dbport} = $data{dbport}) : ($obj->{dbport} = 3306);

	$obj->{dbh} = DBI->connect("dbi:mysql:".$obj->{dbnam},$obj->{dbuser},$obj->{dbpass},{PrintError => 0});
	unless(defined($obj->{dbh})){
		my $e = new NLIB::Exception(app => $obj->getApp(),error => $DBI::errstr, etype => NLIB_EXCEPTION_TYPE_DBERROR);
		$e->raiseException();
		return undef;
	}

	$obj->debug(NLIB_DL_METHOD,"_init","Using database ".$obj->{dbnam},__LINE__);
	#return $obj->{dbh};
}

=pod

=over

=item B<getDbh>

Returns the active database handle

=back

=cut
sub  getDbh
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getDbh","",__LINE__);
	return $obj->{dbh};
}



=pod

=over

=item B<querySth($query)>

Prepares and executes $query. Returns the active statement handle.

=back

=cut
sub  querySth
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"querySth","",__LINE__);
	my $query = shift;
	$obj->debug(NLIB_DL_SQL,"querySth","QUERY: ".$query,__LINE__);
	my $sth = $obj->{dbh}->prepare($query);
	$sth->execute();
	return $sth;
}


=pod

=over

=item B<do>



=back

=cut
sub do
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"do","",__LINE__);
	
	my $query = shift;
	$obj->debug(NLIB_DL_SQL,"do","QUERY-DO: ".$query,__LINE__);
	return $obj->{dbh}->do($query);
}




1;
