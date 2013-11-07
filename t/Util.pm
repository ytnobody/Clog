package t::Util;
use strict;
use warnings;
use File::Temp 'tempdir';
use File::Spec;
use parent qw(Exporter);

our @EXPORT = qw/test_config/;

my $dbdir = tempdir(CLEANUP => 1);
my $testdb = File::Spec->catfile($dbdir, 'clog_test.sqlite3');

sub test_config {
    ( 
        DBI => {
            connect_info => [ "dbi:SQLite:dbname=$testdb", "", "" ],
        },
        'Plugin::FormValidator::Lite' => {
            function_message => 'en',
            constants        => [qw/Email +Clog::Validator::Constraint/],
        },
    );
}

1;
