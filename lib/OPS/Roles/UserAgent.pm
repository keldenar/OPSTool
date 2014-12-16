#ABSTRACT: UserAgent specific calls
package OPS::Roles::UserAgent;

use Moose::Role;
use Data::Dumper;
use Log::Log4perl qw/get_logger/;

use LWP::UserAgent;
use HTTP::Request;

has ua_agent => (
    is => 'rw',
    isa => 'LWP::UserAgent',
    traits     => [ 'NoGetopt' ],
    lazy_build => 1,
);

has ua_request => (
    is => 'rw',
    isa => 'HTTP::Request',
    traits     => [ 'NoGetopt' ],
    lazy_build => 1,
);


sub _build_ua_agent {
    my $self = shift;
    my $tmp = LWP::UserAgent->new;
    $tmp->agent("OPS::Roles::UserAgent/1.0");
    $tmp->timeout(30);
    return $tmp;
}

sub _build_ua_request {
    my $self = shift;
    return HTTP::Request->new;
}


1;

