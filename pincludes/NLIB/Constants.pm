package NLIB::Constants;

#
# $Id: Constants.pm,v 1.13 2014-02-04 08:42:52 nils-1327 Exp $
#

use strict;
require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
NLIB_DL_NONE
NLIB_DL_METHOD
NLIB_DL_DEBUG
NLIB_DL_TEMPLATE
NLIB_DL_SQL
NLIB_DL_EXCEPTION
NLIB_DL_INSTANCE
NLIB_DL_VDEBUG
NLIB_DL_TABLE
NLIB_DL_SESSION
NLIB_DL_BIZ

NLIB_SUCCESS
NLIB_FALIURE

NLIB_TEMPLATE_DIR
NLIB_TEMPLATE_EXT
NLIB_TEMPLATE_DFLT
NLIB_EXCEPTION_TEMPLATE

NLIB_EXCEPTION_TYPE_DEFAULT
NLIB_EXCEPTION_TYPE_NO_TEMPLATE
NLIB_EXCEPTION_TYPE_DBERROR
NLIB_EXCEPTION_TYPE_TABLE_WITHOUT_NAME
NLIB_EXCEPTION_TYPE_TABLE_HAS_NO_COLUMNS
NLIB_EXCEPTION_TYPE_UNKONWN_SESSION_STYLE
NLIB_EXCEPTION_TYPE_UNKONWN_FLAVOUR
NLIB_EXCEPTION_TYPE_UNREGISTERED_FLOW_TYPE
NLIB_EXCEPTION_TYPE_WRONG_REQUEST_PARAMETER_STRUCTURE

NLIB_SESSION_TYPE_ANONYMOUS
NLIB_SESSION_TYPE_PERSONAL
NLIB_SESSION_TYPE_GROUP

NLIB_SESSION_STYLE_ACTION
NLIB_SESSION_STYLE_WEBFLOW

NLIB_SESSION_ANONYMOUS_USER

NLIB_DEFAULT_ANONYMOUS_ACTION
NLIB_DEFAULT_PERSONAL_ACTION
NLIB_DEFAULT_ANONYMOUS_WEBFLOW
NLIB_DEFAULT_PERSONAL_WEBFLOW

NLIB_SESSION_FLAVOUR_ANON_FLOW
NLIB_SESSION_FLAVOUR_ANON_ACT
NLIB_SESSION_FLAVOUR_PERS_FLOW
NLIB_SESSION_FLAVOUR_PERS_ACT

NLIB_REQUEST_TYPE_NONE
NLIB_REQUEST_TYPE_USER
NLIB_REQUEST_TYPE_AUTO
);

=pod

=head1 NAME

NLIB::Constants

=head1 SYNOPSIS

use NLIB::Constants;

=head1 DESCRIPTION

NLIB::Constants provides applicaiton constants. It is no object but a classic Exporter. 

Activate the vaious debug levels as OR'ed given to any (but recommended to NLIB::Application) constructor using the 'debug' parameter:

C<my $obj = new NLIB::Object(debug =E<gt> NLIB_DL_METHOD | NLIB_DL_TABLE);>

=head1 EXPORTED CONSTANTS

=head2 DEBUG LEVEL CLASSES

=over

=item NLIB_DL_NONE     

Dont output anything. 

=item NLIB_DL_METHOD   

The method flow is reported.

=item NLIB_DL_DEBUG    

Detailed debug info. Use for development only!

=item NLIB_DL_TEMPLATE

Report template operations.

=item NLIB_DL_SQL

Report SQL operations and queries.

=item NLIB_DL_EXCEPTION

Report when exceptions are thrown and raised. Doesn't report internal exception behaviour. For this you have to turn on NLIB_DL_DEBUG.

=item NLIB_DL_INSTANCE

Originally used to report instanciation of objects within _init. Not really used anymore.

=item NLIB_DL_VDEBUG

Verbose reporting. Use for development only.

=item NLIB_DL_TABLE

Report table object operations.

=item NLIB_DL_SESSION

Report Session operations

=item NLIB_DL_BIZ

The level to report user-friendly messages about the business logic.

=back

