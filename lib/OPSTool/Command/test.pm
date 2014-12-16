#ABSTRACT: tests things
package OPSTool::Command::test;

use Moose;
use Data::Dumper;

use Log::Log4perl qw/ get_logger /;
use Term::ANSIColor qw(:constants);

extends "MooseX::App::Cmd::Command";

use OPS;

sub execute {
    my $self = shift;
    my $ops = OPS->new_with_options();
    print Dumper($ops->config);
} ## end sub execute

1;

__END__

=head NAME

VMPTool::Command::install Installs VMP.

=cut

