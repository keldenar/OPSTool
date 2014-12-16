#ABSTRACT: Loads configuration data
package OPS::Roles::Config;

use Moose::Role;
use Data::Dumper;
use Log::Log4perl qw/get_logger/;
use Config::General qw/ParseConfig/;
use File::Copy;

with 'MooseX::Getopt';

has name => (
    documentation => 'A config name.',
    is            => 'rw',
    isa           => 'Str',
    required      => 1,
);

has config => (
    traits     => [ 'NoGetopt' ],
    is         => 'rw',
    isa        => 'Ref',
    lazy_build => 1,
);

has CHILDREN => (
    documentation => 'Number of children to fork. (Default: 30)',
    is            => 'rw',
    isa           => 'Int',
    default       => 30,
);

has log_level => (
    documentation => 'Override log level "DEBUG", "INFO", "WARN", "ERROR", "FATAL"',
    is => 'rw',
    isa => 'Str',
    default => 0,
    trigger => \&change_log_level,
);

has config_dir => (
    documentation => 'Change configuration directory. (Default: /home/bcombast/src/OPSTool/CONFIG)',
    is            => 'ro',
    isa           => 'Str',
    default       => '/home/bcombast/src/OPSTool/CONFIG/',
);


sub change_log_level {
    # This is bad and needs to be fixed
    my $self = shift;
    use Log::Log4perl::Level;
    get_logger( "" )->level( ${$self->log_level} );
}
    
sub _build_config {
    my $self    = shift;
    my %options = ParseConfig(
        -ConfigFile => $self->config_dir . $self->name . ".cfg",
        -ForceArray => 1,
    );
    return \%options;
}


sub config_array {
    my $self = shift;
    my $array = [];
    my $type = shift;
    my $name = shift;
    foreach my $entry (@{ $self->config->{$type}->{$name} } ) {
        push(@{$array}, $entry);
    }
    return $array;
}

sub update_config {
    my $self = shift;
    my $new = $self->config_dir . $self->name . ".cfg.new";
    my $old = $self->config_dir . $self->name . ".cfg.old";
    my $current = $self->config_dir . $self->name . ".cfg";
    get_logger->debug("Copying files.");

    if (-e $new) {
        get_logger->trace("Copying current -> old");
        copy($current, $old);
        get_logger->trace("Copying new -> current");
        copy($new, $current);
        unlink($new);
        $self->reconfig;
    }
}

sub reconfig {
    my $self = shift;
    $self->config($self->_build_config);
}


1;