=cut
use constant NLIB_DL_NONE						=> 0x000;
use constant NLIB_DL_METHOD					=> 0x001;
use constant NLIB_DL_DEBUG					=> 0x002;
use constant NLIB_DL_TEMPLATE				=> 0x004;
use constant NLIB_DL_SQL						=> 0x008;
use constant NLIB_DL_EXCEPTION			=> 0x010;
use constant NLIB_DL_INSTANCE				=> 0x020;
use constant NLIB_DL_VDEBUG					=> 0x040;
use constant NLIB_DL_TABLE					=> 0x080;
use constant NLIB_DL_SESSION				=> 0x100;
use constant NLIB_DL_BIZ						=> 0x200;


=pod

=head2 EXIT STATES

I think the exit states are never used until today...

=over

=item NLIB_SUCCESS

Returns 0

=item NLIB_FAILURE

Always returns undef

=back

=cut
use constant NLIB_SUCCESS => 0x0;
use constant NLIB_FAILURE => undef;

=pod

=head2 DIRECTORIES AND TEMPLATES

=over

=item NLIB_TEMPLATE_DIR

The place where html (or any page) templates are found in target runtime env.

=item NLIB_TEMPLATE_EXT

The default template extension (.htm)

=item NLIB_TEMPLATE_DFLT

The default template to use when no other template is defined.

=item NLIB_EXCEPTION_TEMPLATE

The default template for exceptions.

=back

=cut
use constant NLIB_TEMPLATE_DIR => "%%%MAKEFILE_NLIB_BASE%%%/tpl";
use constant NLIB_TEMPLATE_EXT => ".htm";
use constant NLIB_TEMPLATE_DFLT => "nlibMainTemplate";
use constant NLIB_EXCEPTION_TEMPLATE => "nlibException";


=pod

=head2 EXCEPTION TYPES

=over

=item NLIB_EXCEPTION_TYPE_DEFAULT

The default exception if no other is specified.

=item NLIB_EXCEPTION_TYPE_NO_TEMPLATE

This exception is raised if no template is found. Because of the fact that an exception uses a template itself and to avoid deep recursion, a safeException will be raised in the case if the exception doesn't find its template as well. Usually this is the case when the template path isn't properly configured.

=item NLIB_EXCEPTION_TYPE_DBERROR

A database connection and communicatoion error has occurred. 

=item NLIB_EXCEPTION_TYPE_TABLE_WITHOUT_NAME

This exception is thrown if an NLIB::TableObject is instanciated without a table name it should refer to.

=item NLIB_EXCEPTION_TYPE_TABLE_HAS_NO_COLUMNS

This exception is raised when a table object acquires a table reference for a table that has no columns. This could also be an indicator for the non-existence of the specified table.

=item NLIB_EXCEPTION_TYPE_UNKNOWN_SESSION_STYLE

Raised if the session style is none of the registered session style types. See section B<SESSION STYLES> below.

=item NLIB_EXCEPTION_TYPE_UNKONWN_FLAVOUR

Indicates that an unknown session flavour type is used.

=item NLIB_EXCEPTION_TYPE_UNREGISTERED_FLOW_TYPE

The requested flow type during flow instanciation is not registered.

=item NLIB_EXCEPTION_TYPE_WRONG_REQUEST_PARAMETER_STRUCTURE

The structure of the request doesn't fit the requirements. This usually indicates that some request parameter is missing because it hasn't been encoded in the client.

=back

=cut
use constant NLIB_EXCEPTION_TYPE_DEFAULT 								=> 0x00000001;
use constant NLIB_EXCEPTION_TYPE_NO_TEMPLATE  					=> 0x00000002;
use constant NLIB_EXCEPTION_TYPE_DBERROR  							=> 0x00000004;
use constant NLIB_EXCEPTION_TYPE_TABLE_WITHOUT_NAME 		=> 0x00000008;
use constant NLIB_EXCEPTION_TYPE_TABLE_HAS_NO_COLUMNS 	=> 0x00000010;
use constant NLIB_EXCEPTION_TYPE_UNKONWN_SESSION_STYLE 	=> 0x00000020;
use constant NLIB_EXCEPTION_TYPE_UNKONWN_FLAVOUR 				=> 0x00000040;
use constant NLIB_EXCEPTION_TYPE_UNREGISTERED_FLOW_TYPE => 0x00000080;
use constant NLIB_EXCEPTION_TYPE_WRONG_REQUEST_PARAMETER_STRUCTURE => 0x00000100;

=pod

=head2 SESSION TYPES

=over

=item NLIB_SESSION_TYPE_ANONYMOUS

This type defines an anonymous session, i.e. when no user info is available and/or no user is logged in. This type is also used for public available areas.

