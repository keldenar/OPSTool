#ABSTRACT: Process controll functions
package OPS::Roles::Process;

use Moose::Role;
use Data::Dumper;
use Log::Log4perl qw/get_logger/;

has proc_list => (
    is  => 'rw',
    isa => 'HashRef',
);

before 'kill_process' => \&get_processes;

sub start_process {
    my $self    = shift;
    my $service = shift;
    get_logger->debug("Starting: ". $self->server . ": ". $service);
    $self->execute_on_server_safe("service", $service, "start");
}

sub stop_process {
    my $self    = shift;
    my $service = shift;
    get_logger->debug("Stopping: ". $self->server . ": ". $service);
    $self->execute_on_server_safe("service", $service, "stop");
}

sub kill_process {
    my $self    = shift;
    my $command = shift;
    my $args    = shift;
    get_logger->debug("Killing: $command $args");
    foreach my $pid ( keys %{ $self->proc_list } ) {
        if ( $self->proc_list->{$pid}->{command} =~ /$command/ ) {
            if ( ( defined $args ) && ( $self->proc_list->{$pid}->{args} =~ /$args/ ) ) {
                $self->execute_on_server_safe("kill", "-9", $pid);
            } elsif ( !defined $args ) {
                $self->execute_on_server_safe("kill", "-9", $pid);
            }
        }
    }
}

sub get_processes {
    my $self = shift;
    $self->execute_on_server_safe( "ps", "auwx" );
    $self->_process_ps;
}

sub _process_ps {
    my $self = shift;
    my $ps   = {};

    foreach my $line ( split( /\n/, $self->return_val ) ) {
        $line =~ s/\s+/ /g;
        my ( $user, $pid, $cpu, $mem, $vsz, $rss, $tty, $stat, $start, $time, $command, $args ) =
            split( / /, $line, 12 );
        $ps->{$pid}->{user}    = $user;
        $ps->{$pid}->{command} = $command;
        $ps->{$pid}->{args}    = $args;
        $ps->{$pid}->{cpu}     = $cpu;
        $ps->{$pid}->{mem}     = $mem;
        $ps->{$pid}->{vsz}     = $vsz;
        $ps->{$pid}->{rss}     = $rss;
        $ps->{$pid}->{tty}     = $tty;
        $ps->{$pid}->{stat}    = $stat;
        $ps->{$pid}->{start}   = $start;
        $ps->{$pid}->{time}    = $time;
    }
    $self->proc_list( $ps );
}

1;

