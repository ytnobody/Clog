use strict;
use warnings;
use File::Spec;
use File::Basename 'dirname';

+{
    DBI => {
        connect_info => [ "dbi:SQLite:dbname=clog.sqlite3", "", "" ],
    },
    'Plugin::FormValidator::Lite' => {
        function_message => 'en',
        constants        => [qw/Email +Clog::Validator::Constraint/],
    },
};
