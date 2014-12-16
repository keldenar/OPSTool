#ABSTRACT: OPSTool module for instantiating the tool.
package OPSTool;

use Moose;
extends qw(MooseX::App::Cmd);
with 'MooseX::Getopt';

sub usage_desc {
    return "OPSTool <command> [options]";
}

1;
