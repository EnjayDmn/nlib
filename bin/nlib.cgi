#!/usr/bin/perl -X -I../api -I../api/NLIB -I%%%MAKEFILE_NLIB_BASE%%%/pincludes

use strict;

use NLIB;
use NLIB::Constants;

my $app = new NLIB::Application(debug => (NLIB_DL_DEBUG|NLIB_DL_EXCEPTION|NLIB_DL_BIZ));
#my $app = new NLIB::Application(debug => (NLIB_DL_SESSION|NLIB_DL_DEBUG|NLIB_DL_METHOD|NLIB_DL_EXCEPTION|NLIB_DL_BIZ|NLIB_DL_SQL));
$app->run();
