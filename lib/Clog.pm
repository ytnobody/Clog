package Clog;
use strict;
use warnings;
use File::Spec;
use utf8;

our $VERSION = 0.01;

use Nephia plugins => [
    'Otogiri',
    'FormValidator::Lite',
    'JSON',
    'View::Xslate' => {
        syntax => 'Kolon',
        path   => [File::Spec->catdir('view')],
    },
    'ResponseHandler',
    'Dispatch',
];

database_do <<'SQL';
CREATE TABLE IF NOT EXISTS event (
    id         INTEGER  PRIMARY KEY AUTOINCREMENT,
    title      TEXT     NOT NULL,
    begin_time DATETIME NOT NULL,
    end_time   DATETIME NOT NULL,
    created_by TEXT     NOT NULL,
    note       TEXT,
    tags       TEXT,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
);
SQL

database_do <<'SQL';
CREATE TABLE IF NOT EXISTS event_messages (
    id         INTEGER  PRIMARY KEY AUTOINCREMENT,
    event_id   INT      NOT NULL,
    message    TEXT     NOT NULL,
    created_at DATETIME NOT NULL
);
SQL

app {
    get  '/'                      => Nephia->call('C::Root#index');
    get  '/docs/api'              => Nephia->call('C::Docs#api');
    get  '/ical/recent'           => Nephia->call('C::ICal#recent');
    post '/api/event/new'         => Nephia->call('C::API#event_create');
    get  '/api/event/:id'         => Nephia->call('C::API#event');
    post '/api/event/:id'         => Nephia->call('C::API#event_update');
    del  '/api/event/:id'         => Nephia->call('C::API#event_delete');
    post '/api/event/:id/comment' => Nephia->call('C::API#comment_create');
};

1;

=encoding utf-8

=head1 NAME

Clog - Web Application that powered by Nephia

=head1 DESCRIPTION

An web application

=head1 SYNOPSIS

    use Clog;
    Clog->run;

=head1 AUTHOR

clever people

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Nephia>

=cut

