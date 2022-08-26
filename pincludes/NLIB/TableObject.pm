package NLIB::TableObject;

#
# $Id: TableObject.pm,v 1.13 2014-02-28 08:18:22 nils-1327 Exp $
#

=pod

=begin html

<a href="index.html#NLIB-TableObject">All Classes</a>

=end html

=head1 NAME

NLIB::TableObject

=head1 SYNOPSIS

B<construction:>

 my $obj = new NLIB::TableObject (%params);

B<private:>

 $obj->_init(%data);

B<public:>

 DOCSYNOPSIS

=head1 DESCRIPTION

This is the base class for all TableObjects. 

A TableObject has to know about its corresponding table. You can specify the table name with the 'table' parameter in the constructor. By default, any table that corresponds with a TableObject must have a primary key field named 'id'. The 'id' field must be the first column within the table. If the id is known you can specify the id in the constructor with the 'id' parameter. If the id is given, a reference to the row specified by the id is acquired during construction. If no id is given, a  new data set will be created along with a new id. This will also be the case if the spcified id doesn't exist. 

Use the 'getset' method to set or get values from the object and database. Getting a value means requesting the value of the specified field (column name) from the current active table reference. Setting a value updates the corresponding database field immediately. However, the reference then is out of date and the reference is in out-of-date status. It needs to be updated to return the new value from database upon request. For this could rise up the database traffic you can control the update process with the 'autoupdate' parameter. If 'autoupdate' is on (i.e. "1", which is on by default), the reference is updated directly after database update. If 'autoupdate' is off you either have to update the reference manually using the 'updateReference' method, or, if not updated yet, the updateRequest method will be called the next time a parameter is requested and the reference is in outdated state. 

It is up to subclasses to implement appropriate accessors for the individual table fields. 

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

  defined($data{table}) ? ($obj->{table} = $data{table}) : ($obj->{table} = undef);
	unless(defined($obj->{table})){
		my $e = new NLIB::Exception(etype => NLIB_EXCEPTION_TYPE_TABLE_WITHOUT_NAME, error => ref($obj).": A table object needs a table name.", app => $obj->getApp());
		$e->raiseException();
	}
  defined($data{dbc}) ? ($obj->{dbc} = $data{dbc}) : ($obj->{dbc} = $obj->getApp()->getDbc());

	# The active table reference
  defined($data{ref}) ? ($obj->{ref} = $data{ref}) : ($obj->{ref} = undef);

	# The table fields of this table	
  defined($data{colindex}) ? ($obj->{colindex} = $data{colindex}) : ($obj->{colindex} = undef);
  defined($data{colnames}) ? ($obj->{colnames} = $data{colnames}) : ($obj->{colnames} = undef);
  defined($data{numcols}) ? ($obj->{numcols} = $data{numcols}) : ($obj->{numcols} = 0);

  defined($data{create}) ? ($obj->{create} = $data{create}) : ($obj->{create} = 1);

  defined($data{autoupdate}) ? ($obj->{autoupdate} = $data{autoupdate}) : ($obj->{autoupdate} = 1);
  defined($data{outdated}) ? ($obj->{outdated} = $data{outdated}) : ($obj->{outdated} = 0);
  defined($data{is_fresh}) ? ($obj->{is_fresh} = $data{is_fresh}) : ($obj->{is_fresh} = 0);

	# The reference id to the table object
  defined($data{id}) ? ($obj->{id} = $data{id}) : ($obj->{id} = undef);

	# The column and its value to use for connection setup instead of an id. This must be an array reference of a single name/ value pair.
  defined($data{col}) ? ($obj->{col} = $data{col}) : ($obj->{col} = undef);

	$obj->_getColInfo();
	if($obj->{numcols} == 0){
		my $e = new NLIB::Exception( etype => NLIB_EXCEPTION_TYPE_TABLE_HAS_NO_COLUMNS, error => (ref($obj)).": The reference table '".$obj->getTable()."' seems to have no columns. Does the table exist?", app => $obj->getApp());
		$e->raiseException();
	}
	#$obj->debug(NLIB_DL_DEBUG,"init","Going to instanciate TableObject ".$obj->{table}.": ".(defined($obj->{col})? (join("'",@{$obj->{col}})) : "NIX"),__LINE__);
	$obj->_setupConnection();
}



