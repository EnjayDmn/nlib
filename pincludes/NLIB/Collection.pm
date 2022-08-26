package NLIB::Collection;

#
# $Id: Collection.pm,v 1.4 2013-12-10 13:06:03 nils-1327 Exp $
#

use strict;
use NLIB;
use NLIB::Constants;

use vars qw(@ISA);
@ISA = qw(NLIB::Object);

sub _init
{
	my $obj = shift;
	my %data = @_;
	$obj->SUPER::_init(%data);
	defined($data{data}) ? ($obj->{data} = $data{data}) : ($obj->{data} = undef);
}

sub count
{
	my $obj = shift;
	unless(defined($obj->{data})){return 0;}
	my $len = @$obj->{data};
	return $len;
}



1;
