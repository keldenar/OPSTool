#ABSTRACT: Works with Yum on the server
package OPS::Roles::Yum;

use Moose::Role;
use Data::Dumper;
use Log::Log4perl qw/get_logger/;

has packages => (
    is     => 'rw',
    isa    => 'HashRef',
    traits => [ 'NoGetopt' ],
);

has RPMS => (
    is     => 'rw',
    isa    => 'HashRef',
    traits => [ 'NoGetopt' ],
);

sub check_updates {
    my $self = shift;
    my $servers = shift;
    my %RPMS;
    get_logger->debug("Checking for yum updates.");

    $self->pm->run_on_start();
    $self->pm->run_on_wait();
    $self->pm->run_on_finish(
        sub {
            my ( $pid, $exit_code, $ident, $exit_signal, $core_dump, $data_structure_reference ) = @_;
            if ( defined( $data_structure_reference ) ) {
                @RPMS{ keys %{$data_structure_reference} } = values %{$data_structure_reference};
            }
        }
    );

    foreach my $server ( @{$servers} ) {
        get_logger->trace("Checking yum updates: $server");
        $self->pm->start( $server ) and next;
        $self->server( $server );
        $self->execute_on_server_safe( "yum", "-q", "check-update" );
        %RPMS = $self->process_yum_check;
        $self->pm->finish( 0, \%RPMS );
    }
    $self->pm->wait_all_children;
    $self->RPMS( \%RPMS );
} ## end sub check_updates

sub process_yum_check {
    my $self = shift;
    my $RPMS = {};

    foreach my $line ( split( /\n/, $self->return_val ) ) {
        next if $line =~ /^$/;
        $line =~ s/\s+/ /g;    # turn all white space into a single space
        my ( $rpm, $version, $repo ) = split( / /, $line );
        $RPMS->{ $self->server }->{$rpm}->{version} = $version;
        $RPMS->{ $self->server }->{$rpm}->{repo}    = $repo;
    }
    return %{$RPMS};
}

sub show_updates {
    my $self = shift;
    my %RPMS;
    print "The following packages will be updated:\n";
    printf( "%-30.30s %-20.20s %-20.20s %-20.20s\n", "Package", "Version", "Repo", "Servers Effected" );
    foreach my $server ( keys %{ $self->RPMS } ) {
        foreach my $rpm ( keys %{ $self->RPMS->{$server} } ) {
            $RPMS{$rpm}->{version} = $self->RPMS->{$server}->{$rpm}->{version};
            $RPMS{$rpm}->{repo}    = $self->RPMS->{$server}->{$rpm}->{repo};
            $RPMS{$rpm}->{count} += 1;
        }
    }
    foreach my $rpm ( sort keys %RPMS ) {
        printf(
            "%-30.30s %-20.20s %-20.20s %-20.20s\n",
            $rpm,
            $RPMS{$rpm}->{version},
            $RPMS{$rpm}->{repo},
            $RPMS{$rpm}->{count}
        );
    }

}

sub yum_clean_servers {
    my $self    = shift;
    my $servers = shift;
    get_logger->debug("Running yum clean.");
    foreach my $server ( @{$servers} ) {
        get_logger->trace("Cleaning: $server");
        $self->pm->start( $server ) and next;
        $self->server( $server );
        $self->execute_on_server_safe( "yum", "-q", "clean", "all" );
        $self->pm->finish( 0 );
    }
    $self->pm->wait_all_children;
}

sub yum_update_servers {
    my $self    = shift;
    my $servers = shift;
    get_logger->debug("Running yum update.");
    foreach my $server ( @{$servers} ) {
        get_logger->trace("Updating: $server");
        $self->pm->start( $server ) and next;
        $self->server( $server );
        get_logger->trace(sprintf("Running: %s %s %s %s","yum", "-q", "-y", "update" ));
        $self->execute_on_server_safe( "yum", "-q", "-y", "update" );
#        $self->execute_on_server_safe( "yum", "-q", "-y", "update" );
        $self->pm->finish( 0 );
    }
    $self->pm->wait_all_children;
}

sub yum_remove_rpms {
    my $self    = shift;
    my $servers = shift;
    my $rpms    = shift;

    get_logger->debug("Removing rpms.");
    foreach my $server ( @{$servers} ) {
        get_logger->trace("Updating: $server");
        $self->pm->start( $server ) and next;
        $self->server( $server );
        $self->_remove_rpms( $rpms );
        $self->pm->finish( 0 );
    }
    $self->pm->wait_all_children;
}

sub _remove_rpms {
    my $self = shift;
    my $rpms = shift;
    foreach my $rpm ( @{$rpms} ) {
        get_logger->trace("Removing: $rpm");
        $self->execute_on_server_safe("yum", "-q", "-y", "remove", "$rpm");
    }
}

sub yum_install_rpms {
    my $self    = shift;
    my $servers = shift;
    my $rpms    = shift;

    get_logger->debug("Installing rpms.");
    foreach my $server ( @{$servers} ) {
        get_logger->trace("Server: $server");
        $self->pm->start( $server ) and next;
        $self->server( $server );
        $self->_install_rpms( $rpms );
        $self->pm->finish( 0 );
    }
    $self->pm->wait_all_children;
}

sub _install_rpms {
    my $self = shift;
    my $rpms = shift;
    foreach my $rpm ( @{$rpms} ) {
        get_logger->trace("Installing: " . $self->server . ": " . $rpm);

        $self->execute_on_server_safe("yum", "-q", "-y", "install", "$rpm");
    }
}

1;