=pod

=over

=item B<getId>

Retrieve the TableObject id.

=back

=cut
sub  getId
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getId","",__LINE__);
	return $obj->{id};
}


=pod

=over

=item B<getset($colnam,[$newval])>

A method to get or set/ update a single column value.

=back

=cut
sub  getset
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getset","",__LINE__);
	my $colnam = shift || undef;
	my $newval = shift;
# return current value only
  
	unless (defined($colnam)){
		$obj->debug(NLIB_DL_DEBUG,"getset","Error: Need column name as first parameter.",__LINE__);
		return undef;
	}

	unless (defined($newval)){
		if($obj->{outdated} == 1){
			$obj->debug(NLIB_DL_TABLE,"getset","Object is out of date. Updating reference.",__LINE__);
			unless(defined($obj->updateReference())){
				$obj->debug(NLIB_DL_DEBUG,"getset","Update reference failed.",__LINE__);
				return undef;
			}
		}
		$obj->debug(NLIB_DL_TABLE,"getset","No new value for column given, going to return value only (if any)",__LINE__);
		my $ri = $obj->{colnames}->{$colnam};
		my $r = $obj->{ref}->[$ri-1];
		$obj->debug(NLIB_DL_TABLE,"getset","Returning from index '$colnam', colindex '$ri': '$r'",__LINE__);
    return $r;
  }
	
	$obj->debug(NLIB_DL_TABLE,"getset","Going to set new column value: ".$colnam.", ".$newval,__LINE__);

	my $dbh = $obj->getDbh();
  my $update = "update ".$obj->getTable()." set ".$colnam."='".$newval."' where id = '".$obj->{id}."'";
  unless(defined($dbh->do($update))){
		$obj->debug(NLIB_DL_DEBUG,"getset","Error updating table: ".$DBI::errstr,__LINE__);
		# TODO: check if to return here...
	}
	$obj->{outdated} = 1;

	if($obj->autoupdate() == 1){
		unless(defined($obj->updateReference())){
			$obj->debug(NLIB_DL_DEBUG,"getset","Update reference failed.",__LINE__);
			return undef;
		}
	}
}





=pod

=over

=item B<get($lo-fileds,$lo-return)>

Retrieve multiple field values as array. The param 'lo-fields' is an array reference of desired field values. The array reference lo-return will hold the values returned by the request.

=back

=cut
sub  get
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"get","",__LINE__);
	my $fields = shift;
	my $return = shift;
	foreach my $field(@$fields){
		push @$return, $obj->getset($field);
	}
}


=pod

=over

=item B<set(%keyval)>

Set one or more values.

=back

=cut
sub  set
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"set","",__LINE__);
	my %params = @_;
	#print STDERR join(",",@_);

	my $austate = $obj->autoupdate();
	if($obj->autoupdate() == 1){$obj->autoupdate(0);}
	foreach my $k(keys %params){
		$obj->debug(NLIB_DL_TABLE,"set","Setting key/val: $k => ".$params{$k},__LINE__);
		$obj->getset($k,$params{$k});
	}
	unless(defined($obj->updateReference())){
		$obj->debug(NLIB_DL_DEBUG,"set","Update reference failed.",__LINE__);
		return undef;
	}
	if($austate == 1){$obj->autoupdate(1);}
}




=pod

=over

=item B<autoupdate([0|1])>

Get and/or set autoupdate switch.

=back

=cut
sub  autoupdate
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"autoupdate","",__LINE__);
	my $onoff = shift;
	if(defined($onoff)){$obj->{autoupdate} = $onoff;}
	$obj->debug(NLIB_DL_TABLE,"autoupdate","Autoupdate is turned ".(($obj->{autoupdate} == 1) ? "ON" : "OFF"),__LINE__);
	return $obj->{autoupdate};
}






