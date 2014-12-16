#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

use FindBin;

BEGIN {
        unshift @INC, "$FindBin::Bin/../lib";
    }


use OPSTool;
OPSTool->run;
