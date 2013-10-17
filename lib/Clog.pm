package Clog;
use strict;
use warnings;
use File::Spec;
use Time::Piece;
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
    get '/' => sub {
        my @rows = db->select(event => {}, {order_by => 'id DESC'});
        {template => 'index.tx', appname => 'Clog', rows => \@rows};
    };

    post '/api/event/new' => sub {
        my $v = form(
            title      => [[qw/NOT_NULL/], [qw/LENGTH 1 140/]],
            begin_time => [[qw/NOT_NULL DATETIME/]],
            end_time   => [[qw/NOT_NULL DATETIME/]],
            created_by => [[qw/NOT_NULL EMAIL/]],
            note       => [[qw/LENGTH 1 1600/]],
            tags       => [[qw/LENGTH 1 255/]],
        );

        return {status => 0, errors => [$v->get_error_messages]} if $v->has_error;

        my $data = param->as_hashref;
        $data->{created_at} = localtime->strftime('%Y-%m-%d %H:%M:%S');
        $data->{updated_at} = $data->{created_at};
        
        my $row = db->insert(event => $data);
        return {status => 1, row => $row};
    };

    get '/api/event/:id' => sub {
        my $id = path_param('id');
        { 
            status   => 1, 
            row      => db->single(event => {id => $id}),
            comments => [db->select(event_messages => {event_id => $id})],
        };
    };

    post '/api/event/:id' => sub {
        my $id = path_param('id');
        my $v = form(
            title      => [[qw/LENGTH 1 140/]],
            begin_time => [[qw/DATETIME/]],
            end_time   => [[qw/DATETIME/]],
            note       => [[qw/LENGTH 1 1600/]],
            tags       => [[qw/LENGTH 1 255/]],
        );

        return {status => 0, errors => [$v->get_error_messages]} if $v->has_error;

        my $data = param->as_hashref;
        $data->{updated_at} = localtime->strftime('%Y-%m-%d %H:%M:%S');
        db->update(event => [ %$data ], {id => $id});

        my $row = db->single(event => {id => $id});
        return $row ? 
            {status => 1, row => $row} : 
            {status => 0, errors => ['undefined event_id']}
        ;
    };

    del '/api/event/:id' => sub {
        my $id = path_param('id');
        do {
            my $txn = db->txn_scope;
            db->delete(event_messages => {event_id => $id});
            db->delete(event => {id => $id});
            $txn->commit;
        };
        return {status => 1};
    };

    post '/api/event/:id/comment' => sub {
        my $id  = path_param('id');
        my $v = form(
            message => [[qw/NOT_NULL/], [qw/LENGTH 1 1600/]],
        );

        return {status => 0, errors => [$v->get_error_messages]} if $v->has_error;

        my $row = db->insert(event_messages => {
            event_id   => $id,
            message    => param('message'),
            created_at => localtime->strftime('%Y-%m-%d %H:%M:%S'),
        });
        return {status => 1, row => $row};
    };
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

