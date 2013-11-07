package Clog::C::API;
use strict;
use warnings;
use Time::Piece;

sub event_create {
    my $c = shift;
    my $v = $c->form(
        title      => [[qw/NOT_NULL/], [qw/LENGTH 1 140/]],
        begin_time => [[qw/NOT_NULL DATETIME/]],
        end_time   => [[qw/NOT_NULL DATETIME/]],
        created_by => [[qw/NOT_NULL EMAIL/]],
        note       => [[qw/LENGTH 1 1600/]],
        tags       => [[qw/LENGTH 1 255/]],
    );

    return {status => 0, errors => [$v->get_error_messages]} if $v->has_error;

    my $data = $c->param->as_hashref;
    $data->{created_at} = localtime->strftime('%Y-%m-%d %H:%M:%S');
    $data->{updated_at} = $data->{created_at};
    
    my $row = $c->db->insert(event => $data);
    return {status => 1, row => $row};
}

sub event {
    my $c = shift;
    my $id = $c->path_param('id');
    { 
        status   => 1, 
        row      => $c->db->single(event => {id => $id}),
        comments => [$c->db->select(event_messages => {event_id => $id})],
    };
}

sub event_update {
    my $c = shift;
    my $id = $c->path_param('id');
    my $v = $c->form(
        title      => [[qw/LENGTH 1 140/]],
        begin_time => [[qw/DATETIME/]],
        end_time   => [[qw/DATETIME/]],
        note       => [[qw/LENGTH 1 1600/]],
        tags       => [[qw/LENGTH 1 255/]],
    );

    return {status => 0, errors => [$v->get_error_messages]} if $v->has_error;

    my $data = $c->param->as_hashref;
    $data->{updated_at} = localtime->strftime('%Y-%m-%d %H:%M:%S');
    $c->db->update(event => [ %$data ], {id => $id});

    my $row = $c->db->single(event => {id => $id});
    return $row ? 
        {status => 1, row => $row} : 
        {status => 0, errors => ['undefined event_id']}
    ;
}

sub event_delete {
    my $c = shift;
    my $id = $c->path_param('id');
    do {
        my $txn = $c->db->txn_scope;
        $c->db->delete(event_messages => {event_id => $id});
        $c->db->delete(event => {id => $id});
        $txn->commit;
    };
    return {status => 1};
}

sub comment_create {
    my $c = shift;
    my $id  = $c->path_param('id');
    my $v = $c->form(
        message => [[qw/NOT_NULL/], [qw/LENGTH 1 1600/]],
    );

    return {status => 0, errors => [$v->get_error_messages]} if $v->has_error;

    my $row = $c->db->insert(event_messages => {
        event_id   => $id,
        message    => $c->param('message'),
        created_at => localtime->strftime('%Y-%m-%d %H:%M:%S'),
    });
    return {status => 1, row => $row};
}

1;