=item NLIB_SESSION_TYPE_PERSONAL

This defines a session which is bound to a registered user.

=item NLIB_SESSION_TYPE_GROUP

You can think of a group session. Is it ever needed? I don't know. maybe, but not yet. :-)

=back

=cut
use constant NLIB_SESSION_TYPE_ANONYMOUS  => 0x01;
use constant NLIB_SESSION_TYPE_PERSONAL		=> 0x02;
use constant NLIB_SESSION_TYPE_GROUP			=> 0x04; # dont know if ever needed...

=pod

=head2 SESSION STYLES

=over

=item NLIB_SESSION_STYLE_ACTION

This is an action based session. The application is requested to do something. Maybe it does. Then, it delivers output.

=item NLIB_SESSION_STYLE_WEBFLOW

This defines a WebFlow based session. A web flow combines allowed actions that a user may or may not request the application to do.

=back

=cut

# The values have to correspond with the session type values in order to generate
# the appropriate session flavour.
use constant NLIB_SESSION_STYLE_ACTION => 0x08;
use constant NLIB_SESSION_STYLE_WEBFLOW => 0x10;




=pod

=head2 USER TYPES

=over

=item NLIB_SESSION_ANONYMOUS_USER

=back

=cut
use constant NLIB_SESSION_ANONYMOUS_USER => 0;


=pod

=head2 DEFAULT ACTION AND WEB FLOWS

=over

=item NLIB_DEFAULT_ANONYMOUS_ACTION

The default anonymous action, predefined during rollout.

=item NLIB_DEFAULT_PERSONAL_ACTION

The default personal action, predefined during rollout.

=item NLIB_DEFAULT_ANONYMOUS_WEBFLOW

The default anonymous webflow, predefined during rollout.

=item NLIB_DEFAULT_PERSONAL_WEBFLOW

The default personal webflow, predefined during rollout.

=back

=cut
use constant NLIB_DEFAULT_ANONYMOUS_ACTION    => "%%%MAKEFILE_DEFAULT_ANONYMOUS_ACTION%%%";
use constant NLIB_DEFAULT_PERSONAL_ACTION     => "%%%MAKEFILE_DEFAULT_PERSONAL_ACTION%%%";
use constant NLIB_DEFAULT_ANONYMOUS_WEBFLOW   => "%%%MAKEFILE_DEFAULT_ANONYMOUS_WEBFLOW%%%";
use constant NLIB_DEFAULT_PERSONAL_WEBFLOW    => "%%%MAKEFILE_DEFAULT_PERSONAL_WEBFLOW%%%";

=pod

=head2 SESSION FLAVOURS

Session flavours describe certain session type/ session style combinations.

=over

=item NLIB_SESSION_FLAVOUR_ANON_FLOW

=item NLIB_SESSION_FLAVOUR_ANON_ACT

=item NLIB_SESSION_FLAVOUR_PERS_FLOW

=item NLIB_SESSION_FLAVOUR_PERS_ACT

=back

=cut
use constant NLIB_SESSION_FLAVOUR_ANON_FLOW => (NLIB_SESSION_TYPE_ANONYMOUS | NLIB_SESSION_STYLE_WEBFLOW); # 17
use constant NLIB_SESSION_FLAVOUR_ANON_ACT  => (NLIB_SESSION_TYPE_ANONYMOUS | NLIB_SESSION_STYLE_ACTION);  #  9
use constant NLIB_SESSION_FLAVOUR_PERS_FLOW => (NLIB_SESSION_TYPE_PERSONAL | NLIB_SESSION_STYLE_WEBFLOW);  # 18
use constant NLIB_SESSION_FLAVOUR_PERS_ACT  => (NLIB_SESSION_TYPE_PERSONAL | NLIB_SESSION_STYLE_ACTION);   # 10


=pod

=head2 REQUEST TYPES

Different types of requests a client may send to the application.

=over 

=item NLIB_REQUEST_TYPE_NONE

Unknown or undefined request type

=item NLIB_REQUEST_TYPE_USER

If the user actively initiates the request.

=item NLIB_REQUEST_TYPE_AUTO

If the request is automatically triggered (I.e. while polling or other ajax status requests etc...)

=cut
use constant NLIB_REQUEST_TYPE_NONE => 0;
use constant NLIB_REQUEST_TYPE_USER => 1;
use constant NLIB_REQUEST_TYPE_AUTO => 2;

1;