=pod

=over

=item B<_getColInfo>



=back

=cut
sub  _getColInfo
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"_getColInfo","",__LINE__);
	my $sth1 = $obj->getDbh()->column_info( undef, undef, $obj->getTable(), undef );
	my $ref1 = $sth1->fetchall_arrayref();
	my $numcols = scalar(@$ref1);
	$obj->{numcols} = $numcols;
	$obj->debug(NLIB_DL_TABLE,"_getColInfo","Table has ".$obj->{numcols}." columns",__LINE__);

	# Register column names and positions NOTE: 1-based, as mentioned in DBI(3pm)!
	foreach my $inf(@$ref1){
		$obj->{colindex}->[$inf->[16]] = $inf->[3];
		$obj->{colnames}->{$inf->[3]} = $inf->[16];
	}
}



=pod

=over

=item B<_setupConnection>

I<INTERNAL> Set up the table connection for this object.

=back

=cut
sub  _setupConnection
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"_setupConnection","",__LINE__);

	my $dbh = $obj->getDbh();

	# If we had passed an id to the consrtuctor we try to acquire the table reference by id.
	if(defined($obj->{id}))
	{
		$obj->debug(NLIB_DL_TABLE,"_setupConnection","Having id, try to acquire reference for id ".$obj->{id},__LINE__);
		my $selid = "select * from ".$obj->getTable()." where id = ".$obj->{id}." limit 1";
		my $sthid = $dbh->prepare($selid);
		$sthid->execute();
		if($sthid->rows == 1){
			$obj->{ref} = $sthid->fetchrow_arrayref();
			$obj->debug(NLIB_DL_TABLE,"_setupConnection","Found reference: ".$obj->{ref}->[0],__LINE__);
			# we can savely return here.
			$obj->{is_fresh} = 0;
			return;
		}
		else{
			$obj->debug(NLIB_DL_TABLE,"_setupConnection","Found no reference for id ".$obj->{id},__LINE__);
			$obj->debug(NLIB_DL_TABLE,"_setupConnection","Resetting id and going to acquire new reference with new id.",__LINE__);
			$obj->{id} = undef;
		}
	}
	# We dont use id as setup indicator bit another column name
	elsif(defined($obj->{col}))
	{
		$obj->debug(NLIB_DL_TABLE,"_setupConnection","Having no id but col parameter, try to acquire reference by column ".$obj->{col}->[0].", ".$obj->{col}->[1],__LINE__);
		
		# we just get the first we found, because we expect this indicator to be an indicator ;-)
		#my $selc = "select * from ".$obj->getTable()." where ".$obj->{col}->[0]." = '".$obj->{col}->[1]."' limit 1"; 
		my $selc = "select * from ".$obj->getTable()." where ";
		for(my $i = 0; $i < (@{$obj->{col}}); $i+=2){
			$selc .= $obj->{col}->[$i]." = '".$obj->{col}->[$i+1]."' and "; 
		}
		$selc =~ s/and\ $/limit\ 1/;
		$obj->debug(NLIB_DL_SQL,"_setupConnection","SELECT: $selc",__LINE__);
		my $sthc = $dbh->prepare($selc);
		$sthc->execute();
		if($sthc->rows == 1){
			$obj->{ref} = $sthc->fetchrow_arrayref();
			$obj->debug(NLIB_DL_TABLE,"_setupConnection","Found reference by column/value: ".$obj->{ref}->[0],__LINE__);
			$obj->{id} = $obj->{ref}->[0]; # to keep in sync
			$obj->{is_fresh} = 0;
			# we can savely return here.
			return;
		}
		else{
			$obj->debug(NLIB_DL_TABLE,"_setupConnection","Found no reference by column/value".$obj->{id},__LINE__);
			$obj->debug(NLIB_DL_TABLE,"_setupConnection","Resetting col param and going to acquire new reference with new id.",__LINE__);
			$obj->{col} = undef;
		}
	}
	
	unless(defined($obj->{ref}))
	{
		
		$obj->debug(NLIB_DL_TABLE,"_setupConnection","No reference, acquiring new one...",__LINE__);
		# retrieve table info
		if($obj->{create} == 0){
			$obj->debug(NLIB_DL_TABLE,"_setupConnection","Create flag not set, wont create new data set. You should either recreate data set or destroy the object.",__LINE__);
			return undef;
		}
    
		my $insert = "insert into ".$obj->getTable()." values(";
		for(0..$obj->{numcols}-1){ $insert .= "'',"; }
		chop $insert;
		$insert .= ")";

		$obj->{is_fresh} = 1;
    
		$obj->debug(NLIB_DL_TABLE,"_setupConnection","Doing insert: ".$insert,__LINE__);
		# store new row
		unless($dbh->do($insert)){
			$obj->debug(NLIB_DL_TABLE,"_setupConnection","Insert failed: ".$DBI::errstr,__LINE__);
		}

    my $sl = "select * from ".$obj->getTable()." where id=LAST_INSERT_ID()";
		$obj->debug(NLIB_DL_TABLE,"_setupConnection","Retrieving stored reference: ".$sl,__LINE__);
    
		my $sthsl = $dbh->prepare($sl);
    $sthsl->execute();
    $obj->{ref} = $sthsl->fetchrow_arrayref();
		$obj->{id} = $obj->{ref}->[0];
		$obj->debug(NLIB_DL_TABLE,"_setupConnection","Having new reference with id ".$obj->{id},__LINE__);
  }
	
}

