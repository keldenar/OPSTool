#ABSTRACT: Main OPS Module ##### This is really just a stub for the test module to show how it works.
package OPS;

use Moose;

use Log::Log4perl qw/get_logger/;

with 'MooseX::Getopt';
with "OPS::Roles::Config";
with "OPS::Roles::Parallel";
with "OPS::Roles::SSH";
with 'OPS::Roles::User';
with 'OPS::Roles::Yum';
with 'OPS::Roles::Process';
with 'OPS::Roles::UserAgent';

sub BUILD {
    my $self    = shift;

    my $CONF    = <<EOF;

    log4perl.rootLogger                                   = DEBUG, Screen, OPS

    log4perl.appender.Screen.layout                       = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.Screen.layout.ConversionPattern     = [%d] %p %C (Line: %L) [pid:%P] %m%n
    log4perl.appender.Screen                              = Log::Log4perl::Appender::Screen

    log4perl.appender.OPS                          = Log::Log4perl::Appender::File
    log4perl.appender.OPS.filename                 = /var/log/OPS.log
    log4perl.appender.OPS.layout                   = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.OPS.layout.ConversionPattern = [%d] [%P] %X{ip} %X{session_id} %p %c [%l] %m{chomp}%n
    log4perl.appender.OPS.mode                     = append
    log4perl.appender.OPS.syswrite                 = 1
    log4perl.appender.OPS.utf8                     = 1

EOF

    Log::Log4perl::init( \$CONF );
} ## end sub BUILD

1;
