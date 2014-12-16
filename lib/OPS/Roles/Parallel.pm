#ABSTRACT: Parallel::ForkManager interface
package OPS::Roles::Parallel;

use Moose::Role;
use Data::Dumper;
use Log::Log4perl qw/get_logger/;

use Parallel::ForkManager;

has pm => (
    is => 'rw',
    isa => 'Parallel::ForkManager',
    lazy_build => 1,
    traits => [ 'NoGetopt' ],
);

sub _build_pm {
    my $self = shift;
    return Parallel::ForkManager->new($self->CHILDREN);
}

1;