=pod

=over

=item B<isFresh>

Returns 1 if the object has freshly been created.

=back

=cut
sub isFresh
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"isFresh","",__LINE__);

	return $obj->{is_fresh};
}


=pod

=over

=item B<updateReference>

Retrieve latest information from database.

=back

=cut
sub  updateReference
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"updateReference","",__LINE__);

	if(defined($obj->{id}))
	{
		$obj->debug(NLIB_DL_TABLE,"updateReference","Having id, try to acquire reference for id ".$obj->{id},__LINE__);
		my $selid = "select * from ".$obj->getTable()." where id = ".$obj->{id}." limit 1";
		my $dbh = $obj->getDbh();
		my $sthid = $dbh->prepare($selid);
		$sthid->execute();
		if($sthid->rows == 1){
			$obj->{ref} = $sthid->fetchrow_arrayref();
			$obj->debug(NLIB_DL_TABLE,"updateReference","Found reference: ".$obj->{ref}->[0],__LINE__);
			
			# Object now is up-to-date
			$obj->{outdated} = 0; 
			
			# We can safely return a defined value here.
			return $obj->{id};
		}
		else{
			$obj->debug(NLIB_DL_TABLE,"updateReference","No reference found for id ".$obj->{id}.". Check if the table connection has been set up correctly!",__LINE__);
			return undef;
		}
	}
	else
	{
		$obj->debug(NLIB_DL_TABLE,"updateReference","No id. Unable to update reference without id.",__LINE__);
		return undef;
	}
	
}


=pod

=over

=item B<getDbh>

Returns the active database handle from the NLIB database connector.

=back

=cut
sub  getDbh
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getDbh","",__LINE__);

	$obj->{dbc}->getDbh();
}

=pod

=over

=item B<getTable>

Retrieve the table name.

=back

=cut
sub  getTable
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"getTable","",__LINE__);
	return $obj->{table};
}


=pod

=over

=item B<toJson>



=back

=cut
sub  toJson
{
	my $obj = shift;
	$obj->debug(NLIB_DL_METHOD,"toJson","",__LINE__);
	my $json = shift;

  my $selT = "describe ".$obj->{table};
  my $sthT = $obj->querySth($selT);
  if($sthT->rows){
		
    while(my $refT = $sthT->fetchrow_arrayref()){
      $obj->debug(NLIB_DL_DEBUG,"toJson","DESCRIBE: ".$refT->[0],__LINE__);
			$json->{$refT->[0]} = $obj->getset($refT->[0]);
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
