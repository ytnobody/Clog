package Clog::C::ICal;
use strict;
use warnings;
use utf8;
use Data::ICal;
use Data::ICal::DateTime;
use Data::ICal::Entry::Event;
use Time::Piece;
use DateTime;
use Encode;

sub recent {
    my $c = shift;
    my $ical   = Data::ICal->new;
    my $limit  = $c->param('limit') || 50;
    my $offset = $c->param('offset') || 0;
    my @rows   = $c->db->select(event => {}, {order => 'begin_time DESC', limit => $limit, offset => $offset});
    for my $row (@rows) {
        my $event      = Data::ICal::Entry::Event->new;
        my $begin_time = Time::Piece->strptime($row->{begin_time}, '%Y-%m-%d %H:%M:%S');
        my $end_time   = Time::Piece->strptime($row->{end_time}, '%Y-%m-%d %H:%M:%S');
        $event->add_properties(
            summary     => $row->{title},
            description => $row->{note},
            dtstart     => DateTime->from_epoch(epoch => $begin_time->epoch),
            dtend       => DateTime->from_epoch(epoch => $end_time->epoch),
        );
        $ical->add_entry($event);
    }
    [200, ['Content-Type' => 'text/calendar'], [Encode::encode_utf8($ical->as_string)]], 
}

1;
