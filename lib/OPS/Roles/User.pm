#ABSTRACT: Works with User input
package OPS::Roles::User;

use Moose::Role;
use Data::Dumper;
use Log::Log4perl qw/get_logger/;

sub user_continue {
    my $self = shift;
    my $tmp  = "";
    while ( $tmp !~ /^[yYnN]$/ ) {
        printf( "Continue (y/N): " );
        $tmp = <STDIN>;
    }
    if ( $tmp =~ /^(n|N)$/ ) {
        printf( "Exiting due to user input!\n" );
        get_logger->info( "Exiting due to user input!\n" );
        exit;
    }
}



1;
