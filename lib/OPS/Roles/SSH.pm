package OPS::Roles::SSH;

use Moose::Role;
use Data::Dumper;
use Net::OpenSSH;
use Log::Log4perl qw / get_logger /;

has ssh => (
    traits  => [ 'NoGetopt' ],
    is         => 'rw',
    isa        => 'Net::OpenSSH',
    lazy_build => 1,
);

has tty => (
    traits  => [ 'NoGetopt' ],
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has server => (
    traits  => [ 'NoGetopt' ],
    is      => 'rw',
    isa     => 'Str',
    default => "",
);

has return_val => (
    traits  => [ 'NoGetopt' ],
    is      => 'rw',
    isa     => 'Str',
);

has error_val => (
    traits  => [ 'NoGetopt' ],
    is      => 'rw',
    isa     => 'Str',
);


before [ qw(execute_on_server_safe execute_on_server_unsafe) ] => \&_server_set;
after  [ qw(execute_on_server_safe execute_on_server_unsafe) ] => \&_check_errors;

sub _check_errors {
    my $self = shift;
    if (( $self->ssh->error ) && ($self->error_val ne "")) {
        # I consider this non fatal ex. yum check-update exits w/100 if there are updates.
        my $error = sprintf( "%s:%s", $self->server, $self->ssh->error );
        get_logger->error( $error );
    }
}

sub _server_set {
    my $self = shift;
    if ( $self->server eq "" ) {
        get_logger->error( "No server defined." );
        die "No server defined.";
    }
    $self->ssh( Net::OpenSSH->new( $self->server ) );
    $self->return_val("");
    $self->error_val("");
}

# Takes an array for a single call or something I don't know
sub execute_on_server_safe {
    my $self    = shift;
    my $command = shift;
    my @args    = @_;
    my ( $ret, $err ) = $self->ssh->capture2( { tty => $self->tty }, $command, @args );
    $self->return_val($ret);
    $self->error_val($err);
}

# Takes a string and well whatever
sub execute_on_server_unsafe {
    my $self    = shift;
    my $command = shift;
    my ( $ret, $err ) = $self->ssh->capture2( { tty => $self->tty }, $command );
    $self->return_val($ret);
    $self->error_val($err);
}

1;
